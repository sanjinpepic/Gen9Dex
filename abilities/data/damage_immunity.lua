-- Inclusion list only. Real, confirmed abilities this covers (2026-08-27
-- audit of the "other" bucket, cross-checked against real move/status
-- data before building anything):
--   STURDY -- immune to OHKO moves (real shared effect id "OHKO_EFFECT",
--     confirmed on all four: FISSURE, GUILLOTINE, HORN_DRILL, SHEERCOLD
--     -- used instead of a hardcoded id list, more robust) + survives an
--     otherwise-lethal hit at 1 HP when struck at full HP.
--   WONDERGUARD -- immune to any damaging hit that isn't super
--     effective (real final type multiplier, via combat/modern_combat
--     .lua's registerPostEffectivenessModifier -- the exact primitive
--     Phase 2's Tinted Lens/Filter family already proved out).
--   BULLETPROOF/SOUNDPROOF/WINDRIDER -- immune to moves flagged
--     bullet/sound/wind respectively (real national_dex moveFlags
--     fields, confirmed present in data/moves/generated/flags.lua).
--   TELEPATHY -- takes no damage from an ally's move (sideOf-based;
--     a genuine no-op in today's 2-battler engine, ready once a real
--     ally slot exists, same status as every other ally-scope ability
--     this project has built so far).
--   MAGICGUARD -- immune to damage/effects not directly caused by a
--     move. Scoped to what's CONFIRMED reachable this pass: status
--     residual damage (poison/burn, both engines) and Gen 1's sand
--     chip (combat/modern_weather.lua's own inline loop). NOT covered,
--     honestly flagged rather than silently skipped: Gen 2's sand chip
--     (Gen2Effects.sandstormDamage's own signature carries no mon
--     identity at all -- maxHp only -- a real, separate interception
--     point would be needed), recoil, and entry hazards. Leech Seed
--     needs no gate at all -- confirmed elsewhere in this mod (combat/
--     boss_fight_status.lua's own header) as not implemented anywhere.
--   HEATPROOF -- halves residual burn damage (does NOT block poison,
--     confirmed real: Heatproof's own effect is burn-specific).
--   SANDFORCE/SANDRUSH/SANDVEIL -- immune to Gen 1's sand chip (their
--     own real, separate stat_multiplier halves were already built,
--     Phase 4). SNOWCLOAK's own hail-chip-immunity half is NOT built
--     here -- this engine has no hail/snow chip damage mechanic at all
--     (combat/modern_weather.lua's own header: "we won't bring hail
--     yet"), so there is nothing to be immune to; a genuine non-gap.
return {
  STURDY = true, WONDERGUARD = true, BULLETPROOF = true, SOUNDPROOF = true,
  WINDRIDER = true, TELEPATHY = true, MAGICGUARD = true, HEATPROOF = true,
  SANDFORCE = true, SANDRUSH = true, SANDVEIL = true,
}
