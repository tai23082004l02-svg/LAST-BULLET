extends SceneTree
const PROFILE := "user://robots-test.cfg"
var game: Node2D
func _initialize() -> void:
	call_deferred("run")
func cleanup() -> void:
	for p in [PROFILE,"user://robots-test-admin.cfg","user://robots-test-mode.cfg"]: DirAccess.remove_absolute(p)
func run() -> void:
	cleanup()
	game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = PROFILE
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	await process_frame
	assert(game.selected_robot == 0 and game.owned_robots.size() == 1)
	for i in range(6):
		var tex := RobotRoster.texture(i)
		assert(Rect2(Vector2.ZERO,RobotRoster.SHEET.get_size()).encloses(tex.region))
	game.coins = 100
	game.buy_or_equip_robot(6)
	assert(game.coins == 100 and game.selected_robot == 0)
	game.summon.shards = 30
	game.buy_or_equip_robot(1)
	assert(game.coins == 100 and game.summon.shards == 0 and game.selected_robot == 1)
	game.buy_or_equip_robot(1)
	assert(game.coins == 100)
	game.selected_robot = 0
	game.load_profile()
	assert(game.selected_robot == 1 and game.owned_robots.has(1))
	game.start_run()
	assert(game.player_actor.robot == 1 and game.hp == 5)
	game.show_menu()
	game.show_admin()
	game.switch_admin(true)
	assert(game.owned_robots.size() == 7)
	var wallet: int = game.coins
	for i in range(7):
		game.buy_or_equip_robot(i)
		game.start_run()
		assert(game.player_actor.robot == i and game.hp == 5)
		assert(game.coins == wallet)
		var bullets := 0
		for child in game.get_children():
			if child is PermanentBullet: bullets += 1
		assert(bullets == 1)
		game.show_menu()
	game.show_admin()
	game.switch_admin(false)
	assert(game.selected_robot == 1 and game.owned_robots.size() == 2 and game.coins == 100)
	print("PASS: seven robot roster, atlas, funds check, single-charge purchase, save/equip, admin free access, profile isolation and unchanged HP/single bullet")
	cleanup()
	game.audio.shutdown()
	OS.delay_msec(150)
	await process_frame
	game.queue_free()
	await process_frame
	quit()
