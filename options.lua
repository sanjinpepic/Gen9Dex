-- Mod Manager option schema for GalarGmaxDex's W1 (wild spawns) / F1
-- (follower) native engines.
--
-- Declared in manifest.json's "options_schema" field, same as Wilds of
-- Kanto's own options.lua, so the Mod Manager can lazy-load and render
-- this list even before/without the mod's own entry chunk running (a
-- disabled mod's options are still viewable/editable this way). main.lua
-- also calls mod.options:define() with this exact table at load time, so
-- both the static manifest path and the live mod.options:get() reads
-- share one source of truth instead of two schemas that could drift.
--
-- Visible labels stay short: the Mod Manager's row layout truncates long
-- labels (same constraint every other mod's options.lua documents).
--
-- mod.options:define() REPLACES the whole schema on every call -- it is
-- not additive across multiple calls within the same mod (confirmed from
-- Loader.lua: loader.optionSchemas[modId] = schema, a plain overwrite).
-- gmax_custom_art and animated_battle_sprites used to be defined by their
-- own separate mod.options:define() calls elsewhere in main.lua
-- (installGmaxAssetPacks, installSpriteAnimation) -- each call silently
-- discarded whatever schema came before it, which is exactly why only the
-- LAST-registered option ever showed up in the Mod Manager screen. Both
-- rows now live here instead, in this one shared schema, and those two
-- functions no longer call mod.options:define at all -- see main.lua.
-- Keys/types/choices/defaults are unchanged from their original
-- definitions, so every existing mod.options:get(...) read elsewhere in
-- this mod keeps working exactly as before.
return {
  {
    key = "gmax_custom_art",
    label = "CUSTOM GIGANTAMAX ART",
    type = "choice",
    default = "true",
    choices = { { "ON", "true" }, { "OFF", "false" } },
  },
  {
    key = "animated_battle_sprites",
    label = "ANIMATED BATTLE SPRITES",
    type = "choice",
    default = "true",
    choices = { { "ON", "true" }, { "OFF", "false" } },
  },
  {
    key = "wild_spawns_enabled",
    label = "Wild Spawns",
    type = "toggle",
    default = true,
    description = "Show visible wild Pokemon walking in grass (W1 native engine). Battle triggers on contact.",
  },
  {
    key = "classic_encounters",
    label = "Classic Enc",
    type = "toggle",
    default = false,
    description = "Allow the vanilla step-based random encounter roll in addition to visible wild spawns. OFF by default -- visible spawns already provide encounters; leaving both on doubles encounter frequency.",
  },
  {
    key = "wild_max_per_map",
    label = "Max Per Map",
    type = "choice",
    default = 4,
    choices = { { "1", 1 }, { "2", 2 }, { "3", 3 }, { "4", 4 }, { "6", 6 }, { "8", 8 } },
    description = "Maximum simultaneous visible wild Pokemon per map (W1).",
  },
  {
    key = "follower_enabled",
    label = "Follower",
    type = "toggle",
    default = true,
    description = "Show a party follower trailing the player in the overworld (F1 native engine).",
  },
  -- Contact-trigger area for wild encounters (proximity contact -> battle,
  -- Phase 6 -- the classic 2D grid trigger is untouched per explicit user
  -- instruction and isn't cell-based in a way this could shrink anyway).
  -- Previously a fixed "adjacent cell" check, which in continuous pixel
  -- terms is a 16px center-to-center reach -- reported too generous.
  -- Default here is 13px, 80% of that 16px baseline.
  {
    key = "wild_contact_radius",
    label = "Wild Contact Area",
    type = "choice",
    default = 13,
    choices = { { "65% (10px)", 10 }, { "80% (13px)", 13 }, { "90% (14px)", 14 }, { "100% (16px)", 16 } },
    description = "How close (pixels, center-to-center) the player must get to a wild spawn to trigger contact. Does not affect the classic 2D grid trigger.",
  },
  {
    key = "modern_combat_formulas",
    label = "MODERN COMBAT FORMULAS",
    type = "choice",
    default = "true",
    choices = { { "ON", "true" }, { "OFF", "false" } },
    description = "Native Lua port of modern (Gen 6+) damage/crit formulas -- Sp.Atk/Sp.Def split, EV/IV/nature-aware, stage-based crit. Applies to every battle. OFF reverts to the engine's native Gen 1 formula. Pure math -- no visual effect; battle presentation is always vanilla.",
  },
  {
    key = "custom_battle_scene",
    label = "CUSTOM BATTLE SCENE",
    type = "choice",
    default = "false",
    choices = { { "ON", "true" }, { "OFF", "false" } },
    description = "PHASE A / foundation build: forces OG battle layout (hides the BATTLE LAYOUT option row while on) and replaces the plain white battle background with a placeholder color, to confirm the custom-scene render pipeline before real scene content is built on it. OFF (default): battles are fully vanilla.",
  },
  {
    key = "custom_menu_scene",
    label = "CUSTOM MENU SCREENS",
    type = "choice",
    default = "false",
    choices = { { "ON", "true" }, { "OFF", "false" } },
    description = "Replaces native menu screens with GalarGmaxDex's own GUI, styled like the custom battle scene. Covers: party overview + moves/relearn/IV-EV screens, the title screen menu, the in-game start menu (with a MOD MENUS hub for other mods' rows), the options menu, and the mod manager. Battle switch prompts and TM/HM teach mode still render natively; bag and Pokedex are not covered yet. OFF (default): menus are fully vanilla.",
  },
}
