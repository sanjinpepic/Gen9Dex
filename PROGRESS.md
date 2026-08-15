# Progress against README scope

Cross-checked against the actual GalarGmaxDex source (this repo's dev
counterpart) rather than assumed from memory — see notes under each item
for what was actually found. Ordered top (highest priority) to bottom
(lowest priority), matching the README's own order.

## Scope

### 1. All up to date moves with working sub effects
🔶 **In progress.** Stat-stage stubs (~60), status/recoil/drain/two-turn
moves, Detect + the Counter family, and the weather-linked sub effects are
wired to real engine primitives. A direct re-audit of `moves_new.lua`
against runtime `:patch()` overrides and the `multiHit`-field false
positives (Protect/Detect and the pure multi-hit moves were already
handled elsewhere) corrected the estimate from ~68 to **49 confirmed
stubs**, tracked as 8 batches:

- ✅ **Entry hazards** (`combat/modern_hazards.lua`) — Stealth Rock, Toxic
  Spikes, Rapid Spin built from scratch; native Gen 2 Spikes upgraded
  in-place from its original single-layer/flat-1/8 behavior to real Gen 9
  stacking (3 layers, 1/8 → 1/6 → 1/4), verified directly against
  Showdown's own `data/moves.ts`. Sharp Steel (Gen VIII) is fully defined
  — real per-side state and switch-in damage — but nothing sets it yet:
  G-Max Steelsurge exists as move data (Copperajah's signature) but is
  still an unwired stub, flagged in-file as an `INTERACTION TODO`.
- ✅ **Item interactions** (`combat/modern_items.lua`) — Fling (real
  per-item power, sourced directly from Showdown's `data/items.ts`),
  Knock Off (removal + 1.5x boost), Covet (steal), Incinerate
  (destroys berries, hard-fails otherwise), Bug Bite/Pluck (eats the
  target's berry and applies its real heal/cure effect to the user),
  Recycle, and Belch — all real, Gen 2 only (Gen 1 has no item concept
  in this engine at all, which is mechanically correct, not a gap).
- ⬜ Turn-order / switch-conditional moves (U-turn/Dragon Tail, After
  You, Fake Out, Sucker Punch, Focus Punch, Court Change)
- ⬜ Terrain (Grassy/Misty/Psychic Terrain) — see item 4 below
- ⬜ Stockpile family + Endure + Belly Drum-style all-in stat moves
- ⬜ Protect-family bypass/reflection (Feint, Magic Coat)
- ⬜ Type/ability-changing status moves (Soak, Magic Powder, Entrainment,
  Aromatherapy, Healing Wish, Curse)
- ⬜ Damage-formula variants and misc (Foul Play, Round, Burn Up, Smack
  Down, Jaw Lock, Snipe Shot, Last Resort, Wicked Blow, Laser Focus,
  Rollout, Uproar)

~38 stubs remain across the six unstarted batches above.

Every batch in this project follows two standing rules: (1) any real
interaction-rule dependency deferred to later work is left as an
explicit, greppable `-- INTERACTION TODO:` comment at the exact spot,
not just prose (`grep -r "INTERACTION TODO" combat/` finds the current
list); (2) on a genuine cross-generation behavioral collision, the
current Gen 9 (Pokemon Showdown) rule always overrides older native
engine behavior — Showdown is the primary source of truth for every
number/mechanic, other sources are enrichment only.

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
all (~26%), before counting the 49 sub effects among those 247 that are
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
🔶 **Move-triggered interactions done; expansion not started.**
`combat/modern_items.lua` gives eight moves real, working item
interactions (Fling/Knock Off/Covet/Incinerate/Bug Bite/Pluck/
Recycle/Belch — see item 1). Passive held-item effects (Quick Claw
priority, King's Rock flinch, Focus Band endure, type-boost damage,
Leftovers/Berry residual healing, BrightPowder accuracy, and more) are
real and working today, but that's Gen 2's own native engine mechanism
(`Battle:heldEffect`/`tickHeldItem`, ROM-driven), pre-existing and
untouched by this mod — not something built for this scope item.
"Expansion" (adding held items beyond Gen 2's real ~250-item ROM
roster) hasn't been attempted at all.

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
