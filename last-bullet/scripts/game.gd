extends Node2D

signal enemy_killed(points: int)
signal leveled_up
signal run_ended

var player := Vector2(360, 650)
var aim := Vector2.UP
var bullet: PermanentBullet
var enemies: Array[ArenaEnemy] = []
var boss: ArenaEnemy
var pickups: Array[Vector2] = []
var fires: Array[Dictionary] = []
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
var attempts := 0
var deflect_successes := 0
var perfect_chain := 0
var best_perfect_chain := 0
var lifetime_chain := 0
var blitz_best := 0
var previous_record := 0
var new_record := false
var low_effects := false
var final_summary := ""
var selected_robot := 0
var owned_robots: Array[int] = [0]
var robot_gallery_index := 0
var perfect_label: Label
var admin_enabled := false
var normal_save_path := ""
var admin_context := false
var admin_god := true
var admin_max_start := false
var admin_free_deflect := false

const AudioDirector = preload("res://scripts/audio.gd")
var audio: Node
var upgrades: Array[int] = [0,0,0,0,0,0,0,0]
var coins := 0
var owned_skins: Array[int] = [0]
var selected_skin := 0
var sound_on := true
var haptics_on := true
var save_path := "user://records.cfg"
var perfect_count := 0
var mission_claimed: Array[bool] = [false,false,false]
var mission_label: Label
var deflect_button: Button
var pause_button: Button
var feedback := 0.0
var last_deflect_perfect := false
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
var deflect_window := 0.0
var slow := 0.0
var fire_timer := 0.0
var boss_spawned := false
var best_score := 0
var joystick_id := -1
var joystick := Vector2.ZERO
var joystick_origin := Vector2(185,1135)
var joystick_touch_origin := Vector2.ZERO
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
	perfect_label = Label.new()
	perfect_label.position = Vector2(42,110)
	perfect_label.add_theme_font_size_override("font_size",20)
	perfect_label.add_theme_color_override("font_color",Color("a1f5e0"))
	root.add_child(perfect_label)
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
	var deflect := Button.new()
	deflect_button = deflect
	deflect.focus_mode = Control.FOCUS_NONE
	deflect.text = "DEFLECT\nSPACE"
	deflect.position = Vector2(495,1070)
	deflect.size = Vector2(190,145)
	deflect.add_theme_font_size_override("font_size",24)
	deflect.button_down.connect(request_deflect)
	NeonArt.style_button(deflect,Color("7fffe1"),true)
	root.add_child(deflect)
	toast = Label.new()
	toast.position = Vector2(40,955)
	toast.size = Vector2(640,50)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.add_theme_font_size_override("font_size",23)
	root.add_child(toast)
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
	state = "menu"
	audio.stop_all()
	for enemy in enemies: enemy.hide()
	if is_instance_valid(bullet): bullet.hide()
	clear_card_nodes()
	overlay.hide()
	home_shell.open_home()
	layout_modal()

func show_help() -> void:
	clear_cards("ONE SHOT. YOUR CALL.", "1. Move with WASD / arrows, or drag the left joystick. Avoid coral enemies.\n\n2. Aim with movement; the arrow previews your next deflect. Press SPACE inside the outer ring. Catch an incoming bullet inside the gold ring for PERFECT!\n\n3. Collect XP, choose upgrades, complete missions for skin coins. Shields block front hits; dodge yellow marked zones. Your bullet is harmless.\n\nPLAY offers Open, Reflector and 90-second Blitz. Chain Perfect catches for bonus points. After boss release, deflect back while its core is gold for x4 damage. Claim x2 gold instantly on results.")
	add_button("BACK", show_menu)

func show_modes() -> void:
	clear_cards("CHOOSE YOUR RUN","Open arena to learn. Reflector to experiment. Blitz for a quick score chase.")
	add_button("CAMPAIGN • 5 STAGES",show_campaign)
	add_button("SURVIVAL • OPEN",start_run.bind("survival","open"))
	add_button("SURVIVAL • REFLECTOR",start_run.bind("survival","reflector"))
	add_button("BLITZ • 90 SECONDS",start_run.bind("blitz","open"))
	add_button("BACK",show_menu)

