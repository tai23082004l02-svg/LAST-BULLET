# CURRENT — v1.1.2 PROJECTILE VISUALS (2026-11-06)

User asked for projectile designs and effects after illustrated weapon/pet patch. Implemented shared projectile_art.gd (procedural deterministic drawing): all12 distinct projectiles, layered tracers/glow, muzzle flashes, per-style enemy/wall impacts, same renderer in arsenal animated preview. Combat routes muzzle/impact through existing bounded32 flash list. Pause freezes effects, reset clears; low_effects reduces layers/sparks. Hostile bullets retain distinct orange readability. No simulation/economy/save/control changes and no gameplay RNG consumption in drawing. Source project.godot engine/version metadata intentionally untouched for this art-only patch.

Eight relevant suites pass (projectile_fx plus arsenal/arsenal_stress/shooting/shooter_stress/graphics/polish/pets_practice). Visual gallery renders all12 projectiles/muzzles/impacts in full/reduced modes without renderer errors, and arsenal capture reviewed. See PROJECTILE_FX.md, TEST_RESULTS.md and previews/v1.1.2-*.png. Phone FPS remains unverified. Preserve all prior profiles and ownership.

--- Previous context ---

# CURRENT — v1.1.1 ILLUSTRATED PETS / WEAPONS (2026-11-06)

User specifically requested genuinely richer art for the six pets and twelve weapons shown in their screenshots. Replaced their geometric icons with original generated painted transparent sprites: art/arsenal/pets.png (3×2), weapons.png (4×4, only first 12 cells used). Runtime import settings tracked; do not track .godot. item_art.gd decodes each atlas once and lazily fits each cell into a mipmapped 256px cached texture; previews, collection and combat pets share these assets. Vector fallback remains for other groups. Keep unique ID order, ownership and existing gameplay/profile data. Locked pets remain dimmed but visible, with lock icons.

Pet card art area increased and equipped pet preview enlarged. Weapon preview and catalog enlarged, compact three-column navigation retained. No price, drop rate, balance, control, profile or language changes in this art patch. Version 1.1.1. Read ILLUSTRATED_ART.md and TEST_RESULTS.md. Seven relevant suites rerun (illustrated_art plus six regressions); full 18-suite run belongs to v1.1.0 and is not claimed newly rerun. Phone FPS still unverified.

--- Previous completed release ---

# CURRENT HANDOFF — v1.1.0 COMPLETE (2026-11-05)

The authorized visual/UI/bilingual/hero-growth/balance batch is implemented and validated. Read VISUAL_LANGUAGE_HERO.md first, then RPG_SYSTEMS.md for preserved systems. This section supersedes older art/UI/test counts below. 18 current suites including polish; 41 cached vector icons; paged equipment; VI/EN settings with persisted global language; level1–20 hero training, hero cores and safe-room repair kits. See TEST_RESULTS.md for limits. No real-phone performance claim.

User requested a one-time check three hours after 16:50 UTC on 2026-11-05. This cannot reset account usage. If the scheduled task runs after this completed release, inspect GitHub HEAD and report completion; do not repeat work or invent an endless new batch. User asks to end completed work with a question about the next feature/hero/removal. Preserve all existing controls, no ads, profile isolation and Termux workflow.

New modules: item_art.gd, localization.gd, localization_catalog.gd; polish.gd regression. Art is generated in code with mipmaps and cached; no external image download needed. Runtime Translation resources are explicitly removed on exit. Additive profile fields hero_levels/hero_cores/repair_kits; language in normal-path basename + '-language.cfg'. Never reset inventory or progression to install the update.

--- Previous release context ---

# CURRENT HANDOFF — v1.0.0 RPG (2026-11-05)

Read RPG_SYSTEMS.md first. This section supersedes older v0.8/v0.9 progression and timed-campaign notes below.

User explicitly authorized all discussed systems, no further permission needed for routine implementation:12 gear templates,4 slots/rarities,+0…10, guaranteed3→1 fusion/refunds/protections,6 passive pets,5-stage×5-room dungeons with separate Hard stars, checkpoints, sweeps,3 loadout presets and2/4 set bonuses, collection gallery and DPS practice. The requested collection gallery replaces weakness/loss-analysis idea; do not add those features.

Entry: lobby tab ĐỒ & PET. Gear/pets/daily/sweep/presets/library/practice in hub. Keep12 free weapons,16 run upgrades, release-to-fire with moving-fire option, drag-anywhere controls and hidden double-tap skill. Admin now owns all48 gear rarity variants and6pets, free upgrades/fusion-material test button; all normal/admin state stays isolated.

Key modules: progression.gd pure inventory/economy; progression_ui.gd hub/routes; adventure.gd room/checkpoint/sweep/practice; companions.gd passive pets/set shield; collectible_view.gd lightweight procedural art; game/combat glue. RPG persisted under rpg schema1 in existing profile, atomically temp+rename. Initial four Common pieces unequipped, Bee,30 mats granted once. Keep current checkpoint receipts, never repay missions/milestones on resume. First-clear/currency/inventory/rewards committed together. No ads/mock ads/payments added.

