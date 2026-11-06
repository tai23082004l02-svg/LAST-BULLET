extends Node
const View = preload("res://scripts/collectible_view.gd")
const RPG = preload("res://scripts/progression.gd")
var game: Node2D
var fusion_base := -1
var fusion_picks: Array[int] = []
var library_group := "hero"
var library_filter := 0
var gear_slot := -1
var gear_page := 0
var sweep_inflight := false
func page(title: String, info := "") -> void:
	game.show_menu()
	game.clear_cards(title,info)
	game.cards.add_theme_constant_override("separation",12)
func button(text: String, action: Callable, enabled := true) -> Button:
	var b: Button = game.add_button(text,action)
	b.custom_minimum_size.y = 84; b.disabled = not enabled
	return b
func text(value: String, size := 24, color := Color("b7d4df")) -> Label: return game.result_label(game.cards,value,size,color)
func picture(group: String, index: int, rarity := 0, owned := true, height := 160) -> Control:
	var art := View.new()
	art.group = group; art.index = index; art.rarity = rarity; art.owned = owned
	art.custom_minimum_size = Vector2(0,height)
	game.cards.add_child(art)
	return art
func wallet() -> String: return "%d vàng • %d vật liệu • %d vé càn quét" % [game.coins,game.progress.materials,game.progress.sweep_tickets]
func hub() -> void:
	page("HÀNH TRANG",wallet())
	var grid := GridContainer.new(); grid.columns = 2; grid.add_theme_constant_override("h_separation",12); grid.add_theme_constant_override("v_separation",12); game.cards.add_child(grid)
	for row in [["TRANG BỊ & HỢP NHẤT","gear",4,gear],["PET ĐỒNG HÀNH","pet",game.progress.pet,pets],["NÂNG NHÂN VẬT","hero",game.selected_robot,hero_training.bind(game.selected_robot)],["VẬT PHẨM HỖ TRỢ","item",0,supplies],["BỘ TRANG BỊ","gear",1,presets],["THƯ VIỆN SƯU TẦM","hero",4,library],["PHÓ BẢN & CÀN QUÉT","skill",5,game.show_campaign],["KHU THỬ TRANG BỊ","weapon",4,practice]]:
		tile(grid,row[0],row[1],row[2],row[3],false,156,275)
	button("NHẬN 5 VÉ CÀN QUÉT NGÀY (UTC)",daily,game.progress.daily_day != Time.get_date_string_from_system(true))
	button("NGOẠI HÌNH ĐẠN",game.show_skins)

func tile(parent: Node, title: String, group: String, index: int, callback: Callable, selected := false, height := 156, width := 182) -> Button:
	var b := Button.new(); b.focus_mode = Control.FOCUS_NONE; b.custom_minimum_size = Vector2(width,height)
	NeonArt.style_button(b,Color("86eadc"),selected); b.pressed.connect(callback); parent.add_child(b)
	var art := View.new(); art.group = group; art.index = index; art.rarity = 2 if selected else 0; art.position = Vector2(8,2); art.size = Vector2(width-16,height-48); b.add_child(art)
	var label := Label.new(); label.text = ("✓ " if selected else "")+title; label.mouse_filter = Control.MOUSE_FILTER_IGNORE; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; label.position = Vector2(8,height-52); label.size = Vector2(width-16,48); label.add_theme_font_size_override("font_size",18); b.add_child(label)
	return b

func daily() -> void:
	if game.state != "menu": return
	if game.progress.claim_daily(Time.get_date_string_from_system(true)): game.save_profile()
	hub()