func start_run(run_mode := "survival", layout := "open") -> void:
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
	attempts = 0
	deflect_successes = 0
	perfect_chain = 0
	best_perfect_chain = 0
	new_record = false
	if mode == "blitz":
		rng.seed = 90300
	else:
		rng.randomize()
	if is_instance_valid(bullet):
		remove_child(bullet)
		bullet.queue_free()
	for enemy in enemies:
		remove_child(enemy)
		enemy.queue_free()
	enemies.clear()
	boss = null
	pickups.clear()
	fires.clear()
	upgrades = [0,0,0,0,0,0,0,0]
	if admin_enabled and admin_max_start:
		for i in range(upgrades.size()): upgrades[i] = Balance.UPGRADE_CAPS[i]
	perfect_count = 0
	mission_claimed = [false,false,false]
	result_paid = false
	reward_profile_path = ""
	feedback = 0
	fire_timer = 0
	last_deflect_perfect = false
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
	deflect_window = 0
	invulnerable = 0
	slow = 0
	boss_spawned = false
	joystick_id = -1
	joystick = Vector2.ZERO
	bullet = PermanentBullet.new()
	bullet.name = "Bullet"
	bullet.z_index = 20
	bullet.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	bullet.skin = selected_skin
	bullet.position = player + Vector2(0,-45)
	add_child(bullet)
	bullet.reset_physics_interpolation()
	state = "playing"
	update_hud()
	overlay.hide()
	notice("ONE BULLET. MAKE IT COUNT.")

func _input(event: InputEvent) -> void:
	# Release even if a finger ends over a GUI button that consumes the event.
	if event is InputEventScreenTouch and not event.pressed and event.index == joystick_id:
		reset_stick()
	if event is InputEventMouseButton and not event.pressed and joystick_id == -2:
		reset_stick()

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
			request_deflect()
		elif event.keycode == KEY_ESCAPE:
			toggle_pause()
	if state != "playing":
		return
	var pointer := Vector2.ZERO
	if event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventMouse:
		pointer = event.position-Vector2(horizontal_padding,0)
	if event is InputEventScreenTouch:
		if event.pressed and in_movement_zone(pointer) and joystick_id == -1:
			joystick_id = event.index
			joystick_origin = comfortable_stick_origin(pointer)
			joystick_touch_origin = pointer
		elif not event.pressed and event.index == joystick_id:
			joystick_id = -1
			joystick = Vector2.ZERO
	if event is InputEventScreenDrag and event.index == joystick_id:
		joystick = ((pointer - joystick_touch_origin) / 70).limit_length()
	# Mouse joystick for desktop preview; keyboard works independently.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and in_movement_zone(pointer) and joystick_id == -1:
			joystick_id = -2
			joystick_origin = comfortable_stick_origin(pointer)
			joystick_touch_origin = pointer
		elif not event.pressed and joystick_id == -2:
			joystick_id = -1
			joystick = Vector2.ZERO
	if event is InputEventMouseMotion and joystick_id == -2:
		joystick = ((pointer - joystick_touch_origin)/70).limit_length()

func in_movement_zone(pointer: Vector2) -> bool:
	if not Rect2(0,safe_margins.x,720,canvas_height-safe_margins.x-safe_margins.y).has_point(pointer):
		return false
	# Buttons own their touches; all other screen space can start movement.
	for button in [pause_button,deflect_button]:
		if button.is_visible_in_tree() and Rect2(button.position,button.size).has_point(pointer):
			return false
	return true

func comfortable_stick_origin(pointer: Vector2) -> Vector2:
	# The ring follows the finger inside the safe play area, without clipping edges.
	return pointer.clamp(Vector2(80,safe_margins.x+80),Vector2(640,canvas_height-safe_margins.y-90))

