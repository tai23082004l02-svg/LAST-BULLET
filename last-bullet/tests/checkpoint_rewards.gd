extends SceneTree
const PROFILE := "user://checkpoint-rewards.cfg"
func _initialize() -> void: call_deferred("run")
func instance_game() -> Node2D:
	var game = load("res://scenes/Main.tscn").instantiate(); game.save_path = PROFILE
	root.add_child(game); game.set_physics_process(false); game.audio.enabled = false
	return game
func run() -> void:
	DirAccess.remove_absolute(PROFILE)
	var game = instance_game()
	game.start_campaign(0)
	var run_id: String = game.adventure.run_id
	# A mid-room XP choice survives restart without advancing the room or losing the selected build.
	game.level = 2
	game.show_upgrades()
	var offered: Array = game.offered_upgrades.duplicate()
	assert(game.progress.checkpoint.phase == "xp_upgrade")
	game.audio.shutdown(); game.queue_free(); await process_frame
	game = instance_game(); assert(game.adventure.resume())
	assert(game.adventure.room == 0 and game.offered_upgrades == offered)
	var choice: int = game.offered_upgrades[0]
	game.choose_upgrade(choice)
	assert(game.adventure.room == 0 and game.upgrades[choice] == 1 and game.progress.checkpoint.upgrades[choice] == 1)
	# Pay missions/milestones after the entry checkpoint, then terminate mid-room.
	game.kills = 30; game.best_combo = 10; game.combat.skill_uses = 3; game.elapsed = 121
	game.check_missions(); game._physics_process(0)
	var gold: int = game.coins; var tickets: int = game.summon.tickets; var sweeps: int = game.progress.sweep_tickets
	assert(game.progress.receipts.has(run_id+":milestone:0") and game.progress.receipts.has(run_id+":milestone:1"))
	game.audio.shutdown(); game.queue_free(); await process_frame
	game = instance_game()
	assert(game.adventure.resume())
	assert(game.mission_coins == 45 and game.mission_claimed.count(true) == 3 and game.milestone_claimed.count(true) == 2)
	game.kills = 30; game.best_combo = 10; game.combat.skill_uses = 3; game.elapsed = 121
	game.check_missions(); game._physics_process(0)
	assert(game.coins == gold and game.summon.tickets == tickets and game.progress.sweep_tickets == sweeps)
	# Current checkpoint receipts survive history pruning.
	for i in range(1600): game.progress.mark("other:"+str(i))
	assert(game.progress.receipts.has(run_id+":mission:0"))
	# Same-profile x2 still includes banked mission gold once, never reissues tickets or gear.
	game.hp = 0; game.finish_run()
	var reward: int = game.run_coins
	gold = game.coins
	game.claim_double_gold(); game.claim_double_gold()
	assert(game.coins == gold+reward and game.summon.tickets == tickets and game.progress.checkpoint.is_empty())
	game.audio.shutdown(); game.queue_free(); await process_frame
	DirAccess.remove_absolute(PROFILE)
	print("PASS checkpoints: mid-room mission/milestone bank survives replay without double pay, receipt pruning protects checkpoint and x2 remains once-only")
	quit()
