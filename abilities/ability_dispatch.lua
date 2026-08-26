-- The ability-execution primitive: this mod's first real integration of
-- national_dex's ability DATA (dex.exports.abilityById, 0.30.0+) into
-- actual battle behavior. Nothing before this session executed an ability
-- anywhere in this engine -- confirmed directly (a dedicated research pass
-- grepped the whole base engine and every installed mod): mon.ability
-- exists only as save/display data (stats/engine_modern_stats.lua's own
-- generation/toggle functions, the SummaryMenu page-3 readout), never read
-- by combat logic.
--
-- We do not register abilities -- national_dex already owns the species-
-- ability associations (statsBySpecies(id).abilities) and the ability
-- behavior text (abilityById(id)) -- we only WIRE what's already there
-- into the primitives this mod already has (changeStage, setMonTypes,
-- etc.), the exact same "patch, never register" discipline this mod's own
-- SUBEFFECTS.md already states for moves.
--
-- MODULARITY, explicit user directive: data and engine stay entirely
-- separate for the whole ability system, this file included. abilities/
-- data/*.lua files are pure tables (no logic, no mod.exports -- loaded via
-- loadSibling the same way combat/moves_new.lua's own plain data table
-- already is) keyed by ability id; abilities/engine/*.lua files are pure
-- dispatch logic, each reading exactly one data file and calling exactly
-- one existing primitive. This file is the one exception living outside
-- that split -- it IS the primitive every engine file depends on
-- (abilityIdOf/abilityBehaviorOf), not a per-ability dispatcher itself.
return function(mod)
  local nationalDex = mod.find and mod.find("national_dex")
  assert(nationalDex and nationalDex.exports and nationalDex.exports.abilityById,
    "ability_dispatch: national_dex (with abilityById) must be installed")

  -- mon.ability stores a display name ("Intimidate", "As One (Glastrier)");
  -- national_dex's own ids strip everything but letters/digits and
  -- uppercase (confirmed directly against real records: "As One
  -- (Glastrier)" -> ASONEGLASTRIER, "Dauntless Shield" -> DAUNTLESSSHIELD).
  local function abilityIdOf(mon)
    local name = mon and mon.ability
    if type(name) ~= "string" then return nil end
    local id = name:upper():gsub("[^%w]", "")
    if id == "" then return nil end
    return id
  end
  mod.exports.abilityIdOf = abilityIdOf

  -- The real national_dex behavior record for mon's current ability, or
  -- nil (no ability set, or national_dex has no record for it). A COPY,
  -- like every other national_dex reply -- callers may read but should
  -- never assume mutating it does anything.
  function mod.exports.abilityBehaviorOf(mon)
    local id = abilityIdOf(mon)
    if not id then return nil end
    return nationalDex.exports.abilityById(id)
  end

  mod.log:info("g9-battle-engine-beta: ability_dispatch installed (abilityIdOf, abilityBehaviorOf)")
end
