-- Galar Gigantamax Dex -- Phases 1-4: species/evolutions/typing, movepool,
-- Gigantamax moves/forms, and full animated battle sprites.
--
-- Phase 1 registers every species national_dex reports (the base-stat/
-- type/dex source of truth now -- explicit user decision), with
-- evolutions bound in from species_evolutions.lua (national_dex's own
-- evolutions field ships empty). custom_sprite_species.lua is the
-- separate, narrower id list (51 species: the 34 Gigantamax-capable
-- species' full evolution lines) this mod has its own bundled battle/
-- overworld art for -- see the sprite/scale-scoping phases further down.
--
-- Phase 2 (registerNewMoves/patchLearnsets below) replaces Phase 1's
-- placeholder { "TACKLE" } moveset with each species' real level-up
-- learnset. See moves_new.lua's header for the full fully-replicated /
-- approximated / stubbed triage across the 174 non-native moves it
-- registers; 68 more moves in these learnsets are Gen 1-native (already
-- fully implemented by the base engine) and need no registration here at
-- all, only the id translation baked into learnsets_data.lua.
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

-- Same per-primary-type native-Kanto fallback art postgame_species.lua
-- uses, plus FAIRY (not needed by that mod's Johto roster, needed by
-- ours: Milcery/Alcremie).
local TEMPLATE_FOR_TYPE = {
  NORMAL = "RATTATA", GRASS = "BULBASAUR", FIRE = "CHARMANDER",
  WATER = "SQUIRTLE", ELECTRIC = "PIKACHU", BUG = "CATERPIE",
  FLYING = "PIDGEY", POISON = "EKANS", GROUND = "SANDSHREW",
  ROCK = "GEODUDE", PSYCHIC_TYPE = "ABRA", GHOST = "GASTLY",
  ICE = "SEEL", FIGHTING = "MACHOP", DARK = "GROWLITHE",
  STEEL = "MAGNEMITE", DRAGON = "DRATINI", FAIRY = "CLEFAIRY",
}
-- Party-menu icon art: a single static 32x32 pose -- row 0, column 0 (the
-- down-facing idle frame) of each species' own
-- Overworld_Sprites/Followers/<ID>.png sheet (a confirmed 4x4 grid: rows
-- are facing directions down/left/right/up, columns are animation
-- frames). Native cell size is 64px+ per species, so 32x32 is still a
-- resample (nearest-neighbor, to keep pixel-art edges crisp rather than
-- bicubic-softened), but a much gentler one than the classic UI's fixed
-- 16x16 slot allows.
-- This same registration also feeds gen1_modern_ui's icon presenter
-- (iconFor in that mod's main.lua), which reads mod.content.icons /
-- pokemon.icon directly and does real scale-to-fit rendering from the
-- image's actual dimensions -- confirmed by reading that mod's source, not
-- assumed. Points at assets/icons_large specifically for that reason: the
-- classic 160x144 screen can't use the extra resolution (drawIcon has no
-- scale path, only a hard 16x16 crop or native-size draw), so
-- installBigPartyIcons wraps PartyMenu.drawIcon itself to pre-scale this
-- same file down to 16x16 for that screen instead of relying on the
-- registry path there.
local function iconPath(mod, speciesId)
  return mod.path .. "/assets/icons_large/" .. speciesId .. ".png"
end

-- A handful of species have an obviously better-fitting native relative
-- than the generic per-type fallback (Pichu/Munchlax are literally the
-- pre-evolutions of already-native Pikachu/Snorlax).
local SPECIAL_TEMPLATE = {
  PICHU = "PIKACHU",
  MUNCHLAX = "SNORLAX",
}

-- =============================================================================
-- Phase 2: movepool effects
-- =============================================================================
-- Registers one move_effect per distinct chance value actually used in
-- moves_new.lua's GALAR_FLINCH_EFFECT_<chance> / GALAR_CONFUSE_EFFECT_<chance>
-- ids (derived from the data, not hardcoded, so a later phase adding more
-- moves at a new chance tier needs no change here) plus the one
-- unconditional GALAR_TRAP_EFFECT.
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
local function installMovepoolEffects(mod, movesData)
  local flinchChanceByMove, confuseChanceByMove = {}, {}
  for id, def in pairs(movesData) do
    local chance = def.effect:match("^GALAR_FLINCH_EFFECT_(%d+)$")
    if chance then flinchChanceByMove[id] = tonumber(chance) end
    chance = def.effect:match("^GALAR_CONFUSE_EFFECT_(%d+)$")
    if chance then confuseChanceByMove[id] = tonumber(chance) end
  end

  local registeredEffect = {}
  local function registerFullStub(id)
    if registeredEffect[id] then return end
    mod.content.move_effects:register(id, { kind = "full" })
    registeredEffect[id] = true
  end
  for _, chance in pairs(flinchChanceByMove) do
    registerFullStub("GALAR_FLINCH_EFFECT_" .. chance)
  end
  for _, chance in pairs(confuseChanceByMove) do
    registerFullStub("GALAR_CONFUSE_EFFECT_" .. chance)
  end

  mod.events:on("battle.damage_dealt", function(ev)
    local battle = ev and ev.battle
    local moveId = ev and ((ev.move and ev.move.id) or ev.moveId)
    local target = ev and ev.target
    if not (battle and moveId and target) then return end
    local flinchChance = flinchChanceByMove[moveId]
    local confuseChance = confuseChanceByMove[moveId]
    if not (flinchChance or confuseChance) then return end
    local ok, err = pcall(function()
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
    if not ok then
      mod.log:warn("galar_gmax_dex: installMovepoolEffects: flinch/confuse failed: %s",
        tostring(err))
    end
  end)

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

-- Fields mod.content.moves:register actually understands. moves_new.lua
-- also carries `functionCode` (the original PBS FunctionCode, kept purely
-- as documentation of what got stubbed) -- deliberately not passed through.
-- bypassesProtect: Phase 3 of the move-effect completion pipeline (Feint)
-- -- a plain data flag, not schema-declared on R.moves (Schemas.lua:824-846)
-- but preserved anyway by that schema's own record-mode leniency (same
-- "unknown top-level fields ride through" behavior modern_movepool_damage
-- .lua's header already confirmed for R.move_effects); modern_combat_
-- protect.lua's battle.damage hook already reads it off the live
-- registered move, it just needed to actually reach that record.
local MOVE_REGISTER_FIELDS = {
  "name", "type", "category", "power", "accuracy", "pp",
  "priority", "highCrit", "effect", "multiHit", "bypassesProtect",
}

-- A move id is "ours" (GalarGmaxDex owns its mechanics outright, per this
-- session's explicit decision) once it has a real, non-stub effect: either
-- a genuine secondary effect (a custom GALAR_*_EFFECT etc., not the plain
-- "NO_ADDITIONAL_EFFECT" stub placeholder), a real multiHit distribution,
-- a functionCode of "None" (the move never had a secondary effect to
-- begin with -- confirmed complete, not stubbed), or a functionCode of
-- "RemoveProtections" (Feint: its whole real "effect" is the bypassesProtect
-- data flag above, with no move_effects handler of its own to point
-- `effect` at -- same "nothing left to implement" reasoning as "None",
-- just carried by a different field).
local function isMoveDataComplete(def)
  return def.multiHit ~= nil
    or def.effect ~= "NO_ADDITIONAL_EFFECT"
    or def.functionCode == "None"
    or def.functionCode == "RemoveProtections"
    -- Protect/Detect's real effect is applied via a runtime :patch in
    -- modern_combat_protect.lua (both ids, unconditionally), never
    -- through this file's own effect field -- confirmed real bug caught
    -- reviewing Phase 3's own report: without this, isMoveDataComplete
    -- (and learnset_ownership.lua's identical mirror of this check) would
    -- classify PROTECT/DETECT as still-stubbed and the move-availability
    -- gate would block selecting either of them, despite both being
    -- fully functional.
    or def.functionCode == "ProtectUser"
    -- Round's real bonus (double power right after an ally uses Round
    -- the same turn) is a doubles-only mechanic -- this engine is
    -- confirmed singles-only, so there is no ally slot for the
    -- condition to ever read. Nothing left to implement, same
    -- "structurally inert" reasoning as the exemptions above, not a
    -- guessed-away stub.
    or def.functionCode == "UsedAfterAllyRoundWithDoublePower"
end

local function registerNewMoves(mod, movesData)
  installMovepoolEffects(mod, movesData)
  local registered, overridden, skipped = 0, 0, 0
  for id, def in pairs(movesData) do
    local entry = { id = id }
    for _, field in ipairs(MOVE_REGISTER_FIELDS) do
      entry[field] = def[field]
    end
    -- moves_new.lua keeps PBS's own type spelling (e.g. "PSYCHIC"), same
    -- convention national_dex's own types field uses -- translated here
    -- the same way species registration already does via engineTypeId,
    -- rather than registered raw. Missing this for moves specifically
    -- (species typing was already correctly translated) is what produced the
    -- "unresolved reference" validation error.
    entry.type = engineTypeId(entry.type)
    -- national_dex (a hard dependency) unconditionally registers its own
    -- modern move roster, which overlaps a real chunk of these 175 --
    -- both mods separately set out to fill the same "modern moves Gen 1
    -- never had" gap (confirmed collision: HEAVYSLAM exists in both).
    -- :register throws on an existing record-semantics entry (Registry.lua
    -- :90-96), so a collision needs :register vs :override, not a retry.
    -- Explicit user decision, this session: GalarGmaxDex owns move
    -- mechanics outright, so a move we have REAL effect coverage for
    -- always wins here, regardless of registration order -- :override
    -- replaces whatever national_dex/native already set. Anything we
    -- still have stubbed is left alone: overriding with an equally (or
    -- more) incomplete version would be a straight regression.
    if not mod.content.moves:get(id) then
      mod.content.moves:register(id, entry)
      registered = registered + 1
    elseif isMoveDataComplete(def) then
      mod.content.moves:override(id, entry)
      overridden = overridden + 1
    else
      skipped = skipped + 1
    end
  end
  if overridden > 0 or skipped > 0 then
    mod.log:info(
      "galar_gmax_dex: moves: %d newly registered, %d overrode an existing (national_dex/native) registration with our complete implementation, %d left alone (still stubbed here)",
      registered, overridden, skipped)
  end
  return registered
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
  -- to dynamax, the same engineTypeId step registerNewMoves applies to
  -- moves_new.lua, rather than mutating the loaded gmax_moves.lua table
  -- in place. This mod is responsible for feeding dynamax engine-ready
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
local function installGmaxAssetPacks(mod, gmaxData)
  local packs = {}
  local activePackId = nil

  -- gmax_custom_art is defined once, for the whole mod, in options.lua
  -- (loaded/defined by installDebugOptions) -- mod.options:define()
  -- overwrites the entire schema on every call, so a second call here
  -- would have silently discarded every other option this mod exposes.
  mod.exports.registerGmaxAssetPack = function(packId, resolverFn)
    packs[packId] = resolverFn
  end
  mod.exports.setActiveGmaxAssetPack = function(packId)
    activePackId = packId
  end

  local function resolveSprite(speciesId)
    if mod.options:get("gmax_custom_art") == "false" then return nil end
    local resolver = activePackId and packs[activePackId]
    return resolver and resolver(speciesId) or nil
  end

  mod.exports.reapplyGmaxSprites = function()
    local dynamaxMod = mod.find("dynamax")
    if not (dynamaxMod and dynamaxMod.exports and dynamaxMod.exports.setDynamaxSprite) then
      mod.log:warn("galar_gmax_dex: dynamax not loaded; Gigantamax sprites (and the whole Gigantamax mechanic) are inactive")
      return false
    end
    for _, id in ipairs(gmaxData.order) do
      local sprite = resolveSprite(id)
      if sprite then dynamaxMod.exports.setDynamaxSprite(id, sprite) end
    end
    return true
  end

  mod.exports.reapplyGmaxSprites()
  mod.events:on("save.loaded", function() mod.exports.reapplyGmaxSprites() end)
end

-- =============================================================================
-- Phase 4: battle sprites -- full animation, asset pack toggle + extension
-- point
-- =============================================================================
-- assets/<side>/<SPECIES>/NNN.png are every frame of each species'
-- Pokemon_Back_Front sheet, individually sliced (frame size = sheet
-- height, frame count = sheet width / height -- confirmed by direct pixel
-- measurement, no fixed count/size: 12-102 frames, 38-123px, in this
-- batch, see sprite_frames.lua) at NATIVE resolution -- crop only, no
-- resize, so every frame's pixels are byte-identical to the source (a
-- same-size-rectangle GDI+ DrawImage copy needs no resampling). On-screen
-- size is set per species via battleScaleFront/battleScaleBack (a flat
-- 50% of that species' own native frame size -- see BASE_SPRITE_SCALE
-- below) instead of resampling pixels -- confirmed real, with tested
-- feet/bottom-pinned
-- placement math, via BattleState.lua's BATTLE_SCALE_DEFAULT/
-- resolveBattleScale (native Gen 1 front pics already draw at a scale
-- multiplier on their OWN resolution, back at a different one -- this is
-- not a mechanism invented for this mod). An earlier version of this file
-- resized every frame onto a uniform 56x56 canvas via bicubic
-- interpolation, which visibly lost detail on both up- and down-scaled
-- species -- corrected once this was checked against the real engine
-- source instead of assumed necessary.
--
-- Quad-based cropping straight from one never-touched sheet (the way
-- src/render/SpriteRenderer.lua handles overworld sprites) was considered
-- and rejected: BattleState:drawBattlerPic's other pic effects (substitute
-- doll, faint-sink slide, squish, blink, Dig's emerge-from-ground slide)
-- all assume battler.sprite's dimensions ARE exactly one pose -- handing
-- them a whole multi-frame sheet would break every one of those for our
-- species specifically. Per-frame files keep battler.sprite single-pose,
-- matching what the rest of the battle engine already assumes.
--
-- Two layers:
--   1. spriteFront/spriteBack (frame 001 of each sequence) -- the
--      engine's own confirmed-native static schema, used for anything
--      that isn't a live battle (Pokedex, party menu, etc).
--   2. A BattleState.update wrap that advances a per-battler frame index
--      during battle and swaps battler.sprite to the current frame's
--      loaded image -- directly adapted from kanto-ascendant's own
--      crystal_animation.lua (A.updateBattle/updateBattler), a real,
--      shipped implementation of exactly this pattern, not a guess:
--      same battle.showPlayerBack/battle.sendingOut/
--      battle.showEnemyTrainer/battle.enemySendingOut guard fields, same
--      elapsed-ms accumulator with a 50-iteration runaway guard, same
--      loadImage cache + nearest-neighbor filter. Multiple mods wrapping
--      BattleState.update independently is itself confirmed safe/
--      precedented (dynamax's own mod does it too, each guarded by its
--      own already-wrapped flag on the class).
--   Approximated: per-frame duration. The source sheets carry no timing
--   data at all, so every frame uses a flat 100ms -- not invented, this
--   is crystal_animation.lua's own confirmed fallback default
--   (`state.durations[state.frame] or 100`) for exactly this situation.
--
-- Asset-pack toggle/extension point, same shape as Phase 3's Gigantamax
-- art (see installGmaxAssetPacks): mod.exports.registerSpriteAssetPack
-- lets a future pack supply its own static sprite AND its own animation
-- (frameCounts + a framePath resolver); mod.exports.setActiveSpriteAssetPack
-- picks which is live. Static fields are core registration fields (not
-- late-bound), so switching packs re-patches every species, same as
-- reapplying learnsets in Phase 2 -- reapplySpritePacks() runs at load and
-- again on save.loaded.
local FRAME_DURATION_MS = 100

local function builtinFramePath(mod, side, speciesId, frame)
  return mod.path .. "/assets/" .. side .. "/" .. speciesId .. ("/%03d.png"):format(frame)
end

-- GalarGmaxDex owns sprite sizing outright: every species loads at a flat
-- 50% of its OWN native/base asset resolution -- not normalized against a
-- shared target size the way TARGET_PIC_SIZE used to work, so species
-- with bigger native art stay proportionally bigger on screen than
-- species with smaller native art, exactly as their own source sheets
-- were drawn. A single scalar multiplier per side (battleScaleFront/Back
-- both = 0.5), applied identically to width and height, so aspect ratio
-- is preserved by construction -- and nearest-neighbor filtered (set per
-- image in installSpriteAnimation), so the smaller size stays crisp pixel
-- art instead of picking up jagged/aliased edges. This is a resize of the
-- SCALE FIELD the engine multiplies native art by at draw time, not a
-- pixel resample -- no image data is touched or degraded, only the
-- on-screen footprint. A flat constant is always within the schema's own
-- confirmed battleScaleFront/Back bound (f.numRange(0.25, 4.0)) for every
-- species, unconditionally -- no per-species clamp needed.
--
-- Dynamax's own grow/shrink sequence (dynamax/main.lua) only ever
-- multiplies its own factor on top of whatever scale it's handed here --
-- it has no awareness of what that baseline represents (a fixed target, a
-- percentage of native size, anything else) and needs none. This mod
-- owns the resting size; dynamax owns growing and shrinking it.
local BASE_SPRITE_SCALE = 0.7

local function installSpriteAssetPacks(mod, spritePackRosterFull, frameCounts, nativeVanillaSpecies)
  local packs = {}
  local isNativeVanilla = {}
  for _, id in ipairs(nativeVanillaSpecies or {}) do isNativeVanilla[id] = true end
  local activePackId = "sliced_v1"

  packs.sliced_v1 = function(speciesId)
    local counts = frameCounts[speciesId]
    if not counts then return nil end
    return {
      spriteFront = builtinFramePath(mod, "front", speciesId, 1),
      spriteBack = builtinFramePath(mod, "back", speciesId, 1),
      frontSize = 7,
      battleScaleFront = BASE_SPRITE_SCALE,
      battleScaleBack = BASE_SPRITE_SCALE,
      frameCounts = counts,
      framePath = function(side, frame) return builtinFramePath(mod, side, speciesId, frame) end,
    }
  end

  mod.exports.registerSpriteAssetPack = function(packId, resolverFn)
    packs[packId] = resolverFn
  end
  mod.exports.setActiveSpriteAssetPack = function(packId)
    activePackId = packId
  end

  local function resolveRaw(speciesId)
    local resolver = packs[activePackId] or packs.sliced_v1
    return resolver(speciesId) or packs.sliced_v1(speciesId)
  end

  -- Real existence check, not just "did frameCounts have an entry" --
  -- confirmed real gap: frameCounts/sprite_pack_roster_full.lua are
  -- generated-at-slicing-time data, true only when assets/front|back/
  -- were last regenerated, not a live guarantee the PNGs are still on
  -- disk. A public build that ships this mod's code without its real
  -- sprite pack (asset-free release, this session) would otherwise
  -- commit dead paths straight into the registry with nothing catching
  -- it. love.filesystem is gone entirely from the mod sandbox as of
  -- gen1recomp's Aug 2026 "grandmas kitchen" release -- confirmed (via
  -- overworld_spawns.lua's own read of that branch's src/mods/Sandbox.lua)
  -- that merely READING the .filesystem field off love throws, so a
  -- love.filesystem.getInfo attempt here was never going to reach its own
  -- pcall's protection; dropped entirely rather than attempted-then-
  -- caught. Sole check is now the same proven pattern already used
  -- elsewhere in this exact codebase (overworld_spawns.lua's own
  -- pcall(love.graphics.newImage, path)) -- love.graphics itself is
  -- unaffected by the sandbox, only love.filesystem/thread/system/event.
  -- Cached by path: installSpriteAnimation's own per-battler update loop
  -- calls mod.exports.resolveSpritePack every advancing frame (advance ->
  -- updateBattler, up to 60x/sec per active battler), not just once at
  -- registration -- an uncached check here would be a real per-frame I/O
  -- cost, not a one-off. A path's existence can't change mid-session
  -- under normal play, so a permanent cache is safe (matches the same
  -- never-invalidated imageCache pattern installSpriteAnimation's own
  -- loadImage already uses for the actual frame loads).
  local existsCache = {}
  local function spriteFileExists(path)
    if type(path) ~= "string" or path == "" then return false end
    local cached = existsCache[path]
    if cached ~= nil then return cached end
    local okImg, img = pcall(love.graphics.newImage, path)
    local result = okImg and img ~= nil
    existsCache[path] = result
    return result
  end

  -- The checked resolver every caller (static registration below, and
  -- installSpriteAnimation's live per-frame lookup via the export) should
  -- use -- returns nil (same as "this pack has nothing for this species")
  -- whenever the resolved front/back files don't actually exist, so every
  -- existing "resolve(id) or <fallback>" call site downstream degrades
  -- correctly with no other change needed.
  local function resolve(speciesId)
    local sprite = resolveRaw(speciesId)
    if not sprite then return nil end
    if spriteFileExists(sprite.spriteFront) and spriteFileExists(sprite.spriteBack) then
      return sprite
    end
    return nil
  end
  mod.exports.resolveSpritePack = resolve

  -- national_dex's own README is explicit: it ships NO Pokemon artwork at
  -- all, only two 922-byte flat-grey "?" placeholders (assets/sets/
  -- placeholder/front.png and .../back.png) -- species beyond the cart's
  -- native roster show that placeholder unless the player has their own
  -- sprite pack (e.g. universal_sprites) installed to fill it in. Not
  -- something this mod can distinguish "real art" from "placeholder"
  -- except by path -- so isPlaceholder below is a path check, not
  -- foolproof forever, but accurate against the one convention that
  -- exists today.
  local function isPlaceholder(path)
    return type(path) ~= "string" or path == "" or path:find("/placeholder/", 1, true) ~= nil
  end

  -- Layer 0: a genuinely generic "no art available" placeholder (id
  -- "000"), referenced by raw path (not a registry lookup) -- the
  -- absolute last resort whenever resolve() above returns nothing at all
  -- for a species, INCLUDING the case where the real files are simply
  -- missing (a public, asset-free release of this mod, explicit user
  -- decision this session -- players supply their own art via national_dex
  -- or another sprite pack; this mod ships no bundled Pokemon art). Was
  -- previously real PICHU art (an earlier, narrower "layer 0 failsafe"
  -- call), then briefly a direct copy of national_dex's own placeholder
  -- art -- that copy is confirmed to crash on mobile (root cause not
  -- chased down; explicit user call was to replace it outright rather
  -- than debug it). assets/front|back/000/001.png are now a minimal,
  -- self-generated 16x16 white square with a black X, deliberately the
  -- simplest possible valid PNG (a plain uncompressed bitmap via
  -- System.Drawing, no unusual palette/interlacing/metadata) to remove
  -- whatever about the national_dex asset's own format was mobile-hostile.
  local PLACEHOLDER_FAILSAFE = {
    spriteFront = builtinFramePath(mod, "front", "000", 1),
    spriteBack = builtinFramePath(mod, "back", "000", 1),
    frontSize = 7,
    battleScaleFront = BASE_SPRITE_SCALE,
    battleScaleBack = BASE_SPRITE_SCALE,
  }

  -- Sprite priority, explicit user spec (this session):
  --   1 (highest). Any other mod's real sprite for the id.
  --   2. national_dex's own real sprite -- ONLY for ids national_dex
  --      itself added beyond the cart's native roster -- when NATIONAL
  --      DEX SPRITES is on; also the fallback for a THIRD mod's missing
  --      coverage on those same ids.
  --   3. This mod's own bundled pack.
  --   4. The cart's own native sprite (vanilla-native ids only -- this
  --      mod's pack always wins over it, never the reverse).
  --   5 (lowest). PLACEHOLDER_FAILSAFE (generic "000" art, or missing
  --      real files for an id resolve() would otherwise have covered).
  --
  -- Confirmed bug, fixed here: the previous version treated ANY existing
  -- real (non-placeholder) sprite -- tier 2 national_dex OR tier 4 plain
  -- vanilla, no distinction -- as reason to skip our own patch whenever
  -- NATIONAL DEX SPRITES was on (its default). That's correct for tier 2
  -- but backwards for tier 4: a vanilla-native id (e.g. Gen 2's own
  -- Cyndaquil) already ships a real native sprite, so it was always
  -- treated as "already covered" and our own art for it never applied --
  -- tier 3 never actually got to beat tier 4 the way it's supposed to.
  -- native_vanilla_species.lua (Kanto+Johto, 251 ids -- same source/
  -- methodology Phase 1's own generator already used to classify these
  -- exact ids) is what lets deferToExisting only fire for the genuinely
  -- higher-priority case (a non-native id, i.e. one national_dex itself
  -- contributed) instead of every id that merely already has SOME real
  -- sprite.
  --
  -- Known, stated gap (not silently glossed over): tier 1 (a genuine
  -- OTHER mod's sprite) isn't independently detected -- there's no signal
  -- available here to distinguish "national_dex set this" from "some
  -- third mod set this" for a non-native id, so both are deferred to
  -- alike (correct either way, since both outrank tier 3), and a third
  -- mod's sprite on a NATIVE id would incorrectly still be overridden by
  -- our own pack (no baseline to compare native's own sprite against).
  -- Separately, explicit user call this session: national_dex's own
  -- sprites aren't being correctly consumed at all right now (a real,
  -- known bug) -- deferred, not fixed here.
  mod.exports.reapplySpritePacks = function()
    local patched = 0
    local ndexOn = mod.options:get("national_dex_sprites") ~= "false"
    for _, id in ipairs(spritePackRosterFull) do
      local current = mod.content.pokemon:get(id)
      local hasRealSprite = current
        and not isPlaceholder(current.spriteFront) and not isPlaceholder(current.spriteBack)
      local deferToExisting = hasRealSprite and ndexOn and not isNativeVanilla[id]
      -- Confirmed real gap, caught reasoning through the asset-free
      -- (Gen9Dex) case: a vanilla-native species with no real bundled art
      -- of our own (an asset-free build, or simply not one of ours) used
      -- to fall straight to PLACEHOLDER_FAILSAFE below once resolve()
      -- came back nil, CLOBBERING vanilla's own perfectly good native
      -- sprite with a generic "?" placeholder -- strictly worse art than
      -- what was already there. deferToExisting only ever gated the
      -- national_dex case (tier 2); it never asked "is there already
      -- real art of ANY kind worth leaving alone." skipEntirely covers
      -- that second, general case: we have nothing of our own to offer
      -- AND something real already exists, so don't touch this id at
      -- all -- not even the placeholder.
      local skipEntirely = false
      local sprite = nil
      if not deferToExisting then
        sprite = resolve(id)
        skipEntirely = not sprite and hasRealSprite
      end
      if deferToExisting or skipEntirely then
        -- nothing to do: either national_dex's real sprite already wins
        -- (tier 2), or we have nothing of our own and something real is
        -- already in place (tier 4, left untouched).
      else
        sprite = sprite or PLACEHOLDER_FAILSAFE
        mod.content.pokemon:patch(id, {
          spriteFront = sprite.spriteFront, spriteBack = sprite.spriteBack,
          frontSize = sprite.frontSize,
          battleScaleFront = sprite.battleScaleFront, battleScaleBack = sprite.battleScaleBack,
          -- Confirmed real bug, root-caused via a live screenshot: any
          -- vanilla-native species (dex 1-251) our pack now reaches shows
          -- as a hollow/outline mangled mess -- the engine's own GBC/SGB
          -- palette-recolor pass, which vanilla's own indexed-palette ROM
          -- art is DESIGNED to go through, was being applied to our real
          -- full-color PNG frames too, since trueColor was never set on
          -- the patch. national_dex-sourced species (739 of Phase 1's
          -- roster) already carry trueColor=true from national_dex's own
          -- registration, so a species-agnostic patch never touched their
          -- flag and they looked fine -- only the 251 native-vanilla
          -- species, whose OWN registration leaves trueColor unset/false,
          -- were affected. This bug was latent until the priority fix
          -- above first let our pack actually reach native-vanilla species
          -- at all. Already an established, real field in this codebase
          -- for exactly this purpose -- installOverworldSpriteProvider's
          -- own ourDef() sets the identical trueColor=true on its own
          -- real-color art.
          trueColor = true,
        })
        patched = patched + 1
      end
    end
    return patched
  end

  local patched = mod.exports.reapplySpritePacks()
  mod.events:on("save.loaded", function() mod.exports.reapplySpritePacks() end)
  -- DRAMATIC_SHAPE's own 3D-BTL row is changeable mid-session (its
  -- OverworldBattle.lua notes it's "reachable from the mod manager's page
  -- mid-session"), so the classic-mode scale picked above can go stale
  -- while the game keeps running, not just between loads. mod.options_changed
  -- is a real, general engine event (confirmed: DRAMATIC_SHAPE's own
  -- main.lua listens for it too) -- re-running on every firing rather than
  -- trying to filter for this one specific option is simpler and still
  -- cheap enough (one registry patch per registered species -- this used
  -- to mean 51, now the full national_dex catalogue, still a one-off pass
  -- over plain table lookups, not per-frame work).
  mod.events:on("mod.options_changed", function() mod.exports.reapplySpritePacks() end)
  return patched
end

-- =============================================================================
-- Direct draw-time ownership of resting scale
-- =============================================================================
-- The registry patch above (battleScaleFront/Back via reapplySpritePacks)
-- is the schema-documented way to set a species' resting battle scale, and
-- it folds into data.pokemon[id] correctly by construction -- but it
-- depends on registry merge timing that this mod cannot directly observe
-- at runtime. BattleState.resolveBattleScale (src/battle/BattleState.lua)
-- is the actual, single choke point every front/back draw call reads
-- through every frame -- the enemy's send-out, the player's send-out,
-- every resting frame after, mid-battle switches, and the base `s` that
-- dynamax's own grow/shrink factor multiplies on top of (dynamax reads
-- this same value via the `scale` param it's handed, per the comment on
-- BASE_SPRITE_SCALE above). Wrapping that one function -- the same way
-- dynamax itself wraps BattleState.drawBattlerPic -- makes this mod's
-- resting scale unconditional at the exact spot it is consumed, with no
-- dependency on patch/merge ordering: for our species it always returns
-- restScale; every other species (and the non-species trainer pics) falls
-- through to vanilla behavior, image-level battle_sprite_scales override
-- included, untouched.
local function installRestingScaleOverride(mod, spritePackRosterFull, restScale)
  local BattleState = require("src.battle.BattleState")
  if BattleState.__galarGmaxDexScaleWrapped then return end
  BattleState.__galarGmaxDexScaleWrapped = true

  local ours = {}
  for _, id in ipairs(spritePackRosterFull) do ours[id] = true end

  local vanillaResolveBattleScale = BattleState.resolveBattleScale
  function BattleState.resolveBattleScale(data, side, path, species)
    if species and ours[species] then
      return restScale
    end
    return vanillaResolveBattleScale(data, side, path, species)
  end
end

-- =============================================================================
-- Gen 2 battle sprite position fix (front and back)
-- =============================================================================
-- Confirmed by direct source read (src/ui/gen2/BattleState.lua:563-635,
-- drawPic): position is computed from the image's RAW, unscaled pixel
-- dimensions against fixed box constants (enemy 56x56 at (96,0), player
-- 48x48 at (16,48)), clamped so an oversized image pins to the box's
-- corner -- THEN battleScaleFront/Back is applied as a symmetric shrink
-- AROUND that already-wrong anchor point. For an image taller than the
-- box (this mod's own battle art runs up to 123px/frame, vs vanilla's
-- own largest sprite, Onix, at exactly 56x56 -- the box's real max), the
-- math reduces algebraically to the bottom edge landing at y = h (the
-- image's own raw height) regardless of scale -- no battleScaleFront/
-- Back value can pull it back into the box through that mechanism alone.
-- picScale/battleScaleFront/Back themselves resolve correctly (same
-- field names, same data.pokemon registry Gen 1 uses, confirmed no
-- Gen-2-renamed key here unlike encounters/sprites elsewhere) -- the bug
-- is purely drawPic's own position math, not this mod's registration.
--
-- Fix: wrap drawPic for our own species only, computing the CORRECT
-- box-relative position (bottom edge + horizontal center pinned to the
-- box using the ALREADY-SCALED size -- matching what Gen 1's own
-- frontPlacement/backPlacement comments describe as the actual intent),
-- then applying the delta between that and whatever native would have
-- computed as a love.graphics.translate around an otherwise completely
-- unmodified call to native drawPic -- so palette/trueColor/hidden/
-- vanish/trainer-swap/slide-animation handling inside drawPic (not
-- reimplemented here) are never touched, only the position is
-- corrected. Any non-roster species, or a roster species whose image
-- already fits the box (delta == 0), is a pure passthrough with no
-- behavior change.
local function installGen2BattlePicPositionFix(mod, spritePackRosterFull)
  local ok, Gen2BattleState = pcall(require, "src.ui.gen2.BattleState")
  if not ok or type(Gen2BattleState) ~= "table" then
    mod.log:warn("galar_gmax_dex: gen2 battle pic position fix: src.ui.gen2.BattleState not available: %s",
      tostring(Gen2BattleState))
    return
  end
  if Gen2BattleState.__galarPicPositionWrapped then return end
  Gen2BattleState.__galarPicPositionWrapped = true

  local ours = {}
  for _, id in ipairs(spritePackRosterFull) do ours[id] = true end

  local nativeDrawPic = Gen2BattleState.drawPic
  function Gen2BattleState:drawPic(mon, back)
    local species = mon and mon.species
    if not (species and ours[species]) then
      return nativeDrawPic(self, mon, back)
    end
    local image, _, path = self:pic(mon, back)
    if not image then
      return nativeDrawPic(self, mon, back)
    end
    local w, h = image:getDimensions()
    local scale = self:picScale(path, mon, back)
    local ex, ey, box
    if back then
      ex, ey, box = Gen2BattleState.PLAYER_PIC_TILE_X * 8, Gen2BattleState.PLAYER_PIC_TILE_Y * 8,
        Gen2BattleState.PLAYER_PIC_TILES * 8
    else
      ex, ey, box = Gen2BattleState.ENEMY_PIC_TILE_X * 8, Gen2BattleState.ENEMY_PIC_TILE_Y * 8,
        Gen2BattleState.ENEMY_PIC_TILES * 8
    end
    -- Replicates native's own unscaled-then-shrink math exactly, so we
    -- know what it will actually draw at, then computes what SHOULD
    -- have been drawn (bottom + horizontal center pinned to the box,
    -- using the already-scaled size), and offsets by the delta.
    local nativePx = back and (ex + math.floor((box - w) / 2))
      or (ex + math.max(0, math.floor((box - w) / 2)))
    local nativePy = back and (ey + (box - h)) or (ey + math.max(0, box - h))
    if scale ~= 1 then
      nativePx = nativePx + math.floor(w * (1 - scale) / 2)
      nativePy = nativePy + math.floor(h * (1 - scale))
    end
    local correctPx = ex + (box - w * scale) / 2
    local correctPy = ey + (box - h * scale)
    local dx, dy = correctPx - nativePx, correctPy - nativePy
    if dx == 0 and dy == 0 then
      return nativeDrawPic(self, mon, back)
    end
    love.graphics.push()
    love.graphics.translate(dx, dy)
    local drawOk, err = pcall(nativeDrawPic, self, mon, back)
    love.graphics.pop()
    if not drawOk then
      mod.log:warn("galar_gmax_dex: gen2 drawPic position fix failed for %s: %s",
        tostring(species), tostring(err))
    end
  end

  mod.log:info("galar_gmax_dex: gen2 battle sprite position fix installed")
end

-- =============================================================================
-- Player sprite side selection -- front vs back artwork
-- =============================================================================
-- Which artwork (front-view vs back-view frames) to load into the
-- player's animated battler sprite -- NOT placement: self.player always
-- draws through BattleState.backPlacement regardless of which artwork is
-- shown (confirmed by reading drawPicsLayer directly), so this only ever
-- picks which frames go into battler.sprite.
--
-- Reverted to reading DRAMATIC_SHAPE directly, self-contained: dynamax's
-- own BACK SPRITE toggle (a separate, non-G-Max/Max-Move addition) was
-- removed when dynamax's own drawing logic was reverted to its original
-- form per explicit user request, so this no longer depends on dynamax's
-- exports at all. With DRAMATIC_SHAPE's BACK SPRITES option off (and
-- 3D-BTL on), the player's own Pokemon stands out in the 3D/map scene
-- facing the foe instead of sitting in the classic 2D back-sprite menu
-- slot -- confirmed via OverworldBattle.textures(): when backPinned() is
-- false it builds a world-standing texture for the player side instead of
-- drawing the pinned 2D pic. Reached the same read-only way dynamax's own
-- mod reaches DRAMATIC_SHAPE (mod.find + exports.lib V.require loader),
-- fully pcall-guarded: any failure (mod absent, a future version
-- renaming/removing these functions) falls back to the pre-existing
-- behavior (always back for the player), not a crash.
local function installPlayerSpriteSide(mod)
  local overworldBattle
  -- Cache a successful resolution permanently; keep retrying on failure
  -- (mod absent this call, or just not loaded yet -- mod load order
  -- relative to this one isn't guaranteed) rather than latching a false
  -- negative from one early call.
  local function resolve()
    if overworldBattle then return overworldBattle end
    pcall(function()
      local dramaticShape = mod.find("DRAMATIC_SHAPE")
      local V = dramaticShape and dramaticShape.exports and dramaticShape.exports.lib
      overworldBattle = V and V.require("OverworldBattle")
    end)
    return overworldBattle
  end

  return {
    -- true only when DRAMATIC_SHAPE is installed, its staged-battle mode is
    -- on, and its BACK SPRITES row is off -- i.e. the player's mon should be
    -- shown front-facing this tick, not in the classic back-sprite slot.
    wantsPlayerFront = function()
      local ob = resolve()
      if not ob then return false end
      local ok, wantsFront = pcall(function()
        return ob.enabled() and not ob.backPinned()
      end)
      return ok and wantsFront or false
    end,
  }
end

local function installSpriteAnimation(mod, playerSpriteSide)
  local BattleState = require("src.battle.BattleState")
  if BattleState.__galarSpriteAnimWrapped then return end
  BattleState.__galarSpriteAnimWrapped = true

  local imageCache = {}
  local function loadImage(path)
    if imageCache[path] then return imageCache[path] end
    if not (love and love.graphics and love.graphics.newImage) then return nil end
    local ok, image = pcall(love.graphics.newImage, path)
    if not (ok and image) then return nil end
    -- Nearest-neighbor, not the Love2D default (linear/smoothed): keeps
    -- pixel art crisp at any draw scale, most visibly during Dynamax's own
    -- grow animation (drawBattlerPic's love.graphics.scale(factor,factor)
    -- on top of whatever battler.sprite currently is) -- confirmed no
    -- global love.graphics.setDefaultFilter exists anywhere in engine boot
    -- (checked), so every image is linear-filtered unless set individually
    -- per image, same as TileRenderer.lua's own confirmed per-image
    -- nearest calls -- this mod follows that established per-image
    -- convention rather than changing the engine-wide default.
    if image.setFilter then image:setFilter("nearest", "nearest") end
    imageCache[path] = image
    return image
  end

  local function updateBattler(battler, side)
    -- battler.mon wins when present (Gen 1's real shape: battle.player/
    -- .enemy are battler WRAPPERS around a mon, confirmed via
    -- src/battle/BattleState.lua). Gen 2 has no such wrapper -- confirmed
    -- directly (src/battle/gen2/Battle.lua's own comment: "`battler` is
    -- the mon itself here: Gen 2's engine has no battler wrapper") -- so
    -- battle.player/.enemy there ARE the mon already, and this falls
    -- through to `battler` itself. Zero change for Gen 1 (.mon is always
    -- present and always wins); newly correct for Gen 2, which previously
    -- read battler.mon as nil here and silently no-opped every call.
    local mon = battler and (battler.mon or battler)
    local speciesId = mon and mon.species
    local sprite = speciesId and mod.exports.resolveSpritePack(speciesId)
    local total = sprite and sprite.frameCounts and sprite.frameCounts[side]
    if not (total and total > 1) then
      battler.__galarAnim = nil
      return
    end
    local state = battler.__galarAnim
    if not state or state.species ~= speciesId or state.side ~= side then
      state = { species = speciesId, side = side, frame = 1, elapsed = 0 }
      battler.__galarAnim = state
      -- Assign frame 1 through our own nearest-filtered cache immediately,
      -- not on the first natural frame-advance tick (up to FRAME_DURATION_MS
      -- later): before this, battler.sprite would still be whatever the
      -- engine's own native spriteFront/spriteBack load produced, which is
      -- NOT nearest-filtered (that load path isn't ours to hook), so a
      -- Dynamax grow triggered in that brief window would scale up the
      -- blurrier native image instead.
      local image = loadImage(sprite.framePath(side, 1))
      if image then battler.sprite = image end
    end
    return state, sprite, total
  end

  -- dt arrives from the engine's fixed logic step -- a game-speed/fast-
  -- forward mechanism feeds FixedStep dt*speed, so accumulating raw dt
  -- would make sprite cycling play N times faster at N times game speed
  -- (confirmed: reported live, sprite cycling visibly speeding up with
  -- game speed). Fix studied directly from
  -- crystal_animated_sprites_with_shiny_visuals's own logicToReal helper
  -- (that mod's main.lua:76-90) -- same technique: divide by the real,
  -- native Game:logicSpeed() (src/core/Game.lua:241, cross-generation,
  -- has its own Gen2Compat translation) to convert logic-step dt back
  -- into real elapsed time, so sprite cycling always plays at 1x real
  -- speed regardless of game speed. Deliberately scoped to ONLY this
  -- animation-frame timer -- nothing else in this file reads dt, and nothing
  -- about actual game logic speed changes.
  local function logicToReal(dt, game)
    local speed = 1
    if game and type(game.logicSpeed) == "function" then
      speed = game.logicSpeed(game) or 1
    end
    speed = tonumber(speed) or 1
    if speed <= 0 then speed = 1 end
    return (tonumber(dt) or (1 / 60)) / speed
  end

  local function advance(battler, side, dt, game)
    local state, sprite, total = updateBattler(battler, side)
    -- TEMP DIAGNOSTIC (Gen 2 animation debug, remove once confirmed working):
    -- fires once per updateBattler call where state never even got created
    -- (total <= 1 or resolveSpritePack came back nil) -- tells us if the
    -- chain breaks THIS early (never even tries to animate) vs later.
    if not state and mod.__galarAnimDebugOnce ~= (battler and battler.species) then
      mod.__galarAnimDebugOnce = battler and battler.species
      local sp = battler and battler.species and mod.exports.resolveSpritePack(battler.species)
      mod.log:info("galar_gmax_dex: ANIM DEBUG no-state for species=%s side=%s frameCounts=%s",
        tostring(battler and battler.species), tostring(side),
        tostring(sp and sp.frameCounts and sp.frameCounts[side]))
    end
    if not state then return end
    state.elapsed = state.elapsed + logicToReal(dt, game) * 1000
    local changed, guard = false, 0
    while state.elapsed >= FRAME_DURATION_MS and guard < 50 do
      state.elapsed = state.elapsed - FRAME_DURATION_MS
      state.frame = state.frame + 1
      if state.frame > total then state.frame = 1 end
      changed, guard = true, guard + 1
    end
    if changed then
      local image = loadImage(sprite.framePath(side, state.frame))
      if image then battler.sprite = image end
      -- TEMP DIAGNOSTIC: confirms frame-advancing IS happening at all.
      mod.log:info("galar_gmax_dex: ANIM DEBUG frame advance species=%s side=%s frame=%d/%d",
        tostring(state.species), tostring(side), state.frame, total)
    end
  end

  -- Base-engine pic effects (BattleState.lua's real drawBattlerPic: faint-
  -- slide, bounce, squish, Dig's emerge-slide, and any effect carrying an
  -- ox/oy displacement) compute a partial-quad reveal window FROM THE
  -- CURRENTLY DRAWN IMAGE'S OWN WIDTH/HEIGHT each frame (e.g. faint-slide's
  -- `visible = img:getHeight() - floor(off/scale)`, Dig's emerge
  -- `visible = floor(h*step/7)`) -- they assume that size stays constant
  -- for the effect's whole duration, since the base engine's own sprites
  -- never change mid-effect. This mod's animation does the opposite on
  -- purpose (swaps battler.sprite to a new frame file every ~100ms), and
  -- different frames of the same species are NOT guaranteed to share
  -- identical cropped dimensions (sprite_frames.lua's own crop-per-frame
  -- convention, confirmed by direct measurement to vary within a species,
  -- not just across them). A frame swap landing mid-effect changes what
  -- img:getWidth()/getHeight() the reveal math sees, independent of the
  -- effect's own progress -- read as a leg (or other extremity nearest an
  -- edge) flickering or momentarily vanishing, matching exactly what was
  -- reported. Fixed by freezing the frame timer -- not resetting it, not
  -- catching it back up, just not accumulating -- for any battler with an
  -- active pic effect right now, so battler.sprite's size can never change
  -- out from under one of these reveals; it resumes cycling normally the
  -- instant the effect ends. fxFaintActive is a separate, older mechanism
  -- from picFx (confirmed via BattleState.lua: checked before picFx even
  -- applies) with the exact same size-dependent shape, so it's checked too.
  local function shouldPauseAnim(self, battler)
    local faintOk, faintActive = pcall(function() return self:fxFaintActive(battler) end)
    if faintOk and faintActive then return true end
    local pf = self.picFx and self.picFx[battler]
    if not pf then return false end
    return pf.fade ~= nil or pf.kind ~= nil or pf.hidden or pf.minimized
      or (pf.ox or 0) ~= 0 or (pf.oy or 0) ~= 0
  end

  -- Exposed (see mod.exports.advanceBattleSprites below) so OTHER
  -- GalarGmaxDex files that freeze their own slice of BattleState:update
  -- for an overlay of their own (the gimmick ring, the Gigantamax grow/
  -- shrink sequence) can keep sprite frame-cycling running independently
  -- instead of it silently stopping for as long as their overlay owns the
  -- frame -- confirmed live: both did exactly that before this existed.
  --
  -- gameOverride: optional 3rd arg, additive, existing 2-arg callers
  -- unaffected. Gen 1's own "battle" here IS the BattleState UI instance
  -- (battle.game already a real field, confirmed -- this is how the
  -- feature worked at all before Gen 2 existed), but Gen 2's callers pass
  -- the pure src.battle.gen2.Battle object, which carries no .game field
  -- of its own at all (checked directly, no match) -- without an
  -- override, logicToReal's game-speed-up protection -- the actual point
  -- of this whole feature -- would silently do nothing on Gen 2 even with
  -- every other piece wired correctly. Gen 2 callers pass their own
  -- Gen2BattleState UI instance's .game (self.game) here instead.
  --
  -- forcePause: optional 4th arg, additive, same reasoning. shouldPauseAnim
  -- itself is deliberately untouched (its self:fxFaintActive/self.picFx
  -- checks are Gen 1 BattleState concepts that simply don't exist on a
  -- pure Gen 2 Battle object -- confirmed no match for either name
  -- anywhere in src/battle/gen2/Battle.lua -- so for a Gen 2 battle that
  -- check already silently answers false always, a dead check rather than
  -- a wrong one). Gen 2 has the exact same size-dependent-reveal
  -- fragility shouldPauseAnim exists to guard against (src/ui/gen2/
  -- BattleState.lua's own BattleState:drawPic reads image:getDimensions()
  -- fresh every frame for its own resize/slide effect math, same pattern
  -- that caused Gen 1's leg-flickering bug), just tracked under a
  -- different name (self.anim on the Gen2BattleState UI instance, not the
  -- pure Battle object either) -- so its caller passes that in directly
  -- instead of this function needing to know Gen 2's shape.
  local function advanceBattleSprites(battle, dt, gameOverride, forcePause)
    if mod.options:get("animated_battle_sprites") == "false" then return end
    local game = gameOverride or battle.game
    if battle.player and not battle.showPlayerBack and not battle.sendingOut
        and not forcePause and not shouldPauseAnim(battle, battle.player) then
      local playerSide = playerSpriteSide.wantsPlayerFront() and "front" or "back"
      advance(battle.player, playerSide, dt, game)
    end
    if battle.enemy and not battle.showEnemyTrainer and not battle.enemySendingOut
        and not forcePause and not shouldPauseAnim(battle, battle.enemy) then
      advance(battle.enemy, "front", dt, game)
    end
  end
  mod.exports.advanceBattleSprites = advanceBattleSprites

  local vanillaUpdate = BattleState.update
  function BattleState:update(dt)
    local result = vanillaUpdate(self, dt)
    advanceBattleSprites(self, dt)
    return result
  end

  local function clearAnim(battle)
    if not battle then return end
    if battle.player then battle.player.__galarAnim = nil end
    if battle.enemy then battle.enemy.__galarAnim = nil end
  end
  mod.events:on("battle.battler_switched", function(ev) clearAnim(ev and ev.battle) end)
  mod.events:on("battle.ended", function(ev) clearAnim(ev and ev.battle) end)

  -- Gen 2 render-side hookup -- IMPERATIVE this stays additive-only, never
  -- touching how Gen 1 or the existing static registration already work.
  -- Confirmed by direct source read (src/ui/gen2/BattleState.lua):
  -- Gen 2 has NO per-battler mutable .sprite field its own draw code ever
  -- reads. BattleState:pic(mon, back) resolves def.spriteFront/spriteBack
  -- FRESH from the species registration on every single draw call
  -- (BattleState:drawPic calls self:pic every frame), through the
  -- "pokemon.sprite" hook -- the exact same hook name/ctx shape Gen 1's
  -- own src/pokemon/Sprites.lua:path uses, per that function's own
  -- comment: "one subscription reskins both games". So the battler.sprite
  -- mutation updateBattler/advance already do above is INERT for Gen 2 --
  -- harmless (confirmed no existing Gen 2 mon-record field named "sprite"
  -- it could collide with: checked src/pokemon/Pokemon.lua and
  -- src/battle/gen2/Battle.lua directly, neither references one) but does
  -- nothing on screen by itself. This hook is what actually makes Gen 2
  -- show it: given the SAME per-mon state updateBattler/advance already
  -- maintain (battler.__galarAnim -- Gen 2's battler IS the mon, no
  -- wrapper, per the fix just above), it returns that state's current
  -- frame's path instead of the default whenever one is tracked --
  -- leaving ctx.trueColor (what actually gates GBC palette remapping --
  -- the exact regression risk this whole feature was flagged against)
  -- completely untouched, never read or written here at all.
  --
  -- Gated behind isGen2Boot so this hook is never even REGISTERED on a
  -- Gen 1 boot -- not just inert, structurally absent -- zero interaction
  -- with Gen 1's existing, already-shipped animation path. Further scoped
  -- tight even on Gen 2: ctx.kind == "battle" only (this same hook also
  -- answers Pokedex/party/summary-screen calls for their own static,
  -- non-animated resolution -- never touch those), and the tracked
  -- state's own species+side must match what's actually being asked for
  -- right now, so a stale or switched-out state can never leak onto the
  -- wrong pic. Any failure pcalls back to the untouched default path,
  -- same fail-open convention as every other resolver in this file.
  local GameVersion = require("src.core.GameVersion")
  local isGen2Boot = GameVersion.generation(GameVersion.get()) == 2
  -- TEMP DIAGNOSTIC (Gen 2 animation debug, remove once confirmed working)
  mod.log:info("galar_gmax_dex: ANIM DEBUG installSpriteAnimation reached hook section, isGen2Boot=%s",
    tostring(isGen2Boot))
  if isGen2Boot then
    mod.log:info("galar_gmax_dex: ANIM DEBUG registering pokemon.sprite hook")
    mod.hooks:wrap("pokemon.sprite", function(next, path, ctx)
      local ok, framePath = pcall(function()
        if not (ctx and ctx.kind == "battle" and ctx.mon) then return nil end
        local state = ctx.mon.__galarAnim
        -- TEMP DIAGNOSTIC: throttled to once per distinct (species,side,
        -- reason) so a real battle doesn't spam thousands of lines.
        local function dbg(reason)
          local key = tostring(ctx.species) .. "|" .. tostring(ctx.side) .. "|" .. reason
          mod.__galarSpriteHookDebug = mod.__galarSpriteHookDebug or {}
          if mod.__galarSpriteHookDebug[key] then return end
          mod.__galarSpriteHookDebug[key] = true
          mod.log:info("galar_gmax_dex: ANIM DEBUG hook species=%s side=%s -> %s",
            tostring(ctx.species), tostring(ctx.side), reason)
        end
        if not (state and state.frame and state.frame > 1) then
          dbg("no-state-or-frame1 (state=" .. tostring(state ~= nil)
            .. " frame=" .. tostring(state and state.frame) .. ")")
          return nil
        end
        if state.species ~= ctx.mon.species or state.side ~= ctx.side then
          dbg("mismatch (state.species=" .. tostring(state.species) .. " state.side="
            .. tostring(state.side) .. ")")
          return nil
        end
        local sprite = mod.exports.resolveSpritePack(state.species)
        if not (sprite and sprite.framePath) then
          dbg("no-resolveSpritePack")
          return nil
        end
        dbg("OVERRIDE frame " .. tostring(state.frame))
        return sprite.framePath(state.side, state.frame)
      end)
      return next((ok and framePath) or path, ctx)
    end)
  end

  -- animated_battle_sprites is defined once, for the whole mod, in
  -- options.lua (loaded/defined by installDebugOptions) -- see that
  -- function's own comment for why a second mod.options:define() call
  -- here would silently wipe out every other option.
end

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

-- =============================================================================
-- Overworld sprite provider for Wilds of Kanto (overworld_wild_spawns)
-- =============================================================================
-- Wilds of Kanto's own best-quality "pokemmo" walker tier goes through the
-- real engine's SpriteRenderer, which is hard-locked to 16x16 pixels per
-- frame (src/render/SpriteRenderer.lua: love.graphics.newQuad(0, f*16, 16,
-- 16, iw, ih), not a mod convention) -- Wilds' own bundled art gets resampled
-- down to that size before it ever reaches this engine module. Going through
-- that path would mean resampling our Overworld_Sprites art too, which
-- conflicts with the lossless requirement for this pass -- confirmed with
-- the user, who chose the lossless 2D tier over native-walker/Dramatic
-- Shape compatibility.
--
-- Wilds' own Developer Guide (section 16) documents a second, non-native 2D
-- path that does NOT resample the file: it draws the full-resolution image
-- with a single love.graphics.draw(img, x, y, 0, scale, scale) and only
-- scales it visually, the same principle GalarGmaxDex's own
-- battleScaleFront/Back already relies on (see BASE_SPRITE_SCALE above).
-- That's the tier this hooks into, via Wilds' own documented, no-fork
-- extension point (mod.exports.registerSpriteProvider, lib/sprite_providers
-- .lua) -- zero edits to Wilds' own files. Cost: no walk-cycle animation
-- (Wilds' non-native draw path renders one static frame; the deprecated
-- "enhanced atlas" path is legacy and not relied on here) and no Dramatic
-- Shape 3D billboard for these species specifically -- they render 2D-only,
-- same as several of Wilds' own fallback tiers already do.
--
-- Wilds only ever consults a provider id that appears in its own hardcoded
-- STYLE_CHAINS table (lib/sprite_providers.lua) -- a custom id registered
-- under our own name is never actually reached during play. First attempt
-- wrapped "followers_ex" instead, which turned out to be the wrong slot:
-- that id is only ever consulted when a player has manually selected the
-- "Poke Followers" style in Wilds' Mod Settings -- the DEFAULT style
-- ("HGSS / PokeMMO") never asks it at all, so by default our species kept
-- falling through to Wilds' own automatic fallback (baking our battle-front
-- sprite, not overworld art, down to 16x16) regardless of this mod being
-- installed. Confirmed live in-game, not assumed.
--
-- "pokedex" is the correct slot: it's the LAST fallback in every single
-- style chain (pokemmo, followers, and pokedex itself), so wrapping it
-- reaches our species regardless of the player's style choice or whether
-- Followers EX is even installed. It's also Wilds' own builtin (not
-- another mod's identity), so there's no collision risk in overwriting it
-- -- still delegate-first to whatever "pokedex" already resolves for every
-- OTHER species (vanilla Kanto art, unchanged), and only serve our own
-- overworld crop for the amplified-dex species it has no coverage for.
--
-- Registration is deferred to "mods.loaded" (fired once by the loader after
-- every enabled mod's init has run, src/mods/Loader.lua) rather than called
-- directly from this mod's own init: Wilds' own exports only exist once it
-- has finished loading, and "mods.loaded" is order-independent -- no
-- dependency on manifest.json priority/declaration order between the two
-- mods.
local function installOverworldSpriteProvider(mod, spritePackRosterFull)
  local oursByKey, oursByDex = {}, {}
  -- dex lookup used to read straight off species_data.lua's own stat
  -- table; that table's gone (national_dex is the stat/dex source of
  -- truth now), so this resolves dex through national_dex instead --
  -- every one of these 51 species is a real, numbered Pokemon it knows
  -- about. Best-effort: if national_dex isn't installed, oursByDex just
  -- stays empty and dex-number lookups (not string-id ones) silently
  -- don't resolve, same as any other optional-dependency gap in this mod.
  local nd = mod.find and mod.find("national_dex")
  local ndOk = nd and nd.exports and (nd.exports.apiVersion or 0) >= 1
    and type(nd.exports.statsBySpecies) == "function"
  for _, id in ipairs(spritePackRosterFull) do
    oursByKey[id] = true
    if ndOk then
      local ok, rec = pcall(nd.exports.statsBySpecies, id)
      local dex = ok and rec and (rec.baseDex or rec.dex)
      if dex then oursByDex[dex] = id end
    end
  end

  -- Our own lossless assets/overworld/ crop, frames=1 (no walker flag) --
  -- back to the original format. The native 16x96/frames=6/walker=true
  -- attempt was meant to get Wilds' own nativeSheet fast path (hard-coded
  -- scale=1) to guarantee correct sizing, but the actual 2D size is now
  -- owned directly by installWildDrawOverride below (a render.makeEntity
  -- hook that replaces entity.draw outright, same technique Followers EX
  -- itself uses for its own walker-sheet swap) -- this def only needs to
  -- be a valid SpriteRenderer source for whatever it's still asked for
  -- (Dramatic Shape's voxel billboard, the Pokedex-seen icon), and
  -- frames=1/no walker is exactly what FOLLOWERS_EX's own BillboardUvFix
  -- already auto-detects as "whole image on the card" (not a frame slice),
  -- confirmed by reading its owStrip/sliceFrames check directly.
  local function overworldPath(speciesId)
    return mod.path .. "/assets/overworld/" .. speciesId .. ".png"
  end

  local function resolveOurs(speciesId)
    if type(speciesId) == "string" and oursByKey[speciesId] then
      return speciesId
    end
    local dex = tonumber(speciesId)
    if dex then return oursByDex[math.floor(dex)] end
    return nil
  end

  local function ourDef(key)
    local def = {
      image = overworldPath(key),
      frames = 1,
      trueColor = true,
      id = "SPRITE_OW_WILD_" .. key,
    }
    local meta = {
      providerId = "galar_gmax_dex",
      usedVariant = "normal",
      loadPath = def.image,
      frames = 1,
      walker = false,
    }
    return def, meta
  end

  mod.events:on("mods.loaded", function()
    local ok = pcall(function()
      local wilds = mod.find("overworld_wild_spawns")
      if not wilds then return end

      local getProvider = wilds.exports and wilds.exports.getSpriteProvider
      local register = wilds.exports and wilds.exports.registerSpriteProvider
      if not (getProvider and register) then return end

      local existing = getProvider("pokedex")

      register("pokedex", {
        id = "pokedex",
        isAvailable = function(_self, game)
          if existing then return existing:isAvailable(game) end
          return true, "galar gmax dex overworld art (amplified dex only)"
        end,
        resolve = function(_self, speciesId, variant, game)
          local key = resolveOurs(speciesId)
          if key then return ourDef(key) end
          if existing then
            return existing:resolve(speciesId, variant, game)
          end
          return nil, nil, "not covered by pokedex or galar_gmax_dex"
        end,
      })
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: failed to register overworld sprite provider with Wilds of Kanto")
    end
  end)
end

-- =============================================================================
-- 2D draw-size override for Wilds-spawned wild encounters of our species
-- =============================================================================
-- Explicit user decision: rather than keep fighting Wilds' own scale
-- pipeline (SpriteScale.compute's legacy path, or the nativeSheet fast
-- path's format assumptions) to get our species' wild spawns sized
-- correctly, take the draw call away from Wilds entirely for these
-- entities and control the on-screen size directly -- same
-- render.makeEntity hook point Followers EX itself uses to swap in its own
-- walker sheets (lib installPokepcOwPipeline), just replacing entity.draw
-- outright instead of entity.sprite. Reuses overworld_spawns.lua's own
-- applyLosslessDraw (mod.exports, populated regardless of whether W1's own
-- spawning is gated off -- see that file's own comment) so the exact same
-- explicit-display-height scaling applies here as it would to our own
-- native spawn engine's fallback path.
--
-- Only one hook point: makeEntity, for anything spawned after this
-- installs (mods.loaded, at boot -- well before any real spawn can exist).
-- A second pass, sweeping wilds.exports.logic.entities on every
-- map.entered to catch anything "already live," was here originally but
-- got removed: it's the prime suspect for the ghost sprite reported after
-- shipping this file (appears right at the player's entry point, persists
-- until the player leaves the map, and visibly tracks this same draw
-- override's own display-height changes). logic.entities is Wilds' own
-- table, not scoped to the current map by anything we control -- if it
-- still holds a spawn Wilds itself hasn't fully torn down yet when the
-- player crosses into a new map, sweeping it and attaching our own
-- npc.draw override would make that stale entity visible again under our
-- rendering instead of whatever (correct) fate Wilds already had for it.
-- makeEntity alone should already cover every real spawn, since that is
-- the one place Wilds actually constructs a wild encounter's NPC.
local function installWildDrawOverride(mod, spritePackRosterFull)
  local ours = {}
  for _, id in ipairs(spritePackRosterFull) do ours[id] = true end

  local function applyIfOurs(entity)
    if not entity then return end
    local species = entity.species
    if not (species and ours[species]) then return end
    local apply = mod.exports and mod.exports.applyLosslessDraw
    if apply then apply(entity, species) end
  end

  mod.events:on("mods.loaded", function()
    local ok = pcall(function()
      local wilds = mod.find("overworld_wild_spawns")
      if not (wilds and wilds.exports and wilds.exports.render) then return end
      local render = wilds.exports.render
      if render._galarGmaxDexDrawWrap then return end
      local origMake = render.makeEntity
      if type(origMake) ~= "function" then return end
      function render:makeEntity(game, record)
        local entity = origMake(self, game, record)
        pcall(applyIfOurs, entity)
        return entity
      end
      render._galarGmaxDexDrawWrap = true
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: failed to hook Wilds of Kanto entity creation for draw-size override")
    end
  end)
end

-- =============================================================================
-- Bigger party-menu icons for our species -- scale at draw time, not layout
-- =============================================================================
-- Reconsidered from scratch after checking gen1_modern_ui (an installed
-- overhaul mod that presents Party, Pokedex, Bag, etc. in a responsive,
-- high-resolution layer on top of the classic frame). Its own icon
-- presenter (iconFor in gen1_modern_ui/main.lua) already does proper
-- aspect-ratio scale-to-fit rendering from the SAME mod.content.icons /
-- pokemon.icon registry entry GalarGmaxDex already writes -- real
-- love.graphics.draw(img, x, y, 0, scale, scale) using the image's actual
-- width/height, not a fixed pixel crop. So simply pointing our existing
-- icon registration at a bigger, static source image is enough for
-- gen1_modern_ui to render it well, with zero code changes on that side.
-- (No `frames` field on the descriptor -- static image, not a cycling
-- animation; that mod's own frame-detection only activates when `frames`
-- is present.)
--
-- The classic 160x144 PartyMenu.drawIcon has no such scale path (confirmed
-- directly: it either slices a hard 16x16 pixel window with no scale
-- factor, or draws at literal native size) -- so a bigger source file
-- would show as a broken, cropped corner there instead of shrinking
-- cleanly (verified live with a real file swap earlier this session).
-- Rather than redesigning the classic screen's layout (16px row spacing is
-- a hard, shared constraint across the whole party list -- a much bigger,
-- riskier change that was tried and reverted), this wraps only
-- PartyMenu.drawIcon itself: for our species, load the same bigger source
-- and draw it pre-scaled down to the exact same 16x16 footprint classic
-- always used, using a real scale factor instead of a raw crop. Row
-- height, text position, and cursor position never change -- this is a
-- pure quality improvement at the exact same size, not a layout change.
-- Every other species (and TradeAnim.lua's own drawIcon call, which goes
-- through the same wrapped function) is untouched.
--
-- Logic switch (explicit user decision): our custom art is only worth
-- showing where it actually renders well. gen1_modern_ui's own presenter
-- scale-to-fits from real image dimensions, so our species look sharp
-- there. The classic 160x144 screen has no such scaling and only ever
-- shows our art pre-scaled to a fixed 16x16 -- correct, but still a
-- resample of a resample compared to gen1_modern_ui's presentation. When
-- gen1_modern_ui is not installed/enabled, skip our own art entirely and
-- fall through to whatever CHARMANDER (a real, always-present base-game
-- species) resolves to -- i.e. let vanilla's own icons.bySpecies /
-- icons.byDex fallback chain answer "what does Charmander's icon look
-- like" for us, rather than guessing/hardcoding which shared icon class
-- that is (that mapping comes from imported ROM data, not static engine
-- source, so it isn't available to read at mod-init time anyway).
-- gen1_modern_ui presence is checked once via mod.find, which only
-- resolves reliably if that mod has already finished loading -- guaranteed
-- here because gen1_modern_ui is declared in this mod's own
-- optional_dependencies (manifest.json), which orders it first when
-- present without requiring it (src/mods/Loader.lua Loader:_order:
-- "optional dependencies order without requiring anything").
local function installBigPartyIcons(mod, spritePackRosterFull)
  local PartyMenu = require("src.ui.PartyMenu")
  if PartyMenu.__galarIconScaleWrapped then return end
  PartyMenu.__galarIconScaleWrapped = true

  local hasModernUI = mod.find("gen1_modern_ui") ~= nil

  local ours = {}
  for _, id in ipairs(spritePackRosterFull) do ours[id] = true end

  local bigIconImages = {}
  local function loadBigIcon(speciesId)
    local path = iconPath(mod, speciesId)
    local cached = bigIconImages[path]
    if cached ~= nil then
      if cached == false then return nil end
      return cached
    end
    local ok, img = pcall(love.graphics.newImage, path)
    if ok and img then
      img:setFilter("nearest", "nearest")
      bigIconImages[path] = img
      return img
    end
    bigIconImages[path] = false
    return nil
  end

  local vanillaDrawIcon = PartyMenu.drawIcon
  function PartyMenu.drawIcon(game, mon, x, y, selected, counter, forceAlt)
    local species = mon and mon.species
    if not (species and ours[species]) then
      return vanillaDrawIcon(game, mon, x, y, selected, counter, forceAlt)
    end

    if not hasModernUI then
      -- Classic UI only, no gen1_modern_ui: fall through to Charmander's
      -- own resolved icon instead of our custom art. Real hp/stats are
      -- kept (only species is swapped) so the selected-row bounce speed
      -- still reflects the actual party member, matching vanilla's own
      -- per-mon HP-based bounce rule.
      local shim = { species = "CHARMANDER", hp = mon.hp, stats = mon.stats,
        nickname = mon.nickname, level = mon.level, status = mon.status }
      return vanillaDrawIcon(game, shim, x, y, selected, counter, forceAlt)
    end

    local img = loadBigIcon(species)
    if not img then
      return vanillaDrawIcon(game, mon, x, y, selected, counter, forceAlt)
    end

    -- Static single frame, no bounce cycling -- assets/icons_large files
    -- are one plain 32x32 pose per species.
    local iw = img:getWidth()
    local scale = 16 / iw -- fit the classic 16px-wide slot exactly; frame is square
    love.graphics.draw(img, x, y, 0, scale, scale)
    return true
  end
end

-- Gen 2 equivalent, deployed as the fix for a confirmed crash: the Gen 1
-- version above requires("src.ui.PartyMenu"), which under a Gen 2 boot
-- resolves to Gen2Compat.lua's own FACADE, not the real Gen 1 class.
-- That facade lists "drawIcon" under its own documented `absent` set
-- (Gen2Compat.lua: "PartyMenu.drawIcon is a STATIC under Gen 1 and a
-- METHOD on Gold, so the same call would bind self = game and die inside
-- iconFor") -- so `local vanillaDrawIcon = PartyMenu.drawIcon` silently
-- captured nil, and every ordinary (non-roster) species' icon draw called
-- that nil and crashed the instant the party list tried to render one --
-- reproduced live opening the party window right after receiving a Gen 2
-- starter. This requires the REAL native class directly
-- (src.ui.gen2.PartyMenu, bypassing the facade entirely) and wraps its
-- REAL method shape, confirmed by direct source read: `function
-- PartyMenu:drawIcon(mon, px, py)` (src/ui/gen2/PartyMenu.lua:577) -- a
-- method (self, not a `game` first-argument) taking only 3 params, not
-- Gen 1's 7-argument static shape. Icon sprite handling ONLY -- the rest
-- of Gen 2's party screen is untouched, matching the confirmed crash's
-- exact scope.
--
-- Today's actual roster (spritePackRosterFull, this mod's own Gigantamax-
-- capable species list) has zero Gen 2 species in it, so the "ours[species]"
-- branch below is currently unreachable in practice -- this is here so a
-- future Gen 2 roster addition already has a correctly-shaped hook to
-- land on, not because it does anything visible today. Every species not
-- in that (currently empty, for Gen 2) set just calls straight through to
-- Gold's own real drawIcon, unmodified -- which is the actual fix: a
-- correct, non-nil pass-through instead of a crash.
local function installBigPartyIconsGen2(mod, spritePackRosterFull)
  local ok, Party2 = pcall(require, "src.ui.gen2.PartyMenu")
  if not ok or type(Party2) ~= "table" then return end
  if Party2.__galarIconScaleWrapped then return end
  Party2.__galarIconScaleWrapped = true

  local ours = {}
  for _, id in ipairs(spritePackRosterFull) do ours[id] = true end

  local bigIconImages = {}
  local function loadBigIcon(speciesId)
    local path = iconPath(mod, speciesId)
    local cached = bigIconImages[path]
    if cached ~= nil then
      if cached == false then return nil end
      return cached
    end
    local imgOk, img = pcall(love.graphics.newImage, path)
    if imgOk and img then
      img:setFilter("nearest", "nearest")
      bigIconImages[path] = img
      return img
    end
    bigIconImages[path] = false
    return nil
  end

  local vanillaDrawIcon = Party2.drawIcon
  function Party2:drawIcon(mon, px, py)
    local species = mon and mon.species
    if not (species and ours[species]) then
      return vanillaDrawIcon(self, mon, px, py)
    end
    local img = loadBigIcon(species)
    if not img then
      return vanillaDrawIcon(self, mon, px, py)
    end
    -- Static single frame, no bounce cycling, no held-item marker overlay
    -- -- same accepted simplification the Gen 1 version above already
    -- uses for its own custom-art path.
    local iw = img:getWidth()
    local scale = 16 / iw
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(img, px, py, 0, scale, scale)
    return true
  end

  mod.log:info("galar_gmax_dex: big party icons (gen2) installed")
end

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
-- classic_encounters defaults OFF for a real, load-bearing reason, not
-- just a UI nicety: the core engine's own step-based random encounter
-- roll (src/world/OverworldController.lua, OverworldState:onStepComplete
-- -> rollEncounter -> Encounter.roll) is ALWAYS ACTIVE regardless of any
-- mod, reads the exact same mod.content.encounters table area.lua
-- populates, and nothing before this session ever suppressed it. With
-- W1's own visible wild spawns also on, every grass step was rolling a
-- SECOND, fully independent encounter on top of whatever W1's visible
-- Pokemon were already doing -- two full encounter systems stacked,
-- which is the most likely reason this has felt chaotic to test. Wrapping
-- "encounter.roll" and returning nil suppresses it outright (confirmed
-- from rollEncounter's own doc comment: "returns nil to suppress");
-- Runtime.wantsHook only routes through the hook chain at all once
-- something has wrapped the name, so this hook alone is what flips the
-- vanilla path off, independent of the option toggle.
local function installDebugOptions(mod)
  local schema = loadSibling(mod, "options.lua")
  mod.options:define(schema)

  mod.hooks:wrap("encounter.roll", function(next, encDef, ctx)
    if mod.options:get("classic_encounters") then
      return next(encDef, ctx)
    end
    return nil
  end)

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
  local spriteSpeciesList = loadSibling(mod, "species/custom_sprite_species.lua")
  local spritePackRosterFull = loadSibling(mod, "species/sprite_pack_roster_full.lua")
  local nativeVanillaSpecies = loadSibling(mod, "species/native_vanilla_species.lua")
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

  -- ------- Phase 2: movepool -------
  local movesData = loadSibling(mod, "combat/moves_new.lua")
  local movesRegistered = registerNewMoves(mod, movesData)
  -- Exported so combat/learnset_ownership.lua's usability gate reads the
  -- SAME completeness check registerNewMoves itself uses, not a second
  -- copy -- confirmed drift bug caught this session: learnset_ownership.lua
  -- had its own independent inline duplicate of this logic, missing both
  -- the RemoveProtections and ProtectUser special cases added here, which
  -- would have kept blocking Feint/Protect/Detect from ever being taught
  -- even after they became genuinely complete.
  mod.exports.isMoveDataComplete = isMoveDataComplete

  -- Learnset ownership switch (explicit user decision, this session):
  -- national_dex is the canonical "what can this species learn" source
  -- (its unfiltered movesFull/movesByMethod, not its own filtered
  -- learnset/levelMoves field -- see learnset_ownership.lua's own header
  -- for why that field's filtering can't reflect this mod's own
  -- completeness); GalarGmaxDex gates USABILITY on its own move-effect
  -- completeness. Replaces the old combat/learnsets_data.lua's own
  -- self-authored 51-species-only table -- superseded, no longer loaded,
  -- left on disk rather than deleted since nothing else references it.
  local installLearnsetOwnership = loadSibling(mod, "combat/learnset_ownership.lua")
  local learnsetOwnership = installLearnsetOwnership(mod, movesData)
  learnsetOwnership.reapplyLearnsets()
  mod.events:on("save.loaded", learnsetOwnership.reapplyLearnsets)
  mod.events:on("mod.options_changed", learnsetOwnership.reapplyLearnsets)

  mod.log:info("galar_gmax_dex: registered %d new moves (Phase 2)", movesRegistered)

  -- ------- Phase 3: Gigantamax moves and forms -------
  local gmaxMovesData = loadSibling(mod, "gigantamax/gmax_moves.lua")
  local gmaxData = loadSibling(mod, "gigantamax/gmax_data.lua")
  mod.exports.gmaxData = gmaxData

  local gmaxMovesRegistered = installGigantamaxMoves(mod, gmaxMovesData, gmaxData)
  installGmaxAssetPacks(mod, gmaxData)

  mod.log:info(
    "galar_gmax_dex: fed %d Gigantamax moves to dynamax for %d/%d species (Phase 3)",
    gmaxMovesRegistered, #gmaxData.order, #gmaxData.order)

  -- ------- Phase 4: battle sprites -------
  local frameCounts = loadSibling(mod, "overworld/sprite_frames_full.lua")
  local playerSpriteSide = installPlayerSpriteSide(mod)
  local spritesPatched = installSpriteAssetPacks(mod, spritePackRosterFull, frameCounts, nativeVanillaSpecies)
  installRestingScaleOverride(mod, spritePackRosterFull, BASE_SPRITE_SCALE)
  installGen2BattlePicPositionFix(mod, spritePackRosterFull)
  installSpriteAnimation(mod, playerSpriteSide)
  mod.log:info("galar_gmax_dex: patched %d/%d species with sliced, animated battle sprites (Phase 4)",
    spritesPatched, #spritePackRosterFull)

  -- ------- Phase 5: overworld sprite provider (optional: Wilds of Kanto) -------
  installOverworldSpriteProvider(mod, spritePackRosterFull)
  installWildDrawOverride(mod, spritePackRosterFull)
  -- Confirmed crash fix: the Gen 1 version below requires("src.ui
  -- .PartyMenu"), which under a Gen 2 boot resolves to a facade that
  -- reports drawIcon as absent -- see installBigPartyIconsGen2's own
  -- header for the full mechanism. Dispatch by generation instead of
  -- always installing the Gen 1-shaped wrap.
  local GameVersionForIcons = require("src.core.GameVersion")
  if GameVersionForIcons.generation(GameVersionForIcons.get()) == 2 then
    installBigPartyIconsGen2(mod, spritePackRosterFull)
  else
    installBigPartyIcons(mod, spritePackRosterFull)
  end

  -- ------- Phase 6: wild encounter area placements -------
  -- area.lua now self-gates by generation internally (an early Gen 2
  -- section using the real gen2Keys/gen2GrassRow registry shape, an
  -- early return before ever reaching the Kanto-map-id Gen 1 body) --
  -- always loaded, not skipped here, so its own Gen 2 content actually
  -- runs.
  local installAreaEncounters = loadSibling(mod, "overworld/area.lua")
  installAreaEncounters(mod)

  -- ------- Phase 7 (W1): native overworld wild-spawn engine -------
  -- Full replacement for Wilds of Kanto, per explicit user decision
  -- (2026-08-07). Once this is active, Wilds of Kanto should be disabled
  -- in the Mod Manager -- it would otherwise still try to spawn/render
  -- wild Pokemon on the same maps independently, producing duplicate/
  -- conflicting visible spawns. installOverworldSpriteProvider above is
  -- now dead weight if that mod is disabled (a no-op when Wilds isn't
  -- found) -- left in place for now rather than removed mid-transition.
  -- Followers EX compatibility (installFollowerSpriteHook/
  -- installFollowerOrphanCleanup) was removed outright per explicit user
  -- instruction -- not required, redundant with Phase 8's own native
  -- follower engine below.
  local installOverworldSpawns = loadSibling(mod, "overworld/overworld_spawns.lua")
  installOverworldSpawns(mod)

  -- ------- Phase 8 (F1): native follower engine -------
  -- Full replacement for Followers EX, per the same decision as Phase 7.
  -- Must run after Phase 7: reuses its mod.exports.wildSpriteIdFor rather
  -- than re-registering the same sprite ids.
  local installOverworldFollowers = loadSibling(mod, "overworld/overworld_followers.lua")
  installOverworldFollowers(mod)

  -- ------- Phase 9: Dramatic Shape voxel billboard override (optional) -------
  -- Explicit user decision after being warned of the risk (shared mesh
  -- across the solid/shadow/occlusion passes -- see the file's own
  -- comment). Must run after Phase 7: reuses mod.exports.wildSpriteIdFor.
  -- No-ops entirely if Dramatic Shape isn't installed.
  local installVoxelBillboards = loadSibling(mod, "overworld/voxel_billboards.lua")
  installVoxelBillboards(mod)

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
  local installModernCombat = loadSibling(mod, "combat/modern_combat.lua")
  installModernCombat(mod)
  local installModernCombatProtect = loadSibling(mod, "combat/modern_combat_protect.lua")
  installModernCombatProtect(mod)

  -- Phase 1 of the move-effect completion pipeline: wires moves_new.lua's
  -- stat-stage-change stubs to modern_combat.lua's changeStage primitive.
  -- Split into its own sibling file rather than grown into modern_combat.lua
  -- (~56 registrations) -- see that file's own header for the full
  -- grounding. Must load after modern_combat.lua (consumes its exports).
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
  -- .lua data + a MOVE_REGISTER_FIELDS entry above -- neither needs this
  -- file). Loaded after modern_combat_protect.lua (installed above) so its
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

  -- Own battle scene, gated on custom_battle_scene -- see that file's own
  -- header for the full grounding (verified against real engine source,
  -- not just DRAMATIC_SHAPE's zip, before writing it). PHASE A / a
  -- foundation build: forces OG layout, strips the plain white
  -- background, hands the renderer a placeholder-color canvas -- proves
  -- the render pipeline before real scene content is built on it.
  local installCustomBattleScene = loadSibling(mod, "combat/custom_battle_scene.lua")
  installCustomBattleScene(mod, UiTheme)

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
  -- custom_battle_scene.lua's own ring-menu framework (mod.exports
  -- .gimmickRing, installed above as part of installCustomBattleScene)
  -- absorbs the design of the standalone "gimmick ring menu" mod
  -- natively -- opens on a move-select grid boundary press. This
  -- registers the actual Gigantamax mechanic (Max Moves, HP double,
  -- 3-turn duration, size-up) as its first entry. Neither the reference
  -- gimmick_menu nor Dynamax mods are required to be installed -- see
  -- gimmick_dynamax.lua's own header for what was ported vs deliberately
  -- left out (the animated grow/shrink sprite sequence -- a draw-code
  -- change the standing "leave canvas untouched" rule doesn't cover).
  local installGigantamax = loadSibling(mod, "gigantamax/gimmick_dynamax.lua")
  installGigantamax(mod, mod.exports.gimmickRing)

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
