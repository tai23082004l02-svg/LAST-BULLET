# Godot Android + Termux/Git

Cập nhật 2026-11-05. Thiết bị: Samsung Galaxy S23 Ultra. Người dùng đã clone thành công bằng HTTPS, import và chạy dự án trong Godot Android, sau đó xác nhận vào được chế độ dọc. Chưa ghi nhận chính xác phiên bản Godot Android hoặc thao tác nào đã giải quyết xoay màn hình.

## Thiết lập đã thực hiện

Termux cài từ F-Droid. Cài Git và cấp quyền bộ nhớ:

```bash
pkg update && pkg upgrade -y
pkg install git -y
termux-setup-storage
```

Chấp nhận quyền truy cập bộ nhớ. Khi nâng cấp hỏi giữ cấu hình openssl.cnf hoặc sources.list, người dùng đã chọn N để giữ cấu hình hoạt động. Các thông báo SSH khi cài gói không yêu cầu thiết lập SSH để clone HTTPS repository công khai.

```bash
mkdir -p ~/storage/downloads/GodotProjects
cd ~/storage/downloads/GodotProjects
git clone https://github.com/tai23082004l02-svg/LAST-BULLET.git
```

Trong Godot: Import → Bộ nhớ trong/Download/GodotProjects/LAST-BULLET/last-bullet/project.godot → Import & Edit → Run. Cho phép truy cập thư mục nếu được hỏi.

## Mỗi lần cập nhật

Dừng game và đóng dự án trong Godot trước, rồi mở Termux:

```bash
cd ~/storage/downloads/GodotProjects/LAST-BULLET
git pull --ff-only
```

Mở lại dự án trong Godot; không cần clone, tải ZIP hoặc import lại. Already up to date nghĩa là đã có bản mới nhất.

Nếu Git báo dubious ownership trên bộ nhớ chia sẻ, chỉ thêm chính thư mục repository này:

```bash
git config --global --add safe.directory /storage/emulated/0/Download/GodotProjects/LAST-BULLET
```

Không đặt safe.directory thành dấu *.

## Khi pull bị chặn

Dừng lại và lấy thông tin:

```bash
git status --short
git diff --stat
```

Gửi lỗi và kết quả cho trợ lý. Không tự reset --hard, git clean hoặc discard toàn bộ. Godot có thể sửa project.godot hoặc tạo .import; cần phân biệt file sinh tự động với thiết lập import và thay đổi thật. Bảo toàn thay đổi trước khi xử lý. Không đưa mật khẩu/token vào ảnh hoặc chat.

## Màn hình dọc

Game thiết kế portrait. Trong Editor nhúng ở hướng ngang, game dọc có thể bị thu nhỏ và có viền hai bên. Đã hướng dẫn bật Tự động xoay của Samsung, xoay máy đứng và thử nút mở rộng vùng chạy (biểu tượng bốn góc). Người dùng xác nhận đã vào được, nhưng chưa xác định riêng thao tác nào có tác dụng. Không khẳng định mọi phiên bản Editor đều tự xoay. APK độc lập là lựa chọn tương lai; phiên này chưa build hoặc xác minh APK.

GitHub Android không thay thế GitHub Desktop để đồng bộ thư mục Godot; Termux/Git đảm nhiệm clone/pull.
