extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var path := "user://shooter-campaign-test.cfg"
	DirAccess.remove_absolute(path)
	var game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = path
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	game.layout_viewport(Vector2(720,1280))
	game.start_campaign(4)
	assert(game.state == "menu")
	var initial_tickets: int = game.summon.tickets
	for stage in range(5):
		game.start_campaign(stage)
		game.player = Vector2(180,300)
		# Run each stage's active timeline including new weapons, enemies, upgrade pauses and hazards.
		var steps := int(float(CampaignData.data(stage).at)*30)+30
		for frame in range(steps):
			game.invulnerable = 10
			if game.state == "upgrade": game.choose_upgrade(game.offered_upgrades[0])
			game._physics_process(1.0/30)
			assert(game.combat.shots.size() <= 160 and game.combat.hostile.size() <= 180)
			assert(game.enemies.size() <= Balance.MAX_ENEMIES+1)
			if frame%450 == 0: await process_frame
		assert(game.campaign_room == 3 and is_instance_valid(game.boss))
		var boss = game.boss
		assert(boss.boss_style == stage)
		# Fan patterns differ, aimed hostile shots exist; pillars block line of sight.
		game.combat.hostile.clear()
		game.player = boss.position+Vector2(0,100)
		game.combat.enemy_volley(boss)
		assert(game.combat.hostile.size() == [3,5,5,5,3][stage])
		if stage == 4:
			boss.hp = boss.max_hp*0.4
			game.combat.hostile.clear()
			game.combat.enemy_volley(boss)
			assert(game.combat.hostile.size() == 7)
		if stage == 1:
			boss.phase = 1
			boss.facing = Vector2.LEFT
			assert(boss.blocks(Vector2.RIGHT))
			boss.phase = 4
			assert(not boss.blocks(Vector2.RIGHT))
		if stage in [2,3,4]:
			boss.hazard_cycle = 0
			boss.advance(0.01,game.player)
			assert(boss.hazard_clock > 0)
		# Kill with normal damage. No capture, deflect or return strike is required.
		boss.phase = 4
		game.damage_enemy(boss,10000,true,Vector2.UP)
		assert(game.campaign_won and game.state == "results")
		assert(game.campaign_unlocked == mini(5,stage+2) and game.campaign_cleared.has(stage))
		assert(game.campaign_stars[stage] == 3)
		var coins: int = game.coins
		var tickets: int = game.summon.tickets
		game.finish_run()
		assert(game.coins == coins and game.summon.tickets == tickets)
	assert(game.summon.tickets >= initial_tickets+15 and game.best_score == 0)
	game.load_profile()
	game.audio.enabled = false
	assert(game.campaign_cleared.size() == 5)
	game.start_campaign(0)
	game.spawn_enemy(3)
	var tickets: int = game.summon.tickets
	game.damage_enemy(game.boss,10000,true,Vector2.ZERO)
	assert(game.summon.tickets == tickets+1)
	game.campaign_unlocked = 1
	game.campaign_cleared.clear()
	game.start_campaign(0)
	game.hp = 0
	game.finish_run()
	assert(not game.campaign_won and game.campaign_unlocked == 1 and game.campaign_cleared.is_empty())
	game.audio.shutdown()
	await create_timer(0.15).timeout
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(path)
	print("PASS shooter campaign: five active timelines, bosses/volleys/phase2/shields/hazards, no return mechanics, stars, unlocks, saves and once-only rewards")
	quit()