func reset_stick() -> void:
	joystick_id = -1
	joystick = Vector2.ZERO
	joystick_origin = Vector2(185,canvas_height-safe_margins.y-145)

func request_deflect() -> void:
	if state == "playing" and cooldown <= 0:
		attempts += 1
		deflect_window = 0.22
		cooldown = 0.0 if admin_enabled and admin_free_deflect else 0.65 + upgrades[7]*0.12
		# Immediate sampling distinguishes a timed press from an early buffered catch.
		try_deflect(true)

func toggle_pause() -> void:
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
	deflect_button.visible = state in ["playing","paused","upgrade"]
	pause_button.visible = state in ["playing","paused"]
	hud.visible = state in ["playing","paused","upgrade"]
	xp_bar.visible = state in ["playing","paused","upgrade"]
	mission_label.visible = state in ["playing","paused","upgrade"]
	var playing_ui := state in ["playing","paused","upgrade"]
	player_actor.visible = playing_ui and (invulnerable <= 0 or int(invulnerable*15)%2 == 0)
	header_panel.visible = playing_ui
	brand.text = "LAST BULLET • ADMIN" if admin_enabled else "LAST BULLET"
	brand.visible = playing_ui
	perfect_label.visible = playing_ui
	health_icons.visible = playing_ui
	health_icons.queue_redraw()
	effects.visible = playing_ui
	boss_label.visible = playing_ui and is_instance_valid(boss)
	boss_bar.visible = boss_label.visible
	if boss_label.visible:
		var boss_name: String = Campaign.data(active_stage).boss if mode == "campaign" else "BULLET EATER"
		boss_label.text = boss_name+" • " + ("CAPTURING" if bullet.capture > 0 else boss.status_text())
		boss_bar.max_value = boss.max_hp
		boss_bar.value = boss.hp
	toast_time = maxf(0,toast_time-delta)
	toast.visible = toast_time > 0
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
	cooldown = 0.0 if admin_enabled and admin_free_deflect else maxf(0,cooldown-delta)
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
	if deflect_window > 0:
		if not try_deflect(false):
			deflect_window -= delta
			if deflect_window <= 0:
				perfect_chain = 0
				notice("MISSED • PERFECT CHAIN RESET")
	player_actor.position = player
	player_actor.moving = player_moving
	player_actor.target_lean = player_lean
	player_actor.flash = maxf(0,invulnerable-1.1)*0.8 if invulnerable <= 1.2 else 0.0
	bullet.effects_reduced = low_effects or enemies.size() > 24
	bullet.advance(delta,self)
	if state != "playing": return
	if mode == "campaign":
		var hazard_index := 0
		for box in Campaign.hot_zones(Balance.ARENA,active_stage):
			if Campaign.heat_state(elapsed,hazard_index) == 2 and box.grow(15).has_point(player): hurt_player(box.get_center())
			hazard_index += 1
		if state != "playing": return
	slow = maxf(0,slow-delta)
	var enemy_delta := delta * (0.35 if slow > 0 else 1.0)
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy):
			continue
		var target := Geometry.navigate(enemy.position,player,enemy.radius,world_obstacles()) if enemy.kind != 5 else player
		enemy.advance(enemy_delta,target)
		enemy.weak_timer = maxf(0,enemy.weak_timer-(delta-enemy_delta))
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
		notice("BULLET EATER HAS ARRIVED")
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
	fire_timer -= delta
	if upgrades[4] > 0 and fire_timer <= 0 and bullet.capture <= 0:
		fire_timer = 0.16
		fires.append({"p":bullet.position,"ttl":0.7,"tick":0.0})
	for i in range(fires.size()-1,-1,-1):
		fires[i].ttl -= delta
		fires[i].tick -= delta
		if fires[i].ttl <= 0:
			fires.remove_at(i)
			continue
		if fires[i].tick <= 0:
			fires[i].tick = 0.3
			for enemy in enemies.duplicate():
				if enemy.position.distance_to(fires[i].p) < enemy.radius+15:
					damage_enemy(enemy,0.2*upgrades[4])
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

