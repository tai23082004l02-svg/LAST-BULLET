extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/Main.tscn").instantiate(); game.save_path = "user://rpg-stress.cfg"
	root.add_child(game); game.set_physics_process(false); game.audio.enabled = false
	game.layout_viewport(Vector2(720,1600),Vector2(40,32))
	var gear: Array[int] = []
	for kind in range(12):
		var uid: int = game.progress.add_item(kind,3); game.progress.item(uid).level = 10; gear.append(uid)
	game.progress.pets.assign([0,1,2,3,4,5])
	for family in range(3):
		for slot in range(4): game.progress.equipped[slot] = gear[family*4+slot]
		for pet in range(6):
			game.progress.pet = pet; game.selected_weapon = (family*6+pet)%12
			game.start_run("survival","reflector"); game.upgrades.assign(Balance.UPGRADE_CAPS)
			for frame in range(900):
				game.invulnerable = 10
				game.joystick = Vector2.from_angle(frame*0.01) if frame%180 < 90 else Vector2.ZERO
				if frame%200 == 0: game.request_skill()
				game._physics_process(1.0/30)
				assert(game.state == "playing" and game.hp <= game.max_hp and game.hp > 0)
				assert(game.combat.shots.size() <= 160 and game.combat.hostile.size() <= 180 and game.combat.flashes.size() <= 32)
				assert(game.enemies.size() <= 49 and game.companions.heals <= 3)
				for shot in game.combat.shots: assert(shot.p.is_finite() and shot.ttl > 0)
				if frame%180 == 0: await process_frame
			game.finish_run(); game.show_menu(); await process_frame
	game.audio.shutdown(); game.queue_free(); await process_frame
	DirAccess.remove_absolute("user://rpg-stress.cfg")
	print("PASS RPG stress: 3 legendary +10 sets x6 pets x30s, all upgrades, mixed weapons/skills, HP and projectile/FX bounds")
	quit()
