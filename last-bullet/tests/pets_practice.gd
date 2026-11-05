extends SceneTree
var game: Node2D
const PROFILE := "user://pets-practice-test.cfg"
func _initialize() -> void: call_deferred("run")
func enemy(point: Vector2) -> ArenaEnemy:
	var e := ArenaEnemy.new(); e.setup(2,1); e.position = point; e.hp = 1000; e.max_hp = 1000; e.fire_clock = 100
	game.add_child(e); game.enemies.append(e); return e
func run() -> void:
	DirAccess.remove_absolute(PROFILE)
	game = load("res://scenes/Main.tscn").instantiate(); game.save_path = PROFILE
	root.add_child(game); game.set_physics_process(false); game.audio.enabled = false
	game.layout_viewport(Vector2(720,1280))
	game.progress.pets.assign([0,1,2,3,4,5])
	for pet in range(6):
		game.progress.pet = pet; game.start_run(); game.player = Vector2(300,500)
		var target := enemy(Vector2(450,500))
		game.companions.pet_position = game.player
		if pet == 0:
			game.companions.advance(0.1); assert(game.combat.shots.size() == 1)
		elif pet == 1:
			game.pickups.append(Vector2(100,100)); game.companions.advance(0.1); assert(game.pickups[0] == game.player)
		elif pet == 2:
			for i in range(4):
				game.hp = 1; game.companions.timer = 0; game.companions.advance(0.1)
				assert(game.hp == (2 if i < 3 else 1))
		elif pet == 3:
			game.hurt_player(Vector2(500,500)); assert(game.hp == game.max_hp)
			game.invulnerable = 0; game.hurt_player(Vector2(500,500)); assert(game.hp == game.max_hp-1)
		elif pet == 4:
			game.companions.advance(0.1); assert(target.chilled > 0)
		else:
			game.companions.advance(0.1); assert(target.hp < 1000)
		game.state = "upgrade"
		var timer: float = game.companions.timer
		game.companions.advance(2); assert(game.companions.timer == timer)
	# Gear changes real HP/weapon/crit/speed/cooldown and two/four-piece sets.
	for slot in range(4): game.progress.equipped[slot] = game.progress.add_item(slot,3)
	game.start_run()
	assert(game.max_hp > 5 and game.run_stats.speed > 1 and game.run_stats.crit > 0 and game.run_stats.cooldown < 1)
	var target := enemy(game.player+Vector2(100,0)); target.chilled = 2
	var hp_before: float = target.hp
	game.damage_enemy(target,10,true,Vector2.ZERO)
	assert(is_equal_approx(hp_before-target.hp,11.5))
	assert(game.rpg_ui.owns("gear",0) and game.rpg_ui.owns("weapon",11) and not game.rpg_ui.owns("hero",4))
	game.spawn_enemy(0); assert(game.rpg_ui.owns("monster",0))
	game.show_menu()
	game.rpg_ui.save_preset(0)
	var saved: Array = game.progress.equipped.duplicate()
	game.progress.equipped.assign([-1,-1,-1,-1])
	game.rpg_ui.load_preset(0); assert(game.progress.equipped == saved)
	# Practice has a fixed 10-second window, static targets, no rewards and no checkpoint overwrite.
	game.campaign_hard = false; game.start_campaign(0)
	var checkpoint: Dictionary = game.progress.checkpoint.duplicate(true)
	game.show_menu()
	var gold: int = game.coins; var tickets: int = game.summon.tickets; var bag: int = game.progress.items.size()
	game.adventure.practice(1)
	var points: Array = game.enemies.map(func(e): return e.position)
	for i in range(610):
		game._physics_process(1.0/60)
		if game.state == "practice_results": break
	assert(game.state == "practice_results" and game.adventure.practice_damage > 0)
	assert(game.enemies.map(func(e): return e.position) == points)
	assert(game.coins == gold and game.summon.tickets == tickets and game.progress.items.size() == bag and game.progress.checkpoint == checkpoint)
	game.audio.shutdown(); game.queue_free(); await process_frame
	DirAccess.remove_absolute(PROFILE)
	print("PASS pets/practice: six passive pets, limits/pause, effective gear/sets, collection, presets, fixed static DPS window without rewards/checkpoint loss")
	quit()
