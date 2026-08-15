# Progress against README scope

Cross-checked against the actual GalarGmaxDex source (this repo's dev
counterpart) rather than assumed from memory — see notes under each item
for what was actually found. Ordered top (highest priority) to bottom
(lowest priority), matching the README's own order.

## Scope

### 1. All up to date moves with working sub effects
🔶 **In progress.** Stat-stage stubs (~60), status/recoil/drain/two-turn
moves, Detect + the Counter family, and the weather-linked sub effects are
wired to real engine primitives. ~68 lower-priority sub effects are still
stubbed: item interactions, hazards, turn-order edge cases, and
damage-formula variants.

### 2. EV, IV, Natures implementation
✅ **Done.** A full modern stat layer (`stats/engine_modern_stats.lua` +
`wild_modern_ivs.lua` + `trainer_modern_stats.lua` + `gen2_modern_stats.lua`)
covers wild and trainer mons on both generations — real IVs/EVs/natures,
generated or provider-fed, computed into native battle stats.

### 3. Battle effective Abilities
⬜ **Not started.** Abilities are assigned to every mon as identity data
(`ModernStats.generateAbility`/`resolveAbilities`), but nothing in
`combat/` gives an ability an actual battle effect — no Levitate immunity,
no Intimidate, no weather/ability interactions. Purely cosmetic today.

### 4. Fields and Weather conditions
🔶 **Half done.** Weather (Sun/Rain/Sandstorm/Snow-Hail: extra STAB,
one-turn Solar Beam, 100%-accuracy Thunder, chip damage) is fully wired.
Fields/Terrain are not: Terrain-setting moves (Grassy/Misty/Psychic
Terrain) are registered as move data only, with no field-state or
in-battle effect behind them — confirmed directly in the source, e.g.
`combat/modern_movepool_stages.lua`'s own comment on Bulldoze: "grassy-
terrain power reduction not modeled (this mod's terrain support is
separate/unbuilt)."

### 5. All 934 moves updated to generation 9
🔶 **In progress, early.** 179 moves are registered with real Gen 9 data
in `combat/moves_new.lua`, plus ~68 native Gen 1 moves reused as-is where
they already match modern behavior — roughly 247 of 934 moves touched at
all (~26%), before counting the ~68 sub effects among those 247 that are
still stubbed (see item 1).

### 6. Dynamax (Dynamax level, Gigantamax factor), Mega-evos, Z-moves, Tera type
🔶 **Partial — one of four gimmicks built.** Dynamax/Gigantamax is
substantial and real: this is the project's own namesake feature (Phase 3
Gigantamax move/form registration, the gimmick ring UI, the
grow/shrink sequence, Gigantamax-level scaling). Mega Evolution exists
only as sprite/art data for species with a Mega form (national dex
form/id entries, sprite pack roster) — there is no in-battle trigger or
transformation mechanic anywhere in `combat/`. Z-Moves and Tera Type have
no implementation at all — no data, no mechanic, nothing found.

### 7. Held Item expansion + combat effects
⬜ **Not started.** No held-item combat-effect system exists in `combat/`
at all — this is part of the same ~68-stub gap as item 1 (item
interactions specifically), not yet begun as its own feature.

### 8. Overworld encounters
✅ **Good enough initial state** (explicit call — this is the lowest-
priority scope item, and it's functional: native wild-spawn engine
(Phase 7/W1), full lossless art with a real 4-frame walk cycle per
direction, layered fallback chain, encounter tables).

### 9. Followers
✅ **Good enough initial state** (explicit call — also lowest priority).
Native follower engine (Phase 8/F1) is the sole follower system now
(FOLLOWERS_EX compatibility removed as redundant); shares the same art/
sprite-registration pipeline as overworld encounters.

## Future extensions (explicitly out of current scope)

All three are unstarted — no code, no data, no partial groundwork found
for any of them:

- Overworld Alphamons, Hordes, Double Battle, gen 5 phenomena encounter
  type, Dynamax Den, Tera Dens, Mega Dens, (Dynamax/Tera/Mega) Adventures
- Tutor, TM extensions
- EV/IV modification items
