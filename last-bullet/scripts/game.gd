extends Node2D

signal enemy_killed(points: int)
signal leveled_up
signal run_ended

var player := Vector2(360, 650)
var aim := Vector2.UP
const Shooter = preload("res://scripts/combat.gd")
var combat: Node2D
var enemies: Array[ArenaEnemy] = []
var boss: ArenaEnemy
var pickups: Array[Vector2] = []
const Lobby = preload("res://scripts/mobile_lobby.gd")
var home_shell: Control
var safe_margins := Vector2.ZERO
var preferred_mode := "campaign"
var preferred_layout := "open"
var preferred_stage := -1
var reward_profile_path := ""

const Campaign = preload("res://scripts/campaign_data.gd")
const Summons = preload("res://scripts/summon_system.gd")
const Reveal = preload("res://scripts/summon_reveal.gd")
var summon: SummonSystem
var campaign_unlocked := 1
var campaign_cleared: Array[int] = []
var campaign_stars: Array[int] = [0,0,0,0,0]
var active_stage := 0
var campaign_room := 1
var campaign_won := false
var run_tickets := 0
var milestone_claimed: Array[bool] = [false,false]
var summon_reveal: Control
var summon_results: Array[Dictionary] = []
var summon_revealed := false
var obstacle_cache_mode := ""
var obstacle_cache_layout := ""
var obstacle_cache_stage := -1
var obstacle_cache_arena := Rect2()
var obstacle_cache_pillar := Rect2()
var obstacle_cache: Array[Rect2] = []

const FX = preload("res://scripts/visual_effects.gd")
const Preview = preload("res://scripts/skin_preview.gd")
var effects: Node2D
var player_actor: Node2D
var visual_clock := 0.0
var move_clock := 0.0
var player_lean := 0.0
var player_moving := 0.0
var boss_label: Label
var boss_bar: ProgressBar
var header_panel: Panel
var brand: Label
var health_icons: Control
var horizontal_padding := 0.0
var canvas_height := 1280.0

const Geometry = preload("res://scripts/arena_geometry.gd")
var double_claimed := false
var run_coins := 0
var mission_coins := 0
var mode := "survival"
var arena_layout := "open"
var challenge_complete := false
var spawn_index := 0
var blitz_best := 0
var previous_record := 0
var new_record := false
var low_effects := false
var final_summary := ""
var upgrade_shade: ColorRect
var selected_robot := 0
var selected_weapon := -1
var shoot_while_moving := false
var armory_preview := -1
var owned_robots: Array[int] = [0]
var robot_gallery_index := 0
var weapon_label: Label
var admin_enabled := false
var normal_save_path := ""
var admin_context := false
var admin_god := true
var admin_max_start := false
var admin_free_skill := false

const AudioDirector = preload("res://scripts/audio.gd")
var audio: Node
var upgrades: Array[int] = Balance.empty_upgrades()
var coins := 0
var owned_skins: Array[int] = [0]
var selected_skin := 0
var sound_on := true
var haptics_on := true
var save_path := "user://records.cfg"
var mission_claimed: Array[bool] = [false,false,false]
var mission_label: Label
var skill_status: Label
var tap_contacts: Dictionary = {}
var last_skill_tap := -1
var last_skill_tap_position := Vector2.ZERO
var last_skill_tap_mouse := false
var pause_button: Button
var feedback := 0.0
var result_paid := false
var offered_upgrades: Array[int] = []
var state := "menu"
var elapsed := 0.0
var wave := 1
var hp := 5
var invulnerable := 0.0
var score := 0
var kills := 0
var combo := 0
var best_combo := 0
var combo_timer := 0.0
var xp := 0
var level := 1
var spawn_timer := 0.0
var cooldown := 0.0
var boss_spawned := false
var best_score := 0
var joystick_id := -1
var joystick := Vector2.ZERO
var joystick_origin := Vector2(185,1135)
var joystick_touch_origin := Vector2.ZERO
var joystick_dragging := false
var ui: CanvasLayer
var hud: Label
var xp_bar: ProgressBar
var overlay: PanelContainer
var cards: VBoxContainer
var toast: Label
var toast_time := 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	audio = AudioDirector.new()
	add_child(audio)
	normal_save_path = save_path
	var mode_config := ConfigFile.new()
	if mode_config.load(profile_mode_path()) == OK:
		admin_enabled = bool(mode_config.get_value("mode","admin",false))
	if admin_enabled: save_path = admin_profile_path()
	summon = Summons.new()
	load_profile()
	combat = Shooter.new()
	combat.game = self
	combat.z_index = 20
	add_child(combat)
	effects = FX.new()
	effects.z_index = 12
	add_child(effects)
	player_actor = load("res://scripts/player_visual.gd").new()
	player_actor.z_index = 5
	add_child(player_actor)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	build_ui()
	get_viewport().size_changed.connect(on_viewport_changed)
	on_viewport_changed()
	show_menu()

func build_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(root)
	hud = Label.new()
	hud.position = Vector2(42,52)
	hud.add_theme_font_size_override("font_size", 22)
	header_panel = Panel.new()
	header_panel.position = Vector2(25,16)
	header_panel.size = Vector2(670,133)
	header_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header_panel.add_theme_stylebox_override("panel",NeonArt.panel(Color("0c1c2e"),Color("2b697d"),18))
	root.add_child(header_panel)
	brand = Label.new()
	brand.text = "LAST BULLET"
	brand.position = Vector2(42,23)
	brand.add_theme_font_size_override("font_size",24)
	brand.add_theme_font_override("font",NeonArt.title_font())
	brand.add_theme_color_override("font_color",Color("d0fcff"))
	root.add_child(brand)
	health_icons = Control.new()
	health_icons.position = Vector2(525,116)
	health_icons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_icons.draw.connect(func():
		for i in range(5): NeonArt.heart(health_icons,Vector2(i*26,0),i<hp))
	root.add_child(health_icons)
	root.add_child(hud)
	weapon_label = Label.new()
	weapon_label.position = Vector2(42,110)
	weapon_label.add_theme_font_size_override("font_size",20)
	weapon_label.add_theme_color_override("font_color",Color("a1f5e0"))
	root.add_child(weapon_label)
	xp_bar = ProgressBar.new()
	xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	xp_bar.position = Vector2(40,137)
	xp_bar.size = Vector2(640,7)
	xp_bar.show_percentage = false
	xp_bar.add_theme_font_size_override("font_size",1)
	xp_bar.add_theme_stylebox_override("background",NeonArt.panel(Color("071322"),Color("1e4558"),4))
	xp_bar.add_theme_stylebox_override("fill",NeonArt.panel(Color("66e5dd"),Color("b6fff6"),4))
	root.add_child(xp_bar)
	boss_label = Label.new()
	boss_label.position = Vector2(145,169)
	boss_label.size = Vector2(430,22)
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.add_theme_font_size_override("font_size",16)
	boss_label.add_theme_stylebox_override("normal",NeonArt.panel(Color("0c1828"),Color("583e31"),6))
	boss_label.add_theme_color_override("font_color",Color("ffd598"))
	root.add_child(boss_label)
	boss_bar = ProgressBar.new()
	boss_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_bar.position = Vector2(180,198)
	boss_bar.size = Vector2(360,6)
	boss_bar.show_percentage = false
	boss_bar.add_theme_font_size_override("font_size",1)
	boss_bar.add_theme_stylebox_override("background",NeonArt.panel(Color("211b29"),Color("4f3544"),3))
	boss_bar.add_theme_stylebox_override("fill",NeonArt.panel(Color("f7b069"),Color("ffe0ac"),3))
	root.add_child(boss_bar)
	pause_button = Button.new()
	pause_button.text = "Ⅱ"
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.position = Vector2(615,40)
	pause_button.size = Vector2(58,58)
	pause_button.pressed.connect(toggle_pause)
	NeonArt.style_button(pause_button)
	root.add_child(pause_button)
	skill_status = Label.new()
	skill_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	skill_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skill_status.add_theme_font_size_override("font_size",24)
	skill_status.add_theme_color_override("font_color",Color("8eb8c7"))
	root.add_child(skill_status)
	toast = Label.new()
	toast.position = Vector2(40,955)
	toast.size = Vector2(640,50)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.add_theme_font_size_override("font_size",23)
	root.add_child(toast)
	upgrade_shade = ColorRect.new()
	upgrade_shade.color = Color(0.01,0.025,0.055,0.84)
	upgrade_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	upgrade_shade.hide()
	root.add_child(upgrade_shade)
	overlay = PanelContainer.new()
	overlay.position = Vector2(65,190)
	overlay.size = Vector2(590,820)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("0d1e31")
	panel_style.border_color = Color("4c8c9d")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(22)
	panel_style.shadow_color = Color(0,0,0,0.6)
	panel_style.shadow_size = 18
	overlay.add_theme_stylebox_override("panel",panel_style)
	root.add_child(overlay)
	var margins := MarginContainer.new()
	for side in ["left","right","top","bottom"]:
		margins.add_theme_constant_override("margin_" + side,30)
	overlay.add_child(margins)
	cards = VBoxContainer.new()
	cards.add_theme_constant_override("separation",20)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(580,760)
	margins.add_child(scroll)
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(cards)
	mission_label = Label.new()
	mission_label.position = Vector2(40,1025)
	mission_label.add_theme_font_size_override("font_size",19)
	root.add_child(mission_label)
	home_shell = Lobby.new()
	home_shell.game = self
	root.add_child(home_shell)

func clear_card_nodes() -> void:
	for child in cards.get_children():
		cards.remove_child(child)
		child.queue_free()

func front_page() -> bool:
	return state not in ["playing","paused","upgrade","results"] and not (state == "admin" and admin_context)