func gear(slot := -1, page_index := 0) -> void:
	gear_slot = slot
	gear_page = maxi(0,page_index)
	page("KHO TRANG BỊ",wallet()+"\nBốn ô • 4 độ hiếm • +0 đến +10 • chạm món để xem")
	var stats: Dictionary = game.progress.stats(game.selected_robot)
	text("HP %d • sát thương +%d%% • tốc chạy +%d%%" % [int(stats.hp),roundi((stats.damage-1)*100),roundi((stats.speed-1)*100)],22)
	var slots := GridContainer.new(); slots.columns = 4; slots.add_theme_constant_override("h_separation",8); game.cards.add_child(slots)
	for i in range(4):
		var entry: Dictionary = game.progress.item(game.progress.equipped[i])
		var slot_button := tile(slots,RPG.SLOTS[i]+(" +"+str(entry.level) if not entry.is_empty() else ""),"gear",int(entry.kind) if not entry.is_empty() else 4+i,gear.bind(i),i == gear_slot,128,134)
		if entry.is_empty(): (slot_button.get_child(0) as Control).set("owned",false)
	button("TẤT CẢ (%d/500)" % game.progress.items.size(),gear.bind(-1))
	var entries: Array[Dictionary] = []
	for entry in game.progress.items:
		if slot < 0 or int(entry.kind)%4 == slot: entries.append(entry)
	entries.sort_custom(func(a,b): return a.rarity > b.rarity if a.rarity != b.rarity else a.id < b.id)
	var pages := maxi(1,ceili(entries.size()/12.0))
	gear_page = mini(gear_page,pages-1)
	var grid := GridContainer.new(); grid.columns = 3; grid.add_theme_constant_override("h_separation",10); grid.add_theme_constant_override("v_separation",10); game.cards.add_child(grid)
	for entry in entries.slice(gear_page*12,mini(entries.size(),gear_page*12+12)):
		var label := RPG.item_name(entry.kind)+" +%d" % entry.level
		var b := tile(grid,label,"gear",entry.kind,item_detail.bind(int(entry.id)),game.progress.equipped.has(entry.id),156)
		NeonArt.style_button(b,RPG.COLORS[entry.rarity],game.progress.equipped.has(entry.id))
		(b.get_child(0) as Control).set("rarity",int(entry.rarity))
	if pages > 1:
		text("%d / %d" % [gear_page+1,pages],22)
		var navigation := HBoxContainer.new(); navigation.add_theme_constant_override("separation",10); game.cards.add_child(navigation)
		for direction in [-1,1]:
			var action := button("‹" if direction < 0 else "›",gear.bind(gear_slot,gear_page+direction),gear_page+direction in range(pages))
			game.cards.remove_child(action); navigation.add_child(action); action.custom_minimum_size = Vector2(275,76)
	button("VỀ HÀNH TRANG",hub)
func gear_summary(entry: Dictionary) -> String:
	var rarity: int = entry.rarity; var level: int = entry.level
	var value: String
	match int(entry.kind)%4:
		0: value = "+%d HP tối đa" % (1+rarity+level/5)
		1: value = "+%.1f%% sát thương" % ((0.03*(rarity+1)+0.004*level)*100)
		2: value = "+%.1f%% tốc chạy" % ((0.03*(rarity+1)+0.004*level)*100)
		_: value = "+%.1f%% chí mạng" % ((0.02*(rarity+1)+0.003*level)*100)
	if rarity >= 1: value += " • -%d%% hồi kỹ năng" % (rarity+1)
	return value

func item_detail(uid: int) -> void:
	var entry: Dictionary = game.progress.item(uid)
	if entry.is_empty(): gear(); return
	page(RPG.item_name(entry.kind),"%s • +%d • #%d" % [RPG.RARITIES[entry.rarity],entry.level,uid])
	picture("gear",entry.kind,entry.rarity)
	text("Bộ %s • %s" % [RPG.SETS[int(entry.kind)/4],RPG.SLOTS[int(entry.kind)%4]],24,RPG.COLORS[entry.rarity])
	var family: int = int(entry.kind)/4
	text(gear_summary(entry)+"\n"+("ĐANG CÓ: " if entry.rarity >= 2 else "SỬ THI MỞ: ")+["Thêm 0.15 giây làm chậm.","Khiên khi còn nửa máu, hồi 20 giây.","Thêm 0.15 sát thương cháy/giây."][family]+"\n"+("ĐANG CÓ: " if entry.rarity == 3 else "HUYỀN THOẠI MỞ: ")+["+15% sát thương lên địch lạnh.","Khiên vỡ đẩy lùi địch.","Hạ địch cháy tạo vụ nổ."][family],22)
	button("THÁO TRANG BỊ" if game.progress.equipped.has(uid) else "TRANG BỊ",equip.bind(uid))
	var cost: int = 20*(int(entry.level)+1)*(int(entry.rarity)+1)
	var mats: int = 2*(int(entry.level)+1)
	button("NÂNG +%d • %s" % [mini(10,int(entry.level)+1),"ADMIN MIỄN PHÍ" if game.admin_enabled else "%d vàng + %d VL" % [cost,mats]],upgrade.bind(uid),entry.level < 10 and (game.admin_enabled or (game.coins >= cost and game.progress.materials >= mats)))
	button("MỞ KHÓA" if entry.locked else "KHÓA BẢO VỆ",lock_item.bind(uid))
	button("HỢP NHẤT • 3 → 1 • 100%",start_fusion.bind(uid),entry.rarity < 3)
	button("TÁCH THÀNH VẬT LIỆU",confirm_dismantle.bind(uid),not entry.locked and not game.progress.equipped.has(uid))
	if game.admin_enabled and entry.rarity < 3: button("ADMIN: THÊM 2 NGUYÊN LIỆU TEST",admin_duplicates.bind(uid))
	button("NGUỒN KIẾM MÓN NÀY",sources.bind("gear",int(entry.kind)))
	button("VỀ KHO",gear.bind(gear_slot))