func bullet_speed() -> float:
	return minf(Balance.MAX_BULLET_SPEED,Balance.BULLET_SPEED*(1+upgrades[1]*0.12))

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
		enemy.hp = [20.0,32.0,42.0,50.0,75.0][active_stage]
		enemy.max_hp = enemy.hp
		enemy.speed = 65+active_stage*5
		enemy.capture_ready = 4
	enemy.phase = rng.randf_range(0,2)
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
	if (enemy.kind == 4 and not impact) or (impact and enemy.blocks(incoming)):
		audio.play_event("bounce",0.8)
		return
	if enemy.kind == 3 and impact and bullet.return_strike and enemy.weak_timer > 0:
		damage *= 4
		bullet.return_strike = false
		notice("RETURN STRIKE • ×4 DAMAGE!")
		audio.play_event("deflect",1.35)
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
		notice("BULLET EATER DEFEATED!")
	enemies.erase(enemy)
	enemy.queue_free()
	enemy_killed.emit(points)
	if was_boss and mode == "campaign":
		campaign_won = true
		finish_run()

func show_upgrades() -> void:
	var available: Array[int] = []
	for i in range(upgrades.size()):
		if upgrades[i] < Balance.UPGRADE_CAPS[i]:
			available.append(i)
	if available.is_empty():
		hp = mini(5,hp+1)
		return
	state = "upgrade"
	joystick = Vector2.ZERO
	joystick_id = -1
	leveled_up.emit()
	audio.play_event("level_up")
	clear_cards("LEVEL %d" % level,"Choose one. The arena waits.")
	available.shuffle()
	offered_upgrades.clear()
	for i in range(mini(3,available.size())):
		offered_upgrades.append(available[i])
	for i in range(mini(3,available.size())):
		var index := available[i]
		var card := add_button("%s [%d/%d]\n%s" % [Balance.UPGRADE_NAMES[index],upgrades[index],Balance.UPGRADE_CAPS[index],Balance.UPGRADE_INFO[index]],choose_upgrade.bind(index))
		card.add_theme_font_size_override("font_size",26)
		card.alignment = HORIZONTAL_ALIGNMENT_LEFT
		for style_name in ["normal","hover","pressed","disabled"]:
			var style := card.get_theme_stylebox(style_name).duplicate() as StyleBoxFlat
			style.content_margin_left = 70
			style.content_margin_right = 12
			card.add_theme_stylebox_override(style_name,style)
		var icon := Control.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = Vector2(30,39)
		icon.draw.connect(func(): NeonArt.icon(index,Vector2.ZERO,icon))
		card.add_child(icon)
		card.add_theme_constant_override("outline_size",2)

func choose_upgrade(index: int) -> void:
	if state != "upgrade" or not offered_upgrades.has(index):
		return
	upgrades[index] = mini(upgrades[index]+1,Balance.UPGRADE_CAPS[index])
	offered_upgrades.clear()
	state = "playing"
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
	lifetime_chain = maxi(lifetime_chain,best_perfect_chain)
	var reward := mini(50,int(kills/5)+int(elapsed/30))
	if mode == "campaign" and campaign_won:
		var first := not campaign_cleared.has(active_stage)
		if first: campaign_cleared.append(active_stage)
		campaign_unlocked = maxi(campaign_unlocked,mini(5,active_stage+2))
		preferred_stage = mini(4,active_stage+1)
		var stars := 1+(1 if hp >= 3 else 0)+(1 if perfect_count >= 3 else 0)
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
	final_summary = "TIME %s  •  SCORE %d\nKILLS %d\nPERFECT %d  •  BEST STREAK %d\nDEFLECT %d/%d (%d%%)\n%s\nCOINS: run %d + missions %d = %d" % [time_text(),total,kills,perfect_count,best_perfect_chain,deflect_successes,attempts,deflect_rate(),record_text,reward,mission_coins,run_coins]
	final_summary += "\nTICKETS +%d • TOTAL %d" % [run_tickets,summon.tickets]
	if mode == "campaign":
		final_summary = ("STAGE CLEAR • %s" % "★".repeat(campaign_stars[active_stage]) if campaign_won else "STAGE FAILED • RETRY")+"\n"+Campaign.data(active_stage).name+"\n"+final_summary
	if mode == "blitz":
		final_summary = ("FINISHED • " if challenge_complete else "TIME CHALLENGE • ")+medal(total)+"\n"+final_summary
	for enemy in enemies: enemy.hide()
	bullet.hide()
	update_hud()
	show_results()
	run_ended.emit()

