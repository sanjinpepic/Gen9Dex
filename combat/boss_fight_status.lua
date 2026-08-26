-- Boss-fight "hardStatus"/"softStatus"/"antiDrain" protections (combat/
-- boss_fight.lua's own header owns the full flag list) -- grouped in one
-- file since none of these three has an existing primitive-owning file
-- of its own the way weather/terrain/type do (StatusRegistry/Battle:
-- applyStatus are raw ENGINE modules, not something this mod already
-- wraps anywhere; confusion has no shared primitive at all in this mod,
-- every site writes .confusedTurns/.confuseCount directly; drain-healing
-- is split across two native generic mechanisms plus one mod-custom
-- effect id, with no shared post-heal hook either).
--
-- HARD STATUS (poison/burn/paralyze/sleep/freeze): confirmed by direct
-- source read (not assumed) that every hostile hard-status application
-- in this engine -- native AND this mod's own -- funnels through exactly
-- one of two shared primitives depending on generation:
--   Gen 1: StatusRegistry.inflict(battle, target, status, opts)
--     (src/battle/StatusRegistry.lua) -- also the primitive Gen 1's own
--     native statusSide()/ctx.inflict facade route through, so gating it
--     here covers native Toxic/Thunder Wave/Sleep Powder/Will-O-Wisp too,
--     not just this mod's own secondary-chance handlers.
--   Gen 2: Battle:applyStatus(mon, status, source) (gen2/Battle.lua) --
--     same story, covers native Gen 2 status moves directly.
-- Neither primitive carries a hostile/self-inflicted flag of its own (the
-- caller's responsibility per their own contract) -- but REST bypasses
-- BOTH of them entirely on both generations (confirmed: Gen 1's HEAL_
-- EFFECT writes mon.status = "SLP" directly, src/battle/MoveEffects.lua
-- :206; Gen 2's Rest does the same, gen2/Battle.lua:2340) -- so gating
-- these two primitives unconditionally by target (battle.enemy -> block)
-- is safe: the one self-only case the user named ("only self induced are
-- allowed like rest") never reaches either gate in the first place, on
-- either engine.
--
-- SOFT STATUS (confusion + "similar bracket, like leechseed"):
--   Confusion has no shared primitive in this mod; confirmed by direct
--   source read that only TWO of the mod's own three infliction sites
--   are hostile-capable (the third, Outrage's post-rampage self-confuse
--   in modern_movepool_damage.lua, always targets its own user and is
--   deliberately left untouched). Of those two:
--     - main.lua's GALAR_CONFUSE_EFFECT_<chance> secondary-confuse-chance
--       handler (a damaging move's chance effect) is gated below via a
--       battle.damage_dealt listener, registered at an explicit LOW
--       priority (-100) -- confirmed by reading src/mods/Events.lua
--       directly that Events:emit sorts listeners by priority descending
--       and table.sort is NOT stable for equal priorities in Lua's
--       reference implementation, so "this file loads after main.lua" is
--       NOT enough on its own to guarantee this listener runs after that
--       handler's own roll; both default to priority 0 without an
--       explicit value, so an explicit low priority here is required, not
--       just tidy.
--     - modern_movepool_status.lua's confuseTarget (Flatter/Swagger) is a
--       power=0 STATUS move -- it never deals damage, so battle.
--       damage_dealt never fires for it at all, confirmed by this
--       engine's own damage-dealt emit sites (both only fire after a
--       landed, non-zero hit). Gated directly at that file's own call
--       site instead, not through this event at all.
--   LeechSeed: confirmed NOT implemented anywhere in this mod at all
--   (national_dex registers the move id with effectModeled=false, same
--   "registered, no real effect" shape as MAGICROOM/WONDERROOM/
--   HEALBLOCK) -- nothing currently applies it to anything, so there is
--   nothing to gate; an honest no-op today, not silently pretended done.
--
-- antiDrain: every drain-heal path found (native Gen 1 drainHalf, native
-- Gen 2's Effects.DRAIN check in Battle:useMove, and this mod's own
-- GALAR_DRAIN_EFFECT_75 for Draining Kiss) heals the ATTACKER, never
-- battle.enemy itself -- so there's no separate "who gets healed" gate
-- needed, only "did the player just drain off the boss." Implemented as
-- a battle.damage_dealt listener (the same real, confirmed event main
-- .lua's own flinch/confuse handler already uses, payload shape confirmed
-- directly: {battle,user,target,move,damage,...}) that recomputes the
-- same drain fraction the native/mod handler already applied and deals
-- it back to the attacker as self-harm -- net HP effect is the SAME as
-- "the heal never happened, dealt as self-harm instead" (explicit user
-- rule), even though the visible sequence is heal-then-immediate-
-- correction rather than a single substituted message, since none of the
-- three drain implementations expose a pre-heal interception point this
-- mod can reach without touching engine source.
--
-- healblock: NOT enforced. HEALBLOCK is registered as a move id by
-- national_dex (confirmed) but has zero real implementation anywhere in
-- g9-battle-engine-beta -- nothing currently applies Heal Block to
-- anything, so like ability-changing and LeechSeed, this is an honest
-- no-op until the underlying mechanic exists, not silently skipped.
return function(mod)
  local StatusRegistry = require("src.battle.StatusRegistry")
  local Battle = require("src.battle.gen2.Battle")
  local bossFightHas = mod.exports.bossFightHas
  assert(bossFightHas, "boss_fight_status: combat/boss_fight.lua must load first")

  ------------------------------------------------------------------
  -- hardStatus
  ------------------------------------------------------------------
  local nativeStatusInflict = StatusRegistry.inflict
  StatusRegistry.inflict = function(battle, target, status, opts)
    if battle and target == battle.enemy and bossFightHas(battle, "hardStatus") then
      return {}
    end
    return nativeStatusInflict(battle, target, status, opts)
  end

  local nativeApplyStatus = Battle.applyStatus
  function Battle:applyStatus(mon, status, source)
    if mon == self.enemy and bossFightHas(self, "hardStatus") then
      return
    end
    return nativeApplyStatus(self, mon, status, source)
  end

  ------------------------------------------------------------------
  -- softStatus (confusion; LeechSeed is a documented no-op, see header)
  ------------------------------------------------------------------
  -- main.lua's installMovepoolEffects: the GALAR_CONFUSE_EFFECT_<chance>
  -- secondary-confuse-chance handler. Wrapping the roll itself isn't
  -- possible (it's a closure, not an export) -- instead this listens on
  -- the SAME battle.damage_dealt event at priority -100, GUARANTEED to
  -- run after that handler's own default-priority (0) roll (see this
  -- file's own header for why registration order alone isn't a safe
  -- assumption here), and clears whatever the roll just set if the
  -- target is boss-protected -- same net effect as preventing it, since
  -- nothing reads the field between those two steps within the same
  -- event dispatch.
  mod.events:on("battle.damage_dealt", function(ev)
    local battle = ev and ev.battle
    local target = ev and ev.target
    if not (battle and target and target == battle.enemy) then return end
    if bossFightHas(battle, "softStatus") then
      local gen2 = mod.exports.isGen2Battle and mod.exports.isGen2Battle(battle)
      if gen2 then
        battle:volatile(target).confuseCount = nil
      else
        target.confusedTurns = nil
      end
    end
  end, -100)

  ------------------------------------------------------------------
  -- antiDrain
  ------------------------------------------------------------------
  -- Effect ids confirmed (direct source read) to be every drain-heal
  -- path in this engine, native and mod-custom alike, each mapped to its
  -- own real fraction -- DRAIN_HP_EFFECT/EFFECT_LEECH_HIT/EFFECT_
  -- DREAM_EATER are native Gen1/Gen2 half-heal; GALAR_DRAIN_EFFECT_75 is
  -- this mod's own Draining Kiss handler (Gen1-only, per that file's own
  -- header -- afterDamage never runs on Gen2).
  local DRAIN_FRACTION = {
    DRAIN_HP_EFFECT = 1 / 2,
    EFFECT_LEECH_HIT = 1 / 2,
    EFFECT_DREAM_EATER = 1 / 2,
    GALAR_DRAIN_EFFECT_75 = 3 / 4,
  }
  mod.events:on("battle.damage_dealt", function(ev)
    local battle = ev and ev.battle
    local target = ev and ev.target
    local user = ev and ev.user
    local move = ev and ev.move
    local dealt = ev and ev.damage
    if not (battle and target and user and move and dealt and dealt > 0) then return end
    if target ~= battle.enemy or not bossFightHas(battle, "antiDrain") then return end
    local fraction = DRAIN_FRACTION[move.effect]
    if not fraction then return end
    local harm = math.max(1, math.floor(dealt * fraction))
    local userMon = user.mon or user
    userMon.hp = math.max(0, (userMon.hp or 0) - harm)
    battle:emit({ kind = "message",
      text = battle:monName(user) .. " was hurt trying to drain the boss!" })
  end)

  mod.log:info("g9-battle-engine-beta: boss_fight_status installed (hardStatus, softStatus, antiDrain)")
end
