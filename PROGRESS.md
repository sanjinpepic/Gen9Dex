# g9-battle-engine-beta — Progress

- **Flinch/confusion chance**: read directly off national_dex's own
  `moveById` record (`flinchChance`, `ailment=="confusion"`+
  `ailmentChance`) on every landed hit, for the entire roster, not a
  precomputed table built from a static file.
- **highCrit/multiHit**: derived live from national_dex's own `critRate`/
  `minHits`/`maxHits` fields and patched onto the live move record —
  applied uniformly across all 764 moves, not just the ones this mod's
  old data file happened to cover. The real 2-5-hit weighted distribution
  (3/8·3/8·1/8·1/8) is applied by formula, confirmed against national_dex's
  own effect text, not guessed.
- **Move completeness** (`isMoveDataComplete`, gates `combat/
  learnset_ownership.lua`'s usability check): judged entirely off
  national_dex's own modern fields on the live record (ailment, stat
  changes, drain, healing, multi-turn) — a move needing nothing beyond
  flinch/confusion/multi-hit is complete with zero registration; anything
  needing a real ailment/stat-change/drain/heal/charge effect is complete
  only if some file in this mod has actually patched a working custom
  effect onto it.
- **Custom sub-effects** (`bypassesProtect`, and pointing a move's
  `effect` field at one of this mod's own registered handlers): a
  explicit, audited table (`CUSTOM_EFFECT_PATCH` in `main.lua`) replacing
  every per-move mapping moves_new.lua used to carry silently. Rebuilt
  from a full cross-check of every `move_effects:register` call in this
  codebase against its real body (not assumed) after an initial pass
  missed ~60 of them — confirmed fixed and in-game tested (weather
  starters, Taunt/Attract, stat-change moves all working).

## Move roster & sub-effects
🔶 **In progress**,
(`combat/modern_type_change_moves.lua`), but Stockpile/Endure/Belly
Drum-style moves, Protect-bypass beyond Feint (Magic Coat), and several
damage-formula variants remain unstarted.

## Abilities
🔶 **Real battle-effective ability-execution system, built from scratch
this session** (`abilities/`) — consumes `national_dex`'s own
`abilityById` live, no duplicated data. Phased:
- ✅ Phase 0 — storage/dispatch plumbing + 4 switch-in stat abilities
  (Intimidate, Intrepid Sword, Dauntless Shield, Supersweet Syrup)
- ✅ Phase 1 — switch-in weather (Drizzle/Drought/Snow Warning/Orichalcum
  Pulse), switch-in terrain (Electric/Grassy/Misty/Psychic Surge, Hadron
  Engine), on-move/on-damage type-change (Protean, Libero, Color Change)
- ✅ Phase 1.5 — primal weather (Desolate Land, Primordial Sea, Delta
  Stream): irreplaceable, indefinite duration, ends only when the setter
  leaves the field, Water/Fire move-fail gate, Delta Stream's own
  type-effectiveness cap against Flying
- ✅ Phase 1.8 — the passive/derived-type family: Multitype (fixed at
  switch-in to held Plate, never re-derived live), Forecast (reactive to
  live weather changes), Mimicry (reactive to live terrain changes)
- ⬜ Phases 2-8 — damage/defense multipliers, status/type immunity,
  `stat_multiplier`, `priority_change`, heal/crit/accuracy effects, the
  43-ability `prevent` bucket, and the 118-ability `other` bucket are all
  still unstarted — the large majority of the ability roster by count.
- ⬜ Ability-changing/suppressing moves (Skill Swap, Worry Seed,
  Entrainment, Gastro Acid) — no mechanism exists at all; standing,
  explicitly-flagged TODO.

## Weather, terrain, and field conditions
✅ **Core systems done and substantially extended this session.** The
four standard weathers and four terrains are fully wired
(`combat/modern_weather.lua`, `combat/modern_terrain.lua`), plus Trick
Room (`combat/trick_room.lua`, real 5-turn activation/-7 priority/
toggle-off). New this session: primal weather (see Abilities above) and
a boss-fight permanent-lock tier for both weather and terrain (see Boss
fight protections below) — both reuse the same setter/getter primitives
rather than parallel state.

## Type-override primitive
✅ **Done**, one shared gate (`combat/type_override_primitives.lua`) behind
Soak/Magic Powder/Conversion/Reflect Type/Camouflage/Burn Up/Double Shock
(moves) and Protean/Libero/Color Change/Multitype/Forecast/Mimicry
(abilities) alike. Tera always blocks any change, self or opponent-
directed, with no exceptions. Known, flagged gap: the Dynamax-side of the
gate (should block only opponent-directed changes against a Dynamaxed
target) is inert — `battle_forms` exposes no "is this mon Dynamaxed right
now" query for it to read.

## Switch-inducing moves
✅ **Done.** U-turn, Volt Switch, Flip Turn, Parting Shot, Teleport, Baton
Pass (`combat/switch_primitives.lua`, `combat/modern_switch_moves.lua`) —
built on the engine's real `battle.forcedSwitch` field rather than a
pause/resume model, since `runTurn` is a private, unreachable local
closure on both generations (confirmed directly from source — not
something a mod can hook around).

## Turn order
✅ **Done**, Gen 9/Showdown-accurate priority + Speed + Trick-Room + random
-tie comparator (`combat/turn_order.lua`), replacing the native
comparator outright. Fixed this session: every switch-in ability/effect
engine used a fixed player-then-enemy order for simultaneous triggers at
turn 0 (e.g. a Drought vs. Drizzle lead matchup) — now genuinely
Speed-ordered (`mod.exports.orderSwitchInMons`), matching the real rule
that the slower side's trigger is what's left standing after both
resolve. One permanent, unfixable gap: a genuine same-turn **mid-battle**
double switch is hardcoded player-first in native's own `runTurn`, a
private local function no mod can reach — confirmed, not attempted
further.

## Boss-fight protection system
✅ **Built from scratch this session** (`combat/boss_fight.lua`, `combat/
boss_fight_status.lua`) — a variadic flag API (`setBossFightProtections
(battle, "sun", "statsDrop", ...)`) gating ten independent protections on
the enemy side only: `sun`/`mistyTerrain` (permanent, boss-only
weather/terrain lock, beats even a player's primal weather), `statsDrop`
(immune to any stat reduction, self-inflicted included), `type`
(immune to opponent-directed type changes), `dimensionLock`/`trickRoom`/
`magicRoom`/`wonderRoom` (composable room-move bans, `trickRoom` also
forces the battle permanently into Trick Room), `hardStatus`/`softStatus`
(immune to hostile status/confusion; self-casts like Rest are unaffected,
confirmed both bypass the shared status primitives entirely), `antiDrain`
(draining the boss harms the drainer instead of healing it). Three
flags — `ability`, LeechSeed (part of `softStatus`), `healblock` — are
honest no-ops: nothing in this engine can currently change an ability or
apply LeechSeed/Heal Block at all, so there's nothing yet to gate.

## Dynamax / Gigantamax
🔶 **Storage + API only, by explicit scope decision.** Dynamax Level and
Gigantamax Factor are fully tracked with a public API
(`gigantamax/dynamax_state.lua`); no activation, no HP changes — that's
`battle_forms`'s job end to end. The older gimmick-ring UI/grow-shrink
sequence/move roster (`gigantamax/gimmick_dynamax.lua`) still exists on
disk but is currently disabled — both custom battle scenes it depended on
were removed entirely earlier in this project's history, pending a new
activation hook from whichever mod now owns gimmick triggering.

## Tera Type
🔶 **Storage + API only, same scope discipline as Dynamax.** STAB fix,
Stellar defense/economy, and Tera Blast's Stellar variant are real and
wired (`combat/modern_tera.lua`); Terastallization's own trigger/menu/item
slot is owned by `battle_forms`, not this mod.

## Held items
🔶 **Move-triggered interactions done; passive effects pre-existing,
untouched.** Fling, Knock Off, Covet, Incinerate, Bug Bite, Pluck,
Recycle, Belch are real, working, Gen 2-only interactions
(`combat/modern_items.lua` — Gen 1 has no held-item concept in this
engine at all, which is correct, not a gap). Passive held-item effects
(Quick Claw, King's Rock, Leftovers, etc.) are Gen 2's own native,
ROM-driven mechanism, pre-existing and not something this mod built or
has touched.

## EV/IV/Natures, modern stats
✅ **Done.** Full modern stat layer for wild and trainer mons on both
generations (`stats/engine_modern_stats.lua`, `wild_modern_ivs.lua`,
`trainer_modern_stats.lua`, `gen2_modern_stats.lua`), including ability
assignment/resolution and the Ability Capsule-equivalent swap API.

## Learnset ownership & move-availability gate
✅ **Done.** `national_dex`'s unfiltered movesets are the canonical "what
can this species learn" source (`combat/learnset_ownership.lua`); this
mod gates actual usability on its own move-effect completeness (now read
entirely off the live registry, see the standing rule above), enforced
in-battle by a 0-PP-style blocking gate (`combat/move_availability_gate.lua`)
installed after every other `:update` wrap bar one (the battle-prompt
intercept below, which reads no input outside its own phase).

## In-battle two-choice prompt (mod-facing primitive)
✅ **Done, Gen 2.** `mod.exports.askBattleChoice` / `battleChoiceActive` /
`cancelBattleChoice` (`combat/battle_prompt.lua`): any mod supplies a
question, two labels and a callback, and gets the answer back. A
primitive, not a policy — nothing in it knows what a boss, a capture or
an HP threshold is, so the boss-at-1-HP "CATCH it"/"LEAVE it" case is a
caller, not a hardcoded rule. Works around a real base-engine
limitation, confirmed by source read: `src/ui/gen2/BattleState.lua:3822`
draws the yes/no box only for five hardcoded phase names, and an
unrecognised phase falls off the end of native `:update` every frame — a
softlock, not merely an undrawn box. Installed as Phase 17, outermost of
every `:update` wrap, so its own phase name never reaches another wrap.
🔶 **Gen 1 is a follow-up**: `src/battle/BattleState.lua` has no yes/no
infrastructure at all, so there is no box to reuse there and the whole
widget would have to be drawn from scratch against a different chrome
stack — `askBattleChoice` returns `false` with a reason on a Gen 1 boot
rather than half-working.
