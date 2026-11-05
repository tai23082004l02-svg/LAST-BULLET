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
