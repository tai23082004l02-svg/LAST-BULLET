# Trang bị, pet, phó bản — v1.0.0

Đây là luồng đã triển khai, thay cho các đề xuất trước đó. Vào ĐỒ & PET ở sảnh; giữ nguyên 12 vũ khí, 16 nâng cấp trong trận, kéo để né/thả để bắn (tùy chọn bắn khi chạy) và nhấn đúp dùng skill.

## Trang bị
12 mẫu = ba bộ Băng hà/Thành trì/Hỏa ngục × bốn ô Giáp/Lõi/Bộ đẩy/Chip. Mỗi mẫu có 4 độ hiếm: Thường xám, Hiếm xanh, Sử thi tím, Huyền thoại vàng. Cấp +0…+10 độc lập với độ hiếm. Có một món Thường khởi đầu mỗi ô, không tự mặc. Đây là quyền khởi đầu theo schema một lần; làm trống kho không nhận lại.

Chỉ số mỗi món: Giáp +1+rarity+floor(level/5) HP; Lõi +3%*(rarity+1)+.4%*level damage; Bộ đẩy cùng công thức tăng tốc; Chip +2%*(rarity+1)+.3%*level crit. rarity=0…3. Hiếm trở lên giảm hồi kỹ năng1%*(rarity+1)/món. Sử thi Băng thêm.15s lạnh, Thành trì có khiên lúc còn nửa máu hồi20s, Hỏa thêm.15 burn DPS. Huyền thoại Băng thêm15% sát thương lên địch lạnh; Thành trì đẩy lùi lúc chặn; Hỏa tạo nổ khi hạ địch cháy. Hiệu ứng Huyền thoại theo bộ không nhân nhiều lần cùng cờ.

Nâng cấp kế tiếp tốn20*(level+1)*(rarity+1) vàng và2*(level+1) vật liệu. Admin miễn phí, không tạo đầu tư giả để hoàn vàng. Chỉ thao tác trong sảnh. Mặc/tháo, khóa bảo vệ, xem nguồn và tách đồ có xác nhận; không tách đồ khóa/đang mặc. Tách hoàn đầu tư thật và4*(rarity+1) vật liệu.

## Hợp nhất
Chọn món chính, hai nguyên liệu cùng mẫu/độ hiếm, xem trước rồi xác nhận. Thành công100%, Huyền thoại là tối đa. Tự chọn ưu tiên cấp thấp rồi ID. Nguyên liệu khóa/đang mặc bị loại; món chính có thể đang mặc/khóa và giữ ID/trạng thái. Giữ cấp cao nhất; giữ đầu tư của món cấp cao nhất và hoàn vàng/vật liệu đầu tư của hai món dư. Giữ nguyên trạng thái trước khi xác nhận; mọi điều kiện kiểm tra lại khi thực hiện. Gọi lại không thể tiêu thụ/hoàn cùng hai món lần nữa.

Preset tham chiếu nguyên liệu đã ghép được chuyển sang món chính; tách đồ gỡ tham chiếu khỏi preset. Kho tối đa500 món; càn quét yêu cầu đủ chỗ cho số lượt để không tiêu vé khi không thể chứa batch. Boss khi đầy kho đổi phần đồ không thêm được thành vật liệu; không xóa đồ cũ.

## Bộ lưu sẵn và thưởng bộ
Ba preset Đánh boss/Dọn quái/Sinh tồn lưu bốn món, pet và vũ khí; kiểm tra đồ còn tồn tại trước khi thay cả bộ. Đổi trong sảnh. Thưởng bộ2/4: Băng tăng lạnh/.4s rồi+10% damage; Thành trì+1HP rồi khiên thấp máu20s; Hỏa+8% damage rồi+.5 burn DPS. Đồ rời vẫn có chỉ số/hiệu ứng theo chất lượng. Hiệu ứng dùng trong thực chiến và phòng thử, không chỉ cộng số trên UI.

## Pet
Mang một, không hitbox/cản đường, không có nút riêng:
- Bee (Thường, khởi đầu): bắn mỗi1s,65% primary damage.
- Magnet (Hiếm, clear ải1): hút XP tầm240 thay115, gom XP còn trên sân mỗi6s.
- Medic (Sử thi, clear ải2): hồi1 HP khi thiếu, mỗi22s, tối đa3 lần/run.
- Bulwark (Hiếm, clear ải3): chặn một đòn khi sẵn sàng, hồi16s.
- Frostling (Sử thi, clear ải4): chill nhóm trong110 quanh mục tiêu mỗi8s; phối hợp bộ Băng.
- Bomber (Huyền thoại, clear ải5): chọn vùng đông địch, nổ100 radius mỗi7s,1.8x primary damage, tôn trọng cover.

Pet/bộ hiệu ứng ngừng trong pause/upgrade/results. Checkpoint lưu lượt hồi Medic và cooldown tại đầu phòng. Không thêm pet summon riêng. Clear Thường cũ được dùng để cấp pet phù hợp khi migrate. Admin có đủ6.

## Phó bản 5 phòng
Năm khu vực giữ atlas/boss/môi trường. Mỗi lần vào: giao tranh (12+4*stage enemies), tinh anh (5+2*stage,2.2x HP), tiếp tế (hồi2 hoặc một upgrade), sự kiện (+20% damage/-1 maxHP trong run hoặc hồi1), boss. Các phòng đánh cần hạ đủ địch; có giới hạn số sống cùng lúc. XP chưa nhặt được gom khi clear phòng. Hai phòng đánh trả2/4 vật liệu; tinh anh45% rơi một món Hiếm. Mỗi clear combat room có chọn nâng cấp, giữ build qua phòng.

