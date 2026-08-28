-- Dispatch engine for abilities/data/damage_immunity.lua -- Phase 8a of
-- the ability roadmap ("other" bucket, first batch). Real conditions are
-- read live wherever national_dex/this mod's own primitives already
-- expose them; see the data file's own header for the full per-ability
-- grounding and the honest MAGICGUARD scope note.
return function(mod, data)
  local nationalDex = mod.find and mod.find("national_dex")
  assert(nationalDex and nationalDex.exports and nationalDex.exports.moveFlags,
    "damage_immunity: national_dex must be loaded first")
  local moveFlags = nationalDex.exports.moveFlags
  local abilityIdOf = mod.exports.abilityIdOf
  local registerPostEffectivenessModifier = mod.exports.registerPostEffectivenessModifier
  assert(abilityIdOf and registerPostEffectivenessModifier,
    "damage_immunity: ability_dispatch.lua and modern_combat.lua must load first")

  local function hpOf(mon) return (mon.mon or mon) end

  ------------------------------------------------------------------
  -- WONDERGUARD -- real final type multiplier (ctx.mult), the same
  -- primitive Phase 2's Tinted Lens/Filter family already proved out.
  ------------------------------------------------------------------
  registerPostEffectivenessModifier("wonderguard", 0, function(ctx)
    if abilityIdOf(ctx.target) ~= "WONDERGUARD" then return 1.0 end
    if ctx.mult and ctx.mult > 1.0 then return 1.0 end
    return 0
  end)

  ------------------------------------------------------------------
  -- STURDY, BULLETPROOF/SOUNDPROOF/WINDRIDER, TELEPATHY, MAGICGUARD's
  -- move-caused half (nothing to gate there -- Magic Guard's own scope
  -- is INDIRECT damage; a move that lands normally still deals full
  -- damage to a Magic Guard holder, real confirmed rule) -- all share
  -- the same "battle.damage" wrap combat/modern_combat_protect.lua's own
  -- Protect block and combat/type_immunity.lua already use for "this hit
  -- does nothing." Priority 40, matching type_immunity.lua's own tier
  -- (below Protect's 50 -- a protected Sturdy/Bulletproof holder still
  -- goes through Protect's own block first, unaffected by this file).
  ------------------------------------------------------------------
  local FLAG_IMMUNITY = { BULLETPROOF = "bullet", SOUNDPROOF = "sound", WINDRIDER = "wind" }

  mod.hooks:wrap("battle.damage", function(next, ctx)
    local target = ctx.target
    local user = ctx.user
    local move = ctx.move
    if not (target and move) then return next(ctx) end
    local id = abilityIdOf(target)

    if id == "TELEPATHY" and user and ctx.battle and ctx.battle:sideOf(user) == ctx.battle:sideOf(target) then
      return 0, { crit = false, typeMult = 0 }
    end

    local wantFlag = id and FLAG_IMMUNITY[id]
    if wantFlag then
      local flags = moveFlags(move.id)
      if flags and flags[wantFlag] then
        return 0, { crit = false, typeMult = 0 }
      end
    end

    if id == "STURDY" then
      if move.effect == "OHKO_EFFECT" then
        return 0, { crit = false, typeMult = 0 }
      end
      local m = hpOf(target)
      local maxHp = m.stats and m.stats.hp
      local hpBefore = m.hp or 0
      local dmg, info = next(ctx)
      if maxHp and hpBefore == maxHp and hpBefore > 1 and dmg and dmg >= hpBefore then
        dmg = hpBefore - 1
      end
      return dmg, info
    end

    return next(ctx)
  end, 40)

  ------------------------------------------------------------------
  -- Status residual: Heatproof (halve burn) and Magic Guard (block
  -- poison/burn residual entirely) both patch the same two real
  -- functions Phase 6's Poison Heal already patches -- Gen 1's
  -- Status.RECORDS.PSN/BRN.residual and Gen 2's Battle.STATUSES.
  -- poison/toxic/burn.residual. Each layer captures whatever the
  -- PREVIOUS layer left behind as its own "native" and delegates when
  -- its own ability isn't present, so this composes correctly with
  -- Poison Heal regardless of which loaded first -- Magic Guard is
  -- wrapped LAST (outermost), so it's checked first and unconditionally
  -- wins over either.
  --
  -- Gen 1's own residual functions MUTATE mon.hp directly and return
  -- messages, not a damage number (confirmed by direct read of Status
  -- .lua's damageOverTime) -- Heatproof's own halving here uses the
  -- same "apply then correct" pattern combat/boss_fight_status.lua's
  -- antiDrain already established for exactly this shape, rather than
  -- re-deriving the native damage formula a second time. Gen 2's own
  -- residual functions are pure (return a number, Battle:tickStatus
  -- applies it) -- confirmed by direct read -- so Heatproof there is a
  -- plain halve of the returned number, no correction needed.
  ------------------------------------------------------------------
  local Status = require("src.battle.Status")
  local Battle = require("src.battle.gen2.Battle")

  -- Heatproof is burn-specific (confirmed real, its own effect never
  -- mentions poison) -- no poison-residual wrap needed for it at all,
  -- only Magic Guard's own PSN wrap further below.
  local nativeBrn = Status.RECORDS.BRN.residual
  Status.RECORDS.BRN.residual = function(battler, opponent, battle)
    local hpBefore = hpOf(battler).hp
    local msgs = nativeBrn(battler, opponent, battle)
    if abilityIdOf(battler) == "HEATPROOF" then
      local m = hpOf(battler)
      local dealt = hpBefore - (m.hp or 0)
      if dealt > 0 then
        local maxHp = m.stats and m.stats.hp
        m.hp = math.min(maxHp or m.hp, (m.hp or 0) + math.floor(dealt / 2))
      end
    end
    return msgs
  end

  local function patchGen2BurnResidual()
    local record = Battle.STATUSES.burn
    if not record then return end
    local native = record.residual
    record.residual = function(battle, mon, maxHp)
      local dmg, text = native(battle, mon, maxHp)
      if abilityIdOf(mon) == "HEATPROOF" and dmg then
        dmg = math.max(1, math.floor(dmg / 2))
      end
      return dmg, text
    end
  end
  patchGen2BurnResidual()

  -- Magic Guard, wrapped LAST (outermost) -- unconditional block of
  -- whatever's already there when present.
  local magicGuardPsn = Status.RECORDS.PSN.residual
  Status.RECORDS.PSN.residual = function(battler, opponent, battle)
    if abilityIdOf(battler) == "MAGICGUARD" then return {} end
    return magicGuardPsn(battler, opponent, battle)
  end
  local magicGuardBrn = Status.RECORDS.BRN.residual
  Status.RECORDS.BRN.residual = function(battler, opponent, battle)
    if abilityIdOf(battler) == "MAGICGUARD" then return {} end
    return magicGuardBrn(battler, opponent, battle)
  end
  local function magicGuardGen2(statusKey)
    local record = Battle.STATUSES[statusKey]
    if not record then return end
    local native = record.residual
    record.residual = function(battle, mon, maxHp)
      if abilityIdOf(mon) == "MAGICGUARD" then return 0 end
      return native(battle, mon, maxHp)
    end
  end
  magicGuardGen2("poison")
  magicGuardGen2("toxic")
  magicGuardGen2("burn")

  mod.log:info("g9-battle-engine-beta: damage_immunity installed (STURDY, WONDERGUARD, BULLETPROOF, SOUNDPROOF, WINDRIDER, TELEPATHY, MAGICGUARD, HEATPROOF; SANDFORCE/SANDRUSH/SANDVEIL sand-chip half wired in combat/modern_weather.lua)")
end