func admin_duplicates(uid: int) -> void:
	if not game.admin_enabled or game.state != "menu" or game.progress.items.size() > 498: return
	var entry: Dictionary = game.progress.item(uid)
	if entry.is_empty() or entry.rarity >= 3: return
	for i in range(2): game.progress.add_item(entry.kind,entry.rarity)
	game.save_profile(); item_detail(uid)

func equip(uid: int) -> void:
	if game.state != "menu": return
	var entry: Dictionary = game.progress.item(uid)
	if entry.is_empty(): return
	var slot: int = int(entry.kind)%4
	game.progress.equipped[slot] = -1 if game.progress.equipped[slot] == uid else uid
	game.save_profile(); item_detail(uid)
func lock_item(uid: int) -> void:
	if game.state != "menu": return
	var entry: Dictionary = game.progress.item(uid)
	if entry.is_empty(): return
	entry.locked = not entry.locked; game.save_profile(); item_detail(uid)
func upgrade(uid: int) -> void:
	if game.state != "menu": return
	var result: Dictionary = game.progress.upgrade(uid,game.coins,game.admin_enabled)
	if not result.is_empty(): game.coins -= int(result.gold); game.save_profile()
	item_detail(uid)
func confirm_dismantle(uid: int) -> void:
	var entry: Dictionary = game.progress.item(uid)
	if entry.is_empty(): return
	page("XÁC NHẬN TÁCH",RPG.item_name(entry.kind)+"\nHoàn %d vàng + %d vật liệu. Món này sẽ bị tiêu thụ." % [entry.gold,int(entry.mats)+4*(int(entry.rarity)+1)])
	picture("gear",entry.kind,entry.rarity)
	button("XÁC NHẬN TÁCH",dismantle.bind(uid)); button("HỦY",item_detail.bind(uid))
func dismantle(uid: int) -> void:
	if game.state != "menu": return
	var result: Dictionary = game.progress.dismantle(uid)
	if not result.is_empty(): game.coins += int(result.gold); game.save_profile()
	gear()
func start_fusion(uid: int) -> void:
	fusion_base = uid; fusion_picks.clear(); fusion()
func fusion() -> void:
	var base: Dictionary = game.progress.item(fusion_base)
	if base.is_empty(): gear(); return
	page("HỢP NHẤT",RPG.item_name(base.kind)+" • "+RPG.RARITIES[base.rarity]+"\nGiữ món chính đang mặc và khóa bảo vệ. Chọn 2 món cùng tên và độ hiếm; không dùng đồ khóa/đang mặc làm nguyên liệu.")
	picture("gear",base.kind,mini(3,int(base.rarity)+1),true,130)
	var preview: Dictionary = game.progress.fusion_preview(fusion_base,fusion_picks)
	if preview.is_empty(): text("Đã chọn %d/2 nguyên liệu" % fusion_picks.size())
	else: text("→ %s +%d\nHoàn %d vàng + %d vật liệu\nThành công 100%% • không mất cấp cao nhất" % [RPG.RARITIES[preview.rarity],preview.level,preview.gold,preview.mats],24,RPG.COLORS[preview.rarity])
	button("XÁC NHẬN HỢP NHẤT",fuse,not preview.is_empty())
	button("TỰ CHỌN • ƯU TIÊN MÓN +0",auto_fusion)
	for entry in game.progress.items:
		if entry.id == fusion_base or entry.kind != base.kind or entry.rarity != base.rarity or entry.locked or game.progress.equipped.has(entry.id): continue
		button(("✓ " if fusion_picks.has(entry.id) else "")+"#%d • +%d" % [entry.id,entry.level],pick_fusion.bind(int(entry.id)))
	button("HỦY",item_detail.bind(fusion_base))
