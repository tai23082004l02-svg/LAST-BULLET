# LAST BULLET handoff — v0.8.0 (2026-11-05)

Repository tai23082004l02-svg/LAST-BULLET, branch main. Project: last-bullet/project.godot. Read current HEAD and README before edits. This handoff supersedes earlier Deflect design notes.

## User and workflow
Vietnamese user, tests on Samsung S23 Ultra using Godot Android and Termux/Git. Confirmed clone/import/run and portrait worked in prior sessions. Close Godot project before pull. Local repo: ~/storage/downloads/GodotProjects/LAST-BULLET. Read ANDROID_TERMUX.md for exact commands/safe.directory fix. Do not ask them to download ZIP again. Do not reset/clean/discard their local changes to fix pull; inspect and preserve first.

## Approved gameplay change
User found deflect gameplay boring and approved full transition to auto-aim/auto-fire survival shooter, seven robot weapons/skills, new gun upgrades and boss patterns. v0.8 implements this. Drag anywhere on blank screen to move; tap alone does nothing, 12-pixel drag threshold; special buttons excluded. Skill replaces Deflect; latest control is double-tap at the same blank area, Space on PC. The skill button has been removed. Do not restore left-only movement, tap-to-move, permanent bullet or Perfect missions.

Read SHOOTER.md for exact rules, bounds and migration; README for player-facing controls/robot table. Five campaign stages and existing summon/skin/robot progress are retained. Eight new weapon upgrades. Missions: kill15, skill3, chain10. Stars: win, HP3+, finish within 60s of scheduled boss arrival. Local admin from avatar, separate save, all content, god/max-upgrades/no-skill-cooldown/labs. No server account implied.

## Files
scripts/game.gd: run lifecycle, UI, missions/rewards, profiles and admin.
scripts/combat.gd: bounded projectiles, aim/fire, seven weapons/skills, enemy volleys.
scripts/enemy.gd: movement, shields, hazards, ranged warning visual and status effects.
scripts/bullet.gd: static BulletVisual cosmetic helpers only.
scripts/mobile_lobby.gd: existing mobile lobby.
art/neon/: approved robot/neon art; reuse it.

## Preservation constraints
No real ads or mock ads. X2 gold is immediate, once/run and same profile. Keep summon pity/receipts/inventory; no update gifts or reset. Existing save files records.cfg, records-admin.cfg, records-mode.cfg stay; unknown/legacy fields retained. Shooter records use new keys to avoid comparing to old gameplay scores. Existing ownership/stars/unlocks stay.

Do not commit .godot or docs/concept image .import files. Keep .gdignore in docs and art/concepts and tracked runtime art/neon .import settings. Godot auto-edits project.godot locally can block pull; preserve user edits. Push against inspected latest HEAD, expected SHA, force=false. Link actual GitHub screenshots/docs so the user can open them on phone.

## Validation and limits
Godot 4.6.3 Linux automated tests plus Xvfb/Mesa visual captures. tests/legacy contains retired permanent-bullet tests (.gdignore); do not count them as passing or run them against v0.8. Current 10 suites listed in TEST_RESULTS.md. Shooter stress covers 630s Survival across seven max builds and 90s Blitz. Five campaign timelines/volleys, rewards and save migration tested. User must still assess new shooting feel/difficulty and multitouch on S23 Ultra; no APK/phone FPS/thermal/battery claim.

## Next step
Ship v0.8 to main, ask user to close Godot/pull/reopen and playtest. Gameplay tuning feedback may follow; no further unapproved feature is assumed. Older docs/previews remain historical; current README/SHOOTER.md govern combat.

## Latest control request
User asked to hide skill UI and activate by double tap. Implemented: two quick short taps in the same area use skill; normal drag-anywhere movement remains unchanged. A single tap/long hold/drag does not fire skill. A second finger may double-tap while the first keeps moving. Pause/menus/upgrades are excluded; cooldown retained. Small passive cooldown text replaces the button. See SHOOTER.md and tests/double_tap.gd. Do not reintroduce an on-screen skill button unless user asks.
