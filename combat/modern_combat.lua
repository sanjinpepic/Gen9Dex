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
  local MoveCategory = mod.exports.MoveCategory
  local ModernStats = mod.exports.ModernStats
  local TypeChart = require("src.battle.TypeChart")
  local Stats = require("src.pokemon.Stats")
  local Status = require("src.battle.Status")
  local Damage = require("src.battle.Damage") -- BADGE_BOOSTS table only, reused as data
  local romText = require("src.core.RomText")
  local Strings = require("src.core.Strings")

  -- Gen 2 detection, needed early (the STAB modifier below already
  -- reads a generation-aware type list). Same pattern proven in
  -- gen2_modern_stats.lua: compare the live battle's metatable against
  -- the real Gen 2 Battle class.
  local gen2Ok, Gen2Battle = pcall(require, "src.battle.gen2.Battle")
  Gen2Battle = gen2Ok and Gen2Battle or nil
  local function isGen2Battle(battle)
    return Gen2Battle ~= nil and battle ~= nil and getmetatable(battle) == Gen2Battle
  end

  -- Gen 1's battler wrapper exposes curTypes (Transform/Conversion-
  -- aware); Gen 2's raw mon carries the same live-type list as .types
  -- (confirmed from Gen 2's own native STAB check, gen2/Damage.lua:
  -- 249-253, which reads attacker.types).
  local function curTypesOf(who, gen2)
    return (gen2 and who.types or who.curTypes) or {}
  end
  -- Exported for Phase 4 (combat/modern_weather.lua): Sand's chip-damage
  -- immunity check (Ground/Steel/Rock) needs the same Transform/
  -- Conversion-aware live type list this file already uses for STAB.
  mod.exports.curTypesOf = curTypesOf
  -- Exported for the same sibling: several weather touch-points (the
  -- Solar Beam charge-skip performMove wrap, the sand-chip end-of-turn
  -- hook, the Thunder/Blizzard battle.accuracy hook) run OUTSIDE the
  -- move_effects normalize() bridge, so they need this discriminator
  -- directly instead of re-deriving it.
  mod.exports.isGen2Battle = isGen2Battle

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
    for _, t in ipairs(curTypesOf(ctx.user, ctx.gen2)) do
      if t == ctx.move.type then return 1.5 end
    end
    return 1.0
  end)

  ------------------------------------------------------------------
  -- Phase 4: GalarGmaxDex-owned weather state. Gen 1 has no native
  -- weather concept at all -- field.weather is a declared-but-dead field
  -- (confirmed zero real consumers; BattleCheckpoint.lua:367 only
  -- persists whatever nil is already there). battle.weather/
  -- battle.weatherTurns are new fields, written directly onto the battle
  -- object itself, the same direct-field convention already used for
  -- per-battler state elsewhere in this engine (user.thrashTurns,
  -- user.protected) -- no side table needed, since the battle object's
  -- own lifetime already bounds it (unlike stageState above, which needs
  -- one because it's keyed off a table it doesn't own).
  --
  -- Gen 2 already has this SAME state, for real: self.weather/
  -- self.weatherTurns (gen2/Battle.lua:291-292; native RAINDANCE/
  -- SUNNYDAY/SANDSTORM handlers at :1896-1906 set them; tickWeather at
  -- :4275-4304 counts them down and, for sandstorm, applies end-of-turn
  -- chip). Reused directly here, not shadowed with a parallel field --
  -- setWeather below writes straight into those same two fields, using
  -- Gen 2's own lowercase value convention ("rain"/"sun"/"sandstorm"),
  -- so every OTHER native consumer already keyed off self.weather
  -- (Effects.weatherHealFraction, gen2/Ai.lua's sun check, the
  -- EFFECT_SOLARBEAM sun-skip at gen2/Battle.lua:1460) keeps working
  -- automatically. modern_weather.lua's own header explains why
  -- GalarGmaxDex's own override handlers have to be the ones calling
  -- this now instead of native's hardcoded EFFECT_RAIN_DANCE/EFFECT_
  -- SUNNY_DAY/EFFECT_SANDSTORM ones.
  --
  -- "snow" is a weather value Gen 2 never produces natively (no Hail/
  -- Snow move exists in its own Effects.WEATHER table) -- modern_
  -- weather.lua adds it as pure new DATA into Gen 2's own Effects.
  -- WEATHER_START_TEXT/TURN_TEXT/END_TEXT tables (not a new field), so
  -- tickWeather's own generic countdown/expiry logic -- keyed by
  -- self.weather's VALUE, not a fixed key list -- handles it correctly
  -- with no control-flow changes at all.
  ------------------------------------------------------------------
  local GEN2_WEATHER_VALUE = { RAIN = "rain", SUN = "sun", SAND = "sandstorm", SNOW = "snow" }
  local FROM_GEN2_WEATHER_VALUE = { rain = "RAIN", sun = "SUN", sandstorm = "SAND", snow = "SNOW" }

  -- Single cross-engine reader: "RAIN"|"SUN"|"SAND"|"SNOW"|nil, regardless
  -- of which engine's own field shape backs it. Every weather touch-point
  -- (the damage modifier below, the Ice-type Defense boost further down,
  -- modern_weather.lua's accuracy/charge/chip hooks) goes through this
  -- one function rather than reading battle.weather directly.
  local function currentWeather(battle, gen2)
    if not battle then return nil end
    if gen2 then
      return battle.weather and FROM_GEN2_WEATHER_VALUE[battle.weather] or nil
    end
    return battle.weather
  end
  mod.exports.currentWeather = currentWeather

  -- 5 turns: real Showdown's default weather duration (no weather-rock/
  -- ability extension modeled), and exactly Gen 2's own native
  -- Effects.WEATHER_TURNS -- both engines agree already.
  local WEATHER_TURNS = 5
  mod.exports.WEATHER_TURNS = WEATHER_TURNS

  -- key is "RAIN"|"SUN"|"SAND"|"SNOW"|nil (nil clears the weather).
  local function setWeather(battle, gen2, key)
    if gen2 then
      battle.weather = key and GEN2_WEATHER_VALUE[key] or nil
      battle.weatherTurns = key and WEATHER_TURNS or 0
      return
    end
    battle.weather = key
    battle.weatherTurns = key and WEATHER_TURNS or 0
  end
  mod.exports.setWeather = setWeather

  -- Sun/Rain's Fire/Water damage multiplier. Priority 110, ABOVE stab's
  -- 100 -- real Gen 6+ Showdown applies the weather modifier before STAB
  -- in the damage-stage order (Bulbapedia's damage formula: ...weather,
  -- glaive rush, critical, random, STAB, type...), so this has to run
  -- first through the descending-priority chain for the per-stage floor
  -- rounding to land in the right place. Sand/Snow have no flat damage
  -- multiplier in real Showdown (Sand's old Rock SpDef boost and Snow's
  -- real Ice Defense boost are BOTH stat-input effects, not whole-damage
  -- multipliers -- Snow's is wired directly into this function's own
  -- defense-stat resolution below instead; Sand's is out of scope per
  -- the plan). Registered here, not in modern_weather.lua, purely so it
  -- sits next to currentWeather() -- the actual call site (registerDamage
  -- Modifier is already a public export) doesn't care which file calls it.
  registerDamageModifier("weather", 110, function(ctx)
    local weather = currentWeather(ctx.battle, ctx.gen2)
    if weather == "SUN" then
      if ctx.move.type == "FIRE" then return 1.5 end
      if ctx.move.type == "WATER" then return 0.5 end
    elseif weather == "RAIN" then
      if ctx.move.type == "WATER" then return 1.5 end
      if ctx.move.type == "FIRE" then return 0.5 end
    end
    return 1.0
  end)

  ------------------------------------------------------------------
  -- GalarGmaxDex-owned stat-stage store (atk/def/spa/spd only -- speed/
  -- accuracy/evasion stay 100% native for both generations, out of
  -- scope this phase). Both native engines already track stages
  -- correctly, but in two incompatible shapes (Gen 1: per-battler-
  -- wrapper mon.stages, combined "special"; Gen 2: per-side on the
  -- Battle object, split specialAttack/specialDefense) -- and, more to
  -- the point, Gen 2's native dispatch never actually reaches most
  -- stock stat-changing moves at all today: data.moves is Gen-1-ROM-
  -- sourced, Gen 2's own dispatcher looks up a different id convention
  -- (confirmed: gen2/Battle.lua's Battle.moveEffectRecordFor checks
  -- data.gen2MoveEffects/Battle.MOVE_EFFECT_RECORDS, both keyed
  -- "EFFECT_*", against data.moves[x].effect strings that are still
  -- Gen 1's "*_EFFECT" convention) -- Growl, Swords Dance etc. are
  -- non-functional on Gen 2 right now, mod or no mod. So this owns
  -- stage storage AND re-registers every atk/def/spa/spd move effect
  -- through one shared handler, rather than reading/writing whichever
  -- native storage happens to exist per generation.
  --
  -- Storage: stageState[battle] = { player = {attack=,defense=,spa=,
  -- spd=}, enemy = {...} }, the same battle-keyed-table shape already
  -- proven by gimmick_dynamax.lua's gState. A missing entry means
  -- "unmodified" (stage 0), same convention native tables already use.
  -- (Gen 2 detection/isGen2Battle already defined above, next to
  -- curTypesOf -- reused here, not redefined.)
  ------------------------------------------------------------------
  local stageState = {}
  local function ensureStageState(battle)
    local s = stageState[battle]
    if not s then
      s = { player = {}, enemy = {} }
      stageState[battle] = s
    end
    return s
  end
  local function stagesFor(battle, side)
    return ensureStageState(battle)[side]
  end

  -- "player"/"enemy", uniformly, regardless of generation. Gen 1's own
  -- BattleState:sideOf returns a side-record object (not a string,
  -- confirmed BattleState.lua:1487), so this doesn't reuse it --
  -- who.isPlayer is the reliable Gen 1 signal (set at makeBattler
  -- construction). Gen 2's Battle:sideOf already returns "player"/
  -- "enemy" directly (confirmed gen2/Battle.lua:411-413), reused as-is.
  local function sideOfWho(battle, who, gen2)
    if gen2 then return battle:sideOf(who) end
    return who.isPlayer and "player" or "enemy"
  end

  local function displayNameFor(battle, who, gen2)
    if gen2 then
      local nm = battle:monName(who)
      return sideOfWho(battle, who, true) == "player" and nm or Strings("Enemy %s", nm)
    end
    return (who.isPlayer and who.name) or Strings("Enemy %s", who.name)
  end

  -- Mist/Substitute gate -- same rule both generations share (a status
  -- move can't lower a Substitute'd/Mist'd target's stat from the
  -- outside), different field shapes per engine's own volatile-state
  -- convention: Gen 1 keeps the flags directly on the battler wrapper;
  -- Gen 2 keeps them in Battle:volatile(mon) (confirmed
  -- gen2/Battle.lua:968 construction, :2010 mist read, substitute is a
  -- remaining-HP number rather than a boolean).
  local function isProtectedFrom(battle, who, gen2)
    if gen2 then
      local vol = battle:volatile(who)
      return (vol.substitute or 0) > 0, vol.mist
    end
    return who.substituteHP, who.mist
  end

  local function rawStat(who, key, gen2)
    return gen2 and who.stats[key] or who.curStats[key]
  end

  local function badgeStatNameFor(statKey)
    if statKey == "spa" or statKey == "spd" then return "special" end
    return statKey
  end

  -- Kanto badge boosts. Gen 1 battler-wrapper-only (battler.badges) --
  -- silently a no-op for Gen 2 (raw mon has no .badges field), which is
  -- correct: Johto badge boosts are a separate native Gen 2 mechanic
  -- this file doesn't touch either way.
  local function badgeBoost(battler, statKey)
    local badges = battler.badges
    if not badges then return nil end
    local badgeStat = badgeStatNameFor(statKey)
    for _, row in ipairs(battler.badgeBoosts or Damage.BADGE_BOOSTS) do
      if row.stat == badgeStat and badges[row.badge] then return row end
    end
    return nil
  end

  -- Burn's attack-halving penalty: Gen 1 battler-wrapper shape only for
  -- now (battler.statuses/battler.mon.status is that wrapper's own
  -- convention) -- Gen 2's status-penalty equivalent is a separate,
  -- not-yet-scoped piece of work, flagged here rather than guessed at.
  local function statusRecord(battler, gen2)
    if gen2 then return nil end
    return Status.recordFor(battler.statuses, battler.mon.status)
  end

  ------------------------------------------------------------------
  -- Canonical stage-change: attack/defense/spa/spd, both generations,
  -- one code path -- replaces the old changeModernStage (which only
  -- ever owned spa/spd, Gen 1 only, deferring attack/defense to native
  -- MoveEffects.changeStage). Same contract/messages/clamp native
  -- always had (Mist/Substitute protection, the -6..+6 clamp, "nothing
  -- happened", the rise/greatly-rose message tiers), just backed by our
  -- own store instead of whichever native table happens to exist per
  -- generation. Exported so future ability/item work can reuse it.
  ------------------------------------------------------------------
  local STAT_LABEL = { attack = "Attack", defense = "Defense", spa = "Sp. Atk", spd = "Sp. Def" }

  -- Turns either engine's move-effect run() call into one shape:
  -- {battle=, user=, target=, gen2=}. Gen 1's run(ctx) already hands us
  -- a ctx facade (EffectRegistry.makeCtx, ctx.battle always present);
  -- Gen 2's run(battle, attacker, defender, def, moveId, sureHit) is
  -- six positional args (confirmed gen2/Battle.lua:1529, documented at
  -- :2645-2648) -- a is the raw Battle instance there, which has no
  -- .battle field of its own, so the discriminator is safe.
  local function normalize(a, b, c)
    if type(a) == "table" and a.battle ~= nil then
      return { battle = a.battle, user = a.user, target = a.target, gen2 = false }
    end
    return { battle = a, user = b, target = c, gen2 = true }
  end

  local function changeStage(battle, who, stat, delta, fromEnemy, gen2)
    local protectedBySub, mist = isProtectedFrom(battle, who, gen2)
    if fromEnemy and (protectedBySub or mist) then
      if mist then
        return { Strings("%s is\nprotected by MIST!", displayNameFor(battle, who, gen2)) }
      end
      return { romText(battle.data, "_ButItFailedText", "But, it failed!") }
    end
    local stages = stagesFor(battle, sideOfWho(battle, who, gen2))
    local cur = stages[stat] or 0
    local new = math.max(-6, math.min(6, cur + delta))
    if new == cur then
      return { romText(battle.data, "_NothingHappenedText", "Nothing happened!") }
    end
    stages[stat] = new
    who.hazeStatReset = nil
    local label = STAT_LABEL[stat]
    local name = displayNameFor(battle, who, gen2)
    if delta >= 2 then
      return { Strings("%s's\n%s\ngreatly rose!", name, label) }
    elseif delta == 1 then
      return { Strings("%s's\n%s rose!", name, label) }
    elseif delta == -1 then
      return { Strings("%s's\n%s fell!", name, label) }
    end
    return { Strings("%s's\n%s\ngreatly fell!", name, label) }
  end
  mod.exports.changeStage = changeStage
  -- Exported so sibling files (modern_movepool_stages.lua) can bridge
  -- Gen1/Gen2 move_effects run() calls the same way this file's own
  -- GMAX_* handlers do, instead of re-deriving the discriminator.
  mod.exports.normalize = normalize
  -- Exported for Phase 2 siblings (modern_movepool_status.lua) that need
  -- a battler's display name on BOTH generations -- EffectRegistry's own
  -- displayName (src/battle/EffectRegistry.lua) is Gen 1-only (reads
  -- who.name directly, which doesn't exist on a Gen 2 mon), so a
  -- primary() handler meant to run on both engines needs this version
  -- instead, same as changeStage/normalize above.
  mod.exports.displayNameFor = displayNameFor

  -- Resets a battler's OWN atk/def/spa/spd store to 0 (Clear Smog-style
  -- "wipe every stat stage" moves -- Haze-likes, if this mod ever needs
  -- one, reuse this too). Speed/accuracy/evasion are NOT this store's
  -- business (see the store's own header above) -- a caller resetting
  -- those goes straight to native storage instead, same as any other
  -- speed/accuracy/evasion change (modern_movepool_stages.lua's
  -- changeNativeStage). Returns whether anything was actually 0'd, for a
  -- caller that wants to print "Nothing happened!" on a no-op.
  local function resetStages(battle, who, gen2)
    local stages = stagesFor(battle, sideOfWho(battle, who, gen2))
    local changed = false
    for _, stat in ipairs({ "attack", "defense", "spa", "spd" }) do
      if (stages[stat] or 0) ~= 0 then
        stages[stat] = nil
        changed = true
      end
    end
    return changed
  end
  mod.exports.resetStages = resetStages

  -- One registration per native atk/def stat-effect id (statUp/
  -- statDown's exact real ids, MoveEffects.lua:166-178), both
  -- generations, one shared handler. targetsSelf=true mirrors native
  -- statUp (raises the move's own user, fromEnemy=false); false
  -- mirrors native statDown (lowers the target, fromEnemy=true so
  -- Mist/Substitute gate it). Speed/accuracy/evasion ids
  -- (SPEED_UP2_EFFECT, SPEED_DOWN1_EFFECT, EVASION_UP1_EFFECT,
  -- ACCURACY_DOWN1_EFFECT) are deliberately NOT registered here -- out
  -- of scope this phase, left exactly as native already handles them.
  -- override, not register: these 7 ids are native Gen 1 ids the base
  -- game already registers (unlike the GMAX_*-prefixed custom ids below,
  -- which are new) -- :register throws "already registered" against an
  -- existing record-semantics entry, :override replaces it outright
  -- (confirmed src/mods/Registry.lua:90-104).
  local function registerStatEffect(id, stat, delta, targetsSelf)
    mod.content.move_effects:override(id, {
      kind = "primary",
      run = function(a, b, c)
        local n = normalize(a, b, c)
        local who = targetsSelf and n.user or n.target
        return changeStage(n.battle, who, stat, delta, not targetsSelf, n.gen2)
      end,
    })
  end

  registerStatEffect("ATTACK_UP1_EFFECT", "attack", 1, true)
  registerStatEffect("ATTACK_UP2_EFFECT", "attack", 2, true)
  registerStatEffect("DEFENSE_UP1_EFFECT", "defense", 1, true)
  registerStatEffect("DEFENSE_UP2_EFFECT", "defense", 2, true)
  registerStatEffect("ATTACK_DOWN1_EFFECT", "attack", -1, false)
  registerStatEffect("DEFENSE_DOWN1_EFFECT", "defense", -1, false)
  registerStatEffect("DEFENSE_DOWN2_EFFECT", "defense", -2, false)

  -- The only three native Gen-1 moves that touched the old shared
  -- "special" stage (confirmed by grepping data/generated/moves.lua for
  -- every SPECIAL_UP1_EFFECT/SPECIAL_UP2_EFFECT/SPECIAL_DOWN_SIDE_EFFECT
  -- reference -- exactly AMNESIA, GROWTH, PSYCHIC_M, nothing else).
  -- Re-pointed at real Gen 2+ targeting instead of Gen 1's combined
  -- Special stat. None of GalarGmaxDex's own 174 new moves reference any
  -- stat-stage effect yet (grepped: zero matches) -- those are a
  -- separate, pre-existing "NO_ADDITIONAL_EFFECT placeholder" gap this
  -- pass does not attempt to close.
  mod.content.move_effects:register("GMAX_AMNESIA_EFFECT", {
    kind = "primary",
    run = function(a, b, c)
      local n = normalize(a, b, c)
      -- Amnesia: Sp. Def +2 only (Gen 2+), not the combined Special +2
      -- Gen 1 originally had.
      return changeStage(n.battle, n.user, "spd", 2, false, n.gen2)
    end,
  })
  mod.content.moves:patch("AMNESIA", { effect = "GMAX_AMNESIA_EFFECT" })

  mod.content.move_effects:register("GMAX_GROWTH_EFFECT", {
    kind = "primary",
    run = function(a, b, c)
      local n = normalize(a, b, c)
      -- Growth: Attack +1 AND Sp. Atk +1 (Gen 5+ behavior; Gen 2-4 only
      -- raised Special/Sp.Atk -- Gen 5+ is the more modern, current rule
      -- and matches this ruleset's overall Gen 9-oriented direction).
      local atkMsg = changeStage(n.battle, n.user, "attack", 1, false, n.gen2)
      local spaMsg = changeStage(n.battle, n.user, "spa", 1, false, n.gen2)
      local out = {}
      for _, m in ipairs(atkMsg) do out[#out + 1] = m end
      for _, m in ipairs(spaMsg) do out[#out + 1] = m end
      return out
    end,
  })
  mod.content.moves:patch("GROWTH", { effect = "GMAX_GROWTH_EFFECT" })

  -- Psychic's secondary Sp.Def-drop chance. Still kind="secondary",
  -- deliberately NOT redesigned this phase: confirmed broken on Gen 2
  -- today independent of this change (Gen 2's dispatch runs ANY
  -- move_effects record with a .run field and returns immediately,
  -- before the damage path, so a secondary-kind record currently
  -- pre-empts the whole move instead of following it --
  -- gen2/Battle.lua:1526-1531). Explicit decision: once combat is fully
  -- owned, secondary/chance-based effects get applied by the mod's own
  -- turn processing after damage lands but before the turn ends, not
  -- through this registry at all -- see the combat-ownership notes.
  -- For now this just avoids crashing on Gen 2 (n.gen2 short-circuits
  -- to a clean no-op) rather than attempting a real fix here.
  mod.content.move_effects:register("GMAX_PSYCHIC_SPD_EFFECT", {
    kind = "secondary",
    run = function(a, b, c)
      local n = normalize(a, b, c)
      if n.gen2 then return {} end
      if n.target.substituteHP then return {} end
      if n.battle.rng(0, 255) >= 85 then return {} end
      return changeStage(n.battle, n.target, "spd", -1, false, n.gen2)
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

    local gen2 = isGen2Battle(ctx.battle)

    -- Idempotent -- only fills fields that are missing, safe every call.
    -- Gen 1 only: user.def/user.mon are battler-wrapper fields that
    -- don't exist on Gen 2's raw mon objects -- gen2_modern_stats.lua
    -- already guarantees modern stats are present by battle.started
    -- time for every Gen 2 wild/trainer mon.
    if not gen2 then
      ModernStats.ensure(user.def, user.mon)
      ModernStats.ensure(target.def, target.mon)
    end

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
      atk = rawStat(user, atkStat, gen2)
      dfn = rawStat(target, defStat, gen2)
    else
      local userStages = stagesFor(ctx.battle, sideOfWho(ctx.battle, user, gen2))
      local targetStages = stagesFor(ctx.battle, sideOfWho(ctx.battle, target, gen2))
      atk = Stats.applyStage(rawStat(user, atkStat, gen2), userStages[atkStat] or 0)
      dfn = Stats.applyStage(rawStat(target, defStat, gen2), targetStages[defStat] or 0)
      local atkBoost = badgeBoost(user, atkStat)
      if atkBoost then
        atk = math.floor(atk * (atkBoost.num or 9) / (atkBoost.den or 8))
      end
      local defBoost = badgeBoost(target, defStat)
      if defBoost then
        dfn = math.floor(dfn * (defBoost.num or 9) / (defBoost.den or 8))
      end
      -- Burn's statPenalty.stat is always "attack" (Status.lua), so this
      -- naturally never touches Special -- no extra casing needed. Gen 1
      -- only for now -- see statusRecord.
      local record = statusRecord(user, gen2)
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

    -- Snow: Ice-type Defense +50% -- Gen 9's real replacement mechanic
    -- for old Hail (this project explicitly doesn't build Hail; see
    -- modern_weather.lua's header). A genuine STAT-INPUT multiplier, not
    -- a whole-damage multiplier like Sun/Rain's Fire/Water bonus above
    -- (registerDamageModifier's chain only ever scales the final `d`,
    -- confirmed by that chain's own call site further down -- it never
    -- touches atk/dfn), so it has to land here, on dfn itself, before
    -- it's used in the formula. Applies to the DEFENDER only, and only
    -- for a physical hit (defStat=="defense") -- Snow's real boost is to
    -- Defense specifically, not Sp. Def. Runs regardless of crit: a
    -- crit ignores stat STAGE changes (critIgnoresStages above), not a
    -- flat weather/ability-shaped multiplier, so this sits after both
    -- branches rather than inside either one.
    if defStat == "defense" and currentWeather(ctx.battle, gen2) == "SNOW" then
      for _, t in ipairs(curTypesOf(target, gen2)) do
        if t == "ICE" then
          dfn = math.floor(dfn * 1.5);
          break
        end
      end
    end

    if opts.explode then
      dfn = math.max(1, math.floor(dfn / 2))
    end

    -- No Gen-1 byte-clamp quirk here (the atk>255/dfn>255 quarter-both
    -- rule is a Game Boy hardware artifact, not a modern-game rule), and
    -- crit no longer doubles level. user.mon is the Gen 1 battler-
    -- wrapper's real-mon field; Gen 2's user IS the real mon already.
    local level = gen2 and user.level or user.mon.level
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
          gen2 = gen2,
        }) or 1.0
        if m ~= 1.0 then
          d = math.floor(d * m)
        end
      end

      local targetTypes = curTypesOf(target, gen2)
      mult = TypeChart.effectiveness(move.type, targetTypes)
      if mult == 0 then
        return 0, { crit = false, typeMult = 0 }
      end
      for _, m in ipairs(TypeChart.rows(move.type, targetTypes)) do
        d = math.floor(d * m / 10)
      end
    end

    -- No "rounds to 0 counts as a miss" Gen-1 quirk -- modern games
    -- always clamp to a minimum of 1.
    return math.max(1, d), { crit = crit, typeMult = mult }
  end

  ------------------------------------------------------------------
  -- Stage-store lifecycle: reset when a new mon becomes active (covers
  -- every voluntary/forced switch and faint-replacement via
  -- battle.battler_switched -- confirmed fired for all of those, both
  -- generations, same event/payload shape), and free the whole table
  -- when the battle ends. The very first send-out at battle start does
  -- NOT emit battle.battler_switched (confirmed: only makeBattler runs
  -- there on Gen 1, no matching emit site) -- harmless, since a brand
  -- new `battle` object is never a stale key to begin with; the
  -- battle.started reset below is just cheap defensive symmetry with
  -- gimmick_dynamax.lua's own battle.started reset, not load-bearing.
  ------------------------------------------------------------------
  mod.events:on("battle.started", function(ev)
    if ev and ev.battle then stageState[ev.battle] = nil end
  end)
  mod.events:on("battle.battler_switched", function(ev)
    local battle = ev and ev.battle
    if not battle or not ev.battler then return end
    local side = sideOfWho(battle, ev.battler, isGen2Battle(battle))
    ensureStageState(battle)[side] = {}
  end)
  mod.events:on("battle.ended", function(ev)
    if ev and ev.battle then stageState[ev.battle] = nil end
  end)

  ------------------------------------------------------------------
  -- Hook wiring. Explicit user decision: this formula is the only
  -- damage path, unconditionally, for every battle regardless of
  -- generation -- no options toggle, no silent pcall-to-vanilla
  -- fallback on error (removed; formerly `modern_combat_formulas`).
  -- `next` is still accepted (the battle.damage hook contract requires
  -- it) but is never called.
  ------------------------------------------------------------------
  mod.hooks:wrap("battle.damage", function(next, ctx)
    return computeModernDamage(ctx)
  end, 0)

  mod.log:info("galar_gmax_dex: modern_combat loaded")
end
