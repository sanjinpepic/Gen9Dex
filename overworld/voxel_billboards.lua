-- Dramatic Shape voxel billboard override (optional, higher-risk).
--
-- Explicit user decision after being warned of the risk: Dramatic Shape's
-- 3D voxel billboard is a hard-coded 16x16 world-unit quad
-- (lib/SpriteBillboards.lua buildCard: verts run 0..16 in both axes,
-- UVs assume a frame*16 vertical slice into the source sheet) shared by
-- three passes -- the solid draw, the sun/shadow pass, and the player's
-- own occlusion silhouette -- which the source's own comment calls
-- "load-bearing, not tidiness": those three must agree on the exact same
-- mesh or shadows/occlusion break.
--
-- Confirmed this session, not assumed: simply enlarging the mesh alone
-- would NOT add detail -- it would stretch the same low-resolution
-- 16x96 native walker texture over a bigger quad. Two things have to
-- change together, and only for our own species' sprite ids, so nothing
-- else in the game is affected:
--   1. SpriteRenderer.resolveImage (already wrapped once, by
--      installFollowerSpriteHook in main.lua, but only for Followers EX's
--      own sprite ids) needs a SEPARATE wrap here for our
--      SPRITE_GGD_WILD_*/SPRITE_GGD_FOLLOWER_* ids, redirecting to the
--      lossless assets/overworld/<species>.png crop. Safe to do
--      unconditionally (not just for the voxel path): the classic 2D
--      NPC:draw is already overridden per-instance (overworld_spawns.lua
--      applyLosslessDraw) to bypass sprite:draw()/resolveImage() entirely
--      for these entities, so this redirect is only ever actually reached
--      by Dramatic Shape's own VoxelScene code, which calls
--      sprite:resolveImage() directly.
--   2. SpriteBillboards.mesh/shadowQuad need a matching override: the
--      lossless crop is one whole static image, not a frame*16 vertical
--      strip, so the quad this builds uses the FULL image as its UV rect
--      (u0,v0,u1,v1 = 0,0,1,1) instead of slicing a 16px band out of it.
--      Both the "mesh" name and its shadowQuad alias get the same
--      override (SpriteBillboards.lua aliases them to literally the same
--      function already, by design, for exactly the consistency reason
--      above) -- overriding both call sites once, correctly, rather than
--      relying on the alias to carry a partial fix.
--
-- Quad sizing: keeps the same "16 world units tall" convention every
-- other billboard uses (so our species doesn't tower over the player/
-- NPCs), but lets width follow the source crop's own aspect ratio
-- instead of forcing a square -- avoids squashing non-square art (the
-- roster has some: e.g. Rillaboom's own 72x64 source tile). Height is
-- fixed at the vanilla constant specifically so occlusion/shadow
-- geometry stays proportioned the way the rest of the world expects;
-- only width varies per species.
--
-- Because SpriteBillboards.mesh/resolveImage are shared, global module
-- tables (not per-instance), this can only be safely overridden ONCE
-- process-wide -- guarded the same way every other cross-mod wrap in
-- this codebase guards itself.
return function(mod)
  mod.events:on("mods.loaded", function()
    local ok = pcall(function()
      local ds = mod.find("DRAMATIC_SHAPE")
      if not (ds and ds.exports and ds.exports.lib) then return end
      local V = ds.exports.lib
      if type(V.require) ~= "function" then return end

      local okSB, SpriteBillboards = pcall(V.require, "SpriteBillboards")
      local okV3, Voxel3D = pcall(V.require, "Voxel3D")
      if not (okSB and SpriteBillboards and okV3 and Voxel3D) then return end
      if SpriteBillboards.__galarVoxelWrapped then return end
      SpriteBillboards.__galarVoxelWrapped = true

      local SpriteRenderer = require("src.render.SpriteRenderer")
      local Assets = require("src.render.Assets")

      -- id -> species, for both wild-spawn and follower sprite ids this
      -- mod registers (SPRITE_GGD_WILD_<species> from overworld_spawns.lua
      -- -- the follower reuses the exact same registry, see that file's
      -- own mod.exports.wildSpriteIdFor).
      local speciesForId = {}
      do
        local map = mod.exports and mod.exports.wildSpriteIdFor
        if map then
          for species, spriteId in pairs(map) do
            speciesForId[spriteId] = species
          end
        end
      end

      local function overworldPath(species)
        return mod.path .. "/assets/overworld/" .. species .. ".png"
      end

      -- ------- 1: redirect the texture for our sprite ids ---------------
      local origResolveImage = SpriteRenderer.resolveImage
      function SpriteRenderer:resolveImage(...)
        local id = self.def and self.def.id
        local species = id and speciesForId[id]
        if species then
          local ok2, img = pcall(Assets.image, overworldPath(species))
          if ok2 and img then
            img:setFilter("nearest", "nearest")
            self.image = img
            return img
          end
        end
        return origResolveImage(self, ...)
      end

      -- ------- 2: whole-image, non-sliced quad for the same ids ---------
      local BILLBOARD_HEIGHT = 24 -- vanilla constant every other billboard uses
      local customMeshes = {}

      local function buildWholeImageCard(species)
        local ok2, img = pcall(Assets.image, overworldPath(species))
        if not (ok2 and img) then return nil end
        img:setFilter("nearest", "nearest")
        local iw, ih = img:getDimensions()
        if not (iw and ih and iw > 0 and ih > 0) then return nil end
        local h = BILLBOARD_HEIGHT
        local w = h * (iw / ih)
        local u0, u1 = 0.02 / iw, (iw - 0.02) / iw
        local v0, v1 = 0.02 / ih, (ih - 0.02) / ih
        local verts = {
          { 0, 0, 0, u0, v1, 1 }, { w, 0, 0, u1, v1, 1 },
          { w, h, 0, u1, v0, 1 }, { 0, h, 0, u0, v0, 1 },
        }
        local indices = {}
        Voxel3D.pushQuad(indices, 0)
        local okMesh, mesh = pcall(Voxel3D.newMesh, verts, indices)
        if not okMesh then return nil end
        return mesh
      end

      local origMesh = SpriteBillboards.mesh
      local function customMesh(def, frame)
        local id = def and def.id
        local species = id and speciesForId[id]
        if species then
          if customMeshes[species] == nil then
            customMeshes[species] = buildWholeImageCard(species) or false
          end
          local mesh = customMeshes[species]
          if mesh then return mesh end
        end
        return origMesh(def, frame)
      end
      SpriteBillboards.mesh = customMesh
      SpriteBillboards.shadowQuad = customMesh

      mod.log:info("galar_gmax_dex: Dramatic Shape voxel billboard override active (%d species)",
        (function() local n = 0 for _ in pairs(speciesForId) do n = n + 1 end return n end)())
    end)
    if not ok then
      mod.log:warn("galar_gmax_dex: failed to install Dramatic Shape voxel billboard override")
    end
  end)
end
