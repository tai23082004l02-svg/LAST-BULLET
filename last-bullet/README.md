# LAST BULLET — v0.4.0
ZORVYKA Games • **One Shot. Endless Chaos.**

Godot 4 portrait arcade survival. Exactly one permanent bullet, no external plugins or online runtime services.

## v0.4.0 — Neon Arcade art update
- Full illustrated robot roster: mint hero, Chaser, Dasher, Tank, Shield Guard, Zone Caster, Bullet Eater and reflector pillar. Art follows the approved Neon Arcade concept.
- Painted navy metal arena with cyan frame, gold danger accents, new app icon and beveled neon panels/buttons. Upgrade cards have individual icons; HUD includes health pips, XP and boss phase/health.
- Idle/walk sway, hover, spawn-in, shield animation, dash telegraph, boss core pulse, hit flash, kill fragments, bounce sparks, Perfect ring bursts, animated skin previews and tapered skin trails.
- Physics interpolation for moving actors/bullet; time-based UI transitions and lean/hover animation. Cosmetic rendering is separate from gameplay collision. Bullet remains exactly one; visual halos/robot limbs do not enlarge hitboxes.
- One sprite atlas shared by all robots, cached regions, linear mipmap filtering, simple Compatibility rendering, bounded FX renderer (80 events / 24 in low-effects mode). Crowded scenes shorten trails and reduce fire opacity. No full-screen bloom or per-spark nodes.

### See the real build
[Gameplay screenshot](docs/previews/v0.4-arena.png) · [Boss screenshot](docs/previews/v0.4-boss.png) · [Menu screenshot](docs/previews/v0.4-menu.png) · **[Download 8-second motion preview](docs/previews/v0.4-motion.mp4)**

The video is an offline 60-fps scripted art preview recorded from Godot at 450×800, with invulnerability and automatic movement/skin changes. It is not a phone performance benchmark or a claim of 60-fps performance on Android.

**Run/update:** GitHub Desktop → Fetch origin → Pull origin → Godot 4.6.3 → F5. Let the editor import the new PNG files before Play. Game rules, save compatibility and instant admin x2 reward remain available.

## Chạy game / lấy bản mới
- GitHub Desktop: **Fetch origin → Pull origin**, mở Godot.
- Hoặc GitHub: **Code → Download ZIP**, giải nén.
- Godot **4.6.3 Standard**: Import `last-bullet/project.godot` → **F5 → PLAY**.
- Di chuyển: **WASD / phím mũi tên**; deflect: **Space**; pause: **Esc**.
- Cảm ứng: kéo joystick trái và bấm **DEFLECT** bên phải. Có thể giữ joystick trong lúc bấm deflect bằng ngón còn lại.

## Bản 0.3.0 — chọn chế độ và nhận x2 vàng
**PLAY** mở ba lựa chọn: **SURVIVAL • OPEN**, **SURVIVAL • REFLECTOR**, **BLITZ • 90 SECONDS**. Retry giữ chế độ/bản đồ vừa chơi.

1. **Theo dõi đạn:** lõi trắng, viền tối/halo và thứ tự vẽ trên địch. Đạn cách người chơi hơn 280px thì hiện mũi chỉ hướng nhỏ. Hitbox vẫn 7px, skin không thay đổi va chạm. Khi trên 24 địch, tự rút ngắn vệt đạn và giảm độ đậm Fire Trail; Settings có **LOW EFFECTS** để luôn giảm hiệu ứng.
2. **Perfect streak:** Perfect liên tiếp thưởng `25 × min(streak, 10)` điểm mỗi lần, tăng cao độ âm thanh tới giới hạn. Đỡ thường hoặc bấm hụt kết thúc chuỗi; không trừ máu. HUD tách chuỗi Perfect khỏi chuỗi kill. Lưu kỷ lục chuỗi Perfect cục bộ.
3. **Reflector:** bản đồ thử nghiệm có một cột vuông giữa sân. Cả đạn, người chơi và địch đều va chạm; địch đi vòng qua cột bằng đồ thị nhỏ của bốn góc. Nảy cột cũng tích Bank Shot. Open vẫn giữ nguyên sân trống. Sweep dùng hình chữ nhật mở rộng theo bán kính, nên góc vuông xử lý hơi bảo thủ.
4. **Boss phản đòn:** sau khi nhả cùng viên đạn, Bullet Eater đứng yên/lộ lõi vàng trong 3 giây gameplay. Deflect viên đạn rồi đưa nó trúng boss trong cửa sổ đó để gây **x4 sát thương cho một lần trúng**. Đỡ thường cũng làm được; không bắt buộc Perfect. Va tường không mất cơ hội, nhưng hết 3 giây thì mất. Time Warp không kéo dài cửa sổ phản đòn.
5. **Blitz 90s:** sáu giai đoạn 15 giây với mẫu địch và nhịp spawn định trước, tăng từ Chaser tới Dasher, Tank, Shield Guard, Zone Caster. Không có boss. Thời gian chỉ chạy khi đang chơi, dừng khi pause/chọn nâng cấp. 90 giây thì tự chốt kết quả nếu còn sống; chết sớm vẫn có kết quả. Huy chương theo điểm: Bronze 600, Silver 1500, Gold 3000. Kỷ lục Blitz lưu riêng Survival. Nâng cấp vẫn ngẫu nhiên; vị trí spawn còn phụ thuộc khoảng cách an toàn với người chơi.
6. **Kết quả chi tiết:** số Perfect, chuỗi Perfect cao nhất, tỷ lệ deflect thành công trên số lần bấm hợp lệ, kỷ lục vừa phá và số vàng còn thiếu để mở skin kế tiếp. Không có lần bấm thì tỷ lệ hiển thị 0%.

