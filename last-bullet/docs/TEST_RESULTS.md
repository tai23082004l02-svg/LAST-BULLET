# v0.7.0 validation — 2026-11-05

Godot 4.6.3, Linux Compatibility. All nine existing suites pass: features, smoke, expansion, reflector_stress, graphics, admin_mobile, robots, summon, campaign.

`tests/lobby.gd` covers home/navigation, compact and exact balances, preview ownership guards, primary Blitz routing, safe layouts at logical heights 1280/1600/1800, once-only x2 rewards and profile isolation. Reviewed rendered home, hangar, summon, profile, 360×640 and 360×800 layouts with Xvfb/Mesa. No physical Android device or APK export was tested.

Previewing a robot does not equip or debit. Missions show existing automatic progress; rewards use the last completed run's existing x2 entitlement, with no new fake claims. Admin moved to the top-left avatar.

---

# v0.6.0 validation — 2026-11-05

**Godot 4.6.3**, Linux Compatibility. Script import and existing 7 suites pass after the new systems; roster purchase expectations updated to the approved shard-exchange design.

- `tests/campaign.gd`: complete active timelines for all 5 stages (90/105/120/120/135 seconds before each boss), combat-wave transitions/upgrades, valid obstacle bounds and persistent bullet identity, five boss styles, Mirror shield states, zone telegraph, actual boss kills → unlocks/stars/rewards. Duplicate finish does not repay. Save reload restores 5 cleared stages; replay pays only repeat reward; failure does not unlock. Campaign does not overwrite Survival best score. Magnetic steering keeps speed/caps turn; hot tiles warn before damage. Final Core phase-two charge, same-bullet capture/release and single-use x4 return strike tested explicitly.
- `tests/summon.gd`: invalid batches/funds rejected before RNG/spending, 1,000 pulls obey max 10/50 gaps, forced Legendary priority, free admin ×10, duplicate shard amounts, exchange cost/owned guards, profile roundtrip and receipt persistence. 10,000 seeded base rolls (pity reset per sample) fall within test tolerances around 75/20/5; this checks implementation rather than promising session outcomes. UI double-click/skip/review does not charge again, reload after reveal starts preserves inventory/receipt. Admin/free and normal inventories/pity remain separate.
- `tests/graphics.gd` also validates all 6 campaign atlas regions/shared texture bounds. Rendered stage selection, every themed arena/boss, chamber/reveal/results and summon at 360×800 reviewed through Xvfb/Mesa. New PNGs are in `docs/previews/`.
- Five boss sprites and one summon chamber added as a cached, mipmapped atlas. Environmental effects do not create extra projectiles; obstacle routes are cached/bounded. Tests use separate temporary profiles and clean up successful runs.

Not verified: physical Android, touch/notch edge cases, FPS/heat/battery on phones, APK export or real-player difficulty balance. Boss timing targets a short stage but fight duration depends on skill. No online services, paid draws, ads or account backend were added.

---

# v0.5.0 validation — 2026-11-05

Engine: **Godot 4.6.3**, Linux Compatibility renderer. No Android hardware test.

- Existing 5 test suites pass: controls/skins/wallet, five-minute survival, expansion/Blitz/boss/x2, Reflector stress, atlas/FX/menu lifecycle.
- `tests/admin_mobile.gd`: admin activation, 4 free skins, god mode, no cooldown, max-start and per-upgrade lab controls, enemy/boss cap, one bullet, paused tools, persisted mode/options, separate admin profile, restored normal wallet/record/owned skins after switching back. Adaptive 720×1600 logical layout with simulated 40/32 safe margins, footer/modal bounds, centered wide layout and shrink back to baseline.
- `tests/robots.gd`: 7 characters, six valid atlas regions, insufficient funds rejected, purchase paid once, ownership/equip saved, every admin character free, unchanged HP and single bullet, normal robot collection restored after admin.
- Actual rendered screenshots inspected at 540×960, 360×800 and 360×640: admin/options/upgrade lab, robot hangar, enlarged main buttons, tall arena/footer and two-line HUD plus Perfect row. Long lab lists intentionally scroll.
- Mobile display-safe-area uses the platform safe rectangle. This branch is covered with simulated margins only; physical notch/navigation bars, touch scaling and orientation remain to test on real devices.
- Robot additions are cosmetic, using a second shared atlas and the same interpolated player actor. Existing collision sizes are unchanged.

---

# v0.4.0 validation — 2026-11-05

Engine: **Godot 4.6.3.stable.official.7d41c59c4**, Linux; OpenGL Compatibility / Mesa llvmpipe for rendered checks.

