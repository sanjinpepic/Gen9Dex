-- Native overworld wild-spawn engine (W1: core).
--
-- Full replacement for Wilds of Kanto's role, owned by GalarGmaxDex, per
-- explicit user decision (2026-08-07) after repeated, unresolved
-- integration bugs with the standalone mod that could not be diagnosed
-- without live debugging access this environment doesn't have.
--
-- Architecture grounded directly in the real engine's own primitives, not
-- reinvented -- confirmed by reading src/world/*.lua before writing this:
-- - mod.world:spawnNpc(mapId, objDef) / :removeNpc(npcId) (WorldAPI.lua)
--   create/destroy REAL NPC instances (src/world/NPC.lua) through
--   OverworldState:addRuntimeObject, already pooled into both ow.npcs and
--   ow.entities. A spawned wild Pokemon is therefore a genuine NPC: full
--   movement, wander ("WALK" movement + "ANY_DIR" range, built into
--   NPC.lua's own :update, no custom wander logic needed), rendering, and
--   Collision.canMove participation all come for free.
-- - Map:isGrassCell / :isWalkableCell / :inBounds (Map.lua) are the same
--   tile queries Collision.lua itself uses -- reused directly, not
--   reimplemented.
-- - The "movement.collision" hook (src/mods/Hooks.lua contract: callback
--   receives (next, ...args), returns its own value to short-circuit or
--   calls next(...) to pass through unchanged) is the exact mechanism
--   Wilds' own SpawnLogic:onCollision used -- reused here against our own
--   spawn registry instead.
-- - Encounter.roll (src/world/Encounter.lua) documents the vanilla
--   species/level weighting algorithm (cumulative bucket thresholds out
--   of 256, engine/battle/wild_encounters.asm) against the exact same
--   mod.content.encounters data area.lua already populates -- the slot
--   selection here mirrors that algorithm rather than inventing a new one.
--
-- Deferred to later phases (W2-W6), not built here: aggressive/hidden
-- behaviors, water encounters, Safari Zone, Dramatic Shape voxel
-- billboards (would require the lossy native-format tradeoff already
-- litigated this session), spawn density/region balancing beyond a flat
-- per-map cap.
return function(mod)
  local Game = require("src.core.Game")
  local Assets = require("src.render.Assets")

  -- Gen 2 support. Confirmed by direct source read (not assumed): Gen 2's
  -- real wild-encounter data lives at a completely different Data key and
  -- shape than Gen 1's (Schemas.GEN2.encounters = "gen2Encounters",
  -- src/mods/Schemas.lua:483 -- keyed by kind then map id, with per-
  -- time-of-day rate/slot tables, vs Gen 1's flat per-map {grass={rate,
  -- slots}}), so Game.data.encounters[mapId] always misses on a Gen 2
  -- map -- that's the whole reason encounters silently never spawned.
  -- src/battle/gen2/Encounter.lua already implements the real Gen 2
  -- roll against that real shape (grassRate/grassSlot) -- reused
  -- directly below rather than hand-rolling a second bucket table.
  -- Also: mod.world:spawnNpc's Gen1-string objDef ({movement="WALK",
  -- range="ANY_DIR"}) silently produces a STANDING (non-wandering) NPC
  -- under Gen 2 -- spawnNpc doesn't route through the legacy Gen1 shim,
  -- and Gen 2's own patternFor(movement) (src/world/gen2/Npc.lua:140-158)
  -- only recognizes numeric NPC.MOVE.* constants, falling through to a
  -- non-wandering "stand" kind for the string "WALK". NPC.MOVE.WANDER +
  -- a radius table is the real Gen 2 wander vocabulary.
  local GameVersion = require("src.core.GameVersion")
  local isGen2Boot = GameVersion.generation(GameVersion.get()) == 2
  local Gen2Encounter = isGen2Boot and require("src.battle.gen2.Encounter") or nil
  -- src.world.NPC is aliased to src.world.gen2.Npc under a Gen 2 boot
  -- (confirmed via Gen2Compat.lua), so this one require resolves
  -- correctly either way -- only fetched under Gen 2 since Gen 1's own
  -- spawn call below never needs it.
  local Gen2NPC = isGen2Boot and require("src.world.NPC") or nil

  -- Neither SpriteRenderer.lua nor the underlying Assets.image() cache
  -- ever call img:setFilter -- confirmed by reading both directly -- so
  -- every image loaded through them keeps LOVE's default linear filter,
  -- which blurs small pixel-art scaled up onto a Dramatic Shape billboard
  -- (or any sizeable on-screen scale). Assets.image() caches by resolved
  -- path and returns the same Image object to every caller, so nudging
  -- the filter on our own first access here is enough to fix it for
  -- every later SpriteRenderer draw of the same path -- no global
  -- love.graphics.setDefaultFilter override, which would also touch
  -- everything else's art. Deferred to actual gameplay time (never called
  -- from the top-level init below) since creating textures this early in
  -- boot is not a pattern used elsewhere in this mod.
  local filteredPaths = {}
  local function ensureNearestFilter(path)
    if filteredPaths[path] then return end
    filteredPaths[path] = true
    pcall(function()
      local img = Assets.image(path)
      if img then img:setFilter("nearest", "nearest") end
    end)
  end

  -- ------- Phase 1: sprite registration for the full available roster ---
  -- Registers a native 16x96 walker sheet record (src/render/
  -- SpriteRenderer.lua's hard-locked per-frame format) for every
  -- registered species, agnostic the same way installFollowerSpriteHook's
  -- battle-sprite loop was: iterate mod.content.pokemon:each() directly,
  -- no per-species art file needed at all.
  --
  -- assets/wild_walkers/ used to be ~1400 individual per-species 16x96
  -- sheets (generated from Overworld_Sprites/Followers). Removed outright
  -- this session (explicit user instruction, "a bad asset that still
  -- lingers") and briefly regenerated as per-species placeholders when a
  -- live crash (Route 29 wild spawns AND the party follower, both hitting
  -- this exact registry) proved the files still needed to exist -- but
  -- root-causing that crash properly (src/render/SpriteRenderer.lua:
  -- 135-153's SpriteRenderer.new) showed WHY, and it has nothing to do
  -- with per-species art:
  --   self.image = getImage(spriteDef.image)   -- eager, unconditional,
  --   local iw, ih = self.image:getDimensions()  -- AT ENTITY CONSTRUCTION
  -- getImage/Assets.image have no pcall anywhere in that chain -- a
  -- missing file throws a hard, uncaught error the moment an NPC is
  -- CONSTRUCTED against this sprite id, well before drawLossless/
  -- applyLosslessDraw ever get a chance to intercept anything (that
  -- override replaces :draw(), not construction). But self.frameWidth/
  -- frameHeight -- what movement/collision actually reads -- come from
  -- spriteDef.frameWidth/frameHeight (registration fields, defaulting to
  -- a constant), NEVER from the loaded image's own iw/ih; those two are
  -- used only to satisfy love.graphics.newQuad's own API (which needs a
  -- source-texture-size argument), a pure rendering-math technicality.
  -- Since drawLossless/applyLosslessDraw already replace this sprite's
  -- draw() entirely, the underlying image's actual pixel content was
  -- NEVER visible to a player in the first place -- so every species
  -- sharing ONE always-present placeholder file satisfies
  -- SpriteRenderer.new's hard "must be a real, loadable image" engine
  -- requirement exactly as well as 1400 unique ones did, at a fraction of
  -- the size and with nothing left to go stale.
  local WALKER_PLACEHOLDER = mod.path .. "/assets/wild_walkers/placeholder.png"
  local spriteIdFor = {}
  do
    local registered = 0
    for id in mod.content.pokemon:each() do
      local spriteId = "SPRITE_GGD_WILD_" .. id
      local okReg = pcall(function()
        mod.content.sprites:register(spriteId, {
          id = spriteId, -- R.sprites' id field is optional/not
          -- auto-populated from the registry key -- voxel_billboards.lua's
          -- def.id lookup needs this set explicitly, confirmed by reading
          -- Schemas.lua's R.sprites fields directly.
          image = WALKER_PLACEHOLDER,
          frames = 6,
          walker = true,
          trueColor = true,
        })
      end)
      if okReg then
        spriteIdFor[id] = spriteId
        registered = registered + 1
      end
    end
    mod.log:info("galar_gmax_dex: registered %d wild overworld sprites (Phase 7 W1)", registered)
  end

  -- Shared with overworld_followers.lua (F1): both draw the same native
  -- walker art, so the follower engine reuses this registry instead of
  -- re-registering the same sprite ids (which would error as duplicates)
  -- or re-scanning the asset directory itself.
  mod.exports.wildSpriteIdFor = spriteIdFor

  -- ------- Lossless custom draw override (classic 2D overworld only) ----
  -- Explicit user decision: the native 16x16-per-frame SpriteRenderer
  -- format (required above for movement/collision/registration) is too
  -- low-detail for the actual on-screen appearance. assets/overworld/
  -- holds a genuinely lossless single-frame crop per species (native
  -- source resolution, e.g. 64x64-128x128, no resample at all -- the
  -- same crop already proven correct for the earlier Wilds "pokedex" tier
  -- integration). NPC:draw is an ordinary instance method (NPC.__index =
  -- NPC) -- shadowing it with a per-instance field is the exact same
  -- pattern the real engine's own PikachuFollower.lua uses for walkPhase,
  -- not a new technique. Falls back to the native draw (npc:pose() +
  -- sprite:draw(...)) whenever the lossless art fails to load, so a
  -- missing file degrades to "looks like every other NPC" rather than
  -- drawing nothing.
  --
  -- Known limit, not fixed here: this is one static down-facing frame, no
  -- directional facing or walk animation in the classic 2D view (the
  -- source crop is only ever row 0 / column 0) -- same trade the old
  -- Wilds-integration "pokedex" tier already made. Also classic-2D-only:
  -- Dramatic Shape's voxel billboard reads pose()/the native sprite
  -- directly for its own 3D rendering, a separate, not-yet-investigated
  -- system this override does not reach.
  local OVERWORLD_REL = "assets/overworld"
  local overworldImages = {}
  -- suffix: "" (down/front, the original single crop), "_up", or "_left"
  -- (right reuses "_left" mirrored at draw time, not a separate file --
  -- matches this mod's existing native-format convention of right =
  -- mirrored left, e.g. SpriteRenderer's own WALK/STAND tables). Confirmed
  -- the source sheet's row layout by opening a couple of samples directly
  -- (CHARMANDER.png, PIDGEY.png, PIKACHU.png): row0=down, row1=left
  -- profile, row3=up -- a 4-column x 4-row grid, columns being 4 walk-
  -- cycle frames. tools/generate_overworld_walkcycle.ps1 (successor to
  -- the earlier scratchpad-only gen_full_roster_overworld.ps1/
  -- gen_directional_overworld.ps1, whose row/column convention it reuses
  -- exactly) sliced all 4 columns for the full 1403-species roster.
  --
  -- frame: 1-4, defaults to 1 -- column 0, the original single crop every
  -- call site used before walk-cycle frames existed. Infixed BEFORE the
  -- direction suffix (frame 1 has no infix at all, matching the pre-
  -- existing on-disk names): <ID>.png/_2/_3/_4 (down),
  -- <ID>_left.png/_2_left/_3_left/_4_left, same for _up. Species not
  -- covered by the sliced roster (an asset-free build, or genuinely
  -- outside the ~1403) simply have no frame >1 on disk and read as such
  -- via the normal pcall existence check below -- no separate "does this
  -- species have walk frames" concept, agnostic the same way frame 1
  -- always was.
  local FRAME_INFIX = { [1] = "", [2] = "_2", [3] = "_3", [4] = "_4" }
  local function loadOverworldImage(species, suffix, frame)
    local infix = FRAME_INFIX[frame or 1] or ""
    local key = species .. infix .. (suffix or "")
    local cached = overworldImages[key]
    if cached ~= nil then
      if cached == false then return nil end
      return cached
    end
    local path = mod.path .. "/" .. OVERWORLD_REL .. "/" .. species .. infix .. (suffix or "") .. ".png"
    local ok, img = pcall(love.graphics.newImage, path)
    if ok and img then
      img:setFilter("nearest", "nearest")
      overworldImages[key] = img
      return img
    end
    overworldImages[key] = false
    return nil
  end

  -- How many contiguous walk-cycle frames actually exist for this
  -- species+direction (1 for the "000" placeholder and anything else the
  -- sliced roster doesn't cover, up to 4 for the full roster) -- probed
  -- once and cached permanently, same "can't change mid-session" reasoning
  -- as main.lua's own spriteFileExists cache. Frame-cycling below always
  -- wraps against THIS count rather than assuming 4, so a 1-frame set
  -- (the fallback tier) just always draws frame 1, no special-casing.
  local frameCountCache = {}
  local function frameCountFor(species, suffix)
    local key = species .. (suffix or "")
    local cached = frameCountCache[key]
    if cached ~= nil then return cached end
    local count = 0
    for frame = 1, 4 do
      if loadOverworldImage(species, suffix, frame) then
        count = frame
      else
        break
      end
    end
    frameCountCache[key] = count
    return count
  end

  -- Walking: extends the native NPC:walkPhase()'s own convention
  -- (src/world/NPC.lua:114-118, `self.progress % 16`, alternating 2
  -- phases across one tile's traversal) to as many phases as this
  -- species+direction actually has frames for, since our source art has
  -- up to 4 walk frames per direction instead of the native sheet's 2.
  -- 16 is not a guess -- it's the same constant walkPhase() itself reads.
  local WALK_CYCLE_LENGTH = 16
  local function walkFrame(self, frameCount)
    if frameCount <= 1 then return 1 end
    local p = (self.progress or 0) % WALK_CYCLE_LENGTH
    local idx = math.floor(p / (WALK_CYCLE_LENGTH / frameCount)) + 1
    return idx > frameCount and frameCount or idx
  end

  -- Idle: explicit user goal, "cycle and have idle movement for the same
  -- side if they aren't walking" -- native walkPhase() answers a flat
  -- frame 1 whenever not moving, no idle animation at all. No movement-
  -- progress ticks exist for a standing entity to read, so this is driven
  -- by wall-clock time instead, deliberately slower than the walk cycle
  -- (a gentle idle sway, not a walk in place).
  local IDLE_FPS = 3
  local function idleFrame(frameCount)
    if frameCount <= 1 then return 1 end
    return math.floor(love.timer.getTime() * IDLE_FPS) % frameCount + 1
  end

  -- Frame index for the current facing, walking or idle -- shared by both
  -- drawLossless (Gen 1) and drawLosslessGen2 below.
  local function currentFrame(self, species, suffix)
    local frameCount = frameCountFor(species, suffix)
    return (self.moving and walkFrame(self, frameCount) or idleFrame(frameCount)), frameCount
  end

  -- Fallback tier, both first and last resort, explicit user instruction:
  -- when a species has no lossless overworld art of its own (an asset-
  -- free build, or simply not one of the ~1403 species this pack covers),
  -- show CYNDAQUIL's real registered battle-front sprite instead of
  -- jumping straight to the generic native walker sheet. Deliberately a
  -- BATTLE pose, not a walk-cycle -- there is no native overworld-walker
  -- convention to fall back to at all (confirmed: no "SPRITE_CYNDAQUIL"
  -- or any per-species overworld sprite id exists anywhere in the native
  -- SPRITE_* roster, grepped tools/rom_manifest_gold.json directly --
  -- only a small hand-picked set of species, e.g. SPRITE_PIKACHU, have a
  -- native overworld-walker asset at all, and Cyndaquil isn't one of
  -- them). mod.content.pokemon:get("CYNDAQUIL").spriteFront is,
  -- deliberately, the SAME already-resolved battle sprite the priority
  -- chain in main.lua's reapplySpritePacks produces -- Cyndaquil is
  -- vanilla-native, so that chain guarantees this is always a REAL,
  -- non-placeholder sprite (this mod's own art if present, otherwise the
  -- cart's own real native sprite, never our generic "000" placeholder --
  -- confirmed by that same chain's own vanilla-preservation fix). Loaded
  -- and cached once, not re-resolved per frame.
  local cyndaquilFallbackImage, cyndaquilFallbackTried = nil, false
  local function loadCyndaquilFallback()
    if cyndaquilFallbackTried then return cyndaquilFallbackImage end
    cyndaquilFallbackTried = true
    local ok, def = pcall(function() return mod.content.pokemon:get("CYNDAQUIL") end)
    local path = ok and def and def.spriteFront
    if not path then return nil end
    local okImg, img = pcall(love.graphics.newImage, path)
    if okImg and img then
      img:setFilter("nearest", "nearest")
      cyndaquilFallbackImage = img
    end
    return cyndaquilFallbackImage
  end

  -- Explicit on-screen display height, not the source file's own pixel
  -- size. Explicit user decision after seeing the 1:1-pixel draw come out
  -- oversized (64x64 native crops drawn at literal native size, 4x a
  -- vanilla 16px tile): keep the full-resolution source (nearest-neighbor
  -- filtered, no file ever resampled) but scale it down at DRAW time to a
  -- deliberately chosen footprint, same principle as battleScaleFront/Back
  -- already used for battle sprites elsewhere in this mod. Went through a
  -- live Mod Manager option (wild_display_height) and back twice; settled
  -- again as a fixed constant by explicit user decision, option removed
  -- from options.lua. Shared by both wild spawns and the follower (this
  -- function is exported/reused by overworld_followers.lua's own Gen 1
  -- makeFollower), and by the Gen 2 native-draw wrap further down this
  -- file.
  local DISPLAY_HEIGHT = 28
  local function displayHeight()
    return DISPLAY_HEIGHT
  end

  -- Gen 2: the SAME lossless assets/overworld art Gen 1 uses (correct
  -- asset, explicit user correction -- native draw's own walker sheet,
  -- assets/wild_walkers, is the wrong, lower-detail source for this),
  -- but native Gen 2's real draw signature/position convention is
  -- different from Gen 1's, confirmed by direct source read:
  -- src/world/gen2/Npc.lua's real `NPC:draw(ox, oy, scale)` takes
  -- already screen-space-adjusted ox/oy plus a uniform scale, not Gen
  -- 1's `draw(camX, camY)` world-camera-subtract convention
  -- drawLossless below is built around. Reusing drawLossless's own
  -- camX/camY math against Gen 2's real args is exactly what put the
  -- follower off-screen the first time -- this is a SEPARATE function
  -- with Gen 2's own correct anchor math, not a reuse.
  --
  -- Anchor point mirrors World:drawPeople's own billboard anchor exactly
  -- (src/world/gen2/World.lua: `billboard(ox + (entity.px + 8) * s, oy +
  -- (entity.py + 16) * s, body)`) -- the sprite's own feet in screen
  -- space, computed from the same ox/oy/scale args this wrap receives.
  -- displayHeight()/native-image-height gives the same scale-to-target
  -- ratio drawLossless already uses for Gen 1, just combined with the
  -- incoming uniform `scale` instead of a flat 1.
  --
  -- Covers both wild spawns (npc.ggdWildSpawn + npc.ggdSpecies, set
  -- where this file spawns them below) and the Gen 2 native follower
  -- (npc.pikachuFollower, set by src/world/gen2/Follower.lua itself;
  -- npc.ggdSpecies set by overworld_followers.lua's own sync) -- one
  -- shared wrap, installed here since this file loads before
  -- overworld_followers.lua. Falls back to native draw (the walker
  -- sheet) whenever the lossless art fails to load, same as Gen 1's own
  -- applyLosslessDraw -- never a blank NPC.
  if isGen2Boot then
    local npcOk, Gen2NPCClass = pcall(require, "src.world.gen2.Npc")
    if npcOk and Gen2NPCClass and not Gen2NPCClass.__galarSizeWrapped then
      Gen2NPCClass.__galarSizeWrapped = true
      local nativeNpcDraw = Gen2NPCClass.draw

      local function drawLosslessGen2(self, ox, oy, scale)
        local facing = self.facing or "down"
        local suffix, mirror
        if facing == "up" then suffix = "_up"
        elseif facing == "left" then suffix = "_left"
        elseif facing == "right" then suffix, mirror = "_left", true
        else suffix = "" end

        local frame = currentFrame(self, self.ggdSpecies, suffix)
        local img = loadOverworldImage(self.ggdSpecies, suffix, frame)
        if not img and suffix ~= "" then
          frame = currentFrame(self, self.ggdSpecies, "")
          img = loadOverworldImage(self.ggdSpecies, "", frame)
          mirror = false
        end
        if not img then
          img = loadCyndaquilFallback()
          mirror = false
        end
        if not img then return false end

        local iw, ih = img:getWidth(), img:getHeight()
        local drawScale = (displayHeight() / ih) * scale
        local dw, dh = iw * drawScale, ih * drawScale
        -- Horizontally centered on the tile; vertically anchored to the
        -- tile's OWN bottom edge (the ground line), not its center.
        -- Tile-center anchoring (the previous version) ties the vertical
        -- anchor to a FIXED point -- half of the native 16px tile,
        -- independent of WILD/FOLLOWER SIZE -- so growing the display
        -- height pushes the image's bottom edge below ground by
        -- (dh - tile_height)/2, an amount that gets WORSE the larger the
        -- size option is set. Ground-line anchoring keeps the same
        -- contact point at any size: the art only ever grows UPWARD from
        -- a fixed ground line, exactly like a taller-than-one-tile
        -- standing sprite should, and stays correct across the whole
        -- WILD/FOLLOWER SIZE range instead of only looking right at one
        -- specific value. Applies to every species' lossless crop
        -- uniformly, not a per-asset fix.
        local centerX = ox + (self.px + 8) * scale
        local groundY = oy + (self.py + 13) * scale
        local x = math.floor(centerX - dw / 2)
        local y = math.floor(groundY - dh)
        love.graphics.setColor(1, 1, 1, 1)
        if mirror then
          love.graphics.draw(img, x + dw, y, 0, -drawScale, drawScale)
        else
          love.graphics.draw(img, x, y, 0, drawScale, drawScale)
        end
        return true
      end

      function Gen2NPCClass:draw(ox, oy, scale)
        if scale == nil or not self.ggdSpecies
            or not (self.ggdWildSpawn or self.pikachuFollower) then
          return nativeNpcDraw(self, ox, oy, scale)
        end
        local ok, drew = pcall(drawLosslessGen2, self, ox, oy, scale)
        if ok and drew then return end
        if not ok then
          mod.log:warn("galar_gmax_dex: gen2 lossless draw failed for %s: %s",
            tostring(self.ggdSpecies), tostring(drew))
        end
        -- This entity's own registered sprite id points at the single
        -- shared assets/wild_walkers/placeholder.png (see overworld_
        -- spawns.lua's own Phase 1 header for why one shared file, not a
        -- per-species asset, is correct here) -- always present, so this
        -- native fallback path is safe again. Stays pcalled regardless:
        -- native SpriteRenderer's own image load (Assets.image, src/
        -- render/Assets.lua) has no pcall of its own, and the engine's
        -- render loop has none around entity:draw either (confirmed
        -- elsewhere in this file) -- an unguarded miss here would still
        -- crash the whole game rather than skip one entity's frame for
        -- any OTHER reason a draw might fail, not just a missing file.
        local nativeOk, nativeErr = pcall(nativeNpcDraw, self, ox, oy, scale)
        if not nativeOk then
          mod.log:warn("galar_gmax_dex: gen2 native draw fallback also failed for %s: %s",
            tostring(self.ggdSpecies), tostring(nativeErr))
        end
      end
    end
  end

  -- The engine's own render loop (src/world/OverworldController.lua,
  -- the "for _, e in ipairs(self.entities) do e:draw(...) end" pass) calls
  -- this every frame with ZERO pcall around it -- confirmed by reading
  -- that loop directly, not assumed. This function was originally written
  -- for our own NPC.new-created instances (guaranteed :pose()); it is now
  -- ALSO applied to Wilds-created wild-encounter entities
  -- (installWildDrawOverride in main.lua), which are not guaranteed to be
  -- shaped identically. Any uncaught error in here -- a missing :pose(),
  -- an unexpected nil field -- crashes the entire game outright rather
  -- than failing one frame's draw, since nothing upstream catches it.
  -- The whole body is wrapped in a pcall for exactly that reason: worst
  -- case is one entity silently not drawing for a frame, never a crash.
  local function drawLossless(self, camX, camY)
    -- Directional facing so the sprite shows which way it's actually
    -- walking instead of always the down/front crop. "right" is "_left"
    -- mirrored (see loadOverworldImage's own comment), not a fourth file.
    local facing = self.facing or "down"
    local suffix, mirror
    if facing == "up" then suffix = "_up"
    elseif facing == "left" then suffix = "_left"
    elseif facing == "right" then suffix, mirror = "_left", true
    else suffix = "" end

    local frame = currentFrame(self, self.ggdSpecies, suffix)
    local img = loadOverworldImage(self.ggdSpecies, suffix, frame)
    if not img and suffix ~= "" then
      -- directional crop missing for this species (should not happen for
      -- the generated roster, but never worse than the old single-frame
      -- behavior): fall back to the base down/front crop.
      frame = currentFrame(self, self.ggdSpecies, "")
      img = loadOverworldImage(self.ggdSpecies, "", frame)
      mirror = false
    end
    if not img then
      img = loadCyndaquilFallback()
      mirror = false
    end
    if not img then
      local sprite, px, py, poseFacing, phase, flip = self:pose()
      if sprite then sprite:draw(px, py, camX, camY, poseFacing, phase, flip) end
      return
    end
    local iw, ih = img:getWidth(), img:getHeight()
    local scale = displayHeight() / ih
    local dw, dh = iw * scale, ih * scale
    -- horizontally centered on the tile, feet anchored to the tile's
    -- own bottom edge -- same anchor convention native sprites use,
    -- just at the scaled display size instead of a fixed 16x16.
    local x = math.floor(self.px - camX + 8 - dw / 2)
    local y = math.floor(self.py - camY + 16 - dh)
    love.graphics.setColor(1, 1, 1, 1)

    if mirror then
      -- same "draw from the far edge with a negative scale" convention
      -- already used for follower mirroring in main.lua's SpriteRenderer
      -- draw wrap.
      love.graphics.draw(img, x + dw, y, 0, -scale, scale)
    else
      love.graphics.draw(img, x, y, 0, scale, scale)
    end
  end

  -- Shared with overworld_followers.lua (F1) and installWildDrawOverride
  -- (main.lua).
  mod.exports.applyLosslessDraw = function(npc, species)
    npc.ggdSpecies = species
    npc.draw = function(self, camX, camY)
      local ok, err = pcall(drawLossless, self, camX, camY)
      if not ok then
        love.graphics.setColor(1, 1, 1, 1)
        mod.log:warn("galar_gmax_dex: lossless draw failed for %s: %s",
          tostring(self.ggdSpecies), tostring(err))
      end
    end
  end

  -- Wilds of Kanto (overworld_wild_spawns) turned out to be far more than
  -- the placeholder it was assumed to be when this file's "full
  -- replacement" plan was written: reading its real source this session
  -- (spawn_render.lua, sprite_scale.lua, spawn_logic, cave_reachability,
  -- safari_compat, grass_occlusion, water_spawn, ...) shows a mature,
  -- actively-installed spawn/scale/collision engine with its own
  -- battle-tested one-tile-max sizing (SpriteScale.compute) that this
  -- file's own naive 1:1-pixel draw (applyLosslessDraw, above) has none of
  -- -- confirmed as the direct cause of the oversized, stuck wild sprite
  -- reported in-game. Exactly the same situation as Followers EX turning
  -- out to be a full pack/leader system rather than a simple sprite
  -- lookup (see overworld_followers.lua's own gate). So the same
  -- resolution applies here: when Wilds is present, everything BELOW this
  -- point (spawning, despawning, collision-to-battle) stays inactive and
  -- Wilds owns wild spawns entirely, fed our species' art through
  -- installOverworldSpriteProvider's "pokedex" provider hook in main.lua
  -- (now returning the native 16x96/frames=6/walker=true contract, so
  -- Wilds treats it as a first-class native sheet -- guaranteed one-tile
  -- size, real walk animation -- instead of routing it through the legacy
  -- single-frame scale path).
  --
  -- The sprite registration and mod.exports above this point stay
  -- UNGATED on purpose: overworld_followers.lua (F1) and voxel_billboards
  -- .lua both read mod.exports.wildSpriteIdFor/applyLosslessDraw
  -- independently of whether THIS file's own spawning is active -- a
  -- setup with Wilds installed but Followers EX absent still needs F1
  -- to have real sprite ids to hand its trailer NPCs.
  if mod.find("overworld_wild_spawns") then
    mod.log:info("galar_gmax_dex: Wilds of Kanto present -- native wild-spawn engine (W1) spawning stays inactive; installOverworldSpriteProvider covers our species instead")
    return
  end

  -- ------- Phase 2: spawn state + species/level selection -------------
  -- npcId -> { mapId, species, level }
  local activeSpawns = {}

  -- Live-read from Mod Manager -> GalarGmaxDex -> Max Per Map
  -- (installDebugOptions, main.lua) instead of a fixed constant, so
  -- density can be A/B tested without a restart.
  local function maxPerMap()
    return mod.options:get("wild_max_per_map") or 4
  end
  local MIN_ELIGIBLE_PER_SPAWN = 15 -- don't crowd tiny grass patches

  -- Mirrors Encounter.roll's own bucket-threshold algorithm (weighted
  -- slots out of 256) against the same mod.content.encounters data,
  -- without requiring the "did a step happen" gate that function assumes
  -- -- we always want a firm species+level pick for a tile we've already
  -- decided to spawn on.
  local DEFAULT_BUCKETS = { 51, 102, 141, 166, 191, 216, 229, 242, 252, 256 }

  local function rollSlot(grassDef)
    if not grassDef or not grassDef.slots or #grassDef.slots == 0 then
      return nil
    end
    local buckets = grassDef.buckets or DEFAULT_BUCKETS
    local pick = love.math.random(0, 255)
    for i, threshold in ipairs(buckets) do
      if pick < threshold then
        local slot = grassDef.slots[i]
        if slot then return slot.species, slot.level end
        return nil
      end
    end
    return nil
  end

  -- ------- Phase 3: eligible tile scan -------------------------------
  local function occupiedByAny(ow, x, y)
    for _, e in ipairs(ow.entities or {}) do
      if (e.cellX == x and e.cellY == y) or (e.targetX == x and e.targetY == y) then
        return true
      end
    end
    return false
  end

  local function findEligibleTiles(map, ow)
    local tiles = {}
    for y = 0, map.heightCells - 1 do
      for x = 0, map.widthCells - 1 do
        if map:isGrassCell(x, y) and map:isWalkableCell(x, y)
            and not (ow.player.cellX == x and ow.player.cellY == y)
            and not occupiedByAny(ow, x, y) then
          tiles[#tiles + 1] = { x = x, y = y }
        end
      end
    end
    return tiles
  end

  -- Fisher-Yates partial shuffle, just enough to pick N distinct tiles
  -- without biasing toward the scan order (row-major would otherwise
  -- always favor the top of the map).
  local function pickRandom(list, n)
    local picked = {}
    local pool = {}
    for i, v in ipairs(list) do pool[i] = v end
    n = math.min(n, #pool)
    for _ = 1, n do
      local i = love.math.random(1, #pool)
      picked[#picked + 1] = pool[i]
      pool[i] = pool[#pool]
      pool[#pool] = nil
    end
    return picked
  end

  -- ------- Phase 4: spawn / despawn lifecycle -------------------------
  local function despawnMap(mapId)
    for npcId, info in pairs(activeSpawns) do
      if info.mapId == mapId then
        mod.world:removeNpc(npcId)
        activeSpawns[npcId] = nil
      end
    end
  end

  local function populateMap(mapId)
    if not mod.options:get("wild_spawns_enabled") then return end
    local ow = mod.world:overworld()
    if not ow or not ow.map or ow.map.id ~= mapId then return end
    local map = ow.map
    local grass
    if isGen2Boot then
      -- ow.encounters/ow.daytime are real fields on the live Gen 2 World
      -- instance (the same table World:load reads into
      -- Game.data.gen2Encounters, and the same daytime World.lua's own
      -- "world.stepped" payload already exposes).
      local rate = Gen2Encounter.grassRate(ow.encounters, mapId, ow.daytime)
      if rate <= 0 then return end
      grass = true -- gate only; Gen 2's own roll below reads ow.encounters directly, not this
    else
      local encDef = Game.data and Game.data.encounters and Game.data.encounters[mapId]
      grass = encDef and encDef.grass
      if not grass or not grass.slots or #grass.slots == 0 then return end
    end

    local eligible = findEligibleTiles(map, ow)
    if #eligible < MIN_ELIGIBLE_PER_SPAWN then return end

    local target = math.min(maxPerMap(),
      math.floor(#eligible / MIN_ELIGIBLE_PER_SPAWN))
    if target < 1 then return end

    -- Each tile's spawn attempt is independently pcall'd: the "map.entered"
    -- event dispatcher already catches an error escaping this whole
    -- function (src/mods/Events.lua logs and skips a throwing listener),
    -- but that would abort every remaining tile in this loop too. One bad
    -- spawn (an unregistered sprite, a stale tile) should not cost the
    -- other 3.
    local tiles = pickRandom(eligible, target)
    for _, tile in ipairs(tiles) do
      local ok, err = pcall(function()
        local species, level
        if isGen2Boot then
          -- nil random param: Encounter.lua's own internal fallback
          -- (love.math.random(n) - 1) already normalizes to the 0..n-1
          -- range its `roll` helper expects -- love.math.random(n) alone
          -- returns 1..n and would be off by one if passed directly.
          local picked = Gen2Encounter.grassSlot(ow.encounters, mapId, ow.daytime, nil)
          species, level = picked and picked.species, picked and picked.level
        else
          species, level = rollSlot(grass)
        end
        if not (species and level) then return end
        local spriteId = spriteIdFor[species]
        if not spriteId then return end
        local objDef = isGen2Boot
          and { sprite = spriteId, x = tile.x, y = tile.y,
                movement = Gen2NPC.MOVE.WANDER, radius = { x = 2, y = 2 } }
          or { sprite = spriteId, x = tile.x, y = tile.y,
               movement = "WALK", range = "ANY_DIR" }
        local npcId, spawnErr = mod.world:spawnNpc(mapId, objDef)
        if not npcId then
          mod.log:warn("galar_gmax_dex: wild spawn failed for %s: %s",
            tostring(species), tostring(spawnErr))
          return
        end
        activeSpawns[npcId] = {
          mapId = mapId, species = species, level = level,
        }
        -- Was per-species (WALKERS_REL .. "/" .. species .. ".png") before
        -- the shared-placeholder redesign above -- every species' native
        -- sprite now points at the SAME file, so this pre-filters that
        -- one path (filteredPaths' own cache makes every call after the
        -- first a no-op, so this is cheap regardless of call frequency).
        ensureNearestFilter(WALKER_PLACEHOLDER)
        for _, npc in ipairs(ow.npcs or {}) do
          if npc.id == npcId then
            -- Gen 1 only: applyLosslessDraw replaces npc.draw with a
            -- 2-arg (camX, camY) function using Gen1's own "subtract
            -- camera position" convention. Confirmed by direct source
            -- read that Gen 2's real NPC:draw(ox, oy, scale) is a 3-arg
            -- method with a DIFFERENT, documented convention (its own
            -- 2-arg compat shim negates and recurses rather than
            -- subtracting) -- calling our override with Gen 2's real
            -- args feeds it the wrong-convention coordinates, which is
            -- why nothing drew (or drew off-screen). Native draw
            -- (already correctly wired for every other Gen 2 NPC) using
            -- the registered walker sprite is the right, already-
            -- precedented fallback here -- same reasoning this file's
            -- own header already uses for the Wilds-of-Kanto case
            -- ("fed our species' art through... the native 16x96/
            -- frames=6/walker=true contract instead of the legacy
            -- single-frame scale path").
            if not isGen2Boot then
              mod.exports.applyLosslessDraw(npc, species)
            else
              -- Marks this instance for the NPC:draw wrap above, which
              -- draws the same lossless assets/overworld art Gen 1 uses
              -- (via Gen 2's own correct draw signature/anchor math).
              npc.ggdWildSpawn = true
              npc.ggdSpecies = species
            end
            -- Explicit user decision: wild spawns no longer block movement
            -- (Collision.occupied treats passable=true as non-blocking, the
            -- same field F1's own follower already relies on). Contact
            -- still starts a battle -- see the proximity-based trigger
            -- below (Phase 6), which now runs unconditionally instead of
            -- only under voxel rendering, since Phase 5's own collision
            -- hook structurally cannot fire once nothing gets blocked.
            npc.passable = true
            break
          end
        end
      end)
      if not ok then
        mod.log:warn("galar_gmax_dex: wild spawn attempt errored: %s", tostring(err))
      end
    end
  end

  local currentMapId = nil
  mod.events:on("map.entered", function()
    local ow = mod.world:overworld()
    local mapId = ow and ow.map and ow.map.id
    if currentMapId and currentMapId ~= mapId then
      despawnMap(currentMapId)
    end
    currentMapId = mapId
    if mapId then populateMap(mapId) end
  end)

  -- Flipping "Wild Spawns" in Mod Manager takes effect immediately instead
  -- of waiting for the next map transition -- the whole point of a
  -- test-facing toggle is not having to walk through a door to see it.
  mod.events:on("mod.options_changed", function(payload)
    if not (payload and payload.mod == mod.id and payload.key == "wild_spawns_enabled") then
      return
    end
    if payload.value then
      if currentMapId then populateMap(currentMapId) end
    else
      if currentMapId then despawnMap(currentMapId) end
    end
  end)

  -- ------- Phase 5: contact -> battle ---------------------------------
  -- Same shape as the real Collision.lua "movement.collision" hook
  -- Wilds' own SpawnLogic:onCollision used: only ever intercepts when the
  -- blocked mover is the player and the blocking tile is one of our own
  -- tracked spawns; every other call passes straight through unchanged,
  -- so this cannot affect NPC-vs-NPC or NPC-vs-player collision checks
  -- elsewhere in the game.
  mod.hooks:wrap("movement.collision", function(nextFn, allowed, ctx)
    if not allowed and ctx and ctx.reason == "entity" then
      local ow = mod.world:overworld()
      if ow and ctx.mover == ow.player then
        for npcId, info in pairs(activeSpawns) do
          if info.mapId == (ow.map and ow.map.id) then
            local npc
            for _, n in ipairs(ow.npcs or {}) do
              if n.id == npcId then npc = n break end
            end
            if npc and npc.cellX == ctx.toX and npc.cellY == ctx.toY then
              -- queueScript fails (returns nil, "a script is already
              -- running") when another script/scene owns the runner right
              -- now -- confirmed from WorldAPI:queueScript directly. The
              -- old code ignored that return: it would despawn the wild
              -- Pokemon and remove it from activeSpawns unconditionally,
              -- so a collision landing in that window silently ate the
              -- encounter with no battle ever starting. Only consume the
              -- spawn once the battle script is actually confirmed queued;
              -- otherwise leave it alive and let the next collision retry.
              local queued, queueErr = mod.world:queueScript({
                { "start_battle", "wild", info.species, info.level },
              })
              if queued then
                activeSpawns[npcId] = nil
                mod.world:removeNpc(npcId)
                return false
              end
              mod.log:warn("galar_gmax_dex: wild battle script not queued (%s), leaving %s spawned",
                tostring(queueErr), tostring(info.species))
              return nextFn(allowed, ctx)
            end
          end
        end
      end
    end
    return nextFn(allowed, ctx)
  end)

  -- ------- Phase 6: proximity contact -> battle (all modes) -------------
  -- UPDATE: wild spawns are now passable (populateMap, above -- explicit
  -- user decision, "allow passing through wild pokemon entities"), so
  -- Phase 5's blocked-collision hook can structurally never fire again in
  -- ANY mode, flat 2D included, not just voxel -- nothing ever gets
  -- blocked for it to react to. This phase (originally built as a voxel-
  -- only fallback, see the history below) is what actually triggers
  -- contact now, everywhere; its own voxel-level gate was removed for
  -- that reason. Phase 5's code is left in place untouched regardless --
  -- it just never fires -- rather than deleting it, since removing it was
  -- never asked for and it costs nothing to leave inert.
  --
  -- Original (still accurate) history follows: this started as A
  -- SEPARATE, ADDITIVE system from Phase 5 above -- that hook was
  -- confirmed working for the classic 2D grid walk and was left
  -- completely untouched, on purpose. Dramatic Shape's own free-move/first-
  -- person driving mode (lib/FreeMove.lua) never reaches
  -- "movement.collision" at all: its own blockedCell() calls
  -- Collision.occupied() directly (~line 132), and pushSpecials() (~line
  -- 205) explicitly runs none of its handlers for an entity block --
  -- "why ~= 'entity'" gates every one of them, so a firm push against an
  -- NPC there is just a silent stop, never a hook call -- confirmed by
  -- reading that file directly, not assumed.
  --
  -- User confirmed the trigger fails on EVERY voxel level, not just the
  -- free-roam ones (1ST/3RD PERSON, EXPERIMENTAL) -- including the plain
  -- tilt angles (FULL/15/35/50/75), which do NOT swap movement at all
  -- (only FreeMove.lua and Horde.lua ever override OverworldState.
  -- handleInput, confirmed by grepping every file in DRAMATIC_SHAPE/lib;
  -- a tilt level uses the exact same grid walk / Collision.canMove /
  -- movement.collision chain as flat 2D). So this gate is deliberately
  -- "any voxel level at all," not "free-roam only" -- whatever is
  -- actually breaking Phase 5 under tilted rendering is not something
  -- this file can root-cause without editing Dramatic Shape's own code,
  -- which is off-limits. This is a blanket, additive safety net instead:
  -- reached via Voxel.level (VoxelState.lua, the same mod.exports.lib +
  -- V.require("...") pattern already used for SpriteBillboards/Voxel3D/
  -- FirstPerson elsewhere this session), nonzero at any level above OFF.
  --
  -- Detection is cell-adjacency + facing, not a raw pixel radius (the
  -- first version of this, radius-only, was calibrated for FreeMove's
  -- own sliding-collision-circle geometry alone and does not describe a
  -- grid-walking player at rest, who sits exactly 16px from an adjacent
  -- cell's center, never closer, until the step completes). "Player's
  -- current cell is directly adjacent to the spawn's current cell, in
  -- the direction the player is already facing" mirrors what a blocked
  -- step means on the grid, and reads the same way in free-roam (p.facing
  -- is still a discrete up/down/left/right there too -- FirstPerson.
  -- pointBody resolves the continuous look to one, confirmed from
  -- FreeMove.lua's own "p.facing = FirstPerson.pointBody(...)"), but the
  -- facing requirement is dropped below after the fact: the render-
  -- pipeline version of this check (facing-gated) was reported to still
  -- not trigger on any voxel level, and facing was one more thing that
  -- could be silently wrong (or a red herring) without a way to verify it
  -- live. Plain cell-adjacency (Manhattan distance <= 1, no facing check)
  -- is strictly more permissive -- it can only trigger MORE often, never
  -- less -- so it cannot be the reason contact was missed if the actual
  -- fault was there; it removes that variable rather than trusting it.
  --
  -- npc.px/py (not cellX/cellY*16) for the spawn's own cell: our wild
  -- spawns wander (movement="WALK") and are frequently mid-step, where
  -- cellX/cellY still names the cell being left, not the current one.
  --
  -- Two independent trigger paths, not one, because the render-pipeline
  -- present() callback's own reliability under voxel rendering could not
  -- be confirmed live (level > 0 gate, Pipelines.eligible, needPresent --
  -- all read correct from source, but "reads correct" is not the same as
  -- "confirmed firing" without a way to watch it run). "world.stepped"
  -- (src/world/OverworldController.lua ~3463-3467, inside
  -- OverworldState:onStepComplete) is a plain engine event fired on every
  -- completed step in EITHER mode -- FreeMove.tick calls onStepComplete
  -- itself on every cell crossing (confirmed directly, ~line 333) -- so
  -- this is about as close to "guaranteed to fire" as this mod can reach
  -- without editing Dramatic Shape's own files. Both paths call the same
  -- shared trigger function and are individually safe to double up (the
  -- "only consume on confirmed queue" removal from activeSpawns means
  -- whichever fires first wins; the second simply finds nothing left).
  local VOXEL_PIPELINE_ID = "ggd_voxel_wild_contact"

  local function currentVoxelLevel()
    local ds = mod.find("DRAMATIC_SHAPE")
    if not (ds and ds.exports and ds.exports.lib) then return 0 end
    local V = ds.exports.lib
    if type(V.require) ~= "function" then return 0 end
    local ok, VoxelState = pcall(V.require, "VoxelState")
    if not (ok and VoxelState) then return 0 end
    return tonumber(VoxelState.level) or 0
  end

  -- pcx/pcy are the player's continuous PIXEL center (not cell
  -- coordinates) -- explicit user decision to shrink this to a
  -- configurable radius (Mod Manager -> GalarGmaxDex -> Wild Contact
  -- Area, options.lua) instead of the previous fixed "adjacent cell"
  -- check, which was reported too generous (a full 16px center-to-center
  -- reach in every direction). Euclidean, not axis-separated, so the
  -- shrink applies evenly regardless of approach angle.
  local function triggerAdjacentVoxelSpawn(ow, mapId, pcx, pcy)
    local radius = tonumber(mod.options:get("wild_contact_radius")) or 13
    local radiusSq = radius * radius
    for npcId, info in pairs(activeSpawns) do
      if info.mapId == mapId then
        local npc
        for _, n in ipairs(ow.npcs or {}) do
          if n.id == npcId then npc = n break end
        end
        if npc then
          local ncx = (npc.px or ((npc.cellX or 0) * 16)) + 8
          local ncy = (npc.py or ((npc.cellY or 0) * 16)) + 8
          local dx, dy = pcx - ncx, pcy - ncy
          if (dx * dx + dy * dy) <= radiusSq then
            -- same "only consume on confirmed queue" fix as Phase 5 above.
            local queued, queueErr = mod.world:queueScript({
              { "start_battle", "wild", info.species, info.level },
            })
            if queued then
              activeSpawns[npcId] = nil
              mod.world:removeNpc(npcId)
            else
              mod.log:warn("galar_gmax_dex: voxel wild battle script not queued (%s), leaving %s spawned",
                tostring(queueErr), tostring(info.species))
            end
            return true
          end
        end
      end
    end
    return false
  end

  -- No longer gated on currentVoxelLevel() > 0: wild spawns are now
  -- passable (populateMap, above), so Phase 5's blocked-collision hook
  -- structurally cannot fire in ANY mode any more, not just under voxel
  -- rendering -- this proximity check is now the universal contact
  -- trigger, flat 2D included, not just a voxel-specific safety net.
  -- currentVoxelLevel() is left defined above in case a future pass wants
  -- voxel-specific tuning again; nothing currently reads it.
  local function checkVoxelContact()
    local ow = mod.world:overworld()
    if not (ow and ow.player and ow.map) then return end
    local p = ow.player
    local pcx = (p.px or 0) + 8
    local pcy = (p.py or 0) + 8
    triggerAdjacentVoxelSpawn(ow, ow.map.id, pcx, pcy)
  end

  mod.content.render_pipelines:register(VOXEL_PIPELINE_ID, {
    label = "GALAR WILD VOXEL CONTACT",
    levels = { "OFF", "ON" },
    priority = 1,
    available = function() return true end,
    present = function(canvas, ctx)
      local ok = pcall(checkVoxelContact)
      if not ok then
        mod.log:warn("galar_gmax_dex: voxel wild-contact check errored")
      end
      return canvas
    end,
  })
  do
    local ok, Pipelines = pcall(require, "src.render.Pipelines")
    if ok and Pipelines and Pipelines.setLevel then
      Pipelines.setLevel(VOXEL_PIPELINE_ID, 1) -- default ON, matching F1's own convention
    end
  end

  -- Second, independent path: fires once per completed step, in any mode,
  -- regardless of whether the render pipeline above is actually running.
  -- Also no longer voxel-gated, for the same passable-spawns reason above.
  mod.events:on("world.stepped", function(payload)
    local ok = pcall(function()
      if not payload then return end
      local ow = mod.world:overworld()
      if not (ow and ow.player and ow.map) then return end
      if ow.map.id ~= payload.mapId then return end
      -- payload.x/y are cells (world.stepped's own payload shape); convert
      -- to the same pixel-center space triggerAdjacentVoxelSpawn now uses.
      triggerAdjacentVoxelSpawn(ow, payload.mapId,
        (payload.x or 0) * 16 + 8, (payload.y or 0) * 16 + 8)
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: voxel wild-contact step check errored")
    end
  end)

  mod.log:info("galar_gmax_dex: native wild-spawn engine active (Phase 7 W1)")
end
