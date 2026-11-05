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
	hud.position = Vector2(35,30)
	hud.add_theme_font_size_override("font_size", 22)
	root.add_child(hud)
	xp_bar = ProgressBar.new()
	xp_bar.position = Vector2(35,125)
	xp_bar.size = Vector2(650,14)
	xp_bar.show_percentage = false
	root.add_child(xp_bar)
	pause_button = Button.new()
	pause_button.text = "Ⅱ"
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.position = Vector2(614,30)
	pause_button.size = Vector2(70,65)
	pause_button.pressed.connect(toggle_pause)
	root.add_child(pause_button)
	var deflect := Button.new()
	deflect_button = deflect
	deflect.focus_mode = Control.FOCUS_NONE
	deflect.text = "DEFLECT\nSPACE"
	deflect.position = Vector2(505,1060)
	deflect.size = Vector2(175,155)
	deflect.add_theme_font_size_override("font_size",24)
	deflect.button_down.connect(request_deflect)
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
	panel_style.bg_color = Color("101d32")
	panel_style.border_color = Color("355672")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(16)
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
	(cards.get_parent() as ScrollContainer).set_deferred("scroll_vertical",0)
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size",32)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cards.add_child(label)
	var description := Label.new()
	description.text = subtitle
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size",23)
	cards.add_child(description)

func add_button(text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(510,78)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("1a304c")
	style.border_color = Color("3b647c")
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	button.add_theme_stylebox_override("normal",style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color("284c66")
	button.add_theme_stylebox_override("hover",hover)
	button.add_theme_stylebox_override("pressed",hover)
	button.add_theme_font_size_override("font_size",24)
	button.pressed.connect(func(): audio.play_event("ui_click"); callback.call())
	cards.add_child(button)

func show_menu() -> void:
	state = "menu"
	audio.stop_all()
	for enemy in enemies:
		enemy.hide()
	if is_instance_valid(bullet):
		bullet.hide()
	clear_cards("LAST BULLET", "ZORVYKA Games • v0.3.0\nOne Shot. Endless Chaos.\n\nBEST SCORE  %d" % best_score)
	add_button("PLAY", show_modes)
	add_button("HOW TO PLAY", show_help)
	add_button("SKINS • %d COINS" % coins, show_skins)
	add_button("SETTINGS", show_settings)
	if not OS.has_feature("mobile"):
		add_button("QUIT", func(): get_tree().quit())

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
	bullet.skin = selected_skin
	bullet.position = player + Vector2(0,-45)
	add_child(bullet)
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
	toast_time = maxf(0,toast_time-delta)
	toast.visible = toast_time > 0
	if state != "playing":
		queue_redraw()
		return
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
	enemy.hp -= damage
	enemy.flash = 0.08
	if enemy.hp > 0:
		return
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
		add_button("%s [%d/%d]\n%s" % [Balance.UPGRADE_NAMES[index],upgrades[index],Balance.UPGRADE_CAPS[index],Balance.UPGRADE_INFO[index]],choose_upgrade.bind(index))

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

func _draw() -> void:
	draw_rect(Balance.ARENA,Color("0b1930"))
	for x in range(30,691,55):
		draw_line(Vector2(x,165),Vector2(x,1020),Color(0.1,0.2,0.3,0.35))
	for y in range(165,1021,55):
		draw_line(Vector2(30,y),Vector2(690,y),Color(0.1,0.2,0.3,0.35))
	draw_rect(Balance.ARENA,Color("355672"),false,4)
	if state in ["menu","results"]:
		return
	if arena_layout == "reflector":
		draw_rect(Geometry.PILLAR,Color("172b45"))
		draw_rect(Geometry.PILLAR,Color("73c6e9"),false,4)
		draw_line(Geometry.PILLAR.position,Geometry.PILLAR.end,Color("355672"),2)
	for point in pickups:
		draw_circle(point,4 if low_effects else 6,Color("ffd17c"))
	for fire in fires:
		draw_circle(fire.p,18,Color(1,0.45,0.12,fire.ttl*(0.25 if low_effects or enemies.size()>24 else 0.6)))
	draw_arc(player,deflect_radius(),0,TAU,64,Color(0.3,1,0.8,0.65 if cooldown <= 0 else 0.15),2)
	draw_arc(player,Balance.PERFECT_RADIUS,0,TAU,48,Color(1,0.82,0.4,0.6),2)
	if feedback > 0:
		draw_arc(player,45+(0.45-feedback)*180,0,TAU,48,Color(1,0.85,0.4,feedback*2),5)
	if is_instance_valid(bullet) and bullet.capture <= 0 and player.distance_to(bullet.position) < deflect_radius()+80:
		var end := player + aim*145
		draw_line(player+aim*25,end,Color("b5ffe6"),4)
		draw_line(end,end-aim.rotated(0.5)*24,Color("b5ffe6"),4)
		draw_line(end,end-aim.rotated(-0.5)*24,Color("b5ffe6"),4)
	if deflect_window > 0:
		draw_arc(player,deflect_radius()-8,0,TAU,64,Color.WHITE,5)
	if invulnerable <= 0 or int(invulnerable*15)%2 == 0:
		draw_circle(player,17,Color("8affc1"))
		draw_line(player,player+aim*27,Color.WHITE,4)
	if is_instance_valid(bullet) and bullet.capture <= 0 and player.distance_to(bullet.position) > 280:
		var direction := (bullet.position-player).normalized()
		var pointer := player+direction*125
		draw_colored_polygon(PackedVector2Array([pointer+direction*13,pointer-direction.rotated(0.65)*10,pointer-direction.rotated(-0.65)*10]),Color("d7fdff"))
	if is_instance_valid(bullet) and bullet.capture > 0:
		draw_line(bullet.position,player,Color(1,0.8,0.3,0.55),5)
	draw_circle(joystick_origin,76,Color(0.4,0.8,0.9,0.08))
	draw_arc(joystick_origin,76,0,TAU,48,Color(0.4,0.8,0.9,0.4),2)
	draw_circle(joystick_origin+joystick*55,28,Color(0.4,0.9,0.85,0.5))

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
		var preview := Control.new()
		preview.custom_minimum_size = Vector2(500,24)
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.draw.connect(func(): PermanentBullet.draw_skin_preview(preview,i))
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
