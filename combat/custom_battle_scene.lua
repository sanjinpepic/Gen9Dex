-- GalarGmaxDex's own battle scene, gated on the custom_battle_scene
-- option. Pure vanilla battle GUI everywhere -- native draws its own HUD/
-- menu/move list/mimic list/sprites completely unsuppressed and
-- unmodified, no custom panels, no forced layout, no whole-scene zoom, no
-- sprite dragging (removed -- sprites sit at their real native positions
-- now, no offset/drag system at all). One thing lives here:
--   A gimmick menu (Dynamax now; Mega/Z-Move/Tera/whatever else
--      registers into GimmickRing later), injected via START into the
--      vanilla move-select screen for BOTH native layouts (classic/OG and
--      Wide), navigated the same way each layout's own move list already
--      is, drawn with the same native primitives (Font.drawBox/Font.draw/
--      Font.drawCode) native itself uses -- never Theme, never a
--      redesigned look. Gen1 only this pass (OG/Wide are both Gen1-only
--      concepts; Gold's battle UI is a structurally separate class --
--      confirmed via Gen2Compat.lua listing wideLayout as absent on the
--      Gold facade, so it's guarded rather than silently assumed).
--
-- Confirmed directly before writing this (both researched live against
-- BattleState.lua/WideBattle.lua, not assumed) -- and one mistake from an
-- earlier pass corrected here:
--   - Classic's real move box is a VERTICAL LIST -- one column, up to 4
--     rows (BattleState.lua's moveSelect draw: names at a single x,
--     stacked by 8px per row). Native's up/down-only linear cycle with
--     wraparound (A up -> D, D down -> A, A down -> B down -> C down -> D)
--     is CORRECT for that shape -- there was never a bug to fix here. An
--     earlier pass wrongly treated classic's list as a 2x2 grid (same
--     shape as Wide) and "fixed" it into hold-at-the-edge grid behavior,
--     which broke the boundless cycling classic's real 1-column layout is
--     supposed to have. Reverted: classic's real move list is left
--     completely untouched now (native's own linear cycle stands as-is).
--   - Wide's real move box IS a genuine 2x2 grid (WideBattle.lua's
--     drawMoveGrid: two columns, two rows) -- but WideBattle.moveGridIndex
--     isn't direction-SIGN-aware, so pressing left while already in the
--     left column bounces to the right column exactly like pressing right
--     would, instead of holding position. THAT is a real bug, fixed below
--     with a direction-hold-aware grid function (gridStep), applied as a
--     post-nativeUpdate override to self.moveIndex for Wide only.
--   - The gimmick menu itself is drawn in TWO different shapes depending
--     on which layout is active (a vertical list under classic, a 2x2
--     grid under Wide -- see drawGimmickMenu) -- so its own navigation has
--     to match whichever shape it's currently drawn in: linearCycle when
--     drawn as a list, gridStep when drawn as a grid. Using gridStep
--     unconditionally for it (the earlier pass's mistake) was wrong for
--     the same reason it was wrong for classic's real move list.
--   - 4 slots is a hard limit everywhere (box sizes, grid math, even
--     move-learning code) in both layouts -- no room for a "5th move" a
--     gimmick menu could piggyback on. The gimmick menu is its own
--     screen, replacing the move box temporarily (same shape the old
--     ring had), not an extra row squeezed into it.
--   - Wide's own move-box drawing has NO public patch point at all -- it's
--     a private `local function drawTextArea(battle)` inside
--     WideBattle.lua, not a table field, so it can't be monkey-patched
--     the way classic's real BattleState:drawTextArea method can.
--     Solution: don't try to suppress either layout's native drawing at
--     all -- draw the gimmick menu AFTER native's own full draw finishes
--     each frame (wrapping the one shared entry point, BattleState:draw,
--     which both layouts already go through), as an OPAQUE native box in
--     the exact same screen region the move box occupies. Font.drawBox's
--     fill is opaque, so it fully overpaints whatever native just drew
--     there -- one mechanism, works identically for both layouts, no
--     suppression plumbing needed for either.
--
-- GimmickRing's state API (register/unregister/getRegistered/
-- getBattleState/isActivated/markActivated/onActivated/onFocusChanged,
-- exported as mod.exports.gimmickRing) is unchanged in contract --
-- gimmick_dynamax.lua depends on register/markActivated directly.
return function(mod)
  local BattleState = require("src.battle.BattleState")
  local OverworldState = require("src.world.OverworldController")
  local Game = require("src.core.Game")
  local Font = require("src.render.Font")

  -- Confirmed bug, fixed here: this used to be `if BattleState.galarSceneHook
  -- then return end` -- an early RETURN gating the entire rest of this
  -- function, including the fully independent Gen 2 block ~400 lines
  -- below (which the header above already describes as "only installed
  -- if that module loads"). Gen 1 and Gen 2 installation were never
  -- actually independent the way that implied -- they shared one
  -- Gen-1-scoped gate. On any re-init after the first pass (this engine
  -- explicitly supports dev-mode hot reload, src/ui/Screens.lua's own
  -- header), BattleState.galarSceneHook is already true and the whole
  -- function -- Gen 2 block included -- silently returned here forever,
  -- with zero log output. Now only the genuinely Gen 1-specific
  -- installation statements below are skipped on a repeat pass; the
  -- shared GimmickRing setup and the Gen 2 block (already self-gated on
  -- Gen2BattleState.galarSceneHook) always run.
  local skipGen1 = BattleState.galarSceneHook == true
  if not skipGen1 then
    BattleState.galarSceneHook = true
  end

  local function sceneActive()
    return mod.options:get("gimmicks") == "true"
  end

  -- VANILLA ENHANCED (options.lua): a single OG/WIDE choice, not two
  -- independent toggles -- exactly one layout gets the gimmick menu +
  -- free navigation at a time. type(battle.wideLayout) guard: absent on a
  -- Gold battle (Gen2Compat facade), this feature is Gen1-only so the
  -- guard is defensive, not a Gen2 attempt.
  local function enhancedForLayout(battle)
    if not sceneActive() then return false end
    local wide = type(battle.wideLayout) == "function" and battle:wideLayout()
    local chosen = mod.options:get("vanilla_enhanced_layout")
    return (wide and chosen == "wide") or (not wide and chosen == "og")
  end

  ------------------------------------------------------------------
  -- Force the real save.options.battleLayout ("og"/"wide", confirmed
  -- BattleState.lua:63-64, read by BattleState:wideLayout()) to match
  -- VANILLA ENHANCED's choice whenever GIMMICKS is on -- otherwise the
  -- option only ever filters an already-active layout it never actually
  -- sets, so picking WIDE here while the player's own BATTLE LAYOUT
  -- setting is still "og" would silently keep showing OG. Same pattern an
  -- earlier pass here used for forceOG, generalized to whichever value is
  -- chosen instead of hardcoding "og". The native BATTLE LAYOUT options
  -- row is hidden while this manages it, so there's nothing to fall back
  -- out of sync with.
  ------------------------------------------------------------------
  -- Gen 1 only: forces save.options.battleLayout (a Gen 1-only concept --
  -- Gen 2 has no OG/Wide choice at all) and hides the corresponding
  -- options row. Skipped on a repeat install pass (skipGen1) so a
  -- hot-reload never re-wraps OverworldState.pushBattle a second time.
  if not skipGen1 then
    -- TEMPORARY diagnostic logging: two independent static-analysis
    -- passes found this whole forcing/dispatch chain internally
    -- consistent (field names, value comparisons, wrap ordering all
    -- match), yet WIDE is reported not working at all -- so the next
    -- data point has to come from an actual run, not more static
    -- reading. Remove once the real cause is found.
    local function forceChosenLayout()
      local opts = Game and Game.save and Game.save.options
      if not opts then
        mod.log:info("galar_gmax_dex: [diag] forceChosenLayout: no save.options yet")
        return
      end
      if not sceneActive() then
        mod.log:info("galar_gmax_dex: [diag] forceChosenLayout: sceneActive()==false (gimmicks option is off)")
        return
      end
      local wanted = mod.options:get("vanilla_enhanced_layout")
      if wanted ~= "og" and wanted ~= "wide" then
        mod.log:info("galar_gmax_dex: [diag] forceChosenLayout: vanilla_enhanced_layout=%s (not og/wide)",
          tostring(wanted))
        return
      end
      if opts.battleLayout == wanted then
        mod.log:info("galar_gmax_dex: [diag] forceChosenLayout: already %s, no change needed", wanted)
        return
      end
      mod.log:info("galar_gmax_dex: [diag] forceChosenLayout: forcing battleLayout %s -> %s",
        tostring(opts.battleLayout), wanted)
      opts.battleLayout = wanted
      if Game.writeOptions then pcall(Game.writeOptions, Game) end
    end

    local innerPushBattle = OverworldState.pushBattle
    function OverworldState:pushBattle(battle)
      local ok, err = pcall(forceChosenLayout)
      if not ok then
        mod.log:warn("galar_gmax_dex: custom_battle_scene: forceChosenLayout errored: %s", tostring(err))
      end
      return innerPushBattle(self, battle)
    end

    mod.hooks:wrap("ui.options.rows", function(next, game, rows)
      local out = next(game, rows)
      if type(out) ~= "table" or not sceneActive() then return out end
      for i = #out, 1, -1 do
        if type(out[i]) == "table" and out[i].id == "battleLayout" then
          table.remove(out, i)
        end
      end
      return out
    end)
  end

  ------------------------------------------------------------------
  -- GimmickRing state API + paging. registeredGimmicks stays in the same
  -- fixed (priority, then id) order it already sorted to -- that order is
  -- the paging order too, unaffected by which page is currently shown.
  ------------------------------------------------------------------
  local PAGE_SIZE = 4 -- the engine's own hard per-screen cap, matched here

  local registeredGimmicks = {}
  local activatedByBattle = setmetatable({}, { __mode = "k" })
  local onActivatedCallbacks = {}
  local onFocusChangedCallbacks = {}

  local ring = { open = false, page = 1, focus = 1, entries = {}, battle = nil }

  local GimmickRing = {}

  function GimmickRing.register(def)
    if type(def) ~= "table" or type(def.id) ~= "string" then return end
    for i, existing in ipairs(registeredGimmicks) do
      if existing.id == def.id then
        registeredGimmicks[i] = def
        return
      end
    end
    registeredGimmicks[#registeredGimmicks + 1] = def
    table.sort(registeredGimmicks, function(a, b)
      local pa, pb = a.priority or 0, b.priority or 0
      if pa ~= pb then return pa < pb end
      return a.id < b.id
    end)
  end

  function GimmickRing.unregister(id)
    for i, existing in ipairs(registeredGimmicks) do
      if existing.id == id then
        table.remove(registeredGimmicks, i)
        return
      end
    end
  end

  function GimmickRing.getRegistered()
    return registeredGimmicks
  end

  function GimmickRing.getBattleState(battle)
    local activated = activatedByBattle[battle]
    if not activated then
      activated = {}
      activatedByBattle[battle] = activated
    end
    local focusId = nil
    if ring.open and ring.battle == battle then
      local def = ring.entries[ring.focus]
      focusId = def and def.id
    end
    return { focus = focusId, activated = activated }
  end

  function GimmickRing.isActivated(battle, id)
    local activated = activatedByBattle[battle]
    return activated ~= nil and activated[id] == true
  end

  -- Returns true only the first time for a given (battle, id) pair -- an
  -- async mechanic (activate() returning "pending") can safely call this
  -- once its own animation/sequence actually finishes without double-
  -- firing onActivated.
  function GimmickRing.markActivated(battle, id, battler)
    local activated = activatedByBattle[battle]
    if not activated then
      activated = {}
      activatedByBattle[battle] = activated
    end
    if activated[id] then return false end
    activated[id] = true
    local state = GimmickRing.getBattleState(battle)
    for _, fn in ipairs(onActivatedCallbacks) do
      pcall(fn, id, battle, battler, state)
    end
    return true
  end

  function GimmickRing.onActivated(fn)
    onActivatedCallbacks[#onActivatedCallbacks + 1] = fn
  end

  function GimmickRing.onFocusChanged(fn)
    onFocusChangedCallbacks[#onFocusChangedCallbacks + 1] = fn
  end

  mod.exports.gimmickRing = GimmickRing

  local function fireFocusChanged(battle)
    local def = ring.entries[ring.focus]
    local state = GimmickRing.getBattleState(battle)
    for _, fn in ipairs(onFocusChangedCallbacks) do
      pcall(fn, def and def.id, battle, battle.player, state)
    end
  end

  local function totalPages()
    return math.max(1, math.ceil(#registeredGimmicks / PAGE_SIZE))
  end

  -- Wraps page into 1..totalPages, slices the next PAGE_SIZE entries in
  -- registration order into ring.entries, resets focus to the page's
  -- first slot.
  local function showPage(battle, page)
    local pages = totalPages()
    page = ((page - 1) % pages) + 1
    ring.page = page
    ring.entries = {}
    local start = (page - 1) * PAGE_SIZE
    for i = 1, PAGE_SIZE do
      local def = registeredGimmicks[start + i]
      if def then ring.entries[#ring.entries + 1] = def end
    end
    ring.focus = 1
    fireFocusChanged(battle)
  end

  local function openGimmickMenu(battle)
    if #registeredGimmicks == 0 then return false end
    ring.open = true
    ring.battle = battle
    showPage(battle, 1)
    return true
  end

  local function closeGimmickMenu(battle)
    ring.open = false
    local state = GimmickRing.getBattleState(battle)
    for _, fn in ipairs(onFocusChangedCallbacks) do
      pcall(fn, nil, battle, battle.player, state)
    end
  end

  mod.events:on("battle.ended", function(ev)
    if ring.battle == ev.battle then
      ring.open = false
      ring.battle = nil
    end
    activatedByBattle[ev.battle] = nil
  end)

  -- Real Gen 2 Battle class, for telling a Gen 2 battle apart from Gen 1
  -- classic inside drawGimmickMenu below -- both share the same "not
  -- wide" branch today (battle.wideLayout is simply absent for both a
  -- Gen 1 classic battle's OWN check being false and a Gen 2 battle
  -- having no such method at all), but their real move boxes are
  -- DIFFERENT widths (confirmed this session: Gen 1 classic's real move
  -- box is Font.drawBox(4,12,16,6), BattleState.lua:5739; Gen 2's real
  -- move box is the full-width Chrome.box(0,12,20,6), src/ui/gen2/
  -- BattleState.lua:3232) -- so they need their own branch, not to keep
  -- sharing Gen 1 classic's narrower box.
  local gen2BattleOk, Gen2Battle = pcall(require, "src.battle.gen2.Battle")
  Gen2Battle = gen2BattleOk and Gen2Battle or nil
  local function isGen2Battle(battle)
    return Gen2Battle ~= nil and battle ~= nil and getmetatable(battle) == Gen2Battle
  end

  ------------------------------------------------------------------
  -- Gimmick menu drawing: native primitives only, positioned to match
  -- whichever layout is currently showing (see header for why this draws
  -- AFTER native's own full pass instead of suppressing it).
  ------------------------------------------------------------------
  local function drawGimmickMenu(battle)
    local wide = type(battle.wideLayout) == "function" and battle:wideLayout()
    local gen2 = (not wide) and isGen2Battle(battle)
    love.graphics.setColor(1, 1, 1, 1)
    if wide then
      Font.drawBox(0, 13, 28, 5)
    elseif gen2 then
      -- Full 20-tile width (0-160px), matching Gen 2's own real move
      -- box exactly -- the narrower Gen 1 classic box (below) left the
      -- native cursor/held-item marker/partial move name exposed on the
      -- left edge instead of fully occluded, confirmed this session.
      Font.drawBox(0, 12, 20, 6)
    else
      Font.drawBox(4, 12, 16, 6)
    end
    love.graphics.setColor(0, 0, 0, 1)
    for i, def in ipairs(ring.entries) do
      local label = def.label or def.name or def.id
      if wide then
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        Font.draw(label, col == 0 and 16 or 120, 112 + row * 16)
      elseif gen2 then
        -- Tile column 2 -- matches Gen 2's own real per-row move-name
        -- column exactly (src/ui/gen2/BattleState.lua:3273).
        Font.draw(label, 16, 96 + i * 8)
      else
        Font.draw(label, 48, 96 + i * 8)
      end
    end
    if wide then
      local col = (ring.focus - 1) % 2
      local row = math.floor((ring.focus - 1) / 2)
      Font.drawCode(0xED, col == 0 and 8 or 112, 112 + row * 16)
    elseif gen2 then
      -- Tile column 1 -- matches Gen 2's own real cursor column exactly
      -- (src/ui/gen2/BattleState.lua:3261).
      Font.drawCode(0xED, 8, 96 + ring.focus * 8)
    else
      Font.drawCode(0xED, 40, 96 + ring.focus * 8)
    end
    if totalPages() > 1 then
      local pageLabel = ("PAGE %d/%d"):format(ring.page, totalPages())
      local pageX = (wide or gen2) and 16 or 48
      Font.draw(pageLabel, pageX, wide and 152 or 136)
    end
  end

  if not skipGen1 then
    local nativeDraw = BattleState.draw
    function BattleState:draw()
      nativeDraw(self)
      -- TEMPORARY diagnostic, once per battle instance -- see
      -- forceChosenLayout's own comment above for why.
      if not self.__ggdLayoutLogged then
        self.__ggdLayoutLogged = true
        local wideNow = type(self.wideLayout) == "function" and self:wideLayout()
        mod.log:info(
          "galar_gmax_dex: [diag] battle draw: sceneActive=%s wideLayout()=%s vanilla_enhanced_layout=%s enhancedForLayout=%s",
          tostring(sceneActive()), tostring(wideNow), tostring(mod.options:get("vanilla_enhanced_layout")),
          tostring(enhancedForLayout(self)))
      end
      if enhancedForLayout(self) and ring.open and ring.battle == self then
        local ok, err = pcall(drawGimmickMenu, self)
        if not ok then
          mod.log:warn("galar_gmax_dex: custom_battle_scene: drawGimmickMenu errored: %s", tostring(err))
        end
      end
    end
  end

  ------------------------------------------------------------------
  -- Free (direction-hold-aware) 2x2 grid navigation. index/count use the
  -- same 1-based, row-major convention both native layouts already do
  -- (row = floor((i-1)/2), col = (i-1)%2). Holds position when there's no
  -- real neighbor in the pressed direction, instead of native's own
  -- bounce-to-the-other-side behavior on both layouts -- see header for
  -- why this replaces relying on either native function.
  ------------------------------------------------------------------
  local function gridStep(index, count, direction)
    local row = math.floor((index - 1) / 2)
    local col = (index - 1) % 2
    if direction == "left" then
      if col == 1 then return index - 1 end
    elseif direction == "right" then
      local candidate = index + 1
      if col == 0 and candidate <= count then return candidate end
    elseif direction == "up" then
      if row == 1 then
        local candidate = index - 2
        if candidate >= 1 then return candidate end
      end
    elseif direction == "down" then
      if row == 0 then
        local candidate = index + 2
        if candidate <= count then return candidate end
      end
    end
    return index
  end

  -- Classic's real shape: a single vertical column, boundless up/down
  -- cycling (native's own real behavior -- A up -> D, D down -> A). Left/
  -- right have no meaning for one column, so they're simply not read by
  -- callers of this function.
  local function linearCycle(index, count, direction)
    if direction == "up" then
      return index > 1 and index - 1 or count
    elseif direction == "down" then
      return index < count and index + 1 or 1
    end
    return index
  end

  local function pressedDirection(input)
    if input:wasPressed("left") then return "left" end
    if input:wasPressed("right") then return "right" end
    if input:wasPressed("up") then return "up" end
    if input:wasPressed("down") then return "down" end
    return nil
  end

  ------------------------------------------------------------------
  -- BattleState:update wrap: gimmick menu open/page/navigate/confirm/
  -- cancel (drawing handled separately in BattleState:draw above), plus
  -- the free-movement override for the real move list.
  ------------------------------------------------------------------
  if not skipGen1 then
  local nativeUpdate = BattleState.update
  function BattleState:update(dt)
    local onMoveSelect = enhancedForLayout(self) and self.phase == "moveSelect" and not self.demo
      and self.player and self.player.curMoves and #self.player.curMoves >= 1

    if ring.open and ring.battle == self then
      local input = self.game.input
      if input:wasPressed("start") then
        -- Cycle to the next group of up to 4 -- a no-op back to the same
        -- single page whenever 4 or fewer gimmicks are registered.
        showPage(self, ring.page + 1)
      else
        local dir = pressedDirection(input)
        if dir then
          -- Match whichever shape drawGimmickMenu is actually drawing
          -- this battle in (see header) -- grid under Wide, boundless
          -- vertical list under classic.
          local wide = type(self.wideLayout) == "function" and self:wideLayout()
          local newFocus = wide and gridStep(ring.focus, #ring.entries, dir)
            or (dir ~= "left" and dir ~= "right") and linearCycle(ring.focus, #ring.entries, dir)
            or ring.focus
          if newFocus ~= ring.focus then
            ring.focus = newFocus
            fireFocusChanged(self)
          end
        end
      end
      if input:wasPressed("b") then
        closeGimmickMenu(self)
      elseif input:wasPressed("a") then
        local def = ring.entries[ring.focus]
        if def and def.canActivate and def.activate then
          local state = GimmickRing.getBattleState(self)
          local okC, usable = pcall(def.canActivate, self, self.player, state)
          if okC and usable then
            local okA, result = pcall(def.activate, self, self.player, state)
            if okA and (result == true or result == "pending") then
              if result == true then
                GimmickRing.markActivated(self, def.id, self.player)
              end
              closeGimmickMenu(self)
            elseif not okA then
              mod.log:warn("galar_gmax_dex: gimmick '%s' activate errored: %s", def.id, tostring(result))
            end
          end
        end
      end
      -- Sprite frame-cycling is a separate BattleState:update wrap further
      -- down the chain (main.lua's installSpriteAnimation) -- returning
      -- above without calling nativeUpdate freezes it too unless called
      -- directly, same fix the old ring used.
      if mod.exports.advanceBattleSprites then
        pcall(mod.exports.advanceBattleSprites, self, dt)
      end
      return
    end

    if onMoveSelect and self.game.input:wasPressed("start") then
      openGimmickMenu(self)
      return
    end

    -- Free move-list navigation: Wide only. Classic's real move box is a
    -- single vertical column and native's own up/down linear-cycle-with-
    -- wraparound is already correct for that shape (see header) -- left/
    -- right genuinely do nothing there, natively, and that's not a bug.
    -- Wide's real 2x2 grid needs the hold-position fix: read the pressed
    -- direction before nativeUpdate runs (wasPressed is a non-consuming
    -- per-frame edge read, so checking now vs. after makes no difference),
    -- let native's own update run first so PP/disabled-move handling etc.
    -- still work unmodified, then overwrite self.moveIndex with the
    -- correct result.
    local wide = onMoveSelect and type(self.wideLayout) == "function" and self:wideLayout()
    local dir = wide and pressedDirection(self.game.input) or nil
    local before = wide and self.moveIndex or nil

    nativeUpdate(self, dt)

    if dir and self.phase == "moveSelect" and before then
      local count = #self.player.curMoves
      if before > count then before = count end
      self.moveIndex = gridStep(before, count, dir)
    end
  end
  end

  ------------------------------------------------------------------
  -- Gen 2: parallel ring wiring on src.ui.gen2.BattleState, only
  -- installed if that module loads. Gen 2's own move-select is a single
  -- vertical list (self.phase == "moves", confirmed src/ui/gen2/
  -- BattleState.lua:1801-1834) -- the exact same shape classic's OG
  -- layout already has, so this reuses linearCycle and drawGimmickMenu
  -- completely unchanged (drawGimmickMenu's own type(battle.wideLayout)
  -- guard is already false/nil for a Gen 2 pure Battle object, so it
  -- already falls into the correct vertical-list draw branch with no
  -- gen-specific code needed there at all -- no grid shape/free-nav fix
  -- needed either, since Gen 2's own move list already cycles boundlessly
  -- the same way classic's does).
  --
  -- Ring state (ring.battle / activatedByBattle / GimmickRing's own key)
  -- is keyed by self.battle here, NOT the UI screen self -- matching
  -- gigantamax/gimmick_dynamax.lua's own gState[battle] convention
  -- (keyed by the pure Battle object on Gen 2), and matching what the
  -- battle.ended cleanup handler above already compares against
  -- (ev.battle IS the pure Battle object on Gen 2) -- so that handler
  -- needs no Gen-2-specific change to correctly clean up a Gen 2 ring
  -- session too. Gated on sceneActive() alone, not enhancedForLayout --
  -- VANILLA ENHANCED's OG/WIDE choice is a Gen 1-only axis (Gen 2 has no
  -- second layout to choose between), so Gen 2 simply gets the ring
  -- whenever GIMMICKS is on.
  ------------------------------------------------------------------
  local gen2Ok, Gen2BattleState = pcall(require, "src.ui.gen2.BattleState")
  -- Only warn when this SHOULD have been available -- a genuine Red/
  -- Blue/Yellow-only boot never has this file at all, and that's
  -- expected/normal, not worth logging on every single Gen 1 boot.
  if not gen2Ok then
    local GameVersionForScene = require("src.core.GameVersion")
    if GameVersionForScene.generation(GameVersionForScene.get()) == 2 then
      mod.log:warn("galar_gmax_dex: custom_battle_scene: src.ui.gen2.BattleState not available on a gen 2 boot: %s",
        tostring(Gen2BattleState))
    end
  end
  Gen2BattleState = gen2Ok and Gen2BattleState or nil

  -- Confirmed bug, fixed here: Gen2BattleState:draw() is NOT the real
  -- per-frame render entry point for an ordinary solo-battle-state screen.
  -- Game2:drawScene sees BattleState:drawsWidescreen()==true (hardcoded)
  -- and calls battle:drawWidescreen(w,h) directly -- which calls
  -- self:drawScene() itself, never self:draw() -- then only ALSO runs
  -- self.stack:draw() (the thing that would have called our wrapped
  -- :draw()) when a submenu (Pack/Party/Evolution) happens to be pushed on
  -- top too. During plain move-select -- the ring's actual use case -- the
  -- stack is just { Gen2BattleState }, so the old :draw() wrap here never
  -- fired at all; the ring was silently dead outside that submenu-pushed
  -- edge case. Fixed by hooking battle.overlay instead: BattleState.lua's
  -- own drawScene() (src/ui/gen2/BattleState.lua:3334-3345) fires it
  -- unconditionally on every frame, already inside whichever transform
  -- (native fit-scale, same as Gen1's own tail-of-draw battle.overlay
  -- site) is active -- confirmed via direct engine source read, not
  -- assumed. Gen1 keeps its existing BattleState:draw wrap above
  -- unchanged: Game.lua iterates every stack state's own :draw() with no
  -- widescreen bypass, so that path was never actually broken for Gen 1.
  mod.hooks:wrap("battle.overlay", function(next, ctx)
    next(ctx)
    if ctx and ctx.battle and isGen2Battle(ctx.battle)
        and sceneActive() and ring.open and ring.battle == ctx.battle then
      local ok, err = pcall(drawGimmickMenu, ctx.battle)
      if not ok then
        mod.log:warn("galar_gmax_dex: custom_battle_scene: drawGimmickMenu (gen2) errored: %s", tostring(err))
      end
    end
  end)

  if Gen2BattleState and not Gen2BattleState.galarSceneHook then
    Gen2BattleState.galarSceneHook = true

    local nativeGen2Update = Gen2BattleState.update
    function Gen2BattleState:update(dt)
      local battle = self.battle
      local input = self.game and self.game.input

      if battle and input and ring.open and ring.battle == battle then
        if input:wasPressed("start") then
          showPage(battle, ring.page + 1)
        else
          local dir = pressedDirection(input)
          if dir then
            local newFocus = (dir ~= "left" and dir ~= "right")
              and linearCycle(ring.focus, #ring.entries, dir) or ring.focus
            if newFocus ~= ring.focus then
              ring.focus = newFocus
              fireFocusChanged(battle)
            end
          end
        end
        if input:wasPressed("b") then
          closeGimmickMenu(battle)
        elseif input:wasPressed("a") then
          local def = ring.entries[ring.focus]
          if def and def.canActivate and def.activate then
            local state = GimmickRing.getBattleState(battle)
            local okC, usable = pcall(def.canActivate, battle, battle.player, state)
            if okC and usable then
              local okA, result = pcall(def.activate, battle, battle.player, state)
              if okA and (result == true or result == "pending") then
                if result == true then
                  GimmickRing.markActivated(battle, def.id, battle.player)
                end
                closeGimmickMenu(battle)
              elseif not okA then
                mod.log:warn("galar_gmax_dex: gimmick '%s' activate (gen2) errored: %s", def.id, tostring(result))
              end
            end
          end
        end
        if mod.exports.advanceBattleSprites then
          pcall(mod.exports.advanceBattleSprites, battle, dt)
        end
        return
      end

      local onMoveSelect = battle and sceneActive() and self.phase == "moves"
        and #self:playerMoves() >= 1
      if onMoveSelect and input and input:wasPressed("start") then
        openGimmickMenu(battle)
        return
      end

      return nativeGen2Update(self, dt)
    end
  end

  mod.log:info("galar_gmax_dex: custom_battle_scene installed (vanilla GUI, gimmick menu only)")
end
