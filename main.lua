-- Galar Gigantamax Dex -- Phases 1-4: species/evolutions/typing, movepool,
-- Gigantamax moves/forms, and full animated battle sprites.
--
-- Phase 1 registers the 51 species (see species_data.lua) needed to
-- complete the evolution lines of the 34 Gigantamax-capable species.
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
-- virtual validation FS) with a loadfile() fallback for a plain
-- filesystem entry point. Plain require() only resolves the engine's own
-- src.* module tree, not a mod's own sibling files.
local ENTRY_SOURCE = debug.getinfo(1, "S").source
local ENTRY_DIR = ENTRY_SOURCE:sub(1, 1) == "@"
  and ENTRY_SOURCE:sub(2):match("^(.*)/[^/]+$") or "."

local function loadSibling(mod, filename)
  local body, readErr = mod:read(filename)
  local chunk, err
  if body then
    chunk, err = loadstring(body, "@" .. mod.path .. "/" .. filename)
  elseif ENTRY_DIR then
    chunk, err = loadfile(ENTRY_DIR .. "/" .. filename)
  end
  assert(chunk, err or readErr)
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
-- unconditional GALAR_TRAP_EFFECT. All three read/write only confirmed
-- real battler fields (flinched, confusedTurns, trappingTurns/boundTurns),
-- all seen in Dynamax's own clearDynamaxVolatiles (main.lua of the
-- `dynamax` mod). ctx.target (not ctx.defender) and ctx.rng(min, max) are
-- both confirmed against dynamax's MOD_MAXGUARD_EFFECT and its own test
-- suite's documented ctx.defender -> ctx.target fix.
--
-- Duration values (confusedTurns, trappingTurns) are reasonable
-- approximations, not confirmed exact -- this engine's own real formula
-- for either was not found in any reference source.
local function installMovepoolEffects(mod, movesData)
  local flinchChances, confuseChances = {}, {}
  for _, def in pairs(movesData) do
    local chance = def.effect:match("^GALAR_FLINCH_EFFECT_(%d+)$")
    if chance then flinchChances[tonumber(chance)] = true end
    chance = def.effect:match("^GALAR_CONFUSE_EFFECT_(%d+)$")
    if chance then confuseChances[tonumber(chance)] = true end
  end

  for chance in pairs(flinchChances) do
    mod.content.move_effects:register("GALAR_FLINCH_EFFECT_" .. chance, {
      kind = "secondary",
      run = function(ctx)
        if ctx.target and ctx.rng(1, 100) <= chance then
          ctx.target.flinched = true
        end
        return {}
      end,
    })
  end

  for chance in pairs(confuseChances) do
    mod.content.move_effects:register("GALAR_CONFUSE_EFFECT_" .. chance, {
      kind = "secondary",
      run = function(ctx)
        if ctx.target and ctx.rng(1, 100) <= chance then
          -- Approximated duration (2-5 turns); this engine's real
          -- confusion-length formula wasn't found anywhere confirmed.
          ctx.target.confusedTurns = ctx.rng(2, 5)
        end
        return {}
      end,
    })
  end

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
local MOVE_REGISTER_FIELDS = {
  "name", "type", "category", "power", "accuracy", "pp",
  "priority", "highCrit", "effect", "multiHit",
}

local function registerNewMoves(mod, movesData)
  installMovepoolEffects(mod, movesData)
  local registered = 0
  for id, def in pairs(movesData) do
    local entry = { id = id }
    for _, field in ipairs(MOVE_REGISTER_FIELDS) do
      entry[field] = def[field]
    end
    -- moves_new.lua keeps PBS's own type spelling (e.g. "PSYCHIC"), same
    -- as species_data.lua's types field -- translated here the same way
    -- species registration already does via engineTypeId, rather than
    -- registered raw. Missing this for moves specifically (species
    -- typing was already correctly translated) is what produced the
    -- "unresolved reference" validation error.
    entry.type = engineTypeId(entry.type)
    mod.content.moves:register(id, entry)
    registered = registered + 1
  end
  return registered
end

