extends SceneTree

var game: Node2D

func _initialize() -> void:
	call_deferred("run")

func enemy_at(kind: int, point: Vector2) -> ArenaEnemy:
	var enemy := ArenaEnemy.new()
	enemy.setup(kind,1)
	enemy.position = point
	game.add_child(enemy)
	game.enemies.append(enemy)
	return enemy

func clear_enemies() -> void:
	for enemy in game.enemies:
		enemy.free()
	game.enemies.clear()
	game.boss = null
	game.bullet.hit_cooldowns.clear()

func run() -> void:
	game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = "user://features-test.cfg"
	DirAccess.remove_absolute(game.save_path)
	root.add_child(game)
	game.set_physics_process(false)
	await process_frame
	game.rng.seed = 42
	seed(42)
	game.start_run()
	var bullet: PermanentBullet = game.bullet
	# Normal, perfect, outgoing, missed and early buffered catches.
	bullet.position = game.player+Vector2(80,0)
	bullet.velocity = Vector2.LEFT*560
	game.request_deflect()
	assert(not game.last_deflect_perfect and bullet.boost == 1)
	game.cooldown = 0
	bullet.position = game.player+Vector2(35,0)
	bullet.velocity = Vector2.LEFT*560
	game.request_deflect()
	assert(game.perfect_count == 1 and bullet.perfect_boost and bullet.boost == 2.2)
	assert(bullet.velocity.normalized() == game.aim)
	game.cooldown = 0
	bullet.velocity = Vector2.RIGHT*560
	game.request_deflect()
	assert(game.perfect_count == 1 and not game.last_deflect_perfect)
	game.cooldown = 0
	bullet.position = game.player+Vector2(200,0)
	game.request_deflect()
	assert(game.deflect_window > 0)
	bullet.position = game.player+Vector2(35,0)
	bullet.velocity = Vector2.LEFT*560
	assert(game.try_deflect(false))
	assert(game.perfect_count == 1)
	# Expired buffer misses; pause freezes run and cannot award deflect.
	bullet.position = Vector2(100,200)
	game.cooldown = 0
	game.request_deflect()
	game.spawn_timer = 100
	game._physics_process(0.23)
	assert(game.deflect_window <= 0)
	game.toggle_pause()
	var time: float = game.elapsed
	game._physics_process(1.0)
	game.request_deflect()
	assert(game.elapsed == time)
	game.toggle_pause()
	# Wide Catch tradeoff; Phase Shot hits through an enemy with same bullet.
	game.upgrades[7] = 2
	assert(game.deflect_radius() == 141)
	game.cooldown = 0
	bullet.position = game.player+Vector2(130,0)
	game.request_deflect()
	assert(is_equal_approx(game.cooldown,0.89))
	clear_enemies()
	game.upgrades[5] = 1
	game.cooldown = 0
	game.aim = Vector2.RIGHT
	bullet.position = game.player+Vector2(30,0)
	game.request_deflect()
	bullet.position = Vector2(200,400)
	var target := enemy_at(2,Vector2(260,400))
	bullet.advance(0.1,game)
	assert(target.hp < target.max_hp and bullet.pierce_left == 0 and bullet.velocity.x > 0)
	# Bank charge is capped and consumed by impact.
	clear_enemies()
	game.upgrades[6] = 3
	bullet.position = Vector2(680,400)
	bullet.velocity = Vector2.RIGHT*560
	bullet.advance(0.04,game)
	assert(bullet.bank_charge == 1 and bullet.velocity.x < 0)
	target = enemy_at(2,Vector2(600,400))
	bullet.advance(0.06,game)
	assert(bullet.bank_charge == 0)
	# No false hits on targets behind the direction of travel.
	clear_enemies()
	bullet.position = Vector2(300,400)
	bullet.velocity = Vector2.RIGHT*560
	target = enemy_at(2,Vector2(200,400))
	bullet.advance(0.016,game)
	assert(target.hp == target.max_hp)
	# Shield front blocks and rear takes damage. Fire cannot bypass shield.
	clear_enemies()
	target = enemy_at(4,Vector2(360,400))
	target.facing = Vector2.RIGHT
	game.damage_enemy(target,1,true,Vector2.LEFT)
	assert(target.hp == target.max_hp)
	game.damage_enemy(target,1,true,Vector2.RIGHT)
	assert(target.hp == target.max_hp-1)
	game.damage_enemy(target,1)
	assert(target.hp == target.max_hp-1)
	# Zone locks to the telegraphed point, waits, then damages; no projectile.
	clear_enemies()
	target = enemy_at(5,Vector2(100,300))
	target.advance(0.01,game.player)
	var mark := target.hazard_point
	assert(not target.hazard_active())
	target.advance(1.12,game.player+Vector2(100,0))
	assert(target.hazard_active() and target.hazard_point == mark)
	game.player = mark
	game.invulnerable = 0
	game.spawn_timer = 100
	var hp: int = game.hp
	game._physics_process(0.01)
	assert(game.hp == hp-1)
	# Each mission pays once, persists even without results. Purchases are atomic.
	game.kills = 15
	game.best_combo = 10
	game.perfect_count = 3
	game.check_missions()
	assert(game.coins == 45 and game.mission_claimed.count(true) == 3)
	game.check_missions()
	assert(game.coins == 45)
	game.buy_or_equip(2) # Cannot afford 60.
	assert(game.coins == 45 and not game.owned_skins.has(2))
	game.buy_or_equip(1)
	assert(game.coins == 15 and game.selected_skin == 1)
	game.buy_or_equip(1)
	assert(game.coins == 15)
	game.coins = 0
	game.selected_skin = 0
	game.load_profile()
	assert(game.coins == 15 and game.selected_skin == 1)
	game.start_run()
	assert(game.bullet.skin == 1 and game.bullet != bullet)
	# XP collection and synthetic two-finger controls; release over GUI resets stick.
	game.pickups.append(game.player)
	game._physics_process(0.01)
	assert(game.xp == 1)
	var touch := InputEventScreenTouch.new()
	touch.index = 1
	touch.pressed = true
	touch.position = Vector2(135,1135)
	game._unhandled_input(touch)
	var drag := InputEventScreenDrag.new()
	drag.index = 1
	drag.position = Vector2(200,1135)
	game._unhandled_input(drag)
	var before: Vector2 = game.player
	game._physics_process(0.02)
	assert(game.player.x > before.x)
	game.bullet.position = game.player+Vector2(70,0)
	game.cooldown = 0
	game.deflect_button.button_down.emit()
	assert(game.bullet.boost > 0 and game.joystick_id == 1)
	touch.pressed = false
	touch.position = Vector2(580,1135)
	game._input(touch)
	assert(game.joystick_id == -1 and game.joystick == Vector2.ZERO)
	# Card selection only accepts offered upgrades and respects limits.
	game.show_upgrades()
	assert(game.offered_upgrades.size() == 3)
	var offered: int = game.offered_upgrades[0]
	game.choose_upgrade(offered)
	assert(game.upgrades[offered] == 1)
	game.choose_upgrade(offered)
	assert(game.upgrades[offered] == 1)
	game.finish_run()
	var wallet: int = game.coins
	game.finish_run()
	assert(game.coins == wallet)
	# Streams decode; pool bounded; mute stops voices.
	for stream in game.audio.STREAMS.values():
		assert(stream.get_length() > 0)
	game.audio.enabled = true
	game.audio.play_event("deflect")
	assert(game.audio.voices.size() == 8)
	game.audio.enabled = false
	game.audio.stop_all()
	for voice in game.audio.voices:
		assert(not voice.playing)
	DirAccess.remove_absolute(game.save_path)
	print("PASS: deflect timing, pause, upgrades, sweeps, shield, hazards, mission wallet, skins, saves, retry, audio decoding/mute")
	game.audio.shutdown()
	OS.delay_msec(150)
	await process_frame
	game.queue_free()
	await process_frame
	await process_frame
	quit()