func clear_cards(title: String, subtitle: String) -> void:
	clear_skill_taps()
	upgrade_shade.visible = state == "upgrade"
	clear_card_nodes()
	home_shell.open_section(title,front_page())
	layout_modal()
	cards.add_theme_constant_override("separation",20)
	overlay.show()
	if overlay.has_meta("fade"):
		var old: Tween = overlay.get_meta("fade")
		if old != null and old.is_valid(): old.kill()
	overlay.modulate.a = 0
	var fade := overlay.create_tween()
	fade.tween_property(overlay,"modulate:a",1.0,0.16)
	overlay.set_meta("fade",fade)
	(cards.get_parent() as ScrollContainer).set_deferred("scroll_vertical",0)
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size",40 if title == "LAST BULLET" else 32)
	label.add_theme_font_override("font",NeonArt.title_font())
	label.add_theme_color_override("font_color",Color("d9fbff"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cards.add_child(label)
	var description := Label.new()
	description.text = subtitle
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size",26)
	cards.add_child(description)

func add_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(560,96)
	NeonArt.style_button(button,Color("73e6de"),text in ["PLAY","RETRY"] or text.begins_with("CLAIM"))
	button.mouse_entered.connect(func(): animate_button(button,1.012))
	button.mouse_exited.connect(func(): animate_button(button,1.0))
	button.button_down.connect(func(): animate_button(button,0.985))
	button.button_up.connect(func(): animate_button(button,1.0))
	button.add_theme_font_size_override("font_size",28)
	button.pressed.connect(func(): audio.play_event("ui_click"); callback.call())
	cards.add_child(button)
	return button

func animate_button(button: Button, target: float) -> void:
	if button.has_meta("motion"):
		var old: Tween = button.get_meta("motion")
		if old != null and old.is_valid(): old.kill()
	button.pivot_offset = button.size*0.5
	var motion := button.create_tween()
	motion.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	motion.tween_property(button,"scale",Vector2.ONE*target,0.1)
	button.set_meta("motion",motion)

func show_menu() -> void:
	clear_skill_taps()
	upgrade_shade.hide()
	state = "menu"
	audio.stop_all()
	for enemy in enemies: enemy.hide()
	combat.hide()
	clear_card_nodes()
	overlay.hide()
	home_shell.open_home()
	layout_modal()

func show_help() -> void:
	clear_cards("CÁCH CHƠI", "Kéo ở bất kỳ vùng trống nào để di chuyển; chạm đơn không kích hoạt. Robot tự ngắm địch gần trong tầm có đường bắn thông thoáng. Thả tay để bắn, kéo để né; có thể bật bắn khi di chuyển trong Cài đặt. Kho vũ khí ở tab VŨ KHÍ, tất cả mở sẵn để thử.\n\nNé đạn đỏ/cam của địch và vùng cảnh báo. Đạn sáng của bạn không gây hại cho bạn.\n\nNhấn đúp nhanh tại cùng vùng trống để dùng kỹ năng. Kéo hoặc giữ lâu không kích hoạt. Space trên PC vẫn dùng được. Thu XP để chọn nâng cấp súng. Pause để tạm dừng.\n\nMỗi trận: hạ 15 địch, dùng 3 kỹ năng, đạt chuỗi hạ 10 địch. Mỗi mục tiêu tự trả 15 vàng + 1 vé, một lần. Kết thúc nhận x2 vàng ngay, không quảng cáo.")
	add_button("VỀ SẢNH",show_menu)

func show_modes() -> void:
	clear_cards("CHOOSE YOUR RUN","Open arena to learn. Reflector to experiment. Blitz for a quick score chase.")
	add_button("CAMPAIGN • 5 STAGES",show_campaign)
	add_button("SURVIVAL • OPEN",start_run.bind("survival","open"))
	add_button("SURVIVAL • REFLECTOR",start_run.bind("survival","reflector"))
	add_button("BLITZ • 90 SECONDS",start_run.bind("blitz","open"))
	add_button("BACK",show_menu)

func start_run(run_mode := "survival", layout := "open") -> void:
	clear_skill_taps()
	upgrade_shade.hide()
	home_shell.hide_all()
	preferred_mode = run_mode
	preferred_layout = layout if layout in ["open","reflector"] else "open"
	if run_mode == "campaign": preferred_stage = active_stage
	save_profile()
	campaign_room = 1
	campaign_won = false
	run_tickets = 0
	milestone_claimed = [false,false]
	effects.effects.clear()
	move_clock = 0
	player_lean = 0
	admin_context = false
	mode = run_mode
	arena_layout = layout
	double_claimed = false
	run_coins = 0
	mission_coins = 0
	challenge_complete = false
	spawn_index = 0
	new_record = false
	if mode == "blitz":
		rng.seed = 90300
	else:
		rng.randomize()
	combat.reset()
	for enemy in enemies:
		remove_child(enemy)
		enemy.queue_free()
	enemies.clear()
	boss = null
	pickups.clear()
	upgrades = Balance.empty_upgrades()
	if admin_enabled and admin_max_start:
		for i in range(upgrades.size()): upgrades[i] = Balance.UPGRADE_CAPS[i]
	mission_claimed = [false,false,false]
	result_paid = false
	reward_profile_path = ""
	feedback = 0
	offered_upgrades.clear()
	audio.stop_all()
	player = Balance.ARENA.get_center()+Vector2(0,57.5)
	player_actor.position = player
	player_actor.robot = selected_robot
	player_actor.moving = 0
	player_actor.lean = 0
	player_actor.target_lean = 0
	player_actor.flash = 0
	player_actor.clock = 0
	player_actor.reset_physics_interpolation()
	aim = Vector2.UP
	elapsed = 0
	wave = 1
	hp = 5
	score = 0
	kills = 0
	combo = 0
	best_combo = 0
	combo_timer = 0
	xp = 0
	level = 1
	spawn_timer = 0.5
	cooldown = 0
	invulnerable = 0
	boss_spawned = false
	joystick_id = -1
	joystick = Vector2.ZERO
	state = "playing"
	update_hud()
	overlay.hide()
	notice("KÉO ĐỂ NÉ • THẢ TAY BẮN • NHẤN ĐÚP SKILL")

func clear_skill_taps() -> void:
	tap_contacts.clear()
	last_skill_tap = -1

func begin_skill_tap(id: int, pointer: Vector2) -> void:
	tap_contacts[id] = {"p":pointer,"at":Time.get_ticks_msec(),"dragged":false,"previous":last_skill_tap}

func finish_skill_tap(id: int, pointer: Vector2, canceled := false) -> void:
	if not tap_contacts.has(id): return
	var contact: Dictionary = tap_contacts[id]
	tap_contacts.erase(id)
	var now := Time.get_ticks_msec()
	if canceled or state != "playing" or contact.dragged or pointer.distance_to(contact.p) >= 12 or now-int(contact.at) > 220 or not in_movement_zone(pointer):
		last_skill_tap = -1
		return
	if last_skill_tap >= 0 and contact.previous == last_skill_tap and now-last_skill_tap <= 330 and pointer.distance_to(last_skill_tap_position) <= 48 and last_skill_tap_mouse == (id == -2):
		last_skill_tap = -1
		request_skill()
	else:
		last_skill_tap = now
		last_skill_tap_position = pointer
		last_skill_tap_mouse = id == -2

func _input(event: InputEvent) -> void:
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION: return
	var id := -99
	var pointer := Vector2.ZERO
	var released := false
	var canceled := false
	if event is InputEventScreenTouch:
		id = event.index
		pointer = event.position-Vector2(horizontal_padding,0)
		released = not event.pressed
		canceled = event.canceled
	elif event is InputEventScreenDrag:
		id = event.index
		pointer = event.position-Vector2(horizontal_padding,0)
	elif event is InputEventMouse:
		id = -2
		pointer = event.position-Vector2(horizontal_padding,0)
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT: released = not event.pressed
	if tap_contacts.has(id) and not tap_contacts[id].dragged and pointer.distance_to(tap_contacts[id].p) >= 12:
		tap_contacts[id].dragged = true
		last_skill_tap = -1
	# Observe releases even over GUI, but reject GUI endpoints as taps.
	if released:
		finish_skill_tap(id,pointer,canceled)
		if id == joystick_id: reset_stick()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11 and not OS.has_feature("mobile"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if state != "playing" and state != "paused":
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			request_skill()
		elif event.keycode == KEY_ESCAPE:
			toggle_pause()
	if state != "playing":
		return
	var pointer := Vector2.ZERO
	if event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventMouse:
		pointer = event.position-Vector2(horizontal_padding,0)
	if event is InputEventScreenTouch:
		if event.pressed and in_movement_zone(pointer): begin_skill_tap(event.index,pointer)
		if event.pressed and in_movement_zone(pointer) and joystick_id == -1:
			joystick_id = event.index
			joystick_origin = comfortable_stick_origin(pointer)
			joystick_touch_origin = pointer
			joystick_dragging = false
		elif not event.pressed and event.index == joystick_id:
			joystick_id = -1
			joystick = Vector2.ZERO
	if event is InputEventScreenDrag and event.index == joystick_id:
		update_stick_drag(pointer)
	# Mouse joystick for desktop preview; keyboard works independently.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and in_movement_zone(pointer): begin_skill_tap(-2,pointer)
		if event.pressed and in_movement_zone(pointer) and joystick_id == -1:
			joystick_id = -2
			joystick_origin = comfortable_stick_origin(pointer)
			joystick_touch_origin = pointer
			joystick_dragging = false
		elif not event.pressed and joystick_id == -2:
			joystick_id = -1
			joystick = Vector2.ZERO
	if event is InputEventMouseMotion and joystick_id == -2:
		update_stick_drag(pointer)

func update_stick_drag(pointer: Vector2) -> void:
	var delta := pointer-joystick_touch_origin
	if not joystick_dragging and delta.length() < 12:
		return
	if not joystick_dragging:
		last_skill_tap = -1
	joystick_dragging = true
	if tap_contacts.has(joystick_id): tap_contacts[joystick_id].dragged = true
	joystick = (delta/70).limit_length()

func in_movement_zone(pointer: Vector2) -> bool:
	if not Rect2(0,safe_margins.x,720,canvas_height-safe_margins.x-safe_margins.y).has_point(pointer):
		return false
	# Buttons own their touches; all other screen space can start movement.
	for button in [pause_button]:
		if button.is_visible_in_tree() and Rect2(button.position,button.size).has_point(pointer):
			return false
	return true

func comfortable_stick_origin(pointer: Vector2) -> Vector2:
	# The ring follows the finger inside the safe play area, without clipping edges.
	return pointer.clamp(Vector2(80,safe_margins.x+80),Vector2(640,canvas_height-safe_margins.y-90))

func reset_stick() -> void:
	joystick_dragging = false
	joystick_id = -1
	joystick = Vector2.ZERO
	joystick_origin = Vector2(185,canvas_height-safe_margins.y-145)

func request_skill() -> void:
	combat.skill()


func toggle_pause() -> void:
	clear_skill_taps()
	if state == "playing":
		state = "paused"
		audio.stop_all()
		joystick = Vector2.ZERO
		joystick_id = -1
		clear_cards("PAUSED", "Catch your breath.")
		add_button("RESUME", func(): state = "playing"; overlay.hide())
		if admin_enabled: add_button("ADMIN TOOLS",show_admin)
		add_button("MAIN MENU", show_menu)
	elif state == "paused":
		state = "playing"
		overlay.hide()

func _physics_process(delta: float) -> void:
	skill_status.visible = state == "playing"
	pause_button.visible = state in ["playing","paused"]
	hud.visible = state in ["playing","paused"]
	xp_bar.visible = state in ["playing","paused"]
	mission_label.visible = state in ["playing","paused"]
	var playing_ui := state in ["playing","paused"]
	player_actor.visible = playing_ui and (invulnerable <= 0 or int(invulnerable*15)%2 == 0)
	header_panel.visible = playing_ui
	brand.text = "LAST BULLET • ADMIN" if admin_enabled else "LAST BULLET"
	brand.visible = playing_ui
	weapon_label.visible = playing_ui
	health_icons.visible = playing_ui
	health_icons.queue_redraw()
	effects.visible = playing_ui
	boss_label.visible = playing_ui and is_instance_valid(boss)
	boss_bar.visible = boss_label.visible
	if boss_label.visible:
		var boss_name: String = Campaign.data(active_stage).boss if mode == "campaign" else "SIEGE COMMANDER"
		boss_label.text = boss_name+" • " + boss.status_text()
		boss_bar.max_value = boss.max_hp
		boss_bar.value = boss.hp
	toast_time = maxf(0,toast_time-delta)
	toast.visible = toast_time > 0 and state != "upgrade"
	if state != "playing":
		queue_redraw()
		return
	effects.reduced = low_effects or enemies.size()>24
	effects.advance(delta)
	elapsed += delta
	if mode == "blitz" and elapsed >= 90:
		elapsed = 90
		challenge_complete = true
		finish_run()
		return
	if mode == "campaign" and advance_campaign(): return
	feedback = maxf(0,feedback-delta)
	wave = 1+active_stage+campaign_room-1 if mode == "campaign" else 1 + int(elapsed / (15 if mode == "blitz" else 20))
	invulnerable = maxf(0,invulnerable-delta)
	cooldown = 0.0 if admin_enabled and admin_free_skill else maxf(0,cooldown-delta)
	combo_timer -= delta
	if combo_timer <= 0:
		combo = 0
	var movement := Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	if joystick.length() > 0.1:
		movement = joystick
	movement = movement.limit_length()
	player_moving = movement.length()
	move_clock += delta*(10 if player_moving > 0.1 else 2)
	player_lean = lerpf(player_lean,movement.x*0.12,1-exp(-delta*12))
	if movement.length() > 0.1:
		aim = movement.normalized()
	player += movement * Balance.PLAYER_SPEED * delta
	player = player.clamp(Balance.ARENA.position+Vector2(18,18),Balance.ARENA.end-Vector2(18,18))
	player = Geometry.resolve_all(player,18,world_obstacles())
	player_actor.position = player
	player_actor.moving = player_moving
	player_actor.target_lean = player_lean
	player_actor.flash = maxf(0,invulnerable-1.1)*0.8 if invulnerable <= 1.2 else 0.0
	combat.advance(delta)
	if state != "playing": return
	if mode == "campaign":
		var hazard_index := 0
		for box in Campaign.hot_zones(Balance.ARENA,active_stage):
			if Campaign.heat_state(elapsed,hazard_index) == 2 and box.grow(15).has_point(player): hurt_player(box.get_center())
			hazard_index += 1
		if state != "playing": return
	var enemy_delta := delta
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy):
			continue
		var target := Geometry.navigate(enemy.position,player,enemy.radius,world_obstacles()) if enemy.kind != 5 else player
		enemy.advance(enemy_delta*(0.45 if enemy.chilled > 0 else 1.0),target)
		enemy.position = Geometry.resolve_all(enemy.position,enemy.radius,world_obstacles())
		if player.distance_to(enemy.position) < enemy.radius + 17:
			hurt_player(enemy.position)
		if (enemy.kind == 5 or enemy.boss_style in [2,3,4]) and enemy.hazard_active() and player.distance_to(enemy.hazard_point) < 83:
			hurt_player(enemy.hazard_point)
		if state == "results":
			return
	spawn_timer -= delta
	if spawn_timer <= 0 and not (mode == "campaign" and boss_spawned):
		spawn_timer = maxf(0.32,1.4 - wave * 0.07) if mode != "blitz" else [1.2,0.95,0.8,0.7,0.6,0.5][mini(wave-1,5)]
		if mode == "campaign": spawn_timer = maxf(0.5,1.3-active_stage*0.1-campaign_room*0.08)
		if enemies.size() < (36 if mode == "campaign" else Balance.MAX_ENEMIES):
			var pool := [0]
			if wave >= 2: pool.append(1)
			if wave >= 3: pool.append(2)
			if wave >= 4: pool.append(4)
			if wave >= 5: pool.append(5)
			if mode == "campaign":
				var roster: Array = Campaign.data(active_stage).pool
				spawn_enemy(roster[rng.randi_range(0,roster.size()-1)])
			elif mode == "blitz":
				var formations := [[0,0,0],[0,1,0],[0,1,2],[1,0,4],[2,1,5],[4,1,2,5]]
				var formation: Array = formations[mini(wave-1,5)]
				spawn_enemy(formation[spawn_index%formation.size()])
				spawn_index += 1
			else:
				spawn_enemy(pool[rng.randi_range(0,pool.size()-1)])
	if mode == "survival" and elapsed >= 240 and not boss_spawned:
		boss_spawned = true
		spawn_enemy(3)
		notice("SIEGE COMMANDER HAS ARRIVED")
		audio.play_event("boss_warning")
	for i in range(pickups.size()-1,-1,-1):
		var distance := player.distance_to(pickups[i])
		if distance < 115:
			pickups[i] = pickups[i].move_toward(player,delta*430)
		if distance < 24:
			pickups.remove_at(i)
			effects.burst(player,Color("ffd68f"),"pickup")
			xp += 1
			audio.play_event("xp_pickup")
	if xp >= xp_required():
		xp -= xp_required()
		level += 1
		show_upgrades()
	check_missions()
	if not milestone_claimed[0] and elapsed >= 120:
		milestone_claimed[0] = true
		grant_tickets(1)
	if not milestone_claimed[1] and kills >= 30:
		milestone_claimed[1] = true
		grant_tickets(1)
	update_hud()
	queue_redraw()


func xp_required() -> int:
	return 4+level*3

func nearest_enemy(point: Vector2) -> ArenaEnemy:
	var result: ArenaEnemy
	var distance := INF
	for enemy in enemies:
		if point.distance_squared_to(enemy.position) < distance:
			result = enemy
			distance = point.distance_squared_to(enemy.position)
	return result

func spawn_enemy(kind: int) -> void:
	var enemy := ArenaEnemy.new()
	enemy.setup(kind,wave)
	if kind == 3 and mode == "campaign":
		enemy.boss_style = active_stage
		enemy.hp = [100.0,145.0,185.0,220.0,300.0][active_stage]
		enemy.max_hp = enemy.hp
		enemy.speed = 65+active_stage*5
	enemy.phase = rng.randf_range(0,2)
	enemy.fire_clock = rng.randf_range(1.0,2.5)
	var spawn := Vector2.ZERO
	for attempt in range(16):
		spawn = Vector2(rng.randf_range(90,630),rng.randf_range(Balance.ARENA.position.y+60,Balance.ARENA.end.y-60))
		if rng.randf() < 0.5:
			spawn.x = 90 if rng.randf() < 0.5 else 630
		else:
			spawn.y = Balance.ARENA.position.y+60 if rng.randf() < 0.5 else Balance.ARENA.end.y-60
		if spawn.distance_to(player) > 200:
			break
	if spawn.distance_to(player) <= 200:
		enemy.free()
		return
	enemy.position = Geometry.resolve_all(spawn,enemy.radius,world_obstacles())
	add_child(enemy)
	enemy.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	enemy.reset_physics_interpolation()
	enemies.append(enemy)
	if kind == 3:
		boss = enemy

func damage_enemy(enemy: ArenaEnemy, damage: float, impact := false, incoming := Vector2.ZERO) -> void:
	if not enemies.has(enemy):
		return
	if impact and enemy.blocks(incoming):
		audio.play_event("bounce",0.8)
		return
	audio.play_event("enemy_hit")
	effects.burst(enemy.position,Color("ffc39a"),"hit",incoming)
	enemy.hp -= damage
	enemy.flash = 0.08
	if enemy.hp > 0:
		return
	effects.burst(enemy.position,Color("ffac82"),"death")
	combo += 1
	combo_timer = Balance.COMBO_WINDOW
	best_combo = maxi(combo,best_combo)
	kills += 1
	audio.play_event("enemy_death",1.0+minf(combo*0.015,0.25))
	var points := (100 if enemy.kind == 3 else 10) + mini(combo,50)*2
	score += points
	if combo in [5,20,50]:
		notice("%d KILL CHAIN!" % combo)
	if pickups.size() < 180:
		pickups.append(enemy.position)
	var was_boss := enemy == boss
	if was_boss:
		boss = null
		notice("BOSS DEFEATED!")
	enemies.erase(enemy)
	enemy.queue_free()
	enemy_killed.emit(points)
	if was_boss and mode == "campaign":
		campaign_won = true
		finish_run()

func upgrade_color(index: int) -> Color:
	return Color("ffb779") if index in [0,3,4,5,6,8,9,10,13] else Color("83cfff") if index in [7,12] else Color("b7ed68") if index == 11 else Color("83f5db")

func upgrade_delta(index: int) -> String:
	var current := upgrades[index]
	var next := mini(current+1,Balance.UPGRADE_CAPS[index])
	match index:
		0: return "Sát thương: %.2f → %.2f" % [Shooter.DAMAGES[combat.weapon_id()]*(1+current*0.22),Shooter.DAMAGES[combat.weapon_id()]*(1+next*0.22)]
		1: return "Nhịp bắn: %.2f → %.2f giây" % [Shooter.INTERVALS[combat.weapon_id()]/(1+current*0.16),Shooter.INTERVALS[combat.weapon_id()]/(1+next*0.16)]
		2: return "Đạn mỗi loạt: %d → %d" % [(5 if combat.weapon_id() == 5 else 1)+current,(5 if combat.weapon_id() == 5 else 1)+next]
		3: return "Chí mạng: %d%% → %d%% • sát thương ×1.8" % [current*8,next*8]
		4: return "Sát thương cháy/giây: %.1f → %.1f" % [(0.6 if combat.weapon_id() == 3 else 0)+current*0.5,(0.6 if combat.weapon_id() == 3 else 0)+next*0.5]
		5: return "Xuyên thêm: %d → %d địch" % [current+(3 if combat.weapon_id() == 4 else 1 if combat.weapon_id() == 8 else 12 if combat.weapon_id() == 9 else 0),next+(3 if combat.weapon_id() == 4 else 1 if combat.weapon_id() == 8 else 12 if combat.weapon_id() == 9 else 0)]
		6: return "Nảy sang mục tiêu mới: %d → %d" % [current+(1 if combat.weapon_id() == 1 else 0),next+(1 if combat.weapon_id() == 1 else 0)]
		7:
			if admin_enabled and admin_free_skill: return "Giảm hồi chiêu: %d%% → %d%%\nAdmin đang bỏ hồi kỹ năng" % [current*10,next*10]
			return "Hồi kỹ năng: %.1f → %.1f giây" % [Shooter.SKILL_COOLDOWNS[selected_robot]*(1-current*0.1),Shooter.SKILL_COOLDOWNS[selected_robot]*(1-next*0.1)]
		8: return "Đường chéo: 0 → 2 • sát thương mỗi viên 70%"
		9: return "Đạn phía sau: 0 → 1 • sát thương 80%"
		10: return "Nảy tường: %d → %d lần" % [current,next]
		11: return "Độc/giây: %.1f → %.1f • kéo dài 3 giây" % [(1.2 if combat.weapon_id() == 11 else 0)+current*0.5,(1.2 if combat.weapon_id() == 11 else 0)+next*0.5]
		12: return "Làm chậm: %.1f → %.1f giây" % [(1.4 if combat.weapon_id() == 2 else 0.6 if current > 0 else 0)+current*0.4,(1.4 if combat.weapon_id() == 2 else 0.6)+next*0.4]
		13: return "Nổ lan: %d%% → %d%% sát thương" % [(65 if combat.weapon_id() in [7,10] else 0)+current*18,(65 if combat.weapon_id() in [7,10] else 0)+next*18]
		14: return "Drone: %d → %d • mỗi 0.8 giây" % [current,next]
		15: return "Lưỡi xoay: %d → %d • tầm 78" % [current,next]
	return ""

func show_upgrades() -> void:
	var available: Array[int] = []
	for i in range(upgrades.size()):
		if upgrades[i] < Balance.UPGRADE_CAPS[i]: available.append(i)
	if available.is_empty():
		hp = mini(5,hp+1)
		return
	state = "upgrade"
	reset_stick()
	leveled_up.emit()
	audio.play_event("level_up")
	clear_cards("LÊN CẤP %d" % level,"Chọn 1 nâng cấp")
	cards.add_theme_constant_override("separation",16)
	(cards.get_child(1) as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	(cards.get_child(1) as Label).add_theme_color_override("font_color",Color("8eb8c7"))
	available.shuffle()
	offered_upgrades.clear()
	for i in range(mini(3,available.size())): offered_upgrades.append(available[i])
	var names := Balance.UPGRADE_NAMES
	var hints := Balance.UPGRADE_INFO
	for index in offered_upgrades:
		var accent := upgrade_color(index)
		var card := add_button("",choose_upgrade.bind(index))
		card.name = "Upgrade%d" % index
		card.custom_minimum_size = Vector2(560,178)
		NeonArt.style_button(card,accent)
		var icon := Control.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = Vector2(40,42)
		icon.draw.connect(func(): NeonArt.icon(index,Vector2.ZERO,icon))
		card.add_child(icon)
		var content := VBoxContainer.new()
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.position = Vector2(78,15)
		content.size = Vector2(466,150)
		content.add_theme_constant_override("separation",4)
		card.add_child(content)
		var name_label := result_label(content,names[index]+"  %d → %d/%d" % [upgrades[index],upgrades[index]+1,Balance.UPGRADE_CAPS[index]],26,accent)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		var hint := result_label(content,hints[index],21,Color("a2bfcc"))
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		var delta := result_label(content,upgrade_delta(index),22)
		delta.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		for label in [name_label,hint,delta]: label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_physics_process(0)

func choose_upgrade(index: int) -> void:
	if state != "upgrade" or not offered_upgrades.has(index):
		return
	upgrades[index] = mini(upgrades[index]+1,Balance.UPGRADE_CAPS[index])
	offered_upgrades.clear()
	reset_stick()
	state = "playing"
	upgrade_shade.hide()
	overlay.hide()

func finish_run() -> void:
	if state == "results" or result_paid:
		return
	check_missions()
	state = "results"
	result_paid = true
	reward_profile_path = save_path
	var total := score+int(elapsed)
	previous_record = blitz_best if mode == "blitz" else best_score
	new_record = mode != "campaign" and total > previous_record
	if mode == "blitz":
		blitz_best = maxi(blitz_best,total)
	elif mode != "campaign":
		best_score = maxi(best_score,total)
	var reward := mini(50,int(kills/5)+int(elapsed/30))
	if mode == "campaign" and campaign_won:
		var first := not campaign_cleared.has(active_stage)
		if first: campaign_cleared.append(active_stage)
		campaign_unlocked = maxi(campaign_unlocked,mini(5,active_stage+2))
		preferred_stage = mini(4,active_stage+1)
		var stars := 1+(1 if hp >= 3 else 0)+(1 if elapsed <= float(Campaign.data(active_stage).at)+60 else 0)
		campaign_stars[active_stage] = maxi(campaign_stars[active_stage],stars)
		reward += 40+active_stage*20
		grant_tickets(3 if first else 1)
	if mode == "blitz" and challenge_complete: grant_tickets(1)
	coins += reward
	run_coins = reward+mission_coins
	save_profile()
	audio.stop_all()
	audio.play_event("level_up" if challenge_complete else "defeat")
	var record_text := "CAMPAIGN SCORE" if mode == "campaign" else (("NEW RECORD! +%d" % (total-previous_record)) if new_record else "RECORD %d" % previous_record)
	final_summary = "TIME %s • SCORE %d\nKILLS %d • SKILLS %d • CRITS %d\n%s\nGOLD +%d • TICKETS +%d" % [time_text(),total,kills,combat.skill_uses,combat.criticals,record_text,run_coins,run_tickets]
	for enemy in enemies: enemy.hide()
	combat.hide()
	update_hud()
	show_results()
	run_ended.emit()

func result_label(parent: Node, text: String, font_size := 24, color := Color("d9fbff")) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	parent.add_child(label)
	return label

func show_results() -> void:
	state = "results"
	reset_stick()
	var won := campaign_won if mode == "campaign" else challenge_complete
	clear_cards("HOÀN THÀNH!" if won else "THỬ LẠI NHÉ!", "")
	cards.get_child(1).hide()
	cards.add_theme_constant_override("separation",14)
	result_label(cards,Campaign.data(active_stage).name if mode == "campaign" else "BLITZ • 90 GIÂY" if mode == "blitz" else "SINH TỒN",24,Color("8eb8c7"))
	var portrait := Preview.new()
	portrait.name = "ResultRobot"
	portrait.actor = selected_robot
	portrait.actor_width = 140
	portrait.custom_minimum_size = Vector2(0,150)
	cards.add_child(portrait)
	portrait.modulate = Color("baffed") if won else Color("b0c5db")
	portrait.pivot_offset = Vector2(280,75)
	var reveal := portrait.create_tween()
	portrait.modulate.a = 0
	reveal.tween_property(portrait,"modulate:a",1.0,0.3)
	if mode == "campaign" and campaign_won:
		result_label(cards,"★".repeat(campaign_stars[active_stage]),34,Color("ffd184"))
	if new_record:
		result_label(cards,"KỶ LỤC MỚI! +%d" % (score+int(elapsed)-previous_record),24,Color("ffd184"))
	elif mode == "campaign" and campaign_won and active_stage < 4:
		result_label(cards,"ĐÃ MỞ MÀN %02d" % (active_stage+2),22,Color("8ffff0"))
	var stats := HBoxContainer.new()
	stats.name = "ResultStats"
	stats.add_theme_constant_override("separation",12)
	cards.add_child(stats)
	var values := [str(score+int(elapsed)),time_text(),str(kills)]
	var labels := ["ĐIỂM","THỜI GIAN","HẠ ĐỊCH"]
	for i in range(3):
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.custom_minimum_size.y = 100
		panel.add_theme_stylebox_override("panel",NeonArt.panel(Color("102b3b"),Color("386573"),12))
		stats.add_child(panel)
		var column := VBoxContainer.new()
		panel.add_child(column)
		result_label(column,values[i],30)
		result_label(column,labels[i],18,Color("8eb8c7"))
	var rewards := HBoxContainer.new()
	rewards.name = "ResultRewards"
	rewards.alignment = BoxContainer.ALIGNMENT_CENTER
	rewards.add_theme_constant_override("separation",32)
	cards.add_child(rewards)
	result_label(rewards,"◉ +%d VÀNG" % (run_coins*(2 if double_claimed else 1)),26,Color("ffd184"))
	result_label(rewards,"▣ +%d VÉ" % run_tickets,26,Color("8adfff"))
	if run_coins > 0:
		var claim := add_button("ĐÃ NHẬN X2 VÀNG" if double_claimed else "NHẬN X2 VÀNG • +%d" % run_coins,claim_double_gold)
		claim.name = "ResultDouble"
		claim.custom_minimum_size.y = 80
		claim.disabled = double_claimed or reward_profile_path != save_path
		NeonArt.style_button(claim,Color("ffd184"),true)
	var primary: Button
	if mode == "campaign":
		primary = add_button("MÀN TIẾP THEO" if campaign_won and active_stage < 4 else "CHƠI LẠI",start_campaign.bind(active_stage+1 if campaign_won and active_stage < 4 else active_stage))
	else:
		primary = add_button("CHƠI LẠI",start_run.bind(mode,arena_layout))
	primary.name = "ResultPrimary"
	primary.custom_minimum_size.y = 106
	NeonArt.style_button(primary,Color("8ffff0"),true)
	var secondary := HBoxContainer.new()
	secondary.add_theme_constant_override("separation",12)
	cards.add_child(secondary)
	if mode == "campaign":
		var stages := add_button("CHỌN MÀN",show_campaign)
		cards.remove_child(stages)
		secondary.add_child(stages)
		stages.custom_minimum_size = Vector2(0,80)
		stages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var home := add_button("VỀ SẢNH",show_menu)
	cards.remove_child(home)
	secondary.add_child(home)
	home.custom_minimum_size = Vector2(0,80)
	home.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var details := add_button("CHI TIẾT TRẬN ▾",func(): pass)
	details.name = "ResultDetailsToggle"
	details.custom_minimum_size.y = 64
	details.add_theme_font_size_override("font_size",22)
	var detail_text := result_label(cards,"ĐẠN BẮN %d • TRÚNG ĐÍCH %d\nCHÍ MẠNG %d • KỸ NĂNG %d\nCHUỖI HẠ ĐỊCH %d" % [combat.shots_fired,combat.hits,combat.criticals,combat.skill_uses,best_combo],22,Color("8eb8c7"))
	detail_text.name = "ResultDetails"
	detail_text.hide()
	details.pressed.connect(func():
		detail_text.visible = not detail_text.visible
		details.text = "THU GỌN ▴" if detail_text.visible else "CHI TIẾT TRẬN ▾")


func medal(total: int) -> String:
	if total >= 3000: return "GOLD"
	if total >= 1500: return "SILVER"
	if total >= 600: return "BRONZE"
	return "KEEP PRACTICING • BRONZE AT 600"


func claim_double_gold() -> void:
	# Admin build: instant claim, once per completed run. No ad provider involved.
	if state != "results" or double_claimed or not result_paid or run_coins <= 0 or reward_profile_path != save_path:
		return
	double_claimed = true
	coins += run_coins
	save_profile()
	audio.play_event("level_up")
	show_results()

func time_text() -> String:
	return "%02d:%02d" % [int(elapsed)/60,int(elapsed)%60]

func notice(text: String) -> void:
	toast.text = text
	toast_time = 1.8

func update_hud() -> void:
	var clock := time_text() if mode != "blitz" else "%02d:%02d" % [int(maxf(0,90-elapsed))/60,int(maxf(0,90-elapsed))%60]
	hud.text = "HP %d/5    %s    %s %d\nSCORE %d  •  KILL ×%d" % [hp,clock,"WAVE" if mode != "blitz" else "BLITZ",wave,score+int(elapsed),combo]
	weapon_label.text = "%s • LV %d" % [Shooter.WEAPONS[combat.weapon_id()],level]
	if mode == "campaign": weapon_label.text += "  •  S%d R%d" % [active_stage+1,campaign_room]
	xp_bar.max_value = xp_required()
	xp_bar.value = xp
	mission_label.text = "HẠ ĐỊCH %d/15 • KỸ NĂNG %d/3 • CHUỖI %d/10" % [mini(kills,15),mini(combat.skill_uses,3),mini(best_combo,10)]
	skill_status.text = "NHẤN ĐÚP • "+["KHIÊN","XUNG ĐIỆN","ĐÓNG BĂNG","BÙNG CHÁY","BÃO LASER","TÊN LỬA","LƯỚT"][selected_robot]+" • " + ("SẴN SÀNG" if cooldown <= 0 else "%.1fs" % cooldown)

func _process(delta: float) -> void:
	visual_clock += delta
	queue_redraw()

func _draw() -> void:
	draw_texture_rect(NeonArt.FLOOR,Balance.ARENA,false)
	if state in ["menu","results","admin","summon","summon_results"]:
		draw_rect(Rect2(0,0,720,canvas_height),Color(0.01,0.02,0.05,0.3))
		return
	if mode == "campaign": Campaign.draw_arena(self,Balance.ARENA,active_stage,elapsed)
	for pillar in world_obstacles():
		draw_texture_rect(NeonArt.texture(7),Rect2(pillar.position-Vector2(4,6),pillar.size+Vector2(8,12)),false)
	for point in pickups:
		if not low_effects: NeonArt.glow(self,point,4,Color("ffc777"))
		NeonArt.diamond(self,point,6,Color("ffd38c"))
	if state == "playing":
		draw_line(player+aim*22,player+aim*40,Color("b5fff0"),4)
	# Floating joystick appears only while dragging.
	if joystick_id != -1 and joystick_dragging and state == "playing":
		# Thumb controls: layered rings and a damped visual thumb cap.
		draw_circle(joystick_origin,76,Color(0.04,0.13,0.19,0.85))
		draw_arc(joystick_origin,76,0,TAU,64,Color(0.4,0.85,0.9,0.7),2)
		draw_arc(joystick_origin,69,0,TAU,64,Color(0.3,0.65,0.75,0.25),2)
		for i in range(4):
			var direction := Vector2.from_angle(i*PI/2)
			draw_line(joystick_origin+direction*59-direction.orthogonal()*4,joystick_origin+direction*63,Color(0.4,0.8,0.85,0.5),2)
			draw_line(joystick_origin+direction*63,joystick_origin+direction*59+direction.orthogonal()*4,Color(0.4,0.8,0.85,0.5),2)
		var thumb := joystick_origin+joystick*48
		draw_circle(thumb,29,Color("173e4b"))
		draw_arc(thumb,29,0,TAU,40,Color("60b9c3"),2)


func hurt_player(source: Vector2) -> void:
	if (admin_enabled and admin_god) or invulnerable > 0 or state != "playing":
		return
	if combat.shield > 0 and combat.shield_hits > 0:
		combat.shield_hits -= 1
		invulnerable = 0.25
		effects.burst(player,Color("8bffe1"),"hit")
		return
	hp -= 1
	invulnerable = 1.2
	player = (player+(player-source).normalized()*35).clamp(Balance.ARENA.position+Vector2(18,18),Balance.ARENA.end-Vector2(18,18))
	audio.play_event("player_hit")
	effects.burst(player,Color("93ffe0"),"hit")
	if hp <= 0:
		finish_run()

func check_missions() -> void:
	var progress := [kills,combat.skill_uses,best_combo]
	var goals := [15,3,10]
	for i in range(3):
		if not mission_claimed[i] and progress[i] >= goals[i]:
			mission_claimed[i] = true
			coins += 15
			mission_coins += 15
			grant_tickets(1)
			save_profile()
			audio.play_event("level_up")
			notice("MISSION • +15 COINS +1 TICKET")

func load_profile() -> void:
	selected_weapon = -1
	shoot_while_moving = false
	var config := ConfigFile.new()
	if config.load(save_path) == OK:
		best_score = maxi(0,int(config.get_value("record","shooter_score",0)))
		blitz_best = maxi(0,int(config.get_value("record","shooter_blitz",0)))
		low_effects = bool(config.get_value("settings","low_effects",false))
		coins = maxi(0,int(config.get_value("profile","coins",0)))
		owned_skins = [0]
		var saved: Variant = config.get_value("profile","skins",[0])
		if saved is Array:
			for id in saved:
				if id is int and id >= 0 and id < 4 and not owned_skins.has(id):
					owned_skins.append(id)
		selected_weapon = clampi(int(config.get_value("profile","weapon",-1)),-1,Shooter.WEAPONS.size()-1)
		shoot_while_moving = bool(config.get_value("settings","shoot_while_moving",false))
		selected_skin = int(config.get_value("profile","selected",0))
		if not owned_skins.has(selected_skin): selected_skin = 0
		owned_robots = [0]
		var saved_robots: Variant = config.get_value("profile","robots",[0])
		if saved_robots is Array:
			for id in saved_robots:
				if id is int and id >= 0 and id < RobotRoster.NAMES.size() and not owned_robots.has(id): owned_robots.append(id)
		selected_robot = int(config.get_value("profile","robot",0))
		if not owned_robots.has(selected_robot): selected_robot = 0
		sound_on = bool(config.get_value("settings","sound",true))
		haptics_on = bool(config.get_value("settings","haptics",true))
	preferred_mode = str(config.get_value("lobby","mode","campaign"))
	if preferred_mode not in ["campaign","survival","blitz"]: preferred_mode = "campaign"
	preferred_layout = str(config.get_value("lobby","layout","open"))
	if preferred_layout not in ["open","reflector"]: preferred_layout = "open"
	preferred_stage = clampi(int(config.get_value("lobby","stage",-1)),-1,4)
	summon.read(config)
	campaign_unlocked = clampi(int(config.get_value("campaign","unlocked",1)),1,5)
	campaign_cleared.clear()
	var cleared: Variant = config.get_value("campaign","cleared",[])
	if cleared is Array:
		for id in cleared:
			if id is int and id in range(5) and not campaign_cleared.has(id): campaign_cleared.append(id)
	campaign_stars = [0,0,0,0,0]
	var saved_stars: Variant = config.get_value("campaign","stars",[])
	if saved_stars is Array:
		for i in range(mini(5,saved_stars.size())): campaign_stars[i] = clampi(int(saved_stars[i]),0,3)
	if admin_enabled:
		owned_skins = [0,1,2,3]
		owned_robots = [0,1,2,3,4,5,6]
		coins = maxi(999999,coins)
		admin_god = bool(config.get_value("admin","god",true))
		admin_max_start = bool(config.get_value("admin","max_start",false))
		admin_free_skill = bool(config.get_value("admin","free_skill",config.get_value("admin","free_deflect",false)))
	audio.enabled = sound_on

func save_profile() -> void:
	var config := ConfigFile.new()
	config.load(save_path) # Retain legacy/unknown fields while writing the new schema.
	config.set_value("profile","combat_version",2)
	config.set_value("record","shooter_score",best_score)
	config.set_value("record","shooter_blitz",blitz_best)
	config.set_value("settings","low_effects",low_effects)
	config.set_value("profile","coins",coins)
	config.set_value("profile","skins",owned_skins)
	config.set_value("profile","selected",selected_skin)
	config.set_value("profile","robots",owned_robots)
	config.set_value("profile","robot",selected_robot)
	config.set_value("profile","weapon",selected_weapon)
	config.set_value("settings","shoot_while_moving",shoot_while_moving)
	config.set_value("settings","sound",sound_on)
	config.set_value("settings","haptics",haptics_on)
	if admin_enabled:
		config.set_value("admin","god",admin_god)
		config.set_value("admin","max_start",admin_max_start)
		config.set_value("admin","free_skill",admin_free_skill)
	config.set_value("lobby","mode",preferred_mode)
	config.set_value("lobby","layout",preferred_layout)
	config.set_value("lobby","stage",preferred_stage)
	summon.write(config)
	config.set_value("campaign","unlocked",campaign_unlocked)
	config.set_value("campaign","cleared",campaign_cleared)
	config.set_value("campaign","stars",campaign_stars)
	config.save(save_path)

func show_skins() -> void:
	show_menu()
	clear_cards("BULLET SKINS", "ADMIN • ALL SKINS FREE" if admin_enabled else "COSMETIC ONLY • %d COINS\nPreview each trail below. Earn coins from missions and runs." % coins)
	cards.add_theme_constant_override("separation",10)
	for i in range(4):
		var action := "EQUIPPED" if selected_skin == i else ("EQUIP" if owned_skins.has(i) else "%d COINS" % Balance.SKIN_COSTS[i])
		add_button("%s • %s" % [Balance.SKIN_NAMES[i],action],buy_or_equip.bind(i))
		var button := cards.get_child(cards.get_child_count()-1) as Button
		button.custom_minimum_size.y = 88
		button.add_theme_color_override("font_color",Balance.SKIN_COLORS[i])
		button.add_theme_color_override("font_disabled_color",Balance.SKIN_COLORS[i].darkened(0.2))
		button.disabled = selected_skin == i or (not owned_skins.has(i) and coins < Balance.SKIN_COSTS[i])
		var preview := Preview.new()
		preview.skin = i
		preview.custom_minimum_size = Vector2(500,24)
		cards.add_child(preview)
	add_button("BACK",show_menu)

func buy_or_equip(index: int) -> void:
	if index < 0 or index >= 4:
		return
	if not owned_skins.has(index):
		if coins < Balance.SKIN_COSTS[index]: return
		coins -= Balance.SKIN_COSTS[index]
		owned_skins.append(index)
	selected_skin = index
	save_profile()
	show_skins()

func show_settings() -> void:
	clear_cards("SETTINGS","Âm thanh, hiệu ứng và điều khiển.")
	add_button("HOW TO PLAY",show_help)
	add_button("BẮN KHI DI CHUYỂN: "+("BẬT" if shoot_while_moving else "TẮT"),func(): shoot_while_moving = not shoot_while_moving; save_profile(); show_settings())
	add_button("SOUND: " + ("ON" if sound_on else "OFF"),func(): sound_on = not sound_on; audio.enabled = sound_on; audio.stop_all(); save_profile(); show_settings())
	add_button("LOW EFFECTS: "+("ON" if low_effects else "OFF"),func(): low_effects = not low_effects; save_profile(); show_settings())
	add_button("VIBRATION: " + ("ON" if haptics_on else "OFF"),func(): haptics_on = not haptics_on; save_profile(); show_settings())
	add_button("THÔNG TIN GAME",show_about)
	add_button("BACK",show_menu)

func admin_profile_path() -> String:
	return normal_save_path.get_basename()+"-admin.cfg"

func profile_mode_path() -> String:
	return normal_save_path.get_basename()+"-mode.cfg"

func switch_admin(enabled: bool) -> void:
	if state not in ["menu","results","admin"] or (admin_context and state == "admin"):
		return
	save_profile()
	admin_enabled = enabled
	admin_context = false
	save_path = admin_profile_path() if enabled else normal_save_path
	# Load each mode's own progression. Never copy an admin record into normal play.
	best_score = 0
	blitz_best = 0
	coins = 0
	owned_skins = [0]
	selected_skin = 0
	owned_robots = [0]
	selected_robot = 0
	load_profile()
	var mode_config := ConfigFile.new()
	mode_config.set_value("mode","admin",enabled)
	mode_config.save(profile_mode_path())
	save_profile()
	show_menu()
	show_admin()

func show_admin() -> void:
	if state == "paused": admin_context = true
	elif state in ["menu","results"]: admin_context = false
	state = "admin"
	joystick = Vector2.ZERO
	joystick_id = -1
	clear_cards("ADMIN CONTROL", "ALL CONTENT UNLOCKED\nSeparate admin save • Normal progress is preserved." if admin_enabled else "Owner test tools: free skins, test gold, god mode, upgrade lab and instant boss access.\nYour normal save stays separate.")
	cards.add_theme_constant_override("separation",12)
	if not admin_enabled:
		add_button("ENABLE ADMIN • UNLOCK ALL",switch_admin.bind(true))
	else:
		add_button("TEST OPTIONS",show_admin_options)
		add_button("UPGRADE LAB • ALL 16",show_upgrade_lab)
		add_button("SUMMON BOSS" if admin_context else "START BOSS TEST",admin_boss)
		add_button("ENEMY LAB",show_enemy_lab)
		if not admin_context:
			add_button("ALL SKINS • FREE",show_skins)
			add_button("ALL ROBOTS • FREE",show_robots)
			add_button("CAMPAIGN • ALL STAGES",show_campaign)
			add_button("SUMMON • FREE",show_summon)
			add_button("RETURN TO NORMAL MODE",switch_admin.bind(false))
	add_button("RESUME GAME" if admin_context else "BACK TO MENU",close_admin)

func close_admin() -> void:
	if admin_context:
		admin_context = false
		state = "playing"
		overlay.hide()
	else:
		show_menu()

func show_admin_options() -> void:
	if not admin_enabled: return
	clear_cards("ADMIN OPTIONS","Options apply only in admin. Test all weapons and skills with bounded projectiles.")
	add_button("GOD MODE: "+("ON" if admin_god else "OFF"),toggle_admin_option.bind("god"))
	add_button("START MAX UPGRADES: "+("ON" if admin_max_start else "OFF"),toggle_admin_option.bind("max"))
	add_button("NO SKILL COOLDOWN: "+("ON" if admin_free_skill else "OFF"),toggle_admin_option.bind("skill"))
	add_button("BACK",show_admin)

func toggle_admin_option(option: String) -> void:
	if not admin_enabled or state != "admin": return
	match option:
		"god": admin_god = not admin_god
		"max": admin_max_start = not admin_max_start
		"skill":
			admin_free_skill = not admin_free_skill
			if admin_free_skill: cooldown = 0
	save_profile()
	show_admin_options()

func ensure_admin_arena() -> void:
	if not admin_context:
		start_run("survival","open")
		admin_context = true
		state = "admin"

func show_upgrade_lab() -> void:
	if not admin_enabled: return
	ensure_admin_arena()
	clear_cards("UPGRADE LAB","Game paused. Tap to cycle 0 → cap → 0. Resume to test your build.")
	cards.add_theme_constant_override("separation",10)
	for i in range(upgrades.size()):
		var button := add_button("%s  %d/%d" % [Balance.UPGRADE_NAMES[i],upgrades[i],Balance.UPGRADE_CAPS[i]],admin_cycle_upgrade.bind(i))
		button.custom_minimum_size.y = 88
	add_button("MAX ALL",admin_set_upgrades.bind(true))
	add_button("CLEAR ALL",admin_set_upgrades.bind(false))
	add_button("BACK",show_admin)

func admin_cycle_upgrade(index: int) -> void:
	if not admin_enabled or state != "admin" or index < 0 or index >= upgrades.size(): return
	upgrades[index] = (upgrades[index]+1)%(Balance.UPGRADE_CAPS[index]+1)
	show_upgrade_lab()

func admin_set_upgrades(maximum: bool) -> void:
	if not admin_enabled or state != "admin": return
	for i in range(upgrades.size()): upgrades[i] = Balance.UPGRADE_CAPS[i] if maximum else 0
	show_upgrade_lab()

func admin_boss() -> void:
	if not admin_enabled: return
	ensure_admin_arena()
	if not is_instance_valid(boss): spawn_enemy(3)
	boss_spawned = true
	close_admin()
	notice("ADMIN • SIEGE COMMANDER TEST")

func show_enemy_lab() -> void:
	if not admin_enabled: return
	ensure_admin_arena()
	clear_cards("ENEMY LAB","Paused • Spawn safely at arena edges. Repeated boss requests reuse the live boss.")
	cards.add_theme_constant_override("separation",10)
	var names := ["CHASER","DASHER","TANK","SIEGE COMMANDER","SHIELD GUARD","ZONE CASTER"]
	for i in range(6):
		var button := add_button("SPAWN "+names[i],admin_spawn_enemy.bind(i))
		button.custom_minimum_size.y = 88
	add_button("BACK",show_admin)

func admin_spawn_enemy(kind: int) -> void:
	if not admin_enabled or state != "admin" or kind < 0 or kind > 5: return
	if kind == 3:
		if not is_instance_valid(boss): spawn_enemy(3)
		boss_spawned = true
	elif enemies.size() < Balance.MAX_ENEMIES:
		spawn_enemy(kind)
	show_enemy_lab()

func on_viewport_changed() -> void:
	var size := get_viewport_rect().size
	var safe := Vector2.ZERO
	if OS.has_feature("mobile"):
		var window := DisplayServer.window_get_size()
		var area := DisplayServer.get_display_safe_area()
		if window.y > 0 and area.size.y > 0:
			safe.x = clampf(area.position.y*size.y/window.y,0,size.y*0.12)
			safe.y = clampf((window.y-area.end.y)*size.y/window.y,0,size.y*0.12)
	layout_viewport(size,safe)

func layout_viewport(size: Vector2, safe := Vector2.ZERO) -> void:
	safe_margins = safe
	canvas_height = maxf(1280,size.y)
	horizontal_padding = maxf(0,(size.x-720)*0.5)
	position.x = horizontal_padding
	ui.offset.x = horizontal_padding
	var old_arena := Balance.ARENA
	Balance.ARENA = Rect2(30,165+safe.x,660,canvas_height-425-safe.x-safe.y)
	Geometry.PILLAR = Rect2(305,Balance.ARENA.get_center().y-132.5,110,110)
	if is_instance_valid(player_actor) and old_arena != Balance.ARENA:
		var normalized := (player-old_arena.position)/old_arena.size
		player = Balance.ARENA.position+normalized*Balance.ARENA.size
		player = Geometry.resolve_all(player,18,world_obstacles())
		player_actor.position = player
		player_actor.reset_physics_interpolation()
		combat.shots.clear()
		combat.hostile.clear()
		for enemy in enemies:
			enemy.position = enemy.position.clamp(Balance.ARENA.position+Vector2.ONE*enemy.radius,Balance.ARENA.end-Vector2.ONE*enemy.radius)
			enemy.position = Geometry.resolve_all(enemy.position,enemy.radius,world_obstacles())
			enemy.reset_physics_interpolation()
	header_panel.position.y = 16+safe.x
	hud.position.y = 52+safe.x
	weapon_label.position.y = 110+safe.x
	brand.position.y = 23+safe.x
	health_icons.position.y = 116+safe.x
	xp_bar.position.y = 137+safe.x
	pause_button.position.y = 40+safe.x
	boss_label.position.y = 169+safe.x
	boss_bar.position.y = 198+safe.x
	skill_status.position = Vector2(40,canvas_height-190-safe.y)
	skill_status.size = Vector2(640,64)
	joystick_origin = Vector2(185,canvas_height-145-safe.y)
	joystick_id = -1
	joystick = Vector2.ZERO
	mission_label.position.y = Balance.ARENA.end.y+5
	toast.position.y = Balance.ARENA.end.y-65
	home_shell.layout(canvas_height,safe)
	layout_modal()
	queue_redraw()

func show_robots(index := -1) -> void:
	show_menu()
	robot_gallery_index = selected_robot if index < 0 else clampi(index,0,RobotRoster.NAMES.size()-1)
	var id := robot_gallery_index
	clear_cards("ROBOT HANGAR","ADMIN • ALL ROBOTS FREE" if admin_enabled else "Choose your pilot • %d shards\nEach pilot has a unique skill. Choose weapons separately in Arsenal." % summon.shards)
	cards.add_theme_constant_override("separation",14)
	var portrait := Preview.new()
	portrait.actor = id
	portrait.actor_width = 200
	portrait.custom_minimum_size = Vector2(560,210)
	cards.add_child(portrait)
	var name_label := Label.new()
	var rarity := "STARTER" if id == 0 else "RARE" if id in [1,5,6] else "EPIC" if id in [2,3] else "LEGENDARY"
	name_label.text = RobotRoster.NAMES[id]+" • "+rarity+"\n"+RobotRoster.NOTES[id]+"\n"+Shooter.WEAPONS[id]+" • "+Shooter.SKILLS[id]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size",26)
	name_label.add_theme_color_override("font_color",RobotRoster.COLORS[id])
	cards.add_child(name_label)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation",12)
	cards.add_child(navigation)
	for direction in [-1,1]:
		var next: int = (id+direction+RobotRoster.NAMES.size())%RobotRoster.NAMES.size()
		var button := add_button("‹ PREV" if direction < 0 else "NEXT ›",show_robots.bind(next))
		cards.remove_child(button)
		navigation.add_child(button)
		button.custom_minimum_size = Vector2(270,88)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var action := "EQUIPPED" if selected_robot == id else "EQUIP" if owned_robots.has(id) else "EXCHANGE • %d SHARDS" % Summons.EXCHANGE_COSTS[id]
	var equip := add_button(action,buy_or_equip_robot.bind(id))
	equip.disabled = selected_robot == id or (not owned_robots.has(id) and summon.shards < Summons.EXCHANGE_COSTS[id])
	add_button("BACK TO MENU",show_menu)

func buy_or_equip_robot(index: int) -> void:
	if index < 0 or index >= RobotRoster.NAMES.size(): return
	if not owned_robots.has(index) and not summon.exchange(index,owned_robots,admin_enabled): return
	selected_robot = index
	player_actor.robot = selected_robot
	save_profile()
	show_robots(index)

func world_obstacles() -> Array[Rect2]:
	if obstacle_cache_mode != mode or obstacle_cache_layout != arena_layout or obstacle_cache_stage != active_stage or obstacle_cache_arena != Balance.ARENA or obstacle_cache_pillar != Geometry.PILLAR:
		obstacle_cache_mode = mode
		obstacle_cache_layout = arena_layout
		obstacle_cache_stage = active_stage
		obstacle_cache_arena = Balance.ARENA
		obstacle_cache_pillar = Geometry.PILLAR
		obstacle_cache = []
		if mode == "campaign": obstacle_cache = Campaign.obstacles(Balance.ARENA,active_stage)
		elif arena_layout == "reflector": obstacle_cache.append(Geometry.PILLAR)
	return obstacle_cache

func show_campaign() -> void:
	show_menu()
	clear_cards("CAMPAIGN","Five stages • 3 combat waves + boss each.\nUpgrades carry within a stage. First clear: 3 tickets; replay: 1.")
	cards.add_theme_constant_override("separation",12)
	for i in range(5):
		var unlocked := admin_enabled or i < campaign_unlocked
		var label := "%02d • %s" % [i+1,Campaign.data(i).name]
		label += "  "+"★".repeat(campaign_stars[i]) if unlocked else " • LOCKED"
		var button := add_button(label,show_stage_brief.bind(i))
		button.add_theme_font_size_override("font_size",24)
		button.disabled = not unlocked
	add_button("BACK",show_modes)

func start_campaign(stage: int) -> void:
	if stage < 0 or stage >= 5 or (not admin_enabled and stage >= campaign_unlocked): return
	active_stage = stage
	start_run("campaign","campaign")
	notice("STAGE %d • %s" % [stage+1,Campaign.data(stage).name])

func advance_campaign() -> bool:
	var data: Dictionary = Campaign.data(active_stage)
	var next_room := mini(3,1+int(elapsed/(float(data.at)/3)))
	if next_room > campaign_room and not boss_spawned:
		campaign_room = next_room
		level += 1
		show_upgrades()
		notice("WAVE %d/3 • %s" % [campaign_room,data.name])
		return state != "playing"
	if elapsed >= float(data.at) and not boss_spawned:
		# Clear remaining normal mobs to make the boss pattern readable.
		for enemy in enemies:
			remove_child(enemy)
			enemy.queue_free()
		enemies.clear()
		boss = null
		spawn_enemy(3)
		boss_spawned = is_instance_valid(boss)
		notice("BOSS • %s" % data.boss)
		audio.play_event("boss_warning")
	return false

func grant_tickets(amount: int) -> void:
	if amount <= 0: return
	summon.tickets += amount
	run_tickets += amount
	save_profile()

func show_summon() -> void:
	show_menu()
	clear_cards("ROBOT SUMMON","%s • SHARDS %d\nBase: Rare 75%% / Epic 20%% / Legendary 5%%\nEpic+ pity %d/10 • Legendary pity %d/50\n1 ticket per pull. Every pull gives a robot.\nDuplicates → 5 / 15 / 50 shards." % ["ADMIN • FREE PULLS" if admin_enabled else "TICKETS %d" % summon.tickets,summon.shards,summon.epic_pity,summon.legendary_pity])
	cards.add_theme_constant_override("separation",14)
	var one := add_button("SUMMON ×1"+(" • FREE" if admin_enabled else " • 1 TICKET"),begin_summon.bind(1))
	one.disabled = not admin_enabled and summon.tickets < 1
	var ten := add_button("SUMMON ×10"+(" • FREE" if admin_enabled else " • 10 TICKETS"),begin_summon.bind(10))
	ten.disabled = not admin_enabled and summon.tickets < 10
	add_button("RATES & GUARANTEES",show_summon_rules)
	if not summon.last_results.is_empty(): add_button("LAST RESULTS",show_summon_results)
	add_button("EXCHANGE SHARDS / ROBOTS",show_robots)
	add_button("BACK",show_menu)

func begin_summon(count: int) -> void:
	if state != "menu": return
	state = "summon"
	summon_results = summon.pull(count,owned_robots,admin_enabled)
	if summon_results.is_empty():
		show_summon()
		return
	# The complete cost, pity, inventory and receipt are committed together before
	# the reveal. Reopening/skip reads this receipt; it never performs another pull.
	save_profile()
	summon_revealed = false
	var best: Dictionary = summon_results[0]
	for result in summon_results:
		if result.tier > best.tier: best = result
	clear_cards("SUMMONING…","Opening the robot chamber. Skip changes only the animation.")
	summon_reveal = Reveal.new()
	summon_reveal.robot = int(best.robot)
	summon_reveal.tier = int(best.tier)
	summon_reveal.custom_minimum_size = Vector2(560,250)
	summon_reveal.finished.connect(show_summon_results)
	cards.add_child(summon_reveal)
	add_button("SKIP ANIMATION",summon_reveal.skip)
	audio.play_event("level_up")

func show_summon_results() -> void:
	if summon.last_results.is_empty():
		show_summon()
		return
	state = "summon_results"
	summon_revealed = true
	clear_cards("SUMMON RESULTS","Saved to your collection • %d tickets • %d shards" % [summon.tickets,summon.shards])
	cards.add_theme_constant_override("separation",12)
	var featured: Dictionary = summon.last_results[0]
	for result in summon.last_results:
		if result.tier > featured.tier: featured = result
	var portrait := Preview.new()
	portrait.actor = int(featured.robot)
	portrait.actor_width = 170
	portrait.custom_minimum_size = Vector2(560,180)
	cards.add_child(portrait)
	for result in summon.last_results:
		var label := Label.new()
		var status := "DUPLICATE • +%d SHARDS" % int(result.get("shards",0)) if bool(result.get("duplicate",false)) else "NEW ROBOT"
		label.text = "%s • %s\n%s" % [Summons.TIERS[int(result.tier)],RobotRoster.NAMES[int(result.robot)],status]
		label.add_theme_font_size_override("font_size",24)
		label.add_theme_color_override("font_color",Summons.COLORS[int(result.tier)])
		cards.add_child(label)
	add_button("SUMMON AGAIN",show_summon)
	add_button("ROBOT HANGAR",show_robots)
	add_button("MAIN MENU",show_menu)

func show_stage_brief(stage: int) -> void:
	if stage < 0 or stage > 4 or (not admin_enabled and stage >= campaign_unlocked): return
	var data: Dictionary = Campaign.data(stage)
	clear_cards("%02d • %s" % [stage+1,data.name],"3 combat waves → %s\nBoss enters at %d seconds.\n\n%s\n\nFirst clear: 3 tickets. Repeat: 1. Stars: clear, HP 3+, finish within 60s after boss arrival. Upgrades carry across waves." % [data.boss,int(data.at),data.tip])
	add_button("START STAGE",start_campaign.bind(stage))
	add_button("BACK",show_campaign)

func show_summon_rules() -> void:
	clear_cards("SUMMON RULES","BASE RATES (before pity)\nRare 75%: Volt, Cobalt, Scout (25% each)\nEpic 20%: Frost, Ember (10% each)\nLegendary 5%: Nova\nAegis is your free starter, not in this pool.\n\nGUARANTEES\nAfter 9 Rare pulls, the next pull is Epic or Legendary: a Rare result is promoted to Epic.\nAfter 49 pulls without Legendary, pull 50 is Legendary. Legendary resets both meters; Epic resets only Epic+.\n\nDUPLICATES & EXCHANGE\nRare +5 / Epic +15 / Legendary +50 universal robot shards. Exchange Rare for 30, Epic for 90, Legendary for 300 shards. Owned robots remain owned.\n\nTICKETS\n5 starter tickets, +1 per run mission, +1 at 120 seconds and 30 kills once each per run, +1 for completed Blitz. Campaign first clear +3; replay clear +1. No payments or ads.")
	add_button("BACK",show_summon)

func layout_modal() -> void:
	var top := 144+safe_margins.x if home_shell.visible else 100+safe_margins.x
	var bottom := canvas_height-144-safe_margins.y if home_shell.visible else canvas_height-100-safe_margins.y
	var height := maxf(400,bottom-top)
	if state == "upgrade":
		height = minf(height,800)
		top = safe_margins.x+(canvas_height-safe_margins.x-safe_margins.y-height)*0.5
	upgrade_shade.position = Vector2(-horizontal_padding,0)
	upgrade_shade.size = Vector2(720+horizontal_padding*2,canvas_height)
	var scroll := cards.get_parent() as ScrollContainer
	scroll.custom_minimum_size = Vector2(590,height-64)
	overlay.position = Vector2(35,top)
	overlay.size = Vector2(650,height)

func primary_stage() -> int:
	var latest := clampi(campaign_unlocked-1,0,4)
	return preferred_stage if preferred_stage >= 0 and (admin_enabled or preferred_stage <= latest) else latest

func play_primary() -> void:
	if preferred_mode == "campaign": start_campaign(primary_stage())
	else: start_run(preferred_mode,preferred_layout)

func show_primary_selection() -> void:
	if preferred_mode == "campaign": show_campaign()
	else: show_modes()

func show_profile_menu() -> void:
	state = "menu"
	clear_cards("HỒ SƠ","%s\nRobot: %s\nSurvival: %d • Blitz: %d" % ["ADMIN • Đang bật" if admin_enabled else "CHẾ ĐỘ CHƠI THƯỜNG",RobotRoster.NAMES[selected_robot],best_score,blitz_best])
	add_button("QUẢN TRỊ / ADMIN",show_admin)
	add_button("CÀI ĐẶT",show_settings)
	add_button("HƯỚNG DẪN",show_help)
	add_button("THÔNG TIN GAME",show_about)
	if not OS.has_feature("mobile"): add_button("THOÁT GAME",func(): get_tree().quit())
	add_button("VỀ SẢNH",show_menu)

func show_about() -> void:
	clear_cards("THÔNG TIN","LAST BULLET\nZORVYKA Games\nPhiên bản %s\nAuto Fire. Endless Chaos.\n\nWASD / phím mũi tên: di chuyển\nSpace: kỹ năng • Esc: pause\nF11: fullscreen cửa sổ desktop" % str(ProjectSettings.get_setting("application/config/version")))
	add_button("VỀ SẢNH",show_menu)

static func full_number(value: int) -> String:
	var digits := str(value)
	var result := ""
	for i in range(digits.length()):
		if i > 0 and (digits.length()-i)%3 == 0: result += ","
		result += digits[i]
	return result

func show_wallet() -> void:
	state = "menu"
	clear_cards("TÀI NGUYÊN","VÀNG  %s\nVÉ SUMMON  %s\nMẢNH ROBOT  %s\n\nVàng dùng mở skin đạn. Vé dùng summon; mảnh dùng đổi robot. Chạm số ở thanh trên để xem đầy đủ tại đây." % [full_number(coins),full_number(summon.tickets),full_number(summon.shards)])
	add_button("PHẦN THƯỞNG",show_rewards)
	add_button("SUMMON",show_summon)
	add_button("VỀ SẢNH",show_menu)

func show_lobby_missions() -> void:
	state = "menu"
	clear_cards("NHIỆM VỤ","Mỗi trận có 3 mục tiêu. Mỗi mục tiêu trả tự động 15 vàng + 1 vé, một lần/trận. Bắt đầu trận mới sẽ đặt lại tiến độ.")
	var goals := [15,3,10]
	var progress := [kills,combat.skill_uses,best_combo]
	var names := ["Hạ địch","Dùng kỹ năng","Chuỗi hạ địch"]
	for i in range(3):
		var label := Label.new()
		label.text = "%s  %d/%d\n%s" % [names[i],mini(progress[i],goals[i]),goals[i],"ĐÃ TỰ ĐỘNG NHẬN" if mission_claimed[i] else "+15 vàng • +1 vé"]
		label.add_theme_font_size_override("font_size",26)
		label.add_theme_color_override("font_color",Color("8bffe1") if mission_claimed[i] else Color("c8e3eb"))
		cards.add_child(label)
	add_button("CHƠI NGAY",play_primary)
	add_button("VỀ SẢNH",show_menu)

func pending_lobby_reward() -> bool:
	return result_paid and not double_claimed and run_coins > 0 and reward_profile_path == save_path

func claim_lobby_reward() -> void:
	if not pending_lobby_reward(): return
	state = "results"
	claim_double_gold()
	show_rewards()

func show_rewards() -> void:
	state = "menu"
	clear_cards("PHẦN THƯỞNG","Nhiệm vụ và mốc chơi trả thưởng tự động. Vé khởi đầu, thưởng Campaign và mảnh summon đã được cộng vào ví.")
	if pending_lobby_reward():
		add_button("NHẬN X2 VÀNG • +%s" % full_number(run_coins),claim_lobby_reward)
	else:
		var label := Label.new()
		label.text = "Không có thưởng chờ nhận.\nHoàn thành trận để nhận vàng;\nx2 có thể nhận một lần ở kết quả hoặc sảnh."
		label.add_theme_font_size_override("font_size",24)
		cards.add_child(label)
	add_button("NHIỆM VỤ",show_lobby_missions)
	add_button("SUMMON",show_summon)
	add_button("VỀ SẢNH",show_menu)

func show_armory(index := -2) -> void:
	show_menu()
	armory_preview = selected_weapon if index == -2 else clampi(index,-1,Shooter.WEAPONS.size()-1)
	var id := selected_robot if armory_preview == -1 else armory_preview
	clear_cards("KHO VŨ KHÍ","12 vũ khí mở sẵn để thử • không tốn vàng\nRobot giữ kỹ năng riêng khi đổi vũ khí.")
	cards.add_theme_constant_override("separation",12)
	var preview := preload("res://scripts/weapon_preview.gd").new()
	preview.weapon = id
	preview.custom_minimum_size = Vector2(560,180)
	cards.add_child(preview)
	result_label(cards,("THEO ROBOT • " if armory_preview == -1 else "")+Shooter.WEAPONS[id],30,Shooter.COLORS[id])
	result_label(cards,Shooter.INFO[id],24,Color("abcad6"))
	result_label(cards,"Mỗi viên %.2f • nhịp %.2fs • tầm %d" % [Shooter.DAMAGES[id],Shooter.INTERVALS[id],Shooter.RANGES[id]],22)
	var equip := add_button("ĐANG TRANG BỊ" if selected_weapon == armory_preview else "TRANG BỊ MIỄN PHÍ",equip_weapon.bind(armory_preview))
	equip.disabled = selected_weapon == armory_preview
	add_button("DÙNG VŨ KHÍ ĐẶC TRƯNG ROBOT",show_armory.bind(-1))
	for i in range(Shooter.WEAPONS.size()):
		var choice := add_button(("✓ " if selected_weapon == i else "")+Shooter.WEAPONS[i],show_armory.bind(i))
		choice.custom_minimum_size.y = 76
		choice.add_theme_color_override("font_color",Shooter.COLORS[i])
	add_button("VỀ SẢNH",show_menu)

func equip_weapon(index: int) -> void:
	if state != "menu" or index < -1 or index >= Shooter.WEAPONS.size(): return
	selected_weapon = index
	save_profile()
	show_armory(index)
