-- Wild-encounter area placements.
--
-- The grass/water encounter tables below (VIRIDIAN_FOREST through
-- POWER_PLANT) are copied verbatim from the standalone "All Catchable"
-- mod (all_catchable_mod, credited to Wowabox/Darklinkduck) -- GalarGmaxDex
-- is taking over ownership of this area-placement role from that mod, per
-- explicit user decision (2026-08-07). ROUTE_3 is the one deliberate
-- exception: replaced with a single-species URSHIFU table instead of its
-- original vanilla-completion content.
--
-- Mechanics confirmed directly against the real engine schema
-- (src/mods/Schemas.lua R.encounters) before writing this file, not
-- assumed from the source mod's usage alone:
-- - mod.content.encounters:patch(mapId, { grass = { rate, slots }, water = {...} })
--   is the only moddable surface for wild encounters; fishing-rod tables
--   live in a separate, ROM-derived data source this registry does not
--   reach.
-- - Generation 1's engine hard-caps every table at exactly 10 weighted
--   slots (20/20/15/10/10/10/5/5/4/1%, by slot position) -- confirmed by
--   the source mod's own changelog ("Slot 11 Mankey" never loaded).
-- - Patching `slots` replaces the array wholesale (record-semantics
--   registries deep-merge tables but replace arrays outright, per
--   src/mods/Merge.lua) -- there is no way to append one slot to an
--   existing table without re-listing every slot that should survive.
--   Every map below therefore lists a complete 10-slot table.
--
-- Standing rule if this mod is uninstalled/superseded further: the
-- original all_catchable_mod should be disabled in the Mod Manager once
-- this file is active, since both would patch the same maps and whichever
-- loads last silently wins for any map they both touch.

