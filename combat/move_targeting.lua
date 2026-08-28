-- Move targeting resolver -- the seam described in combat/
-- MULTI_BATTLE_HOOKS.md's own header ("we own combat resolution... you
-- own only which battlers exist"), extended from turn order to
-- targeting: this engine does not know or track battlefield position at
-- all (confirmed standing answer this session), so it never computes
-- adjacency itself.
--
-- REDESIGNED 2026-08-27: the first pass of this file had battle scene
-- calling a query function (moveNeedsAdjacency) before deciding whether
-- to call the resolver -- rightly rejected. That put a comparator over
-- move data on battle scene's side for a fact only this mod needs to
-- know in the first place. WE own the move's real target archetype
-- (national_dex's own `target` field); WE are the one deciding whether
-- a given move-use needs anything beyond the one target the caller
-- already has. Battle scene's only job is to answer a request IF one
-- ever arrives, never to decide when that should happen.
--
-- The trigger is therefore on OUR side, fired through the same hook bus
-- combat/turn_order.lua already uses for battle.turn_order (confirmed
-- generic, not engine-exclusive: src/mods/Runtime.lua's Runtime.call/
-- Hooks:call takes a name, a vanilla fallback, and the call args; any
-- code can fire one, any mod can intercept one via mod.hooks:wrap).
-- mod.exports.resolveMoveTargets below calls Runtime.call("g9.
-- request_adjacency", ...) ITSELF, and only for the two archetypes that
-- genuinely cannot be satisfied by the one already-known target --
-- battle scene never inspects a moveId or a flag to decide whether to
-- respond; it just implements one handler that reports real battlefield
-- position whenever asked:
--
--   mod.hooks:wrap("g9.request_adjacency", function(nextFn, battle, caster, moveId)
--     return { allies = {...}, enemies = {...} }  -- real roster, caster excluded
--   end, 0, "your-mod-id")
--
-- No comparator on that side at all -- it answers a position query, full
-- stop. A battle-scene mod that hasn't wrapped the hook yet (today's
-- only real format, 1v1) gets the built-in fallback below instead, which
-- degrades correctly to the native two-battler case with zero wiring.
--
-- Real PokeAPI/Showdown target archetypes, confirmed directly against
-- live national_dex records before writing any of this (not guessed):
--   "selected-pokemon" -- the overwhelming majority of moves (confirmed:
--     Axe Kick, Bullet Seed, Cross Poison, and every other single-target
--     move sampled this session). The caller already knows who this is
--     -- same role as useMove's own `defender` parameter -- so this
--     never needs the adjacency hook at all, distance-flagged or not.
--     moveFlags(id).distance only matters to whatever UI builds the
--     target picker (it may offer any battler, not just adjacent ones)
--     -- a battle-scene concern, not something this resolver re-validates
--     after the fact.
--   "all-other-pokemon" -- Earthquake, Surf (confirmed directly): hits
--     every adjacent battler except the caster, both sides at once --
--     "user as center." Genuinely needs the real roster -- triggers the
--     hook.
--   "all-opponents" -- Muddy Water (confirmed directly): every adjacent
--     enemy, never allies. Also triggers the hook.
-- Flame Burst was checked as a candidate fourth archetype ("requires a
-- target, splashes to the target's own adjacent allies") and confirmed
-- NOT to be one -- its own live record is plain target="selected-
-- pokemon"; the splash is a custom secondary effect in its prose `effect`
-- text, not a targeting type national_dex's own `target` field
-- expresses. Not built here for that reason -- it belongs with this
-- mod's own per-move secondary-effect work, not the generic targeting
-- resolver.
return function(mod)
  local Runtime = require("src.mods.Runtime")
  local nationalDex = mod.find and mod.find("national_dex")
  assert(nationalDex and nationalDex.exports and nationalDex.exports.moveById,
    "move_targeting: national_dex must be loaded first")
  local moveById = nationalDex.exports.moveById

  -- Built-in fallback for "g9.request_adjacency" when no battle-scene mod
  -- has wrapped it yet -- today's only real format, the native two-
  -- battler engine. caster is always either battle.player or
  -- battle.enemy here (no third slot exists in this engine, confirmed in
  -- MULTI_BATTLE_HOOKS.md), so the other one is the only possible real
  -- adjacent enemy and there are no allies to report at all. Correct
  -- degradation, not a guess: an all-other-pokemon/all-opponents move in
  -- a 1v1 fight really does only ever have the one enemy to hit.
  local function nativeFallbackAdjacency(battle, caster)
    local enemy = (caster == battle.player) and battle.enemy or battle.player
    return { allies = {}, enemies = { enemy } }
  end

  -- requestAdjacency(battle, caster, moveId) -> { allies = {...}, enemies = {...} }
  -- The shared primitive underneath resolveMoveTargets, also exported
  -- directly for anything else that needs real adjacent-battler position
  -- and isn't itself resolving a move's target list -- switch-in
  -- abilities with a "foes" scope (Intimidate/Intrepid Sword/Dauntless
  -- Shield) are the first real case: they need "every adjacent enemy,"
  -- the same question a spread MOVE asks, just triggered by a switch-in
  -- instead of a move-use. moveId is optional here (nil for a non-move
  -- trigger) -- a wrapped handler never inspects it anyway (see this
  -- file's own header: "no move-awareness... it answers a position
  -- query"), so the ability case and the move case share the exact same
  -- hook and the exact same battle-scene-side contract, with nothing new
  -- for battle scene to implement.
  mod.exports.requestAdjacency = function(battle, caster, moveId)
    local adjacency = Runtime.call("g9.request_adjacency", nativeFallbackAdjacency, battle, caster, moveId)
    adjacency = adjacency or {}
    return { allies = adjacency.allies or {}, enemies = adjacency.enemies or {} }
  end

  -- resolveMoveTargets(battle, caster, moveId, chosenTarget) -> array of
  -- real battlers, possibly empty. chosenTarget is whatever single mon
  -- the caller already has in hand -- the same thing it would otherwise
  -- pass straight to battle:useMove as the defender -- never a separately
  -- built "adjacency bundle." We only reach past it, via requestAdjacency
  -- above, for the two archetypes that structurally need more than one
  -- target.
  mod.exports.resolveMoveTargets = function(battle, caster, moveId, chosenTarget)
    local info = moveById(moveId)
    local realTarget = info and info.target or "selected-pokemon"

    if realTarget ~= "all-other-pokemon" and realTarget ~= "all-opponents" then
      if chosenTarget then return { chosenTarget } end
      return {}
    end

    local adjacency = mod.exports.requestAdjacency(battle, caster, moveId)
    local allies = adjacency.allies
    local enemies = adjacency.enemies

    if realTarget == "all-other-pokemon" then
      local out = {}
      for _, m in ipairs(allies) do out[#out + 1] = m end
      for _, m in ipairs(enemies) do out[#out + 1] = m end
      return out
    end

    -- "all-opponents"
    local out = {}
    for _, m in ipairs(enemies) do out[#out + 1] = m end
    return out
  end

  mod.log:info("g9-battle-engine-beta: move_targeting installed (resolveMoveTargets, not yet called by anything)")
end