func show_results() -> void:
	state = "results"
	clear_cards("CAMPAIGN RESULTS" if mode == "campaign" else "BLITZ RESULTS" if mode == "blitz" else "RUN COMPLETE",final_summary+"\n"+next_skin_hint()+"\nWALLET %d" % coins)
	cards.add_theme_constant_override("separation",12)
	if run_coins > 0:
		add_button("CLAIM X2 GOLD • +%d" % run_coins if not double_claimed else "X2 CLAIMED • +%d" % run_coins,claim_double_gold)
		(cards.get_child(cards.get_child_count()-1) as Button).disabled = double_claimed
	if mode == "campaign":
		if campaign_won and active_stage < 4: add_button("NEXT STAGE",start_campaign.bind(active_stage+1))
		add_button("RETRY STAGE",start_campaign.bind(active_stage))
		add_button("STAGE SELECT",show_campaign)
	else:
		add_button("RETRY",start_run.bind(mode,arena_layout))
	add_button("SUMMON",show_summon)
	add_button("MAIN MENU",show_menu)

func deflect_rate() -> int:
	return clampi(int(round(100.0*deflect_successes/maxi(1,attempts))),0,100)

func medal(total: int) -> String:
	if total >= 3000: return "GOLD"
	if total >= 1500: return "SILVER"
	if total >= 600: return "BRONZE"
	return "KEEP PRACTICING • BRONZE AT 600"

func next_skin_hint() -> String:
	for i in range(1,4):
		if not owned_skins.has(i):
			var missing := maxi(0,Balance.SKIN_COSTS[i]-coins)
			return "%d coins to %s" % [missing,Balance.SKIN_NAMES[i]] if missing > 0 else "%s is ready to unlock!" % Balance.SKIN_NAMES[i]
	return "ALL SKINS UNLOCKED • BEST PERFECT STREAK %d" % lifetime_chain

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
	perfect_label.text = "PERFECT ×%d  •  LV %d" % [perfect_chain,level]
	if mode == "campaign": perfect_label.text += "  •  S%d R%d" % [active_stage+1,campaign_room]
	xp_bar.max_value = xp_required()
	xp_bar.value = xp
	mission_label.text = "MISSIONS  Kills %d/15  •  Perfect %d/3  •  Chain %d/10" % [mini(kills,15),mini(perfect_count,3),mini(best_combo,10)]
	deflect_button.text = "DEFLECT\n" + ("READY" if cooldown <= 0 else "%.1fs" % cooldown)

func _process(delta: float) -> void:
	visual_clock += delta
	queue_redraw()

