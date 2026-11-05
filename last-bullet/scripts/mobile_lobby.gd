extends Control

# Persistent front-end shell; no gameplay state or rewards are owned here.
var game: Node2D
var home_view: Control
var top_bar: Control
var bottom_bar: Panel
var hero_input: Control
var hero_preview: Control
var hero_name: Label
var hero_status: Label
var hero_hint: Label
var hero_equip: Button
var avatar: Button
var avatar_art: Control
var title: Label
var tagline: Label
var left_arrow: Button
var right_arrow: Button
var stage_card: Panel
var stage_picker: Button
var mode_picker: Button
var play_button: Button
var missions_button: Button
var rewards_button: Button
var currency_values: Array[Label] = []
var nav_buttons: Array[Button] = []
var nav_icons: Array[Control] = []
var preview_robot := 0
var active_page := 0
var height := 1280.0
var safe := Vector2.ZERO
var clock := 0.0
var finger := -1
var swipe_start := Vector2.ZERO
var swipe_end := Vector2.ZERO
var page_tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(720,height)
	home_view = Control.new()
	home_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(home_view)
	top_bar = Control.new()
	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_bar)
	avatar = make_button(top_bar,"",game.show_profile_menu)
	avatar_art = Control.new()
	avatar_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(avatar_art)
	avatar_art.draw.connect(func(): NeonArt.hero(avatar_art,game.selected_robot,Vector2(48,33),44,clock))
	var badge := label(avatar,"",16,Color("ffc97f"))
	badge.name = "Badge"
	badge.position = Vector2(3,65)
	badge.size = Vector2(90,24)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(3):
		var chip := make_button(top_bar,"",game.show_wallet)
		chip.name = "Resource%d" % i
		var icon := Control.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = Vector2(25,47)
		chip.add_child(icon)
		icon.draw.connect(draw_currency.bind(icon,i))
		var caption := label(chip,["VÀNG","VÉ","MẢNH"][i],14,Color("80a5b7"))
		caption.position = Vector2(48,18)
		var value := label(chip,"0",25,Color("e2fbff"))
		value.position = Vector2(48,39)
		currency_values.append(value)
	var gear := make_button(top_bar,"",game.show_settings)
	gear.name = "Gear"
	var gear_icon := Control.new()
	gear_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gear_icon.position = Vector2(48,48)
	gear.add_child(gear_icon)
	gear_icon.draw.connect(func():
		gear_icon.draw_arc(Vector2.ZERO,15,0,TAU,24,Color("b5e3e7"),4)
		gear_icon.draw_circle(Vector2.ZERO,6,Color("b5e3e7"))
		for i in range(8):
			var direction := Vector2.from_angle(i*TAU/8)
			gear_icon.draw_line(direction*17,direction*22,Color("b5e3e7"),5))
	title = label(home_view,"LAST BULLET",48,Color("ddffff"))
	title.add_theme_font_override("font",NeonArt.title_font())
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline = label(home_view,"AUTO FIRE. ENDLESS CHAOS.",18,Color("6b9aaf"))
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_input = Control.new()
	hero_input.mouse_filter = Control.MOUSE_FILTER_STOP
	hero_input.gui_input.connect(on_hero_input)
	home_view.add_child(hero_input)
	hero_preview = game.Preview.new()
	hero_preview.actor_width = 320
	hero_input.add_child(hero_preview)
	left_arrow = make_button(home_view,"‹",cycle_robot.bind(-1))
	right_arrow = make_button(home_view,"›",cycle_robot.bind(1))
	left_arrow.add_theme_font_size_override("font_size",44)
	right_arrow.add_theme_font_size_override("font_size",44)
	hero_name = label(home_view,"",36,Color.WHITE)
	hero_name.add_theme_font_override("font",NeonArt.title_font())
	hero_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_status = label(home_view,"",20,Color("9db9c9"))
	hero_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_hint = label(home_view,"Vuốt để xem • Chạm robot để xem chi tiết",18,Color("648b9f"))
	hero_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_equip = make_button(home_view,"TRANG BỊ",equip_preview)
	stage_card = Panel.new()
	stage_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_card.add_theme_stylebox_override("panel",NeonArt.panel(Color("102d3e"),Color("3e6a78"),20))
	home_view.add_child(stage_card)
	stage_picker = make_button(stage_card,"",game.show_primary_selection)
	stage_picker.alignment = HORIZONTAL_ALIGNMENT_LEFT
	stage_picker.add_theme_font_size_override("font_size",24)
	stage_picker.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
	mode_picker = make_button(stage_card,"⋯",game.show_modes)
	mode_picker.add_theme_font_size_override("font_size",36)
	play_button = make_button(stage_card,"CHƠI NGAY",game.play_primary,true)
	play_button.add_theme_font_size_override("font_size",34)
	missions_button = make_button(home_view,"NHIỆM VỤ",game.show_lobby_missions)
	rewards_button = make_button(home_view,"PHẦN THƯỞNG",game.show_rewards)
	bottom_bar = Panel.new()
	bottom_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_bar.add_theme_stylebox_override("panel",NeonArt.panel(Color("0b2031"),Color("244f63"),22))
	add_child(bottom_bar)
	var routes: Array[Callable] = [game.show_menu,game.show_robots,game.show_summon,game.show_skins]
	for i in range(4):
		var button := make_button(bottom_bar,"\n"+["SẢNH","ROBOT","SUMMON","NGOẠI HÌNH"][i],routes[i])
		button.add_theme_font_size_override("font_size",20)
		button.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
		var icon := Control.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
		icon.draw.connect(draw_nav.bind(icon,i))
		nav_buttons.append(button)
		nav_icons.append(icon)
	layout(height,safe)

