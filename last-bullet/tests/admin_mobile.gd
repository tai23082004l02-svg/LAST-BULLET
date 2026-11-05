extends SceneTree
var game: Node2D
const PROFILE := "user://admin-mobile-test.cfg"

func _initialize() -> void:
	call_deferred("run")

func cleanup() -> void:
	for path in [PROFILE,"user://admin-mobile-test-admin.cfg","user://admin-mobile-test-mode.cfg"]:
		DirAccess.remove_absolute(path)

func new_game() -> Node2D:
	var instance = load("res://scenes/Main.tscn").instantiate()
	instance.save_path = PROFILE
	root.add_child(instance)
	instance.set_physics_process(false)
	instance.audio.enabled = false
	return instance

func run() -> void:
	cleanup()
	game = new_game()
	await process_frame
	game.coins = 321
	game.best_score = 1234
	game.owned_skins.append(1)
	game.selected_skin = 1
	game.save_profile()
	game.show_admin()
	game.switch_admin(true)
	assert(game.admin_enabled and game.owned_skins.size() == 4 and game.coins >= 999999)
	assert(game.save_path != PROFILE)
	var balance: int = game.coins
	game.buy_or_equip(3)
	assert(game.coins == balance and game.selected_skin == 3)
	game.show_admin()
	game.toggle_admin_option("max")
	game.toggle_admin_option("deflect")
	game.start_run()
	for i in range(8): assert(game.upgrades[i] == Balance.UPGRADE_CAPS[i])
	game.hurt_player(game.player)
	assert(game.hp == 5)
	game.request_deflect()
	assert(game.cooldown == 0)
	game.toggle_pause()
	game.show_admin()
	var elapsed: float = game.elapsed
	game._physics_process(3)
	assert(game.elapsed == elapsed)
	game.show_upgrade_lab()
	game.admin_set_upgrades(false)
	for value in game.upgrades: assert(value == 0)
	game.admin_cycle_upgrade(0)
	assert(game.upgrades[0] == 1)
	game.admin_set_upgrades(true)
	game.show_admin()
	for kind in range(6): game.admin_spawn_enemy(kind)
	var count: int = game.enemies.size()
	game.admin_spawn_enemy(3)
	assert(game.enemies.size() == count)
	var bullet = game.bullet
	game.admin_boss()
	assert(game.state == "playing" and game.bullet == bullet)
	game.finish_run()
	game.show_menu()
	game.audio.shutdown()
	OS.delay_msec(150)
	game.queue_free()
	await process_frame
	# Mode and admin options survive reload; normal economy stays separate.
	game = new_game()
	assert(game.admin_enabled and game.admin_max_start and game.admin_free_deflect)
	assert(game.selected_skin == 3)
	game.show_admin()
	game.switch_admin(false)
	assert(not game.admin_enabled and game.save_path == PROFILE)
	assert(game.coins == 321 and game.best_score == 1234 and game.selected_skin == 1)
	assert(game.owned_skins.size() == 2)
	game.show_menu()
	game.start_run()
	for value in game.upgrades: assert(value == 0)
	game.hurt_player(game.player+Vector2(20,0))
	assert(game.hp == 4)
	# Tall phones use extra height; controls respect supplied safe margins.
	game.layout_viewport(Vector2(720,1600),Vector2(40,32))
	await process_frame
	assert(Balance.ARENA.position.y == 205 and Balance.ARENA.end.y == 1308)
	assert(game.deflect_button.position.y+game.deflect_button.size.y < 1568)
	assert(game.overlay.position.y >= 40)
	assert(game.overlay.position.y+game.overlay.size.y <= 1568)
	assert(game.joystick_origin.y+76 < 1568)
	assert(game.joystick_origin.x == 185)
	var edge: Vector2 = game.comfortable_stick_origin(Vector2(1,1599))
	assert(edge.x >= 80 and edge.y+76 < 1568)
	assert(game.in_movement_zone(Vector2(200,400)))
	assert(not game.in_movement_zone(Vector2(500,400)))
	assert(not game.in_movement_zone(Vector2(200,50)))
	game.joystick = Vector2.ONE
	game.joystick_id = 3
	game.reset_stick()
	assert(game.joystick == Vector2.ZERO and game.joystick_id == -1)
	var touch := InputEventScreenTouch.new()
	touch.index = 2
	touch.position = Vector2(200,600)
	touch.pressed = true
	game._unhandled_input(touch)
	assert(game.joystick_id == 2 and game.joystick == Vector2.ZERO)
	var drag := InputEventScreenDrag.new()
	drag.index = 2
	drag.position = Vector2(270,600)
	game._unhandled_input(drag)
	assert(game.joystick.x == 1 and game.joystick.y == 0)
	# Second finger cannot steal movement; GUI-consumed release still stops it.
	touch.index = 3
	game._unhandled_input(touch)
	assert(game.joystick_id == 2)
	touch.index = 2
	touch.pressed = false
	game._input(touch)
	assert(game.joystick_id == -1 and game.joystick == Vector2.ZERO)
	assert(Balance.ARENA.has_point(game.bullet.position))
	game.layout_viewport(Vector2(1000,1280))
	await process_frame
	assert(game.horizontal_padding == 140 and game.ui.offset.x == 140)
	assert(game.overlay.size.y <= 1084)
	game.layout_viewport(Vector2(720,1280))
	assert(Balance.ARENA == Rect2(30,165,660,855))
	assert(ProjectSettings.get_setting("display/window/stretch/aspect") == "expand")
	print("PASS: admin unlocks/options/labs, single boss/bullet, paused tools, profile isolation/reload, normal restore, tall-phone safe layout/resize")
	cleanup()
	game.audio.shutdown()
	OS.delay_msec(150)
	await process_frame
	game.queue_free()
	await process_frame
	quit()
