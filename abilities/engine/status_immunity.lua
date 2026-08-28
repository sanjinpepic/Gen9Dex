-- Dispatch engine for abilities/data/status_immunity.lua -- Phase 3a of
-- the ability roadmap (PROGRESS.md's own "Phases 2-8" list, status/type
-- immunity next after Phase 2's damage/defense multipliers). That file
-- is only an inclusion list; which status each ability blocks is read
-- LIVE from national_dex's own abilityBehaviorOf here, at check time,
-- every time -- nothing about the effect itself is duplicated into this
-- mod's own data.
--
-- FOUR real infliction sites this engine has, confirmed by direct source
-- read (not assumed) -- every one of them gets its own explicit gate,
-- since none of the three status FAMILIES (hard status, flinch,
-- confusion) shares a primitive with either of the others:
--
-- 1. HARD STATUS (poison/burn/paralyze/sleep/freeze): funnels through
--    exactly one of two shared primitives depending on generation --
--    StatusRegistry.inflict (Gen 1) / Battle:applyStatus (Gen 2) -- the
--    SAME two combat/boss_fight_status.lua's own hardStatus flag already
--    wraps (see that file's own header for the full grounding on why
--    wrapping these two covers every native AND mod-custom hostile
--    status application, and why Rest safely bypasses both). Wrapped
--    again here, independently -- gating by the TARGET's own ability
--    this time, not a battle-wide boss flag, and by the SPECIFIC status
--    the ability blocks, not "every hard status."
--
--    Gen 1 codes (src/battle/Status.lua's own record ids, confirmed:
--    SLP/FRZ/BRN/PAR/PSN) and Gen 2 words (gen2/Battle.lua's own
--    EFFECT_* table, confirmed: sleep/freeze/burn/paralyze/poison) are
--    two genuinely different spellings for the same five statuses --
--    neither matches national_dex's own canonical strings
--    (paralysis/freeze/burn/sleep/poison) exactly, so STATUS_ALIASES
--    below is a real, necessary naming-convention adapter (the same
--    class of thing switchin_stat_change.lua's own STAT_KEY already is),
--    not game data.
--
-- 2. FLINCH: main.lua's installMovepoolEffects sets target.flinched
--    (Gen 1) / battle:volatile(target).flinched (Gen 2) directly, not
--    through any shared primitive -- gated at that call site itself
--    (see the check added there) via hasStatusImmunity below, since
--    there's nothing here to wrap.
--
-- 3+4. CONFUSION: no shared primitive in this mod either (boss_fight_
--    status.lua's own header: "every site writes .confusedTurns/
--    .confuseCount directly"). Three real infliction sites exist, all
--    gated directly at their own call sites the same way: main.lua's
--    secondary-confuse-chance listener, modern_movepool_status.lua's
--    confuseTarget (Flatter/Swagger), and modern_movepool_damage.lua's
--    Outrage/Thrash post-rampage self-confuse -- the third one is
--    self-inflicted, unlike boss-fight softStatus (which deliberately
--    left it untouched, hostile-only in scope), but real Own Tempo does
--    block self-inflicted rampage confusion too, so it's gated here.
--
-- SWEETVEIL is the one ally-scope case (protects allies too, not just
-- self) -- reuses combat/move_targeting.lua's own requestAdjacency, the
-- same primitive switchin_stat_change.lua's Intimidate now uses for the
-- opposite direction (checking foes); here it's the mon's OWN side being
-- checked. See abilities/data/status_immunity.lua's own header for why
-- self is checked unconditionally regardless of the dataset's "allies"
-- scope label.
return function(mod, data)
  local abilityIdOf = mod.exports.abilityIdOf
  local abilityBehaviorOf = mod.exports.abilityBehaviorOf
  local requestAdjacency = mod.exports.requestAdjacency
  assert(abilityIdOf and abilityBehaviorOf and requestAdjacency,
    "status_immunity: ability_dispatch.lua and move_targeting.lua must load first")

  local STATUS_ALIASES = {
    -- Gen 1 codes -> national_dex's own canonical spelling
    SLP = "sleep", FRZ = "freeze", BRN = "burn", PAR = "paralysis", PSN = "poison", TOX = "poison",
    -- Gen 2 words -> national_dex's own canonical spelling
    sleep = "sleep", freeze = "freeze", burn = "burn", paralyze = "paralysis", poison = "poison", toxic = "poison",
  }

  -- canonicalStatusOf(mon) -- the mon's CURRENT major status, normalized
  -- to national_dex's own spelling, or nil. Reused by abilities/engine/
  -- stat_multiplier.lua (Flare Boost/Toxic Boost's own "while
  -- burned"/"while poisoned" condition) rather than rebuilding this same
  -- Gen1-code/Gen2-word adapter a second time.
  mod.exports.canonicalStatusOf = function(mon)
    local raw = mon and (mon.mon and mon.mon.status or mon.status)
    return raw and STATUS_ALIASES[raw] or nil
  end

  -- The one status this ability's own record blocks, or nil. Reads
  -- live off abilityBehaviorOf every call -- no caching, no precompute.
  local function blockedStatusOf(mon)
    local id = abilityIdOf(mon)
    if not (id and data[id]) then return nil end
    local record = abilityBehaviorOf(mon)
    local behavior = record and record.behaviour
    for _, eff in ipairs(behavior and behavior.effects or {}) do
      if eff.kind == "status_immunity" and eff.status then return eff.status end
    end
    return nil
  end

  -- hasStatusImmunity(mon, canonicalStatus) -- canonicalStatus is one of
  -- national_dex's own strings: "paralysis"/"freeze"/"burn"/"sleep"/
  -- "poison"/"confusion"/"flinch". Checks the mon's own ability first
  -- (every real case except Sweet Veil's sleep block), then -- sleep
  -- only -- whether an ally carries Sweet Veil. battle is optional: the
  -- ally check is skipped without one (self-only, always correct for
  -- every OTHER status regardless).
  local function hasStatusImmunity(mon, canonicalStatus, battle)
    if not mon then return false end
    local blocked = blockedStatusOf(mon)
    if blocked == "any" or blocked == canonicalStatus then return true end
    if canonicalStatus == "sleep" and battle then
      for _, ally in ipairs(requestAdjacency(battle, mon, nil).allies) do
        local allyBlocked = blockedStatusOf(ally)
        if allyBlocked == "any" or allyBlocked == "sleep" then return true end
      end
    end
    return false
  end
  mod.exports.hasStatusImmunity = hasStatusImmunity

  ------------------------------------------------------------------
  -- 1. Hard status -- StatusRegistry.inflict (Gen 1) / Battle:applyStatus
  -- (Gen 2), both wrapped independently of boss_fight_status.lua's own
  -- wraps (both mods' checks run; either one blocking is enough).
  ------------------------------------------------------------------
  local StatusRegistry = require("src.battle.StatusRegistry")
  local Battle = require("src.battle.gen2.Battle")

  -- target here is the battler itself (StatusRegistry.lua's own body
  -- reads target.mon.status/target.curTypes/target.substituteHP
  -- directly on it, confirmed by direct read) -- the same object
  -- abilityIdOf already expects everywhere else in this mod (switchin_
  -- stat_change.lua's own applySwitchInAbility is called with
  -- battle.player/battle.enemy directly), so no unwrap is needed here.
  local nativeStatusInflict = StatusRegistry.inflict
  StatusRegistry.inflict = function(battle, target, status, opts)
    local canonical = STATUS_ALIASES[status]
    if canonical and hasStatusImmunity(target, canonical, battle) then return {} end
    return nativeStatusInflict(battle, target, status, opts)
  end

  local nativeApplyStatus = Battle.applyStatus
  function Battle:applyStatus(mon, status, source)
    local canonical = STATUS_ALIASES[status]
    if canonical and hasStatusImmunity(mon, canonical, self) then return false end
    return nativeApplyStatus(self, mon, status, source)
  end

  mod.log:info("g9-battle-engine-beta: status_immunity installed (10 abilities: INNERFOCUS, MAGMAARMOR, LIMBER, OWNTEMPO, PURIFYINGSALT, SWEETVEIL, VITALSPIRIT, THERMALEXCHANGE, WATERVEIL, WATERBUBBLE)")
end
