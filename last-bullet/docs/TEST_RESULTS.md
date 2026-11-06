# v1.1.1 illustrated art validation — 2026-11-06

Seven suites rerun and pass: illustrated_art, polish, graphics, pets_practice, rpg_inventory, lobby, arsenal. Editor import clean. New atlas suite validates all18 distinct sprites, transparent corners, fitted aspect-preserving bounds, mipmaps and stable caches. Rendered VI/EN weapons and VI pets at360×800; source atlases inspected and runtime captures reviewed. No fresh full-suite or physical-device FPS claim; preceding v1.1.0 results remain historical.

--- Previous validation ---

# v1.1.0 validation — 2026-11-05

All 18 current suites pass under Godot 4.6.3: polish plus the 17 v1.0 suites below. Editor import clean. Major-menu EN audit: zero remaining Vietnamese strings across visited routes. New test validates bilingual formatted templates/language reload; 41 cached textures; hero upgrade funds/caps/stats/save; kit safe-room/checkpoint/zero persistence; Hard first-clear cores; floating damage cap/expiry/reduced effects. Arsenal suite rerun independently with verbose logging exits cleanly (initial concurrent run emitted a resource-cleanup warning).

Rendered 360×800 both languages, arsenal/summon/hub/training/pets/admin gear. Screenshot previews in v1.1-*.png. Visual resource caching, offscreen animation suppression and gear pagination added. No actual S23 Ultra FPS, physical input, APK or long-term balance benchmark claimed. See VISUAL_LANGUAGE_HERO.md.

--- Historical validation ---

# v1.0.0 RPG validation — 2026-11-05

Godot4.6.3 Linux Compatibility; editor import clean.17 suites pass: rpg_inventory, pets_practice, checkpoint_rewards, shooting, shooter_campaign, shooter_stress, admin_mobile, robots, summon, graphics, lobby, results, upgrade_ui, double_tap, arsenal, arsenal_stress, rpg_stress.

- rpg_inventory: one-time migration/empty bag, costs/caps, fusion same-template/tier/unique IDs, highest level/refund investments, locked/worn protection, repeated fuse rejection, preset references, dismantle, real set stats, admin all tiers/pets, daily/receipt dedup.
- shooter_campaign rewritten for all5×5 active room sequences, Hard stars/patterns, pending upgrade reload/exact offers, room reward receipts, fixed pet unlocks, once-only finish, sweep1/5/10 economics/conditions/duplicate UI clicks, failure retains loot.
- checkpoint_rewards: XP-upgrade resume keeps same offered choices/build without skipping room; mid-room mission/milestone rewards cannot pay again after replay; receipt pruning preserves active checkpoint; x2 includes banked mission gold once.
- pets_practice: six actual pet effects and Medic cap, pause/freeze, real HP/damage/crit/speed/cooldown and sets, collection ownership/discovery, preset restore, static10s DPS practice with no payout/checkpoint loss.
- rpg_stress:3 Legendary+10 sets×6pets×30 simulated seconds, all16 upgrades, varied weapons/skills; finite shots, HP bounds,160 friendly/180 hostile/32 flashes caps. Other shooter/arsenal stress adds720+540 simulated seconds. Not a real-time device benchmark.
- Existing remaining suites cover weapon collisions/LOS/expiry/native elements/auxiliaries, save migration, admin isolation/touch layout, summon pity/economics/skip guards, UI lifecycle/atlas/effect bounds, lobby, results/x2, upgrades and double tap.

Rendered equipment/fusion/pets/locked-and-owned collection/dungeon room strip/supply/sweep and gameplay,360×800 plus360×640 gear screen, via Xvfb/Mesa. Screens under docs/previews/v1.0-*.png. No per-pet physics body or per-status node; reuse approved atlases and procedural neon icons.

Not verified: actual S23 Ultra play feel, balance/loot progression speed, physical multitouch/notches, FPS/heat/battery or APK export. Old phone confirmation was setup only. Old validation below is historical and timed campaign descriptions superseded by room flow. No ads/payments/backend.

---

# v0.9.0 Arsenal validation — 2026-11-05

