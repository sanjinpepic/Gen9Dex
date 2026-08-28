-- Inclusion list only -- blocked move type and the reaction (heal
-- fraction or stat-change stages) are both read LIVE from national_dex's
-- own abilityBehaviorOf at hit time, matching every other abilities/
-- data/*.lua file in this mod. Real, confirmed type_immunity abilities
-- (2026-08-27 audit): DRYSKIN(water), SAPSIPPER(grass), WATERABSORB
-- (water), VOLTABSORB(electric), WELLBAKEDBODY(fire).
--
-- DRY SKIN also carries two more effects this file does NOT cover --
-- damage_self (1/8 max HP each turn during strong sunlight) and heal
-- (1/8 max HP each turn during rain) -- both real, both genuinely
-- unbuilt (no per-turn weather-tick primitive exists in this mod for
-- any ability yet; that's a later phase's own bucket, not type_immunity
-- -- honest gap, not silently dropped). Only Dry Skin's own water-
-- immunity + on-hit heal (the type_immunity-kind effect and its paired
-- "hit by a Water-type move" heal) are wired here.
return {
  DRYSKIN = true, SAPSIPPER = true, WATERABSORB = true, VOLTABSORB = true,
  WELLBAKEDBODY = true,
}