func auto_fusion() -> void:
	fusion_picks = game.progress.fusion_candidates(fusion_base); fusion()
func pick_fusion(uid: int) -> void:
	if fusion_picks.has(uid): fusion_picks.erase(uid)
	elif fusion_picks.size() < 2: fusion_picks.append(uid)
	fusion()
func fuse() -> void:
	if game.state != "menu": return
	var result: Dictionary = game.progress.fuse(fusion_base,fusion_picks)
	if not result.is_empty(): game.coins += int(result.gold); game.save_profile()
	fusion_picks.clear(); item_detail(fusion_base)
func pets() -> void:
	page("PET ĐỒNG HÀNH","Mang một pet • tự động hỗ trợ • không cản đường\nBEE có sẵn. Các pet tiếp theo mở khi qua lần đầu 5 ải.")
	picture("pet",game.progress.pet,[0,1,2,1,2,3][game.progress.pet],true,210)
	text(RPG.PETS[game.progress.pet]+" • "+RPG.PET_INFO[game.progress.pet],22)
	var grid := GridContainer.new(); grid.columns = 3; grid.add_theme_constant_override("h_separation",10); grid.add_theme_constant_override("v_separation",10); game.cards.add_child(grid)
	for i in range(6):
		var owned: bool = game.progress.pets.has(i)
		var b := Button.new(); b.focus_mode = Control.FOCUS_NONE; b.custom_minimum_size = Vector2(182,190)
		NeonArt.style_button(b,Color("83ead6") if owned else Color("4a5f70"),game.progress.pet == i)
		b.pressed.connect(pet_detail.bind(i)); grid.add_child(b)
		var art := View.new(); art.group = "pet"; art.index = i; art.owned = owned; art.rarity = [0,1,2,1,2,3][i]; art.position = Vector2(5,5); art.size = Vector2(172,126); b.add_child(art)
		var label := Label.new(); label.text = RPG.PETS[i]+"\n"+("ĐỒNG HÀNH" if game.progress.pet == i else "ĐÃ CÓ" if owned else "CHƯA MỞ")
		label.position = Vector2(5,132); label.size = Vector2(172,55); label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; label.mouse_filter = Control.MOUSE_FILTER_IGNORE; label.add_theme_font_size_override("font_size",18); b.add_child(label)
	button("VỀ HÀNH TRANG",hub)
func pet_detail(index: int) -> void:
	var owned: bool = game.progress.pets.has(index)
	page(RPG.PETS[index],RPG.RARITIES[[0,1,2,1,2,3][index]]+" • "+("ĐÃ CÓ" if owned else "CHƯA MỞ"))
	picture("pet",index,[0,1,2,1,2,3][index],owned,230)
	text(RPG.PET_INFO[index]+"\nTự động hỗ trợ, không thêm nút bấm.")
	button("ĐANG ĐỒNG HÀNH" if game.progress.pet == index else "TRANG BỊ PET",equip_pet.bind(index),owned and game.progress.pet != index)
	button("NGUỒN MỞ KHÓA",sources.bind("pet",index))
	button("VỀ PET",pets)

func equip_pet(index: int) -> void:
	if game.state != "menu" or not game.progress.pets.has(index): return
	game.progress.pet = index; game.save_profile(); pets()