### Nhận x2 vàng — bản admin
Ở màn kết quả, bấm **CLAIM X2 GOLD** để nhận ngay phần vàng cộng thêm. **Không quảng cáo, không mô phỏng quảng cáo, không đếm ngược.** Mỗi trận nhận tối đa một lần.

Phần được nhân đôi là **toàn bộ vàng kiếm trong trận vừa xong**, gồm vàng nhiệm vụ đã trả trong trận và vàng kết thúc trận; không nhân đôi cả ví. Ví dụ: ví cũ 100, trận kiếm 15 từ nhiệm vụ + 5 từ kết quả → ví 120, nhận x2 → ví 140. Nút bị khóa sau khi nhận. Trận không kiếm được vàng thì không có phần thưởng x2. Rời màn kết quả hoặc đóng game trước khi nhận thì không giữ lượt nhận cũ. Tích hợp quảng cáo thật để sau, hiện không có SDK/provider quảng cáo.

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
- Waves every 20s; safe enemy cap 48, boss can add one. Bullet Eater at 4 minutes in Survival captures and releases **the same bullet** after 1.1s, then exposes a 3s return-strike window. The line telegraphs its release toward the current player position.
- Soft steering after 5s without bullet impact. XP attracts within 115px. Combo expires after 3s without a kill. Five-minute survival target, then continue indefinitely.
- Eight upgrade types: original Heavy Bullet, Accelerator, Magnetic Assist, Time Warp, Fire Trail (5 stacks each); new Phase Shot, Bank Shot, Wide Catch (3 each). Time Warp slows enemies only. Shield Guard also blocks ground fire; hit its unshielded side with the bullet. All upgrades maxed: next levels heal 1 HP up to 5.
- Save in `user://records.cfg`: Survival/Blitz best scores, Perfect streak record, coins, owned/equipped skins, settings. Existing best-score saves migrate automatically. No cloud save.

## Files / tuning
- `scenes/Main.tscn`: entry scene, UI created in code.
- `scripts/game.gd`: run lifecycle, player/controls, waves, missions, upgrade cards, wallet/skins/settings/save.
- `scripts/bullet.gd`: persistent projectile, sweep, boost, pierce/bank, skin rendering.
- `scripts/enemy.gd`: enemy behaviors, shield direction, telegraphed zones and boss.
- `scripts/arena_geometry.gd`: reflector sweep, separation and four-corner navigation.
- `art/neon/`: illustrated art, atlas region helper, import settings and provenance.
- `scripts/player_visual.gd`, `scripts/skin_preview.gd`, `scripts/visual_effects.gd`: cosmetic animation and capped feedback rendering.
- `scripts/audio.gd`: bounded local audio pool, limiter and generated wall ping.
- `scripts/balance.gd`: primary tuning constants, caps, names, skin colors/prices. Enemy stats are in `enemy.gd`; wave/XP/mission values in `game.gd`.
- `tests/smoke.gd`, `tests/features.gd`, `tests/expansion.gd`, `tests/reflector_stress.gd`, `tests/graphics.gd`: isolated test saves, cleaned up on success.
- `docs/TEST_RESULTS.md`: validation evidence and remaining device checks.

## Validation commands
```sh
godot --headless --path last-bullet --editor --import --quit
godot --headless --path last-bullet --script res://tests/features.gd
godot --headless --path last-bullet --script res://tests/smoke.gd
godot --headless --path last-bullet --script res://tests/expansion.gd
godot --headless --path last-bullet --script res://tests/reflector_stress.gd
godot --headless --path last-bullet --script res://tests/graphics.gd
```
Tested on **Godot 4.6.3.stable.official.7d41c59c4**, Linux. Tests do not alter `records.cfg`.

## Android export
1. Install matching Godot 4.6.3 export templates: **Editor → Manage Export Templates**.
2. Install OpenJDK 17 and Android SDK per Godot's Android export guide. Configure **Editor Settings → Export → Android → Java SDK Path / Android SDK Path**.
3. **Project → Export → Add Android**; set a package name such as `com.zorvyka.lastbullet`, version and your debug keystore. Portrait is configured in the project. Use arm64-v8a for modern phones.
4. Export a debug APK or use one-click deploy with USB debugging. For release, exclude `docs/` and `art/concepts/` from export; those are review materials, not runtime assets.

No APK/signing credentials included. Android export, physical multi-touch, vibration, speaker balance and phone performance are **not yet tested**.

## Remaining limitations
Prototype balance; robot movement uses procedural pose/hover/sway rather than frame-by-frame directional animation. No notch/safe-area adaptation or gamepad support. The bullet sweep samples enemy positions once per tick, so relative-motion sweeps may be useful at extreme speeds. Cosmetic trail/effects and damage zones are capped; XP pickups capped at 180. No ads, IAP, accounts, analytics, multiplayer or leaderboards.
