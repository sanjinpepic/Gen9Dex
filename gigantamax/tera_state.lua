-- Tera Type storage + public API: per-mon read/modify, same shape and
-- reasoning as gigantamax/dynamax_state.lua's Dynamax Level/Gigantamax
-- Factor pair. We own this storage outright -- explicit user instruction
-- (2026-08-20): battle_forms's own "TERA TYPE" mod option (src/tera.lua)
-- is a placeholder built for testing before this API existed, and is
-- meant to be rewired to read from here later. That rewiring is NOT done
-- by this file -- battle_forms's own activation flow (its menu cell, its
-- once-per-battle registry slot, its own mod option) is untouched and
-- keeps working exactly as it does today until that follow-up happens.
-- This file only ever owns the STORED VALUE, never when/how a
-- Terastallization actually triggers -- same ownership line already drawn
-- for Dynamax Level/Gigantamax Factor.
--
-- Stored as a bare `mon.teraType` field (a type id string, or nil for
-- "unset") -- schema-less save round-tripping, the identical pattern
-- `mon.gigantamaxFactor`/battle_forms's own `mon.battleFormsStone` already
-- rely on (src/mods/SaveSerializer.lua's generic table walk, confirmed
-- this session). Does NOT survive a real link-cable trade (a separate
-- allowlist wire protocol) unless moved under mon.extra -- not needed for
-- the currently scoped use.
--
-- STELLAR is a real, valid value here even though no chart record and no
-- battle_forms menu choice exists for it (src/tera.lua's own TERA_CHOICES
-- lists the 18 standard types only) -- see combat/modern_tera.lua's own
-- header for why Stellar structurally cannot be represented by
-- battle_forms's mechanism at all, and is this mod's own domain instead.
return function(mod)
  local SAVE_FIELD = "teraType"

  -- Every type id the RUNNING game's merged chart can resolve, same
  -- guarded-registry-read pattern battle_forms's own src/tera.lua uses
  -- (typeExists) -- a type chosen here that the loaded chart has never
  -- heard of (DARK/STEEL/FAIRY without National Dex's chart layered in)
  -- would silently do nothing useful downstream, so it is refused here
  -- instead of accepted and failing later.
  local function chartHasType(battle, typeId)
    local chart = battle and battle.data and battle.data.type_chart
    local types = chart and chart.types
    return types ~= nil and types[typeId] ~= nil
  end

  -- STELLAR is accepted unconditionally, chart or no chart -- it is
  -- deliberately absent from every type chart on purpose (no matchup rows
  -- of its own is the whole mechanic, see modern_tera.lua), so "the chart
  -- doesn't know this type" is never a valid refusal reason for it the way
  -- it is for the 18 standard types.
  mod.exports.isValidTeraType = function(typeId, battle)
    if type(typeId) ~= "string" or typeId == "" then return false end
    if typeId == "STELLAR" then return true end
    if not battle then return true end -- no live battle to check against yet; accept, defer the real check to activation time
    return chartHasType(battle, typeId)
  end

  -- Same fallback love.math.random/math.random shape the base engine's
  -- own gen2/Battle.lua module-local `rand` helper uses (confirmed this
  -- session) -- a personality-style roll like this has no battle to seed
  -- an RNG from (it can fire from a party/box screen, outside any battle
  -- at all), so it is deliberately NOT battle.random/roller()-seeded the
  -- way an in-battle roll would be.
  local function randomIndex(n)
    if love and love.math and love.math.random then return love.math.random(n) end
    return math.random(n)
  end

  -- The mon's own real types, with or without a live battle to read them
  -- through -- battle.data.pokemon[id] when one is handed in (matches
  -- combat/modern_tera.lua's own originalTypesOf, unaffected by any
  -- battle-only override), else a plain registry read so this also works
  -- from the party screen, a Nuzlocke/box tool, or anywhere else outside
  -- a battle.
  local function speciesTypesOf(mon, battle)
    local id = mon and mon.species
    if not id then return nil end
    if battle and battle.data and battle.data.pokemon and battle.data.pokemon[id] then
      return battle.data.pokemon[id].types
    end
    local registry = mod.content and mod.content.pokemon
    if not registry or type(registry.get) ~= "function" then return nil end
    local ok, rec = pcall(registry.get, registry, id)
    return ok and rec and rec.types or nil
  end

  -- One of the mon's OWN real types, unmodified -- dual-type rolls one of
  -- the two at random (50/50), monotype has only the one answer. Persists
  -- the roll into mon.teraType itself so it reads back identically to an
  -- explicit choice from here on -- there is no separate "default vs
  -- chosen" flag to track, since a later setTeraType call is meant to
  -- freely overwrite either the same way (explicit user spec: "that can
  -- be replaced later by any other").
  local function rollDefaultTeraType(mon, battle)
    local types = speciesTypesOf(mon, battle)
    if not types or #types == 0 then return nil end
    local pick = types[1]
    if #types > 1 then pick = types[randomIndex(#types)] end
    mon[SAVE_FIELD] = pick
    return pick
  end

  -- Read API: mod.exports.getTeraType(mon, battle) -> a type id string,
  -- never nil for a mon with any real species types at all. `battle` is
  -- optional context for resolving those types (see speciesTypesOf above)
  -- -- pass it when calling from inside a live battle, omit it anywhere
  -- else. A mon with no stored value yet -- a brand-new one, OR one that
  -- existed before this file did and so never got one -- is handled
  -- identically, by design, per explicit user instruction: both roll a
  -- random default here, on first read, rather than one path initializing
  -- at creation time and a second, separate migration path backfilling
  -- old saves. One mechanism, not two.
  mod.exports.getTeraType = function(mon, battle)
    if not mon then return nil end
    local t = mon[SAVE_FIELD]
    if type(t) == "string" and t ~= "" then return t end
    return rollDefaultTeraType(mon, battle)
  end

  -- Write API: mod.exports.setTeraType(mon, typeId, battle) -> the value
  -- actually stored, or false if refused (invalid mon, invalid/unresolved
  -- type). `battle` is optional context for the chart-membership check
  -- above -- pass the live battle when calling this from inside one, omit
  -- it (e.g. from a party-screen picker outside battle) to accept any of
  -- the 18 known ids plus STELLAR without a live chart to check against.
  -- Any other mod may call this directly, same as Dynamax
  -- Level/Gigantamax Factor -- we don't decide when/why a Tera Type gets
  -- chosen or changed, only persist what we're told.
  mod.exports.setTeraType = function(mon, typeId, battle)
    if not mon then return false end
    if typeId == nil then
      mon[SAVE_FIELD] = nil
      return nil
    end
    if not mod.exports.isValidTeraType(typeId, battle) then return false end
    mon[SAVE_FIELD] = typeId
    return typeId
  end

  mod.log:info("galar_gmax_dex: tera_state installed (per-mon Tera Type storage + API, no activation)")
end
