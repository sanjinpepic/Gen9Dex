-- Phase 1 species catalogue: the 51 species that do not already exist in
-- the base 151-species Kanto roster, needed to complete the evolution
-- lines of the 34 Gigantamax-capable species (see GMAX_SPECIES in
-- main.lua for the species that actually receive a Gigantamax form --
-- that list also includes 25 already-native species that need no entry
-- here at all: Venusaur, Charizard, Blastoise, Butterfree, Pikachu,
-- Meowth, Machamp, Gengar, Kingler, Lapras, Eevee and Snorlax's whole
-- pre-evolution lines).
--
-- Source: Pokemon_Stats/pokemon.txt (national dex order confirmed by
-- direct inspection: entry N in the file is dex number N). Field values
-- below are copied from that file except where noted:
--   * baseStats is the engine's native 5-stat Gen 1 model
--     (hp/attack/defense/speed/special), not PBS's 6-stat model.
--     special = round((SpAtk + SpDef) / 2), the rest copied directly.
--   * growthRate is INFERRED to the engine's likely UPPER_SNAKE_CASE
--     naming (matching every other identifier convention this engine's
--     Lua API uses) from PBS's Medium/Slow/Parabolic/Erratic. Only
--     "SLOW" itself is confirmed against reference-mod source; the
--     others (MEDIUM_FAST, MEDIUM_SLOW, ERRATIC) are not independently
--     verified and should be spot-checked against actual level-up
--     tables in game once this loads.
--   * types keeps PBS's own spelling (e.g. "PSYCHIC"); main.lua
--     translates to the engine's ids (e.g. "PSYCHIC_TYPE") at
--     registration time.
--   * dexEntry kind/text is kept in the source data's own Spanish
--     (matches this whole PBS pack's language), not translated.
--   * height/weight are heightM/weightKg as given; main.lua derives
--     heightFt/heightIn/weight(decipounds) the same way
--     postgame_species.lua does.
--   * evolutions omits two branches present in the source data that lead
--     outside this project's confirmed Gen-8 Gigantamax scope: Applin's
--     third branch to DIPPLIN (Gen 9) and Duraludon's branch to
--     ARCHALUDON (Gen 9) -- neither target species is registered here.
--   * Milcery's evolution is PBS "HoldItem" (hold the Sweet + level up
--     while spinning), which this engine has no held-item mechanic to
--     express. Approximated as a consumable "ITEM" use instead (the
--     same trigger already used for Kubfu's two Scrolls and Applin's two
--     Apples), one entry per Sweet flavor. This is a deliberate
--     simplification, not the real games' mechanic.

return {
  order = {
    "PICHU",
    "MUNCHLAX",
    "TRUBBISH", "GARBODOR",
    "MELTAN", "MELMETAL",
    "GROOKEY", "THWACKEY", "RILLABOOM",
    "SCORBUNNY", "RABOOT", "CINDERACE",
    "SOBBLE", "DRIZZILE", "INTELEON",
    "ROOKIDEE", "CORVISQUIRE", "CORVIKNIGHT",
    "BLIPBUG", "DOTTLER", "ORBEETLE",
    "CHEWTLE", "DREDNAW",
    "ROLYCOLY", "CARKOL", "COALOSSAL",
    "APPLIN", "FLAPPLE", "APPLETUN",
    "SILICOBRA", "SANDACONDA",
    "TOXEL", "TOXTRICITY",
    "SIZZLIPEDE", "CENTISKORCH",
    "HATENNA", "HATTREM", "HATTERENE",
    "IMPIDIMP", "MORGREM", "GRIMMSNARL",
    "MILCERY", "ALCREMIE",
    "CUFANT", "COPPERAJAH",
    "DURALUDON",
    "ETERNATUS",
    "KUBFU", "URSHIFU",
    "GOSSIFLEUR", "ELDEGOSS",
  },

  -- Consumable evolution items this pack introduces, beyond the native
  -- stones. Registered as real items in main.lua and wired through the
  -- same generic "use item -> check species evolutions table" hook
  -- Gorochu's Thunder Tear used one-off; see installCustomEvolutionItems.
  items = {
    TARTAPPLE        = { name = "Manzana Ácida" },
    SWEETAPPLE       = { name = "Manzana Dulce" },
    SCROLLOFDARKNESS = { name = "Rollo de la Oscuridad" },
    SCROLLOFWATERS   = { name = "Rollo de las Aguas" },
    STRAWBERRYSWEET  = { name = "Dulce de Fresa" },
    BERRYSWEET       = { name = "Dulce de Baya" },
    LOVESWEET        = { name = "Dulce de Amor" },
    STARSWEET        = { name = "Dulce de Estrella" },
    CLOVERSWEET      = { name = "Dulce de Trébol" },
    FLOWERSWEET      = { name = "Dulce de Flor" },
    RIBBONSWEET      = { name = "Dulce de Lazo" },
  },

    species = {
    BULBASAUR = {
      dex = 1, name = "Bulbasaur", types = { "GRASS", "POISON" },
      baseStats = { hp = 45, attack = 49, defense = 49, speed = 45, specialA = 65, specialD = 65 },
      catchRate = 45, baseExp = 64, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "IVYSAUR", level = 16 },
      },
      heightM = 0.7, weightKg = 6.9,
      dexEntry = { kind = "Seed Pokémon",
        text = "There is a plant seed on its back right from the day this Pokémon is born. The seed slowly grows larger." },
    },

    IVYSAUR = {
      dex = 2, name = "Ivysaur", types = { "GRASS", "POISON" },
      baseStats = { hp = 60, attack = 62, defense = 63, speed = 60, specialA = 80, specialD = 80 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "VENUSAUR", level = 32 },
      },
      heightM = 1, weightKg = 13,
      dexEntry = { kind = "Seed Pokémon",
        text = "When the bulb on its back grows large, it appears to lose the ability to stand on its hind legs." },
    },

    VENUSAUR = {
      dex = 3, name = "Venusaur", types = { "GRASS", "POISON" },
      baseStats = { hp = 80, attack = 82, defense = 83, speed = 80, specialA = 100, specialD = 100 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 100,
      dexEntry = { kind = "Seed Pokémon",
        text = "Its plant blooms when it is absorbing solar energy. It stays on the move to seek sunlight." },
    },

    CHARMANDER = {
      dex = 4, name = "Charmander", types = { "FIRE" },
      baseStats = { hp = 39, attack = 52, defense = 43, speed = 65, specialA = 60, specialD = 50 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CHARMELEON", level = 16 },
      },
      heightM = 0.6, weightKg = 8.5,
      dexEntry = { kind = "Lizard Pokémon",
        text = "It has a preference for hot things. When it rains, steam is said to spout from the tip of its tail." },
    },

    CHARMELEON = {
      dex = 5, name = "Charmeleon", types = { "FIRE" },
      baseStats = { hp = 58, attack = 64, defense = 58, speed = 80, specialA = 80, specialD = 65 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CHARIZARD", level = 36 },
      },
      heightM = 1.1, weightKg = 19,
      dexEntry = { kind = "Flame Pokémon",
        text = "It has a barbaric nature. In battle, it whips its fiery tail around and slashes away with sharp claws." },
    },

    CHARIZARD = {
      dex = 6, name = "Charizard", types = { "FIRE", "FLYING" },
      baseStats = { hp = 78, attack = 84, defense = 78, speed = 100, specialA = 109, specialD = 85 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 90.5,
      dexEntry = { kind = "Flame Pokémon",
        text = "It spits fire that is hot enough to melt boulders. It may cause forest fires by blowing flames." },
    },

    SQUIRTLE = {
      dex = 7, name = "Squirtle", types = { "WATER" },
      baseStats = { hp = 44, attack = 48, defense = 65, speed = 43, specialA = 50, specialD = 64 },
      catchRate = 45, baseExp = 63, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "WARTORTLE", level = 16 },
      },
      heightM = 0.5, weightKg = 9,
      dexEntry = { kind = "Tiny Turtle Pokémon",
        text = "When it retracts its long neck into its shell, it squirts out water with vigorous force." },
    },

    WARTORTLE = {
      dex = 8, name = "Wartortle", types = { "WATER" },
      baseStats = { hp = 59, attack = 63, defense = 80, speed = 58, specialA = 65, specialD = 80 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BLASTOISE", level = 36 },
      },
      heightM = 1, weightKg = 22.5,
      dexEntry = { kind = "Turtle Pokémon",
        text = "It is recognized as a symbol of longevity. If its shell has algae on it, that Wartortle is very old." },
    },

    BLASTOISE = {
      dex = 9, name = "Blastoise", types = { "WATER" },
      baseStats = { hp = 79, attack = 83, defense = 100, speed = 78, specialA = 85, specialD = 105 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 85.5,
      dexEntry = { kind = "Shellfish Pokémon",
        text = "It crushes its foe under its heavy body to cause fainting. In a pinch, it will withdraw inside its shell." },
    },

    CATERPIE = {
      dex = 10, name = "Caterpie", types = { "BUG" },
      baseStats = { hp = 45, attack = 30, defense = 35, speed = 45, specialA = 20, specialD = 20 },
      catchRate = 255, baseExp = 39, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "METAPOD", level = 7 },
      },
      heightM = 0.3, weightKg = 2.9,
      dexEntry = { kind = "Worm Pokémon",
        text = "For protection, it releases a horrible stench from the antenna on its head to drive away enemies." },
    },

    METAPOD = {
      dex = 11, name = "Metapod", types = { "BUG" },
      baseStats = { hp = 50, attack = 20, defense = 55, speed = 30, specialA = 25, specialD = 25 },
      catchRate = 120, baseExp = 72, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BUTTERFREE", level = 10 },
      },
      heightM = 0.7, weightKg = 9.9,
      dexEntry = { kind = "Cocoon Pokémon",
        text = "It is waiting for the moment to evolve. At this stage, it can only harden, so it remains motionless to avoid attack." },
    },

    BUTTERFREE = {
      dex = 12, name = "Butterfree", types = { "BUG", "FLYING" },
      baseStats = { hp = 60, attack = 45, defense = 50, speed = 70, specialA = 90, specialD = 80 },
      catchRate = 45, baseExp = 198, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 32,
      dexEntry = { kind = "Butterfly Pokémon",
        text = "In battle, it flaps its wings at great speed to release highly toxic dust into the air." },
    },

    WEEDLE = {
      dex = 13, name = "Weedle", types = { "BUG", "POISON" },
      baseStats = { hp = 40, attack = 35, defense = 30, speed = 50, specialA = 20, specialD = 20 },
      catchRate = 255, baseExp = 39, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "KAKUNA", level = 7 },
      },
      heightM = 0.3, weightKg = 3.2,
      dexEntry = { kind = "Hairy Pokémon",
        text = "Beware of the sharp stinger on its head. It hides in grass and bushes where it eats leaves." },
    },

    KAKUNA = {
      dex = 14, name = "Kakuna", types = { "BUG", "POISON" },
      baseStats = { hp = 45, attack = 25, defense = 50, speed = 35, specialA = 25, specialD = 25 },
      catchRate = 120, baseExp = 72, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BEEDRILL", level = 10 },
      },
      heightM = 0.6, weightKg = 10,
      dexEntry = { kind = "Cocoon Pokémon",
        text = "Able to move only slightly. When endangered, it may stick out its stinger and poison its enemy." },
    },

    BEEDRILL = {
      dex = 15, name = "Beedrill", types = { "BUG", "POISON" },
      baseStats = { hp = 65, attack = 90, defense = 40, speed = 75, specialA = 45, specialD = 80 },
      catchRate = 45, baseExp = 198, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 29.5,
      dexEntry = { kind = "Poison Bee Pokémon",
        text = "It has three poisonous stingers on its forelegs and its tail. They are used to jab its enemy repeatedly." },
    },

    PIDGEY = {
      dex = 16, name = "Pidgey", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 40, attack = 45, defense = 40, speed = 56, specialA = 35, specialD = 35 },
      catchRate = 255, baseExp = 50, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PIDGEOTTO", level = 18 },
      },
      heightM = 0.3, weightKg = 1.8,
      dexEntry = { kind = "Tiny Bird Pokémon",
        text = "Very docile. If attacked, it will often kick up sand to protect itself rather than fight back." },
    },

    PIDGEOTTO = {
      dex = 17, name = "Pidgeotto", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 63, attack = 60, defense = 55, speed = 71, specialA = 50, specialD = 50 },
      catchRate = 120, baseExp = 122, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PIDGEOT", level = 36 },
      },
      heightM = 1.1, weightKg = 30,
      dexEntry = { kind = "Bird Pokémon",
        text = "This Pokémon is full of vitality. It constantly flies around its large territory in search of prey." },
    },

    PIDGEOT = {
      dex = 18, name = "Pidgeot", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 83, attack = 80, defense = 75, speed = 101, specialA = 70, specialD = 70 },
      catchRate = 45, baseExp = 240, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 39.5,
      dexEntry = { kind = "Bird Pokémon",
        text = "This Pokémon flies at Mach 2 speed, seeking prey. Its large talons are feared as wicked weapons." },
    },

    RATTATA = {
      dex = 19, name = "Rattata", types = { "NORMAL" },
      baseStats = { hp = 30, attack = 56, defense = 35, speed = 72, specialA = 25, specialD = 35 },
      catchRate = 255, baseExp = 51, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "RATICATE", level = 20 },
      },
      heightM = 0.3, weightKg = 3.5,
      dexEntry = { kind = "Mouse Pokémon",
        text = "Will chew on anything with its fangs. If you see one, you can be certain that 40 more live in the area." },
    },

    RATICATE = {
      dex = 20, name = "Raticate", types = { "NORMAL" },
      baseStats = { hp = 55, attack = 81, defense = 60, speed = 97, specialA = 50, specialD = 70 },
      catchRate = 127, baseExp = 145, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 18.5,
      dexEntry = { kind = "Mouse Pokémon",
        text = "Its hind feet are webbed. They act as flippers, so it can swim in rivers and hunt for prey." },
    },

    SPEAROW = {
      dex = 21, name = "Spearow", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 40, attack = 60, defense = 30, speed = 70, specialA = 31, specialD = 31 },
      catchRate = 255, baseExp = 52, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FEAROW", level = 20 },
      },
      heightM = 0.3, weightKg = 2,
      dexEntry = { kind = "Tiny Bird Pokémon",
        text = "Inept at flying high. However, it can fly around very fast to protect its territory." },
    },

    FEAROW = {
      dex = 22, name = "Fearow", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 65, attack = 90, defense = 65, speed = 100, specialA = 61, specialD = 61 },
      catchRate = 90, baseExp = 155, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 38,
      dexEntry = { kind = "Beak Pokémon",
        text = "A Pokémon that dates back many years. If it senses danger, it flies high and away, instantly." },
    },

    EKANS = {
      dex = 23, name = "Ekans", types = { "POISON" },
      baseStats = { hp = 35, attack = 60, defense = 44, speed = 55, specialA = 40, specialD = 54 },
      catchRate = 255, baseExp = 58, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ARBOK", level = 22 },
      },
      heightM = 2, weightKg = 6.9,
      dexEntry = { kind = "Snake Pokémon",
        text = "The older it gets, the longer it grows. At night, it wraps its long body around tree branches to rest." },
    },

    ARBOK = {
      dex = 24, name = "Arbok", types = { "POISON" },
      baseStats = { hp = 60, attack = 95, defense = 69, speed = 80, specialA = 65, specialD = 79 },
      catchRate = 90, baseExp = 157, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 3.5, weightKg = 65,
      dexEntry = { kind = "Cobra Pokémon",
        text = "The frightening patterns on its belly have been studied. Six variations have been confirmed." },
    },

    PIKACHU = {
      dex = 25, name = "Pikachu", types = { "ELECTRIC" },
      baseStats = { hp = 35, attack = 55, defense = 40, speed = 90, specialA = 50, specialD = 50 },
      catchRate = 190, baseExp = 112, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "RAICHU", item = "THUNDERSTONE" },
      },
      heightM = 0.4, weightKg = 6,
      dexEntry = { kind = "Mouse Pokémon",
        text = "Pikachu that can generate powerful electricity have cheek sacs that are extra soft and super stretchy." },
    },

    RAICHU = {
      dex = 26, name = "Raichu", types = { "ELECTRIC" },
      baseStats = { hp = 60, attack = 90, defense = 55, speed = 110, specialA = 90, specialD = 80 },
      catchRate = 75, baseExp = 243, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 30,
      dexEntry = { kind = "Mouse Pokémon",
        text = "Its long tail serves as a ground to protect itself from its own high-voltage power." },
    },

    SANDSHREW = {
      dex = 27, name = "Sandshrew", types = { "GROUND" },
      baseStats = { hp = 50, attack = 75, defense = 85, speed = 40, specialA = 20, specialD = 30 },
      catchRate = 255, baseExp = 60, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SANDSLASH", level = 22 },
      },
      heightM = 0.6, weightKg = 12,
      dexEntry = { kind = "Mouse Pokémon",
        text = "It loves to bathe in the grit of dry, sandy areas. By sand bathing, the Pokémon rids itself of dirt and moisture clinging to its body." },
    },

    SANDSLASH = {
      dex = 28, name = "Sandslash", types = { "GROUND" },
      baseStats = { hp = 75, attack = 100, defense = 110, speed = 65, specialA = 45, specialD = 55 },
      catchRate = 90, baseExp = 158, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 29.5,
      dexEntry = { kind = "Mouse Pokémon",
        text = "The drier the area Sandslash lives in, the harder and smoother the Pokémon’s spikes will feel when touched." },
    },

    NIDORANFE = {
      dex = 29, name = "Nidoran♀", types = { "POISON" },
      baseStats = { hp = 55, attack = 47, defense = 52, speed = 41, specialA = 40, specialD = 40 },
      catchRate = 235, baseExp = 55, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "NIDORINA", level = 16 },
      },
      heightM = 0.4, weightKg = 7,
      dexEntry = { kind = "Poison Pin Pokémon",
        text = "Females are more sensitive to smells than males. While foraging, they’ll use their whiskers to check wind direction and stay downwind of predators." },
    },

    NIDORINA = {
      dex = 30, name = "Nidorina", types = { "POISON" },
      baseStats = { hp = 70, attack = 62, defense = 67, speed = 56, specialA = 55, specialD = 55 },
      catchRate = 120, baseExp = 128, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "NIDOQUEEN", item = "MOONSTONE" },
      },
      heightM = 0.8, weightKg = 20,
      dexEntry = { kind = "Poison Pin Pokémon",
        text = "The horn on its head has atrophied. It’s thought that this happens so Nidorina’s children won’t get poked while their mother is feeding them." },
    },

    NIDOQUEEN = {
      dex = 31, name = "Nidoqueen", types = { "POISON", "GROUND" },
      baseStats = { hp = 90, attack = 92, defense = 87, speed = 76, specialA = 75, specialD = 85 },
      catchRate = 45, baseExp = 253, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 60,
      dexEntry = { kind = "Drill Pokémon",
        text = "Nidoqueen is better at defense than offense. With scales like armor, this Pokémon will shield its children from any kind of attack." },
    },

    NIDORANMA = {
      dex = 32, name = "Nidoran♂", types = { "POISON" },
      baseStats = { hp = 46, attack = 57, defense = 40, speed = 50, specialA = 40, specialD = 40 },
      catchRate = 235, baseExp = 55, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "NIDORINO", level = 16 },
      },
      heightM = 0.5, weightKg = 9,
      dexEntry = { kind = "Poison Pin Pokémon",
        text = "The horn on a male Nidoran’s forehead contains a powerful poison. This is a very cautious Pokémon, always straining its large ears." },
    },

    NIDORINO = {
      dex = 33, name = "Nidorino", types = { "POISON" },
      baseStats = { hp = 61, attack = 72, defense = 57, speed = 65, specialA = 55, specialD = 55 },
      catchRate = 120, baseExp = 128, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "NIDOKING", item = "MOONSTONE" },
      },
      heightM = 0.9, weightKg = 19.5,
      dexEntry = { kind = "Poison Pin Pokémon",
        text = "With a horn that’s harder than diamond, this Pokémon goes around shattering boulders as it searches for a moon stone." },
    },

    NIDOKING = {
      dex = 34, name = "Nidoking", types = { "POISON", "GROUND" },
      baseStats = { hp = 81, attack = 102, defense = 77, speed = 85, specialA = 85, specialD = 75 },
      catchRate = 45, baseExp = 253, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 62,
      dexEntry = { kind = "Drill Pokémon",
        text = "When it goes on a rampage, it’s impossible to control. But in the presence of a Nidoqueen it’s lived with for a long time, Nidoking calms down." },
    },

    CLEFAIRY = {
      dex = 35, name = "Clefairy", types = { "FAIRY" },
      baseStats = { hp = 70, attack = 45, defense = 48, speed = 35, specialA = 60, specialD = 65 },
      catchRate = 150, baseExp = 113, growthRate = "FAST", happiness = 140,
      evolutions = {
        { method = "ITEM", species = "CLEFABLE", item = "MOONSTONE" },
      },
      heightM = 0.6, weightKg = 7.5,
      dexEntry = { kind = "Fairy Pokémon",
        text = "It is said that happiness will come to those who see a gathering of Clefairy dancing under a full moon." },
    },

    CLEFABLE = {
      dex = 36, name = "Clefable", types = { "FAIRY" },
      baseStats = { hp = 95, attack = 70, defense = 73, speed = 60, specialA = 95, specialD = 90 },
      catchRate = 25, baseExp = 242, growthRate = "FAST", happiness = 140,
      evolutions = {},
      heightM = 1.3, weightKg = 40,
      dexEntry = { kind = "Fairy Pokémon",
        text = "A timid fairy Pokémon that is rarely seen, it will run and hide the moment it senses people." },
    },

    VULPIX = {
      dex = 37, name = "Vulpix", types = { "FIRE" },
      baseStats = { hp = 38, attack = 41, defense = 40, speed = 65, specialA = 50, specialD = 65 },
      catchRate = 190, baseExp = 60, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "NINETALES", item = "FIRESTONE" },
      },
      heightM = 0.6, weightKg = 9.9,
      dexEntry = { kind = "Fox Pokémon",
        text = "While young, it has six gorgeous tails. When it grows, several new tails are sprouted." },
    },

    NINETALES = {
      dex = 38, name = "Ninetales", types = { "FIRE" },
      baseStats = { hp = 73, attack = 76, defense = 75, speed = 100, specialA = 81, specialD = 100 },
      catchRate = 75, baseExp = 177, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 19.9,
      dexEntry = { kind = "Fox Pokémon",
        text = "It is said to live 1,000 years, and each of its tails is loaded with supernatural powers." },
    },

    JIGGLYPUFF = {
      dex = 39, name = "Jigglypuff", types = { "NORMAL", "FAIRY" },
      baseStats = { hp = 115, attack = 45, defense = 20, speed = 20, specialA = 45, specialD = 25 },
      catchRate = 170, baseExp = 95, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "WIGGLYTUFF", item = "MOONSTONE" },
      },
      heightM = 0.5, weightKg = 5.5,
      dexEntry = { kind = "Balloon Pokémon",
        text = "Jigglypuff has top-notch lung capacity, even by comparison to other Pokémon. It won’t stop singing its lullabies until its foes fall asleep." },
    },

    WIGGLYTUFF = {
      dex = 40, name = "Wigglytuff", types = { "NORMAL", "FAIRY" },
      baseStats = { hp = 140, attack = 70, defense = 45, speed = 45, specialA = 85, specialD = 50 },
      catchRate = 50, baseExp = 218, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 12,
      dexEntry = { kind = "Balloon Pokémon",
        text = "The more air it takes in, the more it inflates. If opponents catch it in a bad mood, it will inflate itself to an enormous size to intimidate them." },
    },

    ZUBAT = {
      dex = 41, name = "Zubat", types = { "POISON", "FLYING" },
      baseStats = { hp = 40, attack = 45, defense = 35, speed = 55, specialA = 30, specialD = 40 },
      catchRate = 255, baseExp = 49, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GOLBAT", level = 22 },
      },
      heightM = 0.8, weightKg = 7.5,
      dexEntry = { kind = "Bat Pokémon",
        text = "It emits ultrasonic waves from its mouth to check its surroundings. Even in tight caves, Zubat flies around with skill." },
    },

    GOLBAT = {
      dex = 42, name = "Golbat", types = { "POISON", "FLYING" },
      baseStats = { hp = 75, attack = 80, defense = 70, speed = 90, specialA = 65, specialD = 75 },
      catchRate = 90, baseExp = 159, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HAPPINESS", species = "CROBAT" },
      },
      heightM = 1.6, weightKg = 55,
      dexEntry = { kind = "Bat Pokémon",
        text = "It loves to drink other creatures’ blood. It’s said that if it finds others of its kind going hungry, it sometimes shares the blood it’s gathered." },
    },

    ODDISH = {
      dex = 43, name = "Oddish", types = { "GRASS", "POISON" },
      baseStats = { hp = 45, attack = 50, defense = 55, speed = 30, specialA = 75, specialD = 65 },
      catchRate = 255, baseExp = 64, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GLOOM", level = 21 },
      },
      heightM = 0.5, weightKg = 5.4,
      dexEntry = { kind = "Weed Pokémon",
        text = "If exposed to moonlight, it starts to move. It roams far and wide at night to scatter its seeds." },
    },

    GLOOM = {
      dex = 44, name = "Gloom", types = { "GRASS", "POISON" },
      baseStats = { hp = 60, attack = 65, defense = 70, speed = 40, specialA = 85, specialD = 75 },
      catchRate = 120, baseExp = 138, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "VILEPLUME", item = "LEAFSTONE" },
        { method = "ITEM", species = "BELLOSSOM", item = "SUNSTONE" },
      },
      heightM = 0.8, weightKg = 8.6,
      dexEntry = { kind = "Weed Pokémon",
        text = "Its pistils exude an incredibly foul odor. The horrid stench can cause fainting at a distance of 1.25 miles." },
    },

    VILEPLUME = {
      dex = 45, name = "Vileplume", types = { "GRASS", "POISON" },
      baseStats = { hp = 75, attack = 80, defense = 85, speed = 50, specialA = 110, specialD = 90 },
      catchRate = 45, baseExp = 245, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 18.6,
      dexEntry = { kind = "Flower Pokémon",
        text = "It has the world’s largest petals. With every step, the petals shake out heavy clouds of toxic pollen." },
    },

    PARAS = {
      dex = 46, name = "Paras", types = { "BUG", "GRASS" },
      baseStats = { hp = 35, attack = 70, defense = 55, speed = 25, specialA = 45, specialD = 55 },
      catchRate = 190, baseExp = 57, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PARASECT", level = 24 },
      },
      heightM = 0.3, weightKg = 5.4,
      dexEntry = { kind = "Mushroom Pokémon",
        text = "Burrows under the ground to gnaw on tree roots. The mushrooms on its back absorb most of the nutrition." },
    },

    PARASECT = {
      dex = 47, name = "Parasect", types = { "BUG", "GRASS" },
      baseStats = { hp = 60, attack = 95, defense = 80, speed = 30, specialA = 60, specialD = 80 },
      catchRate = 75, baseExp = 142, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 29.5,
      dexEntry = { kind = "Mushroom Pokémon",
        text = "The bug host is drained of energy by the mushroom on its back. The mushroom appears to do all the thinking." },
    },

    VENONAT = {
      dex = 48, name = "Venonat", types = { "BUG", "POISON" },
      baseStats = { hp = 60, attack = 55, defense = 50, speed = 45, specialA = 40, specialD = 55 },
      catchRate = 190, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "VENOMOTH", level = 31 },
      },
      heightM = 1, weightKg = 30,
      dexEntry = { kind = "Insect Pokémon",
        text = "Its large eyes act as radar. In a bright place, you can see that they are clusters of many tiny eyes." },
    },

    VENOMOTH = {
      dex = 49, name = "Venomoth", types = { "BUG", "POISON" },
      baseStats = { hp = 70, attack = 65, defense = 60, speed = 90, specialA = 90, specialD = 75 },
      catchRate = 75, baseExp = 158, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 12.5,
      dexEntry = { kind = "Poison Moth Pokémon",
        text = "The powdery scales on its wings are hard to remove from skin. They also contain poison that leaks out on contact." },
    },

    DIGLETT = {
      dex = 50, name = "Diglett", types = { "GROUND" },
      baseStats = { hp = 10, attack = 55, defense = 25, speed = 95, specialA = 35, specialD = 45 },
      catchRate = 255, baseExp = 53, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DUGTRIO", level = 26 },
      },
      heightM = 0.2, weightKg = 0.8,
      dexEntry = { kind = "Mole Pokémon",
        text = "If a Diglett digs through a field, it leaves the soil perfectly tilled and ideal for planting crops." },
    },

    DUGTRIO = {
      dex = 51, name = "Dugtrio", types = { "GROUND" },
      baseStats = { hp = 35, attack = 100, defense = 50, speed = 120, specialA = 50, specialD = 70 },
      catchRate = 50, baseExp = 149, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 33.3,
      dexEntry = { kind = "Mole Pokémon",
        text = "A team of Diglett triplets. It triggers huge earthquakes by burrowing 60 miles underground." },
    },

    MEOWTH = {
      dex = 52, name = "Meowth", types = { "NORMAL" },
      baseStats = { hp = 40, attack = 45, defense = 35, speed = 90, specialA = 40, specialD = 40 },
      catchRate = 255, baseExp = 58, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PERSIAN", level = 28 },
      },
      heightM = 0.4, weightKg = 4.2,
      dexEntry = { kind = "Scratch Cat Pokémon",
        text = "It loves to collect shiny things. If it’s in a good mood, it might even let its Trainer have a look at its hoard of treasures." },
    },

    PERSIAN = {
      dex = 53, name = "Persian", types = { "NORMAL" },
      baseStats = { hp = 65, attack = 70, defense = 60, speed = 115, specialA = 65, specialD = 65 },
      catchRate = 90, baseExp = 154, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 32,
      dexEntry = { kind = "Classy Cat Pokémon",
        text = "Getting this prideful Pokémon to warm up to you takes a lot of effort, and it will claw at you the moment it gets annoyed." },
    },

    PSYDUCK = {
      dex = 54, name = "Psyduck", types = { "WATER" },
      baseStats = { hp = 50, attack = 52, defense = 48, speed = 55, specialA = 65, specialD = 50 },
      catchRate = 190, baseExp = 64, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GOLDUCK", level = 33 },
      },
      heightM = 0.8, weightKg = 19.6,
      dexEntry = { kind = "Duck Pokémon",
        text = "Psyduck is constantly beset by headaches. If the Pokémon lets its strange power erupt, apparently the pain subsides for a while." },
    },

    GOLDUCK = {
      dex = 55, name = "Golduck", types = { "WATER" },
      baseStats = { hp = 80, attack = 82, defense = 78, speed = 85, specialA = 95, specialD = 80 },
      catchRate = 75, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 76.6,
      dexEntry = { kind = "Duck Pokémon",
        text = "This Pokémon lives in gently flowing rivers. It paddles through the water with its long limbs, putting its graceful swimming skills on display." },
    },

    MANKEY = {
      dex = 56, name = "Mankey", types = { "FIGHTING" },
      baseStats = { hp = 40, attack = 80, defense = 35, speed = 70, specialA = 35, specialD = 45 },
      catchRate = 190, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PRIMEAPE", level = 28 },
      },
      heightM = 0.5, weightKg = 28,
      dexEntry = { kind = "Pig Monkey Pokémon",
        text = "An agile Pokémon that lives in trees. It angers easily and will not hesitate to attack anything." },
    },

    PRIMEAPE = {
      dex = 57, name = "Primeape", types = { "FIGHTING" },
      baseStats = { hp = 65, attack = 105, defense = 60, speed = 95, specialA = 60, specialD = 70 },
      catchRate = 75, baseExp = 159, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVELUSEMOVECOUNT", species = "ANNIHILAPE" },
      },
      heightM = 1, weightKg = 32,
      dexEntry = { kind = "Pig Monkey Pokémon",
        text = "It stops being angry only when nobody else is around. To view this moment is very difficult." },
    },

    GROWLITHE = {
      dex = 58, name = "Growlithe", types = { "FIRE" },
      baseStats = { hp = 55, attack = 70, defense = 45, speed = 60, specialA = 70, specialD = 50 },
      catchRate = 190, baseExp = 70, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "ARCANINE", item = "FIRESTONE" },
      },
      heightM = 0.7, weightKg = 19,
      dexEntry = { kind = "Puppy Pokémon",
        text = "It has a brave and trustworthy nature. It fearlessly stands up to bigger and stronger foes." },
    },

    ARCANINE = {
      dex = 59, name = "Arcanine", types = { "FIRE" },
      baseStats = { hp = 90, attack = 110, defense = 80, speed = 95, specialA = 100, specialD = 80 },
      catchRate = 75, baseExp = 194, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 155,
      dexEntry = { kind = "Legendary Pokémon",
        text = "The sight of it running over 6,200 miles in a single day and night has captivated many people." },
    },

    POLIWAG = {
      dex = 60, name = "Poliwag", types = { "WATER" },
      baseStats = { hp = 40, attack = 50, defense = 40, speed = 90, specialA = 40, specialD = 40 },
      catchRate = 255, baseExp = 60, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "POLIWHIRL", level = 25 },
      },
      heightM = 0.6, weightKg = 12.4,
      dexEntry = { kind = "Tadpole Pokémon",
        text = "For Poliwag, swimming is easier than walking. The swirl pattern on its belly is actually part of the Pokémon’s innards showing through the skin." },
    },

    POLIWHIRL = {
      dex = 61, name = "Poliwhirl", types = { "WATER" },
      baseStats = { hp = 65, attack = 65, defense = 65, speed = 90, specialA = 50, specialD = 50 },
      catchRate = 120, baseExp = 135, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "POLIWRATH", item = "WATERSTONE" },
        { method = "CABLELINKITEM", species = "POLITOED" },
      },
      heightM = 1, weightKg = 20,
      dexEntry = { kind = "Tadpole Pokémon",
        text = "Staring at the swirl on its belly causes drowsiness. This trait of Poliwhirl’s has been used in place of lullabies to get children to go to sleep." },
    },

    POLIWRATH = {
      dex = 62, name = "Poliwrath", types = { "WATER", "FIGHTING" },
      baseStats = { hp = 90, attack = 95, defense = 95, speed = 70, specialA = 70, specialD = 90 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 54,
      dexEntry = { kind = "Tadpole Pokémon",
        text = "Its body is solid muscle. When swimming through cold seas, Poliwrath uses its impressive arms to smash through drift ice and plow forward." },
    },

    ABRA = {
      dex = 63, name = "Abra", types = { "PSYCHIC" },
      baseStats = { hp = 25, attack = 20, defense = 15, speed = 90, specialA = 105, specialD = 55 },
      catchRate = 200, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "KADABRA", level = 16 },
      },
      heightM = 0.9, weightKg = 19.5,
      dexEntry = { kind = "Psi Pokémon",
        text = "This Pokémon uses its psychic powers while it sleeps. The contents of Abra’s dreams affect the powers that the Pokémon wields." },
    },

    KADABRA = {
      dex = 64, name = "Kadabra", types = { "PSYCHIC" },
      baseStats = { hp = 40, attack = 35, defense = 30, speed = 105, specialA = 120, specialD = 70 },
      catchRate = 100, baseExp = 140, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "TRADE", species = "ALAKAZAM" },
        { method = "ITEM", species = "ALAKAZAM", item = "LINKINGCORD" },
      },
      heightM = 1.3, weightKg = 56.5,
      dexEntry = { kind = "Psi Pokémon",
        text = "Using its psychic power, Kadabra levitates as it sleeps. It uses its springy tail as a pillow." },
    },

    ALAKAZAM = {
      dex = 65, name = "Alakazam", types = { "PSYCHIC" },
      baseStats = { hp = 55, attack = 50, defense = 45, speed = 120, specialA = 135, specialD = 95 },
      catchRate = 50, baseExp = 250, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 48,
      dexEntry = { kind = "Psi Pokémon",
        text = "It has an incredibly high level of intelligence. Some say that Alakazam remembers everything that ever happens to it, from birth till death." },
    },

    MACHOP = {
      dex = 66, name = "Machop", types = { "FIGHTING" },
      baseStats = { hp = 70, attack = 80, defense = 50, speed = 35, specialA = 35, specialD = 35 },
      catchRate = 180, baseExp = 61, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MACHOKE", level = 28 },
      },
      heightM = 0.8, weightKg = 19.5,
      dexEntry = { kind = "Superpower Pokémon",
        text = "Its whole body is composed of muscles. Even though it’s the size of a human child, it can hurl 100 grown-ups." },
    },

    MACHOKE = {
      dex = 67, name = "Machoke", types = { "FIGHTING" },
      baseStats = { hp = 80, attack = 100, defense = 70, speed = 45, specialA = 50, specialD = 60 },
      catchRate = 90, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "TRADE", species = "MACHAMP" },
        { method = "ITEM", species = "MACHAMP", item = "LINKINGCORD" },
      },
      heightM = 1.5, weightKg = 70.5,
      dexEntry = { kind = "Superpower Pokémon",
        text = "Its muscular body is so powerful, it must wear a power-save belt to be able to regulate its motions." },
    },

    MACHAMP = {
      dex = 68, name = "Machamp", types = { "FIGHTING" },
      baseStats = { hp = 90, attack = 130, defense = 80, speed = 55, specialA = 65, specialD = 85 },
      catchRate = 45, baseExp = 253, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 130,
      dexEntry = { kind = "Superpower Pokémon",
        text = "It quickly swings its four arms to rock its opponents with ceaseless punches and chops from all angles." },
    },

    BELLSPROUT = {
      dex = 69, name = "Bellsprout", types = { "GRASS", "POISON" },
      baseStats = { hp = 50, attack = 75, defense = 35, speed = 40, specialA = 70, specialD = 30 },
      catchRate = 255, baseExp = 60, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "WEEPINBELL", level = 21 },
      },
      heightM = 0.7, weightKg = 4,
      dexEntry = { kind = "Flower Pokémon",
        text = "Prefers hot and humid places. It ensnares tiny bugs with its vines and devours them." },
    },

    WEEPINBELL = {
      dex = 70, name = "Weepinbell", types = { "GRASS", "POISON" },
      baseStats = { hp = 65, attack = 90, defense = 50, speed = 55, specialA = 85, specialD = 45 },
      catchRate = 120, baseExp = 137, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "VICTREEBEL", item = "LEAFSTONE" },
      },
      heightM = 1, weightKg = 6.4,
      dexEntry = { kind = "Flycatcher Pokémon",
        text = "When hungry, it swallows anything that moves. Its hapless prey is dissolved by strong acids." },
    },

    VICTREEBEL = {
      dex = 71, name = "Victreebel", types = { "GRASS", "POISON" },
      baseStats = { hp = 80, attack = 105, defense = 65, speed = 70, specialA = 100, specialD = 70 },
      catchRate = 45, baseExp = 245, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 15.5,
      dexEntry = { kind = "Flycatcher Pokémon",
        text = "Lures prey with the sweet aroma of honey. Swallowed whole, the prey is dissolved in a day, bones and all." },
    },

    TENTACOOL = {
      dex = 72, name = "Tentacool", types = { "WATER", "POISON" },
      baseStats = { hp = 40, attack = 40, defense = 35, speed = 70, specialA = 50, specialD = 100 },
      catchRate = 190, baseExp = 67, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TENTACRUEL", level = 30 },
      },
      heightM = 0.9, weightKg = 45.5,
      dexEntry = { kind = "Jellyfish Pokémon",
        text = "Tentacool is not a particularly strong swimmer. It drifts across the surface of shallow seas as it searches for prey." },
    },

    TENTACRUEL = {
      dex = 73, name = "Tentacruel", types = { "WATER", "POISON" },
      baseStats = { hp = 80, attack = 70, defense = 65, speed = 100, specialA = 80, specialD = 120 },
      catchRate = 60, baseExp = 180, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 55,
      dexEntry = { kind = "Jellyfish Pokémon",
        text = "When the red orbs on Tentacruel’s head glow brightly, watch out. The Pokémon is about to fire off a burst of ultrasonic waves." },
    },

    GEODUDE = {
      dex = 74, name = "Geodude", types = { "ROCK", "GROUND" },
      baseStats = { hp = 40, attack = 80, defense = 100, speed = 20, specialA = 30, specialD = 30 },
      catchRate = 255, baseExp = 60, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GRAVELER", level = 25 },
      },
      heightM = 0.4, weightKg = 20,
      dexEntry = { kind = "Rock Pokémon",
        text = "Commonly found near mountain trails and the like. If you step on one by accident, it gets angry." },
    },

    GRAVELER = {
      dex = 75, name = "Graveler", types = { "ROCK", "GROUND" },
      baseStats = { hp = 55, attack = 95, defense = 115, speed = 35, specialA = 45, specialD = 45 },
      catchRate = 120, baseExp = 137, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "TRADE", species = "GOLEM" },
        { method = "ITEM", species = "GOLEM", item = "LINKINGCORD" },
      },
      heightM = 1, weightKg = 105,
      dexEntry = { kind = "Rock Pokémon",
        text = "Often seen rolling down mountain trails. Obstacles are just things to roll straight over, not avoid." },
    },

    GOLEM = {
      dex = 76, name = "Golem", types = { "ROCK", "GROUND" },
      baseStats = { hp = 80, attack = 120, defense = 130, speed = 45, specialA = 55, specialD = 65 },
      catchRate = 45, baseExp = 248, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 300,
      dexEntry = { kind = "Megaton Pokémon",
        text = "Once it sheds its skin, its body turns tender and whitish. Its hide hardens when it’s exposed to air." },
    },

    PONYTA = {
      dex = 77, name = "Ponyta", types = { "FIRE" },
      baseStats = { hp = 50, attack = 85, defense = 55, speed = 90, specialA = 65, specialD = 65 },
      catchRate = 190, baseExp = 82, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "RAPIDASH", level = 40 },
      },
      heightM = 1, weightKg = 30,
      dexEntry = { kind = "Fire Horse Pokémon",
        text = "It can’t run properly when it’s newly born. As it races around with others of its kind, its legs grow stronger." },
    },

    RAPIDASH = {
      dex = 78, name = "Rapidash", types = { "FIRE" },
      baseStats = { hp = 65, attack = 100, defense = 70, speed = 105, specialA = 80, specialD = 80 },
      catchRate = 60, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 95,
      dexEntry = { kind = "Fire Horse Pokémon",
        text = "This Pokémon can be seen galloping through fields at speeds of up to 150 mph, its fiery mane fluttering in the wind." },
    },

    SLOWPOKE = {
      dex = 79, name = "Slowpoke", types = { "WATER", "PSYCHIC" },
      baseStats = { hp = 90, attack = 65, defense = 65, speed = 15, specialA = 40, specialD = 40 },
      catchRate = 190, baseExp = 63, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SLOWBRO", level = 37 },
        { method = "CABLELINKITEM", species = "SLOWKING" },
      },
      heightM = 1.2, weightKg = 36,
      dexEntry = { kind = "Dopey Pokémon",
        text = "Slow-witted and oblivious, this Pokémon won’t feel any pain if its tail gets eaten. It won’t notice when its tail grows back, either." },
    },

    SLOWBRO = {
      dex = 80, name = "Slowbro", types = { "WATER", "PSYCHIC" },
      baseStats = { hp = 95, attack = 75, defense = 110, speed = 30, specialA = 100, specialD = 80 },
      catchRate = 75, baseExp = 172, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 78.5,
      dexEntry = { kind = "Hermit Crab Pokémon",
        text = "Slowpoke became Slowbro when a Shellder bit on to its tail. Sweet flavors seeping from the tail make the Shellder feel as if its life is a dream." },
    },

    MAGNEMITE = {
      dex = 81, name = "Magnemite", types = { "ELECTRIC", "STEEL" },
      baseStats = { hp = 25, attack = 35, defense = 70, speed = 45, specialA = 95, specialD = 55 },
      catchRate = 190, baseExp = 65, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MAGNETON", level = 30 },
      },
      heightM = 0.3, weightKg = 6,
      dexEntry = { kind = "Magnet Pokémon",
        text = "At times, Magnemite runs out of electricity and ends up on the ground. If you give batteries to a grounded Magnemite, it’ll start moving again." },
    },

    MAGNETON = {
      dex = 82, name = "Magneton", types = { "ELECTRIC", "STEEL" },
      baseStats = { hp = 50, attack = 60, defense = 95, speed = 70, specialA = 120, specialD = 70 },
      catchRate = 60, baseExp = 163, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "MAGNEZONE", item = "THUNDERSTONE" },
        { method = "LOCATIONFLAG", species = "MAGNEZONE" },
      },
      heightM = 1, weightKg = 60,
      dexEntry = { kind = "Magnet Pokémon",
        text = "This Pokémon is three Magnemite that have linked together. Magneton sends out powerful radio waves to study its surroundings." },
    },

    FARFETCHD = {
      dex = 83, name = "Farfetch'd", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 52, attack = 90, defense = 55, speed = 60, specialA = 58, specialD = 62 },
      catchRate = 45, baseExp = 132, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "NONE", species = "SIRFETCHD" },
      },
      heightM = 0.8, weightKg = 15,
      dexEntry = { kind = "Wild Duck Pokémon",
        text = "The stalk this Pokémon carries in its wings serves as a sword to cut down opponents. In a dire situation, the stalk can also serve as food." },
    },

    DODUO = {
      dex = 84, name = "Doduo", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 35, attack = 85, defense = 45, speed = 75, specialA = 35, specialD = 35 },
      catchRate = 190, baseExp = 62, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DODRIO", level = 31 },
      },
      heightM = 1.4, weightKg = 39.2,
      dexEntry = { kind = "Twin Bird Pokémon",
        text = "Its short wings make flying difficult. Instead, this Pokémon runs at high speed on developed legs." },
    },

    DODRIO = {
      dex = 85, name = "Dodrio", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 60, attack = 110, defense = 70, speed = 110, specialA = 60, specialD = 60 },
      catchRate = 45, baseExp = 165, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 85.2,
      dexEntry = { kind = "Triple Bird Pokémon",
        text = "One of Doduo’s two heads splits to form a unique species. It runs close to 40 mph in prairies." },
    },

    SEEL = {
      dex = 86, name = "Seel", types = { "WATER" },
      baseStats = { hp = 65, attack = 45, defense = 55, speed = 45, specialA = 45, specialD = 70 },
      catchRate = 190, baseExp = 65, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DEWGONG", level = 34 },
      },
      heightM = 1.1, weightKg = 90,
      dexEntry = { kind = "Sea Lion Pokémon",
        text = "Loves freezing-cold conditions. Relishes swimming in a frigid climate of around 14 degrees Fahrenheit." },
    },

    DEWGONG = {
      dex = 87, name = "Dewgong", types = { "WATER", "ICE" },
      baseStats = { hp = 90, attack = 70, defense = 80, speed = 70, specialA = 70, specialD = 95 },
      catchRate = 75, baseExp = 166, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 120,
      dexEntry = { kind = "Sea Lion Pokémon",
        text = "Its entire body is a snowy white. Unharmed by even intense cold, it swims powerfully in icy waters." },
    },

    GRIMER = {
      dex = 88, name = "Grimer", types = { "POISON" },
      baseStats = { hp = 80, attack = 80, defense = 50, speed = 25, specialA = 40, specialD = 50 },
      catchRate = 190, baseExp = 65, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MUK", level = 38 },
      },
      heightM = 0.9, weightKg = 30,
      dexEntry = { kind = "Sludge Pokémon",
        text = "Made of congealed sludge. It smells too putrid to touch. Even weeds won’t grow in its path." },
    },

    MUK = {
      dex = 89, name = "Muk", types = { "POISON" },
      baseStats = { hp = 105, attack = 105, defense = 75, speed = 50, specialA = 65, specialD = 100 },
      catchRate = 75, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 30,
      dexEntry = { kind = "Sludge Pokémon",
        text = "Smells so awful, it can cause fainting. Through degeneration of its nose, it lost its sense of smell." },
    },

    SHELLDER = {
      dex = 90, name = "Shellder", types = { "WATER" },
      baseStats = { hp = 30, attack = 65, defense = 100, speed = 40, specialA = 45, specialD = 25 },
      catchRate = 190, baseExp = 61, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "CLOYSTER", item = "WATERSTONE" },
      },
      heightM = 0.3, weightKg = 4,
      dexEntry = { kind = "Bivalve Pokémon",
        text = "It swims facing backward by opening and closing its two-piece shell. It is surprisingly fast." },
    },

    CLOYSTER = {
      dex = 91, name = "Cloyster", types = { "WATER", "ICE" },
      baseStats = { hp = 50, attack = 95, defense = 180, speed = 70, specialA = 85, specialD = 45 },
      catchRate = 60, baseExp = 184, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 132.5,
      dexEntry = { kind = "Bivalve Pokémon",
        text = "Its shell is extremely hard. It cannot be shattered, even with a bomb. The shell opens only when it is attacking." },
    },

    GASTLY = {
      dex = 92, name = "Gastly", types = { "GHOST", "POISON" },
      baseStats = { hp = 30, attack = 35, defense = 30, speed = 80, specialA = 100, specialD = 35 },
      catchRate = 190, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "HAUNTER", level = 25 },
      },
      heightM = 1.3, weightKg = 0.1,
      dexEntry = { kind = "Gas Pokémon",
        text = "Born from gases, anyone would faint if engulfed by its gaseous body, which contains poison." },
    },

    HAUNTER = {
      dex = 93, name = "Haunter", types = { "GHOST", "POISON" },
      baseStats = { hp = 45, attack = 50, defense = 45, speed = 95, specialA = 115, specialD = 55 },
      catchRate = 90, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "TRADE", species = "GENGAR" },
        { method = "ITEM", species = "GENGAR", item = "LINKINGCORD" },
      },
      heightM = 1.6, weightKg = 0.1,
      dexEntry = { kind = "Gas Pokémon",
        text = "Its tongue is made of gas. If licked, its victim starts shaking constantly until death eventually comes." },
    },

    GENGAR = {
      dex = 94, name = "Gengar", types = { "GHOST", "POISON" },
      baseStats = { hp = 60, attack = 65, defense = 60, speed = 110, specialA = 130, specialD = 75 },
      catchRate = 45, baseExp = 250, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 40.5,
      dexEntry = { kind = "Shadow Pokémon",
        text = "On the night of a full moon, if shadows move on their own and laugh, it must be Gengar’s doing." },
    },

    ONIX = {
      dex = 95, name = "Onix", types = { "ROCK", "GROUND" },
      baseStats = { hp = 35, attack = 45, defense = 160, speed = 70, specialA = 30, specialD = 45 },
      catchRate = 45, baseExp = 77, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "STEELIX" },
      },
      heightM = 8.8, weightKg = 210,
      dexEntry = { kind = "Rock Snake Pokémon",
        text = "As it digs through the ground, it absorbs many hard objects. This is what makes its body so solid." },
    },

    DROWZEE = {
      dex = 96, name = "Drowzee", types = { "PSYCHIC" },
      baseStats = { hp = 60, attack = 48, defense = 45, speed = 42, specialA = 43, specialD = 90 },
      catchRate = 190, baseExp = 66, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "HYPNO", level = 26 },
      },
      heightM = 1, weightKg = 32.4,
      dexEntry = { kind = "Hypnosis Pokémon",
        text = "If you sleep by it all the time, it will sometimes show you dreams it had eaten in the past." },
    },

    HYPNO = {
      dex = 97, name = "Hypno", types = { "PSYCHIC" },
      baseStats = { hp = 85, attack = 73, defense = 70, speed = 67, specialA = 73, specialD = 115 },
      catchRate = 75, baseExp = 169, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 75.6,
      dexEntry = { kind = "Hypnosis Pokémon",
        text = "Avoid eye contact if you come across one. It will try to put you to sleep by using its pendulum." },
    },

    KRABBY = {
      dex = 98, name = "Krabby", types = { "WATER" },
      baseStats = { hp = 30, attack = 105, defense = 90, speed = 50, specialA = 25, specialD = 25 },
      catchRate = 225, baseExp = 65, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "KINGLER", level = 28 },
      },
      heightM = 0.4, weightKg = 6.5,
      dexEntry = { kind = "River Crab Pokémon",
        text = "It can be found near the sea. The large pincers grow back if they are torn out of their sockets." },
    },

    KINGLER = {
      dex = 99, name = "Kingler", types = { "WATER" },
      baseStats = { hp = 55, attack = 130, defense = 115, speed = 75, specialA = 50, specialD = 50 },
      catchRate = 60, baseExp = 166, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 60,
      dexEntry = { kind = "Pincer Pokémon",
        text = "Its large and hard pincer has 10,000-horsepower strength. However, being so big, it is unwieldy to move." },
    },

    VOLTORB = {
      dex = 100, name = "Voltorb", types = { "ELECTRIC" },
      baseStats = { hp = 40, attack = 30, defense = 50, speed = 100, specialA = 55, specialD = 55 },
      catchRate = 190, baseExp = 66, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ELECTRODE", level = 30 },
      },
      heightM = 0.5, weightKg = 10.4,
      dexEntry = { kind = "Ball Pokémon",
        text = "It is said to camouflage itself as a Poké Ball. It will self-destruct with very little stimulus." },
    },

    ELECTRODE = {
      dex = 101, name = "Electrode", types = { "ELECTRIC" },
      baseStats = { hp = 60, attack = 50, defense = 70, speed = 150, specialA = 80, specialD = 80 },
      catchRate = 60, baseExp = 172, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 66.6,
      dexEntry = { kind = "Ball Pokémon",
        text = "Stores electrical energy inside its body. Even the slightest shock could trigger a huge explosion." },
    },

    EXEGGCUTE = {
      dex = 102, name = "Exeggcute", types = { "GRASS", "PSYCHIC" },
      baseStats = { hp = 60, attack = 40, defense = 80, speed = 40, specialA = 60, specialD = 45 },
      catchRate = 90, baseExp = 65, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "EXEGGUTOR", item = "LEAFSTONE" },
      },
      heightM = 0.4, weightKg = 2.5,
      dexEntry = { kind = "Egg Pokémon",
        text = "Though it may look like it’s just a bunch of eggs, it’s a proper Pokémon. Exeggcute communicates with others of its kind via telepathy, apparently." },
    },

    EXEGGUTOR = {
      dex = 103, name = "Exeggutor", types = { "GRASS", "PSYCHIC" },
      baseStats = { hp = 95, attack = 95, defense = 85, speed = 55, specialA = 125, specialD = 75 },
      catchRate = 45, baseExp = 186, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 120,
      dexEntry = { kind = "Coconut Pokémon",
        text = "Each of Exeggutor’s three heads is thinking different thoughts. The three don’t seem to be very interested in one another." },
    },

    CUBONE = {
      dex = 104, name = "Cubone", types = { "GROUND" },
      baseStats = { hp = 50, attack = 50, defense = 95, speed = 35, specialA = 40, specialD = 50 },
      catchRate = 190, baseExp = 64, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MAROWAK", level = 28 },
      },
      heightM = 0.4, weightKg = 6.5,
      dexEntry = { kind = "Lonely Pokémon",
        text = "When the memory of its departed mother brings it to tears, its cries echo mournfully within the skull it wears on its head." },
    },

    MAROWAK = {
      dex = 105, name = "Marowak", types = { "GROUND" },
      baseStats = { hp = 60, attack = 80, defense = 110, speed = 45, specialA = 50, specialD = 80 },
      catchRate = 75, baseExp = 149, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 45,
      dexEntry = { kind = "Bone Keeper Pokémon",
        text = "This Pokémon overcame its sorrow to evolve a sturdy new body. Marowak faces its opponents bravely, using a bone as a weapon." },
    },

    HITMONLEE = {
      dex = 106, name = "Hitmonlee", types = { "FIGHTING" },
      baseStats = { hp = 50, attack = 120, defense = 53, speed = 87, specialA = 35, specialD = 110 },
      catchRate = 45, baseExp = 159, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 49.8,
      dexEntry = { kind = "Kicking Pokémon",
        text = "This amazing Pokémon has an awesome sense of balance. It can kick in succession from any position." },
    },

    HITMONCHAN = {
      dex = 107, name = "Hitmonchan", types = { "FIGHTING" },
      baseStats = { hp = 50, attack = 105, defense = 79, speed = 76, specialA = 35, specialD = 110 },
      catchRate = 45, baseExp = 159, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 50.2,
      dexEntry = { kind = "Punching Pokémon",
        text = "Its punches slice the air. They are launched at such high speed, even a slight graze could cause a burn." },
    },

    LICKITUNG = {
      dex = 108, name = "Lickitung", types = { "NORMAL" },
      baseStats = { hp = 90, attack = 55, defense = 75, speed = 30, specialA = 60, specialD = 75 },
      catchRate = 45, baseExp = 77, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HAS_MOVE", species = "LICKILICKY", move = "ROLLOUT" },
      },
      heightM = 1.2, weightKg = 65.5,
      dexEntry = { kind = "Licking Pokémon",
        text = "If this Pokémon’s sticky saliva gets on you and you don’t clean it off, an intense itch will set in. The itch won’t go away, either." },
    },

    KOFFING = {
      dex = 109, name = "Koffing", types = { "POISON" },
      baseStats = { hp = 40, attack = 65, defense = 95, speed = 35, specialA = 60, specialD = 45 },
      catchRate = 190, baseExp = 68, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "WEEZING", level = 35 },
      },
      heightM = 0.6, weightKg = 1,
      dexEntry = { kind = "Poison Gas Pokémon",
        text = "Its body is full of poisonous gas. It floats into garbage dumps, seeking out the fumes of raw, rotting trash." },
    },

    WEEZING = {
      dex = 110, name = "Weezing", types = { "POISON" },
      baseStats = { hp = 65, attack = 90, defense = 120, speed = 60, specialA = 85, specialD = 70 },
      catchRate = 60, baseExp = 172, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 9.5,
      dexEntry = { kind = "Poison Gas Pokémon",
        text = "It mixes gases between its two bodies. It’s said that these Pokémon were seen all over the Galar region back in the day." },
    },

    RHYHORN = {
      dex = 111, name = "Rhyhorn", types = { "GROUND", "ROCK" },
      baseStats = { hp = 80, attack = 85, defense = 95, speed = 25, specialA = 30, specialD = 30 },
      catchRate = 120, baseExp = 69, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "RHYDON", level = 42 },
      },
      heightM = 1, weightKg = 115,
      dexEntry = { kind = "Spikes Pokémon",
        text = "Strong, but not too bright, this Pokémon can shatter even a skyscraper with its charging tackles." },
    },

    RHYDON = {
      dex = 112, name = "Rhydon", types = { "GROUND", "ROCK" },
      baseStats = { hp = 105, attack = 130, defense = 120, speed = 40, specialA = 45, specialD = 45 },
      catchRate = 60, baseExp = 170, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "RHYPERIOR" },
      },
      heightM = 1.9, weightKg = 120,
      dexEntry = { kind = "Drill Pokémon",
        text = "It begins walking on its hind legs after evolution. It can punch holes through boulders with its horn." },
    },

    CHANSEY = {
      dex = 113, name = "Chansey", types = { "NORMAL" },
      baseStats = { hp = 250, attack = 5, defense = 5, speed = 50, specialA = 35, specialD = 105 },
      catchRate = 30, baseExp = 255, growthRate = "FAST", happiness = 140,
      evolutions = {
        { method = "HAPPINESS", species = "BLISSEY" },
      },
      heightM = 1.1, weightKg = 34.6,
      dexEntry = { kind = "Egg Pokémon",
        text = "The egg Chansey carries is not only delicious but also packed with nutrition. It’s used as a high-class cooking ingredient." },
    },

    TANGELA = {
      dex = 114, name = "Tangela", types = { "GRASS" },
      baseStats = { hp = 65, attack = 55, defense = 115, speed = 60, specialA = 100, specialD = 40 },
      catchRate = 45, baseExp = 87, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HAS_MOVE", species = "TANGROWTH", move = "ANCIENTPOWER" },
      },
      heightM = 1, weightKg = 35,
      dexEntry = { kind = "Vine Pokémon",
        text = "Hidden beneath a tangle of vines that grows nonstop even if the vines are torn off, this Pokémon’s true appearance remains a mystery." },
    },

    KANGASKHAN = {
      dex = 115, name = "Kangaskhan", types = { "NORMAL" },
      baseStats = { hp = 105, attack = 95, defense = 80, speed = 90, specialA = 40, specialD = 80 },
      catchRate = 45, baseExp = 172, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2.2, weightKg = 80,
      dexEntry = { kind = "Parent Pokémon",
        text = "Although it’s carrying its baby in a pouch on its belly, Kangaskhan is swift on its feet. It intimidates its opponents with quick jabs." },
    },

    HORSEA = {
      dex = 116, name = "Horsea", types = { "WATER" },
      baseStats = { hp = 30, attack = 40, defense = 70, speed = 60, specialA = 70, specialD = 25 },
      catchRate = 225, baseExp = 59, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SEADRA", level = 32 },
      },
      heightM = 0.4, weightKg = 8,
      dexEntry = { kind = "Dragon Pokémon",
        text = "Horsea makes its home in oceans with gentle currents. If this Pokémon is under attack, it spits out pitch-black ink and escapes." },
    },

    SEADRA = {
      dex = 117, name = "Seadra", types = { "WATER" },
      baseStats = { hp = 55, attack = 65, defense = 95, speed = 85, specialA = 95, specialD = 45 },
      catchRate = 75, baseExp = 154, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "KINGDRA" },
      },
      heightM = 1.2, weightKg = 25,
      dexEntry = { kind = "Dragon Pokémon",
        text = "It’s the males that raise the offspring. While Seadra are raising young, the spines on their backs secrete thicker and stronger poison." },
    },

    GOLDEEN = {
      dex = 118, name = "Goldeen", types = { "WATER" },
      baseStats = { hp = 45, attack = 67, defense = 60, speed = 63, specialA = 35, specialD = 50 },
      catchRate = 225, baseExp = 64, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SEAKING", level = 33 },
      },
      heightM = 0.6, weightKg = 15,
      dexEntry = { kind = "Goldfish Pokémon",
        text = "Its dorsal, pectoral, and tail fins wave elegantly in water. That is why it is known as the Water Dancer." },
    },

    SEAKING = {
      dex = 119, name = "Seaking", types = { "WATER" },
      baseStats = { hp = 80, attack = 92, defense = 65, speed = 68, specialA = 65, specialD = 80 },
      catchRate = 60, baseExp = 158, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 39,
      dexEntry = { kind = "Goldfish Pokémon",
        text = "In autumn, its body becomes more fatty in preparing to propose to a mate. It takes on beautiful colors." },
    },

    STARYU = {
      dex = 120, name = "Staryu", types = { "WATER" },
      baseStats = { hp = 30, attack = 45, defense = 55, speed = 85, specialA = 70, specialD = 55 },
      catchRate = 225, baseExp = 68, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "STARMIE", item = "WATERSTONE" },
      },
      heightM = 0.8, weightKg = 34.5,
      dexEntry = { kind = "Starshape Pokémon",
        text = "If you visit a beach at the end of summer, you’ll be able to see groups of Staryu lighting up in a steady rhythm." },
    },

    STARMIE = {
      dex = 121, name = "Starmie", types = { "WATER", "PSYCHIC" },
      baseStats = { hp = 60, attack = 75, defense = 85, speed = 115, specialA = 100, specialD = 85 },
      catchRate = 60, baseExp = 182, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 80,
      dexEntry = { kind = "Mysterious Pokémon",
        text = "This Pokémon has an organ known as its core. The organ glows in seven colors when Starmie is unleashing its potent psychic powers." },
    },

    MRMIME = {
      dex = 122, name = "Mr. Mime", types = { "PSYCHIC", "FAIRY" },
      baseStats = { hp = 40, attack = 45, defense = 65, speed = 90, specialA = 100, specialD = 120 },
      catchRate = 45, baseExp = 161, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "NONE", species = "MRRIME" },
      },
      heightM = 1.3, weightKg = 54.5,
      dexEntry = { kind = "Barrier Pokémon",
        text = "The broadness of its hands may be no coincidence—many scientists believe its palms became enlarged specifically for pantomiming." },
    },

    SCYTHER = {
      dex = 123, name = "Scyther", types = { "BUG", "FLYING" },
      baseStats = { hp = 70, attack = 110, defense = 80, speed = 105, specialA = 55, specialD = 80 },
      catchRate = 45, baseExp = 100, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "SCIZOR" },
        { method = "ITEM", species = "KLEAVOR", item = "BLACKAUGURITE" },
      },
      heightM = 1.5, weightKg = 56,
      dexEntry = { kind = "Mantis Pokémon",
        text = "As Scyther fights more and more battles, its scythes become sharper and sharper. With a single slice, Scyther can fell a massive tree." },
    },

    JYNX = {
      dex = 124, name = "Jynx", types = { "ICE", "PSYCHIC" },
      baseStats = { hp = 65, attack = 50, defense = 35, speed = 95, specialA = 115, specialD = 95 },
      catchRate = 45, baseExp = 159, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 40.6,
      dexEntry = { kind = "Humanshape Pokémon",
        text = "In certain parts of Galar, Jynx was once feared and worshiped as the Queen of Ice." },
    },

    ELECTABUZZ = {
      dex = 125, name = "Electabuzz", types = { "ELECTRIC" },
      baseStats = { hp = 65, attack = 83, defense = 57, speed = 105, specialA = 95, specialD = 85 },
      catchRate = 45, baseExp = 172, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "ELECTIVIRE" },
      },
      heightM = 1.1, weightKg = 30,
      dexEntry = { kind = "Electric Pokémon",
        text = "Many power plants keep Ground-type Pokémon around as a defense against Electabuzz that come seeking electricity." },
    },

    MAGMAR = {
      dex = 126, name = "Magmar", types = { "FIRE" },
      baseStats = { hp = 65, attack = 95, defense = 57, speed = 93, specialA = 100, specialD = 85 },
      catchRate = 45, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "MAGMORTAR" },
      },
      heightM = 1.3, weightKg = 44.5,
      dexEntry = { kind = "Spitfire Pokémon",
        text = "Magmar dispatches its prey with fire. But it regrets this habit once it realizes that it has burned its intended prey to a charred crisp." },
    },

    PINSIR = {
      dex = 127, name = "Pinsir", types = { "BUG" },
      baseStats = { hp = 65, attack = 125, defense = 100, speed = 85, specialA = 55, specialD = 70 },
      catchRate = 45, baseExp = 175, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 55,
      dexEntry = { kind = "Stagbeetle Pokémon",
        text = "These Pokémon judge one another based on pincers. Thicker, more impressive pincers make for more popularity with the opposite gender." },
    },

    TAUROS = {
      dex = 128, name = "Tauros", types = { "NORMAL" },
      baseStats = { hp = 75, attack = 100, defense = 95, speed = 110, specialA = 40, specialD = 70 },
      catchRate = 45, baseExp = 172, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 88.4,
      dexEntry = { kind = "Wild Bull Pokémon",
        text = "When Tauros begins whipping itself with its tails, it’s a warning that the Pokémon is about to charge with astounding speed." },
    },

    MAGIKARP = {
      dex = 129, name = "Magikarp", types = { "WATER" },
      baseStats = { hp = 20, attack = 10, defense = 55, speed = 80, specialA = 15, specialD = 20 },
      catchRate = 255, baseExp = 40, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GYARADOS", level = 20 },
      },
      heightM = 0.9, weightKg = 10,
      dexEntry = { kind = "Fish Pokémon",
        text = "It is virtually worthless in terms of both power and speed. It is the most weak and pathetic Pokémon in the world." },
    },

    GYARADOS = {
      dex = 130, name = "Gyarados", types = { "WATER", "FLYING" },
      baseStats = { hp = 95, attack = 125, defense = 79, speed = 81, specialA = 60, specialD = 100 },
      catchRate = 45, baseExp = 189, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 6.5, weightKg = 235,
      dexEntry = { kind = "Atrocious Pokémon",
        text = "It has an extremely aggressive nature. The Hyper Beam it shoots from its mouth totally incinerates all targets." },
    },

    LAPRAS = {
      dex = 131, name = "Lapras", types = { "WATER", "ICE" },
      baseStats = { hp = 130, attack = 85, defense = 80, speed = 60, specialA = 85, specialD = 95 },
      catchRate = 45, baseExp = 187, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.5, weightKg = 220,
      dexEntry = { kind = "Transport Pokémon",
        text = "A smart and kindhearted Pokémon, it glides across the surface of the sea while its beautiful song echoes around it." },
    },

    DITTO = {
      dex = 132, name = "Ditto", types = { "NORMAL" },
      baseStats = { hp = 48, attack = 48, defense = 48, speed = 48, specialA = 48, specialD = 48 },
      catchRate = 35, baseExp = 101, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 4,
      dexEntry = { kind = "Transform Pokémon",
        text = "It can reconstitute its entire cellular structure to change into what it sees, but it returns to normal when it relaxes." },
    },

    EEVEE = {
      dex = 133, name = "Eevee", types = { "NORMAL" },
      baseStats = { hp = 55, attack = 55, defense = 50, speed = 55, specialA = 45, specialD = 65 },
      catchRate = 45, baseExp = 65, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "VAPOREON", item = "WATERSTONE" },
        { method = "ITEM", species = "FLAREON", item = "FIRESTONE" },
        { method = "ITEM", species = "LEAFEON", item = "LEAFSTONE" },
        { method = "LOCATIONFLAG", species = "LEAFEON" },
        { method = "ITEM", species = "GLACEON", item = "ICESTONE" },
        { method = "LOCATIONFLAG", species = "GLACEON" },
        { method = "HAPPINESSMOVETYPE", species = "SYLVEON" },
        { method = "HAPPINESSDAY", species = "ESPEON" },
        { method = "HAPPINESSNIGHT", species = "UMBREON" },
      },
      heightM = 0.3, weightKg = 6.5,
      dexEntry = { kind = "Evolution Pokémon",
        text = "It has the ability to alter the composition of its body to suit its surrounding environment." },
    },

    VAPOREON = {
      dex = 134, name = "Vaporeon", types = { "WATER" },
      baseStats = { hp = 130, attack = 65, defense = 60, speed = 65, specialA = 110, specialD = 95 },
      catchRate = 45, baseExp = 184, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 29,
      dexEntry = { kind = "Bubble Jet Pokémon",
        text = "When Vaporeon’s fins begin to vibrate, it is a sign that rain will come within a few hours." },
    },

    JOLTEON = {
      dex = 135, name = "Jolteon", types = { "ELECTRIC" },
      baseStats = { hp = 65, attack = 65, defense = 60, speed = 130, specialA = 110, specialD = 95 },
      catchRate = 45, baseExp = 184, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 24.5,
      dexEntry = { kind = "Lightning Pokémon",
        text = "If it is angered or startled, the fur all over its body bristles like sharp needles that pierce foes." },
    },

    FLAREON = {
      dex = 136, name = "Flareon", types = { "FIRE" },
      baseStats = { hp = 65, attack = 130, defense = 60, speed = 65, specialA = 95, specialD = 110 },
      catchRate = 45, baseExp = 184, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 25,
      dexEntry = { kind = "Flame Pokémon",
        text = "Once it has stored up enough heat, this Pokémon’s body temperature can reach up to 1,700 degrees Fahrenheit." },
    },

    PORYGON = {
      dex = 137, name = "Porygon", types = { "NORMAL" },
      baseStats = { hp = 65, attack = 60, defense = 70, speed = 40, specialA = 85, specialD = 75 },
      catchRate = 45, baseExp = 79, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "PORYGON2" },
      },
      heightM = 0.8, weightKg = 36.5,
      dexEntry = { kind = "Virtual Pokémon",
        text = "State-of-the-art technology was used to create Porygon. It was the first artificial Pokémon to be created via computer programming." },
    },

    OMANYTE = {
      dex = 138, name = "Omanyte", types = { "ROCK", "WATER" },
      baseStats = { hp = 35, attack = 40, defense = 100, speed = 35, specialA = 90, specialD = 55 },
      catchRate = 45, baseExp = 71, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "OMASTAR", level = 40 },
      },
      heightM = 0.4, weightKg = 7.5,
      dexEntry = { kind = "Spiral Pokémon",
        text = "Because some Omanyte manage to escape after being restored or are released into the wild by people, this species is becoming a problem." },
    },

    OMASTAR = {
      dex = 139, name = "Omastar", types = { "ROCK", "WATER" },
      baseStats = { hp = 70, attack = 60, defense = 125, speed = 55, specialA = 115, specialD = 70 },
      catchRate = 45, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 35,
      dexEntry = { kind = "Spiral Pokémon",
        text = "Weighed down by a large and heavy shell, Omastar couldn’t move very fast. Some say it went extinct because it was unable to catch food." },
    },

    KABUTO = {
      dex = 140, name = "Kabuto", types = { "ROCK", "WATER" },
      baseStats = { hp = 30, attack = 80, defense = 90, speed = 55, specialA = 55, specialD = 45 },
      catchRate = 45, baseExp = 71, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "KABUTOPS", level = 40 },
      },
      heightM = 0.5, weightKg = 11.5,
      dexEntry = { kind = "Shellfish Pokémon",
        text = "This species is almost entirely extinct. Kabuto molt every three days, making their shells harder and harder." },
    },

    KABUTOPS = {
      dex = 141, name = "Kabutops", types = { "ROCK", "WATER" },
      baseStats = { hp = 60, attack = 115, defense = 105, speed = 80, specialA = 65, specialD = 70 },
      catchRate = 45, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 40.5,
      dexEntry = { kind = "Shellfish Pokémon",
        text = "Kabutops slices its prey apart and sucks out the fluids. The discarded body parts become food for other Pokémon." },
    },

    AERODACTYL = {
      dex = 142, name = "Aerodactyl", types = { "ROCK", "FLYING" },
      baseStats = { hp = 80, attack = 105, defense = 65, speed = 130, specialA = 60, specialD = 75 },
      catchRate = 45, baseExp = 180, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 59,
      dexEntry = { kind = "Fossil Pokémon",
        text = "This is a ferocious Pokémon from ancient times. Apparently even modern technology is incapable of producing a perfectly restored specimen." },
    },

    SNORLAX = {
      dex = 143, name = "Snorlax", types = { "NORMAL" },
      baseStats = { hp = 160, attack = 110, defense = 65, speed = 30, specialA = 65, specialD = 110 },
      catchRate = 25, baseExp = 189, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.1, weightKg = 460,
      dexEntry = { kind = "Sleeping Pokémon",
        text = "It is not satisfied unless it eats over 880 pounds of food every day. When it is done eating, it goes promptly to sleep." },
    },

    ARTICUNO = {
      dex = 144, name = "Articuno", types = { "ICE", "FLYING" },
      baseStats = { hp = 90, attack = 85, defense = 100, speed = 85, specialA = 95, specialD = 125 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.7, weightKg = 55.4,
      dexEntry = { kind = "Freeze Pokémon",
        text = "It’s said that this Pokémon’s beautiful blue wings are made of ice. Articuno flies over snowy mountains, its long tail fluttering along behind it." },
    },

    ZAPDOS = {
      dex = 145, name = "Zapdos", types = { "ELECTRIC", "FLYING" },
      baseStats = { hp = 90, attack = 90, defense = 85, speed = 100, specialA = 125, specialD = 90 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.6, weightKg = 52.6,
      dexEntry = { kind = "Electric Pokémon",
        text = "This Pokémon has complete control over electricity. There are tales of Zapdos nesting in the dark depths of pitch-black thunderclouds." },
    },

    MOLTRES = {
      dex = 146, name = "Moltres", types = { "FIRE", "FLYING" },
      baseStats = { hp = 90, attack = 100, defense = 90, speed = 90, specialA = 125, specialD = 85 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2, weightKg = 60,
      dexEntry = { kind = "Flame Pokémon",
        text = "It’s one of the legendary bird Pokémon. When Moltres flaps its flaming wings, they glimmer with a dazzling red glow." },
    },

    DRATINI = {
      dex = 147, name = "Dratini", types = { "DRAGON" },
      baseStats = { hp = 41, attack = 64, defense = 45, speed = 50, specialA = 50, specialD = 50 },
      catchRate = 45, baseExp = 60, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "DRAGONAIR", level = 30 },
      },
      heightM = 1.8, weightKg = 3.3,
      dexEntry = { kind = "Dragon Pokémon",
        text = "Dratini dwells near bodies of rapidly flowing water, such as the plunge pools of waterfalls. As it grows, Dratini will shed its skin many times." },
    },

    DRAGONAIR = {
      dex = 148, name = "Dragonair", types = { "DRAGON" },
      baseStats = { hp = 61, attack = 84, defense = 65, speed = 70, specialA = 70, specialD = 70 },
      catchRate = 45, baseExp = 147, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "DRAGONITE", level = 55 },
      },
      heightM = 4, weightKg = 16.5,
      dexEntry = { kind = "Dragon Pokémon",
        text = "This Pokémon lives in pristine oceans and lakes. It can control the weather, and it uses this power to fly into the sky, riding on the wind." },
    },

    DRAGONITE = {
      dex = 149, name = "Dragonite", types = { "DRAGON", "FLYING" },
      baseStats = { hp = 91, attack = 134, defense = 95, speed = 80, specialA = 100, specialD = 100 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2.2, weightKg = 210,
      dexEntry = { kind = "Dragon Pokémon",
        text = "It’s a kindhearted Pokémon. If it spots a drowning person or Pokémon, Dragonite simply must help them." },
    },

    MEWTWO = {
      dex = 150, name = "Mewtwo", types = { "PSYCHIC" },
      baseStats = { hp = 106, attack = 110, defense = 90, speed = 130, specialA = 154, specialD = 90 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2, weightKg = 122,
      dexEntry = { kind = "Genetic Pokémon",
        text = "Its DNA is almost the same as Mew’s. However, its size and disposition are vastly different." },
    },

    MEW = {
      dex = 151, name = "Mew", types = { "PSYCHIC" },
      baseStats = { hp = 100, attack = 100, defense = 100, speed = 100, specialA = 100, specialD = 100 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 100,
      evolutions = {},
      heightM = 0.4, weightKg = 4,
      dexEntry = { kind = "New Species Pokémon",
        text = "When viewed through a microscope, this Pokémon’s short, fine, delicate hair can be seen." },
    },

    CHIKORITA = {
      dex = 152, name = "Chikorita", types = { "GRASS" },
      baseStats = { hp = 45, attack = 49, defense = 65, speed = 45, specialA = 49, specialD = 65 },
      catchRate = 45, baseExp = 64, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BAYLEEF", level = 16 },
      },
      heightM = 0.9, weightKg = 6.4,
      dexEntry = { kind = "Leaf Pokémon",
        text = "In battle, Chikorita waves its leaf around to keep the foe at bay. However, a sweet fragrance also wafts from the leaf, becalming the battling Pokémon and creating a cozy, friendly atmosphere all around." },
    },

    BAYLEEF = {
      dex = 153, name = "Bayleef", types = { "GRASS" },
      baseStats = { hp = 60, attack = 62, defense = 80, speed = 60, specialA = 63, specialD = 80 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MEGANIUM", level = 32 },
      },
      heightM = 1.2, weightKg = 15.8,
      dexEntry = { kind = "Leaf Pokémon",
        text = "Bayleef’s neck is ringed by curled-up leaves. Inside each tubular leaf is a small shoot of a tree. The fragrance of this shoot makes people peppy." },
    },

    MEGANIUM = {
      dex = 154, name = "Meganium", types = { "GRASS" },
      baseStats = { hp = 80, attack = 82, defense = 100, speed = 80, specialA = 83, specialD = 100 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 100.5,
      dexEntry = { kind = "Herb Pokémon",
        text = "The fragrance of Meganium’s flower soothes and calms emotions. In battle, this Pokémon gives off more of its becalming scent to blunt the foe’s fighting spirit." },
    },

    CYNDAQUIL = {
      dex = 155, name = "Cyndaquil", types = { "FIRE" },
      baseStats = { hp = 39, attack = 52, defense = 43, speed = 65, specialA = 60, specialD = 50 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "QUILAVA", level = 14 },
      },
      heightM = 0.5, weightKg = 7.9,
      dexEntry = { kind = "Fire Mouse Pokémon",
        text = "Cyndaquil protects itself by flaring up the flames on its back. The flames are vigorous if the Pokémon is angry. However, if it is tired, the flames splutter fitfully with incomplete combustion." },
    },

    QUILAVA = {
      dex = 156, name = "Quilava", types = { "FIRE" },
      baseStats = { hp = 58, attack = 64, defense = 58, speed = 80, specialA = 80, specialD = 65 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TYPHLOSION", level = 36 },
      },
      heightM = 0.9, weightKg = 19,
      dexEntry = { kind = "Volcano Pokémon",
        text = "Quilava keeps its foes at bay with the intensity of its flames and gusts of superheated air. This Pokémon applies its outstanding nimbleness to dodge attacks even while scorching the foe with flames." },
    },

    TYPHLOSION = {
      dex = 157, name = "Typhlosion", types = { "FIRE" },
      baseStats = { hp = 78, attack = 84, defense = 78, speed = 100, specialA = 109, specialD = 85 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 79.5,
      dexEntry = { kind = "Volcano Pokémon",
        text = "Typhlosion obscures itself behind a shimmering heat haze that it creates using its intensely hot flames. This Pokémon creates blazing explosive blasts that burn everything to cinders." },
    },

    TOTODILE = {
      dex = 158, name = "Totodile", types = { "WATER" },
      baseStats = { hp = 50, attack = 65, defense = 64, speed = 43, specialA = 44, specialD = 48 },
      catchRate = 45, baseExp = 63, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CROCONAW", level = 18 },
      },
      heightM = 0.6, weightKg = 9.5,
      dexEntry = { kind = "Big Jaw Pokémon",
        text = "Despite the smallness of its body, Totodile’s jaws are very powerful. While the Pokémon may think it is just playfully nipping, its bite has enough power to cause serious injury." },
    },

    CROCONAW = {
      dex = 159, name = "Croconaw", types = { "WATER" },
      baseStats = { hp = 65, attack = 80, defense = 80, speed = 58, specialA = 59, specialD = 63 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FERALIGATR", level = 30 },
      },
      heightM = 1.1, weightKg = 25,
      dexEntry = { kind = "Big Jaw Pokémon",
        text = "Once Croconaw has clamped its jaws on its foe, it will absolutely not let go. Because the tips of its fangs are forked back like barbed fishhooks, they become impossible to remove when they have sunk in." },
    },

    FERALIGATR = {
      dex = 160, name = "Feraligatr", types = { "WATER" },
      baseStats = { hp = 85, attack = 105, defense = 100, speed = 78, specialA = 79, specialD = 83 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.3, weightKg = 88.8,
      dexEntry = { kind = "Big Jaw Pokémon",
        text = "Feraligatr intimidates its foes by opening its huge mouth. In battle, it will kick the ground hard with its thick and powerful hind legs to charge at the foe at an incredible speed." },
    },

    SENTRET = {
      dex = 161, name = "Sentret", types = { "NORMAL" },
      baseStats = { hp = 35, attack = 46, defense = 34, speed = 20, specialA = 35, specialD = 45 },
      catchRate = 255, baseExp = 43, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FURRET", level = 15 },
      },
      heightM = 0.8, weightKg = 6,
      dexEntry = { kind = "Scout Pokémon",
        text = "When Sentret sleeps, it does so while another stands guard. The sentry wakes the others at the first sign of danger. When this Pokémon becomes separated from its pack, it becomes incapable of sleep due to fear." },
    },

    FURRET = {
      dex = 162, name = "Furret", types = { "NORMAL" },
      baseStats = { hp = 85, attack = 76, defense = 64, speed = 90, specialA = 45, specialD = 55 },
      catchRate = 90, baseExp = 145, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 32.5,
      dexEntry = { kind = "Long Body Pokémon",
        text = "Furret has a very slim build. When under attack, it can slickly squirm through narrow spaces and get away. In spite of its short limbs, this Pokémon is very nimble and fleet." },
    },

    HOOTHOOT = {
      dex = 163, name = "Hoothoot", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 60, attack = 30, defense = 30, speed = 50, specialA = 36, specialD = 56 },
      catchRate = 255, baseExp = 52, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "NOCTOWL", level = 20 },
      },
      heightM = 0.7, weightKg = 21.2,
      dexEntry = { kind = "Owl Pokémon",
        text = "It always stands on one foot. It changes feet so fast, the movement can rarely be seen." },
    },

    NOCTOWL = {
      dex = 164, name = "Noctowl", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 100, attack = 50, defense = 50, speed = 70, specialA = 86, specialD = 96 },
      catchRate = 90, baseExp = 158, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 40.8,
      dexEntry = { kind = "Owl Pokémon",
        text = "Its eyes are specially developed to enable it to see clearly even in murky darkness and minimal light." },
    },

    LEDYBA = {
      dex = 165, name = "Ledyba", types = { "BUG", "FLYING" },
      baseStats = { hp = 40, attack = 20, defense = 30, speed = 55, specialA = 40, specialD = 80 },
      catchRate = 255, baseExp = 53, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "LEDIAN", level = 18 },
      },
      heightM = 1, weightKg = 10.8,
      dexEntry = { kind = "Five Star Pokémon",
        text = "This Pokémon is very sensitive to cold. In the warmth of Alola, it appears quite lively." },
    },

    LEDIAN = {
      dex = 166, name = "Ledian", types = { "BUG", "FLYING" },
      baseStats = { hp = 55, attack = 35, defense = 50, speed = 85, specialA = 55, specialD = 110 },
      catchRate = 90, baseExp = 137, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 35.6,
      dexEntry = { kind = "Five Star Pokémon",
        text = "It’s said that the patterns on its back are related to the stars in the night sky, but the details of that relationship remain unclear." },
    },

    SPINARAK = {
      dex = 167, name = "Spinarak", types = { "BUG", "POISON" },
      baseStats = { hp = 40, attack = 60, defense = 40, speed = 30, specialA = 40, specialD = 40 },
      catchRate = 255, baseExp = 50, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ARIADOS", level = 22 },
      },
      heightM = 0.5, weightKg = 8.5,
      dexEntry = { kind = "String Spit Pokémon",
        text = "With threads from its mouth, it fashions sturdy webs that won’t break even if you set a rock on them." },
    },

    ARIADOS = {
      dex = 168, name = "Ariados", types = { "BUG", "POISON" },
      baseStats = { hp = 70, attack = 90, defense = 70, speed = 40, specialA = 60, specialD = 70 },
      catchRate = 90, baseExp = 140, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 33.5,
      dexEntry = { kind = "Long Leg Pokémon",
        text = "Every night, it wanders around in search of prey, whose movements it restrains by spewing threads before it bites into them with its fangs." },
    },

    CROBAT = {
      dex = 169, name = "Crobat", types = { "POISON", "FLYING" },
      baseStats = { hp = 85, attack = 90, defense = 80, speed = 130, specialA = 70, specialD = 80 },
      catchRate = 90, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 75,
      dexEntry = { kind = "Bat Pokémon",
        text = "Both of its legs have turned into wings. Without a sound, Crobat flies swiftly toward its prey and sinks its fangs into the nape of its target’s neck." },
    },

    CHINCHOU = {
      dex = 170, name = "Chinchou", types = { "WATER", "ELECTRIC" },
      baseStats = { hp = 75, attack = 38, defense = 38, speed = 67, specialA = 56, specialD = 56 },
      catchRate = 190, baseExp = 66, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "LANTURN", level = 27 },
      },
      heightM = 0.5, weightKg = 12,
      dexEntry = { kind = "Angler Pokémon",
        text = "Its antennae, which evolved from a fin, have both positive and negative charges flowing through them." },
    },

    LANTURN = {
      dex = 171, name = "Lanturn", types = { "WATER", "ELECTRIC" },
      baseStats = { hp = 125, attack = 58, defense = 58, speed = 67, specialA = 76, specialD = 76 },
      catchRate = 75, baseExp = 161, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 22.5,
      dexEntry = { kind = "Light Pokémon",
        text = "The light it emits is so bright that it can illuminate the sea’s surface from a depth of over three miles." },
    },

    PICHU = {
      dex = 172, name = "Pichu", types = { "ELECTRIC" },
      baseStats = { hp = 20, attack = 40, defense = 15, speed = 60, specialA = 35, specialD = 35 },
      catchRate = 190, baseExp = 41, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HAPPINESS", species = "PIKACHU" },
      },
      heightM = 0.3, weightKg = 2,
      dexEntry = { kind = "Tiny Mouse Pokémon",
        text = "Despite its small size, it can zap even adult humans. However, if it does so, it also surprises itself." },
    },

    CLEFFA = {
      dex = 173, name = "Cleffa", types = { "FAIRY" },
      baseStats = { hp = 50, attack = 25, defense = 28, speed = 15, specialA = 45, specialD = 55 },
      catchRate = 150, baseExp = 44, growthRate = "FAST", happiness = 140,
      evolutions = {
        { method = "HAPPINESS", species = "CLEFAIRY" },
      },
      heightM = 0.3, weightKg = 3,
      dexEntry = { kind = "Star Shape Pokémon",
        text = "According to local rumors, Cleffa are often seen in places where shooting stars have fallen." },
    },

    IGGLYBUFF = {
      dex = 174, name = "Igglybuff", types = { "NORMAL", "FAIRY" },
      baseStats = { hp = 90, attack = 30, defense = 15, speed = 15, specialA = 40, specialD = 20 },
      catchRate = 170, baseExp = 42, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "HAPPINESS", species = "JIGGLYPUFF" },
      },
      heightM = 0.3, weightKg = 1,
      dexEntry = { kind = "Balloon Pokémon",
        text = "Igglybuff loves to sing. Its marshmallow-like body gives off a faint sweet smell." },
    },

    TOGEPI = {
      dex = 175, name = "Togepi", types = { "FAIRY" },
      baseStats = { hp = 35, attack = 20, defense = 65, speed = 20, specialA = 40, specialD = 65 },
      catchRate = 190, baseExp = 49, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "HAPPINESS", species = "TOGETIC" },
      },
      heightM = 0.3, weightKg = 1.5,
      dexEntry = { kind = "Spike Ball Pokémon",
        text = "The shell seems to be filled with joy. It is said that it will share good luck when treated kindly." },
    },

    TOGETIC = {
      dex = 176, name = "Togetic", types = { "FAIRY", "FLYING" },
      baseStats = { hp = 55, attack = 40, defense = 85, speed = 40, specialA = 80, specialD = 105 },
      catchRate = 75, baseExp = 142, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "TOGEKISS", item = "SHINYSTONE" },
      },
      heightM = 0.6, weightKg = 3.2,
      dexEntry = { kind = "Happiness Pokémon",
        text = "They say that it will appear before kindhearted, caring people and shower them with happiness." },
    },

    NATU = {
      dex = 177, name = "Natu", types = { "PSYCHIC", "FLYING" },
      baseStats = { hp = 40, attack = 50, defense = 45, speed = 70, specialA = 70, specialD = 45 },
      catchRate = 190, baseExp = 64, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "XATU", level = 25 },
      },
      heightM = 0.2, weightKg = 2,
      dexEntry = { kind = "Little Bird Pokémon",
        text = "It is extremely good at climbing tree trunks and likes to eat the new sprouts on the trees." },
    },

    XATU = {
      dex = 178, name = "Xatu", types = { "PSYCHIC", "FLYING" },
      baseStats = { hp = 65, attack = 75, defense = 70, speed = 95, specialA = 95, specialD = 70 },
      catchRate = 75, baseExp = 165, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 15,
      dexEntry = { kind = "Mystic Pokémon",
        text = "They say that it stays still and quiet because it is seeing both the past and future at the same time." },
    },

    MAREEP = {
      dex = 179, name = "Mareep", types = { "ELECTRIC" },
      baseStats = { hp = 55, attack = 40, defense = 40, speed = 35, specialA = 65, specialD = 45 },
      catchRate = 235, baseExp = 56, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FLAAFFY", level = 15 },
      },
      heightM = 0.6, weightKg = 7.8,
      dexEntry = { kind = "Wool Pokémon",
        text = "Clothing made from Mareep’s fleece is easily charged with static electricity, so a special process is used on it." },
    },

    FLAAFFY = {
      dex = 180, name = "Flaaffy", types = { "ELECTRIC" },
      baseStats = { hp = 70, attack = 55, defense = 55, speed = 45, specialA = 80, specialD = 60 },
      catchRate = 120, baseExp = 128, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "AMPHAROS", level = 30 },
      },
      heightM = 0.8, weightKg = 13.3,
      dexEntry = { kind = "Wool Pokémon",
        text = "In the places on its body where fleece doesn’t grow, its skin is rubbery and doesn’t conduct electricity. Those spots are safe to touch." },
    },

    AMPHAROS = {
      dex = 181, name = "Ampharos", types = { "ELECTRIC" },
      baseStats = { hp = 90, attack = 75, defense = 85, speed = 55, specialA = 115, specialD = 90 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 61.5,
      dexEntry = { kind = "Light Pokémon",
        text = "The light from its tail can be seen from space. This is why you can always tell exactly where it is, which is why it usually keeps the light off." },
    },

    BELLOSSOM = {
      dex = 182, name = "Bellossom", types = { "GRASS" },
      baseStats = { hp = 75, attack = 80, defense = 95, speed = 50, specialA = 90, specialD = 100 },
      catchRate = 45, baseExp = 245, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.4, weightKg = 5.8,
      dexEntry = { kind = "Flower Pokémon",
        text = "Plentiful in the tropics. When it dances, its petals rub together and make a pleasant ringing sound." },
    },

    MARILL = {
      dex = 183, name = "Marill", types = { "WATER", "FAIRY" },
      baseStats = { hp = 70, attack = 20, defense = 50, speed = 40, specialA = 20, specialD = 50 },
      catchRate = 190, baseExp = 88, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "AZUMARILL", level = 18 },
      },
      heightM = 0.4, weightKg = 8.5,
      dexEntry = { kind = "Aquamouse Pokémon",
        text = "This Pokémon uses its round tail as a float. The ball of Marill’s tail is filled with nutrients that have been turned into an oil." },
    },

    AZUMARILL = {
      dex = 184, name = "Azumarill", types = { "WATER", "FAIRY" },
      baseStats = { hp = 100, attack = 50, defense = 80, speed = 50, specialA = 60, specialD = 80 },
      catchRate = 75, baseExp = 210, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 28.5,
      dexEntry = { kind = "Aquarabbit Pokémon",
        text = "It spends most of its time in the water. On sunny days, Azumarill floats on the surface of the water and sunbathes." },
    },

    SUDOWOODO = {
      dex = 185, name = "Sudowoodo", types = { "ROCK" },
      baseStats = { hp = 70, attack = 100, defense = 115, speed = 30, specialA = 30, specialD = 65 },
      catchRate = 65, baseExp = 144, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 38,
      dexEntry = { kind = "Imitation Pokémon",
        text = "If a tree branch shakes when there is no wind, it’s a Sudowoodo, not a tree. It hides from the rain." },
    },

    POLITOED = {
      dex = 186, name = "Politoed", types = { "WATER" },
      baseStats = { hp = 90, attack = 75, defense = 75, speed = 70, specialA = 90, specialD = 100 },
      catchRate = 45, baseExp = 250, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 33.9,
      dexEntry = { kind = "Frog Pokémon",
        text = "At nightfall, these Pokémon appear on the shores of lakes. They announce their territorial claims by letting out cries that sound like shouting." },
    },

    HOPPIP = {
      dex = 187, name = "Hoppip", types = { "GRASS", "FLYING" },
      baseStats = { hp = 35, attack = 35, defense = 40, speed = 50, specialA = 35, specialD = 55 },
      catchRate = 255, baseExp = 50, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SKIPLOOM", level = 18 },
      },
      heightM = 0.4, weightKg = 0.5,
      dexEntry = { kind = "Cottonweed Pokémon",
        text = "This Pokémon drifts and floats with the wind. If it senses the approach of strong winds, Hoppip links its leaves with other Hoppip to prepare against being blown away." },
    },

    SKIPLOOM = {
      dex = 188, name = "Skiploom", types = { "GRASS", "FLYING" },
      baseStats = { hp = 55, attack = 45, defense = 50, speed = 80, specialA = 45, specialD = 65 },
      catchRate = 120, baseExp = 119, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "JUMPLUFF", level = 27 },
      },
      heightM = 0.6, weightKg = 1,
      dexEntry = { kind = "Cottonweed Pokémon",
        text = "Skiploom’s flower blossoms when the temperature rises above 64 degrees Fahrenheit. How much the flower opens depends on the temperature. For that reason, this Pokémon is sometimes used as a thermometer." },
    },

    JUMPLUFF = {
      dex = 189, name = "Jumpluff", types = { "GRASS", "FLYING" },
      baseStats = { hp = 75, attack = 55, defense = 70, speed = 110, specialA = 55, specialD = 95 },
      catchRate = 45, baseExp = 230, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 3,
      dexEntry = { kind = "Cottonweed Pokémon",
        text = "Jumpluff rides warm southern winds to cross the sea and fly to foreign lands. The Pokémon descends to the ground when it encounters cold air while it is floating." },
    },

    AIPOM = {
      dex = 190, name = "Aipom", types = { "NORMAL" },
      baseStats = { hp = 55, attack = 70, defense = 55, speed = 85, specialA = 40, specialD = 55 },
      catchRate = 45, baseExp = 72, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "HAS_MOVE", species = "AMBIPOM", move = "DOUBLEHIT" },
      },
      heightM = 0.8, weightKg = 11.5,
      dexEntry = { kind = "Long Tail Pokémon",
        text = "As it did more and more with its tail, its hands became clumsy. It makes its nest high in the treetops." },
    },

    SUNKERN = {
      dex = 191, name = "Sunkern", types = { "GRASS" },
      baseStats = { hp = 30, attack = 30, defense = 30, speed = 30, specialA = 30, specialD = 30 },
      catchRate = 235, baseExp = 36, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "SUNFLORA", item = "SUNSTONE" },
      },
      heightM = 0.3, weightKg = 1.8,
      dexEntry = { kind = "Seed Pokémon",
        text = "Sunkern tries to move as little as it possibly can. It does so because it tries to conserve all the nutrients it has stored in its body for its evolution. It will not eat a thing, subsisting only on morning dew." },
    },

    SUNFLORA = {
      dex = 192, name = "Sunflora", types = { "GRASS" },
      baseStats = { hp = 75, attack = 75, defense = 55, speed = 30, specialA = 105, specialD = 85 },
      catchRate = 120, baseExp = 149, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 8.5,
      dexEntry = { kind = "Sun Pokémon",
        text = "Sunflora converts solar energy into nutrition. It moves around actively in the daytime when it is warm. It stops moving as soon as the sun goes down for the night." },
    },

    YANMA = {
      dex = 193, name = "Yanma", types = { "BUG", "FLYING" },
      baseStats = { hp = 65, attack = 65, defense = 45, speed = 95, specialA = 75, specialD = 45 },
      catchRate = 75, baseExp = 78, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HAS_MOVE", species = "YANMEGA", move = "ANCIENTPOWER" },
      },
      heightM = 1.2, weightKg = 38,
      dexEntry = { kind = "Clear Wing Pokémon",
        text = "Yanma is capable of seeing 360 degrees without having to move its eyes. It is a great flier that is adept at making sudden stops and turning midair. This Pokémon uses its flying ability to quickly chase down targeted prey." },
    },

    WOOPER = {
      dex = 194, name = "Wooper", types = { "WATER", "GROUND" },
      baseStats = { hp = 55, attack = 45, defense = 45, speed = 15, specialA = 25, specialD = 25 },
      catchRate = 255, baseExp = 42, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "QUAGSIRE", level = 20 },
      },
      heightM = 0.4, weightKg = 8.5,
      dexEntry = { kind = "Water Fish Pokémon",
        text = "This Pokémon lives in cold water. It will leave the water to search for food when it gets cold outside." },
    },

    QUAGSIRE = {
      dex = 195, name = "Quagsire", types = { "WATER", "GROUND" },
      baseStats = { hp = 95, attack = 85, defense = 85, speed = 35, specialA = 65, specialD = 65 },
      catchRate = 90, baseExp = 151, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 75,
      dexEntry = { kind = "Water Fish Pokémon",
        text = "It has an easygoing nature. It doesn’t care if it bumps its head on boats and boulders while swimming." },
    },

    ESPEON = {
      dex = 196, name = "Espeon", types = { "PSYCHIC" },
      baseStats = { hp = 65, attack = 65, defense = 60, speed = 110, specialA = 130, specialD = 95 },
      catchRate = 45, baseExp = 184, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 26.5,
      dexEntry = { kind = "Sun Pokémon",
        text = "By reading air currents, it can predict things such as the weather or its foe’s next move." },
    },

    UMBREON = {
      dex = 197, name = "Umbreon", types = { "DARK" },
      baseStats = { hp = 95, attack = 65, defense = 110, speed = 65, specialA = 60, specialD = 130 },
      catchRate = 45, baseExp = 184, growthRate = "MEDIUM_FAST", happiness = 35,
      evolutions = {},
      heightM = 1, weightKg = 27,
      dexEntry = { kind = "Moonlight Pokémon",
        text = "When this Pokémon becomes angry, its pores secrete a poisonous sweat, which it sprays at its opponent’s eyes." },
    },

    MURKROW = {
      dex = 198, name = "Murkrow", types = { "DARK", "FLYING" },
      baseStats = { hp = 60, attack = 85, defense = 42, speed = 91, specialA = 85, specialD = 42 },
      catchRate = 30, baseExp = 81, growthRate = "MEDIUM_SLOW", happiness = 35,
      evolutions = {
        { method = "ITEM", species = "HONCHKROW", item = "DUSKSTONE" },
      },
      heightM = 0.5, weightKg = 2.1,
      dexEntry = { kind = "Darkness Pokémon",
        text = "It has a weakness for shiny things. It’s been known to sneak into the nests of Gabite—noted collectors of jewels—in search of treasure." },
    },

    SLOWKING = {
      dex = 199, name = "Slowking", types = { "WATER", "PSYCHIC" },
      baseStats = { hp = 95, attack = 75, defense = 80, speed = 30, specialA = 100, specialD = 110 },
      catchRate = 70, baseExp = 172, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 79.5,
      dexEntry = { kind = "Royal Pokémon",
        text = "Miraculously, this former Slowpoke’s latent intelligence was drawn out when Shellder poison raced through its brain." },
    },

    MISDREAVUS = {
      dex = 200, name = "Misdreavus", types = { "GHOST" },
      baseStats = { hp = 60, attack = 60, defense = 60, speed = 85, specialA = 85, specialD = 85 },
      catchRate = 45, baseExp = 87, growthRate = "FAST", happiness = 35,
      evolutions = {
        { method = "ITEM", species = "MISMAGIUS", item = "DUSKSTONE" },
      },
      heightM = 0.7, weightKg = 1,
      dexEntry = { kind = "Screech Pokémon",
        text = "What gives meaning to its life is surprising others. If you set your ear against the red orbs around its neck, you can hear shrieking." },
    },

    UNOWN = {
      dex = 201, name = "Unown", types = { "PSYCHIC" },
      baseStats = { hp = 48, attack = 72, defense = 48, speed = 48, specialA = 72, specialD = 48 },
      catchRate = 225, baseExp = 118, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.5, weightKg = 5,
      dexEntry = { kind = "Symbol Pokémon",
        text = "This Pokémon is shaped like ancient writing. It is a mystery as to which came first, the ancient writings or the various Unown. Research into this topic is ongoing but nothing is known." },
    },

    WOBBUFFET = {
      dex = 202, name = "Wobbuffet", types = { "PSYCHIC" },
      baseStats = { hp = 190, attack = 33, defense = 58, speed = 33, specialA = 33, specialD = 58 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 28.5,
      dexEntry = { kind = "Patient Pokémon",
        text = "It hates light and shock. If attacked, it inflates its body to pump up its counterstrike." },
    },

    GIRAFARIG = {
      dex = 203, name = "Girafarig", types = { "NORMAL", "PSYCHIC" },
      baseStats = { hp = 70, attack = 80, defense = 65, speed = 85, specialA = 90, specialD = 65 },
      catchRate = 60, baseExp = 159, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HAS_MOVE", species = "FARIGIRAF", move = "TWINBEAM" },
      },
      heightM = 1.5, weightKg = 41.5,
      dexEntry = { kind = "Long Neck Pokémon",
        text = "Girafarig’s rear head also has a brain, but it is small. The rear head attacks in response to smells and sounds. Approaching this Pokémon from behind can cause the rear head to suddenly lash out and bite." },
    },

    PINECO = {
      dex = 204, name = "Pineco", types = { "BUG" },
      baseStats = { hp = 50, attack = 65, defense = 90, speed = 15, specialA = 35, specialD = 35 },
      catchRate = 190, baseExp = 58, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FORRETRESS", level = 31 },
      },
      heightM = 0.6, weightKg = 7.2,
      dexEntry = { kind = "Bagworm Pokémon",
        text = "Motionless, it hangs from trees, waiting for its bug Pokémon prey to come to it. Its favorite in Alola is Cutiefly." },
    },

    FORRETRESS = {
      dex = 205, name = "Forretress", types = { "BUG", "STEEL" },
      baseStats = { hp = 75, attack = 90, defense = 140, speed = 40, specialA = 60, specialD = 60 },
      catchRate = 75, baseExp = 163, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 125.8,
      dexEntry = { kind = "Bagworm Pokémon",
        text = "When something approaches it, it fires off fragments of its steel shell in attack. This is not a conscious action but a conditioned reflex." },
    },

    DUNSPARCE = {
      dex = 206, name = "Dunsparce", types = { "NORMAL" },
      baseStats = { hp = 100, attack = 70, defense = 70, speed = 45, specialA = 65, specialD = 65 },
      catchRate = 190, baseExp = 145, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HASMOVERANDFORM", species = "DUDUNSPARCE" },
      },
      heightM = 1.5, weightKg = 14,
      dexEntry = { kind = "Land Snake Pokémon",
        text = "This Pokémon’s tiny wings have some scientists saying that Dunsparce used to fly through the sky in ancient times." },
    },

    GLIGAR = {
      dex = 207, name = "Gligar", types = { "GROUND", "FLYING" },
      baseStats = { hp = 65, attack = 75, defense = 105, speed = 85, specialA = 35, specialD = 65 },
      catchRate = 60, baseExp = 86, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "NIGHTHOLDITEM", species = "GLISCOR" },
      },
      heightM = 1.1, weightKg = 64.8,
      dexEntry = { kind = "Flyscorpion Pokémon",
        text = "Gligar glides through the air without a sound as if it were sliding. This Pokémon hangs on to the face of its foe using its clawed hind legs and the large pincers on its forelegs, then injects the prey with its poison barb." },
    },

    STEELIX = {
      dex = 208, name = "Steelix", types = { "STEEL", "GROUND" },
      baseStats = { hp = 75, attack = 85, defense = 200, speed = 30, specialA = 55, specialD = 65 },
      catchRate = 25, baseExp = 179, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 9.2, weightKg = 400,
      dexEntry = { kind = "Iron Snake Pokémon",
        text = "It is said that if an Onix lives for over 100 years, its composition changes to become diamond-like." },
    },

    SNUBBULL = {
      dex = 209, name = "Snubbull", types = { "FAIRY" },
      baseStats = { hp = 60, attack = 80, defense = 50, speed = 30, specialA = 40, specialD = 40 },
      catchRate = 190, baseExp = 60, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GRANBULL", level = 23 },
      },
      heightM = 0.6, weightKg = 7.8,
      dexEntry = { kind = "Fairy Pokémon",
        text = "It grows close to others easily and is also easily spoiled. The disparity between its face and its actions makes many young people wild about it." },
    },

    GRANBULL = {
      dex = 210, name = "Granbull", types = { "FAIRY" },
      baseStats = { hp = 90, attack = 120, defense = 75, speed = 45, specialA = 60, specialD = 60 },
      catchRate = 75, baseExp = 158, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 48.7,
      dexEntry = { kind = "Fairy Pokémon",
        text = "While it has powerful jaws, it doesn’t care for disputes, so it rarely has a chance to display their might." },
    },

    QWILFISH = {
      dex = 211, name = "Qwilfish", types = { "WATER", "POISON" },
      baseStats = { hp = 65, attack = 95, defense = 85, speed = 85, specialA = 55, specialD = 55 },
      catchRate = 45, baseExp = 88, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.5, weightKg = 3.9,
      dexEntry = { kind = "Balloon Pokémon",
        text = "When faced with a larger opponent, it swallows as much water as it can to match the opponent’s size." },
    },

    SCIZOR = {
      dex = 212, name = "Scizor", types = { "BUG", "STEEL" },
      baseStats = { hp = 70, attack = 130, defense = 100, speed = 65, specialA = 55, specialD = 80 },
      catchRate = 25, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 118,
      dexEntry = { kind = "Pincer Pokémon",
        text = "Bulky pincers account for one third of Scizor’s body weight. A single swing of one of these pincers will crush a boulder completely." },
    },

    SHUCKLE = {
      dex = 213, name = "Shuckle", types = { "BUG", "ROCK" },
      baseStats = { hp = 20, attack = 10, defense = 230, speed = 5, specialA = 10, specialD = 230 },
      catchRate = 190, baseExp = 177, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.6, weightKg = 20.5,
      dexEntry = { kind = "Mold Pokémon",
        text = "It stores berries inside its shell. To avoid attacks, it hides beneath rocks and remains completely still." },
    },

    HERACROSS = {
      dex = 214, name = "Heracross", types = { "BUG", "FIGHTING" },
      baseStats = { hp = 80, attack = 125, defense = 75, speed = 85, specialA = 40, specialD = 95 },
      catchRate = 45, baseExp = 175, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 54,
      dexEntry = { kind = "Singlehorn Pokémon",
        text = "Heracross loves sweet sap and will go looking through forests for it. The Pokémon uses its two antennae to pick up scents as it searches." },
    },

    SNEASEL = {
      dex = 215, name = "Sneasel", types = { "DARK", "ICE" },
      baseStats = { hp = 55, attack = 95, defense = 55, speed = 115, specialA = 35, specialD = 75 },
      catchRate = 60, baseExp = 86, growthRate = "MEDIUM_SLOW", happiness = 35,
      evolutions = {
        { method = "NIGHTHOLDITEM", species = "WEAVILE" },
      },
      heightM = 0.9, weightKg = 28,
      dexEntry = { kind = "Sharp Claw Pokémon",
        text = "Its paws conceal sharp claws. If attacked, it suddenly extends the claws and startles its enemy." },
    },

    TEDDIURSA = {
      dex = 216, name = "Teddiursa", types = { "NORMAL" },
      baseStats = { hp = 60, attack = 80, defense = 50, speed = 40, specialA = 50, specialD = 50 },
      catchRate = 120, baseExp = 66, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "URSARING", level = 30 },
      },
      heightM = 0.6, weightKg = 8.8,
      dexEntry = { kind = "Little Bear Pokémon",
        text = "This Pokémon likes to lick its palms that are sweetened by being soaked in honey. Teddiursa concocts its own honey by blending fruits and pollen collected by Beedrill." },
    },

    URSARING = {
      dex = 217, name = "Ursaring", types = { "NORMAL" },
      baseStats = { hp = 90, attack = 130, defense = 75, speed = 55, specialA = 75, specialD = 75 },
      catchRate = 60, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEMNIGHT", species = "URSALUNA" },
      },
      heightM = 1.8, weightKg = 125.8,
      dexEntry = { kind = "Hibernator Pokémon",
        text = "In the forests inhabited by Ursaring, it is said that there are many streams and towering trees where they gather food. This Pokémon walks through its forest gathering food every day." },
    },

    SLUGMA = {
      dex = 218, name = "Slugma", types = { "FIRE" },
      baseStats = { hp = 40, attack = 40, defense = 40, speed = 20, specialA = 70, specialD = 40 },
      catchRate = 190, baseExp = 50, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MAGCARGO", level = 38 },
      },
      heightM = 0.7, weightKg = 35,
      dexEntry = { kind = "Lava Pokémon",
        text = "Molten magma courses throughout Slugma’s circulatory system. If this Pokémon is chilled, the magma cools and hardens. Its body turns brittle and chunks fall off, reducing its size." },
    },

    MAGCARGO = {
      dex = 219, name = "Magcargo", types = { "FIRE", "ROCK" },
      baseStats = { hp = 60, attack = 50, defense = 120, speed = 30, specialA = 90, specialD = 80 },
      catchRate = 75, baseExp = 151, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 55,
      dexEntry = { kind = "Lava Pokémon",
        text = "Magcargo’s shell is actually its skin that hardened as a result of cooling. Its shell is very brittle and fragile—just touching it causes it to crumble apart. This Pokémon returns to its original size by dipping itself in magma." },
    },

    SWINUB = {
      dex = 220, name = "Swinub", types = { "ICE", "GROUND" },
      baseStats = { hp = 50, attack = 50, defense = 40, speed = 50, specialA = 30, specialD = 30 },
      catchRate = 225, baseExp = 50, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PILOSWINE", level = 33 },
      },
      heightM = 0.4, weightKg = 6.5,
      dexEntry = { kind = "Pig Pokémon",
        text = "It rubs its snout on the ground to find and dig up food. It sometimes discovers hot springs." },
    },

    PILOSWINE = {
      dex = 221, name = "Piloswine", types = { "ICE", "GROUND" },
      baseStats = { hp = 100, attack = 100, defense = 80, speed = 50, specialA = 60, specialD = 60 },
      catchRate = 75, baseExp = 158, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "HAS_MOVE", species = "MAMOSWINE", move = "ANCIENTPOWER" },
      },
      heightM = 1.1, weightKg = 55.8,
      dexEntry = { kind = "Swine Pokémon",
        text = "If it charges at an enemy, the hairs on its back stand up straight. It is very sensitive to sound." },
    },

    CORSOLA = {
      dex = 222, name = "Corsola", types = { "WATER", "ROCK" },
      baseStats = { hp = 65, attack = 55, defense = 95, speed = 35, specialA = 65, specialD = 95 },
      catchRate = 60, baseExp = 144, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "NONE", species = "CURSOLA" },
      },
      heightM = 0.6, weightKg = 5,
      dexEntry = { kind = "Coral Pokémon",
        text = "It will regrow any branches that break off its head. People keep particularly beautiful Corsola branches as charms to promote safe childbirth." },
    },

    REMORAID = {
      dex = 223, name = "Remoraid", types = { "WATER" },
      baseStats = { hp = 35, attack = 65, defense = 35, speed = 65, specialA = 65, specialD = 35 },
      catchRate = 190, baseExp = 60, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "OCTILLERY", level = 25 },
      },
      heightM = 0.6, weightKg = 12,
      dexEntry = { kind = "Jet Pokémon",
        text = "The water they shoot from their mouths can hit moving prey from more than 300 feet away." },
    },

    OCTILLERY = {
      dex = 224, name = "Octillery", types = { "WATER" },
      baseStats = { hp = 75, attack = 105, defense = 75, speed = 45, specialA = 105, specialD = 75 },
      catchRate = 75, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 28.5,
      dexEntry = { kind = "Jet Pokémon",
        text = "It has a tendency to want to be in holes. It prefers rock crags or pots and sprays ink from them before attacking." },
    },

    DELIBIRD = {
      dex = 225, name = "Delibird", types = { "ICE", "FLYING" },
      baseStats = { hp = 45, attack = 55, defense = 45, speed = 75, specialA = 65, specialD = 45 },
      catchRate = 45, baseExp = 116, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 16,
      dexEntry = { kind = "Delivery Pokémon",
        text = "It carries food all day long. There are tales about lost people who were saved by the food it had." },
    },

    MANTINE = {
      dex = 226, name = "Mantine", types = { "WATER", "FLYING" },
      baseStats = { hp = 85, attack = 40, defense = 70, speed = 70, specialA = 80, specialD = 140 },
      catchRate = 25, baseExp = 170, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.1, weightKg = 220,
      dexEntry = { kind = "Kite Pokémon",
        text = "If it builds up enough speed swimming, it can jump out above the waves and glide for over 300 feet." },
    },

    SKARMORY = {
      dex = 227, name = "Skarmory", types = { "STEEL", "FLYING" },
      baseStats = { hp = 65, attack = 80, defense = 140, speed = 70, specialA = 40, specialD = 70 },
      catchRate = 25, baseExp = 163, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 50.5,
      dexEntry = { kind = "Armor Bird Pokémon",
        text = "The pointed feathers of these Pokémon are sharper than swords. Skarmory and Corviknight fight viciously over territory." },
    },

    HOUNDOUR = {
      dex = 228, name = "Houndour", types = { "DARK", "FIRE" },
      baseStats = { hp = 45, attack = 60, defense = 30, speed = 65, specialA = 80, specialD = 50 },
      catchRate = 120, baseExp = 66, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "HOUNDOOM", level = 24 },
      },
      heightM = 0.6, weightKg = 10.8,
      dexEntry = { kind = "Dark Pokémon",
        text = "It cooperates with others skillfully. When it becomes your partner, it’s very loyal to you as its Trainer and will obey your orders." },
    },

    HOUNDOOM = {
      dex = 229, name = "Houndoom", types = { "DARK", "FIRE" },
      baseStats = { hp = 75, attack = 90, defense = 50, speed = 95, specialA = 110, specialD = 80 },
      catchRate = 45, baseExp = 175, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.4, weightKg = 35,
      dexEntry = { kind = "Dark Pokémon",
        text = "They spew flames mixed with poison to finish off their opponents. They divvy up their prey evenly among the members of their pack." },
    },

    KINGDRA = {
      dex = 230, name = "Kingdra", types = { "WATER", "DRAGON" },
      baseStats = { hp = 75, attack = 95, defense = 95, speed = 85, specialA = 95, specialD = 95 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 152,
      dexEntry = { kind = "Dragon Pokémon",
        text = "With the arrival of a storm at sea, this Pokémon will show itself on the surface. When a Kingdra and a Dragonite meet, a fierce battle ensues." },
    },

    PHANPY = {
      dex = 231, name = "Phanpy", types = { "GROUND" },
      baseStats = { hp = 90, attack = 60, defense = 60, speed = 40, specialA = 40, specialD = 40 },
      catchRate = 120, baseExp = 66, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DONPHAN", level = 25 },
      },
      heightM = 0.5, weightKg = 33.5,
      dexEntry = { kind = "Long Nose Pokémon",
        text = "For its nest, Phanpy digs a vertical pit in the ground at the edge of a river. It marks the area around its nest with its trunk to let the others know that the area has been claimed." },
    },

    DONPHAN = {
      dex = 232, name = "Donphan", types = { "GROUND" },
      baseStats = { hp = 90, attack = 120, defense = 120, speed = 50, specialA = 60, specialD = 60 },
      catchRate = 60, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 120,
      dexEntry = { kind = "Armor Pokémon",
        text = "Donphan’s favorite attack is curling its body into a ball, then charging at its foe while rolling at high speed. Once it starts rolling, this Pokémon can’t stop very easily." },
    },

    PORYGON2 = {
      dex = 233, name = "Porygon2", types = { "NORMAL" },
      baseStats = { hp = 85, attack = 80, defense = 90, speed = 60, specialA = 105, specialD = 95 },
      catchRate = 45, baseExp = 180, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "PORYGONZ" },
      },
      heightM = 0.6, weightKg = 32.5,
      dexEntry = { kind = "Virtual Pokémon",
        text = "This is a Porygon that was updated with special data. Porygon2 develops itself by learning about many different subjects all on its own." },
    },

    STANTLER = {
      dex = 234, name = "Stantler", types = { "NORMAL" },
      baseStats = { hp = 73, attack = 95, defense = 62, speed = 85, specialA = 85, specialD = 65 },
      catchRate = 45, baseExp = 163, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVELUSEMOVECOUNT", species = "WYRDEER" },
      },
      heightM = 1.4, weightKg = 71.2,
      dexEntry = { kind = "Big Horn Pokémon",
        text = "Stantler’s magnificent antlers were traded at high prices as works of art. As a result, this Pokémon was hunted close to extinction by those who were after the priceless antlers." },
    },

    SMEARGLE = {
      dex = 235, name = "Smeargle", types = { "NORMAL" },
      baseStats = { hp = 55, attack = 20, defense = 35, speed = 75, specialA = 20, specialD = 45 },
      catchRate = 45, baseExp = 88, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 58,
      dexEntry = { kind = "Painter Pokémon",
        text = "The fluid of Smeargle’s tail secretions changes in the intensity of its hue as the Pokémon’s emotions change." },
    },

    TYROGUE = {
      dex = 236, name = "Tyrogue", types = { "FIGHTING" },
      baseStats = { hp = 35, attack = 35, defense = 35, speed = 35, specialA = 35, specialD = 35 },
      catchRate = 75, baseExp = 42, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ATTACK_GREATER", species = "HITMONLEE" },
        { method = "DEFENSE_GREATER", species = "HITMONCHAN" },
        { method = "ATTACK_DEFENSE_EQUAL", species = "HITMONTOP" },
      },
      heightM = 0.7, weightKg = 21,
      dexEntry = { kind = "Scuffle Pokémon",
        text = "It is always bursting with energy. To make itself stronger, it keeps on fighting even if it loses." },
    },

    HITMONTOP = {
      dex = 237, name = "Hitmontop", types = { "FIGHTING" },
      baseStats = { hp = 50, attack = 95, defense = 95, speed = 70, specialA = 35, specialD = 110 },
      catchRate = 45, baseExp = 159, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 48,
      dexEntry = { kind = "Handstand Pokémon",
        text = "It launches kicks while spinning. If it spins at high speed, it may bore its way into the ground." },
    },

    SMOOCHUM = {
      dex = 238, name = "Smoochum", types = { "ICE", "PSYCHIC" },
      baseStats = { hp = 45, attack = 30, defense = 15, speed = 65, specialA = 85, specialD = 65 },
      catchRate = 45, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "JYNX", level = 30 },
      },
      heightM = 0.4, weightKg = 6,
      dexEntry = { kind = "Kiss Pokémon",
        text = "If its face gets even slightly dirty, Smoochum will bathe immediately. But if its body gets dirty, Smoochum doesn’t really seem to care." },
    },

    ELEKID = {
      dex = 239, name = "Elekid", types = { "ELECTRIC" },
      baseStats = { hp = 45, attack = 63, defense = 37, speed = 95, specialA = 65, specialD = 55 },
      catchRate = 45, baseExp = 72, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ELECTABUZZ", level = 30 },
      },
      heightM = 0.6, weightKg = 23.5,
      dexEntry = { kind = "Electric Pokémon",
        text = "When a storm approaches, this Pokémon gets restless. Once Elekid hears the sound of thunder, it gets full-on rowdy." },
    },

    MAGBY = {
      dex = 240, name = "Magby", types = { "FIRE" },
      baseStats = { hp = 45, attack = 75, defense = 37, speed = 83, specialA = 70, specialD = 55 },
      catchRate = 45, baseExp = 73, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MAGMAR", level = 30 },
      },
      heightM = 0.7, weightKg = 21.4,
      dexEntry = { kind = "Live Coal Pokémon",
        text = "This Pokémon is still small and timid. Whenever Magby gets excited or surprised, flames leak from its mouth and its nose." },
    },

    MILTANK = {
      dex = 241, name = "Miltank", types = { "NORMAL" },
      baseStats = { hp = 95, attack = 80, defense = 105, speed = 100, specialA = 40, specialD = 70 },
      catchRate = 45, baseExp = 172, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 75.5,
      dexEntry = { kind = "Milk Cow Pokémon",
        text = "Miltank produces highly nutritious milk, so it’s been supporting the lives of people and other Pokémon since ancient times." },
    },

    BLISSEY = {
      dex = 242, name = "Blissey", types = { "NORMAL" },
      baseStats = { hp = 255, attack = 10, defense = 10, speed = 55, specialA = 75, specialD = 135 },
      catchRate = 30, baseExp = 255, growthRate = "FAST", happiness = 140,
      evolutions = {},
      heightM = 1.5, weightKg = 46.8,
      dexEntry = { kind = "Happiness Pokémon",
        text = "Whenever a Blissey finds a weakened Pokémon, it will share its egg and offer its care until the other Pokémon is all better." },
    },

    RAIKOU = {
      dex = 243, name = "Raikou", types = { "ELECTRIC" },
      baseStats = { hp = 90, attack = 85, defense = 75, speed = 115, specialA = 115, specialD = 100 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.9, weightKg = 178,
      dexEntry = { kind = "Thunder Pokémon",
        text = "Raikou embodies the speed of lightning. The roars of this Pokémon send shock waves shuddering through the air and shake the ground as if lightning bolts had come crashing down." },
    },

    ENTEI = {
      dex = 244, name = "Entei", types = { "FIRE" },
      baseStats = { hp = 115, attack = 115, defense = 85, speed = 100, specialA = 90, specialD = 75 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2.1, weightKg = 198,
      dexEntry = { kind = "Volcano Pokémon",
        text = "Entei embodies the passion of magma. This Pokémon is thought to have been born in the eruption of a volcano. It sends up massive bursts of fire that utterly consume all that they touch." },
    },

    SUICUNE = {
      dex = 245, name = "Suicune", types = { "WATER" },
      baseStats = { hp = 100, attack = 75, defense = 115, speed = 85, specialA = 90, specialD = 115 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2, weightKg = 187,
      dexEntry = { kind = "Aurora Pokémon",
        text = "Suicune embodies the compassion of a pure spring of water. It runs across the land with gracefulness. This Pokémon has the power to purify dirty water." },
    },

    LARVITAR = {
      dex = 246, name = "Larvitar", types = { "ROCK", "GROUND" },
      baseStats = { hp = 50, attack = 64, defense = 50, speed = 41, specialA = 45, specialD = 50 },
      catchRate = 45, baseExp = 60, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "PUPITAR", level = 30 },
      },
      heightM = 0.6, weightKg = 72,
      dexEntry = { kind = "Rock Skin Pokémon",
        text = "Born deep underground, it comes aboveground and becomes a pupa once it has finished eating the surrounding soil." },
    },

    PUPITAR = {
      dex = 247, name = "Pupitar", types = { "ROCK", "GROUND" },
      baseStats = { hp = 70, attack = 84, defense = 70, speed = 51, specialA = 65, specialD = 70 },
      catchRate = 45, baseExp = 144, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "TYRANITAR", level = 55 },
      },
      heightM = 1.2, weightKg = 152,
      dexEntry = { kind = "Hard Shell Pokémon",
        text = "Even sealed in its shell, it can move freely. Hard and fast, it has outstanding destructive power." },
    },

    TYRANITAR = {
      dex = 248, name = "Tyranitar", types = { "ROCK", "DARK" },
      baseStats = { hp = 100, attack = 134, defense = 110, speed = 61, specialA = 95, specialD = 100 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2, weightKg = 202,
      dexEntry = { kind = "Armor Pokémon",
        text = "Its body can’t be harmed by any sort of attack, so it is very eager to make challenges against enemies." },
    },

    LUGIA = {
      dex = 249, name = "Lugia", types = { "PSYCHIC", "FLYING" },
      baseStats = { hp = 106, attack = 90, defense = 130, speed = 110, specialA = 90, specialD = 154 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 5.2, weightKg = 216,
      dexEntry = { kind = "Diving Pokémon",
        text = "Lugia’s wings pack devastating power—a light fluttering of its wings can blow apart regular houses. As a result, this Pokémon chooses to live out of sight deep under the sea." },
    },

    HOOH = {
      dex = 250, name = "Ho-Oh", types = { "FIRE", "FLYING" },
      baseStats = { hp = 106, attack = 130, defense = 90, speed = 90, specialA = 110, specialD = 154 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.8, weightKg = 199,
      dexEntry = { kind = "Rainbow Pokémon",
        text = "Ho-Oh’s feathers glow in seven colors depending on the angle at which they are struck by light. These feathers are said to bring happiness to the bearers. This Pokémon is said to live at the foot of a rainbow." },
    },

    CELEBI = {
      dex = 251, name = "Celebi", types = { "PSYCHIC", "GRASS" },
      baseStats = { hp = 100, attack = 100, defense = 100, speed = 100, specialA = 100, specialD = 100 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 100,
      evolutions = {},
      heightM = 0.6, weightKg = 5,
      dexEntry = { kind = "Time Travel Pokémon",
        text = "This Pokémon came from the future by crossing over time. It is thought that so long as Celebi appears, a bright and shining future awaits us." },
    },

    TREECKO = {
      dex = 252, name = "Treecko", types = { "GRASS" },
      baseStats = { hp = 40, attack = 45, defense = 35, speed = 70, specialA = 65, specialD = 55 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GROVYLE", level = 16 },
      },
      heightM = 0.5, weightKg = 5,
      dexEntry = { kind = "Wood Gecko Pokémon",
        text = "Treecko has small hooks on the bottom of its feet that enable it to scale vertical walls. This Pokémon attacks by slamming foes with its thick tail." },
    },

    GROVYLE = {
      dex = 253, name = "Grovyle", types = { "GRASS" },
      baseStats = { hp = 50, attack = 65, defense = 45, speed = 95, specialA = 85, specialD = 65 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SCEPTILE", level = 36 },
      },
      heightM = 0.9, weightKg = 21.6,
      dexEntry = { kind = "Wood Gecko Pokémon",
        text = "The leaves growing out of Grovyle’s body are convenient for camouflaging it from enemies in the forest. This Pokémon is a master at climbing trees in jungles." },
    },

    SCEPTILE = {
      dex = 254, name = "Sceptile", types = { "GRASS" },
      baseStats = { hp = 70, attack = 85, defense = 65, speed = 120, specialA = 105, specialD = 85 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 52.2,
      dexEntry = { kind = "Forest Pokémon",
        text = "The leaves growing on Sceptile’s body are very sharp edged. This Pokémon is very agile—it leaps all over the branches of trees and jumps on its foe from above or behind." },
    },

    TORCHIC = {
      dex = 255, name = "Torchic", types = { "FIRE" },
      baseStats = { hp = 45, attack = 60, defense = 40, speed = 45, specialA = 70, specialD = 50 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "COMBUSKEN", level = 16 },
      },
      heightM = 0.4, weightKg = 2.5,
      dexEntry = { kind = "Chick Pokémon",
        text = "Torchic sticks with its Trainer, following behind with unsteady steps. This Pokémon breathes fire of over 1,800 degrees Fahrenheit, including fireballs that leave the foe scorched black." },
    },

    COMBUSKEN = {
      dex = 256, name = "Combusken", types = { "FIRE", "FIGHTING" },
      baseStats = { hp = 60, attack = 85, defense = 60, speed = 55, specialA = 85, specialD = 60 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BLAZIKEN", level = 36 },
      },
      heightM = 0.9, weightKg = 19.5,
      dexEntry = { kind = "Young Fowl Pokémon",
        text = "Combusken toughens up its legs and thighs by running through fields and mountains. This Pokémon’s legs possess both speed and power, enabling it to dole out 10 kicks in one second." },
    },

    BLAZIKEN = {
      dex = 257, name = "Blaziken", types = { "FIRE", "FIGHTING" },
      baseStats = { hp = 80, attack = 120, defense = 70, speed = 80, specialA = 110, specialD = 70 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 52,
      dexEntry = { kind = "Blaze Pokémon",
        text = "In battle, Blaziken blows out intense flames from its wrists and attacks foes courageously. The stronger the foe, the more intensely this Pokémon’s wrists burn." },
    },

    MUDKIP = {
      dex = 258, name = "Mudkip", types = { "WATER" },
      baseStats = { hp = 50, attack = 70, defense = 50, speed = 40, specialA = 50, specialD = 50 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MARSHTOMP", level = 16 },
      },
      heightM = 0.4, weightKg = 7.6,
      dexEntry = { kind = "Mud Fish Pokémon",
        text = "The fin on Mudkip’s head acts as highly sensitive radar. Using this fin to sense movements of water and air, this Pokémon can determine what is taking place around it without using its eyes." },
    },

    MARSHTOMP = {
      dex = 259, name = "Marshtomp", types = { "WATER", "GROUND" },
      baseStats = { hp = 70, attack = 85, defense = 70, speed = 50, specialA = 60, specialD = 70 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SWAMPERT", level = 36 },
      },
      heightM = 0.7, weightKg = 28,
      dexEntry = { kind = "Mud Fish Pokémon",
        text = "The surface of Marshtomp’s body is enveloped by a thin, sticky film that enables it to live on land. This Pokémon plays in mud on beaches when the ocean tide is low." },
    },

    SWAMPERT = {
      dex = 260, name = "Swampert", types = { "WATER", "GROUND" },
      baseStats = { hp = 100, attack = 110, defense = 90, speed = 60, specialA = 85, specialD = 90 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 81.9,
      dexEntry = { kind = "Mud Fish Pokémon",
        text = "Swampert is very strong. It has enough power to easily drag a boulder weighing more than a ton. This Pokémon also has powerful vision that lets it see even in murky water." },
    },

    POOCHYENA = {
      dex = 261, name = "Poochyena", types = { "DARK" },
      baseStats = { hp = 35, attack = 55, defense = 35, speed = 35, specialA = 30, specialD = 30 },
      catchRate = 255, baseExp = 56, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MIGHTYENA", level = 18 },
      },
      heightM = 0.5, weightKg = 13.6,
      dexEntry = { kind = "Bite Pokémon",
        text = "At first sight, Poochyena takes a bite at anything that moves. This Pokémon chases after prey until the victim becomes exhausted. However, it may turn tail if the prey strikes back." },
    },

    MIGHTYENA = {
      dex = 262, name = "Mightyena", types = { "DARK" },
      baseStats = { hp = 70, attack = 90, defense = 70, speed = 70, specialA = 60, specialD = 60 },
      catchRate = 127, baseExp = 147, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 37,
      dexEntry = { kind = "Bite Pokémon",
        text = "Mightyena gives obvious signals when it is preparing to attack. It starts to growl deeply and then flattens its body. This Pokémon will bite savagely with its sharply pointed fangs." },
    },

    ZIGZAGOON = {
      dex = 263, name = "Zigzagoon", types = { "NORMAL" },
      baseStats = { hp = 38, attack = 30, defense = 41, speed = 60, specialA = 30, specialD = 41 },
      catchRate = 255, baseExp = 56, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "LINOONE", level = 20 },
      },
      heightM = 0.4, weightKg = 17.5,
      dexEntry = { kind = "Tiny Racoon Pokémon",
        text = "It marks its territory by rubbing its bristly fur on trees. This variety of Zigzagoon is friendlier and calmer than the kind native to Galar." },
    },

    LINOONE = {
      dex = 264, name = "Linoone", types = { "NORMAL" },
      baseStats = { hp = 78, attack = 70, defense = 61, speed = 100, specialA = 50, specialD = 61 },
      catchRate = 90, baseExp = 147, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "NONE", species = "OBSTAGOON" },
      },
      heightM = 0.5, weightKg = 32.5,
      dexEntry = { kind = "Rush Pokémon",
        text = "Its fur is strong and supple. Shaving brushes made with shed Linoone hairs are highly prized." },
    },

    WURMPLE = {
      dex = 265, name = "Wurmple", types = { "BUG" },
      baseStats = { hp = 45, attack = 45, defense = 35, speed = 20, specialA = 20, specialD = 30 },
      catchRate = 255, baseExp = 56, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "SILCOON", species = "SILCOON" },
        { method = "CASCOON", species = "CASCOON" },
      },
      heightM = 0.3, weightKg = 3.6,
      dexEntry = { kind = "Worm Pokémon",
        text = "Using the spikes on its rear end, Wurmple peels the bark off trees and feeds on the sap that oozes out. This Pokémon’s feet are tipped with suction pads that allow it to cling to glass without slipping." },
    },

    SILCOON = {
      dex = 266, name = "Silcoon", types = { "BUG" },
      baseStats = { hp = 50, attack = 35, defense = 55, speed = 15, specialA = 25, specialD = 25 },
      catchRate = 120, baseExp = 72, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BEAUTIFLY", level = 10 },
      },
      heightM = 0.6, weightKg = 10,
      dexEntry = { kind = "Cocoon Pokémon",
        text = "Silcoon tethers itself to a tree branch using silk to keep from falling. There, this Pokémon hangs quietly while it awaits evolution. It peers out of the silk cocoon through a small hole." },
    },

    BEAUTIFLY = {
      dex = 267, name = "Beautifly", types = { "BUG", "FLYING" },
      baseStats = { hp = 60, attack = 70, defense = 50, speed = 65, specialA = 100, specialD = 50 },
      catchRate = 45, baseExp = 198, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 28.4,
      dexEntry = { kind = "Butterfly Pokémon",
        text = "Beautifly’s favorite food is the sweet pollen of flowers. If you want to see this Pokémon, just leave a potted flower by an open window. Beautifly is sure to come looking for pollen." },
    },

    CASCOON = {
      dex = 268, name = "Cascoon", types = { "BUG" },
      baseStats = { hp = 50, attack = 35, defense = 55, speed = 15, specialA = 25, specialD = 25 },
      catchRate = 120, baseExp = 72, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DUSTOX", level = 10 },
      },
      heightM = 0.7, weightKg = 11.5,
      dexEntry = { kind = "Cocoon Pokémon",
        text = "Cascoon makes its protective cocoon by wrapping its body entirely with a fine silk from its mouth. Once the silk goes around its body, it hardens. This Pokémon prepares for its evolution inside the cocoon." },
    },

    DUSTOX = {
      dex = 269, name = "Dustox", types = { "BUG", "POISON" },
      baseStats = { hp = 60, attack = 50, defense = 70, speed = 65, specialA = 50, specialD = 90 },
      catchRate = 45, baseExp = 193, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 31.6,
      dexEntry = { kind = "Poison Moth Pokémon",
        text = "Dustox is instinctively drawn to light. Swarms of this Pokémon are attracted by the bright lights of cities, where they wreak havoc by stripping the leaves off roadside trees for food." },
    },

    LOTAD = {
      dex = 270, name = "Lotad", types = { "WATER", "GRASS" },
      baseStats = { hp = 40, attack = 30, defense = 30, speed = 30, specialA = 40, specialD = 50 },
      catchRate = 255, baseExp = 44, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "LOMBRE", level = 14 },
      },
      heightM = 0.5, weightKg = 2.6,
      dexEntry = { kind = "Water Weed Pokémon",
        text = "It searches about for clean water. If it does not drink water for too long, the leaf on its head wilts." },
    },

    LOMBRE = {
      dex = 271, name = "Lombre", types = { "WATER", "GRASS" },
      baseStats = { hp = 60, attack = 50, defense = 50, speed = 50, specialA = 60, specialD = 70 },
      catchRate = 120, baseExp = 119, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "LUDICOLO", item = "WATERSTONE" },
      },
      heightM = 1.2, weightKg = 32.5,
      dexEntry = { kind = "Jolly Pokémon",
        text = "It is nocturnal and becomes active at nightfall. It feeds on aquatic mosses that grow in the riverbed." },
    },

    LUDICOLO = {
      dex = 272, name = "Ludicolo", types = { "WATER", "GRASS" },
      baseStats = { hp = 80, attack = 70, defense = 70, speed = 70, specialA = 90, specialD = 100 },
      catchRate = 45, baseExp = 240, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 55,
      dexEntry = { kind = "Carefree Pokémon",
        text = "The rhythm of bright, festive music activates Ludicolo’s cells, making it more powerful." },
    },

    SEEDOT = {
      dex = 273, name = "Seedot", types = { "GRASS" },
      baseStats = { hp = 40, attack = 40, defense = 50, speed = 30, specialA = 30, specialD = 30 },
      catchRate = 255, baseExp = 44, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "NUZLEAF", level = 14 },
      },
      heightM = 0.5, weightKg = 4,
      dexEntry = { kind = "Acorn Pokémon",
        text = "If it remains still, it looks just like a real nut. It delights in surprising foraging Pokémon." },
    },

    NUZLEAF = {
      dex = 274, name = "Nuzleaf", types = { "GRASS", "DARK" },
      baseStats = { hp = 70, attack = 70, defense = 40, speed = 60, specialA = 60, specialD = 40 },
      catchRate = 120, baseExp = 119, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "SHIFTRY", item = "LEAFSTONE" },
      },
      heightM = 1, weightKg = 28,
      dexEntry = { kind = "Wily Pokémon",
        text = "It lives deep in forests. With the leaf on its head, it makes a flute whose song makes listeners uneasy." },
    },

    SHIFTRY = {
      dex = 275, name = "Shiftry", types = { "GRASS", "DARK" },
      baseStats = { hp = 90, attack = 100, defense = 60, speed = 80, specialA = 90, specialD = 60 },
      catchRate = 45, baseExp = 240, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 59.6,
      dexEntry = { kind = "Wickid Pokémon",
        text = "A Pokémon that was feared as a forest guardian. It can read the foe’s mind and take preemptive action." },
    },

    TAILLOW = {
      dex = 276, name = "Taillow", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 40, attack = 55, defense = 30, speed = 85, specialA = 30, specialD = 30 },
      catchRate = 200, baseExp = 54, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SWELLOW", level = 22 },
      },
      heightM = 0.3, weightKg = 2.3,
      dexEntry = { kind = "TinySwallow Pokémon",
        text = "Taillow courageously stands its ground against foes, however strong they may be. This gutsy Pokémon will remain defiant even after a loss. On the other hand, it cries loudly if it becomes hungry." },
    },

    SWELLOW = {
      dex = 277, name = "Swellow", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 60, attack = 85, defense = 60, speed = 125, specialA = 75, specialD = 50 },
      catchRate = 45, baseExp = 159, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 19.8,
      dexEntry = { kind = "Swallow Pokémon",
        text = "Swellow flies high above our heads, making graceful arcs in the sky. This Pokémon dives at a steep angle as soon as it spots its prey. The hapless prey is tightly grasped by Swellow’s clawed feet, preventing escape." },
    },

    WINGULL = {
      dex = 278, name = "Wingull", types = { "WATER", "FLYING" },
      baseStats = { hp = 40, attack = 30, defense = 30, speed = 85, specialA = 55, specialD = 30 },
      catchRate = 190, baseExp = 54, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PELIPPER", level = 25 },
      },
      heightM = 0.6, weightKg = 9.5,
      dexEntry = { kind = "Seagull Pokémon",
        text = "It makes its nest on sheer cliffs. Riding the sea breeze, it glides up into the expansive skies." },
    },

    PELIPPER = {
      dex = 279, name = "Pelipper", types = { "WATER", "FLYING" },
      baseStats = { hp = 60, attack = 50, defense = 100, speed = 65, specialA = 95, specialD = 70 },
      catchRate = 45, baseExp = 154, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 28,
      dexEntry = { kind = "Water Bird Pokémon",
        text = "It is a messenger of the skies, carrying small Pokémon and eggs to safety in its bill." },
    },

    RALTS = {
      dex = 280, name = "Ralts", types = { "PSYCHIC", "FAIRY" },
      baseStats = { hp = 28, attack = 25, defense = 25, speed = 40, specialA = 45, specialD = 35 },
      catchRate = 235, baseExp = 40, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "KIRLIA", level = 20 },
      },
      heightM = 0.4, weightKg = 6.6,
      dexEntry = { kind = "Feeling Pokémon",
        text = "It is highly attuned to the emotions of people and Pokémon. It hides if it senses hostility." },
    },

    KIRLIA = {
      dex = 281, name = "Kirlia", types = { "PSYCHIC", "FAIRY" },
      baseStats = { hp = 38, attack = 35, defense = 35, speed = 50, specialA = 65, specialD = 55 },
      catchRate = 120, baseExp = 97, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "GARDEVOIR", level = 30 },
        { method = "ITEMMALE", species = "GALLADE" },
      },
      heightM = 0.8, weightKg = 20.2,
      dexEntry = { kind = "Emotion Pokémon",
        text = "If its Trainer becomes happy, it overflows with energy, dancing joyously while spinning about." },
    },

    GARDEVOIR = {
      dex = 282, name = "Gardevoir", types = { "PSYCHIC", "FAIRY" },
      baseStats = { hp = 68, attack = 65, defense = 65, speed = 80, specialA = 125, specialD = 115 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.6, weightKg = 48.4,
      dexEntry = { kind = "Embrace Pokémon",
        text = "It has the power to predict the future. Its power peaks when it is protecting its Trainer." },
    },

    SURSKIT = {
      dex = 283, name = "Surskit", types = { "BUG", "WATER" },
      baseStats = { hp = 40, attack = 30, defense = 32, speed = 65, specialA = 50, specialD = 52 },
      catchRate = 200, baseExp = 54, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MASQUERAIN", level = 22 },
      },
      heightM = 0.5, weightKg = 1.7,
      dexEntry = { kind = "Pond Skater Pokémon",
        text = "If it’s in a pinch, it will secrete a sweet liquid from the tip of its head. Syrup made from gathering that liquid is tasty on bread." },
    },

    MASQUERAIN = {
      dex = 284, name = "Masquerain", types = { "BUG", "FLYING" },
      baseStats = { hp = 70, attack = 60, defense = 62, speed = 80, specialA = 100, specialD = 82 },
      catchRate = 75, baseExp = 159, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 3.6,
      dexEntry = { kind = "Eyeball Pokémon",
        text = "Masquerain intimidates enemies with the eyelike patterns of its eyespots. If that doesn’t work, it deftly makes its escape on its set of four wings." },
    },

    SHROOMISH = {
      dex = 285, name = "Shroomish", types = { "GRASS" },
      baseStats = { hp = 60, attack = 40, defense = 60, speed = 35, specialA = 40, specialD = 60 },
      catchRate = 255, baseExp = 59, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BRELOOM", level = 23 },
      },
      heightM = 0.4, weightKg = 4.5,
      dexEntry = { kind = "Mushroom Pokémon",
        text = "Shroomish live in damp soil in the dark depths of forests. They are often found keeping still under fallen leaves. This Pokémon feeds on compost that is made up of fallen, rotted leaves." },
    },

    BRELOOM = {
      dex = 286, name = "Breloom", types = { "GRASS", "FIGHTING" },
      baseStats = { hp = 60, attack = 130, defense = 80, speed = 70, specialA = 60, specialD = 60 },
      catchRate = 90, baseExp = 161, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 39.2,
      dexEntry = { kind = "Mushroom Pokémon",
        text = "Breloom closes in on its foe with light and sprightly footwork, then throws punches with its stretchy arms. This Pokémon’s fighting technique puts boxers to shame." },
    },

    SLAKOTH = {
      dex = 287, name = "Slakoth", types = { "NORMAL" },
      baseStats = { hp = 60, attack = 60, defense = 60, speed = 30, specialA = 35, specialD = 35 },
      catchRate = 255, baseExp = 56, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "VIGOROTH", level = 18 },
      },
      heightM = 0.8, weightKg = 24,
      dexEntry = { kind = "Slacker Pokémon",
        text = "Slakoth lolls around for over 20 hours every day. Because it moves so little, it does not need much food. This Pokémon’s sole daily meal consists of just three leaves." },
    },

    VIGOROTH = {
      dex = 288, name = "Vigoroth", types = { "NORMAL" },
      baseStats = { hp = 80, attack = 80, defense = 80, speed = 90, specialA = 55, specialD = 55 },
      catchRate = 120, baseExp = 154, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SLAKING", level = 36 },
      },
      heightM = 1.4, weightKg = 46.5,
      dexEntry = { kind = "Wild Monkey Pokémon",
        text = "Vigoroth is always itching and agitated to go on a wild rampage. It simply can’t tolerate sitting still for even a minute. This Pokémon’s stress level rises if it can’t be moving constantly." },
    },

    SLAKING = {
      dex = 289, name = "Slaking", types = { "NORMAL" },
      baseStats = { hp = 150, attack = 160, defense = 100, speed = 100, specialA = 95, specialD = 65 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 130.5,
      dexEntry = { kind = "Lazy Pokémon",
        text = "Slaking spends all day lying down and lolling about. It eats grass growing within its reach. If it eats all the grass it can reach, this Pokémon reluctantly moves to another spot." },
    },

    NINCADA = {
      dex = 290, name = "Nincada", types = { "BUG", "GROUND" },
      baseStats = { hp = 31, attack = 45, defense = 90, speed = 40, specialA = 30, specialD = 30 },
      catchRate = 255, baseExp = 53, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "NINJASK", species = "NINJASK" },
        { method = "SHEDINJA", species = "SHEDINJA" },
      },
      heightM = 0.5, weightKg = 5.5,
      dexEntry = { kind = "Trainee Pokémon",
        text = "Because it lived almost entirely underground, it is nearly blind. It uses its antennae instead." },
    },

    NINJASK = {
      dex = 291, name = "Ninjask", types = { "BUG", "FLYING" },
      baseStats = { hp = 61, attack = 90, defense = 45, speed = 160, specialA = 50, specialD = 50 },
      catchRate = 120, baseExp = 160, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 12,
      dexEntry = { kind = "Ninja Pokémon",
        text = "Its cry leaves a lasting headache if heard for too long. It moves so quickly that it is almost invisible." },
    },

    SHEDINJA = {
      dex = 292, name = "Shedinja", types = { "BUG", "GHOST" },
      baseStats = { hp = 1, attack = 90, defense = 45, speed = 40, specialA = 30, specialD = 30 },
      catchRate = 45, baseExp = 83, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 1.2,
      dexEntry = { kind = "Shed Pokémon",
        text = "A most peculiar Pokémon that somehow appears in a Poké Ball when a Nincada evolves." },
    },

    WHISMUR = {
      dex = 293, name = "Whismur", types = { "NORMAL" },
      baseStats = { hp = 64, attack = 51, defense = 23, speed = 28, specialA = 51, specialD = 23 },
      catchRate = 190, baseExp = 48, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "LOUDRED", level = 20 },
      },
      heightM = 0.6, weightKg = 16.3,
      dexEntry = { kind = "Whisper Pokémon",
        text = "The cry of a Whismur is over 100 decibels. If you’re close to a Whismur when it lets out a cry, you’ll be stuck with an all-day headache." },
    },

    LOUDRED = {
      dex = 294, name = "Loudred", types = { "NORMAL" },
      baseStats = { hp = 84, attack = 71, defense = 43, speed = 48, specialA = 71, specialD = 43 },
      catchRate = 120, baseExp = 126, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "EXPLOUD", level = 40 },
      },
      heightM = 1, weightKg = 40.5,
      dexEntry = { kind = "Big Voice Pokémon",
        text = "Loudred’s ears serve as speakers, and they can put out sound waves powerful enough to blow away a house." },
    },

    EXPLOUD = {
      dex = 295, name = "Exploud", types = { "NORMAL" },
      baseStats = { hp = 104, attack = 91, defense = 63, speed = 68, specialA = 91, specialD = 73 },
      catchRate = 45, baseExp = 245, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 84,
      dexEntry = { kind = "Loud Noise Pokémon",
        text = "In the past, people would use the loud voices of these Pokémon as a means of communication between distant cities." },
    },

    MAKUHITA = {
      dex = 296, name = "Makuhita", types = { "FIGHTING" },
      baseStats = { hp = 72, attack = 60, defense = 30, speed = 25, specialA = 20, specialD = 30 },
      catchRate = 180, baseExp = 47, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "HARIYAMA", level = 24 },
      },
      heightM = 1, weightKg = 86.4,
      dexEntry = { kind = "Guts Pokémon",
        text = "It practices its slaps by repeatedly slapping tree trunks. It has been known to slap an Exeggutor and get flung away." },
    },

    HARIYAMA = {
      dex = 297, name = "Hariyama", types = { "FIGHTING" },
      baseStats = { hp = 144, attack = 120, defense = 60, speed = 50, specialA = 40, specialD = 60 },
      catchRate = 200, baseExp = 166, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {},
      heightM = 2.3, weightKg = 253.8,
      dexEntry = { kind = "Arm Thrust Pokémon",
        text = "Although they enjoy comparing their strength, they’re also kind. They value etiquette, praising opponents they battle." },
    },

    AZURILL = {
      dex = 298, name = "Azurill", types = { "NORMAL", "FAIRY" },
      baseStats = { hp = 50, attack = 20, defense = 40, speed = 20, specialA = 20, specialD = 40 },
      catchRate = 150, baseExp = 38, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "HAPPINESS", species = "MARILL" },
      },
      heightM = 0.2, weightKg = 2,
      dexEntry = { kind = "Polka Dot Pokémon",
        text = "The ball on Azurill’s tail bounces like a rubber ball, and it’s full of the nutrients the Pokémon needs to grow." },
    },

    NOSEPASS = {
      dex = 299, name = "Nosepass", types = { "ROCK" },
      baseStats = { hp = 30, attack = 45, defense = 135, speed = 30, specialA = 45, specialD = 90 },
      catchRate = 255, baseExp = 75, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LOCATIONFLAG", species = "PROBOPASS" },
        { method = "ITEM", species = "PROBOPASS", item = "THUNDERSTONE" },
      },
      heightM = 1, weightKg = 97,
      dexEntry = { kind = "Compass Pokémon",
        text = "It moves less than an inch a year, but when it’s in a jam, it will spin and drill down into the ground in a split second." },
    },

    SKITTY = {
      dex = 300, name = "Skitty", types = { "NORMAL" },
      baseStats = { hp = 50, attack = 45, defense = 45, speed = 50, specialA = 35, specialD = 35 },
      catchRate = 255, baseExp = 52, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "DELCATTY", item = "MOONSTONE" },
      },
      heightM = 0.6, weightKg = 11,
      dexEntry = { kind = "Kitten Pokémon",
        text = "Skitty has the habit of becoming fascinated by moving objects and chasing them around. This Pokémon is known to chase after its own tail and become dizzy." },
    },

    DELCATTY = {
      dex = 301, name = "Delcatty", types = { "NORMAL" },
      baseStats = { hp = 70, attack = 65, defense = 65, speed = 90, specialA = 55, specialD = 55 },
      catchRate = 60, baseExp = 140, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 32.6,
      dexEntry = { kind = "Prim Pokémon",
        text = "Delcatty prefers to live an unfettered existence in which it can do as it pleases at its own pace. Because this Pokémon eats and sleeps whenever it decides, its daily routines are completely random." },
    },

    SABLEYE = {
      dex = 302, name = "Sableye", types = { "DARK", "GHOST" },
      baseStats = { hp = 50, attack = 75, defense = 75, speed = 50, specialA = 65, specialD = 65 },
      catchRate = 45, baseExp = 133, growthRate = "MEDIUM_SLOW", happiness = 35,
      evolutions = {},
      heightM = 0.5, weightKg = 11,
      dexEntry = { kind = "Darkness Pokémon",
        text = "This Pokémon is feared. When its gemstone eyes begin to glow with a sinister shine, it’s believed that Sableye will steal people’s spirits away." },
    },

    MAWILE = {
      dex = 303, name = "Mawile", types = { "STEEL", "FAIRY" },
      baseStats = { hp = 50, attack = 85, defense = 85, speed = 50, specialA = 55, specialD = 55 },
      catchRate = 45, baseExp = 133, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.6, weightKg = 11.5,
      dexEntry = { kind = "Deceiver Pokémon",
        text = "It uses its docile-looking face to lull foes into complacency, then bites with its huge, relentless jaws." },
    },

    ARON = {
      dex = 304, name = "Aron", types = { "STEEL", "ROCK" },
      baseStats = { hp = 50, attack = 70, defense = 100, speed = 30, specialA = 40, specialD = 40 },
      catchRate = 180, baseExp = 66, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "LAIRON", level = 32 },
      },
      heightM = 0.4, weightKg = 60,
      dexEntry = { kind = "Iron Armor Pokémon",
        text = "It eats iron ore—and sometimes railroad tracks— to build up the steel armor that protects its body." },
    },

    LAIRON = {
      dex = 305, name = "Lairon", types = { "STEEL", "ROCK" },
      baseStats = { hp = 60, attack = 90, defense = 140, speed = 40, specialA = 50, specialD = 50 },
      catchRate = 90, baseExp = 151, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "AGGRON", level = 42 },
      },
      heightM = 0.9, weightKg = 120,
      dexEntry = { kind = "Iron Armor Pokémon",
        text = "Lairon live in mountains brimming with spring water and iron ore, so these Pokémon often came into conflict with humans in the past." },
    },

    AGGRON = {
      dex = 306, name = "Aggron", types = { "STEEL", "ROCK" },
      baseStats = { hp = 70, attack = 110, defense = 180, speed = 50, specialA = 60, specialD = 60 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2.1, weightKg = 360,
      dexEntry = { kind = "Iron Armor Pokémon",
        text = "Aggron has a horn sharp enough to perforate thick iron sheets. It brings down its opponents by ramming into them horn first." },
    },

    MEDITITE = {
      dex = 307, name = "Meditite", types = { "FIGHTING", "PSYCHIC" },
      baseStats = { hp = 30, attack = 40, defense = 55, speed = 60, specialA = 40, specialD = 55 },
      catchRate = 180, baseExp = 56, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MEDICHAM", level = 37 },
      },
      heightM = 0.6, weightKg = 11.2,
      dexEntry = { kind = "Meditate Pokémon",
        text = "Meditite undertakes rigorous mental training deep in the mountains. However, whenever it meditates, this Pokémon always loses its concentration and focus. As a result, its training never ends." },
    },

    MEDICHAM = {
      dex = 308, name = "Medicham", types = { "FIGHTING", "PSYCHIC" },
      baseStats = { hp = 60, attack = 60, defense = 75, speed = 80, specialA = 60, specialD = 75 },
      catchRate = 90, baseExp = 144, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 31.5,
      dexEntry = { kind = "Meditate Pokémon",
        text = "It is said that through meditation, Medicham heightens energy inside its body and sharpens its sixth sense. This Pokémon hides its presence by merging itself with fields and mountains." },
    },

    ELECTRIKE = {
      dex = 309, name = "Electrike", types = { "ELECTRIC" },
      baseStats = { hp = 40, attack = 45, defense = 40, speed = 65, specialA = 65, specialD = 40 },
      catchRate = 120, baseExp = 59, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MANECTRIC", level = 26 },
      },
      heightM = 0.6, weightKg = 15.2,
      dexEntry = { kind = "Lightning Pokémon",
        text = "It stores static electricity in its fur for discharging. It gives off sparks if a storm approaches." },
    },

    MANECTRIC = {
      dex = 310, name = "Manectric", types = { "ELECTRIC" },
      baseStats = { hp = 70, attack = 75, defense = 60, speed = 105, specialA = 105, specialD = 60 },
      catchRate = 45, baseExp = 166, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 40.2,
      dexEntry = { kind = "Discharge Pokémon",
        text = "It stimulates its own muscles with electricity, so it can move quickly. It eases its soreness with electricity, too, so it can recover quickly as well." },
    },

    PLUSLE = {
      dex = 311, name = "Plusle", types = { "ELECTRIC" },
      baseStats = { hp = 60, attack = 50, defense = 40, speed = 95, specialA = 85, specialD = 75 },
      catchRate = 200, baseExp = 142, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.4, weightKg = 4.2,
      dexEntry = { kind = "Cheering Pokémon",
        text = "Plusle always acts as a cheerleader for its partners. Whenever a teammate puts out a good effort in battle, this Pokémon shorts out its body to create the crackling noises of sparks to show its joy." },
    },

    MINUN = {
      dex = 312, name = "Minun", types = { "ELECTRIC" },
      baseStats = { hp = 60, attack = 40, defense = 50, speed = 95, specialA = 75, specialD = 85 },
      catchRate = 200, baseExp = 142, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.4, weightKg = 4.2,
      dexEntry = { kind = "Cheering Pokémon",
        text = "Minun is more concerned about cheering on its partners than its own safety. It shorts out the electricity in its body to create brilliant showers of sparks to cheer on its teammates." },
    },

    VOLBEAT = {
      dex = 313, name = "Volbeat", types = { "BUG" },
      baseStats = { hp = 65, attack = 73, defense = 75, speed = 85, specialA = 47, specialD = 85 },
      catchRate = 150, baseExp = 151, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 17.7,
      dexEntry = { kind = "Firefly Pokémon",
        text = "With the arrival of night, Volbeat emits light from its tail. It communicates with others by adjusting the intensity and flashing of its light. This Pokémon is attracted by the sweet aroma of Illumise." },
    },

    ILLUMISE = {
      dex = 314, name = "Illumise", types = { "BUG" },
      baseStats = { hp = 65, attack = 47, defense = 75, speed = 85, specialA = 73, specialD = 85 },
      catchRate = 150, baseExp = 151, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {},
      heightM = 0.6, weightKg = 17.7,
      dexEntry = { kind = "Firefly Pokémon",
        text = "Illumise attracts a swarm of Volbeat using a sweet fragrance. Once the Volbeat have gathered, this Pokémon leads the lit-up swarm in drawing geometric designs on the canvas of the night sky." },
    },

    ROSELIA = {
      dex = 315, name = "Roselia", types = { "GRASS", "POISON" },
      baseStats = { hp = 50, attack = 60, defense = 45, speed = 65, specialA = 100, specialD = 80 },
      catchRate = 150, baseExp = 140, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "ROSERADE", item = "SHINYSTONE" },
      },
      heightM = 0.3, weightKg = 2,
      dexEntry = { kind = "Thorn Pokémon",
        text = "Its flowers give off a relaxing fragrance. The stronger its aroma, the healthier the Roselia is." },
    },

    GULPIN = {
      dex = 316, name = "Gulpin", types = { "POISON" },
      baseStats = { hp = 70, attack = 43, defense = 53, speed = 40, specialA = 43, specialD = 53 },
      catchRate = 225, baseExp = 60, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SWALOT", level = 26 },
      },
      heightM = 0.4, weightKg = 10.3,
      dexEntry = { kind = "Stomach Pokémon",
        text = "Virtually all of Gulpin’s body is its stomach. As a result, it can swallow something its own size. This Pokémon’s stomach contains a special fluid that digests anything." },
    },

    SWALOT = {
      dex = 317, name = "Swalot", types = { "POISON" },
      baseStats = { hp = 100, attack = 73, defense = 83, speed = 55, specialA = 73, specialD = 83 },
      catchRate = 75, baseExp = 163, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 80,
      dexEntry = { kind = "Poison Bag Pokémon",
        text = "When Swalot spots prey, it spurts out a hideously toxic fluid from its pores and sprays the target. Once the prey has weakened, this Pokémon gulps it down whole with its cavernous mouth." },
    },

    CARVANHA = {
      dex = 318, name = "Carvanha", types = { "WATER", "DARK" },
      baseStats = { hp = 45, attack = 90, defense = 20, speed = 65, specialA = 65, specialD = 20 },
      catchRate = 225, baseExp = 61, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "SHARPEDO", level = 30 },
      },
      heightM = 0.8, weightKg = 20.8,
      dexEntry = { kind = "Savage Pokémon",
        text = "It won’t attack while it’s alone—not even if it spots prey. Instead, it waits for other Carvanha to join it, and then the Pokémon attack as a group." },
    },

    SHARPEDO = {
      dex = 319, name = "Sharpedo", types = { "WATER", "DARK" },
      baseStats = { hp = 70, attack = 120, defense = 40, speed = 95, specialA = 95, specialD = 40 },
      catchRate = 60, baseExp = 161, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.8, weightKg = 88.8,
      dexEntry = { kind = "Brutal Pokémon",
        text = "As soon as it catches the scent of prey, Sharpedo will jet seawater from its backside, hurtling toward the target to attack at 75 mph." },
    },

    WAILMER = {
      dex = 320, name = "Wailmer", types = { "WATER" },
      baseStats = { hp = 130, attack = 70, defense = 35, speed = 60, specialA = 70, specialD = 35 },
      catchRate = 125, baseExp = 80, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "WAILORD", level = 40 },
      },
      heightM = 2, weightKg = 130,
      dexEntry = { kind = "Ball Whale Pokémon",
        text = "It shows off by spraying jets of seawater from the nostrils above its eyes. It eats a solid ton of Wishiwashi every day." },
    },

    WAILORD = {
      dex = 321, name = "Wailord", types = { "WATER" },
      baseStats = { hp = 170, attack = 90, defense = 45, speed = 60, specialA = 90, specialD = 45 },
      catchRate = 60, baseExp = 175, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {},
      heightM = 14.5, weightKg = 398,
      dexEntry = { kind = "Float Whale Pokémon",
        text = "It can sometimes knock out opponents with the shock created by breaching and crashing its big body onto the water." },
    },

    NUMEL = {
      dex = 322, name = "Numel", types = { "FIRE", "GROUND" },
      baseStats = { hp = 60, attack = 60, defense = 40, speed = 35, specialA = 65, specialD = 45 },
      catchRate = 255, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CAMERUPT", level = 33 },
      },
      heightM = 0.7, weightKg = 24,
      dexEntry = { kind = "Numb Pokémon",
        text = "Numel is extremely dull witted—it doesn’t notice being hit. However, it can’t stand hunger for even a second. This Pokémon’s body is a seething cauldron of boiling magma." },
    },

    CAMERUPT = {
      dex = 323, name = "Camerupt", types = { "FIRE", "GROUND" },
      baseStats = { hp = 70, attack = 100, defense = 70, speed = 40, specialA = 105, specialD = 75 },
      catchRate = 150, baseExp = 161, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 220,
      dexEntry = { kind = "Eruption Pokémon",
        text = "Camerupt has a volcano inside its body. Magma of 18,000 degrees Fahrenheit courses through its body. Occasionally, the humps on this Pokémon’s back erupt, spewing the superheated magma." },
    },

    TORKOAL = {
      dex = 324, name = "Torkoal", types = { "FIRE" },
      baseStats = { hp = 70, attack = 85, defense = 140, speed = 20, specialA = 85, specialD = 70 },
      catchRate = 90, baseExp = 165, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.5, weightKg = 80.4,
      dexEntry = { kind = "Coal Pokémon",
        text = "It burns coal inside its shell for energy. It blows out black soot if it is endangered." },
    },

    SPOINK = {
      dex = 325, name = "Spoink", types = { "PSYCHIC" },
      baseStats = { hp = 60, attack = 25, defense = 35, speed = 60, specialA = 70, specialD = 80 },
      catchRate = 255, baseExp = 66, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GRUMPIG", level = 32 },
      },
      heightM = 0.7, weightKg = 30.6,
      dexEntry = { kind = "Bounce Pokémon",
        text = "Spoink bounces around on its tail. The shock of its bouncing makes its heart pump. As a result, this Pokémon cannot afford to stop bouncing—if it stops, its heart will stop." },
    },

    GRUMPIG = {
      dex = 326, name = "Grumpig", types = { "PSYCHIC" },
      baseStats = { hp = 80, attack = 45, defense = 65, speed = 80, specialA = 90, specialD = 110 },
      catchRate = 60, baseExp = 165, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 71.5,
      dexEntry = { kind = "Manipulate Pokémon",
        text = "Grumpig uses the black pearls on its body to amplify its psychic power waves for gaining total control over its foe. When this Pokémon uses its special power, its snorting breath grows labored." },
    },

    SPINDA = {
      dex = 327, name = "Spinda", types = { "NORMAL" },
      baseStats = { hp = 60, attack = 60, defense = 60, speed = 60, specialA = 60, specialD = 60 },
      catchRate = 255, baseExp = 126, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 5,
      dexEntry = { kind = "Spot Panda Pokémon",
        text = "Its steps are shaky and stumbling. Walking for a long time makes it feel sick." },
    },

    TRAPINCH = {
      dex = 328, name = "Trapinch", types = { "GROUND" },
      baseStats = { hp = 45, attack = 100, defense = 45, speed = 10, specialA = 45, specialD = 45 },
      catchRate = 255, baseExp = 58, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "VIBRAVA", level = 35 },
      },
      heightM = 0.7, weightKg = 15,
      dexEntry = { kind = "Ant Pit Pokémon",
        text = "Its nest is a sloped, bowl-like pit in the desert. Once something has fallen in, there is no escape." },
    },

    VIBRAVA = {
      dex = 329, name = "Vibrava", types = { "GROUND", "DRAGON" },
      baseStats = { hp = 50, attack = 70, defense = 50, speed = 70, specialA = 50, specialD = 50 },
      catchRate = 120, baseExp = 119, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FLYGON", level = 45 },
      },
      heightM = 1.1, weightKg = 15.3,
      dexEntry = { kind = "Vibration Pokémon",
        text = "The ultrasonic waves it generates by rubbing its two wings together cause severe headaches." },
    },

    FLYGON = {
      dex = 330, name = "Flygon", types = { "GROUND", "DRAGON" },
      baseStats = { hp = 80, attack = 100, defense = 80, speed = 100, specialA = 80, specialD = 80 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 82,
      dexEntry = { kind = "Mystic Pokémon",
        text = "This Pokémon hides in the heart of sandstorms it creates and seldom appears where people can see it." },
    },

    CACNEA = {
      dex = 331, name = "Cacnea", types = { "GRASS" },
      baseStats = { hp = 50, attack = 85, defense = 40, speed = 35, specialA = 85, specialD = 40 },
      catchRate = 190, baseExp = 67, growthRate = "MEDIUM_SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "CACTURNE", level = 32 },
      },
      heightM = 0.4, weightKg = 51.3,
      dexEntry = { kind = "Cactus Pokémon",
        text = "Cacnea lives in arid locations such as deserts. It releases a strong aroma from its flower to attract prey. When prey comes near, this Pokémon shoots sharp thorns from its body to bring the victim down." },
    },

    CACTURNE = {
      dex = 332, name = "Cacturne", types = { "GRASS", "DARK" },
      baseStats = { hp = 70, attack = 115, defense = 60, speed = 55, specialA = 115, specialD = 60 },
      catchRate = 60, baseExp = 166, growthRate = "MEDIUM_SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.3, weightKg = 77.4,
      dexEntry = { kind = "Scarecrow Pokémon",
        text = "During the daytime, Cacturne remains unmoving so that it does not lose any moisture to the harsh desert sun. This Pokémon becomes active at night when the temperature drops." },
    },

    SWABLU = {
      dex = 333, name = "Swablu", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 45, attack = 40, defense = 60, speed = 50, specialA = 40, specialD = 75 },
      catchRate = 255, baseExp = 62, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ALTARIA", level = 35 },
      },
      heightM = 0.4, weightKg = 1.2,
      dexEntry = { kind = "Cotton Bird Pokémon",
        text = "Its cottony wings are full of air, making them light and fluffy to the touch. Swablu takes diligent care of its wings." },
    },

    ALTARIA = {
      dex = 334, name = "Altaria", types = { "DRAGON", "FLYING" },
      baseStats = { hp = 75, attack = 70, defense = 90, speed = 80, specialA = 70, specialD = 105 },
      catchRate = 45, baseExp = 172, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 20.6,
      dexEntry = { kind = "Humming Pokémon",
        text = "As it flies in a calm and relaxed manner, Altaria performs a humming song that would enrapture any audience." },
    },

    ZANGOOSE = {
      dex = 335, name = "Zangoose", types = { "NORMAL" },
      baseStats = { hp = 73, attack = 115, defense = 60, speed = 90, specialA = 60, specialD = 60 },
      catchRate = 90, baseExp = 160, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 40.3,
      dexEntry = { kind = "Cat Ferret Pokémon",
        text = "Memories of battling its archrival Seviper are etched into every cell of Zangoose’s body. This Pokémon adroitly dodges attacks with incredible agility." },
    },

    SEVIPER = {
      dex = 336, name = "Seviper", types = { "POISON" },
      baseStats = { hp = 73, attack = 100, defense = 60, speed = 65, specialA = 100, specialD = 60 },
      catchRate = 90, baseExp = 160, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {},
      heightM = 2.7, weightKg = 52.5,
      dexEntry = { kind = "Fang Snake Pokémon",
        text = "Seviper shares a generations-long feud with Zangoose. The scars on its body are evidence of vicious battles. This Pokémon attacks using its sword-edged tail." },
    },

    LUNATONE = {
      dex = 337, name = "Lunatone", types = { "ROCK", "PSYCHIC" },
      baseStats = { hp = 90, attack = 55, defense = 65, speed = 70, specialA = 95, specialD = 85 },
      catchRate = 45, baseExp = 161, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 168,
      dexEntry = { kind = "Meteorite Pokémon",
        text = "The phase of the moon apparently has some effect on its power. It’s active on the night of a full moon." },
    },

    SOLROCK = {
      dex = 338, name = "Solrock", types = { "ROCK", "PSYCHIC" },
      baseStats = { hp = 90, attack = 95, defense = 85, speed = 70, specialA = 55, specialD = 65 },
      catchRate = 45, baseExp = 161, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 154,
      dexEntry = { kind = "Meteorite Pokémon",
        text = "When it rotates itself, it gives off light similar to the sun, thus blinding its foes." },
    },

    BARBOACH = {
      dex = 339, name = "Barboach", types = { "WATER", "GROUND" },
      baseStats = { hp = 50, attack = 48, defense = 43, speed = 60, specialA = 46, specialD = 41 },
      catchRate = 190, baseExp = 58, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "WHISCASH", level = 30 },
      },
      heightM = 0.4, weightKg = 1.9,
      dexEntry = { kind = "Whiskers Pokémon",
        text = "Its slimy body is hard to grasp. In one region, it is said to have been born from hardened mud." },
    },

    WHISCASH = {
      dex = 340, name = "Whiscash", types = { "WATER", "GROUND" },
      baseStats = { hp = 110, attack = 78, defense = 73, speed = 60, specialA = 76, specialD = 71 },
      catchRate = 75, baseExp = 164, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 23.6,
      dexEntry = { kind = "Whiskers Pokémon",
        text = "It makes its nest at the bottom of swamps. It will eat anything—if it is alive, Whiscash will eat it." },
    },

    CORPHISH = {
      dex = 341, name = "Corphish", types = { "WATER" },
      baseStats = { hp = 43, attack = 80, defense = 65, speed = 35, specialA = 50, specialD = 35 },
      catchRate = 205, baseExp = 62, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CRAWDAUNT", level = 30 },
      },
      heightM = 0.6, weightKg = 11.5,
      dexEntry = { kind = "Ruffian Pokémon",
        text = "No matter how dirty the water in the river, it will adapt and thrive. It has a strong will to survive." },
    },

    CRAWDAUNT = {
      dex = 342, name = "Crawdaunt", types = { "WATER", "DARK" },
      baseStats = { hp = 63, attack = 120, defense = 85, speed = 55, specialA = 90, specialD = 55 },
      catchRate = 155, baseExp = 164, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 32.8,
      dexEntry = { kind = "Rogue Pokémon",
        text = "A rough customer that wildly flails its giant claws. It is said to be extremely hard to raise." },
    },

    BALTOY = {
      dex = 343, name = "Baltoy", types = { "GROUND", "PSYCHIC" },
      baseStats = { hp = 40, attack = 40, defense = 55, speed = 55, specialA = 40, specialD = 70 },
      catchRate = 255, baseExp = 60, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CLAYDOL", level = 36 },
      },
      heightM = 0.5, weightKg = 21.5,
      dexEntry = { kind = "Clay Doll Pokémon",
        text = "It moves while spinning around on its single foot. Some Baltoy have been seen spinning on their heads." },
    },

    CLAYDOL = {
      dex = 344, name = "Claydol", types = { "GROUND", "PSYCHIC" },
      baseStats = { hp = 60, attack = 70, defense = 105, speed = 75, specialA = 70, specialD = 120 },
      catchRate = 90, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 108,
      dexEntry = { kind = "Clay Doll Pokémon",
        text = "This mysterious Pokémon started life as an ancient clay figurine made over 20,000 years ago." },
    },

    LILEEP = {
      dex = 345, name = "Lileep", types = { "ROCK", "GRASS" },
      baseStats = { hp = 66, attack = 41, defense = 77, speed = 23, specialA = 61, specialD = 87 },
      catchRate = 45, baseExp = 71, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CRADILY", level = 40 },
      },
      heightM = 1, weightKg = 23.8,
      dexEntry = { kind = "Sea Lily Pokémon",
        text = "This Pokémon was restored from a fossil. Lileep once lived in warm seas that existed approximately 100,000,000 years ago." },
    },

    CRADILY = {
      dex = 346, name = "Cradily", types = { "ROCK", "GRASS" },
      baseStats = { hp = 86, attack = 81, defense = 97, speed = 43, specialA = 81, specialD = 107 },
      catchRate = 45, baseExp = 173, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 60.4,
      dexEntry = { kind = "Barnacle Pokémon",
        text = "It has short legs and can’t walk very fast, but its neck and tentacles can extend to over three times their usual length to nab distant prey." },
    },

    ANORITH = {
      dex = 347, name = "Anorith", types = { "ROCK", "BUG" },
      baseStats = { hp = 45, attack = 95, defense = 50, speed = 75, specialA = 40, specialD = 50 },
      catchRate = 45, baseExp = 71, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ARMALDO", level = 40 },
      },
      heightM = 0.7, weightKg = 12.5,
      dexEntry = { kind = "Old Shrimp Pokémon",
        text = "This Pokémon was restored from a fossil. Anorith lived in the ocean about 100,000,000 years ago, hunting with its pair of claws." },
    },

    ARMALDO = {
      dex = 348, name = "Armaldo", types = { "ROCK", "BUG" },
      baseStats = { hp = 75, attack = 125, defense = 100, speed = 45, specialA = 70, specialD = 80 },
      catchRate = 45, baseExp = 173, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 68.2,
      dexEntry = { kind = "Plate Pokémon",
        text = "After evolution, this Pokémon emerged onto land. Its lower body has become stronger, and blows from its tail are devastating." },
    },

    FEEBAS = {
      dex = 349, name = "Feebas", types = { "WATER" },
      baseStats = { hp = 20, attack = 15, defense = 20, speed = 80, specialA = 10, specialD = 55 },
      catchRate = 255, baseExp = 40, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "MILOTIC" },
        { method = "BEAUTY", species = "MILOTIC" },
      },
      heightM = 0.6, weightKg = 7.4,
      dexEntry = { kind = "Fish Pokémon",
        text = "Although unattractive and unpopular, this Pokémon’s marvelous vitality has made it a subject of research." },
    },

    MILOTIC = {
      dex = 350, name = "Milotic", types = { "WATER" },
      baseStats = { hp = 95, attack = 60, defense = 79, speed = 81, specialA = 100, specialD = 125 },
      catchRate = 60, baseExp = 189, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 6.2, weightKg = 162,
      dexEntry = { kind = "Tender Pokémon",
        text = "Milotic has provided inspiration to many artists. It has even been referred to as the most beautiful Pokémon of all." },
    },

    CASTFORM = {
      dex = 351, name = "Castform", types = { "NORMAL" },
      baseStats = { hp = 70, attack = 70, defense = 70, speed = 70, specialA = 70, specialD = 70 },
      catchRate = 45, baseExp = 147, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 0.8,
      dexEntry = { kind = "Weather Pokémon",
        text = "Although its form changes with the weather, that is apparently the result of a chemical reaction and not the result of its own free will." },
    },

    KECLEON = {
      dex = 352, name = "Kecleon", types = { "NORMAL" },
      baseStats = { hp = 60, attack = 90, defense = 70, speed = 40, specialA = 60, specialD = 120 },
      catchRate = 200, baseExp = 154, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 22,
      dexEntry = { kind = "Color Swap Pokémon",
        text = "It changes its hue to blend into its surroundings. If no one takes notice of it for too long, it will pout and never reveal itself." },
    },

    SHUPPET = {
      dex = 353, name = "Shuppet", types = { "GHOST" },
      baseStats = { hp = 44, attack = 75, defense = 35, speed = 45, specialA = 63, specialD = 33 },
      catchRate = 225, baseExp = 59, growthRate = "FAST", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "BANETTE", level = 37 },
      },
      heightM = 0.6, weightKg = 2.3,
      dexEntry = { kind = "Puppet Pokémon",
        text = "It eats up emotions like malice, jealousy, and resentment, so some people are grateful for its presence." },
    },

    BANETTE = {
      dex = 354, name = "Banette", types = { "GHOST" },
      baseStats = { hp = 64, attack = 115, defense = 65, speed = 65, specialA = 83, specialD = 63 },
      catchRate = 45, baseExp = 159, growthRate = "FAST", happiness = 35,
      evolutions = {},
      heightM = 1.1, weightKg = 12.5,
      dexEntry = { kind = "Marionette Pokémon",
        text = "It’s a stuffed toy that was thrown away and became possessed, ever searching for the one who threw it away so it can exact its revenge." },
    },

    DUSKULL = {
      dex = 355, name = "Duskull", types = { "GHOST" },
      baseStats = { hp = 20, attack = 40, defense = 90, speed = 25, specialA = 30, specialD = 90 },
      catchRate = 190, baseExp = 59, growthRate = "FAST", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "DUSCLOPS", level = 37 },
      },
      heightM = 0.8, weightKg = 15,
      dexEntry = { kind = "Requiem Pokémon",
        text = "If it finds bad children who won’t listen to their parents, it will spirit them away—or so it’s said." },
    },

    DUSCLOPS = {
      dex = 356, name = "Dusclops", types = { "GHOST" },
      baseStats = { hp = 40, attack = 70, defense = 130, speed = 25, specialA = 60, specialD = 130 },
      catchRate = 90, baseExp = 159, growthRate = "FAST", happiness = 35,
      evolutions = {
        { method = "CABLELINKITEM", species = "DUSKNOIR" },
      },
      heightM = 1.6, weightKg = 30.6,
      dexEntry = { kind = "Beckon Pokémon",
        text = "Its body is entirely hollow. When it opens its mouth, it sucks everything in as if it were a black hole." },
    },

    TROPIUS = {
      dex = 357, name = "Tropius", types = { "GRASS", "FLYING" },
      baseStats = { hp = 99, attack = 68, defense = 83, speed = 51, specialA = 72, specialD = 87 },
      catchRate = 200, baseExp = 161, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 100,
      dexEntry = { kind = "Fruit Pokémon",
        text = "The bunches of fruit growing around the necks of Tropius in Alola are especially sweet compared to those in other regions." },
    },

    CHIMECHO = {
      dex = 358, name = "Chimecho", types = { "PSYCHIC" },
      baseStats = { hp = 75, attack = 50, defense = 80, speed = 65, specialA = 95, specialD = 90 },
      catchRate = 45, baseExp = 159, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.6, weightKg = 1,
      dexEntry = { kind = "Wind Chime Pokémon",
        text = "Chimecho makes its cries echo inside its hollow body. When this Pokémon becomes enraged, its cries result in ultrasonic waves that have the power to knock foes flying." },
    },

    ABSOL = {
      dex = 359, name = "Absol", types = { "DARK" },
      baseStats = { hp = 65, attack = 130, defense = 60, speed = 75, specialA = 75, specialD = 60 },
      catchRate = 30, baseExp = 163, growthRate = "MEDIUM_SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.2, weightKg = 47,
      dexEntry = { kind = "Disaster Pokémon",
        text = "Swift as the wind, Absol races through fields and mountains. Its curved, bow-like horn is acutely sensitive to the warning signs of natural disasters." },
    },

    WYNAUT = {
      dex = 360, name = "Wynaut", types = { "PSYCHIC" },
      baseStats = { hp = 95, attack = 23, defense = 48, speed = 23, specialA = 23, specialD = 48 },
      catchRate = 125, baseExp = 52, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "WOBBUFFET", level = 15 },
      },
      heightM = 0.6, weightKg = 14,
      dexEntry = { kind = "Bright Pokémon",
        text = "It tends to move in a pack. Individuals squash against one another to toughen their spirits." },
    },

    SNORUNT = {
      dex = 361, name = "Snorunt", types = { "ICE" },
      baseStats = { hp = 50, attack = 50, defense = 50, speed = 50, specialA = 50, specialD = 50 },
      catchRate = 190, baseExp = 60, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GLALIE", level = 42 },
        { method = "ITEMFEMALE", species = "FROSLASS" },
      },
      heightM = 0.7, weightKg = 16.8,
      dexEntry = { kind = "Snow Hat Pokémon",
        text = "It’s said that if they are seen at midnight, they’ll cause heavy snow. They eat snow and ice to survive." },
    },

    GLALIE = {
      dex = 362, name = "Glalie", types = { "ICE" },
      baseStats = { hp = 80, attack = 80, defense = 80, speed = 80, specialA = 80, specialD = 80 },
      catchRate = 75, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 256.5,
      dexEntry = { kind = "Face Pokémon",
        text = "It has a body of ice that won’t melt, even with fire. It can instantly freeze moisture in the atmosphere." },
    },

    SPHEAL = {
      dex = 363, name = "Spheal", types = { "ICE", "WATER" },
      baseStats = { hp = 70, attack = 40, defense = 50, speed = 25, specialA = 55, specialD = 50 },
      catchRate = 255, baseExp = 58, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SEALEO", level = 32 },
      },
      heightM = 0.8, weightKg = 39.5,
      dexEntry = { kind = "Clap Pokémon",
        text = "This Pokémon’s body is covered in blubber and impressively round. It’s faster for Spheal to roll around than walk." },
    },

    SEALEO = {
      dex = 364, name = "Sealeo", types = { "ICE", "WATER" },
      baseStats = { hp = 90, attack = 60, defense = 70, speed = 45, specialA = 75, specialD = 70 },
      catchRate = 120, baseExp = 144, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "WALREIN", level = 44 },
      },
      heightM = 1.1, weightKg = 87.6,
      dexEntry = { kind = "Ball Roll Pokémon",
        text = "Sealeo live on top of drift ice. They go swimming when they’re on the hunt, seeking out their prey by scent." },
    },

    WALREIN = {
      dex = 365, name = "Walrein", types = { "ICE", "WATER" },
      baseStats = { hp = 110, attack = 80, defense = 90, speed = 65, specialA = 95, specialD = 90 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 150.6,
      dexEntry = { kind = "Ice Break Pokémon",
        text = "Walrein form herds of 20 to 30 individuals. When a threat appears, the herd’s leader will protect the group with its life." },
    },

    CLAMPERL = {
      dex = 366, name = "Clamperl", types = { "WATER" },
      baseStats = { hp = 35, attack = 64, defense = 85, speed = 32, specialA = 74, specialD = 55 },
      catchRate = 255, baseExp = 69, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "HUNTAIL" },
        { method = "CABLELINKITEM", species = "GOREBYSS" },
      },
      heightM = 0.4, weightKg = 52.5,
      dexEntry = { kind = "Bivalve Pokémon",
        text = "Despite its appearance, it’s carnivorous. It clamps down on its prey with both sides of its shell and doesn’t let go until they stop moving." },
    },

    HUNTAIL = {
      dex = 367, name = "Huntail", types = { "WATER" },
      baseStats = { hp = 55, attack = 104, defense = 105, speed = 52, specialA = 94, specialD = 75 },
      catchRate = 60, baseExp = 170, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 27,
      dexEntry = { kind = "Deep Sea Pokémon",
        text = "It’s not the strongest swimmer. It wags its tail to lure in its prey and then gulps them down as soon as they get close." },
    },

    GOREBYSS = {
      dex = 368, name = "Gorebyss", types = { "WATER" },
      baseStats = { hp = 55, attack = 84, defense = 105, speed = 52, specialA = 114, specialD = 75 },
      catchRate = 60, baseExp = 170, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 22.6,
      dexEntry = { kind = "South Sea Pokémon",
        text = "The color of its body changes with the water temperature. The coloration of Gorebyss in Alola is almost blindingly vivid." },
    },

    RELICANTH = {
      dex = 369, name = "Relicanth", types = { "WATER", "ROCK" },
      baseStats = { hp = 100, attack = 90, defense = 130, speed = 55, specialA = 45, specialD = 65 },
      catchRate = 25, baseExp = 170, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 23.4,
      dexEntry = { kind = "Longevity Pokémon",
        text = "Rock-hard scales and oil-filled swim bladders allow this Pokémon to survive the intense water pressure of the deep sea." },
    },

    LUVDISC = {
      dex = 370, name = "Luvdisc", types = { "WATER" },
      baseStats = { hp = 43, attack = 30, defense = 55, speed = 97, specialA = 40, specialD = 65 },
      catchRate = 225, baseExp = 116, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.6, weightKg = 8.7,
      dexEntry = { kind = "Rendezvous Pokémon",
        text = "There was an era when it was overfished due to the rumor that having one of its heart-shaped scales would enable you to find a sweetheart." },
    },

    BAGON = {
      dex = 371, name = "Bagon", types = { "DRAGON" },
      baseStats = { hp = 45, attack = 75, defense = 60, speed = 50, specialA = 40, specialD = 30 },
      catchRate = 45, baseExp = 60, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "SHELGON", level = 30 },
      },
      heightM = 0.6, weightKg = 42.1,
      dexEntry = { kind = "Rock Head Pokémon",
        text = "Bagon jumps off cliffs every day, trying to grow stronger so that someday it will be able to fly." },
    },

    SHELGON = {
      dex = 372, name = "Shelgon", types = { "DRAGON" },
      baseStats = { hp = 65, attack = 95, defense = 100, speed = 50, specialA = 60, specialD = 50 },
      catchRate = 45, baseExp = 147, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "SALAMENCE", level = 50 },
      },
      heightM = 1.1, weightKg = 110.5,
      dexEntry = { kind = "Endurance Pokémon",
        text = "This Pokémon has covered its body in a hard shell that has the same composition as bone. Shelgon stores energy for evolution." },
    },

    SALAMENCE = {
      dex = 373, name = "Salamence", types = { "DRAGON", "FLYING" },
      baseStats = { hp = 95, attack = 135, defense = 80, speed = 100, specialA = 110, specialD = 80 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.5, weightKg = 102.6,
      dexEntry = { kind = "Dragon Pokémon",
        text = "Salamence is an unusual Pokémon in that it was able to evolve a body with wings just by constantly wishing to be able to fly." },
    },

    BELDUM = {
      dex = 374, name = "Beldum", types = { "STEEL", "PSYCHIC" },
      baseStats = { hp = 40, attack = 55, defense = 80, speed = 30, specialA = 35, specialD = 60 },
      catchRate = 3, baseExp = 60, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "METANG", level = 20 },
      },
      heightM = 0.6, weightKg = 95.2,
      dexEntry = { kind = "Iron Ball Pokémon",
        text = "From its rear, Beldum emits a magnetic force that rapidly pulls opponents in. They get skewered on Beldum’s sharp claws." },
    },

    METANG = {
      dex = 375, name = "Metang", types = { "STEEL", "PSYCHIC" },
      baseStats = { hp = 60, attack = 75, defense = 100, speed = 50, specialA = 55, specialD = 80 },
      catchRate = 3, baseExp = 147, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "METAGROSS", level = 45 },
      },
      heightM = 1.2, weightKg = 202.5,
      dexEntry = { kind = "Iron Claw Pokémon",
        text = "Two Beldum have become stuck together via their own magnetic forces. With two brains, the resulting Metang has doubled psychic powers." },
    },

    METAGROSS = {
      dex = 376, name = "Metagross", types = { "STEEL", "PSYCHIC" },
      baseStats = { hp = 80, attack = 135, defense = 130, speed = 70, specialA = 95, specialD = 90 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.6, weightKg = 550,
      dexEntry = { kind = "Iron Leg Pokémon",
        text = "Because the magnetic powers of these Pokémon get stronger in freezing temperatures, Metagross living on snowy mountains are full of energy." },
    },

    REGIROCK = {
      dex = 377, name = "Regirock", types = { "ROCK" },
      baseStats = { hp = 80, attack = 100, defense = 200, speed = 50, specialA = 50, specialD = 100 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.7, weightKg = 230,
      dexEntry = { kind = "Rock Peak Pokémon",
        text = "Every bit of Regirock’s body is made of stone. As parts of its body erode, this Pokémon sticks rocks to itself to repair what’s been lost." },
    },

    REGICE = {
      dex = 378, name = "Regice", types = { "ICE" },
      baseStats = { hp = 80, attack = 50, defense = 100, speed = 50, specialA = 100, specialD = 200 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.8, weightKg = 175,
      dexEntry = { kind = "Iceberg Pokémon",
        text = "With cold air that can reach temperatures as low as −328 degrees Fahrenheit, Regice instantly freezes any creature that approaches it." },
    },

    REGISTEEL = {
      dex = 379, name = "Registeel", types = { "STEEL" },
      baseStats = { hp = 80, attack = 75, defense = 150, speed = 50, specialA = 75, specialD = 150 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.9, weightKg = 205,
      dexEntry = { kind = "Iron Pokémon",
        text = "Registeel’s body is made of a strange material that is flexible enough to stretch and shrink but also more durable than any metal." },
    },

    LATIAS = {
      dex = 380, name = "Latias", types = { "DRAGON", "PSYCHIC" },
      baseStats = { hp = 80, attack = 80, defense = 90, speed = 110, specialA = 110, specialD = 130 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 90,
      evolutions = {},
      heightM = 1.4, weightKg = 40,
      dexEntry = { kind = "Eon Pokémon",
        text = "Latias is highly sensitive to the emotions of people. If it senses any hostility, this Pokémon ruffles the feathers all over its body and cries shrilly to intimidate the foe." },
    },

    LATIOS = {
      dex = 381, name = "Latios", types = { "DRAGON", "PSYCHIC" },
      baseStats = { hp = 80, attack = 90, defense = 80, speed = 110, specialA = 130, specialD = 110 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 90,
      evolutions = {},
      heightM = 2, weightKg = 60,
      dexEntry = { kind = "Eon Pokémon",
        text = "Latios has the ability to make others see an image of what it has seen or imagines in its head. This Pokémon is intelligent and understands human speech." },
    },

    KYOGRE = {
      dex = 382, name = "Kyogre", types = { "WATER" },
      baseStats = { hp = 100, attack = 100, defense = 90, speed = 90, specialA = 150, specialD = 140 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 4.5, weightKg = 352,
      dexEntry = { kind = "Sea Basin Pokémon",
        text = "Through Primal Reversion and with nature’s full power, it will take back its true form. It can summon storms that cause the sea levels to rise." },
    },

    GROUDON = {
      dex = 383, name = "Groudon", types = { "GROUND" },
      baseStats = { hp = 100, attack = 150, defense = 140, speed = 90, specialA = 100, specialD = 90 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.5, weightKg = 950,
      dexEntry = { kind = "Continent Pokémon",
        text = "Groudon is said to be the personification of the land itself. Legends tell of its many clashes against Kyogre, as each sought to gain the power of nature." },
    },

    RAYQUAZA = {
      dex = 384, name = "Rayquaza", types = { "DRAGON", "FLYING" },
      baseStats = { hp = 105, attack = 150, defense = 90, speed = 95, specialA = 150, specialD = 90 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 7, weightKg = 206.5,
      dexEntry = { kind = "Sky High Pokémon",
        text = "Rayquaza is said to have lived for hundreds of millions of years. Legends remain of how it put to rest the clash between Kyogre and Groudon." },
    },

    JIRACHI = {
      dex = 385, name = "Jirachi", types = { "STEEL", "PSYCHIC" },
      baseStats = { hp = 100, attack = 100, defense = 100, speed = 100, specialA = 100, specialD = 100 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 100,
      evolutions = {},
      heightM = 0.3, weightKg = 1.1,
      dexEntry = { kind = "Wish Pokémon",
        text = "A legend states that Jirachi will make true any wish that is written on notes attached to its head when it awakens. If this Pokémon senses danger, it will fight without awakening." },
    },

    DEOXYS = {
      dex = 386, name = "Deoxys", types = { "PSYCHIC" },
      baseStats = { hp = 50, attack = 150, defense = 50, speed = 150, specialA = 150, specialD = 50 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.7, weightKg = 60.8,
      dexEntry = { kind = "DNA Pokémon",
        text = "The DNA of a space virus underwent a sudden mutation upon exposure to a laser beam and resulted in Deoxys. The crystalline organ on this Pokémon’s chest appears to be its brain." },
    },

    TURTWIG = {
      dex = 387, name = "Turtwig", types = { "GRASS" },
      baseStats = { hp = 55, attack = 68, defense = 64, speed = 31, specialA = 45, specialD = 55 },
      catchRate = 45, baseExp = 64, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GROTLE", level = 18 },
      },
      heightM = 0.4, weightKg = 10.2,
      dexEntry = { kind = "Tiny Leaf Pokémon",
        text = "Photosynthesis occurs across its body under the sun. The shell on its back is actually hardened soil." },
    },

    GROTLE = {
      dex = 388, name = "Grotle", types = { "GRASS" },
      baseStats = { hp = 75, attack = 89, defense = 85, speed = 36, specialA = 55, specialD = 65 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TORTERRA", level = 32 },
      },
      heightM = 1.1, weightKg = 97,
      dexEntry = { kind = "Grove Pokémon",
        text = "It lives along water in forests. In the daytime, it leaves the forest to sunbathe its treed shell." },
    },

    TORTERRA = {
      dex = 389, name = "Torterra", types = { "GRASS", "GROUND" },
      baseStats = { hp = 95, attack = 109, defense = 105, speed = 56, specialA = 75, specialD = 85 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.2, weightKg = 310,
      dexEntry = { kind = "Continent Pokémon",
        text = "Ancient people imagined that beneath the ground, a gigantic Torterra dwelled." },
    },

    CHIMCHAR = {
      dex = 390, name = "Chimchar", types = { "FIRE" },
      baseStats = { hp = 44, attack = 58, defense = 44, speed = 61, specialA = 58, specialD = 44 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MONFERNO", level = 14 },
      },
      heightM = 0.5, weightKg = 6.2,
      dexEntry = { kind = "Chimp Pokémon",
        text = "Its fiery rear end is fueled by gas made in its belly. Even rain can’t extinguish the fire." },
    },

    MONFERNO = {
      dex = 391, name = "Monferno", types = { "FIRE", "FIGHTING" },
      baseStats = { hp = 64, attack = 78, defense = 52, speed = 81, specialA = 78, specialD = 52 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "INFERNAPE", level = 36 },
      },
      heightM = 0.9, weightKg = 22,
      dexEntry = { kind = "Playful Pokémon",
        text = "It skillfully controls the intensity of the fire on its tail to keep its foes at an ideal distance." },
    },

    INFERNAPE = {
      dex = 392, name = "Infernape", types = { "FIRE", "FIGHTING" },
      baseStats = { hp = 76, attack = 104, defense = 71, speed = 108, specialA = 104, specialD = 71 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 55,
      dexEntry = { kind = "Flame Pokémon",
        text = "Its crown of fire is indicative of its fiery nature. It is beaten by none in terms of quickness." },
    },

    PIPLUP = {
      dex = 393, name = "Piplup", types = { "WATER" },
      baseStats = { hp = 53, attack = 51, defense = 53, speed = 40, specialA = 61, specialD = 56 },
      catchRate = 45, baseExp = 63, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PRINPLUP", level = 16 },
      },
      heightM = 0.4, weightKg = 5.2,
      dexEntry = { kind = "Penguin Pokémon",
        text = "It doesn’t like to be taken care of. It’s difficult to bond with since it won’t listen to its Trainer." },
    },

    PRINPLUP = {
      dex = 394, name = "Prinplup", types = { "WATER" },
      baseStats = { hp = 64, attack = 66, defense = 68, speed = 50, specialA = 81, specialD = 76 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "EMPOLEON", level = 36 },
      },
      heightM = 0.8, weightKg = 23,
      dexEntry = { kind = "Penguin Pokémon",
        text = "It lives alone, away from others. Apparently, every one of them believes it is the most important." },
    },

    EMPOLEON = {
      dex = 395, name = "Empoleon", types = { "WATER", "STEEL" },
      baseStats = { hp = 84, attack = 86, defense = 88, speed = 60, specialA = 111, specialD = 101 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 84.5,
      dexEntry = { kind = "Emperor Pokémon",
        text = "It swims as fast as a jet boat. The edges of its wings are sharp and can slice apart drifting ice." },
    },

    STARLY = {
      dex = 396, name = "Starly", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 40, attack = 55, defense = 30, speed = 60, specialA = 30, specialD = 30 },
      catchRate = 255, baseExp = 49, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "STARAVIA", level = 14 },
      },
      heightM = 0.3, weightKg = 2,
      dexEntry = { kind = "Starling Pokémon",
        text = "They flock in great numbers. Though small, they flap their wings with great power." },
    },

    STARAVIA = {
      dex = 397, name = "Staravia", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 55, attack = 75, defense = 50, speed = 80, specialA = 40, specialD = 40 },
      catchRate = 120, baseExp = 119, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "STARAPTOR", level = 34 },
      },
      heightM = 0.6, weightKg = 15.5,
      dexEntry = { kind = "Starling Pokémon",
        text = "They maintain huge flocks, although fierce scuffles break out between various flocks." },
    },

    STARAPTOR = {
      dex = 398, name = "Staraptor", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 85, attack = 120, defense = 70, speed = 100, specialA = 50, specialD = 60 },
      catchRate = 45, baseExp = 243, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 24.9,
      dexEntry = { kind = "Predator Pokémon",
        text = "The muscles in its wings and legs are strong. It can easily fly while gripping a small Pokémon." },
    },

    BIDOOF = {
      dex = 399, name = "Bidoof", types = { "NORMAL" },
      baseStats = { hp = 59, attack = 45, defense = 40, speed = 31, specialA = 35, specialD = 40 },
      catchRate = 255, baseExp = 50, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BIBAREL", level = 15 },
      },
      heightM = 0.5, weightKg = 20,
      dexEntry = { kind = "Plump Mouse Pokémon",
        text = "With nerves of steel, nothing can perturb it. It is more agile and active than it appears." },
    },

    BIBAREL = {
      dex = 400, name = "Bibarel", types = { "NORMAL", "WATER" },
      baseStats = { hp = 79, attack = 85, defense = 60, speed = 71, specialA = 55, specialD = 60 },
      catchRate = 127, baseExp = 144, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 31.5,
      dexEntry = { kind = "Beaver Pokémon",
        text = "It busily makes its nest with stacks of branches and roots it has cut up with its sharp incisors." },
    },

    KRICKETOT = {
      dex = 401, name = "Kricketot", types = { "BUG" },
      baseStats = { hp = 37, attack = 25, defense = 41, speed = 25, specialA = 25, specialD = 41 },
      catchRate = 255, baseExp = 39, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "KRICKETUNE", level = 10 },
      },
      heightM = 0.3, weightKg = 2.2,
      dexEntry = { kind = "Cricket Pokémon",
        text = "It chats with others using the sounds of its colliding antennae. These sounds are fall hallmarks." },
    },

    KRICKETUNE = {
      dex = 402, name = "Kricketune", types = { "BUG" },
      baseStats = { hp = 77, attack = 85, defense = 51, speed = 65, specialA = 55, specialD = 51 },
      catchRate = 45, baseExp = 134, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 25.5,
      dexEntry = { kind = "Cricket Pokémon",
        text = "It crosses its knifelike arms in front of its chest when it cries. It can compose melodies ad lib." },
    },

    SHINX = {
      dex = 403, name = "Shinx", types = { "ELECTRIC" },
      baseStats = { hp = 45, attack = 65, defense = 34, speed = 45, specialA = 40, specialD = 34 },
      catchRate = 235, baseExp = 53, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "LUXIO", level = 15 },
      },
      heightM = 0.5, weightKg = 9.5,
      dexEntry = { kind = "Flash Pokémon",
        text = "This Pokémon generates electricity by contracting its muscles. Excited trembling is a sign that Shinx is generating a tremendous amount of electricity." },
    },

    LUXIO = {
      dex = 404, name = "Luxio", types = { "ELECTRIC" },
      baseStats = { hp = 60, attack = 85, defense = 49, speed = 60, specialA = 60, specialD = 49 },
      catchRate = 120, baseExp = 127, growthRate = "MEDIUM_SLOW", happiness = 100,
      evolutions = {
        { method = "LEVEL", species = "LUXRAY", level = 30 },
      },
      heightM = 0.9, weightKg = 30.5,
      dexEntry = { kind = "Spark Pokémon",
        text = "By joining its tail with that of another Luxio, this Pokémon can receive some of the other Luxio’s electricity and power up its own electric blasts." },
    },

    LUXRAY = {
      dex = 405, name = "Luxray", types = { "ELECTRIC" },
      baseStats = { hp = 80, attack = 120, defense = 79, speed = 70, specialA = 95, specialD = 79 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 42,
      dexEntry = { kind = "Gleam Eyes Pokémon",
        text = "Luxray can see through solid objects. It will instantly spot prey trying to hide behind walls, even if the walls are thick." },
    },

    BUDEW = {
      dex = 406, name = "Budew", types = { "GRASS", "POISON" },
      baseStats = { hp = 40, attack = 30, defense = 35, speed = 55, specialA = 50, specialD = 70 },
      catchRate = 255, baseExp = 56, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "HAPPINESSDAY", species = "ROSELIA" },
      },
      heightM = 0.2, weightKg = 1.2,
      dexEntry = { kind = "Bud Pokémon",
        text = "The pollen it releases contains poison. If this Pokémon is raised on clean water, the poison’s toxicity is increased." },
    },

    ROSERADE = {
      dex = 407, name = "Roserade", types = { "GRASS", "POISON" },
      baseStats = { hp = 60, attack = 70, defense = 65, speed = 90, specialA = 125, specialD = 105 },
      catchRate = 75, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 14.5,
      dexEntry = { kind = "Bouquet Pokémon",
        text = "After captivating opponents with its sweet scent, it lashes them with its thorny whips." },
    },

    CRANIDOS = {
      dex = 408, name = "Cranidos", types = { "ROCK" },
      baseStats = { hp = 67, attack = 125, defense = 40, speed = 58, specialA = 30, specialD = 30 },
      catchRate = 45, baseExp = 70, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "RAMPARDOS", level = 30 },
      },
      heightM = 0.9, weightKg = 31.5,
      dexEntry = { kind = "Head Butt Pokémon",
        text = "A primeval Pokémon, it possesses a hard and sturdy skull, lacking any intelligence within." },
    },

    RAMPARDOS = {
      dex = 409, name = "Rampardos", types = { "ROCK" },
      baseStats = { hp = 97, attack = 165, defense = 60, speed = 58, specialA = 65, specialD = 50 },
      catchRate = 45, baseExp = 173, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 102.5,
      dexEntry = { kind = "Head Butt Pokémon",
        text = "In ancient times, people would dig up fossils of this Pokémon and use its skull, which is harder than steel, to make helmets." },
    },

    SHIELDON = {
      dex = 410, name = "Shieldon", types = { "ROCK", "STEEL" },
      baseStats = { hp = 30, attack = 42, defense = 118, speed = 30, specialA = 42, specialD = 88 },
      catchRate = 45, baseExp = 70, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BASTIODON", level = 30 },
      },
      heightM = 0.5, weightKg = 57,
      dexEntry = { kind = "Shield Pokémon",
        text = "A mild-mannered, herbivorous Pokémon, it used its face to dig up tree roots to eat. The skin on its face was plenty tough." },
    },

    BASTIODON = {
      dex = 411, name = "Bastiodon", types = { "ROCK", "STEEL" },
      baseStats = { hp = 60, attack = 52, defense = 168, speed = 30, specialA = 47, specialD = 138 },
      catchRate = 45, baseExp = 173, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 149.5,
      dexEntry = { kind = "Shield Pokémon",
        text = "The bones of its face are huge and hard, so they were mistaken for its spine until after this Pokémon was successfully restored." },
    },

    BURMY = {
      dex = 412, name = "Burmy", types = { "BUG" },
      baseStats = { hp = 40, attack = 29, defense = 45, speed = 36, specialA = 29, specialD = 45 },
      catchRate = 120, baseExp = 45, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVELFEMALE", species = "WORMADAM" },
        { method = "LEVELMALE", species = "MOTHIM" },
      },
      heightM = 0.2, weightKg = 3.4,
      dexEntry = { kind = "Bagworm Pokémon",
        text = "To shelter itself from cold, wintry winds, it covers itself with a cloak made of twigs and leaves." },
    },

    WORMADAM = {
      dex = 413, name = "Wormadam", types = { "BUG", "GRASS" },
      baseStats = { hp = 60, attack = 59, defense = 85, speed = 36, specialA = 79, specialD = 105 },
      catchRate = 45, baseExp = 148, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.5, weightKg = 6.5,
      dexEntry = { kind = "Bagworm Pokémon",
        text = "Its appearance changes depending on where it evolved. The materials on hand become a part of its body." },
    },

    MOTHIM = {
      dex = 414, name = "Mothim", types = { "BUG", "FLYING" },
      baseStats = { hp = 70, attack = 94, defense = 50, speed = 66, specialA = 94, specialD = 50 },
      catchRate = 45, baseExp = 148, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 23.3,
      dexEntry = { kind = "Moth Pokémon",
        text = "It loves the honey of flowers and steals honey collected by Combee." },
    },

    COMBEE = {
      dex = 415, name = "Combee", types = { "BUG", "FLYING" },
      baseStats = { hp = 30, attack = 30, defense = 42, speed = 70, specialA = 30, specialD = 42 },
      catchRate = 120, baseExp = 49, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVELFEMALE", species = "VESPIQUEN" },
      },
      heightM = 0.3, weightKg = 5.5,
      dexEntry = { kind = "Tiny Bee Pokémon",
        text = "The members of the trio spend all their time together. Each one has a slightly different taste in nectar." },
    },

    VESPIQUEN = {
      dex = 416, name = "Vespiquen", types = { "BUG", "FLYING" },
      baseStats = { hp = 70, attack = 80, defense = 102, speed = 40, specialA = 80, specialD = 102 },
      catchRate = 45, baseExp = 166, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 38.5,
      dexEntry = { kind = "Beehive Pokémon",
        text = "It skillfully commands its grubs in battles with its enemies. The grubs are willing to risk their lives to defend Vespiquen." },
    },

    PACHIRISU = {
      dex = 417, name = "Pachirisu", types = { "ELECTRIC" },
      baseStats = { hp = 60, attack = 45, defense = 70, speed = 95, specialA = 45, specialD = 90 },
      catchRate = 200, baseExp = 142, growthRate = "MEDIUM_FAST", happiness = 100,
      evolutions = {},
      heightM = 0.4, weightKg = 3.9,
      dexEntry = { kind = "EleSquirrel Pokémon",
        text = "It makes fur balls that crackle with static electricity. It stores them with berries in tree holes." },
    },

    BUIZEL = {
      dex = 418, name = "Buizel", types = { "WATER" },
      baseStats = { hp = 55, attack = 65, defense = 35, speed = 85, specialA = 60, specialD = 30 },
      catchRate = 190, baseExp = 66, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FLOATZEL", level = 26 },
      },
      heightM = 0.7, weightKg = 29.5,
      dexEntry = { kind = "Sea Weasel Pokémon",
        text = "It swims by rotating its two tails like a screw. When it dives, its flotation sac collapses." },
    },

    FLOATZEL = {
      dex = 419, name = "Floatzel", types = { "WATER" },
      baseStats = { hp = 85, attack = 105, defense = 55, speed = 115, specialA = 85, specialD = 50 },
      catchRate = 75, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 33.5,
      dexEntry = { kind = "Sea Weasel Pokémon",
        text = "It floats using its well-developed flotation sac. It assists in the rescues of drowning people." },
    },

    CHERUBI = {
      dex = 420, name = "Cherubi", types = { "GRASS" },
      baseStats = { hp = 45, attack = 35, defense = 45, speed = 35, specialA = 62, specialD = 53 },
      catchRate = 190, baseExp = 55, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CHERRIM", level = 25 },
      },
      heightM = 0.4, weightKg = 3.3,
      dexEntry = { kind = "Cherry Pokémon",
        text = "It nimbly dashes about to avoid getting pecked by bird Pokémon that would love to make off with its small, nutrient-rich storage ball." },
    },

    CHERRIM = {
      dex = 421, name = "Cherrim", types = { "GRASS" },
      baseStats = { hp = 70, attack = 60, defense = 70, speed = 85, specialA = 87, specialD = 78 },
      catchRate = 75, baseExp = 158, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.5, weightKg = 9.3,
      dexEntry = { kind = "Blossom Pokémon",
        text = "As a bud, it barely moves. It sits still, placidly waiting for sunlight to appear." },
    },

    SHELLOS = {
      dex = 422, name = "Shellos", types = { "WATER" },
      baseStats = { hp = 76, attack = 48, defense = 48, speed = 34, specialA = 57, specialD = 62 },
      catchRate = 190, baseExp = 65, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GASTRODON", level = 30 },
      },
      heightM = 0.3, weightKg = 6.3,
      dexEntry = { kind = "Sea Slug Pokémon",
        text = "This Pokémon’s habitat shapes its physique. According to some theories, life in warm ocean waters causes this variation to develop." },
    },

    GASTRODON = {
      dex = 423, name = "Gastrodon", types = { "WATER", "GROUND" },
      baseStats = { hp = 111, attack = 83, defense = 68, speed = 39, specialA = 92, specialD = 82 },
      catchRate = 75, baseExp = 166, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 29.9,
      dexEntry = { kind = "Sea Slug Pokémon",
        text = "Its search for food sometimes leads it onto land, where it leaves behind a sticky trail of slime as it passes through." },
    },

    AMBIPOM = {
      dex = 424, name = "Ambipom", types = { "NORMAL" },
      baseStats = { hp = 75, attack = 100, defense = 66, speed = 115, specialA = 60, specialD = 66 },
      catchRate = 45, baseExp = 169, growthRate = "FAST", happiness = 100,
      evolutions = {},
      heightM = 1.2, weightKg = 20.3,
      dexEntry = { kind = "Long Tail Pokémon",
        text = "In their search for comfortable trees, they get into territorial disputes with groups of Passimian. They win about half the time." },
    },

    DRIFLOON = {
      dex = 425, name = "Drifloon", types = { "GHOST", "FLYING" },
      baseStats = { hp = 90, attack = 50, defense = 34, speed = 70, specialA = 60, specialD = 44 },
      catchRate = 125, baseExp = 70, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DRIFBLIM", level = 28 },
      },
      heightM = 0.4, weightKg = 1.2,
      dexEntry = { kind = "Balloon Pokémon",
        text = "Perhaps seeking company, it approaches children. However, it often quickly runs away again when the children play too roughly with it." },
    },

    DRIFBLIM = {
      dex = 426, name = "Drifblim", types = { "GHOST", "FLYING" },
      baseStats = { hp = 150, attack = 80, defense = 44, speed = 80, specialA = 90, specialD = 54 },
      catchRate = 60, baseExp = 174, growthRate = "FLUCTUATING", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 15,
      dexEntry = { kind = "Blimp Pokémon",
        text = "Some say this Pokémon is a collection of souls burdened with regrets, silently drifting through the dusk." },
    },

    BUNEARY = {
      dex = 427, name = "Buneary", types = { "NORMAL" },
      baseStats = { hp = 55, attack = 66, defense = 44, speed = 85, specialA = 44, specialD = 56 },
      catchRate = 190, baseExp = 70, growthRate = "MEDIUM_FAST", happiness = 0,
      evolutions = {
        { method = "HAPPINESS", species = "LOPUNNY" },
      },
      heightM = 0.4, weightKg = 5.5,
      dexEntry = { kind = "Rabbit Pokémon",
        text = "If both of Buneary’s ears are rolled up, something is wrong with its body or mind. It’s a sure sign the Pokémon is in need of care." },
    },

    LOPUNNY = {
      dex = 428, name = "Lopunny", types = { "NORMAL" },
      baseStats = { hp = 65, attack = 76, defense = 84, speed = 105, specialA = 54, specialD = 96 },
      catchRate = 60, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 140,
      evolutions = {},
      heightM = 1.2, weightKg = 33.3,
      dexEntry = { kind = "Rabbit Pokémon",
        text = "Lopunny is constantly monitoring its surroundings. If danger approaches, this Pokémon responds with superdestructive kicks." },
    },

    MISMAGIUS = {
      dex = 429, name = "Mismagius", types = { "GHOST" },
      baseStats = { hp = 60, attack = 60, defense = 60, speed = 105, specialA = 105, specialD = 105 },
      catchRate = 45, baseExp = 173, growthRate = "FAST", happiness = 35,
      evolutions = {},
      heightM = 0.9, weightKg = 4.4,
      dexEntry = { kind = "Magical Pokémon",
        text = "Feared for its wrath and the curses it spreads, this Pokémon will also, on a whim, cast spells that help people." },
    },

    HONCHKROW = {
      dex = 430, name = "Honchkrow", types = { "DARK", "FLYING" },
      baseStats = { hp = 100, attack = 125, defense = 52, speed = 71, specialA = 105, specialD = 52 },
      catchRate = 30, baseExp = 177, growthRate = "MEDIUM_SLOW", happiness = 35,
      evolutions = {},
      heightM = 0.9, weightKg = 27.3,
      dexEntry = { kind = "Big Boss Pokémon",
        text = "It will absolutely not forgive failure from or betrayal by its goons. It has no choice in this if it wants to maintain the order of the flock." },
    },

    GLAMEOW = {
      dex = 431, name = "Glameow", types = { "NORMAL" },
      baseStats = { hp = 49, attack = 55, defense = 42, speed = 85, specialA = 42, specialD = 37 },
      catchRate = 190, baseExp = 62, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PURUGLY", level = 38 },
      },
      heightM = 0.5, weightKg = 3.9,
      dexEntry = { kind = "Catty Pokémon",
        text = "It claws if displeased and purrs when affectionate. Its fickleness is very popular among some." },
    },

    PURUGLY = {
      dex = 432, name = "Purugly", types = { "NORMAL" },
      baseStats = { hp = 71, attack = 82, defense = 64, speed = 112, specialA = 64, specialD = 59 },
      catchRate = 75, baseExp = 158, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 43.8,
      dexEntry = { kind = "Tiger Cat Pokémon",
        text = "It would claim another Pokémon’s nest as its own if it finds a nest sufficiently comfortable." },
    },

    CHINGLING = {
      dex = 433, name = "Chingling", types = { "PSYCHIC" },
      baseStats = { hp = 45, attack = 30, defense = 50, speed = 45, specialA = 65, specialD = 50 },
      catchRate = 120, baseExp = 57, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "HAPPINESSNIGHT", species = "CHIMECHO" },
      },
      heightM = 0.2, weightKg = 0.6,
      dexEntry = { kind = "Bell Pokémon",
        text = "Each time it hops, it makes a ringing sound. It deafens foes by emitting high-frequency cries." },
    },

    STUNKY = {
      dex = 434, name = "Stunky", types = { "POISON", "DARK" },
      baseStats = { hp = 63, attack = 63, defense = 47, speed = 74, specialA = 41, specialD = 41 },
      catchRate = 225, baseExp = 66, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SKUNTANK", level = 34 },
      },
      heightM = 0.4, weightKg = 19.2,
      dexEntry = { kind = "Skunk Pokémon",
        text = "From its rear, it sprays a foul-smelling liquid at opponents. It aims for their faces, and it can hit them from over 16 feet away." },
    },

    SKUNTANK = {
      dex = 435, name = "Skuntank", types = { "POISON", "DARK" },
      baseStats = { hp = 103, attack = 93, defense = 67, speed = 84, specialA = 71, specialD = 61 },
      catchRate = 60, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 38,
      dexEntry = { kind = "Skunk Pokémon",
        text = "In its belly, it reserves stinky fluid that it shoots from its tail during battle. As this Pokémon’s diet varies, so does the stench of its fluid." },
    },

    BRONZOR = {
      dex = 436, name = "Bronzor", types = { "STEEL", "PSYCHIC" },
      baseStats = { hp = 57, attack = 24, defense = 86, speed = 23, specialA = 24, specialD = 86 },
      catchRate = 255, baseExp = 60, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BRONZONG", level = 33 },
      },
      heightM = 0.5, weightKg = 60.5,
      dexEntry = { kind = "Bronze Pokémon",
        text = "It appears in ancient ruins. The pattern on its body doesn’t come from any culture in the Galar region, so it remains shrouded in mystery." },
    },

    BRONZONG = {
      dex = 437, name = "Bronzong", types = { "STEEL", "PSYCHIC" },
      baseStats = { hp = 67, attack = 89, defense = 116, speed = 33, specialA = 79, specialD = 116 },
      catchRate = 90, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 187,
      dexEntry = { kind = "Bronze Bell Pokémon",
        text = "Some believe it to be a deity that summons rain clouds. When angered, it lets out a warning cry that rings out like the tolling of a bell." },
    },

    BONSLY = {
      dex = 438, name = "Bonsly", types = { "ROCK" },
      baseStats = { hp = 50, attack = 80, defense = 95, speed = 10, specialA = 10, specialD = 45 },
      catchRate = 255, baseExp = 58, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HAS_MOVE", species = "SUDOWOODO", move = "MIMIC" },
      },
      heightM = 0.5, weightKg = 15,
      dexEntry = { kind = "Bonsai Pokémon",
        text = "It expels both sweat and tears from its eyes. The sweat is a little salty, while the tears have a slight bitterness." },
    },

    MIMEJR = {
      dex = 439, name = "Mime Jr.", types = { "PSYCHIC", "FAIRY" },
      baseStats = { hp = 20, attack = 25, defense = 45, speed = 60, specialA = 70, specialD = 90 },
      catchRate = 145, baseExp = 62, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HAS_MOVE", species = "MRMIME", move = "MIMIC" },
      },
      heightM = 0.6, weightKg = 13,
      dexEntry = { kind = "Mime Pokémon",
        text = "It mimics everyone it sees, but it puts extra effort into copying the graceful dance steps of Mr. Rime as practice." },
    },

    HAPPINY = {
      dex = 440, name = "Happiny", types = { "NORMAL" },
      baseStats = { hp = 100, attack = 5, defense = 5, speed = 30, specialA = 15, specialD = 65 },
      catchRate = 130, baseExp = 110, growthRate = "FAST", happiness = 140,
      evolutions = {
        { method = "DAYHOLDITEM", species = "CHANSEY" },
      },
      heightM = 0.6, weightKg = 24.4,
      dexEntry = { kind = "Playhouse Pokémon",
        text = "Mimicking Chansey, Happiny will place an egg- shaped stone in its belly pouch. Happiny will treasure this stone." },
    },

    CHATOT = {
      dex = 441, name = "Chatot", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 76, attack = 65, defense = 45, speed = 91, specialA = 92, specialD = 42 },
      catchRate = 30, baseExp = 144, growthRate = "MEDIUM_SLOW", happiness = 35,
      evolutions = {},
      heightM = 0.5, weightKg = 1.9,
      dexEntry = { kind = "Music Note Pokémon",
        text = "It mimics the cries of other Pokémon to trick them into thinking it’s one of them. This way they won’t attack it." },
    },

    SPIRITOMB = {
      dex = 442, name = "Spiritomb", types = { "GHOST", "DARK" },
      baseStats = { hp = 50, attack = 92, defense = 108, speed = 35, specialA = 92, specialD = 108 },
      catchRate = 100, baseExp = 170, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 108,
      dexEntry = { kind = "Forbidden Pokémon",
        text = "Exactly 108 spirits gathered to become this Pokémon. Apparently there are some ill-natured spirits in the mix." },
    },

    GIBLE = {
      dex = 443, name = "Gible", types = { "DRAGON", "GROUND" },
      baseStats = { hp = 58, attack = 70, defense = 45, speed = 42, specialA = 40, specialD = 45 },
      catchRate = 45, baseExp = 60, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GABITE", level = 24 },
      },
      heightM = 0.7, weightKg = 20.5,
      dexEntry = { kind = "Land Shark Pokémon",
        text = "Gible prefers to stay in narrow holes in the sides of caves heated by geothermal energy. This way, Gible can stay warm even during a blizzard." },
    },

    GABITE = {
      dex = 444, name = "Gabite", types = { "DRAGON", "GROUND" },
      baseStats = { hp = 68, attack = 90, defense = 65, speed = 82, specialA = 50, specialD = 55 },
      catchRate = 45, baseExp = 144, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GARCHOMP", level = 48 },
      },
      heightM = 1.4, weightKg = 56,
      dexEntry = { kind = "Cave Pokémon",
        text = "This Pokémon emits ultrasonic waves from a protrusion on either side of its head to probe pitch-dark caves." },
    },

    GARCHOMP = {
      dex = 445, name = "Garchomp", types = { "DRAGON", "GROUND" },
      baseStats = { hp = 108, attack = 130, defense = 95, speed = 102, specialA = 80, specialD = 85 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 95,
      dexEntry = { kind = "Mach Pokémon",
        text = "Garchomp makes its home in volcanic mountains. It flies through the sky as fast as a jet airplane, hunting down as much prey as it can." },
    },

    MUNCHLAX = {
      dex = 446, name = "Munchlax", types = { "NORMAL" },
      baseStats = { hp = 135, attack = 85, defense = 40, speed = 5, specialA = 40, specialD = 85 },
      catchRate = 50, baseExp = 78, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "HAPPINESS", species = "SNORLAX" },
      },
      heightM = 0.6, weightKg = 105,
      dexEntry = { kind = "Big Eater Pokémon",
        text = "Stuffing itself with vast amounts of food is its only concern. Whether the food is rotten or fresh, yummy or tasteless—it does not care." },
    },

    RIOLU = {
      dex = 447, name = "Riolu", types = { "FIGHTING" },
      baseStats = { hp = 40, attack = 70, defense = 40, speed = 60, specialA = 35, specialD = 40 },
      catchRate = 75, baseExp = 57, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "HAPPINESSDAY", species = "LUCARIO" },
      },
      heightM = 0.7, weightKg = 20.2,
      dexEntry = { kind = "Emanation Pokémon",
        text = "It’s exceedingly energetic, with enough stamina to keep running all through the night. Taking it for walks can be a challenging experience." },
    },

    LUCARIO = {
      dex = 448, name = "Lucario", types = { "FIGHTING", "STEEL" },
      baseStats = { hp = 70, attack = 110, defense = 70, speed = 90, specialA = 115, specialD = 70 },
      catchRate = 45, baseExp = 184, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 54,
      dexEntry = { kind = "Aura Pokémon",
        text = "It controls waves known as auras, which are powerful enough to pulverize huge rocks. It uses these waves to take down its prey." },
    },

    HIPPOPOTAS = {
      dex = 449, name = "Hippopotas", types = { "GROUND" },
      baseStats = { hp = 68, attack = 72, defense = 78, speed = 32, specialA = 38, specialD = 42 },
      catchRate = 140, baseExp = 66, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "HIPPOWDON", level = 34 },
      },
      heightM = 0.8, weightKg = 49.5,
      dexEntry = { kind = "Hippo Pokémon",
        text = "It moves through the sands with its mouth open, swallowing sand along with its prey. It gets rid of the sand by spouting it from its nose." },
    },

    HIPPOWDON = {
      dex = 450, name = "Hippowdon", types = { "GROUND" },
      baseStats = { hp = 108, attack = 112, defense = 118, speed = 47, specialA = 68, specialD = 72 },
      catchRate = 60, baseExp = 184, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 300,
      dexEntry = { kind = "Heavyweight Pokémon",
        text = "Stones can get stuck in the ports on their bodies. Dwebble help dislodge such stones, so Hippowdon look after these Pokémon." },
    },

    SKORUPI = {
      dex = 451, name = "Skorupi", types = { "POISON", "BUG" },
      baseStats = { hp = 40, attack = 50, defense = 90, speed = 65, specialA = 30, specialD = 55 },
      catchRate = 120, baseExp = 66, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DRAPION", level = 40 },
      },
      heightM = 0.8, weightKg = 12,
      dexEntry = { kind = "Scorpion Pokémon",
        text = "After burrowing into the sand, it waits patiently for prey to come near. This Pokémon and Sizzlipede share common descent." },
    },

    DRAPION = {
      dex = 452, name = "Drapion", types = { "POISON", "DARK" },
      baseStats = { hp = 70, attack = 90, defense = 110, speed = 95, specialA = 60, specialD = 75 },
      catchRate = 45, baseExp = 175, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 61.5,
      dexEntry = { kind = "Ogre Scorp Pokémon",
        text = "Its poison is potent, but it rarely sees use. This Pokémon prefers to use physical force instead, going on rampages with its car-crushing strength." },
    },

    CROAGUNK = {
      dex = 453, name = "Croagunk", types = { "POISON", "FIGHTING" },
      baseStats = { hp = 48, attack = 61, defense = 40, speed = 50, specialA = 61, specialD = 40 },
      catchRate = 140, baseExp = 60, growthRate = "MEDIUM_FAST", happiness = 100,
      evolutions = {
        { method = "LEVEL", species = "TOXICROAK", level = 37 },
      },
      heightM = 0.7, weightKg = 23,
      dexEntry = { kind = "Toxic Mouth Pokémon",
        text = "It makes frightening noises with its poison-filled cheek sacs. When opponents flinch, Croagunk hits them with a poison jab." },
    },

    TOXICROAK = {
      dex = 454, name = "Toxicroak", types = { "POISON", "FIGHTING" },
      baseStats = { hp = 83, attack = 106, defense = 65, speed = 85, specialA = 86, specialD = 65 },
      catchRate = 75, baseExp = 172, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 44.4,
      dexEntry = { kind = "Toxic Mouth Pokémon",
        text = "It bounces toward opponents and gouges them with poisonous claws. No more than a scratch is needed to knock out its adversaries." },
    },

    CARNIVINE = {
      dex = 455, name = "Carnivine", types = { "GRASS" },
      baseStats = { hp = 74, attack = 100, defense = 72, speed = 46, specialA = 90, specialD = 72 },
      catchRate = 200, baseExp = 159, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 27,
      dexEntry = { kind = "Bug Catcher Pokémon",
        text = "It attracts prey with its sweet-smelling saliva, then chomps down. It takes a whole day to eat prey." },
    },

    FINNEON = {
      dex = 456, name = "Finneon", types = { "WATER" },
      baseStats = { hp = 49, attack = 49, defense = 56, speed = 66, specialA = 49, specialD = 61 },
      catchRate = 190, baseExp = 66, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "LUMINEON", level = 31 },
      },
      heightM = 0.4, weightKg = 7,
      dexEntry = { kind = "Wing Fish Pokémon",
        text = "When night falls, their pink patterns begin to shine. They’re popular with divers, so there are resorts that feed them to keep them close." },
    },

    LUMINEON = {
      dex = 457, name = "Lumineon", types = { "WATER" },
      baseStats = { hp = 69, attack = 69, defense = 76, speed = 91, specialA = 69, specialD = 86 },
      catchRate = 75, baseExp = 161, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 24,
      dexEntry = { kind = "Neon Pokémon",
        text = "Deep down at the bottom of the ocean, prey is scarce. Lumineon get into fierce disputes with Lanturn over food." },
    },

    MANTYKE = {
      dex = 458, name = "Mantyke", types = { "WATER", "FLYING" },
      baseStats = { hp = 45, attack = 20, defense = 50, speed = 50, specialA = 60, specialD = 120 },
      catchRate = 25, baseExp = 69, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "HASINPARTY", species = "MANTINE" },
      },
      heightM = 1, weightKg = 65,
      dexEntry = { kind = "Kite Pokémon",
        text = "Mantyke living in Galar seem to be somewhat sluggish. The colder waters of the seas in this region may be the cause." },
    },

    SNOVER = {
      dex = 459, name = "Snover", types = { "GRASS", "ICE" },
      baseStats = { hp = 60, attack = 62, defense = 50, speed = 40, specialA = 62, specialD = 60 },
      catchRate = 120, baseExp = 67, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ABOMASNOW", level = 40 },
      },
      heightM = 1, weightKg = 50.5,
      dexEntry = { kind = "Frosted Tree Pokémon",
        text = "It lives on snowy mountains. It sinks its legs into the snow to absorb water and keep its own temperature down." },
    },

    ABOMASNOW = {
      dex = 460, name = "Abomasnow", types = { "GRASS", "ICE" },
      baseStats = { hp = 90, attack = 92, defense = 75, speed = 60, specialA = 92, specialD = 85 },
      catchRate = 60, baseExp = 173, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.2, weightKg = 135.5,
      dexEntry = { kind = "Frosted Tree Pokémon",
        text = "If it sees any packs of Darumaka going after Snover, it chases them off, swinging its sizable arms like hammers." },
    },

    WEAVILE = {
      dex = 461, name = "Weavile", types = { "DARK", "ICE" },
      baseStats = { hp = 70, attack = 120, defense = 65, speed = 125, specialA = 45, specialD = 85 },
      catchRate = 45, baseExp = 179, growthRate = "MEDIUM_SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.1, weightKg = 34,
      dexEntry = { kind = "Sharp Claw Pokémon",
        text = "They attack their quarry in packs. Prey as large as Mamoswine easily fall to the teamwork of a group of Weavile." },
    },

    MAGNEZONE = {
      dex = 462, name = "Magnezone", types = { "ELECTRIC", "STEEL" },
      baseStats = { hp = 70, attack = 70, defense = 115, speed = 60, specialA = 130, specialD = 90 },
      catchRate = 30, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 180,
      dexEntry = { kind = "Magnet Area Pokémon",
        text = "Some say that Magnezone receives signals from space via the antenna on its head and that it’s being controlled by some mysterious being." },
    },

    LICKILICKY = {
      dex = 463, name = "Lickilicky", types = { "NORMAL" },
      baseStats = { hp = 110, attack = 85, defense = 95, speed = 50, specialA = 80, specialD = 95 },
      catchRate = 30, baseExp = 180, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 140,
      dexEntry = { kind = "Licking Pokémon",
        text = "Lickilicky’s strange tongue can stretch to many times the length of its body. No one has figured out how Lickilicky’s tongue can stretch so far." },
    },

    RHYPERIOR = {
      dex = 464, name = "Rhyperior", types = { "GROUND", "ROCK" },
      baseStats = { hp = 115, attack = 140, defense = 130, speed = 40, specialA = 55, specialD = 55 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.4, weightKg = 282.8,
      dexEntry = { kind = "Drill Pokémon",
        text = "It can load up to three projectiles per arm into the holes in its hands. What launches out of those holes could be either rocks or Roggenrola." },
    },

    TANGROWTH = {
      dex = 465, name = "Tangrowth", types = { "GRASS" },
      baseStats = { hp = 100, attack = 100, defense = 125, speed = 50, specialA = 110, specialD = 50 },
      catchRate = 30, baseExp = 187, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 128.6,
      dexEntry = { kind = "Vine Pokémon",
        text = "Tangrowth has two arms that it can extend as it pleases. Recent research has shown that these arms are, in fact, bundles of vines." },
    },

    ELECTIVIRE = {
      dex = 466, name = "Electivire", types = { "ELECTRIC" },
      baseStats = { hp = 75, attack = 123, defense = 67, speed = 95, specialA = 95, specialD = 85 },
      catchRate = 30, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 138.6,
      dexEntry = { kind = "Thunderbolt Pokémon",
        text = "The amount of electrical energy this Pokémon produces is proportional to the rate of its pulse. The voltage jumps while Electivire is battling." },
    },

    MAGMORTAR = {
      dex = 467, name = "Magmortar", types = { "FIRE" },
      baseStats = { hp = 75, attack = 95, defense = 67, speed = 83, specialA = 125, specialD = 95 },
      catchRate = 30, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 68,
      dexEntry = { kind = "Blast Pokémon",
        text = "When Magmortar inhales deeply, the fire burning in its belly intensifies, rising in temperature to over 3,600 degrees Fahrenheit." },
    },

    TOGEKISS = {
      dex = 468, name = "Togekiss", types = { "FAIRY", "FLYING" },
      baseStats = { hp = 85, attack = 50, defense = 95, speed = 80, specialA = 120, specialD = 115 },
      catchRate = 30, baseExp = 255, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 38,
      dexEntry = { kind = "Jubilee Pokémon",
        text = "These Pokémon are never seen anywhere near conflict or turmoil. In recent times, they’ve hardly been seen at all." },
    },

    YANMEGA = {
      dex = 469, name = "Yanmega", types = { "BUG", "FLYING" },
      baseStats = { hp = 86, attack = 76, defense = 86, speed = 95, specialA = 116, specialD = 56 },
      catchRate = 30, baseExp = 180, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 51.5,
      dexEntry = { kind = "Ogre Darner Pokémon",
        text = "It prefers to battle by biting apart foes’ heads instantly while flying by at high speed." },
    },

    LEAFEON = {
      dex = 470, name = "Leafeon", types = { "GRASS" },
      baseStats = { hp = 65, attack = 110, defense = 130, speed = 95, specialA = 60, specialD = 65 },
      catchRate = 45, baseExp = 184, growthRate = "MEDIUM_FAST", happiness = 35,
      evolutions = {},
      heightM = 1, weightKg = 25.5,
      dexEntry = { kind = "Verdant Pokémon",
        text = "Galarians favor the distinctive aroma that drifts from this Pokémon’s leaves. There’s a popular perfume made using that scent." },
    },

    GLACEON = {
      dex = 471, name = "Glaceon", types = { "ICE" },
      baseStats = { hp = 65, attack = 60, defense = 110, speed = 65, specialA = 130, specialD = 95 },
      catchRate = 45, baseExp = 184, growthRate = "MEDIUM_FAST", happiness = 35,
      evolutions = {},
      heightM = 0.8, weightKg = 25.9,
      dexEntry = { kind = "Fresh Snow Pokémon",
        text = "Any who become captivated by the beauty of the snowfall that Glaceon creates will be frozen before they know it." },
    },

    GLISCOR = {
      dex = 472, name = "Gliscor", types = { "GROUND", "FLYING" },
      baseStats = { hp = 75, attack = 95, defense = 125, speed = 95, specialA = 45, specialD = 75 },
      catchRate = 30, baseExp = 179, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 42.5,
      dexEntry = { kind = "Fang Scorp Pokémon",
        text = "It observes prey while hanging inverted from branches. When the chance presents itself, it swoops!" },
    },

    MAMOSWINE = {
      dex = 473, name = "Mamoswine", types = { "ICE", "GROUND" },
      baseStats = { hp = 110, attack = 130, defense = 80, speed = 80, specialA = 70, specialD = 60 },
      catchRate = 50, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.5, weightKg = 291,
      dexEntry = { kind = "Twin Tusk Pokémon",
        text = "This Pokémon can be spotted in wall paintings from as far back as 10,000 years ago. For a while, it was thought to have gone extinct." },
    },

    PORYGONZ = {
      dex = 474, name = "Porygon-Z", types = { "NORMAL" },
      baseStats = { hp = 85, attack = 80, defense = 70, speed = 90, specialA = 135, specialD = 75 },
      catchRate = 30, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 34,
      dexEntry = { kind = "Virtual Pokémon",
        text = "Porygon-Z had a program installed to allow it to move between dimensions, but the program also caused instability in Porygon-Z’s behavior." },
    },

    GALLADE = {
      dex = 475, name = "Gallade", types = { "PSYCHIC", "FIGHTING" },
      baseStats = { hp = 68, attack = 125, defense = 65, speed = 80, specialA = 65, specialD = 115 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.6, weightKg = 52,
      dexEntry = { kind = "Blade Pokémon",
        text = "True to its honorable-warrior image, it uses the blades on its elbows only in defense of something or someone." },
    },

    PROBOPASS = {
      dex = 476, name = "Probopass", types = { "ROCK", "STEEL" },
      baseStats = { hp = 60, attack = 55, defense = 145, speed = 40, specialA = 75, specialD = 150 },
      catchRate = 60, baseExp = 184, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 340,
      dexEntry = { kind = "Compass Pokémon",
        text = "Although it can control its units known as Mini-Noses, they sometimes get lost and don’t come back." },
    },

    DUSKNOIR = {
      dex = 477, name = "Dusknoir", types = { "GHOST" },
      baseStats = { hp = 45, attack = 100, defense = 135, speed = 45, specialA = 65, specialD = 135 },
      catchRate = 45, baseExp = 255, growthRate = "FAST", happiness = 35,
      evolutions = {},
      heightM = 2.2, weightKg = 106.6,
      dexEntry = { kind = "Gripper Pokémon",
        text = "At the bidding of transmissions from the spirit world, it steals people and Pokémon away. No one knows whether it has a will of its own." },
    },

    FROSLASS = {
      dex = 478, name = "Froslass", types = { "ICE", "GHOST" },
      baseStats = { hp = 70, attack = 80, defense = 70, speed = 110, specialA = 80, specialD = 70 },
      catchRate = 75, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 26.6,
      dexEntry = { kind = "Snow Land Pokémon",
        text = "After a woman met her end on a snowy mountain, her regrets lingered on. From them, this Pokémon was born. Its favorite food is frozen souls." },
    },

    ROTOM = {
      dex = 479, name = "Rotom", types = { "ELECTRIC", "GHOST" },
      baseStats = { hp = 50, attack = 50, defense = 77, speed = 91, specialA = 95, specialD = 77 },
      catchRate = 45, baseExp = 154, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 0.3,
      dexEntry = { kind = "Plasma Pokémon",
        text = "One boy’s invention led to the development of many different machines that take advantage of Rotom’s unique capabilities." },
    },

    UXIE = {
      dex = 480, name = "Uxie", types = { "PSYCHIC" },
      baseStats = { hp = 75, attack = 75, defense = 130, speed = 95, specialA = 75, specialD = 130 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 140,
      evolutions = {},
      heightM = 0.3, weightKg = 0.3,
      dexEntry = { kind = "Knowledge Pokémon",
        text = "Known as “The Being of Knowledge.” It is said that it can wipe out the memory of those who see its eyes." },
    },

    MESPRIT = {
      dex = 481, name = "Mesprit", types = { "PSYCHIC" },
      baseStats = { hp = 80, attack = 105, defense = 105, speed = 80, specialA = 105, specialD = 105 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 140,
      evolutions = {},
      heightM = 0.3, weightKg = 0.3,
      dexEntry = { kind = "Emotion Pokémon",
        text = "Known as “The Being of Emotion.” It taught humans the nobility of sorrow, pain, and joy." },
    },

    AZELF = {
      dex = 482, name = "Azelf", types = { "PSYCHIC" },
      baseStats = { hp = 75, attack = 125, defense = 70, speed = 115, specialA = 125, specialD = 70 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 140,
      evolutions = {},
      heightM = 0.3, weightKg = 0.3,
      dexEntry = { kind = "Willpower Pokémon",
        text = "Known as “The Being of Willpower.” It sleeps at the bottom of a lake to keep the world in balance." },
    },

    DIALGA = {
      dex = 483, name = "Dialga", types = { "STEEL", "DRAGON" },
      baseStats = { hp = 100, attack = 120, defense = 120, speed = 90, specialA = 150, specialD = 100 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 5.4, weightKg = 683,
      dexEntry = { kind = "Temporal Pokémon",
        text = "A Pokémon spoken of in legend. It is said that time began moving when Dialga was born." },
    },

    PALKIA = {
      dex = 484, name = "Palkia", types = { "WATER", "DRAGON" },
      baseStats = { hp = 90, attack = 120, defense = 100, speed = 100, specialA = 150, specialD = 120 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 4.2, weightKg = 336,
      dexEntry = { kind = "Spatial Pokémon",
        text = "It is said to live in a gap in the spatial dimension parallel to ours. It appears in mythology." },
    },

    HEATRAN = {
      dex = 485, name = "Heatran", types = { "FIRE", "STEEL" },
      baseStats = { hp = 91, attack = 90, defense = 106, speed = 77, specialA = 130, specialD = 106 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 100,
      evolutions = {},
      heightM = 1.7, weightKg = 430,
      dexEntry = { kind = "Lava Dome Pokémon",
        text = "It dwells in volcanic caves. It digs in with its cross-shaped feet to crawl on ceilings and walls." },
    },

    REGIGIGAS = {
      dex = 486, name = "Regigigas", types = { "NORMAL" },
      baseStats = { hp = 110, attack = 160, defense = 110, speed = 100, specialA = 80, specialD = 110 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.7, weightKg = 420,
      dexEntry = { kind = "Colossal Pokémon",
        text = "It is said to have made Pokémon that look like itself from a special ice mountain, rocks, and magma." },
    },

    GIRATINA = {
      dex = 487, name = "Giratina", types = { "GHOST", "DRAGON" },
      baseStats = { hp = 150, attack = 100, defense = 120, speed = 90, specialA = 100, specialD = 120 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 4.5, weightKg = 750,
      dexEntry = { kind = "Renegade Pokémon",
        text = "This Pokémon is said to live in a world on the reverse side of ours, where common knowledge is distorted and strange." },
    },

    CRESSELIA = {
      dex = 488, name = "Cresselia", types = { "PSYCHIC" },
      baseStats = { hp = 120, attack = 70, defense = 110, speed = 85, specialA = 75, specialD = 120 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 100,
      evolutions = {},
      heightM = 1.5, weightKg = 85.6,
      dexEntry = { kind = "Lunar Pokémon",
        text = "Shiny particles are released from its wings like a veil. It is said to represent the crescent moon." },
    },

    PHIONE = {
      dex = 489, name = "Phione", types = { "WATER" },
      baseStats = { hp = 80, attack = 80, defense = 80, speed = 80, specialA = 80, specialD = 80 },
      catchRate = 30, baseExp = 240, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.4, weightKg = 3.1,
      dexEntry = { kind = "Sea Drifter Pokémon",
        text = "When the water warms, they inflate the flotation sac on their heads and drift languidly on the sea in packs." },
    },

    MANAPHY = {
      dex = 490, name = "Manaphy", types = { "WATER" },
      baseStats = { hp = 100, attack = 100, defense = 100, speed = 100, specialA = 100, specialD = 100 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 1.4,
      dexEntry = { kind = "Seafaring Pokémon",
        text = "It is born with a wondrous power that lets it bond with any kind of Pokémon." },
    },

    DARKRAI = {
      dex = 491, name = "Darkrai", types = { "DARK" },
      baseStats = { hp = 70, attack = 90, defense = 90, speed = 125, specialA = 135, specialD = 90 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.5, weightKg = 50.5,
      dexEntry = { kind = "Pitch-Black Pokémon",
        text = "It chases people and Pokémon from its territory by causing them to experience deep, nightmarish slumbers." },
    },

    SHAYMIN = {
      dex = 492, name = "Shaymin", types = { "GRASS" },
      baseStats = { hp = 100, attack = 100, defense = 100, speed = 100, specialA = 100, specialD = 100 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 100,
      evolutions = {},
      heightM = 0.2, weightKg = 2.1,
      dexEntry = { kind = "Gratitude Pokémon",
        text = "It can dissolve toxins in the air to instantly transform ruined land into a lush field of flowers." },
    },

    ARCEUS = {
      dex = 493, name = "Arceus", types = { "NORMAL" },
      baseStats = { hp = 120, attack = 120, defense = 120, speed = 120, specialA = 120, specialD = 120 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.2, weightKg = 320,
      dexEntry = { kind = "Alpha Pokémon",
        text = "According to the legends of Sinnoh, this Pokémon emerged from an egg and shaped all there is in this world." },
    },

    VICTINI = {
      dex = 494, name = "Victini", types = { "PSYCHIC", "FIRE" },
      baseStats = { hp = 100, attack = 100, defense = 100, speed = 100, specialA = 100, specialD = 100 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 100,
      evolutions = {},
      heightM = 0.4, weightKg = 4,
      dexEntry = { kind = "Victory Pokémon",
        text = "This Pokémon brings victory. It is said that Trainers with Victini always win, regardless of the type of encounter." },
    },

    SNIVY = {
      dex = 495, name = "Snivy", types = { "GRASS" },
      baseStats = { hp = 45, attack = 45, defense = 55, speed = 63, specialA = 45, specialD = 55 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SERVINE", level = 17 },
      },
      heightM = 0.6, weightKg = 8.1,
      dexEntry = { kind = "Grass Snake Pokémon",
        text = "Being exposed to sunlight makes its movements swifter. It uses vines more adeptly than its hands." },
    },

    SERVINE = {
      dex = 496, name = "Servine", types = { "GRASS" },
      baseStats = { hp = 60, attack = 60, defense = 75, speed = 83, specialA = 60, specialD = 75 },
      catchRate = 45, baseExp = 145, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SERPERIOR", level = 36 },
      },
      heightM = 0.8, weightKg = 16,
      dexEntry = { kind = "Grass Snake Pokémon",
        text = "It moves along the ground as if sliding. Its swift movements befuddle its foes, and it then attacks with a vine whip." },
    },

    SERPERIOR = {
      dex = 497, name = "Serperior", types = { "GRASS" },
      baseStats = { hp = 75, attack = 75, defense = 95, speed = 113, specialA = 75, specialD = 95 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 3.3, weightKg = 63,
      dexEntry = { kind = "Regal Pokémon",
        text = "It only gives its all against strong opponents who are not fazed by the glare from Serperior’s noble eyes." },
    },

    TEPIG = {
      dex = 498, name = "Tepig", types = { "FIRE" },
      baseStats = { hp = 65, attack = 63, defense = 45, speed = 45, specialA = 45, specialD = 45 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PIGNITE", level = 17 },
      },
      heightM = 0.5, weightKg = 9.9,
      dexEntry = { kind = "Fire Pig Pokémon",
        text = "It can deftly dodge its foe’s attacks while shooting fireballs from its nose. It roasts berries before it eats them." },
    },

    PIGNITE = {
      dex = 499, name = "Pignite", types = { "FIRE", "FIGHTING" },
      baseStats = { hp = 90, attack = 93, defense = 55, speed = 55, specialA = 70, specialD = 55 },
      catchRate = 45, baseExp = 146, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "EMBOAR", level = 36 },
      },
      heightM = 1, weightKg = 55.5,
      dexEntry = { kind = "Fire Pig Pokémon",
        text = "The more it eats, the more fuel it has to make the fire in its stomach stronger. This fills it with even more power." },
    },

    EMBOAR = {
      dex = 500, name = "Emboar", types = { "FIRE", "FIGHTING" },
      baseStats = { hp = 110, attack = 123, defense = 65, speed = 65, specialA = 100, specialD = 65 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 150,
      dexEntry = { kind = "Mega Fire Pig Pokémon",
        text = "It can throw a fire punch by setting its fists on fire with its fiery chin. It cares deeply about its friends." },
    },

    OSHAWOTT = {
      dex = 501, name = "Oshawott", types = { "WATER" },
      baseStats = { hp = 55, attack = 55, defense = 45, speed = 45, specialA = 63, specialD = 45 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DEWOTT", level = 17 },
      },
      heightM = 0.5, weightKg = 5.9,
      dexEntry = { kind = "Sea Otter Pokémon",
        text = "The scalchop on its stomach isn’t just used for battle—it can be used to break open hard berries as well." },
    },

    DEWOTT = {
      dex = 502, name = "Dewott", types = { "WATER" },
      baseStats = { hp = 75, attack = 75, defense = 60, speed = 60, specialA = 83, specialD = 60 },
      catchRate = 45, baseExp = 145, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SAMUROTT", level = 36 },
      },
      heightM = 0.8, weightKg = 24.5,
      dexEntry = { kind = "Discipline Pokémon",
        text = "Strict training is how it learns its flowing double-scalchop technique." },
    },

    SAMUROTT = {
      dex = 503, name = "Samurott", types = { "WATER" },
      baseStats = { hp = 95, attack = 100, defense = 85, speed = 70, specialA = 108, specialD = 70 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 94.6,
      dexEntry = { kind = "Formidable Pokémon",
        text = "In the time it takes a foe to blink, it can draw and sheathe the seamitars attached to its front legs." },
    },

    PATRAT = {
      dex = 504, name = "Patrat", types = { "NORMAL" },
      baseStats = { hp = 45, attack = 55, defense = 39, speed = 42, specialA = 35, specialD = 39 },
      catchRate = 255, baseExp = 51, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "WATCHOG", level = 20 },
      },
      heightM = 0.5, weightKg = 11.6,
      dexEntry = { kind = "Scout Pokémon",
        text = "Using food stored in cheek pouches, they can keep watch for days. They use their tails to communicate with others." },
    },

    WATCHOG = {
      dex = 505, name = "Watchog", types = { "NORMAL" },
      baseStats = { hp = 60, attack = 85, defense = 69, speed = 77, specialA = 60, specialD = 69 },
      catchRate = 255, baseExp = 147, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 27,
      dexEntry = { kind = "Lookout Pokémon",
        text = "Using luminescent matter, it makes its eyes and body glow and stuns attacking opponents." },
    },

    LILLIPUP = {
      dex = 506, name = "Lillipup", types = { "NORMAL" },
      baseStats = { hp = 45, attack = 60, defense = 45, speed = 55, specialA = 25, specialD = 45 },
      catchRate = 255, baseExp = 55, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "HERDIER", level = 16 },
      },
      heightM = 0.4, weightKg = 4.1,
      dexEntry = { kind = "Puppy Pokémon",
        text = "This Pokémon is courageous but also cautious. It uses the soft fur covering its face to collect information about its surroundings." },
    },

    HERDIER = {
      dex = 507, name = "Herdier", types = { "NORMAL" },
      baseStats = { hp = 65, attack = 80, defense = 65, speed = 60, specialA = 35, specialD = 65 },
      catchRate = 120, baseExp = 130, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "STOUTLAND", level = 32 },
      },
      heightM = 0.9, weightKg = 14.7,
      dexEntry = { kind = "Loyal Dog Pokémon",
        text = "Herdier is a very smart and friendly Pokémon. So much so that there’s a theory that Herdier was the first Pokémon to partner with people." },
    },

    STOUTLAND = {
      dex = 508, name = "Stoutland", types = { "NORMAL" },
      baseStats = { hp = 85, attack = 110, defense = 90, speed = 80, specialA = 45, specialD = 90 },
      catchRate = 45, baseExp = 250, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 61,
      dexEntry = { kind = "Big-Hearted Pokémon",
        text = "These Pokémon seem to enjoy living with humans. Even a Stoutland caught in the wild will warm up to people in about three days." },
    },

    PURRLOIN = {
      dex = 509, name = "Purrloin", types = { "DARK" },
      baseStats = { hp = 41, attack = 50, defense = 37, speed = 66, specialA = 50, specialD = 37 },
      catchRate = 255, baseExp = 56, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "LIEPARD", level = 20 },
      },
      heightM = 0.4, weightKg = 10.1,
      dexEntry = { kind = "Devious Pokémon",
        text = "It steals things from people just to amuse itself with their frustration. A rivalry exists between this Pokémon and Nickit." },
    },

    LIEPARD = {
      dex = 510, name = "Liepard", types = { "DARK" },
      baseStats = { hp = 64, attack = 88, defense = 50, speed = 106, specialA = 88, specialD = 50 },
      catchRate = 90, baseExp = 156, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 37.5,
      dexEntry = { kind = "Cruel Pokémon",
        text = "Don’t be fooled by its gorgeous fur and elegant figure. This is a moody and vicious Pokémon." },
    },

    PANSAGE = {
      dex = 511, name = "Pansage", types = { "GRASS" },
      baseStats = { hp = 50, attack = 53, defense = 48, speed = 64, specialA = 53, specialD = 48 },
      catchRate = 190, baseExp = 63, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "SIMISAGE", item = "LEAFSTONE" },
      },
      heightM = 0.6, weightKg = 10.5,
      dexEntry = { kind = "Grass Monkey Pokémon",
        text = "It shares the leaf on its head with weary-looking Pokémon. These leaves are known to relieve stress." },
    },

    SIMISAGE = {
      dex = 512, name = "Simisage", types = { "GRASS" },
      baseStats = { hp = 75, attack = 98, defense = 63, speed = 101, specialA = 98, specialD = 63 },
      catchRate = 75, baseExp = 174, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 30.5,
      dexEntry = { kind = "Thorn Monkey Pokémon",
        text = "It attacks enemies with strikes of its thorn-covered tail. This Pokémon is wild tempered." },
    },

    PANSEAR = {
      dex = 513, name = "Pansear", types = { "FIRE" },
      baseStats = { hp = 50, attack = 53, defense = 48, speed = 64, specialA = 53, specialD = 48 },
      catchRate = 190, baseExp = 63, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "SIMISEAR", item = "FIRESTONE" },
      },
      heightM = 0.6, weightKg = 11,
      dexEntry = { kind = "High Temp Pokémon",
        text = "Very intelligent, it roasts berries before eating them. It likes to help people." },
    },

    SIMISEAR = {
      dex = 514, name = "Simisear", types = { "FIRE" },
      baseStats = { hp = 75, attack = 98, defense = 63, speed = 101, specialA = 98, specialD = 63 },
      catchRate = 75, baseExp = 174, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 28,
      dexEntry = { kind = "Ember Pokémon",
        text = "A flame burns inside its body. It scatters embers from its head and tail to sear its opponents." },
    },

    PANPOUR = {
      dex = 515, name = "Panpour", types = { "WATER" },
      baseStats = { hp = 50, attack = 53, defense = 48, speed = 64, specialA = 53, specialD = 48 },
      catchRate = 190, baseExp = 63, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "SIMIPOUR", item = "WATERSTONE" },
      },
      heightM = 0.6, weightKg = 13.5,
      dexEntry = { kind = "Spray Pokémon",
        text = "The water stored inside the tuft on its head is full of nutrients. It waters plants with it using its tail." },
    },

    SIMIPOUR = {
      dex = 516, name = "Simipour", types = { "WATER" },
      baseStats = { hp = 75, attack = 98, defense = 63, speed = 101, specialA = 98, specialD = 63 },
      catchRate = 75, baseExp = 174, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 29,
      dexEntry = { kind = "Geyser Pokémon",
        text = "The high-pressure water expelled from its tail is so powerful, it can destroy a concrete wall." },
    },

    MUNNA = {
      dex = 517, name = "Munna", types = { "PSYCHIC" },
      baseStats = { hp = 76, attack = 25, defense = 45, speed = 24, specialA = 67, specialD = 55 },
      catchRate = 190, baseExp = 58, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "MUSHARNA", item = "MOONSTONE" },
      },
      heightM = 0.6, weightKg = 23.3,
      dexEntry = { kind = "Dream Eater Pokémon",
        text = "Late at night, it appears beside people’s pillows. As it feeds on dreams, the patterns on its body give off a faint glow." },
    },

    MUSHARNA = {
      dex = 518, name = "Musharna", types = { "PSYCHIC" },
      baseStats = { hp = 116, attack = 55, defense = 85, speed = 29, specialA = 107, specialD = 95 },
      catchRate = 75, baseExp = 170, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 60.5,
      dexEntry = { kind = "Drowsing Pokémon",
        text = "When dark mists emanate from its body, don’t get too near. If you do, your nightmares will become reality." },
    },

    PIDOVE = {
      dex = 519, name = "Pidove", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 50, attack = 55, defense = 50, speed = 43, specialA = 36, specialD = 30 },
      catchRate = 255, baseExp = 53, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TRANQUILL", level = 21 },
      },
      heightM = 0.3, weightKg = 2.1,
      dexEntry = { kind = "Tiny Pigeon Pokémon",
        text = "Where people go, these Pokémon follow. If you’re scattering food for them, be careful—several hundred of them can gather at once." },
    },

    TRANQUILL = {
      dex = 520, name = "Tranquill", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 62, attack = 77, defense = 62, speed = 65, specialA = 50, specialD = 42 },
      catchRate = 120, baseExp = 125, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "UNFEZANT", level = 32 },
      },
      heightM = 0.6, weightKg = 15,
      dexEntry = { kind = "Wild Pigeon Pokémon",
        text = "It can fly moderately quickly. No matter how far it travels, it can always find its way back to its master and its nest." },
    },

    UNFEZANT = {
      dex = 521, name = "Unfezant", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 80, attack = 115, defense = 80, speed = 93, specialA = 65, specialD = 55 },
      catchRate = 45, baseExp = 244, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 29,
      dexEntry = { kind = "Proud Pokémon",
        text = "Unfezant are exceptional fliers. The females are known for their stamina, while the males outclass them in terms of speed." },
    },

    BLITZLE = {
      dex = 522, name = "Blitzle", types = { "ELECTRIC" },
      baseStats = { hp = 45, attack = 60, defense = 32, speed = 76, specialA = 50, specialD = 32 },
      catchRate = 190, baseExp = 59, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ZEBSTRIKA", level = 27 },
      },
      heightM = 0.8, weightKg = 29.8,
      dexEntry = { kind = "Electrified Pokémon",
        text = "When thunderclouds cover the sky, it will appear. It can catch lightning with its mane and store the electricity." },
    },

    ZEBSTRIKA = {
      dex = 523, name = "Zebstrika", types = { "ELECTRIC" },
      baseStats = { hp = 75, attack = 100, defense = 63, speed = 116, specialA = 80, specialD = 63 },
      catchRate = 75, baseExp = 174, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 79.5,
      dexEntry = { kind = "Thunderbolt Pokémon",
        text = "When this ill-tempered Pokémon runs wild, it shoots lightning from its mane in all directions." },
    },

    ROGGENROLA = {
      dex = 524, name = "Roggenrola", types = { "ROCK" },
      baseStats = { hp = 55, attack = 75, defense = 85, speed = 15, specialA = 25, specialD = 25 },
      catchRate = 255, baseExp = 56, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BOLDORE", level = 25 },
      },
      heightM = 0.4, weightKg = 18,
      dexEntry = { kind = "Mantle Pokémon",
        text = "It’s as hard as steel, but apparently a long soak in water will cause it to soften a bit." },
    },

    BOLDORE = {
      dex = 525, name = "Boldore", types = { "ROCK" },
      baseStats = { hp = 70, attack = 105, defense = 105, speed = 20, specialA = 50, specialD = 40 },
      catchRate = 120, baseExp = 137, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "TRADE", species = "GIGALITH" },
        { method = "ITEM", species = "GIGALITH", item = "LINKINGCORD" },
      },
      heightM = 0.9, weightKg = 102,
      dexEntry = { kind = "Ore Pokémon",
        text = "If you see its orange crystals start to glow, be wary. It’s about to fire off bursts of energy." },
    },

    GIGALITH = {
      dex = 526, name = "Gigalith", types = { "ROCK" },
      baseStats = { hp = 85, attack = 135, defense = 130, speed = 25, specialA = 60, specialD = 80 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 260,
      dexEntry = { kind = "Compressed Pokémon",
        text = "This hardy Pokémon can often be found on construction sites and in mines, working alongside people and Copperajah." },
    },

    WOOBAT = {
      dex = 527, name = "Woobat", types = { "PSYCHIC", "FLYING" },
      baseStats = { hp = 65, attack = 45, defense = 43, speed = 72, specialA = 55, specialD = 43 },
      catchRate = 190, baseExp = 65, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HAPPINESS", species = "SWOOBAT" },
      },
      heightM = 0.4, weightKg = 2.1,
      dexEntry = { kind = "Bat Pokémon",
        text = "While inside a cave, if you look up and see lots of heart-shaped marks lining the walls, it’s evidence that Woobat live there." },
    },

    SWOOBAT = {
      dex = 528, name = "Swoobat", types = { "PSYCHIC", "FLYING" },
      baseStats = { hp = 67, attack = 57, defense = 55, speed = 114, specialA = 77, specialD = 55 },
      catchRate = 45, baseExp = 149, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 10.5,
      dexEntry = { kind = "Courting Pokémon",
        text = "Emitting powerful sound waves tires it out. Afterward, it won’t be able to fly for a little while." },
    },

    DRILBUR = {
      dex = 529, name = "Drilbur", types = { "GROUND" },
      baseStats = { hp = 60, attack = 85, defense = 40, speed = 68, specialA = 30, specialD = 45 },
      catchRate = 120, baseExp = 66, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "EXCADRILL", level = 31 },
      },
      heightM = 0.3, weightKg = 8.5,
      dexEntry = { kind = "Mole Pokémon",
        text = "It brings its claws together and whirls around at high speed before rushing toward its prey." },
    },

    EXCADRILL = {
      dex = 530, name = "Excadrill", types = { "GROUND", "STEEL" },
      baseStats = { hp = 110, attack = 135, defense = 60, speed = 88, specialA = 50, specialD = 65 },
      catchRate = 60, baseExp = 178, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 40.4,
      dexEntry = { kind = "Subterrene Pokémon",
        text = "It’s not uncommon for tunnels that appear to have formed naturally to actually be a result of Excadrill’s rampant digging." },
    },

    AUDINO = {
      dex = 531, name = "Audino", types = { "NORMAL" },
      baseStats = { hp = 103, attack = 60, defense = 86, speed = 50, specialA = 60, specialD = 86 },
      catchRate = 255, baseExp = 255, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 31,
      dexEntry = { kind = "Hearing Pokémon",
        text = "Audino’s sense of hearing is superb. Not even a pebble rolling along over a mile away will escape Audino’s ears." },
    },

    TIMBURR = {
      dex = 532, name = "Timburr", types = { "FIGHTING" },
      baseStats = { hp = 75, attack = 80, defense = 55, speed = 35, specialA = 25, specialD = 35 },
      catchRate = 180, baseExp = 61, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GURDURR", level = 25 },
      },
      heightM = 0.6, weightKg = 12.5,
      dexEntry = { kind = "Muscular Pokémon",
        text = "It loves helping out with construction projects. It loves it so much that if rain causes work to halt, it swings its log around and throws a tantrum." },
    },

    GURDURR = {
      dex = 533, name = "Gurdurr", types = { "FIGHTING" },
      baseStats = { hp = 85, attack = 105, defense = 85, speed = 40, specialA = 40, specialD = 50 },
      catchRate = 90, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "TRADE", species = "CONKELDURR" },
        { method = "ITEM", species = "CONKELDURR", item = "LINKINGCORD" },
      },
      heightM = 1.2, weightKg = 40,
      dexEntry = { kind = "Muscular Pokémon",
        text = "It shows off its muscles to Machoke and other Gurdurr. If it fails to measure up to the other Pokémon, it lies low for a little while." },
    },

    CONKELDURR = {
      dex = 534, name = "Conkeldurr", types = { "FIGHTING" },
      baseStats = { hp = 105, attack = 140, defense = 95, speed = 45, specialA = 55, specialD = 65 },
      catchRate = 45, baseExp = 253, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 87,
      dexEntry = { kind = "Muscular Pokémon",
        text = "Concrete mixed by Conkeldurr is much more durable than normal concrete, even when the compositions of the two materials are the same." },
    },

    TYMPOLE = {
      dex = 535, name = "Tympole", types = { "WATER" },
      baseStats = { hp = 50, attack = 50, defense = 40, speed = 64, specialA = 50, specialD = 40 },
      catchRate = 255, baseExp = 59, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PALPITOAD", level = 25 },
      },
      heightM = 0.5, weightKg = 4.5,
      dexEntry = { kind = "Tadpole Pokémon",
        text = "Graceful ripples running across the water’s surface are a sure sign that Tympole are singing in high-pitched voices below." },
    },

    PALPITOAD = {
      dex = 536, name = "Palpitoad", types = { "WATER", "GROUND" },
      baseStats = { hp = 75, attack = 65, defense = 55, speed = 69, specialA = 65, specialD = 55 },
      catchRate = 120, baseExp = 134, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SEISMITOAD", level = 36 },
      },
      heightM = 0.8, weightKg = 17,
      dexEntry = { kind = "Vibration Pokémon",
        text = "It weakens its prey with sound waves intense enough to cause headaches, then entangles them with its sticky tongue." },
    },

    SEISMITOAD = {
      dex = 537, name = "Seismitoad", types = { "WATER", "GROUND" },
      baseStats = { hp = 105, attack = 95, defense = 75, speed = 74, specialA = 85, specialD = 75 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 62,
      dexEntry = { kind = "Vibration Pokémon",
        text = "The vibrating of the bumps all over its body causes earthquake-like tremors. Seismitoad and Croagunk are similar species." },
    },

    THROH = {
      dex = 538, name = "Throh", types = { "FIGHTING" },
      baseStats = { hp = 120, attack = 100, defense = 85, speed = 45, specialA = 30, specialD = 85 },
      catchRate = 45, baseExp = 163, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 55.5,
      dexEntry = { kind = "Judo Pokémon",
        text = "It performs throwing moves with first-rate skill. Over the course of many battles, Throh’s belt grows darker as it absorbs its wearer’s sweat." },
    },

    SAWK = {
      dex = 539, name = "Sawk", types = { "FIGHTING" },
      baseStats = { hp = 75, attack = 125, defense = 75, speed = 85, specialA = 30, specialD = 75 },
      catchRate = 45, baseExp = 163, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 51,
      dexEntry = { kind = "Karate Pokémon",
        text = "If you see a Sawk training in the mountains in its single-minded pursuit of strength, it’s best to quietly pass by." },
    },

    SEWADDLE = {
      dex = 540, name = "Sewaddle", types = { "BUG", "GRASS" },
      baseStats = { hp = 45, attack = 53, defense = 70, speed = 42, specialA = 40, specialD = 60 },
      catchRate = 255, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SWADLOON", level = 20 },
      },
      heightM = 0.3, weightKg = 2.5,
      dexEntry = { kind = "Sewing Pokémon",
        text = "This Pokémon makes clothes for itself. It chews up leaves and sews them with sticky thread extruded from its mouth." },
    },

    SWADLOON = {
      dex = 541, name = "Swadloon", types = { "BUG", "GRASS" },
      baseStats = { hp = 55, attack = 63, defense = 90, speed = 42, specialA = 50, specialD = 80 },
      catchRate = 120, baseExp = 133, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "HAPPINESS", species = "LEAVANNY" },
      },
      heightM = 0.5, weightKg = 7.3,
      dexEntry = { kind = "Leaf-Wrapped Pokémon",
        text = "Forests where Swadloon live have superb foliage because the nutrients they make from fallen leaves nourish the plant life." },
    },

    LEAVANNY = {
      dex = 542, name = "Leavanny", types = { "BUG", "GRASS" },
      baseStats = { hp = 75, attack = 103, defense = 80, speed = 92, specialA = 70, specialD = 80 },
      catchRate = 45, baseExp = 250, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 20.5,
      dexEntry = { kind = "Nurturing Pokémon",
        text = "Upon finding a small Pokémon, it weaves clothing for it from leaves by using the sticky silk secreted from its mouth." },
    },

    VENIPEDE = {
      dex = 543, name = "Venipede", types = { "BUG", "POISON" },
      baseStats = { hp = 30, attack = 45, defense = 59, speed = 57, specialA = 30, specialD = 39 },
      catchRate = 255, baseExp = 52, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "WHIRLIPEDE", level = 22 },
      },
      heightM = 0.4, weightKg = 5.3,
      dexEntry = { kind = "Centipede Pokémon",
        text = "Venipede and Sizzlipede are similar species, but when the two meet, a huge fight ensues." },
    },

    WHIRLIPEDE = {
      dex = 544, name = "Whirlipede", types = { "BUG", "POISON" },
      baseStats = { hp = 40, attack = 55, defense = 99, speed = 47, specialA = 40, specialD = 79 },
      catchRate = 120, baseExp = 126, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SCOLIPEDE", level = 30 },
      },
      heightM = 1.2, weightKg = 58.5,
      dexEntry = { kind = "Curlipede Pokémon",
        text = "This Pokémon spins itself rapidly and charges into its opponents. Its top speed is just over 60 mph." },
    },

    SCOLIPEDE = {
      dex = 545, name = "Scolipede", types = { "BUG", "POISON" },
      baseStats = { hp = 60, attack = 100, defense = 89, speed = 112, specialA = 55, specialD = 69 },
      catchRate = 45, baseExp = 243, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.5, weightKg = 200.5,
      dexEntry = { kind = "Megapede Pokémon",
        text = "Scolipede latches on to its prey with the claws on its neck before slamming them into the ground and jabbing them with its claws’ toxic spikes." },
    },

    COTTONEE = {
      dex = 546, name = "Cottonee", types = { "GRASS", "FAIRY" },
      baseStats = { hp = 40, attack = 27, defense = 60, speed = 66, specialA = 37, specialD = 50 },
      catchRate = 190, baseExp = 56, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "WHIMSICOTT", item = "SUNSTONE" },
      },
      heightM = 0.3, weightKg = 0.6,
      dexEntry = { kind = "Cotton Puff Pokémon",
        text = "It shoots cotton from its body to protect itself. If it gets caught up in hurricane-strength winds, it can get sent to the other side of the Earth." },
    },

    WHIMSICOTT = {
      dex = 547, name = "Whimsicott", types = { "GRASS", "FAIRY" },
      baseStats = { hp = 60, attack = 67, defense = 85, speed = 116, specialA = 77, specialD = 75 },
      catchRate = 75, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 6.6,
      dexEntry = { kind = "Windveiled Pokémon",
        text = "It scatters cotton all over the place as a prank. If it gets wet, it’ll become too heavy to move and have no choice but to answer for its mischief." },
    },

    PETILIL = {
      dex = 548, name = "Petilil", types = { "GRASS" },
      baseStats = { hp = 45, attack = 35, defense = 50, speed = 30, specialA = 70, specialD = 50 },
      catchRate = 190, baseExp = 56, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "LILLIGANT", item = "SUNSTONE" },
      },
      heightM = 0.5, weightKg = 6.6,
      dexEntry = { kind = "Bulb Pokémon",
        text = "Petilil appears around sources of clean water. Boiling leaves from this Pokémon’s head results in a liquid that’s sometimes used as a bug repellent." },
    },

    LILLIGANT = {
      dex = 549, name = "Lilligant", types = { "GRASS" },
      baseStats = { hp = 70, attack = 60, defense = 75, speed = 90, specialA = 110, specialD = 75 },
      catchRate = 75, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 16.3,
      dexEntry = { kind = "Flowering Pokémon",
        text = "It’s believed that even first-rate gardeners have a hard time getting the flower on a Lilligant’s head to bloom." },
    },

    BASCULIN = {
      dex = 550, name = "Basculin", types = { "WATER" },
      baseStats = { hp = 70, attack = 92, defense = 65, speed = 98, specialA = 80, specialD = 55 },
      catchRate = 25, baseExp = 161, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVELRECOILDAMAGEFORM0", species = "BASCULEGION" },
      },
      heightM = 1, weightKg = 18,
      dexEntry = { kind = "Hostile Pokémon",
        text = "Anglers love the fight this Pokémon puts up on the hook. And there are always more to catch— many people release them into lakes illicitly." },
    },

    SANDILE = {
      dex = 551, name = "Sandile", types = { "GROUND", "DARK" },
      baseStats = { hp = 50, attack = 72, defense = 35, speed = 65, specialA = 35, specialD = 35 },
      catchRate = 180, baseExp = 58, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "KROKOROK", level = 29 },
      },
      heightM = 0.7, weightKg = 15.2,
      dexEntry = { kind = "Desert Croc Pokémon",
        text = "The desert gets cold at night, so when the sun sets, this Pokémon burrows deep into the sand and sleeps until sunrise." },
    },

    KROKOROK = {
      dex = 552, name = "Krokorok", types = { "GROUND", "DARK" },
      baseStats = { hp = 60, attack = 82, defense = 45, speed = 74, specialA = 45, specialD = 45 },
      catchRate = 90, baseExp = 123, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "KROOKODILE", level = 40 },
      },
      heightM = 1, weightKg = 33.4,
      dexEntry = { kind = "Desert Croc Pokémon",
        text = "Krokorok has specialized eyes that enable it to see in the dark. This ability lets Krokorok hunt in the dead of night without getting lost." },
    },

    KROOKODILE = {
      dex = 553, name = "Krookodile", types = { "GROUND", "DARK" },
      baseStats = { hp = 95, attack = 117, defense = 80, speed = 92, specialA = 65, specialD = 70 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 96.3,
      dexEntry = { kind = "Intimidation Pokémon",
        text = "This Pokémon is known as the Bully of the Sands. Krookodile’s mighty jaws can bite through heavy plates of iron with almost no effort at all." },
    },

    DARUMAKA = {
      dex = 554, name = "Darumaka", types = { "FIRE" },
      baseStats = { hp = 70, attack = 90, defense = 45, speed = 50, specialA = 15, specialD = 45 },
      catchRate = 120, baseExp = 63, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DARMANITAN", level = 35 },
      },
      heightM = 0.6, weightKg = 37.5,
      dexEntry = { kind = "Zen Charm Pokémon",
        text = "It derives its power from fire burning inside its body. If the fire dwindles, this Pokémon will immediately fall asleep." },
    },

    DARMANITAN = {
      dex = 555, name = "Darmanitan", types = { "FIRE" },
      baseStats = { hp = 105, attack = 140, defense = 55, speed = 95, specialA = 30, specialD = 55 },
      catchRate = 60, baseExp = 168, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 92.9,
      dexEntry = { kind = "Blazing Pokémon",
        text = "The thick arms of this hot-blooded Pokémon can deliver punches capable of obliterating a dump truck." },
    },

    MARACTUS = {
      dex = 556, name = "Maractus", types = { "GRASS" },
      baseStats = { hp = 75, attack = 86, defense = 67, speed = 60, specialA = 106, specialD = 67 },
      catchRate = 255, baseExp = 161, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 28,
      dexEntry = { kind = "Cactus Pokémon",
        text = "With noises that could be mistaken for the rattles of maracas, it creates an upbeat rhythm, startling bird Pokémon and making them fly off in a hurry." },
    },

    DWEBBLE = {
      dex = 557, name = "Dwebble", types = { "BUG", "ROCK" },
      baseStats = { hp = 50, attack = 65, defense = 85, speed = 55, specialA = 35, specialD = 35 },
      catchRate = 190, baseExp = 65, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CRUSTLE", level = 34 },
      },
      heightM = 0.3, weightKg = 14.5,
      dexEntry = { kind = "Rock Inn Pokémon",
        text = "When it finds a stone appealing, it creates a hole inside it and uses it as its home. This Pokémon is the natural enemy of Roggenrola and Rolycoly." },
    },

    CRUSTLE = {
      dex = 558, name = "Crustle", types = { "BUG", "ROCK" },
      baseStats = { hp = 70, attack = 105, defense = 125, speed = 45, specialA = 65, specialD = 75 },
      catchRate = 75, baseExp = 170, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 200,
      dexEntry = { kind = "Stone Home Pokémon",
        text = "This highly territorial Pokémon prefers dry climates. It won’t come out of its boulder on rainy days." },
    },

    SCRAGGY = {
      dex = 559, name = "Scraggy", types = { "DARK", "FIGHTING" },
      baseStats = { hp = 50, attack = 75, defense = 70, speed = 48, specialA = 35, specialD = 70 },
      catchRate = 180, baseExp = 70, growthRate = "MEDIUM_FAST", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "SCRAFTY", level = 39 },
      },
      heightM = 0.6, weightKg = 11.8,
      dexEntry = { kind = "Shedding Pokémon",
        text = "If it locks eyes with you, watch out! Nothing and no one is safe from the reckless headbutts of this troublesome Pokémon." },
    },

    SCRAFTY = {
      dex = 560, name = "Scrafty", types = { "DARK", "FIGHTING" },
      baseStats = { hp = 65, attack = 90, defense = 115, speed = 58, specialA = 45, specialD = 115 },
      catchRate = 90, baseExp = 171, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 30,
      dexEntry = { kind = "Hoodlum Pokémon",
        text = "As halfhearted as this Pokémon’s kicks may seem, they pack enough power to shatter Conkeldurr’s concrete pillars." },
    },

    SIGILYPH = {
      dex = 561, name = "Sigilyph", types = { "PSYCHIC", "FLYING" },
      baseStats = { hp = 72, attack = 58, defense = 80, speed = 97, specialA = 103, specialD = 80 },
      catchRate = 45, baseExp = 172, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 14,
      dexEntry = { kind = "Avianoid Pokémon",
        text = "Psychic power allows these Pokémon to fly. Some say they were the guardians of an ancient city. Others say they were the guardians’ emissaries." },
    },

    YAMASK = {
      dex = 562, name = "Yamask", types = { "GHOST" },
      baseStats = { hp = 38, attack = 30, defense = 85, speed = 30, specialA = 55, specialD = 65 },
      catchRate = 190, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "COFAGRIGUS", level = 34 },
        { method = "NONE", species = "RUNERIGUS" },
      },
      heightM = 0.5, weightKg = 1.5,
      dexEntry = { kind = "Spirit Pokémon",
        text = "It wanders through ruins by night, carrying a mask that’s said to have been the face it had when it was still human." },
    },

    COFAGRIGUS = {
      dex = 563, name = "Cofagrigus", types = { "GHOST" },
      baseStats = { hp = 58, attack = 50, defense = 145, speed = 30, specialA = 95, specialD = 105 },
      catchRate = 90, baseExp = 169, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 76.5,
      dexEntry = { kind = "Coffin Pokémon",
        text = "This Pokémon has a body of sparkling gold. People say it no longer remembers that it was once human." },
    },

    TIRTOUGA = {
      dex = 564, name = "Tirtouga", types = { "WATER", "ROCK" },
      baseStats = { hp = 54, attack = 78, defense = 103, speed = 22, specialA = 53, specialD = 45 },
      catchRate = 45, baseExp = 71, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CARRACOSTA", level = 37 },
      },
      heightM = 0.7, weightKg = 16.5,
      dexEntry = { kind = "Prototurtle Pokémon",
        text = "This Pokémon inhabited ancient seas. Although it can only crawl, it still comes up onto land in search of prey." },
    },

    CARRACOSTA = {
      dex = 565, name = "Carracosta", types = { "WATER", "ROCK" },
      baseStats = { hp = 74, attack = 108, defense = 133, speed = 32, specialA = 83, specialD = 65 },
      catchRate = 45, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 81,
      dexEntry = { kind = "Prototurtle Pokémon",
        text = "Carracosta completely devours its prey—bones, shells, and all. Because of this, Carracosta’s own shell grows thick and sturdy." },
    },

    ARCHEN = {
      dex = 566, name = "Archen", types = { "ROCK", "FLYING" },
      baseStats = { hp = 55, attack = 112, defense = 45, speed = 70, specialA = 74, specialD = 45 },
      catchRate = 45, baseExp = 71, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ARCHEOPS", level = 37 },
      },
      heightM = 0.5, weightKg = 9.5,
      dexEntry = { kind = "First Bird Pokémon",
        text = "This Pokémon was successfully restored from a fossil. As research suggested, Archen is unable to fly. But it’s very good at jumping." },
    },

    ARCHEOPS = {
      dex = 567, name = "Archeops", types = { "ROCK", "FLYING" },
      baseStats = { hp = 75, attack = 140, defense = 65, speed = 110, specialA = 112, specialD = 65 },
      catchRate = 45, baseExp = 177, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 32,
      dexEntry = { kind = "First Bird Pokémon",
        text = "It needs a running start to take off. If Archeops wants to fly, it first needs to run nearly 25 mph, building speed over a course of about 2.5 miles." },
    },

    TRUBBISH = {
      dex = 568, name = "Trubbish", types = { "POISON" },
      baseStats = { hp = 50, attack = 50, defense = 62, speed = 65, specialA = 40, specialD = 62 },
      catchRate = 190, baseExp = 66, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GARBODOR", level = 36 },
      },
      heightM = 0.6, weightKg = 31,
      dexEntry = { kind = "Trash Bag Pokémon",
        text = "Its favorite places are unsanitary ones. If you leave trash lying around, you could even find one of these Pokémon living in your room." },
    },

    GARBODOR = {
      dex = 569, name = "Garbodor", types = { "POISON" },
      baseStats = { hp = 80, attack = 95, defense = 82, speed = 75, specialA = 60, specialD = 82 },
      catchRate = 60, baseExp = 166, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 107.3,
      dexEntry = { kind = "Trash Heap Pokémon",
        text = "This Pokémon eats trash, which turns into poison inside its body. The main component of the poison depends on what sort of trash was eaten." },
    },

    ZORUA = {
      dex = 570, name = "Zorua", types = { "DARK" },
      baseStats = { hp = 40, attack = 65, defense = 40, speed = 65, specialA = 80, specialD = 40 },
      catchRate = 75, baseExp = 66, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ZOROARK", level = 30 },
      },
      heightM = 0.7, weightKg = 12.5,
      dexEntry = { kind = "Tricky Fox Pokémon",
        text = "Zorua is a timid Pokémon. This disposition seems to be what led to the development of Zorua’s ability to take on the forms of other creatures." },
    },

    ZOROARK = {
      dex = 571, name = "Zoroark", types = { "DARK" },
      baseStats = { hp = 60, attack = 105, defense = 60, speed = 105, specialA = 120, specialD = 60 },
      catchRate = 45, baseExp = 179, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 81.1,
      dexEntry = { kind = "Illusion Fox Pokémon",
        text = "This Pokémon cares deeply about others of its kind, and it will conjure terrifying illusions to keep its den and pack safe." },
    },

    MINCCINO = {
      dex = 572, name = "Minccino", types = { "NORMAL" },
      baseStats = { hp = 55, attack = 50, defense = 40, speed = 75, specialA = 40, specialD = 40 },
      catchRate = 255, baseExp = 60, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "CINCCINO", item = "SHINYSTONE" },
      },
      heightM = 0.4, weightKg = 5.8,
      dexEntry = { kind = "Chinchilla Pokémon",
        text = "The way it brushes away grime with its tail can be helpful when cleaning. But its focus on spotlessness can make cleaning more of a hassle." },
    },

    CINCCINO = {
      dex = 573, name = "Cinccino", types = { "NORMAL" },
      baseStats = { hp = 75, attack = 95, defense = 60, speed = 115, specialA = 65, specialD = 60 },
      catchRate = 60, baseExp = 165, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.5, weightKg = 7.5,
      dexEntry = { kind = "Scarf Pokémon",
        text = "Its body secretes oil that this Pokémon spreads over its nest as a coating to protect it from dust. Cinccino won’t tolerate even a speck of the stuff." },
    },

    GOTHITA = {
      dex = 574, name = "Gothita", types = { "PSYCHIC" },
      baseStats = { hp = 45, attack = 30, defense = 50, speed = 45, specialA = 55, specialD = 65 },
      catchRate = 200, baseExp = 58, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GOTHORITA", level = 32 },
      },
      heightM = 0.4, weightKg = 5.8,
      dexEntry = { kind = "Fixation Pokémon",
        text = "Though they’re still only babies, there’s psychic power stored in their ribbonlike feelers, and sometimes they use that power to fight." },
    },

    GOTHORITA = {
      dex = 575, name = "Gothorita", types = { "PSYCHIC" },
      baseStats = { hp = 60, attack = 45, defense = 70, speed = 55, specialA = 75, specialD = 85 },
      catchRate = 100, baseExp = 137, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GOTHITELLE", level = 41 },
      },
      heightM = 0.7, weightKg = 18,
      dexEntry = { kind = "Manipulate Pokémon",
        text = "It’s said that when stars shine in the night sky, this Pokémon will spirit away sleeping children. Some call it the Witch of Punishment." },
    },

    GOTHITELLE = {
      dex = 576, name = "Gothitelle", types = { "PSYCHIC" },
      baseStats = { hp = 70, attack = 55, defense = 95, speed = 65, specialA = 95, specialD = 110 },
      catchRate = 50, baseExp = 245, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 44,
      dexEntry = { kind = "Astral Body Pokémon",
        text = "It has tremendous psychic power, but it dislikes conflict. It’s also able to predict the future based on the movement of the stars." },
    },

    SOLOSIS = {
      dex = 577, name = "Solosis", types = { "PSYCHIC" },
      baseStats = { hp = 45, attack = 30, defense = 40, speed = 20, specialA = 105, specialD = 50 },
      catchRate = 200, baseExp = 58, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DUOSION", level = 32 },
      },
      heightM = 0.3, weightKg = 1,
      dexEntry = { kind = "Cell Pokémon",
        text = "It communicates with others telepathically. Its body is encapsulated in liquid, but if it takes a heavy blow, the liquid will leak out." },
    },

    DUOSION = {
      dex = 578, name = "Duosion", types = { "PSYCHIC" },
      baseStats = { hp = 65, attack = 40, defense = 50, speed = 30, specialA = 125, specialD = 60 },
      catchRate = 100, baseExp = 130, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "REUNICLUS", level = 41 },
      },
      heightM = 0.6, weightKg = 8,
      dexEntry = { kind = "Mitosis Pokémon",
        text = "Its psychic power can supposedly cover a range of more than half a mile—but only if its two brains can agree with each other." },
    },

    REUNICLUS = {
      dex = 579, name = "Reuniclus", types = { "PSYCHIC" },
      baseStats = { hp = 110, attack = 65, defense = 75, speed = 30, specialA = 125, specialD = 85 },
      catchRate = 50, baseExp = 245, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 20.1,
      dexEntry = { kind = "Multiplying Pokémon",
        text = "While it could use its psychic abilities in battle, this Pokémon prefers to swing its powerful arms around to beat opponents into submission." },
    },

    DUCKLETT = {
      dex = 580, name = "Ducklett", types = { "WATER", "FLYING" },
      baseStats = { hp = 62, attack = 44, defense = 50, speed = 55, specialA = 44, specialD = 50 },
      catchRate = 190, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SWANNA", level = 35 },
      },
      heightM = 0.5, weightKg = 5.5,
      dexEntry = { kind = "Water Bird Pokémon",
        text = "When attacked, it uses its feathers to splash water, escaping under cover of the spray." },
    },

    SWANNA = {
      dex = 581, name = "Swanna", types = { "WATER", "FLYING" },
      baseStats = { hp = 75, attack = 87, defense = 63, speed = 98, specialA = 87, specialD = 63 },
      catchRate = 45, baseExp = 166, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 24.2,
      dexEntry = { kind = "White Bird Pokémon",
        text = "Despite their elegant appearance, they can flap their wings strongly and fly for thousands of miles." },
    },

    VANILLITE = {
      dex = 582, name = "Vanillite", types = { "ICE" },
      baseStats = { hp = 36, attack = 50, defense = 50, speed = 44, specialA = 65, specialD = 60 },
      catchRate = 255, baseExp = 61, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "VANILLISH", level = 35 },
      },
      heightM = 0.4, weightKg = 5.7,
      dexEntry = { kind = "Fresh Snow Pokémon",
        text = "Unable to survive in hot areas, it makes itself comfortable by breathing out air cold enough to cause snow. It burrows into the snow to sleep." },
    },

    VANILLISH = {
      dex = 583, name = "Vanillish", types = { "ICE" },
      baseStats = { hp = 51, attack = 65, defense = 65, speed = 59, specialA = 80, specialD = 75 },
      catchRate = 120, baseExp = 138, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "VANILLUXE", level = 47 },
      },
      heightM = 1.1, weightKg = 41,
      dexEntry = { kind = "Icy Snow Pokémon",
        text = "By drinking pure water, it grows its icy body. This Pokémon can be hard to find on days with warm, sunny weather." },
    },

    VANILLUXE = {
      dex = 584, name = "Vanilluxe", types = { "ICE" },
      baseStats = { hp = 71, attack = 95, defense = 85, speed = 79, specialA = 110, specialD = 95 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 57.5,
      dexEntry = { kind = "Snowstorm Pokémon",
        text = "When its anger reaches a breaking point, this Pokémon unleashes a fierce blizzard that freezes every creature around it, be they friend or foe." },
    },

    DEERLING = {
      dex = 585, name = "Deerling", types = { "NORMAL", "GRASS" },
      baseStats = { hp = 60, attack = 60, defense = 50, speed = 75, specialA = 40, specialD = 50 },
      catchRate = 190, baseExp = 67, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SAWSBUCK", level = 34 },
      },
      heightM = 0.6, weightKg = 19.5,
      dexEntry = { kind = "Season Pokémon",
        text = "Their coloring changes according to the seasons and can be slightly affected by the temperature and humidity as well." },
    },

    SAWSBUCK = {
      dex = 586, name = "Sawsbuck", types = { "NORMAL", "GRASS" },
      baseStats = { hp = 80, attack = 100, defense = 70, speed = 95, specialA = 60, specialD = 70 },
      catchRate = 75, baseExp = 166, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 92.5,
      dexEntry = { kind = "Season Pokémon",
        text = "They migrate according to the seasons. People can tell the season by looking at Sawsbuck’s horns." },
    },

    EMOLGA = {
      dex = 587, name = "Emolga", types = { "ELECTRIC", "FLYING" },
      baseStats = { hp = 55, attack = 75, defense = 60, speed = 103, specialA = 75, specialD = 60 },
      catchRate = 200, baseExp = 150, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.4, weightKg = 5,
      dexEntry = { kind = "Sky Squirrel Pokémon",
        text = "As Emolga flutters through the air, it crackles with electricity. This Pokémon is cute, but it can cause a lot of trouble." },
    },

    KARRABLAST = {
      dex = 588, name = "Karrablast", types = { "BUG" },
      baseStats = { hp = 50, attack = 75, defense = 45, speed = 60, specialA = 40, specialD = 45 },
      catchRate = 200, baseExp = 63, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "TRADESPECIES", species = "ESCAVALIER" },
      },
      heightM = 0.5, weightKg = 5.9,
      dexEntry = { kind = "Clamping Pokémon",
        text = "Its strange physiology reacts to electrical energy in interesting ways. The presence of a Shelmet will cause this Pokémon to evolve." },
    },

    ESCAVALIER = {
      dex = 589, name = "Escavalier", types = { "BUG", "STEEL" },
      baseStats = { hp = 70, attack = 135, defense = 105, speed = 20, specialA = 60, specialD = 105 },
      catchRate = 75, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 33,
      dexEntry = { kind = "Cavalry Pokémon",
        text = "They use shells they’ve stolen from Shelmet to arm and protect themselves. They’re very popular Pokémon in the Galar region." },
    },

    FOONGUS = {
      dex = 590, name = "Foongus", types = { "GRASS", "POISON" },
      baseStats = { hp = 69, attack = 55, defense = 45, speed = 15, specialA = 55, specialD = 55 },
      catchRate = 190, baseExp = 59, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "AMOONGUSS", level = 39 },
      },
      heightM = 0.2, weightKg = 1,
      dexEntry = { kind = "Mushroom Pokémon",
        text = "No one knows what the Poké Ball–like pattern on Foongus means or why Foongus has it." },
    },

    AMOONGUSS = {
      dex = 591, name = "Amoonguss", types = { "GRASS", "POISON" },
      baseStats = { hp = 114, attack = 85, defense = 70, speed = 30, specialA = 85, specialD = 80 },
      catchRate = 75, baseExp = 162, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.6, weightKg = 10.5,
      dexEntry = { kind = "Mushroom Pokémon",
        text = "This Pokémon puffs poisonous spores at its foes. If the spores aren’t washed off quickly, they’ll grow into mushrooms wherever they land." },
    },

    FRILLISH = {
      dex = 592, name = "Frillish", types = { "WATER", "GHOST" },
      baseStats = { hp = 55, attack = 40, defense = 50, speed = 40, specialA = 65, specialD = 85 },
      catchRate = 190, baseExp = 67, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "JELLICENT", level = 40 },
      },
      heightM = 1.2, weightKg = 33,
      dexEntry = { kind = "Floating Pokémon",
        text = "It envelops its prey in its veillike arms and draws it down to the deeps, five miles below the ocean’s surface." },
    },

    JELLICENT = {
      dex = 593, name = "Jellicent", types = { "WATER", "GHOST" },
      baseStats = { hp = 100, attack = 60, defense = 70, speed = 60, specialA = 85, specialD = 105 },
      catchRate = 60, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2.2, weightKg = 135,
      dexEntry = { kind = "Floating Pokémon",
        text = "Most of this Pokémon’s body composition is identical to sea water. It makes sunken ships its lair." },
    },

    ALOMOMOLA = {
      dex = 594, name = "Alomomola", types = { "WATER" },
      baseStats = { hp = 165, attack = 75, defense = 80, speed = 65, specialA = 40, specialD = 45 },
      catchRate = 75, baseExp = 165, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 31.6,
      dexEntry = { kind = "Caring Pokémon",
        text = "Fishermen take them along on long voyages, because if you have an Alomomola with you, there’ll be no need for a doctor or medicine." },
    },

    JOLTIK = {
      dex = 595, name = "Joltik", types = { "BUG", "ELECTRIC" },
      baseStats = { hp = 50, attack = 47, defense = 50, speed = 65, specialA = 57, specialD = 50 },
      catchRate = 190, baseExp = 64, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GALVANTULA", level = 36 },
      },
      heightM = 0.1, weightKg = 0.6,
      dexEntry = { kind = "Attaching Pokémon",
        text = "Joltik can be found clinging to other Pokémon. It’s soaking up static electricity because it can’t produce a charge on its own." },
    },

    GALVANTULA = {
      dex = 596, name = "Galvantula", types = { "BUG", "ELECTRIC" },
      baseStats = { hp = 70, attack = 77, defense = 60, speed = 108, specialA = 97, specialD = 60 },
      catchRate = 75, baseExp = 165, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 14.3,
      dexEntry = { kind = "EleSpider Pokémon",
        text = "It launches electrified fur from its abdomen as its means of attack. Opponents hit by the fur could be in for three full days and nights of paralysis." },
    },

    FERROSEED = {
      dex = 597, name = "Ferroseed", types = { "GRASS", "STEEL" },
      baseStats = { hp = 44, attack = 50, defense = 91, speed = 10, specialA = 24, specialD = 86 },
      catchRate = 255, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FERROTHORN", level = 40 },
      },
      heightM = 0.6, weightKg = 18.8,
      dexEntry = { kind = "Thorn Seed Pokémon",
        text = "It defends itself by launching spikes, but its aim isn’t very good at first. Only after a lot of practice will it improve." },
    },

    FERROTHORN = {
      dex = 598, name = "Ferrothorn", types = { "GRASS", "STEEL" },
      baseStats = { hp = 74, attack = 94, defense = 131, speed = 20, specialA = 54, specialD = 116 },
      catchRate = 90, baseExp = 171, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 110,
      dexEntry = { kind = "Thorn Pod Pokémon",
        text = "This Pokémon scrapes its spikes across rocks, and then uses the tips of its feelers to absorb the nutrients it finds within the stone." },
    },

    KLINK = {
      dex = 599, name = "Klink", types = { "STEEL" },
      baseStats = { hp = 40, attack = 55, defense = 70, speed = 30, specialA = 45, specialD = 60 },
      catchRate = 130, baseExp = 60, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "KLANG", level = 38 },
      },
      heightM = 0.3, weightKg = 21,
      dexEntry = { kind = "Gear Pokémon",
        text = "The two minigears that compose this Pokémon are closer than twins. They mesh well only with each other." },
    },

    KLANG = {
      dex = 600, name = "Klang", types = { "STEEL" },
      baseStats = { hp = 60, attack = 80, defense = 95, speed = 50, specialA = 70, specialD = 85 },
      catchRate = 60, baseExp = 154, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "KLINKLANG", level = 49 },
      },
      heightM = 0.6, weightKg = 51,
      dexEntry = { kind = "Gear Pokémon",
        text = "When Klang goes all out, the minigear links up perfectly with the outer part of the big gear, and this Pokémon’s rotation speed increases sharply." },
    },

    KLINKLANG = {
      dex = 601, name = "Klinklang", types = { "STEEL" },
      baseStats = { hp = 60, attack = 100, defense = 115, speed = 90, specialA = 70, specialD = 85 },
      catchRate = 30, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.6, weightKg = 81,
      dexEntry = { kind = "Gear Pokémon",
        text = "From its spikes, it launches powerful blasts of electricity. Its red core contains an enormous amount of energy." },
    },

    TYNAMO = {
      dex = 602, name = "Tynamo", types = { "ELECTRIC" },
      baseStats = { hp = 35, attack = 55, defense = 40, speed = 60, specialA = 45, specialD = 40 },
      catchRate = 190, baseExp = 55, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "EELEKTRIK", level = 39 },
      },
      heightM = 0.2, weightKg = 0.3,
      dexEntry = { kind = "EleFish Pokémon",
        text = "While one alone doesn’t have much power, a chain of many Tynamo can be as powerful as lightning." },
    },

    EELEKTRIK = {
      dex = 603, name = "Eelektrik", types = { "ELECTRIC" },
      baseStats = { hp = 65, attack = 85, defense = 70, speed = 40, specialA = 75, specialD = 70 },
      catchRate = 60, baseExp = 142, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "EELEKTROSS", item = "THUNDERSTONE" },
      },
      heightM = 1.2, weightKg = 22,
      dexEntry = { kind = "EleFish Pokémon",
        text = "It wraps itself around its prey and paralyzes it with electricity from the round spots on its sides. Then it chomps." },
    },

    EELEKTROSS = {
      dex = 604, name = "Eelektross", types = { "ELECTRIC" },
      baseStats = { hp = 85, attack = 115, defense = 80, speed = 50, specialA = 105, specialD = 80 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.1, weightKg = 80.5,
      dexEntry = { kind = "EleFish Pokémon",
        text = "With their sucker mouths, they suck in prey. Then they use their fangs to shock the prey with electricity." },
    },

    ELGYEM = {
      dex = 605, name = "Elgyem", types = { "PSYCHIC" },
      baseStats = { hp = 55, attack = 55, defense = 55, speed = 30, specialA = 85, specialD = 55 },
      catchRate = 255, baseExp = 67, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BEHEEYEM", level = 42 },
      },
      heightM = 0.5, weightKg = 9,
      dexEntry = { kind = "Cerebral Pokémon",
        text = "If this Pokémon stands near a TV, strange scenery will appear on the screen. That scenery is said to be from its home." },
    },

    BEHEEYEM = {
      dex = 606, name = "Beheeyem", types = { "PSYCHIC" },
      baseStats = { hp = 75, attack = 75, defense = 75, speed = 40, specialA = 125, specialD = 95 },
      catchRate = 90, baseExp = 170, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 34.5,
      dexEntry = { kind = "Cerebral Pokémon",
        text = "Whenever a Beheeyem visits a farm, a Dubwool mysteriously disappears." },
    },

    LITWICK = {
      dex = 607, name = "Litwick", types = { "GHOST", "FIRE" },
      baseStats = { hp = 50, attack = 30, defense = 55, speed = 20, specialA = 65, specialD = 55 },
      catchRate = 190, baseExp = 55, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "LAMPENT", level = 41 },
      },
      heightM = 0.3, weightKg = 3.1,
      dexEntry = { kind = "Candle Pokémon",
        text = "The flame on its head keeps its body slightly warm. This Pokémon takes lost children by the hand to guide them to the spirit world." },
    },

    LAMPENT = {
      dex = 608, name = "Lampent", types = { "GHOST", "FIRE" },
      baseStats = { hp = 60, attack = 40, defense = 60, speed = 55, specialA = 95, specialD = 60 },
      catchRate = 90, baseExp = 130, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "CHANDELURE", item = "DUSKSTONE" },
      },
      heightM = 0.6, weightKg = 13,
      dexEntry = { kind = "Lamp Pokémon",
        text = "This Pokémon appears just before someone passes away, so it’s feared as an emissary of death." },
    },

    CHANDELURE = {
      dex = 609, name = "Chandelure", types = { "GHOST", "FIRE" },
      baseStats = { hp = 60, attack = 55, defense = 90, speed = 80, specialA = 145, specialD = 90 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 34.3,
      dexEntry = { kind = "Luring Pokémon",
        text = "This Pokémon haunts dilapidated mansions. It sways its arms to hypnotize opponents with the ominous dancing of its flames." },
    },

    AXEW = {
      dex = 610, name = "Axew", types = { "DRAGON" },
      baseStats = { hp = 46, attack = 87, defense = 60, speed = 57, specialA = 30, specialD = 40 },
      catchRate = 75, baseExp = 64, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "FRAXURE", level = 38 },
      },
      heightM = 0.6, weightKg = 18,
      dexEntry = { kind = "Tusk Pokémon",
        text = "These Pokémon nest in the ground and use their tusks to crush hard berries. Crushing berries is also how they test each other’s strength." },
    },

    FRAXURE = {
      dex = 611, name = "Fraxure", types = { "DRAGON" },
      baseStats = { hp = 66, attack = 117, defense = 70, speed = 67, specialA = 40, specialD = 50 },
      catchRate = 60, baseExp = 144, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "HAXORUS", level = 48 },
      },
      heightM = 1, weightKg = 36,
      dexEntry = { kind = "Axe Jaw Pokémon",
        text = "After battle, this Pokémon carefully sharpens its tusks on river rocks. It needs to take care of its tusks—if one breaks, it will never grow back." },
    },

    HAXORUS = {
      dex = 612, name = "Haxorus", types = { "DRAGON" },
      baseStats = { hp = 76, attack = 147, defense = 90, speed = 97, specialA = 60, specialD = 70 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.8, weightKg = 105.5,
      dexEntry = { kind = "Axe Jaw Pokémon",
        text = "Its resilient tusks are its pride and joy. It licks up dirt to take in the minerals it needs to keep its tusks in top condition." },
    },

    CUBCHOO = {
      dex = 613, name = "Cubchoo", types = { "ICE" },
      baseStats = { hp = 55, attack = 70, defense = 40, speed = 40, specialA = 60, specialD = 40 },
      catchRate = 120, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BEARTIC", level = 37 },
      },
      heightM = 0.5, weightKg = 8.5,
      dexEntry = { kind = "Chill Pokémon",
        text = "When this Pokémon is in good health, its snot becomes thicker and stickier. It will smear its snot on anyone it doesn’t like." },
    },

    BEARTIC = {
      dex = 614, name = "Beartic", types = { "ICE" },
      baseStats = { hp = 95, attack = 130, defense = 80, speed = 50, specialA = 70, specialD = 80 },
      catchRate = 60, baseExp = 177, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2.6, weightKg = 260,
      dexEntry = { kind = "Freezing Pokémon",
        text = "It swims through frigid seas, searching for prey. From its frozen breath, it forms icy fangs that are harder than steel." },
    },

    CRYOGONAL = {
      dex = 615, name = "Cryogonal", types = { "ICE" },
      baseStats = { hp = 80, attack = 50, defense = 50, speed = 105, specialA = 95, specialD = 135 },
      catchRate = 25, baseExp = 180, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 148,
      dexEntry = { kind = "Crystallizing Pokémon",
        text = "With its icy chains, Cryogonal freezes those it encounters. It then takes its victims away to somewhere unknown." },
    },

    SHELMET = {
      dex = 616, name = "Shelmet", types = { "BUG" },
      baseStats = { hp = 50, attack = 40, defense = 85, speed = 25, specialA = 40, specialD = 65 },
      catchRate = 200, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "TRADESPECIES", species = "ACCELGOR" },
      },
      heightM = 0.4, weightKg = 7.7,
      dexEntry = { kind = "Snail Pokémon",
        text = "When attacked, it tightly shuts the lid of its shell. This reaction fails to protect it from Karrablast, however, because they can still get into the shell." },
    },

    ACCELGOR = {
      dex = 617, name = "Accelgor", types = { "BUG" },
      baseStats = { hp = 80, attack = 70, defense = 40, speed = 145, specialA = 100, specialD = 60 },
      catchRate = 75, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 25.3,
      dexEntry = { kind = "Shell Out Pokémon",
        text = "It moves with blinding speed and lobs poison at foes. Featuring Accelgor as a main character is a surefire way to make a movie or comic popular." },
    },

    STUNFISK = {
      dex = 618, name = "Stunfisk", types = { "GROUND", "ELECTRIC" },
      baseStats = { hp = 109, attack = 66, defense = 84, speed = 32, specialA = 81, specialD = 99 },
      catchRate = 75, baseExp = 165, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 11,
      dexEntry = { kind = "Trap Pokémon",
        text = "Thanks to bacteria that lived in the mud flats with it, this Pokémon developed the organs it uses to generate electricity." },
    },

    MIENFOO = {
      dex = 619, name = "Mienfoo", types = { "FIGHTING" },
      baseStats = { hp = 45, attack = 85, defense = 50, speed = 65, specialA = 55, specialD = 50 },
      catchRate = 180, baseExp = 70, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MIENSHAO", level = 50 },
      },
      heightM = 0.9, weightKg = 20,
      dexEntry = { kind = "Martial Arts Pokémon",
        text = "In one minute, a well-trained Mienfoo can chop with its arms more than 100 times." },
    },

    MIENSHAO = {
      dex = 620, name = "Mienshao", types = { "FIGHTING" },
      baseStats = { hp = 65, attack = 125, defense = 60, speed = 105, specialA = 95, specialD = 60 },
      catchRate = 45, baseExp = 179, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 35.5,
      dexEntry = { kind = "Martial Arts Pokémon",
        text = "When Mienshao comes across a truly challenging opponent, it will lighten itself by biting off the fur on its arms." },
    },

    DRUDDIGON = {
      dex = 621, name = "Druddigon", types = { "DRAGON" },
      baseStats = { hp = 77, attack = 120, defense = 90, speed = 48, specialA = 60, specialD = 90 },
      catchRate = 45, baseExp = 170, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 139,
      dexEntry = { kind = "Cave Pokémon",
        text = "Druddigon lives in caves, but it never skips sunbathing—it won’t be able to move if its body gets too cold." },
    },

    GOLETT = {
      dex = 622, name = "Golett", types = { "GROUND", "GHOST" },
      baseStats = { hp = 59, attack = 74, defense = 50, speed = 35, specialA = 35, specialD = 50 },
      catchRate = 190, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GOLURK", level = 43 },
      },
      heightM = 1, weightKg = 92,
      dexEntry = { kind = "Automaton Pokémon",
        text = "They were sculpted from clay in ancient times. No one knows why, but some of them are driven to continually line up boulders." },
    },

    GOLURK = {
      dex = 623, name = "Golurk", types = { "GROUND", "GHOST" },
      baseStats = { hp = 89, attack = 124, defense = 80, speed = 55, specialA = 55, specialD = 80 },
      catchRate = 90, baseExp = 169, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2.8, weightKg = 330,
      dexEntry = { kind = "Automaton Pokémon",
        text = "Artillery platforms built into the walls of ancient castles served as perches from which Golurk could fire energy beams." },
    },

    PAWNIARD = {
      dex = 624, name = "Pawniard", types = { "DARK", "STEEL" },
      baseStats = { hp = 45, attack = 85, defense = 70, speed = 60, specialA = 40, specialD = 40 },
      catchRate = 120, baseExp = 68, growthRate = "MEDIUM_FAST", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "BISHARP", level = 52 },
      },
      heightM = 0.5, weightKg = 10.2,
      dexEntry = { kind = "Sharp Blade Pokémon",
        text = "It uses river stones to maintain the cutting edges of the blades covering its body. These sharpened blades allow it to bring down opponents." },
    },

    BISHARP = {
      dex = 625, name = "Bisharp", types = { "DARK", "STEEL" },
      baseStats = { hp = 65, attack = 125, defense = 100, speed = 70, specialA = 60, specialD = 70 },
      catchRate = 45, baseExp = 172, growthRate = "MEDIUM_FAST", happiness = 35,
      evolutions = {
        { method = "LEVELDEFEATITSKINDWITHITEM", species = "KINGAMBIT" },
      },
      heightM = 1.6, weightKg = 70,
      dexEntry = { kind = "Sword Blade Pokémon",
        text = "It’s accompanied by a large retinue of Pawniard. Bisharp keeps a keen eye on its minions, ensuring none of them even think of double-crossing it." },
    },

    BOUFFALANT = {
      dex = 626, name = "Bouffalant", types = { "NORMAL" },
      baseStats = { hp = 95, attack = 110, defense = 95, speed = 55, specialA = 40, specialD = 95 },
      catchRate = 45, baseExp = 172, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 94.5,
      dexEntry = { kind = "Bash Buffalo Pokémon",
        text = "These Pokémon can crush a car with no more than a headbutt. Bouffalant with more hair on their heads hold higher positions within the herd." },
    },

    RUFFLET = {
      dex = 627, name = "Rufflet", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 70, attack = 83, defense = 50, speed = 60, specialA = 37, specialD = 50 },
      catchRate = 190, baseExp = 70, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BRAVIARY", level = 54 },
      },
      heightM = 0.5, weightKg = 10.5,
      dexEntry = { kind = "Eaglet Pokémon",
        text = "If it spies a strong Pokémon, Rufflet can’t resist challenging it to a battle. But if Rufflet loses, it starts bawling." },
    },

    BRAVIARY = {
      dex = 628, name = "Braviary", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 100, attack = 123, defense = 75, speed = 80, specialA = 57, specialD = 75 },
      catchRate = 60, baseExp = 179, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 41,
      dexEntry = { kind = "Valiant Pokémon",
        text = "Known for its bravery and pride, this majestic Pokémon is often seen as a motif for various kinds of emblems." },
    },

    VULLABY = {
      dex = 629, name = "Vullaby", types = { "DARK", "FLYING" },
      baseStats = { hp = 70, attack = 55, defense = 75, speed = 60, specialA = 45, specialD = 65 },
      catchRate = 190, baseExp = 74, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "MANDIBUZZ", level = 54 },
      },
      heightM = 0.5, weightKg = 9,
      dexEntry = { kind = "Diapered Pokémon",
        text = "It wears a bone to protect its rear. It often squabbles with others of its kind over particularly comfy bones." },
    },

    MANDIBUZZ = {
      dex = 630, name = "Mandibuzz", types = { "DARK", "FLYING" },
      baseStats = { hp = 110, attack = 65, defense = 105, speed = 80, specialA = 55, specialD = 95 },
      catchRate = 60, baseExp = 179, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.2, weightKg = 39.5,
      dexEntry = { kind = "Bone Vulture Pokémon",
        text = "Although it’s a bit of a ruffian, this Pokémon will take lost Vullaby under its wing and care for them till they’re ready to leave the nest." },
    },

    HEATMOR = {
      dex = 631, name = "Heatmor", types = { "FIRE" },
      baseStats = { hp = 85, attack = 97, defense = 66, speed = 65, specialA = 105, specialD = 66 },
      catchRate = 90, baseExp = 169, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 58,
      dexEntry = { kind = "Anteater Pokémon",
        text = "There’s a hole in its tail that allows it to draw in the air it needs to keep its fire burning. If the hole gets blocked, this Pokémon will fall ill." },
    },

    DURANT = {
      dex = 632, name = "Durant", types = { "BUG", "STEEL" },
      baseStats = { hp = 58, attack = 109, defense = 112, speed = 109, specialA = 48, specialD = 48 },
      catchRate = 90, baseExp = 169, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 33,
      dexEntry = { kind = "Iron Ant Pokémon",
        text = "They lay their eggs deep inside their nests. When attacked by Heatmor, they retaliate using their massive mandibles." },
    },

    DEINO = {
      dex = 633, name = "Deino", types = { "DARK", "DRAGON" },
      baseStats = { hp = 52, attack = 65, defense = 50, speed = 38, specialA = 45, specialD = 50 },
      catchRate = 45, baseExp = 60, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "ZWEILOUS", level = 50 },
      },
      heightM = 0.8, weightKg = 17.3,
      dexEntry = { kind = "Irate Pokémon",
        text = "When it encounters something, its first urge is usually to bite it. If it likes what it tastes, it will commit the associated scent to memory." },
    },

    ZWEILOUS = {
      dex = 634, name = "Zweilous", types = { "DARK", "DRAGON" },
      baseStats = { hp = 72, attack = 85, defense = 70, speed = 58, specialA = 65, specialD = 70 },
      catchRate = 45, baseExp = 147, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "HYDREIGON", level = 64 },
      },
      heightM = 1.4, weightKg = 50,
      dexEntry = { kind = "Hostile Pokémon",
        text = "While hunting for prey, Zweilous wanders its territory, its two heads often bickering over which way to go." },
    },

    HYDREIGON = {
      dex = 635, name = "Hydreigon", types = { "DARK", "DRAGON" },
      baseStats = { hp = 92, attack = 105, defense = 90, speed = 98, specialA = 125, specialD = 90 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.8, weightKg = 160,
      dexEntry = { kind = "Brutal Pokémon",
        text = "There are a slew of stories about villages that were destroyed by Hydreigon. It bites anything that moves." },
    },

    LARVESTA = {
      dex = 636, name = "Larvesta", types = { "BUG", "FIRE" },
      baseStats = { hp = 55, attack = 85, defense = 55, speed = 60, specialA = 50, specialD = 55 },
      catchRate = 45, baseExp = 72, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "VOLCARONA", level = 59 },
      },
      heightM = 1.1, weightKg = 28.8,
      dexEntry = { kind = "Torch Pokémon",
        text = "The people of ancient times believed that Larvesta fell from the sun." },
    },

    VOLCARONA = {
      dex = 637, name = "Volcarona", types = { "BUG", "FIRE" },
      baseStats = { hp = 85, attack = 60, defense = 65, speed = 100, specialA = 135, specialD = 105 },
      catchRate = 15, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 46,
      dexEntry = { kind = "Sun Pokémon",
        text = "Volcarona scatters burning scales. Some say it does this to start fires. Others say it’s trying to rescue those that suffer in the cold." },
    },

    COBALION = {
      dex = 638, name = "Cobalion", types = { "STEEL", "FIGHTING" },
      baseStats = { hp = 91, attack = 90, defense = 129, speed = 108, specialA = 90, specialD = 72 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2.1, weightKg = 250,
      dexEntry = { kind = "Iron Will Pokémon",
        text = "This Pokémon appears in a legend alongside Terrakion and Virizion, fighting against humans in defense of the Unova region’s Pokémon." },
    },

    TERRAKION = {
      dex = 639, name = "Terrakion", types = { "ROCK", "FIGHTING" },
      baseStats = { hp = 91, attack = 129, defense = 90, speed = 108, specialA = 72, specialD = 90 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.9, weightKg = 260,
      dexEntry = { kind = "Cavern Pokémon",
        text = "It has phenomenal power. It will mercilessly crush anyone or anything that bullies small Pokémon." },
    },

    VIRIZION = {
      dex = 640, name = "Virizion", types = { "GRASS", "FIGHTING" },
      baseStats = { hp = 91, attack = 90, defense = 72, speed = 108, specialA = 90, specialD = 129 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2, weightKg = 200,
      dexEntry = { kind = "Grassland Pokémon",
        text = "A legend tells of this Pokémon working together with Cobalion and Terrakion to protect the Pokémon of the Unova region." },
    },

    TORNADUS = {
      dex = 641, name = "Tornadus", types = { "FLYING" },
      baseStats = { hp = 79, attack = 115, defense = 70, speed = 111, specialA = 125, specialD = 80 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 90,
      evolutions = {},
      heightM = 1.5, weightKg = 63,
      dexEntry = { kind = "Cyclone Pokémon",
        text = "The lower half of its body is wrapped in a cloud of energy. It zooms through the sky at 200 mph." },
    },

    THUNDURUS = {
      dex = 642, name = "Thundurus", types = { "ELECTRIC", "FLYING" },
      baseStats = { hp = 79, attack = 115, defense = 70, speed = 111, specialA = 125, specialD = 80 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 90,
      evolutions = {},
      heightM = 1.5, weightKg = 61,
      dexEntry = { kind = "Bolt Strike Pokémon",
        text = "The spikes on its tail discharge immense bolts of lightning. It flies around the Unova region firing off lightning bolts." },
    },

    RESHIRAM = {
      dex = 643, name = "Reshiram", types = { "DRAGON", "FIRE" },
      baseStats = { hp = 100, attack = 120, defense = 100, speed = 90, specialA = 150, specialD = 120 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.2, weightKg = 330,
      dexEntry = { kind = "Vast White Pokémon",
        text = "This legendary Pokémon can scorch the world with fire. It helps those who want to build a world of truth." },
    },

    ZEKROM = {
      dex = 644, name = "Zekrom", types = { "DRAGON", "ELECTRIC" },
      baseStats = { hp = 100, attack = 150, defense = 120, speed = 90, specialA = 120, specialD = 100 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2.9, weightKg = 345,
      dexEntry = { kind = "Deep Black Pokémon",
        text = "This legendary Pokémon can scorch the world with lightning. It assists those who want to build an ideal world." },
    },

    LANDORUS = {
      dex = 645, name = "Landorus", types = { "GROUND", "FLYING" },
      baseStats = { hp = 89, attack = 125, defense = 90, speed = 101, specialA = 115, specialD = 80 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 90,
      evolutions = {},
      heightM = 1.5, weightKg = 68,
      dexEntry = { kind = "Abundance Pokémon",
        text = "Lands visited by Landorus grant such bountiful crops that it has been hailed as “The Guardian of the Fields.”" },
    },

    KYUREM = {
      dex = 646, name = "Kyurem", types = { "DRAGON", "ICE" },
      baseStats = { hp = 125, attack = 130, defense = 90, speed = 95, specialA = 130, specialD = 90 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3, weightKg = 325,
      dexEntry = { kind = "Boundary Pokémon",
        text = "This legendary ice Pokémon waits for a hero to fill in the missing parts of its body with truth or ideals." },
    },

    KELDEO = {
      dex = 647, name = "Keldeo", types = { "WATER", "FIGHTING" },
      baseStats = { hp = 91, attack = 72, defense = 90, speed = 108, specialA = 129, specialD = 90 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.4, weightKg = 48.5,
      dexEntry = { kind = "Colt Pokémon",
        text = "It crosses the world, running over the surfaces of oceans and rivers. It appears at scenic waterfronts." },
    },

    MELOETTA = {
      dex = 648, name = "Meloetta", types = { "NORMAL", "PSYCHIC" },
      baseStats = { hp = 100, attack = 77, defense = 77, speed = 90, specialA = 128, specialD = 128 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 100,
      evolutions = {},
      heightM = 0.6, weightKg = 6.5,
      dexEntry = { kind = "Melody Pokémon",
        text = "The melodies sung by Meloetta have the power to make Pokémon that hear them happy or sad." },
    },

    GENESECT = {
      dex = 649, name = "Genesect", types = { "BUG", "STEEL" },
      baseStats = { hp = 71, attack = 120, defense = 95, speed = 99, specialA = 120, specialD = 95 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.5, weightKg = 82.5,
      dexEntry = { kind = "Paleozoic Pokémon",
        text = "This ancient bug Pokémon was altered by Team Plasma. They upgraded the cannon on its back." },
    },

    CHESPIN = {
      dex = 650, name = "Chespin", types = { "GRASS" },
      baseStats = { hp = 56, attack = 61, defense = 65, speed = 38, specialA = 48, specialD = 45 },
      catchRate = 45, baseExp = 63, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "QUILLADIN", level = 16 },
      },
      heightM = 0.4, weightKg = 9,
      dexEntry = { kind = "Spiky Nut Pokémon",
        text = "The quills on its head are usually soft. When it flexes them, the points become so hard and sharp that they can pierce rock." },
    },

    QUILLADIN = {
      dex = 651, name = "Quilladin", types = { "GRASS" },
      baseStats = { hp = 61, attack = 78, defense = 95, speed = 57, specialA = 56, specialD = 58 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CHESNAUGHT", level = 36 },
      },
      heightM = 0.7, weightKg = 29,
      dexEntry = { kind = "Spiny Armor Pokémon",
        text = "It relies on its sturdy shell to deflect predators’ attacks. It counterattacks with its sharp quills." },
    },

    CHESNAUGHT = {
      dex = 652, name = "Chesnaught", types = { "GRASS", "FIGHTING" },
      baseStats = { hp = 88, attack = 107, defense = 122, speed = 64, specialA = 74, specialD = 75 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 90,
      dexEntry = { kind = "Spiny Armor Pokémon",
        text = "Its Tackle is forceful enough to flip a 50-ton tank. It shields its allies from danger with its own body." },
    },

    FENNEKIN = {
      dex = 653, name = "Fennekin", types = { "FIRE" },
      baseStats = { hp = 40, attack = 45, defense = 40, speed = 60, specialA = 62, specialD = 60 },
      catchRate = 45, baseExp = 61, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BRAIXEN", level = 16 },
      },
      heightM = 0.4, weightKg = 9.4,
      dexEntry = { kind = "Fox Pokémon",
        text = "Eating a twig fills it with energy, and its roomy ears give vent to air hotter than 390 degrees Fahrenheit." },
    },

    BRAIXEN = {
      dex = 654, name = "Braixen", types = { "FIRE" },
      baseStats = { hp = 59, attack = 59, defense = 58, speed = 73, specialA = 90, specialD = 70 },
      catchRate = 45, baseExp = 143, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DELPHOX", level = 36 },
      },
      heightM = 1, weightKg = 14.5,
      dexEntry = { kind = "Fox Pokémon",
        text = "It has a twig stuck in its tail. With friction from its tail fur, it sets the twig on fire and launches into battle." },
    },

    DELPHOX = {
      dex = 655, name = "Delphox", types = { "FIRE", "PSYCHIC" },
      baseStats = { hp = 75, attack = 69, defense = 72, speed = 104, specialA = 114, specialD = 100 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 39,
      dexEntry = { kind = "Fox Pokémon",
        text = "It gazes into the flame at the tip of its branch to achieve a focused state, which allows it to see into the future." },
    },

    FROAKIE = {
      dex = 656, name = "Froakie", types = { "WATER" },
      baseStats = { hp = 41, attack = 56, defense = 40, speed = 71, specialA = 62, specialD = 44 },
      catchRate = 45, baseExp = 63, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FROGADIER", level = 16 },
      },
      heightM = 0.3, weightKg = 7,
      dexEntry = { kind = "Bubble Frog Pokémon",
        text = "It secretes flexible bubbles from its chest and back. The bubbles reduce the damage it would otherwise take when attacked." },
    },

    FROGADIER = {
      dex = 657, name = "Frogadier", types = { "WATER" },
      baseStats = { hp = 54, attack = 63, defense = 52, speed = 97, specialA = 83, specialD = 56 },
      catchRate = 45, baseExp = 142, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GRENINJA", level = 36 },
      },
      heightM = 0.6, weightKg = 10.9,
      dexEntry = { kind = "Bubble Frog Pokémon",
        text = "It can throw bubble-covered pebbles with precise control, hitting empty cans up to a hundred feet away." },
    },

    GRENINJA = {
      dex = 658, name = "Greninja", types = { "WATER", "DARK" },
      baseStats = { hp = 72, attack = 95, defense = 67, speed = 122, specialA = 103, specialD = 71 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 40,
      dexEntry = { kind = "Ninja Pokémon",
        text = "It creates throwing stars out of compressed water. When it spins them and throws them at high speed, these stars can split metal in two." },
    },

    BUNNELBY = {
      dex = 659, name = "Bunnelby", types = { "NORMAL" },
      baseStats = { hp = 38, attack = 36, defense = 38, speed = 57, specialA = 32, specialD = 36 },
      catchRate = 255, baseExp = 47, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DIGGERSBY", level = 20 },
      },
      heightM = 0.4, weightKg = 5,
      dexEntry = { kind = "Digging Pokémon",
        text = "It excels at digging holes. Using its ears, it can dig a nest 33 feet deep in one night." },
    },

    DIGGERSBY = {
      dex = 660, name = "Diggersby", types = { "NORMAL", "GROUND" },
      baseStats = { hp = 85, attack = 56, defense = 77, speed = 78, specialA = 50, specialD = 77 },
      catchRate = 127, baseExp = 148, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 42.4,
      dexEntry = { kind = "Digging Pokémon",
        text = "With power equal to an excavator, it can dig through dense bedrock. It’s a huge help during tunnel construction." },
    },

    FLETCHLING = {
      dex = 661, name = "Fletchling", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 45, attack = 50, defense = 43, speed = 62, specialA = 40, specialD = 38 },
      catchRate = 255, baseExp = 56, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FLETCHINDER", level = 17 },
      },
      heightM = 0.3, weightKg = 1.7,
      dexEntry = { kind = "Tiny Robin Pokémon",
        text = "Its melodious cries are actually warnings. Fletchling will mercilessly peck at anything that enters its territory." },
    },

    FLETCHINDER = {
      dex = 662, name = "Fletchinder", types = { "FIRE", "FLYING" },
      baseStats = { hp = 62, attack = 73, defense = 55, speed = 84, specialA = 56, specialD = 52 },
      catchRate = 120, baseExp = 134, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TALONFLAME", level = 35 },
      },
      heightM = 0.7, weightKg = 16,
      dexEntry = { kind = "Ember Pokémon",
        text = "Fletchinder launches embers into the den of its prey. When the prey comes leaping out, Fletchinder’s sharp talons finish it off." },
    },

    TALONFLAME = {
      dex = 663, name = "Talonflame", types = { "FIRE", "FLYING" },
      baseStats = { hp = 78, attack = 81, defense = 71, speed = 126, specialA = 74, specialD = 69 },
      catchRate = 45, baseExp = 175, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 24.5,
      dexEntry = { kind = "Scorching Pokémon",
        text = "Talonflame mainly preys upon other bird Pokémon. To intimidate opponents, it sends embers spewing from gaps between its feathers." },
    },

    SCATTERBUG = {
      dex = 664, name = "Scatterbug", types = { "BUG" },
      baseStats = { hp = 38, attack = 35, defense = 40, speed = 35, specialA = 27, specialD = 25 },
      catchRate = 255, baseExp = 40, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SPEWPA", level = 9 },
      },
      heightM = 0.3, weightKg = 2.5,
      dexEntry = { kind = "Scatterdust Pokémon",
        text = "When under attack from bird Pokémon, it spews a poisonous black powder that causes paralysis on contact." },
    },

    SPEWPA = {
      dex = 665, name = "Spewpa", types = { "BUG" },
      baseStats = { hp = 45, attack = 22, defense = 60, speed = 29, specialA = 27, specialD = 30 },
      catchRate = 120, baseExp = 75, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "VIVILLON", level = 12 },
      },
      heightM = 0.3, weightKg = 8.4,
      dexEntry = { kind = "Scatterdust Pokémon",
        text = "It lives hidden within thicket shadows. When predators attack, it quickly bristles the fur covering its body in an effort to threaten them." },
    },

    VIVILLON = {
      dex = 666, name = "Vivillon", types = { "BUG", "FLYING" },
      baseStats = { hp = 80, attack = 52, defense = 50, speed = 89, specialA = 90, specialD = 50 },
      catchRate = 45, baseExp = 206, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 17,
      dexEntry = { kind = "Scale Pokémon",
        text = "Vivillon with many different patterns are found all over the world. These patterns are affected by the climate of their habitat." },
    },

    LITLEO = {
      dex = 667, name = "Litleo", types = { "FIRE", "NORMAL" },
      baseStats = { hp = 62, attack = 50, defense = 58, speed = 72, specialA = 73, specialD = 54 },
      catchRate = 220, baseExp = 74, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PYROAR", level = 35 },
      },
      heightM = 0.6, weightKg = 13.5,
      dexEntry = { kind = "Lion Cub Pokémon",
        text = "When they’re young, they live with a pride. Once they’re able to hunt prey on their own, they’re kicked out and have to make their own way." },
    },

    PYROAR = {
      dex = 668, name = "Pyroar", types = { "FIRE", "NORMAL" },
      baseStats = { hp = 86, attack = 68, defense = 72, speed = 106, specialA = 109, specialD = 66 },
      catchRate = 65, baseExp = 177, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 81.5,
      dexEntry = { kind = "Royal Pokémon",
        text = "The males are usually lazy, but when attacked by a strong foe, a male will protect its friends with no regard for its own safety." },
    },

    FLABEBE = {
      dex = 669, name = "Flabébé", types = { "FAIRY" },
      baseStats = { hp = 44, attack = 38, defense = 39, speed = 42, specialA = 61, specialD = 79 },
      catchRate = 225, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FLOETTE", level = 19 },
      },
      heightM = 0.1, weightKg = 0.1,
      dexEntry = { kind = "Single Bloom Pokémon",
        text = "It’s not safe without the power of a flower, but it will keep traveling around until it finds one with the color and shape it wants." },
    },

    FLOETTE = {
      dex = 670, name = "Floette", types = { "FAIRY" },
      baseStats = { hp = 54, attack = 45, defense = 47, speed = 52, specialA = 75, specialD = 98 },
      catchRate = 120, baseExp = 130, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "FLORGES", item = "SHINYSTONE" },
      },
      heightM = 0.2, weightKg = 0.9,
      dexEntry = { kind = "Fairy Pokémon",
        text = "It raises flowers and uses them as weapons. The more gorgeous the blossom, the more power it contains." },
    },

    FLORGES = {
      dex = 671, name = "Florges", types = { "FAIRY" },
      baseStats = { hp = 78, attack = 65, defense = 68, speed = 75, specialA = 112, specialD = 154 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 10,
      dexEntry = { kind = "Garden Pokémon",
        text = "It controls the flowers it grows. The petal blizzards that Florges triggers are overwhelming in their beauty and power." },
    },

    SKIDDO = {
      dex = 672, name = "Skiddo", types = { "GRASS" },
      baseStats = { hp = 66, attack = 65, defense = 48, speed = 52, specialA = 62, specialD = 57 },
      catchRate = 200, baseExp = 70, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GOGOAT", level = 32 },
      },
      heightM = 0.9, weightKg = 31,
      dexEntry = { kind = "Mount Pokémon",
        text = "Thought to be one of the first Pokémon to live in harmony with humans, it has a placid disposition." },
    },

    GOGOAT = {
      dex = 673, name = "Gogoat", types = { "GRASS" },
      baseStats = { hp = 123, attack = 100, defense = 62, speed = 68, specialA = 97, specialD = 81 },
      catchRate = 45, baseExp = 186, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 91,
      dexEntry = { kind = "Mount Pokémon",
        text = "It can tell how its Trainer is feeling by subtle shifts in the grip on its horns. This empathic sense lets them run as if one being." },
    },

    PANCHAM = {
      dex = 674, name = "Pancham", types = { "FIGHTING" },
      baseStats = { hp = 67, attack = 82, defense = 62, speed = 43, specialA = 46, specialD = 48 },
      catchRate = 220, baseExp = 70, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVELDARKINPARTY", species = "PANGORO" },
      },
      heightM = 0.6, weightKg = 8,
      dexEntry = { kind = "Playful Pokémon",
        text = "It chooses a Pangoro as its master and then imitates its master’s actions. This is how it learns to battle and hunt for prey." },
    },

    PANGORO = {
      dex = 675, name = "Pangoro", types = { "FIGHTING", "DARK" },
      baseStats = { hp = 95, attack = 124, defense = 78, speed = 58, specialA = 69, specialD = 71 },
      catchRate = 65, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2.1, weightKg = 136,
      dexEntry = { kind = "Daunting Pokémon",
        text = "This Pokémon is quick to anger, and it has no problem using its prodigious strength to get its way. It lives for duels against Obstagoon." },
    },

    FURFROU = {
      dex = 676, name = "Furfrou", types = { "NORMAL" },
      baseStats = { hp = 75, attack = 80, defense = 60, speed = 102, specialA = 65, specialD = 90 },
      catchRate = 160, baseExp = 165, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 28,
      dexEntry = { kind = "Poodle Pokémon",
        text = "There was an era when aristocrats would compete to see who could trim their Furfrou’s fur into the most exquisite style." },
    },

    ESPURR = {
      dex = 677, name = "Espurr", types = { "PSYCHIC" },
      baseStats = { hp = 62, attack = 48, defense = 54, speed = 68, specialA = 63, specialD = 60 },
      catchRate = 190, baseExp = 71, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MEOWSTIC", level = 25 },
      },
      heightM = 0.3, weightKg = 3.5,
      dexEntry = { kind = "Restraint Pokémon",
        text = "Though Espurr’s expression never changes, behind that blank stare is an intense struggle to contain its devastating psychic power." },
    },

    MEOWSTIC = {
      dex = 678, name = "Meowstic", types = { "PSYCHIC" },
      baseStats = { hp = 74, attack = 48, defense = 76, speed = 104, specialA = 83, specialD = 81 },
      catchRate = 75, baseExp = 163, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.6, weightKg = 8.5,
      dexEntry = { kind = "Constraint Pokémon",
        text = "Revealing the eyelike patterns on the insides of its ears will unleash its psychic powers. It normally keeps the patterns hidden, however." },
    },

    HONEDGE = {
      dex = 679, name = "Honedge", types = { "STEEL", "GHOST" },
      baseStats = { hp = 45, attack = 80, defense = 100, speed = 28, specialA = 35, specialD = 37 },
      catchRate = 180, baseExp = 65, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DOUBLADE", level = 35 },
      },
      heightM = 0.8, weightKg = 2,
      dexEntry = { kind = "Sword Pokémon",
        text = "Honedge’s soul once belonged to a person who was killed a long time ago by the sword that makes up Honedge’s body." },
    },

    DOUBLADE = {
      dex = 680, name = "Doublade", types = { "STEEL", "GHOST" },
      baseStats = { hp = 59, attack = 110, defense = 150, speed = 35, specialA = 45, specialD = 49 },
      catchRate = 90, baseExp = 157, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "AEGISLASH", item = "DUSKSTONE" },
      },
      heightM = 0.8, weightKg = 4.5,
      dexEntry = { kind = "Sword Pokémon",
        text = "Honedge evolves into twins. The two blades rub together to emit a metallic sound that unnerves opponents." },
    },

    AEGISLASH = {
      dex = 681, name = "Aegislash", types = { "STEEL", "GHOST" },
      baseStats = { hp = 60, attack = 50, defense = 140, speed = 60, specialA = 50, specialD = 140 },
      catchRate = 45, baseExp = 250, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 53,
      dexEntry = { kind = "Royal Sword Pokémon",
        text = "In this defensive stance, Aegislash uses its steel body and a force field of spectral power to reduce the damage of any attack." },
    },

    SPRITZEE = {
      dex = 682, name = "Spritzee", types = { "FAIRY" },
      baseStats = { hp = 78, attack = 52, defense = 60, speed = 23, specialA = 63, specialD = 65 },
      catchRate = 200, baseExp = 68, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "AROMATISSE" },
      },
      heightM = 0.2, weightKg = 0.5,
      dexEntry = { kind = "Perfume Pokémon",
        text = "A scent pouch within this Pokémon’s body allows it to create various scents. A change in its diet will alter the fragrance it produces." },
    },

    AROMATISSE = {
      dex = 683, name = "Aromatisse", types = { "FAIRY" },
      baseStats = { hp = 101, attack = 72, defense = 72, speed = 29, specialA = 99, specialD = 89 },
      catchRate = 140, baseExp = 162, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 15.5,
      dexEntry = { kind = "Fragrance Pokémon",
        text = "The scent that constantly emits from its fur is so powerful that this Pokémon’s companions will eventually lose their sense of smell." },
    },

    SWIRLIX = {
      dex = 684, name = "Swirlix", types = { "FAIRY" },
      baseStats = { hp = 62, attack = 48, defense = 66, speed = 49, specialA = 59, specialD = 57 },
      catchRate = 200, baseExp = 68, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "CABLELINKITEM", species = "SLURPUFF" },
      },
      heightM = 0.4, weightKg = 3.5,
      dexEntry = { kind = "Cotton Candy Pokémon",
        text = "It eats its own weight in sugar every day. If it doesn’t get enough sugar, it becomes incredibly grumpy." },
    },

    SLURPUFF = {
      dex = 685, name = "Slurpuff", types = { "FAIRY" },
      baseStats = { hp = 82, attack = 80, defense = 86, speed = 72, specialA = 85, specialD = 75 },
      catchRate = 140, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 5,
      dexEntry = { kind = "Meringue Pokémon",
        text = "By taking in a person’s scent, it can sniff out their mental and physical condition. It’s hoped that this skill will have many medical applications." },
    },

    INKAY = {
      dex = 686, name = "Inkay", types = { "DARK", "PSYCHIC" },
      baseStats = { hp = 53, attack = 54, defense = 53, speed = 45, specialA = 37, specialD = 46 },
      catchRate = 190, baseExp = 58, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MALAMAR", level = 30 },
      },
      heightM = 0.4, weightKg = 3.5,
      dexEntry = { kind = "Revolving Pokémon",
        text = "It spins while making its luminescent spots flash. These spots allow it to communicate with others by using different patterns of light." },
    },

    MALAMAR = {
      dex = 687, name = "Malamar", types = { "DARK", "PSYCHIC" },
      baseStats = { hp = 86, attack = 92, defense = 88, speed = 73, specialA = 68, specialD = 75 },
      catchRate = 80, baseExp = 169, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 47,
      dexEntry = { kind = "Overturning Pokémon",
        text = "Gazing at its luminescent spots will quickly induce a hypnotic state, putting the observer under Malamar’s control." },
    },

    BINACLE = {
      dex = 688, name = "Binacle", types = { "ROCK", "WATER" },
      baseStats = { hp = 42, attack = 52, defense = 67, speed = 50, specialA = 39, specialD = 56 },
      catchRate = 120, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BARBARACLE", level = 39 },
      },
      heightM = 0.5, weightKg = 31,
      dexEntry = { kind = "Two-Handed Pokémon",
        text = "After two Binacle find a suitably sized rock, they adhere themselves to it and live together. They cooperate to gather food during high tide." },
    },

    BARBARACLE = {
      dex = 689, name = "Barbaracle", types = { "ROCK", "WATER" },
      baseStats = { hp = 72, attack = 105, defense = 115, speed = 68, specialA = 54, specialD = 86 },
      catchRate = 45, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 96,
      dexEntry = { kind = "Collective Pokémon",
        text = "Seven Binacle come together to form one Barbaracle. The Binacle that serves as the head gives orders to those serving as the limbs." },
    },

    SKRELP = {
      dex = 690, name = "Skrelp", types = { "POISON", "WATER" },
      baseStats = { hp = 50, attack = 60, defense = 60, speed = 30, specialA = 60, specialD = 60 },
      catchRate = 225, baseExp = 64, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DRAGALGE", level = 48 },
      },
      heightM = 0.5, weightKg = 7.3,
      dexEntry = { kind = "Mock Kelp Pokémon",
        text = "It drifts in the ocean, blending in with floating seaweed. When other Pokémon come to feast on the seaweed, Skrelp feasts on them instead." },
    },

    DRAGALGE = {
      dex = 691, name = "Dragalge", types = { "POISON", "DRAGON" },
      baseStats = { hp = 65, attack = 75, defense = 90, speed = 44, specialA = 97, specialD = 123 },
      catchRate = 55, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 81.5,
      dexEntry = { kind = "Mock Kelp Pokémon",
        text = "Dragalge uses a poisonous liquid capable of corroding metal to send tankers that enter its territory to the bottom of the sea." },
    },

    CLAUNCHER = {
      dex = 692, name = "Clauncher", types = { "WATER" },
      baseStats = { hp = 50, attack = 53, defense = 62, speed = 44, specialA = 58, specialD = 63 },
      catchRate = 225, baseExp = 66, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CLAWITZER", level = 37 },
      },
      heightM = 0.5, weightKg = 8.3,
      dexEntry = { kind = "Water Gun Pokémon",
        text = "Clauncher’s claws can fall off during battle, but they’ll regenerate. The meat inside the claws is popular as a delicacy in Galar." },
    },

    CLAWITZER = {
      dex = 693, name = "Clawitzer", types = { "WATER" },
      baseStats = { hp = 71, attack = 73, defense = 88, speed = 59, specialA = 120, specialD = 89 },
      catchRate = 55, baseExp = 100, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 35.3,
      dexEntry = { kind = "Howitzer Pokémon",
        text = "After using the feelers on its oversized claw to detect the location of prey, Clawitzer launches a cannonball of water at its target." },
    },

    HELIOPTILE = {
      dex = 694, name = "Helioptile", types = { "ELECTRIC", "NORMAL" },
      baseStats = { hp = 44, attack = 38, defense = 33, speed = 70, specialA = 61, specialD = 43 },
      catchRate = 190, baseExp = 58, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "HELIOLISK", item = "SUNSTONE" },
      },
      heightM = 0.5, weightKg = 6,
      dexEntry = { kind = "Generator Pokémon",
        text = "When spread, the frills on its head act like solar panels, generating the power behind this Pokémon’s electric moves." },
    },

    HELIOLISK = {
      dex = 695, name = "Heliolisk", types = { "ELECTRIC", "NORMAL" },
      baseStats = { hp = 62, attack = 55, defense = 52, speed = 109, specialA = 109, specialD = 94 },
      catchRate = 75, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 21,
      dexEntry = { kind = "Generator Pokémon",
        text = "A now-vanished desert culture treasured these Pokémon. Appropriately, when Heliolisk came to the Galar region, treasure came with them." },
    },

    TYRUNT = {
      dex = 696, name = "Tyrunt", types = { "ROCK", "DRAGON" },
      baseStats = { hp = 58, attack = 89, defense = 77, speed = 48, specialA = 45, specialD = 45 },
      catchRate = 45, baseExp = 72, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVELDAY", species = "TYRANTRUM" },
      },
      heightM = 0.8, weightKg = 26,
      dexEntry = { kind = "Royal Heir Pokémon",
        text = "This is an ancient Pokémon, revived in modern times. It has a violent disposition, and it’ll tear apart anything it gets between its hefty jaws." },
    },

    TYRANTRUM = {
      dex = 697, name = "Tyrantrum", types = { "ROCK", "DRAGON" },
      baseStats = { hp = 82, attack = 121, defense = 119, speed = 71, specialA = 69, specialD = 59 },
      catchRate = 45, baseExp = 182, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2.5, weightKg = 270,
      dexEntry = { kind = "Despot Pokémon",
        text = "This Pokémon is from about 100,000,000 years ago. It has the presence of a king, vicious but magnificent." },
    },

    AMAURA = {
      dex = 698, name = "Amaura", types = { "ROCK", "ICE" },
      baseStats = { hp = 77, attack = 59, defense = 50, speed = 46, specialA = 67, specialD = 63 },
      catchRate = 45, baseExp = 72, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVELNIGHT", species = "AURORUS" },
      },
      heightM = 1.3, weightKg = 25.2,
      dexEntry = { kind = "Tundra Pokémon",
        text = "This Pokémon was successfully restored from a fossil. In the past, it lived with others of its kind in cold lands where there were fewer predators." },
    },

    AURORUS = {
      dex = 699, name = "Aurorus", types = { "ROCK", "ICE" },
      baseStats = { hp = 123, attack = 77, defense = 72, speed = 58, specialA = 99, specialD = 92 },
      catchRate = 45, baseExp = 104, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2.7, weightKg = 225,
      dexEntry = { kind = "Tundra Pokémon",
        text = "Aurorus was restored from a fossil. It’s said that when this Pokémon howls, auroras appear in the night sky." },
    },

    SYLVEON = {
      dex = 700, name = "Sylveon", types = { "FAIRY" },
      baseStats = { hp = 95, attack = 65, defense = 65, speed = 60, specialA = 110, specialD = 130 },
      catchRate = 45, baseExp = 184, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 23.5,
      dexEntry = { kind = "Intertwining Pokémon",
        text = "By releasing enmity-erasing waves from its ribbonlike feelers, Sylveon stops any conflict." },
    },

    HAWLUCHA = {
      dex = 701, name = "Hawlucha", types = { "FIGHTING", "FLYING" },
      baseStats = { hp = 78, attack = 92, defense = 75, speed = 118, specialA = 74, specialD = 63 },
      catchRate = 100, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 21.5,
      dexEntry = { kind = "Wrestling Pokémon",
        text = "It drives its opponents to exhaustion with its agile maneuvers, then ends the fight with a flashy finishing move." },
    },

    DEDENNE = {
      dex = 702, name = "Dedenne", types = { "ELECTRIC", "FAIRY" },
      baseStats = { hp = 67, attack = 58, defense = 57, speed = 101, specialA = 81, specialD = 67 },
      catchRate = 180, baseExp = 151, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.2, weightKg = 2.2,
      dexEntry = { kind = "Antenna Pokémon",
        text = "A Dedenne’s whiskers pick up electrical waves other Dedenne send out. These Pokémon share locations of food or electricity with one another." },
    },

    CARBINK = {
      dex = 703, name = "Carbink", types = { "ROCK", "FAIRY" },
      baseStats = { hp = 50, attack = 50, defense = 150, speed = 50, specialA = 50, specialD = 150 },
      catchRate = 60, baseExp = 100, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 5.7,
      dexEntry = { kind = "Jewel Pokémon",
        text = "When beset by attackers, Carbink wipes them all out by firing high-energy beams from the gems embedded in its body." },
    },

    GOOMY = {
      dex = 704, name = "Goomy", types = { "DRAGON" },
      baseStats = { hp = 45, attack = 50, defense = 35, speed = 40, specialA = 55, specialD = 75 },
      catchRate = 45, baseExp = 60, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVEL", species = "SLIGGOO", level = 40 },
      },
      heightM = 0.3, weightKg = 2.8,
      dexEntry = { kind = "Soft Tissue Pokémon",
        text = "Because most of its body is water, it will dry up if the weather becomes too arid. It’s considered the weakest dragon Pokémon." },
    },

    SLIGGOO = {
      dex = 705, name = "Sliggoo", types = { "DRAGON" },
      baseStats = { hp = 68, attack = 75, defense = 53, speed = 60, specialA = 83, specialD = 113 },
      catchRate = 45, baseExp = 158, growthRate = "SLOW", happiness = 35,
      evolutions = {
        { method = "LEVELRAIN", species = "GOODRA" },
      },
      heightM = 0.8, weightKg = 17.5,
      dexEntry = { kind = "Soft Tissue Pokémon",
        text = "Although this Pokémon isn’t very strong, its body is coated in a caustic slime that can melt through anything, so predators steer clear of it." },
    },

    GOODRA = {
      dex = 706, name = "Goodra", types = { "DRAGON" },
      baseStats = { hp = 90, attack = 100, defense = 70, speed = 80, specialA = 110, specialD = 150 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2, weightKg = 150.5,
      dexEntry = { kind = "Dragon Pokémon",
        text = "Sometimes it misunderstands instructions and appears dazed or bewildered. Many Trainers don’t mind, finding this behavior to be adorable." },
    },

    KLEFKI = {
      dex = 707, name = "Klefki", types = { "STEEL", "FAIRY" },
      baseStats = { hp = 57, attack = 80, defense = 91, speed = 75, specialA = 80, specialD = 87 },
      catchRate = 75, baseExp = 165, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.2, weightKg = 3,
      dexEntry = { kind = "Key Ring Pokémon",
        text = "This Pokémon is constantly collecting keys. Entrust a Klefki with important keys, and the Pokémon will protect them no matter what." },
    },

    PHANTUMP = {
      dex = 708, name = "Phantump", types = { "GHOST", "GRASS" },
      baseStats = { hp = 43, attack = 70, defense = 48, speed = 38, specialA = 50, specialD = 60 },
      catchRate = 120, baseExp = 62, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "TRADE", species = "TREVENANT" },
        { method = "ITEM", species = "TREVENANT", item = "LINKINGCORD" },
      },
      heightM = 0.4, weightKg = 7,
      dexEntry = { kind = "Stump Pokémon",
        text = "After a lost child perished in the forest, their spirit possessed a tree stump, causing the spirit’s rebirth as this Pokémon." },
    },

    TREVENANT = {
      dex = 709, name = "Trevenant", types = { "GHOST", "GRASS" },
      baseStats = { hp = 85, attack = 110, defense = 76, speed = 56, specialA = 65, specialD = 82 },
      catchRate = 60, baseExp = 166, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 71,
      dexEntry = { kind = "Elder Tree Pokémon",
        text = "People fear it due to a belief that it devours any who try to cut down trees in its forest, but to the Pokémon it shares its woods with, it’s kind." },
    },

    PUMPKABOO = {
      dex = 710, name = "Pumpkaboo", types = { "GHOST", "GRASS" },
      baseStats = { hp = 44, attack = 66, defense = 70, speed = 56, specialA = 44, specialD = 55 },
      catchRate = 120, baseExp = 67, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "TRADE", species = "GOURGEIST" },
        { method = "ITEM", species = "GOURGEIST", item = "LINKINGCORD" },
      },
      heightM = 0.3, weightKg = 3.5,
      dexEntry = { kind = "Pumpkin Pokémon",
        text = "Spirits that wander this world are placed into Pumpkaboo’s body. They’re then moved on to the afterlife." },
    },

    GOURGEIST = {
      dex = 711, name = "Gourgeist", types = { "GHOST", "GRASS" },
      baseStats = { hp = 55, attack = 85, defense = 122, speed = 99, specialA = 58, specialD = 75 },
      catchRate = 60, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 9.5,
      dexEntry = { kind = "Pumpkin Pokémon",
        text = "Eerie cries emanate from its body in the dead of night. The sounds are said to be the wails of spirits who are suffering in the afterlife." },
    },

    BERGMITE = {
      dex = 712, name = "Bergmite", types = { "ICE" },
      baseStats = { hp = 55, attack = 69, defense = 85, speed = 28, specialA = 32, specialD = 35 },
      catchRate = 190, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "AVALUGG", level = 37 },
      },
      heightM = 1, weightKg = 99.5,
      dexEntry = { kind = "Ice Chunk Pokémon",
        text = "They chill the air around them to −150 degrees Fahrenheit, freezing the water in the air into ice that they use as armor." },
    },

    AVALUGG = {
      dex = 713, name = "Avalugg", types = { "ICE" },
      baseStats = { hp = 95, attack = 117, defense = 184, speed = 28, specialA = 44, specialD = 46 },
      catchRate = 55, baseExp = 180, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 505,
      dexEntry = { kind = "Iceberg Pokémon",
        text = "At high latitudes, this Pokémon can be found with clusters of Bergmite on its back as it swims among the icebergs." },
    },

    NOIBAT = {
      dex = 714, name = "Noibat", types = { "FLYING", "DRAGON" },
      baseStats = { hp = 40, attack = 30, defense = 35, speed = 55, specialA = 45, specialD = 40 },
      catchRate = 190, baseExp = 49, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "NOIVERN", level = 48 },
      },
      heightM = 0.5, weightKg = 8,
      dexEntry = { kind = "Sound Wave Pokémon",
        text = "After nightfall, they emerge from the caves they nest in during the day. Using their ultrasonic waves, they go on the hunt for ripened fruit." },
    },

    NOIVERN = {
      dex = 715, name = "Noivern", types = { "FLYING", "DRAGON" },
      baseStats = { hp = 85, attack = 70, defense = 80, speed = 123, specialA = 97, specialD = 80 },
      catchRate = 45, baseExp = 187, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 85,
      dexEntry = { kind = "Sound Wave Pokémon",
        text = "Aggressive and cruel, this Pokémon will ruthlessly torment enemies that are helpless in the dark." },
    },

    XERNEAS = {
      dex = 716, name = "Xerneas", types = { "FAIRY" },
      baseStats = { hp = 126, attack = 131, defense = 95, speed = 99, specialA = 131, specialD = 98 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3, weightKg = 215,
      dexEntry = { kind = "Life Pokémon",
        text = "Legends say it can share eternal life. It slept for a thousand years in the form of a tree before its revival." },
    },

    YVELTAL = {
      dex = 717, name = "Yveltal", types = { "DARK", "FLYING" },
      baseStats = { hp = 126, attack = 131, defense = 95, speed = 99, specialA = 131, specialD = 98 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 5.8, weightKg = 203,
      dexEntry = { kind = "Destruction Pokémon",
        text = "When this legendary Pokémon’s wings and tail feathers spread wide and glow red, it absorbs the life force of living creatures." },
    },

    ZYGARDE = {
      dex = 718, name = "Zygarde", types = { "DRAGON", "GROUND" },
      baseStats = { hp = 108, attack = 100, defense = 121, speed = 95, specialA = 81, specialD = 95 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 5, weightKg = 305,
      dexEntry = { kind = "Order Pokémon",
        text = "This is Zygarde’s form when about half of its pieces have been assembled. It plays the role of monitoring the ecosystem." },
    },

    DIANCIE = {
      dex = 719, name = "Diancie", types = { "ROCK", "FAIRY" },
      baseStats = { hp = 50, attack = 100, defense = 150, speed = 50, specialA = 100, specialD = 150 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 8.8,
      dexEntry = { kind = "Jewel Pokémon",
        text = "A sudden transformation of Carbink, its pink, glimmering body is said to be the loveliest sight in the whole world." },
    },

    HOOPA = {
      dex = 720, name = "Hoopa", types = { "PSYCHIC", "GHOST" },
      baseStats = { hp = 80, attack = 110, defense = 60, speed = 70, specialA = 150, specialD = 130 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.5, weightKg = 9,
      dexEntry = { kind = "Mischief Pokémon",
        text = "In its true form, it possesses a huge amount of power. Legends of its avarice tell how it once carried off an entire castle to gain the treasure hidden within." },
    },

    VOLCANION = {
      dex = 721, name = "Volcanion", types = { "FIRE", "WATER" },
      baseStats = { hp = 80, attack = 110, defense = 120, speed = 70, specialA = 130, specialD = 90 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 100,
      evolutions = {},
      heightM = 1.7, weightKg = 195,
      dexEntry = { kind = "Steam Pokémon",
        text = "It lets out billows of steam and disappears into the dense fog. It’s said to live in mountains where humans do not tread." },
    },

    ROWLET = {
      dex = 722, name = "Rowlet", types = { "GRASS", "FLYING" },
      baseStats = { hp = 68, attack = 55, defense = 55, speed = 42, specialA = 50, specialD = 50 },
      catchRate = 45, baseExp = 64, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DARTRIX", level = 17 },
      },
      heightM = 0.3, weightKg = 1.5,
      dexEntry = { kind = "Grass Quill Pokémon",
        text = "It sends its feathers, which are as sharp as blades, flying in attack. Its legs are strong, so its kicks are also formidable." },
    },

    DARTRIX = {
      dex = 723, name = "Dartrix", types = { "GRASS", "FLYING" },
      baseStats = { hp = 78, attack = 75, defense = 75, speed = 52, specialA = 70, specialD = 70 },
      catchRate = 45, baseExp = 147, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DECIDUEYE", level = 34 },
      },
      heightM = 0.7, weightKg = 16,
      dexEntry = { kind = "Blade Quill Pokémon",
        text = "This narcissistic Pokémon is a clean freak. If you don’t groom it diligently, it will stop listening to you." },
    },

    DECIDUEYE = {
      dex = 724, name = "Decidueye", types = { "GRASS", "GHOST" },
      baseStats = { hp = 78, attack = 107, defense = 75, speed = 70, specialA = 100, specialD = 100 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 36.6,
      dexEntry = { kind = "Arrow Quill Pokémon",
        text = "It nocks its arrow quills and shoots them at opponents. When it simply can’t afford to miss, it tugs the vine on its head to improve its focus." },
    },

    LITTEN = {
      dex = 725, name = "Litten", types = { "FIRE" },
      baseStats = { hp = 45, attack = 65, defense = 40, speed = 70, specialA = 60, specialD = 40 },
      catchRate = 45, baseExp = 64, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TORRACAT", level = 17 },
      },
      heightM = 0.4, weightKg = 4.3,
      dexEntry = { kind = "Fire Cat Pokémon",
        text = "If you try too hard to get close to it, it won’t open up to you. Even if you do grow close, giving it too much affection is still a no-no." },
    },

    TORRACAT = {
      dex = 726, name = "Torracat", types = { "FIRE" },
      baseStats = { hp = 65, attack = 85, defense = 50, speed = 90, specialA = 80, specialD = 50 },
      catchRate = 45, baseExp = 147, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "INCINEROAR", level = 34 },
      },
      heightM = 0.7, weightKg = 25,
      dexEntry = { kind = "Fire Cat Pokémon",
        text = "It can act spoiled if it grows close to its Trainer. A powerful Pokémon, its sharp claws can leave its Trainer’s whole body covered in scratches." },
    },

    INCINEROAR = {
      dex = 727, name = "Incineroar", types = { "FIRE", "DARK" },
      baseStats = { hp = 95, attack = 115, defense = 90, speed = 60, specialA = 80, specialD = 90 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 83,
      dexEntry = { kind = "Heel Pokémon",
        text = "Although it’s rough mannered and egotistical, it finds beating down unworthy opponents boring. It gets motivated for stronger opponents." },
    },

    POPPLIO = {
      dex = 728, name = "Popplio", types = { "WATER" },
      baseStats = { hp = 50, attack = 54, defense = 54, speed = 40, specialA = 66, specialD = 56 },
      catchRate = 45, baseExp = 64, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BRIONNE", level = 17 },
      },
      heightM = 0.4, weightKg = 7.5,
      dexEntry = { kind = "Sea Lion Pokémon",
        text = "The balloons it inflates with its nose grow larger and larger as it practices day by day." },
    },

    BRIONNE = {
      dex = 729, name = "Brionne", types = { "WATER" },
      baseStats = { hp = 60, attack = 69, defense = 69, speed = 50, specialA = 91, specialD = 81 },
      catchRate = 45, baseExp = 147, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PRIMARINA", level = 34 },
      },
      heightM = 0.6, weightKg = 17.5,
      dexEntry = { kind = "Pop Star Pokémon",
        text = "It gets excited when it sees a dance it doesn’t know. This hard worker practices diligently until it can learn that dance." },
    },

    PRIMARINA = {
      dex = 730, name = "Primarina", types = { "WATER", "FAIRY" },
      baseStats = { hp = 80, attack = 74, defense = 74, speed = 60, specialA = 126, specialD = 116 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 44,
      dexEntry = { kind = "Soloist Pokémon",
        text = "To Primarina, every battle is a stage. It takes down its prey with beautiful singing and dancing." },
    },

    PIKIPEK = {
      dex = 731, name = "Pikipek", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 35, attack = 75, defense = 30, speed = 65, specialA = 30, specialD = 30 },
      catchRate = 255, baseExp = 53, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TRUMBEAK", level = 14 },
      },
      heightM = 0.3, weightKg = 1.2,
      dexEntry = { kind = "Woodpecker Pokémon",
        text = "It pecks at trees with its hard beak. You can get some idea of its mood or condition from the rhythm of its pecking." },
    },

    TRUMBEAK = {
      dex = 732, name = "Trumbeak", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 55, attack = 85, defense = 50, speed = 75, specialA = 40, specialD = 50 },
      catchRate = 120, baseExp = 124, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TOUCANNON", level = 28 },
      },
      heightM = 0.6, weightKg = 14.8,
      dexEntry = { kind = "Bugle Beak Pokémon",
        text = "It can bend the tip of its beak to produce over a hundred different cries at will." },
    },

    TOUCANNON = {
      dex = 733, name = "Toucannon", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 80, attack = 120, defense = 75, speed = 60, specialA = 75, specialD = 75 },
      catchRate = 45, baseExp = 243, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 26,
      dexEntry = { kind = "Cannon Pokémon",
        text = "They smack beaks with others of their kind to communicate. The strength and number of hits tell each other how they feel." },
    },

    YUNGOOS = {
      dex = 734, name = "Yungoos", types = { "NORMAL" },
      baseStats = { hp = 48, attack = 70, defense = 30, speed = 45, specialA = 30, specialD = 30 },
      catchRate = 255, baseExp = 51, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVELDAY", species = "GUMSHOOS" },
      },
      heightM = 0.4, weightKg = 6,
      dexEntry = { kind = "Loitering Pokémon",
        text = "Its stomach takes up most of its long torso. It’s a big eater, so the amount Trainers have to spend on its food is no laughing matter." },
    },

    GUMSHOOS = {
      dex = 735, name = "Gumshoos", types = { "NORMAL" },
      baseStats = { hp = 88, attack = 110, defense = 60, speed = 45, specialA = 55, specialD = 60 },
      catchRate = 127, baseExp = 146, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 14.2,
      dexEntry = { kind = "Stakeout Pokémon",
        text = "Although it wasn’t originally found in Alola, this Pokémon was brought over a long time ago when there was a huge Rattata outbreak." },
    },

    GRUBBIN = {
      dex = 736, name = "Grubbin", types = { "BUG" },
      baseStats = { hp = 47, attack = 62, defense = 45, speed = 46, specialA = 55, specialD = 45 },
      catchRate = 255, baseExp = 60, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CHARJABUG", level = 20 },
      },
      heightM = 0.4, weightKg = 4.4,
      dexEntry = { kind = "Larva Pokémon",
        text = "Its natural enemies, like Rookidee, may flee rather than risk getting caught in its large mandibles that can snap thick tree branches." },
    },

    CHARJABUG = {
      dex = 737, name = "Charjabug", types = { "BUG", "ELECTRIC" },
      baseStats = { hp = 57, attack = 82, defense = 95, speed = 36, specialA = 55, specialD = 75 },
      catchRate = 120, baseExp = 140, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "VIKAVOLT", item = "THUNDERSTONE" },
        { method = "LOCATIONFLAG", species = "VIKAVOLT" },
      },
      heightM = 0.5, weightKg = 10.5,
      dexEntry = { kind = "Battery Pokémon",
        text = "While its durable shell protects it from attacks, Charjabug strikes at enemies with jolts of electricity discharged from the tips of its jaws." },
    },

    VIKAVOLT = {
      dex = 738, name = "Vikavolt", types = { "BUG", "ELECTRIC" },
      baseStats = { hp = 77, attack = 70, defense = 90, speed = 43, specialA = 145, specialD = 75 },
      catchRate = 45, baseExp = 250, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 45,
      dexEntry = { kind = "Stag Beetle Pokémon",
        text = "It builds up electricity in its abdomen, focuses it through its jaws, and then fires the electricity off in concentrated beams." },
    },

    CRABRAWLER = {
      dex = 739, name = "Crabrawler", types = { "FIGHTING" },
      baseStats = { hp = 47, attack = 82, defense = 57, speed = 63, specialA = 42, specialD = 47 },
      catchRate = 225, baseExp = 68, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LOCATIONFLAG", species = "CRABOMINABLE" },
        { method = "ITEM", species = "CRABOMINABLE", item = "ICESTONE" },
      },
      heightM = 0.6, weightKg = 7,
      dexEntry = { kind = "Boxing Pokémon",
        text = "Its hard pincers are well suited to both offense and defense. Fights between two Crabrawler are like boxing matches." },
    },

    CRABOMINABLE = {
      dex = 740, name = "Crabominable", types = { "FIGHTING", "ICE" },
      baseStats = { hp = 97, attack = 132, defense = 77, speed = 43, specialA = 62, specialD = 67 },
      catchRate = 60, baseExp = 167, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.7, weightKg = 180,
      dexEntry = { kind = "Woolly Crab Pokémon",
        text = "It stores coldness in its pincers and pummels its foes. It can even smash thick walls of ice to bits!" },
    },

    ORICORIO = {
      dex = 741, name = "Oricorio", types = { "FIRE", "FLYING" },
      baseStats = { hp = 75, attack = 70, defense = 70, speed = 93, specialA = 98, specialD = 70 },
      catchRate = 45, baseExp = 167, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.6, weightKg = 3.4,
      dexEntry = { kind = "Dancing Pokémon",
        text = "It wins the hearts of its enemies with its passionate dancing and then uses the opening it creates to burn them up with blazing flames." },
    },

    CUTIEFLY = {
      dex = 742, name = "Cutiefly", types = { "BUG", "FAIRY" },
      baseStats = { hp = 40, attack = 45, defense = 40, speed = 84, specialA = 55, specialD = 40 },
      catchRate = 190, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "RIBOMBEE", level = 25 },
      },
      heightM = 0.1, weightKg = 0.2,
      dexEntry = { kind = "Bee Fly Pokémon",
        text = "Nectar and pollen are its favorite fare. You can find Cutiefly hovering around Gossifleur, trying to get some of Gossifleur’s pollen." },
    },

    RIBOMBEE = {
      dex = 743, name = "Ribombee", types = { "BUG", "FAIRY" },
      baseStats = { hp = 60, attack = 55, defense = 60, speed = 124, specialA = 95, specialD = 70 },
      catchRate = 75, baseExp = 162, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.2, weightKg = 0.5,
      dexEntry = { kind = "Bee Fly Pokémon",
        text = "It makes pollen puffs from pollen and nectar. The puffs’ effects depend on the type of ingredients and how much of each one is used." },
    },

    ROCKRUFF = {
      dex = 744, name = "Rockruff", types = { "ROCK" },
      baseStats = { hp = 45, attack = 65, defense = 40, speed = 60, specialA = 30, specialD = 40 },
      catchRate = 190, baseExp = 56, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "LYCANROC", level = 25 },
      },
      heightM = 0.5, weightKg = 9.2,
      dexEntry = { kind = "Puppy Pokémon",
        text = "This Pokémon can bond very strongly with its Trainer, but it also has a habit of biting. Raising a Rockruff for a long time can be challenging." },
    },

    LYCANROC = {
      dex = 745, name = "Lycanroc", types = { "ROCK" },
      baseStats = { hp = 75, attack = 115, defense = 65, speed = 112, specialA = 55, specialD = 65 },
      catchRate = 90, baseExp = 170, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 25,
      dexEntry = { kind = "Wolf Pokémon",
        text = "This Lycanroc is calm and cautious. The rocks jutting from its mane are razor sharp." },
    },

    WISHIWASHI = {
      dex = 746, name = "Wishiwashi", types = { "WATER" },
      baseStats = { hp = 45, attack = 20, defense = 20, speed = 40, specialA = 25, specialD = 25 },
      catchRate = 60, baseExp = 61, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.2, weightKg = 0.3,
      dexEntry = { kind = "Small Fry Pokémon",
        text = "Individually, they’re incredibly weak. It’s by gathering up into schools that they’re able to confront opponents." },
    },

    MAREANIE = {
      dex = 747, name = "Mareanie", types = { "POISON", "WATER" },
      baseStats = { hp = 50, attack = 53, defense = 62, speed = 45, specialA = 43, specialD = 52 },
      catchRate = 190, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TOXAPEX", level = 38 },
      },
      heightM = 0.4, weightKg = 8,
      dexEntry = { kind = "Brutal Star Pokémon",
        text = "The first symptom of its sting is numbness. The next is an itching sensation so intense that it’s impossible to resist the urge to claw at your skin." },
    },

    TOXAPEX = {
      dex = 748, name = "Toxapex", types = { "POISON", "WATER" },
      baseStats = { hp = 50, attack = 63, defense = 152, speed = 35, specialA = 53, specialD = 142 },
      catchRate = 75, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 14.5,
      dexEntry = { kind = "Brutal Star Pokémon",
        text = "To survive in the cold waters of Galar, this Pokémon forms a dome with its legs, enclosing its body so it can capture its own body heat." },
    },

    MUDBRAY = {
      dex = 749, name = "Mudbray", types = { "GROUND" },
      baseStats = { hp = 70, attack = 100, defense = 70, speed = 45, specialA = 45, specialD = 55 },
      catchRate = 190, baseExp = 77, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MUDSDALE", level = 30 },
      },
      heightM = 1, weightKg = 110,
      dexEntry = { kind = "Donkey Pokémon",
        text = "Loads weighing up to 50 times as much as its own body weight pose no issue for this Pokémon. It’s skilled at making use of mud." },
    },

    MUDSDALE = {
      dex = 750, name = "Mudsdale", types = { "GROUND" },
      baseStats = { hp = 100, attack = 125, defense = 100, speed = 35, specialA = 55, specialD = 85 },
      catchRate = 60, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2.5, weightKg = 920,
      dexEntry = { kind = "Draft Horse Pokémon",
        text = "Mud that hardens around a Mudsdale’s legs sets harder than stone. It’s so hard that it allows this Pokémon to scrap a truck with a single kick." },
    },

    DEWPIDER = {
      dex = 751, name = "Dewpider", types = { "WATER", "BUG" },
      baseStats = { hp = 38, attack = 40, defense = 52, speed = 27, specialA = 40, specialD = 72 },
      catchRate = 200, baseExp = 54, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ARAQUANID", level = 22 },
      },
      heightM = 0.3, weightKg = 4,
      dexEntry = { kind = "Water Bubble Pokémon",
        text = "It forms a water bubble at the rear of its body and then covers its head with it. Meeting another Dewpider means comparing water-bubble sizes." },
    },

    ARAQUANID = {
      dex = 752, name = "Araquanid", types = { "WATER", "BUG" },
      baseStats = { hp = 68, attack = 70, defense = 92, speed = 42, specialA = 50, specialD = 132 },
      catchRate = 100, baseExp = 159, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 82,
      dexEntry = { kind = "Water Bubble Pokémon",
        text = "It launches water bubbles with its legs, drowning prey within the bubbles. This Pokémon can then take its time to savor its meal." },
    },

    FOMANTIS = {
      dex = 753, name = "Fomantis", types = { "GRASS" },
      baseStats = { hp = 40, attack = 55, defense = 35, speed = 35, specialA = 50, specialD = 35 },
      catchRate = 190, baseExp = 50, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVELDAY", species = "LURANTIS" },
      },
      heightM = 0.3, weightKg = 1.5,
      dexEntry = { kind = "Sickle Grass Pokémon",
        text = "When bathed in sunlight, this Pokémon emits a pleasantly sweet scent, which causes bug Pokémon to gather around it." },
    },

    LURANTIS = {
      dex = 754, name = "Lurantis", types = { "GRASS" },
      baseStats = { hp = 70, attack = 105, defense = 90, speed = 45, specialA = 80, specialD = 90 },
      catchRate = 75, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 18.5,
      dexEntry = { kind = "Bloom Sickle Pokémon",
        text = "This Pokémon resembles a beautiful flower. A properly raised Lurantis will have gorgeous, brilliant colors." },
    },

    MORELULL = {
      dex = 755, name = "Morelull", types = { "GRASS", "FAIRY" },
      baseStats = { hp = 40, attack = 35, defense = 55, speed = 15, specialA = 65, specialD = 75 },
      catchRate = 190, baseExp = 57, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SHIINOTIC", level = 24 },
      },
      heightM = 0.2, weightKg = 1.5,
      dexEntry = { kind = "Illuminating Pokémon",
        text = "Pokémon living in the forest eat the delicious caps on Morelull’s head. The caps regrow overnight." },
    },

    SHIINOTIC = {
      dex = 756, name = "Shiinotic", types = { "GRASS", "FAIRY" },
      baseStats = { hp = 60, attack = 45, defense = 80, speed = 30, specialA = 90, specialD = 100 },
      catchRate = 75, baseExp = 142, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 11.5,
      dexEntry = { kind = "Illuminating Pokémon",
        text = "Its flickering spores lure in prey and put them to sleep. Once this Pokémon has its prey snoozing, it drains their vitality with its fingertips." },
    },

    SALANDIT = {
      dex = 757, name = "Salandit", types = { "POISON", "FIRE" },
      baseStats = { hp = 48, attack = 44, defense = 40, speed = 77, specialA = 71, specialD = 40 },
      catchRate = 120, baseExp = 64, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVELFEMALE", species = "SALAZZLE" },
      },
      heightM = 0.6, weightKg = 4.8,
      dexEntry = { kind = "Toxic Lizard Pokémon",
        text = "Its venom sacs produce a fluid that this Pokémon then heats up with the flame in its tail. This process creates Salandit’s poisonous gas." },
    },

    SALAZZLE = {
      dex = 758, name = "Salazzle", types = { "POISON", "FIRE" },
      baseStats = { hp = 68, attack = 64, defense = 60, speed = 117, specialA = 111, specialD = 60 },
      catchRate = 45, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 22.2,
      dexEntry = { kind = "Toxic Lizard Pokémon",
        text = "Only female Salazzle exist. They emit a gas laden with pheromones to captivate male Salandit." },
    },

    STUFFUL = {
      dex = 759, name = "Stufful", types = { "NORMAL", "FIGHTING" },
      baseStats = { hp = 70, attack = 75, defense = 50, speed = 50, specialA = 45, specialD = 50 },
      catchRate = 140, baseExp = 68, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BEWEAR", level = 27 },
      },
      heightM = 0.5, weightKg = 6.8,
      dexEntry = { kind = "Flailing Pokémon",
        text = "Its fluffy fur is a delight to pet, but carelessly reaching out to touch this Pokémon could result in painful retaliation." },
    },

    BEWEAR = {
      dex = 760, name = "Bewear", types = { "NORMAL", "FIGHTING" },
      baseStats = { hp = 120, attack = 125, defense = 80, speed = 60, specialA = 55, specialD = 60 },
      catchRate = 70, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2.1, weightKg = 135,
      dexEntry = { kind = "Strong Arm Pokémon",
        text = "Once it accepts you as a friend, it tries to show its affection with a hug. Letting it do that is dangerous—it could easily shatter your bones." },
    },

    BOUNSWEET = {
      dex = 761, name = "Bounsweet", types = { "GRASS" },
      baseStats = { hp = 42, attack = 30, defense = 38, speed = 32, specialA = 30, specialD = 38 },
      catchRate = 235, baseExp = 42, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "STEENEE", level = 18 },
      },
      heightM = 0.3, weightKg = 3.2,
      dexEntry = { kind = "Fruit Pokémon",
        text = "Its body gives off a sweet, fruity scent that is extremely appetizing to bird Pokémon." },
    },

    STEENEE = {
      dex = 762, name = "Steenee", types = { "GRASS" },
      baseStats = { hp = 52, attack = 40, defense = 48, speed = 62, specialA = 40, specialD = 48 },
      catchRate = 120, baseExp = 102, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "HAS_MOVE", species = "TSAREENA", move = "STOMP" },
      },
      heightM = 0.7, weightKg = 8.2,
      dexEntry = { kind = "Fruit Pokémon",
        text = "As it twirls like a dancer, a sweet smell spreads out around it. Anyone who inhales the scent will feel a surge of happiness." },
    },

    TSAREENA = {
      dex = 763, name = "Tsareena", types = { "GRASS" },
      baseStats = { hp = 72, attack = 120, defense = 98, speed = 72, specialA = 50, specialD = 98 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 21.4,
      dexEntry = { kind = "Fruit Pokémon",
        text = "This feared Pokémon has long, slender legs and a cruel heart. It shows no mercy as it stomps on its opponents." },
    },

    COMFEY = {
      dex = 764, name = "Comfey", types = { "FAIRY" },
      baseStats = { hp = 51, attack = 52, defense = 90, speed = 100, specialA = 82, specialD = 110 },
      catchRate = 60, baseExp = 170, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.1, weightKg = 0.3,
      dexEntry = { kind = "Posy Picker Pokémon",
        text = "Comfey picks flowers with its vine and decorates itself with them. For some reason, flowers won’t wither once they’re attached to a Comfey." },
    },

    ORANGURU = {
      dex = 765, name = "Oranguru", types = { "NORMAL", "PSYCHIC" },
      baseStats = { hp = 90, attack = 60, defense = 80, speed = 60, specialA = 90, specialD = 110 },
      catchRate = 45, baseExp = 172, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 76,
      dexEntry = { kind = "Sage Pokémon",
        text = "With waves of its fan—made from leaves and its own fur—Oranguru skillfully gives instructions to other Pokémon." },
    },

    PASSIMIAN = {
      dex = 766, name = "Passimian", types = { "FIGHTING" },
      baseStats = { hp = 100, attack = 120, defense = 90, speed = 80, specialA = 40, specialD = 60 },
      catchRate = 45, baseExp = 172, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 82.8,
      dexEntry = { kind = "Teamwork Pokémon",
        text = "Displaying amazing teamwork, they follow the orders of their boss as they all help out in the search for their favorite berries." },
    },

    WIMPOD = {
      dex = 767, name = "Wimpod", types = { "BUG", "WATER" },
      baseStats = { hp = 25, attack = 35, defense = 40, speed = 80, specialA = 20, specialD = 30 },
      catchRate = 90, baseExp = 46, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GOLISOPOD", level = 30 },
      },
      heightM = 0.5, weightKg = 12,
      dexEntry = { kind = "Turn Tail Pokémon",
        text = "It’s nature’s cleaner—it eats anything and everything, including garbage and rotten things. The ground near its nest is always clean." },
    },

    GOLISOPOD = {
      dex = 768, name = "Golisopod", types = { "BUG", "WATER" },
      baseStats = { hp = 75, attack = 125, defense = 140, speed = 40, specialA = 60, specialD = 90 },
      catchRate = 45, baseExp = 186, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 108,
      dexEntry = { kind = "Hard Scale Pokémon",
        text = "It will do anything to win, taking advantage of every opening and finishing opponents off with the small claws on its front legs." },
    },

    SANDYGAST = {
      dex = 769, name = "Sandygast", types = { "GHOST", "GROUND" },
      baseStats = { hp = 55, attack = 55, defense = 80, speed = 15, specialA = 70, specialD = 45 },
      catchRate = 140, baseExp = 64, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PALOSSAND", level = 42 },
      },
      heightM = 0.5, weightKg = 70,
      dexEntry = { kind = "Sand Heap Pokémon",
        text = "Grudges of the dead have possessed a mound of sand and become a Pokémon. Sandygast is fond of the shovel on its head." },
    },

    PALOSSAND = {
      dex = 770, name = "Palossand", types = { "GHOST", "GROUND" },
      baseStats = { hp = 85, attack = 75, defense = 110, speed = 35, specialA = 100, specialD = 75 },
      catchRate = 60, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 250,
      dexEntry = { kind = "Sand Castle Pokémon",
        text = "Palossand is known as the Beach Nightmare. It pulls its prey down into the sand by controlling the sand itself, and then it sucks out their souls." },
    },

    PYUKUMUKU = {
      dex = 771, name = "Pyukumuku", types = { "WATER" },
      baseStats = { hp = 55, attack = 60, defense = 130, speed = 5, specialA = 30, specialD = 130 },
      catchRate = 60, baseExp = 144, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 1.2,
      dexEntry = { kind = "Sea Cucumber Pokémon",
        text = "It lives in warm, shallow waters. If it encounters a foe, it will spit out its internal organs as a means to punch them." },
    },

    TYPENULL = {
      dex = 772, name = "Código Cero", types = { "NORMAL" },
      baseStats = { hp = 95, attack = 95, defense = 95, speed = 59, specialA = 95, specialD = 95 },
      catchRate = 3, baseExp = 107, growthRate = "SLOW", happiness = 0,
      evolutions = {
        { method = "HAPPINESS", species = "SILVALLY" },
      },
      heightM = 1.9, weightKg = 120.5,
      dexEntry = { kind = "Synthetic Pokémon",
        text = "Rumor has it that the theft of top-secret research notes led to a new instance of this Pokémon being created in the Galar region." },
    },

    SILVALLY = {
      dex = 773, name = "Silvally", types = { "NORMAL" },
      baseStats = { hp = 95, attack = 95, defense = 95, speed = 95, specialA = 95, specialD = 95 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2.3, weightKg = 100.5,
      dexEntry = { kind = "Synthetic Pokémon",
        text = "A solid bond of trust between this Pokémon and its Trainer awakened the strength hidden within Silvally. It can change its type at will." },
    },

    MINIOR = {
      dex = 774, name = "Minior", types = { "ROCK", "FLYING" },
      baseStats = { hp = 60, attack = 60, defense = 100, speed = 60, specialA = 60, specialD = 100 },
      catchRate = 30, baseExp = 154, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 40,
      dexEntry = { kind = "Meteor Pokémon",
        text = "It lives in the ozone layer, where it becomes food for stronger Pokémon. When it tries to run away, it falls to the ground." },
    },

    KOMALA = {
      dex = 775, name = "Komala", types = { "NORMAL" },
      baseStats = { hp = 65, attack = 115, defense = 65, speed = 65, specialA = 75, specialD = 95 },
      catchRate = 45, baseExp = 168, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.4, weightKg = 19.9,
      dexEntry = { kind = "Drowsing Pokémon",
        text = "It stays asleep from the moment it’s born. When it falls into a deep sleep, it stops moving altogether." },
    },

    TURTONATOR = {
      dex = 776, name = "Turtonator", types = { "FIRE", "DRAGON" },
      baseStats = { hp = 60, attack = 78, defense = 135, speed = 36, specialA = 91, specialD = 85 },
      catchRate = 70, baseExp = 170, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 212,
      dexEntry = { kind = "Blast Turtle Pokémon",
        text = "Explosive substances coat the shell on its back. Enemies that dare attack it will be blown away by an immense detonation." },
    },

    TOGEDEMARU = {
      dex = 777, name = "Togedemaru", types = { "ELECTRIC", "STEEL" },
      baseStats = { hp = 65, attack = 98, defense = 63, speed = 96, specialA = 40, specialD = 73 },
      catchRate = 180, baseExp = 152, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 3.3,
      dexEntry = { kind = "Roly-Poly Pokémon",
        text = "With the long hairs on its back, this Pokémon takes in electricity from other electric Pokémon. It stores what it absorbs in an electric sac." },
    },

    MIMIKYU = {
      dex = 778, name = "Mimikyu", types = { "GHOST", "FAIRY" },
      baseStats = { hp = 55, attack = 90, defense = 80, speed = 96, specialA = 50, specialD = 105 },
      catchRate = 45, baseExp = 167, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.2, weightKg = 0.7,
      dexEntry = { kind = "Disguise Pokémon",
        text = "It wears a rag fashioned into a Pikachu costume in an effort to look less scary. Unfortunately, the costume only makes it creepier." },
    },

    BRUXISH = {
      dex = 779, name = "Bruxish", types = { "WATER", "PSYCHIC" },
      baseStats = { hp = 68, attack = 105, defense = 70, speed = 92, specialA = 70, specialD = 70 },
      catchRate = 80, baseExp = 166, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 19,
      dexEntry = { kind = "Gnash Teeth Pokémon",
        text = "It burrows beneath the sand, radiating psychic power from the protuberance on its head. It waits for prey as it surveys the area." },
    },

    DRAMPA = {
      dex = 780, name = "Drampa", types = { "NORMAL", "DRAGON" },
      baseStats = { hp = 78, attack = 60, defense = 85, speed = 36, specialA = 135, specialD = 91 },
      catchRate = 70, baseExp = 170, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 3, weightKg = 185,
      dexEntry = { kind = "Placid Pokémon",
        text = "The mountains it calls home are nearly two miles in height. On rare occasions, it descends to play with the children living in the towns below." },
    },

    DHELMISE = {
      dex = 781, name = "Dhelmise", types = { "GHOST", "GRASS" },
      baseStats = { hp = 70, attack = 131, defense = 100, speed = 40, specialA = 86, specialD = 90 },
      catchRate = 25, baseExp = 181, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 3.9, weightKg = 210,
      dexEntry = { kind = "Sea Creeper Pokémon",
        text = "After a piece of seaweed merged with debris from a sunken ship, it was reborn as this ghost Pokémon." },
    },

    JANGMOO = {
      dex = 782, name = "Jangmo-o", types = { "DRAGON" },
      baseStats = { hp = 45, attack = 55, defense = 65, speed = 45, specialA = 45, specialD = 45 },
      catchRate = 45, baseExp = 60, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "HAKAMOO", level = 35 },
      },
      heightM = 0.6, weightKg = 29.7,
      dexEntry = { kind = "Scaly Pokémon",
        text = "They learn to fight by smashing their head scales together. The dueling strengthens both their skills and their spirits." },
    },

    HAKAMOO = {
      dex = 783, name = "Hakamo-o", types = { "DRAGON", "FIGHTING" },
      baseStats = { hp = 55, attack = 75, defense = 90, speed = 65, specialA = 65, specialD = 70 },
      catchRate = 45, baseExp = 147, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "KOMMOO", level = 45 },
      },
      heightM = 1.2, weightKg = 47,
      dexEntry = { kind = "Scaly Pokémon",
        text = "The scaleless, scarred parts of its body are signs of its strength. It shows them off to defeated opponents." },
    },

    KOMMOO = {
      dex = 784, name = "Kommo-o", types = { "DRAGON", "FIGHTING" },
      baseStats = { hp = 75, attack = 110, defense = 125, speed = 85, specialA = 100, specialD = 105 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 78.2,
      dexEntry = { kind = "Scaly Pokémon",
        text = "It clatters its tail scales to unnerve opponents. This Pokémon will battle only those who stand steadfast in the face of this display." },
    },

    TAPUKOKO = {
      dex = 785, name = "Tapu Koko", types = { "ELECTRIC", "FAIRY" },
      baseStats = { hp = 70, attack = 115, defense = 85, speed = 130, specialA = 95, specialD = 75 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 20.5,
      dexEntry = { kind = "Land Spirit Pokémon",
        text = "Although it’s called a guardian deity, if a person or Pokémon puts it in a bad mood, it will become a malevolent deity and attack." },
    },

    TAPULELE = {
      dex = 786, name = "Tapu Lele", types = { "PSYCHIC", "FAIRY" },
      baseStats = { hp = 70, attack = 85, defense = 75, speed = 95, specialA = 130, specialD = 115 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 18.6,
      dexEntry = { kind = "Land Spirit Pokémon",
        text = "It heals the wounds of people and Pokémon by sprinkling them with its sparkling scales. This guardian deity is worshiped on Akala." },
    },

    TAPUBULU = {
      dex = 787, name = "Tapu Bulu", types = { "GRASS", "FAIRY" },
      baseStats = { hp = 70, attack = 130, defense = 115, speed = 75, specialA = 85, specialD = 95 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 45.5,
      dexEntry = { kind = "Land Spirit Pokémon",
        text = "Although it’s called a guardian deity, it’s violent enough to crush anyone it sees as an enemy." },
    },

    TAPUFINI = {
      dex = 788, name = "Tapu Fini", types = { "WATER", "FAIRY" },
      baseStats = { hp = 70, attack = 75, defense = 115, speed = 85, specialA = 95, specialD = 130 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 21.2,
      dexEntry = { kind = "Land Spirit Pokémon",
        text = "This guardian deity of Poni Island manipulates water. Because it lives deep within a thick fog, it came to be both feared and revered." },
    },

    COSMOG = {
      dex = 789, name = "Cosmog", types = { "PSYCHIC" },
      baseStats = { hp = 43, attack = 29, defense = 31, speed = 37, specialA = 29, specialD = 31 },
      catchRate = 45, baseExp = 40, growthRate = "SLOW", happiness = 0,
      evolutions = {
        { method = "LEVEL", species = "COSMOEM", level = 43 },
      },
      heightM = 0.2, weightKg = 0.1,
      dexEntry = { kind = "Nebula Pokémon",
        text = "Even though its helpless, gaseous body can be blown away by the slightest breeze, it doesn’t seem to care." },
    },

    COSMOEM = {
      dex = 790, name = "Cosmoem", types = { "PSYCHIC" },
      baseStats = { hp = 43, attack = 29, defense = 131, speed = 37, specialA = 29, specialD = 131 },
      catchRate = 45, baseExp = 140, growthRate = "SLOW", happiness = 0,
      evolutions = {
        { method = "LEVELDAY", species = "SOLGALEO" },
        { method = "LEVELNIGHT", species = "LUNALA" },
      },
      heightM = 0.1, weightKg = 999.9,
      dexEntry = { kind = "Protostar Pokémon",
        text = "The king who ruled Alola in times of antiquity called it the “cocoon of the stars” and built an altar to worship it." },
    },

    SOLGALEO = {
      dex = 791, name = "Solgaleo", types = { "PSYCHIC", "STEEL" },
      baseStats = { hp = 137, attack = 137, defense = 107, speed = 97, specialA = 113, specialD = 89 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.4, weightKg = 230,
      dexEntry = { kind = "Sunne Pokémon",
        text = "Sometimes the result of its opening an Ultra Wormhole is that energy and life-forms from other worlds are called here to this world." },
    },

    LUNALA = {
      dex = 792, name = "Lunala", types = { "PSYCHIC", "GHOST" },
      baseStats = { hp = 137, attack = 113, defense = 89, speed = 97, specialA = 137, specialD = 107 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 4, weightKg = 120,
      dexEntry = { kind = "Moone Pokémon",
        text = "Records of it exist in writings from long, long ago, where it was known by the name “the beast that calls the moon.”" },
    },

    NIHILEGO = {
      dex = 793, name = "Nihilego", types = { "ROCK", "POISON" },
      baseStats = { hp = 109, attack = 53, defense = 47, speed = 103, specialA = 127, specialD = 131 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.2, weightKg = 55.5,
      dexEntry = { kind = "Parasite Pokémon",
        text = "A life-form from another world, it was dubbed a UB and is thought to produce a strong neurotoxin." },
    },

    BUZZWOLE = {
      dex = 794, name = "Buzzwole", types = { "BUG", "FIGHTING" },
      baseStats = { hp = 107, attack = 139, defense = 139, speed = 79, specialA = 53, specialD = 53 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2.4, weightKg = 333.6,
      dexEntry = { kind = "Swollen Pokémon",
        text = "Although it’s alien to this world and a danger here, it’s apparently a common organism in the world where it normally lives." },
    },

    PHEROMOSA = {
      dex = 795, name = "Pheromosa", types = { "BUG", "FIGHTING" },
      baseStats = { hp = 71, attack = 137, defense = 37, speed = 151, specialA = 137, specialD = 37 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.8, weightKg = 25,
      dexEntry = { kind = "Lissome Pokémon",
        text = "A life-form that lives in another world, its body is thin and supple, but it also possesses great power." },
    },

    XURKITREE = {
      dex = 796, name = "Xurkitree", types = { "ELECTRIC" },
      baseStats = { hp = 83, attack = 89, defense = 71, speed = 83, specialA = 173, specialD = 71 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.8, weightKg = 100,
      dexEntry = { kind = "Glowing Pokémon",
        text = "Although it’s alien to this world and a danger here, it’s apparently a common organism in the world where it normally lives." },
    },

    CELESTEELA = {
      dex = 797, name = "Celesteela", types = { "STEEL", "FLYING" },
      baseStats = { hp = 97, attack = 101, defense = 103, speed = 61, specialA = 107, specialD = 101 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 9.2, weightKg = 999.9,
      dexEntry = { kind = "Launch Pokémon",
        text = "One of the dangerous UBs, high energy readings can be detected coming from both of its huge arms." },
    },

    KARTANA = {
      dex = 798, name = "Kartana", types = { "GRASS", "STEEL" },
      baseStats = { hp = 59, attack = 181, defense = 131, speed = 109, specialA = 59, specialD = 31 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 0.3, weightKg = 0.1,
      dexEntry = { kind = "Drawn Sword Pokémon",
        text = "This Ultra Beast’s body, which is as thin as paper, is like a sharpened sword." },
    },

    GUZZLORD = {
      dex = 799, name = "Guzzlord", types = { "DARK", "DRAGON" },
      baseStats = { hp = 223, attack = 101, defense = 53, speed = 43, specialA = 97, specialD = 53 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 5.5, weightKg = 888,
      dexEntry = { kind = "Junkivore Pokémon",
        text = "Although it’s alien to this world and a danger here, it’s apparently a common organism in the world where it normally lives." },
    },

    NECROZMA = {
      dex = 800, name = "Necrozma", types = { "PSYCHIC" },
      baseStats = { hp = 97, attack = 107, defense = 101, speed = 79, specialA = 127, specialD = 89 },
      catchRate = 255, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2.4, weightKg = 230,
      dexEntry = { kind = "Prism Pokémon",
        text = "It looks somehow pained as it rages around in search of light, which serves as its energy. It’s apparently from another world." },
    },

    MAGEARNA = {
      dex = 801, name = "Magearna", types = { "STEEL", "FAIRY" },
      baseStats = { hp = 80, attack = 95, defense = 115, speed = 65, specialA = 130, specialD = 115 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1, weightKg = 80.5,
      dexEntry = { kind = "Artificial Pokémon",
        text = "It synchronizes its consciousness with others to understand their feelings. This faculty makes it useful for taking care of people." },
    },

    MARSHADOW = {
      dex = 802, name = "Marshadow", types = { "FIGHTING", "GHOST" },
      baseStats = { hp = 90, attack = 125, defense = 80, speed = 125, specialA = 90, specialD = 90 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 0.7, weightKg = 22.2,
      dexEntry = { kind = "Gloomdweller Pokémon",
        text = "It slips into the shadows of others and mimics their powers and movements. As it improves, it becomes stronger than those it’s imitating." },
    },

    POIPOLE = {
      dex = 803, name = "Poipole", types = { "POISON" },
      baseStats = { hp = 67, attack = 73, defense = 67, speed = 73, specialA = 73, specialD = 67 },
      catchRate = 45, baseExp = 210, growthRate = "SLOW", happiness = 0,
      evolutions = {
        { method = "HAS_MOVE", species = "NAGANADEL", move = "DRAGONPULSE" },
      },
      heightM = 0.6, weightKg = 1.8,
      dexEntry = { kind = "Poison Pin Pokémon",
        text = "This Ultra Beast is well enough liked to be chosen as a first partner in its own world." },
    },

    NAGANADEL = {
      dex = 804, name = "Naganadel", types = { "POISON", "DRAGON" },
      baseStats = { hp = 73, attack = 73, defense = 73, speed = 121, specialA = 127, specialD = 73 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.6, weightKg = 150,
      dexEntry = { kind = "Poison Pin Pokémon",
        text = "It stores hundreds of liters of poisonous liquid inside its body. It is one of the organisms known as UBs." },
    },

    STAKATAKA = {
      dex = 805, name = "Stakataka", types = { "ROCK", "STEEL" },
      baseStats = { hp = 61, attack = 131, defense = 211, speed = 13, specialA = 53, specialD = 101 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 5.5, weightKg = 820,
      dexEntry = { kind = "Rampart Pokémon",
        text = "It appeared from an Ultra Wormhole. Each one appears to be made up of many life-forms stacked one on top of each other." },
    },

    BLACEPHALON = {
      dex = 806, name = "Blacephalon", types = { "FIRE", "GHOST" },
      baseStats = { hp = 53, attack = 127, defense = 53, speed = 107, specialA = 151, specialD = 79 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.8, weightKg = 13,
      dexEntry = { kind = "Fireworks Pokémon",
        text = "It slithers toward people. Then, without warning, it triggers the explosion of its own head. It’s apparently one kind of Ultra Beast." },
    },

    ZERAORA = {
      dex = 807, name = "Zeraora", types = { "ELECTRIC" },
      baseStats = { hp = 88, attack = 112, defense = 75, speed = 143, specialA = 102, specialD = 80 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.5, weightKg = 44.5,
      dexEntry = { kind = "Thunderclap Pokémon",
        text = "It electrifies its claws and tears its opponents apart with them. Even if they dodge its attack, they’ll be electrocuted by the flying sparks." },
    },

    MELTAN = {
      dex = 808, name = "Meltan", types = { "STEEL" },
      baseStats = { hp = 46, attack = 65, defense = 65, speed = 34, specialA = 55, specialD = 35 },
      catchRate = 3, baseExp = 150, growthRate = "SLOW", happiness = 0,
      evolutions = {
        { method = "LEVEL", species = "MELMETAL", level = 45 },
      },
      heightM = 0.2, weightKg = 8,
      dexEntry = { kind = "Hex Nut Pokémon",
        text = "It melts particles of iron and other metals found in the subsoil, so it can absorb them into its body of molten steel." },
    },

    MELMETAL = {
      dex = 809, name = "Melmetal", types = { "STEEL" },
      baseStats = { hp = 135, attack = 143, defense = 143, speed = 34, specialA = 80, specialD = 65 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2.5, weightKg = 800,
      dexEntry = { kind = "Hex Nut Pokémon",
        text = "At the end of its life-span, Melmetal will rust and fall apart. The small shards left behind will eventually be reborn as Meltan." },
    },

    GROOKEY = {
      dex = 810, name = "Grookey", types = { "GRASS" },
      baseStats = { hp = 50, attack = 65, defense = 50, speed = 65, specialA = 40, specialD = 40 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "THWACKEY", level = 16 },
      },
      heightM = 0.3, weightKg = 5,
      dexEntry = { kind = "Chimp Pokémon",
        text = "When it uses its special stick to strike up a beat, the sound waves produced carry revitalizing energy to the plants and flowers in the area." },
    },

    THWACKEY = {
      dex = 811, name = "Thwackey", types = { "GRASS" },
      baseStats = { hp = 70, attack = 85, defense = 70, speed = 80, specialA = 55, specialD = 60 },
      catchRate = 45, baseExp = 147, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "RILLABOOM", level = 35 },
      },
      heightM = 0.7, weightKg = 14,
      dexEntry = { kind = "Beat Pokémon",
        text = "The faster a Thwackey can beat out a rhythm with its two sticks, the more respect it wins from its peers." },
    },

    RILLABOOM = {
      dex = 812, name = "Rillaboom", types = { "GRASS" },
      baseStats = { hp = 100, attack = 125, defense = 90, speed = 85, specialA = 60, specialD = 70 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.1, weightKg = 90,
      dexEntry = { kind = "Drummer Pokémon",
        text = "By drumming, it taps into the power of its special tree stump. The roots of the stump follow its direction in battle." },
    },

    SCORBUNNY = {
      dex = 813, name = "Scorbunny", types = { "FIRE" },
      baseStats = { hp = 50, attack = 71, defense = 40, speed = 69, specialA = 40, specialD = 40 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "RABOOT", level = 16 },
      },
      heightM = 0.3, weightKg = 4.5,
      dexEntry = { kind = "Rabbit Pokémon",
        text = "A warm-up of running around gets fire energy coursing through this Pokémon’s body. Once that happens, it’s ready to fight at full power." },
    },

    RABOOT = {
      dex = 814, name = "Raboot", types = { "FIRE" },
      baseStats = { hp = 65, attack = 86, defense = 60, speed = 94, specialA = 55, specialD = 60 },
      catchRate = 45, baseExp = 147, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CINDERACE", level = 35 },
      },
      heightM = 0.6, weightKg = 9,
      dexEntry = { kind = "Rabbit Pokémon",
        text = "Its thick and fluffy fur protects it from the cold and enables it to use hotter fire moves." },
    },

    CINDERACE = {
      dex = 815, name = "Cinderace", types = { "FIRE" },
      baseStats = { hp = 80, attack = 116, defense = 75, speed = 119, specialA = 65, specialD = 75 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 33,
      dexEntry = { kind = "Striker Pokémon",
        text = "It juggles a pebble with its feet, turning it into a burning soccer ball. Its shots strike opponents hard and leave them scorched." },
    },

    SOBBLE = {
      dex = 816, name = "Sobble", types = { "WATER" },
      baseStats = { hp = 50, attack = 40, defense = 40, speed = 70, specialA = 70, specialD = 40 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DRIZZILE", level = 16 },
      },
      heightM = 0.3, weightKg = 4,
      dexEntry = { kind = "Water Lizard Pokémon",
        text = "When scared, this Pokémon cries. Its tears pack the chemical punch of 100 onions, and attackers won’t be able to resist weeping." },
    },

    DRIZZILE = {
      dex = 817, name = "Drizzile", types = { "WATER" },
      baseStats = { hp = 65, attack = 60, defense = 55, speed = 90, specialA = 95, specialD = 55 },
      catchRate = 45, baseExp = 147, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "INTELEON", level = 35 },
      },
      heightM = 0.7, weightKg = 11.5,
      dexEntry = { kind = "Water Lizard Pokémon",
        text = "A clever combatant, this Pokémon battles using water balloons created with moisture secreted from its palms." },
    },

    INTELEON = {
      dex = 818, name = "Inteleon", types = { "WATER" },
      baseStats = { hp = 70, attack = 85, defense = 65, speed = 120, specialA = 125, specialD = 65 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 45.2,
      dexEntry = { kind = "Secret Agent Pokémon",
        text = "It has many hidden capabilities, such as fingertips that can shoot water and a membrane on its back that it can use to glide through the air." },
    },

    SKWOVET = {
      dex = 819, name = "Skwovet", types = { "NORMAL" },
      baseStats = { hp = 70, attack = 55, defense = 55, speed = 25, specialA = 35, specialD = 35 },
      catchRate = 255, baseExp = 55, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GREEDENT", level = 24 },
      },
      heightM = 0.3, weightKg = 2.5,
      dexEntry = { kind = "Cheeky Pokémon",
        text = "Found throughout the Galar region, this Pokémon becomes uneasy if its cheeks are ever completely empty of berries." },
    },

    GREEDENT = {
      dex = 820, name = "Greedent", types = { "NORMAL" },
      baseStats = { hp = 120, attack = 95, defense = 95, speed = 20, specialA = 55, specialD = 75 },
      catchRate = 90, baseExp = 161, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.6, weightKg = 6,
      dexEntry = { kind = "Greedy Pokémon",
        text = "It stashes berries in its tail—so many berries that they fall out constantly. But this Pokémon is a bit slow-witted, so it doesn’t notice the loss." },
    },

    ROOKIDEE = {
      dex = 821, name = "Rookidee", types = { "FLYING" },
      baseStats = { hp = 38, attack = 47, defense = 35, speed = 57, specialA = 33, specialD = 35 },
      catchRate = 255, baseExp = 49, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CORVISQUIRE", level = 18 },
      },
      heightM = 0.2, weightKg = 1.8,
      dexEntry = { kind = "Tiny Bird Pokémon",
        text = "It will bravely challenge any opponent, no matter how powerful. This Pokémon benefits from every battle—even a defeat increases its strength a bit." },
    },

    CORVISQUIRE = {
      dex = 822, name = "Corvisquire", types = { "FLYING" },
      baseStats = { hp = 68, attack = 67, defense = 55, speed = 77, specialA = 43, specialD = 55 },
      catchRate = 120, baseExp = 128, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CORVIKNIGHT", level = 38 },
      },
      heightM = 0.8, weightKg = 16,
      dexEntry = { kind = "Raven Pokémon",
        text = "Smart enough to use tools in battle, these Pokémon have been seen picking up rocks and flinging them or using ropes to wrap up enemies." },
    },

    CORVIKNIGHT = {
      dex = 823, name = "Corviknight", types = { "FLYING", "STEEL" },
      baseStats = { hp = 98, attack = 87, defense = 105, speed = 67, specialA = 53, specialD = 85 },
      catchRate = 45, baseExp = 248, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.2, weightKg = 75,
      dexEntry = { kind = "Raven Pokémon",
        text = "This Pokémon reigns supreme in the skies of the Galar region. The black luster of its steel body could drive terror into the heart of any foe." },
    },

    BLIPBUG = {
      dex = 824, name = "Blipbug", types = { "BUG" },
      baseStats = { hp = 25, attack = 20, defense = 20, speed = 45, specialA = 25, specialD = 45 },
      catchRate = 255, baseExp = 36, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DOTTLER", level = 10 },
      },
      heightM = 0.4, weightKg = 8,
      dexEntry = { kind = "Larva Pokémon",
        text = "A constant collector of information, this Pokémon is very smart. Very strong is what it isn’t." },
    },

    DOTTLER = {
      dex = 825, name = "Dottler", types = { "BUG", "PSYCHIC" },
      baseStats = { hp = 50, attack = 35, defense = 80, speed = 30, specialA = 50, specialD = 90 },
      catchRate = 120, baseExp = 117, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ORBEETLE", level = 30 },
      },
      heightM = 0.4, weightKg = 19.5,
      dexEntry = { kind = "Radome Pokémon",
        text = "It barely moves, but it’s still alive. Hiding in its shell without food or water seems to have awakened its psychic powers." },
    },

    ORBEETLE = {
      dex = 826, name = "Orbeetle", types = { "BUG", "PSYCHIC" },
      baseStats = { hp = 60, attack = 45, defense = 110, speed = 90, specialA = 80, specialD = 120 },
      catchRate = 45, baseExp = 253, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.4, weightKg = 40.8,
      dexEntry = { kind = "Seven Spot Pokémon",
        text = "It’s famous for its high level of intelligence, and the large size of its brain is proof that it also possesses immense psychic power." },
    },

    NICKIT = {
      dex = 827, name = "Nickit", types = { "DARK" },
      baseStats = { hp = 40, attack = 28, defense = 28, speed = 50, specialA = 47, specialD = 52 },
      catchRate = 255, baseExp = 49, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "THIEVUL", level = 18 },
      },
      heightM = 0.6, weightKg = 8.9,
      dexEntry = { kind = "Fox Pokémon",
        text = "Aided by the soft pads on its feet, it silently raids the food stores of other Pokémon. It survives off its ill-gotten gains." },
    },

    THIEVUL = {
      dex = 828, name = "Thievul", types = { "DARK" },
      baseStats = { hp = 70, attack = 58, defense = 58, speed = 90, specialA = 87, specialD = 92 },
      catchRate = 127, baseExp = 159, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 19.9,
      dexEntry = { kind = "Fox Pokémon",
        text = "It secretly marks potential targets with a scent. By following the scent, it stalks its targets and steals from them when they least expect it." },
    },

    GOSSIFLEUR = {
      dex = 829, name = "Gossifleur", types = { "GRASS" },
      baseStats = { hp = 40, attack = 40, defense = 60, speed = 10, specialA = 40, specialD = 60 },
      catchRate = 190, baseExp = 50, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ELDEGOSS", level = 20 },
      },
      heightM = 0.4, weightKg = 2.2,
      dexEntry = { kind = "Flowering Pokémon",
        text = "It anchors itself in the ground with its single leg, then basks in the sun. After absorbing enough sunlight, its petals spread as it blooms brilliantly." },
    },

    ELDEGOSS = {
      dex = 830, name = "Eldegoss", types = { "GRASS" },
      baseStats = { hp = 60, attack = 50, defense = 90, speed = 60, specialA = 80, specialD = 120 },
      catchRate = 75, baseExp = 161, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.5, weightKg = 2.5,
      dexEntry = { kind = "Cotton Bloom Pokémon",
        text = "The seeds attached to its cotton fluff are full of nutrients. It spreads them on the wind so that plants and other Pokémon can benefit from them." },
    },

    WOOLOO = {
      dex = 831, name = "Wooloo", types = { "NORMAL" },
      baseStats = { hp = 42, attack = 40, defense = 55, speed = 48, specialA = 40, specialD = 45 },
      catchRate = 255, baseExp = 122, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DUBWOOL", level = 24 },
      },
      heightM = 0.6, weightKg = 6,
      dexEntry = { kind = "Sheep Pokémon",
        text = "Its curly fleece is such an effective cushion that this Pokémon could fall off a cliff and stand right back up at the bottom, unharmed." },
    },

    DUBWOOL = {
      dex = 832, name = "Dubwool", types = { "NORMAL" },
      baseStats = { hp = 72, attack = 80, defense = 100, speed = 88, specialA = 60, specialD = 90 },
      catchRate = 127, baseExp = 172, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 43,
      dexEntry = { kind = "Sheep Pokémon",
        text = "Weave a carpet from its springy wool, and you end up with something closer to a trampoline. You’ll start to bounce the moment you set foot on it." },
    },

    CHEWTLE = {
      dex = 833, name = "Chewtle", types = { "WATER" },
      baseStats = { hp = 50, attack = 64, defense = 50, speed = 44, specialA = 38, specialD = 38 },
      catchRate = 255, baseExp = 57, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DREDNAW", level = 22 },
      },
      heightM = 0.3, weightKg = 8.5,
      dexEntry = { kind = "Snapping Pokémon",
        text = "Apparently the itch of its teething impels it to snap its jaws at anything in front of it." },
    },

    DREDNAW = {
      dex = 834, name = "Drednaw", types = { "WATER", "ROCK" },
      baseStats = { hp = 90, attack = 115, defense = 90, speed = 74, specialA = 48, specialD = 68 },
      catchRate = 75, baseExp = 170, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 115.5,
      dexEntry = { kind = "Bite Pokémon",
        text = "With jaws that can shear through steel rods, this highly aggressive Pokémon chomps down on its unfortunate prey." },
    },

    YAMPER = {
      dex = 835, name = "Yamper", types = { "ELECTRIC" },
      baseStats = { hp = 59, attack = 45, defense = 50, speed = 26, specialA = 40, specialD = 50 },
      catchRate = 255, baseExp = 54, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BOLTUND", level = 25 },
      },
      heightM = 0.3, weightKg = 13.5,
      dexEntry = { kind = "Puppy Pokémon",
        text = "This Pokémon is very popular as a herding dog in the Galar region. As it runs, it generates electricity from the base of its tail." },
    },

    BOLTUND = {
      dex = 836, name = "Boltund", types = { "ELECTRIC" },
      baseStats = { hp = 69, attack = 90, defense = 60, speed = 121, specialA = 90, specialD = 60 },
      catchRate = 45, baseExp = 172, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 34,
      dexEntry = { kind = "Dog Pokémon",
        text = "This Pokémon generates electricity and channels it into its legs to keep them going strong. Boltund can run nonstop for three full days." },
    },

    ROLYCOLY = {
      dex = 837, name = "Rolycoly", types = { "ROCK" },
      baseStats = { hp = 30, attack = 40, defense = 50, speed = 30, specialA = 40, specialD = 50 },
      catchRate = 255, baseExp = 48, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CARKOL", level = 18 },
      },
      heightM = 0.3, weightKg = 12,
      dexEntry = { kind = "Coal Pokémon",
        text = "Most of its body has the same composition as coal. Fittingly, this Pokémon was first discovered in coal mines about 400 years ago." },
    },

    CARKOL = {
      dex = 838, name = "Carkol", types = { "ROCK", "FIRE" },
      baseStats = { hp = 80, attack = 60, defense = 90, speed = 50, specialA = 60, specialD = 70 },
      catchRate = 120, baseExp = 144, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "COALOSSAL", level = 34 },
      },
      heightM = 1.1, weightKg = 78,
      dexEntry = { kind = "Coal Pokémon",
        text = "It forms coal inside its body. Coal dropped by this Pokémon once helped fuel the lives of people in the Galar region." },
    },

    COALOSSAL = {
      dex = 839, name = "Coalossal", types = { "ROCK", "FIRE" },
      baseStats = { hp = 110, attack = 80, defense = 120, speed = 30, specialA = 80, specialD = 90 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.8, weightKg = 310.5,
      dexEntry = { kind = "Coal Pokémon",
        text = "It’s usually peaceful, but the vandalism of mines enrages it. Offenders will be incinerated with flames that reach 2,700 degrees Fahrenheit." },
    },

    APPLIN = {
      dex = 840, name = "Applin", types = { "GRASS", "DRAGON" },
      baseStats = { hp = 40, attack = 40, defense = 80, speed = 20, specialA = 40, specialD = 40 },
      catchRate = 255, baseExp = 52, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "FLAPPLE", item = "TARTAPPLE" },
        { method = "ITEM", species = "APPLETUN", item = "SWEETAPPLE" },
        { method = "ITEM", species = "DIPPLIN", item = "SYRUPYAPPLE" },
      },
      heightM = 0.2, weightKg = 0.5,
      dexEntry = { kind = "Apple Core Pokémon",
        text = "It spends its entire life inside an apple. It hides from its natural enemies, bird Pokémon, by pretending it’s just an apple and nothing more." },
    },

    FLAPPLE = {
      dex = 841, name = "Flapple", types = { "GRASS", "DRAGON" },
      baseStats = { hp = 70, attack = 110, defense = 80, speed = 70, specialA = 95, specialD = 60 },
      catchRate = 45, baseExp = 170, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 1,
      dexEntry = { kind = "Apple Wing Pokémon",
        text = "It ate a sour apple, and that induced its evolution. In its cheeks, it stores an acid capable of causing chemical burns." },
    },

    APPLETUN = {
      dex = 842, name = "Appletun", types = { "GRASS", "DRAGON" },
      baseStats = { hp = 110, attack = 85, defense = 80, speed = 30, specialA = 100, specialD = 80 },
      catchRate = 45, baseExp = 170, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 0.4, weightKg = 13,
      dexEntry = { kind = "Apple Nectar Pokémon",
        text = "Eating a sweet apple caused its evolution. A nectarous scent wafts from its body, luring in the bug Pokémon it preys on." },
    },

    SILICOBRA = {
      dex = 843, name = "Silicobra", types = { "GROUND" },
      baseStats = { hp = 52, attack = 57, defense = 75, speed = 46, specialA = 35, specialD = 50 },
      catchRate = 255, baseExp = 63, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SANDACONDA", level = 36 },
      },
      heightM = 2.2, weightKg = 7.6,
      dexEntry = { kind = "Sand Snake Pokémon",
        text = "As it digs, it swallows sand and stores it in its neck pouch. The pouch can hold more than 17 pounds of sand." },
    },

    SANDACONDA = {
      dex = 844, name = "Sandaconda", types = { "GROUND" },
      baseStats = { hp = 72, attack = 107, defense = 125, speed = 71, specialA = 65, specialD = 70 },
      catchRate = 120, baseExp = 179, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 3.8, weightKg = 65.5,
      dexEntry = { kind = "Sand Snake Pokémon",
        text = "When it contracts its body, over 220 pounds of sand sprays from its nose. If it ever runs out of sand, it becomes disheartened." },
    },

    CRAMORANT = {
      dex = 845, name = "Cramorant", types = { "FLYING", "WATER" },
      baseStats = { hp = 70, attack = 85, defense = 55, speed = 85, specialA = 85, specialD = 95 },
      catchRate = 45, baseExp = 166, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 18,
      dexEntry = { kind = "Gulp Pokémon",
        text = "It’s so strong that it can knock out some opponents in a single hit, but it also may forget what it’s battling midfight." },
    },

    ARROKUDA = {
      dex = 846, name = "Arrokuda", types = { "WATER" },
      baseStats = { hp = 41, attack = 63, defense = 40, speed = 66, specialA = 40, specialD = 30 },
      catchRate = 255, baseExp = 56, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BARRASKEWDA", level = 26 },
      },
      heightM = 0.5, weightKg = 1,
      dexEntry = { kind = "Rush Pokémon",
        text = "If it sees any movement around it, this Pokémon charges for it straightaway, leading with its sharply pointed jaw. It’s very proud of that jaw." },
    },

    BARRASKEWDA = {
      dex = 847, name = "Barraskewda", types = { "WATER" },
      baseStats = { hp = 61, attack = 123, defense = 60, speed = 136, specialA = 60, specialD = 50 },
      catchRate = 60, baseExp = 172, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 30,
      dexEntry = { kind = "Skewer Pokémon",
        text = "This Pokémon has a jaw that’s as sharp as a spear and as strong as steel. Apparently Barraskewda’s flesh is surprisingly tasty, too." },
    },

    TOXEL = {
      dex = 848, name = "Toxel", types = { "ELECTRIC", "POISON" },
      baseStats = { hp = 40, attack = 38, defense = 35, speed = 40, specialA = 54, specialD = 35 },
      catchRate = 75, baseExp = 48, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TOXTRICITY", level = 30 },
      },
      heightM = 0.4, weightKg = 11,
      dexEntry = { kind = "Baby Pokémon",
        text = "It stores poison in an internal poison sac and secretes that poison through its skin. If you touch this Pokémon, a tingling sensation follows." },
    },

    TOXTRICITY = {
      dex = 849, name = "Toxtricity", types = { "ELECTRIC", "POISON" },
      baseStats = { hp = 75, attack = 98, defense = 70, speed = 75, specialA = 114, specialD = 70 },
      catchRate = 45, baseExp = 176, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 40,
      dexEntry = { kind = "Punk Pokémon",
        text = "Capable of generating 15,000 volts of electricity, this Pokémon looks down on all that would challenge it." },
    },

    SIZZLIPEDE = {
      dex = 850, name = "Sizzlipede", types = { "FIRE", "BUG" },
      baseStats = { hp = 50, attack = 65, defense = 45, speed = 45, specialA = 50, specialD = 50 },
      catchRate = 190, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CENTISKORCH", level = 28 },
      },
      heightM = 0.7, weightKg = 1,
      dexEntry = { kind = "Radiator Pokémon",
        text = "It stores flammable gas in its body and uses it to generate heat. The yellow sections on its belly get particularly hot." },
    },

    CENTISKORCH = {
      dex = 851, name = "Centiskorch", types = { "FIRE", "BUG" },
      baseStats = { hp = 100, attack = 115, defense = 65, speed = 65, specialA = 90, specialD = 90 },
      catchRate = 75, baseExp = 184, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 3, weightKg = 120,
      dexEntry = { kind = "Radiator Pokémon",
        text = "When it heats up, its body temperature reaches about 1,500 degrees Fahrenheit. It lashes its body like a whip and launches itself at enemies." },
    },

    CLOBBOPUS = {
      dex = 852, name = "Clobbopus", types = { "FIGHTING" },
      baseStats = { hp = 50, attack = 68, defense = 60, speed = 32, specialA = 50, specialD = 50 },
      catchRate = 180, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "HAS_MOVE", species = "GRAPPLOCT", move = "TAUNT" },
      },
      heightM = 0.6, weightKg = 4,
      dexEntry = { kind = "Tantrum Pokémon",
        text = "It’s very curious, but its means of investigating things is to try to punch them with its tentacles. The search for food is what brings it onto land." },
    },

    GRAPPLOCT = {
      dex = 853, name = "Grapploct", types = { "FIGHTING" },
      baseStats = { hp = 80, attack = 118, defense = 90, speed = 42, specialA = 70, specialD = 80 },
      catchRate = 45, baseExp = 168, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 39,
      dexEntry = { kind = "Jujitsu Pokémon",
        text = "A body made up of nothing but muscle makes the grappling moves this Pokémon performs with its tentacles tremendously powerful." },
    },

    SINISTEA = {
      dex = 854, name = "Sinistea", types = { "GHOST" },
      baseStats = { hp = 40, attack = 45, defense = 45, speed = 50, specialA = 74, specialD = 54 },
      catchRate = 120, baseExp = 62, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "POLTEAGEIST", item = "CRACKEDPOT" },
      },
      heightM = 0.1, weightKg = 0.2,
      dexEntry = { kind = "Black Tea Pokémon",
        text = "This Pokémon is said to have been born when a lonely spirit possessed a cold, leftover cup of tea." },
    },

    POLTEAGEIST = {
      dex = 855, name = "Polteageist", types = { "GHOST" },
      baseStats = { hp = 60, attack = 65, defense = 65, speed = 70, specialA = 134, specialD = 114 },
      catchRate = 60, baseExp = 178, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.2, weightKg = 0.4,
      dexEntry = { kind = "Black Tea Pokémon",
        text = "This species lives in antique teapots. Most pots are forgeries, but on rare occasions, an authentic work is found." },
    },

    HATENNA = {
      dex = 856, name = "Hatenna", types = { "PSYCHIC" },
      baseStats = { hp = 42, attack = 30, defense = 45, speed = 39, specialA = 56, specialD = 53 },
      catchRate = 235, baseExp = 53, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "HATTREM", level = 32 },
      },
      heightM = 0.4, weightKg = 3.4,
      dexEntry = { kind = "Calm Pokémon",
        text = "Via the protrusion on its head, it senses other creatures’ emotions. If you don’t have a calm disposition, it will never warm up to you." },
    },

    HATTREM = {
      dex = 857, name = "Hattrem", types = { "PSYCHIC" },
      baseStats = { hp = 57, attack = 40, defense = 65, speed = 49, specialA = 86, specialD = 73 },
      catchRate = 120, baseExp = 130, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "HATTERENE", level = 42 },
      },
      heightM = 0.6, weightKg = 4.8,
      dexEntry = { kind = "Serene Pokémon",
        text = "No matter who you are, if you bring strong emotions near this Pokémon, it will silence you violently." },
    },

    HATTERENE = {
      dex = 858, name = "Hatterene", types = { "PSYCHIC", "FAIRY" },
      baseStats = { hp = 57, attack = 90, defense = 95, speed = 29, specialA = 136, specialD = 103 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.1, weightKg = 5.1,
      dexEntry = { kind = "Silent Pokémon",
        text = "It emits psychic power strong enough to cause headaches as a deterrent to the approach of others." },
    },

    IMPIDIMP = {
      dex = 859, name = "Impidimp", types = { "DARK", "FAIRY" },
      baseStats = { hp = 45, attack = 45, defense = 30, speed = 50, specialA = 55, specialD = 40 },
      catchRate = 255, baseExp = 53, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MORGREM", level = 32 },
      },
      heightM = 0.4, weightKg = 5.5,
      dexEntry = { kind = "Wily Pokémon",
        text = "Through its nose, it sucks in the emanations produced by people and Pokémon when they feel annoyed. It thrives off this negative energy." },
    },

    MORGREM = {
      dex = 860, name = "Morgrem", types = { "DARK", "FAIRY" },
      baseStats = { hp = 65, attack = 60, defense = 45, speed = 70, specialA = 75, specialD = 55 },
      catchRate = 120, baseExp = 130, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GRIMMSNARL", level = 42 },
      },
      heightM = 0.8, weightKg = 12.5,
      dexEntry = { kind = "Devious Pokémon",
        text = "When it gets down on all fours as if to beg for forgiveness, it’s trying to lure opponents in so that it can stab them with its spear-like hair." },
    },

    GRIMMSNARL = {
      dex = 861, name = "Grimmsnarl", types = { "DARK", "FAIRY" },
      baseStats = { hp = 95, attack = 120, defense = 65, speed = 60, specialA = 95, specialD = 75 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 61,
      dexEntry = { kind = "Bulk Up Pokémon",
        text = "With the hair wrapped around its body helping to enhance its muscles, this Pokémon can overwhelm even Machamp." },
    },

    OBSTAGOON = {
      dex = 862, name = "Obstagoon", types = { "DARK", "NORMAL" },
      baseStats = { hp = 93, attack = 90, defense = 101, speed = 95, specialA = 60, specialD = 81 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 46,
      dexEntry = { kind = "Blocking Pokémon",
        text = "Its voice is staggering in volume. Obstagoon has a tendency to take on a threatening posture and shout—this move is known as Obstruct." },
    },

    PERRSERKER = {
      dex = 863, name = "Perrserker", types = { "STEEL" },
      baseStats = { hp = 70, attack = 110, defense = 100, speed = 50, specialA = 50, specialD = 60 },
      catchRate = 90, baseExp = 154, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 28,
      dexEntry = { kind = "Viking Pokémon",
        text = "What appears to be an iron helmet is actually hardened hair. This Pokémon lives for the thrill of battle." },
    },

    CURSOLA = {
      dex = 864, name = "Cursola", types = { "GHOST" },
      baseStats = { hp = 60, attack = 95, defense = 50, speed = 30, specialA = 145, specialD = 130 },
      catchRate = 30, baseExp = 179, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 0.4,
      dexEntry = { kind = "Coral Pokémon",
        text = "Its shell is overflowing with its heightened otherworldly energy. The ectoplasm serves as protection for this Pokémon’s core spirit." },
    },

    SIRFETCHD = {
      dex = 865, name = "Sirfetch'd", types = { "FIGHTING" },
      baseStats = { hp = 62, attack = 135, defense = 95, speed = 65, specialA = 68, specialD = 82 },
      catchRate = 45, baseExp = 177, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.8, weightKg = 117,
      dexEntry = { kind = "Wild Duck Pokémon",
        text = "Only Farfetch’d that have survived many battles can attain this evolution. When this Pokémon’s leek withers, it will retire from combat." },
    },

    MRRIME = {
      dex = 866, name = "Mr. Rime", types = { "ICE", "PSYCHIC" },
      baseStats = { hp = 80, attack = 85, defense = 75, speed = 70, specialA = 110, specialD = 100 },
      catchRate = 45, baseExp = 182, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 58.2,
      dexEntry = { kind = "Comedian Pokémon",
        text = "It’s highly skilled at tap-dancing. It waves its cane of ice in time with its graceful movements." },
    },

    RUNERIGUS = {
      dex = 867, name = "Runerigus", types = { "GROUND", "GHOST" },
      baseStats = { hp = 58, attack = 95, defense = 145, speed = 30, specialA = 50, specialD = 105 },
      catchRate = 90, baseExp = 169, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 66.6,
      dexEntry = { kind = "Grudge Pokémon",
        text = "A powerful curse was woven into an ancient painting. After absorbing the spirit of a Yamask, the painting began to move." },
    },

    MILCERY = {
      dex = 868, name = "Milcery", types = { "FAIRY" },
      baseStats = { hp = 45, attack = 40, defense = 40, speed = 34, specialA = 50, specialD = 61 },
      catchRate = 200, baseExp = 54, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HOLDITEM", species = "ALCREMIE" },
        { method = "HOLDITEM", species = "ALCREMIE" },
        { method = "HOLDITEM", species = "ALCREMIE" },
        { method = "HOLDITEM", species = "ALCREMIE" },
        { method = "HOLDITEM", species = "ALCREMIE" },
        { method = "HOLDITEM", species = "ALCREMIE" },
        { method = "HOLDITEM", species = "ALCREMIE" },
      },
      heightM = 0.2, weightKg = 0.3,
      dexEntry = { kind = "Cream Pokémon",
        text = "This Pokémon was born from sweet-smelling particles in the air. Its body is made of cream." },
    },

    ALCREMIE = {
      dex = 869, name = "Alcremie", types = { "FAIRY" },
      baseStats = { hp = 65, attack = 60, defense = 75, speed = 64, specialA = 110, specialD = 121 },
      catchRate = 100, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 0.5,
      dexEntry = { kind = "Cream Pokémon",
        text = "When it trusts a Trainer, it will treat them to berries it's decorated with cream." },
    },

    FALINKS = {
      dex = 870, name = "Falinks", types = { "FIGHTING" },
      baseStats = { hp = 65, attack = 100, defense = 100, speed = 75, specialA = 70, specialD = 60 },
      catchRate = 45, baseExp = 165, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 3, weightKg = 62,
      dexEntry = { kind = "Formation Pokémon",
        text = "Five of them are troopers, and one is the brass. The brass’s orders are absolute." },
    },

    PINCURCHIN = {
      dex = 871, name = "Pincurchin", types = { "ELECTRIC" },
      baseStats = { hp = 48, attack = 101, defense = 95, speed = 15, specialA = 91, specialD = 85 },
      catchRate = 75, baseExp = 152, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 1,
      dexEntry = { kind = "Sea Urchin Pokémon",
        text = "It feeds on seaweed, using its teeth to scrape it off rocks. Electric current flows from the tips of its spines." },
    },

    SNOM = {
      dex = 872, name = "Snom", types = { "ICE", "BUG" },
      baseStats = { hp = 30, attack = 25, defense = 35, speed = 20, specialA = 45, specialD = 30 },
      catchRate = 190, baseExp = 37, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "HAPPINESSNIGHT", species = "FROSMOTH" },
      },
      heightM = 0.3, weightKg = 3.8,
      dexEntry = { kind = "Worm Pokémon",
        text = "It spits out thread imbued with a frigid sort of energy and uses it to tie its body to branches, disguising itself as an icicle while it sleeps." },
    },

    FROSMOTH = {
      dex = 873, name = "Frosmoth", types = { "ICE", "BUG" },
      baseStats = { hp = 70, attack = 65, defense = 60, speed = 65, specialA = 125, specialD = 90 },
      catchRate = 75, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 42,
      dexEntry = { kind = "Frost Moth Pokémon",
        text = "Icy scales fall from its wings like snow as it flies over fields and mountains. The temperature of its wings is less than −290 degrees Fahrenheit." },
    },

    STONJOURNER = {
      dex = 874, name = "Stonjourner", types = { "ROCK" },
      baseStats = { hp = 100, attack = 125, defense = 135, speed = 70, specialA = 20, specialD = 20 },
      catchRate = 60, baseExp = 165, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.5, weightKg = 520,
      dexEntry = { kind = "Big Rock Pokémon",
        text = "It stands in grasslands, watching the sun’s descent from zenith to horizon. This Pokémon has a talent for delivering dynamic kicks." },
    },

    EISCUE = {
      dex = 875, name = "Eiscue", types = { "ICE" },
      baseStats = { hp = 75, attack = 80, defense = 110, speed = 50, specialA = 65, specialD = 90 },
      catchRate = 60, baseExp = 165, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 89,
      dexEntry = { kind = "Penguin Pokémon",
        text = "It drifted in on the flow of ocean waters from a frigid place. It keeps its head iced constantly to make sure it stays nice and cold." },
    },

    INDEEDEE = {
      dex = 876, name = "Indeedee", types = { "PSYCHIC", "NORMAL" },
      baseStats = { hp = 60, attack = 65, defense = 55, speed = 95, specialA = 105, specialD = 95 },
      catchRate = 30, baseExp = 166, growthRate = "FAST", happiness = 140,
      evolutions = {},
      heightM = 0.9, weightKg = 28,
      dexEntry = { kind = "Emotion Pokémon",
        text = "It uses the horns on its head to sense the emotions of others. Males will act as valets for those they serve, looking after their every need." },
    },

    MORPEKO = {
      dex = 877, name = "Morpeko", types = { "ELECTRIC", "DARK" },
      baseStats = { hp = 58, attack = 95, defense = 58, speed = 97, specialA = 70, specialD = 58 },
      catchRate = 180, baseExp = 153, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 3,
      dexEntry = { kind = "Two-Sided Pokémon",
        text = "As it eats the seeds stored up in its pocket-like pouches, this Pokémon is not just satisfying its constant hunger. It’s also generating electricity." },
    },

    CUFANT = {
      dex = 878, name = "Cufant", types = { "STEEL" },
      baseStats = { hp = 72, attack = 80, defense = 49, speed = 40, specialA = 40, specialD = 49 },
      catchRate = 190, baseExp = 66, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "COPPERAJAH", level = 34 },
      },
      heightM = 1.2, weightKg = 100,
      dexEntry = { kind = "Copperderm Pokémon",
        text = "It digs up the ground with its trunk. It’s also very strong, being able to carry loads of over five tons without any problem at all." },
    },

    COPPERAJAH = {
      dex = 879, name = "Copperajah", types = { "STEEL" },
      baseStats = { hp = 122, attack = 130, defense = 69, speed = 30, specialA = 80, specialD = 69 },
      catchRate = 90, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 3, weightKg = 650,
      dexEntry = { kind = "Copperderm Pokémon",
        text = "They came over from another region long ago and worked together with humans. Their green skin is resistant to water." },
    },

    DRACOZOLT = {
      dex = 880, name = "Dracozolt", types = { "ELECTRIC", "DRAGON" },
      baseStats = { hp = 90, attack = 100, defense = 90, speed = 75, specialA = 80, specialD = 70 },
      catchRate = 45, baseExp = 177, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 190,
      dexEntry = { kind = "Fossil Pokémon",
        text = "In ancient times, it was unbeatable thanks to its powerful lower body, but it went extinct anyway after it depleted all its plant-based food sources." },
    },

    ARCTOZOLT = {
      dex = 881, name = "Arctozolt", types = { "ELECTRIC", "ICE" },
      baseStats = { hp = 90, attack = 100, defense = 90, speed = 55, specialA = 90, specialD = 80 },
      catchRate = 45, baseExp = 177, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.3, weightKg = 150,
      dexEntry = { kind = "Fossil Pokémon",
        text = "The shaking of its freezing upper half is what generates its electricity. It has a hard time walking around." },
    },

    DRACOVISH = {
      dex = 882, name = "Dracovish", types = { "WATER", "DRAGON" },
      baseStats = { hp = 90, attack = 90, defense = 100, speed = 75, specialA = 70, specialD = 80 },
      catchRate = 45, baseExp = 177, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.3, weightKg = 215,
      dexEntry = { kind = "Fossil Pokémon",
        text = "Powerful legs and jaws made it the apex predator of its time. Its own overhunting of its prey was what drove it to extinction." },
    },

    ARCTOVISH = {
      dex = 883, name = "Arctovish", types = { "WATER", "ICE" },
      baseStats = { hp = 90, attack = 90, defense = 100, speed = 55, specialA = 80, specialD = 90 },
      catchRate = 45, baseExp = 177, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 175,
      dexEntry = { kind = "Fossil Pokémon",
        text = "Though it’s able to capture prey by freezing its surroundings, it has trouble eating the prey afterward because its mouth is on top of its head." },
    },

    DURALUDON = {
      dex = 884, name = "Duraludon", types = { "STEEL", "DRAGON" },
      baseStats = { hp = 70, attack = 95, defense = 115, speed = 85, specialA = 120, specialD = 50 },
      catchRate = 45, baseExp = 187, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "ARCHALUDON", item = "METALALLOY" },
      },
      heightM = 1.8, weightKg = 40,
      dexEntry = { kind = "Alloy Pokémon",
        text = "Its body resembles polished metal, and it’s both lightweight and strong. The only drawback is that it rusts easily." },
    },

    DREEPY = {
      dex = 885, name = "Dreepy", types = { "DRAGON", "GHOST" },
      baseStats = { hp = 28, attack = 60, defense = 30, speed = 82, specialA = 40, specialD = 30 },
      catchRate = 45, baseExp = 54, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DRAKLOAK", level = 50 },
      },
      heightM = 0.5, weightKg = 2,
      dexEntry = { kind = "Lingering Pokémon",
        text = "After being reborn as a ghost Pokémon, Dreepy wanders the areas it used to inhabit back when it was alive in prehistoric seas." },
    },

    DRAKLOAK = {
      dex = 886, name = "Drakloak", types = { "DRAGON", "GHOST" },
      baseStats = { hp = 68, attack = 80, defense = 50, speed = 102, specialA = 60, specialD = 50 },
      catchRate = 45, baseExp = 144, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DRAGAPULT", level = 60 },
      },
      heightM = 1.4, weightKg = 11,
      dexEntry = { kind = "Caretaker Pokémon",
        text = "It’s capable of flying faster than 120 mph. It battles alongside Dreepy and dotes on them until they successfully evolve." },
    },

    DRAGAPULT = {
      dex = 887, name = "Dragapult", types = { "DRAGON", "GHOST" },
      baseStats = { hp = 88, attack = 120, defense = 75, speed = 142, specialA = 100, specialD = 75 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 3, weightKg = 50,
      dexEntry = { kind = "Stealth Pokémon",
        text = "When it isn’t battling, it keeps Dreepy in the holes on its horns. Once a fight starts, it launches the Dreepy like supersonic missiles." },
    },

    ZACIAN = {
      dex = 888, name = "Zacian", types = { "FAIRY" },
      baseStats = { hp = 92, attack = 130, defense = 115, speed = 138, specialA = 80, specialD = 115 },
      catchRate = 10, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2.8, weightKg = 110,
      dexEntry = { kind = "Warrior Pokémon",
        text = "Known as a legendary hero, this Pokémon absorbs metal particles, transforming them into a weapon it uses to battle." },
    },

    ZAMAZENTA = {
      dex = 889, name = "Zamazenta", types = { "FIGHTING" },
      baseStats = { hp = 92, attack = 130, defense = 115, speed = 138, specialA = 80, specialD = 115 },
      catchRate = 10, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2.9, weightKg = 210,
      dexEntry = { kind = "Warrior Pokémon",
        text = "In times past, it worked together with a king of the people to save the Galar region. It absorbs metal that it then uses in battle." },
    },

    ETERNATUS = {
      dex = 890, name = "Eternatus", types = { "POISON", "DRAGON" },
      baseStats = { hp = 140, attack = 85, defense = 95, speed = 130, specialA = 145, specialD = 95 },
      catchRate = 255, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 20, weightKg = 950,
      dexEntry = { kind = "Gigantic Pokémon",
        text = "The core on its chest absorbs energy emanating from the lands of the Galar region. This energy is what allows Eternatus to stay active." },
    },

    KUBFU = {
      dex = 891, name = "Kubfu", types = { "FIGHTING" },
      baseStats = { hp = 60, attack = 90, defense = 60, speed = 72, specialA = 53, specialD = 50 },
      catchRate = 3, baseExp = 77, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "URSHIFU", item = "SCROLLOFDARKNESS" },
        { method = "ITEM", species = "URSHIFU", item = "SCROLLOFWATERS" },
      },
      heightM = 0.6, weightKg = 12,
      dexEntry = { kind = "Wushu Pokémon",
        text = "Kubfu trains hard to perfect its moves. The moves it masters will determine which form it takes when it evolves." },
    },

    URSHIFU = {
      dex = 892, name = "Urshifu", types = { "FIGHTING", "DARK" },
      baseStats = { hp = 100, attack = 130, defense = 100, speed = 97, specialA = 63, specialD = 60 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 105,
      dexEntry = { kind = "Wushu Pokémon",
        text = "This form of Urshifu is a strong believer in the one-hit KO. Its strategy is to leap in close to foes and land a devastating blow with a hardened fist." },
    },

    ZARUDE = {
      dex = 893, name = "Zarude", types = { "DARK", "GRASS" },
      baseStats = { hp = 105, attack = 120, defense = 105, speed = 105, specialA = 70, specialD = 95 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.8, weightKg = 70,
      dexEntry = { kind = "Rogue Monkey Pokémon",
        text = "Within dense forests, this Pokémon lives in a pack with others of its kind. It's incredibly aggressive and the other Pokémon of the forest fear it." },
    },

    REGIELEKI = {
      dex = 894, name = "Regieleki", types = { "ELECTRIC" },
      baseStats = { hp = 80, attack = 100, defense = 50, speed = 200, specialA = 100, specialD = 50 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.2, weightKg = 145,
      dexEntry = { kind = "Electron Pokémon",
        text = "This Pokémon is a cluster of electrical energy. It’s said that removing the rings on Regieleki’s body will unleash the Pokémon’s latent power." },
    },

    REGIDRAGO = {
      dex = 895, name = "Regidrago", types = { "DRAGON" },
      baseStats = { hp = 200, attack = 100, defense = 50, speed = 80, specialA = 100, specialD = 50 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2.1, weightKg = 200,
      dexEntry = { kind = "Dragon Orb Pokémon",
        text = "An academic theory proposes that Regidrago’s arms were once the head of an ancient dragon Pokémon. The theory remains unproven." },
    },

    GLASTRIER = {
      dex = 896, name = "Glastrier", types = { "ICE" },
      baseStats = { hp = 100, attack = 145, defense = 130, speed = 30, specialA = 65, specialD = 110 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2.2, weightKg = 800,
      dexEntry = { kind = "Wild Horse Pokémon",
        text = "Glastrier emits intense cold from its hooves. It’s also a belligerent Pokémon—anything it wants, it takes by force." },
    },

    SPECTRIER = {
      dex = 897, name = "Spectrier", types = { "GHOST" },
      baseStats = { hp = 100, attack = 65, defense = 60, speed = 130, specialA = 145, specialD = 80 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 35,
      evolutions = {},
      heightM = 2, weightKg = 44.5,
      dexEntry = { kind = "Swift Horse Pokémon",
        text = "It probes its surroundings with all its senses save one—it doesn’t use its sense of sight. Spectrier’s kicks are said to separate soul from body." },
    },

    CALYREX = {
      dex = 898, name = "Calyrex", types = { "PSYCHIC", "GRASS" },
      baseStats = { hp = 100, attack = 80, defense = 80, speed = 80, specialA = 80, specialD = 80 },
      catchRate = 3, baseExp = 250, growthRate = "SLOW", happiness = 100,
      evolutions = {},
      heightM = 1.1, weightKg = 7.7,
      dexEntry = { kind = "King Pokémon",
        text = "Calyrex is a merciful Pokémon, capable of providing healing and blessings. It reigned over the Galar region in times of yore." },
    },

    WYRDEER = {
      dex = 899, name = "Wyrdeer", types = { "NORMAL", "PSYCHIC" },
      baseStats = { hp = 103, attack = 105, defense = 72, speed = 65, specialA = 105, specialD = 75 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 70,
      evolutions = {},
      heightM = 1.8, weightKg = 95.1,
      dexEntry = { kind = "Big Horn Pokémon",
        text = "The black orbs shine with an uncanny light when the Pokémon is erecting invisible barriers. The fur shed from its beard retains heat well and is a highly useful material for winter clothing." },
    },

    KLEAVOR = {
      dex = 900, name = "Kleavor", types = { "BUG", "ROCK" },
      baseStats = { hp = 70, attack = 135, defense = 95, speed = 85, specialA = 45, specialD = 70 },
      catchRate = 45, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 70,
      evolutions = {},
      heightM = 1.8, weightKg = 89,
      dexEntry = { kind = "Axe Pokémon",
        text = "This Pokémon is a rough, crude, and violent sort. It swings around its large, heavy stone axes to finish off its prey." },
    },

    URSALUNA = {
      dex = 901, name = "Ursaluna", types = { "GROUND", "NORMAL" },
      baseStats = { hp = 130, attack = 140, defense = 105, speed = 50, specialA = 45, specialD = 80 },
      catchRate = 20, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 70,
      evolutions = {},
      heightM = 2.4, weightKg = 290,
      dexEntry = { kind = "Peat Pokémon",
        text = "I believe it was Hisui’s swampy terrain that gave Ursaluna its burly physique and newfound capacity to manipulate peat at will." },
    },

    BASCULEGION = {
      dex = 902, name = "Basculegion", types = { "WATER", "GHOST" },
      baseStats = { hp = 120, attack = 112, defense = 65, speed = 78, specialA = 80, specialD = 75 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 3, weightKg = 110,
      dexEntry = { kind = "Big Fish Pokémon",
        text = "It can jump with incredible power. Parts of its body are tinged red by the rage of its fallen friends." },
    },

    SNEASLER = {
      dex = 903, name = "Sneasler", types = { "FIGHTING", "POISON" },
      baseStats = { hp = 80, attack = 130, defense = 60, speed = 120, specialA = 40, specialD = 80 },
      catchRate = 20, baseExp = 102, growthRate = "MEDIUM_SLOW", happiness = 35,
      evolutions = {},
      heightM = 1.3, weightKg = 43,
      dexEntry = { kind = "Free Climb Pokémon",
        text = "Because of Sneasler’s virulent poison and daunting physical prowess, no other species could hope to best it on the frozen highlands. Preferring solitude, this species does not form packs." },
    },

    OVERQWIL = {
      dex = 904, name = "Overqwil", types = { "DARK", "POISON" },
      baseStats = { hp = 85, attack = 115, defense = 95, speed = 85, specialA = 65, specialD = 65 },
      catchRate = 45, baseExp = 179, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2.5, weightKg = 60.5,
      dexEntry = { kind = "Pin Cluster Pokémon",
        text = "It’s ferocious and has a short temper. The ends of its spikes are barbed, and they can’t be easily removed once they’ve punctured something." },
    },

    ENAMORUS = {
      dex = 905, name = "Enamorus", types = { "FAIRY", "FLYING" },
      baseStats = { hp = 74, attack = 115, defense = 70, speed = 106, specialA = 135, specialD = 80 },
      catchRate = 3, baseExp = 116, growthRate = "SLOW", happiness = 90,
      evolutions = {},
      heightM = 1.8, weightKg = 48,
      dexEntry = { kind = "Love-Hate Pokémon",
        text = "When it flies to this land from across the sea, the bitter winter comes to an end. According to legend, this Pokémon’s love gives rise to the budding of fresh life across Hisui." },
    },

    SPRIGATITO = {
      dex = 906, name = "Sprigatito", types = { "GRASS" },
      baseStats = { hp = 40, attack = 61, defense = 54, speed = 65, specialA = 45, specialD = 45 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "FLORAGATO", level = 16 },
      },
      heightM = 0.4, weightKg = 4.1,
      dexEntry = { kind = "Grass Cat Pokémon",
        text = "The sweet scent its body gives off mesmerizes those around it. The scent grows stronger when this Pokémon is in the sun." },
    },

    FLORAGATO = {
      dex = 907, name = "Floragato", types = { "GRASS" },
      baseStats = { hp = 61, attack = 80, defense = 63, speed = 83, specialA = 60, specialD = 63 },
      catchRate = 45, baseExp = 144, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MEOWSCARADA", level = 36 },
      },
      heightM = 0.9, weightKg = 12.2,
      dexEntry = { kind = "Grass Cat Pokémon",
        text = "The hardness of Floragato’s fur depends on the Pokémon’s mood. When Floragato is prepared to battle, its fur becomes pointed and needle sharp." },
    },

    MEOWSCARADA = {
      dex = 908, name = "Meowscarada", types = { "GRASS", "DARK" },
      baseStats = { hp = 76, attack = 110, defense = 70, speed = 123, specialA = 81, specialD = 70 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 31.2,
      dexEntry = { kind = "Magician Pokémon",
        text = "With skillful misdirection, it rigs foes with pollen-packed flower bombs. Meowscarada sets off the bombs before its foes realize what’s going on." },
    },

    FUECOCO = {
      dex = 909, name = "Fuecoco", types = { "FIRE" },
      baseStats = { hp = 67, attack = 45, defense = 59, speed = 36, specialA = 63, specialD = 40 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "CROCALOR", level = 16 },
      },
      heightM = 0.4, weightKg = 9.8,
      dexEntry = { kind = "Fire Croc Pokémon",
        text = "Its flame sac is small, so energy is always leaking out. This energy is released from the dent atop Fuecoco’s head and flickers to and fro." },
    },

    CROCALOR = {
      dex = 910, name = "Crocalor", types = { "FIRE" },
      baseStats = { hp = 81, attack = 55, defense = 78, speed = 49, specialA = 90, specialD = 58 },
      catchRate = 45, baseExp = 144, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SKELEDIRGE", level = 36 },
      },
      heightM = 1, weightKg = 30.7,
      dexEntry = { kind = "Fire Croc Pokémon",
        text = "The valve in Crocalor’s flame sac is closely connected to its vocal cords. This Pokémon utters a guttural cry as it spews flames every which way." },
    },

    SKELEDIRGE = {
      dex = 911, name = "Skeledirge", types = { "FIRE", "GHOST" },
      baseStats = { hp = 104, attack = 75, defense = 100, speed = 66, specialA = 110, specialD = 75 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 326.5,
      dexEntry = { kind = "Singer Pokémon",
        text = "Skeledirge’s gentle singing soothes the souls of all that hear it. It burns its enemies to a crisp with flames of over 5,400 degrees Fahrenheit." },
    },

    QUAXLY = {
      dex = 912, name = "Quaxly", types = { "WATER" },
      baseStats = { hp = 55, attack = 65, defense = 45, speed = 50, specialA = 50, specialD = 45 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "QUAXWELL", level = 16 },
      },
      heightM = 0.5, weightKg = 6.1,
      dexEntry = { kind = "Duckling Pokémon",
        text = "Its strong legs let it easily swim around in even fast-flowing rivers. It likes to keep things tidy and is prone to overthinking things." },
    },

    QUAXWELL = {
      dex = 913, name = "Quaxwell", types = { "WATER" },
      baseStats = { hp = 70, attack = 85, defense = 65, speed = 65, specialA = 65, specialD = 60 },
      catchRate = 45, baseExp = 144, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "QUAQUAVAL", level = 36 },
      },
      heightM = 1.2, weightKg = 21.5,
      dexEntry = { kind = "Practicing Pokémon",
        text = "The hardworking Quaxwell observes people and Pokémon from various regions and incorporates their movements into its own dance routines." },
    },

    QUAQUAVAL = {
      dex = 914, name = "Quaquaval", types = { "WATER", "FIGHTING" },
      baseStats = { hp = 85, attack = 120, defense = 80, speed = 85, specialA = 85, specialD = 75 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 61.9,
      dexEntry = { kind = "Dancer Pokémon",
        text = "Dancing in ways that evoke far-away places, this Pokémon mesmerizes all that see it. Flourishes of its decorative water feathers slice into its foes." },
    },

    LECHONK = {
      dex = 915, name = "Lechonk", types = { "NORMAL" },
      baseStats = { hp = 54, attack = 45, defense = 40, speed = 35, specialA = 35, specialD = 45 },
      catchRate = 255, baseExp = 51, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "OINKOLOGNE", level = 18 },
      },
      heightM = 0.5, weightKg = 10.2,
      dexEntry = { kind = "Hog Pokémon",
        text = "This Pokémon spurns all but the finest of foods. Its body gives off an herblike scent that bug Pokémon detest." },
    },

    OINKOLOGNE = {
      dex = 916, name = "Oinkologne", types = { "NORMAL" },
      baseStats = { hp = 110, attack = 100, defense = 75, speed = 65, specialA = 59, specialD = 80 },
      catchRate = 100, baseExp = 171, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 120,
      dexEntry = { kind = "Hog Pokémon",
        text = "It entrances female Pokémon with the sweet, alluring scent that wafts from all over its body." },
    },

    TAROUNTULA = {
      dex = 917, name = "Tarountula", types = { "BUG" },
      baseStats = { hp = 35, attack = 41, defense = 45, speed = 20, specialA = 29, specialD = 40 },
      catchRate = 255, baseExp = 42, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "SPIDOPS", level = 15 },
      },
      heightM = 0.3, weightKg = 4,
      dexEntry = { kind = "String Ball Pokémon",
        text = "The thread it secretes from its rear is as strong as wire. The secret behind the thread’s strength is the topic of ongoing research." },
    },

    SPIDOPS = {
      dex = 918, name = "Spidops", types = { "BUG" },
      baseStats = { hp = 60, attack = 79, defense = 92, speed = 35, specialA = 52, specialD = 86 },
      catchRate = 120, baseExp = 141, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 1, weightKg = 16.5,
      dexEntry = { kind = "Trap Pokémon",
        text = "Spidops covers its territory in tough, sticky threads to set up traps for intruders." },
    },

    NYMBLE = {
      dex = 919, name = "Nymble", types = { "BUG" },
      baseStats = { hp = 33, attack = 46, defense = 40, speed = 45, specialA = 21, specialD = 25 },
      catchRate = 190, baseExp = 42, growthRate = "MEDIUM_FAST", happiness = 20,
      evolutions = {
        { method = "LEVEL", species = "LOKIX", level = 24 },
      },
      heightM = 0.2, weightKg = 1,
      dexEntry = { kind = "Grasshopper Pokémon",
        text = "It’s highly skilled at a fighting style in which it uses its jumping capabilities to dodge incoming attacks while also dealing damage to opponents." },
    },

    LOKIX = {
      dex = 920, name = "Lokix", types = { "BUG", "DARK" },
      baseStats = { hp = 71, attack = 102, defense = 78, speed = 92, specialA = 52, specialD = 55 },
      catchRate = 30, baseExp = 158, growthRate = "MEDIUM_FAST", happiness = 0,
      evolutions = {},
      heightM = 1, weightKg = 17.5,
      dexEntry = { kind = "Grasshopper Pokémon",
        text = "It uses its normally folded third set of legs when in Showdown Mode. This places a huge burden on its body, so it can’t stay in this mode for long." },
    },

    PAWMI = {
      dex = 921, name = "Pawmi", types = { "ELECTRIC" },
      baseStats = { hp = 45, attack = 50, defense = 20, speed = 60, specialA = 40, specialD = 25 },
      catchRate = 190, baseExp = 48, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PAWMO", level = 18 },
      },
      heightM = 0.3, weightKg = 2.5,
      dexEntry = { kind = "Mouse Pokémon",
        text = "The pads of its paws are electricity-discharging organs. Pawmi fires electricity from its forepaws while standing unsteadily on its hind legs." },
    },

    PAWMO = {
      dex = 922, name = "Pawmo", types = { "ELECTRIC", "FIGHTING" },
      baseStats = { hp = 60, attack = 75, defense = 40, speed = 85, specialA = 50, specialD = 40 },
      catchRate = 80, baseExp = 123, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVELWALK", species = "PAWMOT" },
      },
      heightM = 0.4, weightKg = 6.5,
      dexEntry = { kind = "Mouse Pokémon",
        text = "Pawmo uses a unique fighting technique in which it uses its forepaws to strike foes and zap them with electricity from its paw pads simultaneously." },
    },

    PAWMOT = {
      dex = 923, name = "Pawmot", types = { "ELECTRIC", "FIGHTING" },
      baseStats = { hp = 70, attack = 115, defense = 70, speed = 105, specialA = 70, specialD = 60 },
      catchRate = 45, baseExp = 245, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 41,
      dexEntry = { kind = "Hands-On Pokémon",
        text = "Pawmot’s fluffy fur acts as a battery. It can store the same amount of electricity as an electric car." },
    },

    TANDEMAUS = {
      dex = 924, name = "Tandemaus", types = { "NORMAL" },
      baseStats = { hp = 50, attack = 50, defense = 45, speed = 75, specialA = 40, specialD = 45 },
      catchRate = 150, baseExp = 61, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "LEVELRANDFORM", species = "MAUSHOLD" },
      },
      heightM = 0.3, weightKg = 1.8,
      dexEntry = { kind = "Couple Pokémon",
        text = "The pair sticks together no matter what. They split any food they find exactly in half and then eat it together." },
    },

    MAUSHOLD = {
      dex = 925, name = "Maushold", types = { "NORMAL" },
      baseStats = { hp = 74, attack = 75, defense = 70, speed = 111, specialA = 65, specialD = 75 },
      catchRate = 75, baseExp = 165, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 2.8,
      dexEntry = { kind = "Family Pokémon",
        text = "The larger pair protects the little ones during battles. When facing strong opponents, the whole group will join the fight." },
    },

    FIDOUGH = {
      dex = 926, name = "Fidough", types = { "FAIRY" },
      baseStats = { hp = 37, attack = 55, defense = 70, speed = 65, specialA = 30, specialD = 55 },
      catchRate = 190, baseExp = 62, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DACHSBUN", level = 26 },
      },
      heightM = 0.3, weightKg = 10.9,
      dexEntry = { kind = "Puppy Pokémon",
        text = "The yeast in Fidough’s breath is useful for cooking, so this Pokémon has been protected by people since long ago." },
    },

    DACHSBUN = {
      dex = 927, name = "Dachsbun", types = { "FAIRY" },
      baseStats = { hp = 57, attack = 80, defense = 115, speed = 95, specialA = 50, specialD = 80 },
      catchRate = 90, baseExp = 167, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.5, weightKg = 14.9,
      dexEntry = { kind = "Dog Pokémon",
        text = "The surface of this Pokémon’s skin hardens when exposed to intense heat, and its body has an appetizing aroma." },
    },

    SMOLIV = {
      dex = 928, name = "Smoliv", types = { "GRASS", "NORMAL" },
      baseStats = { hp = 41, attack = 35, defense = 45, speed = 30, specialA = 58, specialD = 51 },
      catchRate = 255, baseExp = 52, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "DOLLIV", level = 25 },
      },
      heightM = 0.3, weightKg = 6.5,
      dexEntry = { kind = "Olive Pokémon",
        text = "This Pokémon converts nutrients into oil, which it stores in the fruit on its head. It can easily go a whole week without eating or drinking." },
    },

    DOLLIV = {
      dex = 929, name = "Dolliv", types = { "GRASS", "NORMAL" },
      baseStats = { hp = 52, attack = 53, defense = 60, speed = 33, specialA = 78, specialD = 78 },
      catchRate = 120, baseExp = 124, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ARBOLIVA", level = 35 },
      },
      heightM = 0.6, weightKg = 11.9,
      dexEntry = { kind = "Olive Pokémon",
        text = "It basks in the sun to its heart’s content until the fruits on its head ripen. After that, Dolliv departs from human settlements and goes on a journey." },
    },

    ARBOLIVA = {
      dex = 930, name = "Arboliva", types = { "GRASS", "NORMAL" },
      baseStats = { hp = 78, attack = 69, defense = 90, speed = 39, specialA = 125, specialD = 109 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 48.2,
      dexEntry = { kind = "Olive Pokémon",
        text = "This Pokémon drives back enemies by launching its rich, aromatic oil at them with enough force to smash a boulder." },
    },

    SQUAWKABILLY = {
      dex = 931, name = "Squawkabilly", types = { "NORMAL", "FLYING" },
      baseStats = { hp = 82, attack = 96, defense = 51, speed = 92, specialA = 45, specialD = 51 },
      catchRate = 190, baseExp = 146, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 0.6, weightKg = 2.4,
      dexEntry = { kind = "Parrot Pokémon",
        text = "Green-feathered flocks hold the most sway. When they’re out searching for food in the mornings and evenings, it gets very noisy." },
    },

    NACLI = {
      dex = 932, name = "Nacli", types = { "ROCK" },
      baseStats = { hp = 55, attack = 55, defense = 75, speed = 25, specialA = 35, specialD = 35 },
      catchRate = 255, baseExp = 56, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "NACLSTACK", level = 24 },
      },
      heightM = 0.4, weightKg = 16,
      dexEntry = { kind = "Rock Salt Pokémon",
        text = "The ground scrapes its body as it travels, causing it to leave salt behind. Salt is constantly being created and replenished inside Nacli’s body." },
    },

    NACLSTACK = {
      dex = 933, name = "Naclstack", types = { "ROCK" },
      baseStats = { hp = 60, attack = 60, defense = 100, speed = 35, specialA = 35, specialD = 65 },
      catchRate = 120, baseExp = 124, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GARGANACL", level = 38 },
      },
      heightM = 0.6, weightKg = 105,
      dexEntry = { kind = "Rock Salt Pokémon",
        text = "It compresses rock salt inside its body and shoots out hardened salt pellets with enough force to perforate an iron sheet." },
    },

    GARGANACL = {
      dex = 934, name = "Garganacl", types = { "ROCK" },
      baseStats = { hp = 100, attack = 100, defense = 130, speed = 35, specialA = 45, specialD = 90 },
      catchRate = 45, baseExp = 250, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.3, weightKg = 240,
      dexEntry = { kind = "Rock Salt Pokémon",
        text = "Many Pokémon gather around Garganacl, hoping to lick at its mineral-rich salt." },
    },

    CHARCADET = {
      dex = 935, name = "Charcadet", types = { "FIRE" },
      baseStats = { hp = 40, attack = 50, defense = 40, speed = 35, specialA = 50, specialD = 40 },
      catchRate = 90, baseExp = 51, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "ARMAROUGE", item = "AUSPICIOUSARMOR" },
        { method = "ITEM", species = "CERULEDGE", item = "MALICIOUSARMOR" },
      },
      heightM = 0.6, weightKg = 10.5,
      dexEntry = { kind = "Fire Child Pokémon",
        text = "Its firepower increases when it fights, reaching over 1,800 degrees Fahrenheit. It likes berries that are rich in fat." },
    },

    ARMAROUGE = {
      dex = 936, name = "Armarouge", types = { "FIRE", "PSYCHIC" },
      baseStats = { hp = 85, attack = 60, defense = 100, speed = 75, specialA = 125, specialD = 80 },
      catchRate = 25, baseExp = 255, growthRate = "SLOW", happiness = 20,
      evolutions = {},
      heightM = 1.5, weightKg = 85,
      dexEntry = { kind = "Fire Warrior Pokémon",
        text = "This Pokémon clads itself in armor that has been fortified by psychic and fire energy, and it shoots blazing fireballs." },
    },

    CERULEDGE = {
      dex = 937, name = "Ceruledge", types = { "FIRE", "GHOST" },
      baseStats = { hp = 75, attack = 125, defense = 80, speed = 85, specialA = 60, specialD = 100 },
      catchRate = 25, baseExp = 255, growthRate = "SLOW", happiness = 20,
      evolutions = {},
      heightM = 1.6, weightKg = 62,
      dexEntry = { kind = "Fire Blades Pokémon",
        text = "An old set of armor steeped in grudges caused this Pokémon’s evolution. Ceruledge cuts its enemies to pieces without mercy." },
    },

    TADBULB = {
      dex = 938, name = "Tadbulb", types = { "ELECTRIC" },
      baseStats = { hp = 61, attack = 31, defense = 41, speed = 45, specialA = 59, specialD = 35 },
      catchRate = 190, baseExp = 54, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "BELLIBOLT", item = "THUNDERSTONE" },
      },
      heightM = 0.3, weightKg = 0.4,
      dexEntry = { kind = "EleTadpole Pokémon",
        text = "It floats using the electricity stored in its body. When thunderclouds are around, Tadbulb will float higher off the ground." },
    },

    BELLIBOLT = {
      dex = 939, name = "Bellibolt", types = { "ELECTRIC" },
      baseStats = { hp = 109, attack = 64, defense = 91, speed = 45, specialA = 103, specialD = 83 },
      catchRate = 50, baseExp = 173, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 113,
      dexEntry = { kind = "EleFrog Pokémon",
        text = "What appear to be eyeballs are actually organs for discharging the electricity generated by Bellibolt’s belly-button dynamo." },
    },

    WATTREL = {
      dex = 940, name = "Wattrel", types = { "ELECTRIC", "FLYING" },
      baseStats = { hp = 40, attack = 40, defense = 35, speed = 70, specialA = 55, specialD = 40 },
      catchRate = 180, baseExp = 56, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "KILOWATTREL", level = 25 },
      },
      heightM = 0.4, weightKg = 3.6,
      dexEntry = { kind = "Storm Petrel Pokémon",
        text = "These Pokémon make their nests on coastal cliffs. The nests have a strange, crackling texture, and they’re a popular delicacy." },
    },

    KILOWATTREL = {
      dex = 941, name = "Kilowattrel", types = { "ELECTRIC", "FLYING" },
      baseStats = { hp = 70, attack = 70, defense = 60, speed = 125, specialA = 105, specialD = 60 },
      catchRate = 90, baseExp = 172, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.4, weightKg = 38.6,
      dexEntry = { kind = "Frigatebird Pokémon",
        text = "It uses its throat sac to store electricity generated by its wings. There’s hardly any oil in its feathers, so it is a poor swimmer." },
    },

    MASCHIFF = {
      dex = 942, name = "Maschiff", types = { "DARK" },
      baseStats = { hp = 60, attack = 78, defense = 60, speed = 51, specialA = 40, specialD = 51 },
      catchRate = 150, baseExp = 68, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "MABOSSTIFF", level = 30 },
      },
      heightM = 0.5, weightKg = 16,
      dexEntry = { kind = "Rascal Pokémon",
        text = "Its well-developed jaw and fangs are strong enough to crunch through boulders, and its thick fat makes for an excellent defense." },
    },

    MABOSSTIFF = {
      dex = 943, name = "Mabosstiff", types = { "DARK" },
      baseStats = { hp = 80, attack = 120, defense = 90, speed = 85, specialA = 60, specialD = 70 },
      catchRate = 75, baseExp = 177, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.1, weightKg = 61,
      dexEntry = { kind = "Boss Pokémon",
        text = "Mabosstiff loves playing with children. Though usually gentle, it takes on an intimidating look when protecting its family." },
    },

    SHROODLE = {
      dex = 944, name = "Shroodle", types = { "POISON", "NORMAL" },
      baseStats = { hp = 40, attack = 65, defense = 35, speed = 75, specialA = 40, specialD = 35 },
      catchRate = 190, baseExp = 58, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GRAFAIAI", level = 28 },
      },
      heightM = 0.2, weightKg = 0.7,
      dexEntry = { kind = "Toxic Mouse Pokémon",
        text = "To keep enemies away from its territory, it paints markings around its nest using a poisonous liquid that has an acrid odor." },
    },

    GRAFAIAI = {
      dex = 945, name = "Grafaiai", types = { "POISON", "NORMAL" },
      baseStats = { hp = 63, attack = 95, defense = 65, speed = 110, specialA = 80, specialD = 72 },
      catchRate = 90, baseExp = 170, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 27.2,
      dexEntry = { kind = "Toxic Monkey Pokémon",
        text = "Each Grafaiai paints its own individual pattern, and it will paint that same pattern over and over again throughout its life." },
    },

    BRAMBLIN = {
      dex = 946, name = "Bramblin", types = { "GRASS", "GHOST" },
      baseStats = { hp = 40, attack = 65, defense = 30, speed = 60, specialA = 45, specialD = 35 },
      catchRate = 190, baseExp = 55, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVELWALK", species = "BRAMBLEGHAST" },
      },
      heightM = 0.6, weightKg = 0.6,
      dexEntry = { kind = "Tumbleweed Pokémon",
        text = "Not even Bramblin knows where it is headed as it tumbles across the wilderness, blown by the wind. It loathes getting wet." },
    },

    BRAMBLEGHAST = {
      dex = 947, name = "Brambleghast", types = { "GRASS", "GHOST" },
      baseStats = { hp = 55, attack = 115, defense = 70, speed = 90, specialA = 80, specialD = 70 },
      catchRate = 45, baseExp = 168, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 6,
      dexEntry = { kind = "Tumbleweed Pokémon",
        text = "Brambleghast wanders around arid regions. On rare occasions, mass outbreaks of these Pokémon will bury an entire town." },
    },

    TOEDSCOOL = {
      dex = 948, name = "Toedscool", types = { "GROUND", "GRASS" },
      baseStats = { hp = 40, attack = 40, defense = 35, speed = 70, specialA = 50, specialD = 100 },
      catchRate = 190, baseExp = 67, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TOEDSCRUEL", level = 30 },
      },
      heightM = 0.9, weightKg = 33,
      dexEntry = { kind = "Woodear Pokémon",
        text = "Though it looks like Tentacool, Toedscool is a completely different species. Its legs may be thin, but it can run at a speed of 30 mph." },
    },

    TOEDSCRUEL = {
      dex = 949, name = "Toedscruel", types = { "GROUND", "GRASS" },
      baseStats = { hp = 80, attack = 70, defense = 65, speed = 100, specialA = 80, specialD = 120 },
      catchRate = 90, baseExp = 180, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 58,
      dexEntry = { kind = "Woodear Pokémon",
        text = "It coils its 10 tentacles around prey and sucks out their nutrients, causing the prey pain. The folds along the rim of its head are a popular delicacy." },
    },

    KLAWF = {
      dex = 950, name = "Klawf", types = { "ROCK" },
      baseStats = { hp = 70, attack = 100, defense = 115, speed = 75, specialA = 35, specialD = 55 },
      catchRate = 120, baseExp = 158, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 79,
      dexEntry = { kind = "Ambush Pokémon",
        text = "This Pokémon lives on sheer cliffs. It sidesteps opponents’ attacks, then lunges for their weak spots with its claws." },
    },

    CAPSAKID = {
      dex = 951, name = "Capsakid", types = { "GRASS" },
      baseStats = { hp = 50, attack = 62, defense = 40, speed = 50, specialA = 62, specialD = 40 },
      catchRate = 190, baseExp = 61, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "SCOVILLAIN", item = "FIRESTONE" },
      },
      heightM = 0.3, weightKg = 3,
      dexEntry = { kind = "Spicy Pepper Pokémon",
        text = "Traditional Paldean dishes can be extremely spicy because they include the shed front teeth of Capsakid among their ingredients." },
    },

    SCOVILLAIN = {
      dex = 952, name = "Scovillain", types = { "GRASS", "FIRE" },
      baseStats = { hp = 65, attack = 108, defense = 65, speed = 75, specialA = 108, specialD = 65 },
      catchRate = 75, baseExp = 170, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.9, weightKg = 15,
      dexEntry = { kind = "Spicy Pepper Pokémon",
        text = "The green head has turned vicious due to the spicy chemicals stimulating its brain. Once it goes on a rampage, there is no stopping it." },
    },

    RELLOR = {
      dex = 953, name = "Rellor", types = { "BUG" },
      baseStats = { hp = 41, attack = 50, defense = 60, speed = 30, specialA = 31, specialD = 58 },
      catchRate = 190, baseExp = 54, growthRate = "FAST", happiness = 50,
      evolutions = {
        { method = "LEVELWALK", species = "RABSCA" },
      },
      heightM = 0.2, weightKg = 1,
      dexEntry = { kind = "Rolling Pokémon",
        text = "It rolls its mud ball around while the energy it needs for evolution matures. Eventually the time comes for it to evolve." },
    },

    RABSCA = {
      dex = 954, name = "Rabsca", types = { "BUG", "PSYCHIC" },
      baseStats = { hp = 75, attack = 50, defense = 85, speed = 45, specialA = 115, specialD = 100 },
      catchRate = 45, baseExp = 165, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 3.5,
      dexEntry = { kind = "Rolling Pokémon",
        text = "An infant sleeps inside the ball. Rabsca rolls the ball soothingly with its legs to ensure the infant sleeps comfortably." },
    },

    FLITTLE = {
      dex = 955, name = "Flittle", types = { "PSYCHIC" },
      baseStats = { hp = 30, attack = 35, defense = 30, speed = 75, specialA = 55, specialD = 30 },
      catchRate = 120, baseExp = 51, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ESPATHRA", level = 35 },
      },
      heightM = 0.2, weightKg = 1.5,
      dexEntry = { kind = "Frill Pokémon",
        text = "It spends its time running around wastelands. If anyone steals its beloved berries, it will chase them down and exact its revenge." },
    },

    ESPATHRA = {
      dex = 956, name = "Espathra", types = { "PSYCHIC" },
      baseStats = { hp = 95, attack = 60, defense = 60, speed = 105, specialA = 101, specialD = 60 },
      catchRate = 60, baseExp = 168, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.9, weightKg = 90,
      dexEntry = { kind = "Ostrich Pokémon",
        text = "It emits psychic power from the gaps between its multicolored frills and sprints at speeds greater than 120 mph." },
    },

    TINKATINK = {
      dex = 957, name = "Tinkatink", types = { "FAIRY", "STEEL" },
      baseStats = { hp = 50, attack = 45, defense = 45, speed = 58, specialA = 35, specialD = 64 },
      catchRate = 190, baseExp = 59, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TINKATUFF", level = 24 },
      },
      heightM = 0.4, weightKg = 8.9,
      dexEntry = { kind = "Metalsmith Pokémon",
        text = "This Pokémon pounds iron scraps together to make a hammer. It will remake the hammer again and again until it’s satisfied with the result." },
    },

    TINKATUFF = {
      dex = 958, name = "Tinkatuff", types = { "FAIRY", "STEEL" },
      baseStats = { hp = 65, attack = 55, defense = 55, speed = 78, specialA = 45, specialD = 82 },
      catchRate = 90, baseExp = 133, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "TINKATON", level = 38 },
      },
      heightM = 0.7, weightKg = 59.1,
      dexEntry = { kind = "Hammer Pokémon",
        text = "These Pokémon make their homes in piles of scrap metal. They test the strength of each other’s hammers by smashing them together." },
    },

    TINKATON = {
      dex = 959, name = "Tinkaton", types = { "FAIRY", "STEEL" },
      baseStats = { hp = 85, attack = 75, defense = 77, speed = 94, specialA = 70, specialD = 105 },
      catchRate = 45, baseExp = 253, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.7, weightKg = 112.8,
      dexEntry = { kind = "Hammer Pokémon",
        text = "The hammer tops 220 pounds, yet it gets swung around easily by Tinkaton as it steals whatever it pleases and carries its plunder back home." },
    },

    WIGLETT = {
      dex = 960, name = "Wiglett", types = { "WATER" },
      baseStats = { hp = 10, attack = 55, defense = 25, speed = 95, specialA = 35, specialD = 25 },
      catchRate = 255, baseExp = 49, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "WUGTRIO", level = 26 },
      },
      heightM = 1.2, weightKg = 1.8,
      dexEntry = { kind = "Garden Eel Pokémon",
        text = "Though it looks like Diglett, Wiglett is an entirely different species. The resemblance seems to be a coincidental result of environmental adaptation." },
    },

    WUGTRIO = {
      dex = 961, name = "Wugtrio", types = { "WATER" },
      baseStats = { hp = 35, attack = 100, defense = 50, speed = 120, specialA = 50, specialD = 70 },
      catchRate = 50, baseExp = 149, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 5.4,
      dexEntry = { kind = "Garden Eel Pokémon",
        text = "A variety of fish Pokémon, Wugtrio was once considered to be a regional form of Dugtrio." },
    },

    BOMBIRDIER = {
      dex = 962, name = "Bombirdier", types = { "FLYING", "DARK" },
      baseStats = { hp = 70, attack = 103, defense = 85, speed = 82, specialA = 60, specialD = 85 },
      catchRate = 25, baseExp = 243, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 42.9,
      dexEntry = { kind = "Item Drop Pokémon",
        text = "Bombirdier uses the apron on its chest to bundle up food, which it carries back to its nest. It enjoys dropping things that make loud noises." },
    },

    FINIZEN = {
      dex = 963, name = "Finizen", types = { "WATER" },
      baseStats = { hp = 70, attack = 45, defense = 40, speed = 75, specialA = 45, specialD = 40 },
      catchRate = 200, baseExp = 63, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "PALAFIN", level = 38 },
      },
      heightM = 1.3, weightKg = 60.2,
      dexEntry = { kind = "Dolphin Pokémon",
        text = "Its water ring is made from seawater mixed with a sticky fluid that Finizen secretes from its blowhole." },
    },

    PALAFIN = {
      dex = 964, name = "Palafin", types = { "WATER" },
      baseStats = { hp = 100, attack = 70, defense = 72, speed = 100, specialA = 53, specialD = 62 },
      catchRate = 45, baseExp = 160, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.3, weightKg = 60.2,
      dexEntry = { kind = "Dolphin Pokémon",
        text = "Its physical capabilities are no different than a Finizen’s, but when its allies are in danger, it transforms and powers itself up." },
    },

    VAROOM = {
      dex = 965, name = "Varoom", types = { "STEEL", "POISON" },
      baseStats = { hp = 45, attack = 70, defense = 63, speed = 47, specialA = 30, specialD = 45 },
      catchRate = 190, baseExp = 60, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "REVAVROOM", level = 40 },
      },
      heightM = 1, weightKg = 35,
      dexEntry = { kind = "Single-Cyl Pokémon",
        text = "The steel section is Varoom’s actual body. This Pokémon clings to rocks and converts the minerals within into energy to fuel its activities." },
    },

    REVAVROOM = {
      dex = 966, name = "Revavroom", types = { "STEEL", "POISON" },
      baseStats = { hp = 80, attack = 119, defense = 90, speed = 90, specialA = 54, specialD = 67 },
      catchRate = 75, baseExp = 175, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 120,
      dexEntry = { kind = "Multi-Cyl Pokémon",
        text = "Revavroom viciously threatens others with the sound of its exhaust. It sticks its tongue out from its cylindrical mouth and sprays toxic fluids." },
    },

    CYCLIZAR = {
      dex = 967, name = "Cyclizar", types = { "DRAGON", "NORMAL" },
      baseStats = { hp = 70, attack = 95, defense = 65, speed = 121, specialA = 85, specialD = 65 },
      catchRate = 190, baseExp = 175, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 63,
      dexEntry = { kind = "Mount Pokémon",
        text = "It can sprint at over 70 mph while carrying a human. The rider’s body heat warms Cyclizar’s back and lifts the Pokémon’s spirit." },
    },

    ORTHWORM = {
      dex = 968, name = "Orthworm", types = { "STEEL" },
      baseStats = { hp = 70, attack = 85, defense = 145, speed = 65, specialA = 60, specialD = 55 },
      catchRate = 25, baseExp = 240, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.5, weightKg = 310,
      dexEntry = { kind = "Earthworm Pokémon",
        text = "This Pokémon lives in arid deserts. It maintains its metal body by consuming iron from the soil." },
    },

    GLIMMET = {
      dex = 969, name = "Glimmet", types = { "ROCK", "POISON" },
      baseStats = { hp = 48, attack = 35, defense = 42, speed = 60, specialA = 105, specialD = 60 },
      catchRate = 70, baseExp = 70, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "GLIMMORA", level = 35 },
      },
      heightM = 0.7, weightKg = 8,
      dexEntry = { kind = "Ore Pokémon",
        text = "Glimmet’s toxic mineral crystals look just like flower petals. This Pokémon scatters poisonous powder like pollen to protect itself." },
    },

    GLIMMORA = {
      dex = 970, name = "Glimmora", types = { "ROCK", "POISON" },
      baseStats = { hp = 83, attack = 55, defense = 90, speed = 86, specialA = 130, specialD = 81 },
      catchRate = 25, baseExp = 184, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.5, weightKg = 45,
      dexEntry = { kind = "Ore Pokémon",
        text = "Glimmora’s petals are made of crystallized poison energy. It has recently become evident that these petals resemble Tera Jewels." },
    },

    GREAVARD = {
      dex = 971, name = "Greavard", types = { "GHOST" },
      baseStats = { hp = 50, attack = 61, defense = 60, speed = 34, specialA = 30, specialD = 55 },
      catchRate = 120, baseExp = 58, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "LEVELNIGHT", species = "HOUNDSTONE" },
      },
      heightM = 0.6, weightKg = 35,
      dexEntry = { kind = "Ghost Dog Pokémon",
        text = "This friendly Pokémon doesn’t like being alone. Pay it even the slightest bit of attention, and it will follow you forever." },
    },

    HOUNDSTONE = {
      dex = 972, name = "Houndstone", types = { "GHOST" },
      baseStats = { hp = 72, attack = 101, defense = 100, speed = 68, specialA = 50, specialD = 97 },
      catchRate = 60, baseExp = 171, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 15,
      dexEntry = { kind = "Ghost Dog Pokémon",
        text = "A lovingly mourned Pokémon was reborn as Houndstone. It doesn’t like anyone touching the protuberance atop its head." },
    },

    FLAMIGO = {
      dex = 973, name = "Flamigo", types = { "FLYING", "FIGHTING" },
      baseStats = { hp = 82, attack = 115, defense = 74, speed = 90, specialA = 75, specialD = 64 },
      catchRate = 100, baseExp = 175, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.6, weightKg = 37,
      dexEntry = { kind = "Synchronize Pokémon",
        text = "Thanks to a behavior of theirs known as “synchronizing,” an entire flock of these Pokémon can attack simultaneously in perfect harmony." },
    },

    CETODDLE = {
      dex = 974, name = "Cetoddle", types = { "ICE" },
      baseStats = { hp = 108, attack = 68, defense = 45, speed = 43, specialA = 30, specialD = 40 },
      catchRate = 150, baseExp = 67, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "CETITAN", item = "ICESTONE" },
      },
      heightM = 1.2, weightKg = 45,
      dexEntry = { kind = "Terra Whale Pokémon",
        text = "It lives in frigid regions in pods of five or so individuals. It loves the minerals found in snow and ice." },
    },

    CETITAN = {
      dex = 975, name = "Cetitan", types = { "ICE" },
      baseStats = { hp = 170, attack = 113, defense = 65, speed = 73, specialA = 45, specialD = 55 },
      catchRate = 50, baseExp = 182, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 4.5, weightKg = 700,
      dexEntry = { kind = "Terra Whale Pokémon",
        text = "Ice energy builds up in the horn on its upper jaw, causing the horn to reach cryogenic temperatures that freeze its surroundings." },
    },

    VELUZA = {
      dex = 976, name = "Veluza", types = { "WATER", "PSYCHIC" },
      baseStats = { hp = 90, attack = 102, defense = 73, speed = 70, specialA = 78, specialD = 65 },
      catchRate = 100, baseExp = 167, growthRate = "FAST", happiness = 50,
      evolutions = {},
      heightM = 2.5, weightKg = 90,
      dexEntry = { kind = "Jettison Pokémon",
        text = "Veluza has excellent regenerative capabilities. It sheds spare flesh from its body to boost its agility, then charges at its prey." },
    },

    DONDOZO = {
      dex = 977, name = "Dondozo", types = { "WATER" },
      baseStats = { hp = 150, attack = 100, defense = 115, speed = 35, specialA = 65, specialD = 65 },
      catchRate = 25, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 12, weightKg = 220,
      dexEntry = { kind = "Big Catfish Pokémon",
        text = "It treats Tatsugiri like its boss and follows it loyally. Though powerful, Dondozo is apparently not very smart." },
    },

    TATSUGIRI = {
      dex = 978, name = "Tatsugiri", types = { "DRAGON", "WATER" },
      baseStats = { hp = 68, attack = 50, defense = 60, speed = 82, specialA = 120, specialD = 95 },
      catchRate = 100, baseExp = 166, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.3, weightKg = 8,
      dexEntry = { kind = "Mimicry Pokémon",
        text = "Tatsugiri is an extremely cunning Pokémon. It feigns weakness to lure in prey, then orders its partner to attack." },
    },

    ANNIHILAPE = {
      dex = 979, name = "Annihilape", types = { "FIGHTING", "GHOST" },
      baseStats = { hp = 110, attack = 115, defense = 80, speed = 90, specialA = 50, specialD = 90 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 56,
      dexEntry = { kind = "Rage Monkey Pokémon",
        text = "It imbues its fists with the power of the rage that it kept hidden in its heart. Opponents struck by these imbued fists will be shattered to their core." },
    },

    CLODSIRE = {
      dex = 980, name = "Clodsire", types = { "POISON", "GROUND" },
      baseStats = { hp = 130, attack = 75, defense = 60, speed = 20, specialA = 45, specialD = 100 },
      catchRate = 90, baseExp = 151, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 223,
      dexEntry = { kind = "Spiny Fish Pokémon",
        text = "It lives at the bottom of ponds and swamps. It will carry Wooper on its back and ferry them across water from one shore to the other." },
    },

    FARIGIRAF = {
      dex = 981, name = "Farigiraf", types = { "NORMAL", "PSYCHIC" },
      baseStats = { hp = 120, attack = 90, defense = 70, speed = 60, specialA = 110, specialD = 70 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 3.2, weightKg = 160,
      dexEntry = { kind = "Long Neck Pokémon",
        text = "The hardened head from the tail protects the head of the main body as Farigiraf whips its long neck around to headbutt enemies." },
    },

    DUDUNSPARCE = {
      dex = 982, name = "Dudunsparce", types = { "NORMAL" },
      baseStats = { hp = 125, attack = 100, defense = 80, speed = 55, specialA = 85, specialD = 75 },
      catchRate = 45, baseExp = 182, growthRate = "MEDIUM_SLOW", happiness = 50,
      evolutions = {},
      heightM = 3.6, weightKg = 39.2,
      dexEntry = { kind = "Land Snake Pokémon",
        text = "It drives enemies out of its nest by sucking in enough air to fill its long, narrow lungs, then releasing the air in an intense blast." },
    },

    KINGAMBIT = {
      dex = 983, name = "Kingambit", types = { "DARK", "STEEL" },
      baseStats = { hp = 100, attack = 135, defense = 120, speed = 50, specialA = 60, specialD = 85 },
      catchRate = 25, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 120,
      dexEntry = { kind = "Big Blade Pokémon",
        text = "Though it commands a massive army in battle, it’s not skilled at devising complex strategies. It just uses brute strength to keep pushing." },
    },

    GREATTUSK = {
      dex = 984, name = "Great Tusk", types = { "GROUND", "FIGHTING" },
      baseStats = { hp = 115, attack = 131, defense = 131, speed = 87, specialA = 53, specialD = 53 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2.2, weightKg = 320,
      dexEntry = { kind = "Paradox Pokémon",
        text = "This creature resembles a mysterious Pokémon that, according to a paranormal magazine, has lived since ancient times." },
    },

    SCREAMTAIL = {
      dex = 985, name = "Screamtail", types = { "FAIRY", "PSYCHIC" },
      baseStats = { hp = 115, attack = 65, defense = 99, speed = 111, specialA = 65, specialD = 115 },
      catchRate = 50, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.2, weightKg = 8,
      dexEntry = { kind = "Paradox Pokémon",
        text = "It resembles a mysterious Pokémon described in a paranormal magazine as a Jigglypuff from one billion years ago." },
    },

    BRUTEBONNET = {
      dex = 986, name = "Brutebonnet", types = { "GRASS", "DARK" },
      baseStats = { hp = 111, attack = 127, defense = 99, speed = 55, specialA = 79, specialD = 99 },
      catchRate = 50, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.2, weightKg = 21,
      dexEntry = { kind = "Paradox Pokémon",
        text = "It bears a slight resemblance to a Pokémon described in a dubious magazine as a cross between a dinosaur and a mushroom." },
    },

    FLUTTERMANE = {
      dex = 987, name = "Fluttermane", types = { "GHOST", "FAIRY" },
      baseStats = { hp = 55, attack = 55, defense = 55, speed = 135, specialA = 135, specialD = 135 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.4, weightKg = 4,
      dexEntry = { kind = "Paradox Pokémon",
        text = "It has similar features to a ghostly pterosaur that was covered in a paranormal magazine, but the two have little else in common." },
    },

    SLITHERWING = {
      dex = 988, name = "Slitherwing", types = { "BUG", "FIGHTING" },
      baseStats = { hp = 85, attack = 135, defense = 79, speed = 81, specialA = 85, specialD = 105 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.2, weightKg = 92,
      dexEntry = { kind = "Paradox Pokémon",
        text = "This Pokémon somewhat resembles an ancient form of Volcarona that was introduced in a dubious magazine." },
    },

    SANDYSHOCKS = {
      dex = 989, name = "Sandyshocks", types = { "ELECTRIC", "GROUND" },
      baseStats = { hp = 85, attack = 81, defense = 97, speed = 101, specialA = 121, specialD = 85 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2.3, weightKg = 60,
      dexEntry = { kind = "Paradox Pokémon",
        text = "It slightly resembles a Magneton that lived for 10,000 years and was featured in an article in a paranormal magazine." },
    },

    IRONTREADS = {
      dex = 990, name = "Irontreads", types = { "GROUND", "STEEL" },
      baseStats = { hp = 90, attack = 112, defense = 120, speed = 106, specialA = 72, specialD = 70 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 0.9, weightKg = 240,
      dexEntry = { kind = "Paradox Pokémon",
        text = "Sightings of this Pokémon have occurred in recent years. It resembles a mysterious object described in an old expedition journal." },
    },

    IRONBUNDLE = {
      dex = 991, name = "Ironbundle", types = { "ICE", "WATER" },
      baseStats = { hp = 56, attack = 80, defense = 114, speed = 136, specialA = 124, specialD = 60 },
      catchRate = 50, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 0.6, weightKg = 11,
      dexEntry = { kind = "Paradox Pokémon",
        text = "It resembles a mysterious object mentioned in an old book. There are only two reported sightings of this Pokémon." },
    },

    IRONHANDS = {
      dex = 992, name = "Ironhands", types = { "FIGHTING", "ELECTRIC" },
      baseStats = { hp = 154, attack = 140, defense = 108, speed = 50, specialA = 50, specialD = 68 },
      catchRate = 50, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.8, weightKg = 380.7,
      dexEntry = { kind = "Paradox Pokémon",
        text = "This Pokémon shares many similarities with Iron Hands, an object mentioned in a certain expedition journal." },
    },

    IRONJUGULIS = {
      dex = 993, name = "Ironjugulis", types = { "DARK", "FLYING" },
      baseStats = { hp = 94, attack = 80, defense = 86, speed = 108, specialA = 122, specialD = 80 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.3, weightKg = 111,
      dexEntry = { kind = "Paradox Pokémon",
        text = "It’s possible that Iron Jugulis, an object described in an old book, may actually be this Pokémon." },
    },

    IRONMOTH = {
      dex = 994, name = "Ferropolilla", types = { "FIRE", "POISON" },
      baseStats = { hp = 80, attack = 70, defense = 60, speed = 110, specialA = 140, specialD = 110 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.2, weightKg = 36,
      dexEntry = { kind = "Paradox Pokémon",
        text = "No records exist of this species being caught. Data is lacking, but the Pokémon’s traits match up with an object described in an old book." },
    },

    IRONTHORNS = {
      dex = 995, name = "Ferropúas", types = { "ROCK", "ELECTRIC" },
      baseStats = { hp = 100, attack = 134, defense = 110, speed = 72, specialA = 70, specialD = 84 },
      catchRate = 30, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.6, weightKg = 303,
      dexEntry = { kind = "Paradox Pokémon",
        text = "Some of its notable features match those of an object named within a certain expedition journal as Iron Thorns." },
    },

    FRIGIBAX = {
      dex = 996, name = "Frigibax", types = { "DRAGON", "ICE" },
      baseStats = { hp = 65, attack = 75, defense = 45, speed = 55, specialA = 35, specialD = 45 },
      catchRate = 45, baseExp = 64, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "ARCTIBAX", level = 35 },
      },
      heightM = 0.5, weightKg = 17,
      dexEntry = { kind = "Ice Fin Pokémon",
        text = "This Pokémon lives in forests and craggy areas. Using the power of its dorsal fin, it cools the inside of its nest like a refrigerator." },
    },

    ARCTIBAX = {
      dex = 997, name = "Arctibax", types = { "DRAGON", "ICE" },
      baseStats = { hp = 90, attack = 95, defense = 66, speed = 62, specialA = 45, specialD = 65 },
      catchRate = 25, baseExp = 182, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVEL", species = "BAXCALIBUR", level = 54 },
      },
      heightM = 0.8, weightKg = 30,
      dexEntry = { kind = "Ice Fin Pokémon",
        text = "It attacks with the blade of its frozen dorsal fin by doing a front flip in the air. Arctibax’s strong back and legs allow it to pull off this technique." },
    },

    BAXCALIBUR = {
      dex = 998, name = "Baxcalibur", types = { "DRAGON", "ICE" },
      baseStats = { hp = 115, attack = 145, defense = 92, speed = 87, specialA = 75, specialD = 86 },
      catchRate = 10, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 2.1, weightKg = 210,
      dexEntry = { kind = "Ice Dragon Pokémon",
        text = "It launches itself into battle by flipping upside down and spewing frigid air from its mouth. It finishes opponents off with its dorsal blade." },
    },

    GIMMIGHOUL = {
      dex = 999, name = "Gimmighoul", types = { "GHOST" },
      baseStats = { hp = 45, attack = 30, defense = 70, speed = 10, specialA = 75, specialD = 70 },
      catchRate = 45, baseExp = 60, growthRate = "SLOW", happiness = 50,
      evolutions = {
        { method = "LEVELCOINS", species = "GHOLDENGO" },
      },
      heightM = 0.3, weightKg = 5,
      dexEntry = { kind = "Coin Chest Pokémon",
        text = "It lives inside an old treasure chest. Sometimes it gets left in shop corners since no one realizes it’s actually a Pokémon." },
    },

    GHOLDENGO = {
      dex = 1000, name = "Gholdengo", types = { "STEEL", "GHOST" },
      baseStats = { hp = 87, attack = 60, defense = 95, speed = 84, specialA = 133, specialD = 91 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 30,
      dexEntry = { kind = "Coin Entity Pokémon",
        text = "It has a sturdy body made up of stacked coins. Gholdengo overwhelms its enemies by firing coin after coin at them in quick succession." },
    },

    WOCHIEN = {
      dex = 1001, name = "Wo-Chien", types = { "DARK", "GRASS" },
      baseStats = { hp = 85, attack = 85, defense = 100, speed = 70, specialA = 95, specialD = 135 },
      catchRate = 6, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.5, weightKg = 74.2,
      dexEntry = { kind = "Ruinous Pokémon",
        text = "It drains the life-force from vegetation, causing nearby forests to instantly wither and fields to turn barren." },
    },

    CHIENPAO = {
      dex = 1002, name = "Chien-Pao", types = { "DARK", "ICE" },
      baseStats = { hp = 80, attack = 120, defense = 80, speed = 135, specialA = 90, specialD = 65 },
      catchRate = 6, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.9, weightKg = 152.2,
      dexEntry = { kind = "Ruinous Pokémon",
        text = "The hatred of those who perished by the sword long ago has clad itself in snow and become a Pokémon." },
    },

    TINGLU = {
      dex = 1003, name = "Ting-Lu", types = { "DARK", "GROUND" },
      baseStats = { hp = 155, attack = 110, defense = 125, speed = 45, specialA = 55, specialD = 80 },
      catchRate = 6, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2.7, weightKg = 699.7,
      dexEntry = { kind = "Ruinous Pokémon",
        text = "It slowly brings its exceedingly heavy head down upon the ground, splitting the earth open with huge fissures that run over 160 feet deep." },
    },

    CHIYU = {
      dex = 1004, name = "Chi-Yu", types = { "DARK", "FIRE" },
      baseStats = { hp = 55, attack = 80, defense = 80, speed = 100, specialA = 135, specialD = 120 },
      catchRate = 6, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 0.4, weightKg = 4.9,
      dexEntry = { kind = "Ruinous Pokémon",
        text = "The envy accumulated within curved beads that sparked multiple conflicts has clad itself in fire and become a Pokémon." },
    },

    ROARINGMOON = {
      dex = 1005, name = "Bramaluna", types = { "DRAGON", "DARK" },
      baseStats = { hp = 105, attack = 139, defense = 71, speed = 119, specialA = 55, specialD = 101 },
      catchRate = 10, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2, weightKg = 380,
      dexEntry = { kind = "Paradox Pokémon",
        text = "According to an article in a dubious magazine, this Pokémon has some connection to a phenomenon that occurs in a certain region." },
    },

    IRONVALIANT = {
      dex = 1006, name = "Ferropaladín", types = { "FAIRY", "FIGHTING" },
      baseStats = { hp = 74, attack = 130, defense = 90, speed = 116, specialA = 120, specialD = 60 },
      catchRate = 10, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.4, weightKg = 35,
      dexEntry = { kind = "Paradox Pokémon",
        text = "It’s possible that this is the object listed as Iron Valiant in a certain expedition journal." },
    },

    KORAIDON = {
      dex = 1007, name = "Koraidon", types = { "FIGHTING", "DRAGON" },
      baseStats = { hp = 100, attack = 135, defense = 115, speed = 135, specialA = 85, specialD = 100 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 2.5, weightKg = 303,
      dexEntry = { kind = "Paradox Pokémon",
        text = "This Pokémon resembles Cyclizar, but it is far burlier and more ferocious. Nothing is known about its ecology or other features." },
    },

    MIRAIDON = {
      dex = 1008, name = "Miraidon", types = { "ELECTRIC", "DRAGON" },
      baseStats = { hp = 100, attack = 85, defense = 100, speed = 135, specialA = 135, specialD = 115 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.5, weightKg = 240,
      dexEntry = { kind = "Paradox Pokémon",
        text = "This seems to be the Iron Serpent mentioned in an old book. The Iron Serpent is said to have turned the land to ash with its lightning." },
    },

    WALKINGWAKE = {
      dex = 1009, name = "Ondulagua", types = { "WATER", "DRAGON" },
      baseStats = { hp = 99, attack = 83, defense = 91, speed = 109, specialA = 125, specialD = 83 },
      catchRate = 5, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.5, weightKg = 280,
      dexEntry = { kind = "Paradox Pokémon",
        text = "It resembles an illustration published in a paranormal magazine, said to be a depiction of a super-ancient Suicune." },
    },

    IRONLEAVES = {
      dex = 1010, name = "Ferroverdor", types = { "GRASS", "PSYCHIC" },
      baseStats = { hp = 90, attack = 130, defense = 88, speed = 104, specialA = 70, specialD = 108 },
      catchRate = 5, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.5, weightKg = 125,
      dexEntry = { kind = "Paradox Pokémon",
        text = "According to the few eyewitness accounts that exist, it used its shining blades to julienne large trees and boulders." },
    },

    DIPPLIN = {
      dex = 1011, name = "Dipplin", types = { "GRASS", "DRAGON" },
      baseStats = { hp = 80, attack = 80, defense = 110, speed = 40, specialA = 95, specialD = 90 },
      catchRate = 45, baseExp = 170, growthRate = "ERRATIC", happiness = 50,
      evolutions = {
        { method = "HAS_MOVE", species = "HYDRAPPLE", move = "DRAGONCHEER" },
      },
      heightM = 0.4, weightKg = 4.4,
      dexEntry = { kind = "Candy Apple Pokémon",
        text = "The head sticking out belongs to the fore-wyrm, while the tail belongs to the core-wyrm. The two share one apple and help each other out." },
    },

    POLTCHAGEIST = {
      dex = 1012, name = "Poltchageist", types = { "GRASS", "GHOST" },
      baseStats = { hp = 40, attack = 45, defense = 45, speed = 50, specialA = 74, specialD = 54 },
      catchRate = 120, baseExp = 62, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {
        { method = "ITEM", species = "SINISTCHA", item = "UNREMARKABLETEACUP" },
      },
      heightM = 0.1, weightKg = 1.1,
      dexEntry = { kind = "Matcha Pokémon",
        text = "Poltchageist looks like a regional form of Sinistea, but it was recently discovered that the two Pokémon are entirely unrelated." },
    },

    SINISTCHA = {
      dex = 1013, name = "Sinistcha", types = { "GRASS", "GHOST" },
      baseStats = { hp = 71, attack = 60, defense = 106, speed = 70, specialA = 121, specialD = 80 },
      catchRate = 60, baseExp = 178, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 0.2, weightKg = 4.9,
      dexEntry = { kind = "Matcha Pokémon",
        text = "It prefers cool, dark places, such as the back of a shelf or the space beneath a home’s floorboards. It wanders in search of prey after sunset." },
    },

    OKIDOGI = {
      dex = 1014, name = "Okidogi", types = { "POISON", "FIGHTING" },
      baseStats = { hp = 88, attack = 128, defense = 115, speed = 80, specialA = 58, specialD = 86 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.8, weightKg = 92,
      dexEntry = { kind = "Retainer Pokémon",
        text = "Okidogi is a ruffian with a short temper. It can pulverize anything by swinging around the chain on its neck." },
    },

    MUNKIDORI = {
      dex = 1015, name = "Munkidori", types = { "POISON", "PSYCHIC" },
      baseStats = { hp = 88, attack = 75, defense = 66, speed = 106, specialA = 130, specialD = 90 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1, weightKg = 12.2,
      dexEntry = { kind = "Retainer Pokémon",
        text = "Munkidori keeps itself somewhere safe while it toys with its foes, using psychokinesis to induce intense dizziness." },
    },

    FEZANDIPITI = {
      dex = 1016, name = "Fezandipiti", types = { "POISON", "FAIRY" },
      baseStats = { hp = 88, attack = 91, defense = 82, speed = 99, specialA = 70, specialD = 125 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.4, weightKg = 30.1,
      dexEntry = { kind = "Retainer Pokémon",
        text = "Fezandipiti beats its glossy wings to scatter pheromones that captivate people and Pokémon." },
    },

    OGERPON = {
      dex = 1017, name = "Ogerpon", types = { "GRASS" },
      baseStats = { hp = 80, attack = 120, defense = 84, speed = 110, specialA = 60, specialD = 96 },
      catchRate = 5, baseExp = 255, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 1.2, weightKg = 39.8,
      dexEntry = { kind = "Mask Pokémon",
        text = "This mischief-loving Pokémon is full of curiosity. It battles by drawing out the type-based energy contained within its masks." },
    },

    ARCHALUDON = {
      dex = 1018, name = "Archaludon", types = { "STEEL", "DRAGON" },
      baseStats = { hp = 90, attack = 105, defense = 130, speed = 85, specialA = 125, specialD = 65 },
      catchRate = 10, baseExp = 255, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = {},
      heightM = 2, weightKg = 60,
      dexEntry = { kind = "Alloy Pokémon",
        text = "It digs holes on mountains, searching for food. It’s so durable that being caught in a cave-in won’t faze it." },
    },

    HYDRAPPLE = {
      dex = 1019, name = "Hydrapple", types = { "GRASS", "DRAGON" },
      baseStats = { hp = 106, attack = 80, defense = 110, speed = 44, specialA = 120, specialD = 80 },
      catchRate = 10, baseExp = 255, growthRate = "ERRATIC", happiness = 50,
      evolutions = {},
      heightM = 1.8, weightKg = 93,
      dexEntry = { kind = "Apple Hydra Pokémon",
        text = "These capricious syrpents have banded together. On the rare occasion that their moods align, their true power is unleashed." },
    },

    GOUGINGFIRE = {
      dex = 1020, name = "Flamariete", types = { "FIRE", "DRAGON" },
      baseStats = { hp = 105, attack = 115, defense = 121, speed = 91, specialA = 65, specialD = 93 },
      catchRate = 10, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 3.5, weightKg = 590,
      dexEntry = { kind = "Paradox Pokémon",
        text = "It resembles an eerie Pokémon once shown in a paranormal magazine. That Pokémon was said to be an Entei regenerated from a fossil." },
    },

    RAGINGBOLT = {
      dex = 1021, name = "Electrofuria", types = { "ELECTRIC", "DRAGON" },
      baseStats = { hp = 125, attack = 73, defense = 91, speed = 75, specialA = 137, specialD = 89 },
      catchRate = 10, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 5.2, weightKg = 480,
      dexEntry = { kind = "Paradox Pokémon",
        text = "It bears resemblance to a Pokémon that became a hot topic for a short while after a paranormal magazine touted it as Raikou’s ancestor." },
    },

    IRONBOULDER = {
      dex = 1022, name = "Ferromole", types = { "ROCK", "PSYCHIC" },
      baseStats = { hp = 90, attack = 120, defense = 80, speed = 124, specialA = 68, specialD = 108 },
      catchRate = 10, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.5, weightKg = 162.5,
      dexEntry = { kind = "Paradox Pokémon",
        text = "It was named after a mysterious object recorded in an old book. Its body seems to be metallic." },
    },

    IRONCROWN = {
      dex = 1023, name = "Ferrotesta", types = { "STEEL", "PSYCHIC" },
      baseStats = { hp = 90, attack = 72, defense = 100, speed = 98, specialA = 122, specialD = 108 },
      catchRate = 10, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 1.6, weightKg = 156,
      dexEntry = { kind = "Paradox Pokémon",
        text = "There was supposedly an incident in which it launched shining blades to cut everything around it to pieces. Little else is known about it." },
    },

    TERAPAGOS = {
      dex = 1024, name = "Terapagos", types = { "NORMAL" },
      baseStats = { hp = 90, attack = 65, defense = 85, speed = 60, specialA = 65, specialD = 85 },
      catchRate = 255, baseExp = 90, growthRate = "SLOW", happiness = 50,
      evolutions = {},
      heightM = 0.2, weightKg = 6.5,
      dexEntry = { kind = "Tera Pokémon",
        text = "It’s thought that this Pokémon lived in ancient Paldea until it got caught in seismic shifts and went extinct." },
    },

    PECHARUNT = {
      dex = 1025, name = "Pecharunt", types = { "POISON", "GHOST" },
      baseStats = { hp = 88, attack = 88, defense = 160, speed = 88, specialA = 88, specialD = 88 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", happiness = 0,
      evolutions = {},
      heightM = 0.3, weightKg = 0.3,
      dexEntry = { kind = "Subjugation Pokémon",
        text = "Its peach-shaped shell serves as storage for a potent poison. It makes poisonous mochi and serves them to people and Pokémon." },
    },

  },
}