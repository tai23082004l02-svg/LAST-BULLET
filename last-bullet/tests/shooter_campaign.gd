extends SceneTree
var game: Node2D
const PROFILE := "user://room-campaign-test.cfg"
func _initialize() -> void: call_deferred("run")
func new_game() -> Node2D:
	var instance = load("res://scenes/Main.tscn").instantiate()
	instance.save_path = PROFILE
	root.add_child(instance)
	instance.set_physics_process(false)
	instance.audio.enabled = false
	instance.layout_viewport(Vector2(720,1280))
	return instance
func complete(stage: int, hard: bool) -> void:
	game.campaign_hard = hard
	game.start_campaign(stage)
	var entered: Array[int] = []
	for frame in range(4000):
		if game.state == "results": break
		if not entered.has(game.adventure.room): entered.append(game.adventure.room)
		game.invulnerable = 10
		if game.state == "upgrade": game.choose_upgrade(game.offered_upgrades[0])
		elif game.state == "room_choice": game.adventure.choice("heal" if game.adventure.room == 2 else "risk")
		else:
			game._physics_process(0.1)
			for enemy in game.enemies.duplicate():
				if enemy.kind == 3:
					assert(enemy.boss_style == stage)
					game.combat.hostile.clear()
					game.player = enemy.position+Vector2(0,100)
					game.combat.enemy_volley(enemy)
					assert(game.combat.hostile.size() == [3,5,5,5,3][stage]+(2 if hard else 0))
					enemy.phase = 4
				game.damage_enemy(enemy,10000,true,Vector2.ZERO)
		if frame%80 == 0: await process_frame
	assert(entered == [0,1,2,3,4])
	assert(game.state == "results" and game.campaign_won and game.progress.checkpoint.is_empty())
	assert((game.progress.hard_stars[stage] if hard else game.campaign_stars[stage]) == 3)
func run() -> void:
	DirAccess.remove_absolute(PROFILE)
	game = new_game()
	game.start_campaign(0)
	# Clear room one, save during its upgrade choice, reload and resume same offers.
	for frame in range(1500):
		game.invulnerable = 10
		game._physics_process(0.1)
		for enemy in game.enemies.duplicate(): game.damage_enemy(enemy,10000,true,Vector2.ZERO)
		if game.state == "upgrade": break
		if frame%80 == 0: await process_frame
	assert(game.progress.checkpoint.phase == "upgrade")
	var offers: Array = game.offered_upgrades.duplicate()
	var materials: int = game.progress.materials
	var coins: int = game.coins
	game.audio.shutdown(); game.queue_free(); await process_frame
	game = new_game()
	assert(game.adventure.resume())
	assert(game.offered_upgrades == offers and game.state == "upgrade")
	assert(game.progress.materials == materials and game.coins == coins)
	game.choose_upgrade(game.offered_upgrades[0])
	assert(game.adventure.room == 1 and game.progress.checkpoint.room == 1)
	game.adventure.room_reward(); game.adventure.room_reward()
	var paid: int = game.progress.materials
	game.adventure.room_reward()
	assert(game.progress.materials == paid)
	# A new attempt deliberately replaces the checkpoint, then all five stages work.
	for stage in range(5):
		await complete(stage,false)
		assert(game.progress.pets.has(stage+1) and game.campaign_cleared.has(stage))
		var gold: int = game.coins
		game.finish_run(); assert(game.coins == gold)
	var normal: Array = game.campaign_stars.duplicate()
	await complete(0,true)
	assert(game.campaign_stars == normal and game.progress.hard_stars[0] == 3)
	game.show_menu()
	game.progress.sweep_tickets = 16
	var tickets: int = game.summon.tickets
	coins = game.coins
	for count in [1,5,10]:
		var reward: Dictionary = game.adventure.sweep(0,false,count)
		assert(reward.gold == 40*count and reward.mats == 8*count)
	assert(game.progress.sweep_tickets == 0 and game.summon.tickets == tickets+16 and game.coins == coins+640)
	coins = game.coins
	assert(game.adventure.sweep(1,true,1).is_empty())
	assert(game.adventure.sweep(0,false,10).is_empty())
	assert(game.coins == coins and game.campaign_stars == normal)
	game.progress.sweep_tickets = 2
	game.rpg_ui.sweep(0,false)
	game.rpg_ui.claim_sweep(0,false,1)
	coins = game.coins
	game.rpg_ui.claim_sweep(0,false,1)
	assert(game.coins == coins and game.progress.sweep_tickets == 1)
	# Failed stage clears checkpoint, preserves earned items/materials, cannot unlock.
	game.campaign_hard = false
	game.start_campaign(0)
	materials = game.progress.materials
	var bag: int = game.progress.items.size()
	game.hp = 0; game.finish_run()
	assert(game.progress.checkpoint.is_empty() and game.progress.materials == materials and game.progress.items.size() == bag)
	game.audio.shutdown(); await create_timer(0.15).timeout
	game.queue_free(); await process_frame
	DirAccess.remove_absolute(PROFILE)
	print("PASS room campaign: five x five rooms, hard stars, checkpoint/offers/reload, receipt guards, fixed pets, replay/sweep economy and failure preservation")
	quit()