- New PNG assets import and scripts compile without missing resources/parse errors.
- Existing features, five-minute survival, expansion (Blitz/boss/x2) and five-minute high-speed Reflector stress pass after the art integration. All keep stable single-bullet identity and prior wallet/skin behavior.
- New `tests/graphics.gd`: all 8 atlas regions valid, shared backing texture/cache; repeated menu/skins/settings lifecycle has stable node count; effect caps 80/24, expiration and retry cleanup; effects create no gameplay bullet; interpolation enabled; actor/effects hidden on results.
- Rendered menu, mode select, gameplay, all enemy types, boss/exposure, upgrade icons, results, skins and settings reviewed in 450×800 window. New screenshots are in `docs/previews/`. New app icon is configured; no Android package was built.
- `docs/previews/v0.4-motion.mp4`: 481 frames at fixed 60 FPS, 450×800, offline Godot Movie Maker art preview. Scripted movement, invulnerability and skin changes are used to review motion; no claim of real-time phone FPS. Audio is disabled in this visual-only preview.
- Software-renderer VSync support warning is expected in the virtual display. No gameplay script errors were observed in these rendered checks.
- Runtime visual effects are capped, share atlas textures and use Compatibility rendering. Physical Android FPS, heat/battery, touch, vibration, speaker listening, APK export and notch/safe-area behavior remain untested.

All tests use their own temporary profile files, not `records.cfg`. The approved concept PNG is retained as reference; the new screenshots are from the implemented game.

---

# v0.3.0 validation — 2026-11-05

Engine: **Godot 4.6.3.stable.official.7d41c59c4**, Linux. Same physical-device/audio-listening limitations as below.

- Editor import and existing `features.gd` / five-minute `smoke.gd` regressions pass.
- New `expansion.gd`: reflector swept reflection/Bank Shot; player separation; Chaser navigates from above to below pillar without entering it; three Perfect streak scoring and accuracy; normal/miss reset without damage; boss captures/releases same bullet, 3s exposure and one-use x4 deflected return; immediate x2 gold once, wallet persistence, no claim during play/no extra claim after retry/zero earnings; complete 90-second Blitz with enemy-cap checks, all five normal types, automatic results and medals; reduced effects persist.
- Extra Reflector stress: high-speed, upgraded single bullet over five simulated minutes, including boss and crowded enemies. Assertions check finite/in-bounds bullet, no pillar overlap and stable bullet identity.
- Actual rendered 450×800 screenshots reviewed using Xvfb/Mesa Compatibility: mode selection, Reflector arena with tracking pointer, results before/after x2 claim, Blitz Silver result, exposed boss. Modal fits; x2 button and all result navigation buttons visible. HUD separated into three short rows and hidden on results.
- x2 is **instant admin reward**, with no SDK, ad provider, mock ad, loading/wait screen or network. Run earnings include completed missions plus end reward; old wallet balance is excluded. Duplicate button callbacks cannot pay twice.
- Tests use separate `expansion-test.cfg` / previous test filenames; success cleans them. No real player save writes.

The simulated invulnerable player and software rendering are not balance validation or Android performance measurement. Physical Android touch, vibration, export and speaker listening remain untested.

---

# v0.2.0 validation — 2026-11-05

Engine: **Godot 4.6.3.stable.official.7d41c59c4**, Linux.

## Passed
- Headless editor import: no script parse errors or missing audio/resources.
- `tests/features.gd`: normal/perfect/outgoing/buffered/missed deflect; pause freezes time; Wide Catch radius/cooldown; Phase Shot keeps direction through a target; Bank Shot charges/consumes; swept targets behind travel do not get phantom hits; shield front blocks and back takes damage; zone locks its marked location and damages only after telegraph; mission reward once; insufficient-funds rejection; repeated equip does not double charge; profile reload; selected skin survives restart; offered upgrade selection/caps; result payment once; audio streams decode, bounded voice count and mute stops playback.
- XP collection and synthetic touch joystick movement, deflect-button signal while joystick is held, finger release over GUI resets stick. These are synthetic tests, not an Android-device test.
- `tests/smoke.gd`: seeded accelerated 300-second survival simulation with invulnerability; combat kills, stable bullet identity, finite position, enemy cap, boss appears; isolated boss capture/release; results/retry reset leaves exactly one bullet. Simulated player is stationary and invulnerable, so this does not establish game balance.
- Actual rendered screenshots examined at a **450×800 window / 720×1280 logical viewport** using Xvfb, OpenGL Compatibility, Mesa llvmpipe: menu, skin shop, arena/aim rings, upgrade screen and help. Improved opaque modal panel and ensured skin previews plus Back fit. This is layout verification on a software renderer, not phone FPS measurement.
- Test saves use `user://features-test.cfg` / `user://smoke-test.cfg` and are removed after success. Real `records.cfg` is not written by tests.

## Not verified
No physical Android touch, vibration, APK export, device speaker listening test, safe-area/notch layout or phone performance benchmark. Audio was decoded and event/mute logic checked; listening/balance needs real playtesting.

## Manual playtest
1. Catch at outer ring, then time an incoming catch in gold ring; compare normal vs Perfect feedback.
2. Hold movement while pressing deflect. Release joystick over another button; player should stop.
3. Try Phase Shot / Bank Shot / Wide Catch builds. Track the single bullet through boss capture.
4. Flank Shield Guard and leave a Caster's yellow mark before it fires.
5. Complete missions; die, open SKINS, purchase/equip; restart Godot and verify wallet/equipped skin.
6. Toggle sound and vibration; replay to tune loudness and performance on target phone.
