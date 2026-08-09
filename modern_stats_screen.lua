-- Modern Pokemon stats display -- Sp.Atk/Sp.Def, IVs, EVs, Nature,
-- Ability, Item, Tera Type, Dynamax Level, and per-move category, read
-- from the core engine's own src.pokemon.ModernStats/MoveCategory helpers
-- (shared utilities, same placement precedent as src.pokemon.Stats itself
-- -- dv_ev_editor, the reference mod this file's structure is modeled on,
-- requires src.pokemon.Stats directly too).
--
-- Deliberately NOT a core-engine SummaryMenu edit. gen1_modern_ui, when
-- active, completely replaces SummaryMenu's own rendering (its
-- render.compose "removes the classic UI on frames render.hud will
-- actually replace") -- a change baked into SummaryMenu.lua itself would
-- be entirely invisible under that setup, confirmed by reading
-- gen1_modern_ui's own source directly rather than assumed. The correct
-- extension points, also confirmed from source, are:
--   - `mod.hooks:wrap("ui.party.submenu", ...)` (the same core-engine hook
--     dv_ev_editor's own "DV/EV" entry uses) to add a menu item, and
--   - gen1_modern_ui's own public `mod.exports.gen1ModernUi` /
--     `registerAdapter` compatibility contract, so this screen gets the
--     modern list-panel styling instead of raw pixel text when that mod is
--     active. Falls back to a plain mod.ui.Font-drawn screen (same
--     primitives dv_ev_editor uses) when it isn't -- gen1_modern_ui is an
--     optional_dependency in manifest.json, never a hard requirement.
return function(mod)
  local ModernStats = require("src.pokemon.ModernStats")
  local MoveCategory = require("src.pokemon.MoveCategory")
  local Stats = require("src.pokemon.Stats")

  local SCREEN_ID = "GgdModernStats"
  local NONE = "----"

  -- key indexes mon.ivs/mon.evs (modern hp/atk/def/spa/spd/spe naming,
  -- ModernStats.lua's ORDER); statsKey indexes mon.stats, which keeps
  -- Stats.lua's original Gen-1 naming (hp/attack/defense/speed/special)
  -- for the four fields ModernStats.ensure doesn't touch -- only spa/spd
  -- are added under the modern key. Reading stats[key] directly for
  -- atk/def/spe silently read nil (-> 0) here until this fix.
  local STAT_ROWS = {
    { key = "hp", statsKey = "hp", label = "HP" },
    { key = "atk", statsKey = "attack", label = "ATK" },
    { key = "def", statsKey = "defense", label = "DEF" },
    { key = "spa", statsKey = "spa", label = "SP.ATK" },
    { key = "spd", statsKey = "spd", label = "SP.DEF" },
    { key = "spe", statsKey = "speed", label = "SPEED" },
  }

  -- Shared by both the fallback pixel draw and the gen1_modern_ui adapter
  -- model -- one row list, {label=, value=} pairs, read by whichever
  -- renderer is actually active. "list order for easier read": stats
  -- first (each row already lines IV/EV/final stat up side by side via
  -- fixed-width formatting), then the fields with no Gen-1 equivalent,
  -- then moves with PP and category -- explicit user-requested order.
  local function buildRows(game, mon)
    local def = game.data.pokemon[mon.species]
    Stats.ensure(def, mon)
    ModernStats.ensure(def, mon)
    local ivs, evs, stats = mon.ivs or {}, mon.evs or {}, mon.stats or {}

    local rows = {}
    for _, s in ipairs(STAT_ROWS) do
      rows[#rows + 1] = {
        label = s.label,
        value = ("IV %-2d  EV %-3d  STAT %-3d"):format(
          ivs[s.key] or 0, evs[s.key] or 0, stats[s.statsKey] or 0),
      }
    end
    rows[#rows + 1] = { label = "NATURE", value = mon.nature or NONE }
    rows[#rows + 1] = { label = "ABILITY", value = mon.ability or NONE }
    rows[#rows + 1] = { label = "ITEM", value = mon.item or NONE }
    rows[#rows + 1] = { label = "TERA TYPE", value = mon.teraType or NONE }
    rows[#rows + 1] = { label = "DMAX LEVEL",
      value = mon.dynamaxLevel and tostring(mon.dynamaxLevel) or NONE }

    for i = 1, 4 do
      local mv = mon.moves and mon.moves[i]
      if mv then
        local mdef = game.data.moves and game.data.moves[mv.id]
        local cat = mdef and MoveCategory.of(mdef)
        local maxPP = mdef and ((mdef.pp or 0) + (mv.ppUps or 0) * math.floor((mdef.pp or 0) / 5)) or 0
        rows[#rows + 1] = {
          label = mdef and mdef.name or tostring(mv.id),
          value = ("%-3s  PP %d/%d"):format(cat and cat:sub(1, 3):upper() or "---", mv.pp or 0, maxPP),
        }
      else
        rows[#rows + 1] = { label = "-", value = "" }
      end
    end
    return rows
  end

  local Screen = {}
  Screen.__index = Screen
  Screen.isOpaque = true
  Screen.screenId = SCREEN_ID

  function Screen.new(game, mon)
    return setmetatable({ game = game, mon = mon }, Screen)
  end

  function Screen:update()
    local input = self.game.input
    if input:wasPressed("a") or input:wasPressed("b") then
      self.game.stack:pop()
    end
  end

  -- Plain pixel fallback for when gen1_modern_ui isn't active -- suppressed
  -- automatically by that mod's adapter system (canSuppressNative, below)
  -- when it is.
  function Screen:draw()
    local Font = mod.ui.Font
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 160, 144)
    love.graphics.setColor(0, 0, 0, 1)
    local def = self.game.data.pokemon[self.mon.species]
    local name = self.mon.nickname or (def and def.name) or tostring(self.mon.species)
    Font.draw(("MODERN STATS: %s"):format(name), 4, 4)
    local rows = buildRows(self.game, self.mon)
    for i, row in ipairs(rows) do
      local y = 16 + (i - 1) * 8
      Font.draw(row.label, 4, y)
      Font.draw(row.value, 64, y)
    end
    love.graphics.setColor(1, 1, 1, 1)
  end

  local function hasLabel(items, label)
    for _, item in ipairs(items or {}) do
      if item.label == label then return true end
    end
    return false
  end

  mod.hooks:wrap("ui.party.submenu", function(nextFn, game, items, mon, ctx)
    local result = nextFn(game, items, mon, ctx)
    if type(result) ~= "table" then result = items end
    -- Same reasoning as dv_ev_editor's own equivalent guard: a battle's
    -- battler copy is temporary, editing/viewing derived stats there would
    -- read stale data once the battle ends.
    if not (ctx and ctx.battle) and not hasLabel(result, "MODERN") then
      mod.ui.insertAfter(result, "STATS", {
        label = "MODERN",
        onSelect = function(selectedMon, selectedGame)
          selectedGame.stack:push(Screen.new(selectedGame, selectedMon))
        end,
      })
    end
    return result
  end, 0)

  -- gen1_modern_ui integration: registered only if that mod is present
  -- (optional_dependency, manifest.json) -- a plain no-op otherwise, same
  -- convention as every other optional-mod hook in this file.
  local modernUi = mod.find and mod.find("gen1_modern_ui")
  if modernUi and modernUi.exports and type(modernUi.exports.registerAdapter) == "function" then
    local ok, err = modernUi.exports.registerAdapter({
      owner = mod.id,
      contract = {
        -- Required by gen1_modern_ui's own validate(): a contract with no
        -- matching apiVersion (or none at all) is rejected outright
        -- (confirmed from source, not guessed -- API_VERSION = 1 there as
        -- of this mod's installed copy).
        apiVersion = 1,
        screens = {
          [SCREEN_ID] = {
            match = function(state)
              return type(state) == "table" and state.screenId == SCREEN_ID
            end,
            model = function(game, state)
              return {
                title = "MODERN STATS",
                rows = buildRows(state.game or game, state.mon),
                index = 1,
              }
            end,
            canSuppressNative = true,
          },
        },
      },
    })
    if ok then
      mod.log:info("galar_gmax_dex: modern stats screen registered with gen1_modern_ui")
    else
      mod.log:warn("galar_gmax_dex: gen1_modern_ui adapter registration failed: %s", tostring(err))
    end
  end

  mod.log:info("galar_gmax_dex: modern stats screen installed")
end
