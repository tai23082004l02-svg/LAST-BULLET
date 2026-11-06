# CURRENT — v1.3.0 ONE-ROOM 3D PROTOTYPE (2026-11-06)

User explicitly approved trying one3D room after discussing Archero/Habby-style rendering. This supersedes their earlier preference to avoid3D only for this isolated prototype; DO NOT migrate the whole game without feedback. Entry: THỬ3D on lobby title row or Modes→PHÒNG THỬ3D. Full existing2D game/shop/profiles remain. Scene prototype3d/Room.tscn; scripts room.gd and robot.gd.

Original lightweight rigid-mesh robot with articulated leg/arm pivots, rifle mounted on body/hand area, actual3D orthographic oblique camera, room floor/walls/gate and two solid covers. One red Sentinel enemy type in3waves (3+4+4=11), delayed telegraphed ranged shots, auto-aim/release-to-fire, optional moving fire, drag-anywhere with12px threshold, double tap/Space energy pulse, HP/failure/retry/win/pause/return. Keyboard WASD/arrows; Android back returns home, focus loss pauses. No rewards, costs, drops or profile writes. Original2D host and its CanvasLayer are hidden/process-disabled while prototype lives as root sibling; restore host/menu on exit, free3D subtree. Quote UI revision invalidated on entry. Existing checkpoint/profile remains byte-identical in test.

Compatibility renderer retained. No external model/texture assets, no animation sprite frames: three shared primitive meshes, solid-color materials, rigid joint animation (NOT production skinned skeletal model), simple contact shadows; no dynamic shadow maps/postprocess. High uses2x MSAA and full internal viewport, Low disables MSAA and halves viewport axes. Up to48projectiles/24FX rings, shared ring mesh, max4active enemies. Paused/finished3D viewport renders once then stops refreshing. Important:2D assets remain resident for safe return, so prototype is NOT a fair total-memory comparison against a complete3D migration. Phone FPS/thermal/battery must be tested on S23 Ultra.

Nine suites rerun: prototype3d plus lobby/admin_mobile/shop/checkpoint_rewards/shooter_campaign/arsenal/held_weapon/graphics. New suite exercises drag/tap/second-finger skill/GUI exclusion, pause/quality, swept hits/cover, caps, full3-wave bot completion/loss/retry, repeated enter/exit cleanup and byte-identical profile. Rendered360×800 VI/EN, high/low, pause and original lobby;8-second scripted simulation clip included (NOT phone FPS footage). Read PROTOTYPE_3D.md. Next step is user playtest/visual direction feedback, not automatic full migration.

--- Prior completed context ---

# CURRENT — v1.2.0 LOCAL SHOP (2026-11-06)

User approved shop supplies, fixed bundles, shard exchange and cosmetics using existing gold/shards, no real payments/ads. Implemented23 catalog entries across5 tabs. Entry: tap any lobby resource chip or Inventory→CỬA HÀNG. Old wallet still accessible. Read SHOP.md for full prices/rewards/limits and cosmetic semantics. VI/EN covered, shop route audit zero missing VN in EN.

Modules shop.gd (local catalog/transactions/persistence), shop_ui.gd (cards/detail/choice/confirmation/receipt/history), shop_art.gd (shared-asset bundle art). Shop initialized before load_profile; shop section stores counts/themes/selected theme/last20 receipts separately in normal/admin profiles. Existing inventory/summon/hero/checkpoint saves retained. save_profile now returns bool from existing temp+rename mechanism; shop validates full request before mutating, snapshots touched fields, rolls back on save failure. Quotes bind current UI revision/profile/day and are consumed once; navigation invalidates old callbacks. No random purchases. Admin bypasses price/limits, still respects inventory capacity/duplicate pet/theme ownership.

Cosmetics are energy finishes, not newly painted character atlases: subtle shared robot+gun tint, aura, bounded12 footsteps (0.5s), tracer palette and legacy bullet skin grant. Purchase does not equip. Equip applies next run; reduced FX removes aura/footsteps. Existing elemental projectile shapes/cores and hostile colors retained. Source project.godot unchanged to avoid unnecessary local engine-config pull conflicts.

Validation: all23 current suites pass incl new shop/shop_rollback. Shop test covers prices/grants/choices, daily/once limits, duplicate/stale/profile/state guards, capacity, reload/admin isolation, language and cosmetic footsteps. Rollback injects save failure and checks currencies/inventory/ownership/limits/history restoration. Rendered all5 shop tabs, starter selector, finish preview, confirmation, receipt, history and English featured at360×800. Physical S23 Ultra shop feel/economy progression still needs user test; no phone FPS claim.

--- Previous release context ---

# CURRENT — v1.1.3 HELD WEAPONS (2026-11-06)

User asked for guns to appear during combat. player_visual.gd now draws equipped weapon from shared illustrated art, with arms/grips, per-family width56–72, aim rotation, vertical mirroring on left aim to keep art upright, rear/front layering for upward/other directions and bounded recoil. game syncs selected/default weapon and aim after combat, resets recoil on start and freezes visual clock/recoil while paused. combat fire triggers kick and puts muzzle flash at transformed barrel. Removed old aim-stick line. No projectile/collision origin, hitbox, damage/rate, economy or save changes. project.godot unchanged.

Seven relevant suites pass: held_weapon, arsenal, projectile_fx, graphics, arsenal_stress, shooting, admin_mobile. New suite checks7 robot defaults/12 weapons×8 directions, real muzzle alignment, recoil/pause/reset and unchanged projectile collision origin. Illustrated 12 equipped poses and360×800 actual gameplay captured with Xvfb/Mesa. Read HELD_WEAPONS.md. No actual S23 Ultra FPS/feel claim. Preserve all prior controls/profiles and no ads.

--- Previous context ---

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
