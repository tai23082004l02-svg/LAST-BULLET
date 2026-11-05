# Bàn giao LAST BULLET

Cập nhật 2026-11-05. Repository: tai23082004l02-svg/LAST-BULLET, nhánh main.
Bản game hiện tại: v0.7.0; commit triển khai giao diện: 1e47952e728e18aea7eb9fbed88908f871d02f03.
Phiên này bổ sung tài liệu quy trình, không thay đổi gameplay.

## Yêu cầu và cách làm việc

Người dùng dùng tiếng Việt, muốn triển khai cụ thể và cập nhật GitHub khi đã yêu cầu làm; không hỏi lại những lựa chọn triển khai thường lệ. Giữ ý định của yêu cầu mới nhất. Người dùng đã chuyển từ GitHub Desktop PC sang thêm Termux/Git trên Samsung S23 Ultra để cập nhật mà không tải ZIP mỗi lần. Đọc ANDROID_TERMUX.md để biết đường dẫn và lệnh đã dùng.

## Trạng thái sản phẩm

- Godot 4, game 2D portrait, phong cách robot neon arcade đã được người dùng duyệt.
- Một viên đạn tồn tại liên tục, phản xạ/deflect, perfect streak, XP, 8 nâng cấp, nhiều loại địch và boss.
- Survival, Reflector và Blitz 90 giây; 5 màn chiến dịch với boss/cơ chế riêng, sao và mở khóa.
- 7 robot, 4 skin đạn. Summon ×1/×10, vé, tỷ lệ gốc 75/20/5, pity Epic+ 10 và Legendary 50, robot trùng thành mảnh, đổi robot bằng mảnh. Giữ quyền sở hữu cũ.
- Admin local mở toàn bộ, quay miễn phí và có phòng thử; không phải tài khoản/quyền máy chủ.
- X2 vàng nhận ngay sau trận, chỉ một lần, đúng profile. Người dùng đã bác bỏ cả quảng cáo thật lẫn quảng cáo mô phỏng; không thêm lại.
- v0.7.0: robot lớn vuốt xem, Chơi ngay, chọn màn/chế độ, tài nguyên phía trên, thanh dưới Sảnh/Robot/Summon/Ngoại hình. Admin trong avatar góc trái; bánh răng mở cài đặt. Preview không tự equip; equip chỉ khi sở hữu.
- Nhiệm vụ phản ánh tiến độ và thưởng tự động hiện có. Mục phần thưởng dùng quyền x2 chưa nhận của trận vừa kết thúc; không tạo thêm thưởng giả.

## File chính và lưu dữ liệu

- project.godot, scenes/Main.tscn.
- scripts/game.gd: vòng chơi, UI trang phụ, điều hướng, lưu profile, kết nối lobby.
- scripts/mobile_lobby.gd: shell sảnh và layout; không sở hữu logic thanh toán phần thưởng.
- Các hệ thống khác ở scripts/; đọc mã hiện tại trước khi thay đổi.
- user://records.cfg, records-admin.cfg, records-mode.cfg: tiến trình thường, admin và chế độ. Đây là dữ liệu thiết bị, không đưa lên GitHub.
- art/neon/: tài nguyên runtime; docs/previews/: ảnh kiểm tra; art/concepts/: concept đã duyệt.

## Kiểm tra đã có

Tự động trên Linux, Godot 4.6.3: features, smoke, expansion, reflector_stress, graphics, admin_mobile, robots, summon, campaign và lobby đều pass ở v0.7.0. Xem TEST_RESULTS.md. Import:

```bash
godot --headless --path last-bullet --editor --import --quit
godot --headless --path last-bullet --script res://tests/lobby.gd
```

Bố cục được render/kiểm tra qua Xvfb/Mesa, gồm 360×640 và 360×800. Sau đó người dùng xác nhận mở và chạy được trên S23 Ultra, rồi xác nhận vào được dọc. Đây chưa phải kiểm tra toàn bộ cảm ứng, gameplay, FPS, nhiệt, pin hoặc APK. Không quảng cáo rằng đã benchmark máy thật.

## Git và lỗi từng gặp

GitHub Desktop từng chặn pull vì project.godot bị sửa tại máy và .png.import chưa track trùng file incoming. Đã thêm docs/.gdignore, art/concepts/.gdignore, bỏ import ảnh preview khỏi Git, cấu hình ignore và LF trong .gitattributes. Giữ bản sửa này. Runtime art/neon/*.import có thể chứa cấu hình cần thiết; không xóa hàng loạt mọi .import.

Luôn kiểm tra HEAD mới nhất trước push, bảo toàn dữ liệu và thay đổi người dùng. Nếu cập nhật ref qua GitHub API, dùng expected_sha và force=false. Không ghi đè commit mới. Đưa link ảnh/tài liệu GitHub trong câu trả lời để người dùng mở được trên điện thoại.

## Trạng thái cuối phiên

Người dùng đã clone repository, import/chạy được Godot Android và xác nhận chế độ dọc đã hoạt động. Yêu cầu mới nhất là lưu quy trình lên GitHub cho phiên chat tiếp theo. Không có lỗi đang chờ xử lý hoặc yêu cầu gameplay mới trong bước bàn giao này.

## Latest touch-control update

The user requested an Archer Hunter-style hidden floating joystick after finding the bottom-left control uncomfortable on S23 Ultra. Movement now starts with a drag anywhere in the left half below the HUD. The ring is hidden while idle and shown only during touch; release stops movement. See TOUCH_CONTROLS.md. This supersedes the previous bottom-only stick placement. Automated touch/drag/second-finger/release checks pass; await user comfort feedback on device.

## Correction: full-screen movement gestures

The user clarified that movement must start anywhere on the screen, not just the left half. All blank screen space inside the safe area can now start the hidden floating joystick. Pause and Deflect explicitly exclude their button rectangles, and GUI buttons keep their normal event handling. Passive progress bars ignore pointer input. The ring follows touches on either side; initial touch remains the movement anchor. Existing multi-touch ownership and release behavior are preserved. Automated tests now exercise a right-side drag, both button exclusions and safe-area bounds. This supersedes left-half-only descriptions above; physical-device feel awaits user confirmation.

## Latest results-screen redesign

Implemented the approved compact mobile results screen; read RESULTS_UI.md. Three stat tiles, robot/stars, reward row, once-only immediate x2, retry/next-stage primary CTA, stage/home secondary actions, collapsible advanced stats. Tested results/campaign/features/lobby and rendered 360×640/800; await physical-device feedback. Touch controls remain drag-anywhere except buttons, with a 12-logical-pixel activation threshold; a tap alone does not activate the ring or movement.

## Latest upgrade-screen redesign

Implemented the approved compact mobile upgrade selector; read UPGRADE_UI.md. Vietnamese cards, before/after stats, functional colors, centered safe-area panel and dark input-blocking backdrop. HUD/missions/controls hide and combat pauses. One card selection resumes, resets movement and remains guarded against repeat claims. Tests upgrade_ui/features/campaign/results/admin_mobile pass; rendered 360×640/800. Touch remains drag-anywhere except buttons, activated after 12 logical pixels; do not revert to left-only or tap-to-move.
