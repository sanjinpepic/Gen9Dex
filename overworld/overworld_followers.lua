-- Native overworld follower engine (F1: core).
--
-- Full replacement for Followers EX's role, owned by GalarGmaxDex, per the
-- same explicit "full replacement" decision as overworld_spawns.lua (W1).
--
-- The trailing-follow algorithm (spawn cell, one-step-behind trail
-- chasing, map-connection rebasing) is adapted directly from the real
-- engine's own src/world/PikachuFollower.lua -- Yellow's native following
-- Pikachu, a proven, already-correct implementation -- generalized from a
-- single hardcoded species to whichever party member currently leads.
-- Deliberately NOT ported: happiness/mood, TalkToPikachu emotion bubbles,
-- the Bill's House scripted scene, ledge-hop doubling, and the "two or
-- more cells behind -> half step length" fast-follow rule. Those are
-- real, tuned behaviors in the source (each with its own historical
-- bug-fix commentary), but F1's scope is "a follower walks behind the
-- player showing the right species" -- not a byte-exact port of Yellow's
-- own companion. Can be added in a later pass if wanted.
--
-- Per-frame tick mechanism: confirmed directly from Wilds of Kanto's own
-- lib/behavior_tick.lua that Gen1Recomp has no world.tick mod event --
-- NPC:update only runs automatically for entries in ow.npcs with
-- movement=="WALK", which this follower deliberately isn't (movement=
-- "STAY", it moves by direct control, not autonomous wander). A
-- present-only mod.content.render_pipelines entry is the same documented,
-- public mechanism Wilds itself relies on for exactly this problem.
return function(mod)
  -- Followers EX (lib/ControlEngine.lua) is a full, actively-installed
  -- control/pack/leader system (pack size, box leader, control-mode
  -- switching, ledge hops, Yellow-specific companion handling) -- reading
  -- its real source this session showed it is far more than a sprite
  -- lookup: it owns the entire party-follower feature, spawning its own
  -- trailer NPCs independently of anything below. If this file's own F1
  -- engine also spawned a follower NPC alongside it, the player would see
  -- two followers trailing (one from each system) rather than one wrong
  -- one. So when Followers EX is present, this whole native replacement
  -- stays inactive -- the correct-species fix lives in main.lua's
  -- installFollowerSpriteHook, which patches Followers EX's own sprite
  -- resolution/draw in place instead of competing with it. This mirrors
  -- the same "if X is present, adjust for X; else use our own" pattern
  -- already used for gen1_modern_ui's party icons.
  if mod.find("FOLLOWERS_EX") then
    mod.log:info("galar_gmax_dex: Followers EX present -- native follower engine (F1) stays inactive; installFollowerSpriteHook covers our species instead")
    return
  end

  local Game = require("src.core.Game")

  -- Gen 2: skip this file's own Gen1-NPC/Collision-based F1 engine
  -- entirely and instead turn ON the engine's own native Gen 2 follower
  -- (src/world/gen2/Follower.lua), which already implements spawn/
  -- update/remove/trail -- it's just disabled by design ("Gold has no
  -- companion, so vanilla answers no", that file's own comment).
  -- Follower.setShouldSpawn/Follower.SPRITE are the real, documented mod
  -- extension points (the same file-local-upvalue pattern Gen2Compat
  -- .lua's own debug.setupvalue note describes for Gen 1 follower mods)
  -- -- adjusting the real thing instead of porting F1's own trailing
  -- algorithm against a different Npc/Player field vocabulary. Same
  -- "if X already does this, adjust for X" pattern the FOLLOWERS_EX
  -- branch above already uses.
  --
  -- Known, accepted gap, not fixed here: Gen 2's World:tryConnection
  -- never calls Follower.rebase() on a map-seam crossing (confirmed by
  -- reading src/world/gen2/World.lua directly -- Gen 1's own
  -- crossConnection does both keepPikachu-threading and the rebase
  -- call) -- so the follower respawns behind the player on a map
  -- crossing instead of smoothly walking across the seam like Gen 1's
  -- does. Engine-source gap, not something a mod can fix from here.
  local GameVersion = require("src.core.GameVersion")
  if GameVersion.generation(GameVersion.get()) == 2 then
    local ok, Follower = pcall(require, "src.world.gen2.Follower")
    if not ok or type(Follower) ~= "table" then
      mod.log:warn("galar_gmax_dex: gen2 native follower module not found, follower stays off")
      return
    end

    -- Same "first non-fainted party member" rule as F1's own Gen 1
    -- currentLeader, defined further down for the Gen 1 path -- kept as
    -- its own small copy here rather than sharing, since the Gen 1 path
    -- never runs once this branch returns.
    local function leadMon(save)
      for _, mon in ipairs(save and save.party or {}) do
        if (mon.hp or 0) > 0 then return mon end
      end
      return nil
    end

    Follower.setShouldSpawn(function(game)
      if not mod.options:get("follower_enabled") then return false end
      return leadMon(game and game.save) ~= nil
    end)

    -- Follower.SPRITE is a single shared field, by design (see that
    -- file's own header) -- kept pointed at the CURRENT lead's species,
    -- and mirrored onto an already-live follower NPC in place (the same
    -- direct-field-mutation extension point spriteDefFor's own comment
    -- describes: "a mod overwrites npc.sprite the line after NPC.new"),
    -- so a mid-map lead switch updates the visible sprite immediately
    -- instead of waiting for the next respawn.
    -- npc.sprite still needs a real resolved SpriteRenderer instance as
    -- the native walker-sheet fallback (see overworld_spawns.lua's own
    -- Gen 2 NPC:draw wrap -- it falls back to native draw whenever the
    -- lossless assets/overworld art fails to load, so this can't be
    -- skipped even though the lossless art is the normal path). NOT
    -- Gen 1's applyLosslessDraw itself: that replaces npc.draw with a
    -- 2-arg (camX, camY) function using Gen 1's "subtract camera
    -- position" convention, but Gen 2's real NPC:draw(ox, oy, scale) is
    -- a 3-arg method with a different, documented convention -- the
    -- actual lossless draw for Gen 2 is installed once, centrally, in
    -- overworld_spawns.lua's own NPC:draw wrap (loaded before this
    -- file), keyed off npc.ggdSpecies (set below) and npc.pikachuFollower
    -- (already set natively).
    local SpriteRenderer = require("src.render.SpriteRenderer")
    local lastSyncedSpecies = nil
    local function syncFollowerSpecies()
      local lead = leadMon(Game and Game.save)
      local species = lead and lead.species
      if not species or species == lastSyncedSpecies then return end
      local spriteMap = mod.exports and mod.exports.wildSpriteIdFor
      local spriteId = spriteMap and spriteMap[species]
      if not spriteId then return end
      local world = mod.world and mod.world:overworld()
      local spriteDef = world and world.sprites and world.sprites[spriteId]
      if not spriteDef then return end
      lastSyncedSpecies = species
      Follower.SPRITE = spriteId
      local npc = Follower.current(world)
      if npc then
        -- npc.sprite is a real SpriteRenderer INSTANCE built from the
        -- resolved def, not the raw string id (confirmed src/world/gen2
        -- /Npc.lua:256 -- NPC.new itself does `SpriteRenderer.new(
        -- spriteDef, uniqueId)`) -- a live re-sync has to build the same
        -- kind of object, not just overwrite the field with an id string.
        npc.sprite = SpriteRenderer.new(spriteDef, npc.id or ("ggd_follower_" .. species))
        npc.spriteDef = spriteDef
        npc.ggdSpecies = species
      end
    end

    mod.events:on("map.entered", function()
      -- Force a re-sync so a freshly-spawned follower always shows the
      -- right species from its very first frame, not just after the
      -- next poll.
      lastSyncedSpecies = nil
      syncFollowerSpecies()
    end)
    -- No party-reorder/switch event exists to hook directly (confirmed
    -- nothing more specific this session) -- world.stepped is a cheap,
    -- already-proven poll-based fallback (overworld_spawns.lua's own W1
    -- voxel-contact phase uses the identical reasoning for the same
    -- "no better hook" situation).
    mod.events:on("world.stepped", syncFollowerSpecies)

    mod.log:info("galar_gmax_dex: gen 2 native follower enabled and species-synced (F1 gen2)")
    return
  end

  local Collision = require("src.world.Collision")
  local NPC = require("src.world.NPC")

  local PIPELINE_ID = "ggd_follower_tick"
  local FOLLOWER_INDEX = 98 -- synthetic, clear of any map's real objects (Yellow's own Pikachu uses 99)

  -- ------- species -> sprite lookup, shared with overworld_spawns.lua ---
  -- Both wild spawns and the follower draw the exact same native walker
  -- art (assets/wild_walkers/<ID>.png); overworld_spawns.lua already
  -- registered a sprite id per available species this same mod load, so
  -- this reuses that registry instead of re-registering (mod.content.
  -- sprites:register would error on a duplicate id) or duplicating the
  -- directory scan. Falls back to an empty table (follower simply can't
  -- spawn) if load order or an earlier failure left it unset -- never a
  -- hard error.
  local function spriteIdFor(species)
    local map = mod.exports and mod.exports.wildSpriteIdFor
    return map and map[species]
  end

  -- ------- leader selection --------------------------------------------
  -- F1 scope: the first non-fainted party member, no manual "set leader"
  -- UI (that's later-phase scope, matching Followers EX's own LEADER
  -- option). Re-evaluated every tick so fainting/switching/depositing the
  -- current leader naturally hands the follower to the next eligible mon.
  local function currentLeader(save)
    for _, mon in ipairs(save and save.party or {}) do
      if (mon.hp or 0) > 0 then return mon end
    end
    return nil
  end

  -- ------- follower entity -----------------------------------------------
  local function findFollower(ow)
    for i, npc in ipairs(ow.npcs or {}) do
      if npc.ggdFollower then return npc, i end
    end
    return nil
  end

  local function removeFollower(ow)
    local npc, i = findFollower(ow)
    if not npc then return end
    table.remove(ow.npcs, i)
    for j, e in ipairs(ow.entities or {}) do
      if e == npc then table.remove(ow.entities, j) break end
    end
    ow.ggdFollowerTrail = nil
  end

  -- Directly behind the player's facing when that cell is walkable, else
  -- the player's own cell (trails out on the first step), matching
  -- PikachuFollower.spawnCell exactly.
  local function spawnCell(ow)
    local p = ow.player
    local dx = p.facing == "left" and 1 or p.facing == "right" and -1 or 0
    local dy = p.facing == "up" and 1 or p.facing == "down" and -1 or 0
    local bx, by = p.cellX + dx, p.cellY + dy
    if ow.map:inBounds(bx, by) and ow.map:isWalkableCell(bx, by) then
      return bx, by
    end
    return p.cellX, p.cellY
  end

  local function makeFollower(species, x, y, facing)
    local spriteId = spriteIdFor(species)
    if not spriteId then return nil end
    local npc = NPC.new(Game.data, "ggd_follower", {
      index = FOLLOWER_INDEX, name = "GGD_FOLLOWER", sprite = spriteId,
      movement = "STAY", range = "NONE", x = x, y = y,
    })
    npc.ggdFollower = true
    npc.ggdSpecies = species
    npc.passable = true -- never blocks a step (Collision.occupied)
    npc.facing = facing or "down"
    -- Same lossless custom-draw override as wild spawns (classic 2D
    -- overworld only, see overworld_spawns.lua's own comment for the
    -- full reasoning) -- reused rather than duplicated here.
    local applyLossless = mod.exports and mod.exports.applyLosslessDraw
    if applyLossless then applyLossless(npc, species) end
    return npc
  end

  local function spawnFollower(ow, viaMapLoad)
    local leader = currentLeader(Game.save)
    if not leader then return end
    local x, y
    if viaMapLoad then
      x, y = ow.player.cellX, ow.player.cellY
    else
      x, y = spawnCell(ow)
    end
    local npc = makeFollower(leader.species, x, y, ow.player.facing)
    if not npc then return end
    table.insert(ow.npcs, npc)
    table.insert(ow.entities, npc)
    ow.ggdFollowerTrail = { x = ow.player.cellX, y = ow.player.cellY }
  end

  -- ------- map lifecycle -------------------------------------------------
  mod.events:on("map.entered", function()
    local ow = mod.world:overworld()
    if not ow or not ow.map then return end
    removeFollower(ow)
    if mod.options:get("follower_enabled") and currentLeader(Game.save) then
      spawnFollower(ow, true)
    end
  end)

  -- Mod Manager -> GalarGmaxDex -> Follower toggle takes effect
  -- immediately (test-facing option, same reasoning as the wild-spawns
  -- one in overworld_spawns.lua) instead of waiting for a map change.
  mod.events:on("mod.options_changed", function(payload)
    if not (payload and payload.mod == mod.id and payload.key == "follower_enabled") then
      return
    end
    local ow = mod.world:overworld()
    if not ow then return end
    if payload.value then
      if not findFollower(ow) and currentLeader(Game.save) then
        spawnFollower(ow, false)
      end
    else
      removeFollower(ow)
    end
  end)

  -- ------- one trailing step per tick ------------------------------------
  -- Adapted from PikachuFollower.update: chase the cell the player last
  -- vacated, staying exactly one step behind. destX/destY read
  -- p.targetX/targetY while a step is in flight (the follow command is
  -- queued the frame the player commits a step, not the frame it lands --
  -- see the source's own detailed comment on why watching cellX/cellY
  -- alone opens a two-tile gap) and fall back to cellX/cellY while
  -- standing, so a warp/teleport still registers.
  local function tick()
    local ow = mod.world:overworld()
    if not ow or not ow.map or not ow.player then return end

    if not mod.options:get("follower_enabled") then
      local existing = findFollower(ow)
      if existing then removeFollower(ow) end
      return
    end

    local leader = currentLeader(Game.save)
    local npc = findFollower(ow)

    if not leader then
      if npc then removeFollower(ow) end
      return
    end
    if not npc then
      spawnFollower(ow, false)
      return
    end
    if npc.ggdSpecies ~= leader.species then
      -- leader changed (switch, faint-through, catch, deposit) -- respawn
      -- with the new species' art at the follower's own current cell so
      -- it doesn't jump.
      local x, y, facing = npc.cellX, npc.cellY, npc.facing
      removeFollower(ow)
      local fresh = makeFollower(leader.species, x, y, facing)
      if fresh then
        table.insert(ow.npcs, fresh)
        table.insert(ow.entities, fresh)
      end
      return
    end

    local p = ow.player
    local trail = ow.ggdFollowerTrail
    if not trail then
      trail = { x = p.cellX, y = p.cellY }
      ow.ggdFollowerTrail = trail
    end

    local destX = p.targetX or p.cellX
    local destY = p.targetY or p.cellY
    if destX ~= trail.x or destY ~= trail.y then
      npc.goalX, npc.goalY = trail.x, trail.y
      trail.x, trail.y = destX, destY
    end

    -- NPC:update(map, entities) is what actually advances self.progress
    -- and eventually flips self.moving back to false (src/world/NPC.lua) --
    -- but it is only auto-called by the core engine loop for movement==
    -- "WALK" NPCs, confirmed directly from that file. This follower is
    -- movement="STAY" on purpose (no autonomous wander), so nothing else
    -- ever calls :update() on it -- this tick() is the ONLY caller. The
    -- previous version returned early here on the theory that "something
    -- else" kept driving progress once moving started; nothing does, so
    -- the follower took exactly one frame of a 16-frame step and then sat
    -- motionless -- moving stuck true -- for the rest of the map visit
    -- (the reported "ghost" that only cleared on the next map's
    -- removeFollower). Call update() every tick while moving instead of
    -- skipping it, so the step actually completes.
    if npc.moving then
      npc:update(ow.map, ow.entities)
      return
    end
    if not npc.goalX then return end -- nothing to chase, stand still

    if npc.cellX == npc.goalX and npc.cellY == npc.goalY then
      npc.goalX, npc.goalY = nil, nil
      return
    end

    -- fell more than a screen behind (forced movement, warp math): snap
    -- instead of visibly racing to catch up
    local far = math.abs(npc.cellX - npc.goalX) + math.abs(npc.cellY - npc.goalY)
    if far > 6 then
      npc.cellX, npc.cellY = npc.goalX, npc.goalY
      npc.px, npc.py = npc.goalX * 16, npc.goalY * 16
      npc.goalX, npc.goalY = nil, nil
      return
    end

    local dir
    if npc.cellX < npc.goalX then dir = "right"
    elseif npc.cellX > npc.goalX then dir = "left"
    elseif npc.cellY < npc.goalY then dir = "down"
    else dir = "up" end
    npc.facing = dir
    local d = Collision.DELTA[dir]
    npc.targetX = npc.cellX + d[1]
    npc.targetY = npc.cellY + d[2]
    npc.stepFrames = p.stepFramesCur or p.stepFrames or 16
    npc.moving = true
    npc.progress = 0
    -- this frame's NPC update pass already ran before this tick fires
    -- (present pipelines run after the world update -- see registration
    -- below), so burn the step's first frame now, matching
    -- PikachuFollower.update's own reasoning: without it the follower
    -- trails a pixel further every tile.
    npc:update(ow.map, ow.entities)
  end

  -- Map-connection seam crossing translates every entity's cell/pixel
  -- coords by a fixed delta (OverworldState:crossConnection) -- the
  -- follower has to move with it or it would appear to teleport back to
  -- the old map's coordinate frame for one frame. Exposed on mod.exports
  -- so nothing else needs to poll for this; if the engine emits a
  -- "world.connection_crossed"-style event in the future this can move
  -- there instead of being called manually.
  mod.exports.ggdFollowerRebase = function(ow, dx, dy)
    local npc = findFollower(ow)
    if not npc then return end
    npc.cellX, npc.cellY = npc.cellX + dx, npc.cellY + dy
    npc.px, npc.py = npc.px + dx * 16, npc.py + dy * 16
    if npc.targetX then npc.targetX = npc.targetX + dx end
    if npc.targetY then npc.targetY = npc.targetY + dy end
    if npc.goalX then npc.goalX = npc.goalX + dx end
    if npc.goalY then npc.goalY = npc.goalY + dy end
    local trail = ow.ggdFollowerTrail
    if trail then trail.x, trail.y = trail.x + dx, trail.y + dy end
  end

  -- ------- per-frame tick registration -----------------------------------
  mod.content.render_pipelines:register(PIPELINE_ID, {
    label = "GALAR FOLLOWER",
    levels = { "OFF", "ON" },
    priority = 1,
    available = function() return true end,
    present = function(canvas, ctx)
      tick()
      return canvas
    end,
  })
  do
    local ok, Pipelines = pcall(require, "src.render.Pipelines")
    if ok and Pipelines and Pipelines.setLevel then
      Pipelines.setLevel(PIPELINE_ID, 1) -- default ON, matching Wilds' own convention
    end
  end

  mod.log:info("galar_gmax_dex: native follower engine active (Phase 8 F1)")
end
