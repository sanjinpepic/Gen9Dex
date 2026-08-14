-- Species ids GalarGmaxDex has its OWN bundled battle/overworld/party-icon
-- art for -- the 34 Gigantamax-capable species' full evolution lines (see
-- gmax_data.lua's own `order` for just the 34 that actually receive a
-- Gigantamax form; this is the larger set, including their non-native
-- pre-evolutions, since a pre-evolved Scorbunny needs custom art too, not
-- just Cinderace).
--
-- Extracted out of the old species_data.lua, which used to double as both
-- this identity list AND the species' stat/type/dex data -- that second
-- role is retired now that national_dex (optional_dependencies,
-- manifest.json) is the base-stat/type source of truth for species
-- registration (main.lua's Phase 1). This file is ONLY an id list now,
-- consumed by the sprite/scale-scoping phases (installSpriteAssetPacks,
-- installRestingScaleOverride, installOverworldSpriteProvider,
-- installBigPartyIcons, etc.) that need to know "which species get our
-- own custom art" -- a concern that has nothing to do with where a
-- species' stats/types/evolutions come from.
return {
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
}