func _draw() -> void:
	draw_texture_rect(NeonArt.FLOOR,Balance.ARENA,false)
	if state in ["menu","results","admin","summon","summon_results"]:
		draw_rect(Rect2(0,0,720,1280),Color(0.01,0.02,0.05,0.3))
		return
	if mode == "campaign": Campaign.draw_arena(self,Balance.ARENA,active_stage,elapsed)
	for pillar in world_obstacles():
		draw_texture_rect(NeonArt.texture(7),Rect2(pillar.position-Vector2(4,6),pillar.size+Vector2(8,12)),false)
	for point in pickups:
		if not low_effects: NeonArt.glow(self,point,4,Color("ffc777"))
		NeonArt.diamond(self,point,6,Color("ffd38c"))
	for fire in fires:
		var alpha: float = fire.ttl*(0.2 if low_effects or enemies.size()>24 else 0.4)
		draw_circle(fire.p,15,Color(1,0.45,0.12,alpha))
		draw_arc(fire.p,8,0,TAU,12,Color(1,0.7,0.2,alpha),2)
	var ready := cooldown <= 0
	draw_arc(player,deflect_radius(),0,TAU,64,Color(0.3,1,0.8,0.55 if ready else 0.13),1.5)
	draw_arc(player,Balance.PERFECT_RADIUS,0,TAU,48,Color(1,0.82,0.4,0.6),1.5)
	if not ready:
		var progress := 1-cooldown/(0.65+upgrades[7]*0.12)
		draw_arc(player,deflect_radius(),-PI/2,-PI/2+TAU*progress,48,Color(0.5,1,0.9,0.6),2.5)
	if is_instance_valid(bullet) and bullet.capture <= 0 and player.distance_to(bullet.position) < deflect_radius()+80:
		var end := player+aim*145
		draw_line(player+aim*27,end,Color(0.6,1,0.85,0.7),3)
		draw_colored_polygon(PackedVector2Array([end+aim*5,end-aim.rotated(0.5)*22,end-aim.rotated(-0.5)*22]),Color("a4ffe0"))
	if deflect_window > 0:
		draw_arc(player,deflect_radius()-8,0,TAU,64,Color.WHITE,3)
	if is_instance_valid(bullet) and bullet.capture <= 0 and player.distance_to(bullet.position) > 280:
		var direction := (bullet.position-player).normalized()
		var pointer := player+direction*125
		draw_colored_polygon(PackedVector2Array([pointer+direction*13,pointer-direction.rotated(0.65)*10,pointer-direction.rotated(-0.65)*10]),Color("d7fdff"))
	if is_instance_valid(bullet) and bullet.capture > 0:
		draw_line(bullet.position,player,Color(1,0.8,0.3,0.4),3)
	# Floating joystick appears only while dragging.
	if joystick_id != -1 and state == "playing":
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

func deflect_radius() -> float:
	return Balance.DEFLECT_RADIUS + upgrades[7]*18

func try_deflect(immediate: bool) -> bool:
	if bullet.capture > 0 or player.distance_to(bullet.position) > deflect_radius():
		return false
	var incoming := bullet.velocity.dot(player-bullet.position) > 0
	deflect_successes += 1
	last_deflect_perfect = immediate and incoming and player.distance_to(bullet.position) <= Balance.PERFECT_RADIUS
	bullet.velocity = aim * bullet_speed()
	bullet.boost = 2.2 if last_deflect_perfect else 1.0
	bullet.perfect_boost = last_deflect_perfect
	bullet.pierce_left = upgrades[5]
	bullet.bank_charge = 0
	bullet.return_strike = bullet.return_window > 0
	deflect_window = 0
	if upgrades[3] > 0:
		slow = 0.6+upgrades[3]*0.3
	if last_deflect_perfect:
		perfect_count += 1
		perfect_chain += 1
		best_perfect_chain = maxi(best_perfect_chain,perfect_chain)
		if perfect_chain > lifetime_chain:
			lifetime_chain = perfect_chain
			save_profile()
		score += 25*mini(perfect_chain,10)
		feedback = 0.45
		effects.burst(player,Color("ffe6a3"),"perfect")
		if haptics_on and OS.has_feature("mobile"):
			Input.vibrate_handheld(35)
	else:
		perfect_chain = 0
	audio.play_event("deflect",minf(1.4,1.1+perfect_chain*0.04) if last_deflect_perfect else 0.9)
	notice("PERFECT ×%d • +%d" % [perfect_chain,25*mini(perfect_chain,10)] if last_deflect_perfect else "DEFLECT!")
	check_missions()
	return true

