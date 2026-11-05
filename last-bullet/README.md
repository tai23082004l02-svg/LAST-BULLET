# LAST BULLET — v0.2.0
ZORVYKA Games • **One Shot. Endless Chaos.**

Godot 4 portrait arcade survival. Exactly one permanent bullet, no external plugins or online runtime services.

## Chạy game / lấy bản mới
- GitHub Desktop: **Fetch origin → Pull origin**, mở Godot.
- Hoặc GitHub: **Code → Download ZIP**, giải nén.
- Godot **4.6.3 Standard**: Import `last-bullet/project.godot` → **F5 → PLAY**.
- Di chuyển: **WASD / phím mũi tên**; deflect: **Space**; pause: **Esc**.
- Cảm ứng: kéo joystick trái và bấm **DEFLECT** bên phải. Có thể giữ joystick trong lúc bấm deflect bằng ngón còn lại.

## Sáu cải tiến ở bản 0.2.0
1. **Perfect Deflect:** bấm khi đạn đang bay tới và nằm trong vòng vàng 43px. Được +2 sát thương, x1.3 tốc độ trong 2.2s; có vòng sáng, tiếng riêng với pitch cao hơn và rung ngắn trên mobile. Đỡ ở vòng ngoài là deflect thường (+1 sát thương, x1.15 tốc độ trong 1s). Bấm sớm có buffer 0.22s nhưng không được Perfect.
2. **Hướng ngắm:** mũi tên xuất hiện khi đạn tới gần. Hướng là hướng di chuyển gần nhất; đứng yên giữ hướng, mặc định lên trên. Mũi tên biểu diễn hướng deflect, không phải dự đoán toàn bộ đường nảy.
3. **Nâng cấp mới:** Phase Shot cho xuyên 1–3 địch sau mỗi deflect; Bank Shot tích tối đa 1–3 sát thương từ nảy tường rồi dùng hết ở lần va địch kế tiếp; Wide Catch tăng vòng đỡ 18px mỗi stack nhưng tăng hồi chiêu 0.12s. Các nâng cấp giữ đúng một viên đạn.
4. **Địch mới:** Shield Guard từ wave 4, quay khiên chậm về phía người chơi; mặt trước chặn cả đạn xuyên, hãy đánh từ bên hoặc phía sau. Zone Caster từ wave 5 đứng yên, đánh dấu vị trí của bạn, chờ 1.1s rồi gây sát thương vùng trong 0.55s. Không bắn thêm projectile.
5. **Nhiệm vụ mỗi trận:** hạ 15 địch, đạt 3 Perfect, đạt chuỗi 10 kill. Mỗi nhiệm vụ thưởng 15 xu một lần, lưu ngay. Khi kết thúc trận nhận thêm `min(50, floor(kills/5) + floor(seconds/30))` xu. Thoát ra menu giữa trận không nhận xu kết thúc trận.
6. **Skin đạn/vệt đạn:** Plasma miễn phí; Meteor 30 xu, Electric 60 xu, Starlight 90 xu. **Menu → SKINS** để xem preview, mua và equip. Chỉ thay ngoại hình; bán kính va chạm, sát thương và tốc độ không đổi. Mua/equip và xu lưu offline.

## Âm thanh
Dùng lại 9 mẫu local đã có trong **Game-create**; không tạo thêm mẫu trả phí, không gọi ElevenLabs lúc chơi. Tiếng nảy tường được tổng hợp bằng GDScript. SFX có giới hạn 8 voice, cooldown từng sự kiện, limiter; dành riêng 3 voice cho thông báo/deflect để tiếng va chạm không lấn át.

**Menu → SETTINGS** bật/tắt âm thanh và rung. Không có nhạc nền ở bản này. Xem nguồn trong `audio/SOURCE.md` và `audio/source.json`. Chưa đánh giá âm thanh bằng tai trên thiết bị thật.

## Core rules
- One `PermanentBullet` per run, analytic wall reflection and swept circle tests against enemies; behind-direction intersections are ignored. Per-enemy hit cooldown 0.22s, separation and same-entity unstuck recovery.
- Bullet never hurts the player. Chaser circles, Dasher triangles, Tank squares. Contact damage gives 1.2s invulnerability.
- Waves every 20s; safe enemy cap 48, boss can add one. Bullet Eater at 4 minutes captures and releases **the same bullet** after 1.1s. The line telegraphs its release toward the current player position.
- Soft steering after 5s without bullet impact. XP attracts within 115px. Combo expires after 3s without a kill. Five-minute survival target, then continue indefinitely.
- Eight upgrade types: original Heavy Bullet, Accelerator, Magnetic Assist, Time Warp, Fire Trail (5 stacks each); new Phase Shot, Bank Shot, Wide Catch (3 each). Time Warp slows enemies only. Shield Guard also blocks ground fire; hit its unshielded side with the bullet. All upgrades maxed: next levels heal 1 HP up to 5.
- Save in `user://records.cfg`: best score, coins, owned/equipped skins, settings. Existing best-score saves migrate automatically. No cloud save.

## Files / tuning
- `scenes/Main.tscn`: entry scene, UI created in code.
- `scripts/game.gd`: run lifecycle, player/controls, waves, missions, upgrade cards, wallet/skins/settings/save.
- `scripts/bullet.gd`: persistent projectile, sweep, boost, pierce/bank, skin rendering.
- `scripts/enemy.gd`: enemy behaviors, shield direction, telegraphed zones and boss.
- `scripts/audio.gd`: bounded local audio pool, limiter and generated wall ping.
- `scripts/balance.gd`: primary tuning constants, caps, names, skin colors/prices. Enemy stats are in `enemy.gd`; wave/XP/mission values in `game.gd`.
- `tests/smoke.gd`, `tests/features.gd`: isolated test saves, cleaned up on success.
- `docs/TEST_RESULTS.md`: validation evidence and remaining device checks.

## Validation commands
```sh
godot --headless --path last-bullet --editor --import --quit
godot --headless --path last-bullet --script res://tests/features.gd
godot --headless --path last-bullet --script res://tests/smoke.gd
```
Tested on **Godot 4.6.3.stable.official.7d41c59c4**, Linux. Tests do not alter `records.cfg`.

## Android export
1. Install matching Godot 4.6.3 export templates: **Editor → Manage Export Templates**.
2. Install OpenJDK 17 and Android SDK per Godot's Android export guide. Configure **Editor Settings → Export → Android → Java SDK Path / Android SDK Path**.
3. **Project → Export → Add Android**; set a package name such as `com.zorvyka.lastbullet`, version and your debug keystore. Portrait is configured in the project. Use arm64-v8a for modern phones.
4. Export a debug APK or use one-click deploy with USB debugging.

No APK/signing credentials included. Android export, physical multi-touch, vibration, speaker balance and phone performance are **not yet tested**.

## Remaining limitations
Primitive art and prototype balance. No notch/safe-area adaptation or gamepad support. The bullet sweep samples enemy positions once per tick, so relative-motion sweeps may be useful at extreme speeds. Cosmetic trail/effects and damage zones are capped; XP pickups capped at 180. No ads, IAP, accounts, analytics, multiplayer or leaderboards.
