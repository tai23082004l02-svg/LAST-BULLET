# LAST BULLET — hướng dẫn tiếp tục công việc

Đọc `last-bullet/docs/SESSION_HANDOFF.md` và `last-bullet/docs/ANDROID_TERMUX.md` trước khi thay đổi dự án. Kiểm tra HEAD trên GitHub để biết trạng thái mới nhất; tài liệu bàn giao không thay thế mã nguồn.

- Dự án Godot ở `last-bullet/project.godot`, không nằm ở thư mục gốc repository.
- Người dùng dùng tiếng Việt, phát triển trên PC và thử bằng Godot Editor Android trên Samsung S23 Ultra. Cập nhật qua Git/Termux; không yêu cầu tải ZIP lại.
- Giữ tiến trình thường/admin riêng. Không thêm quảng cáo thật hoặc mô phỏng: x2 vàng nhận ngay, một lần mỗi trận.
- Giữ hình ảnh neon, 7 robot, campaign và summon hiện có. Xem robot không tự trang bị hoặc trừ tài nguyên.
- Kiểm tra thay đổi phù hợp bằng Godot; ghi rõ đâu là tự động, đâu là người dùng xác nhận trên thiết bị.
- Không ghi đè thay đổi của người dùng, không force-push, reset --hard hoặc git clean để chữa lỗi pull. Xem git status/diff và bảo toàn dữ liệu trước.
- Không commit thư mục .godot hoặc các .import của ảnh tài liệu/concept. Giữ .gdignore hiện có và cấu hình import ảnh runtime art/neon.
- Khi người dùng yêu cầu triển khai và cập nhật GitHub, hoàn thành code, kiểm tra, tài liệu và push; báo commit/link và cách pull ngắn gọn. Không coi yêu cầu chỉ tư vấn là lệnh sửa code.

## Current gameplay: v0.9
User explicitly replaced the old single-bullet/Deflect design with auto-aim/auto-fire, robot weapons and skills. Read last-bullet/docs/SHOOTER.md. Do not restore permanent bullets/Perfect/capture-return boss rules. Movement is drag-anywhere except UI buttons, activated after a small drag threshold, not tap-to-move. Old Deflect tests are historical under tests/legacy/.gdignore; run the thirteen current suites in TEST_RESULTS.md. Keep original records/inventory and use separate shooter score keys.

## v0.9 arsenal (current)
Read last-bullet/docs/ARSENAL.md. User authorized Archer Hero-style variety without more approval: 12 free equipable primaries independent of 7 robot skills, 16 build upgrades, drones/orbit blades and elemental synergies. Default release-to-fire, optional saved shoot-while-moving. Keep double-tap skills and hidden skill button. Preserve profile loadout and old progression; do not charge currency for the current free weapon catalog. Five lobby tabs include VŨ KHÍ. Tests arsenal/arsenal_stress join the 11 prior current suites.

## CURRENT v1.0 RPG (takes precedence)
Read last-bullet/docs/RPG_SYSTEMS.md and latest SESSION_HANDOFF.md. User authorized all discussed gear/pet/dungeon/merge/sweep/preset/set/collection/practice systems. Current entry is ĐỒ & PET lobby tab.12 gear templates,4 rarities,+0…10; guaranteed3→1 merge with highest level/excess investment refunds, locked/worn material protection.6 passive pets.5 stages×5 enemy-clear rooms, Normal/Hard separate stars, checkpoints preserving upgrade offers/build and banked rewards. Sweeps1/5/10 use replay loot only, daily/mission sweep tickets, admin free.3 presets,2/4 sets. Collection glows for owned/encountered, no weakness/loss analysis.10s no-reward DPS practice.17 current suites, campaign test now room-based. Preserve old progression and separate profiles, hidden double-tap skill and12 free weapons. Admin has all48 rarity variants/6pets and free upgrade/test materials. Do not restore timed/permanent-bullet campaign flow. RPG writes via temporary config+rename; room/mission/milestone receipts must prevent duplicate rewards after resume.

## CURRENT v1.1 visuals/language/growth
Read last-bullet/docs/VISUAL_LANGUAGE_HERO.md and newest SESSION_HANDOFF. Authorized batch complete: 41 cached original icons, compact/paged mobile menus, immediate persisted VI/EN, level1–20 hero training, core loot and safe-room kits, balanced room pacing and bounded FX. 18 suites. Preserve additive saves and all prior controls/economy. Scheduled three-hour check must not redo finished work or claim it resets usage.

## CURRENT v1.1.1 illustrated weapon/pet patch
User requested richer actual art after v1.1.0. Read docs/ILLUSTRATED_ART.md and latest SESSION_HANDOFF. Two generated transparent sprite atlases replace geometric weapon/pet icons; preserve exact catalog order, cached texture API and runtime import configs. Seven relevant suites rerun; no gameplay/save/economy changes.
