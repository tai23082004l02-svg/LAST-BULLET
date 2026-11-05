extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = "user://graphics-test.cfg"
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	await process_frame
	# All eight atlas regions are valid and use the same backing texture.
	for i in range(8):
		var tex := NeonArt.texture(i)
		assert(tex.atlas == NeonArt.SHEET and tex.get_width() > 0 and tex.get_height() > 0)
		assert(Rect2(Vector2.ZERO,NeonArt.SHEET.get_size()).encloses(tex.region))
	assert(NeonArt.textures.size() == 8)
	game.show_menu()
	await process_frame
	var count := get_node_count()
	# Menus repeatedly create/release previews, cards and tweens cleanly.
	for i in range(12):
		game.show_skins()
		await process_frame
		game.show_settings()
		await process_frame
		game.show_menu()
		await process_frame
	assert(get_node_count() == count)
	game.start_run()
	var bullet = game.bullet
	for i in range(200):
		game.effects.burst(Vector2(100+i,300),Color.CYAN,"death")
	assert(game.effects.effects.size() == 80)
	game.effects.reduced = true
	game.effects.advance(0)
	assert(game.effects.effects.size() == 24)
	game.effects.advance(1)
	assert(game.effects.effects.is_empty())
	assert(game.bullet == bullet)
	game.effects.burst(Vector2(150,300),Color.CYAN,"hit")
	game.start_run()
	assert(game.effects.effects.is_empty())
	assert(ProjectSettings.get_setting("physics/common/physics_interpolation"))
	assert(game.bullet.physics_interpolation_mode == Node.PHYSICS_INTERPOLATION_MODE_ON)
	game.finish_run()
	game._physics_process(0)
	assert(not game.player_actor.visible and not game.effects.visible)
	DirAccess.remove_absolute(game.save_path)
	print("PASS: atlas bounds/cache, menu lifecycle, effects caps/expiry/reset, single bullet, interpolation and result visibility")
	game.audio.shutdown()
	OS.delay_msec(150)
	await process_frame
	game.queue_free()
	await process_frame
	quit()