func label(parent: Node, text: String, font_size: int, color: Color) -> Label:
	var item := Label.new()
	item.text = text
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item.add_theme_font_size_override("font_size",font_size)
	item.add_theme_color_override("font_color",color)
	parent.add_child(item)
	return item

func make_button(parent: Node, text: String, callback: Callable, primary := false) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size",26)
	NeonArt.style_button(button,Color("83ead6"),primary)
	button.pressed.connect(func(): game.audio.play_event("ui_click"); callback.call())
	parent.add_child(button)
	return button

static func compact(amount: int) -> String:
	if amount >= 1000000: return ("%.1f" % (amount/1000000.0)).trim_suffix(".0")+"M"
	if amount >= 10000: return ("%.1f" % (amount/1000.0)).trim_suffix(".0")+"K"
	return str(amount)

func refresh(reset_preview := false) -> void:
	if reset_preview: preview_robot = game.selected_robot
	currency_values[0].text = compact(game.coins)
	currency_values[1].text = compact(game.summon.tickets)
	currency_values[2].text = compact(game.summon.shards)
	(avatar.get_node("Badge") as Label).text = "ADMIN" if game.admin_enabled else "HỒ SƠ"
	avatar_art.queue_redraw()
	hero_preview.actor = preview_robot
	hero_name.text = RobotRoster.NAMES[preview_robot]
	hero_name.add_theme_color_override("font_color",RobotRoster.COLORS[preview_robot])
	var owned: bool = game.owned_robots.has(preview_robot)
	hero_status.text = "ĐANG TRANG BỊ" if preview_robot == game.selected_robot else "ĐÃ SỞ HỮU" if owned else "CHƯA MỞ KHÓA"
	hero_equip.visible = owned and preview_robot != game.selected_robot
	hero_hint.visible = not hero_equip.visible
	rewards_button.text = "NHẬN X2 VÀNG • +"+compact(game.run_coins) if game.pending_lobby_reward() else "PHẦN THƯỞNG"
	if game.preferred_mode == "campaign":
		var index: int = game.primary_stage()
		stage_picker.text = "CHIẾN DỊCH\nMÀN %02d • %s" % [index+1,CampaignData.data(index).name]
	else:
		stage_picker.text = "CHẾ ĐỘ\n"+("BLITZ • 90 GIÂY" if game.preferred_mode == "blitz" else "SURVIVAL • "+game.preferred_layout.to_upper())
	for i in range(4):
		nav_buttons[i].add_theme_color_override("font_color",Color("a5ffe7") if i == active_page else Color("7192a8"))
		nav_icons[i].queue_redraw()
	queue_redraw()

