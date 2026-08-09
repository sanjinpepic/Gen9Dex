-- GalarGmaxDex's own battle scene, gated on the custom_battle_scene
-- option. Ground rules for this file, all confirmed directly against the
-- real engine source (not the DRAMATIC_SHAPE zip alone) before writing a
-- line of code here, since this session was burned repeatedly by acting
-- on unverified assumptions:
--
-- - There is no public, documented hook for battle-scene VISUALS.
--   battle.overlay (BattleState.lua:5766-5767, WideBattle.lua:372-373) is
--   real and draw-only, but it only ever lets you draw ON TOP of whatever
--   native already drew -- it cannot suppress or replace native's own
--   drawing. Taking the scene over means monkey-patching
--   src.battle.BattleState directly, same as DRAMATIC_SHAPE
--   (lib/OverworldBattle.lua) does. manifest.json already declares the
--   engine_internals permission this needs.
-- - src.world.OverworldController:pushBattle (confirmed,
--   OverworldController.lua:754) pushes a BattleTransition wrapper whose
--   completion callback pushes the real battle state -- wrapping it runs
--   BEFORE the flash/wipe transition even starts, nothing battle-related
--   on screen yet.
-- - save.options.battleLayout (confirmed, BattleState.lua:63-64, read by
--   BattleState:wideLayout()) holds exactly "og" or "wide". Forcing "og"
--   (DRAMATIC_SHAPE's own OverworldBattle.forceOG pattern) means every
--   patch below only ever has ONE native layout to deal with -- WideBattle
--   .lua's drawStatusPanel/drawMessageBox/etc are private locals with no
--   real suppression seam (confirmed and fought at length earlier this
--   session); BattleState:drawTextArea/drawHUDs/drawPicsLayer are real,
--   directly patchable methods, so forcing OG sidesteps that whole class
--   of bug rather than working around it.
-- - ui.options.rows (confirmed, fired at OptionsMenu.lua:532) is the real
--   hook for editing the options-menu row list; DRAMATIC_SHAPE's own
--   main.lua uses it to force OG and drop the BATTLE LAYOUT row while its
--   3D mode is on, so the player is never offered a switch that gets
--   reverted under them. Same pattern here.
-- - Renderer:setWorldOverride(canvas) (confirmed, Renderer.lua:114,
--   consumed at Renderer.lua:856) accepts a canvas already at WINDOW
--   resolution and blits it 1:1 before the normal UI canvas composites
--   over it. The core engine only calls this itself from the overworld's
--   own render pipeline; DRAMATIC_SHAPE calls it manually from its own
--   BattleState:draw patch (OverworldBattle.lua:1310-1312) -- confirmed
--   working, the technique copied here for the backdrop layer.
--
-- PHASE A (confirmed live, working): force OG, hide the layout row, strip
-- the native OG white background fill, hand the renderer a window-
-- resolution placeholder-color canvas.
--
-- PHASE B (this pass): real scene content, fully draggable, filling
-- whatever the current window size is. Three layers, back to front:
--   1. Backdrop -- the Phase A world-override canvas, still window-
--      resolution, rebuilt on resize.
--   2. Sprites -- native's own drawPicsLayer, unmodified placement math,
--      wrapped only in a drag translate. This still renders inside the
--      small 160x144 GB canvas (the letterboxed area within the window),
--      the same as vanilla always has -- native mon art was never meant
--      to be resampled to arbitrary window resolution, and re-placing it
--      there keeps species art crisp instead of blurry/mushy.
--   3. Panels -- HP/name/level (both sides), message box, menu, move
--      select, mimic select. Drawn via render.hud (fires after the whole
--      window composite -- confirmed real, used safely earlier this
--      session) directly in WINDOW pixel space, not the small GB canvas,
--      so they scale with the window instead of being constrained to
--      160x144 -- this is what "fill the screen dynamically" means here.
--      Native's own HUD/text drawing is fully suppressed via colorMask
--      (BattleState:drawTextArea/drawHUDs, real patchable methods --
--      classic-only now, so no cover()-vs-drag gap the way wide layout
--      had earlier this session).
--
-- Every draggable element (sprites AND panels) shares one persisted-
-- position store, split into two coordinate spaces since the layers draw
-- in two different ones: panel positions are absolute WINDOW pixels;
-- sprite offsets are small translate deltas in GB-canvas pixels (added on
-- top of wherever native's own placement math already puts the sprite).
return function(mod, Theme)
  local BattleState = require("src.battle.BattleState")
  local OverworldState = require("src.world.OverworldController")
  local Game = require("src.core.Game")
  local Font = require("src.render.Font")
  local Strings = require("src.core.Strings")
  local TypeChart = require("src.battle.TypeChart")
  local SaveData = require("src.core.SaveData")

  local MOD_ID = "galar_gmax_dex"

  if BattleState.galarSceneHook then return end
  BattleState.galarSceneHook = true

  local function sceneActive()
    return mod.options:get("custom_battle_scene") == "true"
  end

  local function forceOG()
    local opts = Game and Game.save and Game.save.options
    if not opts or opts.battleLayout ~= "wide" then return end
    opts.battleLayout = "og"
    if Game.writeOptions then pcall(Game.writeOptions, Game) end
  end

  ------------------------------------------------------------------
  -- Entry point + options-menu row drop. Unchanged from Phase A.
  ------------------------------------------------------------------
  local innerPushBattle = OverworldState.pushBattle
  function OverworldState:pushBattle(battle)
    if sceneActive() then
      local ok, err = pcall(forceOG)
      if not ok then
        mod.log:warn("galar_gmax_dex: custom_battle_scene: forceOG errored: %s", tostring(err))
      end
    end
    return innerPushBattle(self, battle)
  end

  mod.hooks:wrap("ui.options.rows", function(next, game, rows)
    local out = next(game, rows)
    if type(out) ~= "table" or not sceneActive() then return out end
    pcall(forceOG)
    for i = #out, 1, -1 do
      if type(out[i]) == "table" and out[i].id == "battleLayout" then
        table.remove(out, i)
      end
    end
    return out
  end)

  ------------------------------------------------------------------
  -- Persisted positions: panels (absolute window-pixel x,y) and sprite
  -- offsets (GB-canvas-pixel dx,dy) in one save bucket, two sub-tables.
  ------------------------------------------------------------------
  local panelPositions = {}
  local spriteOffsets = {}
  do
    local ok, opts = pcall(SaveData.loadOptions)
    if ok and opts and opts.modOptions and opts.modOptions[MOD_ID] then
      local saved = opts.modOptions[MOD_ID].scenePositions
      if type(saved) == "table" then
        if type(saved.panels) == "table" then
          for id, p in pairs(saved.panels) do
            if type(p) == "table" and type(p.x) == "number" and type(p.y) == "number" then
              panelPositions[id] = { x = p.x, y = p.y }
            end
          end
        end
        if type(saved.sprites) == "table" then
          for id, p in pairs(saved.sprites) do
            if type(p) == "table" and type(p.dx) == "number" and type(p.dy) == "number" then
              spriteOffsets[id] = { dx = p.dx, dy = p.dy }
            end
          end
        end
      end
    end
  end

  local function persistPositions()
    local ok, opts = pcall(SaveData.loadOptions)
    if not ok or not opts then return end
    opts.modOptions = opts.modOptions or {}
    opts.modOptions[MOD_ID] = opts.modOptions[MOD_ID] or {}
    local panels, sprites = {}, {}
    for id, p in pairs(panelPositions) do panels[id] = { x = p.x, y = p.y } end
    for id, p in pairs(spriteOffsets) do sprites[id] = { dx = p.dx, dy = p.dy } end
    opts.modOptions[MOD_ID].scenePositions = { panels = panels, sprites = sprites }
    pcall(SaveData.saveOptions, opts)
  end

  local function spriteOffset(id)
    local p = spriteOffsets[id]
    if p then return p.dx, p.dy end
    return 0, 0
  end

  ------------------------------------------------------------------
  -- Theme + small drawing helpers (window-pixel scale, generously sized
  -- since this now fills the real window instead of a 160x144 canvas).
  ------------------------------------------------------------------
  -- Pulled from the shared ui_theme.lua module (aliased to local names so
  -- every call site below is unchanged) so this file's look and every
  -- other GalarGmaxDex custom screen's look stay one coherent system.
  local COLOR_PANEL = Theme.COLOR_PANEL
  local COLOR_PANEL_LIGHT = Theme.COLOR_PANEL_LIGHT
  local COLOR_BORDER = Theme.COLOR_BORDER
  local COLOR_TEXT = Theme.COLOR_TEXT
  local COLOR_TEXT_ON_LIGHT = Theme.COLOR_TEXT_ON_LIGHT
  local COLOR_MUTED = Theme.COLOR_MUTED
  local setColor = Theme.setColor
  local panel = Theme.panel
  local fontOf = Theme.fontOf
  local printText = Theme.printText
  local fitName = Theme.fitName
  local drawCursor = Theme.drawCursor
  local drawHPBar = Theme.drawHPBar

  local function shownHP(battler)
    return math.max(0, math.floor((battler.shownHP or battler.mon.hp) or 0))
  end

  -- Font.drawCode is the only way to draw battle.shown -- it holds
  -- pre-encoded glyph codes, not plain strings, and always renders baked
  -- black (confirmed live earlier this session: does not respond to
  -- setColor) -- scaled up so it reads at window resolution instead of
  -- native's tiny 8px-per-glyph size, drawn onto the LIGHT panel variant
  -- so the fixed-black glyphs stay legible.
  local function drawShownLines(battle, x, y, scale)
    setColor(COLOR_TEXT_ON_LIGHT)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(scale, scale)
    local ok, err = pcall(function()
      local off = battle.scrollPx or 0
      local ys = { 0, 16 }
      for li, line in ipairs(battle.shown or {}) do
        local ly = (ys[li] or 16) + off
        for i = 1, #line do
          Font.drawCode(line[i], (i - 1) * 8, ly)
        end
      end
    end)
    love.graphics.pop()
    if not ok then error(err, 0) end
  end

  ------------------------------------------------------------------
  -- Panel drawing + drag/hit-test bookkeeping, window-pixel space.
  ------------------------------------------------------------------
  local activeRects = {}

  local function panelPos(id, defX, defY)
    local p = panelPositions[id]
    if p then return p.x, p.y end
    return defX, defY
  end

  local function window(id, defX, defY, w, h, contentFn, light)
    local x, y = panelPos(id, defX, defY)
    panel(x, y, w, h, light)
    love.graphics.push()
    love.graphics.translate(x, y)
    -- pop() must run even if contentFn() errors -- an unmatched push()
    -- would corrupt every draw call after it for the rest of this frame,
    -- not just this one panel.
    local ok, err = pcall(contentFn)
    love.graphics.pop()
    if not ok then
      mod.log:warn("galar_gmax_dex: custom_battle_scene window '%s' errored: %s", id, tostring(err))
    end
    activeRects[id] = { x = x, y = y, w = w, h = h }
  end

  ------------------------------------------------------------------
  -- Default layout, computed fresh each frame from the current window
  -- size -- once a panel is dragged, its stored absolute position wins
  -- instead (panelPos above), so this only matters before the first drag.
  ------------------------------------------------------------------
  local function defaultRect(id, w, h)
    if id == "enemyHud" then
      return 32, 32, math.min(420, w * 0.34), 110
    elseif id == "playerHud" then
      local pw = math.min(440, w * 0.36)
      return w - pw - 32, h - 250, pw, 130
    elseif id == "messages" then
      return 32, h - 190, w - 64, 158
    elseif id == "menu" then
      return w - 360, h - 190, 328, 158
    elseif id == "moveList" then
      return 32, h - 230, w * 0.55, 198
    elseif id == "moveDetails" then
      local lx = 32 + w * 0.55 + 16
      return lx, h - 230, w - lx - 32, 198
    elseif id == "mimic" then
      return w * 0.5 - 220, h * 0.5 - 150, 440, 240
    end
    return 32, 32, 320, 110
  end

  ------------------------------------------------------------------
  -- Panel content. battle.phase drives which of these shows, exactly
  -- matching vanilla's own mutually-exclusive text-area phases.
  ------------------------------------------------------------------
  local function drawEnemyHud(battle, w, h)
    if not (battle.enemy and not battle.showEnemyTrainer and not battle.enemySendingOut
        and not battle.enemy.fainted) then return end
    local dx, dy, dw, dh = defaultRect("enemyHud", w, h)
    window("enemyHud", dx, dy, dw, dh, function()
      printText(fitName(battle.enemy.name, dw - 120, 24), 16, 12, 24)
      if battle.enemy.shownStatus then
        printText(battle:statusLabel({ status = battle.enemy.shownStatus }), dw - 100, 16, 18, COLOR_BORDER)
      else
        printText("Lv" .. tostring(battle.enemy.mon.level), dw - 80, 16, 18, COLOR_MUTED)
      end
      drawHPBar(16, 56, dw - 32, 30, shownHP(battle.enemy), battle.enemy.mon.stats.hp)
    end)
  end

  local function drawPlayerHud(battle, w, h)
    local hidePlayer = battle.safari or battle.demo or battle.showPlayerBack
    if not (battle.player and not hidePlayer) then return end
    local dx, dy, dw, dh = defaultRect("playerHud", w, h)
    window("playerHud", dx, dy, dw, dh, function()
      printText(fitName(battle.player.name, dw - 120, 24), 16, 12, 24)
      if battle.player.shownStatus then
        printText(battle:statusLabel({ status = battle.player.shownStatus }), dw - 100, 16, 18, COLOR_BORDER)
      else
        printText("Lv" .. tostring(battle.player.mon.level), dw - 80, 16, 18, COLOR_MUTED)
      end
      drawHPBar(16, 56, dw - 32, 30, shownHP(battle.player), battle.player.mon.stats.hp)
      printText(("%d / %d"):format(shownHP(battle.player), battle.player.mon.stats.hp), 16, 96, 18, COLOR_MUTED)
    end)
  end

  local function drawMessages(battle, w, h)
    if not (battle.phase == "messages" and (battle.current or battle.animPlaying or battle.msgHold)) then
      return
    end
    local dx, dy, dw, dh = defaultRect("messages", w, h)
    window("messages", dx, dy, dw, dh, function()
      drawShownLines(battle, 20, 24, 2.4)
      if (battle.msgWaiting or battle.msgPrompt) and battle.frame % 60 < 30 then
        printText("v", dw - 34, dh - 42, 22, COLOR_BORDER)
      end
    end, true)
  end

  local function drawMenu(battle, w, h)
    if not (battle.phase == "menu" and not battle.demo) then return end
    local dx, dy, dw, dh = defaultRect("menu", w, h)
    window("menu", dx, dy, dw, dh, function()
      if battle.safari then
        printText(Strings("BALLx"), 24, 20, 20)
        printText(("%2d"):format(battle.safari.balls), 130, 20, 20)
        printText(Strings("BAIT"), dw / 2 + 16, 20, 20)
        printText(Strings("THROW ROCK"), 24, 70, 20)
        printText(Strings("RUN"), dw / 2 + 16, 70, 20)
        local col = (battle.menuIndex - 1) % 2
        local row = math.floor((battle.menuIndex - 1) / 2)
        drawCursor((col == 0 and 8 or dw / 2), 16 + row * 50)
      else
        printText(Strings("FIGHT"), 60, 20, 22)
        printText(Strings("PKMN"), dw / 2 + 20, 20, 22)
        printText(Strings("ITEM"), 60, 76, 22)
        printText(Strings("RUN"), dw / 2 + 20, 76, 22)
        local col = (battle.menuIndex - 1) % 2
        local row = math.floor((battle.menuIndex - 1) / 2)
        drawCursor((col == 0 and 20 or dw / 2 - 20), 16 + row * 56)
      end
    end)
  end

  local function drawMoveGrid(battle, w, h, moves, selected, idPrefix)
    local dxL, dyL, dwL, dhL = defaultRect("moveList", w, h)
    window(idPrefix .. "List", dxL, dyL, dwL, dhL, function()
      for i, move in ipairs(moves or {}) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local def = battle.data.moves[move.id]
        local mx, my = 24 + col * (dwL / 2), 20 + row * 60
        printText(fitName(def and def.name or move.id or "", dwL / 2 - 60, 20), mx + 30, my, 20)
      end
      local col = (selected - 1) % 2
      local row = math.floor((selected - 1) / 2)
      drawCursor(6 + col * (dwL / 2), 20 + row * 60)
    end)
    local dxD, dyD, dwD, dhD = defaultRect("moveDetails", w, h)
    window(idPrefix .. "Details", dxD, dyD, dwD, dhD, function()
      local move = moves and moves[selected]
      if move then
        local def = battle.data.moves[move.id]
        if def then
          local maxPP = def.pp + (move.ppUps or 0) * math.floor(def.pp / 5)
          printText(("PP %d/%d"):format(move.pp or 0, maxPP), 20, 24, 20)
          printText(fitName(TypeChart.displayName(def.type), dwD - 40, 20), 20, 64, 20, COLOR_BORDER)
        end
      end
    end)
  end

  local function drawScenePanels(battle, w, h)
    drawEnemyHud(battle, w, h)
    drawPlayerHud(battle, w, h)
    drawMessages(battle, w, h)
    drawMenu(battle, w, h)
    if battle.phase == "moveSelect" then
      drawMoveGrid(battle, w, h, battle.player.curMoves, battle.moveIndex, "move")
    elseif battle.phase == "mimicSelect" then
      local dx, dy, dw, dh = defaultRect("mimic", w, h)
      window("mimic", dx, dy, dw, dh, function()
        for i, m in ipairs(battle.mimicMoves) do
          printText(battle.data.moves[m.id].name, 60, 16 + (i - 1) * 40, 20)
        end
        drawCursor(20, 16 + (battle.mimicIndex - 1) * 40)
      end)
    end
  end

  ------------------------------------------------------------------
  -- Native suppression: colorMask blocks every color-channel write
  -- regardless of what color native code sets internally -- confirmed
  -- working technique, used here exactly as it was for classic layout all
  -- session (only classic ever runs now, since forceOG above never lets
  -- wide turn on).
  ------------------------------------------------------------------
  local nativeDrawTextArea = BattleState.drawTextArea
  function BattleState:drawTextArea()
    if not sceneActive() then return nativeDrawTextArea(self) end
    love.graphics.push("all")
    love.graphics.setColorMask(false, false, false, false)
    local ok, err = pcall(nativeDrawTextArea, self)
    love.graphics.pop()
    if not ok then
      mod.log:warn("galar_gmax_dex: custom_battle_scene: hidden drawTextArea errored: %s", tostring(err))
    end
  end

  local nativeDrawHUDs = BattleState.drawHUDs
  function BattleState:drawHUDs(slide)
    if not sceneActive() then return nativeDrawHUDs(self, slide) end
    love.graphics.push("all")
    love.graphics.setColorMask(false, false, false, false)
    local ok, err = pcall(nativeDrawHUDs, self, slide)
    love.graphics.pop()
    if not ok then
      mod.log:warn("galar_gmax_dex: custom_battle_scene: hidden drawHUDs errored: %s", tostring(err))
    end
  end

  ------------------------------------------------------------------
  -- Draggable sprites -- reverted to the simple version on explicit user
  -- direction: no separate offscreen canvas, drawn directly as part of
  -- native's own small-canvas pass, just wrapped in a translate for the
  -- current drag offset (the exact technique already proven earlier this
  -- session). Known, accepted trade-off from this revert: sprites are
  -- again BEHIND the panels drawn in render.hud (panels fire after the
  -- whole window composite, so anything from this normal draw pass is
  -- necessarily under them) -- the separate-canvas version fixed that,
  -- but is reverted here along with the white-background stripping it
  -- was paired with. Flagged, not silently dropped -- revisit if wanted.
  --
  -- classic layout's own drawClassic() always calls drawPicsLayer with NO
  -- onlySide argument (confirmed, three call sites in BattleState.lua) --
  -- forceOG means that is the only shape this ever sees, so the
  -- split-into-two-native-calls technique (confirmed safe earlier this
  -- session: the two side branches share no state beyond a self-contained
  -- scissor save/restore that tolerates running twice) is unconditional.
  ------------------------------------------------------------------
  local spriteRects = {}

  -- skipMenuClip forced true (not passed through): confirmed live via
  -- source (BattleState.lua:5315-5330) that native drawPicsLayer scissors
  -- the pics layer to y<64 (moveSelect) / y<56 (mimicSelect) whenever
  -- skipMenuClip is falsy, specifically to keep sprites from overlapping
  -- native's own move-select/mimic-select box -- confirmed by its own
  -- comment ("clip them to the visible rows"). That box is fully
  -- colorMask-suppressed here (drawTextArea above) and replaced with our
  -- own window-space panel, so there is nothing left for this clip to
  -- protect -- it was only cutting sprites off (reported live: pressing
  -- FIGHT visibly truncated them) for no remaining reason. Classic's own
  -- three call sites never pass this argument at all (confirmed,
  -- BattleState.lua's drawClassic()), so there is no vanilla behavior
  -- being overridden here, only a clip this mod's own suppression made
  -- moot.
  local nativeDrawPicsLayer = BattleState.drawPicsLayer
  function BattleState:drawPicsLayer(slide, sx, sy, onlySide, skipMenuClip)
    if not sceneActive() then
      return nativeDrawPicsLayer(self, slide, sx, sy, onlySide, skipMenuClip)
    end
    spriteRects = {}
    local pdx, pdy = spriteOffset("playerSprite")
    love.graphics.push()
    love.graphics.translate(pdx, pdy)
    local ok1, err1 = pcall(nativeDrawPicsLayer, self, slide, sx, sy, "player", true)
    love.graphics.pop()
    if not ok1 then
      mod.log:warn("galar_gmax_dex: custom_battle_scene: drawPicsLayer (player) errored: %s", tostring(err1))
    end
    spriteRects.playerSprite = { x = pdx, y = 32 + pdy, w = 96, h = 64 }

    local edx, edy = spriteOffset("enemySprite")
    love.graphics.push()
    love.graphics.translate(edx, edy)
    local ok2, err2 = pcall(nativeDrawPicsLayer, self, slide, sx, sy, "enemy", true)
    love.graphics.pop()
    if not ok2 then
      mod.log:warn("galar_gmax_dex: custom_battle_scene: drawPicsLayer (enemy) errored: %s", tostring(err2))
    end
    -- Widened hit-box (kept from the earlier fix): the tight 56x56 "7x7
    -- slot" box only marks where enemyPicXY ANCHORS the sprite -- vertical
    -- padding can push a shorter sprite lower within that slot than the
    -- box assumed, so a click centered on the visible art could miss a
    -- pixel-exact box. Generous on purpose.
    spriteRects.enemySprite = { x = 80 + edx, y = edy, w = 80, h = 96 }
  end

  ------------------------------------------------------------------
  -- Zoom the whole native scene out within the SAME screen footprint --
  -- explicit correction from the earlier per-sprite scale multiplier
  -- ("I dont want a layered reduce, that's NOT what I asked"): what was
  -- actually asked is effectively a bigger virtual canvas at the same
  -- physical size, i.e. a camera zoomed out -- native's entire draw
  -- (background, pics, suppressed HUD/text, anim) renders smaller and
  -- centered within the same native 160x144 logical space, with the
  -- REST of that space filled white first, so nothing changes about the
  -- letterboxed screen area itself -- only how much of it native's
  -- content occupies. resolveBattleScale is untouched.
  --
  -- SCENE_ZOOM = 0.65 -- roughly the requested 30-40% reduction. The
  -- OUTER letterbox blit (viewport.gameX/gameY/gameWidth/gameHeight,
  -- computed by the renderer, unrelated to this file) still maps the
  -- FULL 160x144 logical space to the FULL screen footprint exactly as
  -- before -- this only changes what native draws WITHIN that logical
  -- space, centering it in a smaller sub-region instead of filling it.
  -- colorMode() stays forced false so native's own inner fill is flat
  -- white too, matching the outer white pre-fill with no visible seam.
  ------------------------------------------------------------------
  -- Now a mutable, player-controlled zoom instead of a fixed constant --
  -- see the wheel-zoom section further down. 1.0 = native fills the whole
  -- 160x144 area (no margin, "normal size"); smaller values reveal more
  -- white canvas margin around a proportionally smaller scene -- "make
  -- canvas larger than game screen, so zoom out leaves us more space of
  -- canvas," reusing the same zoom-out-reveals-margin mechanism already
  -- built, just made live-adjustable instead of fixed at 0.65.
  local SCENE_ZOOM = 0.65
  local SCENE_ZOOM_MIN = 0.25
  local SCENE_ZOOM_MAX = 1.0

  local nativeColorMode = BattleState.colorMode
  function BattleState:colorMode()
    if sceneActive() then return false end
    return nativeColorMode(self)
  end

  local nativeDraw = BattleState.draw
  function BattleState:draw()
    if not sceneActive() then return nativeDraw(self) end
    local g = love.graphics
    local offX = 160 * (1 - SCENE_ZOOM) / 2
    local offY = 144 * (1 - SCENE_ZOOM) / 2
    g.push()
    g.setColor(1, 1, 1, 1)
    g.rectangle("fill", 0, 0, 160, 144)
    g.translate(offX, offY)
    g.scale(SCENE_ZOOM, SCENE_ZOOM)
    local ok, err = pcall(nativeDraw, self)
    g.pop()
    if not ok then
      mod.log:warn("galar_gmax_dex: custom_battle_scene: draw errored: %s", tostring(err))
    end
  end

  ------------------------------------------------------------------
  -- Mouse-wheel zoom -- modeled directly on DRAMATIC_SHAPE's own
  -- CamControl.lua router (confirmed real and read directly before
  -- writing this: CamControl.zoomTarget()/zoomBy(), and its own
  -- Game:wheelmoved wrap at CamControl.lua:206-211), simplified for a
  -- flat 2D scene with exactly one target instead of camera-mode
  -- branching (battle/boom/survey/nil) -- there's no first-person/
  -- third-person camera here to hand off to, so sceneZoomTarget() is
  -- just the one gate: is a custom-scene battle currently on top of the
  -- stack. Same sign convention as their own zoomBy: positive notches
  -- zoom OUT (more canvas revealed), negative zoom IN -- and the same
  -- scroll-up-zooms-in mapping their wheelmoved wrap uses (LÖVE's own
  -- wheelmoved dy is positive for upward scroll).
  --
  -- Touch/pinch zoom (their CamControl.lua also wraps touchpressed/
  -- touchmoved/touchreleased with a free-finger table, PINCH_SLACK
  -- threshold, and FirstPerson look-drop/reseat) is NOT implemented here
  -- -- flagged, not silently dropped: that bookkeeping is real and
  -- copyable, but this pass only covers wheel zoom, the directly
  -- testable path. Ask if touch support is wanted and it can be added on
  -- top of the same SCENE_ZOOM/zoomBy this section already provides.
  ------------------------------------------------------------------
  local function sceneZoomTarget()
    local top = Game and Game.stack and Game.stack.top and Game.stack:top()
    return top and getmetatable(top) == BattleState and sceneActive()
  end

  local ZOOM_STEP = 0.05
  local function zoomBy(notches)
    if not notches or notches == 0 then return end
    SCENE_ZOOM = SCENE_ZOOM - notches * ZOOM_STEP
    if SCENE_ZOOM < SCENE_ZOOM_MIN then SCENE_ZOOM = SCENE_ZOOM_MIN end
    if SCENE_ZOOM > SCENE_ZOOM_MAX then SCENE_ZOOM = SCENE_ZOOM_MAX end
  end

  local innerWheelmoved = Game.wheelmoved
  function Game:wheelmoved(dx, dy)
    if sceneZoomTarget() and dy and dy ~= 0 then
      zoomBy(dy > 0 and -1 or 1) -- scroll up (dy>0) zooms in, same convention as CamControl's own wrap
      return
    end
    return innerWheelmoved(self, dx, dy)
  end

  ------------------------------------------------------------------
  -- render.hud: fires after the whole window composite (confirmed real,
  -- used safely this way earlier this session) -- panels draw here, in
  -- raw window-pixel space, on top of everything (including sprites,
  -- which draw earlier as part of the normal pass -- see that patch's own
  -- comment for the known trade-off from the revert).
  ------------------------------------------------------------------
  local cachedViewport = nil

  local function currentBattle(game)
    local top = game and game.stack and game.stack.top and game.stack:top()
    if top and getmetatable(top) == BattleState and sceneActive() then return top end
    return nil
  end

  mod.hooks:wrap("render.hud", function(next, game, viewport)
    next(game, viewport)
    cachedViewport = viewport
    activeRects = {}
    local battle = currentBattle(game)
    if not battle then return end
    local w, h = love.graphics.getDimensions()
    local ok, err = pcall(drawScenePanels, battle, w, h)
    if not ok then
      mod.log:warn("galar_gmax_dex: custom_battle_scene: panel draw errored: %s", tostring(err))
    end
  end, 100)

  -- Two-step reversal of the compound transform BattleState:draw() now
  -- applies: first undo the engine's OWN letterbox mapping (unchanged --
  -- gives the TRUE 160x144 logical point a click landed on), then undo
  -- this file's own extra zoom translate+scale on top of that, to land
  -- back in native's own un-zoomed coordinate space -- the space
  -- spriteRects/drawPicsLayer's own placement math still assumes
  -- unmodified, since drawPicsLayer itself was never touched, only
  -- wrapped in an outer transform it has no awareness of.
  local function windowToCanvas(px, py)
    local vp = cachedViewport
    if not (vp and vp.gameWidth and vp.gameHeight and vp.gameWidth > 0 and vp.gameHeight > 0) then
      return nil, nil
    end
    local trueX = (px - vp.gameX) * (160 / vp.gameWidth)
    local trueY = (py - vp.gameY) * (144 / vp.gameHeight)
    -- Same offX/offY formula BattleState:draw() computes inline each
    -- frame from the CURRENT (mutable, wheel-adjustable) SCENE_ZOOM --
    -- recomputed here rather than cached, so a click is always reversed
    -- against whatever zoom level was actually active when it landed.
    local offX = 160 * (1 - SCENE_ZOOM) / 2
    local offY = 144 * (1 - SCENE_ZOOM) / 2
    return (trueX - offX) / SCENE_ZOOM, (trueY - offY) / SCENE_ZOOM
  end


  local function hitTestPanel(px, py)
    for id, r in pairs(activeRects) do
      if px >= r.x and px <= r.x + r.w and py >= r.y and py <= r.y + r.h then
        return id
      end
    end
    return nil
  end

  local function hitTestSprite(cx, cy)
    if not (cx and cy) then return nil end
    for id, r in pairs(spriteRects) do
      if cx >= r.x and cx <= r.x + r.w and cy >= r.y and cy <= r.y + r.h then
        return id
      end
    end
    return nil
  end

  ------------------------------------------------------------------
  -- input.pointer: drag against activeRects (panels, window space) first,
  -- then spriteRects (sprites, GB-canvas space via windowToCanvas).
  ------------------------------------------------------------------
  local drag = nil

  mod.hooks:wrap("input.pointer", function(next, game, pointer)
    local battle = currentBattle(game)
    if pointer.source ~= "mouse" or not battle then
      return next(game, pointer)
    end
    if pointer.phase == "pressed" then
      local pid = hitTestPanel(pointer.x, pointer.y)
      if pid then
        local x, y = panelPos(pid, activeRects[pid].x, activeRects[pid].y)
        drag = { kind = "panel", id = pid, startX = pointer.x, startY = pointer.y, x0 = x, y0 = y }
        return true
      end
      local cx, cy = windowToCanvas(pointer.x, pointer.y)
      local sid = hitTestSprite(cx, cy)
      if sid then
        local dx0, dy0 = spriteOffset(sid)
        drag = { kind = "sprite", id = sid, startCX = cx, startCY = cy, dx0 = dx0, dy0 = dy0 }
        return true
      end
    elseif pointer.phase == "moved" and drag then
      if drag.kind == "panel" then
        panelPositions[drag.id] = {
          x = drag.x0 + (pointer.x - drag.startX),
          y = drag.y0 + (pointer.y - drag.startY),
        }
      else
        local cx, cy = windowToCanvas(pointer.x, pointer.y)
        if cx and cy then
          spriteOffsets[drag.id] = {
            dx = drag.dx0 + (cx - drag.startCX),
            dy = drag.dy0 + (cy - drag.startCY),
          }
        end
      end
      return true
    elseif pointer.phase == "released" and drag then
      drag = nil
      persistPositions()
      return true
    end
    return next(game, pointer)
  end, 100)

  ------------------------------------------------------------------
  -- Proper directional move-select navigation.
  --
  -- Root-caused live (confirmed by reading BattleState.lua:1794-1987
  -- directly): move-select navigation is handled inline inside
  -- BattleState:update(dt), not a separate method. It branches on
  -- self:wideLayout() -- true, it calls WideBattle.navigate (a real 2D
  -- grid nav with hard boundaries), false (our forced OG case, always),
  -- it falls into a plain elseif chain that only checks "up"/"down" and
  -- CYCLES all 4 slots linearly with wraparound -- "left"/"right" are
  -- never even checked in that branch. That is exactly the reported bug.
  --
  -- WideBattle.navigate/moveGridIndex (WideBattle.lua:393-419) was
  -- considered and rejected as a direct fix: read closely, it does not
  -- check WHICH direction was pressed against the current column/row --
  -- it just unconditionally toggles column-within-row for left OR right,
  -- and row-within-column for up OR down. At slot A (row0,col0), pressing
  -- LEFT would move to B (row0,col1) exactly the same as pressing RIGHT
  -- would -- not the "solid boundary, direction-aware" behavior asked
  -- for. Reimplemented correctly below instead: each of the four
  -- directions is checked against the CURRENT row/col and only moves
  -- when a real neighboring slot exists in that specific direction;
  -- otherwise the index holds and a boundary event fires.
  --
  -- self.game.input is the same input object BattleState:update reads
  -- internally (confirmed, BattleState.lua:1796: `local input =
  -- self.game.input`) -- read independently here, AFTER letting native's
  -- own update run first (so PP checks, A/B/SELECT, disabled-move
  -- handling etc. all still work unmodified), then this overwrites
  -- self.moveIndex with the correct result, replacing whatever native's
  -- own flawed linear cycle computed.
  --
  -- Boundary event: mods may only emit "mod.<their-id>." prefixed events
  -- (confirmed, Loader.lua's events.emit wrapper) -- fired here as
  -- "mod.galar_gmax_dex.moveselect_boundary" with {battle, direction} so
  -- a future integration (folding gimmick_menu's ring menu in, per
  -- explicit user direction -- not attempted in this pass, this is only
  -- the signal it would consume) can listen with
  -- mod.events:on("mod.galar_gmax_dex.moveselect_boundary", fn) and
  -- decide what an out-of-bounds press should open.
  ------------------------------------------------------------------
  local BOUNDARY_EVENT = "mod." .. MOD_ID .. ".moveselect_boundary"

  local function gridNavigate(before, count, input)
    local row = math.floor((before - 1) / 2)
    local col = (before - 1) % 2
    if input:wasPressed("left") then
      if col == 1 then return before - 1, nil end
      return before, "left"
    elseif input:wasPressed("right") then
      local candidate = before + 1
      if col == 0 and candidate <= count then return candidate, nil end
      return before, "right"
    elseif input:wasPressed("up") then
      if row == 1 then
        local candidate = before - 2
        if candidate >= 1 then return candidate, nil end
      end
      return before, "up"
    elseif input:wasPressed("down") then
      if row == 0 then
        local candidate = before + 2
        if candidate <= count then return candidate, nil end
      end
      return before, "down"
    end
    return before, nil
  end

  local nativeUpdate = BattleState.update
  function BattleState:update(dt)
    local navigating = sceneActive() and self.phase == "moveSelect"
      and self.player and self.player.curMoves and #self.player.curMoves >= 1
    local before = navigating and self.moveIndex or nil

    nativeUpdate(self, dt)

    if navigating and self.phase == "moveSelect" and before then
      local moves = self.player.curMoves
      local count = #moves
      -- clamp in case native's own pass (PP/disabled-move handling)
      -- already moved it somewhere our pre-press snapshot doesn't cover
      if before > count then before = count end
      local newIndex, boundary = gridNavigate(before, count, self.game.input)
      self.moveIndex = newIndex
      if boundary then
        pcall(function()
          mod.events:emit(BOUNDARY_EVENT, { battle = self, direction = boundary })
        end)
      end
    end
  end

  mod.log:info("galar_gmax_dex: custom_battle_scene installed (Phase B -- draggable scene)")
end
