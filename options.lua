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
    key = "use_base_area_tables",
    label = "Base Area Tables",
    type = "toggle",
    default = false,
    description = "Use GalarGmaxDex's built-in area spawn tables. OFF by default to allow custom spawn tables from other mods to take effect.",
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
  -- Not yet consulted anywhere -- explicit user request to leave this
  -- placeholder in place for a future pass that prints "X lost Y HP!"
  -- style messages using our own computed damage number (both gens).
  -- modern_combat.lua's damage formula itself is no longer toggleable
  -- (see that file's own header) -- this option is unrelated to that.
  {
    key = "show_hp_lost_messages",
    label = "SHOW HP LOST MESSAGES",
    type = "choice",
    default = "false",
    choices = { { "ON", "true" }, { "OFF", "false" } },
    description = "Not yet implemented. Reserved for a future \"X lost Y HP!\" battle message using this mod's own computed damage number.",
  },
  {
    key = "gimmicks",
    label = "GIMMICKS",
    type = "choice",
    default = "false",
    choices = { { "ON", "true" }, { "OFF", "false" } },
    description = "Master switch for the gimmick menu (Dynamax/Mega/Z-Move/Tera picker, injected via START into the vanilla move-select screen). Battles stay fully vanilla otherwise -- native draws everything, nothing forced. VANILLA ENHANCED below picks which one battle layout actually gets it.",
  },
  {
    key = "vanilla_enhanced_layout",
    label = "VANILLA ENHANCED",
    type = "choice",
    default = "og",
    choices = { { "OG", "og" }, { "WIDE", "wide" } },
    description = "With GIMMICKS on: which battle layout gets the gimmick menu (and its correct free left/right/up/down move-list navigation -- native's own OG code only ever handles up/down, and native's own Wide grid bounces to the opposite side instead of holding position; both are fixed here). Only the layout selected here is affected -- switch this to match whichever BATTLE LAYOUT you're actually using.",
  },
  {
    key = "gen2_wide_layout",
    label = "GEN 2 MOVE TYPE READOUT",
    type = "choice",
    default = "false",
    choices = { { "ON", "true" }, { "OFF", "false" } },
    description = "Gen 2 only. Gen 2's real move-select screen has no equivalent to Gen 1's WIDE layout -- it's a single fixed 160x144 panel with no engine-level wider-canvas mechanism, confirmed against source. This adds the highlighted move's TYPE on the move box's own unused bottom row (native only fills 4 of the box's 6 rows during move select) -- the one piece of info Gen 2's native list doesn't show at all, without touching or resizing anything native draws.",
  },
  {
    key = "custom_menu_scene",
    label = "CUSTOM MENU SCREENS",
    type = "choice",
    default = "false",
    choices = { { "ON", "true" }, { "OFF", "false" } },
    description = "Replaces native menu screens with GalarGmaxDex's own GUI, styled like the custom battle scene. Covers: party overview + moves/relearn/IV-EV screens, the title screen menu, the in-game start menu (with a MOD MENUS hub for other mods' rows), the options menu, and the mod manager. Battle switch prompts and TM/HM teach mode still render natively; bag and Pokedex are not covered yet. OFF (default): menus are fully vanilla.",
  },
  {
    key = "gigantamax_size",
    label = "GIGANTAMAX SIZE",
    type = "choice",
    default = "1.4",
    choices = { { "x1.2", "1.2" }, { "x1.4", "1.4" }, { "x1.8", "1.8" }, { "x2.2", "2.2" }, { "x2.6", "2.6" } },
    description = "How much bigger the player's mon's battle sprite draws while Gigantamaxed, on top of its normal resting size.",
  },
  {
    key = "gigantamax_skip_animation",
    label = "SKIP GIGANTAMAX GROW/SHRINK",
    type = "choice",
    default = "false",
    choices = { { "ON", "true" }, { "OFF", "false" } },
    description = "ON: Gigantamax's size-up and size-down happen instantly (0 seconds, no staged ramp/pause) instead of the eased multi-stage animation. OFF (default): the full animated sequence plays.",
  },
  {
    key = "national_dex_sprites",
    label = "NATIONAL DEX SPRITES",
    type = "choice",
    default = "true",
    choices = { { "ON", "true" }, { "OFF", "false" } },
    description = "ON (default): for species national_dex itself added beyond the cart's native roster, national_dex's own real sprite (if it has one) is used instead of GalarGmaxDex's bundled art. OFF: GalarGmaxDex's own bundled art always wins for every species in its pack. Either way, GalarGmaxDex's art always wins over the cart's own native sprite (e.g. Cyndaquil in Gen 2) -- this option only ever decides national_dex vs. GalarGmaxDex, never vanilla vs. GalarGmaxDex.",
  },
}
