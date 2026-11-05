extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var path := "user://campaign-test.cfg"
	DirAccess.remove_absolute(path)
	var game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = path
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	assert(game.campaign_unlocked == 1)
	game.start_campaign(4)
	assert(game.state == "menu")
	var tickets_before: int = game.summon.tickets
	for stage in range(5):
		game.start_campaign(stage)
		assert(game.mode == "campaign" and game.active_stage == stage)
		var original = game.bullet
		var objects: Array[Rect2] = game.world_obstacles()
		assert(objects.size() == (2 if stage == 1 else 1 if stage == 4 else 0))
		# Full active combat timeline for all rooms, including environmental damage
		# logic, bounded counts and all levels; invulnerability isolates progression.
		var steps := int(float(CampaignData.data(stage).at)*60)+4
		for frame in range(steps):
			game.invulnerable = 10
			if game.state == "upgrade": game.choose_upgrade(game.offered_upgrades[0])
			game._physics_process(1.0/60)
			assert(game.bullet == original and game.bullet.position.is_finite())
			assert(game.enemies.size() <= Balance.MAX_ENEMIES+1)
			for box in objects: assert(not box.grow(7).has_point(game.bullet.position))
			if frame%600 == 0: await process_frame
		if game.state == "upgrade": game.choose_upgrade(game.offered_upgrades[0])
		game._physics_process(0.05)
		assert(game.campaign_room == 3 and game.boss_spawned and is_instance_valid(game.boss))
		assert(game.boss.boss_style == stage)
		# Exercise each boss behaviour then finish a real boss kill to test unlocks.
		var boss = game.boss
		boss.phase = 2.2
		boss.advance(0.05,game.player)
		if stage == 1:
			boss.facing = Vector2.RIGHT
			assert(boss.blocks(Vector2.LEFT))
			boss.phase = 4
			assert(not boss.blocks(Vector2.LEFT))
		if stage in [2,3,4]:
			boss.hazard_cycle = 0
			boss.advance(0.01,game.player)
			assert(boss.hazard_clock > 0)
		game.damage_enemy(boss,10000,true,Vector2.RIGHT)
		assert(game.campaign_won and game.state == "results" and not game.new_record)
		assert(game.campaign_cleared.has(stage))
		assert(game.campaign_unlocked == mini(5,stage+2))
		var wallet: int = game.coins
		var tickets: int = game.summon.tickets
		game.finish_run()
		assert(game.coins == wallet and game.summon.tickets == tickets)
	assert(game.summon.tickets >= tickets_before+15)
	assert(game.best_score == 0) # Campaign does not overwrite Survival records.
	game.load_profile()
	assert(game.campaign_cleared.size() == 5 and game.campaign_unlocked == 5)
	# Repeat rewards: only one ticket (no repeated first-clear bundle).
	game.start_campaign(0)
	game.spawn_enemy(3)
	var before: int = game.summon.tickets
	game.damage_enemy(game.boss,10000,true,Vector2.UP)
	assert(game.summon.tickets == before+1)
	# Failed stage cannot grant a clear or unlock another stage.
	game.campaign_unlocked = 1
	game.campaign_cleared.clear()
	game.start_campaign(0)
	game.hp = 0
	game.finish_run()
	assert(not game.campaign_won and game.campaign_unlocked == 1 and game.campaign_cleared.is_empty())
	# Environment steering preserves bullet speed and is capped, heat has a warning.
	var arena := Balance.ARENA
	var field := CampaignData.magnets(arena,3)[0]
	var velocity := Vector2.RIGHT*560
	var steered := CampaignData.steer(field+Vector2(0,70),velocity,0.1,arena,3)
	assert(is_equal_approx(velocity.length(),steered.length()))
	assert(absf(velocity.angle_to(steered)) <= 0.1)
	assert(CampaignData.heat_state(0.5,0) == 1 and CampaignData.heat_state(2,0) == 2 and CampaignData.heat_state(4,0) == 0)
	# Final boss combines the preserved capture/return mechanic and phase-two dash.
	game.campaign_unlocked = 5
	game.start_campaign(4)
	game.spawn_enemy(3)
	var core = game.boss
	core.position = Vector2(360,300)
	core.hp = core.max_hp*0.49
	core.phase = 2.3
	core.advance(0.01,game.player)
	var origin: Vector2 = core.position
	core.advance(0.9,game.player)
	assert(core.position.distance_to(origin) > 100)
	core.position = Vector2(360,300)
	core.weak_timer = 0
	core.capture_ready = 0
	game.bullet.position = core.position+Vector2(61,0)
	game.bullet.velocity = Vector2.LEFT*560
	game.bullet.hit_cooldowns.clear()
	game.bullet.advance(0.03,game)
	assert(game.bullet.capture > 0)
	game.bullet.advance(1.2,game)
	assert(core.weak_timer == 3 and game.bullet.return_window == 3)
	game.bullet.position = game.player+Vector2(70,0)
	game.cooldown = 0
	game.request_deflect()
	var health: float = core.hp
	game.damage_enemy(core,2,true,Vector2.UP)
	assert(core.hp == health-8 and not game.bullet.return_strike)
	print("PASS: five full campaign timelines, rooms/upgrades, obstacle bounds, boss behaviours, clear/death/replay rewards, progression/save and heat/magnet rules")
	DirAccess.remove_absolute(path)
	game.audio.shutdown()
	OS.delay_msec(150)
	await process_frame
	game.queue_free()
	await process_frame
	quit()
