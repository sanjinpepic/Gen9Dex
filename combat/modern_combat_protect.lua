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
  local MAX_GUARD_EFFECT_ID = "GMAX_MAX_GUARD_EFFECT"
  local MAX_GUARD_MOVE_ID = "BATTLE_FORMS_MAXGUARD"

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
  -- Detect (functionCode "ProtectUser", the same as Protect's own) is
  -- mechanically identical to Protect in every real generation -- same
  -- decaying success chain, same target flag. Phase 3 of the move-effect
  -- completion pipeline: this was the one line missing, moves_new.lua's
  -- own DETECT entry (priority 4, correct already) needed no other change.
  mod.content.moves:patch("DETECT", { effect = PROTECT_EFFECT_ID })

  ------------------------------------------------------------------
  -- Part A2: Max Guard, rebuilt onto this same Protect chain instead of
  -- battle_forms's own original implementation. Confirmed by reading
  -- battle_forms/src/maxmoves.lua directly: its own M.GUARD_EFFECT sets
  -- `user.invulnerable = true` -- the engine's native semi-invulnerability
  -- flag (the same one Fly/Dig use), not a Protect-style flag at all, and
  -- with no concept of a Feint/Z-Move exception or a different rule
  -- against incoming Max/G-Max moves. Explicit user instruction (2026-08-20):
  -- combat sub-effects, including gimmick move interactions, are this
  -- mod's own domain -- so BATTLE_FORMS_MAXGUARD's effect is patched to
  -- point here instead, replacing battle_forms's invulnerable-flag
  -- approach outright rather than layering on top of it (both active at
  -- once would leave the native semi-invulnerability check ALSO blocking
  -- things this new effect intends to let through, e.g. Feint).
  --
  -- Shares Protect's own protectChainTurn/protectChainX counter fields
  -- (real games treat every member of the Protect family -- Protect,
  -- Detect, Max Guard, Spiky Shield, etc. -- as one shared decaying
  -- chain per Pokemon, not a separate counter per move), but sets a
  -- DIFFERENT target flag (maxGuarded, not protected) -- Part B below
  -- reads which flag is set to tell Max Guard's own 100%-blocks-
  -- everything-including-Max-Moves rule apart from plain Protect's
  -- 75%-blocks-Max-Moves rule.
  ------------------------------------------------------------------
  mod.content.move_effects:register(MAX_GUARD_EFFECT_ID, {
    kind = "full",
    perform = function(ctx)
      mod.log:info("galar_gmax_dex: modern_combat_protect: [diag] Max Guard perform() reached")
      local battle, user = ctx.battle, ctx.user
      local consecutive = user.protectChainTurn == (battle.turnCount or 0) - 1
      local x = (consecutive and user.protectChainX) or 1
      local success = ctx.rng(1, x) == 1
      if success then
        user.maxGuarded = true
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
  -- priority = 4 set explicitly, not left to patch-merge with
  -- battle_forms's own registration: explicit user instruction after
  -- live testing showed Max Guard's user taking no visible action/turn
  -- at all -- consistent with Max Guard losing its going-first priority
  -- and resolving after the incoming hit already landed instead of
  -- before it. battle_forms's own registerMove call already sets
  -- priority = 4 (src/maxmoves.lua:136) and Registry.lua's op-log/fold
  -- model should compose patches from different mods without one
  -- clobbering the other's fields -- but stating it here removes any
  -- doubt rather than trusting that merge silently, given the live
  -- symptom pointed straight at priority.
  mod.content.moves:patch(MAX_GUARD_MOVE_ID, { effect = MAX_GUARD_EFFECT_ID, priority = 4 })

  -- Diagnostic: confirms both this patch and Registry's own fold
  -- actually landed, since reasoning about it in the abstract hasn't
  -- been reliable enough this session -- read back what the LIVE
  -- resolved record actually holds right after patching.
  do
    local ok, resolved = pcall(function() return mod.content.moves:get(MAX_GUARD_MOVE_ID) end)
    mod.log:info("galar_gmax_dex: modern_combat_protect: [diag] %s resolved as effect=%s priority=%s (ok=%s)",
      MAX_GUARD_MOVE_ID, tostring(ok and resolved and resolved.effect), tostring(ok and resolved and resolved.priority),
      tostring(ok))
  end

  -- "Is this a Max Move or G-Max move" -- explicit user spec: Protect
  -- reduces these to 25% damage (not a full block, unlike every other
  -- damaging move); Max Guard still blocks them entirely. Detected by
  -- battle_forms's own confirmed id convention (src/maxmoves.lua:38,
  -- M.PREFIX = "BATTLE_FORMS_", every Max/G-Max move stem starts with
  -- MAX/GMAX) rather than a hand-maintained id list, since this mod
  -- cannot read battle_forms's own data files directly (sandboxed
  -- mod:read refuses a path outside this mod's own folder) -- excludes
  -- Max Guard's own id specifically, which is a status move, not a
  -- damage-dealing one this rule ever applies to.
  local function isMaxMove(move)
    local id = move and move.id
    return id ~= nil and id ~= MAX_GUARD_MOVE_ID and id:match("^BATTLE_FORMS_G?MAX") ~= nil
  end

  ------------------------------------------------------------------
  -- Part B: block an incoming damaging move against a protected target.
  -- Priority 50, above modern_combat.lua's damage-formula hook (0) --
  -- runs first in the chain. ctx.user ~= ctx.target guards a protected
  -- mon's own follow-up self-targeting moves (Swords Dance, Recover,
  -- using Protect again) from ever being blocked by its own flag.
  --
  -- Explicit user spec, four rules in priority order:
  --   1. move.bypassesProtect (Feint, Z-Moves -- see Part E below for how
  --      Z-Moves get this flag) -- ignores any shield entirely, full
  --      damage, unchanged from before.
  --   2. target.maxGuarded -- 100% block of everything else, Max/G-Max
  --      moves included (Max Guard's whole point: it stops what plain
  --      Protect can't).
  --   3. target.protected + an incoming Max/G-Max move -- NOT a full
  --      block: next(ctx) runs the real formula, then the result is
  --      scaled to 25% (rounded to the nearest whole number, floor+0.5
  --      matching this file's own established rounding elsewhere).
  --   4. target.protected against anything else -- 100% block, unchanged
  --      from before.
  ------------------------------------------------------------------
  mod.hooks:wrap("battle.damage", function(next, ctx)
    local target = ctx.target
    if not (target and target ~= ctx.user) then return next(ctx) end
    if ctx.move and ctx.move.bypassesProtect then return next(ctx) end

    if target.maxGuarded then
      return 0, { crit = false, typeMult = 0 }
    end

    if target.protected then
      if isMaxMove(ctx.move) then
        local dmg, info = next(ctx)
        dmg = math.floor((dmg or 0) * 0.25 + 0.5)
        return dmg, info
      end
      return 0, { crit = false, typeMult = 0 }
    end

    return next(ctx)
  end, 50)

  ------------------------------------------------------------------
  -- Part C: turn-scoped cleanup. Runtime.emit("battle.turn_started", ...)
  -- fires as the literal first statement in resolveTurn (BattleState.lua),
  -- before either battler's action executes -- so clearing here, then
  -- Protect's/Max Guard's own perform (above) re-setting a flag if used
  -- again this turn, always happens in the right order regardless of
  -- move order.
  ------------------------------------------------------------------
  mod.events:on("battle.turn_started", function(ev)
    local battle = ev and ev.battle
    if not battle then return end
    local function clear(who)
      if not who then return end
      who.protected = nil
      who.maxGuarded = nil
    end
    clear(battle.player)
    clear(battle.enemy)
  end)

  ------------------------------------------------------------------
  -- Part E: Z-Moves bypass Protect/Max Guard entirely, same as Feint --
  -- explicit user spec. Unlike Feint (a fixed id already carrying
  -- bypassesProtect = true in this mod's own moves_new.lua), Z-Moves are
  -- ~100 individually-registered ids owned entirely by battle_forms, with
  -- no shared marker field on the registered record to test (confirmed
  -- by reading battle_forms/src/zmoves.lua and speciesz.lua's own
  -- mod.content.moves:register calls directly -- id/name/type/power/
  -- accuracy/pp/effect only, nothing like a `kind`/`zMove` flag) and no
  -- way to read battle_forms's own source data files to enumerate them
  -- properly (same sandboxing limit as isMaxMove above). Best-effort
  -- heuristic instead: every BATTLE_FORMS_-prefixed move that ISN'T a Max/
  -- G-Max move (isMaxMove above) and isn't a Tera Blast variant (a real,
  -- ordinary damaging move Tera just retypes, never Protect-exempt) gets
  -- the flag.
  --
  -- Confirmed bug, fixed here: this originally ran on "mods.loaded",
  -- reasoning that it needed to wait for battle_forms's own moves to be
  -- registered first. Direct read of src/mods/Loader.lua proved that
  -- reasoning backwards -- registry:freeze() (Loader.lua:1465) runs
  -- BEFORE "mods.loaded" is ever emitted (Loader.lua:1476), so every
  -- mod.content.moves:patch call in the original version was silently
  -- throwing "content is frozen after load" inside its own pcall, every
  -- single time -- this whole block was a no-op from the start. The real
  -- fix needs no event wait at all: mod loading is priority-ascending,
  -- ties broken by id (Loader.lua's own orderedIds/_order) -- confirmed
  -- battle_forms's manifest priority is 80, this mod's is 95, so
  -- battle_forms's entire entry function (including every move it
  -- registers) has already finished running by the time this mod's own
  -- entry function -- this line included -- starts. Runs synchronously,
  -- same as every other registration in this file. Logs exactly what it
  -- patched so this heuristic's real coverage is checkable rather than
  -- silently trusted.
  ------------------------------------------------------------------
  do
    local patched = 0
    for id in mod.content.moves:each() do
      if type(id) == "string" and id:match("^BATTLE_FORMS_")
          and not isMaxMove({ id = id })
          and not id:match("^BATTLE_FORMS_TERA_BLAST") then
        local ok = pcall(function() mod.content.moves:patch(id, { bypassesProtect = true }) end)
        if ok then patched = patched + 1 end
      end
    end
    mod.log:info("galar_gmax_dex: modern_combat_protect: marked %d battle_forms move(s) as Protect/Max-Guard-bypassing (Z-Move heuristic)", patched)
  end

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
