-- Phase 2 -- the 174 moves needed by the 51 Phase-1 species' learnsets that
-- do NOT already exist as a Gen 1-native move (see NATIVE_MOVE_ID in
-- main.lua for the other 68, which need no entry here at all -- their full
-- effect, including any status/stat-stage secondary effect, is already
-- built into the base engine).
--
-- Source: Pokemon_Stats/moves.txt. name/type/category/power/accuracy/pp
-- are copied directly (category lowercased; PBS's "Accuracy = 0", its
-- convention for "bypasses the accuracy check", is approximated as 100 --
-- there's no confirmed "always hits" flag on this engine to reach for
-- instead, and literal 0 would make the move always MISS, the opposite of
-- intended). priority is only set where moves.txt has a nonzero one.
-- highCrit=true where moves.txt's Flags contains HighCriticalHitRate
-- (confirmed field, see AEROBLAST in kanto-ascendant's johto.lua).
--
-- `effect` and `functionCode` are the actual Phase 2 triage result:
--   functionCode is moves.txt's original FunctionCode, kept on every
--   entry (not passed to mod.content.moves:register -- main.lua filters
--   it out) purely so a future pass can grep for what's still stubbed.
--   effect is what actually got implemented:
--     - "NO_ADDITIONAL_EFFECT" + functionCode "None": the move never had a
--       secondary effect. Fully replicated (17 moves).
--     - "GALAR_FLINCH_EFFECT_<chance>" / "GALAR_CONFUSE_EFFECT_<chance>" /
--       "GALAR_TRAP_EFFECT": custom effects main.lua registers (one
--       per distinct chance value actually needed, since there is no
--       confirmed way for an effect's run() to read its own move's
--       EffectChance back out -- see main.lua's installMovepoolEffects).
--       Built on confirmed real battler fields (flinched, confusedTurns,
--       trappingTurns/boundTurns -- all seen in Dynamax's own
--       clearDynamaxVolatiles). Approximated: trap/confusion duration
--       values are reasonable, not confirmed exact (8 moves).
--     - multiHit: the engine's own real multi-hit field, confirmed against
--       actual engine source (src/battle/EffectRegistry.lua hitCount()):
--       a plain integer is a fixed count, a list is a distribution picked
--       from BY INDEX with a uniform roll -- NOT a [min,max] range. Fixed
--       2-hit moves use {2,2}; 2-5-hit moves use the engine's own
--       confirmed classic distribution {2,2,2,3,3,3,4,5} (3/8 chance of
--       2, 3/8 of 3, 1/8 of 4, 1/8 of 5 -- an earlier version of this file
--       wrongly used {2,5}, a 50/50 exactly-2-or-exactly-5 pick, before
--       engine source was available to check against). Fully replicated
--       (4 moves; DOUBLEIRONBASH also has a dropped flinch chance on top
--       of its multiHit, noted below).
--     - "NO_ADDITIONAL_EFFECT" on any other functionCode: STUBBED. The
--       move deals its damage (or, for 0-power status moves, does
--       nothing at all beyond the message) with its real secondary effect
--       NOT implemented. This is the large majority (145 moves) --
--       status infliction (paralyze/burn/poison/sleep), stat-stage
--       changes, weather/terrain, recoil, drain, protect, two-turn
--       charge moves, priority-conditional moves, item interactions, and
--       more all fall here, because this engine's real primitives for
--       them were not found anywhere in either reference mod (only
--       flinch, confusion, binding, and multi-hit had confirmed
--       evidence). Not a guess dressed up as working: every stubbed
--       move's functionCode says exactly what is missing.
return {
  ACIDSPRAY = { name = "Acid Spray", type = "POISON", category = "special", power = 40, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_ACIDSPRAY_EFFECT", functionCode = "LowerTargetSpDef2" },
  ACROBATICS = { name = "Acrobatics", type = "FLYING", category = "physical", power = 55, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "DoublePowerIfUserHasNoItem" },
  AERIALACE = { name = "Aerial Ace", type = "FLYING", category = "physical", power = 60, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  AFTERYOU = { name = "After You", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "TargetActsNext" },
  ALLYSWITCH = { name = "Ally Switch", type = "PSYCHIC", category = "status", power = 0, accuracy = 100, pp = 15, priority = 2, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "UserSwapsPositionsWithAlly" },
  ANCIENTPOWER = { name = "Ancient Power", type = "ROCK", category = "special", power = 60, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "GMAX_ANCIENTPOWER_EFFECT", functionCode = "RaiseUserMainStats1" },
  APPLEACID = { name = "Apple Acid", type = "GRASS", category = "special", power = 80, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GMAX_APPLEACID_EFFECT", functionCode = "LowerTargetSpDef1" },
  AROMATHERAPY = { name = "Aromatherapy", type = "GRASS", category = "status", power = 0, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "CureUserPartyStatus" },
  AROMATICMIST = { name = "Aromatic Mist", type = "FAIRY", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_AROMATICMIST_EFFECT", functionCode = "RaiseTargetSpDef1" },
  ASSURANCE = { name = "Assurance", type = "DARK", category = "physical", power = 60, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "DoublePowerIfTargetLostHPThisTurn" },
  ASTONISH = { name = "Astonish", type = "GHOST", category = "physical", power = 30, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GALAR_FLINCH_EFFECT_30", functionCode = "FlinchTarget" },
  ATTRACT = { name = "Attract", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_ATTRACT_EFFECT", functionCode = "AttractTarget" },
  BELCH = { name = "Belch", type = "POISON", category = "special", power = 120, accuracy = 90, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "FailsIfUserNotConsumedBerry" },
  BELLYDRUM = { name = "Belly Drum", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "MaxUserAttackLoseHalfOfTotalHP" },
  -- Phase 4 (weather): power/accuracy/type/pp already real (national_dex),
  -- unchanged here -- only effect is new, giving Blizzard's Snow accuracy
  -- exception (combat/modern_weather.lua's battle.accuracy hook, keyed off
  -- move.id directly, not this effect id) a real registration to point at
  -- so isMoveDataComplete stops treating it as stubbed. The 10% freeze
  -- secondary is real Showdown too but explicitly NOT wired this phase
  -- (out of the requested scope) -- GALAR_BLIZZARD_EFFECT is deliberately
  -- an empty kind="full" record (see modern_weather.lua) so it doesn't
  -- eat Blizzard's own damage on Gen 2 the way a kind="secondary"+run
  -- record would.
  BLIZZARD = { name = "Blizzard", type = "ICE", category = "special", power = 110, accuracy = 70, pp = 5, priority = 0, highCrit = false, effect = "GALAR_BLIZZARD_EFFECT", functionCode = "FreezeTarget" },
  BOOMBURST = { name = "Boomburst", type = "NORMAL", category = "special", power = 140, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  BOUNCE = { name = "Bounce", type = "FLYING", category = "physical", power = 85, accuracy = 85, pp = 5, priority = 0, highCrit = false, effect = "GALAR_BOUNCE_EFFECT", functionCode = "TwoTurnAttackInvulnerableInSkyParalyzeTarget" },
  BRANCHPOKE = { name = "Branch Poke", type = "GRASS", category = "physical", power = 40, accuracy = 100, pp = 40, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  BRAVEBIRD = { name = "Brave Bird", type = "FLYING", category = "physical", power = 120, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GALAR_RECOIL_EFFECT_3", functionCode = "RecoilThirdOfDamageDealt" },
  BREAKINGSWIPE = { name = "Breaking Swipe", type = "DRAGON", category = "physical", power = 60, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_BREAKINGSWIPE_EFFECT", functionCode = "LowerTargetAttack1" },
  BRICKBREAK = { name = "Brick Break", type = "FIGHTING", category = "physical", power = 75, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "RemoveScreens" },
  BRUTALSWING = { name = "Brutal Swing", type = "DARK", category = "physical", power = 60, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  BUGBITE = { name = "Bug Bite", type = "BUG", category = "physical", power = 60, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "UserConsumeTargetBerry" },
  BUGBUZZ = { name = "Bug Buzz", type = "BUG", category = "special", power = 90, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GMAX_BUGBUZZ_EFFECT", functionCode = "LowerTargetSpDef1" },
  BULKUP = { name = "Bulk Up", type = "FIGHTING", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_BULKUP_EFFECT", functionCode = "RaiseUserAtkDef1" },
  BULLDOZE = { name = "Bulldoze", type = "GROUND", category = "physical", power = 60, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_BULLDOZE_EFFECT", functionCode = "LowerTargetSpeed1WeakerInGrassyTerrain" },
  BULLETSEED = { name = "Bullet Seed", type = "GRASS", category = "physical", power = 25, accuracy = 100, pp = 30, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", multiHit = {2,2,2,3,3,3,4,5}, functionCode = "HitTwoToFiveTimes" },
  BURNUP = { name = "Burn Up", type = "FIRE", category = "special", power = 130, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "UserLosesFireType" },
  CALMMIND = { name = "Calm Mind", type = "PSYCHIC", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_CALMMIND_EFFECT", functionCode = "RaiseUserSpAtkSpDef1" },
  CHARGE = { name = "Charge", type = "ELECTRIC", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_CHARGE_EFFECT", functionCode = "RaiseUserSpDef1PowerUpElectricMove" },
  CHARM = { name = "Charm", type = "FAIRY", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_CHARM_EFFECT", functionCode = "LowerTargetAttack2" },
  CLEARSMOG = { name = "Clear Smog", type = "POISON", category = "special", power = 50, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_CLEARSMOG_EFFECT", functionCode = "ResetTargetStatStages" },
  CLOSECOMBAT = { name = "Close Combat", type = "FIGHTING", category = "physical", power = 120, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "GMAX_CLOSECOMBAT_EFFECT", functionCode = "LowerUserDefSpDef1" },
  COIL = { name = "Coil", type = "POISON", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_COIL_EFFECT", functionCode = "RaiseUserAtkDefAcc1" },
  CONFIDE = { name = "Confide", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_CONFIDE_EFFECT", functionCode = "LowerTargetSpAtk1" },
  COSMICPOWER = { name = "Cosmic Power", type = "PSYCHIC", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_COSMICPOWER_EFFECT", functionCode = "RaiseUserDefSpDef1" },
  COTTONGUARD = { name = "Cotton Guard", type = "GRASS", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GMAX_COTTONGUARD_EFFECT", functionCode = "RaiseUserDefense3" },
  COTTONSPORE = { name = "Cotton Spore", type = "GRASS", category = "status", power = 0, accuracy = 100, pp = 40, priority = 0, highCrit = false, effect = "GMAX_COTTONSPORE_EFFECT", functionCode = "LowerTargetSpeed2" },
  COURTCHANGE = { name = "Court Change", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "SwapSideEffects" },
  COVET = { name = "Covet", type = "NORMAL", category = "physical", power = 60, accuracy = 100, pp = 25, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "UserTakesTargetItem" },
  CROSSPOISON = { name = "Cross Poison", type = "POISON", category = "physical", power = 70, accuracy = 100, pp = 20, priority = 0, highCrit = true, effect = "GALAR_POISON_EFFECT_10", functionCode = "PoisonTarget" },
  CRUNCH = { name = "Crunch", type = "DARK", category = "physical", power = 80, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_CRUNCH_EFFECT", functionCode = "LowerTargetDefense1" },
  CURSE = { name = "Curse", type = "GHOST", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1" },
  DARKPULSE = { name = "Dark Pulse", type = "DARK", category = "special", power = 80, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GALAR_FLINCH_EFFECT_20", functionCode = "FlinchTarget" },
  DAZZLINGGLEAM = { name = "Dazzling Gleam", type = "FAIRY", category = "special", power = 80, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  DECORATE = { name = "Decorate", type = "FAIRY", category = "status", power = 0, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_DECORATE_EFFECT", functionCode = "RaiseTargetAtkSpAtk2" },
  DETECT = { name = "Detect", type = "FIGHTING", category = "status", power = 0, accuracy = 100, pp = 5, priority = 4, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "ProtectUser" },
  DISARMINGVOICE = { name = "Disarming Voice", type = "FAIRY", category = "special", power = 40, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  DISCHARGE = { name = "Discharge", type = "ELECTRIC", category = "special", power = 80, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GALAR_PARALYZE_EFFECT_30", functionCode = "ParalyzeTarget" },
  DOUBLEHIT = { name = "Double Hit", type = "NORMAL", category = "physical", power = 35, accuracy = 90, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", multiHit = {2,2}, functionCode = "HitTwoTimes" },
  DOUBLEIRONBASH = { name = "Double Iron Bash", type = "STEEL", category = "physical", power = 60, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", multiHit = {2,2}, functionCode = "HitTwoTimesFlinchTarget" },
  DRAGONBREATH = { name = "Dragon Breath", type = "DRAGON", category = "special", power = 60, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GALAR_PARALYZE_EFFECT_30", functionCode = "ParalyzeTarget" },
  DRAGONCLAW = { name = "Dragon Claw", type = "DRAGON", category = "physical", power = 80, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  DRAGONDANCE = { name = "Dragon Dance", type = "DRAGON", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_DRAGONDANCE_EFFECT", functionCode = "RaiseUserAtkSpd1" },
  DRAGONPULSE = { name = "Dragon Pulse", type = "DRAGON", category = "special", power = 85, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  DRAGONRUSH = { name = "Dragon Rush", type = "DRAGON", category = "physical", power = 100, accuracy = 75, pp = 10, priority = 0, highCrit = false, effect = "GALAR_FLINCH_EFFECT_20", functionCode = "FlinchTarget" },
  DRAGONTAIL = { name = "Dragon Tail", type = "DRAGON", category = "physical", power = 60, accuracy = 90, pp = 10, priority = -6, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "SwitchOutTargetDamagingMove" },
  DRAININGKISS = { name = "Draining Kiss", type = "FAIRY", category = "special", power = 50, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GALAR_DRAIN_EFFECT_75", functionCode = "HealUserByThreeQuartersOfDamageDone" },
  DRUMBEATING = { name = "Drum Beating", type = "GRASS", category = "physical", power = 80, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GMAX_DRUMBEATING_EFFECT", functionCode = "LowerTargetSpeed1" },
  DYNAMAXCANNON = { name = "Dynamax Cannon", type = "DRAGON", category = "special", power = 100, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  DYNAMICPUNCH = { name = "Dynamic Punch", type = "FIGHTING", category = "physical", power = 100, accuracy = 50, pp = 5, priority = 0, highCrit = false, effect = "GALAR_CONFUSE_EFFECT_100", functionCode = "ConfuseTarget" },
  EERIEIMPULSE = { name = "Eerie Impulse", type = "ELECTRIC", category = "status", power = 0, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_EERIEIMPULSE_EFFECT", functionCode = "LowerTargetSpAtk2" },
  ENCORE = { name = "Encore", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "EFFECT_ENCORE", functionCode = "ForceRepeatLastMove" },
  ENDEAVOR = { name = "Endeavor", type = "NORMAL", category = "physical", power = 1, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "LowerTargetHPToUserHP" },
  ENDURE = { name = "Endure", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 10, priority = 4, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "UserEnduresFaintingThisTurn" },
  ENERGYBALL = { name = "Energy Ball", type = "GRASS", category = "special", power = 90, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GMAX_ENERGYBALL_EFFECT", functionCode = "LowerTargetSpDef1" },
  ENTRAINMENT = { name = "Entrainment", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "SetTargetAbilityToUserAbility" },
  ETERNABEAM = { name = "Eternabeam", type = "DRAGON", category = "special", power = 160, accuracy = 90, pp = 5, priority = 0, highCrit = false, effect = "GALAR_ETERNABEAM_EFFECT", functionCode = "AttackAndSkipNextTurn" },
  FAKEOUT = { name = "Fake Out", type = "NORMAL", category = "physical", power = 40, accuracy = 100, pp = 10, priority = 3, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "FlinchTargetFailsIfNotUserFirstTurn" },
  FAKETEARS = { name = "Fake Tears", type = "DARK", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_FAKETEARS_EFFECT", functionCode = "LowerTargetSpDef2" },
  FALSESURRENDER = { name = "False Surrender", type = "DARK", category = "physical", power = 80, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  -- bypassesProtect: Feint's whole real effect is hitting straight through
  -- Protect/Detect -- a plain data flag modern_combat_protect.lua's own
  -- battle.damage hook already reads (`not (ctx.move and
  -- ctx.move.bypassesProtect)`, that file's Part B), not a move_effects
  -- registration; Feint otherwise deals ordinary 30-power damage with no
  -- other secondary effect. See main.lua's isMoveDataComplete for why
  -- functionCode "RemoveProtections" is treated as complete here, the same
  -- way "None" already is.
  FEINT = { name = "Feint", type = "NORMAL", category = "physical", power = 30, accuracy = 100, pp = 10, priority = 2, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "RemoveProtections", bypassesProtect = true },
  FIRELASH = { name = "Fire Lash", type = "FIRE", category = "physical", power = 80, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_FIRELASH_EFFECT", functionCode = "LowerTargetDefense1" },
  FLAIL = { name = "Flail", type = "NORMAL", category = "physical", power = 1, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "PowerLowerWithUserHP" },
  FLAMECHARGE = { name = "Flame Charge", type = "FIRE", category = "physical", power = 50, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_FLAMECHARGE_EFFECT", functionCode = "RaiseUserSpeed1" },
  FLAMEWHEEL = { name = "Flame Wheel", type = "FIRE", category = "physical", power = 60, accuracy = 100, pp = 25, priority = 0, highCrit = false, effect = "GALAR_BURN_EFFECT_10", functionCode = "BurnTarget" },
  FLASHCANNON = { name = "Flash Cannon", type = "STEEL", category = "special", power = 80, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GMAX_FLASHCANNON_EFFECT", functionCode = "LowerTargetSpDef1" },
  FLATTER = { name = "Flatter", type = "DARK", category = "status", power = 0, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_FLATTER_EFFECT", functionCode = "RaiseTargetSpAtk1ConfuseTarget" },
  FLING = { name = "Fling", type = "DARK", category = "physical", power = 1, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "ThrowUserItemAtTarget" },
  FOCUSPUNCH = { name = "Focus Punch", type = "FIGHTING", category = "physical", power = 150, accuracy = 100, pp = 20, priority = -3, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "FailsIfUserDamagedThisTurn" },
  FOULPLAY = { name = "Foul Play", type = "DARK", category = "physical", power = 95, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "UseTargetAttackInsteadOfUserAttack" },
  GRASSYTERRAIN = { name = "Grassy Terrain", type = "GRASS", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "StartGrassyTerrain" },
  GRAVAPPLE = { name = "Grav Apple", type = "GRASS", category = "physical", power = 80, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GMAX_GRAVAPPLE_EFFECT", functionCode = "LowerTargetDefense1PowersUpInGravity" },
  GUNKSHOT = { name = "Gunk Shot", type = "POISON", category = "physical", power = 120, accuracy = 80, pp = 5, priority = 0, highCrit = false, effect = "GALAR_POISON_EFFECT_30", functionCode = "PoisonTarget" },
  HAMMERARM = { name = "Hammer Arm", type = "FIGHTING", category = "physical", power = 100, accuracy = 90, pp = 10, priority = 0, highCrit = false, effect = "GMAX_HAMMERARM_EFFECT", functionCode = "LowerUserSpeed1" },
  HEADSMASH = { name = "Head Smash", type = "ROCK", category = "physical", power = 150, accuracy = 80, pp = 5, priority = 0, highCrit = false, effect = "GALAR_RECOIL_EFFECT_2", functionCode = "RecoilHalfOfDamageDealt" },
  HEALINGWISH = { name = "Healing Wish", type = "PSYCHIC", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "UserFaintsHealAndCureReplacement" },
  HEALPULSE = { name = "Heal Pulse", type = "PSYCHIC", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GALAR_HEALPULSE_EFFECT", functionCode = "HealTargetHalfOfTotalHP" },
  HEATCRASH = { name = "Heat Crash", type = "FIRE", category = "physical", power = 1, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "PowerHigherWithUserHeavierThanTarget" },
  HEAVYSLAM = { name = "Heavy Slam", type = "STEEL", category = "physical", power = 1, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "PowerHigherWithUserHeavierThanTarget" },
  HIGHHORSEPOWER = { name = "High Horsepower", type = "GROUND", category = "physical", power = 95, accuracy = 95, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  HONECLAWS = { name = "Hone Claws", type = "DARK", category = "status", power = 0, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_HONECLAWS_EFFECT", functionCode = "RaiseUserAtkAcc1" },
  HYPERVOICE = { name = "Hyper Voice", type = "NORMAL", category = "special", power = 90, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  INCINERATE = { name = "Incinerate", type = "FIRE", category = "special", power = 60, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "DestroyTargetBerryOrGem" },
  INFERNO = { name = "Inferno", type = "FIRE", category = "special", power = 100, accuracy = 50, pp = 5, priority = 0, highCrit = false, effect = "GALAR_BURN_EFFECT_100", functionCode = "BurnTarget" },
  IRONDEFENSE = { name = "Iron Defense", type = "STEEL", category = "status", power = 0, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_IRONDEFENSE_EFFECT", functionCode = "RaiseUserDefense2" },
  IRONHEAD = { name = "Iron Head", type = "STEEL", category = "physical", power = 80, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GALAR_FLINCH_EFFECT_30", functionCode = "FlinchTarget" },
  JAWLOCK = { name = "Jaw Lock", type = "DARK", category = "physical", power = 80, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "TrapUserAndTargetInBattle" },
  KNOCKOFF = { name = "Knock Off", type = "DARK", category = "physical", power = 65, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "RemoveTargetItem" },
  LASERFOCUS = { name = "Laser Focus", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 30, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "EnsureNextCriticalHit" },
  LASTRESORT = { name = "Last Resort", type = "NORMAL", category = "physical", power = 140, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "FailsIfUserHasUnusedMove" },
  LEAFAGE = { name = "Leafage", type = "GRASS", category = "physical", power = 40, accuracy = 100, pp = 40, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  LEAFSTORM = { name = "Leaf Storm", type = "GRASS", category = "special", power = 130, accuracy = 90, pp = 5, priority = 0, highCrit = false, effect = "GMAX_LEAFSTORM_EFFECT", functionCode = "LowerUserSpAtk2" },
  LEAFTORNADO = { name = "Leaf Tornado", type = "GRASS", category = "special", power = 65, accuracy = 90, pp = 10, priority = 0, highCrit = false, effect = "GMAX_LEAFTORNADO_EFFECT", functionCode = "LowerTargetAccuracy1" },
  LIFEDEW = { name = "Life Dew", type = "WATER", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GALAR_LIFEDEW_EFFECT", functionCode = "HealUserAndAlliesQuarterOfTotalHP" },
  LIQUIDATION = { name = "Liquidation", type = "WATER", category = "physical", power = 85, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GMAX_LIQUIDATION_EFFECT", functionCode = "LowerTargetDefense1" },
  LUNGE = { name = "Lunge", type = "BUG", category = "physical", power = 80, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_LUNGE_EFFECT", functionCode = "LowerTargetAttack1" },
  MAGICCOAT = { name = "Magic Coat", type = "PSYCHIC", category = "status", power = 0, accuracy = 100, pp = 15, priority = 4, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "BounceBackProblemCausingStatusMoves" },
  MAGICPOWDER = { name = "Magic Powder", type = "PSYCHIC", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "SetTargetTypesToPsychic" },
  METALBURST = { name = "Metal Burst", type = "STEEL", category = "physical", power = 1, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GALAR_METALBURST_EFFECT", functionCode = "CounterDamagePlusHalf" },
  METALCLAW = { name = "Metal Claw", type = "STEEL", category = "physical", power = 50, accuracy = 95, pp = 35, priority = 0, highCrit = false, effect = "GMAX_METALCLAW_EFFECT", functionCode = "RaiseUserAttack1" },
  METALSOUND = { name = "Metal Sound", type = "STEEL", category = "status", power = 0, accuracy = 85, pp = 40, priority = 0, highCrit = false, effect = "GMAX_METALSOUND_EFFECT", functionCode = "LowerTargetSpDef2" },
  MIRRORCOAT = { name = "Mirror Coat", type = "PSYCHIC", category = "special", power = 1, accuracy = 100, pp = 20, priority = -5, highCrit = false, effect = "GALAR_MIRRORCOAT_EFFECT", functionCode = "CounterSpecialDamage" },
  MISTYTERRAIN = { name = "Misty Terrain", type = "FAIRY", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "StartMistyTerrain" },
  NASTYPLOT = { name = "Nasty Plot", type = "DARK", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_NASTYPLOT_EFFECT", functionCode = "RaiseUserSpAtk2" },
  NOBLEROAR = { name = "Noble Roar", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 30, priority = 0, highCrit = false, effect = "GMAX_NOBLEROAR_EFFECT", functionCode = "LowerTargetAtkSpAtk1" },
  NUZZLE = { name = "Nuzzle", type = "ELECTRIC", category = "physical", power = 20, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GALAR_PARALYZE_EFFECT_100", functionCode = "ParalyzeTarget" },
  OUTRAGE = { name = "Outrage", type = "DRAGON", category = "physical", power = 120, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GALAR_OUTRAGE_EFFECT", functionCode = "MultiTurnAttackConfuseUserAtEnd" },
  OVERDRIVE = { name = "Overdrive", type = "ELECTRIC", category = "special", power = 80, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  PAINSPLIT = { name = "Pain Split", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GALAR_PAINSPLIT_EFFECT", functionCode = "UserTargetAverageHP" },
  PLAYNICE = { name = "Play Nice", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_PLAYNICE_EFFECT", functionCode = "LowerTargetAttack1BypassSubstitute" },
  PLAYROUGH = { name = "Play Rough", type = "FAIRY", category = "physical", power = 90, accuracy = 90, pp = 10, priority = 0, highCrit = false, effect = "GMAX_PLAYROUGH_EFFECT", functionCode = "LowerTargetAttack1" },
  PLUCK = { name = "Pluck", type = "FLYING", category = "physical", power = 60, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "UserConsumeTargetBerry" },
  POISONJAB = { name = "Poison Jab", type = "POISON", category = "physical", power = 80, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GALAR_POISON_EFFECT_30", functionCode = "PoisonTarget" },
  POISONTAIL = { name = "Poison Tail", type = "POISON", category = "physical", power = 50, accuracy = 100, pp = 25, priority = 0, highCrit = true, effect = "GALAR_POISON_EFFECT_10", functionCode = "PoisonTarget" },
  POWERTRIP = { name = "Power Trip", type = "DARK", category = "physical", power = 1, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "PowerHigherWithUserPositiveStatStages" },
  POWERUPPUNCH = { name = "Power-Up Punch", type = "FIGHTING", category = "physical", power = 40, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_POWERUPPUNCH_EFFECT", functionCode = "RaiseUserAttack1" },
  PROTECT = { name = "Protect", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 10, priority = 4, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "ProtectUser" },
  PSYCHICTERRAIN = { name = "Psychic Terrain", type = "PSYCHIC", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "StartPsychicTerrain" },
  PSYCHOCUT = { name = "Psycho Cut", type = "PSYCHIC", category = "physical", power = 70, accuracy = 100, pp = 20, priority = 0, highCrit = true, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  PYROBALL = { name = "Pyro Ball", type = "FIRE", category = "physical", power = 120, accuracy = 90, pp = 5, priority = 0, highCrit = false, effect = "GALAR_BURN_EFFECT_10", functionCode = "BurnTarget" },
  RAINDANCE = { name = "Rain Dance", type = "WATER", category = "status", power = 0, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "GALAR_RAINDANCE_EFFECT", functionCode = "StartRainWeather" },
  RAPIDSPIN = { name = "Rapid Spin", type = "NORMAL", category = "physical", power = 50, accuracy = 100, pp = 40, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "RemoveUserBindingAndEntryHazards" },
  RAZORSHELL = { name = "Razor Shell", type = "WATER", category = "physical", power = 75, accuracy = 95, pp = 10, priority = 0, highCrit = false, effect = "GMAX_RAZORSHELL_EFFECT", functionCode = "LowerTargetDefense1" },
  RECYCLE = { name = "Recycle", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "RestoreUserConsumedItem" },
  ROCKBLAST = { name = "Rock Blast", type = "ROCK", category = "physical", power = 25, accuracy = 90, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", multiHit = {2,2,2,3,3,3,4,5}, functionCode = "HitTwoToFiveTimes" },
  ROCKPOLISH = { name = "Rock Polish", type = "ROCK", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_ROCKPOLISH_EFFECT", functionCode = "RaiseUserSpeed2" },
  ROCKSMASH = { name = "Rock Smash", type = "FIGHTING", category = "physical", power = 40, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_ROCKSMASH_EFFECT", functionCode = "LowerTargetDefense1" },
  ROCKTOMB = { name = "Rock Tomb", type = "ROCK", category = "physical", power = 60, accuracy = 95, pp = 15, priority = 0, highCrit = false, effect = "GMAX_ROCKTOMB_EFFECT", functionCode = "LowerTargetSpeed1" },
  ROLLOUT = { name = "Rollout", type = "ROCK", category = "physical", power = 30, accuracy = 90, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "MultiTurnAttackPowersUpEachTurn" },
  ROUND = { name = "Round", type = "NORMAL", category = "special", power = 60, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "UsedAfterAllyRoundWithDoublePower" },
  SANDSTORM = { name = "Sandstorm", type = "ROCK", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GALAR_SANDSTORM_EFFECT", functionCode = "StartSandstormWeather" },
  SANDTOMB = { name = "Sand Tomb", type = "GROUND", category = "physical", power = 35, accuracy = 85, pp = 15, priority = 0, highCrit = false, effect = "GALAR_TRAP_EFFECT", functionCode = "BindTarget" },
  SCARYFACE = { name = "Scary Face", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GMAX_SCARYFACE_EFFECT", functionCode = "LowerTargetSpeed2" },
  SHIFTGEAR = { name = "Shift Gear", type = "STEEL", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GMAX_SHIFTGEAR_EFFECT", functionCode = "RaiseUserAtk1Spd2" },
  SHOCKWAVE = { name = "Shock Wave", type = "ELECTRIC", category = "special", power = 60, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  SLUDGEBOMB = { name = "Sludge Bomb", type = "POISON", category = "special", power = 90, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GALAR_POISON_EFFECT_30", functionCode = "PoisonTarget" },
  SMACKDOWN = { name = "Smack Down", type = "ROCK", category = "physical", power = 50, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "HitsTargetInSkyGroundsTarget" },
  SNIPESHOT = { name = "Snipe Shot", type = "WATER", category = "special", power = 80, accuracy = 100, pp = 15, priority = 0, highCrit = true, effect = "NO_ADDITIONAL_EFFECT", functionCode = "CannotBeRedirected" },
  -- Phase 4 (weather): Gen 9's real replacement for Hail (out of scope
  -- this project, see combat/modern_weather.lua's header) -- same PP/
  -- accuracy/category shape Hail had, only the type differs (Ice, same
  -- as Hail). Not previously registered anywhere (national_dex or
  -- otherwise) -- a fresh entry, not an override.
  SNOWSCAPE = { name = "Snowscape", type = "ICE", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GALAR_SNOWSCAPE_EFFECT", functionCode = "StartSnowWeather" },
  SOAK = { name = "Soak", type = "WATER", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "SetTargetTypesToWater" },
  -- Phase 4 (weather): power/accuracy/type/pp already real (national_dex),
  -- unchanged here -- only effect is new, giving Solar Beam's real
  -- two-turn charge (previously absent -- national_dex's own stub has no
  -- charge field at all) and its Sun skip-the-charge-turn behavior
  -- (combat/modern_weather.lua's BattleState:performMove wrap, keyed off
  -- move.id directly) a real registration to attach to.
  SOLARBEAM = { name = "Solar Beam", type = "GRASS", category = "special", power = 120, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "GALAR_SOLARBEAM_EFFECT", functionCode = "TwoTurnAttackSkipsChargeInSun" },
  SPARK = { name = "Spark", type = "ELECTRIC", category = "physical", power = 65, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GALAR_PARALYZE_EFFECT_30", functionCode = "ParalyzeTarget" },
  SPIRITBREAK = { name = "Spirit Break", type = "FAIRY", category = "physical", power = 75, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_SPIRITBREAK_EFFECT", functionCode = "LowerTargetSpAtk1" },
  STEALTHROCK = { name = "Stealth Rock", type = "ROCK", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "AddStealthRocksToFoeSide" },
  STEELWING = { name = "Steel Wing", type = "STEEL", category = "physical", power = 70, accuracy = 90, pp = 25, priority = 0, highCrit = false, effect = "GMAX_STEELWING_EFFECT", functionCode = "RaiseUserDefense1" },
  STOCKPILE = { name = "Stockpile", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "UserAddStockpileRaiseDefSpDef1" },
  STONEEDGE = { name = "Stone Edge", type = "ROCK", category = "physical", power = 100, accuracy = 80, pp = 5, priority = 0, highCrit = true, effect = "NO_ADDITIONAL_EFFECT", functionCode = "None" },
  STRUGGLEBUG = { name = "Struggle Bug", type = "BUG", category = "special", power = 50, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_STRUGGLEBUG_EFFECT", functionCode = "LowerTargetSpAtk1" },
  SUCKERPUNCH = { name = "Sucker Punch", type = "DARK", category = "physical", power = 70, accuracy = 100, pp = 5, priority = 1, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "FailsIfTargetActed" },
  -- Phase 4 (weather): real Showdown stats -- power 0 status move, PP 5,
  -- always hits (accuracy=100 here only because this file's own
  -- convention represents "always hits" as a plain 100, matching
  -- RAINDANCE/SANDSTORM above; accuracyChecked is left unset on the
  -- registered effect, same as every other self/field-targeted primary).
  SUNNYDAY = { name = "Sunny Day", type = "FIRE", category = "status", power = 0, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "GALAR_SUNNYDAY_EFFECT", functionCode = "StartSunWeather" },
  SUPERPOWER = { name = "Superpower", type = "FIGHTING", category = "physical", power = 120, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "GMAX_SUPERPOWER_EFFECT", functionCode = "LowerUserAtkDef1" },
  SWAGGER = { name = "Swagger", type = "NORMAL", category = "status", power = 0, accuracy = 85, pp = 15, priority = 0, highCrit = false, effect = "GMAX_SWAGGER_EFFECT", functionCode = "RaiseTargetAttack2ConfuseTarget" },
  SWALLOW = { name = "Swallow", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "HealUserDependingOnUserStockpile" },
  SWEETKISS = { name = "Sweet Kiss", type = "FAIRY", category = "status", power = 0, accuracy = 75, pp = 10, priority = 0, highCrit = false, effect = "GALAR_CONFUSE_EFFECT_100", functionCode = "ConfuseTarget" },
  SWEETSCENT = { name = "Sweet Scent", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_SWEETSCENT_EFFECT", functionCode = "LowerTargetEvasion2" },
  SYNTHESIS = { name = "Synthesis", type = "GRASS", category = "status", power = 0, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "GALAR_SYNTHESIS_EFFECT", functionCode = "HealUserDependingOnWeather" },
  TARSHOT = { name = "Tar Shot", type = "ROCK", category = "status", power = 0, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_TARSHOT_EFFECT", functionCode = "LowerTargetSpeed1MakeTargetWeakerToFire" },
  TAUNT = { name = "Taunt", type = "DARK", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_TAUNT_EFFECT", functionCode = "DisableTargetStatusMoves" },
  TEARFULLOOK = { name = "Tearful Look", type = "NORMAL", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GMAX_TEARFULLOOK_EFFECT", functionCode = "LowerTargetAtkSpAtk1" },
  TORMENT = { name = "Torment", type = "DARK", category = "status", power = 0, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GMAX_TORMENT_EFFECT", functionCode = "DisableTargetUsingSameMoveConsecutively" },
  TOXICSPIKES = { name = "Toxic Spikes", type = "POISON", category = "status", power = 0, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "AddToxicSpikesToFoeSide" },
  TWISTER = { name = "Twister", type = "DRAGON", category = "special", power = 40, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "FlinchTargetDoublePowerIfTargetInSky" },
  UPROAR = { name = "Uproar", type = "NORMAL", category = "special", power = 90, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "MultiTurnAttackPreventSleeping" },
  UTURN = { name = "U-turn", type = "BUG", category = "physical", power = 70, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "SwitchOutUserDamagingMove" },
  VENOSHOCK = { name = "Venoshock", type = "POISON", category = "special", power = 65, accuracy = 100, pp = 10, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "DoublePowerIfTargetPoisoned" },
  WATERPULSE = { name = "Water Pulse", type = "WATER", category = "special", power = 60, accuracy = 100, pp = 20, priority = 0, highCrit = false, effect = "GALAR_CONFUSE_EFFECT_20", functionCode = "ConfuseTarget" },
  WICKEDBLOW = { name = "Wicked Blow", type = "DARK", category = "physical", power = 75, accuracy = 100, pp = 5, priority = 0, highCrit = false, effect = "NO_ADDITIONAL_EFFECT", functionCode = "AlwaysCriticalHit" },
  WOODHAMMER = { name = "Wood Hammer", type = "GRASS", category = "physical", power = 120, accuracy = 100, pp = 15, priority = 0, highCrit = false, effect = "GALAR_RECOIL_EFFECT_3", functionCode = "RecoilThirdOfDamageDealt" },
}
