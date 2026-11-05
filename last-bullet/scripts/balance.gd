class_name Balance
extends RefCounted

static var ARENA := Rect2(30, 165, 660, 855)
const PLAYER_SPEED := 290.0
const MAX_ENEMIES := 48
const COMBO_WINDOW := 3.0
const UPGRADE_NAMES := ["Hỏa lực", "Tốc xạ", "Đa đạn", "Chí mạng", "Đạn cháy", "Xuyên giáp", "Đạn liên hoàn", "Hồi kỹ năng","Đạn chéo","Đạn sau lưng","Nảy tường","Nọc độc","Đạn lạnh","Đạn nổ","Drone hộ vệ","Lưỡi xoay"]
const UPGRADE_INFO := ["Mỗi phát bắn gây nhiều sát thương hơn.", "Bắn nhanh hơn cả khi đang di chuyển.", "Thêm đường đạn vào mỗi loạt bắn.", "Có cơ hội gây sát thương gấp 1.8 lần.", "Đạn trúng gây cháy trong 2 giây.", "Đạn xuyên thêm địch trước khi biến mất.", "Đạn nảy sang địch gần, không xuyên tường.", "Dùng kỹ năng riêng thường xuyên hơn.","Thêm hai đường chéo, mỗi viên gây 70% sát thương.","Bắn thêm một viên phía sau, gây 80% sát thương.","Đạn thường nảy tường hữu hạn; tên lửa/lựu vẫn nổ.","Gây độc trong 3 giây, cộng dồn cùng cháy.","Làm chậm; kết hợp cháy tạo sốc nhiệt.","Đạn trúng nổ lan, không xuyên qua trụ chắn.","Drone tự bắn cả khi bạn đang di chuyển.","Lưỡi dao quay quanh robot để đánh địch gần."]
const UPGRADE_CAPS := [5,5,3,5,5,3,3,3,1,1,2,3,3,3,2,3]
const SKIN_NAMES := ["Plasma", "Meteor", "Electric", "Starlight"]
const SKIN_COSTS := [0,30,60,90]
const SKIN_COLORS := [Color("64f7ff"),Color("ffb55e"),Color("bc9cff"),Color("fff3a6")]

static func empty_upgrades() -> Array[int]:
	var result: Array[int] = []
	result.resize(UPGRADE_CAPS.size())
	result.fill(0)
	return result
