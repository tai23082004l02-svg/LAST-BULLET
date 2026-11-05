# LAST BULLET
ZORVYKA Games — **One Shot. Endless Chaos.**

Playable portrait arcade survival prototype, made with generated geometry and GDScript. No external assets, plugins, or online services required.

## Chạy trong Godot
1. Tải repository (Code → Download ZIP), giải nén.
2. Dùng **Godot 4.6.3 Standard** (không cần .NET), Import file `last-bullet/project.godot`.
3. Nhấn **F6** khi mở Main.tscn hoặc **F5**, chọn PLAY.
4. WASD/phím mũi tên để di chuyển, SPACE để deflect, Esc để pause.
5. Trên điện thoại: kéo joystick trái, chạm nút DEFLECT bên phải.

## Rules and implemented features
- Exactly one `PermanentBullet` Node2D per live run. Swept segment/circle enemy collision, analytic wall reflection, per-enemy hit cooldown, separation and same-entity recovery. The bullet never hurts the player.
- Deflect: press within a 0.22-second window while the bullet is inside the 105px ring; redirects in **last movement direction**, UP if you have not moved. 0.65s cooldown applies on success or miss. Success boosts speed and damage for 1.6s. The ring dims during cooldown.
- Idle soft steering begins after 5 seconds without a bullet hit. Accelerator has a normal-speed cap; temporary deflect boost can exceed it by 20%.
- Chaser circles, telegraphed Dasher triangles, durable Tank squares. Health/contact damage with 1.2s invulnerability. Waves increase every 20s; enemy cap 48 (boss may add one).
- Bullet Eater appears at 4 minutes. Captures the existing bullet for 1.1 seconds, indicates the release path toward the player, then releases it. No extra projectile.
- Kills, 3s combo chains, score, nearby XP attraction, level-up choices, five upgrades capped at five stacks. Time Warp slows enemies only, keeping player/bullet/UI responsive. Fire Trail is damage ground, never another bullet.
- Title/help/pause/results/retry and local best score in `user://records.cfg`. Survive five minutes and continue indefinitely.

## Files / tuning
- `scenes/Main.tscn`: entry scene; UI is built in code.
- `scripts/game.gd`: run lifecycle, player/controls, waves, pickups, upgrades, screens, save.
- `scripts/bullet.gd`: persistent projectile, swept collision, steering, capture, recovery.
- `scripts/enemy.gd`: three enemy classes plus boss, generated visuals.
- `scripts/balance.gd`: primary arena, speed, cooldown and cap constants. Additional enemy stats are in `enemy.gd`, wave/XP values in `game.gd`.
- `tests/smoke.gd`: deterministic lifecycle assertions over randomized combat.

The prototype intentionally uses one entry scene and three focused gameplay scripts instead of empty individual scenes for each screen. Root game owns bullet creation and all run state; kill/level/end signals are exposed for future sound and UI separation.

## Validation
Tested with **Godot 4.6.3.stable.official.7d41c59c4**, Linux headless:

```sh
godot --headless --path last-bullet --editor --import --quit
godot --headless --path last-bullet --script res://tests/smoke.gd
```

Five-minute accelerated simulation checks kills/XP progression, stable bullet identity, finite positions, enemy cap, boss capture/release and clean retry. This is logic validation, not a phone performance benchmark or touch-device test.

Manual checks: move with both keyboard and touch, catch bullet inside ring, try all upgrades, pause/resume, take five hits, retry, resize portrait window, survive to boss. Verify readability and frame rate on your target Android device.

## Android export
1. Install matching Godot 4.6.3 export templates (Editor → Manage Export Templates).
2. Install OpenJDK 17 and Android SDK per Godot's Android export guide; configure Java SDK Path and Android SDK Path under Editor Settings → Export → Android.
3. Project → Export → Add Android. Set a unique package name, e.g. `com.zorvyka.lastbullet`, version and local debug keystore. Keep portrait orientation (configured in project), use arm64-v8a for modern phones.
4. Export a debug APK, install on a device or use Godot one-click deploy with USB debugging enabled. Release signing is a separate step.

No APK or signing credentials are included. Android export and physical-device touch/performance have **not** been tested here.

## Known limitations / deferred
- Prototype balance and primitive visuals; no audio/haptics yet. No device profiling, safe-area/notch adaptation, localization, or gamepad support yet.
- Swept bullet tests use enemy positions sampled once per tick; extremely fast moving targets may need relative-motion sweeps later.
- Touch dragging starts in the lower-left control area. A mouse drag is supported there for desktop preview.
- Pickups capped at 180; all upgrades capped at five; saturated upgrades turn subsequent levels into +1 HP (max 5).
- Boss release aim tracks the player's current position during capture; dodge as the capture expires.
- Ads, payments, login, analytics, cloud save, multiplayer and online leaderboards are deliberately deferred.
