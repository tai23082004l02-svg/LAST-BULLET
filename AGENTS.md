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
