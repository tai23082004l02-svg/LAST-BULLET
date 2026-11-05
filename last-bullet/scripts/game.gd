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
var joystick_origin := Vector2(135,1135)
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
	load_profile()
	effects = FX.new()
	effects.z_index = 12
	add_child(effects)
	player_actor = load("res://scripts/player_visual.gd").new()
	player_actor.z_index = 5
	add_child(player_actor)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	build_ui()
	show_menu()

func build_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(root)
	hud = Label.new()
	hud.position = Vector2(42,55)
	hud.add_theme_font_size_override("font_size", 18)
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
	xp_bar = ProgressBar.new()
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
	scroll.custom_minimum_size = Vector2(530,760)
	margins.add_child(scroll)
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(cards)
	mission_label = Label.new()
	mission_label.position = Vector2(40,1025)
	mission_label.add_theme_font_size_override("font_size",19)
	root.add_child(mission_label)

func clear_cards(title: String, subtitle: String) -> void:
	for child in cards.get_children():
		cards.remove_child(child)
		child.queue_free()
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
	description.add_theme_font_size_override("font_size",23)
	cards.add_child(description)

func add_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(510,78)
	NeonArt.style_button(button,Color("73e6de"),text in ["PLAY","RETRY"] or text.begins_with("CLAIM"))
	button.mouse_entered.connect(func(): animate_button(button,1.012))
	button.mouse_exited.connect(func(): animate_button(button,1.0))
	button.button_down.connect(func(): animate_button(button,0.985))
	button.button_up.connect(func(): animate_button(button,1.0))
	button.add_theme_font_size_override("font_size",24)
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
	for enemy in enemies:
		enemy.hide()
	if is_instance_valid(bullet):
		bullet.hide()
	clear_cards("LAST BULLET", "ZORVYKA Games • v0.4.0\nOne Shot. Endless Chaos.\nBEST SCORE %d" % best_score)
	cards.add_theme_constant_override("separation",12)
	var mascot := Preview.new()
	mascot.actor = 0
	mascot.custom_minimum_size = Vector2(500,100)
	cards.add_child(mascot)
	cards.move_child(mascot,1)
	add_button("PLAY", show_modes)
	add_button("HOW TO PLAY", show_help)
	add_button("SKINS • %d COINS" % coins, show_skins)
	add_button("SETTINGS", show_settings)
	if not OS.has_feature("mobile"):
		add_button("QUIT", func(): get_tree().quit())
	for child in cards.get_children():
		if child is Button: child.custom_minimum_size.y = 64

func show_help() -> void:
	clear_cards("ONE SHOT. YOUR CALL.", "1. Move with WASD / arrows, or drag the left joystick. Avoid coral enemies.\n\n2. Aim with movement; the arrow previews your next deflect. Press SPACE inside the outer ring. Catch an incoming bullet inside the gold ring for PERFECT!\n\n3. Collect XP, choose upgrades, complete missions for skin coins. Shields block front hits; dodge yellow marked zones. Your bullet is harmless.\n\nPLAY offers Open, Reflector and 90-second Blitz. Chain Perfect catches for bonus points. After boss release, deflect back while its core is gold for x4 damage. Claim x2 gold instantly on results.")
	add_button("BACK", show_menu)

func show_modes() -> void:
	clear_cards("CHOOSE YOUR RUN","Open arena to learn. Reflector to experiment. Blitz for a quick score chase.")
	add_button("SURVIVAL • OPEN",start_run.bind("survival","open"))
	add_button("SURVIVAL • REFLECTOR",start_run.bind("survival","reflector"))
	add_button("BLITZ • 90 SECONDS",start_run.bind("blitz","open"))
	add_button("BACK",show_menu)

func start_run(run_mode := "survival", layout := "open") -> void:
	effects.effects.clear()
	move_clock = 0
	player_lean = 0
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
	perfect_count = 0
	mission_claimed = [false,false,false]
	result_paid = false
	feedback = 0
	fire_timer = 0
	last_deflect_perfect = false
	offered_upgrades.clear()
	audio.stop_all()
	player = Vector2(360,650)
	player_actor.position = player
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
		joystick_id = -1
		joystick = Vector2.ZERO
	if event is InputEventMouseButton and not event.pressed and joystick_id == -2:
		joystick_id = -1
		joystick = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
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
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < 340 and event.position.y > 1030 and joystick_id == -1:
			joystick_id = event.index
			joystick_origin = event.position
		elif not event.pressed and event.index == joystick_id:
			joystick_id = -1
			joystick = Vector2.ZERO
	if event is InputEventScreenDrag and event.index == joystick_id:
		joystick = ((event.position - joystick_origin) / 70).limit_length()
	# Mouse joystick for desktop preview; keyboard works independently.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and event.position.x < 340 and event.position.y > 1030:
			joystick_id = -2
			joystick_origin = event.position
		elif not event.pressed and joystick_id == -2:
			joystick_id = -1
			joystick = Vector2.ZERO
	if event is InputEventMouseMotion and joystick_id == -2:
		joystick = ((event.position - joystick_origin)/70).limit_length()

