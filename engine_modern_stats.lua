-- Modern (Gen 3+ style) stat fields, layered ADDITIVELY alongside the
-- existing Gen-1-exact src/pokemon/Stats.lua -- nothing here replaces
-- dvs/statExp/stats.special, which stay exactly as they are today and keep
-- driving the native, non-Showdown battle engine unchanged. This module is
-- purely new fields for save persistence + GUI display (SummaryMenu page
-- 3), per the explicit user decision that stats.special is "silently
-- deprecated" going forward without touching anything that already reads
-- it.
--
-- Every Pokemon gets modern data, not just ones that have been through a
-- Showdown battle: a mon with no Showdown-native ivs/evs/nature has them
-- DERIVED from its existing Gen 1 dvs/statExp (explicit user decision).
-- Conversion is linear and applied once, then cached on the mon table --
-- same "derive on demand, idempotent after" contract as Stats.ensure.
--
-- Lives in GalarGmaxDex's own folder, not the engine tree -- registered
-- into package.preload["src.pokemon.ModernStats"] by main.lua so every
-- require("src.pokemon.ModernStats") call site (this mod's own files, and
-- SaveData.validate's wrap in save_scrub.lua) resolves to this file
-- without needing the engine's own src/pokemon/ to carry it. Keeps the
-- engine tree byte-for-byte stock -- see save_scrub.lua's header for why
-- that split happened and what it replaces.

local ModernStats = {}

local ORDER = { "hp", "atk", "def", "spa", "spd", "spe" }
ModernStats.ORDER = ORDER

-- Gen 1 dvs/statExp keys -> the modern stat key(s) each one seeds.
-- attack/defense/speed/hp convert 1:1; special seeds BOTH spa and spd
-- (explicit user decision: same source DV, same converted grade, applied
-- to both -- not split). statExp.special is the one exception that DOES
-- split, handled separately below since it's a single value dividing into
-- two EVs rather than one value copied into two IVs.
local DV_SOURCE = { hp = "hp", atk = "attack", def = "defense", spe = "speed" }

local function convertDV(dv)
  -- 0-15 -> 0-31, linear: DV 15 -> IV 31 exactly, DV 0 -> IV 0.
  return math.floor((tonumber(dv) or 0) * 31 / 15 + 0.5)
end

local function convertStatExp(exp)
  -- 0-65535 -> 0-252, linear.
  return math.floor((tonumber(exp) or 0) * 252 / 65535 + 0.5)
end

-- Gen 1 has no HP DV field of its own (macros/ram.asm derives it from the
-- low bits of the other four, src/pokemon/Stats.lua:19-20) -- reuse the
-- same derivation so a converted HP IV isn't just left at 0.
local function deriveHPDV(dvs)
  dvs = dvs or {}
  return ((dvs.attack or 0) % 2) * 8 + ((dvs.defense or 0) % 2) * 4 +
         ((dvs.speed or 0) % 2) * 2 + ((dvs.special or 0) % 2)
end

-- Nature multipliers, only for the two stats this module actually
-- computes (spa/spd) -- a mon converted from legacy data has no nature
-- (nothing in Gen 1 to derive one from) and gets the neutral 1.0
-- multiplier; a Showdown-created mon (Phase 4) carries a real nature.
local NATURE_SPA = {
  Modest = 1.1, Mild = 1.1, Rash = 1.1, Quiet = 1.1,
  Adamant = 0.9, Jolly = 0.9, Careful = 0.9, Timid = 0.9,
}
local NATURE_SPD = {
  Calm = 1.1, Careful = 1.1, Sassy = 1.1, Gentle = 1.1,
  Naive = 0.9, Lax = 0.9, Rash = 0.9, Hasty = 0.9,
}

local function natureMult(nature, statKey)
  if not nature then return 1.0 end
  if statKey == "spa" then return NATURE_SPA[nature] or 1.0 end
  if statKey == "spd" then return NATURE_SPD[nature] or 1.0 end
  return 1.0
end

-- Standard Gen 3+ stat formula (bulbapedia "Statistic#Determination of
-- values"), applied only to spa/spd here -- hp/atk/def/spe keep coming
-- from the untouched Gen 1 Stats.calc.
local function calcModernStat(base, iv, ev, level, nature, statKey)
  local v = math.floor((2 * base + iv + math.floor(ev / 4)) * level / 100) + 5
  return math.floor(v * natureMult(nature, statKey))
end

-- Fills mon.ivs, mon.evs, mon.stats.spa, mon.stats.spd ONLY if missing --
-- a mon already carrying real (Showdown-native) values is returned
-- untouched, same contract as Stats.ensure.
--
-- baseSpa/baseSpd both read from speciesDef.baseStats.special: this
-- codebase's species data has one Gen 1 "special" base stat, not a modern
-- split, and there's no separate modern pokedex wired in yet (that's a
-- larger data-import task, not part of this pass) -- using the same base
-- for both matches the real games' own Gen 1 -> Gen 2 conversion, which
-- set Sp. Atk and Sp. Def equal to the original Special for these species.
function ModernStats.ensure(speciesDef, mon)
  if type(mon) ~= "table" then return mon end

  local needIvs = type(mon.ivs) ~= "table"
  local needEvs = type(mon.evs) ~= "table"
  if needIvs or needEvs then
    local dvs = mon.dvs or {}
    local statExp = mon.statExp or {}
    mon.ivs = mon.ivs or {}
    mon.evs = mon.evs or {}
    for _, key in ipairs(ORDER) do
      if key == "spa" or key == "spd" then
        if mon.ivs[key] == nil then mon.ivs[key] = convertDV(dvs.special) end
      else
        local dvKey = DV_SOURCE[key]
        local dv = (key == "hp") and deriveHPDV(dvs) or dvs[dvKey]
        if mon.ivs[key] == nil then mon.ivs[key] = convertDV(dv) end
      end
    end
    if mon.evs.spa == nil or mon.evs.spd == nil then
      local totalEV = convertStatExp(statExp.special)
      local spaEV = math.floor(totalEV / 2)
      if mon.evs.spa == nil then mon.evs.spa = spaEV end
      if mon.evs.spd == nil then mon.evs.spd = totalEV - spaEV end
    end
    for _, key in ipairs({ "hp", "atk", "def", "spe" }) do
      if mon.evs[key] == nil then
        mon.evs[key] = convertStatExp(statExp[DV_SOURCE[key]])
      end
    end
  end

  if type(speciesDef) == "table" and type(speciesDef.baseStats) == "table" then
    mon.stats = mon.stats or {}
    local base = speciesDef.baseStats.special
    local level = mon.level or 1
    if mon.stats.spa == nil then
      mon.stats.spa = calcModernStat(base, mon.ivs.spa, mon.evs.spa, level, mon.nature, "spa")
    end
    if mon.stats.spd == nil then
      mon.stats.spd = calcModernStat(base, mon.ivs.spd, mon.evs.spd, level, mon.nature, "spd")
    end
  end

  return mon
end

-- Standard Gen 3+ HP formula (bulbapedia "Statistic#Determination of
-- values") -- different additive term from the other five stats, no
-- nature multiplier. base 1/level<=0 guarded the same way calcModernStat
-- implicitly is (base is always a real species number in practice).
local function calcModernHP(base, iv, ev, level)
  return math.floor((2 * (base or 1) + iv + math.floor(ev / 4)) * (level or 1) / 100) + (level or 1) + 10
end

-- Full recompute of all six stats from mon.ivs/mon.evs/mon.level/mon.nature,
-- UNCONDITIONALLY overwriting mon.stats (unlike .ensure's fill-only-if-
-- missing contract) -- for an explicit editor commit, not passive
-- derivation. attack/defense/speed/hp keep Stats.lua's original Gen-1 key
-- names since that's what the rest of the engine (Damage.lua, the battle
-- HUD, TrainerAI) reads; spa/spd use the modern keys ModernStats.ensure
-- already established. Once a mon has been through this path its
-- hp/attack/defense/speed no longer come from Stats.calc's dvs/statExp
-- formula -- an explicit, editor-triggered opt-in per mon, not a global
-- engine change (a mon nobody ever opens this editor for keeps its
-- original Gen-1-formula stats exactly as before).
--
-- mon.ivs.hp is a real, independently-set field here (0-31, whatever the
-- player last chose) -- NOT re-derived from the other four stats' DV
-- parity bits the way Gen 1's own HP DV was. That derivation only ever
-- runs once, in .ensure, to seed a first value for a mon that has never
-- had modern fields before; every recalcAll after that trusts mon.ivs.hp
-- as edited.
function ModernStats.recalcAll(speciesDef, mon)
  if type(mon) ~= "table" then return mon end
  if type(speciesDef) ~= "table" or type(speciesDef.baseStats) ~= "table" then return mon end
  mon.ivs = mon.ivs or {}
  mon.evs = mon.evs or {}
  mon.stats = mon.stats or {}
  local base = speciesDef.baseStats
  local level = mon.level or 1
  mon.stats.hp = calcModernHP(base.hp, mon.ivs.hp or 0, mon.evs.hp or 0, level)
  mon.stats.attack = calcModernStat(base.attack, mon.ivs.atk or 0, mon.evs.atk or 0, level, mon.nature, "atk")
  mon.stats.defense = calcModernStat(base.defense, mon.ivs.def or 0, mon.evs.def or 0, level, mon.nature, "def")
  mon.stats.speed = calcModernStat(base.speed, mon.ivs.spe or 0, mon.evs.spe or 0, level, mon.nature, "spe")
  mon.stats.spa = calcModernStat(base.special, mon.ivs.spa or 0, mon.evs.spa or 0, level, mon.nature, "spa")
  mon.stats.spd = calcModernStat(base.special, mon.ivs.spd or 0, mon.evs.spd or 0, level, mon.nature, "spd")
  return mon
end

return ModernStats