return function(mod)
  mod.content.encounters:patch("VIRIDIAN_FOREST", {
    grass = {
      slots = {
        { level = 3, species = "CATERPIE" },  -- 20%
        { level = 3, species = "WEEDLE" },    -- 20%

        { level = 4, species = "CATERPIE" },  -- 15%

        { level = 4, species = "WEEDLE" },    -- 10%
        { level = 5, species = "METAPOD" },   -- 10%
        { level = 5, species = "KAKUNA" },    -- 10%

        { level = 5, species = "BULBASAUR" },  -- 5%
        { level = 5, species = "BULBASAUR" },    -- 5%

        -- Rare version-independent encounter
        { level = 9, species = "PIKACHU" },   -- 4%
        { level = 5, species = "PIKACHU" },   -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_2", {
    grass = {
      slots = {
        { level = 6, species = "URSHIFU " },      -- 20%
        { level = 7, species = "URSHIFU" },     -- 20%

        { level = 8, species = "URSHIFU" },      -- 15%

        { level = 5, species = "URSHIFU" },     -- 10%
        { level = 6, species = "URSHIFU" },     -- 10%

        { level = 8, species = "URSHIFU" },     -- 10%

        { level = 8, species = "URSHIFU" },     -- 5%
        { level = 5, species = "URSHIFU" },      -- 5%

        { level = 9, species = "URSHIFU" },  -- 4%
        { level = 5, species = "URSHIFU" },  -- 1%
      },
    },
  })

  -- Deliberate exception: ROUTE_3 is ours, not the source mod's vanilla-
  -- completion table -- a single-species URSHIFU table instead.
  mod.content.encounters:patch("ROUTE_3", {
    grass = {
      slots = {
        { level = 6, species = "URSHIFU" },
        { level = 7, species = "URSHIFU" },
        { level = 8, species = "URSHIFU" },
        { level = 5, species = "URSHIFU" },
        { level = 6, species = "URSHIFU" },
        { level = 8, species = "URSHIFU" },
        { level = 8, species = "URSHIFU" },
        { level = 5, species = "URSHIFU" },
        { level = 4, species = "URSHIFU" },
        { level = 5, species = "URSHIFU" },
      },
    },
  })

  mod.content.encounters:patch("ROUTE_4", {
    grass = {
      slots = {
        { level = 8, species = "RATTATA" },   -- 20%
        { level = 8, species = "SPEAROW" },   -- 20%

        { level = 10, species = "RATTATA" },  -- 15%

        { level = 9, species = "SPEAROW" },   -- 10%
        { level = 6, species = "EKANS" },     -- 10%

        { level = 8, species = "EKANS" },     -- 10%

        { level = 10, species = "SPEAROW" },  -- 5%
        { level = 8, species = "MANKEY" },    -- 5%
        { level = 9, species = "MANKEY" },    -- 4%
        { level = 10, species = "MANKEY" },   -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_5", {
    grass = {
      slots = {
        { level = 13, species = "PIDGEY" },      -- 20%
        { level = 14, species = "RATTATA" },     -- 20%

        { level = 10, species = "MEOWTH" },      -- 15%

        { level = 11, species = "ABRA" },        -- 10%
        { level = 12, species = "ODDISH" },      -- 10%
        { level = 15, species = "RATTATA" },     -- 10%

        { level = 10, species = "MANKEY" },      -- 5%
        { level = 12, species = "BELLSPROUT" },  -- 5%

        { level = 5, species = "JIGGLYPUFF" },   -- 4%
        { level = 12, species = "ABRA" },        -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_6", {
    grass = {
      slots = {
        { level = 13, species = "PIDGEY" },      -- 20%
        { level = 13, species = "RATTATA" },     -- 20%

        { level = 11, species = "ABRA" },        -- 15%

        { level = 12, species = "ODDISH" },      -- 10%
        { level = 10, species = "MEOWTH" },      -- 10%
        { level = 12, species = "BELLSPROUT" },  -- 10%

        { level = 10, species = "MANKEY" },      -- 5%
        { level = 12, species = "MEOWTH" },      -- 5%

        { level = 5, species = "JIGGLYPUFF" },   -- 4%
        { level = 14, species = "ODDISH" },      -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_7", {
    grass = {
      slots = {
        { level = 19, species = "PIDGEY" },      -- 20%
        { level = 17, species = "RATTATA" },     -- 20%

        { level = 18, species = "ODDISH" },      -- 15%

        { level = 18, species = "MEOWTH" },      -- 10%
        { level = 19, species = "GROWLITHE" },   -- 10%
        { level = 18, species = "BELLSPROUT" },  -- 10%

        { level = 18, species = "MANKEY" },      -- 5%
        { level = 19, species = "VULPIX" },      -- 5%

        { level = 18, species = "ABRA" },        -- 4%
        { level = 19, species = "ABRA" },        -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_8", {
    grass = {
      slots = {
        { level = 18, species = "PIDGEY" },      -- 20%
        { level = 18, species = "RATTATA" },     -- 20%

        { level = 18, species = "MEOWTH" },      -- 15%

        { level = 17, species = "EKANS" },       -- 10%
        { level = 17, species = "SANDSHREW" },   -- 10%
        { level = 19, species = "GROWLITHE" },   -- 10%

        { level = 19, species = "VULPIX" },      -- 5%

        { level = 17, species = "ABRA" },        -- 5%
        { level = 18, species = "ABRA" },        -- 4%
        { level = 19, species = "ABRA" },        -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_9", {
    grass = {
      slots = {
        { level = 16, species = "RATTATA" },    -- 20%
        { level = 17, species = "SPEAROW" },    -- 20%

        { level = 18, species = "RATTATA" },    -- 15%

        { level = 16, species = "EKANS" },      -- 10%
        { level = 16, species = "SANDSHREW" },  -- 10%
        { level = 16, species = "NIDORAN_F" },  -- 10%

        { level = 16, species = "NIDORAN_M" },  -- 5%
        { level = 18, species = "RATICATE" },   -- 5%

        { level = 18, species = "NIDORINA" },   -- 4%
        { level = 18, species = "NIDORINO" },   -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_11", {
    grass = {
      slots = {
        { level = 15, species = "DROWZEE" },     -- 20%
        { level = 15, species = "SPEAROW" },     -- 20%

        { level = 14, species = "RATTATA" },     -- 15%

        { level = 14, species = "PIDGEY" },      -- 10%
        { level = 15, species = "EKANS" },       -- 10%
        { level = 15, species = "SANDSHREW" },   -- 10%

        { level = 17, species = "RATICATE" },    -- 5%
        { level = 17, species = "PIDGEOTTO" },   -- 5%

        -- Let's Go-inspired encounter
        { level = 18, species = "MR_MIME" },     -- 4%

        { level = 19, species = "PIDGEOTTO" },   -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_12", {
    grass = {
      slots = {
        { level = 23, species = "PIDGEY" },       -- 20%
        { level = 22, species = "VENONAT" },      -- 20%

        { level = 21, species = "DROWZEE" },      -- 15%

        { level = 22, species = "ODDISH" },       -- 10%
        { level = 22, species = "BELLSPROUT" },   -- 10%
        { level = 21, species = "RATTATA" },      -- 10%

        { level = 23, species = "RATTATA" },      -- 5%
        { level = 24, species = "GLOOM" },        -- 5%

        { level = 24, species = "WEEPINBELL" },   -- 4%
        { level = 25, species = "WEEPINBELL" },   -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_13", {
    grass = {
      slots = {
        { level = 22, species = "VENONAT" },      -- 20%
        { level = 23, species = "PIDGEY" },       -- 20%

        { level = 23, species = "DITTO" },        -- 15%

        { level = 22, species = "ODDISH" },       -- 10%
        { level = 22, species = "BELLSPROUT" },   -- 10%
        { level = 24, species = "GLOOM" },        -- 10%

        { level = 24, species = "VENONAT" },      -- 5%
        { level = 24, species = "WEEPINBELL" },   -- 5%

        -- Yellow-inspired encounter
        { level = 25, species = "FARFETCHD" },    -- 4%
        { level = 26, species = "WEEPINBELL" },   -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_14", {
    grass = {
      slots = {
        { level = 24, species = "VENONAT" },      -- 20%
        { level = 24, species = "RATTATA" },      -- 20%

        { level = 23, species = "DITTO" },        -- 15%

        { level = 25, species = "PIDGEOTTO" },    -- 10%
        { level = 24, species = "ODDISH" },       -- 10%
        { level = 24, species = "BELLSPROUT" },   -- 10%

        { level = 26, species = "VENONAT" },      -- 5%
        { level = 26, species = "RATICATE" },     -- 5%

        { level = 25, species = "RATICATE" },     -- 4%
        { level = 26, species = "RATICATE" },     -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_15", {
    grass = {
      slots = {
        { level = 26, species = "PIDGEOTTO" },    -- 20%
        { level = 25, species = "VENONAT" },      -- 20%

        { level = 23, species = "DITTO" },        -- 15%

        { level = 25, species = "ODDISH" },       -- 10%
        { level = 25, species = "BELLSPROUT" },   -- 10%
        { level = 25, species = "RATICATE" },     -- 10%

        { level = 27, species = "RATICATE" },     -- 5%
        { level = 26, species = "GLOOM" },        -- 5%

        { level = 26, species = "WEEPINBELL" },   -- 4%
        { level = 27, species = "WEEPINBELL" },   -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_21", {
    grass = {
      slots = {
        { level = 21, species = "RATTATA" },    -- 20%
        { level = 23, species = "PIDGEY" },     -- 20%

        { level = 30, species = "RATICATE" },   -- 15%

        { level = 23, species = "RATTATA" },    -- 10%
        { level = 21, species = "PIDGEY" },     -- 10%
        { level = 30, species = "PIDGEOTTO" },  -- 10%

        { level = 32, species = "PIDGEOTTO" },  -- 5%
        { level = 28, species = "TANGELA" },    -- 5%

        { level = 30, species = "TANGELA" },    -- 4%
        { level = 32, species = "TANGELA" },    -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_23", {
    grass = {
      slots = {
        { level = 26, species = "SPEAROW" },     -- 20%
        { level = 28, species = "SPEAROW" },     -- 20%

        { level = 31, species = "FEAROW" },      -- 15%

        { level = 26, species = "EKANS" },       -- 10%
        { level = 26, species = "SANDSHREW" },   -- 10%
        { level = 29, species = "DITTO" },       -- 10%

        { level = 26, species = "NIDORINA" },    -- 5%
        { level = 28, species = "NIDORINO" },    -- 5%

        { level = 28, species = "RHYHORN" },     -- 4%
        { level = 30, species = "RHYHORN" },     -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_24", {
    grass = {
      slots = {
        { level = 8, species = "CATERPIE" },      -- 20%
        { level = 8, species = "WEEDLE" },        -- 20%

        { level = 9, species = "ABRA" },          -- 15%

        { level = 10, species = "METAPOD" },      -- 10%
        { level = 10, species = "KAKUNA" },       -- 10%
        { level = 12, species = "PIDGEY" },       -- 10%

        { level = 13, species = "PIDGEY" },       -- 5%
        { level = 14, species = "PIDGEY" },       -- 5%

        { level = 13, species = "ODDISH" },       -- 4%
        { level = 14, species = "BELLSPROUT" },   -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_25", {
    grass = {
      slots = {
        { level = 12, species = "PIDGEY" },       -- 20%
        { level = 12, species = "RATTATA" },      -- 20%

        { level = 10, species = "ABRA" },         -- 15%

        { level = 10, species = "CATERPIE" },     -- 10%
        { level = 12, species = "METAPOD" },      -- 10%
        { level = 10, species = "WEEDLE" },       -- 10%

        { level = 12, species = "KAKUNA" },       -- 5%
        { level = 13, species = "KAKUNA" },       -- 5%

        { level = 13, species = "BELLSPROUT" },   -- 4%
        { level = 14, species = "ODDISH" },       -- 1%
      },
    },
  })

  mod.content.encounters:patch("ROUTE_22", {
    grass = {
      slots = {
        { level = 6, species = "PSYDUCK" },    -- 20%
        { level = 4, species = "PSYDUCK" },    -- 20%
        { level = 5, species = "RATTATA" },    -- 15%

        { level = 3, species = "SPEAROW" },    -- 10%
        { level = 5, species = "SPEAROW" },    -- 10%

        { level = 3, species = "MANKEY" },     -- 10%

        { level = 3, species = "NIDORAN_M" },  -- 5%
        { level = 3, species = "NIDORAN_F" },  -- 5%
        { level = 4, species = "SQUIRTLE" },    -- 4%

        { level = 4, species = "NIDORAN_M" },  -- 1%
      },
    },
  })

  mod.content.encounters:patch("SAFARI_ZONE_CENTER", {
    grass = {
      slots = {
        { level = 22, species = "NIDORAN_M" },  -- 20%
        { level = 25, species = "RHYHORN" },    -- 20%

        { level = 22, species = "VENONAT" },    -- 15%

        { level = 24, species = "EXEGGCUTE" },  -- 10%
        { level = 31, species = "NIDORINO" },   -- 10%

        -- Rare Eevee encounter
        { level = 23, species = "EEVEE" },       -- 10%

        { level = 31, species = "NIDORINA" },   -- 5%
        { level = 30, species = "PARASECT" },   -- 5%

        { level = 23, species = "SCYTHER" },     -- 4%
        { level = 23, species = "PINSIR" },      -- 1%
      },
    },
  })

  mod.content.encounters:patch("SAFARI_ZONE_EAST", {
    grass = {
      slots = {
        { level = 22, species = "NIDORAN_F" },   -- 20%
        { level = 22, species = "NIDORAN_M" },   -- 20%

        { level = 24, species = "EXEGGCUTE" },   -- 15%

        { level = 26, species = "RHYHORN" },     -- 10%
        { level = 23, species = "PARAS" },       -- 10%
        { level = 25, species = "EXEGGCUTE" },   -- 10%

        { level = 25, species = "TAUROS" },      -- 5%
        { level = 25, species = "KANGASKHAN" },  -- 5%

        -- Rare version-independent encounter
        { level = 23, species = "PINSIR" },       -- 4%

        -- Very rare starter encounter
        { level = 23, species = "BULBASAUR" },    -- 1%
      },
    },
  })

  mod.content.encounters:patch("SAFARI_ZONE_WEST", {
    grass = {
      slots = {
        { level = 25, species = "NIDORAN_M" },   -- 20%
        { level = 26, species = "DODUO" },       -- 20%

        { level = 23, species = "VENONAT" },     -- 15%

        { level = 24, species = "EXEGGCUTE" },   -- 10%
        { level = 33, species = "NIDORINO" },    -- 10%
        { level = 31, species = "VENOMOTH" },    -- 10%

        { level = 25, species = "NIDORAN_F" },   -- 5%
        { level = 26, species = "TAUROS" },      -- 5%

        -- Rare Safari encounters
        { level = 23, species = "SCYTHER" },     -- 4%
        { level = 28, species = "KANGASKHAN" },  -- 1%
      },
    },
  })

  mod.content.encounters:patch("SAFARI_ZONE_NORTH", {
    grass = {
      slots = {
        { level = 22, species = "NIDORAN_M" },   -- 20%
        { level = 26, species = "RHYHORN" },     -- 20%

        { level = 23, species = "PARAS" },       -- 15%

        { level = 25, species = "EXEGGCUTE" },   -- 10%
        { level = 30, species = "NIDORINO" },    -- 10%
        { level = 27, species = "EXEGGCUTE" },   -- 10%

        { level = 32, species = "VENOMOTH" },    -- 5%
        { level = 25, species = "KANGASKHAN" },  -- 5%

        { level = 28, species = "TAUROS" },      -- 4%
        { level = 26, species = "CHANSEY" },     -- 1%
      },
    },
  })

  mod.content.encounters:patch("SEAFOAM_ISLANDS_B2F", {
    grass = {
      slots = {
        { level = 30, species = "SEEL" },       -- 20%
        { level = 30, species = "SLOWPOKE" },   -- 20%

        { level = 32, species = "SEEL" },       -- 15%

        { level = 32, species = "SLOWPOKE" },   -- 10%
        { level = 28, species = "HORSEA" },     -- 10%
        { level = 30, species = "STARYU" },     -- 10%

        { level = 37, species = "SLOWBRO" },    -- 5%
        { level = 28, species = "SHELLDER" },   -- 5%

        { level = 30, species = "GOLBAT" },     -- 4%

        -- Rare starter encounter
        { level = 23, species = "SQUIRTLE" },   -- 1%
      },
    },
  })

  mod.content.encounters:patch("SEAFOAM_ISLANDS_B3F", {
    grass = {
      slots = {
        { level = 31, species = "SLOWPOKE" },   -- 20%
        { level = 31, species = "SEEL" },       -- 20%

        { level = 33, species = "SLOWPOKE" },   -- 15%

        { level = 33, species = "SEEL" },       -- 10%
        { level = 29, species = "HORSEA" },     -- 10%
        { level = 31, species = "SHELLDER" },   -- 10%

        { level = 31, species = "HORSEA" },     -- 5%
        { level = 29, species = "SHELLDER" },   -- 5%

        { level = 34, species = "JYNX" },       -- 4%
        { level = 37, species = "DEWGONG" },    -- 1%
      },
    },
  })

  mod.content.encounters:patch("SEAFOAM_ISLANDS_B4F", {
    grass = {
      slots = {
        { level = 31, species = "HORSEA" },      -- 20%
        { level = 31, species = "SHELLDER" },    -- 20%

        { level = 33, species = "HORSEA" },      -- 15%

        { level = 33, species = "SHELLDER" },    -- 10%
        { level = 29, species = "SLOWPOKE" },    -- 10%
        { level = 31, species = "SEEL" },        -- 10%

        { level = 31, species = "SLOWPOKE" },    -- 5%
        { level = 35, species = "OMANYTE" },     -- 5%

        { level = 35, species = "KABUTO" },      -- 4%
        { level = 35, species = "KABUTO" },      -- 1%
      },
    },
  })

  mod.content.encounters:patch("VICTORY_ROAD_1F", {
    grass = {
      slots = {
        { level = 43, species = "MAROWAK" },     -- 20%
        { level = 26, species = "GEODUDE" },     -- 20%

        { level = 22, species = "ZUBAT" },       -- 15%

        { level = 36, species = "ONIX" },        -- 10%
        { level = 39, species = "ONIX" },        -- 10%
        { level = 42, species = "ONIX" },        -- 10%

        { level = 41, species = "GRAVELER" },    -- 5%
        { level = 41, species = "GOLBAT" },      -- 5%

        { level = 42, species = "MACHOKE" },     -- 4%

        -- Rare alternate Fighting Dojo reward
        { level = 42, species = "HITMONLEE" },   -- 1%
      },
    },
  })

  mod.content.encounters:patch("VICTORY_ROAD_2F", {
    grass = {
      slots = {
        { level = 22, species = "MACHOP" },      -- 20%
        { level = 24, species = "GEODUDE" },     -- 20%

        { level = 26, species = "ZUBAT" },       -- 15%

        { level = 36, species = "ONIX" },        -- 10%
        { level = 39, species = "ONIX" },        -- 10%
        { level = 42, species = "ONIX" },        -- 10%

        { level = 41, species = "MACHOKE" },     -- 5%
        { level = 40, species = "GOLBAT" },      -- 5%

        { level = 40, species = "MAROWAK" },     -- 4%

        -- Rare alternate Fighting Dojo reward
        { level = 42, species = "HITMONCHAN" },  -- 1%
      },
    },
  })

  mod.content.encounters:patch("VICTORY_ROAD_3F", {
    grass = {
      slots = {
        { level = 24, species = "MACHOP" },       -- 20%
        { level = 26, species = "GEODUDE" },      -- 20%

        { level = 22, species = "ZUBAT" },        -- 15%

        { level = 40, species = "VENOMOTH" },     -- 10%
        { level = 45, species = "ONIX" },         -- 10%
        { level = 43, species = "GRAVELER" },     -- 10%

        { level = 41, species = "GOLBAT" },       -- 5%
        { level = 42, species = "MACHOKE" },      -- 5%

        -- Rare fossil encounter
        { level = 45, species = "AERODACTYL" },   -- 4%

        -- Very rare starter encounter
        { level = 23, species = "CHARMANDER" },   -- 1%
      },
    },
  })

  mod.content.encounters:patch("POKEMON_MANSION_B1F", {
    grass = {
      slots = {
        { level = 31, species = "KOFFING" },    -- 20%
        { level = 31, species = "GRIMER" },     -- 20%

        { level = 32, species = "RATICATE" },   -- 15%

        { level = 31, species = "DITTO" },      -- 10%
        { level = 30, species = "GROWLITHE" },  -- 10%
        { level = 30, species = "RATTATA" },    -- 10%

        { level = 33, species = "KOFFING" },    -- 5%
        { level = 32, species = "GRIMER" },     -- 5%

        -- Rare version-exclusive encounter
        { level = 35, species = "MAGMAR" },     -- 4%

        -- Secret mythical encounter
        { level = 10, species = "MEW" },        -- 1%
      },
    },
  })

  mod.content.encounters:patch("CERULEAN_CAVE_1F", {
    grass = {
      rate = 10,
      slots = {
        { level = 46, species = "GOLBAT" },      -- 20%
        { level = 46, species = "HYPNO" },       -- 20%

        { level = 46, species = "MAGNETON" },    -- 15%

        { level = 49, species = "DODRIO" },      -- 10%
        { level = 49, species = "VENOMOTH" },    -- 10%
        { level = 52, species = "ARBOK" },       -- 10%

        -- Trade evolution addition
        { level = 49, species = "ALAKAZAM" },    -- 5%

        { level = 52, species = "PARASECT" },    -- 5%

        { level = 53, species = "RAICHU" },      -- 4%
        { level = 53, species = "DITTO" },       -- 1%
      },
    },
  })

  mod.content.encounters:patch("CERULEAN_CAVE_2F", {
    grass = {
      rate = 15,
      slots = {
        { level = 51, species = "DODRIO" },      -- 20%
        { level = 51, species = "VENOMOTH" },    -- 20%

        { level = 51, species = "KADABRA" },     -- 15%

        { level = 52, species = "RHYDON" },      -- 10%
        { level = 52, species = "MAROWAK" },     -- 10%
        { level = 52, species = "ELECTRODE" },   -- 10%

        { level = 56, species = "CHANSEY" },     -- 5%
        { level = 54, species = "WIGGLYTUFF" },  -- 5%

        -- Trade evolution addition
        { level = 55, species = "MACHAMP" },     -- 4%

        { level = 60, species = "DITTO" },       -- 1%
      },
    },
  })

  mod.content.encounters:patch("CERULEAN_CAVE_B1F", {
    grass = {
      rate = 25,
      slots = {
        { level = 55, species = "RHYDON" },      -- 20%
        { level = 55, species = "MAROWAK" },     -- 20%

        { level = 55, species = "ELECTRODE" },   -- 15%

        { level = 64, species = "CHANSEY" },     -- 10%
        { level = 64, species = "PARASECT" },    -- 10%
        { level = 64, species = "RAICHU" },      -- 10%

        -- Yellow-inspired encounter
        { level = 55, species = "LICKITUNG" },   -- 5%

        -- Trade evolution additions
        { level = 57, species = "GENGAR" },      -- 5%
        { level = 57, species = "GOLEM" },       -- 4%

        { level = 67, species = "DITTO" },       -- 1%
      },
    },
  })

  mod.content.encounters:patch("POWER_PLANT", {
    grass = {
      slots = {
        { level = 21, species = "VOLTORB" },
        { level = 21, species = "MAGNEMITE" },
        { level = 20, species = "PIKACHU" },
        { level = 24, species = "PIKACHU" },

        { level = 23, species = "MAGNEMITE" },
        { level = 23, species = "VOLTORB" },

        { level = 32, species = "MAGNETON" },
        { level = 35, species = "MAGNETON" },

        -- Rare version-independent encounters
        { level = 33, species = "ELECTABUZZ" },
        { level = 36, species = "ELECTABUZZ" },
      },
    },
  })

  mod.log:info("galar_gmax_dex: area encounter tables installed (Phase 6)")
end