func open_home() -> void:
	visible = true
	home_view.show()
	top_bar.show()
	bottom_bar.show()
	active_page = 0
	refresh(true)
	if page_tween != null and page_tween.is_valid(): page_tween.kill()
	home_view.modulate.a = 0
	page_tween = create_tween()
	page_tween.tween_property(home_view,"modulate:a",1.0,0.18)

func open_section(title_text: String, front: bool) -> void:
	visible = front
	home_view.hide()
	active_page = 1 if title_text.contains("ROBOT HANGAR") else 2 if title_text.contains("SUMMON") else 3 if title_text.contains("BULLET SKINS") else 0
	if front:
		top_bar.show()
		bottom_bar.show()
		refresh()

func hide_all() -> void:
	visible = false
	home_view.hide()

func cycle_robot(direction: int) -> void:
	preview_robot = (preview_robot+direction+RobotRoster.NAMES.size())%RobotRoster.NAMES.size()
	refresh()

func equip_preview() -> void:
	if not game.owned_robots.has(preview_robot): return
	game.selected_robot = preview_robot
	game.player_actor.robot = preview_robot
	game.save_profile()
	refresh()

func on_hero_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION: return
	if event is InputEventScreenTouch:
		if event.pressed and finger == -1:
			finger = event.index
			swipe_start = event.position
			swipe_end = swipe_start
		elif not event.pressed and event.index == finger:
			swipe_end = event.position
			finish_swipe()
		hero_input.accept_event()
	elif event is InputEventScreenDrag and event.index == finger:
		swipe_end = event.position
		hero_input.accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			finger = -2
			swipe_start = event.position
			swipe_end = swipe_start
		elif finger == -2:
			swipe_end = event.position
			finish_swipe()
		hero_input.accept_event()
	elif event is InputEventMouseMotion and finger == -2: swipe_end = event.position

func finish_swipe() -> void:
	var delta := swipe_end-swipe_start
	finger = -1
	if absf(delta.x) >= 60 and absf(delta.x) > absf(delta.y): cycle_robot(1 if delta.x < 0 else -1)
	elif delta.length() < 20: game.show_robots(preview_robot)

func layout(view_height: float, margins: Vector2) -> void:
	height = view_height
	safe = margins
	size = Vector2(720,height)
	home_view.size = size
	top_bar.position = Vector2(0,24+safe.x)
	avatar.position = Vector2(24,0)
	avatar.size = Vector2(96,96)
	var positions := [128,298,434]
	var widths := [162,128,142]
	for i in range(3):
		var chip := top_bar.get_node("Resource%d" % i) as Button
		chip.position = Vector2(positions[i],0)
		chip.size = Vector2(widths[i],96)
	var gear := top_bar.get_node("Gear") as Button
	gear.position = Vector2(584,0)
	gear.size = Vector2(96,96)
	title.position = Vector2(24,150+safe.x)
	title.size = Vector2(672,60)
	tagline.position = Vector2(24,211+safe.x)
	tagline.size = Vector2(672,30)
	var usable := height-safe.x-safe.y
	var hero_height := clampf(usable-870,330,800)
	hero_input.position = Vector2(110,250+safe.x)
	hero_input.size = Vector2(500,hero_height)
	hero_preview.position = Vector2.ZERO
	hero_preview.size = hero_input.size
	left_arrow.position = Vector2(24,250+safe.x+hero_height*0.44-48)
	right_arrow.position = Vector2(600,left_arrow.position.y)
	left_arrow.size = Vector2(96,96)
	right_arrow.size = Vector2(96,96)
	var info_y := 250+safe.x+hero_height
	hero_name.position = Vector2(110,info_y)
	hero_name.size = Vector2(500,46)
	hero_status.position = Vector2(110,info_y+48)
	hero_status.size = Vector2(500,28)
	hero_hint.position = Vector2(40,info_y+87)
	hero_hint.size = Vector2(640,28)
	hero_equip.position = Vector2(220,info_y+78)
	hero_equip.size = Vector2(280,64)
	bottom_bar.position = Vector2(24,height-128-safe.y)
	bottom_bar.size = Vector2(672,104)
	for i in range(4):
		nav_buttons[i].position = Vector2(i*168,0)
		nav_buttons[i].size = Vector2(168,104)
		nav_icons[i].position = Vector2(84,27)
	stage_card.position = Vector2(40,bottom_bar.position.y-336)
	stage_card.size = Vector2(640,198)
	stage_picker.position = Vector2(20,6)
	stage_picker.size = Vector2(500,78)
	mode_picker.position = Vector2(536,8)
	mode_picker.size = Vector2(84,72)
	play_button.position = Vector2(16,88)
	play_button.size = Vector2(608,94)
	missions_button.position = Vector2(40,bottom_bar.position.y-114)
	rewards_button.position = Vector2(370,missions_button.position.y)
	missions_button.size = Vector2(310,88)
	rewards_button.size = Vector2(310,88)
	queue_redraw()

