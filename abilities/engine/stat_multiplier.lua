-- Dispatch engine for abilities/data/stat_multiplier.lua -- Phase 4 of
-- the ability roadmap. Which stat and by how much are read LIVE from
-- national_dex's own abilityBehaviorOf at read time; only the CONDITION
-- TYPE (weather/terrain/HP-threshold/status/none) is a small hardcoded
-- lookup below, and only because several of these abilities' own
-- `effects[].when` field is empty in the real generated data despite
-- the ability genuinely being conditional (confirmed against each
-- record's own free-text `notes` field, not guessed -- Orichalcum
-- Pulse's and Toxic Boost's own notes explicitly state the real
-- condition even though the structured `when` field carries nothing).
--
-- WHY THIS WRAPS Battle:battleStat, NOT registerDamageModifier: that
-- chain only scales a computed DAMAGE number after the fact; these
-- abilities change the underlying STAT VALUE itself, which feeds
-- multiple unrelated computations (the damage formula's own
-- attack/specialAttack/defense/specialDefense reads, AND turn order's
-- own Speed read) that would otherwise each need their own separate
-- fix. battleStat is the one real, confirmed choke point EVERY one of
-- those already goes through (gen2/Battle.lua's own DoDamage,
-- effectiveSpeed, and confusion self-hit all call it directly) --
-- wrapping it here means every included ability is automatically
-- correct everywhere a stat gets read, with no changes needed at any of
-- those call sites, the same "one real primitive, not a parallel one"
-- discipline this mod already applies everywhere else.
return function(mod, data)
  local abilityIdOf = mod.exports.abilityIdOf
  local abilityBehaviorOf = mod.exports.abilityBehaviorOf
  local currentWeather = mod.exports.currentWeather
  local canonicalStatusOf = mod.exports.canonicalStatusOf
  local isGen2Battle = mod.exports.isGen2Battle
  assert(abilityIdOf and abilityBehaviorOf and currentWeather and canonicalStatusOf,
    "stat_multiplier: modern_combat.lua and status_immunity.lua must load first")

  local Battle = require("src.battle.gen2.Battle")

  -- national_dex's own stat spelling -> Battle:battleStat's own key
  -- convention (confirmed by direct read of gen2/Battle.lua -- distinct
  -- from every OTHER stat-key adapter in this mod, e.g. changeStage's
  -- own "spa"/"spd" shorthand -- battleStat genuinely uses the longer
  -- camelCase form). Evasion/accuracy are deliberately absent: they have
  -- no base stat at all in this engine (stage-only, gen2/Battle.lua's
  -- own vanillaAccuracyRoll reads self.stages[...].evasion directly,
  -- never battleStat) -- see abilities/data/stat_multiplier.lua's own
  -- header for why the three evasion-multiplier abilities are deferred.
  local STAT_TO_BATTLESTAT_KEY = {
    attack = "attack", defense = "defense",
    ["special-attack"] = "specialAttack", ["special-defense"] = "specialDefense",
    speed = "speed",
  }

  local WEATHER_COND = {
    CHLOROPHYLL = "SUN", SWIFTSWIM = "RAIN", SANDRUSH = "SAND", SLUSHRUSH = "SNOW",
    SOLARPOWER = "SUN", ORICHALCUMPULSE = "SUN",
  }
  local TERRAIN_COND = { SURGESURFER = "ELECTRIC" }
  local HP_HALF_COND = { DEFEATIST = true }
  local STATUS_COND = { FLAREBOOST = "burn", TOXICBOOST = "poison" }
  local ANY_STATUS_COND = { QUICKFEET = true }
  local UNCONDITIONAL = { HUGEPOWER = true, PUREPOWER = true, GORILLATACTICS = true }

  local function conditionMet(battle, mon, id, gen2)
    if UNCONDITIONAL[id] then return true end
    local wantWeather = WEATHER_COND[id]
    if wantWeather then return currentWeather(battle, gen2) == wantWeather end
    local wantTerrain = TERRAIN_COND[id]
    if wantTerrain then return battle.terrain == wantTerrain end
    if HP_HALF_COND[id] then
      local m = mon.mon or mon
      local maxHp = m.stats and m.stats.hp
      return maxHp and maxHp > 0 and (m.hp or 0) <= maxHp * 0.5
    end
    local wantStatus = STATUS_COND[id]
    if wantStatus then return canonicalStatusOf(mon) == wantStatus end
    if ANY_STATUS_COND[id] then return canonicalStatusOf(mon) ~= nil end
    return false
  end

  -- statMultiplierFor(battle, mon, battleStatKey) -> number, the product
  -- of every matching, currently-active effect (almost always exactly
  -- one factor or 1 -- no included ability has more than one
  -- stat_multiplier entry for the SAME stat, but this stays correct if
  -- one ever does). Exported directly in case anything else ever needs
  -- to preview a mon's effective stat without going through
  -- Battle:battleStat itself.
  local function statMultiplierFor(battle, mon, battleStatKey)
    local id = abilityIdOf(mon)
    if not (id and data[id]) then return 1 end
    local record = abilityBehaviorOf(mon)
    local behavior = record and record.behaviour
    local effects = behavior and behavior.effects
    if not effects then return 1 end
    local gen2 = isGen2Battle and isGen2Battle(battle)
    local mult = 1
    for _, eff in ipairs(effects) do
      if eff.kind == "stat_multiplier" and eff.factor
          and STAT_TO_BATTLESTAT_KEY[eff.stat] == battleStatKey
          and conditionMet(battle, mon, id, gen2) then
        mult = mult * eff.factor
      end
    end
    return mult
  end
  mod.exports.statMultiplierFor = statMultiplierFor

  -- Real Gen 2 rounding convention already established in this mod
  -- (combat/modern_combat_protect.lua's own Max Guard 25% scale-down:
  -- math.floor(x + 0.5)) -- matched here rather than a bare floor, so a
  -- x1.5/x1.25-shaped boost rounds the same way the rest of this mod
  -- already does.
  local nativeBattleStat = Battle.battleStat
  function Battle:battleStat(mon, key)
    local value = nativeBattleStat(self, mon, key)
    local mult = statMultiplierFor(self, mon, key)
    if mult ~= 1 then
      value = math.floor(value * mult + 0.5)
    end
    return value
  end

  mod.log:info("g9-battle-engine-beta: stat_multiplier installed (14 abilities: CHLOROPHYLL, SWIFTSWIM, SANDRUSH, SLUSHRUSH, SOLARPOWER, SURGESURFER, DEFEATIST, FLAREBOOST, TOXICBOOST, ORICHALCUMPULSE, HUGEPOWER, PUREPOWER, GORILLATACTICS, QUICKFEET)")
end
