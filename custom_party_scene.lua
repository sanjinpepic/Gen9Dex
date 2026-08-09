-- GalarGmaxDex's own party screen, gated on the custom_menu_scene option.
-- Phase 1 of "replicate the battle GUI's look to the rest of the menus"
-- (gen1_modern_ui's own architecture, generalized): a kindFor-style
-- classifier plus the two-hook suppress/replace pattern its own author
-- documents for non-battle screens (no BattleState-style decorate/restore
-- dance needed -- party has no live animation authority underneath it,
-- confirmed by reading src/ui/PartyMenu.lua directly).
--
-- Ground rules, confirmed against real engine source before writing this:
--   - screen.render_visible (src/core/StateStack.lua:46-50): fires once
--     per state per frame as `Runtime.call("screen.render_visible",
--     visibleByDefault, state)`; returning literal `false` hides that
--     state's native :draw() call entirely. Everything else (update,
--     input, the state's own game logic) is untouched -- native still
--     owns the party cursor, A/B handling, submenu logic, HP animations.
--   - render.hud (src/core/Game.lua:521): fires after the whole window
--     composite, in raw window pixel space -- same hook the battle scene
--     already uses for its panels, confirmed real and safe there.
--   - src/ui/PartyMenu.lua: self.party (nil outside link battles --
--     normal play reads game.save.party, same fallback native's own code
--     uses at PartyMenu.lua:259/535), self.index (cursor), self.submenu
--     (true while the STATS/SWITCH/CANCEL popup is up), self.subItems /
--     self.subIndex (that popup's rows + cursor).
--   - src/pokemon/Sprites.lua: Sprites.path(data, species, "front", {mon=,
--     kind=}) is the sanctioned seam for a species' front-sprite path
--     (also honors GalarGmaxDex's own gmax_custom_art hook, since that
--     registers through the same pokemon.sprite Runtime hook). Loaded
--     with a plain love.graphics.newImage + pcall, same as
--     src/ui/SummaryMenu.lua's own sprite load (SummaryMenu.new). No
--     palette/SGB handling needed here -- that pass only touches the
--     paletted GB canvas, and render.hud fires after that canvas is
--     already composited (same reasoning the battle scene's own panels
--     rely on).
--   - src/pokemon/Stats.lua: mon.stats keeps Gen-1-original key names
--     (hp/attack/defense/speed/special). src/pokemon/ModernStats.lua only
--     ADDS mon.stats.spa/spd on top -- it does not alias attack/defense/
--     speed to atk/def/spe. (modern_stats_screen.lua had exactly this
--     mismatch; fixed alongside this file.)
--   - src/pokemon/MoveCategory.lua: MoveCategory.of(moveDef) returns
--     "Physical"/"Special"/"Status" (capitalized) or nil for Gen-1-only
--     moves with no modern category mapped.
return function(mod, Theme)
  local PartyMenu = require("src.ui.PartyMenu")
  local TypeChart = require("src.battle.TypeChart")
  local Sprites = require("src.pokemon.Sprites")
  local Stats = require("src.pokemon.Stats")
  local ModernStats = require("src.pokemon.ModernStats")
  local MoveCategory = require("src.pokemon.MoveCategory")
  local TextBox = require("src.render.TextBox")

  if PartyMenu.galarPartySceneHook then return end
  PartyMenu.galarPartySceneHook = true

  local NONE = "----"

  local function sceneActive()
    return mod.options:get("custom_menu_scene") == "true"
  end

  -- Phase 1 scope: the plain "check your team" party view only. Battle
  -- switch prompts (opts.battle), forced post-faint switch
  -- (opts.forceSwitch) and TM/HM teaching mode (opts.tmhm) each have
  -- their own extra UI (forced-choice framing, ABLE/NOT ABLE column)
  -- this screen doesn't build yet -- falling through to native for those
  -- is an honest, flagged scope limit, not a silent gap. Extending
  -- coverage to them is real follow-up work, not attempted here.
  local function partyActive(state)
    return sceneActive()
      and getmetatable(state) == PartyMenu
      and not state.tmhm
      and not state.battle
      and not state.forceSwitch
  end

  ------------------------------------------------------------------
  -- Local color/panel/text aliases (shared module -- see ui_theme.lua).
  ------------------------------------------------------------------
  local COLOR_BORDER = Theme.COLOR_BORDER
  local COLOR_TEXT = Theme.COLOR_TEXT
  local COLOR_MUTED = Theme.COLOR_MUTED
  local setColor = Theme.setColor
  local panel = Theme.panel
  local printText = Theme.printText
  local fitName = Theme.fitName
  local drawCursor = Theme.drawCursor
  local drawHPBar = Theme.drawHPBar

  ------------------------------------------------------------------
  -- Sprite loading, cached per mon table (weak-keyed so a mon dropped
  -- from the party -- released, boxed -- doesn't pin its image forever).
  ------------------------------------------------------------------
  local spriteCache = setmetatable({}, { __mode = "k" })

  local function spriteFor(game, mon)
    local cached = spriteCache[mon]
    if cached and cached.species == mon.species then return cached.img end
    local def = game.data.pokemon[mon.species]
    local path = def and select(1, Sprites.path(game.data, mon.species, "front",
      { mon = mon, kind = "summary" }))
    local img = nil
    if path then
      local ok, made = pcall(love.graphics.newImage, path)
      if ok then img = made end
    end
    spriteCache[mon] = { species = mon.species, img = img }
    return img
  end

  local function drawSprite(game, mon, x, y, boxSize)
    local img = spriteFor(game, mon)
    if not img then return end
    local iw, ih = img:getDimensions()
    local scale = boxSize / math.max(iw, ih, 1)
    setColor(COLOR_TEXT)
    love.graphics.draw(img, x + (boxSize - iw * scale) / 2, y + (boxSize - ih * scale) / 2,
      0, scale, scale)
  end

  ------------------------------------------------------------------
  -- Animated detail-panel sprite: reuses main.lua's own animated-frame
  -- system (mod.exports.resolveSpritePack/FRAME_DURATION_MS=100, real,
  -- confirmed at main.lua:387-445 -- the same frames the battle intro
  -- cycles through via installSpriteAnimation) instead of the single
  -- static PNG Sprites.path resolves. Only GalarGmaxDex's own custom-art
  -- roster (sprite_frames.lua) has more than one frame per species --
  -- resolveSpritePack returns nil for everything else, so this falls
  -- straight back to the plain static drawSprite for the vanilla 151.
  -- Respects the existing animated_battle_sprites toggle (options.lua)
  -- rather than a separate on/off switch for this one panel. One shared
  -- animState, not per-mon: only the currently-highlighted party member
  -- is ever shown at this size, so switching selection just restarts the
  -- cycle for whichever species is now hovered, same as any Pokedex-style
  -- browse-and-preview screen.
  ------------------------------------------------------------------
  local ANIM_FRAME_MS = 100
  local animFrameCache = {}
  local animState = nil

  local function loadAnimFrame(path)
    local img = animFrameCache[path]
    if img then return img end
    local ok, made = pcall(love.graphics.newImage, path)
    if not ok then return nil end
    if made.setFilter then made:setFilter("nearest", "nearest") end
    animFrameCache[path] = made
    return made
  end

  local function drawAnimatedSprite(game, mon, x, y, boxSize)
    if mod.options:get("animated_battle_sprites") == "false"
        or not (mod.exports and mod.exports.resolveSpritePack) then
      drawSprite(game, mon, x, y, boxSize)
      return
    end
    local pack = mod.exports.resolveSpritePack(mon.species)
    local total = pack and pack.frameCounts and pack.frameCounts.front
    if not (total and total > 1) then
      drawSprite(game, mon, x, y, boxSize)
      return
    end
    if not animState or animState.species ~= mon.species then
      animState = { species = mon.species, frame = 1, elapsed = 0, total = total, framePath = pack.framePath }
    end
    animState.elapsed = animState.elapsed + love.timer.getDelta() * 1000
    local guard = 0
    while animState.elapsed >= ANIM_FRAME_MS and guard < 50 do
      animState.elapsed = animState.elapsed - ANIM_FRAME_MS
      animState.frame = animState.frame < animState.total and animState.frame + 1 or 1
      guard = guard + 1
    end
    local img = loadAnimFrame(animState.framePath("front", animState.frame))
    if not img then
      drawSprite(game, mon, x, y, boxSize)
      return
    end
    local iw, ih = img:getDimensions()
    local scale = boxSize / math.max(iw, ih, 1)
    setColor(COLOR_TEXT)
    love.graphics.draw(img, x + (boxSize - iw * scale) / 2, y + (boxSize - ih * scale) / 2,
      0, scale, scale)
  end

  ------------------------------------------------------------------
  -- Data helpers
  ------------------------------------------------------------------
  local function partyOf(game, state)
    return state.party or (game.save and game.save.party) or {}
  end

  local function typeLine(def)
    if not def or not def.types then return "" end
    local a = def.types[1] and TypeChart.displayName(def.types[1]) or ""
    local b = def.types[2] and TypeChart.displayName(def.types[2])
    return b and (a .. " / " .. b) or a
  end

  local function ensureStats(game, mon)
    local def = game.data.pokemon[mon.species]
    Stats.ensure(def, mon)
    ModernStats.ensure(def, mon)
    return def
  end

  ------------------------------------------------------------------
  -- List panel (left): every party member, cursor on state.index.
  ------------------------------------------------------------------
  local function drawPartyList(game, state, x, y, w, h)
    panel(x, y, w, h)
    local party = partyOf(game, state)
    local rowH = (h - 16) / 6
    for i = 1, 6 do
      local mon = party[i]
      local ry = y + 8 + (i - 1) * rowH
      if mon then
        local def = ensureStats(game, mon)
        drawSprite(game, mon, x + 10, ry, rowH - 6)
        local name = mon.nickname or (def and def.name) or tostring(mon.species)
        printText(fitName(name, w - 130, 18), x + rowH + 4, ry + 4, 18,
          i == state.index and COLOR_TEXT or COLOR_MUTED)
        printText("Lv" .. tostring(mon.level or 1), x + w - 108, ry + 4, 16, COLOR_MUTED)
        printText(("%d/%d"):format(mon.hp or 0, (mon.stats and mon.stats.hp) or 0),
          x + rowH + 4, ry + rowH * 0.5, 16, COLOR_MUTED)
        if i == state.index then
          drawCursor(x - 2, ry + rowH / 2 - 9)
        end
      end
    end
  end

  ------------------------------------------------------------------
  -- Detail panel (right): sprite, name/level/types, HP bar, ability,
  -- ATK/DEF/SPA/SPD/SPE row, up to 4 moves with category + PP.
  ------------------------------------------------------------------
  local function drawPartyDetail(game, state, x, y, w, h)
    panel(x, y, w, h)
    local party = partyOf(game, state)
    local mon = party[state.index]
    if not mon then return end
    local def = ensureStats(game, mon)
    local spriteBox = 96
    drawAnimatedSprite(game, mon, x + 16, y + 16, spriteBox)

    local tx = x + spriteBox + 32
    local name = mon.nickname or (def and def.name) or tostring(mon.species)
    printText(name, tx, y + 20, 26, COLOR_TEXT)
    printText(("Lv %d  %s"):format(mon.level or 1, typeLine(def)), tx, y + 54, 16, COLOR_MUTED)

    local maxHp = (mon.stats and mon.stats.hp) or 0
    drawHPBar(tx, y + 86, w - (tx - x) - 24, 14, mon.hp or 0, maxHp)
    printText(("HP %d/%d"):format(mon.hp or 0, maxHp), tx, y + 104, 16, COLOR_MUTED)

    local rowY = y + spriteBox + 34
    printText(("Ability:   %s"):format(mon.ability or NONE), x + 16, rowY, 18, COLOR_TEXT)

    rowY = rowY + 32
    local stats = mon.stats or {}
    printText(("ATK %-3d  DEF %-3d  SPA %-3d  SPD %-3d  SPE %-3d"):format(
      stats.attack or 0, stats.defense or 0, stats.spa or 0, stats.spd or 0, stats.speed or 0),
      x + 16, rowY, 17, COLOR_TEXT)

    rowY = rowY + 36
    for i = 1, 4 do
      local mv = mon.moves and mon.moves[i]
      if mv then
        local mdef = game.data.moves and game.data.moves[mv.id]
        local cat = mdef and MoveCategory.of(mdef)
        local maxPP = mdef and ((mdef.pp or 0) + (mv.ppUps or 0) * math.floor((mdef.pp or 0) / 5)) or 0
        printText(fitName(mdef and mdef.name or tostring(mv.id), w * 0.5, 17), x + 16, rowY, 17, COLOR_TEXT)
        printText(("%-3s  PP %d/%d"):format(cat and cat:sub(1, 3):upper() or "---", mv.pp or 0, maxPP),
          x + w * 0.58, rowY, 17, COLOR_MUTED)
      end
      rowY = rowY + 28
    end
  end

  ------------------------------------------------------------------
  -- Submenu popup (STATS/SWITCH/CANCEL etc, state.subItems/subIndex) --
  -- native's own overlay for it is part of the same PartyMenu:draw()
  -- this file suppresses, so it needs its own small replacement too,
  -- otherwise pressing A would silently do nothing visible.
  ------------------------------------------------------------------
  local function drawSubmenu(state, x, y, w, h)
    if not state.submenu or not state.subItems or #state.subItems == 0 then return end
    local rowH = 34
    local pw, ph = 220, 16 + #state.subItems * rowH
    local px, py = x + w / 2 - pw / 2, y + h / 2 - ph / 2
    panel(px, py, pw, ph, true)
    for i, item in ipairs(state.subItems) do
      local ry = py + 8 + (i - 1) * rowH
      printText(item.label or "", px + 30, ry + 6, 18,
        i == state.subIndex and Theme.COLOR_TEXT_ON_LIGHT or COLOR_MUTED)
      if i == state.subIndex then
        drawCursor(px + 8, ry + 3, COLOR_BORDER)
      end
    end
  end

  ------------------------------------------------------------------
  -- MOVES takeover: a self-contained read-only move viewer, pushed
  -- instead of moves_manager's own paged Manager screen (confirmed real,
  -- moves_manager/main.lua:534-546 -- registers "MOVES" via this exact
  -- ui.party.submenu hook, pushes its own SCREEN_ID via mod.ui.push).
  -- Only its OWN entry point is replaced (the onSelect closure on the
  -- "MOVES" row); its move-teaching / slot-swap flow is untouched and
  -- simply unreachable from here -- this screen is viewing only, an
  -- honest, flagged scope limit matching exactly what was asked for
  -- (name + PP list, and a type/category/power/accuracy detail panel),
  -- not an attempt to reproduce teach/swap.
  --
  -- Three of the six requested detail fields have NO backing data
  -- anywhere in this engine or in GalarGmaxDex's own move tables --
  -- confirmed by grepping the whole tree, not assumed: no per-move
  -- secondary-effect-chance field, no contact/makesContact flag, and no
  -- move description text (Gen 1's original game never had in-battle
  -- move descriptions; that's a Gen 2+ feature this port hasn't ported).
  -- Those three show the same "----" placeholder Ability already uses
  -- rather than a fabricated number -- flagged here, not silently faked.
  ------------------------------------------------------------------
  local MoveInfoScreen = {}
  MoveInfoScreen.__index = MoveInfoScreen
  MoveInfoScreen.isOpaque = true
  MoveInfoScreen.screenId = "GgdMoveInfo"

  function MoveInfoScreen.new(game, mon)
    return setmetatable({ game = game, mon = mon, index = 1 }, MoveInfoScreen)
  end

  local function moveCount(mon)
    local n = 0
    for i = 1, 4 do
      if mon.moves and mon.moves[i] then n = i end
    end
    return n
  end

  function MoveInfoScreen:update()
    local input = self.game.input
    local n = moveCount(self.mon)
    if n > 0 then
      if input:wasPressed("up") then
        self.index = self.index > 1 and self.index - 1 or n
      elseif input:wasPressed("down") then
        self.index = self.index < n and self.index + 1 or 1
      end
    end
    if input:wasPressed("b") or input:wasPressed("a") then
      self.game.stack:pop()
    end
  end

  local function drawMoveList(game, mon, index, x, y, w, h)
    panel(x, y, w, h)
    local rowH = (h - 16) / 4
    for i = 1, 4 do
      local mv = mon.moves and mon.moves[i]
      if mv then
        local ry = y + 8 + (i - 1) * rowH
        local mdef = game.data.moves and game.data.moves[mv.id]
        local maxPP = mdef and ((mdef.pp or 0) + (mv.ppUps or 0) * math.floor((mdef.pp or 0) / 5)) or 0
        printText(fitName(mdef and mdef.name or tostring(mv.id), w - 130, 18),
          x + 22, ry + rowH / 2 - 10, 18, i == index and COLOR_TEXT or COLOR_MUTED)
        printText(("%d/%d"):format(mv.pp or 0, maxPP), x + w - 96, ry + rowH / 2 - 8, 16, COLOR_MUTED)
        if i == index then drawCursor(x - 2, ry + rowH / 2 - 9) end
      end
    end
  end

  -- Shared by MoveInfoScreen (mon.moves index) and RelearnScreen (a bare
  -- move id from the learnable-move list, no owning slot yet).
  local function drawMoveDetailById(game, moveId, x, y, w, h)
    panel(x, y, w, h)
    local mdef = moveId and game.data.moves and game.data.moves[moveId]
    if not mdef then return end
    local cat = MoveCategory.of(mdef)
    printText(mdef.name or moveId, x + 20, y + 20, 24, COLOR_TEXT)
    printText(("Typing: %s / %s"):format(
      TypeChart.displayName(mdef.type or ""), cat and cat:upper() or NONE),
      x + 20, y + 58, 18, COLOR_TEXT)
    printText(("Pwr: %s"):format(mdef.power and tostring(mdef.power) or NONE),
      x + 20, y + 88, 18, COLOR_TEXT)
    printText(("Acc: %s    effect%%: %s"):format(
      mdef.accuracy and (tostring(mdef.accuracy) .. "%") or NONE, NONE),
      x + 20, y + 114, 18, COLOR_TEXT)
    printText("Contact: " .. NONE, x + 20, y + 140, 18, COLOR_MUTED)
    printText("Description:", x + 20, y + 172, 16, COLOR_MUTED)
    printText("No description data available.", x + 20, y + 192, 16, COLOR_MUTED)
  end

  local function drawMoveDetail(game, mon, index, x, y, w, h)
    local mv = mon.moves and mon.moves[index]
    drawMoveDetailById(game, mv and mv.id, x, y, w, h)
  end

  local function moveInfoActive(state)
    return sceneActive() and getmetatable(state) == MoveInfoScreen
  end

  ------------------------------------------------------------------
  -- RELEARN takeover: reuses relearn_moves' own exported pure functions
  -- (buildRelearnable/applyMove/isHM -- mod.exports, confirmed real at
  -- relearn_moves/main.lua:374-379, documented there as stable enough for
  -- that mod's own headless tests) for all the actual data work, so this
  -- only replaces PRESENTATION -- level+name+PP list without the native
  -- textbox's cramped ticker-scroll on long names, plus the same move
  -- detail panel MoveInfoScreen already draws. The learn/forget-a-slot
  -- flow itself (and its confirmation text) is unchanged, just re-hosted.
  ------------------------------------------------------------------
  local relearnMod = mod.find and mod.find("relearn_moves")

  local RelearnScreen = {}
  RelearnScreen.__index = RelearnScreen
  RelearnScreen.isOpaque = true
  RelearnScreen.screenId = "GgdRelearn"

  function RelearnScreen.new(game, mon)
    local def = game.data.pokemon[mon.species]
    local list = {}
    if relearnMod and relearnMod.exports and relearnMod.exports.buildRelearnable and def then
      local ok, built = pcall(relearnMod.exports.buildRelearnable, game.data, def, mon)
      if ok and type(built) == "table" then list = built end
    end
    return setmetatable({ game = game, mon = mon, list = list, index = 1, forgetting = nil }, RelearnScreen)
  end

  function RelearnScreen:monName()
    local def = self.game.data.pokemon[self.mon.species]
    return self.mon.nickname or (def and def.name) or tostring(self.mon.species)
  end

  function RelearnScreen:update()
    local input = self.game.input
    if self.forgetting then
      local n = #self.mon.moves + 1
      if input:wasPressed("up") then
        self.forgetting.index = self.forgetting.index > 1 and self.forgetting.index - 1 or n
      elseif input:wasPressed("down") then
        self.forgetting.index = self.forgetting.index < n and self.forgetting.index + 1 or 1
      elseif input:wasPressed("b") then
        self.forgetting = nil
      elseif input:wasPressed("a") then
        if self.forgetting.index > #self.mon.moves then
          self.forgetting = nil
        else
          local old = self.mon.moves[self.forgetting.index]
          if relearnMod.exports.isHM(self.game.data, old.id) then
            self.game.stack:push(TextBox.new(self.game, "HM techniques\ncan't be deleted!"))
          else
            local move, slot = self.forgetting.move, self.forgetting.index
            local mdef = self.game.data.moves[move]
            local oldName = self.game.data.moves[old.id].name
            local name = self:monName()
            relearnMod.exports.applyMove(self.game.data, self.mon, move, slot)
            self.game.stack:pop()
            self.game.stack:push(TextBox.new(self.game,
              ("Poof! %s forgot\n%s! And %s\nlearned %s!"):format(name, oldName, name, mdef.name)))
          end
        end
      end
      return
    end
    local n = #self.list
    if n == 0 then
      if input:wasPressed("a") or input:wasPressed("b") then self.game.stack:pop() end
      return
    end
    if input:wasPressed("up") then
      self.index = self.index > 1 and self.index - 1 or n
    elseif input:wasPressed("down") then
      self.index = self.index < n and self.index + 1 or 1
    elseif input:wasPressed("b") then
      self.game.stack:pop()
    elseif input:wasPressed("a") then
      local entry = self.list[self.index]
      if #self.mon.moves < 4 then
        local name = self:monName()
        relearnMod.exports.applyMove(self.game.data, self.mon, entry.move)
        self.game.stack:pop()
        self.game.stack:push(TextBox.new(self.game, ("%s learned\n%s!"):format(name, entry.name)))
      else
        self.forgetting = { move = entry.move, index = 1 }
      end
    end
  end

  local function drawRelearnList(state, x, y, w, h)
    panel(x, y, w, h)
    if #state.list == 0 then
      printText("No moves left to relearn.", x + 20, y + 20, 18, COLOR_MUTED)
      return
    end
    local rowH = math.min(46, (h - 16) / math.max(1, #state.list))
    local visible = math.floor((h - 16) / rowH)
    local scroll = math.max(0, math.min(state.index - 1, #state.list - visible))
    for row = 1, visible do
      local i = scroll + row
      local entry = state.list[i]
      if not entry then break end
      local ry = y + 8 + (row - 1) * rowH
      local selected = i == state.index
      printText(("Lv%-3d"):format(entry.level), x + 22, ry, 17, selected and COLOR_TEXT or COLOR_MUTED)
      printText(entry.name, x + 78, ry, 17, selected and COLOR_TEXT or COLOR_MUTED)
      printText(("PP%d"):format(entry.pp or 0), x + w - 74, ry, 16, COLOR_MUTED)
      if selected then drawCursor(x - 2, ry - 2) end
    end
  end

  local function drawForgetPopup(state, x, y, w, h)
    if not state.forgetting then return end
    local n = #state.mon.moves + 1
    local rowH = 32
    local pw, ph = 260, 16 + n * rowH
    local px, py = x + w / 2 - pw / 2, y + h / 2 - ph / 2
    panel(px, py, pw, ph, true)
    for i = 1, n do
      local ry = py + 8 + (i - 1) * rowH
      local label = i <= #state.mon.moves
        and (state.game.data.moves[state.mon.moves[i].id] or {}).name or "CANCEL"
      printText(label or state.mon.moves[i].id, px + 30, ry + 5, 17,
        i == state.forgetting.index and Theme.COLOR_TEXT_ON_LIGHT or COLOR_MUTED)
      if i == state.forgetting.index then drawCursor(px + 8, ry + 2, COLOR_BORDER) end
    end
  end

  local function relearnActive(state)
    return sceneActive() and getmetatable(state) == RelearnScreen
  end

  ------------------------------------------------------------------
  -- IV/EV editor: replaces dv_ev_editor's own DV(0-15)/Stat-EXP(0-65535)
  -- screen with a real modern IV(0-31)/EV(0-252, 510 total)/nature stat
  -- pipeline -- not a reskin over the old numbers. mon.ivs.hp is edited
  -- directly rather than derived from the other four stats' DV parity
  -- bits (Gen 1's own quirk, confirmed at dv_ev_editor/main.lua:29-34 and
  -- src/pokemon/ModernStats.lua's own deriveHPDV, which now only seeds a
  -- FIRST value for a mon with no modern fields yet -- see
  -- ModernStats.recalcAll's own header for the full reasoning). Editing
  -- through this screen switches that one mon's hp/attack/defense/speed
  -- from Stats.calc's Gen-1 dvs/statExp formula onto the same modern
  -- Gen3+ formula spa/spd already used -- an explicit, per-mon, editor-
  -- triggered opt-in, not a silent global engine change.
  ------------------------------------------------------------------
  local STAT_KEYS = { "hp", "atk", "def", "spa", "spd", "spe" }
  local STAT_LABELS = { hp = "HP", atk = "ATK", def = "DEF", spa = "SPA", spd = "SPD", spe = "SPE" }
  local STATS_FIELD = { hp = "hp", atk = "attack", def = "defense", spa = "spa", spd = "spd", spe = "speed" }

  local IvEvEditor = {}
  IvEvEditor.__index = IvEvEditor
  IvEvEditor.isOpaque = true
  IvEvEditor.screenId = "GgdIvEv"

  function IvEvEditor.new(game, mon)
    local def = game.data.pokemon[mon.species]
    Stats.ensure(def, mon)
    ModernStats.ensure(def, mon)
    return setmetatable({ game = game, mon = mon, def = def, row = 1, col = "iv", editing = false }, IvEvEditor)
  end

  local function evTotal(mon)
    local total = 0
    for _, k in ipairs(STAT_KEYS) do total = total + (mon.evs[k] or 0) end
    return total
  end

  function IvEvEditor:changeValue(delta)
    local key = STAT_KEYS[self.row]
    local mon = self.mon
    if self.col == "iv" then
      mon.ivs[key] = math.max(0, math.min(31, (mon.ivs[key] or 0) + delta))
    else
      local budget = 510 - (evTotal(mon) - (mon.evs[key] or 0))
      mon.evs[key] = math.max(0, math.min(252, math.min(budget, (mon.evs[key] or 0) + delta)))
    end
    local oldMax = mon.stats.hp or 1
    local oldHp = math.max(0, math.min(mon.hp or 0, oldMax))
    local missing = math.max(0, oldMax - oldHp)
    ModernStats.recalcAll(self.def, mon)
    if oldHp <= 0 then
      mon.hp = 0
    else
      mon.hp = math.max(1, mon.stats.hp - missing)
    end
  end

  function IvEvEditor:update()
    local input = self.game.input
    if input:wasPressed("b") then
      if self.editing then self.editing = false else self.game.stack:pop() end
      return
    end
    if self.editing then
      if input:wasPressed("up") then self:changeValue(1)
      elseif input:wasPressed("down") then self:changeValue(-1)
      elseif input:wasPressed("right") then self:changeValue(10)
      elseif input:wasPressed("left") then self:changeValue(-10)
      elseif input:wasPressed("a") then self.editing = false
      end
      return
    end
    if input:wasPressed("up") then
      self.row = self.row > 1 and self.row - 1 or #STAT_KEYS
    elseif input:wasPressed("down") then
      self.row = self.row < #STAT_KEYS and self.row + 1 or 1
    elseif input:wasPressed("left") or input:wasPressed("right") then
      self.col = self.col == "iv" and "ev" or "iv"
    elseif input:wasPressed("a") then
      self.editing = true
    end
  end

  local function drawIvEvEditor(state, x, y, w, h)
    panel(x, y, w, h)
    local mon = state.mon
    printText(("EV TOTAL: %d/510"):format(evTotal(mon)), x + 16, y + 12, 18, COLOR_TEXT)
    local rowH = (h - 56) / #STAT_KEYS
    for i, key in ipairs(STAT_KEYS) do
      local ry = y + 48 + (i - 1) * rowH
      local selected = state.row == i
      local ivHighlight = selected and state.col == "iv"
      local evHighlight = selected and state.col == "ev"
      printText(STAT_LABELS[key], x + 16, ry, 18, selected and COLOR_TEXT or COLOR_MUTED)
      printText(("IV %2d"):format(mon.ivs[key] or 0), x + 90, ry, 17,
        ivHighlight and (state.editing and COLOR_TEXT or COLOR_BORDER) or COLOR_MUTED)
      printText(("EV %3d"):format(mon.evs[key] or 0), x + 180, ry, 17,
        evHighlight and (state.editing and COLOR_TEXT or COLOR_BORDER) or COLOR_MUTED)
      printText(("STAT %4d"):format(mon.stats[STATS_FIELD[key]] or 0), x + w - 150, ry, 17, COLOR_TEXT)
      if selected then drawCursor(x - 2, ry - 2) end
    end
    printText(state.editing
      and "UP/DOWN +-1   LEFT/RIGHT +-10   A/B DONE"
      or "UP/DOWN ROW   LEFT/RIGHT IV/EV   A EDIT",
      x + 16, y + h - 28, 14, COLOR_MUTED)
  end

  local function ivEvActive(state)
    return sceneActive() and getmetatable(state) == IvEvEditor
  end

  ------------------------------------------------------------------
  -- Submenu item list: strip the now-redundant STATS/MODERN rows (this
  -- screen's own detail card already covers both), add a placeholder
  -- HELD ITEM row for later item-equip work, and redirect the MOVES row
  -- (added by moves_manager) at this screen instead of that mod's own.
  -- Gated on sceneActive() so with the custom screens off, every one of
  -- these mods' rows behaves exactly as it always has.
  ------------------------------------------------------------------
  mod.hooks:wrap("ui.party.submenu", function(nextFn, game, items, mon, ctx)
    local result = nextFn(game, items, mon, ctx)
    if type(result) ~= "table" or not sceneActive() or (ctx and ctx.battle) then
      return result
    end
    for i = #result, 1, -1 do
      local label = result[i].label
      if label == "STATS" or label == "MODERN" then
        table.remove(result, i)
      elseif label == "MOVES" then
        result[i].onSelect = function(selectedMon, selectedGame)
          selectedGame.stack:push(MoveInfoScreen.new(selectedGame, selectedMon))
        end
      elseif label == "RELEARN" then
        result[i].onSelect = function(selectedMon, selectedGame)
          selectedGame.stack:push(RelearnScreen.new(selectedGame, selectedMon))
        end
      elseif label == "DV/EV" then
        result[i].label = "IV/EV"
        result[i].onSelect = function(selectedMon, selectedGame)
          selectedGame.stack:push(IvEvEditor.new(selectedGame, selectedMon))
        end
      end
    end
    mod.ui.insertAfter(result, "SWITCH", { label = "HELD ITEM" })
    return result
  end, 100)

  ------------------------------------------------------------------
  -- Hooks
  ------------------------------------------------------------------
  mod.hooks:wrap("screen.render_visible", function(next, state)
    if partyActive(state) or moveInfoActive(state) or relearnActive(state) or ivEvActive(state) then
      return false
    end
    return next(state)
  end)

  local function topIf(game, predicate)
    local top = game and game.stack and game.stack.top and game.stack:top()
    if top and predicate(top) then return top end
    return nil
  end

  mod.hooks:wrap("render.hud", function(next, game, viewport)
    next(game, viewport)
    local partyState = topIf(game, partyActive)
    local moveState = topIf(game, moveInfoActive)
    local relearnState = topIf(game, relearnActive)
    local ivEvState = topIf(game, ivEvActive)
    if not (partyState or moveState or relearnState or ivEvState) then return end
    local w, h = love.graphics.getDimensions()
    local ok, err = pcall(function()
      local pad = 20
      love.graphics.setColor(0.03, 0.03, 0.05, 1)
      love.graphics.rectangle("fill", 0, 0, w, h)
      local listW = w * 0.42
      if partyState then
        drawPartyList(game, partyState, pad, pad, listW, h - pad * 2)
        drawPartyDetail(game, partyState, pad * 2 + listW, pad, w - listW - pad * 3, h - pad * 2)
        drawSubmenu(partyState, 0, 0, w, h)
      elseif moveState then
        drawMoveList(game, moveState.mon, moveState.index, pad, pad, listW, h - pad * 2)
        drawMoveDetail(game, moveState.mon, moveState.index, pad * 2 + listW, pad,
          w - listW - pad * 3, h - pad * 2)
      elseif relearnState then
        drawRelearnList(relearnState, pad, pad, listW, h - pad * 2)
        local entry = relearnState.list[relearnState.index]
        drawMoveDetailById(game, entry and entry.move, pad * 2 + listW, pad,
          w - listW - pad * 3, h - pad * 2)
        drawForgetPopup(relearnState, 0, 0, w, h)
      elseif ivEvState then
        drawIvEvEditor(ivEvState, pad, pad, w - pad * 2, h - pad * 2)
      end
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: custom_party_scene: draw errored: %s", tostring(err))
    end
  end, 100)

  mod.log:info("galar_gmax_dex: custom_party_scene installed (Phase 1 -- party overview)")
end