func request_deflect() -> void:
	if state == "playing" and cooldown <= 0:
		attempts += 1
		deflect_window = 0.22
		cooldown = 0.65 + upgrades[7]*0.12
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
	brand.visible = playing_ui
	health_icons.visible = playing_ui
	health_icons.queue_redraw()
	effects.visible = playing_ui
	boss_label.visible = playing_ui and is_instance_valid(boss)
	boss_bar.visible = boss_label.visible
	if boss_label.visible:
		boss_label.text = "BULLET EATER • " + ("EXPOSED • RETURN ×4" if boss.weak_timer > 0 else "CAPTURING" if bullet.capture > 0 else "HUNTING")
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
	feedback = maxf(0,feedback-delta)
	wave = 1 + int(elapsed / (15 if mode == "blitz" else 20))
	invulnerable = maxf(0,invulnerable-delta)
	cooldown = maxf(0,cooldown-delta)
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
	if arena_layout == "reflector":
		player = Geometry.resolve(player,18)
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
	slow = maxf(0,slow-delta)
	var enemy_delta := delta * (0.35 if slow > 0 else 1.0)
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy):
			continue
		var target := Geometry.navigation_target(enemy.position,player,enemy.radius) if arena_layout == "reflector" and enemy.kind != 5 else player
		enemy.advance(enemy_delta,target)
		enemy.weak_timer = maxf(0,enemy.weak_timer-(delta-enemy_delta))
		if arena_layout == "reflector":
			enemy.position = Geometry.resolve(enemy.position,enemy.radius)
		if player.distance_to(enemy.position) < enemy.radius + 17:
			hurt_player(enemy.position)
		if enemy.kind == 5 and enemy.hazard_active() and player.distance_to(enemy.hazard_point) < 83:
			hurt_player(enemy.hazard_point)
		if state == "results":
			return
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = maxf(0.32,1.4 - wave * 0.07) if mode != "blitz" else [1.2,0.95,0.8,0.7,0.6,0.5][mini(wave-1,5)]
		if enemies.size() < Balance.MAX_ENEMIES:
			var pool := [0]
			if wave >= 2: pool.append(1)
			if wave >= 3: pool.append(2)
			if wave >= 4: pool.append(4)
			if wave >= 5: pool.append(5)
			if mode == "blitz":
				var formations := [[0,0,0],[0,1,0],[0,1,2],[1,0,4],[2,1,5],[4,1,2,5]]
				var formation: Array = formations[mini(wave-1,5)]
				spawn_enemy(formation[spawn_index%formation.size()])
				spawn_index += 1
			else:
				spawn_enemy(pool[rng.randi_range(0,pool.size()-1)])
	if mode != "blitz" and elapsed >= 240 and not boss_spawned:
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
	enemy.phase = rng.randf_range(0,2)
	var spawn := Vector2.ZERO
	for attempt in range(16):
		spawn = Vector2(rng.randf_range(90,630),rng.randf_range(225,960))
		if rng.randf() < 0.5:
			spawn.x = 90 if rng.randf() < 0.5 else 630
		else:
			spawn.y = 225 if rng.randf() < 0.5 else 960
		if spawn.distance_to(player) > 200:
			break
	if spawn.distance_to(player) <= 200:
		enemy.free()
		return
	enemy.position = Geometry.resolve(spawn,enemy.radius) if arena_layout == "reflector" else spawn
	add_child(enemy)
	enemy.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	enemy.reset_physics_interpolation()
	enemies.append(enemy)
	if kind == 3:
		boss = enemy

