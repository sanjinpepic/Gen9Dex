-- Inclusion list only -- status/scope/chance are all read LIVE from
-- national_dex's own abilityBehaviorOf at dispatch time, matching every
-- other abilities/data/*.lua file in this mod. Real, confirmed
-- status_immunity abilities (2026-08-27 audit of all 313 abilities'
-- expressible=true behaviour, national_dex's own data):
--   INNERFOCUS(flinch), MAGMAARMOR(freeze), LIMBER(paralysis),
--   OWNTEMPO(confusion), PURIFYINGSALT(any), SWEETVEIL(sleep),
--   VITALSPIRIT(sleep), THERMALEXCHANGE(burn), WATERVEIL(burn),
--   WATERBUBBLE(burn).
-- SWEETVEIL's own record carries scope="allies", but real Sweet Veil
-- protects the HOLDER too, not just its allies (the same discrepancy
-- the Aroma Veil/Flower Veil/Pastel Veil family shares against this
-- dataset's own scope label -- confirmed against national_dex's own
-- prose effect text, "Prevents friendly Pokémon from sleeping," which
-- doesn't exclude self) -- abilities/engine/status_immunity.lua's own
-- check always includes self regardless of scope for this reason.
-- PURIFYINGSALT and WATERBUBBLE each also carry a damage_taken_
-- multiplier effect, already wired in Phase 2
-- (abilities/engine/damage_multiplier.lua) -- this file only adds their
-- status_immunity half; nothing here duplicates that work.
return {
  INNERFOCUS = true, MAGMAARMOR = true, LIMBER = true, OWNTEMPO = true,
  PURIFYINGSALT = true, SWEETVEIL = true, VITALSPIRIT = true,
  THERMALEXCHANGE = true, WATERVEIL = true, WATERBUBBLE = true,
}
