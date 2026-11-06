extends Node
const Art = preload("res://scripts/shop_art.gd")
var game: Node2D
var tab := 0
var handled_token := ""
const TABS := ["ĐỀ XUẤT","VẬT PHẨM","CÁC GÓI","ĐỔI MẢNH","NGOẠI HÌNH"]
func text(value: String, size := 24, color := Color("b7d4df")) -> Label: return game.rpg_ui.text(value,size,color)
func button(value: String, action: Callable, enabled := true) -> Button: return game.rpg_ui.button(value,action,enabled)
func page(title: String, info := "") -> void:
	game.show_menu(); game.clear_cards(title,info); game.cards.add_theme_constant_override("separation",12)
func price(entry: Dictionary) -> String:
	if game.shop.owned(entry): return "ĐÃ SỞ HỮU"
	if game.admin_enabled: return "ADMIN • MIỄN PHÍ"
	if game.shop.remaining(entry) <= 0: return "ĐÃ NHẬN HẾT LƯỢT"
	if entry.price == 0: return "MIỄN PHÍ"
	return "%d vàng" % entry.price if entry.currency == "gold" else "%d mảnh" % entry.price
func show_shop(index := 0) -> void:
	tab = clampi(index,0,4); game.shop.pending.clear()
	page("CỬA HÀNG","%d vàng • %d mảnh\nDùng tài nguyên trong game • không thanh toán tiền thật" % [game.coins,game.summon.shards])
	var tabs := HBoxContainer.new(); tabs.add_theme_constant_override("separation",5); game.cards.add_child(tabs)
	for i in range(5):
		var action := Button.new(); action.text = TABS[i]; action.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; action.custom_minimum_size = Vector2(109,76); action.size_flags_horizontal = Control.SIZE_EXPAND_FILL; action.add_theme_font_size_override("font_size",18)
		NeonArt.style_button(action,Color("86eadc"),tab == i); action.pressed.connect(show_shop.bind(i)); tabs.add_child(action)
	text(TABS[tab],26,Color("e1fff7"))
	if tab == 0:
		var banner := Art.new(); banner.group = "featured"; banner.custom_minimum_size = Vector2(0,174); game.cards.add_child(banner)
		text("TRẠM TIẾP TẾ",26,Color("a5ffe4"))
	if tab == 4:
		text("Phủ màu robot & súng • hào quang • dấu chân • màu vệt đạn. Chỉ đổi ngoại hình.",22)
		button("NGUYÊN BẢN" if game.shop.theme != 0 else "✓ NGUYÊN BẢN",equip.bind(0))
	var grid := GridContainer.new(); grid.columns = 2; grid.add_theme_constant_override("h_separation",12); grid.add_theme_constant_override("v_separation",12); game.cards.add_child(grid)
	for entry in game.shop.catalog():
		if entry.tab != tab: continue
		var card := Button.new(); card.custom_minimum_size = Vector2(275,240); card.focus_mode = Control.FOCUS_NONE
		NeonArt.style_button(card,Color("a7e7df"),entry.id == "starter"); grid.add_child(card); card.pressed.connect(detail.bind(entry.id,4 if entry.id == "starter" else 0))
		var art := Art.new(); art.group = entry.art; art.index = entry.index; art.position = Vector2(12,4); art.size = Vector2(251,128); card.add_child(art)
		if entry.has("theme"): art.accent = game.shop.THEME_COLORS[entry.theme]
		var label := Label.new(); label.text = entry.name+"\n"+price(entry); label.position = Vector2(10,138); label.size = Vector2(255,92); label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; label.mouse_filter = Control.MOUSE_FILTER_IGNORE; label.add_theme_font_size_override("font_size",21); card.add_child(label)
	button("LỊCH SỬ NHẬN • %d" % game.shop.history.size(),history)
	button("XEM TÀI NGUYÊN",game.show_wallet)
func art(entry: Dictionary, choice: int) -> void:
	if entry.has("theme"):
		var holder := Control.new(); holder.custom_minimum_size = Vector2(560,230); game.cards.add_child(holder)
		var actor = load("res://scripts/player_visual.gd").new(); actor.robot = game.selected_robot; actor.weapon = game.combat.weapon_id(); actor.aim = Vector2.RIGHT; actor.active = false; actor.finish = int(entry.theme); actor.position = Vector2(240,115); actor.scale = Vector2.ONE*2.6; holder.add_child(actor)
	else:
		var picture := Art.new(); picture.group = entry.art; picture.index = choice if entry.get("gear",false) else int(entry.family)*4+choice%4 if entry.has("family") else entry.index; picture.custom_minimum_size = Vector2(0,190); game.cards.add_child(picture)
func contents(entry: Dictionary, choice: int) -> void:
	for key in entry.reward:
		text("+%d %s" % [int(entry.reward[key]),{"gold":"vàng","tickets":"vé triệu hồi","materials":"vật liệu","cores":"lõi hero","kits":"bộ sơ cứu","sweep":"vé càn quét"}[key]],25,Color("d7f8ee"))
	if entry.get("gear",false): text(game.Progress.item_name(choice)+" • HIẾM • +0",24,Color("69bdff"))
	if entry.has("set"):
		for slot in range(4): text(game.Progress.item_name(int(entry.set)*4+slot)+" • HIẾM • +0",22,Color("69bdff"))
	if entry.has("family"): text(game.Progress.item_name(int(entry.family)*4+choice%4)+" • HIẾM • +0",24,Color("69bdff"))
	if entry.has("pet"): text(game.Progress.PET_INFO[entry.pet],24)
	if entry.has("theme"): text("Phủ màu robot & súng • hào quang • dấu chân • màu vệt đạn. Chỉ đổi ngoại hình.",24)