func damage_enemy(enemy: ArenaEnemy, damage: float, impact := false, incoming := Vector2.ZERO) -> void:
	if not enemies.has(enemy):
		return
	if enemy.kind == 4 and (not impact or enemy.blocks(incoming)):
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
	if enemy == boss:
		boss = null
		notice("BULLET EATER DEFEATED!")
	enemies.erase(enemy)
	enemy.queue_free()
	enemy_killed.emit(points)

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
		card.add_theme_font_size_override("font_size",21)
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
	var total := score+int(elapsed)
	previous_record = blitz_best if mode == "blitz" else best_score
	new_record = total > previous_record
	if mode == "blitz":
		blitz_best = maxi(blitz_best,total)
	else:
		best_score = maxi(best_score,total)
	lifetime_chain = maxi(lifetime_chain,best_perfect_chain)
	var reward := mini(50,int(kills/5)+int(elapsed/30))
	coins += reward
	run_coins = reward+mission_coins
	save_profile()
	audio.stop_all()
	audio.play_event("level_up" if challenge_complete else "defeat")
	final_summary = "TIME %s  •  SCORE %d\nKILLS %d\nPERFECT %d  •  BEST STREAK %d\nDEFLECT %d/%d (%d%%)\n%s\nCOINS: run %d + missions %d = %d" % [time_text(),total,kills,perfect_count,best_perfect_chain,deflect_successes,attempts,deflect_rate(),("NEW RECORD! +%d" % (total-previous_record)) if new_record else "RECORD %d" % previous_record,reward,mission_coins,run_coins]
	if mode == "blitz":
		final_summary = ("FINISHED • " if challenge_complete else "TIME CHALLENGE • ")+medal(total)+"\n"+final_summary
	for enemy in enemies: enemy.hide()
	bullet.hide()
	update_hud()
	show_results()
	run_ended.emit()

func show_results() -> void:
	state = "results"
	clear_cards("BLITZ RESULTS" if mode == "blitz" else "RUN COMPLETE",final_summary+"\n"+next_skin_hint()+"\nWALLET %d" % coins)
	cards.add_theme_constant_override("separation",12)
	if run_coins > 0:
		add_button("CLAIM X2 GOLD • +%d" % run_coins if not double_claimed else "X2 CLAIMED • +%d" % run_coins,claim_double_gold)
		(cards.get_child(cards.get_child_count()-1) as Button).disabled = double_claimed
	add_button("RETRY",start_run.bind(mode,arena_layout))
	add_button("SKINS",show_skins)
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
	if state != "results" or double_claimed or not result_paid or run_coins <= 0:
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
	hud.text = "HP %d/5    %s    %s %d\nSCORE %d  •  KILL ×%d\nPERFECT ×%d  •  LV %d" % [hp,clock,"WAVE" if mode != "blitz" else "BLITZ",wave,score+int(elapsed),combo,perfect_chain,level]
	xp_bar.max_value = xp_required()
	xp_bar.value = xp
	mission_label.text = "MISSIONS  Kills %d/15  •  Perfect %d/3  •  Chain %d/10" % [mini(kills,15),mini(perfect_count,3),mini(best_combo,10)]
	deflect_button.text = "DEFLECT\n" + ("READY" if cooldown <= 0 else "%.1fs" % cooldown)

func _process(delta: float) -> void:
	visual_clock += delta
	queue_redraw()

func _draw() -> void:
	draw_texture_rect(NeonArt.FLOOR,Balance.ARENA,false)
	if state in ["menu","results"]:
		draw_rect(Rect2(0,0,720,1280),Color(0.01,0.02,0.05,0.3))
		return
	if arena_layout == "reflector":
		var pillar := Geometry.PILLAR
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
	if invulnerable > 0 or state != "playing":
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
			save_profile()
			audio.play_event("level_up")
			notice("MISSION COMPLETE • +15 COINS")

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
		sound_on = bool(config.get_value("settings","sound",true))
		haptics_on = bool(config.get_value("settings","haptics",true))
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
	config.set_value("settings","sound",sound_on)
	config.set_value("settings","haptics",haptics_on)
	config.save(save_path)

func show_skins() -> void:
	show_menu()
	clear_cards("BULLET SKINS", "COSMETIC ONLY • %d COINS\nPreview each trail below. Earn coins from missions and runs." % coins)
	cards.add_theme_constant_override("separation",10)
	for i in range(4):
		var action := "EQUIPPED" if selected_skin == i else ("EQUIP" if owned_skins.has(i) else "%d COINS" % Balance.SKIN_COSTS[i])
		add_button("%s • %s" % [Balance.SKIN_NAMES[i],action],buy_or_equip.bind(i))
		var button := cards.get_child(cards.get_child_count()-1) as Button
		button.custom_minimum_size.y = 64
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
	clear_cards("SETTINGS","Audio plays locally. No online services.")
	add_button("SOUND: " + ("ON" if sound_on else "OFF"),func(): sound_on = not sound_on; audio.enabled = sound_on; audio.stop_all(); save_profile(); show_settings())
	add_button("LOW EFFECTS: "+("ON" if low_effects else "OFF"),func(): low_effects = not low_effects; save_profile(); show_settings())
	add_button("VIBRATION: " + ("ON" if haptics_on else "OFF"),func(): haptics_on = not haptics_on; save_profile(); show_settings())
	add_button("BACK",show_menu)
