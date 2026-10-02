# ZbdCombatLock development rules

- Target Project Zomboid Build 42.21 or newer within the Build 42 line.
- Keep the combat simulation native: do not change damage, range, stamina, animation timing, hit chance, targeting, or network packets.
- Prefer client-side Lua. Do not add Java, ZombieBuddy, or another dependency without documenting why Lua cannot satisfy the requirement.
- The default toggle is Left Ctrl. Treat it as a toggle, not a held key.
- UI input must take priority over combat input.
- Keep runtime code nil-safe because Build 42 APIs can vary between minor releases.
- Validate only behavior affected by the current change. Gameplay verification must be performed in the game.
- Commit each accepted phase separately.