func hurt_player(source: Vector2) -> void:
	if (admin_enabled and admin_god) or invulnerable > 0 or state != "playing":
		return
	hp -= 1
	invulnerable = 1.2
	player = (player+(player-source).normalized()*35).clamp(Balance.ARENA.position+Vector2(18,18),Balance.ARENA.end-Vector2(18,18))
	audio.play_event("player_hit")
	effects.burst(player,Color("93ffe0"),"hit")
	if hp <= 0:
		finish_run()

func check_missions() -> void:
	var progress := [kills,perfect_count,best_combo]
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
	var config := ConfigFile.new()
	if config.load(save_path) == OK:
		best_score = maxi(0,int(config.get_value("record","score",0)))
		blitz_best = maxi(0,int(config.get_value("record","blitz",0)))
		lifetime_chain = maxi(0,int(config.get_value("record","perfect_chain",0)))
		low_effects = bool(config.get_value("settings","low_effects",false))
		coins = maxi(0,int(config.get_value("profile","coins",0)))
		owned_skins = [0]
		var saved: Variant = config.get_value("profile","skins",[0])
		if saved is Array:
			for id in saved:
				if id is int and id >= 0 and id < 4 and not owned_skins.has(id):
					owned_skins.append(id)
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
		admin_free_deflect = bool(config.get_value("admin","free_deflect",false))
	audio.enabled = sound_on

func save_profile() -> void:
	var config := ConfigFile.new()
	config.set_value("record","score",best_score)
	config.set_value("record","blitz",blitz_best)
	config.set_value("record","perfect_chain",lifetime_chain)
	config.set_value("settings","low_effects",low_effects)
	config.set_value("profile","coins",coins)
	config.set_value("profile","skins",owned_skins)
	config.set_value("profile","selected",selected_skin)
	config.set_value("profile","robots",owned_robots)
	config.set_value("profile","robot",selected_robot)
	config.set_value("settings","sound",sound_on)
	config.set_value("settings","haptics",haptics_on)
	if admin_enabled:
		config.set_value("admin","god",admin_god)
		config.set_value("admin","max_start",admin_max_start)
		config.set_value("admin","free_deflect",admin_free_deflect)
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
	lifetime_chain = 0
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
		add_button("UPGRADE LAB • ALL 8",show_upgrade_lab)
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
	clear_cards("ADMIN OPTIONS","Options apply only while admin is enabled. Upgrades still use safe caps and one bullet.")
	add_button("GOD MODE: "+("ON" if admin_god else "OFF"),toggle_admin_option.bind("god"))
	add_button("START MAX UPGRADES: "+("ON" if admin_max_start else "OFF"),toggle_admin_option.bind("max"))
	add_button("NO DEFLECT COOLDOWN: "+("ON" if admin_free_deflect else "OFF"),toggle_admin_option.bind("deflect"))
	add_button("BACK",show_admin)

func toggle_admin_option(option: String) -> void:
	if not admin_enabled or state != "admin": return
	match option:
		"god": admin_god = not admin_god
		"max": admin_max_start = not admin_max_start
		"deflect":
			admin_free_deflect = not admin_free_deflect
			if admin_free_deflect: cooldown = 0
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
	notice("ADMIN • BULLET EATER TEST")

