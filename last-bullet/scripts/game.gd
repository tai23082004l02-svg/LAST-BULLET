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
var upgrades: Array[int] = [0,0,0,0,0]
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
	var config := ConfigFile.new()
	if config.load("user://records.cfg") == OK:
		best_score = int(config.get_value("record", "score", 0))
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
	hud.add_theme_font_size_override("font_size", 25)
	root.add_child(hud)
	xp_bar = ProgressBar.new()
	xp_bar.position = Vector2(35,125)
	xp_bar.size = Vector2(650,14)
	xp_bar.show_percentage = false
	root.add_child(xp_bar)
	var pause_button := Button.new()
	pause_button.text = "Ⅱ"
	pause_button.position = Vector2(614,30)
	pause_button.size = Vector2(70,65)
	pause_button.pressed.connect(toggle_pause)
	root.add_child(pause_button)
	var deflect := Button.new()
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
	overlay.position = Vector2(65,235)
	overlay.size = Vector2(590,710)
	root.add_child(overlay)
	var margins := MarginContainer.new()
	for side in ["left","right","top","bottom"]:
		margins.add_theme_constant_override("margin_" + side,30)
	overlay.add_child(margins)
	cards = VBoxContainer.new()
	cards.add_theme_constant_override("separation",20)
	margins.add_child(cards)

func clear_cards(title: String, subtitle: String) -> void:
	for child in cards.get_children():
		cards.remove_child(child)
		child.queue_free()
	overlay.show()
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size",38)
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
	button.custom_minimum_size = Vector2(510,78)
	button.add_theme_font_size_override("font_size",24)
	button.pressed.connect(callback)
	cards.add_child(button)

func show_menu() -> void:
	state = "menu"
	for enemy in enemies:
		enemy.hide()
	if is_instance_valid(bullet):
		bullet.hide()
	clear_cards("LAST BULLET", "ZORVYKA Games\nOne Shot. Endless Chaos.\n\nBEST SCORE  %d" % best_score)
	add_button("PLAY", start_run)
	add_button("HOW TO PLAY", show_help)
	if not OS.has_feature("mobile"):
		add_button("QUIT", func(): get_tree().quit())

func show_help() -> void:
	clear_cards("ONE SHOT. YOUR CALL.", "1. Move with WASD / arrows, or drag the left joystick. Avoid coral enemies.\n\n2. Press SPACE / DEFLECT as the cyan bullet enters your ring. You have 0.22 seconds; aim with movement.\n\n3. Collect gold XP, pick upgrades and survive. Your own bullet is harmless.")
	add_button("BACK", show_menu)

func start_run() -> void:
	if is_instance_valid(bullet):
		remove_child(bullet)
		bullet.queue_free()
	for enemy in enemies:
		enemy.queue_free()
	enemies.clear()
	boss = null
	pickups.clear()
	fires.clear()
	upgrades = [0,0,0,0,0]
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
	bullet.position = player + Vector2(0,-45)
	add_child(bullet)
	state = "playing"
	update_hud()
	overlay.hide()
	notice("ONE BULLET. MAKE IT COUNT.")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			request_deflect()
		elif event.keycode == KEY_ESCAPE:
			toggle_pause()
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
		deflect_window = 0.22
		cooldown = 0.65

func toggle_pause() -> void:
	if state == "playing":
		state = "paused"
		joystick = Vector2.ZERO
		joystick_id = -1
		clear_cards("PAUSED", "Catch your breath.")
		add_button("RESUME", func(): state = "playing"; overlay.hide())
		add_button("MAIN MENU", show_menu)
	elif state == "paused":
		state = "playing"
		overlay.hide()

func _physics_process(delta: float) -> void:
	toast_time = maxf(0,toast_time-delta)
	toast.visible = toast_time > 0
	if state != "playing":
		queue_redraw()
		return
	elapsed += delta
	wave = 1 + int(elapsed / 20)
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
	if deflect_window > 0:
		deflect_window -= delta
		if bullet.capture <= 0 and player.distance_to(bullet.position) < Balance.DEFLECT_RADIUS:
			bullet.velocity = aim * bullet_speed()
			bullet.boost = 1.6
			deflect_window = 0
			if upgrades[3] > 0:
				slow = 0.6 + upgrades[3] * 0.3
			notice("PERFECT DEFLECT!")
		elif deflect_window <= 0:
			notice("MISSED • CATCH IT INSIDE THE RING")
	bullet.advance(delta,self)
	slow = maxf(0,slow-delta)
	var enemy_delta := delta * (0.35 if slow > 0 else 1.0)
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy):
			continue
		enemy.advance(enemy_delta,player)
		if player.distance_to(enemy.position) < enemy.radius + 17 and invulnerable <= 0:
			hp -= 1
			invulnerable = 1.2
			player = (player + (player-enemy.position).normalized()*35).clamp(Balance.ARENA.position+Vector2(18,18),Balance.ARENA.end-Vector2(18,18))
			if hp <= 0:
				finish_run()
				return
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = maxf(0.32,1.4 - wave * 0.07)
		if enemies.size() < Balance.MAX_ENEMIES:
			spawn_enemy(0 if wave < 2 else rng.randi_range(0,mini(2,wave-1)))
	if elapsed >= 240 and not boss_spawned:
		boss_spawned = true
		spawn_enemy(3)
		notice("BULLET EATER HAS ARRIVED")
	for i in range(pickups.size()-1,-1,-1):
		var distance := player.distance_to(pickups[i])
		if distance < 115:
			pickups[i] = pickups[i].move_toward(player,delta*430)
		if distance < 24:
			pickups.remove_at(i)
			xp += 1
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
	enemy.position = spawn
	add_child(enemy)
	enemies.append(enemy)
	if kind == 3:
		boss = enemy

