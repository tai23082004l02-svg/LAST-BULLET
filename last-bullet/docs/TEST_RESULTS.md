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
