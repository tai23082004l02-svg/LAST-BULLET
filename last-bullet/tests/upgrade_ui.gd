extends SceneTree
var game: Node2D
const PROFILE := "user://upgrade-ui-test.cfg"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.remove_absolute(PROFILE)
	game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = PROFILE
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	game.start_run()
	game.level = 2
	game.show_upgrades()
	await process_frame
	assert(game.offered_upgrades.size() == 3 and game.state == "upgrade")
	assert(game.upgrade_shade.visible and game.upgrade_shade.mouse_filter == Control.MOUSE_FILTER_STOP)
	assert(not game.hud.visible and not game.mission_label.visible and not game.deflect_button.visible)
	var elapsed: float = game.elapsed
	var bullet_position: Vector2 = game.bullet.position
	game._physics_process(1)
	assert(game.elapsed == elapsed and game.bullet.position == bullet_position)
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(300,600)
	game._unhandled_input(touch)
	assert(game.joystick_id == -1)
	for index in range(8):
		assert(game.upgrade_delta(index).contains("→"))
	assert(game.upgrade_delta(7).contains("0.65 → 0.77"))
	for height in [1280,1600,1800]:
		game.layout_viewport(Vector2(720,height),Vector2(40,32))
		await process_frame
		assert(game.overlay.size.y <= 800)
		assert(game.overlay.position.y >= 40 and game.overlay.position.y+game.overlay.size.y <= height-32)
		assert(game.upgrade_shade.size.y == height)
		assert(game.cards.get_combined_minimum_size().y <= 736)
	var choice: int = game.offered_upgrades[0]
	var before: int = game.upgrades[choice]
	game.cards.get_node("Upgrade%d" % choice).pressed.emit()
	assert(game.upgrades[choice] == before+1 and game.state == "playing")
	assert(not game.upgrade_shade.visible and not game.overlay.visible and game.joystick == Vector2.ZERO)
	game.choose_upgrade(choice)
	assert(game.upgrades[choice] == before+1)
	# Only the remaining non-maxed choice may be offered; exhausting all choices heals.
	for i in range(8): game.upgrades[i] = Balance.UPGRADE_CAPS[i]
	game.upgrades[7] = 2
	game.show_upgrades()
	assert(game.offered_upgrades == [7])
	game.choose_upgrade(7)
	game.hp = 2
	game.show_upgrades()
	assert(game.hp == 3 and game.state == "playing")
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(PROFILE)
	print("PASS upgrade UI: safe compact layout, paused combat, hidden HUD, touch isolation, deltas, single selection and capped offers")
	quit()