func damage_enemy(enemy: ArenaEnemy, damage: float) -> void:
	if not enemies.has(enemy):
		return
	enemy.hp -= damage
	enemy.flash = 0.08
	if enemy.hp > 0:
		return
	combo += 1
	combo_timer = Balance.COMBO_WINDOW
	best_combo = maxi(combo,best_combo)
	kills += 1
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
	for i in range(5):
		if upgrades[i] < 5:
			available.append(i)
	if available.is_empty():
		hp = mini(5,hp+1)
		return
	state = "upgrade"
	joystick = Vector2.ZERO
	joystick_id = -1
	leveled_up.emit()
	clear_cards("LEVEL %d" % level,"Choose one. The arena waits.")
	available.shuffle()
	for i in range(mini(3,available.size())):
		var index := available[i]
		add_button("%s [%d/5]\n%s" % [Balance.UPGRADE_NAMES[index],upgrades[index],Balance.UPGRADE_INFO[index]],choose_upgrade.bind(index))

func choose_upgrade(index: int) -> void:
	upgrades[index] += 1
	state = "playing"
	overlay.hide()

func finish_run() -> void:
	state = "results"
	best_score = maxi(best_score,score+int(elapsed))
	var config := ConfigFile.new()
	config.set_value("record","score",best_score)
	config.save("user://records.cfg")
	clear_cards("RUN COMPLETE", "SURVIVED  %s\nSCORE  %d\nKILLS  %d\nBEST CHAIN  %d\nRECORD  %d" % [time_text(),score+int(elapsed),kills,best_combo,best_score])
	add_button("RETRY",start_run)
	add_button("MAIN MENU",show_menu)
	run_ended.emit()

func time_text() -> String:
	return "%02d:%02d" % [int(elapsed)/60,int(elapsed)%60]

func notice(text: String) -> void:
	toast.text = text
	toast_time = 1.8

func update_hud() -> void:
	hud.text = "HP %d/5    %s    WAVE %d\nSCORE %d    CHAIN ×%d    LV %d" % [hp,time_text(),wave,score+int(elapsed),combo,level]
	xp_bar.max_value = xp_required()
	xp_bar.value = xp

func _draw() -> void:
	draw_rect(Balance.ARENA,Color("0b1930"))
	for x in range(30,691,55):
		draw_line(Vector2(x,165),Vector2(x,1020),Color(0.1,0.2,0.3,0.35))
	for y in range(165,1021,55):
		draw_line(Vector2(30,y),Vector2(690,y),Color(0.1,0.2,0.3,0.35))
	draw_rect(Balance.ARENA,Color("355672"),false,4)
	if state == "menu":
		return
	for point in pickups:
		draw_circle(point,6,Color("ffd17c"))
	for fire in fires:
		draw_circle(fire.p,18,Color(1,0.45,0.12,fire.ttl*0.6))
	draw_arc(player,Balance.DEFLECT_RADIUS,0,TAU,64,Color(0.3,1,0.8,0.65 if cooldown <= 0 else 0.15),2)
	if deflect_window > 0:
		draw_arc(player,Balance.DEFLECT_RADIUS-8,0,TAU,64,Color.WHITE,5)
	if invulnerable <= 0 or int(invulnerable*15)%2 == 0:
		draw_circle(player,17,Color("8affc1"))
		draw_line(player,player+aim*27,Color.WHITE,4)
	if is_instance_valid(bullet) and bullet.capture > 0:
		draw_line(bullet.position,player,Color(1,0.8,0.3,0.55),5)
	draw_circle(joystick_origin,76,Color(0.4,0.8,0.9,0.08))
	draw_arc(joystick_origin,76,0,TAU,48,Color(0.4,0.8,0.9,0.4),2)
	draw_circle(joystick_origin+joystick*55,28,Color(0.4,0.9,0.85,0.5))
