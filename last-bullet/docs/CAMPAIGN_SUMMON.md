# v0.6.0 — Campaign & Robot Summon

## Chơi chiến dịch
**PLAY → CAMPAIGN → chọn màn → START STAGE.** Chế độ thường mở từ màn 1; hạ boss để mở màn kế tiếp. Admin chọn thẳng cả 5 màn.

Mỗi màn có 3 đợt giao tranh trong cùng đấu trường, sau đó là boss. Hai lần chuyển đợt được thêm một lựa chọn nâng cấp; XP vẫn lên cấp bình thường. Nâng cấp giữ trong màn, reset khi Retry/Next Stage. Thời gian dừng khi pause, chọn nâng cấp hoặc mở admin.

| Màn | Boss xuất hiện | Đấu trường / boss |
|---|---|---|
| 1 · Training Bay | 90 giây | Sân thoáng; Sentinel báo hướng rồi lao tới |
| 2 · Reflection Works | 105 giây | Hai cột phản xạ có va chạm; Mirror Warden quay khiên trước, 3 giây bật / 3 giây tắt |
| 3 · Energy Furnace | 120 giây | Ô sàn cảnh báo 1,2 giây rồi nóng 2 giây; Furnace Heart đánh dấu vị trí để tấn công vùng |
| 4 · Magnetic Station | 120 giây | Hai vùng từ trường uốn đường đạn nhẹ; Polaris thêm đòn vùng khóa vị trí |
| 5 · Machine Core | 135 giây | Kết hợp cột, sàn nóng và từ trường; Core Prime giữ/thả cùng viên đạn, lộ lõi 3 giây cho đòn phản x4; dưới nửa máu thêm đòn lao |

Boss có sprite riêng trong `art/neon/campaign.png`. Vật cản chặn người, địch, đạn; địch đi vòng nhờ đồ thị đường đi có cache. Sàn nóng/từ trường đều có hình cảnh báo; Time Warp làm chậm địch nhưng không kéo dài cảnh báo sàn. Không sinh viên đạn gameplay thứ hai.

Thời lượng 2–3 phút/màn là mục tiêu cân bằng ban đầu; giao tranh boss không có hạn chót và cần playtest thực tế. Chết thì Retry cả màn. Hạ boss là thắng ngay, không cần dọn thêm địch.

### Thưởng và tiến trình
- Thắng: mở màn tiếp; 1 sao hoàn thành, thêm 1 sao nếu còn ít nhất 3 HP, thêm 1 sao nếu đạt 3 Perfect. Lưu số sao cao nhất.
- Thưởng vàng thêm khi thắng: 40 / 60 / 80 / 100 / 120 theo màn, cộng vàng kết quả/nhiệm vụ cũ.
- Lần đầu thắng từng màn: **3 vé summon**. Thắng lại: **1 vé**, không lặp gói lần đầu.
- X2 vàng vẫn nhận ngay một lần ở kết quả, chỉ nhân đôi vàng; không nhân vé hay mảnh.
- Điểm chiến dịch không ghi đè kỷ lục Survival. Admin dùng profile riêng như trước.

## Summon
**Menu → SUMMON**. Không có tiền thật, SDK quảng cáo hay cuộc gọi online.

- Mỗi profile có **5 vé khởi đầu** khi chuyển từ save cũ sang hệ thống mới.
- +1 vé mỗi nhiệm vụ trong trận (15 kills / 3 Perfect / chain 10), mỗi nhiệm vụ một lần/trận.
- +1 vé khi đạt 120 giây; +1 khi đạt 30 kills, mỗi mốc một lần/trận.
- Hoàn thành đủ Blitz 90 giây: +1 vé. Campaign theo thưởng thắng ở trên.
- Quay ×1 tốn 1 vé, ×10 tốn 10 vé, mỗi lượt chắc chắn có robot. Admin quay miễn phí.

| Độ hiếm | Tỷ lệ cơ bản | Robot | Robot trùng | Đổi chọn thẳng |
|---|---|---|---|---|
| Rare | 75% | Volt / Cobalt / Scout, mỗi mẫu 25% | +5 mảnh | 30 mảnh |
| Epic | 20% | Frost / Ember, mỗi mẫu 10% | +15 mảnh | 90 mảnh |
| Legendary | 5% | Nova | +50 mảnh | 300 mảnh |

Aegis vẫn miễn phí, không ở trong pool. Mảnh là tài nguyên robot dùng chung, có thể tích để chọn nhân vật thiếu trong **ROBOTS → EXCHANGE**. Chỉ đổi được robot chưa sở hữu; equip robot đã có không tốn gì. Các robot vẫn cùng stats/hitbox.

### Bảo hiểm
- Sau 9 lượt chỉ ra Rare, lượt kế chắc chắn Epic trở lên: nếu kết quả cơ bản là Rare thì nâng lên Epic. Legendary vẫn có thể xuất hiện.
- Sau 49 lượt chưa có Legendary, lượt 50 chắc chắn Legendary, được ưu tiên hơn bảo hiểm Epic.
- Epic reset bộ đếm Epic+. Legendary reset cả hai. Hai bộ đếm và tổng lượt được lưu xuyên phiên, tách giữa profile thường/admin.
- 75/20/5 là tỷ lệ **cơ bản trước bảo hiểm**; các lượt được bảo hiểm có phân phối khác.

### Hoạt ảnh, lưu và chống nhận lặp
Khoang robot có hoạt ảnh 1,6 giây, ánh sáng theo độ hiếm, nút Skip và màn kết quả/ảnh nhân vật. Lượt ×10 hiển thị mẫu hiếm nhất ở portrait và danh sách đủ 10 kết quả, cuộn để xem hết.

Vé, pity, ownership, mảnh và biên nhận được cập nhật chung trong save **trước** hoạt ảnh. Skip/review không quay lại, không trừ vé và không tặng lại. Đóng game trong lúc hoạt ảnh rồi mở lại có thể xem **LAST RESULTS**. Các kiểm tra đã mô phỏng nạp lại sau khi bắt đầu reveal; chưa kiểm tra mất điện đúng lúc ghi file.

### Save cũ
Tất cả robot/skin và tiền đã sở hữu được giữ nguyên. Từ v0.6, robot mới mở bằng summon hoặc mảnh, thay cho giá xu ở v0.5; skin đạn vẫn dùng xu. Không thu hồi robot đã mua, không tự đổi robot cũ thành mảnh.

## Admin và cách test nhanh
Bật ADMIN như trước: được chọn tất cả màn, tất cả robot/skin và summon miễn phí. Vì admin đã sở hữu mọi robot, kết quả summon của admin thường là duplicate/mảnh; muốn test sưu tầm thực, chuyển **RETURN TO NORMAL MODE**. Inventory và pity của hai profile không trộn.

Trong màn campaign: Pause → ADMIN TOOLS → SUMMON BOSS để gọi đúng boss của màn ngay. Có thể tắt god mode trong TEST OPTIONS để test sát thương sàn/địch.
