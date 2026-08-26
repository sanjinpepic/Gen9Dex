-- Dispatch engine for abilities/data/stat_change_switchin.lua -- that file
-- is only an inclusion list; scope/stat/stages are read LIVE from
-- national_dex's own abilityBehaviorOf here, at dispatch time, every time.
-- Nothing about the effect itself is duplicated into this mod's own data -- only
-- two things that genuinely aren't in national_dex's data at all:
--
-- 1. STAT_KEY: PokeAPI's own stat-name spelling (national_dex's behaviour.
--    effects[].stat, e.g. "special-attack") mapped to this engine's own
--    key convention (modern_combat.lua's changeStage store uses "spa",
--    confirmed against every other stat-changing MOVE in combat/
--    modern_movepool_stages.lua) -- a naming-convention adapter, not game
--    data.
-- 2. NATIVE_STATS: which of those keys route through Gen 2's own native
--    stage table (Battle:changeStageAgainstMist) instead of modern_combat
--    .lua's atk/def/spa/spd store -- that file's own header: speed/
--    accuracy/evasion were never held there at all. A pure function of
--    WHICH STAT is involved, so this is derived here rather than stored
--    per-ability anywhere.
--
-- Reuses combat/modern_combat.lua's own changeStage export (the same
-- primitive every stat-changing MOVE already goes through) and Gen 2's own
-- native Battle:changeStageAgainstMist directly for the three
-- native-store stats.
--
-- SUBSTITUTE, confirmed by direct source read after the user pasted
-- Intimidate's own real national_dex record ("This ability has no effect
-- on an opponent that has a Substitute"): modern_combat.lua's changeStage
-- already gates a hostile (fromEnemy) change on the target's Substitute
-- via isProtectedFrom, so INTIMIDATE/INTREPIDSWORD/DAUNTLESSSHIELD (all
-- non-native stats) already respect it correctly for free. Battle:
-- changeStageAgainstMist does NOT -- read directly, gen2/Battle.lua:2071-
-- 2079: it checks ONLY Mist, and the Battle:changeStage it delegates to
-- (gen2/Battle.lua:1299-1313) has no Substitute check anywhere in the
-- chain. Real, confirmed gap for the native-store stats (SUPERSWEETSYRUP's
-- own evasion drop) -- fixed explicitly below (a plain battle:volatile(
-- target).substitute read, the same field isProtectedFrom itself checks)
-- rather than trusted to the native call. A wider pre-existing gap in
-- combat/modern_movepool_stages.lua's own changeNativeStage (any MOVE
-- routing a hostile speed/accuracy/evasion change that way, e.g. Scary
-- Face/Cotton Spore/Sweet Scent) is flagged here but deliberately not
-- touched -- that file is a separate, earlier piece of work outside this
-- task's scope.
--
-- Triggers: battle.started (the very first send-out at battle start --
-- confirmed by direct read, gen2/Battle.lua:340, a SEPARATE event from any
-- switch) and battle.battler_switched (every switch after that). Both are
-- needed -- Intimidate firing only on MID-battle switches and never on the
-- lead Pokemon would be a real, observable bug. Every other switch_in
-- ability engine file in this directory reuses this exact same two-event
-- pattern.
return function(mod, data)
  local changeStage = mod.exports.changeStage
  local bossStatsDropBlocked = mod.exports.bossStatsDropBlocked
  local abilityIdOf = mod.exports.abilityIdOf
  local abilityBehaviorOf = mod.exports.abilityBehaviorOf
  assert(changeStage and bossStatsDropBlocked and abilityIdOf and abilityBehaviorOf,
    "switchin_stat_change: modern_combat.lua and ability_dispatch.lua must load first")

  local STAT_KEY = {
    attack = "attack", defense = "defense",
    ["special-attack"] = "spa", ["special-defense"] = "spd",
    speed = "speed", accuracy = "accuracy", evasion = "evasion",
  }
  local NATIVE_STATS = { speed = true, accuracy = true, evasion = true }

  local function opponentOf(battle, mon)
    return (mon == battle.player) and battle.enemy or battle.player
  end

  local function applySwitchInAbility(battle, mon)
    if not (battle and mon and (mon.hp or 0) > 0) then return end
    local id = abilityIdOf(mon)
    if not (id and data[id]) then return end
    local record = abilityBehaviorOf(mon)
    local behavior = record and record.behaviour
    local effect = behavior and behavior.effects and behavior.effects[1]
    if not (effect and effect.kind == "stat_change" and effect.stat and effect.stages) then return end
    local stat = STAT_KEY[effect.stat]
    if not stat then return end
    local fromEnemy = behavior.scope == "foes"
    local target = fromEnemy and opponentOf(battle, mon) or mon
    if not target or (target.hp or 0) <= 0 then return end
    -- changeStageAgainstMist has no Substitute check of its own (see this
    -- file's own header) -- applied here so a hostile native-store change
    -- respects it exactly like changeStage already does for the others.
    -- Never gates a self-targeted change: Substitute never blocks a mon
    -- buffing itself.
    if fromEnemy and (battle:volatile(target).substitute or 0) > 0 then return end
    -- Boss-fight "statsDrop" protection: checked here too, ahead of the
    -- native call -- see modern_combat.lua's own bossStatsDropBlocked
    -- header and this file's own header for why the native-store branch
    -- needs its own explicit gate rather than trusting the native call.
    if bossStatsDropBlocked(battle, target, effect.stages) then return end
    if NATIVE_STATS[stat] then
      battle:changeStageAgainstMist(mon, target, stat, effect.stages)
    else
      changeStage(battle, target, stat, effect.stages, fromEnemy, true)
    end
  end

  mod.events:on("battle.started", function(ev)
    local battle = ev and ev.battle
    if not battle then return end
    -- Speed order, not fixed player-then-enemy -- see combat/turn_order
    -- .lua's own orderSwitchInMons header for the full rule (real
    -- simultaneous switch-in resolution is fastest-first, and since each
    -- of these overwrites shared state, the slower mon's own trigger is
    -- what persists on a mismatch -- Intimidate/Intrepid Sword/Dauntless
    -- Shield/Supersweet Syrup don't overwrite each other's stat targets
    -- the way weather/terrain do, so this mostly matters for a future
    -- same-tier collision, but the ordering itself should still be
    -- correct rather than fixed). Read lazily (not hoisted to a local at
    -- install time): this file loads before combat/turn_order.lua in
    -- main.lua's own sequence, but this closure only runs later, during a
    -- real battle, by which point every mod has finished loading.
    local order = mod.exports.orderSwitchInMons
    local first, second = battle.player, battle.enemy
    if order then first, second = order(battle, battle.player, battle.enemy) end
    if first then applySwitchInAbility(battle, first) end
    if second then applySwitchInAbility(battle, second) end
  end)

  mod.events:on("battle.battler_switched", function(ev)
    local battle = ev and ev.battle
    local mon = ev and ev.battler
    if battle and mon then applySwitchInAbility(battle, mon) end
  end)

  mod.log:info("g9-battle-engine-beta: switchin_stat_change installed (INTIMIDATE, INTREPIDSWORD, DAUNTLESSSHIELD, SUPERSWEETSYRUP)")
end
