extends SceneTree
var game: Node2D
const PROFILE := "user://lobby-test.cfg"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for p in [PROFILE,"user://lobby-test-admin.cfg","user://lobby-test-mode.cfg"]: DirAccess.remove_absolute(p)
	game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = PROFILE
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	await process_frame
	var shell = game.home_shell
	assert(shell.visible and shell.home_view.visible)
	assert(shell.compact(1000074) == "1M")
	assert(game.full_number(1000074) == "1,000,074")
	var selected: int = game.selected_robot
	var balance: int = game.coins
	shell.cycle_robot(1)
	assert(game.selected_robot == selected and game.coins == balance)
	shell.equip_preview()
	assert(game.selected_robot == selected and game.coins == balance)
	for h in [1280,1600,1800]:
		game.layout_viewport(Vector2(720,h),Vector2(40,32))
		assert(shell.top_bar.position.y >= 40)
		assert(shell.bottom_bar.position.y+shell.bottom_bar.size.y <= h-32)
		assert(shell.stage_card.position.y+shell.stage_card.size.y <= shell.missions_button.position.y)
		assert(shell.hero_hint.position.y+shell.hero_hint.size.y <= shell.stage_card.position.y)
	game.show_robots()
	assert(shell.visible and not shell.home_view.visible and shell.active_page == 1)
	game.show_menu()
	game.preferred_mode = "blitz"
	game.play_primary()
	assert(game.state == "playing" and game.mode == "blitz" and not shell.visible)
	game.finish_run()
	game.run_coins = 20
	game.result_paid = true
	game.double_claimed = false
	game.reward_profile_path = PROFILE
	game.show_menu()
	assert(game.pending_lobby_reward())
	balance = game.coins
	game.claim_lobby_reward()
	assert(game.coins == balance+20 and not game.pending_lobby_reward())
	game.claim_lobby_reward()
	assert(game.coins == balance+20)
	game.double_claimed = false
	game.reward_profile_path = "other-profile"
	assert(not game.pending_lobby_reward())
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	for p in [PROFILE,"user://lobby-test-admin.cfg","user://lobby-test-mode.cfg"]: DirAccess.remove_absolute(p)
	print("PASS mobile lobby: navigation, safe layout, preview ownership, primary mode, once-only profile rewards")
	quit()
