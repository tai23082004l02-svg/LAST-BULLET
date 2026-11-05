extends SceneTree
var game: Node2D
const PROFILE := "user://results-ui-test.cfg"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.remove_absolute(PROFILE)
	game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = PROFILE
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	game.start_campaign(0)
	game.elapsed = 13
	game.finish_run()
	await process_frame
	assert(game.cards.get_node("ResultPrimary").text == "CHƠI LẠI")
	assert(not game.cards.has_node("ResultDouble"))
	assert(game.cards.get_node("ResultStats").get_child_count() == 3)
	assert(not game.cards.get_node("ResultDetails").visible)
	game.cards.get_node("ResultDetailsToggle").pressed.emit()
	assert(game.cards.get_node("ResultDetails").visible)
	game.start_campaign(0)
	game.campaign_won = true
	game.finish_run()
	await process_frame
	assert(game.cards.get_node("ResultPrimary").text == "MÀN TIẾP THEO")
	var balance: int = game.coins
	var reward: int = game.run_coins
	game.cards.get_node("ResultDouble").pressed.emit()
	await process_frame
	assert(game.coins == balance+reward and game.double_claimed)
	assert(game.cards.get_node("ResultDouble").disabled)
	game.claim_double_gold()
	assert(game.coins == balance+reward)
	game.show_results()
	assert(game.coins == balance+reward)
	game.cards.get_node("ResultPrimary").pressed.emit()
	assert(game.state == "playing" and game.active_stage == 1)
	game.start_run("blitz")
	game.finish_run()
	assert(game.cards.get_node("ResultPrimary").text == "CHƠI LẠI")
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(PROFILE)
	print("PASS results UI: failed/won routing, zero rewards, details toggle, once-only x2, next stage, Blitz retry")
	quit()