Dungeon flow is enemy-clear rooms, not old at90/105/120-second boss schedule. Hard changes fan patterns/speed, not only HP. Resume restarts current room with saved build, same upgrade offers if pending; rewards stay banked. Starting a new campaign replaces checkpoint; Practice does not. Sweep uses replay boss loot, consumes1 sweep ticket, requires3 stars per difficulty, admin free. Daily5 UTC tickets plus1 per run mission. See RPG_SYSTEMS.md for exact reward rates/formulas and limits.

Current tests:17 suites; shooter_campaign updated to five-room/Hard/checkpoint semantics; old timed/permanent-bullet tests remain historical. Added rpg_inventory, pets_practice, checkpoint_rewards and rpg_stress. Physical new systems on S23 Ultra still need user playtest; no phone FPS/APK claim. Close Godot before Termux pull; preserve/stash local project.godot edits rather than discard.

--- Older context (current section takes precedence) ---

# LAST BULLET handoff — v0.9.0 (2026-11-05)

Repository tai23082004l02-svg/LAST-BULLET, branch main. Project: last-bullet/project.godot. Read current HEAD and README before edits. This handoff supersedes earlier Deflect design notes.

## User and workflow
Vietnamese user, tests on Samsung S23 Ultra using Godot Android and Termux/Git. Confirmed clone/import/run and portrait worked in prior sessions. Close Godot project before pull. Local repo: ~/storage/downloads/GodotProjects/LAST-BULLET. Read ANDROID_TERMUX.md for exact commands/safe.directory fix. Do not ask them to download ZIP again. Do not reset/clean/discard their local changes to fix pull; inspect and preserve first.

## Approved gameplay change
User found deflect gameplay boring and approved full transition to auto-aim/auto-fire survival shooter, seven robot weapons/skills, new gun upgrades and boss patterns. v0.8 implements this. Drag anywhere on blank screen to move; tap alone does nothing, 12-pixel drag threshold; special buttons excluded. Skill replaces Deflect; latest control is double-tap at the same blank area, Space on PC. The skill button has been removed. Do not restore left-only movement, tap-to-move, permanent bullet or Perfect missions.

Read SHOOTER.md for exact rules, bounds and migration; README for player-facing controls/robot table. Five campaign stages and existing summon/skin/robot progress are retained. Sixteen current weapon upgrades. Missions: kill15, skill3, chain10. Stars: win, HP3+, finish within 60s of scheduled boss arrival. Local admin from avatar, separate save, all content, god/max-upgrades/no-skill-cooldown/labs. No server account implied.

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
Godot 4.6.3 Linux automated tests plus Xvfb/Mesa visual captures. tests/legacy contains retired permanent-bullet tests (.gdignore); do not count them as passing or run them against v0.8. Current13 suites listed in TEST_RESULTS.md. Shooter stress covers 630s Survival across seven max builds and 90s Blitz. Five campaign timelines/volleys, rewards and save migration tested. User must still assess new shooting feel/difficulty and multitouch on S23 Ultra; no APK/phone FPS/thermal/battery claim.

## Next step
Ship v0.8 to main, ask user to close Godot/pull/reopen and playtest. Gameplay tuning feedback may follow; no further unapproved feature is assumed. Older docs/previews remain historical; current README/SHOOTER.md govern combat.

## Latest control request
User asked to hide skill UI and activate by double tap. Implemented: two quick short taps in the same area use skill; normal drag-anywhere movement remains unchanged. A single tap/long hold/drag does not fire skill. A second finger may double-tap while the first keeps moving. Pause/menus/upgrades are excluded; cooldown retained. Small passive cooldown text replaces the button. See SHOOTER.md and tests/double_tap.gd. Do not reintroduce an on-screen skill button unless user asks.

## Latest v0.9 request and implementation (takes precedence)
User explicitly asked for Archer Hero-style weapon variety and gave discretion to implement without asking. Added12 freely selectable primaries and16 upgrades; read ARSENAL.md for exact mechanics. Lobby now has5 tabs: Sảnh / Robot / Vũ khí / Summon / Skin. Weapons are free for testing in both normal/admin; no debit or ownership reset. Robot skill remains independent and activated by double tap; do not bring back the skill button.

Default is now release-to-fire: drag to dodge, stop to shoot. Settings has saved BẮN KHI DI CHUYỂN to restore moving fire. Added finite wall ricochet, diagonal/back shots, poison/cold/blast, drones/orbit blades and thermal shock. All passive effects freeze in upgrade/pause/results. Weapon selection saved per profile. Existing progress/summon/x2 rules retained. Expanded tests include arsenal and arsenal_stress; total13 suites. New art is lightweight procedural weapon previews/projectiles/icons, using existing neon style. No actual-phone FPS/balance claim; user should playtest S23 Ultra after pull. Project version0.9.0; close Godot before pull and preserve project.godot edits/stash if blocked.
