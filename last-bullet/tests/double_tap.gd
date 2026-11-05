extends SceneTree
var game: Node2D
func _initialize() -> void: call_deferred("run")
func touch(id: int, pressed: bool, at: Vector2, canceled := false) -> void:
	var event := InputEventScreenTouch.new()
	event.index = id
	event.position = at+Vector2(game.horizontal_padding,0)
	event.pressed = pressed
	event.canceled = canceled
	game._input(event)
	game._unhandled_input(event)
func drag(id: int, at: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = id
	event.position = at+Vector2(game.horizontal_padding,0)
	game._input(event)
	game._unhandled_input(event)
func tap(id := 0, at := Vector2(300,600)) -> void:
	touch(id,true,at)
	touch(id,false,at)
func run() -> void:
	var path := "user://double-tap-test.cfg"
	DirAccess.remove_absolute(path)
	game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = path
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	game.start_run()
	game.layout_viewport(Vector2(720,1600),Vector2(40,32))
	game._physics_process(0)
	assert(game.skill_status.visible and game.skill_status.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	for child in game.skill_status.get_parent().get_children():
		if child is Button and child.visible: assert(child == game.pause_button)
	tap()
	assert(game.combat.skill_uses == 0 and game.joystick == Vector2.ZERO)
	tap()
	assert(game.combat.skill_uses == 1 and game.cooldown > 0 and game.joystick_id == -1)
	tap(); tap()
	assert(game.combat.skill_uses == 1) # Cooldown still applies.
	game.cooldown = 0
	# A drag, even one that returns to its origin, cancels double-tap recognition.
	touch(0,true,Vector2(300,600))
	drag(0,Vector2(400,600))
	drag(0,Vector2(300,600))
	touch(0,false,Vector2(300,600))
	tap()
	assert(game.combat.skill_uses == 1)
	game.clear_skill_taps()
	# Long press, cancel, slow pair and distant pair cannot fire a skill.
	touch(0,true,Vector2(300,600))
	game.tap_contacts[0].at -= 300
	touch(0,false,Vector2(300,600))
	tap()
	assert(game.combat.skill_uses == 1)
	game.clear_skill_taps()
	touch(0,true,Vector2(300,600)); touch(0,false,Vector2(300,600),true)
	tap()
	assert(game.combat.skill_uses == 1)
	game.clear_skill_taps()
	tap(); game.last_skill_tap -= 400; tap()
	assert(game.combat.skill_uses == 1)
	game.clear_skill_taps()
	tap(0,Vector2(100,600)); tap(0,Vector2(500,600))
	assert(game.combat.skill_uses == 1)
	game.clear_skill_taps()
	# Simultaneous two-finger taps are not a sequential double tap.
	touch(0,true,Vector2(300,600)); touch(1,true,Vector2(300,600))
	touch(0,false,Vector2(300,600)); touch(1,false,Vector2(300,600))
	assert(game.combat.skill_uses == 1)
	game.clear_skill_taps()
	# A second finger can double-tap while the first keeps moving, without stealing the stick.
	touch(0,true,Vector2(200,600)); drag(0,Vector2(270,600))
	tap(1,Vector2(500,800)); drag(0,Vector2(280,600)); tap(1,Vector2(500,800))
	assert(game.combat.skill_uses == 2 and game.joystick_id == 0 and game.joystick.x == 1)
	touch(0,false,Vector2(270,600))
	game.cooldown = 0
	game.clear_skill_taps()
	var pause_point: Vector2 = game.pause_button.position+game.pause_button.size/2
	tap(0,pause_point); tap(0,pause_point)
	assert(game.combat.skill_uses == 2)
	for state in ["paused","upgrade","results","menu"]:
		game.clear_skill_taps()
		game.state = state
		tap(); tap()
		assert(game.combat.skill_uses == 2)
	game.state = "playing"
	game.clear_skill_taps()
	tap(); game.toggle_pause(); game.toggle_pause(); tap()
	assert(game.combat.skill_uses == 2)
	# Desktop retains Space; synthetic touch-mouse events cannot add extra taps.
	var mouse := InputEventMouseButton.new()
	mouse.device = InputEvent.DEVICE_ID_EMULATION
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.position = Vector2(300,600)
	for pressed in [true,false,true,false]:
		mouse.pressed = pressed
		game._input(mouse); game._unhandled_input(mouse)
	assert(game.combat.skill_uses == 2)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(path)
	print("PASS double tap: hidden skill button, sequential taps, cooldown, drag/jitter/hold/cancel/distance/timing, multitouch movement, UI/state isolation")
	quit()
