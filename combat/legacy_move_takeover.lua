-- Explicit user directive (2026-08-28): "taking control over them is not
-- duplication, it's centralizing... it's imperative all damage goes
-- through us, else we lose turn order control." Nine real, classic
-- moves (Seismic Toss, Night Shade, Dragon Rage, Sonic Boom, Psywave,
-- Super Fang, the three OHKO moves) all currently resolve their damage
-- through a native short-circuit
-- (`record.chooseDamage` on Gen 1, `Effects.fixedDamage` on Gen 2) that
-- computes a number and hands it straight to the HP-subtraction
-- function -- confirmed by direct source read -- NEVER through
-- `Runtime.call("battle.damage", ...)`, the one real, shared choke
-- point this mod's entire ability system (Protect, every type-immunity
-- ability, Sturdy, Wonder Guard, contact-retaliation, Mold Breaker's
-- own bypass, everything) is built on. Confirmed, concretely: Sturdy
-- currently does NOT save a Gen 1 mon from one of these moves at full
-- HP, because `battle.damage` -- the ONLY place Sturdy's own check
-- lives (abilities/engine/damage_immunity.lua) -- never even runs for
-- them today.
--
-- Fixed here by monkeypatching each move's own real damage-choosing
-- function to route its number through Runtime.call("battle.damage",
-- ...) directly -- the exact same real, sanctioned technique this
-- mod's own combat/modern_combat.lua already uses for battle.crit
-- (confirmed, that file's own header: "Runtime.call('battle.damage',
-- vanilla, ctx) already exists in the core engine for exactly this
-- purpose") -- NOT a new pattern invented here, and NOT re-deriving the
-- formula: every one of these moves keeps its own real fixed-amount
-- math, just handed to the SAME hook chain every other move already
-- goes through, so Protect/Sturdy/type-immunity abilities all get a
-- real chance to intercept it for the first time.
--
-- Real, confirmed GEN 1-SPECIFIC bugs fixed alongside the routing
-- (verified by direct source read, not assumed):
--   1. Seismic Toss/Night Shade/Dragon Rage/Sonic Boom/Super Fang
--      natively skip type-effectiveness/immunity ENTIRELY on Gen 1
--      (MoveEffects.lua's own comment, confirmed: "no immunity check:
--      SetDamageEffects skips AdjustDamageForMoveType" -- Super Fang,
--      Normal-type, incorrectly hits Ghost-types; the same real bug
--      class every one of these five shares). Gen 2's own native
--      implementation ALREADY checks this correctly (gen2/Battle.lua's
--      own real `Damage.typeMultiplier(...) == 0` gate) -- this fix is
--      genuinely Gen 1-only, matching the user's own precise scoping.
--   2. Gen 1's OHKO gate is SPEED-based ("fails against faster
--      opponents," MoveEffects.lua's own comment, confirmed) -- real
--      modern OHKO accuracy is LEVEL-based instead
--      (`(userLevel-targetLevel)*2 + baseAccuracy`, fails outright if
--      targetLevel > userLevel, no Speed involved at all). Gen 2's own
--      native OHKO is ALREADY level-based (gen2/Battle.lua's own real
--      comment: "fails outright against a higher-level target, and the
--      level difference is worth two accuracy points each") -- again,
--      genuinely Gen 1-only.
--   3. Psywave's real Gen 1 (AND Gen 2 -- confirmed, gen2/Effects.lua
--      has the identical shape) formula, `rand(1, floor(level*1.5)-1)`,
--      can roll as low as 1 regardless of level and never reaches the
--      real ceiling; real modern Psywave is
--      `floor(level * random(50,150) / 100)`, a genuinely different
--      range. Fixed for BOTH generations since both share the same
--      real bug, unlike the two Gen-1-only items above.
--
-- EXTENDED 2026-08-28, same directive, "the rest of the moves... Pokemon
-- Showdown logic for generation 9": Sheer Cold (a real OHKO move built
-- fresh via battle.accuracy + battle.damage wraps, sidestepping the
-- Gen 1/2 native effect-string mismatch entirely -- see its own section
-- below), Final Gambit, Nature's Madness/Ruination (all three genuinely
-- new to this engine, no native record on either generation at all),
-- and Counter's own real category-based (not Gen 1's authentic-but-
-- outdated type-based) rule, via a whole-registry `counterable` bulk
-- patch rather than touching the native dispatcher.
return function(mod)
  local Runtime = require("src.mods.Runtime")
  local TypeChart = require("src.battle.TypeChart")

  -- Routes an already-computed (dmg, info) pair through the real,
  -- shared "battle.damage" hook chain -- Protect/type-immunity/Sturdy/
  -- everything else registered on it gets first refusal, exactly as if
  -- this had been a normal formula-driven hit; the base function at the
  -- bottom of the chain just returns the pre-computed number untouched
  -- if nothing above it intercepts.
  local function routeThroughBattleDamage(battle, user, target, move, dmg, info, gen2)
    return Runtime.call("battle.damage", function() return dmg, info end,
      { battle = battle, user = user, target = target, move = move,
        opts = {}, rng = battle.rng or (battle.roller and battle:roller()), gen2 = gen2 })
  end

  local function typeImmune(moveType, targetTypes)
    return targetTypes and TypeChart.effectiveness(moveType, targetTypes) == 0
  end

  ------------------------------------------------------------------
  -- GEN 1
  ------------------------------------------------------------------
  local MoveEffects = require("src.battle.MoveEffects")

  local specialDamageRecord = MoveEffects.full and MoveEffects.full.SPECIAL_DAMAGE_EFFECT
  if specialDamageRecord then
    specialDamageRecord.chooseDamage = function(ctx)
      -- ctx.target.curTypes, NOT ctx.target.mon.curTypes -- confirmed
      -- real shape: this mod's own established curTypesOf accessor
      -- (combat/modern_combat.lua) reads Gen 1's own curTypes straight
      -- off the battler wrapper itself, matching the native
      -- immuneMsg helper this same file (MoveEffects.lua) already uses
      -- for OHKO_EFFECT's own real immunity check -- level/hp are the
      -- ones nested under .mon, not curTypes.
      local targetTypes = ctx.target.curTypes
      if typeImmune(ctx.move.type, targetTypes) then
        return 0, { crit = false, typeMult = 0 }
      end
      local dmg
      local id = ctx.move.id
      if id == "SEISMIC_TOSS" or id == "NIGHT_SHADE" then
        dmg = math.max(1, ctx.user.mon.level or 1)
      elseif id == "PSYWAVE" then
        dmg = math.max(1, math.floor((ctx.user.mon.level or 1) * ctx.rng(50, 150) / 100))
      elseif id == "SONICBOOM" then
        dmg = 20
      elseif id == "DRAGON_RAGE" then
        dmg = 40
      else
        dmg = math.max(1, math.floor(ctx.move.power or 0)) -- real fallback, matches native EFFECT_STATIC_DAMAGE's own shape
      end
      return routeThroughBattleDamage(ctx.battle, ctx.user, ctx.target, ctx.move, dmg,
        { crit = false, typeMult = 10 }, false)
    end
  end

  local superFangRecord = MoveEffects.full and MoveEffects.full.SUPER_FANG_EFFECT
  if superFangRecord then
    superFangRecord.chooseDamage = function(ctx)
      local targetTypes = ctx.target.curTypes
      if typeImmune(ctx.move.type, targetTypes) then
        return 0, { crit = false, typeMult = 0 }
      end
      local dmg = math.max(1, math.floor((ctx.target.mon.hp or 1) / 2))
      return routeThroughBattleDamage(ctx.battle, ctx.user, ctx.target, ctx.move, dmg,
        { crit = false, typeMult = 10 }, false)
    end
  end

  local romText = require("src.core.RomText")
  local Strings = require("src.core.Strings")
  local ohkoRecord = MoveEffects.full and MoveEffects.full.OHKO_EFFECT
  if ohkoRecord then
    -- Real modern accuracy: base 30 (this cart's own real OHKO base,
    -- confirmed unchanged across every generation) + 2 per level the
    -- user is ABOVE the target; fails outright (not just "misses") if
    -- the target is a higher level, checked ahead of any roll.
    ohkoRecord.gate = function(ctx)
      local blocked = TypeChart.effectiveness(ctx.move.type, ctx.target.curTypes) == 0
      if blocked then
        local name = ctx.target.isPlayer and ctx.target.name or Strings("Enemy %s", ctx.target.name)
        return false, romText(ctx.battle.data, "_DoesntAffectMonText",
          "It doesn't affect\n%s!", name)
      end
      local userLevel = ctx.user.mon.level or 1
      local targetLevel = ctx.target.mon.level or 1
      if targetLevel > userLevel then
        return false, romText(ctx.battle.data, "_ButItFailedText", "But, it failed!")
      end
      return true
    end
    ohkoRecord.chooseDamage = function(ctx)
      return routeThroughBattleDamage(ctx.battle, ctx.user, ctx.target, ctx.move, 65535,
        { crit = false, typeMult = 10, ohko = true }, false)
    end
  end

  ------------------------------------------------------------------
  -- GEN 2 -- same real "bypasses battle.damage" architectural gap, but
  -- WITHOUT Gen 1's own two extra bugs: confirmed by direct source read
  -- that Gen 2's own native fixed-damage type-immunity check (gen2/
  -- Battle.lua's own real `Damage.typeMultiplier(...) == 0` gate,
  -- checked ahead of dealDamage) and its own OHKO accuracy (gen2/
  -- Battle.lua's own real comment: "fails outright against a higher-
  -- level target, and the level difference is worth two accuracy
  -- points each") are ALREADY correct -- only the routing needs fixing
  -- here, plus the identical real Psywave formula bug Gen 1 has (gen2/
  -- Effects.lua's own fixedDamage carries the SAME real
  -- `random(ceiling-1)+1` shape).
  --
  -- Effects.fixedDamage itself (the function Gen 1's own equivalent
  -- monkeypatch targets) can't be used as the hook point here: its own
  -- real signature (`effect, attacker, defender, random, power`) is
  -- called from deep inside Battle:useMove with no battle/self
  -- reference passed in at all, confirmed by direct read -- there is no
  -- way to build a real battle.damage ctx from inside it. Battle
  -- :dealDamage (a real method, `self` included) is the next real choke
  -- point EVERY one of these calls funnels through on its way to
  -- actually subtracting HP -- confirmed by direct read of both the
  -- fixed-damage call site (Battle.lua:1764) and EFFECT_OHKO's own
  -- (Battle.lua:2424), both passing `{move=def, moveId=...}` as opts --
  -- so this wraps THAT instead, keyed off `opts.move.effect`, careful to
  -- only touch the five real ids below and leave every other real
  -- dealDamage call (recoil, residual status, Aftermath, Struggle,
  -- everything else that never sets opts.move to one of these) 100%
  -- untouched.
  ------------------------------------------------------------------
  local Battle2 = require("src.battle.gen2.Battle")
  local FIXED_EFFECT_IDS = {
    EFFECT_LEVEL_DAMAGE = true, EFFECT_SUPER_FANG = true,
    EFFECT_PSYWAVE = true, EFFECT_STATIC_DAMAGE = true, EFFECT_OHKO = true,
  }
  local nativeDealDamage = Battle2.dealDamage
  function Battle2:dealDamage(attacker, defender, damage, opts)
    local effect = opts and opts.move and opts.move.effect
    if effect and FIXED_EFFECT_IDS[effect] then
      if effect == "EFFECT_PSYWAVE" then
        -- Real modern formula, same fix as Gen 1's own (this file's own
        -- header) -- self.random(n) returns 0..n-1 (confirmed by
        -- gen2/Effects.lua's own real fixedDamage usage), so
        -- self.random(101)+50 gives a real inclusive [50,150] range.
        damage = math.max(1, math.floor((attacker.level or 1)
          * (self.random(101) + 50) / 100))
      end
      local adjusted, info = routeThroughBattleDamage(self, attacker, defender,
        opts.move, damage, { crit = false, typeMult = 10, ohko = effect == "EFFECT_OHKO" }, true)
      return nativeDealDamage(self, attacker, defender, adjusted, opts)
    end
    return nativeDealDamage(self, attacker, defender, damage, opts)
  end

  ------------------------------------------------------------------
  -- SHEER COLD -- un-deferred 2026-08-28 (explicit user directive: "the
  -- rest of the moves, based on Pokemon Showdown logic for generation
  -- 9"). The original "no native record on either engine" blocker is
  -- real, but it turns out not to matter: unlike the nine moves above,
  -- this one needs NO native record to hook at all -- a `battle.damage`
  -- wrap keyed on `ctx.move.id` (this mod's OWN choice of id string,
  -- since national_dex already registers Sheer Cold as a real, playable
  -- move with no working native effect behind it either) reaches it
  -- exactly the same way computeModernDamage's own base formula would
  -- have, and `battle.accuracy` (a real, separate, already-hookable
  -- extension point -- confirmed shared, same ctx keys, both engines,
  -- accuracy_multiplier.lua's own header) covers the real level-based
  -- gate directly, with no dependency on either engine's own
  -- "OHKO_EFFECT" vs "EFFECT_OHKO" naming at all.
  ------------------------------------------------------------------
  mod.hooks:wrap("battle.accuracy", function(next, ctx)
    local moveId = (ctx.move and ctx.move.id) or ctx.moveId
    if moveId ~= "SHEERCOLD" then return next(ctx) end
    local isGen2Battle = mod.exports.isGen2Battle
    local gen2 = isGen2Battle and ctx.battle and isGen2Battle(ctx.battle)
    local user, target = ctx.user, ctx.target
    local userLevel = gen2 and user.level or (user.mon and user.mon.level) or 1
    local targetLevel = gen2 and target.level or (target.mon and target.mon.level) or 1
    if targetLevel > userLevel then return false end
    return next(ctx)
  end, 0)

  mod.hooks:wrap("battle.damage", function(next, ctx)
    local moveId = ctx.move and ctx.move.id
    if moveId ~= "SHEERCOLD" then return next(ctx) end
    local isGen2Battle = mod.exports.isGen2Battle
    local curTypesOf = mod.exports.curTypesOf
    local gen2 = isGen2Battle and ctx.battle and isGen2Battle(ctx.battle)
    local targetTypes = curTypesOf and curTypesOf(ctx.target, gen2)
    if typeImmune(ctx.move.type, targetTypes) then
      return 0, { crit = false, typeMult = 0 }
    end
    return 65535, { crit = false, typeMult = 10, ohko = true }
  end, 1)

  ------------------------------------------------------------------
  -- FINAL GAMBIT -- real Showdown: the user faints, dealing damage to
  -- the target equal to its OWN current HP (read and self-applied
  -- BEFORE the target's own damage is returned, matching real
  -- Showdown's own real order: `directDamage(pokemon.hp, ...)` happens
  -- first, then that same number becomes the returned damage). Only
  -- actually faints the user if the hit genuinely lands (wrapped INSIDE
  -- the "battle.damage" chain, so Protect/type-immunity above this
  -- still correctly refuse the whole thing, self-faint included -- a
  -- blocked Final Gambit costs nothing).
  ------------------------------------------------------------------
  mod.hooks:wrap("battle.damage", function(next, ctx)
    local moveId = ctx.move and ctx.move.id
    if moveId ~= "FINALGAMBIT" then return next(ctx) end
    local user = ctx.user
    local m = user.mon or user
    local hp = m.hp or 0
    if hp <= 0 then return 0, { crit = false, typeMult = 0 } end
    m.hp = 0
    return hp, { crit = false, typeMult = 10 }
  end, 1)

  ------------------------------------------------------------------
  -- NATURE'S MADNESS / RUINATION -- real Showdown: both share the
  -- identical real formula, halving the target's CURRENT hp (floored,
  -- minimum 1) -- confirmed the same real fixed-damage shape, just two
  -- different move ids/generations for the identical mechanic.
  ------------------------------------------------------------------
  mod.hooks:wrap("battle.damage", function(next, ctx)
    local moveId = ctx.move and ctx.move.id
    if moveId ~= "NATURESMADNESS" and moveId ~= "RUINATION" then return next(ctx) end
    local m = ctx.target.mon or ctx.target
    local dmg = math.max(1, math.floor((m.hp or 1) / 2))
    return dmg, { crit = false, typeMult = 10 }
  end, 1)

  ------------------------------------------------------------------
  -- COUNTER -- real modern rule: counts the last CATEGORY=Physical
  -- move taken, not "Normal or Fighting-TYPE" (Gen 1's own real native
  -- check, confirmed by direct read of EffectRegistry.lua -- a real
  -- fact about the authentic cartridge, not a bug on ITS OWN terms, but
  -- not modern-accurate either). The native dispatcher's own hardcoded
  -- `if move.id == "COUNTER"` branch has no `record`-shaped extension
  -- point to monkeypatch (confirmed, see this file's own header) -- but
  -- its own real condition ALREADY checks a genuine, real, per-move
  -- DATA OVERRIDE first (`lm.counterable`, confirmed by direct read)
  -- before ever falling back to the type check, so this closes the gap
  -- without touching that function at all: every real move gets its own
  -- correct `counterable` flag patched directly, matching its own real
  -- damageClass, using the exact same whole-registry bulk-patch pattern
  -- combat/modern_combat_protect.lua's own Z-Move heuristic already
  -- established (pcall-guarded, both the whole pass and each individual
  -- patch, logged count).
  ------------------------------------------------------------------
  do
    local nationalDex = mod.find and mod.find("national_dex")
    local moveById = nationalDex and nationalDex.exports and nationalDex.exports.moveById
    if moveById and mod.content and mod.content.moves then
      local runOk, runErr = pcall(function()
        local patched = 0
        for id in mod.content.moves:each() do
          if type(id) == "string" then
            local ok, info = pcall(moveById, id)
            if ok and info and info.damageClass then
              local physical = info.damageClass == "physical"
              local patchOk = pcall(function()
                mod.content.moves:patch(id, { counterable = physical })
              end)
              if patchOk then patched = patched + 1 end
            end
          end
        end
        mod.log:info("g9-battle-engine-beta: legacy_move_takeover: Counter's own real "
          .. "counterable flag patched onto %d move(s) (category-based, real modern rule, "
          .. "replacing Gen 1's own real type-based cartridge check)", patched)
      end)
      if not runOk then
        mod.log:warn("g9-battle-engine-beta: legacy_move_takeover: Counter counterable "
          .. "bulk-patch errored, skipped (%s)", tostring(runErr))
      end
    end
  end

  mod.log:info("g9-battle-engine-beta: legacy_move_takeover installed, both generations "
    .. "(SEISMICTOSS, NIGHTSHADE, DRAGONRAGE, SONICBOOM, PSYWAVE, SUPERFANG, "
    .. "FISSURE/GUILLOTINE/HORNDRILL centralized through battle.damage; SHEERCOLD, "
    .. "FINALGAMBIT, NATURESMADNESS/RUINATION built fresh; COUNTER's own real "
    .. "counterable flag bulk-patched)")
end
