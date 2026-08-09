-- Protect move logic: genuine greenfield work (confirmed by grepping all of
-- src/battle/ for "protect"/"Protect"/"Detect" -- only unrelated Mist/Light
-- Screen flavor text exists; Gen 1's original ROM never had Protect at all,
-- it was introduced Gen 2).
--
-- Part A: PROTECT already exists in this mod's own data
-- (GalarGmaxDex/moves_new.lua, priority = 4, correct already) as a
-- documented no-op (effect = "NO_ADDITIONAL_EFFECT", functionCode =
-- "ProtectUser" -- functionCode is dead documentation, grepped: nothing in
-- the core engine ever reads it). Registered here as a real move_effects
-- record and patched onto PROTECT -- the same pattern main.lua's
-- installMovepoolEffects already uses for GALAR_FLINCH_EFFECT_*/
-- GALAR_CONFUSE_EFFECT_*/GALAR_TRAP_EFFECT, not a new mechanism. Effect
-- records are keyed by move id, so this applies identically in wild,
-- trainer, and link battles with no extra wiring -- and any future
-- Detect/Endure/Spiky Shield/Baneful Bunker/King's Shield can point their
-- own `effect` field at this exact same id (they're mechanically identical
-- decay chains in every real generation).
--
-- Part B: blocking an INCOMING damaging move against a protected target.
--
-- Deliberately does NOT monkey-patch BattleState.performMove to block
-- before the move even runs: performMove decrements PP and announces
-- "X used Y!" near its own top, BEFORE any effect dispatch -- blocking
-- there entirely would give the attacker their move back for free (no PP
-- cost, no announcement), which is wrong; a Protect-blocked move still
-- costs PP and still gets announced in every real generation.
--
-- Instead this wraps battle.damage (the same hook modern_combat.lua
-- already uses) at a HIGHER priority, so it runs first in the chain and
-- can short-circuit straight to typeMult = 0 without ever calling next()
-- -- reusing EffectRegistry.lua's own existing, already-correct handling
-- for that exact value (confirmed by reading it directly, EffectRegistry
-- .lua:187-191): `if info.typeMult == 0 then ... "It doesn't affect
-- %s!" ... end`. Same code path a type immunity already uses, so no new
-- message logic is needed here at all -- PP/animation/announcement all
-- run completely normally through the untouched native performMove, and
-- only the damage number comes back zeroed.
--
-- Part D: blocking an INCOMING pure status move (Thunder Wave, Toxic, a
-- stat-lowering move) against a protected target -- these never call
-- computeDamage at all, so Part B's battle.damage hook never sees them.
-- No hook exists for "a primary status effect is about to run" the way
-- battle.damage does for damage, so this needs a performMove wrap after
-- all -- but NOT the naive "block before native runs at all" version:
-- that would skip PP decrement and the "X used Y!" announcement, giving
-- the attacker their move back for free, which is wrong (a Protect-
-- blocked move still costs PP and still gets announced in every real
-- generation, exactly like Part B's reasoning for damaging moves).
--
-- Instead, when the block condition is met, this temporarily swaps
-- self.effectRecord (BattleState.lua:2205's own tiny lookup method) for
-- the single native performMove call, substituting a "doesn't affect"
-- stand-in record -- same kind/accuracyChecked shape as the real one, so
-- native's PP/announcement/accuracy-roll logic (BattleState.lua:3433-
-- 3579) runs completely unmodified and unduplicated, and only the
-- record.run(ctx) that would have applied the real effect is swapped
-- out. Restored immediately after, even on error.
return function(mod)
  local BattleState = require("src.battle.BattleState")
  local EffectRegistry = require("src.battle.EffectRegistry")
  local PROTECT_EFFECT_ID = "GMAX_PROTECT_EFFECT"

  ------------------------------------------------------------------
  -- Part A: Protect's own move -- the real decaying success chain
  -- (Showdown's exact "stall" volatile, matching Bulbapedia's documented
  -- values): 100% on first use or after a break in the chain, 1/3 on the
  -- second consecutive use, 1/9 on the third, and so on, capped at
  -- 1/729. Resets to 100% on failure OR on any turn gap (not used last
  -- turn).
  ------------------------------------------------------------------
  mod.content.move_effects:register(PROTECT_EFFECT_ID, {
    kind = "full",
    perform = function(ctx)
      local battle, user = ctx.battle, ctx.user
      local consecutive = user.protectChainTurn == (battle.turnCount or 0) - 1
      local x = (consecutive and user.protectChainX) or 1
      local success = ctx.rng(1, x) == 1
      if success then
        user.protected = true
        user.protectChainX = math.min(x * 3, 729)
        user.protectChainTurn = battle.turnCount
        ctx.say(battle:romText("_ProtectedItselfText", "%s\nprotected itself!", ctx.displayName(user)))
      else
        user.protectChainX = nil
        battle:cancelMoveAnim()
        ctx.say(battle:romText("_ButItFailedText", "But, it failed!"))
      end
    end,
  })
  mod.content.moves:patch("PROTECT", { effect = PROTECT_EFFECT_ID })

  ------------------------------------------------------------------
  -- Part B: block an incoming damaging move against a protected target.
  -- Priority 50, above modern_combat.lua's damage-formula hook (0) --
  -- runs first in the chain and, when blocking, returns its own result
  -- without ever calling next(), so the modern formula never even runs
  -- for a blocked hit. ctx.user ~= ctx.target guards a protected mon's
  -- own follow-up self-targeting moves (Swords Dance, Recover, using
  -- Protect again) from ever being blocked by its own flag.
  -- move.bypassesProtect is a named, documented, unused-for-now field
  -- for Feint-class moves later.
  ------------------------------------------------------------------
  mod.hooks:wrap("battle.damage", function(next, ctx)
    local target = ctx.target
    if target and target ~= ctx.user and target.protected
        and not (ctx.move and ctx.move.bypassesProtect) then
      return 0, { crit = false, typeMult = 0 }
    end
    return next(ctx)
  end, 50)

  ------------------------------------------------------------------
  -- Part C: turn-scoped cleanup. Runtime.emit("battle.turn_started", ...)
  -- fires as the literal first statement in resolveTurn (BattleState.lua),
  -- before either battler's action executes -- so clearing here, then
  -- Protect's own perform (above) re-setting the flag if used again this
  -- turn, always happens in the right order regardless of move order.
  ------------------------------------------------------------------
  mod.events:on("battle.turn_started", function(ev)
    local battle = ev and ev.battle
    if not battle then return end
    if battle.player then battle.player.protected = nil end
    if battle.enemy then battle.enemy.protected = nil end
  end)

  ------------------------------------------------------------------
  -- Part D: block an incoming pure status move (power == 0, a
  -- record.kind == "primary" effect) against a protected target. See
  -- the file header for why this can't reuse Part B's battle.damage
  -- hook and why it doesn't just skip performMove outright.
  ------------------------------------------------------------------
  local nativePerformMove = BattleState.performMove
  function BattleState:performMove(user, target, moveInst, isCalled)
    local blockable = target and target ~= user and target.protected
    if blockable then
      -- read-only determination, pcall-guarded: figures out whether this
      -- is a plain "primary" status effect worth intercepting, without
      -- mutating anything yet.
      local ok, move, record = pcall(function()
        local m = self:moveDef(moveInst)
        if not (m and (m.power or 0) == 0 and not m.bypassesProtect) then return nil end
        local r = self:effectRecord(m.effect)
        -- record.perform ("full") moves (Bide/Roar/Teleport/Mimic, and
        -- Protect itself) are never blocked by Protect in real games --
        -- they either don't meaningfully target an opponent or have
        -- their own bespoke handling. Only the plain "primary" status
        -- effect shape is intercepted here.
        if not (r and r.kind == "primary" and r.run) then return nil end
        return m, r
      end)
      if ok and move and record then
        local nativeEffectRecord = self.effectRecord
        self.effectRecord = function(_self, eff)
          if eff == move.effect then
            return {
              kind = "primary",
              accuracyChecked = record.accuracyChecked,
              run = function(ctx)
                return { ctx.battle:romText("_DoesntAffectMonText", "It doesn't affect\n%s!",
                  EffectRegistry.displayName(target)) }
              end,
            }
          end
          return nativeEffectRecord(self, eff)
        end
        local callOk, callErr = pcall(nativePerformMove, self, user, target, moveInst, isCalled)
        self.effectRecord = nativeEffectRecord
        if not callOk then
          mod.log:warn("galar_gmax_dex: modern_combat_protect: status-move block-check errored (%s)",
            tostring(callErr))
        end
        return
      end
    end
    return nativePerformMove(self, user, target, moveInst, isCalled)
  end

  mod.log:info("galar_gmax_dex: modern_combat_protect loaded")
end
