-- g9-battle-engine-beta -- forked from g9-battle-engine (2026-08-20),
-- combat engine only: species/evolutions/typing, movepool, Gigantamax
-- moves/forms, and the full modern damage/status/weather/hazards/items
-- combat pipeline. Deliberately owns NONE of g9-battle-engine's asset
-- handling -- no battle sprites, no overworld sprites, no wild-spawn
-- engine, no follower engine, no party icons. Those stay g9-battle-
-- engine's job; this fork exists so combat-engine work never has to
-- touch (or wait on) any of that. If you're looking for that half, see
-- the sibling g9-battle-engine mod instead.
--
-- Phase 1 registers every species national_dex reports (the base-stat/
-- type/dex source of truth now -- explicit user decision), with
-- evolutions bound in from species_evolutions.lua (national_dex's own
-- evolutions field ships empty).
--
-- Phase 2 (wireMovepoolSubEffects/patchLearnsets below) replaces Phase 1's
-- placeholder { "TACKLE" } moveset with each species' real level-up
-- learnset. See wireMovepoolSubEffects's own header for how move
-- completeness is judged -- entirely off national_dex's own live data,
-- no static per-move triage file. Base move data itself is always
-- national_dex's alone, never registered by this mod.
-- combat/learnset_ownership.lua (national_dex's own unfiltered movesets)
-- is the real, current learnset source -- the old combat/learnsets_data
-- .lua self-authored table this comment used to point at has been
-- deleted, it had been dead/unreferenced for a while already.
--
-- Two evolution triggers this batch needs don't exist in the base engine
-- and are built here, scoped to just what this mod needs:
--   * HAPPINESS (Pichu->Pikachu, Munchlax->Snorlax): a minimal friendship
--     counter, mirroring kanto-ascendant's own FRIENDSHIP method
--     (johto.lua) but without a day/night split, since neither evolution
--     needs one. Approximated: gains happiness after any battle rather
--     than tracking the real games' precise per-action deltas, since this
--     engine exposes no such granularity to hook.
--   * A generic consumable-item evolution hook, generalizing Gorochu's
--     one-off Thunder Tear pattern (gorochu.lua's installItemEffect) to
--     any number of item/species pairs, for the 11 new items this batch
--     introduces (2 Apples, 2 Scrolls, 7 Sweets). Milcery's evolution is
--     PBS "HoldItem" (hold + level up); approximated here as consumable
--     use instead, since there is no held-item mechanic to check against.

-- Sibling-file loader: identical to kanto-ascendant's own main.lua
-- loadSibling helper. mod:read() goes through the loader filesystem (so
-- this works the same for an installed directory, a zip, or Modkit's
-- virtual validation FS). Plain require() only resolves the engine's own
-- src.* module tree, not a mod's own sibling files.
--
-- Previously had a debug.getinfo(1, "S").source + loadfile() fallback
-- for a plain filesystem entry point. Both debug and loadfile were
-- removed from the mod sandbox in gen1recomp's Aug 2026 mod-sandboxing
-- release ("grandmas kitchen") -- debug.getinfo alone threw
-- unconditionally at load time (attempt to index global 'debug', a nil
-- value), which is the fatal error this fix addresses. mod:read() was
-- always the primary path and is confirmed sufficient on its own per
-- this same comment's own claim above, so the fallback is dropped
-- rather than reworked -- there is no sandboxed replacement for
-- loadfile's own-arbitrary-path use, only for mod:read's own-folder one.
local function loadSibling(mod, filename)
  local body, readErr = mod:read(filename)
  assert(body, readErr)
  local chunk, err = loadstring(body, "@" .. mod.path .. "/" .. filename)
  assert(chunk, err)
  return chunk()
end

local TYPE_ID_TRANSLATION = {
  PSYCHIC = "PSYCHIC_TYPE",
}

local function engineTypeId(pbsType)
  return TYPE_ID_TRANSLATION[pbsType] or pbsType
end

-- [g9-battle-engine-beta] Party-menu icon art (TEMPLATE_FOR_TYPE,
-- SPECIAL_TEMPLATE, iconPath, installBigPartyIcons/Gen2) removed entirely
-- -- this fork owns combat only. See g9-battle-engine for icon/sprite art.

-- =============================================================================
-- Phase 2: movepool effects
-- =============================================================================
-- Flinch/confusion chance read LIVE off national_dex's own moveById
-- record on every landed hit (see installMovepoolEffects's own header) --
-- no per-chance move_effect registration of any kind anymore, just the
-- one unconditional GALAR_TRAP_EFFECT.
--
-- BUGFIX (this session, reported: "flinched pokemon can't act ever
-- again"): the original version of Flinch/Confuse registered
-- kind="secondary" with a single-argument `run = function(ctx)` -- no
-- normalize(a,b,c) bridge, the same gotcha modern_hazards.lua's own
-- header already documents for Rapid Spin: Gen 2's dispatch calls ANY
-- move_effects record with a `.run` field via `handler(self, attacker,
-- defender, def, moveId, sureHit)` -- SIX positional args, not one ctx
-- table -- BEFORE its own damage path, and returns immediately
-- (gen2/Battle.lua:1533-1538). A single-param `function(ctx)` silently
-- captures `self` (the raw Battle instance, which has no `.target` field
-- -- confirmed, zero `self.target =` assignments anywhere in gen2/
-- Battle.lua) as `ctx`, so `ctx.target` was always nil on Gen 2: the
-- roll never ran, the flag never got set, AND -- because the dispatch
-- returns unconditionally right after calling the handler -- the move
-- dealt NO DAMAGE and skipped whatever turn-resolution bookkeeping
-- normally follows a landed hit. That is almost certainly the actual
-- shape of the reported bug (a Gen 2 target that got hit by a flinch-
-- chance move never receiving its "turn completed" step reads as
-- "can't act ever again," not literally as an uncleared flag), on top
-- of silently killing damage for every flinch/confuse-chance move on
-- Gen 2.
--
-- Fixed the same way every other on-hit side effect in this project
-- already is (Rapid Spin, Knock Off, Covet, ... -- combat/
-- modern_hazards.lua, combat/modern_items.lua): kind="full" with NO run
-- field (so damage always proceeds normally on both engines), and the
-- actual roll+flag-set moves to a separate battle.damage_dealt listener,
-- confirmed identical payload shape on both engines and fired only
-- AFTER a landed, non-immune hit.
--
-- Storage location differs by generation -- confirmed directly against
-- this mod's OWN existing gigantamax/gimmick_dynamax.lua
-- clearDynamaxVolatiles, which already draws this exact distinction:
-- Gen 1 keeps flinched/confusedTurns directly on the battler
-- (who.flinched, who.confusedTurns); Gen 2 keeps the equivalents inside
-- battle:volatile(mon) (vol.flinched, vol.confuseCount -- note the
-- different field NAME too, not just location, matching gen2/Battle
-- .lua's own read site at line ~912/921). Writing target.flinched = true
-- unconditionally (the original bug) never touched the place Gen 2
-- actually reads.
--
-- GALAR_TRAP_EFFECT is NOT touched here -- same underlying dispatch bug,
-- but Gen 2 already has a real, separate, WORKING native trap mechanic
-- (mon.wrapCount / EFFECT_TRAP_TARGET, gen2/Battle.lua:1769-1785,
-- confirmed this session) that this effect was never wired to and would
-- need a deliberate design call (route through wrapCount vs. keep its
-- own state), not a same-shape patch. Left as a separately flagged,
-- known-broken-on-Gen-2 issue.
--
-- Duration values (confusedTurns, 2-5 turns) are reasonable
-- approximations, not confirmed exact -- this engine's own real formula
-- was not found in any reference source; unchanged by this fix.
--
-- FULLY MIGRATED off moves_new.lua (2026-08-26): flinch/confusion chance
-- read LIVE from national_dex's own moveById record (flinchChance,
-- ailment=="confusion"+ailmentChance) for EVERY landed hit, not from a
-- precomputed table built from this mod's own static data. This also
-- means no per-move GALAR_FLINCH_EFFECT_<chance>/GALAR_CONFUSE_EFFECT_
-- <chance> registration is needed at all anymore -- the listener reacts
-- to the real move id directly, independent of whatever that move's own
-- registered `effect` field says. Strictly more general than the old
-- approach too: it now applies to EVERY move in national_dex's full
-- roster (any native Gen 1/2 move with a real flinch/confusion chance,
-- not just the 179 this mod's own moves_new.lua happened to cover).
local function installMovepoolEffects(mod)
  local nationalDex = mod.find and mod.find("national_dex")
  assert(nationalDex and nationalDex.exports and nationalDex.exports.moveById,
    "installMovepoolEffects: national_dex must be loaded first")
  local moveById = nationalDex.exports.moveById

  mod.events:on("battle.damage_dealt", function(ev)
    local battle = ev and ev.battle
    local moveId = ev and ((ev.move and ev.move.id) or ev.moveId)
    local target = ev and ev.target
    if not (battle and moveId and target) then return end
    local ok, info = pcall(moveById, moveId)
    if not (ok and info) then return end
    local flinchChance = (info.flinchChance or 0) > 0 and info.flinchChance or nil
    local confuseChance = (info.ailment == "confusion" and (info.ailmentChance or 0) > 0)
      and info.ailmentChance or nil
    if not (flinchChance or confuseChance) then return end
    local applyOk, err = pcall(function()
      -- isGen2Battle is looked up lazily (not hoisted to a local at the
      -- top of this file) because installMovepoolEffects runs during
      -- Phase 2, before combat/modern_combat.lua (Phase 6+) has loaded
      -- and populated mod.exports -- this closure only runs later,
      -- during a real battle, by which point every mod has finished
      -- loading.
      local gen2 = mod.exports.isGen2Battle and mod.exports.isGen2Battle(battle)
      -- RNG convention genuinely differs by engine, confirmed directly:
      -- Gen 1's battle.rng(a, b) (BattleState.lua:596, `love.math.random
      -- (a, b)`) is inclusive-both-ends. Gen 2 has NO .rng field at all
      -- (confirmed, zero matches in gen2/Battle.lua) -- its real
      -- primitive is battle.random(n), a single-arg roll returning
      -- 0..n-1 (gen2/Battle.lua:220 `self.random = opts.random or
      -- function(n) return rand(nil, n) end`), and every native Gen 2
      -- percent-chance check uses exactly `rand(self.random, 100) <
      -- chance` (e.g. gen2/Battle.lua:1815/1821/1850) -- battle.random
      -- (100) < chance here mirrors that same, real, established idiom.
      local function percentRoll(chance)
        if gen2 then return battle.random(100) < chance end
        return battle.rng(1, 100) <= chance
      end
      local function rangeRoll(lo, hi)
        if gen2 then return lo + battle.random(hi - lo + 1) end
        return battle.rng(lo, hi)
      end
      if flinchChance and percentRoll(flinchChance) then
        if gen2 then
          battle:volatile(target).flinched = true
        else
          target.flinched = true
        end
      end
      if confuseChance and percentRoll(confuseChance) then
        if gen2 then
          local vol = battle:volatile(target)
          if not vol.confuseCount then vol.confuseCount = rangeRoll(2, 5) end
        elseif not target.confusedTurns then
          target.confusedTurns = rangeRoll(2, 5)
        end
      end
    end)
    if not applyOk then
      mod.log:warn("galar_gmax_dex: installMovepoolEffects: flinch/confuse failed: %s",
        tostring(err))
    end
  end)

  -- Unconditional registration, genuinely independent of any per-move
  -- data -- only SANDTOMB's own live record gets patched to point at it
  -- (see wireMovepoolSubEffects below).
  mod.content.move_effects:register("GALAR_TRAP_EFFECT", {
    kind = "secondary",
    run = function(ctx)
      if ctx.target then
        -- Approximated duration (4-5 turns); real Gen 1 Bind/Wrap use a
        -- per-turn release roll this engine's equivalent wasn't confirmed.
        ctx.target.trappingTurns = ctx.rng(4, 5)
        ctx.target.boundTurns = ctx.target.trappingTurns
        ctx.target.trapMove = ctx.move and ctx.move.id
      end
      return {}
    end,
  })
end

-- bypassesProtect (Feint's own flag, Phase 3 of the move-effect
-- completion pipeline) -- a plain data flag, not schema-declared on
-- R.moves (Schemas.lua:824-846) but preserved anyway by that schema's
-- own record-mode leniency (same "unknown top-level fields ride through"
-- behavior modern_movepool_damage.lua's header already confirmed for
-- R.move_effects); modern_combat_protect.lua's battle.damage hook reads
-- it off the live move record, patched on by wireMovepoolSubEffects
-- below rather than registered as part of a full move entry. national_
-- dex has no equivalent field -- this mod invented it, it belongs here
-- as a small hardcoded map, not a file.
local BYPASSES_PROTECT = { FEINT = true }

-- Every move whose real custom effect handler (registered elsewhere in
-- this mod, with REAL run/afterDamage/charge logic -- verified one by
-- one, not assumed) depends on ITS OWN move record's `effect` field
-- actually pointing at that handler. This table is EXACTLY what used to
-- be carried silently by moves_new.lua's own per-move `effect` field,
-- copied onto the live record by the old generic wireMovepoolSubEffects
-- loop -- removing that loop without this table would have silently
-- broken every one of these (confirmed real regression caught and fixed
-- in the same session it was introduced: re-audited every mod.content.
-- move_effects:register call in this codebase after the fact, checked
-- each one's actual body for real logic vs. an empty {kind="full"}
-- stub-audit marker -- the empty ones (Acrobatics/Venoshock/Assurance/
-- Heat Crash/Heavy Slam/Power Trip/Flail/Endeavor/Twister/Blizzard/
-- Rapid Spin) need NO patch at all: their real mechanic runs
-- unconditionally off ctx.move.id inside a registerDamageModifier entry
-- or a battle.damage_dealt listener, never through this field -- and two
-- more (GGD_MAXGUARD_EFFECT, GMAX_CUDDLE_EFFECT) belong to moves this mod
-- or gmax_moves.lua already registers/patches directly, with no
-- national_dex record at all, so they were never in scope here).
local CUSTOM_EFFECT_PATCH = {
  -- main.lua's own GALAR_TRAP_EFFECT (installMovepoolEffects above)
  SANDTOMB = "GALAR_TRAP_EFFECT",
  -- combat/modern_weather.lua
  RAINDANCE = "GALAR_RAINDANCE_EFFECT",
  SUNNYDAY = "GALAR_SUNNYDAY_EFFECT",
  SANDSTORM = "GALAR_SANDSTORM_EFFECT",
  SNOWSCAPE = "GALAR_SNOWSCAPE_EFFECT",
  SOLARBEAM = "GALAR_SOLARBEAM_EFFECT",
  -- combat/modern_movepool_damage.lua
  DRAININGKISS = "GALAR_DRAIN_EFFECT_75",
  HEALPULSE = "GALAR_HEALPULSE_EFFECT",
  LIFEDEW = "GALAR_LIFEDEW_EFFECT",
  SYNTHESIS = "GALAR_SYNTHESIS_EFFECT",
  PAINSPLIT = "GALAR_PAINSPLIT_EFFECT",
  BOUNCE = "GALAR_BOUNCE_EFFECT",
  OUTRAGE = "GALAR_OUTRAGE_EFFECT",
  ETERNABEAM = "GALAR_ETERNABEAM_EFFECT",
  -- combat/modern_movepool_status.lua
  FLATTER = "GMAX_FLATTER_EFFECT",
  SWAGGER = "GMAX_SWAGGER_EFFECT",
  -- combat/modern_status_effects.lua
  ATTRACT = "GMAX_ATTRACT_EFFECT",
  TAUNT = "GMAX_TAUNT_EFFECT",
  TORMENT = "GMAX_TORMENT_EFFECT",
  -- combat/modern_hazards.lua
  STEALTHROCK = "GALAR_STEALTHROCK_EFFECT",
  TOXICSPIKES = "GALAR_TOXICSPIKES_EFFECT",
  -- combat/modern_movepool_stages.lua -- primary() (pure status moves)
  AROMATICMIST = "GMAX_AROMATICMIST_EFFECT",
  BULKUP = "GMAX_BULKUP_EFFECT",
  CALMMIND = "GMAX_CALMMIND_EFFECT",
  CHARGE = "GMAX_CHARGE_EFFECT",
  CHARM = "GMAX_CHARM_EFFECT",
  COIL = "GMAX_COIL_EFFECT",
  CONFIDE = "GMAX_CONFIDE_EFFECT",
  COSMICPOWER = "GMAX_COSMICPOWER_EFFECT",
  COTTONGUARD = "GMAX_COTTONGUARD_EFFECT",
  COTTONSPORE = "GMAX_COTTONSPORE_EFFECT",
  DECORATE = "GMAX_DECORATE_EFFECT",
  DRAGONDANCE = "GMAX_DRAGONDANCE_EFFECT",
  EERIEIMPULSE = "GMAX_EERIEIMPULSE_EFFECT",
  FAKETEARS = "GMAX_FAKETEARS_EFFECT",
  HONECLAWS = "GMAX_HONECLAWS_EFFECT",
  IRONDEFENSE = "GMAX_IRONDEFENSE_EFFECT",
  METALSOUND = "GMAX_METALSOUND_EFFECT",
  NASTYPLOT = "GMAX_NASTYPLOT_EFFECT",
  NOBLEROAR = "GMAX_NOBLEROAR_EFFECT",
  PLAYNICE = "GMAX_PLAYNICE_EFFECT",
  ROCKPOLISH = "GMAX_ROCKPOLISH_EFFECT",
  SCARYFACE = "GMAX_SCARYFACE_EFFECT",
  SHIFTGEAR = "GMAX_SHIFTGEAR_EFFECT",
  SWEETSCENT = "GMAX_SWEETSCENT_EFFECT",
  TARSHOT = "GMAX_TARSHOT_EFFECT",
  TEARFULLOOK = "GMAX_TEARFULLOOK_EFFECT",
  -- combat/modern_movepool_stages.lua -- secondary() (damaging moves)
  ACIDSPRAY = "GMAX_ACIDSPRAY_EFFECT",
  ANCIENTPOWER = "GMAX_ANCIENTPOWER_EFFECT",
  APPLEACID = "GMAX_APPLEACID_EFFECT",
  BREAKINGSWIPE = "GMAX_BREAKINGSWIPE_EFFECT",
  BUGBUZZ = "GMAX_BUGBUZZ_EFFECT",
  BULLDOZE = "GMAX_BULLDOZE_EFFECT",
  CLOSECOMBAT = "GMAX_CLOSECOMBAT_EFFECT",
  CRUNCH = "GMAX_CRUNCH_EFFECT",
  DRUMBEATING = "GMAX_DRUMBEATING_EFFECT",
  ENERGYBALL = "GMAX_ENERGYBALL_EFFECT",
  FIRELASH = "GMAX_FIRELASH_EFFECT",
  FLAMECHARGE = "GMAX_FLAMECHARGE_EFFECT",
  FLASHCANNON = "GMAX_FLASHCANNON_EFFECT",
  GRAVAPPLE = "GMAX_GRAVAPPLE_EFFECT",
  HAMMERARM = "GMAX_HAMMERARM_EFFECT",
  LEAFSTORM = "GMAX_LEAFSTORM_EFFECT",
  LEAFTORNADO = "GMAX_LEAFTORNADO_EFFECT",
  LIQUIDATION = "GMAX_LIQUIDATION_EFFECT",
  LUNGE = "GMAX_LUNGE_EFFECT",
  METALCLAW = "GMAX_METALCLAW_EFFECT",
  PLAYROUGH = "GMAX_PLAYROUGH_EFFECT",
  POWERUPPUNCH = "GMAX_POWERUPPUNCH_EFFECT",
  RAZORSHELL = "GMAX_RAZORSHELL_EFFECT",
  ROCKSMASH = "GMAX_ROCKSMASH_EFFECT",
  ROCKTOMB = "GMAX_ROCKTOMB_EFFECT",
  SPIRITBREAK = "GMAX_SPIRITBREAK_EFFECT",
  STEELWING = "GMAX_STEELWING_EFFECT",
  STRUGGLEBUG = "GMAX_STRUGGLEBUG_EFFECT",
  SUPERPOWER = "GMAX_SUPERPOWER_EFFECT",
  -- combat/modern_movepool_stages.lua -- Clear Smog (its own registration)
  CLEARSMOG = "GMAX_CLEARSMOG_EFFECT",
}

-- Completeness, read ENTIRELY from national_dex's own modern fields --
-- no hardcoded per-move exemption list at all (confirmed directly:
-- Feint and Round, the two moves that used to need a special-cased
-- exemption under the old PBS-functionCode model, both come back
-- completely empty on every one of these fields already -- neither
-- "bypasses Protect" nor "doubles-only ally bonus" is a secondary-effect
-- TYPE national_dex's schema tracks at all, so there was never anything
-- here for them to be stubbed on in the first place).
--
-- flinchChance / confusion / multiHit are each handled GENERICALLY for
-- every move in the whole roster now (installMovepoolEffects reads
-- flinch/confusion live; this file's own wireMovepoolSubEffects derives
-- and patches multiHit live) -- a move needing ONLY one of those three
-- is complete with zero registration of its own. Anything else (a real
-- non-confusion ailment, a stat change, drain, healing, or a multi-turn
-- charge) needs a REAL custom effect actually registered and patched
-- onto the live record by some file in this mod -- confirmed this
-- already happens for e.g. Protect/Detect (modern_combat_protect.lua)
-- and Trick Room (combat/trick_room.lua), both picked up here for free
-- since this reads the LIVE record, not a static snapshot.
local function isMoveDataComplete(liveRecord)
  if not liveRecord then return false end
  local hasAilment = liveRecord.ailment and liveRecord.ailment ~= "none"
  local isConfusion = liveRecord.ailment == "confusion"
  local hasStatChange = #(liveRecord.statChanges or {}) > 0
  local hasDrain = (liveRecord.drain or 0) ~= 0
  local hasHeal = (liveRecord.healing or 0) ~= 0
  local hasMultiTurn = (liveRecord.minTurns or 0) > 0 or (liveRecord.maxTurns or 0) > 0
  local needsCustomEngineering = (hasAilment and not isConfusion)
    or hasStatChange or hasDrain or hasHeal or hasMultiTurn
  if not needsCustomEngineering then return true end
  return liveRecord.effect ~= nil and liveRecord.effect ~= "NO_ADDITIONAL_EFFECT"
end

-- STANDING RULE, explicit and repeated user instruction: this mod NEVER
-- registers a move, full stop -- no mod.content.moves:register/:override
-- call writes base move data (name/type/category/power/accuracy/pp/
-- priority) anywhere in this codebase. national_dex is the sole source
-- for that data, unconditionally, for its entire roster. Confirmed
-- exhaustively (2026-08-26, diffed every id, not sampled): all 179 ids
-- this mod used to register already exist as full, real records in
-- national_dex's own catalogue (764 total moves) -- registering/
-- overriding them was pure, harmful duplication of data national_dex
-- already owns, not a gap-filling measure.
--
-- moves_new.lua ITSELF is gone too (2026-08-26) -- its last three
-- legitimate (non-registration) uses are all replaced with live national
-- _dex reads: flinch/confuse chance (installMovepoolEffects above),
-- highCrit/multiHit (derived below from national_dex's own critRate/
-- minHits/maxHits), and move-completeness classification (isMoveDataComplete
-- above, reading national_dex's own modern fields directly). Applied
-- uniformly across national_dex's ENTIRE roster now, not just the 179
-- ids this mod's own old data file happened to cover.
local function wireMovepoolSubEffects(mod)
  installMovepoolEffects(mod)
  local nationalDex = mod.find and mod.find("national_dex")
  assert(nationalDex and nationalDex.exports and nationalDex.exports.moveById
      and nationalDex.exports.listMoves,
    "wireMovepoolSubEffects: national_dex must be loaded first")
  local moveById = nationalDex.exports.moveById
  local patched = 0
  for _, id in ipairs(nationalDex.exports.listMoves()) do
    if mod.content.moves:get(id) then
      local ok, info = pcall(moveById, id)
      if ok and info then
        local patch = {}
        if BYPASSES_PROTECT[id] then patch.bypassesProtect = true end
        if CUSTOM_EFFECT_PATCH[id] then patch.effect = CUSTOM_EFFECT_PATCH[id] end
        -- critRate is the number of +1 crit-stage bumps the move itself
        -- grants (confirmed: Cross Poison critRate=1, a real high-crit
        -- move; Axe Kick/Baddy Bad critRate=0, ordinary) -- >=1 maps onto
        -- this engine's own boolean highCrit field.
        if (info.critRate or 0) >= 1 then patch.highCrit = true end
        -- multiHit: a fixed count (minHits==maxHits, e.g. Double Hit's
        -- 2-2) is just that count twice; the real 2-5 range (Bullet Seed,
        -- Rock Blast, Double Iron Bash) is the well-known, generation-
        -- independent 3/8·3/8·1/8·1/8 weighted distribution -- confirmed
        -- directly against national_dex's OWN effect text for these
        -- moves ("Has a 3/8 chance each to hit 2 or 3 times, and a 1/8
        -- chance each to hit 4 or 5 times"), not guessed. Any other
        -- min/max combination this roster doesn't currently use falls
        -- through to an unweighted flat range rather than silently
        -- guessing a distribution with no confirmed source.
        local minHits, maxHits = info.minHits or 0, info.maxHits or 0
        if minHits > 0 and maxHits > 0 then
          if minHits == maxHits then
            patch.multiHit = { minHits, minHits }
          elseif minHits == 2 and maxHits == 5 then
            patch.multiHit = { 2, 2, 2, 3, 3, 3, 4, 5 }
          else
            local range = {}
            for n = minHits, maxHits do range[#range + 1] = n end
            patch.multiHit = range
          end
        end
        if next(patch) then
          mod.content.moves:patch(id, patch)
          patched = patched + 1
        end
      end
    end
  end
  return patched
end

-- =============================================================================
-- Phase 3: Gigantamax moves -- fed to dynamax, not registered here
-- =============================================================================
-- dynamax now owns both the actual move registration (mod.content.moves)
-- and the species -> move Gigantamax substitution rule (computeMaxMoveId's
-- own type-matching check) -- see dynamax/main.lua's "Gigantamax moves"
-- section. This mod's job is just handing over its own data: the 32 new
-- moves' definitions (gmax_moves.lua) and which species uses which move
-- (gmax_data.lua's own gmaxMove field, already used for dex text/height
-- too). Registration is skipped entirely if dynamax isn't loaded -- the
-- whole Gigantamax mechanic is inert without it either way, same
-- reasoning installGmaxAssetPacks's own reapplyGmaxSprites already
-- applies to sprites below.
local function installGigantamaxMoves(mod, gmaxMovesData, gmaxData)
  local dynamaxMod = mod.find("dynamax")
  if not (dynamaxMod and dynamaxMod.exports and dynamaxMod.exports.registerGmaxMoves
      and dynamaxMod.exports.setGigantamaxMove) then
    mod.log:warn("galar_gmax_dex: dynamax not loaded; Gigantamax moves (and the whole Gigantamax mechanic) are inactive")
    return 0
  end
  -- gmax_moves.lua keeps PBS's own type spelling too (e.g. "PSYCHIC" for
  -- GMAXGRAVITAS) -- translated into a fresh table here before handing it
  -- to dynamax, the same engineTypeId helper applied elsewhere, rather
  -- than mutating the loaded gmax_moves.lua table in place. Gigantamax
  -- moves are genuinely this mod's own invented content -- no national_dex
  -- equivalent exists for them at all, so registering them here (unlike
  -- the Phase 2 sub-effect-only approach above) is correct, not a
  -- violation of the "never register a move" rule, which is specifically
  -- about moves national_dex already owns. This mod is responsible for
  -- feeding dynamax engine-ready
  -- data; dynamax trusts what it's given rather than knowing about
  -- PBS-specific naming quirks itself.
  local translatedMoves = {}
  for id, def in pairs(gmaxMovesData) do
    local entry = {}
    for field, value in pairs(def) do entry[field] = value end
    entry.type = engineTypeId(entry.type)
    translatedMoves[id] = entry
  end
  local registered = dynamaxMod.exports.registerGmaxMoves(translatedMoves)
  for _, id in ipairs(gmaxData.order) do
    local species = gmaxData.species[id]
    if species and species.gmaxMove then
      dynamaxMod.exports.setGigantamaxMove(id, species.gmaxMove)
    end
  end
  return registered
end

-- =============================================================================
-- Phase 3: Gigantamax sprite asset packs -- toggle + extension point
-- =============================================================================
-- No real Gigantamax art exists yet (Phase 4 only ever slices each
-- species' *normal* battle sprite from Pokemon_Back_Front -- a distinct,
-- oversized Gigantamax look is a separate, later asset drop, same as the
-- real games treat it). This mod owns WHICH art feeds dynamax's own
-- mod.exports.setDynamaxSprite(speciesId, def) -- confirmed real,
-- documented in dynamax's main.lua -- not how it's drawn or animated.
--
--   - Built-in "placeholder" behavior (always available, needs no pack
--     registered): do nothing, so the species keeps its ordinary battle
--     sprite while Dynamaxed. Dynamax's own scale-up animation already
--     reads correctly with this -- only the unique look is missing.
--   - mod.exports.registerGmaxAssetPack(packId, resolverFn) lets a future,
--     separate graphics mod plug in real art with zero changes to this
--     mod's own code. resolverFn(speciesId) returns a sprite def (the
--     same {image=...} / {frames=...,fps=...} shape setDynamaxSprite
--     already accepts) or nil to fall through to the placeholder.
--   - mod.exports.setActiveGmaxAssetPack(packId) selects which registered
--     pack is live.
--   - The "gmax_custom_art" option is the actual toggle: off always forces
--     the placeholder, regardless of what's registered -- e.g. to compare
--     against a pack, or while a pack is still a known-broken draft.
-- Since dynamax's own DYNAMAX_SPRITES table is a one-time write (read
-- directly off mon.species at battle time, not re-checked against
-- options live), toggling either the option or the active pack only
-- takes effect after reapplyGmaxSprites runs again -- called once at
-- load and again on save.loaded, the same re-apply-on-load convention
-- gorochu.lua's own migrate() uses.
-- [g9-battle-engine-beta] Gigantamax/battle sprite asset-pack toggles
-- (installGmaxAssetPacks, installSpriteAssetPacks, installRestingScaleOverride,
-- installGen2BattlePicPositionFix) removed entirely -- this fork owns combat
-- only, no sprite/asset handling of any kind. See g9-battle-engine for those.

-- =============================================================================
-- Move name display -- shrink-to-fit for names longer than the classic box
-- =============================================================================
-- Real English move names run longer than the short Spanish text this pack
-- used before (e.g. "High Horsepower", "Psychic Terrain" are 14-15 chars),
-- past the classic move-list box's confirmed ~13-character budget: the box
-- is drawn at tile (4,12) 16x6, names start at column 6 (x=48), confirmed
-- via src/battle/BattleState.lua's real drawTextArea -- moveSelect branch
-- (`Font.draw(def.name, 48, 96 + i * 8)`), with the box's own right border
-- at column 19 (x=152), leaving 104px = 13 chars at the native 8px-per-char
-- fixed-width font.
--
-- This is base-engine UI code, not something this mod owns, so it's
-- reached the same way dynamax's own mod reaches drawBattlerPic: wrap the
-- real method (BattleState:drawTextArea, confirmed a real top-level method,
-- not an inline block), call the vanilla draw first, then -- only for
-- names that would actually overflow -- erase just that row's text cell
-- (the same "paint white first" idiom drawTextArea's own moveSelect branch
-- already uses for the border-cell redraws) and redraw at a shrunk scale.
-- Font.draw/Font.drawCode take no scale parameter (confirmed: plain
-- love.graphics.draw(image, quad, x, y) calls) -- scaling is done via a
-- love.graphics transform anchored at the text's own top-left, not a
-- per-glyph change, so short names that already fit are left at the
-- vanilla draw's normal size untouched.

-- [g9-battle-engine-beta] installPlayerSpriteSide/installSpriteAnimation
-- (battle sprite animation), installOverworldSpriteProvider/
-- installWildDrawOverride (overworld sprites), installBigPartyIcons/
-- installBigPartyIconsGen2 (sprite-based party icons) removed entirely --
-- same reason as above.

-- [g9-battle-engine-beta] These three were originally declared right
-- next to installBigPartyIcons/Gen2 (sprite-based party icons, removed)
-- purely by file-position coincidence -- they belong to
-- installMoveNameDisplay below, not to anything sprite-related, and got
-- swept up in that removal by mistake (confirmed live: "attempt to
-- perform arithmetic on global 'MOVE_LIST_TEXT_RIGHT' (a nil value)" on
-- boot). Restored here, unchanged from the source mod.
local MOVE_LIST_TEXT_X = 48
local MOVE_LIST_TEXT_RIGHT = 152 -- box's own right border column (19*8)
local MOVE_LIST_ROW_HEIGHT = 8

local function installMoveNameDisplay(mod)
  local BattleState = require("src.battle.BattleState")
  if BattleState.__galarMoveNameWrapped then return end
  BattleState.__galarMoveNameWrapped = true

  local Font = require("src.render.Font")
  local availableWidth = MOVE_LIST_TEXT_RIGHT - MOVE_LIST_TEXT_X

  local vanillaDrawTextArea = BattleState.drawTextArea
  function BattleState:drawTextArea()
    local result = vanillaDrawTextArea(self)
    if self.phase == "moveSelect" and self.player and self.player.curMoves then
      for i, mv in ipairs(self.player.curMoves) do
        local def = mv.id and self.data.moves[mv.id]
        local name = def and def.name
        if name then
          local width = Font.width(name)
          if width > availableWidth then
            local y = 96 + i * MOVE_LIST_ROW_HEIGHT
            -- erase the vanilla-drawn full-size text before redrawing
            -- smaller, same "wipe to box white" idiom used elsewhere in
            -- this exact function for the border-cell redraws
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("fill", MOVE_LIST_TEXT_X, y,
              availableWidth, MOVE_LIST_ROW_HEIGHT)
            love.graphics.setColor(0, 0, 0, 1)
            local scale = availableWidth / width
            love.graphics.push()
            love.graphics.translate(MOVE_LIST_TEXT_X, y)
            love.graphics.scale(scale, scale)
            Font.draw(name, 0, 0)
            love.graphics.pop()
          end
        end
      end
    end
    return result
  end
end

local HAPPINESS_EVOLUTION_THRESHOLD = 220
local HAPPINESS_BATTLE_GAIN = 3

local function installHappinessEvolution(mod)
  mod.content.evolution_methods:register("HAPPINESS", {
    check = function(_, mon, _, trigger)
      return trigger.kind == "levelup"
        and (mon.happiness or 0) >= HAPPINESS_EVOLUTION_THRESHOLD
    end,
    describe = function() return "High friendship" end,
  })

  -- Approximated: any completed battle nudges the active mon's happiness
  -- up a little, regardless of outcome. The real games track many finer
  -- deltas (steps walked, level-ups, berries, fainting) this engine has
  -- no equivalent hooks for.
  mod.events:on("battle.ended", function(ev)
    local mon = ev and ev.battle and ev.battle.player and ev.battle.player.mon
    if mon and mon.hp and mon.hp > 0 then
      mon.happiness = math.min(255, (mon.happiness or 70) + HAPPINESS_BATTLE_GAIN)
    end
  end)
end

-- Generalizes gorochu.lua's installItemEffect (one item -> one species) to
-- any number of item ids. On use, looks up the target's *live* registered
-- species evolutions table (not our own local copy) for a method="ITEM"
-- entry matching the used item, so later patches to that table (by this
-- mod or another) are respected.
local function installEvolutionItems(mod, itemIds)
  local ok, ItemEffects = pcall(require, "src.inventory.ItemEffects")
  if not (ok and ItemEffects and type(ItemEffects.use) == "function"
      and type(ItemEffects.needsTarget) == "function") then
    mod.log:warn("galar_gmax_dex: could not hook ItemEffects; new evolution items will not function")
    return false
  end
  local key = "__galarGmaxDexEvolutionItems"
  local holder = rawget(ItemEffects, key)
  if holder then
    for id in pairs(itemIds) do holder.items[id] = true end
    return true
  end
  holder = {
    items = {},
    use = ItemEffects.use,
    needsTarget = ItemEffects.needsTarget,
  }
  for id in pairs(itemIds) do holder.items[id] = true end

  ItemEffects.needsTarget = function(itemId, itemDef)
    if holder.items[itemId] then return true end
    return holder.needsTarget(itemId, itemDef)
  end
  ItemEffects.use = function(data, save, itemId, target, battle, ...)
    if not holder.items[itemId] then
      return holder.use(data, save, itemId, target, battle, ...)
    end
    if battle then
      return "failed", { "It can't be used\nin battle." }
    end
    local species = target and data and data.pokemon
      and data.pokemon[target.species]
    local matchedSpecies
    for _, evo in ipairs(species and species.evolutions or {}) do
      if evo.method == "ITEM" and evo.item == itemId then
        matchedSpecies = evo.species
        break
      end
    end
    if not matchedSpecies then
      return "failed", { "It won't have\nany effect." }
    end
    return "consumed", nil, { evolveTo = matchedSpecies }
  end
  rawset(ItemEffects, key, holder)
  return true
end

-- Converts the derived-field pair postgame_species.lua also uses:
-- heightM -> {heightFt, heightIn}, weightKg -> weight (decipounds, the
-- same *22.0462262 scaling that formula uses so a Bulbasaur-style 6.9kg
-- entry lands on the same "15.2" display value convention).
local function derivedHeightWeight(heightM, weightKg)
  local totalInches = math.floor((heightM or 0) * 39.3700787 + 0.5)
  return {
    heightFt = math.floor(totalInches / 12),
    heightIn = totalInches % 12,
    weight = math.floor((weightKg or 10) * 22.0462262 + 0.5),
  }
end

-- =============================================================================
-- W1/F1 tuning + test options (Start menu -> MOD MENUS -> G9 DEX)
-- =============================================================================
-- Testing W1 (wild spawns) and F1 (follower) meant editing constants and
-- restarting every time, with no way to compare behaviors live.
--
-- Two real, separately-confirmed pieces, read from actual source rather
-- than assumed (an earlier version of this guessed at a "ui.options.rows"
-- hook that isn't what either of these files actually use):
--
-- 1. mod.options:define(schema) is the entire data-layer integration.
--    ManagerState:schemaFor/buildOptionRows/setOption
--    (src/mods/ManagerState.lua ~865-958) is a complete, already-working
--    generic options screen for ANY mod with a defined schema -- display,
--    cycling, persistence (game.save.options.modOptions + loader.
--    modOptions), and it emits "mod.options_changed" itself on every
--    change, the exact event overworld_spawns.lua/overworld_followers.lua
--    listen for. gen1_modern_ui's own settings work this exact same way
--    (its main.lua: mod.options:define(optionSchema), nothing else for
--    UI) -- confirmed by reading it directly.
--
-- 2. The Start Menu entry point: gen1_modern_ui's main.lua (~2632-2735)
--    wraps "ui.start_menu.items" at priority 90 and groups every item any
--    OTHER mod added via that SAME hook under one "MOD MENUS" row --
--    plain object-identity diffing against what was already in `items`
--    before its own wrapper ran, no mod-id field required. FOLLOWERS_EX's
--    own Start Menu shortcut ("FLL EX") uses this identical hook at
--    default priority. So the fix is: add ONE item to "ui.start_menu.
--    items" at default priority (below gen1_modern_ui's 90, so our
--    addition is already present by the time its next(...) call collects
--    everything to group) that opens the native mod list -- gen1_modern_ui
--    then automatically folds it under MOD MENUS for us; no custom
--    grouping/menu code needed on this side at all.
--
-- [g9-battle-engine-beta] The classic_encounters suppression hook
-- (mod.hooks:wrap("encounter.roll", ...)) is removed here -- it existed
-- ONLY to stop the vanilla step-based encounter roll from double-firing
-- alongside g9-battle-engine's own W1 visible wild-spawn engine, which
-- this fork doesn't have. Without W1 present, that hook would suppress
-- EVERY classic encounter by default (classic_encounters itself defaults
-- OFF) -- an active regression, not harmless dead code, so it's removed
-- rather than left in place. Vanilla's own step-based encounter roll is
-- untouched here and remains fully active.
local function installDebugOptions(mod)
  local schema = loadSibling(mod, "options.lua")
  mod.options:define(schema)

  -- Default priority (below gen1_modern_ui's 90) is load-bearing, not
  -- incidental: it puts this item in the list gen1_modern_ui's own
  -- next(game, items) call collects, so its grouping pass sees and folds
  -- it under MOD MENUS. Opens the native mod list (same call the Start
  -- Menu's own built-in "MODS" row makes, src/ui/StartMenu.lua ~108) --
  -- jumps straight to THIS mod's own options screen instead of landing on
  -- the general mod list first. Confirmed both pieces directly rather than
  -- assumed: StateStack:push(state) calls state:enter() automatically
  -- (src/core/StateStack.lua ~18), and ManagerState:enter() never touches
  -- self.screen (only self.status/self.byId/self.banner, ManagerState.lua
  -- ~182-198) -- so pushing first, then calling :openOptions, is safe and
  -- does not get clobbered by enter()'s own setup. openOptions/schemaFor/
  -- buildOptionRows only ever read m.id off the stand-in table (m.path is
  -- only a fallback for a mod that never called mod.options:define,
  -- ManagerState.lua ~847-863) and the options screen's own :draw()
  -- (~1176-1185) never references self.currentMod at all -- so a minimal
  -- { id = mod.id } is everything openOptions needs here.
  mod.hooks:wrap("ui.start_menu.items", function(next, game, items)
    items = next(game, items) or items
    table.insert(items, {
      label = "G9 DEX",
      onSelect = function()
        local ManagerState = require("src.mods.ManagerState")
        local state = ManagerState.new(game)
        game.stack:push(state)
        state:openOptions({ id = mod.id })
      end,
    })
    return items
  end)

  mod.log:info("galar_gmax_dex: options registered (Start -> MOD MENUS -> G9 DEX -> our options directly)")
end

return function(mod)
  -- src.pokemon.ModernStats / src.pokemon.MoveCategory used to be files
  -- hand-added directly to the engine tree (src/pokemon/), because a
  -- normal require("src.pokemon.X") only ever resolves against the
  -- running game's OWN src/ tree, never a mod's sandboxed folder -- that
  -- worked fine against this project's own dev checkout, but meant the
  -- mod silently depended on an engine fork: a stock/release build (no
  -- hand-added files) crashed on the very first require(), confirmed live
  -- ("module 'src.pokemon.ModernStats' not found"). The engine tree is
  -- meant to stay stock -- both files now live here instead
  -- (engine_modern_stats.lua/engine_move_category.lua).
  --
  -- Previously registered into package.preload so every existing
  -- require("src.pokemon.ModernStats")/require("src.pokemon.MoveCategory")
  -- call site kept working unchanged. package (all of it, not just
  -- io/os/love.filesystem) was removed from the mod sandbox in
  -- gen1recomp's Aug 2026 mod-sandboxing release ("grandmas kitchen") --
  -- confirmed every consumer of these two require() calls is one of this
  -- mod's OWN files (grepped the whole tree: no other mod or engine call
  -- site references src.pokemon.ModernStats/MoveCategory), so this is
  -- fully within our control to rewire. Replacement channel is
  -- mod.exports -- the sandbox announcement's own explicit replacement
  -- for "passing data to another mod/file through a global" -- loaded
  -- once here (singleton, matching require()'s real caching semantics)
  -- and read directly by every consumer instead of require(...).
  mod.exports.ModernStats = mod.exports.ModernStats or loadSibling(mod, "stats/engine_modern_stats.lua")
  mod.exports.MoveCategory = mod.exports.MoveCategory or loadSibling(mod, "combat/engine_move_category.lua")
  local installSaveScrub = loadSibling(mod, "stats/save_scrub.lua")
  installSaveScrub(mod)

  -- Wild encounters get fresh, DV-independent modern IVs/EVs the moment
  -- BattleState.newWild builds them -- see wild_modern_ivs.lua for the
  -- full reasoning. Needs ModernStats resolvable (package.preload just
  -- above), so this stays right after installSaveScrub.
  local installWildModernIvs = loadSibling(mod, "stats/wild_modern_ivs.lua")
  installWildModernIvs(mod)

  -- Trainer mons: an open provider API other mods can feed real modern
  -- stats through (mod.exports.registerTrainerStatsProvider), falling back
  -- to the DV/stat-exp conversion system when none is registered for a
  -- given mon -- see trainer_modern_stats.lua for the full reasoning.
  local installTrainerModernStats = loadSibling(mod, "stats/trainer_modern_stats.lua")
  installTrainerModernStats(mod)

  -- Gen 2 (Gold): a separate implementation from the two installs above --
  -- no shared BattleState/newWild/newTrainer with Gen 1, see
  -- gen2_modern_stats.lua's own header. Uses
  -- mod.exports.resolveTrainerSpec, just registered above, so this stays
  -- after installTrainerModernStats.
  local installGen2ModernStats = loadSibling(mod, "stats/gen2_modern_stats.lua")
  installGen2ModernStats(mod)

  -- Gym leader / Elite Four / Champion / Red team replacement -- TEMPORARILY
  -- DISABLED, explicit user report: "after this update we are getting
  -- silent crash" immediately following this feature landing. Files left
  -- in place (overworld/gym_trainer_teams.lua, overworld/
  -- install_gym_trainer_teams.lua) -- this is the call site alone,
  -- commented out rather than deleted, so re-enabling once the actual
  -- crash cause is found is a one-line change, not a rebuild.
  local gymTrainerTeams = loadSibling(mod, "overworld/gym_trainer_teams.lua")
  local installGymTrainerTeams = loadSibling(mod, "overworld/install_gym_trainer_teams.lua")
  installGymTrainerTeams(mod, gymTrainerTeams)

  -- EV yield on faint: every mon that gains EXP from a KO gains that
  -- species' national_dex EV yield too -- listens to battle.exp_gained,
  -- same event name/compatible payload in both generations, so one file
  -- covers both -- see ev_yield_on_faint.lua for the full reasoning. Purely
  -- event-driven (no install-time species/state dependency beyond
  -- ModernStats being resolvable), so ordering relative to the installs
  -- above doesn't matter beyond happening after package.preload is set up.
  local installEvYieldOnFaint = loadSibling(mod, "stats/ev_yield_on_faint.lua")
  installEvYieldOnFaint(mod)

  -- Confirmed real, previously-unfixed bug: national_dex never sets
  -- baseExp on any species it registers, which floors EXP gain to
  -- exactly 1 for every affected species (src/battle/Experience.lua's
  -- own math.max(1, exp) floor) -- see reapply_national_dex_stats.lua's
  -- own header for the full root-cause chain and the BST-approximation
  -- this patches in. Runs here (species should already be registered by
  -- national_dex, a hard dependency, by the time GalarGmaxDex's own
  -- main.lua executes) and re-syncs on save.loaded/mod.options_changed,
  -- explicit user instruction: "we need a reapply stats too."
  local realBaseExpData = loadSibling(mod, "stats/base_exp_data.lua")
  local installReapplyNationalDexStats = loadSibling(mod, "stats/reapply_national_dex_stats.lua")
  installReapplyNationalDexStats(mod, realBaseExpData)

  -- Registered unconditionally, before the species-registration gate
  -- below: the options screen is a completely independent concern from
  -- whether modern_type_framework happens to be loaded, and should still
  -- work (or at least still exist to explain what's off) even if that
  -- check fails.
  installDebugOptions(mod)

  if not mod.content.type_chart:get("STEEL") then
    mod.log:error("galar_gmax_dex: modern_type_framework is not loaded; skipping species registration")
    return false
  end

  -- Phase 1 species registration used to carry its own stat/type/dex data
  -- AND actually register each species (species_data.lua's species={}
  -- table, 51 species, via mod.content.pokemon:register). Both retired --
  -- explicit user correction: this mod is a CONSUMER of species
  -- existence, never a co-registrant. National_dex (or the base engine,
  -- for the cart-native roster) is who actually calls :register() for a
  -- given species; calling it a second time throws ("pokemon already
  -- registered: BULBASAUR", confirmed live -- src/mods/Registry.lua's
  -- register is create-only, no upsert). species_data.lua's other two
  -- roles split into their own files: custom_sprite_species.lua (the pure
  -- id list, for the sprite-fallback-safety phase below, which has
  -- nothing to do with where stat data comes from) and
  -- species_evolutions.lua (evolutions + evolution items, for all 1025
  -- national-dex species -- confirmed national_dex's own `evolutions`
  -- field is unpopulated for every record, see that file's own header --
  -- so THIS is the one thing worth patching onto whatever's already
  -- registered, native or national_dex-sourced alike).
  local speciesEvolutions = loadSibling(mod, "species/species_evolutions.lua")

  installHappinessEvolution(mod)
  -- Must run before the evolutions-patching loop below actually matters
  -- (schema cross-validation is a post-merge pass, but registering these
  -- alongside HAPPINESS keeps every evolution_methods registration in one
  -- place) -- see exotic_evolution_stubs.lua for why this is required for
  -- the mod to load at all, not just nice-to-have.
  local installExoticEvolutionStubs = loadSibling(mod, "species/exotic_evolution_stubs.lua")
  installExoticEvolutionStubs(mod)

  local itemIds = {}
  for id, def in pairs(speciesEvolutions.items) do
    mod.content.items:register(id, {
      id = id, name = def.name, price = def.price or 0,
      tossable = true, needsTarget = true,
    })
    itemIds[id] = true
  end
  installEvolutionItems(mod, itemIds)

  -- Patch evolutions onto whatever's already registered -- skip (not
  -- error) a species nothing has registered yet, e.g. national_dex
  -- absent/disabled and the species isn't cart-native either. Gracefully
  -- degraded, not a hard requirement: unlike the old registration-owning
  -- design, this mod no longer needs national_dex present to do SOMETHING
  -- useful (evolutions for the native roster still patch in fine).
  --
  -- Per-ROW filtering too, not just per-species: an evolution row's own
  -- `species` (the evolution TARGET) is just as much an f.id("pokemon")
  -- reference as this loop's own source-species check -- Schemas.lua's
  -- crossValidate treats an unresolved target exactly the same as an
  -- unresolved evolution_methods id (a blocking "unresolved reference"
  -- error, confirmed live). A source species can be perfectly real and
  -- registered while one of ITS evolution targets isn't yet (e.g.
  -- national_dex not installed, or a newer species it doesn't cover) --
  -- dropping only the unresolvable ROW keeps every other real evolution
  -- on that same mon intact instead of losing the whole species' list
  -- over one bad branch.
  -- Gen 2's pokemon record schema (Schemas.lua's gen2Fields for R.pokemon)
  -- shapes an evolution row differently from Gen 1's -- confirmed by
  -- reading it directly: the target-species key is `into`, not `species`
  -- (Gen 1's key), and `species` isn't a recognized field at all under
  -- Gen 2 -- patching a Gen1-shaped row onto a Gen 2 boot fails schema
  -- validation ("unknown field" + "missing required field (pokemon id)"
  -- for every affected species, confirmed live). `method`/`level`/`item`
  -- are the same key names both shapes; Gen 2 also has optional
  -- `time`/`comparison` fields this pass has no source data for, so
  -- they're simply omitted (same "phased honest, not silently wrong"
  -- treatment already used for the 23 custom items/exotic methods).
  local GameVersion = require("src.core.GameVersion")
  local isGen2Boot = GameVersion.generation(GameVersion.get()) == 2

  local patchedEvolutions, skippedSpecies, droppedRows = 0, 0, 0
  for id, evoList in pairs(speciesEvolutions.evolutions) do
    if mod.content.pokemon:get(id) then
      local resolvable = {}
      for _, evo in ipairs(evoList) do
        if mod.content.pokemon:get(evo.species) then
          if isGen2Boot then
            resolvable[#resolvable + 1] = {
              method = evo.method, into = evo.species,
              level = evo.level, item = evo.item,
            }
          else
            resolvable[#resolvable + 1] = evo
          end
        else
          droppedRows = droppedRows + 1
        end
      end
      mod.content.pokemon:patch(id, { evolutions = resolvable })
      patchedEvolutions = patchedEvolutions + 1
    else
      skippedSpecies = skippedSpecies + 1
    end
  end
  mod.log:info(
    "galar_gmax_dex: patched evolutions onto %d species (%d species skipped unregistered, %d rows dropped for an unregistered target) (Phase 1)",
    patchedEvolutions, skippedSpecies, droppedRows)

  -- ------- Phase 2: movepool sub-effects -------
  -- national_dex registers every one of these moves' base data already --
  -- this mod never does (see wireMovepoolSubEffects's own header for the
  -- full standing rule). No moves_new.lua load at all anymore -- everything
  -- below reads national_dex live.
  local movesPatched = wireMovepoolSubEffects(mod)
  -- Exported so combat/learnset_ownership.lua's usability gate reads the
  -- SAME completeness check wireMovepoolSubEffects itself uses, not a second
  -- copy -- confirmed drift bug caught this session: learnset_ownership.lua
  -- had its own independent inline duplicate of this logic, which would
  -- have kept blocking moves from ever being taught even after they became
  -- genuinely complete.
  mod.exports.isMoveDataComplete = isMoveDataComplete

  -- Learnset ownership switch (explicit user decision, this session):
  -- national_dex is the canonical "what can this species learn" source
  -- (its unfiltered movesFull/movesByMethod, not its own filtered
  -- learnset/levelMoves field -- see learnset_ownership.lua's own header
  -- for why that field's filtering can't reflect this mod's own
  -- completeness); GalarGmaxDex gates USABILITY on its own move-effect
  -- completeness, now judged entirely off the live registry (see
  -- learnset_ownership.lua's own header for the full migration).
  local installLearnsetOwnership = loadSibling(mod, "combat/learnset_ownership.lua")
  local learnsetOwnership = installLearnsetOwnership(mod)
  learnsetOwnership.reapplyLearnsets()
  -- TEMPORARILY DISABLED (2026-08-19, spawn-diagnostic session): same
  -- "content is frozen after load" crash as reapplySpritePacks above --
  -- reapplyLearnsets also calls mod.content.pokemon:patch(...) from a
  -- post-boot event. Disabled to stop log noise while diagnosing spawn
  -- hook compatibility; re-enable afterward, real fix still needed.
  -- mod.events:on("save.loaded", learnsetOwnership.reapplyLearnsets)
  -- mod.events:on("mod.options_changed", learnsetOwnership.reapplyLearnsets)

  mod.log:info("galar_gmax_dex: patched sub-effects onto %d moves (Phase 2, no base data registered)", movesPatched)

  -- ------- Phase 3: Gigantamax moves and forms -------
  -- TEMPORARILY DISABLED (2026-08-20, explicit user instruction, removing
  -- all custom combat scenes): Gigantamax's only in-battle trigger was
  -- GimmickRing (mod.exports.gimmickRing, defined by the now-removed
  -- combat/custom_battle_scene.lua) -- with that gone, registering these
  -- moves fed nothing reachable. Kept on disk, not deleted
  -- (gigantamax/gmax_moves.lua, gigantamax/gmax_data.lua,
  -- gigantamax/gimmick_dynamax.lua all still exist unchanged) -- explicit
  -- user instruction: keep this logic and the HP-increase handling
  -- (inside gimmick_dynamax.lua) until proper hooks into whichever other
  -- mod now owns Gigantamax activation are defined, then re-enable both
  -- this block and the Phase 14 install below.
  -- local gmaxMovesData = loadSibling(mod, "gigantamax/gmax_moves.lua")
  -- local gmaxData = loadSibling(mod, "gigantamax/gmax_data.lua")
  -- mod.exports.gmaxData = gmaxData
  -- local gmaxMovesRegistered = installGigantamaxMoves(mod, gmaxMovesData, gmaxData)
  -- mod.log:info(
  --   "galar_gmax_dex: fed %d Gigantamax moves to dynamax for %d/%d species (Phase 3)",
  --   gmaxMovesRegistered, #gmaxData.order, #gmaxData.order)

  -- Dynamax Level / Gigantamax Factor: storage + public API only (explicit
  -- user scope, 2026-08-20) -- no activation, no HP writes, no ownership
  -- of battle_forms's own gimmick mechanics. gmax_data.lua's roster is
  -- loaded fresh here (independent of the disabled block above) purely
  -- as the base-species reference for isGigantamaxEligibleSpecies. See
  -- gigantamax/dynamax_state.lua's own header for the full grounding.
  local gmaxDataForDynamaxState = loadSibling(mod, "gigantamax/gmax_data.lua")
  local installDynamaxState = loadSibling(mod, "gigantamax/dynamax_state.lua")
  installDynamaxState(mod, gmaxDataForDynamaxState)

  -- Tera Type: storage + public API only, same scope discipline as Dynamax
  -- Level/Gigantamax Factor above -- no activation, battle_forms's own
  -- Terastallization menu/item/registry slot untouched. See
  -- gigantamax/tera_state.lua's own header for the full grounding.
  local installTeraState = loadSibling(mod, "gigantamax/tera_state.lua")
  installTeraState(mod)

  -- [g9-battle-engine-beta] Phase 3's Gigantamax ASSET pack call, Phase 4
  -- (battle sprites), Phase 5 (overworld sprite provider + party icons),
  -- Phase 6 (wild encounter area placements), Phase 7 (native overworld
  -- wild-spawn engine), Phase 8 (native follower engine), and Phase 9
  -- (Dramatic Shape voxel billboards) all removed entirely -- this fork owns
  -- combat only. See g9-battle-engine for asset/spawn/sprite/follower handling.

  installMoveNameDisplay(mod)

  -- ------- Phase 10: modern stats display -------
  -- Sp.Atk/Sp.Def, IVs, EVs, Nature, Ability, Item, Tera Type, Dynamax
  -- Level, and per-move category, added to the party submenu ("MODERN")
  -- and to gen1_modern_ui's own modern-styled list rendering when that mod
  -- is present. See modern_stats_screen.lua's own header for why this is
  -- a party-submenu screen rather than a SummaryMenu edit.
  local installModernStatsScreen = loadSibling(mod, "stats/modern_stats_screen.lua")
  installModernStatsScreen(mod)

  -- ------- Phase 11: native modern combat formulas -------
  -- Replaces an earlier live Showdown/Node bridge (TCP process + async
  -- protocol) that proved fragile across a real process boundary (a
  -- respawn race, a missing "end" message handler, a Node-side team-
  -- validation crash). This ports the FORMULAS natively into Lua instead,
  -- hooked through the engine's own sanctioned battle.damage extension
  -- point (BattleState:computeDamage, src/battle/BattleState.lua) rather
  -- than a raw monkey-patch -- no async wait state, no protocol, no
  -- separate process. Applies to every battle (wild, trainer, link), not
  -- just wild ones.
  -- Gen 9 Showdown-accurate primitives (damage/heal/faint/status/
  -- volatile/boost/chance) -- the verb set the new national_dex-
  -- moveById-driven combat mode is built from. No dependency on
  -- anything else in this file; loaded first among the combat/ installs
  -- purely so anything after it can consume mod.exports.ShowdownPrimitives.
  -- See combat/showdown_primitives.lua's own header for the full
  -- grounding and the standing "native stays the storage substrate,
  -- this owns the rules" split.
  local installShowdownPrimitives = loadSibling(mod, "combat/showdown_primitives.lua")
  installShowdownPrimitives(mod)

  -- The generic "this mon's own side switches out mid-move, battle keeps
  -- going" primitive (mod.exports.requestSwitch/registerSwitchAiChooser) --
  -- U-turn/Volt Switch are its first real callers (below), but per explicit
  -- user decision this is meant to be the same entrypoint any future
  -- ability/item effect reaches for too. No dependency on anything else in
  -- this file; loaded here, right after ShowdownPrimitives, so every real
  -- move-effect install below can consume mod.exports.requestSwitch. The
  -- vanilla-scene bridge (switch-request event -> real party pick ->
  -- Battle:switch) has no dependency the other way -- installed alongside
  -- for grouping. See combat/switch_primitives.lua's own header for the
  -- full grounding, including why this mod stays entirely self-contained
  -- (no gen1recomp-dev engine source edits anywhere in it).
  local installSwitchPrimitives = loadSibling(mod, "combat/switch_primitives.lua")
  installSwitchPrimitives(mod)
  local installSwitchVanillaBridge = loadSibling(mod, "combat/switch_vanilla_bridge.lua")
  installSwitchVanillaBridge(mod)

  -- Shared "does the setter hold the duration-extending item" primitive --
  -- weather (below), Trick Room, and the new terrain system (further down)
  -- all resolve their own real duration through this one function rather
  -- than three copies of the same 5-vs-8 check. No dependency on anything
  -- else in this file; loaded here so every real field-effect install
  -- below can consume mod.exports.resolveFieldDuration. See combat/
  -- field_duration.lua's own header for the full grounding.
  local installFieldDuration = loadSibling(mod, "combat/field_duration.lua")
  installFieldDuration(mod)

  -- The ability-execution primitive (mod.exports.abilityIdOf/
  -- abilityBehaviorOf) -- this mod's first real integration of
  -- national_dex's ability data into actual battle behavior. Only needs
  -- national_dex (a hard dependency, already loaded), so it can sit here,
  -- ahead of modern_combat.lua, ready for anything below to consume. See
  -- abilities/ability_dispatch.lua's own header for the full grounding,
  -- including the explicit user directive that every ability engine file
  -- keeps its data (abilities/data/*.lua, pure tables) and its dispatch
  -- logic (abilities/engine/*.lua) in entirely separate files.
  local installAbilityDispatch = loadSibling(mod, "abilities/ability_dispatch.lua")
  installAbilityDispatch(mod)

  local installModernCombat = loadSibling(mod, "combat/modern_combat.lua")
  installModernCombat(mod)

  -- Boss-fight protection flags (mod.exports.setBossFightProtections/
  -- bossFightHas) -- loaded right after modern_combat.lua since several
  -- of its own primitives (setWeather/canSetWeather, changeStage/
  -- bossStatsDropBlocked) read bossFightHas, but every read is lazy
  -- (inside a function body, not hoisted at install time), so this is
  -- about readability, not a real ordering requirement. See combat/
  -- boss_fight.lua's own header for the full flag list and where each
  -- one's actual enforcement lives.
  local installBossFight = loadSibling(mod, "combat/boss_fight.lua")
  installBossFight(mod)

  -- hardStatus/softStatus/antiDrain halves of the boss-fight protection
  -- set -- grouped in their own file since none of the three has an
  -- existing primitive-owning file the way weather/terrain/type do. See
  -- combat/boss_fight_status.lua's own header for the full grounding,
  -- including why its confusion listener needs an explicit priority
  -- rather than trusting load order.
  local installBossFightStatus = loadSibling(mod, "combat/boss_fight_status.lua")
  installBossFightStatus(mod)

  -- The first real wired abilities: Intimidate/Intrepid Sword/Dauntless
  -- Shield/Supersweet Syrup, all switch_in + kind="stat_change" in
  -- national_dex's own data. Consumes modern_combat.lua's changeStage
  -- (installed just above) and ability_dispatch.lua's abilityIdOf
  -- (installed above that). See abilities/engine/switchin_stat_change.lua's
  -- own header for the full grounding and why every other switch_in
  -- ability was left out of this first pass.
  local statChangeSwitchinData = loadSibling(mod, "abilities/data/stat_change_switchin.lua")
  local installSwitchinStatChange = loadSibling(mod, "abilities/engine/switchin_stat_change.lua")
  installSwitchinStatChange(mod, statChangeSwitchinData)
  local installModernCombatProtect = loadSibling(mod, "combat/modern_combat_protect.lua")
  installModernCombatProtect(mod)
  -- Terastallization's own combat mechanics (STAB fix, Stellar defense/
  -- economy, Tera Blast's Stellar variant) -- consumes modern_combat.lua's
  -- exports, must load after it. See combat/modern_tera.lua's own header.
  local installModernTera = loadSibling(mod, "combat/modern_tera.lua")
  installModernTera(mod)

  -- Type override: the generic "this mon's own current type changes mid-
  -- battle" primitive (mod.exports.setMonTypes, the TYPE_CHANGE_SOURCES
  -- dictionary) -- Soak/Magic Powder/Burn Up/etc. are its first real
  -- callers (below), but per explicit user decision this is meant to be
  -- the same entrypoint a future ability (Protean/Libero/Color Change)
  -- reaches for too. Consumes modern_tera.lua's own originalTypesOf,
  -- installed just above. See combat/type_override_primitives.lua's own
  -- header for the full grounding, including why this is a distinct
  -- system from Terastallization.
  local installTypeOverridePrimitives = loadSibling(mod, "combat/type_override_primitives.lua")
  installTypeOverridePrimitives(mod)

  -- Protean/Libero (on_move_used) and Color Change (on_damaged) --
  -- consumes type_override_primitives.lua's setMonTypes/canChangeType/
  -- once-per-switch-in tracking, all installed just above. See abilities/
  -- engine/onmove_type_change.lua and abilities/engine/
  -- ondamage_type_change.lua's own headers for the full grounding.
  local typeChangeOnMoveData = loadSibling(mod, "abilities/data/type_change_onmove.lua")
  local installOnMoveTypeChange = loadSibling(mod, "abilities/engine/onmove_type_change.lua")
  installOnMoveTypeChange(mod, typeChangeOnMoveData)
  local typeChangeOnDamageData = loadSibling(mod, "abilities/data/type_change_ondamage.lua")
  local installOnDamageTypeChange = loadSibling(mod, "abilities/engine/ondamage_type_change.lua")
  installOnDamageTypeChange(mod, typeChangeOnDamageData)

  -- Phase 1.8: Multitype/Forecast/Mimicry -- the "passive, derived-type"
  -- family, a structurally different shape from Protean/Libero/Color
  -- Change above (those are discrete-trigger; these three compute their
  -- type continuously, or in Multitype's case once at switch-in, from
  -- live item/weather/terrain state rather than reacting to one move/
  -- damage event). No dependency on modern_weather.lua/modern_terrain.lua
  -- actually being loaded by this point -- each engine's own asserts only
  -- need type_override_primitives.lua/modern_combat.lua/ability_dispatch
  -- .lua (all already loaded above); their event listeners are lazy and
  -- only ever run during a real battle, by which point every mod has
  -- finished loading. See each file's own header for its full grounding.
  local multitypeSwitchinData = loadSibling(mod, "abilities/data/multitype_switchin.lua")
  local installSwitchinMultitype = loadSibling(mod, "abilities/engine/switchin_multitype.lua")
  installSwitchinMultitype(mod, multitypeSwitchinData)
  local forecastWeatherData = loadSibling(mod, "abilities/data/forecast_weather.lua")
  local installForecastWeather = loadSibling(mod, "abilities/engine/forecast_weather.lua")
  installForecastWeather(mod, forecastWeatherData)
  local mimicryTerrainData = loadSibling(mod, "abilities/data/mimicry_terrain.lua")
  local installMimicryTerrain = loadSibling(mod, "abilities/engine/mimicry_terrain.lua")
  installMimicryTerrain(mod, mimicryTerrainData)

  -- Turn order: Gen 9/Showdown-accurate priority + Speed + Trick-Room-
  -- aware + random-tie comparator, replacing gen2/Battle.lua's own native
  -- one via the battle.turn_order hook. No dependency on modern_combat.lua's
  -- own exports, load position here is just for grouping with the rest of
  -- combat/. See combat/turn_order.lua's own header and
  -- combat/MULTI_BATTLE_HOOKS.md for the full grounding.
  local installTurnOrder = loadSibling(mod, "combat/turn_order.lua")
  installTurnOrder(mod)

  -- Trick Room's own real activation -- fills the exact gap
  -- combat/turn_order.lua's own header flags ("always false today"),
  -- with no dependency the other way around: this just writes
  -- battle.trickRoomActive, which that file already reads. See
  -- combat/trick_room.lua's own header for the full grounding.
  local installTrickRoom = loadSibling(mod, "combat/trick_room.lua")
  installTrickRoom(mod)

  -- Phase 1 of the move-effect completion pipeline: stat-stage-change
  -- stubs wired to modern_combat.lua's changeStage primitive via their own
  -- hardcoded GMAX_*_EFFECT registrations + move patches -- no runtime
  -- dependency on moves_new.lua, which was only ever this file's original
  -- discovery source for which moves needed this. Split into its own
  -- sibling file rather than grown into modern_combat.lua (~56
  -- registrations) -- see that file's own header for the full grounding.
  -- Must load after modern_combat.lua (consumes its exports).
  local installModernMovepoolStages = loadSibling(mod, "combat/modern_movepool_stages.lua")
  installModernMovepoolStages(mod)

  -- Phase 2 of the move-effect completion pipeline: status-infliction
  -- stubs (burn/paralyze/poison secondaries, Flatter/Swagger's combined
  -- stat+confuse) and recoil/drain/heal/two-turn-charge stubs. Two
  -- siblings, not one -- see each file's own header for why the two
  -- buckets need different move_effects record shapes (kind="secondary"+
  -- run vs. kind="full"+afterDamage/charge). Both load after
  -- modern_movepool_stages.lua for load-order consistency, though only
  -- modern_movepool_status.lua/modern_movepool_damage.lua's primary
  -- heals actually need modern_combat.lua's exports.
  local installModernMovepoolStatus = loadSibling(mod, "combat/modern_movepool_status.lua")
  installModernMovepoolStatus(mod)
  local installModernMovepoolDamage = loadSibling(mod, "combat/modern_movepool_damage.lua")
  installModernMovepoolDamage(mod)

  -- Phase 3 of the move-effect completion pipeline: Metal Burst/Mirror
  -- Coat (Detect's patch lives in modern_combat_protect.lua itself, next
  -- to its own PROTECT patch; Feint's bypassesProtect is plain moves_new
  -- .lua data, patched onto the live FEINT record by wireMovepoolSubEffects
  -- above -- neither needs this file). Loaded after modern_combat_protect.lua
  -- (installed above) so its
  -- target.protected checks see a real flag either way, though load order
  -- between the two doesn't actually matter here -- both only read/write
  -- battler fields at battle time, never at load time.
  local installModernMovepoolCounter = loadSibling(mod, "combat/modern_movepool_counter.lua")
  installModernMovepoolCounter(mod)

  -- Volatile statuses native combat never had a mechanic for at all:
  -- Attract, Taunt, Torment (plus the move data that makes Gen 2's own
  -- already-complete Encore mechanism reachable for the first time) --
  -- see modern_status_effects.lua's own header for the full per-engine
  -- enforcement-touch-point grounding.
  local installModernStatusEffects = loadSibling(mod, "combat/modern_status_effects.lua")
  installModernStatusEffects(mod)

  -- Self-switch moves (U-turn, Volt Switch) -- consumes
  -- mod.exports.requestSwitch, installed above; see
  -- combat/modern_switch_moves.lua's own header for why this wraps
  -- Battle:useMove rather than acting straight from its own
  -- battle.damage_dealt listener.
  local installModernSwitchMoves = loadSibling(mod, "combat/modern_switch_moves.lua")
  installModernSwitchMoves(mod)

  -- Terrain: Electric/Grassy/Misty/Psychic -- consumes modern_combat.lua's
  -- curTypesOf/registerDamageModifier and field_duration.lua's
  -- resolveFieldDuration, both installed above. See combat/
  -- modern_terrain.lua's own header for the full grounding.
  local installModernTerrain = loadSibling(mod, "combat/modern_terrain.lua")
  installModernTerrain(mod)

  -- Electric/Grassy/Misty/Psychic Surge + Hadron Engine's terrain half --
  -- consumes modern_terrain.lua's own mod.exports.setTerrain (extracted
  -- from its move starters just above, specifically so this engine could
  -- reuse it) and ability_dispatch.lua's abilityIdOf. See abilities/
  -- engine/switchin_terrain.lua's own header for the full grounding.
  local terrainSwitchinData = loadSibling(mod, "abilities/data/terrain_switchin.lua")
  local installSwitchinTerrain = loadSibling(mod, "abilities/engine/switchin_terrain.lua")
  installSwitchinTerrain(mod, terrainSwitchinData)

  -- change_type moves (Soak, Magic Powder, Conversion, Reflect Type,
  -- Camouflage, Burn Up, Double Shock) -- consumes mod.exports.
  -- setMonTypes (type_override_primitives.lua, installed above) and
  -- battle.terrain (modern_terrain.lua, installed just above). See
  -- combat/modern_type_change_moves.lua's own header for the full
  -- grounding.
  local installModernTypeChangeMoves = loadSibling(mod, "combat/modern_type_change_moves.lua")
  installModernTypeChangeMoves(mod)

  -- Phase 4 of the move-effect completion pipeline: weather (Rain Dance/
  -- Sunny Day/Sandstorm/Snowscape, Thunder/Blizzard's accuracy exception,
  -- Solar Beam's Sun charge-skip, Sand's end-of-turn chip). Weather STATE
  -- and the Sun/Rain damage modifier live in modern_combat.lua itself
  -- (see that file's own header); this sibling owns the wiring. Loaded
  -- after modern_status_effects.lua for load-order consistency with the
  -- rest of this pipeline, and before gimmick_dynamax.lua so its Solar
  -- Beam performMove wrap sits inside (native-ward of) Max Guard's own.
  local installModernWeather = loadSibling(mod, "combat/modern_weather.lua")
  installModernWeather(mod)

  -- Drizzle/Drought/Snow Warning + Orichalcum Pulse's weather half --
  -- consumes modern_weather.lua's own setWeather/currentWeather and
  -- ability_dispatch.lua's abilityIdOf. See abilities/engine/
  -- switchin_weather.lua's own header for the full grounding, including
  -- why Desolate Land/Primordial Sea/Delta Stream are deliberately not
  -- here yet (Phase 1.5, explicit user decision).
  local weatherSwitchinData = loadSibling(mod, "abilities/data/weather_switchin.lua")
  local installSwitchinWeather = loadSibling(mod, "abilities/engine/switchin_weather.lua")
  installSwitchinWeather(mod, weatherSwitchinData)

  -- Phase 1.5: Desolate Land/Primordial Sea/Delta Stream ("primal"
  -- weather) -- irreplaceable, indefinite duration, ends when the setting
  -- Pokemon leaves the field, plus Desolate Land/Primordial Sea's own
  -- Water/Fire move-fail gate and Delta Stream's type-effectiveness cap.
  -- A deliberately separate engine file from switchin_weather.lua just
  -- above -- the mechanics genuinely differ (see that file's own header
  -- for the full grounding), not a copy-paste split. Consumes modern_
  -- weather.lua's own setWeather/currentWeather/canSetWeather (installed
  -- just above) and ability_dispatch.lua's abilityIdOf/abilityBehaviorOf.
  local primalWeatherSwitchinData = loadSibling(mod, "abilities/data/primal_weather_switchin.lua")
  local installSwitchinPrimalWeather = loadSibling(mod, "abilities/engine/switchin_primal_weather.lua")
  installSwitchinPrimalWeather(mod, primalWeatherSwitchinData)

  -- Part B Phase 5, first batch: entry hazards (Stealth Rock, Toxic
  -- Spikes, Rapid Spin). Same load-order requirement as modern_weather.lua
  -- above -- consumes modern_combat.lua's normalize/displayNameFor/
  -- curTypesOf/isGen2Battle exports -- so stays after it; order relative
  -- to modern_weather.lua itself doesn't matter (independent field state).
  local installModernHazards = loadSibling(mod, "combat/modern_hazards.lua")
  installModernHazards(mod)

  -- Part B Phase 5, second batch: item-interaction moves (Fling, Knock
  -- Off, Covet, Incinerate, Bug Bite, Pluck, Recycle, Belch). Same
  -- modern_combat.lua load-order requirement as modern_hazards.lua above.
  local installModernItems = loadSibling(mod, "combat/modern_items.lua")
  installModernItems(mod)

  -- Shared theme/panel primitives (colors, panel(), printText(), cursor,
  -- HP bar) -- one module so battle and every menu screen below read as
  -- one coherent UI instead of per-screen one-off looks.
  local UiTheme = loadSibling(mod, "ui/ui_theme.lua")

  -- [g9-battle-engine-beta] Both custom battle scenes removed entirely
  -- (explicit user instruction, 2026-08-20): the Gen 1 gimmick-menu
  -- overlay (combat/custom_battle_scene.lua, which also defined
  -- mod.exports.gimmickRing) and the full custom Gen 2 battle screen
  -- (combat/gen2_custom_battle_screen.lua). Both files deleted outright,
  -- not just uncalled -- unlike Gigantamax's own move/HP-increase logic
  -- (Phase 3 above, Phase 14 below), there is nothing in either scene
  -- file worth keeping on disk: GimmickRing's replacement is explicitly
  -- expected to live in a different mod entirely, not a future revival
  -- of this code. Battles are fully vanilla on both generations now.

  -- ------- Phase 12: custom menu takeover, party screen first -------
  -- Same architecture gen1_modern_ui itself uses for non-battle screens
  -- (a kindFor-style classifier + the two-hook screen.render_visible /
  -- render.hud suppress-and-replace pattern its own author documents),
  -- generalized from the battle scene's own render.hud panel technique.
  -- Gated on custom_menu_scene, independent of custom_battle_scene so
  -- either can be toggled alone. The plain party overview is native/
  -- vanilla, untouched; this only adds the MOVES/RELEARN/IV-EV party-
  -- submenu extras vanilla doesn't have -- see custom_party_scene.lua's
  -- own header for the reasoning.
  local installCustomPartyScene = loadSibling(mod, "ui/custom_party_scene.lua")
  installCustomPartyScene(mod, UiTheme)

  -- ------- Phase 13: custom menu takeover, title/start/options/mods -------
  -- Same custom_menu_scene gate and render.hud/screen.render_visible
  -- pattern as custom_party_scene.lua, extended to the title screen menu,
  -- the in-game start (pause) menu, the options menu, and the mod
  -- manager -- see custom_menu_takeover.lua's own header for the full
  -- grounding (Menu/OptionsMenu/ManagerState field names, why title/start
  -- menus need to be individually tagged rather than blanket-catching
  -- every Menu instance, and the MOD MENUS hub replication).
  local installCustomMenuTakeover = loadSibling(mod, "ui/custom_menu_takeover.lua")
  installCustomMenuTakeover(mod, UiTheme)

  -- ------- Phase 14: Gigantamax gimmick ring -------
  -- TEMPORARILY DISABLED (2026-08-20, same instruction as Phase 3 above):
  -- gimmick_dynamax.lua registered into mod.exports.gimmickRing, which no
  -- longer exists now that both custom battle scenes are removed. Its
  -- own HP-doubling/3-turn-duration/Max-Move-access logic is otherwise
  -- untouched and stays on disk -- explicit user instruction: keep it,
  -- commented out here, until proper hooks into whichever other mod now
  -- owns Gigantamax activation (and GimmickRing's replacement) are
  -- defined.
  -- local installGigantamax = loadSibling(mod, "gigantamax/gimmick_dynamax.lua")
  -- installGigantamax(mod, mod.exports.gimmickRing)

  -- ------- Phase 15: Gen 2 move-type readout ("Gen 2 WIDE") -------
  -- Independent of everything above -- own option (gen2_wide_layout),
  -- own battle.overlay hook, touches nothing Phase 14/custom_battle_scene
  -- already owns. See gen2_wide_scene.lua's own header for why this is a
  -- same-box addition rather than a real wider canvas (Gen 2 has no
  -- engine-level mechanism for the latter, confirmed this session).
  local installGen2WideScene = loadSibling(mod, "combat/gen2_wide_scene.lua")
  installGen2WideScene(mod)

  -- ------- Phase 16: move-availability gate (0-PP-style blocking) -------
  -- Installed LAST, deliberately: wraps BattleState:update on both
  -- generations and must be the outermost layer so its input check runs
  -- before every other :update wrap installed above (sprite animation,
  -- custom_battle_scene, gimmick_dynamax, gen2_wide_scene) gets a chance
  -- to consume the frame -- see move_availability_gate.lua's own header.
  local installMoveAvailabilityGate = loadSibling(mod, "combat/move_availability_gate.lua")
  installMoveAvailabilityGate(mod, learnsetOwnership.isMoveUsable)
end