func presets() -> void:
	page("BỘ TRANG BỊ",wallet()+"\nLưu/đổi cả 4 món, pet và vũ khí. Chỉ đổi ở sảnh.")
	var stats: Dictionary = game.progress.stats(game.selected_robot)
	for i in range(3):
		text("%s: %d/4 món • %s" % [RPG.SETS[i],stats.sets[i],"ĐỦ BỘ 4" if stats.sets[i] >= 4 else "BẬT BỘ 2" if stats.sets[i] >= 2 else "CHƯA ĐỦ"],24)
	text("Băng 2: tăng lạnh • 4: +10% sát thương\nThành trì 2: +1 HP • 4: khiên thấp máu mỗi 20s\nHỏa ngục 2: +8% sát thương • 4: tăng cháy",22)
	for i in range(3):
		text(["ĐÁNH BOSS","DỌN QUÁI","SINH TỒN"][i],28)
		button("LƯU BỘ HIỆN TẠI",save_preset.bind(i))
		button("TRANG BỊ BỘ ĐÃ LƯU",load_preset.bind(i),not game.progress.presets[i].is_empty())
	button("VỀ HÀNH TRANG",hub)
func save_preset(index: int) -> void:
	if game.state != "menu": return
	game.progress.presets[index] = {"gear":game.progress.equipped.duplicate(),"pet":game.progress.pet,"weapon":game.selected_weapon}
	game.save_profile(); presets()
func load_preset(index: int) -> void:
	if game.state != "menu": return
	var preset: Dictionary = game.progress.presets[index]
	if not preset.get("gear") is Array or preset.gear.size() != 4 or not game.progress.pets.has(int(preset.get("pet",-1))): return
	for slot in range(4):
		var uid := int(preset.gear[slot]); var entry: Dictionary = game.progress.item(uid)
		if uid != -1 and (entry.is_empty() or int(entry.kind)%4 != slot): return
	game.progress.equipped.assign(preset.gear); game.progress.pet = int(preset.pet); game.selected_weapon = clampi(int(preset.get("weapon",-1)),-1,11)
	game.save_profile(); presets()
func sources(group: String, index: int) -> void:
	if group == "pet" and index == 0:
		page("BEE", "Pet khởi đầu được nhận miễn phí một lần cho mọi profile.")
		button("VỀ PET",pets)
		return
	var stages: Array[int] = []
	if group == "pet": stages.append(maxi(0,index-1))
	else:
		var family := index/4
		for i in range(5):
			if [1,0,2,0,2][i] == family or i == 4: stages.append(i)
	page("NGUỒN SƯU TẦM","Pet: thưởng lần đầu cố định. Trang bị: boss/chơi lại/càn quét có cơ hội rơi; không bảo đảm một món cụ thể. Tinh anh có thể rơi đồ Hiếm. Admin mở đủ.")
	for stage in stages:
		button("ĐẾN ẢI %02d • %s" % [stage+1,game.Campaign.data(stage).name],game.show_stage_brief.bind(stage),game.admin_enabled or stage < game.campaign_unlocked)
	button("VỀ HÀNH TRANG",hub)