Godot4.6.3 Linux Compatibility. All13 current suites pass: arsenal, arsenal_stress, shooting, shooter_campaign, shooter_stress, admin_mobile, robots, summon, graphics, lobby, results, upgrade_ui and double_tap. Editor import passes.

New arsenal suite exercises actual damage for all12 weapons, no-cost/persistent/profile-safe selection and runtime guards, stop/moving-fire policy, diagonal/back directions, finite ricochet, cover blocking splash while front-side wall explosions still damage, exact boomerang outbound/return hits, native elemental upgrades actually increasing duration/power, poison/burn/thermal damage, drones/blades and frozen auxiliary state. UI/stat checks expanded from8 to16 upgrade slots.

Arsenal stress simulates540s across12 weapons with all16 upgrades, mixed robot skills, pillars and both movement modes. Previous seven-robot stress covers630s Survival+90s Blitz. Counts and finite positions checked, not a real-time benchmark. Existing campaign suite runs all five combat timelines and boss patterns/rewards; save migration, summon, x2 and double-tap guards retained.

Rendered loadout (boomerang/laser) and build combat at360×800, new multiline upgrade cards at360×640 via Xvfb/Mesa. Physical S23 Ultra firing feel, balance, frame rate/thermal/battery and APK export remain unverified. Baseline historical notes below are preserved; current behavior is in ARSENAL.md.

---

# Double-tap control patch — 2026-11-05

Skill button removed; skill activated by two sequential short taps on blank screen. New tests/double_tap.gd passes timing/distance/hold/drag/cancel/cooldown/multitouch/GUI/state/emulated-mouse cases. Shooting, admin_mobile, upgrade_ui, graphics and lobby regressions rechecked. The suite list below describes the v0.8 baseline; double_tap is now the eleventh suite. Rendered 360×800 layout reviewed; physical-device gesture feel not yet verified.

---

# v0.8.0 validation — 2026-11-05

Godot 4.6.3 Linux Compatibility. Current shooter replaces the v0.7 permanent-bullet rules. Ten current suites pass:

- shooting: legacy inventory/currency/summon/campaign migration, separate new score keys, swept collisions/expiry, friendlies harmless, pierce/chain distinct hits, LOS/walls including hostile obstruction, armor, burn/chill, all seven weapons/skills, cooldown/state guards, paused shots, missions and once-only x2.
- shooter_campaign: all five full active timelines with wave upgrade pauses, distinct boss fan counts and Core phase two, shield windows/ground hazards, ordinary boss kills without capture/return, stars/unlocks, save reload, first/repeat clear rewards and duplicate-finish guard.
- shooter_stress: 630 simulated seconds of Survival across seven max-upgrade robots plus 90s Blitz, finite projectile state, bounded friendly/hostile/FX/enemy counts and reset/retry lifecycle. Not a real-time performance benchmark.
- admin_mobile: free unlocks, god/max/no-skill-cooldown, labs, single boss, normal/admin profile isolation/reload and touch/safe-area/resize guards.
- robots: atlas, exchange/equip, ownership/profile persistence, admin and one combat controller/reset.
- summon: funds/batches, 10/50 pity, duplicates/exchange, rate distribution, receipt persistence and skip/repeated click guards.
- graphics: atlases, repeated menu lifecycle, FX caps/expiry/reset, combat renderer and result visibility.
- lobby: nav, balances, preview ownership, primary mode and same-profile once-only rewards.
- results: failure/win/next-stage routes, zero reward, collapse/expand details and x2 disabled after claim.
- upgrade_ui: centered safe layout, frozen combat, hidden HUD, touch isolation, eight before/after descriptions, one selection and capped offers.

Import checked with --headless --editor --import --quit. Visuals rendered via Xvfb/Mesa at 360×640 and 360×800: shooter HUD/skill and both projectile teams, new upgrades, results and robot weapon/skill details. No new concept or runtime art replacement required. See previews/v0.8-shooter.png.

Old Deflect features/smoke/expansion/reflector_stress/campaign tests are preserved in tests/legacy with .gdignore, not counted or runnable for current combat. Historical validation is available in Git history.

Not verified: physical S23 Ultra shooting/multitouch feel, APK export, phone FPS, heat, battery or player difficulty balance. Earlier user confirmation of Godot Android/portrait applies to setup, not to this new combat release. No ads, payments or account backend added.