func _process(delta: float) -> void:
	if not visible: return
	clock += delta
	if home_view.visible:
		queue_redraw()
		avatar_art.queue_redraw()

func _draw() -> void:
	if not home_view.visible: return
	draw_rect(Rect2(Vector2.ZERO,Vector2(720,height)),Color("040c19"))
	draw_texture_rect(NeonArt.FLOOR,Rect2(0,126+safe.x,720,height-270-safe.x-safe.y),false,Color(0.5,0.65,0.8,0.42))
	var point := Vector2(360,hero_input.position.y+hero_input.size.y*0.5+147)
	draw_set_transform(point,0,Vector2(1,0.22))
	draw_circle(Vector2.ZERO,156,Color(0.01,0.03,0.05,0.8))
	draw_arc(Vector2.ZERO,156,0,TAU,64,Color(0.25,0.85,0.82,0.6),3)
	draw_arc(Vector2.ZERO,126,clock*0.3,clock*0.3+TAU*0.78,48,Color(0.5,1,0.9,0.35),2)
	draw_set_transform(Vector2.ZERO)
	if not game.low_effects:
		for i in range(6):
			var x := 130+i*89
			var y := 330+safe.x+fmod(clock*12+i*61,240)
			draw_circle(Vector2(x,y),1.4,Color(0.4,0.95,0.9,0.25))

func draw_currency(canvas: Control, index: int) -> void:
	var color: Color = [Color("ffd184"),Color("8adfff"),Color("d4b1ff")][index]
	if index == 0:
		canvas.draw_circle(Vector2.ZERO,13,color)
		canvas.draw_arc(Vector2.ZERO,9,0,TAU,20,Color("75542b"),2)
	elif index == 1:
		canvas.draw_rect(Rect2(-14,-10,28,20),color,false,3)
		canvas.draw_line(Vector2(-3,-8),Vector2(-3,8),color,2)
	else:
		NeonArt.diamond(canvas,Vector2.ZERO,14,color)

func draw_nav(canvas: Control, index: int) -> void:
	var color := Color("8ffff0") if active_page == index else Color("64869d")
	match index:
		0:
			canvas.draw_polyline(PackedVector2Array([Vector2(-18,0),Vector2(0,-15),Vector2(18,0)]),color,3)
			canvas.draw_rect(Rect2(-13,0,26,17),color,false,3)
		1:
			canvas.draw_circle(Vector2.ZERO,16,color)
			canvas.draw_rect(Rect2(-12,-3,24,9),Color("0c2332"))
			canvas.draw_line(Vector2(-8,0),Vector2(8,0),Color("bafff0"),3)
		2:
			canvas.draw_rect(Rect2(-13,-18,26,36),color,false,3)
			canvas.draw_line(Vector2(-8,0),Vector2(8,0),color,3)
		3:
			var points := PackedVector2Array()
			for i in range(8): points.append(Vector2.from_angle(-PI/2+i*PI/4)*(18 if i%2 == 0 else 7))
			canvas.draw_colored_polygon(points,color)
	if active_page == index: canvas.draw_line(Vector2(-24,68),Vector2(24,68),color,3)
