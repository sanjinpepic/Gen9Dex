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
    PICHU = {
      dex = 172, name = "Pichu", types = { "ELECTRIC" },
      baseStats = { hp = 20, attack = 40, defense = 15, speed = 60, special = 35 },
      catchRate = 190, baseExp = 41, growthRate = "MEDIUM_FAST", happiness = 50,
      evolutions = { { method = "HAPPINESS", species = "PIKACHU" } },
      heightM = 0.3, weightKg = 2.0,
      dexEntry = { kind = "Ratoncito",
        text = "Sigue sin poder contener o retener electricidad. Cuando se asusta, descarga energía de forma accidental. Con todo, a medida que pasa el tiempo va mejorando." },
    },

    MUNCHLAX = {
      dex = 446, name = "Munchlax", types = { "NORMAL" },
      baseStats = { hp = 135, attack = 85, defense = 40, speed = 5, special = 63 },
      catchRate = 50, baseExp = 78, growthRate = "SLOW", happiness = 50,
      evolutions = { { method = "HAPPINESS", species = "SNORLAX" } },
      heightM = 0.6, weightKg = 105.0,
      dexEntry = { kind = "Comilón",
        text = "Engulle su peso en comida una vez al día. Se lo traga todo sin apenas masticar. Esconde comida bajo el largo pelo de su cuerpo, pero más tarde lo olvida." },
    },

    TRUBBISH = {
      dex = 568, name = "Trubbish", types = { "POISON" },
      baseStats = { hp = 50, attack = 50, defense = 62, speed = 65, special = 51 },
      catchRate = 190, baseExp = 66, growthRate = "MEDIUM_FAST",
      evolutions = { { method = "LEVEL", species = "GARBODOR", level = 36 } },
      heightM = 0.6, weightKg = 31.0,
      dexEntry = { kind = "Bolsabasura",
        text = "Pokémon nacido de la reacción química entre una bolsa de basura y residuos industriales." },
    },
    GARBODOR = {
      dex = 569, name = "Garbodor", types = { "POISON" },
      baseStats = { hp = 80, attack = 95, defense = 82, speed = 75, special = 71 },
      catchRate = 60, baseExp = 166, growthRate = "MEDIUM_FAST",
      evolutions = {},
      heightM = 1.9, weightKg = 107.3,
      dexEntry = { kind = "Vertedero",
        text = "Traga basura y la integra en su cuerpo. Despide veneno líquido por la punta de los dedos de su mano derecha." },
    },

    MELTAN = {
      dex = 808, name = "Meltan", types = { "STEEL" },
      baseStats = { hp = 46, attack = 65, defense = 65, speed = 34, special = 45 },
      catchRate = 3, baseExp = 150, growthRate = "SLOW",
      evolutions = { { method = "LEVEL", species = "MELMETAL", level = 45 } },
      heightM = 0.2, weightKg = 8.0,
      dexEntry = { kind = "Tuerca",
        text = "Su cuerpo está compuesto de acero líquido. Funde las partículas de hierro y otros metales del subsuelo para luego absorberlas." },
    },
    MELMETAL = {
      dex = 809, name = "Melmetal", types = { "STEEL" },
      baseStats = { hp = 135, attack = 143, defense = 143, speed = 34, special = 73 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", -- clamped from 300 (schema caps baseExp at 255)
      evolutions = {},
      heightM = 2.5, weightKg = 800.0,
      dexEntry = { kind = "Tuerca",
        text = "Al final de su vida, su cuerpo se oxida y se hace pedazos. Poco tiempo después, estos fragmentos que quedan dan vida a varios Meltan." },
    },

    GROOKEY = {
      dex = 810, name = "Grookey", types = { "GRASS" },
      baseStats = { hp = 50, attack = 65, defense = 50, speed = 65, special = 40 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW",
      evolutions = { { method = "LEVEL", species = "THWACKEY", level = 16 } },
      heightM = 0.3, weightKg = 5.0,
      dexEntry = { kind = "Chimpancé",
        text = "Ataca golpeando sin cesar con su baqueta, con un entusiasmo que crece a medida que acelera el ritmo." },
    },
    THWACKEY = {
      dex = 811, name = "Thwackey", types = { "GRASS" },
      baseStats = { hp = 70, attack = 85, defense = 70, speed = 80, special = 58 },
      catchRate = 45, baseExp = 147, growthRate = "MEDIUM_SLOW",
      evolutions = { { method = "LEVEL", species = "RILLABOOM", level = 35 } },
      heightM = 0.7, weightKg = 14.0,
      dexEntry = { kind = "Ritmo",
        text = "Los Thwackey que marcan el ritmo más contundente con sus dos baquetas son los más respetados por sus congéneres." },
    },
    RILLABOOM = {
      dex = 812, name = "Rillaboom", types = { "GRASS" },
      baseStats = { hp = 100, attack = 125, defense = 90, speed = 85, special = 65 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", -- clamped from 265 (schema caps baseExp at 255)
      evolutions = {},
      heightM = 2.1, weightKg = 90.0,
      dexEntry = { kind = "Percusión",
        text = "El percusionista con la técnica más depurada se convierte en líder. Son de carácter tranquilo y dan mucha importancia a la armonía del grupo." },
    },

    SCORBUNNY = {
      dex = 813, name = "Scorbunny", types = { "FIRE" },
      baseStats = { hp = 50, attack = 71, defense = 40, speed = 69, special = 40 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW",
      evolutions = { { method = "LEVEL", species = "RABOOT", level = 16 } },
      heightM = 0.3, weightKg = 4.5,
      dexEntry = { kind = "Conejo",
        text = "Se pone a correr para elevar su temperatura corporal y propagar la energía ígnea por todo el cuerpo. Desata así su verdadera fuerza." },
    },
    RABOOT = {
      dex = 814, name = "Raboot", types = { "FIRE" },
      baseStats = { hp = 65, attack = 86, defense = 60, speed = 94, special = 58 },
      catchRate = 45, baseExp = 147, growthRate = "MEDIUM_SLOW",
      evolutions = { { method = "LEVEL", species = "CINDERACE", level = 35 } },
      heightM = 0.6, weightKg = 9.0,
      dexEntry = { kind = "Conejo",
        text = "Su suave pelaje lo protege del frío y le permite incrementar todavía más la temperatura de sus movimientos de tipo Fuego." },
    },
    CINDERACE = {
      dex = 815, name = "Cinderace", types = { "FIRE" },
      baseStats = { hp = 80, attack = 116, defense = 75, speed = 119, special = 70 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", -- clamped from 265 (schema caps baseExp at 255)
      evolutions = {},
      heightM = 1.4, weightKg = 33.0,
      dexEntry = { kind = "Delantero",
        text = "Destaca tanto en ataque como en defensa. Se crece cuando recibe una ovación, pero a veces se luce tanto que termina viéndose en apuros." },
    },

    SOBBLE = {
      dex = 816, name = "Sobble", types = { "WATER" },
      baseStats = { hp = 50, attack = 40, defense = 40, speed = 70, special = 55 },
      catchRate = 45, baseExp = 62, growthRate = "MEDIUM_SLOW",
      evolutions = { { method = "LEVEL", species = "DRIZZILE", level = 16 } },
      heightM = 0.3, weightKg = 4.0,
      dexEntry = { kind = "Acuartija",
        text = "Cuando se espanta, libera unas lágrimas con un factor lacrimógeno equivalente a 100 cebollas para hacer llorar también al rival." },
    },
    DRIZZILE = {
      dex = 817, name = "Drizzile", types = { "WATER" },
      baseStats = { hp = 65, attack = 60, defense = 55, speed = 90, special = 75 },
      catchRate = 45, baseExp = 147, growthRate = "MEDIUM_SLOW",
      evolutions = { { method = "LEVEL", species = "INTELEON", level = 35 } },
      heightM = 0.7, weightKg = 11.5,
      dexEntry = { kind = "Acuartija",
        text = "Es inteligente, pero no muestra especial interés por nada. Distribuye trampas por su territorio para mantener alejados a sus enemigos." },
    },
    INTELEON = {
      dex = 818, name = "Inteleon", types = { "WATER" },
      baseStats = { hp = 70, attack = 85, defense = 65, speed = 120, special = 95 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW", -- clamped from 265 (schema caps baseExp at 255)
      evolutions = {},
      heightM = 1.9, weightKg = 45.2,
      dexEntry = { kind = "Agente",
        text = "Dispara chorros de agua por la punta de los dedos a 3 mach de velocidad. Con su membrana nictitante puede ver los puntos débiles del rival." },
    },

    ROOKIDEE = {
      dex = 821, name = "Rookidee", types = { "FLYING" },
      baseStats = { hp = 38, attack = 47, defense = 35, speed = 57, special = 34 },
      catchRate = 255, baseExp = 49, growthRate = "MEDIUM_SLOW",
      evolutions = { { method = "LEVEL", species = "CORVISQUIRE", level = 18 } },
      heightM = 0.2, weightKg = 1.8,
      dexEntry = { kind = "Pajarito",
        text = "De naturaleza valiente, planta cara a cualquier rival, por muy fuerte que sea. Los contraataques que recibe le sirven para fortalecerse." },
    },
    CORVISQUIRE = {
      dex = 822, name = "Corvisquire", types = { "FLYING" },
      baseStats = { hp = 68, attack = 67, defense = 55, speed = 77, special = 49 },
      catchRate = 120, baseExp = 128, growthRate = "MEDIUM_SLOW",
      evolutions = { { method = "LEVEL", species = "CORVIKNIGHT", level = 38 } },
      heightM = 0.8, weightKg = 16.0,
      dexEntry = { kind = "Cuervo",
        text = "Su inteligencia le permite servirse de objetos. Por ejemplo, recoge y lanza piedras con las patas, o utiliza cuerdas para atrapar a su oponente." },
    },
    CORVIKNIGHT = {
      dex = 823, name = "Corviknight", types = { "FLYING", "STEEL" },
      baseStats = { hp = 98, attack = 87, defense = 105, speed = 67, special = 69 },
      catchRate = 45, baseExp = 248, growthRate = "MEDIUM_SLOW",
      evolutions = {},
      heightM = 2.2, weightKg = 75.0,
      dexEntry = { kind = "Cuervo",
        text = "No tiene rival en los cielos. El acero negro y lustroso de su cuerpo intimida a cualquier adversario. Ejerce de taxi volador en Galar." },
    },

    BLIPBUG = {
      dex = 824, name = "Blipbug", types = { "BUG" },
      baseStats = { hp = 25, attack = 20, defense = 20, speed = 45, special = 35 },
      catchRate = 255, baseExp = 36, growthRate = "MEDIUM_FAST",
      evolutions = { { method = "LEVEL", species = "DOTTLER", level = 10 } },
      heightM = 0.4, weightKg = 8.0,
      dexEntry = { kind = "Pupa",
        text = "Es habitual verlo en el campo. Los pelos que tiene son sensores con los que percibe lo que ocurre a su alrededor. Es muy inteligente." },
    },
    DOTTLER = {
      dex = 825, name = "Dottler", types = { "BUG", "PSYCHIC" },
      baseStats = { hp = 50, attack = 35, defense = 80, speed = 30, special = 70 },
      catchRate = 120, baseExp = 117, growthRate = "MEDIUM_FAST",
      evolutions = { { method = "LEVEL", species = "ORBEETLE", level = 30 } },
      heightM = 0.4, weightKg = 19.5,
      dexEntry = { kind = "Radomo",
        text = "Apenas se mueve, pero está vivo. Se cree que adquiere poderes psíquicos mientras permanece recluido en su caparazón sin comer ni beber." },
    },
    ORBEETLE = {
      dex = 826, name = "Orbeetle", types = { "BUG", "PSYCHIC" },
      baseStats = { hp = 60, attack = 45, defense = 110, speed = 90, special = 100 },
      catchRate = 45, baseExp = 253, growthRate = "MEDIUM_FAST",
      evolutions = {},
      heightM = 0.4, weightKg = 40.8,
      dexEntry = { kind = "Siete puntos",
        text = "Se sirve de sus poderes psíquicos, con los que es capaz de percibir lo que ocurre en un radio de 10 km, para examinar sus alrededores." },
    },

    CHEWTLE = {
      dex = 833, name = "Chewtle", types = { "WATER" },
      baseStats = { hp = 50, attack = 64, defense = 50, speed = 44, special = 38 },
      catchRate = 255, baseExp = 57, growthRate = "MEDIUM_FAST",
      evolutions = { { method = "LEVEL", species = "DREDNAW", level = 22 } },
      heightM = 0.3, weightKg = 8.5,
      dexEntry = { kind = "Mordedura",
        text = "Muerde todo lo que se le ponga por delante. Al parecer, lo hace para aliviar el dolor que siente cuando le crecen los incisivos." },
    },
    DREDNAW = {
      dex = 834, name = "Drednaw", types = { "WATER", "ROCK" },
      baseStats = { hp = 90, attack = 115, defense = 90, speed = 74, special = 58 },
      catchRate = 75, baseExp = 170, growthRate = "MEDIUM_FAST",
      evolutions = {},
      heightM = 1.0, weightKg = 115.5,
      dexEntry = { kind = "Mordisco",
        text = "Su cuello extensible le permite alcanzar a los rivales a distancia. Hundiendo sus afilados dientes, les da el golpe de gracia." },
    },

    ROLYCOLY = {
      dex = 837, name = "Rolycoly", types = { "ROCK" },
      baseStats = { hp = 30, attack = 40, defense = 50, speed = 30, special = 45 },
      catchRate = 255, baseExp = 48, growthRate = "MEDIUM_SLOW",
      evolutions = { { method = "LEVEL", species = "CARKOL", level = 18 } },
      heightM = 0.3, weightKg = 12.0,
      dexEntry = { kind = "Carbón",
        text = "Fue descubierto hace aproximadamente 400 años en una mina. Casi la totalidad de su cuerpo presenta una composición igual a la del carbón." },
    },
    CARKOL = {
      dex = 838, name = "Carkol", types = { "ROCK", "FIRE" },
      baseStats = { hp = 80, attack = 60, defense = 90, speed = 50, special = 65 },
      catchRate = 120, baseExp = 144, growthRate = "MEDIUM_SLOW",
      evolutions = { { method = "LEVEL", species = "COALOSSAL", level = 34 } },
      heightM = 1.1, weightKg = 78.0,
      dexEntry = { kind = "Carbón",
        text = "Gira las patas a gran velocidad para correr a unos 30 km/h. Emite llamas a una temperatura de 1000 °C." },
    },
    COALOSSAL = {
      dex = 839, name = "Coalossal", types = { "ROCK", "FIRE" },
      baseStats = { hp = 110, attack = 80, defense = 120, speed = 30, special = 85 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_SLOW",
      evolutions = {},
      heightM = 2.8, weightKg = 310.5,
      dexEntry = { kind = "Carbón",
        text = "Aunque es de carácter sereno, monta en cólera si ve a seres humanos dañando una mina y reduce todo a cenizas con sus llamas a 1500 °C." },
    },

    APPLIN = {
      dex = 840, name = "Applin", types = { "GRASS", "DRAGON" },
      baseStats = { hp = 40, attack = 40, defense = 80, speed = 20, special = 40 },
      -- engine has no ERRATIC id; SLIGHTLY_FAST is the closest native curve (see file header)
      catchRate = 255, baseExp = 52, growthRate = "SLIGHTLY_FAST",
      evolutions = {
        { method = "ITEM", species = "FLAPPLE", item = "TARTAPPLE" },
        { method = "ITEM", species = "APPLETUN", item = "SWEETAPPLE" },
      },
      heightM = 0.2, weightKg = 0.5,
      dexEntry = { kind = "Manzanido",
        text = "Habita durante toda su vida en el interior de una manzana. Finge ser una fruta para protegerse de los Pokémon pájaro, sus enemigos naturales." },
    },
    FLAPPLE = {
      dex = 841, name = "Flapple", types = { "GRASS", "DRAGON" },
      baseStats = { hp = 70, attack = 110, defense = 80, speed = 70, special = 78 },
      catchRate = 45, baseExp = 170, growthRate = "SLIGHTLY_FAST",
      evolutions = {},
      heightM = 0.3, weightKg = 1.0,
      dexEntry = { kind = "Manzanala",
        text = "Ha evolucionado tras ingerir una manzana ácida. Las bolsas de las mejillas albergan un fluido cuya extrema acidez llega a provocar quemaduras." },
    },
    APPLETUN = {
      dex = 842, name = "Appletun", types = { "GRASS", "DRAGON" },
      baseStats = { hp = 110, attack = 85, defense = 80, speed = 30, special = 90 },
      catchRate = 45, baseExp = 170, growthRate = "SLIGHTLY_FAST",
      evolutions = {},
      heightM = 0.4, weightKg = 13.0,
      dexEntry = { kind = "Manzanéctar",
        text = "Su cuerpo está recubierto de néctar. La piel de la espalda es tan dulce que los niños de antaño solían tomarla como merienda." },
    },

    SILICOBRA = {
      dex = 843, name = "Silicobra", types = { "GROUND" },
      baseStats = { hp = 52, attack = 57, defense = 75, speed = 46, special = 43 },
      catchRate = 255, baseExp = 63, growthRate = "MEDIUM_FAST",
      evolutions = { { method = "LEVEL", species = "SANDACONDA", level = 36 } },
      heightM = 2.2, weightKg = 7.6,
      dexEntry = { kind = "Serpiente arena",
        text = "Almacena la arena que ingiere al perforar hoyos en la saca del cuello, cuya capacidad llega a alcanzar incluso los 8 kg." },
    },
    SANDACONDA = {
      dex = 844, name = "Sandaconda", types = { "GROUND" },
      baseStats = { hp = 72, attack = 107, defense = 125, speed = 71, special = 68 },
      catchRate = 120, baseExp = 179, growthRate = "MEDIUM_FAST",
      evolutions = {},
      heightM = 3.8, weightKg = 65.5,
      dexEntry = { kind = "Serpiente arena",
        text = "Se retuerce para expulsar por los orificios nasales hasta 100 kg de arena. La ausencia de esta mina su ánimo." },
    },

    TOXEL = {
      dex = 848, name = "Toxel", types = { "ELECTRIC", "POISON" },
      baseStats = { hp = 40, attack = 38, defense = 35, speed = 40, special = 45 },
      catchRate = 75, baseExp = 48, growthRate = "MEDIUM_SLOW",
      evolutions = { { method = "LEVEL", species = "TOXTRICITY", level = 30 } },
      heightM = 0.4, weightKg = 11.0,
      dexEntry = { kind = "Retoño",
        text = "Provoca una reacción química para generar energía eléctrica con sus toxinas. Aunque de bajo voltaje, puede causar entumecimiento." },
    },
    TOXTRICITY = {
      dex = 849, name = "Toxtricity", types = { "ELECTRIC", "POISON" },
      baseStats = { hp = 75, attack = 98, defense = 70, speed = 75, special = 92 },
      catchRate = 45, baseExp = 176, growthRate = "MEDIUM_SLOW",
      evolutions = {},
      heightM = 1.6, weightKg = 40.0,
      dexEntry = { kind = "Punki",
        text = "Cuando rasga las protuberancias del pecho para generar energía eléctrica, emite un sonido similar al de una guitarra, que reverbera en el entorno." },
    },

    SIZZLIPEDE = {
      dex = 850, name = "Sizzlipede", types = { "FIRE", "BUG" },
      baseStats = { hp = 50, attack = 65, defense = 45, speed = 45, special = 50 },
      catchRate = 190, baseExp = 61, growthRate = "MEDIUM_FAST",
      evolutions = { { method = "LEVEL", species = "CENTISKORCH", level = 28 } },
      heightM = 0.7, weightKg = 1.0,
      dexEntry = { kind = "Radiador",
        text = "Genera calor consumiendo el gas inflamable que almacena en su cuerpo. Los círculos amarillos del abdomen están particularmente calientes." },
    },
    CENTISKORCH = {
      dex = 851, name = "Centiskorch", types = { "FIRE", "BUG" },
      baseStats = { hp = 100, attack = 115, defense = 65, speed = 65, special = 90 },
      catchRate = 75, baseExp = 184, growthRate = "MEDIUM_FAST",
      evolutions = {},
      heightM = 3.0, weightKg = 120.0,
      dexEntry = { kind = "Radiador",
        text = "Cuando genera calor, su temperatura corporal alcanza aproximadamente los 800 °C. Usa el cuerpo a modo de látigo para lanzarse al ataque." },
    },

    HATENNA = {
      dex = 856, name = "Hatenna", types = { "PSYCHIC" },
      baseStats = { hp = 42, attack = 30, defense = 45, speed = 39, special = 55 },
      catchRate = 235, baseExp = 53, growthRate = "SLOW",
      evolutions = { { method = "LEVEL", species = "HATTREM", level = 32 } },
      heightM = 0.4, weightKg = 3.4,
      dexEntry = { kind = "Calma",
        text = "Percibe los sentimientos de los seres vivos con la protuberancia de la cabeza. Solo abre su corazón a quienes muestren un carácter sosegado." },
    },
    HATTREM = {
      dex = 857, name = "Hattrem", types = { "PSYCHIC" },
      baseStats = { hp = 57, attack = 40, defense = 65, speed = 49, special = 80 },
      catchRate = 120, baseExp = 130, growthRate = "SLOW",
      evolutions = { { method = "LEVEL", species = "HATTERENE", level = 42 } },
      heightM = 0.6, weightKg = 4.8,
      dexEntry = { kind = "Serenidad",
        text = "Silencia a cualquiera que muestre una emoción intensa sin importar de quién se trate y recurre para ello a métodos a cuál más violento." },
    },
    HATTERENE = {
      dex = 858, name = "Hatterene", types = { "PSYCHIC", "FAIRY" },
      baseStats = { hp = 57, attack = 90, defense = 95, speed = 29, special = 120 },
      catchRate = 45, baseExp = 255, growthRate = "SLOW",
      evolutions = {},
      heightM = 2.1, weightKg = 5.1,
      dexEntry = { kind = "Sliencio",
        text = "Para mantener alejados a los demás seres vivos, emana a su alrededor ondas psíquicas cuya potencia es capaz de provocar jaquecas." },
    },

    IMPIDIMP = {
      dex = 859, name = "Impidimp", types = { "DARK", "FAIRY" },
      baseStats = { hp = 45, attack = 45, defense = 30, speed = 50, special = 48 },
      catchRate = 255, baseExp = 53, growthRate = "MEDIUM_FAST",
      evolutions = { { method = "LEVEL", species = "MORGREM", level = 32 } },
      heightM = 0.4, weightKg = 5.5,
      dexEntry = { kind = "Astuto",
        text = "Con el fin de revitalizarse, inhala por la nariz la energía negativa que desprenden tanto personas como Pokémon cuando están descontentos." },
    },
    MORGREM = {
      dex = 860, name = "Morgrem", types = { "DARK", "FAIRY" },
      baseStats = { hp = 65, attack = 60, defense = 45, speed = 70, special = 65 },
      catchRate = 120, baseExp = 130, growthRate = "MEDIUM_FAST",
      evolutions = { { method = "LEVEL", species = "GRIMMSNARL", level = 42 } },
      heightM = 0.8, weightKg = 12.5,
      dexEntry = { kind = "Malicioso",
        text = "Su estrategia consiste en postrarse ante el rival y fingir una disculpa para ensartarlo con el mechón que tiene en la espalda, afilado cual lanza." },
    },
    GRIMMSNARL = {
      dex = 861, name = "Grimmsnarl", types = { "DARK", "FAIRY" },
      baseStats = { hp = 95, attack = 120, defense = 65, speed = 60, special = 85 },
      catchRate = 45, baseExp = 255, growthRate = "MEDIUM_FAST",
      evolutions = {},
      heightM = 1.5, weightKg = 61.0,
      dexEntry = { kind = "Voluminoso",
        text = "Su cabello desempeña una función similar a la de fibras musculares. Al soltárselo, su movimiento tentacular le permite reducir a su objetivo." },
    },

    MILCERY = {
      dex = 868, name = "Milcery", types = { "FAIRY" },
      baseStats = { hp = 45, attack = 40, defense = 40, speed = 34, special = 56 },
      catchRate = 200, baseExp = 54, growthRate = "MEDIUM_FAST",
      evolutions = {
        { method = "ITEM", species = "ALCREMIE", item = "STRAWBERRYSWEET" },
        { method = "ITEM", species = "ALCREMIE", item = "BERRYSWEET" },
        { method = "ITEM", species = "ALCREMIE", item = "LOVESWEET" },
        { method = "ITEM", species = "ALCREMIE", item = "STARSWEET" },
        { method = "ITEM", species = "ALCREMIE", item = "CLOVERSWEET" },
        { method = "ITEM", species = "ALCREMIE", item = "FLOWERSWEET" },
        { method = "ITEM", species = "ALCREMIE", item = "RIBBONSWEET" },
      },
      heightM = 0.2, weightKg = 0.3,
      dexEntry = { kind = "Nata",
        text = "Su cremoso cuerpo surgió a partir de la unión de partículas odoríferas de dulces aromas presentes en el aire." },
    },
    ALCREMIE = {
      dex = 869, name = "Alcremie", types = { "FAIRY" },
      baseStats = { hp = 65, attack = 60, defense = 75, speed = 64, special = 116 },
      catchRate = 100, baseExp = 173, growthRate = "MEDIUM_FAST",
      evolutions = {},
      heightM = 0.3, weightKg = 0.5,
      dexEntry = { kind = "Nata",
        text = "Obsequia bayas decoradas con nata a aquellos Entrenadores en los que confía." },
    },

    CUFANT = {
      dex = 878, name = "Cufant", types = { "STEEL" },
      baseStats = { hp = 72, attack = 80, defense = 49, speed = 40, special = 45 },
      catchRate = 190, baseExp = 66, growthRate = "MEDIUM_FAST",
      evolutions = { { method = "LEVEL", species = "COPPERAJAH", level = 34 } },
      heightM = 1.2, weightKg = 100.0,
      dexEntry = { kind = "Broncefante",
        text = "Su constitución fornida le permite transportar sin inmutarse cargas de 5 toneladas. Utiliza la trompa para excavar la tierra." },
    },
    COPPERAJAH = {
      dex = 879, name = "Copperajah", types = { "STEEL" },
      baseStats = { hp = 122, attack = 130, defense = 69, speed = 30, special = 75 },
      catchRate = 90, baseExp = 175, growthRate = "MEDIUM_FAST",
      evolutions = {},
      heightM = 3.0, weightKg = 650.0,
      dexEntry = { kind = "Broncefante",
        text = "Su piel verdosa es resistente al agua. Proviene de tierras lejanas y presta ayuda a las personas en la realización de ciertos trabajos." },
    },

    DURALUDON = {
      dex = 884, name = "Duraludon", types = { "STEEL", "DRAGON" },
      baseStats = { hp = 70, attack = 95, defense = 115, speed = 85, special = 85 },
      catchRate = 45, baseExp = 187, growthRate = "MEDIUM_FAST",
      evolutions = {},
      heightM = 1.8, weightKg = 40.0,
      dexEntry = { kind = "Aleación",
        text = "Su cuerpo, similar a un metal pulido, es tan ligero como robusto. Sin embargo, tiene el defecto de que se oxida con facilidad." },
    },

    ETERNATUS = {
      dex = 890, name = "Eternatus", types = { "POISON", "DRAGON" },
      baseStats = { hp = 140, attack = 85, defense = 95, speed = 130, special = 120 },
      catchRate = 255, baseExp = 255, growthRate = "SLOW", -- clamped from 345 (schema caps baseExp at 255)
      evolutions = {},
      heightM = 20.0, weightKg = 950.0,
      dexEntry = { kind = "Gigantesco",
        text = "Fue hallado en el interior de un meteorito caído hace 20000 años. Por lo visto, está relacionado con el misterio que rodea al fenómeno Dinamax." },
    },

    KUBFU = {
      dex = 891, name = "Kubfu", types = { "FIGHTING" },
      baseStats = { hp = 60, attack = 90, defense = 60, speed = 72, special = 52 },
      catchRate = 3, baseExp = 77, growthRate = "SLOW",
      evolutions = {
        { method = "ITEM", species = "URSHIFU", item = "SCROLLOFDARKNESS" },
        { method = "ITEM", species = "URSHIFU", item = "SCROLLOFWATERS" },
      },
      heightM = 0.6, weightKg = 12.0,
      dexEntry = { kind = "Kung-fu",
        text = "Al tirar de los mechones blancos de la cabeza, acrecienta su espíritu luchador y empieza a acumular fuerza en el órgano de su bajo vientre." },
    },
    URSHIFU = {
      dex = 892, name = "Urshifu", types = { "FIGHTING", "DARK" },
      baseStats = { hp = 100, attack = 130, defense = 100, speed = 97, special = 62 },
      catchRate = 3, baseExp = 255, growthRate = "SLOW", -- clamped from 275 (schema caps baseExp at 255)
      evolutions = {},
      heightM = 1.9, weightKg = 105.0,
      dexEntry = { kind = "Kung-fu",
        text = "Vive en zonas montañosas en áreas recónditas, donde entrena corriendo por escarpados riscos para fortalecer sus piernas y refinar su técnica." },
    },

    GOSSIFLEUR = {
      dex = 829, name = "Gossifleur", types = { "GRASS" },
      baseStats = { hp = 40, attack = 40, defense = 60, speed = 10, special = 50 },
      catchRate = 190, baseExp = 50, growthRate = "MEDIUM_FAST",
      evolutions = { { method = "LEVEL", species = "ELDEGOSS", level = 20 } },
      heightM = 0.4, weightKg = 2.2,
      dexEntry = { kind = "Adornofloral",
        text = "Si planta su única extremidad inferior en la tierra y se expone a abundante luz solar, sus pétalos cobran un color vivo." },
    },
    ELDEGOSS = {
      dex = 830, name = "Eldegoss", types = { "GRASS" },
      baseStats = { hp = 60, attack = 50, defense = 90, speed = 60, special = 100 },
      catchRate = 75, baseExp = 161, growthRate = "MEDIUM_FAST",
      evolutions = {},
      heightM = 0.5, weightKg = 2.5,
      dexEntry = { kind = "Adornalgodón",
        text = "Las semillas que tiene entre la pelusa son muy nutritivas. Arrastradas por el viento, devuelven la vitalidad a la flora y a otros Pokémon." },
    },
  },
}
