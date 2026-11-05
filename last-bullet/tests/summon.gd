extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var system := SummonSystem.new()
	var owned: Array[int] = [0]
	assert(system.tickets == 5)
	var before := system.rng.state
	assert(system.pull(10,owned).is_empty() and system.tickets == 5 and system.rng.state == before)
	assert(system.pull(-1,owned,true).is_empty())
	assert(system.pull(2,owned,true).is_empty())
	system.rng.seed = 87
	system.tickets = 1000
	var epic_gap := 0
	var legendary_gap := 0
	for i in range(1000):
		var result: Dictionary = system.pull(1,owned)[0]
		epic_gap = 0 if result.tier > 0 else epic_gap+1
		legendary_gap = 0 if result.tier == 2 else legendary_gap+1
		assert(epic_gap < 10 and legendary_gap < 50)
		assert(SummonSystem.POOLS[int(result.tier)].has(int(result.robot)))
	assert(system.tickets == 0 and system.total_pulls == 1000)
	# Hard legendary pity takes priority and resets both meters.
	system.legendary_pity = 49
	system.epic_pity = 9
	system.tickets = 1
	var rare: Dictionary = system.pull(1,owned)[0]
	assert(rare.tier == 2 and system.epic_pity == 0 and system.legendary_pity == 0)
	# Admin batch is free, bounded to ten, and duplicates give the advertised shards.
	owned = [0,1,2,3,4,5,6]
	var shards := system.shards
	var expected := 0
	var batch := system.pull(10,owned,true)
	for result in batch:
		assert(result.duplicate)
		expected += SummonSystem.SHARD_REWARDS[int(result.tier)]
	assert(system.shards == shards+expected and system.tickets == 0)
	var config := ConfigFile.new()
	system.write(config)
	var restored := SummonSystem.new()
	restored.read(config)
	assert(restored.shards == system.shards and restored.total_pulls == system.total_pulls)
	assert(restored.last_results == system.last_results and restored.legendary_pity == system.legendary_pity)
	var collection: Array[int] = [0]
	restored.shards = 29
	assert(not restored.exchange(1,collection))
	restored.shards = 30
	assert(restored.exchange(1,collection) and restored.shards == 0)
	assert(not restored.exchange(1,collection) and restored.shards == 0)
	# Base-rate check excludes pity by resetting meters for independent base rolls.
	var counts := [0,0,0]
	var sample := SummonSystem.new()
	sample.rng.seed = 3456
	for i in range(10000):
		sample.epic_pity = 0
		sample.legendary_pity = 0
		var result: Dictionary = sample.pull(1,owned,true)[0]
		counts[int(result.tier)] += 1
	assert(absf(counts[0]/10000.0-0.75) < 0.025)
	assert(absf(counts[1]/10000.0-0.20) < 0.025)
	assert(absf(counts[2]/10000.0-0.05) < 0.015)
	# UI awards before animation, double clicks/skip/review do not spend again.
	var path := "user://summon-test.cfg"
	for file in [path,"user://summon-test-admin.cfg","user://summon-test-mode.cfg"]: DirAccess.remove_absolute(file)
	var game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = path
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	game.show_summon()
	game.begin_summon(1)
	assert(game.summon.tickets == 4 and game.state == "summon")
	game.begin_summon(1)
	assert(game.summon.tickets == 4 and game.summon.total_pulls == 1)
	game.load_profile()
	assert(game.summon.tickets == 4 and game.summon.last_results.size() == 1)
	game.summon_reveal.skip()
	game.show_summon_results()
	assert(game.summon.tickets == 4 and game.summon.total_pulls == 1)
	game.show_menu()
	game.show_admin()
	game.switch_admin(true)
	game.show_summon()
	game.begin_summon(10)
	game.summon_reveal.skip()
	assert(game.summon.total_pulls == 10 and game.summon.tickets == 5)
	game.show_menu()
	game.show_admin()
	game.switch_admin(false)
	assert(game.summon.total_pulls == 1 and game.summon.tickets == 4)
	assert(game.summon.last_results.size() == 1)
	print("PASS: summon funds/batch validation, 10/50 pity, duplicate shards, exchange, persistence, base rates, pre-animation commit and skip/double-click guards")
	for file in [path,"user://summon-test-admin.cfg","user://summon-test-mode.cfg"]: DirAccess.remove_absolute(file)
	game.audio.shutdown()
	OS.delay_msec(150)
	await process_frame
	game.queue_free()
	await process_frame
	quit()