func show_enemy_lab() -> void:
	if not admin_enabled: return
	ensure_admin_arena()
	clear_cards("ENEMY LAB","Paused • Spawn safely at arena edges. Repeated boss requests reuse the live boss.")
	cards.add_theme_constant_override("separation",10)
	var names := ["CHASER","DASHER","TANK","BULLET EATER","SHIELD GUARD","ZONE CASTER"]
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
	if is_instance_valid(bullet) and old_arena != Balance.ARENA:
		var normalized := (player-old_arena.position)/old_arena.size
		player = Balance.ARENA.position+normalized*Balance.ARENA.size
		player = Geometry.resolve_all(player,18,world_obstacles())
		player_actor.position = player
		player_actor.reset_physics_interpolation()
		bullet.position = bullet.position.clamp(Balance.ARENA.position+Vector2(8,8),Balance.ARENA.end-Vector2(8,8))
		bullet.position = Geometry.resolve_all(bullet.position,7,world_obstacles())
		bullet.trail.clear()
		bullet.reset_physics_interpolation()
		for enemy in enemies:
			enemy.position = enemy.position.clamp(Balance.ARENA.position+Vector2.ONE*enemy.radius,Balance.ARENA.end-Vector2.ONE*enemy.radius)
			enemy.position = Geometry.resolve_all(enemy.position,enemy.radius,world_obstacles())
			enemy.reset_physics_interpolation()
	header_panel.position.y = 16+safe.x
	hud.position.y = 52+safe.x
	perfect_label.position.y = 110+safe.x
	brand.position.y = 23+safe.x
	health_icons.position.y = 116+safe.x
	xp_bar.position.y = 137+safe.x
	pause_button.position.y = 40+safe.x
	boss_label.position.y = 169+safe.x
	boss_bar.position.y = 198+safe.x
	deflect_button.position = Vector2(475,canvas_height-215-safe.y)
	deflect_button.size = Vector2(210,155)
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
	clear_cards("ROBOT HANGAR","ADMIN • ALL ROBOTS FREE" if admin_enabled else "Choose your pilot • %d shards\nCosmetic only. Summon or exchange for new pilots." % summon.shards)
	cards.add_theme_constant_override("separation",14)
	var portrait := Preview.new()
	portrait.actor = id
	portrait.actor_width = 200
	portrait.custom_minimum_size = Vector2(560,210)
	cards.add_child(portrait)
	var name_label := Label.new()
	var rarity := "STARTER" if id == 0 else "RARE" if id in [1,5,6] else "EPIC" if id in [2,3] else "LEGENDARY"
	name_label.text = RobotRoster.NAMES[id]+" • "+rarity+"\n"+RobotRoster.NOTES[id]
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
	clear_cards("%02d • %s" % [stage+1,data.name],"3 combat waves → %s\nBoss enters at %d seconds.\n\n%s\n\nFirst clear: 3 tickets. Repeat clear: 1 ticket. Upgrades carry across this stage's waves." % [data.boss,int(data.at),data.tip])
	add_button("START STAGE",start_campaign.bind(stage))
	add_button("BACK",show_campaign)

func show_summon_rules() -> void:
	clear_cards("SUMMON RULES","BASE RATES (before pity)\nRare 75%: Volt, Cobalt, Scout (25% each)\nEpic 20%: Frost, Ember (10% each)\nLegendary 5%: Nova\nAegis is your free starter, not in this pool.\n\nGUARANTEES\nAfter 9 Rare pulls, the next pull is Epic or Legendary: a Rare result is promoted to Epic.\nAfter 49 pulls without Legendary, pull 50 is Legendary. Legendary resets both meters; Epic resets only Epic+.\n\nDUPLICATES & EXCHANGE\nRare +5 / Epic +15 / Legendary +50 universal robot shards. Exchange Rare for 30, Epic for 90, Legendary for 300 shards. Owned robots remain owned.\n\nTICKETS\n5 starter tickets, +1 per run mission, +1 at 120 seconds and 30 kills once each per run, +1 for completed Blitz. Campaign first clear +3; replay clear +1. No payments or ads.")
	add_button("BACK",show_summon)

func layout_modal() -> void:
	var top := 144+safe_margins.x if home_shell.visible else 100+safe_margins.x
	var bottom := canvas_height-144-safe_margins.y if home_shell.visible else canvas_height-100-safe_margins.y
	var height := maxf(400,bottom-top)
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
	clear_cards("THÔNG TIN","LAST BULLET\nZORVYKA Games\nPhiên bản %s\nOne Shot. Endless Chaos.\n\nWASD / phím mũi tên: di chuyển\nSpace: deflect • Esc: pause\nF11: fullscreen cửa sổ desktop" % str(ProjectSettings.get_setting("application/config/version")))
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
	var progress := [kills,perfect_count,best_combo]
	var names := ["Hạ địch","Perfect Deflect","Chuỗi hạ địch"]
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
