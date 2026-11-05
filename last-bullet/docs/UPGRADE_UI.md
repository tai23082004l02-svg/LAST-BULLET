# Upgrade UI — v0.9

Centered compact mobile panel, Vietnamese title, up to three vertical cards, icon/current-next-level and actual before/after stats. Functional colors, not rarity. Current16 choices: firepower, fire rate, multishot, critical, burn, penetration, chain, skill cooldown, diagonal pair, back shot, wall ricochet, poison, cold, blast, drones and orbit blades. Statistics depend on selected weapon; admin no-cooldown override is explicit. No Deflect, magnetic idle-assist or Wide Catch upgrade remains.

Dark full-screen input blocker dims combat. HUD/missions/controls hide, combat pauses. Card release selects once and resumes, resets movement; blank taps cannot start movement through the overlay. Existing press feedback animates the button. 800 logical pixel panel fits safe bounds, with scrolling fallback. All capped choices excluded; all-max heals one HP.

See tests/upgrade_ui.gd and ARSENAL.md. Physical-device comfort awaits user feedback.