func library(group := "", filter := -1) -> void:
	if group != "": library_group = group
	if filter >= 0: library_filter = filter
	var counts := {"hero":7,"weapon":12,"gear":12,"pet":6,"monster":6,"boss":5}
	var labels := {"hero":"HERO","weapon":"VŨ KHÍ","gear":"TRANG BỊ","pet":"PET","monster":"QUÁI VẬT","boss":"BOSS"}
	page("THƯ VIỆN SƯU TẦM","Đã có/đã gặp phát sáng • chưa có ảnh tối\nTheo dõi bộ sưu tập và mở từng mục để xem.")
	var categories := GridContainer.new(); categories.columns = 3
	categories.add_theme_constant_override("h_separation",10); categories.add_theme_constant_override("v_separation",10)
	game.cards.add_child(categories)
	for key in ["hero","weapon","gear","pet","monster","boss"]:
		var b := Button.new(); b.text = labels[key]; b.focus_mode = Control.FOCUS_NONE; b.custom_minimum_size = Vector2(182,66)
		NeonArt.style_button(b,Color("83ead6"),key == library_group); b.add_theme_font_size_override("font_size",20)
		b.pressed.connect(library.bind(key,library_filter)); categories.add_child(b)
	var owned_count := 0
	for i in range(counts[library_group]):
		if owns(library_group,i): owned_count += 1
	text("%s • %d/%d" % [labels[library_group],owned_count,counts[library_group]],30)
	var filters := HBoxContainer.new(); filters.add_theme_constant_override("separation",10); game.cards.add_child(filters)
	for i in range(3):
		var b := Button.new(); b.text = ["TẤT CẢ","ĐÃ CÓ / GẶP","CHƯA CÓ"][i]; b.focus_mode = Control.FOCUS_NONE; b.custom_minimum_size = Vector2(182,64)
		NeonArt.style_button(b,Color("83ead6"),library_filter == i); b.add_theme_font_size_override("font_size",18)
		b.pressed.connect(library.bind(library_group,i)); filters.add_child(b)
	var grid := GridContainer.new(); grid.columns = 3; grid.add_theme_constant_override("h_separation",10); grid.add_theme_constant_override("v_separation",10)
	game.cards.add_child(grid)
	for i in range(counts[library_group]):
		var lit := owns(library_group,i)
		if (library_filter == 1 and not lit) or (library_filter == 2 and lit): continue
		var b := Button.new(); b.custom_minimum_size = Vector2(182,188); b.focus_mode = Control.FOCUS_NONE
		NeonArt.style_button(b,Color("83ead6") if lit else Color("40566a"),lit)
		b.pressed.connect(collection_detail.bind(library_group,i)); grid.add_child(b)
		var art := View.new(); art.group = library_group; art.index = i; art.owned = lit; art.rarity = collection_rarity(library_group,i) if lit else 0; art.position = Vector2(5,5); art.size = Vector2(172,112); b.add_child(art)
		var label := Label.new(); label.text = collection_name(library_group,i)+"\n"+("ĐÃ GẶP" if library_group in ["monster","boss"] and lit else "ĐÃ CÓ" if lit else "CHƯA MỞ")
		label.position = Vector2(5,120); label.size = Vector2(172,65); label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; label.add_theme_font_size_override("font_size",18); label.mouse_filter = Control.MOUSE_FILTER_IGNORE; b.add_child(label)
	button("VỀ HÀNH TRANG",hub)
func owns(group: String, index: int) -> bool:
	match group:
		"hero": return game.owned_robots.has(index)
		"weapon": return true
		"pet": return game.progress.pets.has(index)
		"gear":
			for entry in game.progress.items:
				if entry.kind == index: return true
			return false
		_: return game.progress.seen.has(group+":"+str(index))
func collection_rarity(group: String, index: int) -> int:
	if group == "pet": return [0,1,2,1,2,3][index]
	if group == "hero": return 3 if index == 4 else 2 if index in [2,3] else 0 if index == 0 else 1
	if group == "gear":
		var rarity := 0
		for entry in game.progress.items:
			if entry.kind == index: rarity = maxi(rarity,int(entry.rarity))
		return rarity
	return 1

func collection_name(group: String, index: int) -> String:
	match group:
		"hero": return RobotRoster.NAMES[index]
		"weapon": return game.Shooter.WEAPONS[index]
		"gear": return RPG.item_name(index)
		"pet": return RPG.PETS[index]
		"monster": return ["CHASER","DASHER","TANK","COMMANDER","SHIELD GUARD","ZONE CASTER"][index]
		_: return game.Campaign.data(index).boss
func collection_detail(group: String, index: int) -> void:
	page(collection_name(group,index),"ĐÃ SƯU TẦM / ĐÃ GẶP" if owns(group,index) else "CHƯA MỞ KHÓA")
	picture(group,index,collection_rarity(group,index),owns(group,index),250)
	if group in ["hero","pet","gear"]: text("ĐỘ HIẾM: "+RPG.RARITIES[collection_rarity(group,index)],22,RPG.COLORS[collection_rarity(group,index)])
	if group == "pet": text(RPG.PET_INFO[index])
	elif group == "weapon": text(game.Shooter.INFO[index])
	elif group == "hero": text(game.Shooter.SKILLS[index]+" • kỹ năng riêng của robot")
	elif group == "gear": text("Bộ "+RPG.SETS[index/4]+" • có 4 độ hiếm, nâng +0 đến +10")
	else: text("Robot thuộc chiến trường LAST BULLET. Gặp trong phó bản và chế độ sinh tồn.")
	if group in ["pet","gear"]: button("NGUỒN KIẾM",sources.bind(group,index))
	button("VỀ THƯ VIỆN",library.bind(group,library_filter))
