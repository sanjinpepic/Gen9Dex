-- Phase 2 -- real level-up learnsets for the 51 Phase-1 species, replacing
-- main.lua's placeholder { "TACKLE" }. Source: Pokemon_Stats/pokemon.txt
-- Moves lines. PBS level 0/1 entries both become level1Moves (the
-- starting moveset); level>1 entries become learnset. Every move id here
-- is already the FINAL engine id: Gen1-native moves are translated to
-- their real snake_case id (e.g. PBS TAKEDOWN -> engine TAKE_DOWN, cross-
-- checked against confirmed ids from kanto-ascendant's own COUNTERS/
-- RIVAL_EVOLUTIONS tables), everything else is the id moves_new.lua
-- registers under (unchanged from PBS spelling).
--
-- TM/HM/tutor/egg-move compatibility (PBS TutorMoves/EggMoves/the wider
-- TM list) is explicitly NOT part of this pass -- this engine's actual
-- TM/HM roster (which native Gen1 TMs exist, whether it has tutors at
-- all) was never confirmed against either reference mod, so claiming TM
-- compatibility here would be inventing data, not translating it.

return {
    PICHU = {
      level1Moves = { "THUNDER_SHOCK", "TAIL_WHIP" },
      learnset = { { level = 4, move = "PLAYNICE" }, { level = 8, move = "SWEETKISS" }, { level = 12, move = "NUZZLE" }, { level = 16, move = "NASTYPLOT" }, { level = 20, move = "CHARM" } },
    },
    MUNCHLAX = {
      level1Moves = { "LICK", "TACKLE" },
      learnset = { { level = 4, move = "DEFENSE_CURL" }, { level = 8, move = "RECYCLE" }, { level = 12, move = "COVET" }, { level = 16, move = "BITE" }, { level = 20, move = "STOCKPILE" }, { level = 20, move = "SWALLOW" }, { level = 24, move = "SCREECH" }, { level = 28, move = "BODY_SLAM" }, { level = 32, move = "FLING" }, { level = 36, move = "AMNESIA" }, { level = 40, move = "METRONOME" }, { level = 44, move = "FLAIL" }, { level = 48, move = "BELLYDRUM" }, { level = 52, move = "LASTRESORT" } },
    },
    TRUBBISH = {
      level1Moves = { "POUND", "POISON_GAS" },
      learnset = { { level = 3, move = "RECYCLE" }, { level = 6, move = "ACIDSPRAY" }, { level = 9, move = "AMNESIA" }, { level = 12, move = "CLEARSMOG" }, { level = 15, move = "TOXICSPIKES" }, { level = 18, move = "SLUDGE" }, { level = 21, move = "STOCKPILE" }, { level = 21, move = "SWALLOW" }, { level = 24, move = "TAKE_DOWN" }, { level = 27, move = "SLUDGEBOMB" }, { level = 30, move = "TOXIC" }, { level = 33, move = "BELCH" }, { level = 37, move = "PAINSPLIT" }, { level = 39, move = "GUNKSHOT" }, { level = 42, move = "EXPLOSION" } },
    },
    GARBODOR = {
      level1Moves = { "TAKE_DOWN", "METALCLAW", "POUND", "POISON_GAS", "RECYCLE", "ACIDSPRAY" },
      learnset = { { level = 9, move = "AMNESIA" }, { level = 12, move = "CLEARSMOG" }, { level = 15, move = "TOXICSPIKES" }, { level = 18, move = "SLUDGE" }, { level = 21, move = "STOCKPILE" }, { level = 21, move = "SWALLOW" }, { level = 24, move = "BODY_SLAM" }, { level = 27, move = "SLUDGEBOMB" }, { level = 30, move = "TOXIC" }, { level = 33, move = "BELCH" }, { level = 39, move = "PAINSPLIT" }, { level = 43, move = "GUNKSHOT" }, { level = 48, move = "EXPLOSION" } },
    },
    MELTAN = {
      level1Moves = { "THUNDER_SHOCK", "HARDEN" },
      learnset = { { level = 8, move = "TAIL_WHIP" }, { level = 16, move = "HEADBUTT" }, { level = 24, move = "THUNDER_WAVE" }, { level = 32, move = "ACID_ARMOR" }, { level = 40, move = "FLASHCANNON" } },
    },
    MELMETAL = {
      level1Moves = { "THUNDER_PUNCH", "THUNDER_SHOCK", "HARDEN", "TAIL_WHIP", "HEADBUTT" },
      learnset = { { level = 24, move = "THUNDER_WAVE" }, { level = 32, move = "ACID_ARMOR" }, { level = 40, move = "FLASHCANNON" }, { level = 48, move = "MEGA_PUNCH" }, { level = 56, move = "PROTECT" }, { level = 64, move = "DISCHARGE" }, { level = 72, move = "DYNAMICPUNCH" }, { level = 80, move = "SUPERPOWER" }, { level = 88, move = "DOUBLEIRONBASH" }, { level = 96, move = "HYPER_BEAM" } },
    },
    GROOKEY = {
      level1Moves = { "SCRATCH", "GROWL" },
      learnset = { { level = 6, move = "BRANCHPOKE" }, { level = 8, move = "TAUNT" }, { level = 12, move = "RAZOR_LEAF" }, { level = 17, move = "SCREECH" }, { level = 20, move = "KNOCKOFF" }, { level = 24, move = "SLAM" }, { level = 28, move = "UPROAR" }, { level = 32, move = "WOODHAMMER" }, { level = 36, move = "ENDEAVOR" } },
    },
    THWACKEY = {
      level1Moves = { "DOUBLEHIT", "SCRATCH", "GROWL", "BRANCHPOKE", "TAUNT" },
      learnset = { { level = 12, move = "RAZOR_LEAF" }, { level = 19, move = "SCREECH" }, { level = 24, move = "KNOCKOFF" }, { level = 26, move = "SMACKDOWN" }, { level = 30, move = "SLAM" }, { level = 36, move = "UPROAR" }, { level = 39, move = "ROCK_SLIDE" }, { level = 42, move = "WOODHAMMER" }, { level = 45, move = "ROCKPOLISH" }, { level = 48, move = "ENDEAVOR" }, { level = 50, move = "STONEEDGE" }, { level = 54, move = "HEADSMASH" } },
    },
    RILLABOOM = {
      level1Moves = { "DRUMBEATING", "DOUBLEHIT", "GRASSYTERRAIN", "NOBLEROAR", "SCRATCH", "GROWL", "BRANCHPOKE", "TAUNT" },
      learnset = { { level = 12, move = "RAZOR_LEAF" }, { level = 19, move = "SCREECH" }, { level = 24, move = "KNOCKOFF" }, { level = 30, move = "SLAM" }, { level = 38, move = "UPROAR" }, { level = 46, move = "WOODHAMMER" }, { level = 54, move = "ENDEAVOR" }, { level = 62, move = "BOOMBURST" } },
    },
    SCORBUNNY = {
      level1Moves = { "TACKLE", "GROWL" },
      learnset = { { level = 6, move = "EMBER" }, { level = 8, move = "QUICK_ATTACK" }, { level = 12, move = "DOUBLE_KICK" }, { level = 17, move = "FLAMECHARGE" }, { level = 20, move = "AGILITY" }, { level = 24, move = "HEADBUTT" }, { level = 28, move = "COUNTER" }, { level = 32, move = "BOUNCE" }, { level = 36, move = "DOUBLE_EDGE" } },
    },
    RABOOT = {
      level1Moves = { "TACKLE", "GROWL", "EMBER", "QUICK_ATTACK" },
      learnset = { { level = 12, move = "DOUBLE_KICK" }, { level = 19, move = "FLAMECHARGE" }, { level = 24, move = "AGILITY" }, { level = 30, move = "HEADBUTT" }, { level = 36, move = "COUNTER" }, { level = 42, move = "BOUNCE" }, { level = 48, move = "DOUBLE_EDGE" } },
    },
    CINDERACE = {
      level1Moves = { "PYROBALL", "FEINT", "TACKLE", "GROWL", "EMBER", "QUICK_ATTACK" },
      learnset = { { level = 12, move = "DOUBLE_KICK" }, { level = 19, move = "FLAMECHARGE" }, { level = 24, move = "AGILITY" }, { level = 30, move = "HEADBUTT" }, { level = 38, move = "COUNTER" }, { level = 46, move = "BOUNCE" }, { level = 54, move = "DOUBLE_EDGE" }, { level = 62, move = "COURTCHANGE" } },
    },
    SOBBLE = {
      level1Moves = { "POUND", "GROWL" },
      learnset = { { level = 6, move = "WATER_GUN" }, { level = 8, move = "BIND" }, { level = 12, move = "WATERPULSE" }, { level = 17, move = "TEARFULLOOK" }, { level = 20, move = "SUCKERPUNCH" }, { level = 24, move = "UTURN" }, { level = 28, move = "LIQUIDATION" }, { level = 32, move = "SOAK" }, { level = 36, move = "RAINDANCE" } },
    },
    DRIZZILE = {
      level1Moves = { "POUND", "GROWL", "WATER_GUN", "BIND" },
      learnset = { { level = 12, move = "WATERPULSE" }, { level = 19, move = "TEARFULLOOK" }, { level = 24, move = "SUCKERPUNCH" }, { level = 30, move = "UTURN" }, { level = 36, move = "LIQUIDATION" }, { level = 42, move = "SOAK" }, { level = 48, move = "RAINDANCE" } },
    },
    INTELEON = {
      level1Moves = { "SNIPESHOT", "ACROBATICS", "POUND", "GROWL", "WATER_GUN", "BIND" },
      learnset = { { level = 12, move = "WATERPULSE" }, { level = 19, move = "TEARFULLOOK" }, { level = 24, move = "SUCKERPUNCH" }, { level = 30, move = "UTURN" }, { level = 38, move = "LIQUIDATION" }, { level = 46, move = "SOAK" }, { level = 54, move = "RAINDANCE" }, { level = 62, move = "HYDRO_PUMP" } },
    },
    ROOKIDEE = {
      level1Moves = { "PECK", "LEER" },
      learnset = { { level = 4, move = "POWERTRIP" }, { level = 8, move = "HONECLAWS" }, { level = 12, move = "FURY_ATTACK" }, { level = 16, move = "PLUCK" }, { level = 20, move = "TAUNT" }, { level = 24, move = "SCARYFACE" }, { level = 28, move = "DRILL_PECK" }, { level = 32, move = "SWAGGER" }, { level = 36, move = "BRAVEBIRD" } },
    },
    CORVISQUIRE = {
      level1Moves = { "PECK", "LEER", "POWERTRIP", "HONECLAWS" },
      learnset = { { level = 12, move = "FURY_ATTACK" }, { level = 16, move = "PLUCK" }, { level = 22, move = "TAUNT" }, { level = 28, move = "SCARYFACE" }, { level = 34, move = "DRILL_PECK" }, { level = 40, move = "SWAGGER" }, { level = 46, move = "BRAVEBIRD" } },
    },
    CORVIKNIGHT = {
      level1Moves = { "STEELWING", "IRONDEFENSE", "METALSOUND", "PECK", "LEER", "POWERTRIP", "HONECLAWS", "SCREECH" },
      learnset = { { level = 12, move = "FURY_ATTACK" }, { level = 16, move = "PLUCK" }, { level = 22, move = "TAUNT" }, { level = 28, move = "SCARYFACE" }, { level = 34, move = "DRILL_PECK" }, { level = 42, move = "SWAGGER" }, { level = 50, move = "BRAVEBIRD" } },
    },
    BLIPBUG = {
      level1Moves = { "STRUGGLEBUG" },
      learnset = {  },
    },
    DOTTLER = {
      level1Moves = { "REFLECT", "LIGHT_SCREEN", "CONFUSION", "STRUGGLEBUG" },
      learnset = {  },
    },
    ORBEETLE = {
      level1Moves = { "REFLECT", "LIGHT_SCREEN", "CONFUSION", "STRUGGLEBUG" },
      learnset = { { level = 4, move = "CONFUSE_RAY" }, { level = 8, move = "MAGICCOAT" }, { level = 12, move = "AGILITY" }, { level = 16, move = "PSYBEAM" }, { level = 20, move = "HYPNOSIS" }, { level = 24, move = "ALLYSWITCH" }, { level = 28, move = "BUGBUZZ" }, { level = 32, move = "MIRRORCOAT" }, { level = 36, move = "PSYCHIC_M" }, { level = 40, move = "AFTERYOU" }, { level = 44, move = "CALMMIND" }, { level = 48, move = "PSYCHICTERRAIN" } },
    },
    CHEWTLE = {
      level1Moves = { "TACKLE", "WATER_GUN" },
      learnset = { { level = 7, move = "BITE" }, { level = 14, move = "PROTECT" }, { level = 21, move = "HEADBUTT" }, { level = 28, move = "COUNTER" }, { level = 35, move = "JAWLOCK" }, { level = 42, move = "LIQUIDATION" }, { level = 49, move = "BODY_SLAM" } },
    },
    DREDNAW = {
      level1Moves = { "ROCKTOMB", "RAZORSHELL", "CRUNCH", "ROCKPOLISH", "TACKLE", "WATER_GUN", "BITE", "PROTECT" },
      learnset = { { level = 21, move = "HEADBUTT" }, { level = 30, move = "COUNTER" }, { level = 39, move = "JAWLOCK" }, { level = 48, move = "LIQUIDATION" }, { level = 57, move = "BODY_SLAM" }, { level = 66, move = "HEADSMASH" } },
    },
    ROLYCOLY = {
      level1Moves = { "TACKLE", "SMOKESCREEN" },
      learnset = { { level = 5, move = "RAPIDSPIN" }, { level = 10, move = "SMACKDOWN" }, { level = 15, move = "ROCKPOLISH" }, { level = 20, move = "ANCIENTPOWER" }, { level = 25, move = "INCINERATE" }, { level = 30, move = "STEALTHROCK" }, { level = 35, move = "HEATCRASH" }, { level = 40, move = "ROCKBLAST" } },
    },
    CARKOL = {
      level1Moves = { "FLAMECHARGE", "TACKLE", "SMOKESCREEN", "RAPIDSPIN", "SMACKDOWN" },
      learnset = { { level = 15, move = "ROCKPOLISH" }, { level = 20, move = "ANCIENTPOWER" }, { level = 27, move = "INCINERATE" }, { level = 35, move = "STEALTHROCK" }, { level = 41, move = "HEATCRASH" }, { level = 48, move = "ROCKBLAST" }, { level = 55, move = "BURNUP" }, { level = 55, move = "STONEEDGE" } },
    },
    COALOSSAL = {
      level1Moves = { "TARSHOT", "FLAMECHARGE", "TACKLE", "SMOKESCREEN", "RAPIDSPIN", "SMACKDOWN" },
      learnset = { { level = 15, move = "ROCKPOLISH" }, { level = 20, move = "ANCIENTPOWER" }, { level = 27, move = "INCINERATE" }, { level = 37, move = "STEALTHROCK" }, { level = 45, move = "HEATCRASH" }, { level = 54, move = "ROCKBLAST" }, { level = 63, move = "BURNUP" }, { level = 63, move = "STONEEDGE" } },
    },
    APPLIN = {
      level1Moves = { "WITHDRAW", "ASTONISH" },
      learnset = {  },
    },
    FLAPPLE = {
      level1Moves = { "WING_ATTACK", "RECYCLE", "WITHDRAW", "ASTONISH", "GROWTH", "TWISTER" },
      learnset = { { level = 4, move = "ACIDSPRAY" }, { level = 8, move = "ACROBATICS" }, { level = 12, move = "LEECH_SEED" }, { level = 16, move = "PROTECT" }, { level = 20, move = "DRAGONBREATH" }, { level = 24, move = "DRAGONDANCE" }, { level = 28, move = "DRAGONPULSE" }, { level = 32, move = "GRAVAPPLE" }, { level = 36, move = "IRONDEFENSE" }, { level = 40, move = "FLY" }, { level = 44, move = "DRAGONRUSH" } },
    },
    APPLETUN = {
      level1Moves = { "HEADBUTT", "RECYCLE", "WITHDRAW", "ASTONISH", "GROWTH", "SWEETSCENT" },
      learnset = { { level = 4, move = "CURSE" }, { level = 8, move = "STOMP" }, { level = 12, move = "LEECH_SEED" }, { level = 16, move = "PROTECT" }, { level = 20, move = "BULLETSEED" }, { level = 24, move = "RECOVER" }, { level = 28, move = "APPLEACID" }, { level = 32, move = "BODY_SLAM" }, { level = 36, move = "IRONDEFENSE" }, { level = 40, move = "DRAGONPULSE" }, { level = 44, move = "ENERGYBALL" } },
    },
    SILICOBRA = {
      level1Moves = { "WRAP", "SAND_ATTACK" },
      learnset = { { level = 5, move = "MINIMIZE" }, { level = 10, move = "BRUTALSWING" }, { level = 15, move = "BULLDOZE" }, { level = 20, move = "HEADBUTT" }, { level = 25, move = "GLARE" }, { level = 30, move = "DIG" }, { level = 35, move = "SANDSTORM" }, { level = 40, move = "SLAM" }, { level = 45, move = "COIL" }, { level = 50, move = "SANDTOMB" } },
    },
    SANDACONDA = {
      level1Moves = { "SKULL_BASH", "WRAP", "SAND_ATTACK", "MINIMIZE", "BRUTALSWING" },
      learnset = { { level = 15, move = "BULLDOZE" }, { level = 20, move = "HEADBUTT" }, { level = 25, move = "GLARE" }, { level = 30, move = "DIG" }, { level = 35, move = "SANDSTORM" }, { level = 42, move = "SLAM" }, { level = 49, move = "COIL" }, { level = 51, move = "SANDTOMB" } },
    },
    TOXEL = {
      level1Moves = { "BELCH", "TEARFULLOOK", "NUZZLE", "GROWL", "FLAIL", "ACID" },
      learnset = {  },
    },
    TOXTRICITY = {
      level1Moves = { "SPARK", "EERIEIMPULSE", "BELCH", "TEARFULLOOK", "NUZZLE", "GROWL", "FLAIL", "ACID", "THUNDER_SHOCK", "ACIDSPRAY", "LEER", "NOBLEROAR" },
      learnset = { { level = 4, move = "CHARGE" }, { level = 8, move = "SHOCKWAVE" }, { level = 12, move = "SCARYFACE" }, { level = 16, move = "TAUNT" }, { level = 20, move = "VENOSHOCK" }, { level = 24, move = "SCREECH" }, { level = 28, move = "SWAGGER" }, { level = 32, move = "TOXIC" }, { level = 36, move = "DISCHARGE" }, { level = 40, move = "POISONJAB" }, { level = 44, move = "OVERDRIVE" }, { level = 48, move = "BOOMBURST" }, { level = 52, move = "SHIFTGEAR" } },
    },
    SIZZLIPEDE = {
      level1Moves = { "EMBER", "SMOKESCREEN" },
      learnset = { { level = 5, move = "WRAP" }, { level = 10, move = "BITE" }, { level = 15, move = "FLAMEWHEEL" }, { level = 20, move = "BUGBITE" }, { level = 25, move = "COIL" }, { level = 30, move = "SLAM" }, { level = 35, move = "FIRE_SPIN" }, { level = 40, move = "CRUNCH" }, { level = 45, move = "FIRELASH" }, { level = 50, move = "LUNGE" }, { level = 55, move = "BURNUP" } },
    },
    CENTISKORCH = {
      level1Moves = { "INFERNO", "EMBER", "SMOKESCREEN", "WRAP", "BITE" },
      learnset = { { level = 15, move = "FLAMEWHEEL" }, { level = 20, move = "BUGBITE" }, { level = 25, move = "COIL" }, { level = 32, move = "SLAM" }, { level = 39, move = "FIRE_SPIN" }, { level = 46, move = "CRUNCH" }, { level = 53, move = "FIRELASH" }, { level = 60, move = "LUNGE" }, { level = 67, move = "BURNUP" } },
    },
    HATENNA = {
      level1Moves = { "CONFUSION", "PLAYNICE" },
      learnset = { { level = 5, move = "LIFEDEW" }, { level = 10, move = "DISARMINGVOICE" }, { level = 15, move = "AROMATHERAPY" }, { level = 15, move = "AROMATICMIST" }, { level = 20, move = "PSYBEAM" }, { level = 25, move = "HEALPULSE" }, { level = 30, move = "DAZZLINGGLEAM" }, { level = 35, move = "CALMMIND" }, { level = 40, move = "PSYCHIC_M" }, { level = 45, move = "HEALINGWISH" } },
    },
    HATTREM = {
      level1Moves = { "BRUTALSWING", "CONFUSION", "PLAYNICE", "LIFEDEW", "DISARMINGVOICE" },
      learnset = { { level = 15, move = "AROMATHERAPY" }, { level = 15, move = "AROMATICMIST" }, { level = 20, move = "PSYBEAM" }, { level = 25, move = "HEALPULSE" }, { level = 30, move = "DAZZLINGGLEAM" }, { level = 37, move = "CALMMIND" }, { level = 44, move = "PSYCHIC_M" }, { level = 51, move = "HEALINGWISH" } },
    },
    HATTERENE = {
      level1Moves = { "PSYCHOCUT", "BRUTALSWING", "CONFUSION", "PLAYNICE", "LIFEDEW", "DISARMINGVOICE" },
      learnset = { { level = 15, move = "AROMATHERAPY" }, { level = 15, move = "AROMATICMIST" }, { level = 20, move = "PSYBEAM" }, { level = 25, move = "HEALPULSE" }, { level = 30, move = "DAZZLINGGLEAM" }, { level = 37, move = "CALMMIND" }, { level = 46, move = "PSYCHIC_M" }, { level = 55, move = "HEALINGWISH" }, { level = 64, move = "MAGICPOWDER" } },
    },
    IMPIDIMP = {
      level1Moves = { "FAKEOUT", "CONFIDE" },
      learnset = { { level = 4, move = "BITE" }, { level = 8, move = "FLATTER" }, { level = 12, move = "FAKETEARS" }, { level = 16, move = "ASSURANCE" }, { level = 20, move = "SWAGGER" }, { level = 24, move = "SUCKERPUNCH" }, { level = 28, move = "TORMENT" }, { level = 33, move = "DARKPULSE" }, { level = 36, move = "NASTYPLOT" }, { level = 40, move = "PLAYROUGH" }, { level = 44, move = "FOULPLAY" } },
    },
    MORGREM = {
      level1Moves = { "FALSESURRENDER", "FAKEOUT", "CONFIDE", "BITE", "FLATTER" },
      learnset = { { level = 12, move = "FAKETEARS" }, { level = 16, move = "ASSURANCE" }, { level = 20, move = "SWAGGER" }, { level = 24, move = "SUCKERPUNCH" }, { level = 28, move = "TORMENT" }, { level = 35, move = "DARKPULSE" }, { level = 40, move = "NASTYPLOT" }, { level = 46, move = "PLAYROUGH" }, { level = 52, move = "FOULPLAY" } },
    },
    GRIMMSNARL = {
      level1Moves = { "SPIRITBREAK", "FALSESURRENDER", "BULKUP", "POWERUPPUNCH", "FAKEOUT", "CONFIDE", "BITE", "FLATTER" },
      learnset = { { level = 12, move = "FAKETEARS" }, { level = 16, move = "ASSURANCE" }, { level = 20, move = "SWAGGER" }, { level = 24, move = "SUCKERPUNCH" }, { level = 28, move = "TORMENT" }, { level = 35, move = "DARKPULSE" }, { level = 40, move = "NASTYPLOT" }, { level = 48, move = "PLAYROUGH" }, { level = 56, move = "FOULPLAY" }, { level = 64, move = "HAMMERARM" } },
    },
    MILCERY = {
      level1Moves = { "TACKLE", "AROMATICMIST" },
      learnset = { { level = 5, move = "SWEETKISS" }, { level = 10, move = "SWEETSCENT" }, { level = 15, move = "DRAININGKISS" }, { level = 20, move = "AROMATHERAPY" }, { level = 20, move = "CHARM" }, { level = 25, move = "ATTRACT" }, { level = 30, move = "ACID_ARMOR" }, { level = 35, move = "DAZZLINGGLEAM" }, { level = 40, move = "RECOVER" }, { level = 45, move = "MISTYTERRAIN" }, { level = 50, move = "ENTRAINMENT" } },
    },
    ALCREMIE = {
      level1Moves = { "DECORATE", "TACKLE", "AROMATICMIST", "SWEETKISS", "SWEETSCENT" },
      learnset = { { level = 15, move = "DRAININGKISS" }, { level = 20, move = "AROMATHERAPY" }, { level = 20, move = "CHARM" }, { level = 25, move = "ATTRACT" }, { level = 30, move = "ACID_ARMOR" }, { level = 35, move = "DAZZLINGGLEAM" }, { level = 40, move = "RECOVER" }, { level = 45, move = "MISTYTERRAIN" }, { level = 50, move = "ENTRAINMENT" } },
    },
    CUFANT = {
      level1Moves = { "TACKLE", "GROWL" },
      learnset = { { level = 5, move = "ROLLOUT" }, { level = 10, move = "ROCKSMASH" }, { level = 15, move = "BULLDOZE" }, { level = 20, move = "STOMP" }, { level = 25, move = "IRONDEFENSE" }, { level = 30, move = "DIG" }, { level = 35, move = "STRENGTH" }, { level = 40, move = "IRONHEAD" }, { level = 45, move = "PLAYROUGH" }, { level = 50, move = "HIGHHORSEPOWER" }, { level = 55, move = "SUPERPOWER" } },
    },
    COPPERAJAH = {
      level1Moves = { "HEAVYSLAM", "TACKLE", "GROWL", "ROLLOUT", "ROCKSMASH" },
      learnset = { { level = 15, move = "BULLDOZE" }, { level = 20, move = "STOMP" }, { level = 25, move = "IRONDEFENSE" }, { level = 30, move = "DIG" }, { level = 37, move = "STRENGTH" }, { level = 44, move = "IRONHEAD" }, { level = 51, move = "PLAYROUGH" }, { level = 58, move = "HIGHHORSEPOWER" }, { level = 65, move = "SUPERPOWER" } },
    },
    DURALUDON = {
      level1Moves = { "METALCLAW", "LEER" },
      learnset = { { level = 6, move = "ROCKSMASH" }, { level = 12, move = "HONECLAWS" }, { level = 18, move = "METALSOUND" }, { level = 24, move = "BREAKINGSWIPE" }, { level = 30, move = "DRAGONTAIL" }, { level = 36, move = "IRONDEFENSE" }, { level = 42, move = "LASERFOCUS" }, { level = 42, move = "FOCUS_ENERGY" }, { level = 48, move = "DRAGONCLAW" }, { level = 54, move = "FLASHCANNON" }, { level = 60, move = "METALBURST" }, { level = 66, move = "HYPER_BEAM" } },
    },
    ETERNATUS = {
      level1Moves = { "POISONTAIL", "CONFUSE_RAY", "DRAGONTAIL", "AGILITY" },
      learnset = { { level = 8, move = "TOXIC" }, { level = 16, move = "VENOSHOCK" }, { level = 24, move = "DRAGONDANCE" }, { level = 32, move = "CROSSPOISON" }, { level = 40, move = "DRAGONPULSE" }, { level = 48, move = "FLAMETHROWER" }, { level = 56, move = "DYNAMAXCANNON" }, { level = 64, move = "COSMICPOWER" }, { level = 72, move = "RECOVER" }, { level = 80, move = "HYPER_BEAM" }, { level = 88, move = "ETERNABEAM" }, { level = 88, move = "OUTRAGE" } },
    },
    KUBFU = {
      level1Moves = { "ROCKSMASH", "LEER" },
      learnset = { { level = 4, move = "ENDURE" }, { level = 8, move = "FOCUS_ENERGY" }, { level = 12, move = "AERIALACE" }, { level = 16, move = "SCARYFACE" }, { level = 20, move = "HEADBUTT" }, { level = 24, move = "BRICKBREAK" }, { level = 28, move = "DETECT" }, { level = 32, move = "BULKUP" }, { level = 36, move = "IRONHEAD" }, { level = 40, move = "DYNAMICPUNCH" }, { level = 44, move = "COUNTER" }, { level = 48, move = "CLOSECOMBAT" }, { level = 52, move = "FOCUSPUNCH" } },
    },
    URSHIFU = {
      level1Moves = { "WICKEDBLOW", "SUCKERPUNCH", "ROCKSMASH", "LEER", "ENDURE", "FOCUS_ENERGY" },
      learnset = { { level = 12, move = "AERIALACE" }, { level = 16, move = "SCARYFACE" }, { level = 20, move = "HEADBUTT" }, { level = 24, move = "BRICKBREAK" }, { level = 28, move = "DETECT" }, { level = 32, move = "BULKUP" }, { level = 36, move = "IRONHEAD" }, { level = 40, move = "DYNAMICPUNCH" }, { level = 44, move = "COUNTER" }, { level = 48, move = "CLOSECOMBAT" }, { level = 52, move = "FOCUSPUNCH" } },
    },
    GOSSIFLEUR = {
      level1Moves = { "LEAFAGE", "SING" },
      learnset = { { level = 4, move = "RAPIDSPIN" }, { level = 8, move = "SWEETSCENT" }, { level = 12, move = "RAZOR_LEAF" }, { level = 16, move = "ROUND" }, { level = 21, move = "LEAFTORNADO" }, { level = 24, move = "SYNTHESIS" }, { level = 28, move = "HYPERVOICE" }, { level = 32, move = "AROMATHERAPY" }, { level = 36, move = "LEAFSTORM" } },
    },
    ELDEGOSS = {
      level1Moves = { "COTTONSPORE", "LEAFAGE", "SING", "RAPIDSPIN", "SWEETSCENT" },
      learnset = { { level = 12, move = "RAZOR_LEAF" }, { level = 16, move = "ROUND" }, { level = 23, move = "LEAFTORNADO" }, { level = 28, move = "SYNTHESIS" }, { level = 34, move = "HYPERVOICE" }, { level = 40, move = "AROMATHERAPY" }, { level = 46, move = "LEAFSTORM" }, { level = 52, move = "COTTONGUARD" } },
    },
}
