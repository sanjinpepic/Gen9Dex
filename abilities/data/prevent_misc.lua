-- Inclusion list only -- Phase 7 (`prevent` bucket), three real
-- abilities that share no common mechanism with each other or with any
-- other file in this phase, each documented at its own engine call site:
--   DAMP: Self-Destruct/Explosion fail outright, and Aftermath doesn't
--     trigger, while ANY Pokémon in the battle (either battler, not just
--     the holder's own opponent) has this ability.
--   GORILLATACTICS: the real choice-lock half (its atk x1.5 boost is
--     already built, Phase 4's stat_multiplier.lua) -- once the holder
--     has used a move, every future move selection is forced back to
--     that same move for the rest of the time it's on the field.
--   QUICKFEET: the real "no paralysis Speed cut" half (its x1.5 boost is
--     now built too, Phase 4's stat_multiplier.lua, un-deferred this same
--     pass now that this half closes the double-count risk that used to
--     block it).
return {
  DAMP = true, GORILLATACTICS = true, QUICKFEET = true,
}