func sweep(stage: int, hard: bool) -> void:
	sweep_inflight = false
	page("CÀN QUÉT • "+("KHÓ" if hard else "THƯỜNG"),"Ải %02d • %d vé càn quét\nCần 3 sao đúng độ khó. Admin miễn vé/điều kiện.\nMỗi lượt: vàng cơ bản %d, vật liệu %d, 1 vé summon.\nRơi đồ %.0f%%: Thường/Hiếm/Sử thi. Không có đồ Huyền thoại rơi trực tiếp. Không trả lại thưởng lần đầu, không x2." % [stage+1,game.progress.sweep_tickets,int((40+stage*20)*(1.5 if hard else 1)),int((8+stage*2)*(1.5 if hard else 1)),55.0 if hard else 35.0])
	text("Khi rơi đồ • Thường %d%% / Hiếm %d%% / Sử thi %d%%" % [65 if hard else 80,27 if hard else 18,8 if hard else 2],22)
	text("KHO %d/500 • chừa đủ chỗ cho số lượt chọn" % game.progress.items.size(),22)
	var stars: int = game.progress.hard_stars[stage] if hard else game.campaign_stars[stage]
	for count in [1,5,10]: button("CÀN QUÉT ×%d • %s" % [count,"ADMIN MIỄN PHÍ" if game.admin_enabled else "%d VÉ" % count],claim_sweep.bind(stage,hard,count),(game.admin_enabled or (stars >= 3 and game.progress.sweep_tickets >= count)) and game.progress.items.size()+count <= 500)
	button("VỀ PHÓ BẢN",game.show_campaign)
func claim_sweep(stage: int, hard: bool, count: int) -> void:
	if sweep_inflight: return
	sweep_inflight = true
	var reward: Dictionary = game.adventure.sweep(stage,hard,count)
	if reward.is_empty():
		sweep_inflight = false
		return
	page("KẾT QUẢ CÀN QUÉT","×%d • +%d vàng • +%d vật liệu • +%d vé summon\nĐồ vào kho, không tự hợp nhất. Dùng Hợp nhất để ghép các món trùng." % [count,reward.gold,reward.mats,reward.tickets])
	text("+%d lõi hero • +%d bộ sơ cứu" % [reward.get("cores",0),reward.get("kits",0)],23)
	for uid in reward.gear:
		var entry: Dictionary = game.progress.item(uid)
		if not entry.is_empty(): text(RPG.item_name(entry.kind)+" • "+RPG.RARITIES[entry.rarity],24,RPG.COLORS[entry.rarity])
	button("VÀO KHO",gear); button("VỀ PHÓ BẢN",game.show_campaign)
func practice() -> void:
	page("KHU THỬ TRANG BỊ","Bia đứng yên, bất tử • mẫu đo 10 giây\nSo sánh DPS cùng điều kiện. Lượt phó bản đang dở vẫn được giữ.")
	for i in range(3): button(["BIA ĐƠN","NHÓM 5 BIA","BIA BOSS"][i],game.adventure.practice.bind(i))
	button("VỀ HÀNH TRANG",hub)

func loot_receipt() -> void:
	var loot: Dictionary = game.progress.last_loot
	page("RƯƠNG PHÓ BẢN","+%d vật liệu • %d món đồ\nĐã cộng vào kho, xem lại không nhận thêm. X2 chỉ áp dụng vàng trận." % [int(loot.get("mats",0)),loot.get("gear",[]).size()])
	text("+%d lõi hero • +%d bộ sơ cứu" % [loot.get("cores",0),loot.get("kits",0)],23)
	for uid in loot.get("gear",[]):
		var entry: Dictionary = game.progress.item(int(uid))
		if entry.is_empty(): continue
		picture("gear",entry.kind,entry.rarity,true,150)
		text(RPG.item_name(entry.kind)+" • "+RPG.RARITIES[entry.rarity],24,RPG.COLORS[entry.rarity])
	if int(loot.get("pet",-1)) in range(6):
		var pet: int = loot.pet
		picture("pet",pet,[0,1,2,1,2,3][pet],true,130)
		text("MỞ PET "+RPG.PETS[pet],26)
	button("VÀO KHO",gear)
	button("VỀ KẾT QUẢ",game.show_results)