func detail(id: String, choice := 0) -> void:
	var entry: Dictionary = game.shop.offer(id)
	if entry.is_empty(): return
	page(entry.name,"Nội dung cố định • xem rõ trước khi mua")
	art(entry,choice); contents(entry,choice)
	if entry.get("gear",false) or entry.has("family"):
		text("CHỌN TRANG BỊ",24)
		var grid := GridContainer.new(); grid.columns = 3 if entry.get("gear",false) else 2; grid.add_theme_constant_override("h_separation",8); grid.add_theme_constant_override("v_separation",8); game.cards.add_child(grid)
		for i in range(12 if entry.get("gear",false) else 4):
			var action := Button.new(); action.text = game.Progress.item_name(i) if entry.get("gear",false) else game.Progress.SLOTS[i]; action.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; action.custom_minimum_size = Vector2(182 if entry.get("gear",false) else 275,76); action.add_theme_font_size_override("font_size",18); NeonArt.style_button(action,Color("83ead6"),choice == i); grid.add_child(action); action.pressed.connect(detail.bind(id,i))
	if game.admin_enabled and entry.has("limit"): text("ADMIN • BỎ GIỚI HẠN MUA",22)
	elif entry.has("limit"): text(("MỖI NGÀY UTC" if entry.get("daily",false) else "GIỚI HẠN MỖI HỒ SƠ")+" • %d / %d" % [game.shop.remaining(entry),entry.limit],22)
	if entry.has("theme") and game.shop.themes.has(entry.theme):
		button("ĐANG DÙNG" if game.shop.theme == entry.theme else "TRANG BỊ NGOẠI HÌNH",equip.bind(int(entry.theme)),game.shop.theme != entry.theme)
	else:
		var enough: bool = game.admin_enabled or (game.coins if entry.currency == "gold" else game.summon.shards) >= entry.price
		button(price(entry),confirm.bind(id,choice),not game.shop.owned(entry) and (game.admin_enabled or game.shop.remaining(entry) > 0) and enough)
		if not enough: text("KHÔNG ĐỦ TÀI NGUYÊN",22,Color("ffa38d"))
	button("VỀ CỬA HÀNG",show_shop.bind(tab))
func confirm(id: String, choice: int) -> void:
	var entry: Dictionary = game.shop.offer(id)
	page("XÁC NHẬN MUA",entry.name); art(entry,choice); contents(entry,choice)
	text("CHI PHÍ • "+price(entry),28,Color("ffd184"))
	text("Chỉ xác nhận một lần. Vật phẩm vào túi, không tự trang bị.",22)
	var token: String = game.shop.quote(id,choice)
	button("XÁC NHẬN NHẬN" if entry.price == 0 or game.admin_enabled else "XÁC NHẬN MUA",purchase.bind(token))
	button("QUAY LẠI",detail.bind(id,choice))
func purchase(token: String) -> void:
	if token == handled_token: return
	handled_token = token
	var result: Dictionary = game.shop.buy(token)
	if result.has("error"):
		page("GIAO DỊCH CHƯA HOÀN TẤT",result.error); button("VỀ CỬA HÀNG",show_shop.bind(tab)); return
	page("ĐÃ NHẬN THÀNH CÔNG",result.name)
	var entry: Dictionary = game.shop.offer(result.offer)
	art(entry,int(result.gear[0]) if entry.get("gear",false) and not result.gear.is_empty() else int(result.gear[0])%4 if entry.has("family") and not result.gear.is_empty() else 0)
	contents(entry,int(result.gear[0]) if entry.get("gear",false) and not result.gear.is_empty() else int(result.gear[0])%4 if entry.has("family") and not result.gear.is_empty() else 0)
	if result.theme > 0: button("TRANG BỊ NGOẠI HÌNH",equip.bind(int(result.theme)))
	button("TIẾP TỤC MUA SẮM",show_shop.bind(tab))
	button("XEM HÀNH TRANG",game.rpg_ui.hub)
func equip(index: int) -> void:
	if game.shop.equip_theme(index): show_shop(4)
func history() -> void:
	page("LỊCH SỬ CỬA HÀNG","20 giao dịch gần nhất • lưu theo hồ sơ")
	if game.shop.history.is_empty(): text("CHƯA CÓ GIAO DỊCH")
	var entries: Array = game.shop.history.duplicate(); entries.reverse()
	for entry in entries: text(str(entry.get("name",""))+"\n"+str(entry.get("time",""))+" UTC • "+("%d vàng" % int(entry.get("price",0)) if entry.get("currency","") == "gold" else "%d mảnh" % int(entry.get("price",0))),22)
	button("VỀ CỬA HÀNG",show_shop.bind(tab))