Khó yêu cầu clear Thường tương ứng (admin bỏ qua), HP1.65x; boss thêm hai tia fan và đạn260 thay220, ranged mobs fan3 thay1, nhịp bắn nhanh20%. Sao riêng Thường/Khó: thắng, còn>=60% maxHP, hoàn thành<=300s. Không khóa người chơi bằng thời gian chờ spawn boss. Thời lượng/difficulty là giá trị playtest, chưa hứa mỗi run dài3–5 phút trên điện thoại.

Boss first clear: base gold40+20*stage (Khó1.5x), mats8+2*stage (Khó1.5x),3 vé summon và món Sử thi; Thường mở pet tiếp theo. Chơi lại1 vé summon, cùng base gold/mats, chance gear35%/55% Thường/Khó. Khi rơi: common80/65%, rare18/27%, epic2/8%. Legendary không rơi trực tiếp, cần hợp nhất (admin có sẵn). Stage0/1/2/3 tập trung Thành trì/Băng/Hỏa/Băng; stage4 cả ba bộ. Thưởng kill/time/mission là phần thêm khi chơi tay, không được giả lập thành score bởi càn quét.

## Checkpoint và ngân hàng thưởng
Nút Chơi ngay ưu tiên tiếp tục. Checkpoint lưu đầu phòng: HP, build/gear/pet/weapon, XP/level, score/kills/time, trạng thái nhiệm vụ/mốc và cooldown pet/skill. Resume khởi động lại phòng hiện tại, không khôi phục từng viên đạn/địch. Đang chọn nâng cấp phòng hoặc nâng XP thì giữ đúng lựa chọn; nâng đã chọn không mất khi quay lại đầu phòng. Bắt đầu mới thay checkpoint, thất bại/clear kết thúc nó. Practice/Survival không ghi đè checkpoint Campaign.

Gear/vật liệu và mission gold/tickets đã nhận giữ khi thua. Room/mission/milestone receipts chặn trả trùng khi replay sau thoát đột ngột; phần mission gold đã bank vẫn được tính đúng cho x2 cuối run. Lịch sử receipt giới hạn1500, bảo vệ run checkpoint đang lưu. Profile ghi toàn bộ config qua file.tmp rồi rename, tránh ghi dở một nửa inventory/cost/receipt. Đây là lưu local, không phải bảo vệ chống sửa file/đồng hồ.

## Càn quét
Cần3 sao đúng difficulty, tiêu1 vé quét/lượt. Chọn1/5/10, nhận ngay kết quả gộp. Dùng chính hàm loot boss chơi lại: base gold/mats,1 vé summon/lượt, chance gear trên. Không first-clear bundle/pet mới/stars/score/unlock/x2; không tự ghép/tách đồ. Nút UI chặn duplicate click cùng trang kết quả; mở lại trang là yêu cầu mới. Không đủ vé/điều kiện/chỗ kho thì không tiêu gì. Admin miễn điều kiện/vé nhưng vẫn nhận cùng loot table.

5 vé quét/ngày UTC, một lần/profile; mỗi mission trận thêm1 vé quét bên cạnh15 vàng+1 vé summon. Không có thể lực, quảng cáo hay thanh toán.

## Thư viện và khu thử
Thư viện hero7/weapon12/gear12/pet6/monster6/boss5. Hero/pet/gear sáng khi đang sở hữu; weapons12 mở sẵn nên sáng; quái/boss sáng sau gặp, clear cũ cũng mở boss tương ứng. Bộ lọc tất cả/đã có(chạm gặp)/chưa có, tiến độ nhóm, chi tiết ảnh/tên/rarity/mô tả, nguồn gear/pet. Không phân tích điểm yếu hay nguyên nhân thất bại.

Phòng thử bia đơn/nhóm5/boss đứng yên: mẫu10s, đo actual damage/DPS sau block/bonus, pet/gear có tác dụng. Không trả bất kỳ thưởng/record/XP nào, giữ checkpoint đang dở. Admin thêm nút mẫu max-upgrade. Lab boss/địch cũ vẫn có để thử đánh thật.

## Giữ dữ liệu và kiểm tra
Bốn starter common, Bee và30 mats cấp một lần theo schema; không cấp lại khi bag rỗng. Admin có48 biến thể gear (12×4 rarity),6pet, nâng miễn phí và nút tạo nguyên liệu thử hợp nhất. Vẫn tách records.cfg / records-admin.cfg / records-mode.cfg. Vàng/robot/skin/summon/pity/normal stars và gear/loadout cũ được giữ. Đổi avatar/profile không copy admin vào normal.

17 suites hiện tại và import trên Godot4.6.3 Linux pass, gồm fusion/refund/cost guard, checkpoint replay, all rooms/Hard/rewards/sweep, pets/sets/presets/library/practice, max-build stress. Xem TEST_RESULTS.md. Rendered360×640/800 qua Xvfb/Mesa. Chưa test Android vật lý, FPS/thermal/battery, APK hay độ khó với người chơi; cần feedback S23 Ultra.
