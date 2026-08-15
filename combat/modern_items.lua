-- Part B Phase 5, second batch: item-interaction moves -- Fling, Knock
-- Off, Covet, Incinerate, Bug Bite, Pluck, Recycle, Belch.
--
-- Primitives confirmed by direct source read before writing anything
-- (background research this session, then several follow-up checks):
--   Held item field: Gen 2 mons carry a real string item id directly on
--   the raw mon (`mon.item`, src/battle/gen2/Mon.lua:296). Gen 1 has NO
--   item concept anywhere in the engine at all (zero references to a
--   mon-level `item` field in the whole src/pokemon/ tree) -- this is
--   already this mod's own established idiom (modern_combat.lua's own
--   itemOf(who, gen2), redefined locally below since it isn't exported).
--   So every move in this file is structurally a no-op FAIL on Gen 1,
--   which is mechanically correct: none of these eight moves existed on
--   the Gen 1 cart, and Gen 1 battle has no items to interact with.
--   Item removal: no dedicated function exists anywhere in the engine --
--   the only real precedent (Berserk Gene, gen2/Battle.lua:3434-3435) is
--   a plain `mon.item = nil` assignment. Same primitive used here.
--   battle.damage_dealt: confirmed identical shape to modern_hazards.lua's
--   own use (battle, user, target, move/moveId, damage) -- fires only
--   AFTER a landed, non-immune hit, the correct point for "on-hit" item
--   side effects (Knock Off/Covet/Bug Bite/Pluck/Fling's own consumption).
--   battle.damage (mod.hooks:wrap, NOT mod.events:on): a genuine cross-gen
--   wrap-hook, confirmed via Runtime.call("battle.damage", ...) present
--   on BOTH BattleState.lua:2335 (Gen 1) and gen2/Battle.lua:1119 (Gen 2)
--   with matching (dmg, info) return shape. modern_combat_protect.lua's
--   own Part B already establishes the pattern this file reuses for a
--   genuine pre-damage FAIL (Fling/Incinerate/Belch's conditions): wrap
--   at a priority above modern_combat.lua's own formula hook (0) and
--   short-circuit to `0, {crit=false, typeMult=0}` without calling
--   next() -- reusing EffectRegistry.lua's/gen2 Battle.lua's own already-
--   correct zero-damage handling ("It doesn't affect %s!") rather than
--   building new fail-message plumbing. Real Fling/Incinerate/Belch show
--   "But it failed!" specifically, not that text -- a known, minor,
--   deliberate reuse of the existing generic path rather than new
--   infrastructure, same tradeoff Protect's own file already made.
--   registerPowerOverride / registerDamageModifier (both modern_combat.lua
--   exports): the real per-move variable-power and final-multiplier
--   chains (Flail/Power Trip/Heat Crash precedent for the former, STAB/
--   weather precedent for the latter) -- Fling's item-dependent power and
--   Knock Off's 1.5x-if-item-present boost use these, not a move_effects
--   .run (which would hit Gen 2's "any .run field preempts damage"
--   gotcha modern_hazards.lua's own header already documents).
--   held_item.trigger (Battle:heldEffect, gen2/Battle.lua:815-826): the
--   real, mod-hookable chokepoint every native held-item effect goes
--   through, including the end-of-turn HELD_BERRY auto-heal. Used here
--   (read-only, always passes its own effect/parameter through unchanged)
--   purely to learn WHEN the native residual tick is about to actually
--   consume a berry, so Recycle/Belch have real state to work from.
return function(mod)
  local Strings = require("src.core.Strings")
  local romText = require("src.core.RomText")
  local Battle2 = require("src.battle.gen2.Battle")

  local normalize = mod.exports.normalize
  local displayNameFor = mod.exports.displayNameFor
  local isGen2Battle = mod.exports.isGen2Battle
  local registerDamageModifier = mod.exports.registerDamageModifier
  local registerPowerOverride = mod.exports.registerPowerOverride
  assert(normalize and displayNameFor and isGen2Battle and registerDamageModifier
    and registerPowerOverride, "modern_items: combat/modern_combat.lua must load first")

  -- Same one-liner modern_combat.lua's own ACROBATICS handler uses
  -- (not exported from there, so redefined here rather than reached into).
  local function itemOf(who, gen2)
    return gen2 and who.item or nil
  end

  ------------------------------------------------------------------
  -- Item classification. All ids below are real, ROM-extracted Gen 2
  -- Gold/Silver constant names (tools/rom_manifest_gold.json's own
  -- itemOrder, not invented) -- this project owns the CLASSIFICATION
  -- (which of these ids count as a berry / can't be Flung or stolen),
  -- since no such flag exists anywhere in the item schema (R.items has
  -- no isBerry/flingPower/category field at all, confirmed this session),
  -- the same "own it outright, don't touch native data" pattern
  -- modern_hazards.lua's own per-side hazard state already established.
  ------------------------------------------------------------------
  local KNOWN_BERRIES = {
    BERRY = true, GOLD_BERRY = true, MYSTERYBERRY = true,
    PSNCUREBERRY = true, PRZCUREBERRY = true, BURNT_BERRY = true,
    ICE_BERRY = true, BITTER_BERRY = true, MINT_BERRY = true,
    MIRACLEBERRY = true,
  }
  local BALL_ITEMS = {
    MASTER_BALL = true, ULTRA_BALL = true, GREAT_BALL = true, POKE_BALL = true,
    HEAVY_BALL = true, LEVEL_BALL = true, LURE_BALL = true, FAST_BALL = true,
    LIGHT_BALL = true, FRIEND_BALL = true, MOON_BALL = true, LOVE_BALL = true,
    PARK_BALL = true,
  }
  local MAIL_ITEMS = {
    FLOWER_MAIL = true, SURF_MAIL = true, LITEBLUEMAIL = true, PORTRAITMAIL = true,
    LOVELY_MAIL = true, EON_MAIL = true, MORPH_MAIL = true, BLUESKY_MAIL = true,
    MUSIC_MAIL = true, MIRAGE_MAIL = true,
  }
  local APRICORN_ITEMS = {
    RED_APRICORN = true, BLU_APRICORN = true, YLW_APRICORN = true,
    GRN_APRICORN = true, WHT_APRICORN = true, BLK_APRICORN = true,
    PNK_APRICORN = true,
  }
  local KEY_ITEMS_HELD_UNLIKELY = {
    TOWN_MAP = true, BICYCLE = true, CARD_KEY = true, BASEMENT_KEY = true,
    PASS = true, COIN_CASE = true, ITEMFINDER = true, S_S_TICKET = true,
  }

  local function isUnflingable(itemId)
    if BALL_ITEMS[itemId] or MAIL_ITEMS[itemId] or APRICORN_ITEMS[itemId]
        or KEY_ITEMS_HELD_UNLIKELY[itemId] then
      return true
    end
    return itemId:match("^TM_") ~= nil
  end

  -- Real games also exempt Mail from Knock Off/Thief/Covet removal --
  -- everything else in this dataset (stat items, berries, hold-battle
  -- items) is a normal removable/stealable item.
  local function isUnremovable(itemId)
    return MAIL_ITEMS[itemId] == true
  end

  -- Real per-item Fling power, per this project's standing source-of-
  -- truth rule (Pokemon Showdown Gen 9 is primary; other sources are
  -- enrichment only). An earlier draft of this file tried to get these
  -- numbers via WebFetch summaries of Bulbapedia and of Showdown's own
  -- data/items.ts, and the two attempts came back CONTRADICTORY (e.g.
  -- Oran Berry reported as both 10 and 80) -- not a source-priority
  -- problem, a reliability problem: a follow-up direct download of the
  -- real raw data/items.ts (curl, then Grep/Read on the actual file, no
  -- summarization step) showed the WebFetch summaries had silently
  -- fabricated entries for items that were flat NOT in the file's
  -- (correctly truncated) fetched window. Every number below was read
  -- directly off that raw file, not summarized -- e.g. `kingsrock: {
  -- fling: { basePower: 30 } }` at data/items.ts:3205-3209 in the
  -- smogon/pokemon-showdown master branch as of this session.
  --
  -- Berries are a genuine special case, confirmed the same way: no berry
  -- entry (oranberry, lumberry, cheriberry, ...) carries its own `fling`
  -- field at all -- Showdown applies a fixed 10 power to every
  -- `isBerry: true` item generically rather than listing it per-berry,
  -- which is exactly the one fact the very first (unreliable) research
  -- pass had also landed on, now confirmed rather than assumed.
  --
  -- INTERACTION TODO: this table only covers the items that actually
  -- exist in this mod's real Gen 2 item roster (tools/rom_manifest_gold
  -- .json's itemOrder) and that plausibly get held -- not Showdown's
  -- full item list (thousands of entries spanning items this ROM's data
  -- can never produce, like Mega Stones or Z-Crystals). Anything not
  -- listed here falls back to DEFAULT_FLING_POWER rather than a verified
  -- number; extend this table (same direct-read method: fetch/curl the
  -- real data/items.ts, Grep the exact key, never trust a WebFetch
  -- summary's numbers without spot-checking a few against the raw file)
  -- if a specific unlisted item turns out to matter.
  local ITEM_FLING_POWER = {
    BRIGHTPOWDER = 10, QUICK_CLAW = 80, KINGS_ROCK = 30, LUCKY_PUNCH = 40,
    FOCUS_BAND = 10, SILVERPOWDER = 10, SOFT_SAND = 10, SHARP_BEAK = 50,
    POISON_BARB = 70, MYSTIC_WATER = 30, TWISTEDSPOON = 30,
    BLACKGLASSES = 30, BLACKBELT_I = 30, STICK = 60, NEVERMELTICE = 30,
    MAGNET = 30, CHARCOAL = 30, MIRACLE_SEED = 30, HARD_STONE = 100,
    BERRY_JUICE = 30, SCOPE_LENS = 30, METAL_COAT = 30, DRAGON_FANG = 70,
    LEFTOVERS = 10, DRAGON_SCALE = 30, METAL_POWDER = 10,
  }
  local DEFAULT_FLING_POWER = 30

  local function flingPowerOf(itemId)
    if KNOWN_BERRIES[itemId] then return 10 end
    return ITEM_FLING_POWER[itemId] or DEFAULT_FLING_POWER
  end

  ------------------------------------------------------------------
  -- Shared consumed-item tracking (Recycle needs to know what a mon's
  -- own held item most recently was before it disappeared; Belch needs
  -- to know only THAT one was consumed at some point this battle).
  -- Deliberately keyed on the mon table itself, not battle.hazards-style
  -- per-side state -- Gen 2 mon tables are the persistent party members
  -- (same table across many battles), so these two fields are cleared
  -- explicitly on battle.started below rather than relying on a fresh
  -- table each battle.
  --
  -- Populated from ONE real, native consumption path: the end-of-turn
  -- HELD_BERRY auto-heal (Battle:tickHeldItem, gen2/Battle.lua:4498-
  -- 4505), observed here via the held_item.trigger hook (the same
  -- chokepoint that native tick itself goes through) rather than by
  -- polling. This hook only OBSERVES -- it always returns c.effect/
  -- c.parameter unchanged, so it can never alter engine behavior, only
  -- record it. The HP-threshold re-check below mirrors the native tick's
  -- own gate exactly (mon.hp*2 <= maxHp) so this only marks an item
  -- consumed when the native tick is actually about to consume it too,
  -- not merely eligible in principle.
  --
  -- INTERACTION TODO: this is the ONLY consumption path modeled. If a
  -- future move/mechanic adds another way for a mon to consume its own
  -- item (Stuff Cheeks, Natural Gift, a low-HP-triggered attack-boost
  -- berry) it will need its own ggdLastConsumedItem/ggdConsumedBerry
  -- ThisBattle write, following this same shape -- neither field updates
  -- itself automatically for a path that doesn't go through
  -- held_item.trigger's "residual" case.
  ------------------------------------------------------------------
  mod.hooks:wrap("held_item.trigger", function(next, c)
    if c.trigger == "residual" and c.effect == "HELD_BERRY" and c.mon then
      local maxHp = c.mon.maxHp or (c.mon.stats and c.mon.stats.hp) or 0
      if (c.mon.hp or 0) * 2 <= maxHp then
        c.mon.ggdLastConsumedItem = c.item
        c.mon.ggdConsumedBerryThisBattle = true
      end
    end
    return next(c)
  end, 0)

  mod.events:on("battle.started", function(ev)
    local battle = ev and ev.battle
    if not (battle and isGen2Battle(battle)) then return end
    for _, mon in ipairs(battle.party or {}) do
      mon.ggdLastConsumedItem = nil
      mon.ggdConsumedBerryThisBattle = nil
    end
    for _, mon in ipairs(battle.enemyParty or {}) do
      mon.ggdLastConsumedItem = nil
      mon.ggdConsumedBerryThisBattle = nil
    end
  end)

  ------------------------------------------------------------------
  -- Stub-audit markers: one empty kind="full" record per move (the
  -- established Blizzard/Rapid Spin precedent for "real damage, real
  -- effect lives in a side hook, not in .run"), patched onto each move
  -- purely so moves_new.lua's own effect field stops reading
  -- NO_ADDITIONAL_EFFECT -- that field is this project's own stub marker
  -- (Task #9's re-audit), and every move below is fully implemented even
  -- though none of the actual logic lives inside these records.
  ------------------------------------------------------------------
  for _, id in ipairs({
    "GALAR_FLING_EFFECT", "GALAR_KNOCKOFF_EFFECT", "GALAR_COVET_EFFECT",
    "GALAR_INCINERATE_EFFECT", "GALAR_BUGBITE_EFFECT", "GALAR_BELCH_EFFECT",
  }) do
    mod.content.move_effects:register(id, { kind = "full" })
  end
  mod.content.moves:patch("FLING", { effect = "GALAR_FLING_EFFECT" })
  mod.content.moves:patch("KNOCKOFF", { effect = "GALAR_KNOCKOFF_EFFECT" })
  mod.content.moves:patch("COVET", { effect = "GALAR_COVET_EFFECT" })
  mod.content.moves:patch("INCINERATE", { effect = "GALAR_INCINERATE_EFFECT" })
  mod.content.moves:patch("BUGBITE", { effect = "GALAR_BUGBITE_EFFECT" })
  mod.content.moves:patch("PLUCK", { effect = "GALAR_BUGBITE_EFFECT" })
  mod.content.moves:patch("BELCH", { effect = "GALAR_BELCH_EFFECT" })

  ------------------------------------------------------------------
  -- FLING: real per-item power via registerPowerOverride (Flail/Power
  -- Trip's own mechanism, not a move_effects .run -- see header). The
  -- fail case (no item, or an unflingable one) is a genuine pre-damage
  -- block via the battle.damage wrap below, same tier as Protect's own
  -- block (priority 40, deliberately just under Protect's 50 -- if a
  -- target is Protected AND Fling would otherwise fail, Protect's own
  -- hook runs first and its block message wins, which reads more
  -- sensibly than a "you have nothing to throw" message on a move that
  -- was going to be blocked anyway).
  ------------------------------------------------------------------
  registerPowerOverride("FLING", function(ctx)
    if not ctx.gen2 then return nil end
    local item = itemOf(ctx.user, true)
    if not item or isUnflingable(item) then return nil end
    return flingPowerOf(item)
  end)

  mod.hooks:wrap("battle.damage", function(next, ctx)
    local moveId = (ctx.move and ctx.move.id) or ctx.moveId
    if moveId == "FLING" then
      local gen2 = isGen2Battle(ctx.battle)
      local item = gen2 and itemOf(ctx.user, true) or nil
      if not gen2 or not item or isUnflingable(item) then
        return 0, { crit = false, typeMult = 0, effectiveness = 0 }
      end
    end
    return next(ctx)
  end, 40)

  mod.events:on("battle.damage_dealt", function(ev)
    local battle = ev and ev.battle
    local moveId = ev and ((ev.move and ev.move.id) or ev.moveId)
    if not (battle and moveId == "FLING" and ev.user and isGen2Battle(battle)) then return end
    local ok, err = pcall(function()
      local item = ev.user.item
      if not item then return end
      local def = battle:itemDef(item)
      ev.user.item = nil
      battle:emit({ kind = "message",
        text = displayNameFor(battle, ev.user, true) .. " threw its "
          .. (def and def.name or item) .. "!" })
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: modern_items: Fling item-clear failed: %s", tostring(err))
    end
  end)

  ------------------------------------------------------------------
  -- KNOCK OFF: 1.5x power when the target holds a removable item
  -- (real Gen 6+ rule, applies under the golden rule regardless of
  -- Gen 2's own native move list never having had this move), plus
  -- removing the item on a landed hit.
  ------------------------------------------------------------------
  registerDamageModifier("knockoff_item_present", 100, function(ctx)
    if ctx.move.id ~= "KNOCKOFF" or not ctx.gen2 then return 1.0 end
    local item = itemOf(ctx.target, true)
    return (item and not isUnremovable(item)) and 1.5 or 1.0
  end)

  mod.events:on("battle.damage_dealt", function(ev)
    local battle = ev and ev.battle
    local moveId = ev and ((ev.move and ev.move.id) or ev.moveId)
    if not (battle and moveId == "KNOCKOFF" and ev.target and isGen2Battle(battle)) then return end
    local ok, err = pcall(function()
      local item = ev.target.item
      if not item or isUnremovable(item) then return end
      local def = battle:itemDef(item)
      ev.target.item = nil
      battle:emit({ kind = "message",
        text = displayNameFor(battle, ev.user, true) .. " knocked off "
          .. displayNameFor(battle, ev.target, true) .. "'s "
          .. (def and def.name or item) .. "!" })
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: modern_items: Knock Off item-clear failed: %s", tostring(err))
    end
  end)

  ------------------------------------------------------------------
  -- COVET: steal the target's item if the user currently holds none.
  -- No existing steal-item precedent anywhere in the engine or mod
  -- (confirmed this session) -- built from the same mon.item = nil / =
  -- id assignment Knock Off/Fling/Berserk Gene all already use.
  ------------------------------------------------------------------
  mod.events:on("battle.damage_dealt", function(ev)
    local battle = ev and ev.battle
    local moveId = ev and ((ev.move and ev.move.id) or ev.moveId)
    if not (battle and moveId == "COVET" and ev.user and ev.target and isGen2Battle(battle)) then return end
    local ok, err = pcall(function()
      if ev.user.item then return end
      local item = ev.target.item
      if not item or isUnremovable(item) then return end
      local def = battle:itemDef(item)
      ev.target.item = nil
      ev.user.item = item
      battle:emit({ kind = "message",
        text = displayNameFor(battle, ev.user, true) .. " stole "
          .. displayNameFor(battle, ev.target, true) .. "'s "
          .. (def and def.name or item) .. "!" })
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: modern_items: Covet item-steal failed: %s", tostring(err))
    end
  end)

  ------------------------------------------------------------------
  -- INCINERATE: real rule is a genuine pre-damage FAIL (no damage at
  -- all, not just "no effect") when the target isn't holding a berry --
  -- same battle.damage wrap tier as Fling above. On a successful hit,
  -- the berry is destroyed outright (mon.item = nil), no effect applied
  -- to either side -- unlike Bug Bite/Pluck below, Incinerate does not
  -- eat it.
  ------------------------------------------------------------------
  mod.hooks:wrap("battle.damage", function(next, ctx)
    if ((ctx.move and ctx.move.id) or ctx.moveId) == "INCINERATE" then
      local gen2 = isGen2Battle(ctx.battle)
      local item = gen2 and itemOf(ctx.target, true) or nil
      if not gen2 or not item or not KNOWN_BERRIES[item] then
        return 0, { crit = false, typeMult = 0, effectiveness = 0 }
      end
    end
    return next(ctx)
  end, 40)

  mod.events:on("battle.damage_dealt", function(ev)
    local battle = ev and ev.battle
    local moveId = ev and ((ev.move and ev.move.id) or ev.moveId)
    if not (battle and moveId == "INCINERATE" and ev.target and isGen2Battle(battle)) then return end
    local ok, err = pcall(function()
      local item = ev.target.item
      if not item or not KNOWN_BERRIES[item] then return end
      local def = battle:itemDef(item)
      ev.target.item = nil
      battle:emit({ kind = "message",
        text = displayNameFor(battle, ev.target, true) .. "'s "
          .. (def and def.name or item) .. " was burned up!" })
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: modern_items: Incinerate berry-destroy failed: %s", tostring(err))
    end
  end)

  ------------------------------------------------------------------
  -- BUG BITE / PLUCK: eat the target's berry immediately on a landed
  -- hit -- the user gets the berry's own effect (mirroring the real
  -- native heldEffect taxonomy directly off Battle.HELD_STATUS_CURES,
  -- gen2/Battle.lua:4462-4468, applied to the EATER instead of the
  -- item's own holder, rather than re-deriving/guessing the mapping),
  -- and the target loses the item same as Knock Off. Real games don't
  -- pre-gate these on damage (no fail-if-no-berry rule like Incinerate
  -- has) -- an ordinary hit against a non-berry-holder just deals
  -- ordinary damage with no bonus effect, so no battle.damage wrap here.
  ------------------------------------------------------------------
  local function applyEatenBerryEffect(battle, eater, def, eaterName)
    local effect, parameter = def.heldEffect, def.heldParameter or 0
    if effect == "HELD_BERRY" then
      battle:heal(eater, parameter > 0 and parameter or 10, { anim = "RECOVER" })
      return true
    end
    local cure = Battle2.HELD_STATUS_CURES[effect]
    if effect == "HELD_HEAL_STATUS" then cure = eater.status end
    if cure and eater.status == cure then
      eater.status = nil
      eater.statusTurns = nil
      eater.toxicCounter = nil
      battle:emit({ kind = "status", side = battle:sideOf(eater), status = nil,
        text = eaterName .. "'s status was cured!" })
      return true
    end
    if (effect == "HELD_HEAL_CONFUSION" or effect == "HELD_HEAL_STATUS")
        and battle:volatile(eater).confuseCount then
      battle:volatile(eater).confuseCount = nil
      battle:emit({ kind = "message", text = eaterName .. "'s confusion was cured!" })
      return true
    end
    return false
  end

  mod.events:on("battle.damage_dealt", function(ev)
    local battle = ev and ev.battle
    local moveId = ev and ((ev.move and ev.move.id) or ev.moveId)
    if not (battle and (moveId == "BUGBITE" or moveId == "PLUCK")
        and ev.user and ev.target and isGen2Battle(battle)) then return end
    local ok, err = pcall(function()
      local item = ev.target.item
      if not item or not KNOWN_BERRIES[item] then return end
      local def = battle:itemDef(item)
      if not def then return end
      ev.target.item = nil
      local userName = displayNameFor(battle, ev.user, true)
      battle:emit({ kind = "message",
        text = userName .. " ate " .. displayNameFor(battle, ev.target, true)
          .. "'s " .. (def.name or item) .. "!" })
      applyEatenBerryEffect(battle, ev.user, def, userName)
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: modern_items: Bug Bite/Pluck berry-eat failed: %s", tostring(err))
    end
  end)

  ------------------------------------------------------------------
  -- RECYCLE: non-damaging status move -- safe to use kind="primary"+run
  -- the way modern_hazards.lua's own Stealth Rock/Toxic Spikes setters
  -- do (that Gen 2 .run-preempts-damage gotcha only matters for
  -- DAMAGING moves). Restores ggdLastConsumedItem if the user currently
  -- holds no item and has one tracked; fails otherwise (already holding
  -- an item, or nothing tracked yet -- both real fail conditions).
  ------------------------------------------------------------------
  mod.content.move_effects:register("GALAR_RECYCLE_EFFECT", {
    kind = "primary",
    run = function(a, b, c)
      local n = normalize(a, b, c)
      if not n.gen2 then
        return { romText(n.battle.data, "_ButItFailedText", "But, it failed!") }
      end
      local user = n.user
      local restored = user.ggdLastConsumedItem
      if user.item or not restored then
        return { romText(n.battle.data, "_ButItFailedText", "But, it failed!") }
      end
      user.item = restored
      user.ggdLastConsumedItem = nil
      local def = n.battle:itemDef(restored)
      return { Strings("%s found a\n%s!",
        displayNameFor(n.battle, user, true), def and def.name or restored) }
    end,
  })
  mod.content.moves:patch("RECYCLE", { effect = "GALAR_RECYCLE_EFFECT" })

  ------------------------------------------------------------------
  -- BELCH: real rule is a genuine pre-damage FAIL unless the user has
  -- consumed (not necessarily still missing) a berry at some point this
  -- battle -- same battle.damage wrap tier as Fling/Incinerate. Power is
  -- already fixed (120) in moves_new.lua, no override needed once the
  -- fail-gate passes.
  ------------------------------------------------------------------
  mod.hooks:wrap("battle.damage", function(next, ctx)
    if ((ctx.move and ctx.move.id) or ctx.moveId) == "BELCH" then
      local gen2 = isGen2Battle(ctx.battle)
      if not gen2 or not ctx.user.ggdConsumedBerryThisBattle then
        return 0, { crit = false, typeMult = 0, effectiveness = 0 }
      end
    end
    return next(ctx)
  end, 40)

  mod.log:info("galar_gmax_dex: modern_items loaded (Fling, Knock Off, Covet, "
    .. "Incinerate, Bug Bite, Pluck, Recycle, Belch)")
end