func room_strip(current := -1) -> HBoxContainer:
	var strip := HBoxContainer.new(); strip.add_theme_constant_override("separation",8); game.cards.add_child(strip)
	for i in range(5):
		var panel := PanelContainer.new(); panel.custom_minimum_size = Vector2(106,108)
		panel.add_theme_stylebox_override("panel",NeonArt.panel(Color("17494e") if current == i else Color("102a3d"),Color("9efbea") if current == i else Color("3b6374"),10))
		strip.add_child(panel)
		var column := VBoxContainer.new(); panel.add_child(column)
		game.result_label(column,"%02d" % (i+1),22,Color("ffcc87") if i == 4 else Color("8bffe1"))
		game.result_label(column,["GIAO\nTRANH","TINH\nANH","TIẾP\nTẾ","SỰ\nKIỆN","BOSS"][i],17)
	return strip

func hero_training(index: int) -> void:
	page("NÂNG NHÂN VẬT",RobotRoster.NAMES[index]+" • Cấp %d/20" % game.progress.hero_levels[index])
	picture("hero",index,collection_rarity("hero",index),game.owned_robots.has(index),180)
	text("Sát thương +%d%% • HP +%d" % [(game.progress.hero_levels[index]-1)*2,int(game.progress.hero_levels[index])/5],23,RobotRoster.COLORS[index])
	picture("skill",index,2,true,86)
	text(game.Shooter.SKILLS[index],24,RobotRoster.COLORS[index])
	text("+2% sát thương mỗi cấp • +1 HP mỗi 5 cấp",22)
	text("%d lõi hero • %d vàng" % [game.progress.hero_cores,game.coins],24)
	var level: int = game.progress.hero_levels[index]
	var gold := level*100; var cores := 2+level/3
	button("ĐẠT CẤP TỐI ĐA" if level >= 20 else "TĂNG CẤP HERO • %d vàng + %d lõi" % [gold,cores],train_hero.bind(index),game.owned_robots.has(index) and level < 20 and (game.admin_enabled or (game.coins >= gold and game.progress.hero_cores >= cores)))
	var grid := GridContainer.new(); grid.columns = 3; grid.add_theme_constant_override("h_separation",10); grid.add_theme_constant_override("v_separation",10); game.cards.add_child(grid)
	for id in game.owned_robots: tile(grid,RobotRoster.NAMES[id]+" • LV "+str(game.progress.hero_levels[id]),"hero",id,hero_training.bind(id),id == index,150)
	button("KHO HERO",game.show_robots)
	button("VỀ HÀNH TRANG",hub)
func train_hero(index: int) -> void:
	if game.state != "menu" or not game.owned_robots.has(index): return
	var paid: Dictionary = game.progress.train_hero(index,game.coins,game.admin_enabled)
	if not paid.is_empty(): game.coins -= int(paid.gold); game.save_profile()
	hero_training(index)
func supplies() -> void:
	page("VẬT PHẨM HỖ TRỢ","Hồi máu và nâng nhân vật từ vật phẩm phó bản.")
	picture("item",0,1,true,150)
	text("BỘ SƠ CỨU • %d" % game.progress.repair_kits,26)
	text("Hồi 3 HP trong phòng tiếp tế/sự kiện. Rơi từ rương boss.",22)
	picture("item",1,2,true,150)
	text("LÕI HERO • %d" % game.progress.hero_cores,26)
	text("Dùng để nâng nhân vật. Nhận khi thắng boss hoặc càn quét.",22)
	button("NÂNG NHÂN VẬT",hero_training.bind(game.selected_robot))
	button("PHÓ BẢN & CÀN QUÉT",game.show_campaign)
	button("VỀ HÀNH TRANG",hub)
