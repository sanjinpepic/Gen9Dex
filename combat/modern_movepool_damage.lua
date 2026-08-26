-- Phase 2 (part 2) of the move-effect completion pipeline: moves_new.lua's
-- recoil/drain/heal stubs (8 moves) and its two-turn/charge/recharge stubs
-- (3 moves: Bounce, Outrage, Eternabeam). Grouped in one file, not two --
-- both buckets ride the SAME real primitive shape (a `full`-kind
-- move_effects record's `afterDamage` stage callback, EffectRegistry.lua's
-- staged damaging pipeline), unlike modern_movepool_status.lua's
-- kind="secondary"+run pattern. Must load after modern_combat.lua (only
-- HEALPULSE/LIFEDEW/SYNTHESIS/PAINSPLIT below need its exports; the
-- recoil/drain/charge handlers don't, but one load order keeps every
-- Phase 2 sibling consistent).
--
-- Why `afterDamage`, not `run`, for recoil/drain/Bounce/Outrage/
-- Eternabeam: `afterDamage` is ONLY ever read by Gen 1's own damaging
-- pipeline (EffectRegistry.runDamaging, "post-damage effect bookkeeping"
-- -- confirmed, EffectRegistry.lua:307-317) and Gen 1's charge gate
-- (BattleState:performMove reads `record.charge`, :3602). Gen 2's own
-- dispatch (gen2/Battle.lua:1533-1538) never looks at either field --
-- it only ever checks `record.run`, and calling handler(...) there
-- returns immediately regardless of what the handler does inside (see
-- modern_movepool_status.lua's header for the full grounding). So a
-- record with NO `run` field is invisible to that early-return branch:
-- Gen 2 falls through to its OWN native damage path unmodified, meaning
-- these moves deal ordinary, un-recoiled/un-charged damage on Gen 2 today
-- -- not broken, just not (yet) wired there, the same "pre-existing gap,
-- not a regression" bar Phase 1 already established. Giving one of these
-- records a `run` field too (to also drive some Gen 2 behavior) would
-- flip that from "unwired" to "deals zero damage on Gen 2", strictly
-- worse -- deliberately not attempted here.
--
-- schema note: R.move_effects (src/mods/Schemas.lua:1280-1288) only lists
-- kind/accuracyChecked/run as known fields, but Schemas.check's own
-- record-mode validator explicitly allows and preserves unknown top-level
-- keys ("Unknown top-level fields are allowed and preserved -- extensible
-- records are a feature", Schemas.lua:211-217; confirmed in the actual
-- non-patch branch at :249-260, which only rejects unrecognized keys in
-- patch mode). That's what makes `afterDamage`/`charge` on a MOD-registered
-- record legal at all -- they ride through as ordinary extra fields, the
-- same way MoveEffects.full's own native records carry them.
--
-- mon.hp / mon.stats.hp are the confirmed real current/max HP fields
-- (native HEAL_EFFECT, MoveEffects.lua:201-214, reads/writes exactly
-- these two).
return function(mod)
  local EffectRegistry = require("src.battle.EffectRegistry")
  local StatusRegistry = require("src.battle.StatusRegistry")
  local romText = require("src.core.RomText")
  local Strings = require("src.core.Strings")

  local normalize = mod.exports.normalize
  local displayNameFor = mod.exports.displayNameFor
  assert(normalize and displayNameFor,
    "modern_movepool_damage: combat/modern_combat.lua must load first")

  ------------------------------------------------------------------
  -- Recoil: user takes a fraction of the RAW damage it just dealt.
  -- Native RECOIL_EFFECT (MoveEffects.lua:530-539) is hardcoded to 1/4
  -- (Gen 1's only recoil ratio) -- Brave Bird/Wood Hammer (1/3) and Head
  -- Smash (1/2) need their own real Showdown fractions, so this can't
  -- reuse that id even generation risk aside; copies its exact shape
  -- (ctx.rawDamage, ctx.battle:applyDamage) with a configurable fraction.
  ------------------------------------------------------------------
  local function recoilFraction(effectId, numerator, denominator)
    mod.content.move_effects:register(effectId, {
      kind = "full",
      afterDamage = function(ctx)
        local recoil = math.max(1, math.floor(ctx.rawDamage * numerator / denominator))
        ctx.say(romText(ctx.battle.data, "_HitWithRecoilText", "%s's\nhit with recoil!", EffectRegistry.displayName(ctx.user)))
        ctx.battle:applyDamage(ctx.user, recoil)
      end,
    })
  end
  recoilFraction("GALAR_RECOIL_EFFECT_3", 1, 3) -- Brave Bird, Wood Hammer: 1/3
  recoilFraction("GALAR_RECOIL_EFFECT_2", 1, 2) -- Head Smash: 1/2

  ------------------------------------------------------------------
  -- Drain: user heals a fraction of the RAW damage it just dealt.
  -- Native DRAIN_HP_EFFECT/drainHalf (MoveEffects.lua:446-458) is
  -- hardcoded to 1/2 -- Draining Kiss's real Showdown fraction is 3/4, so
  -- same reasoning as recoil above: same shape, configurable fraction.
  -- ctx.battle.lastDamage is set to the drained (not raw) amount on
  -- purpose, mirroring drainHalf's own documented Counter interaction.
  ------------------------------------------------------------------
  mod.content.move_effects:register("GALAR_DRAIN_EFFECT_75", {
    kind = "full",
    afterDamage = function(ctx)
      local heal = math.max(1, math.floor(ctx.rawDamage * 3 / 4))
      ctx.battle.lastDamage = heal
      local mon = ctx.user.mon
      mon.hp = math.min(mon.stats.hp, mon.hp + heal)
      ctx.drain()
      ctx.say(romText(ctx.battle.data, "_SuckedHealthText", Strings.source("Sucked health from\n%s!"), EffectRegistry.displayName(ctx.target)))
    end,
  })

  ------------------------------------------------------------------
  -- Plain heals (kind="primary", power=0 status moves) -- BattleState's
  -- own pure-status-move dispatch (:3637) requires kind=="primary" AND a
  -- `run` field to do anything at all, unlike the afterDamage-only shape
  -- above; these run on both Gen 1 and Gen 2 (normalize+displayNameFor
  -- bridge, same as modern_movepool_status.lua's primary handlers).
  ------------------------------------------------------------------
  local function healFraction(who, numerator, denominator)
    local mon = who.mon
    if mon.hp >= mon.stats.hp then return false end
    local amount = math.max(1, math.floor(mon.stats.hp * numerator / denominator))
    mon.hp = math.min(mon.stats.hp, mon.hp + amount)
    return true
  end

  -- Heal Pulse: heals the TARGET (not the user) by half its max HP.
  -- Target-directed like Decorate in stages.lua, so accuracyChecked=true
  -- for the same reason (a genuine miss roll against the target, not a
  -- self-only buff that should never consult the opponent's evasion).
  -- In this engine's own single-battle-only shape "target" is always the
  -- opponent (no ally slot to aim at) -- healing the opponent is legal
  -- if odd play, exactly as in real single-battle Showdown.
  mod.content.move_effects:register("GALAR_HEALPULSE_EFFECT", {
    kind = "primary",
    accuracyChecked = true,
    run = function(a, b, c)
      local n = normalize(a, b, c)
      if not healFraction(n.target, 1, 2) then
        return { romText(n.battle.data, "_ButItFailedText", "But, it failed!") }
      end
      return { Strings("%s's\nHP was restored!", displayNameFor(n.battle, n.target, n.gen2)) }
    end,
  })

  -- Life Dew: heals the USER (and allies, but this engine has no ally
  -- slot to also heal) by half its max HP. Gen 9 Home update raised this
  -- from its original Gen 8 1/4 to 1/2 -- this file follows the plan's own
  -- cross-generation rule (default to the most current Showdown behavior
  -- unless a later generation explicitly removed something), so 1/2, not
  -- 1/4.
  mod.content.move_effects:register("GALAR_LIFEDEW_EFFECT", {
    kind = "primary",
    run = function(a, b, c)
      local n = normalize(a, b, c)
      if not healFraction(n.user, 1, 2) then
        return { romText(n.battle.data, "_ButItFailedText", "But, it failed!") }
      end
      return { Strings("%s's\nHP was restored!", displayNameFor(n.battle, n.user, n.gen2)) }
    end,
  })

  -- Synthesis: real Showdown heal is weather-conditional (2/3 in sun,
  -- 1/4 in other weather, 1/2 with none) -- this engine has no weather
  -- yet (Phase 4, per the plan), so wired here as the flat "no weather"
  -- fraction (1/2) ONLY, per this phase's explicit instruction. The
  -- weather-conditional part is deferred, not silently dropped: Phase 4
  -- needs to come back and branch this on the weather system it builds.
  mod.content.move_effects:register("GALAR_SYNTHESIS_EFFECT", {
    kind = "primary",
    run = function(a, b, c)
      local n = normalize(a, b, c)
      if not healFraction(n.user, 1, 2) then
        return { romText(n.battle.data, "_ButItFailedText", "But, it failed!") }
      end
      return { Strings("%s's\nHP was restored!", displayNameFor(n.battle, n.user, n.gen2)) }
    end,
  })

  -- Pain Split: both battlers' current HP is set to the floor of their
  -- average (each still clamped to its own max, which the average of two
  -- HP values already at or under their own maxes can never exceed).
  -- Genuinely never misses in real Showdown (no accuracy roll at all,
  -- not even a 100-accuracy one) -- accuracyChecked left unset/nil is
  -- what skips BattleState's own accuracy roll for a primary effect
  -- (:3642, `if record.accuracyChecked and ...`), matching that exactly.
  mod.content.move_effects:register("GALAR_PAINSPLIT_EFFECT", {
    kind = "primary",
    run = function(a, b, c)
      local n = normalize(a, b, c)
      local userMon, targetMon = n.user.mon, n.target.mon
      local avg = math.floor((userMon.hp + targetMon.hp) / 2)
      userMon.hp = math.min(userMon.stats.hp, avg)
      targetMon.hp = math.min(targetMon.stats.hp, avg)
      return { Strings("The battlers'\nHP was\nshared!") }
    end,
  })

  ------------------------------------------------------------------
  -- Two-turn / recharge moves. Real primitive: `record.charge` read
  -- directly off the merged move_effects record by BattleState:performMove
  -- (:3602: "charge moves: first turn just charges" -- confirmed against
  -- native CHARGE_EFFECT/FLY_EFFECT, MoveEffects.lua:556-557), NOT a
  -- field on the move's own data at all -- R.moves (Schemas.lua:824-846)
  -- has chargeText/semiInvulnerable but no `charge` field at all, so
  -- there is nothing for this mod to patch onto a move record for this
  -- (checked, not assumed).
  --
  -- Bounce, Outrage, and Eternabeam are NOT wired by pointing their
  -- moves_new.lua `effect` straight at Gen 1's native ids (FLY_EFFECT /
  -- THRASH_PETAL_DANCE_EFFECT / HYPER_BEAM_EFFECT), even though the
  -- mechanics genuinely match -- same cross-generation reference risk as
  -- modern_movepool_status.lua's header explains for BURN_SIDE_EFFECT1:
  -- move.effect is f.id("move_effects")-validated against whichever
  -- generation's registry is active for that boot, and Gen 1's native ids
  -- are absent from Gen 2's own (gen2/Battle.lua-seeded) copy. Custom
  -- GALAR_* ids, registered fresh on every boot, are the only shape valid
  -- on both -- their handlers below are still DIRECT copies of the real
  -- native Gen 1 algorithms (same field names, same turn counts), not
  -- reinvented, just re-homed under an id that resolves everywhere.
  ------------------------------------------------------------------

  -- Bounce: semi-invulnerable charge turn (Fly-shaped -- no confirmed
  -- Bounce-specific animation exists in this engine, so this reuses
  -- Fly's own TELEPORT charge anim as a placeholder, same as Fly/Dig
  -- already share one), then a 30% paralyze chance on the hit that
  -- releases it. The paralyze roll lives in `afterDamage` (fires once,
  -- after the release-turn hit lands), NOT `run` -- see this file's own
  -- header for why a `run` field here would be actively worse than no
  -- wiring at all on Gen 2. Gen 2's own charge/semi-invulnerable
  -- mechanism is a completely separate `state.chargeMove`/
  -- `Effects.CHARGE[def.effect]` system keyed on GEN 2's OWN hardcoded
  -- effect-id strings (gen2/Battle.lua:1324,1459) -- unreachable for a
  -- custom id without new Gen 2-side engine hooks, out of scope this
  -- phase. Not a regression: Bounce currently has zero charge behavior
  -- on either engine, so Gen 1 gaining the real two-turn mechanic while
  -- Gen 2 stays an ordinary instant-hit move is a strict improvement, not
  -- a new gap.
  mod.content.move_effects:register("GALAR_BOUNCE_EFFECT", {
    kind = "full",
    charge = { invulnerable = true, anim = "TELEPORT" },
    afterDamage = function(ctx)
      if ctx.battle.rng(0, 255) >= 77 then return end -- 30%
      for _, m in ipairs(StatusRegistry.inflict(ctx.battle, ctx.target, "PAR", {
        moveType = ctx.move.type, secondary = true, source = ctx.move.id,
      })) do
        ctx.say(m)
      end
    end,
  })

  -- Outrage: direct copy of native THRASH_PETAL_DANCE_EFFECT's afterDamage
  -- (MoveEffects.lua:584-602) -- locks the user into 2-3 more turns of the
  -- same move via user.thrashTurns/thrashMove/thrashAnnounced, then
  -- confuses it. These exact field names are confirmed read generically
  -- elsewhere in BattleState.lua regardless of which move set them
  -- (:3552 isContinuation, :3562 skip-reannounce, :3494 clearVolatiles),
  -- so the engine's existing turn-continuation machinery Just Works for
  -- Outrage the same way it already does for native Thrash/Petal Dance.
  mod.content.move_effects:register("GALAR_OUTRAGE_EFFECT", {
    kind = "full",
    afterDamage = function(ctx)
      local user = ctx.user
      if not user.thrashTurns then
        user.thrashTurns = ctx.rng(2, 3)
        user.thrashMove = ctx.moveInst
        user.thrashAnnounced = true
      else
        user.thrashTurns = user.thrashTurns - 1
        if user.thrashTurns <= 0 then
          user.thrashTurns, user.thrashMove, user.thrashAnnounced = nil, nil, nil
          if not user.confusedTurns then
            user.confusedTurns = ctx.rng(2, 5)
            ctx.say(romText(ctx.battle.data, "_BecameConfusedText", "%s\nbecame confused!", EffectRegistry.displayName(user)))
          end
        end
      end
    end,
  })

  -- Eternabeam: direct copy of native HYPER_BEAM_EFFECT's afterDamage
  -- (MoveEffects.lua:619-629) -- sets user.mustRecharge unless the target
  -- fainted or its substitute broke (ruleset hyperBeamSkipRechargeOnKO
  -- default true). mustRecharge is likewise confirmed read generically
  -- (:1781 action gate, :3333 recharge-turn consume), so the existing
  -- recharge machinery already works for Eternabeam without any further
  -- hook here.
  mod.content.move_effects:register("GALAR_ETERNABEAM_EFFECT", {
    kind = "full",
    afterDamage = function(ctx)
      local ruleset = ctx.battle and ctx.battle.ruleset
      local skipOnKO = not ruleset or ruleset.hyperBeamSkipRechargeOnKO ~= false
      local targetDown = ctx.target.mon.hp <= 0 or ctx.brokeSub
      if not skipOnKO or not targetDown then
        ctx.user.mustRecharge = true
      end
    end,
  })

  mod.log:info("galar_gmax_dex: modern_movepool_damage loaded")
end
