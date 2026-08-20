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
  if not mod.options:get("use_base_area_tables") then
    mod.log:info("galar_gmax_dex: base area placement tables disabled (allowing external mod spawn tables)")
    return
  end

  local spawnData = {
    grass = {},
    surf = {},
    water = {},
  }

  local function publishProvider()
    mod.exports.overworldSpawnProvider = {
      apiVersion = 1,
      id = mod.id,
      get = function(mapId, encounterKind, timeOfDay)
        encounterKind = encounterKind or "grass"
        local kindTable = spawnData[encounterKind]
        if not kindTable then return nil end
        local mapDef = kindTable[mapId]
        if not mapDef then return nil end

        if mapDef.slots then
          local slotsForTime = timeOfDay and mapDef.slots[timeOfDay]
          if not slotsForTime and type(mapDef.slots) == "table" and not mapDef.slots[1] then
            slotsForTime = mapDef.slots["DAY"] or mapDef.slots["MORN"] or mapDef.slots["NITE"]
          end
          if slotsForTime then
            local rate = mapDef.rates and timeOfDay and mapDef.rates[timeOfDay]
              or (mapDef.rates and (mapDef.rates.DAY or mapDef.rates.MORN or mapDef.rates.NITE))
              or 25
            return { rate = rate, slots = slotsForTime }
          elseif mapDef.slots[1] then
            local rate = mapDef.rate or 25
            return { rate = rate, slots = mapDef.slots, buckets = mapDef.buckets }
          end
        end
        return nil
      end,
    }
  end

  -- Compatibility merge for Gen 2's kind-first encounters shape
  -- (explicit user decision: "merge but we keep the on/off toggle for it
  -- as is"). Confirmed via the registry schema's own header (Schemas.lua
  -- R.encounters): Gold has no per-map record to key the registry by, so
  -- the registry id IS the kind ("surf"/"grass") and the patch value is
  -- itself a per-map table nested inside it -- meaning two different
  -- mods can both legitimately patch "grass" for two different routes,
  -- and a plain owners[id]-based defer (right for Kanto's one-id-per-map
  -- shape above) would be too coarse here: it would throw away OUR
  -- entire route set just because some other mod touched "grass" for a
  -- single unrelated route. Real per-map data lives only in mod-op
  -- values under this registry for Gen 2 (Gold's actual vanilla wild
  -- table is a completely separate ROM-derived structure this registry
  -- never sees -- confirmed: overworld_spawns.lua's own native fallback
  -- reads ow.encounters directly, never mod.content.encounters, for Gen
  -- 2), so :get(kind) before this file's own patch reflects only earlier
  -- mods' contributions -- any route key already present there is
  -- unambiguously someone else's, not vanilla. Only routes NOT already
  -- present get folded into this file's own patch; anything another mod
  -- already placed survives untouched.
  local function mergeKindPatch(kind, byRoute)
    local current = mod.content.encounters:get(kind)
    local toAdd, skipped = {}, {}
    for routeId, def in pairs(byRoute) do
      if current and current[routeId] then
        skipped[#skipped + 1] = routeId
      else
        toAdd[routeId] = def
      end
    end
    if #skipped > 0 then
      mod.log:info("galar_gmax_dex: base area tables: %s already has %d route(s) from another mod -- deferring on those, adding the rest",
        kind, #skipped)
    end
    if next(toAdd) then
      mod.content.encounters:patch(kind, toAdd)
    end
  end

  local GameVersion = require("src.core.GameVersion")
  if GameVersion.generation(GameVersion.get()) == 2 then
    local gen2Surf = {
      ROUTE_31 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "MAGIKARP", level = 18 },
            { species = "FRILLISH", level = 16 },
            { species = "STARYU", level = 14 },
            { species = "MUDKIP", level = 15 },
            { species = "BUIZEL", level = 17 },
            { species = "QUAXLY", level = 14 },
            { species = "WOOPER", level = 20 },
          },
        }
      }
    }
    mergeKindPatch("surf", gen2Surf)
    spawnData.surf = gen2Surf

    local gen2Grass = {
      ROUTE_46 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "MARILL", level = 3 },
            { species = "WHISMUR", level = 6 },
            { species = "TOXEL", level = 6 },
            { species = "SENTRET", level = 4 },
            { species = "CATERPIE", level = 2 },
            { species = "MAGIKARP", level = 5 },
            { species = "TEDDIURSA", level = 4 },
          },
          DAY = {
            { species = "NYMBLE", level = 6 },
            { species = "TAROUNTULA", level = 5 },
            { species = "WURMPLE", level = 2 },
            { species = "PICHU", level = 6 },
            { species = "AZURILL", level = 5 },
            { species = "RATTATA", level = 7 },
            { species = "TYROGUE", level = 7 },
          },
          NITE = {
            { species = "WIGLETT", level = 6 },
            { species = "SPINARAK", level = 7 },
            { species = "HOPPIP", level = 6 },
            { species = "BUNNELBY", level = 6 },
            { species = "ROOKIDEE", level = 6 },
            { species = "SLUGMA", level = 2 },
            { species = "CASCOON", level = 7 },
          },
        },
      },

      ROUTE_29 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "SPEWPA", level = 4 },
            { species = "BURMY", level = 7 },
            { species = "POOCHYENA", level = 6 },
            { species = "SWINUB", level = 7 },
            { species = "HAPPINY", level = 5 },
            { species = "VENIPEDE", level = 5 },
            { species = "ZUBAT", level = 6 },
          },
          DAY = {
            { species = "MAKUHITA", level = 6 },
            { species = "ROLYCOLY", level = 5 },
            { species = "WINGULL", level = 3 },
            { species = "WIMPOD", level = 7 },
            { species = "NICKIT", level = 4 },
            { species = "FOMANTIS", level = 6 },
            { species = "WEEDLE", level = 6 },
          },
          NITE = {
            { species = "APPLIN", level = 5 },
            { species = "FEEBAS", level = 3 },
            { species = "WOOLOO", level = 5 },
            { species = "PAWMI", level = 4 },
            { species = "COMBEE", level = 7 },
            { species = "BIDOOF", level = 5 },
            { species = "NINCADA", level = 3 },
          },
        },
      },

      ROUTE_30 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "NOIBAT", level = 9 },
            { species = "RELLOR", level = 13 },
            { species = "PATRAT", level = 14 },
            { species = "GOSSIFLEUR", level = 10 },
            { species = "LOTAD", level = 14 },
            { species = "STARLY", level = 14 },
            { species = "SPEAROW", level = 13 },
          },
          DAY = {
            { species = "YUNGOOS", level = 9 },
            { species = "SMOLIV", level = 10 },
            { species = "HOOTHOOT", level = 12 },
            { species = "BUDEW", level = 10 },
            { species = "HATENNA", level = 13 },
            { species = "KIRLIA", level = 15 },
            { species = "CHARCADET", level = 12 },
          },
          NITE = {
            { species = "BRAMBLIN", level = 9 },
            { species = "PIKIPEK", level = 10 },
            { species = "IMPIDIMP", level = 11 },
            { species = "BOUNSWEET", level = 12 },
            { species = "WYNAUT", level = 13 },
            { species = "LITLEO", level = 11 },
            { species = "MILCERY", level = 14 },
          },
        },
      },

      ROUTE_31 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "PURRLOIN", level = 17 },
            { species = "DIGLETT", level = 15 },
            { species = "SURSKIT", level = 15 },
            { species = "TADBULB", level = 18 },
            { species = "SANDSHREW", level = 15 },
            { species = "SKITTY", level = 16 },
            { species = "SEEDOT", level = 18 },
          },
          DAY = {
            { species = "GOLETT", level = 15 },
            { species = "BELLSPROUT", level = 15 },
            { species = "MAREEP", level = 14 },
            { species = "NIDORANM", level = 18 },
            { species = "CHERUBI", level = 18 },
            { species = "YAMPER", level = 19 },
            { species = "SLAKOTH", level = 17 },
          },
          NITE = {
            { species = "LITWICK", level = 18 },
            { species = "DEWPIDER", level = 14 },
            { species = "VULPIX", level = 19 },
            { species = "GEODUDE", level = 16 },
            { species = "REMORAID", level = 18 },
            { species = "FLETCHLING", level = 18 },
            { species = "MEDITITE", level = 19 },
          },
        },
      },

      ILEX_FOREST = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "TYNAMO", level = 23 },
            { species = "TINKATINK", level = 23 },
            { species = "NACLI", level = 18 },
            { species = "COTTONEE", level = 21 },
            { species = "SHINX", level = 22 },
            { species = "BAGON", level = 21 },
            { species = "WATTREL", level = 22 },
          },
          DAY = {
            { species = "BARBOACH", level = 23 },
            { species = "RIOLU", level = 22 },
            { species = "DREEPY", level = 23 },
            { species = "PINECO", level = 21 },
            { species = "MUDKIP", level = 23 },
            { species = "FLITTLE", level = 21 },
            { species = "TRAPINCH", level = 19 },
          },
          NITE = {
            { species = "POLIWAG", level = 23 },
            { species = "CHINGLING", level = 19 },
            { species = "HELIOPTILE", level = 20 },
            { species = "PARAS", level = 22 },
            { species = "FROAKIE", level = 18 },
            { species = "GOTHITA", level = 19 },
            { species = "MUNNA", level = 21 },
          },
        },
      },

      ROUTE_32 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "MEOWTH", level = 24 },
            { species = "TOTODILE", level = 24 },
            { species = "DWEBBLE", level = 25 },
            { species = "KRABBY", level = 24 },
            { species = "STEENEE", level = 23 },
            { species = "PIDOVE", level = 22 },
            { species = "ROCKRUFF", level = 22 },
          },
          DAY = {
            { species = "TYMPOLE", level = 22 },
            { species = "FIDOUGH", level = 25 },
            { species = "INKAY", level = 25 },
            { species = "PANPOUR", level = 26 },
            { species = "SHROODLE", level = 25 },
            { species = "CETODDLE", level = 26 },
            { species = "ODDISH", level = 25 },
          },
          NITE = {
            { species = "SOLOSIS", level = 22 },
            { species = "SILICOBRA", level = 24 },
            { species = "ROGGENROLA", level = 26 },
            { species = "FINIZEN", level = 23 },
            { species = "SHUPPET", level = 22 },
            { species = "BUIZEL", level = 26 },
            { species = "DUSKULL", level = 25 },
          },
        },
      },

      ROUTE_33 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "TURTWIG", level = 28 },
            { species = "PIDGEOTTO", level = 26 },
            { species = "DODUO", level = 30 },
            { species = "CLEFAIRY", level = 30 },
            { species = "SNOVER", level = 27 },
            { species = "PIPLUP", level = 27 },
            { species = "CARVANHA", level = 27 },
          },
          DAY = {
            { species = "UNOWN", level = 31 },
            { species = "DRATINI", level = 31 },
            { species = "KARRABLAST", level = 27 },
            { species = "SPHEAL", level = 29 },
            { species = "GROWLITHE", level = 26 },
            { species = "SANDILE", level = 31 },
            { species = "ELECTRIKE", level = 28 },
          },
          NITE = {
            { species = "MANTYKE", level = 29 },
            { species = "SKORUPI", level = 30 },
            { species = "ABRA", level = 29 },
            { species = "BULBASAUR", level = 29 },
            { species = "PIKACHU", level = 26 },
            { species = "TOEDSCOOL", level = 30 },
            { species = "ARON", level = 29 },
          },
        },
      },

      ROUTE_34 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "DRIFLOON", level = 35 },
            { species = "SWABLU", level = 33 },
            { species = "FLAAFFY", level = 32 },
            { species = "SCRAGGY", level = 31 },
            { species = "OMANYTE", level = 35 },
            { species = "ZORUA", level = 30 },
            { species = "BELDUM", level = 34 },
          },
          DAY = {
            { species = "SKRELP", level = 31 },
            { species = "PANSAGE", level = 30 },
            { species = "SHIELDON", level = 35 },
            { species = "LILEEP", level = 35 },
            { species = "SHELLDER", level = 34 },
            { species = "GLAMEOW", level = 32 },
            { species = "CACNEA", level = 31 },
          },
          NITE = {
            { species = "ELEKID", level = 34 },
            { species = "ROWLET", level = 32 },
            { species = "PAWNIARD", level = 35 },
            { species = "OSHAWOTT", level = 33 },
            { species = "VOLTORB", level = 32 },
            { species = "FLOETTE", level = 33 },
            { species = "BALTOY", level = 31 },
          },
        },
      },

      ROUTE_35 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "GRIMER", level = 34 },
            { species = "DEERLING", level = 36 },
            { species = "CRABRAWLER", level = 35 },
            { species = "CUBONE", level = 36 },
            { species = "ESPURR", level = 34 },
            { species = "STARYU", level = 37 },
            { species = "BUNEARY", level = 35 },
          },
          DAY = {
            { species = "CHINCHOU", level = 34 },
            { species = "CLAMPERL", level = 34 },
            { species = "HOUNDOUR", level = 34 },
            { species = "VULLABY", level = 36 },
            { species = "SWADLOON", level = 35 },
            { species = "PUMPKABOOAVERAGE", level = 38 },
            { species = "GOLDEEN", level = 38 },
          },
          NITE = {
            { species = "KOFFING", level = 39 },
            { species = "DITTO", level = 34 },
            { species = "FARFETCHD", level = 37 },
            { species = "KROKOROK", level = 35 },
            { species = "SANDYGAST", level = 35 },
            { species = "ELGYEM", level = 39 },
            { species = "DELIBIRD", level = 36 },
          },
        },
      },

      NATIONAL_PARK = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "ONIX", level = 38 },
            { species = "FRILLISHMALE", level = 42 },
            { species = "LARVESTA", level = 43 },
            { species = "MIENFOO", level = 42 },
            { species = "VANILLISH", level = 39 },
            { species = "DRILBUR", level = 42 },
            { species = "PANCHAM", level = 43 },
          },
          DAY = {
            { species = "AMAURA", level = 39 },
            { species = "GRAVELER", level = 39 },
            { species = "MUDBRAY", level = 40 },
            { species = "CHARJABUG", level = 40 },
            { species = "BOLDORE", level = 40 },
            { species = "TIRTOUGA", level = 41 },
            { species = "PHANPY", level = 38 },
          },
          NITE = {
            { species = "MAGBY", level = 41 },
            { species = "MUNCHLAX", level = 42 },
            { species = "WARTORTLE", level = 41 },
            { species = "MURKROW", level = 39 },
            { species = "BAYLEEF", level = 43 },
            { species = "TIMBURR", level = 39 },
            { species = "TRUBBISH", level = 39 },
          },
        },
      },

      ROUTE_36 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "SPOINK", level = 44 },
            { species = "RHYHORN", level = 46 },
            { species = "CUFANT", level = 42 },
            { species = "PORYGON", level = 44 },
            { species = "CHARMELEON", level = 42 },
            { species = "ROSELIA", level = 43 },
            { species = "PSYDUCK", level = 45 },
          },
          DAY = {
            { species = "POPPLIO", level = 44 },
            { species = "MACHOKE", level = 43 },
            { species = "LITTEN", level = 42 },
            { species = "COMBUSKEN", level = 46 },
            { species = "GURDURR", level = 44 },
            { species = "MINUN", level = 47 },
            { species = "FRAXURE", level = 44 },
          },
          NITE = {
            { species = "SALANDIT", level = 45 },
            { species = "JOLTIK", level = 45 },
            { species = "QUILLADIN", level = 46 },
            { species = "AIPOM", level = 42 },
            { species = "PUPITAR", level = 43 },
            { species = "PYUKUMUKU", level = 43 },
            { species = "HONEDGE", level = 42 },
          },
        },
      },

      ROUTE_37 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "SNEASEL", level = 48 },
            { species = "MONFERNO", level = 48 },
            { species = "CHATOT", level = 49 },
            { species = "CROCALOR", level = 46 },
            { species = "QUAXWELL", level = 46 },
            { species = "GLIMMET", level = 50 },
            { species = "METANG", level = 46 },
          },
          DAY = {
            { species = "SERVINE", level = 46 },
            { species = "GROVYLE", level = 48 },
            { species = "THWACKEY", level = 46 },
            { species = "MAROWAK", level = 46 },
            { species = "ARCTIBAX", level = 46 },
            { species = "FLORAGATO", level = 49 },
            { species = "QUAGSIRE", level = 49 },
          },
          NITE = {
            { species = "ZWEILOUS", level = 49 },
            { species = "DRIZZILE", level = 48 },
            { species = "HAKAMOO", level = 48 },
            { species = "PIGNITE", level = 51 },
            { species = "PINCURCHIN", level = 50 },
            { species = "CLODSIRE", level = 50 },
            { species = "RABOOT", level = 50 },
          },
        },
      },

      ROUTE_38 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "GLIGAR", level = 54 },
            { species = "QWILFISH", level = 50 },
            { species = "DEDENNE", level = 50 },
            { species = "MINIORREDMETEOR", level = 55 },
            { species = "CARNIVINE", level = 52 },
            { species = "PERRSERKER", level = 52 },
            { species = "JYNX", level = 52 },
          },
          DAY = {
            { species = "ROTOM", level = 53 },
            { species = "TANGELA", level = 52 },
            { species = "CAMERUPT", level = 53 },
            { species = "CHIMECHO", level = 50 },
            { species = "SUNFLORA", level = 50 },
            { species = "SOLROCK", level = 53 },
            { species = "RIBOMBEE", level = 52 },
          },
          NITE = {
            { species = "STONJOURNER", level = 54 },
            { species = "CLOBBOPUS", level = 54 },
            { species = "SPRITZEE", level = 54 },
            { species = "SWANNA", level = 54 },
            { species = "BRUXISH", level = 53 },
            { species = "ORTHWORM", level = 55 },
            { species = "KLEFKI", level = 55 },
          },
        },
      },

      ROUTE_39 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "SAWK", level = 57 },
            { species = "COFAGRIGUS", level = 59 },
            { species = "DURANT", level = 54 },
            { species = "SLOWBRO", level = 59 },
            { species = "SKUNTANK", level = 58 },
            { species = "TAUROS", level = 57 },
            { species = "MALAMAR", level = 57 },
          },
          DAY = {
            { species = "FERROTHORN", level = 58 },
            { species = "KABUTOPS", level = 56 },
            { species = "ACCELGOR", level = 54 },
            { species = "DRAMPA", level = 59 },
            { species = "TOXTRICITYAMPED", level = 59 },
            { species = "HAWLUCHA", level = 54 },
            { species = "DIPPLIN", level = 55 },
          },
          NITE = {
            { species = "DRACOVISH", level = 57 },
            { species = "KLEAVOR", level = 54 },
            { species = "DRACOZOLT", level = 58 },
            { species = "OVERQWIL", level = 55 },
            { species = "SIRFETCHD", level = 57 },
            { species = "AVALUGG", level = 58 },
            { species = "GALLADE", level = 57 },
          },
        },
      },

      ROUTE_42 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "LICKILICKY", level = 62 },
            { species = "CETITAN", level = 61 },
            { species = "TANGROWTH", level = 59 },
            { species = "CHESPIN", level = 63 },
            { species = "MAMOSWINE", level = 63 },
            { species = "DUDUNSPARCETWOSEGMENT", level = 60 },
            { species = "BEARTIC", level = 62 },
          },
          DAY = {
            { species = "GIMMIGHOUL", level = 59 },
            { species = "FLUTTERMANE", level = 60 },
            { species = "WYRDEER", level = 63 },
            { species = "TOGEKISS", level = 59 },
            { species = "HYDRAPPLE", level = 60 },
            { species = "CHIKORITA", level = 58 },
            { species = "BRUTEBONNET", level = 58 },
          },
          NITE = {
            { species = "IRONTHORNS", level = 60 },
            { species = "KELDEOORDINARY", level = 62 },
            { species = "ROARINGMOON", level = 62 },
            { species = "THUNDURUSINCARNATE", level = 62 },
            { species = "ZYGARDE50", level = 59 },
            { species = "URSHIFUSINGLESTRIKE", level = 61 },
            { species = "GIRATINAALTERED", level = 58 },
          },
        },
      },

      ROUTE_43 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "TORNADUSINCARNATE", level = 65 },
            { species = "SHAYMINLAND", level = 67 },
            { species = "IRONBUNDLE", level = 67 },
            { species = "HOOH", level = 62 },
            { species = "DEOXYSNORMAL", level = 67 },
            { species = "AUDINO", level = 63 },
            { species = "NINJASK", level = 65 },
          },
          DAY = {
            { species = "MARACTUS", level = 66 },
            { species = "UNFEZANT", level = 63 },
            { species = "SCOVILLAIN", level = 66 },
            { species = "WORMADAMPLANT", level = 63 },
            { species = "CHANSEY", level = 65 },
            { species = "SQUAWKABILLYGREENPLUMAGE", level = 63 },
            { species = "SIMISEAR", level = 67 },
          },
          NITE = {
            { species = "VELUZA", level = 63 },
            { species = "GOURGEISTAVERAGE", level = 66 },
            { species = "ESPATHRA", level = 62 },
            { species = "VESPIQUEN", level = 66 },
            { species = "ARBOK", level = 62 },
            { species = "GALVANTULA", level = 67 },
            { species = "LIEPARD", level = 66 },
          },
        },
      },

      ROUTE_44 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "SWALOT", level = 70 },
            { species = "SEVIPER", level = 70 },
            { species = "SINISTCHA", level = 71 },
            { species = "SLIGGOO", level = 68 },
            { species = "LYCANROCMIDDAY", level = 67 },
            { species = "CRAWDAUNT", level = 67 },
            { species = "TINKATON", level = 68 },
          },
          DAY = {
            { species = "SEISMITOAD", level = 70 },
            { species = "MIMIKYUDISGUISED", level = 67 },
            { species = "PALAFINZERO", level = 67 },
            { species = "STUNFISK", level = 70 },
            { species = "CYCLIZAR", level = 66 },
            { species = "TALONFLAME", level = 69 },
            { species = "EMBOAR", level = 71 },
          },
          NITE = {
            { species = "KROOKODILE", level = 66 },
            { species = "MEOWSTICMALE", level = 67 },
            { species = "DACHSBUN", level = 71 },
            { species = "DHELMISE", level = 66 },
            { species = "GOGOAT", level = 70 },
            { species = "DELPHOX", level = 70 },
            { species = "FEAROW", level = 70 },
          },
        },
      },

      ROUTE_45 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "FLORGES", level = 75 },
            { species = "EMOLGA", level = 71 },
            { species = "FURRET", level = 73 },
            { species = "AROMATISSE", level = 71 },
            { species = "ARCHEN", level = 71 },
            { species = "LUXRAY", level = 72 },
            { species = "MORPEKOFULLBELLY", level = 71 },
          },
          DAY = {
            { species = "ARCHEOPS", level = 75 },
            { species = "BRAIXEN", level = 70 },
            { species = "KRICKETUNE", level = 74 },
            { species = "FLETCHINDER", level = 74 },
            { species = "LUXIO", level = 74 },
            { species = "ARCANINE", level = 71 },
            { species = "CYNDAQUIL", level = 70 },
          },
          NITE = {
            { species = "NOSEPASS", level = 73 },
            { species = "TRANQUILL", level = 70 },
            { species = "BINACLE", level = 75 },
            { species = "CAPSAKID", level = 73 },
            { species = "CHEWTLE", level = 70 },
            { species = "SPIDOPS", level = 71 },
            { species = "GULPIN", level = 70 },
          },
        },
      },

      ROUTE_27 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "OINKOLOGNE", level = 76 },
            { species = "PIDGEOT", level = 75 },
            { species = "FENNEKIN", level = 77 },
            { species = "ZEBSTRIKA", level = 79 },
            { species = "CLEFFA", level = 74 },
            { species = "DOLLIV", level = 75 },
            { species = "SLAKING", level = 79 },
          },
          DAY = {
            { species = "WISHIWASHISOLO", level = 75 },
            { species = "SNOM", level = 76 },
            { species = "KRICKETOT", level = 76 },
            { species = "SHEDINJA", level = 78 },
            { species = "RALTS", level = 79 },
            { species = "BLIPBUG", level = 74 },
            { species = "NIDOQUEEN", level = 74 },
          },
          NITE = {
            { species = "SIMISAGE", level = 78 },
            { species = "FLYGON", level = 78 },
            { species = "VILEPLUME", level = 76 },
            { species = "SHIFTRY", level = 74 },
            { species = "KINGLER", level = 78 },
            { species = "SCYTHER", level = 76 },
            { species = "MEGANIUM", level = 78 },
          },
        },
      },

      ROUTE_26 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "MAGMAR", level = 80 },
            { species = "GOGOAT", level = 82 },
            { species = "VANILLUXE", level = 80 },
            { species = "MILOTIC", level = 80 },
            { species = "FERALIGATR", level = 79 },
            { species = "VOLCARONA", level = 79 },
            { species = "IRONHANDS", level = 81 },
          },
          DAY = {
            { species = "ENAMORUSINCARNATE", level = 78 },
            { species = "ABOMASNOW", level = 78 },
            { species = "LYCANROCMIDDAY", level = 81 },
            { species = "DELPHOX", level = 82 },
            { species = "SEISMITOAD", level = 81 },
            { species = "GALLADE", level = 80 },
            { species = "SIRFETCHD", level = 83 },
          },
          NITE = {
            { species = "TINKATON", level = 78 },
            { species = "POLTEAGEIST", level = 82 },
            { species = "MIENSHAO", level = 79 },
            { species = "TYRANTRUM", level = 81 },
            { species = "SERPERIOR", level = 79 },
            { species = "TENTACRUEL", level = 81 },
            { species = "AVALUGG", level = 78 },
          },
        },
      },

      ROUTE_28 = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "WALKINGWAKE", level = 83 },
            { species = "GOUGINGFIRE", level = 83 },
            { species = "RAGINGBOLT", level = 87 },
            { species = "TYRANITAR", level = 83 },
            { species = "BAXCALIBUR", level = 87 },
            { species = "IRONCROWN", level = 86 },
            { species = "IRONBOULDER", level = 83 },
          },
          DAY = {
            { species = "IRONVALIANT", level = 86 },
            { species = "IRONTREADS", level = 86 },
            { species = "IRONBUNDLE", level = 82 },
            { species = "IRONJUGULIS", level = 83 },
            { species = "IRONMOTH", level = 84 },
            { species = "IRONTHORNS", level = 85 },
            { species = "IRONLEAVES", level = 83 },
          },
          NITE = {
            { species = "SANDYSHOCKS", level = 82 },
            { species = "SLITHERWING", level = 84 },
            { species = "FLUTTERMANE", level = 82 },
            { species = "BRUTEBONNET", level = 84 },
            { species = "SCREAMTAIL", level = 83 },
            { species = "ROARINGMOON", level = 86 },
            { species = "GREATTUSK", level = 83 },
          },
        },
      },
      SILVER_CAVE_OUTSIDE = {
        rates = { MORN = 25, DAY = 25, NITE = 25 },
        slots = {
          MORN = {
            { species = "BUZZWOLE", level = 100 },
            { species = "NIHILEGO", level = 100 },
            { species = "PHEROMOSA", level = 100 },
            { species = "XURKITREE", level = 100 },
            { species = "CELESTEELA", level = 100 },
            { species = "KARTANA", level = 100 },
            { species = "GUZZLORD", level = 100 },
          },
          DAY = {
            { species = "STAKATAKA", level = 100 },
            { species = "BLACEPHALON", level = 100 },
            { species = "KUBFU", level = 100 },
            { species = "WOCHIEN", level = 100 },
            { species = "CHIENPAO", level = 100 },
            { species = "TINGLU", level = 100 },
            { species = "CHIYU", level = 100 },
          },
          NITE = {
            { species = "OKIDOGI", level = 100 },
            { species = "MUNKIDORI", level = 100 },
            { species = "FEZANDIPITI", level = 100 },
            { species = "OGERPON", level = 100 },
            { species = "TERAPAGOS", level = 100 },
            { species = "PECHARUNT", level = 100 },
            { species = "MELMETAL", level = 100 },
          },
        },
      },
    }
    mergeKindPatch("grass", gen2Grass)
    spawnData.grass = gen2Grass
    publishProvider()
    mod.log:info("galar_gmax_dex: gen 2 area placements installed & spawn provider published")
    return
  end

  -- Compatibility merge (explicit user decision: "merge but we keep the
  -- on/off toggle for it as is"). Record-semantics :patch() deep-merges
  -- key/value fields but replaces an array field (slots) wholesale --
  -- confirmed via src/mods/Merge.lua, this file's own header already
  -- noted it -- so blindly patching every Kanto map here would silently
  -- discard any earlier-loaded mod's own edit to that same map's table.
  -- Registry.lua's own owners[id] (last-writing owner) is set only by a
  -- real op (register/override/patch); vanilla ROM data lives in a
  -- separate base() function and is never recorded as an op, so
  -- owners[mapId] being set BEFORE this call means some other mod
  -- already customized this exact map -- defer to them rather than
  -- overwrite. A true slot-by-slot merge of two full weighted 10-slot
  -- tables has no unambiguous semantic (whose weight wins slot 3?), so
  -- "defer entirely to whoever got there first" is the honest reading of
  -- "merge" this data shape actually allows -- not a silent narrowing,
  -- the only well-defined answer available.
  local function patchEncounter(mapId, encDef)
    local owners = mod.content.encounters.owners
    local existingOwner = owners and owners[mapId]
    if existingOwner and existingOwner ~= mod.id then
      mod.log:info("galar_gmax_dex: base area tables: %s already patched by '%s' -- deferring, not overwriting",
        tostring(mapId), tostring(existingOwner))
      return
    end
    mod.content.encounters:patch(mapId, encDef)
    if encDef then
      if encDef.grass then spawnData.grass[mapId] = encDef.grass end
      if encDef.water then spawnData.water[mapId] = encDef.water end
      if encDef.surf then spawnData.surf[mapId] = encDef.surf end
    end
  end

  patchEncounter("VIRIDIAN_FOREST", {
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

  patchEncounter("ROUTE_2", {
    grass = {
      slots = {
        { level = 6, species = "IMPIDIMP " },      -- 20%
        { level = 7, species = "IMPIDIMP" },     -- 20%

        { level = 8, species = "IMPIDIMP" },      -- 15%

        { level = 5, species = "IMPIDIMP" },     -- 10%
        { level = 6, species = "IMPIDIMP" },     -- 10%

        { level = 8, species = "IMPIDIMP" },     -- 10%

        { level = 8, species = "IMPIDIMP" },     -- 5%
        { level = 5, species = "IMPIDIMP" },      -- 5%

        { level = 9, species = "IMPIDIMP" },  -- 4%
        { level = 5, species = "IMPIDIMP" },  -- 1%
      },
    },
  })

  -- Deliberate exception: ROUTE_3 is ours, not the source mod's vanilla-
  -- completion table -- a single-species URSHIFU table instead.
  patchEncounter("ROUTE_3", {
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

  patchEncounter("ROUTE_4", {
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

  patchEncounter("ROUTE_5", {
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

  patchEncounter("ROUTE_6", {
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

  patchEncounter("ROUTE_7", {
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

  patchEncounter("ROUTE_8", {
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

  patchEncounter("ROUTE_9", {
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

  patchEncounter("ROUTE_11", {
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

  patchEncounter("ROUTE_12", {
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

  patchEncounter("ROUTE_13", {
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

  patchEncounter("ROUTE_14", {
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

  patchEncounter("ROUTE_15", {
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

  patchEncounter("ROUTE_21", {
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

  patchEncounter("ROUTE_23", {
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

  patchEncounter("ROUTE_24", {
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

  patchEncounter("ROUTE_25", {
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

  patchEncounter("ROUTE_22", {
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

  patchEncounter("SAFARI_ZONE_CENTER", {
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

  patchEncounter("SAFARI_ZONE_EAST", {
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

  patchEncounter("SAFARI_ZONE_WEST", {
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

  patchEncounter("SAFARI_ZONE_NORTH", {
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

  patchEncounter("SEAFOAM_ISLANDS_B2F", {
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

  patchEncounter("SEAFOAM_ISLANDS_B3F", {
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

  patchEncounter("SEAFOAM_ISLANDS_B4F", {
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

  patchEncounter("VICTORY_ROAD_1F", {
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

  patchEncounter("VICTORY_ROAD_2F", {
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

  patchEncounter("VICTORY_ROAD_3F", {
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

  patchEncounter("POKEMON_MANSION_B1F", {
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

  patchEncounter("CERULEAN_CAVE_1F", {
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

  patchEncounter("CERULEAN_CAVE_2F", {
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

  patchEncounter("CERULEAN_CAVE_B1F", {
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

  patchEncounter("POWER_PLANT", {
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

  publishProvider()
  mod.log:info("galar_gmax_dex: area encounter tables & spawn provider installed (Phase 6)")
end
