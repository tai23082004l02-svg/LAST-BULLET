extends SceneTree
const PROFILE := "user://prototype3d-test.cfg"
var game: Node2D
var room: Control
func _initialize() -> void: call_deferred("run")
func clear_enemies() -> void:
	for entry in room.enemies: entry.actor.queue_free()
	room.enemies.clear(); room.spawn_wait = 1000
func target(point: Vector2) -> Dictionary:
	var actor = load("res://prototype3d/robot.gd").new(); room.world.add_child(actor); actor.build(true); actor.position = Vector3(point.x,0,point.y)
	var entry := {"actor":actor,"hp":3,"timer":1000.0,"warned":false,"locked":Vector2.ZERO}; room.enemies.append(entry); return entry
func run() -> void:
	for p in [PROFILE,"user://prototype3d-test-language.cfg"]: DirAccess.remove_absolute(p)
	game = load("res://scenes/Main.tscn").instantiate(); game.save_path = PROFILE; root.add_child(game); game.set_physics_process(false); game.sound_on = false
	game.coins = 321; game.progress.checkpoint = {"preserved":true}; assert(game.save_profile())
	var before := FileAccess.get_file_as_bytes(PROFILE).hex_encode().sha256_text()
	game.show_prototype_3d(); room = game.prototype_room; room.set_physics_process(false); room.set_process_input(false)
	assert(game.process_mode == Node.PROCESS_MODE_DISABLED and not game.ui.visible and room.view.own_world_3d)
	var original: Vector3 = room.player.position; room.spawn_wait = 1000
	room.pointer_down(0,Vector2(200,400)); room._physics_process(0.03); room.pointer_up(0,Vector2(200,400)); assert(room.player.position == original and room.cooldown == 0)
	room.pointer_down(0,Vector2(200,400)); room.pointer_move(0,Vector2(205,401)); assert(room.drag_vector == Vector2.ZERO)
	room.pointer_move(0,Vector2(290,400)); room._physics_process(0.1); assert(room.player.position.x > original.x)
	room.pointer_up(0,Vector2(290,400)); assert(room.drag_vector == Vector2.ZERO and room.cooldown == 0)
	room.pointer_down(0,room.exit_button.get_global_rect().get_center()); assert(room.primary == -1)
	room.pointer_down(0,Vector2(200,400)); room.pointer_move(0,Vector2(290,400))
	for i in range(2): room.pointer_down(1,Vector2(400,500)); room.pointer_up(1,Vector2(400,500)); room.touch_clock += 0.05
	assert(room.cooldown > 0 and room.primary == 0 and room.drag_vector.length() > 0)
	room.pointer_up(0,Vector2(290,400),true)
	room.toggle_pause(); original = room.player.position; var clock: float = room.elapsed
	room._physics_process(2); assert(room.player.position == original and room.elapsed == clock and room.pointers.is_empty())
	room.toggle_quality(); assert(not room.high_quality and room.container.stretch_shrink == 2)
	room.toggle_quality(); room.toggle_pause(); room.restart(); clear_enemies()
	room.player.position = Vector3(0,0,3); var enemy := target(Vector2(0,0)); room.fire_clock = 1000; room.try_fire()
	assert(room.shots.size() == 1 and room.player.recoil > 0)
	for i in range(20): room._physics_process(1.0/60)
	assert(enemy.hp == 2)
	room.restart(); clear_enemies(); room.player.position = Vector3(-2.8,0,1); enemy = target(Vector2(-2.8,-4)); room.fire_clock = 1000; room.try_fire(); assert(room.shots.is_empty())
	room.shoot(Vector3(-2.8,1.22,1),Vector2.UP,true)
	for i in range(20): room._physics_process(1.0/60)
	assert(enemy.hp == 3 and room.shots.is_empty())
	for i in range(60): room.shoot(Vector3.ZERO,Vector2.RIGHT,true)
	assert(room.shots.size() == 48)
	for i in range(30): room.burst_visual(Vector3.ZERO,Color.WHITE,1,0.2)
	assert(room.effects.size() == 24)
	assert(not room.obstacles[0].has_point(room.resolve(room.obstacles[0].get_center(),0.43)))
	room.restart(); assert(room.shots.is_empty() and room.effects.is_empty() and room.hp == 5)
	# Full room under deterministic moving-fire bot; validates all waves/shooting, not device FPS.
	room.moving_fire = true; room.invulnerable = 1000; room.primary = 0
	for frame in range(9000):
		var wanted := Vector2(sin(frame/130.0)*4,cos(frame/180.0)*7)
		room.drag_vector = (wanted-room.flat(room.player.position)).limit_length(1)
		room._physics_process(1.0/60)
		if frame%60 == 0: await process_frame
		if room.status != "playing": break
	assert(room.status == "won" and room.wave == 3 and room.kills == 11)
	room.restart(); room.hp = 1; room.hurt(); assert(room.status == "lost")
	room.restart(); room.request_exit(); await process_frame
	assert(not is_instance_valid(game.prototype_room) and game.state == "menu" and game.ui.visible)
	assert(game.coins == 321 and game.progress.checkpoint == {"preserved":true})
	assert(FileAccess.get_file_as_bytes(PROFILE).hex_encode().sha256_text() == before)
	var root_count := root.get_child_count()
	for cycle in range(2):
		game.show_prototype_3d(); game.prototype_room.set_physics_process(false); game.prototype_room.request_exit(); await process_frame
		assert(root.get_child_count() == root_count and game.process_mode != Node.PROCESS_MODE_DISABLED)
	game.audio.shutdown(); game.queue_free(); await process_frame
	for p in [PROFILE,"user://prototype3d-test-language.cfg"]: DirAccess.remove_absolute(p)
	print("PASS prototype3d: input/skill/pause/quality, swept hits and cover, caps, all3 waves/11 enemies, retry/exit, byte-identical profile")
	quit()
