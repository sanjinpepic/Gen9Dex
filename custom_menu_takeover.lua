-- GalarGmaxDex's own reskin of the title screen menu, the in-game start
-- menu, the options menu, and the mod manager -- gated on the same
-- custom_menu_scene option custom_party_scene.lua uses. Same two-hook
-- pattern as that file (screen.render_visible to hide native draw,
-- render.hud to draw our own after composite); native update()/input is
-- never touched, so cursor movement, scrolling, option stepping, mod
-- toggling, everything already-working keeps working exactly as before
-- -- only the pixels change.
--
-- Ground rules, confirmed against real engine source before writing this:
--   - Title menu AND the in-game start menu are BOTH just instances of
--     the one generic src/ui/Menu.lua class (Menu.new(game, items, opts),
--     self.items/self.index/self.scroll/self.maxVisible) -- confirmed by
--     reading TitleState:openMenu (TitleState.lua:368-407, builds items,
--     Menu.new(...), game.stack:push(menu) -- all inline, the menu is
--     never returned to a caller) and StartMenu.new (StartMenu.lua:19-186,
--     builds items, returns Menu.new(...) directly). Since Menu is also
--     almost certainly used elsewhere (shop lists etc) that this pass
--     hasn't touched, taking over EVERY Menu instance would be too broad
--     -- instead this file tags only the two menus it means to reskin,
--     by wrapping Menu.new itself (stamps __ggdKind from an ambient flag)
--     together with TitleState.openMenu (sets the flag around the vanilla
--     call, since openMenu pushes internally and never hands the menu
--     back) and StartMenu.new (sets the flag around its own vanilla call,
--     simpler since it does return the menu). Every other Menu instance
--     (no __ggdKind stamped) is completely untouched.
--   - src/ui/OptionsMenu.lua: self.game/self.rows/self.index/self.scroll
--     (OptionsMenu.new, line 529-541, 0-based scroll, cursor 1..#rows+1
--     with #rows+1 being a virtual CANCEL row). Row shape:
--     {id=, label=, value=function(game)->string, step=function(game,dir),
--     activate=function(game)}. Left/right/A already drive row.step or
--     row.activate via native update() -- untouched here, only value
--     display is read.
--   - src/mods/ManagerState.lua: self.game/self.screen/self.tab/
--     self.cursor/self.scroll (1-based; ManagerState.new, line 169-180)
--     and the real instance method self:rowsForScreen() (line 388-403),
--     which already dispatches on self.screen/self.tab to whichever of
--     modRows/profileRows/errorRows/detailRows/permissionRows/applyRows
--     applies -- reused directly rather than reimplemented. Row shapes
--     vary (mod/profile/header/inert/action-bearing) but all carry
--     .label, .header, .inert -- enough for a generic display. Overlay
--     shape: self.overlay = {kind="ok"|"confirm", lines={...}, index=}
--     (confirmed at ManagerState.lua:583/601/606).
--   - "MOD MENUS" hub: gen1_modern_ui's own feature (confirmed at that
--     mod's main.lua, ~line 2746-2842), built by wrapping
--     ui.start_menu.items and diffing the post-chain item list against
--     a pre-chain snapshot to find mod-added rows, grouping them behind
--     one synthetic row. Since gen1_modern_ui is not a dependency this
--     project keeps around, this file replicates the same grouping
--     behavior natively: a HIGH-priority ui.start_menu.items wrap runs
--     first in the chain (Hooks.lua sorts descending by priority, so the
--     highest-priority link sees the ORIGINAL unhooked items as its own
--     `items` argument, then calls next() to let every other mod's wrap
--     run before the composed result bubbles back) -- confirmed real,
--     same Hooks:call mechanics GalarGmaxDex's own damage/party hooks
--     already rely on. No pinning (SELECT to promote a row back to
--     top-level) is implemented -- an honest, flagged scope limit, not
--     silently dropped; gen1_modern_ui's own pin persistence is more
--     machinery than this pass needs.
return function(mod, Theme)
  local Menu = require("src.ui.Menu")
  local TitleState = require("src.ui.TitleState")
  local StartMenu = require("src.ui.StartMenu")
  local OptionsMenu = require("src.ui.OptionsMenu")
  local ManagerState = require("src.mods.ManagerState")

  if Menu.galarMenuTakeoverHook then return end
  Menu.galarMenuTakeoverHook = true

  local function sceneActive()
    return mod.options:get("custom_menu_scene") == "true"
  end

  local COLOR_BORDER = Theme.COLOR_BORDER
  local COLOR_TEXT = Theme.COLOR_TEXT
  local COLOR_MUTED = Theme.COLOR_MUTED
  local panel = Theme.panel
  local printText = Theme.printText
  local fitName = Theme.fitName
  local drawCursor = Theme.drawCursor

  ------------------------------------------------------------------
  -- Title menu / start menu tagging (see header comment for why).
  ------------------------------------------------------------------
  local pendingMenuKind = nil

  local vanillaMenuNew = Menu.new
  function Menu.new(...)
    local m = vanillaMenuNew(...)
    if pendingMenuKind then m.__ggdKind = pendingMenuKind end
    return m
  end

  -- TitleState:openMenu (TitleState.lua:368-407) sets menu.titleUiBox =
  -- {0,0,12,th-1} right after building the menu, purely so
  -- TitleState:sgbPalettes (lines 46-81) can carve a GRAYS zone out of
  -- the full-color logo/Pikachu zones for that exact region -- correct
  -- in vanilla because the native box's own opaque white/black fill
  -- covers precisely that region. We fully hide the native box below
  -- (screen.render_visible=false, the plain two-hook technique this
  -- whole takeover is modeled on); with nothing opaque there anymore,
  -- that GRAYS carve-out has nothing to protect and only exposes
  -- whatever's underneath ungrayed -- confirmed live, twice, across two
  -- different suppression techniques. Clearing titleUiBox removes the
  -- carve-out at its source: sgbPalettes then returns its normal 3
  -- full-color zones with no GRAYS region at all, so the logo/Pikachu
  -- render in full color everywhere, including where the (now fully
  -- hidden) box used to sit -- exactly like the rest of a suppressed
  -- screen already does.
  local vanillaOpenMenu = TitleState.openMenu
  function TitleState:openMenu()
    pendingMenuKind = "title"
    local ok, err = pcall(vanillaOpenMenu, self)
    pendingMenuKind = nil
    if not ok then error(err, 0) end
    if sceneActive() then
      local top = self.game and self.game.stack and self.game.stack:top()
      if top then top.titleUiBox = nil end
    end
  end

  local vanillaStartMenuNew = StartMenu.new
  function StartMenu.new(game)
    pendingMenuKind = "start"
    local ok, m = pcall(vanillaStartMenuNew, game)
    pendingMenuKind = nil
    if not ok then error(m, 0) end
    return m
  end

  local MENU_TITLES = { title = "MAIN MENU", start = "PAUSE MENU", modmenus = "MOD MENUS" }

  local function menuActive(state)
    return sceneActive() and getmetatable(state) == Menu and state.__ggdKind ~= nil
  end

  ------------------------------------------------------------------
  -- Menu (title/start/modmenus) goes back to the plain two-hook
  -- technique -- screen.render_visible=false below, render.hud draws
  -- ours -- now that clearing titleUiBox (above) removes the one real
  -- obstacle to it (the GRAYS zone carve-out that only made sense while
  -- the native box was actually opaque). Two earlier attempts at
  -- "keep native drawing for its side effects, hide/replace the pixels"
  -- (full colorMask, then a surgical box-only redraw) both either
  -- bled the zone onto the raw background or left a visible empty native
  -- box/border showing through -- fixing the ROOT cause (the zone
  -- depending on content that no longer exists once we hide the box) is
  -- what actually made full suppression safe, rather than working around
  -- it draw-call by draw-call.
  --
  -- OptionsMenu/ManagerState have no titleUiBox-style zone dependency
  -- reported against them, so they keep the simpler colorMask technique
  -- (full native draw, invisible pixels) -- nothing suggests they need
  -- this same treatment.
  ------------------------------------------------------------------
  local vanillaOptionsDraw = OptionsMenu.draw
  function OptionsMenu:draw()
    if not sceneActive() then return vanillaOptionsDraw(self) end
    love.graphics.push("all")
    love.graphics.setColorMask(false, false, false, false)
    local ok, err = pcall(vanillaOptionsDraw, self)
    love.graphics.pop()
    if not ok then
      mod.log:warn("galar_gmax_dex: custom_menu_takeover: OptionsMenu:draw errored: %s", tostring(err))
    end
  end

  local vanillaManagerDraw = ManagerState.draw
  function ManagerState:draw()
    if not sceneActive() then return vanillaManagerDraw(self) end
    love.graphics.push("all")
    love.graphics.setColorMask(false, false, false, false)
    local ok, err = pcall(vanillaManagerDraw, self)
    love.graphics.pop()
    if not ok then
      mod.log:warn("galar_gmax_dex: custom_menu_takeover: ManagerState:draw errored: %s", tostring(err))
    end
  end

  local function drawGenericMenu(state, x, y, w, h)
    panel(x, y, w, h)
    printText(MENU_TITLES[state.__ggdKind] or "", x + 20, y + 14, 18, COLOR_BORDER)
    local items = state.items or {}
    local visible = state.maxVisible and math.min(state.maxVisible, #items) or #items
    local scroll = state.scroll or 0
    local top = y + 50
    local rowH = math.min(40, (h - 60) / math.max(1, visible))
    for row = 1, visible do
      local i = scroll + row
      local item = items[i]
      if not item then break end
      local ry = top + (row - 1) * rowH
      local selected = i == state.index
      printText(fitName(item.label or "", w - 70, 18), x + 34, ry, 18,
        selected and COLOR_TEXT or COLOR_MUTED)
      if selected then drawCursor(x + 10, ry - 2) end
    end
  end

  ------------------------------------------------------------------
  -- Options menu
  ------------------------------------------------------------------
  local function optionsActive(state)
    return sceneActive() and getmetatable(state) == OptionsMenu
  end

  local function drawOptionsMenu(state, x, y, w, h)
    panel(x, y, w, h)
    printText("OPTIONS", x + 20, y + 14, 20, COLOR_BORDER)
    local rows = state.rows or {}
    local cancelRow = #rows + 1
    local visible = 8
    local scroll = state.scroll or 0
    local top = y + 56
    local rowH = (h - 70) / visible
    for row = 1, visible do
      local i = scroll + row
      if i > cancelRow then break end
      local ry = top + (row - 1) * rowH
      local selected = i == state.index
      if i <= #rows then
        local r = rows[i]
        printText(r.label or "", x + 30, ry, 18, selected and COLOR_TEXT or COLOR_MUTED)
        local ok, val = pcall(r.value, state.game)
        if ok and val then
          printText(fitName(tostring(val), w * 0.4, 17), x + w - 220, ry, 17, COLOR_MUTED)
        end
      else
        printText("CANCEL", x + 30, ry, 18, selected and COLOR_TEXT or COLOR_MUTED)
      end
      if selected then drawCursor(x + 6, ry - 2) end
    end
  end

  ------------------------------------------------------------------
  -- Mod manager
  ------------------------------------------------------------------
  local MANAGER_TABS = { "MODS", "PROFILES", "ERRORS" }

  local function managerActive(state)
    return sceneActive() and getmetatable(state) == ManagerState
  end

  local function drawManagerOverlay(state, x, y, w, h)
    local ov = state.overlay
    if not ov then return end
    local lines = ov.lines or {}
    local pw = 360
    local ph = 60 + #lines * 24 + (ov.kind == "confirm" and 40 or 0)
    local px, py = x + w / 2 - pw / 2, y + h / 2 - ph / 2
    panel(px, py, pw, ph, true)
    for i, line in ipairs(lines) do
      printText(line, px + 20, py + 16 + (i - 1) * 24, 16, Theme.COLOR_TEXT_ON_LIGHT)
    end
    if ov.kind == "confirm" then
      local yesY = py + ph - 36
      printText("YES", px + 60, yesY, 17,
        ov.index == 1 and Theme.COLOR_TEXT_ON_LIGHT or COLOR_MUTED)
      printText("NO", px + 160, yesY, 17,
        ov.index == 2 and Theme.COLOR_TEXT_ON_LIGHT or COLOR_MUTED)
    end
  end

  -- The "options" sub-screen (a mod's own auto-generated settings, opened
  -- from detail's "OPTIONS.." row) is NOT one of rowsForScreen()'s cases
  -- (ManagerState.lua:388-403 only handles list/detail/errors/
  -- permissions/apply, falling through to `return {}` for anything else)
  -- -- it lives in a separate field, self.optionRows, built by
  -- ManagerState:openOptions/:buildOptionRows (lines 991-997) and read by
  -- native draw via OptionRows.draw(self.game, self.optionRows or {}, ...)
  -- (line 1178). Reading rowsForScreen() alone left this screen blank.
  -- Row shape matches OptionsMenu's own (id/label/value/step/activate).
  -- Matching native's own visible-row count is load-bearing, not just
  -- cosmetic: ManagerState:moveCursor only scrolls self.scroll once the
  -- cursor passes scroll+LIST_ROWS-1 (ManagerState.lua:457-458, LIST_ROWS
  -- =11), and updateOptions scrolls via OptionRows.clampScroll against
  -- OptionRows.VISIBLE=4 (OptionRows.lua:14/23-24) -- native decides WHEN
  -- to scroll, we only decide how many rows to draw starting at
  -- state.scroll. An earlier hardcoded `visible = 9` showed fewer rows
  -- than LIST_ROWS=11 actually lets the cursor reach before scrolling,
  -- so the cursor could sit 2-3 rows below the last one drawn with
  -- nothing visibly there yet -- confirmed live, exactly the reported
  -- "have to move 2-3 rows past what's shown" symptom.
  local MANAGER_LIST_ROWS = 11
  local MANAGER_OPTION_ROWS = 4

  local function drawManagerRows(state, rows, x, y, headerY, w, h, isOptionRows)
    local visible = isOptionRows and MANAGER_OPTION_ROWS or MANAGER_LIST_ROWS
    -- ManagerState:goTo (ManagerState.lua:412) seeds self.scroll
    -- DIFFERENTLY per screen: 0 for "options" (matching OptionRows/
    -- OptionsMenu's 0-based convention), 1 for every other sub-screen
    -- (list/detail/errors/permissions/apply). Treating both as 1-based
    -- turned options' already-zero scroll into -1, landing every row
    -- index on rows[0] (always nil) and breaking out before drawing
    -- anything -- the exact cause of the blank options screen.
    local scroll = isOptionRows and (state.scroll or 0) or ((state.scroll or 1) - 1)
    -- `visible` is a scroll-window COUNT (must stay accurate to native,
    -- above), not a layout hint -- stretching rows to fill the whole
    -- panel height (up to ~1000px for 4 option rows) reads as huge gaps
    -- between them. Cap row height at a fixed, comfortable size instead;
    -- any leftover panel space below just stays empty rather than
    -- pulling rows apart.
    local rowH = math.min(46, (h - (headerY - y) - 20) / visible)
    local ry = headerY
    for row = 1, visible do
      local i = scroll + row
      local r = rows[i]
      if not r then break end
      local selected = i == state.cursor
      if r.header then
        printText(r.label or "", x + 20, ry, 15, COLOR_BORDER)
      else
        printText(fitName(r.label or "", w - 90, 17), x + 34, ry, 17,
          r.inert and COLOR_MUTED or (selected and COLOR_TEXT or COLOR_MUTED))
        if isOptionRows and r.value then
          local ok, val = pcall(r.value, state.game)
          if ok and val then
            printText(fitName(tostring(val), w * 0.35, 16), x + w - 240, ry, 16, COLOR_MUTED)
          end
        end
        if selected and not r.inert then drawCursor(x + 10, ry - 2) end
      end
      ry = ry + rowH
    end
  end

  local function drawManagerState(state, x, y, w, h)
    panel(x, y, w, h)
    local headerY = y + 16
    if state.screen == "list" then
      local tabX = x + 24
      for i, name in ipairs(MANAGER_TABS) do
        printText(name, tabX, headerY, 16, i == state.tab and COLOR_TEXT or COLOR_MUTED)
        tabX = tabX + 120
      end
      if state.banner then
        printText(state.banner, x + w - 260, headerY, 14, COLOR_BORDER)
      end
      headerY = headerY + 34
    else
      printText((state.screen or ""):upper(), x + 24, headerY, 18, COLOR_BORDER)
      headerY = headerY + 34
    end
    if state.screen == "options" then
      drawManagerRows(state, state.optionRows or {}, x, y, headerY, w, h, true)
    else
      local ok, rows = pcall(function() return state:rowsForScreen() end)
      if not ok or type(rows) ~= "table" then rows = {} end
      drawManagerRows(state, rows, x, y, headerY, w, h, false)
    end
    drawManagerOverlay(state, x, y, w, h)
  end

  ------------------------------------------------------------------
  -- MOD MENUS hub: high-priority ui.start_menu.items wrap sees the
  -- ORIGINAL vanilla items (it runs first in the sorted chain), snapshots
  -- them, then diffs what comes back through next() to find every row a
  -- mod added (including GalarGmaxDex's own "G9 DEX" row from main.lua).
  -- Those get pulled out of the top-level list and replaced with one
  -- "MOD MENUS" row that pushes a tagged Menu of just the grouped rows --
  -- reusing drawGenericMenu automatically since it's tagged the same way
  -- title/start are.
  ------------------------------------------------------------------
  local function itemKey(item)
    return item.id or ("label:" .. tostring(item.label))
  end

  mod.hooks:wrap("ui.start_menu.items", function(next, game, items)
    local baseline = {}
    for _, it in ipairs(items) do baseline[itemKey(it)] = true end
    local out = next(game, items)
    if type(out) ~= "table" or not sceneActive() then return out end
    local grouped, kept = {}, {}
    for _, it in ipairs(out) do
      if baseline[itemKey(it)] or it.label == "MODS" then
        kept[#kept + 1] = it
      else
        grouped[#grouped + 1] = it
      end
    end
    if #grouped == 0 then return out end
    kept[#kept + 1] = {
      -- Menu:update() calls item.onSelect() with NO arguments (Menu.lua:94
      -- -- every native start/title menu row captures its own `game` via
      -- closure instead) -- this one closes over the `game` this hook was
      -- itself called with, the same convention TitleState/StartMenu's own
      -- item builders use. An earlier version of this took a `selectedGame`
      -- PARAMETER instead, matching the DIFFERENT (mon, game)-args
      -- convention ui.party.submenu entries get -- always nil here since
      -- nothing ever passed it, crashing on `selectedGame.stack:push`.
      label = "MOD MENUS",
      onSelect = function()
        local ok, err = pcall(function()
          pendingMenuKind = "modmenus"
          local menu = Menu.new(game, grouped, { tx = 4, ty = 2, tw = 12 })
          pendingMenuKind = nil
          game.stack:push(menu)
        end)
        if not ok then
          pendingMenuKind = nil
          mod.log:warn("galar_gmax_dex: custom_menu_takeover: MOD MENUS open errored: %s", tostring(err))
        end
      end,
    }
    return kept
  end, 1000)

  ------------------------------------------------------------------
  -- Hooks
  ------------------------------------------------------------------
  -- Menu (title/start/modmenus) is fully hidden here -- safe now that
  -- titleUiBox is cleared above, removing the zone/content mismatch that
  -- broke this the first time. OptionsMenu/ManagerState stay on
  -- colorMask (native draw still runs, invisibly) -- set up in their own
  -- :draw() overrides above, nothing more needed for them here.
  mod.hooks:wrap("screen.render_visible", function(next, state)
    if menuActive(state) then return false end
    return next(state)
  end)

  local function topIf(game, predicate)
    local top = game and game.stack and game.stack.top and game.stack:top()
    if top and predicate(top) then return top end
    return nil
  end

  -- Native Menu draw is fully suppressed again (see the header comment
  -- above), so there's nothing underneath to align pixel-for-pixel with
  -- -- fixed, generously-sized positions per kind, matching the anchor
  -- direction native itself would have used (start = top-right).
  local function windowRect(state, viewport, w, h)
    local kind = state.__ggdKind
    if kind == "start" then
      return w - 460, 20, 430, 420
    end
    return 30, 30, 380, 340
  end

  -- push("all")/pop() around every draw call below: Font.drawBox and
  -- native Menu:draw() both explicitly restore love.graphics.setColor
  -- when they finish (Font.lua/Menu.lua:151), and this file needs the
  -- same discipline -- confirmed live: leaving the last row's
  -- printText/drawCursor color active past the end of this hook bled a
  -- cyan/blue tint into the NEXT frame's world/sprite drawing (render.hud
  -- fires after the canvas->backbuffer blit, so nothing clears it before
  -- the next frame starts). push("all")/pop() is the same guard
  -- custom_battle_scene.lua already uses around its own native-call
  -- wrappers, applied here around OUR OWN drawing instead.
  mod.hooks:wrap("render.hud", function(next, game, viewport)
    next(game, viewport)
    local menuState = topIf(game, menuActive)
    local optState = topIf(game, optionsActive)
    local mgrState = topIf(game, managerActive)
    if not (menuState or optState or mgrState) then return end
    local w, h = love.graphics.getDimensions()
    love.graphics.push("all")
    local ok, err = pcall(function()
      if menuState then
        local mx, my, mw, mh = windowRect(menuState, viewport, w, h)
        drawGenericMenu(menuState, mx, my, mw, mh)
      elseif optState then
        -- Native OptionRows.draw spans most of the 160x144 canvas (4
        -- boxes, each full screen-width) -- covering it needs a near-
        -- fullscreen panel, not a small centered one, now that
        -- OptionsMenu:draw() runs fully normally instead of colorMasked.
        local pad = 20
        drawOptionsMenu(optState, pad, pad, w - pad * 2, h - pad * 2)
      elseif mgrState then
        local pad = 20
        drawManagerState(mgrState, pad, pad, w - pad * 2, h - pad * 2)
      end
    end)
    love.graphics.pop()
    if not ok then
      mod.log:warn("galar_gmax_dex: custom_menu_takeover: draw errored: %s", tostring(err))
    end
  end, 100)

  mod.log:info("galar_gmax_dex: custom_menu_takeover installed (title/start/options/mods)")
end
