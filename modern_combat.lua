-- Native Lua port of the modern (Gen 6+) damage formula, replacing the
-- Showdown live-bridge approach entirely: this hooks the engine's own
-- sanctioned battle.damage extension point (BattleState:computeDamage,
-- src/battle/BattleState.lua:2239-2247) rather than monkey-patching a
-- BattleState method directly -- Runtime.call("battle.damage", vanilla,
-- ctx) already exists in the core engine for exactly this purpose, and
-- mod.hooks:wrap is the real, generic public API every mod gets
-- (src/mods/Loader.lua:598), not something invented for this file.
--
-- Applies to EVERY battle (wild, trainer, link) -- there is no kind=="wild"
-- gate anywhere in this file, unlike the retired Showdown bridge.
--
-- Reused, not reimplemented: MoveCategory.of (src/pokemon/MoveCategory.lua)
-- for Physical/Special/Status, ModernStats.ensure (src/pokemon/
-- ModernStats.lua) for spa/spd + EV/IV/nature, TypeChart.effectiveness/
-- .rows (src/battle/TypeChart.lua, already includes modern_type_framework's
-- registered types via the shared type_chart content registry) for type
-- effectiveness, Stats.applyStage for stat stages. None of this is
-- reimplemented here -- only the parts nothing else in the engine already
-- does in a modern way: the spa/spd-aware formula shape, a real
-- multiplier-slot chain, and a stage-based crit.
return function(mod)
  local Runtime = require("src.mods.Runtime")
  local MoveCategory = require("src.pokemon.MoveCategory")
  local ModernStats = require("src.pokemon.ModernStats")
  local TypeChart = require("src.battle.TypeChart")
  local Stats = require("src.pokemon.Stats")
  local Status = require("src.battle.Status")
  local Damage = require("src.battle.Damage") -- BADGE_BOOSTS table only, reused as data

  ------------------------------------------------------------------
  -- Multiplier-slot framework: named, priority-ordered damage
  -- modifiers, applied one at a time (each its own floor step, same
  -- style native Damage.compute already uses for type-effectiveness
  -- rows rather than one combined fraction) so a later pass can add
  -- an entry without ever touching computeModernDamage's body.
  --
  -- STAB is the only built-in entry today. Documented, NOT implemented,
  -- extension points for later work (deliberately out of scope this
  -- pass, per explicit user priority: "the whole framework first"):
  --   "tera_stab" (~priority 110, above "stab"): needs a battler
  --     teraType field that doesn't exist yet on this engine's battler
  --     shape -- 2.0x when move.type == teraType and teraType isn't
  --     already one of the mon's natural types, else defer to "stab".
  --   "adaptability_stab": an ability multiplier replacing stab's 1.5x
  --     with 2.0x for a matching type -- register at the same priority
  --     as "stab" and have "stab" itself check for the ability and
  --     return 1.0 (deferring) when adaptability's entry already fired.
  --   general ability/item damage multipliers: priority < 100 (after
  --     STAB), e.g. Life Orb, Choice Band, a damage-boosting ability.
  ------------------------------------------------------------------
  local damageModifiers = {} -- { {id=, priority=, fn=}, ... }, sorted desc

  local function registerDamageModifier(id, priority, fn)
    assert(type(id) == "string" and id ~= "", "damage modifier id is required")
    assert(type(fn) == "function", "damage modifier must be a function")
    for i, entry in ipairs(damageModifiers) do
      if entry.id == id then table.remove(damageModifiers, i) break end
    end
    table.insert(damageModifiers, { id = id, priority = priority or 0, fn = fn })
    table.sort(damageModifiers, function(a, b) return a.priority > b.priority end)
  end
  mod.exports.registerDamageModifier = registerDamageModifier

  local critStageModifiers = {} -- { fn(ctx) -> integer stage delta, ... }
  local function registerCritStageModifier(id, fn)
    assert(type(id) == "string" and id ~= "", "crit stage modifier id is required")
    assert(type(fn) == "function", "crit stage modifier must be a function")
    critStageModifiers[id] = fn
  end
  mod.exports.registerCritStageModifier = registerCritStageModifier

  -- Built-in: STAB. A flat 1.5x when the move's type is one of the
  -- attacker's current types (curTypes -- Transform/Conversion-aware,
  -- same field native Damage.compute already reads).
  registerDamageModifier("stab", 100, function(ctx)
    for _, t in ipairs(ctx.user.curTypes or {}) do
      if t == ctx.move.type then return 1.5 end
    end
    return 1.0
  end)

  ------------------------------------------------------------------
  -- Stat-stage bookkeeping. Previously an explicitly flagged
  -- approximation (spa/spd sharing one "special" stage slot, a Gen-1
  -- relic); now split into independent stages.spa/stages.spd keys, so
  -- Amnesia only ever raises Sp.Def and Charm only ever lowers Attack.
  -- Badge boosts stay mapped to the single "special" row in
  -- Damage.BADGE_BOOSTS on purpose -- the in-game Kanto badge system
  -- (VOLCANOBADGE) is a real-game concept unrelated to this split, and
  -- boosting both spa and spd equally from one badge matches how the
  -- original Gen 1 -> Gen 2 conversion treated it.
  ------------------------------------------------------------------
  local function stageKeyFor(statKey)
    return statKey
  end
  local function badgeStatNameFor(statKey)
    if statKey == "spa" or statKey == "spd" then return "special" end
    return statKey
  end

  local function badgeBoost(battler, statKey)
    local badges = battler.badges
    if not badges then return nil end
    local badgeStat = badgeStatNameFor(statKey)
    for _, row in ipairs(battler.badgeBoosts or Damage.BADGE_BOOSTS) do
      if row.stat == badgeStat and badges[row.badge] then return row end
    end
    return nil
  end

  local function statusRecord(battler)
    return Status.recordFor(battler.statuses, battler.mon.status)
  end

  ------------------------------------------------------------------
  -- changeModernStage: same contract/messages as native
  -- MoveEffects.changeStage (src/battle/MoveEffects.lua), reused
  -- directly for every stat except spa/spd -- native's STAT_LABEL
  -- table only knows attack/defense/speed/special/accuracy/evasion, so
  -- calling native changeStage with "spa"/"spd" would look up a nil
  -- label. This is the one small piece that has to be reimplemented
  -- rather than reused, mirroring native's logic exactly (Mist/
  -- Substitute protection, the -6..+6 clamp, "nothing happened", the
  -- rise/greatly-rose message tiers) with real Sp. Atk/Sp. Def labels.
  -- Exported so future ability/item work can reuse it without
  -- reaching back into native MoveEffects at all.
  ------------------------------------------------------------------
  local MoveEffects = require("src.battle.MoveEffects")
  local romText = require("src.core.RomText")
  local Strings = require("src.core.Strings")

  local MODERN_STAT_LABEL = { spa = "Sp. Atk", spd = "Sp. Def" }

  local function changeModernStage(battle, who, stat, delta, fromEnemy)
    if not MODERN_STAT_LABEL[stat] then
      return MoveEffects.changeStage(battle, who, stat, delta, fromEnemy)
    end
    if fromEnemy and (who.substituteHP or who.mist) then
      if who.mist then
        return { Strings("%s is\nprotected by MIST!", (who.isPlayer and who.name) or Strings("Enemy %s", who.name)) }
      end
      return { romText(battle.data, "_ButItFailedText", "But, it failed!") }
    end
    local cur = who.stages[stat] or 0
    local new = math.max(-6, math.min(6, cur + delta))
    if new == cur then
      return { romText(battle.data, "_NothingHappenedText", "Nothing happened!") }
    end
    who.stages[stat] = new
    who.hazeStatReset = nil
    local label = MODERN_STAT_LABEL[stat]
    local name = (who.isPlayer and who.name) or Strings("Enemy %s", who.name)
    if delta >= 2 then
      return { Strings("%s's\n%s\ngreatly rose!", name, label) }
    elseif delta == 1 then
      return { Strings("%s's\n%s rose!", name, label) }
    elseif delta == -1 then
      return { Strings("%s's\n%s fell!", name, label) }
    end
    return { Strings("%s's\n%s\ngreatly fell!", name, label) }
  end
  mod.exports.changeModernStage = changeModernStage

  -- The only three native Gen-1 moves that touch the old shared
  -- "special" stage (confirmed by grepping data/generated/moves.lua for
  -- every SPECIAL_UP1_EFFECT/SPECIAL_UP2_EFFECT/SPECIAL_DOWN_SIDE_EFFECT
  -- reference -- exactly AMNESIA, GROWTH, PSYCHIC_M, nothing else).
  -- Re-pointed at real Gen 2+ targeting instead of Gen 1's combined
  -- Special stat. None of GalarGmaxDex's own 174 new moves reference any
  -- stat-stage effect yet (grepped: zero matches) -- those are a
  -- separate, pre-existing "NO_ADDITIONAL_EFFECT placeholder" gap this
  -- pass does not attempt to close.
  -- Dispatch contract confirmed by reading BattleState:performMove
  -- directly (BattleState.lua:3543-3579): a pure status move (power==0)
  -- requires record.kind == "primary" AND record.run, called as
  -- record.run(ctx) -- NOT the raw (battle,user,target) signature
  -- native's own internal statUp/statDown helpers happen to use (those
  -- get adapted into this same {kind=,run=} shape by MoveEffects'
  -- own registry-building code; a mod-registered record has to match
  -- the {kind=,run=function(ctx)} shape directly, same as
  -- GALAR_FLINCH_EFFECT_*/GALAR_CONFUSE_EFFECT_* already do in
  -- main.lua's installMovepoolEffects). A damaging move's secondary
  -- chance-effect (kind == "secondary") runs through
  -- EffectRegistry.runDamaging instead, same ctx-based run(ctx) shape.
  mod.content.move_effects:register("GMAX_AMNESIA_EFFECT", {
    kind = "primary",
    run = function(ctx)
      -- Amnesia: Sp. Def +2 only (Gen 2+), not the combined Special +2
      -- Gen 1 originally had.
      return changeModernStage(ctx.battle, ctx.user, "spd", 2, false)
    end,
  })
  mod.content.moves:patch("AMNESIA", { effect = "GMAX_AMNESIA_EFFECT" })

  mod.content.move_effects:register("GMAX_GROWTH_EFFECT", {
    kind = "primary",
    run = function(ctx)
      -- Growth: Attack +1 AND Sp. Atk +1 (Gen 5+ behavior; Gen 2-4 only
      -- raised Special/Sp.Atk -- Gen 5+ is the more modern, current rule
      -- and matches this ruleset's overall Gen 9-oriented direction).
      local atkMsg = MoveEffects.changeStage(ctx.battle, ctx.user, "attack", 1, false)
      local spaMsg = changeModernStage(ctx.battle, ctx.user, "spa", 1, false)
      local out = {}
      for _, m in ipairs(atkMsg) do out[#out + 1] = m end
      for _, m in ipairs(spaMsg) do out[#out + 1] = m end
      return out
    end,
  })
  mod.content.moves:patch("GROWTH", { effect = "GMAX_GROWTH_EFFECT" })

  mod.content.move_effects:register("GMAX_PSYCHIC_SPD_EFFECT", {
    kind = "secondary",
    run = function(ctx)
      -- Psychic: 33%+1 (85/256) chance to lower the target's Sp. Def by
      -- 1 -- matches native statDownSide's exact roll (MoveEffects.lua),
      -- just retargeted from the combined Special stat to Sp. Def only.
      -- fromEnemy=false matches native's own side-effect call: the side-
      -- effect branch never runs MoveHitTest, so (like native) this
      -- pierces Mist -- only a move's PRIMARY stat-lowering effect
      -- checks Mist, not a secondary chance-effect.
      if ctx.target.substituteHP then return {} end
      if ctx.rng(0, 255) >= 85 then return {} end
      return changeModernStage(ctx.battle, ctx.target, "spd", -1, false)
    end,
  })
  mod.content.moves:patch("PSYCHIC_M", { effect = "GMAX_PSYCHIC_SPD_EFFECT" })

  ------------------------------------------------------------------
  -- Modern stage-based crit: stage 0 = 1/24, 1 = 1/8, 2 = 1/2, 3+ =
  -- always -- Gen 6+ rates, not Gen 1's speed-based roll. Flat 1.5x
  -- multiplier on hit (not Gen 1's x2), and crit does NOT double level
  -- (another Gen-1-only quirk dropped here).
  ------------------------------------------------------------------
  local CRIT_STAGE_DENOM = { [0] = 24, [1] = 8, [2] = 2, [3] = 1 }

  local function modernCritStage(ctx)
    local stage = 0
    if ctx.move.highCrit then stage = stage + 1 end
    if ctx.user.focusEnergy then stage = stage + 2 end
    for _, fn in pairs(critStageModifiers) do
      stage = stage + (fn(ctx) or 0)
    end
    if stage < 0 then stage = 0 end
    if stage > 3 then stage = 3 end
    return stage
  end

  local function modernCritRoll(ctx)
    local denom = CRIT_STAGE_DENOM[modernCritStage(ctx)]
    return ctx.rng(1, denom) == 1
  end

  ------------------------------------------------------------------
  -- The formula itself. ctx is exactly what BattleState:computeDamage
  -- builds for the battle.damage hook: { battle, ruleset, user, target,
  -- move, opts, rng }. Returns (damage, {crit=, typeMult=x10}) --
  -- Damage.compute's exact return shape, since callers (EffectRegistry's
  -- damaging-move path) expect it verbatim.
  ------------------------------------------------------------------
  local function computeModernDamage(ctx)
    local user, target, move, opts, rng = ctx.user, ctx.target, ctx.move, ctx.opts or {}, ctx.rng

    -- MoveCategory.of returns capitalized "Physical"/"Special"/"Status" --
    -- deliberately NOT the lowercase move.category some data carries
    -- (Damage.lua's own internal categoryOf compares lowercase; these are
    -- two different casing conventions coexisting in this codebase
    -- depending on data origin, so always go through MoveCategory.of).
    local category = MoveCategory.of(move) or "Physical"
    if (move.power or 0) == 0 or category == "Status" then
      return 0, { crit = false, typeMult = 10 }
    end

    -- Idempotent -- only fills fields that are missing, safe every call.
    -- Guarantees curStats.spa/spd exist (curStats IS mon.stats by
    -- reference, confirmed from makeBattler).
    ModernStats.ensure(user.def, user.mon)
    ModernStats.ensure(target.def, target.mon)

    local crit = opts.forceCrit
    if crit == nil then
      if Runtime.wantsHook("battle.crit") then
        crit = Runtime.call("battle.crit", function(c) return modernCritRoll(c) end,
          { battle = ctx.battle, user = user, move = move, rng = rng })
      else
        crit = modernCritRoll({ user = user, move = move, rng = rng })
      end
    end

    local special = category == "Special"
    local atkStat = special and "spa" or "attack"
    local defStat = special and "spd" or "defense"

    local atk, dfn
    if crit and ctx.ruleset and ctx.ruleset.critIgnoresStages then
      atk = user.curStats[atkStat]
      dfn = target.curStats[defStat]
    else
      atk = Stats.applyStage(user.curStats[atkStat],
                             user.stages and user.stages[stageKeyFor(atkStat)] or 0)
      dfn = Stats.applyStage(target.curStats[defStat],
                             target.stages and target.stages[stageKeyFor(defStat)] or 0)
      local atkBoost = badgeBoost(user, atkStat)
      if atkBoost then
        atk = math.floor(atk * (atkBoost.num or 9) / (atkBoost.den or 8))
      end
      local defBoost = badgeBoost(target, defStat)
      if defBoost then
        dfn = math.floor(dfn * (defBoost.num or 9) / (defBoost.den or 8))
      end
      -- Burn's statPenalty.stat is always "attack" (Status.lua), so this
      -- naturally never touches Special -- no extra casing needed.
      local record = statusRecord(user)
      local penalty = record and record.statPenalty
      if penalty and penalty.stat == atkStat and not user.hazeStatReset then
        atk = math.max(1, math.floor(atk / penalty.div))
      end
      if not crit then
        local screens = opts.screens
        if screens == nil and not opts.typeless then screens = target end
        if screens then
          if special and screens.lightScreen then dfn = dfn * 2 end
          if not special and screens.reflect then dfn = dfn * 2 end
        end
      end
    end

    if opts.explode then
      dfn = math.max(1, math.floor(dfn / 2))
    end

    -- No Gen-1 byte-clamp quirk here (the atk>255/dfn>255 quarter-both
    -- rule is a Game Boy hardware artifact, not a modern-game rule), and
    -- crit no longer doubles level.
    local level = user.mon.level
    local d = math.floor(math.floor(2 * level / 5) + 2)
    d = math.floor(math.floor(d * move.power * atk / math.max(1, dfn)) / 50) + 2

    if crit then
      d = math.floor(d * 1.5)
    end

    -- Random factor applied BEFORE the modifier chain/type effectiveness
    -- (real Gen 6+ order), not after like Gen 1.
    if not opts.typeless then
      d = math.floor(d * (100 - rng(0, 15)) / 100)
    end

    local mult = 10
    if not opts.typeless then
      for _, entry in ipairs(damageModifiers) do
        local m = entry.fn({
          battle = ctx.battle, user = user, target = target, move = move,
          category = category, atkStat = atkStat, defStat = defStat, crit = crit,
        }) or 1.0
        if m ~= 1.0 then
          d = math.floor(d * m)
        end
      end

      mult = TypeChart.effectiveness(move.type, target.curTypes)
      if mult == 0 then
        return 0, { crit = false, typeMult = 0 }
      end
      for _, m in ipairs(TypeChart.rows(move.type, target.curTypes)) do
        d = math.floor(d * m / 10)
      end
    end

    -- No "rounds to 0 counts as a miss" Gen-1 quirk -- modern games
    -- always clamp to a minimum of 1.
    return math.max(1, d), { crit = crit, typeMult = mult }
  end

  ------------------------------------------------------------------
  -- Hook wiring
  ------------------------------------------------------------------
  mod.hooks:wrap("battle.damage", function(next, ctx)
    if mod.options:get("modern_combat_formulas") == "false" then
      return next(ctx)
    end
    local ok, dmg, info = pcall(computeModernDamage, ctx)
    if not ok then
      mod.log:warn("galar_gmax_dex: modern_combat: damage formula errored (%s); falling back to native",
        tostring(dmg))
      return next(ctx)
    end
    return dmg, info
  end, 0)

  mod.log:info("galar_gmax_dex: modern_combat loaded")
end