local function patchLearnsets(mod, learnsetsData)
  local patched = 0
  for id, def in pairs(learnsetsData) do
    if mod.content.pokemon:get(id) then
      mod.content.pokemon:patch(id, {
        level1Moves = def.level1Moves,
        learnset = def.learnset,
      })
      patched = patched + 1
    else
      mod.log:error("galar_gmax_dex: cannot patch learnset, %s is not registered", id)
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
local BASE_SPRITE_SCALE = 1.4

local function installSpriteAssetPacks(mod, speciesData, frameCounts)
  local packs = {}
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

  local function resolve(speciesId)
    local resolver = packs[activePackId] or packs.sliced_v1
    return resolver(speciesId) or packs.sliced_v1(speciesId)
  end
  mod.exports.resolveSpritePack = resolve

  mod.exports.reapplySpritePacks = function()
    local patched = 0
    for _, id in ipairs(speciesData.order) do
      local sprite = resolve(id)
      if sprite then
        mod.content.pokemon:patch(id, {
          spriteFront = sprite.spriteFront, spriteBack = sprite.spriteBack,
          frontSize = sprite.frontSize,
          battleScaleFront = sprite.battleScaleFront, battleScaleBack = sprite.battleScaleBack,
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
  -- cheap (51 species patches).
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
local function installRestingScaleOverride(mod, speciesData, restScale)
  local BattleState = require("src.battle.BattleState")
  if BattleState.__galarGmaxDexScaleWrapped then return end
  BattleState.__galarGmaxDexScaleWrapped = true

  local ours = {}
  for _, id in ipairs(speciesData.order) do ours[id] = true end

  local vanillaResolveBattleScale = BattleState.resolveBattleScale
  function BattleState.resolveBattleScale(data, side, path, species)
    if species and ours[species] then
      return restScale
    end
    return vanillaResolveBattleScale(data, side, path, species)
  end
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
    local mon = battler and battler.mon
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

  local function advance(battler, side, dt)
    local state, sprite, total = updateBattler(battler, side)
    if not state then return end
    state.elapsed = state.elapsed + dt * 1000
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

  local vanillaUpdate = BattleState.update
  function BattleState:update(dt)
    local result = vanillaUpdate(self, dt)
    if mod.options:get("animated_battle_sprites") ~= "false" then
      if self.player and not self.showPlayerBack and not self.sendingOut
          and not shouldPauseAnim(self, self.player) then
        local playerSide = playerSpriteSide.wantsPlayerFront() and "front" or "back"
        advance(self.player, playerSide, dt)
      end
      if self.enemy and not self.showEnemyTrainer and not self.enemySendingOut
          and not shouldPauseAnim(self, self.enemy) then
        advance(self.enemy, "front", dt)
      end
    end
    return result
  end

  local function clearAnim(battle)
    if not battle then return end
    if battle.player then battle.player.__galarAnim = nil end
    if battle.enemy then battle.enemy.__galarAnim = nil end
  end
  mod.events:on("battle.battler_switched", function(ev) clearAnim(ev and ev.battle) end)
  mod.events:on("battle.ended", function(ev) clearAnim(ev and ev.battle) end)

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
-- Shared overworld/follower sprite fallback: closest base-game species
-- =============================================================================
-- Explicit user decision, replacing the earlier "our own lossless crop" /
-- "our own native walker sheet of our own art" attempts for these two
-- integration points: both kept coming out oversized or duplicated once
-- actually tested live (Wilds' legacy scale path, and whatever native-format
-- assumption broke down for FOLLOWERS_EX's own trailer/stock-companion
-- system) and neither could be fully root-caused without live debugging
-- access this environment doesn't have. Instead of chasing that, our
-- species borrow the closest base-game species' own overworld art outright
-- -- real 151-dex sprites already proven correct (native 16x96 walker
-- format, already sized/animated right in every pipeline that consumes
-- them) in both Wilds and FOLLOWERS_EX, by body-plan category:
--   birds -> PIDGEY, bugs -> WEEDLE, plants -> BULBASAUR,
--   everything else (humanoid, quadruped, ghost, blob, ...) -> CHARMANDER
-- Categorized by hand from each species' actual body plan, not from its
-- battle type (type doesn't reliably predict body shape -- e.g. Silicobra
-- is GROUND but snake-shaped, Toxtricity is ELECTRIC/POISON but humanoid).
local OVERWORLD_FALLBACK_SPECIES = {
  -- birds
  ROOKIDEE = "PIDGEY", CORVISQUIRE = "PIDGEY", CORVIKNIGHT = "PIDGEY",
  -- bugs
  BLIPBUG = "WEEDLE", DOTTLER = "WEEDLE", ORBEETLE = "WEEDLE",
  SIZZLIPEDE = "WEEDLE", CENTISKORCH = "WEEDLE",
  -- plants
  APPLIN = "BULBASAUR", FLAPPLE = "BULBASAUR", APPLETUN = "BULBASAUR",
}
local function overworldFallbackSpecies(speciesId)
  return OVERWORLD_FALLBACK_SPECIES[speciesId] or "CHARMANDER"
end

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
local function installOverworldSpriteProvider(mod, speciesData)
  local oursByKey, oursByDex = {}, {}
  for _, id in ipairs(speciesData.order) do
    oursByKey[id] = true
    local dex = speciesData.species[id] and speciesData.species[id].dex
    if dex then oursByDex[dex] = id end
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
local function installWildDrawOverride(mod, speciesData)
  local ours = {}
  for _, id in ipairs(speciesData.order) do ours[id] = true end

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
-- Follower/leader sprite hook for Followers EX (party mon walking as/behind
-- the player)
-- =============================================================================
-- Wild spawns (installOverworldSpriteProvider above) and the player's own
-- party follower are two completely separate systems in this mod ecosystem
-- -- confirmed by reading both source trees directly, not assumed. The
-- follower/leader sprite is owned entirely by FOLLOWERS_EX
-- (lib/ControlEngine.lua), which itself monkey-patches the real engine's
-- SpriteRenderer.resolveImage: for the follower-family sprite ids
-- (SPRITE_POKEPC_MON / SPRITE_PLAYER_POKEMON / SPRITE_PIKACHU) it builds a
-- path <PokePC pack root>/assets/sprites/follower_<SPECIES>.png and loads
-- it -- falling back to Charmander's art when that exact file doesn't
-- exist, which is silently what happened for every one of our species
-- (confirmed: ControlEngine.lua's getFollowerImage has "if not img then
-- img = Assets.image(followerPath('CHARMANDER')) end", no other
-- fallback). There is no per-species extension hook in FOLLOWERS_EX itself
-- -- the fix per user decision is to wrap the same global engine method a
-- second time, layered on top of FOLLOWERS_EX's own wrap, and answer for
-- our species ourselves before its Charmander fallback ever runs.
--
-- Species identity at this layer comes from the sprite def's own image
-- path (self.def.image:match("follower_([%w_]+)%.png")), the exact same
-- technique ControlEngine.lua's own monSpeciesShinyFromDef uses -- that
-- path already embeds the requested species (set by whichever caller
-- created this SpriteRenderer) regardless of whether the file exists on
-- disk, so this does not need to re-derive "who is the current leader"
-- from game state independently.
--
-- This still requires the same native-format tradeoff as native walker
-- sprites elsewhere (16x16 per frame, 6-frame vertical strip, STAND/WALK
-- layout down/up/left with right as a horizontal mirror -- confirmed
-- against the real SpriteRenderer.STAND/WALK tables) -- there is no
-- scale-to-fit path for this feature at all, native or otherwise, so
-- unlike the wild-spawn case there was no lossless alternative to offer;
-- this was explicitly accepted when scoping this fix.
--
-- Load-order: FOLLOWERS_EX must install its own SpriteRenderer.resolveImage
-- wrap before this mod captures "the existing function" to delegate to,
-- or non-amplified-dex species would lose PokePC pack integration
-- entirely. Guaranteed by declaring FOLLOWERS_EX in this mod's own
-- optional_dependencies (manifest.json) plus deferring to "mods.loaded" --
-- same ordering guarantee already relied on for the Wilds sprite provider
-- above.
local function installFollowerSpriteHook(mod, speciesData)
  local ours = {}
  for _, id in ipairs(speciesData.order) do ours[id] = true end

  local walkerImages = {}
  local function loadWalker(speciesId)
    local cached = walkerImages[speciesId]
    if cached ~= nil then
      if cached == false then return nil end
      return cached
    end
    -- Our own species' walker sheet. This draw path is a native 16x16
    -- quad slice per frame (below), already correctly tile-sized
    -- regardless of source species -- the oversize bug lived in the wild-
    -- spawn whole-image draw (overworld_spawns.lua), not here, so there is
    -- no sizing reason to borrow a base-game species' art for followers.
    local path = mod.path .. "/assets/followers/" .. speciesId .. ".png"
    local ok, img = pcall(love.graphics.newImage, path)
    if ok and img then
      img:setFilter("nearest", "nearest")
      walkerImages[speciesId] = img
      return img
    end
    walkerImages[speciesId] = false
    return nil
  end

  mod.events:on("mods.loaded", function()
    local ok = pcall(function()
      local followersEx = mod.find("FOLLOWERS_EX")
      if not followersEx then return end

      local SpriteRenderer = require("src.render.SpriteRenderer")
      if SpriteRenderer.__galarFollowerWrapped then return end
      SpriteRenderer.__galarFollowerWrapped = true

      local origResolveImage = SpriteRenderer.resolveImage
      function SpriteRenderer:resolveImage(...)
        local id = self.def and self.def.id
        if id == "SPRITE_POKEPC_MON" or id == "SPRITE_PLAYER_POKEMON"
            or id == "SPRITE_PIKACHU" then
          local species = self.def.image
            and self.def.image:match("follower_([%w_]+)%.png")
          if species and ours[species] then
            local img = loadWalker(species)
            if img then
              -- Do NOT rewrite self.def.image/frames/walker here: def is the
              -- SAME shared table other code (ControlEngine's own species
              -- detection, FOLLOWERS_EX's BillboardUvFix voxel mesh cache)
              -- pattern-matches against "follower_<SPECIES>.png". A path
              -- without that literal prefix (assets/followers/URSHIFU.png
              -- has no "follower_" substring) makes every LATER call that
              -- re-derives species from self.def.image fail silently and
              -- fall through to their own Charmander/leader-guess fallback
              -- -- confirmed by reading monSpeciesShinyFromDef's exact same
              -- match pattern. Only the resolved image itself needs to
              -- change; the def table's identity string stays untouched.
              self.image = img
              return img
            end
          end
        end
        return origResolveImage(self, ...)
      end

      -- resolveImage above turned out to be dead code for the actual
      -- on-screen bug: ControlEngine.lua's own SpriteRenderer.draw override
      -- for these same three ids never calls self:resolveImage() at all --
      -- it resolves straight from a closure-local getFollowerImage(species)
      -- and blits directly (confirmed by reading ControlEngine.lua's own
      -- SpriteRenderer:draw, ~line 1104). That local function is not
      -- reachable from outside its closure, so the only way to answer for
      -- our species before its Charmander fallback runs is to wrap .draw
      -- itself a second time and short-circuit before ever calling through.
      -- Quad/flip/offset math below is a direct copy of ControlEngine's own
      -- blitPokepcTrueColor + SpriteRenderer:draw (same -4 y offset, same
      -- STAND/WALK frame lookup, same right-facing/step-flip mirroring) so
      -- our species draw pixel-identically to how theirs already do.
      local origDraw = SpriteRenderer.draw
      -- The engine's own render loop has no pcall around entity:draw(...)
      -- (confirmed directly, src/world/OverworldController.lua) -- an
      -- uncaught error here crashes the whole game, not just one frame.
      -- pcall the risky quad-drawing part and fall back to origDraw on
      -- any failure instead.
      local function drawOurs(self, px, py, camX, camY, facing, walkPhase, stepFlip, img)
        local x = math.floor(px - camX)
        local y = math.floor(py - camY) - 4
        local STAND, WALK = SpriteRenderer.STAND, SpriteRenderer.WALK
        local dirMap = (walkPhase == 1) and WALK or STAND
        local frameIdx = (dirMap and dirMap[facing or "down"]) or 0
        local flip = (facing == "right")
          or (stepFlip and (facing == "up" or facing == "down"))
        local iw, ih = img:getDimensions()
        local quad = love.graphics.newQuad(0, frameIdx * 16, 16, 16, iw, ih)
        local drawX = flip and (x + 16) or x
        local sx = flip and -1 or 1
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(img, quad, drawX, y, 0, sx, 1)
      end

      function SpriteRenderer:draw(px, py, camX, camY, facing, walkPhase, stepFlip, topHalf)
        local id = self.def and self.def.id
        if not topHalf and (id == "SPRITE_POKEPC_MON" or id == "SPRITE_PLAYER_POKEMON"
            or id == "SPRITE_PIKACHU") then
          local species = self.def.image
            and self.def.image:match("follower_([%w_]+)%.png")
          if species and ours[species] then
            local img = loadWalker(species)
            if img then
              local ok = pcall(drawOurs, self, px, py, camX, camY, facing, walkPhase, stepFlip, img)
              if ok then return end
              love.graphics.setColor(1, 1, 1, 1)
              mod.log:warn("galar_gmax_dex: follower draw failed for %s", tostring(species))
            end
          end
        end
        return origDraw(self, px, py, camX, camY, facing, walkPhase, stepFlip, topHalf)
      end
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: failed to hook Followers EX sprite resolution")
    end
  end)
end

-- =============================================================================
-- Followers EX stock-companion cleanup (map-entry ghost NPC)
-- =============================================================================
-- A real bug in Followers EX itself, not anything of ours -- traced by
-- reading the real engine's src/world/PikachuFollower.lua (the DRAW loop,
-- src/world/OverworldController.lua ~4862, iterates ow.entities only --
-- never ow.npcs) against how ControlEngine.lua and PokePCFollowers_
-- VoxelMerge both use debug.setupvalue to patch its module-local
-- "shouldSpawn" closure.
--
-- First pass at this fix (removed) assumed a half-purged orphan: present
-- in ow.npcs but missing from ow.entities. Re-tracing the upvalue capture
-- shows that is not what happens. ControlEngine captures "the previous
-- shouldSpawn" off PikachuFollower.onMapEntered AT THE POINT IT RUNS --
-- but by then that name already points at PokePCFollowers_VoxelMerge's own
-- wrapper, not the true engine original, so what ControlEngine captures
-- as its "vanilla fallback" is actually PokePCFollowers_VoxelMerge's own
-- loose check ("does any healthy party mon exist" -- almost always true),
-- not the real Pikachu-only one. Its own newShouldSpawn only explicitly
-- suppresses in pokemon/lead_trainer/pack modes, or in follow mode with a
-- pack size > 0; every OTHER mode/count combination falls through to that
-- mis-captured "fallback" and returns true. In those cases nothing ever
-- purges the companion -- it is a legitimate, fully-registered spawn (both
-- ow.npcs AND ow.entities) for the entire map visit, which is exactly why
-- it renders (the draw loop reads ow.entities, which was never touched)
-- and only clears when the NEXT map's onMapEntered calls its own remove()
-- at the top, or the map fully reloads on exit.
--
-- Nothing here can edit Followers EX's own files (only GalarGmaxDex/
-- dynamax/gimmick_menu/dynamic_scaling_final_dynamax are ours to touch).
-- Instead this re-derives the suppression decision ourselves (mirroring
-- newShouldSpawn's own two real branches, but falling back to a genuine
-- live-Pikachu check instead of trusting their mis-captured "previous"
-- function) and, when the companion should not exist, removes any
-- pikachuFollower-flagged (non-trailer -- that flag alone is what the
-- real engine's own findFollower/remove use to identify it, confirmed
-- from src/world/PikachuFollower.lua directly) entry from BOTH arrays.
local function installFollowerOrphanCleanup(mod)
  local Game = require("src.core.Game")

  local function shouldSuppressStockCompanion(ex, game)
    local mode = (type(ex.controlMode) == "function" and ex.controlMode(game)) or "follow"
    if mode == "pokemon" or mode == "lead_trainer" or mode == "pack" then
      return true
    end
    -- follow (or any other/unexpected mode string): only a genuine live
    -- Pikachu in the party justifies the vanilla talk-to-Pikachu companion.
    for _, mon in ipairs((game and game.save and game.save.party) or {}) do
      if mon and mon.species == "PIKACHU" and (mon.hp or 0) > 0 then
        return false
      end
    end
    return true
  end

  local function purgeStockCompanion(ow)
    for i = #(ow.npcs or {}), 1, -1 do
      local npc = ow.npcs[i]
      if npc and npc.pikachuFollower and not npc.pokepcTrailer then
        table.remove(ow.npcs, i)
      end
    end
    for i = #(ow.entities or {}), 1, -1 do
      local e = ow.entities[i]
      if e and e.pikachuFollower and not e.pokepcTrailer then
        table.remove(ow.entities, i)
      end
    end
  end

  mod.events:on("map.entered", function()
    local ok = pcall(function()
      local followersEx = mod.find("FOLLOWERS_EX")
      local ex = followersEx and followersEx.exports
      if not ex then return end
      local ow = mod.world and mod.world:overworld()
      if not ow then return end
      if shouldSuppressStockCompanion(ex, Game) then
        purgeStockCompanion(ow)
      end
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: failed to run Followers EX stock-companion cleanup")
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
local function installBigPartyIcons(mod, speciesData)
  local PartyMenu = require("src.ui.PartyMenu")
  if PartyMenu.__galarIconScaleWrapped then return end
  PartyMenu.__galarIconScaleWrapped = true

  local hasModernUI = mod.find("gen1_modern_ui") ~= nil

  local ours = {}
  for _, id in ipairs(speciesData.order) do ours[id] = true end

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
  -- (engine_modern_stats.lua/engine_move_category.lua) and get registered
  -- into package.preload before anything else runs, so every existing
  -- require("src.pokemon.ModernStats")/require("src.pokemon.MoveCategory")
  -- call site -- this mod's own files, and save_scrub.lua's
  -- SaveData.validate wrap -- keeps working completely unchanged, and Lua
  -- resolves them from OUR bundled copy instead of ever touching the
  -- engine's own src/pokemon/ directory. package.preload is checked
  -- before the filesystem search on every require() (confirmed by the
  -- crash's own error text: "no field package.preload[...]" was already
  -- the first thing Lua reported trying).
  if not package.preload["src.pokemon.ModernStats"] then
    package.preload["src.pokemon.ModernStats"] = function()
      return loadSibling(mod, "engine_modern_stats.lua")
    end
  end
  if not package.preload["src.pokemon.MoveCategory"] then
    package.preload["src.pokemon.MoveCategory"] = function()
      return loadSibling(mod, "engine_move_category.lua")
    end
  end
  local installSaveScrub = loadSibling(mod, "save_scrub.lua")
  installSaveScrub(mod)

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

  local speciesData = loadSibling(mod, "species_data.lua")

  installHappinessEvolution(mod)

  local itemIds = {}
  for id, def in pairs(speciesData.items) do
    mod.content.items:register(id, {
      id = id, name = def.name, price = def.price or 0,
      tossable = true, needsTarget = true,
    })
    itemIds[id] = true
  end
  installEvolutionItems(mod, itemIds)

  local registered = 0
  for _, id in ipairs(speciesData.order) do
    local def = speciesData.species[id]
    local types = {}
    for i, t in ipairs(def.types) do types[i] = engineTypeId(t) end
    local primary = types[1]

    local templateId = SPECIAL_TEMPLATE[id] or TEMPLATE_FOR_TYPE[primary] or "RATTATA"
    local template = mod.content.pokemon:get(templateId)
    if not template then
      mod.log:error("galar_gmax_dex: fallback template %s missing for %s, skipping", templateId, id)
    else
      local hw = derivedHeightWeight(def.heightM, def.weightKg)
      mod.content.pokemon:register(id, {
        id = id,
        name = def.name,
        dex = def.dex,
        types = types,
        baseStats = def.baseStats,
        catchRate = def.catchRate,
        baseExp = def.baseExp,
        growthRate = def.growthRate,
        happiness = def.happiness or 70,
        -- Phase 2 replaces this placeholder with the real learnset.
        level1Moves = { "TACKLE" },
        learnset = {},
        tmhm = {},
        evolutions = def.evolutions,
        spriteFront = template.spriteFront,
        spriteBack = template.spriteBack,
        frontSize = template.frontSize or 7,
        battleScaleFront = template.battleScaleFront,
        battleScaleBack = template.battleScaleBack,
        icon = { image = iconPath(mod, id) },
        dexEntry = {
          kind = def.dexEntry.kind,
          heightFt = hw.heightFt, heightIn = hw.heightIn,
          weight = hw.weight,
          heightM = def.heightM, weightKg = def.weightKg,
          text = def.dexEntry.text,
        },
      })
      mod.content.icons:register(id, { image = iconPath(mod, id) })
      registered = registered + 1
    end
  end

  local maxDex = 0
  for _, def in pairs(speciesData.species) do
    if def.dex > maxDex then maxDex = def.dex end
  end
  local okDexSize, currentDexSize = pcall(function()
    return mod.content.constants:get("dexSize")
  end)
  mod.content.constants:patch("dexSize",
    math.max(okDexSize and tonumber(currentDexSize) or 0, maxDex))

  mod.log:info("galar_gmax_dex: registered %d/%d species (Phase 1)", registered, #speciesData.order)

  -- ------- Phase 2: movepool -------
  local movesData = loadSibling(mod, "moves_new.lua")
  local movesRegistered = registerNewMoves(mod, movesData)

  local learnsetsData = loadSibling(mod, "learnsets_data.lua")
  local patched = patchLearnsets(mod, learnsetsData)

  mod.log:info("galar_gmax_dex: registered %d new moves, patched %d/%d species learnsets (Phase 2)",
    movesRegistered, patched, #speciesData.order)

  -- ------- Phase 3: Gigantamax moves and forms -------
  local gmaxMovesData = loadSibling(mod, "gmax_moves.lua")
  local gmaxData = loadSibling(mod, "gmax_data.lua")
  mod.exports.gmaxData = gmaxData

  local gmaxMovesRegistered = installGigantamaxMoves(mod, gmaxMovesData, gmaxData)
  installGmaxAssetPacks(mod, gmaxData)

  mod.log:info(
    "galar_gmax_dex: fed %d Gigantamax moves to dynamax for %d/%d species (Phase 3)",
    gmaxMovesRegistered, #gmaxData.order, #gmaxData.order)

  -- ------- Phase 4: battle sprites -------
  local frameCounts = loadSibling(mod, "sprite_frames.lua")
  local playerSpriteSide = installPlayerSpriteSide(mod)
  local spritesPatched = installSpriteAssetPacks(mod, speciesData, frameCounts)
  installRestingScaleOverride(mod, speciesData, BASE_SPRITE_SCALE)
  installSpriteAnimation(mod, playerSpriteSide)
  mod.log:info("galar_gmax_dex: patched %d/%d species with sliced, animated battle sprites (Phase 4)",
    spritesPatched, #speciesData.order)

  -- ------- Phase 5: overworld sprite provider (optional: Wilds of Kanto) -------
  installOverworldSpriteProvider(mod, speciesData)
  installWildDrawOverride(mod, speciesData)
  installFollowerSpriteHook(mod, speciesData)
  installFollowerOrphanCleanup(mod)
  installBigPartyIcons(mod, speciesData)

  -- ------- Phase 6: wild encounter area placements -------
  local installAreaEncounters = loadSibling(mod, "area.lua")
  installAreaEncounters(mod)

  -- ------- Phase 7 (W1): native overworld wild-spawn engine -------
  -- Full replacement for Wilds of Kanto, per explicit user decision
  -- (2026-08-07). Once this is active, Wilds of Kanto and Followers EX
  -- should be disabled in the Mod Manager -- both would otherwise still
  -- try to spawn/render wild Pokemon on the same maps independently,
  -- producing duplicate/conflicting visible spawns. installOverworldSpriteProvider
  -- / installFollowerSpriteHook above are now dead weight if those mods
  -- are disabled (both are no-ops when their target mod isn't found) --
  -- left in place for now rather than removed mid-transition.
  local installOverworldSpawns = loadSibling(mod, "overworld_spawns.lua")
  installOverworldSpawns(mod)

  -- ------- Phase 8 (F1): native follower engine -------
  -- Full replacement for Followers EX, per the same decision as Phase 7.
  -- Must run after Phase 7: reuses its mod.exports.wildSpriteIdFor rather
  -- than re-registering the same sprite ids.
  local installOverworldFollowers = loadSibling(mod, "overworld_followers.lua")
  installOverworldFollowers(mod)

  -- ------- Phase 9: Dramatic Shape voxel billboard override (optional) -------
  -- Explicit user decision after being warned of the risk (shared mesh
  -- across the solid/shadow/occlusion passes -- see the file's own
  -- comment). Must run after Phase 7: reuses mod.exports.wildSpriteIdFor.
  -- No-ops entirely if Dramatic Shape isn't installed.
  local installVoxelBillboards = loadSibling(mod, "voxel_billboards.lua")
  installVoxelBillboards(mod)

  installMoveNameDisplay(mod)

  -- ------- Phase 10: modern stats display -------
  -- Sp.Atk/Sp.Def, IVs, EVs, Nature, Ability, Item, Tera Type, Dynamax
  -- Level, and per-move category, added to the party submenu ("MODERN")
  -- and to gen1_modern_ui's own modern-styled list rendering when that mod
  -- is present. See modern_stats_screen.lua's own header for why this is
  -- a party-submenu screen rather than a SummaryMenu edit.
  local installModernStatsScreen = loadSibling(mod, "modern_stats_screen.lua")
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
  local installModernCombat = loadSibling(mod, "modern_combat.lua")
  installModernCombat(mod)
  local installModernCombatProtect = loadSibling(mod, "modern_combat_protect.lua")
  installModernCombatProtect(mod)

  -- Shared theme/panel primitives (colors, panel(), printText(), cursor,
  -- HP bar) -- one module so battle and every menu screen below read as
  -- one coherent UI instead of per-screen one-off looks.
  local UiTheme = loadSibling(mod, "ui_theme.lua")

  -- Own battle scene, gated on custom_battle_scene -- see that file's own
  -- header for the full grounding (verified against real engine source,
  -- not just DRAMATIC_SHAPE's zip, before writing it). PHASE A / a
  -- foundation build: forces OG layout, strips the plain white
  -- background, hands the renderer a placeholder-color canvas -- proves
  -- the render pipeline before real scene content is built on it.
  local installCustomBattleScene = loadSibling(mod, "custom_battle_scene.lua")
  installCustomBattleScene(mod, UiTheme)

  -- ------- Phase 12: custom menu takeover, party screen first -------
  -- Same architecture gen1_modern_ui itself uses for non-battle screens
  -- (a kindFor-style classifier + the two-hook screen.render_visible /
  -- render.hud suppress-and-replace pattern its own author documents),
  -- generalized from the battle scene's own render.hud panel technique.
  -- Gated on custom_menu_scene, independent of custom_battle_scene so
  -- either can be toggled alone. Phase 1 scope: the plain party overview
  -- only -- see custom_party_scene.lua's own header for what's
  -- deliberately not covered yet (battle switch prompts, TM/HM teach
  -- mode) and why that's a flagged limit, not a silent gap.
  local installCustomPartyScene = loadSibling(mod, "custom_party_scene.lua")
  installCustomPartyScene(mod, UiTheme)

  -- ------- Phase 13: custom menu takeover, title/start/options/mods -------
  -- Same custom_menu_scene gate and render.hud/screen.render_visible
  -- pattern as custom_party_scene.lua, extended to the title screen menu,
  -- the in-game start (pause) menu, the options menu, and the mod
  -- manager -- see custom_menu_takeover.lua's own header for the full
  -- grounding (Menu/OptionsMenu/ManagerState field names, why title/start
  -- menus need to be individually tagged rather than blanket-catching
  -- every Menu instance, and the MOD MENUS hub replication).
  local installCustomMenuTakeover = loadSibling(mod, "custom_menu_takeover.lua")
  installCustomMenuTakeover(mod, UiTheme)
end
