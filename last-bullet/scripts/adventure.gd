extends Node
const ROOM_NAMES := ["GIAO TRANH","TINH ANH","TIẾP TẾ","SỰ KIỆN","BOSS"]
var game: Node2D
var room := 0
var spawned := 0
var quota := 0
var clock := 0.0
var hard := false
var pending_upgrade := false
var run_id := ""
var risk := 0.0
var max_penalty := 0
var practice_damage := 0.0
var practice_clock := 0.0
var practice_group := 0
func new_id() -> String: return str(Time.get_unix_time_from_system())+"-"+str(Time.get_ticks_usec())+"-"+str(randi())
func start(stage: int, difficult: bool) -> void:
	hard = difficult; room = 0; risk = 0; max_penalty = 0; pending_upgrade = false; run_id = new_id()
	game.active_stage = stage
	game.start_run("campaign","campaign")
	enter_room()
func clear_arena() -> void:
	for enemy in game.enemies: enemy.queue_free()
	game.enemies.clear(); game.boss = null
	game.combat.shots.clear(); game.combat.hostile.clear(); game.pickups.clear()
func snapshot(phase := "combat") -> void:
	if game.mode != "campaign": return
	game.progress.checkpoint = {"stage":game.active_stage,"hard":hard,"room":room,"run_id":run_id,"risk":risk,"penalty":max_penalty,"phase":phase,"hp":game.hp,"upgrades":game.upgrades.duplicate(),"level":game.level,"xp":game.xp,"elapsed":game.elapsed,"score":game.score,"kills":game.kills,"best_combo":game.best_combo,"mission_coins":game.mission_coins,"missions":game.mission_claimed.duplicate(),"milestones":game.milestone_claimed.duplicate(),"run_tickets":game.run_tickets,"weapon":game.selected_weapon,"robot":game.selected_robot,"gear":game.progress.equipped.duplicate(),"pet":game.run_pet,"skill_uses":game.combat.skill_uses,"offered":game.offered_upgrades.duplicate(),"pet_heals":game.companions.heals,"pet_timer":game.companions.timer,"pet_barrier":game.companions.barrier_timer,"skill_cooldown":game.cooldown}
	game.save_profile()
func enter_room() -> void:
	clear_arena(); pending_upgrade = false
	game.state = "playing"; game.overlay.hide(); game.upgrade_shade.hide(); game.home_shell.hide_all(); game.reset_stick(); game.clear_skill_taps()
	game.campaign_room = room+1; game.boss_spawned = room == 4
	game.player = Balance.ARENA.get_center()+Vector2(0,120)
	game.player = ArenaGeometry.resolve_all(game.player,18,game.world_obstacles())
	game.player_actor.position = game.player; game.player_actor.reset_physics_interpolation()
	game.invulnerable = 1
	clock = 0; spawned = 0
	quota = (12+game.active_stage*4) if room == 0 else (5+game.active_stage*2) if room == 1 else 0
	game.combat.fire_clock = 0
	if room == 4:
		for attempt in range(8):
			game.spawn_enemy(3)
			if is_instance_valid(game.boss): break
		if is_instance_valid(game.boss):
			game.boss.hp *= 1.45 if hard else 1.0; game.boss.max_hp = game.boss.hp
		spawned = 1
	snapshot()
	if room in [2,3]: show_choice()
	else: game.notice("PHÒNG %d/5 • %s" % [room+1,ROOM_NAMES[room]])
func resume() -> bool:
	var cp: Dictionary = game.progress.checkpoint.duplicate(true)
	if not valid_checkpoint(cp): return false
	hard = bool(cp.hard); game.campaign_hard = hard; room = int(cp.room); run_id = str(cp.run_id); risk = float(cp.risk); max_penalty = int(cp.penalty)
	game.selected_robot = int(cp.robot); game.selected_weapon = int(cp.weapon)
	game.progress.equipped.assign(cp.gear); game.progress.pet = int(cp.pet)
	game.active_stage = int(cp.stage)
	game.start_run("campaign","campaign")
	game.max_hp = maxi(1,int(game.run_stats.hp)-max_penalty)
	game.hp = clampi(int(cp.hp),1,game.max_hp)
	game.upgrades.assign(cp.upgrades); game.level = int(cp.level); game.xp = int(cp.xp); game.elapsed = float(cp.elapsed); game.score = int(cp.score); game.kills = int(cp.kills); game.best_combo = int(cp.best_combo)
	game.mission_coins = int(cp.mission_coins); game.mission_claimed.assign(cp.missions); game.milestone_claimed.assign(cp.milestones); game.run_tickets = int(cp.run_tickets); game.combat.skill_uses = int(cp.skill_uses)
	game.companions.heals = int(cp.get("pet_heals",0)); game.companions.timer = float(cp.get("pet_timer",0)); game.companions.barrier_timer = float(cp.get("pet_barrier",0)); game.cooldown = float(cp.get("skill_cooldown",0))
	for i in range(3):
		if game.progress.receipts.has(run_id+":mission:"+str(i)):
			if not game.mission_claimed[i]: game.run_tickets += 1
			game.mission_claimed[i] = true
	game.mission_coins = game.mission_claimed.count(true)*15
	for i in range(2):
		if game.progress.receipts.has(run_id+":milestone:"+str(i)):
			if not game.milestone_claimed[i]: game.run_tickets += 1
			game.milestone_claimed[i] = true
	if cp.phase == "upgrade":
		clear_arena(); pending_upgrade = true; game.campaign_room = room+1
		game.show_upgrades(cp.offered)
		game.progress.checkpoint = cp
		game.save_profile()
	elif cp.phase == "xp_upgrade":
		enter_room()
		game.show_upgrades(cp.offered)
	else: enter_room()
	return true
func valid_checkpoint(cp: Dictionary) -> bool:
	for key in ["stage","room","run_id","risk","penalty","hard","phase","hp","upgrades","gear","robot","weapon","pet","level","xp","elapsed","score","kills","best_combo","mission_coins","missions","milestones","run_tickets","skill_uses","offered"]:
		if not cp.has(key): return false
	if int(cp.stage) not in range(5) or int(cp.room) not in range(5) or not cp.upgrades is Array or cp.upgrades.size() != Balance.UPGRADE_CAPS.size(): return false
	if int(cp.robot) not in game.owned_robots or int(cp.pet) not in game.progress.pets or int(cp.weapon) < -1 or int(cp.weapon) >= 12: return false
	if not cp.gear is Array or cp.gear.size() != 4 or not cp.missions is Array or cp.missions.size() != 3 or not cp.milestones is Array or cp.milestones.size() != 2: return false
	for i in range(4):
		if int(cp.gear[i]) != -1:
			var entry: Dictionary = game.progress.item(int(cp.gear[i]))
			if entry.is_empty() or int(entry.kind)%4 != i: return false
	for i in range(Balance.UPGRADE_CAPS.size()):
		if int(cp.upgrades[i]) < 0 or int(cp.upgrades[i]) > Balance.UPGRADE_CAPS[i]: return false
	return cp.phase in ["combat","upgrade","xp_upgrade"]
func advance(delta: float) -> bool:
	if room in [2,3]: return true
	if room == 4:
		if not is_instance_valid(game.boss) and not game.campaign_won:
			game.spawn_enemy(3)
			if is_instance_valid(game.boss) and hard: game.boss.hp *= 1.45; game.boss.max_hp = game.boss.hp
		return false
	clock -= delta
	if spawned < quota and clock <= 0 and game.enemies.size() < (5 if room == 1 else 8):
		clock = 2.4 if room == 1 else 2.8
		var pool: Array = game.Campaign.data(game.active_stage).pool
		for burst in range(2 if room == 1 else 3):
			if spawned >= quota or game.enemies.size() >= (5 if room == 1 else 8): break
			var before: int = game.enemies.size()
			game.spawn_enemy(int(pool[spawned%pool.size()]))
			if game.enemies.size() > before:
				spawned += 1
				var enemy = game.enemies[-1]
				enemy.hp *= (2.2 if room == 1 else 1.3)*(1.45 if hard else 1.0); enemy.max_hp = enemy.hp
	if spawned >= quota and game.enemies.is_empty():
		room_reward(); pending_upgrade = true
		game.level += 1
		game.show_upgrades()
		if game.state == "upgrade": snapshot("upgrade")
		else: after_upgrade()
		return true
	return false
func room_reward() -> void:
	if not game.progress.mark(run_id+":room:"+str(room)): return
	game.xp += game.pickups.size()
	game.pickups.clear()
	game.progress.materials += 4 if room == 1 else 2
	if room == 1 and game.progress.rng.randf() < 0.45:
		game.progress.add_item([1,0,2,0,2][game.active_stage]*4+game.progress.rng.randi_range(0,3),1)
	game.save_profile()
func capture_offer() -> void:
	if game.mode != "campaign" or pending_upgrade or game.progress.checkpoint.is_empty(): return
	var cp: Dictionary = game.progress.checkpoint.duplicate(true)
	cp["phase"] = "xp_upgrade"; cp["upgrades"] = game.upgrades.duplicate(); cp["level"] = game.level; cp["xp"] = game.xp; cp["offered"] = game.offered_upgrades.duplicate()
	game.progress.checkpoint = cp; game.save_profile()
func after_upgrade() -> void:
	if game.mode != "campaign": return
	if pending_upgrade:
		pending_upgrade = false; room += 1; enter_room()
	elif not game.progress.checkpoint.is_empty():
		game.progress.checkpoint["phase"] = "combat"
		game.progress.checkpoint["upgrades"] = game.upgrades.duplicate()
		game.progress.checkpoint["level"] = game.level; game.progress.checkpoint["xp"] = game.xp; game.progress.checkpoint["offered"] = []
		game.save_profile()
func show_choice() -> void:
	game.state = "room_choice"
	game.clear_cards("PHÒNG %d/5 • %s" % [room+1,ROOM_NAMES[room]],"Tiến trình được lưu ở đầu phòng. Đồ đã nhận luôn được giữ.")
	var strip = game.rpg_ui.room_strip(room)
	game.cards.move_child(strip,1)
	if game.progress.repair_kits > 0:
		var kit = game.add_button("DÙNG BỘ SƠ CỨU • HỒI 3 HP",use_kit)
		kit.disabled = game.hp >= game.max_hp
	if room == 2:
		game.add_button("HỒI 2 HP",choice.bind("heal"))
		game.add_button("CHỌN MỘT NÂNG CẤP",choice.bind("upgrade"))
	else:
		game.add_button("+20% SÁT THƯƠNG • -1 HP TỐI ĐA",choice.bind("risk"))
		game.add_button("HỒI 1 HP • AN TOÀN",choice.bind("safe"))
func choice(action: String) -> void:
	if game.state != "room_choice" or room not in [2,3]: return
	if action == "upgrade" and room == 2:
		pending_upgrade = true; game.level += 1; game.show_upgrades()
		if game.state == "upgrade": snapshot("upgrade")
		else: after_upgrade()
		return
	if action == "risk" and room == 3:
		risk = 0.2; max_penalty = 1; game.max_hp = maxi(1,int(game.run_stats.hp)-1); game.hp = mini(game.hp,game.max_hp)
	elif action in ["heal","safe"]: game.hp = mini(game.max_hp,game.hp+(2 if action == "heal" else 1))
	else: return
	room += 1; enter_room()
func finish() -> void:
	game.progress.checkpoint.clear()
	pending_upgrade = false
func sweep(stage: int, difficult: bool, count: int) -> Dictionary:
	if game.state not in ["menu","results"] or stage not in range(5) or count not in [1,5,10]: return {}
	var stars: int = game.progress.hard_stars[stage] if difficult else game.campaign_stars[stage]
	if not game.admin_enabled and (stars < 3 or game.progress.sweep_tickets < count): return {}
	if game.progress.items.size()+count > 500: return {}
	if not game.admin_enabled: game.progress.sweep_tickets -= count
	var summary := {"gold":0,"mats":0,"gear":[],"tickets":count,"cores":0,"kits":0}
	for i in range(count):
		var loot: Dictionary = game.progress.loot(stage,difficult)
		summary.gold += int(loot.gold); summary.mats += int(loot.mats); summary.gear.append_array(loot.gear); summary.cores += int(loot.get("cores",0)); summary.kits += int(loot.get("kits",0))
	game.coins += int(summary.gold); game.summon.tickets += count
	game.progress.last_loot = summary.duplicate(true)
	game.save_profile()
	return summary
func practice(group: int) -> void:
	practice_group = clampi(group,0,2); practice_clock = 0; practice_damage = 0
	game.start_run("practice","open")
	game.player = Balance.ARENA.get_center()+Vector2(0,150)
	game.player_actor.position = game.player
	clear_arena()
	for i in range(5 if group == 1 else 1):
		var enemy := ArenaEnemy.new()
		enemy.setup(3 if group == 2 else 2,1)
		enemy.position = Balance.ARENA.get_center()+Vector2((i-2)*65 if group == 1 else 0,-80)
		enemy.hp = 1000000; enemy.max_hp = enemy.hp; enemy.appearance = 1
		game.add_child(enemy); game.enemies.append(enemy)
	game.notice("THỬ ĐỒ • 10 GIÂY • KHÔNG TRẢ THƯỞNG")
func practice_tick(delta: float) -> void:
	practice_clock += delta
	if practice_clock < 10: return
	game.state = "practice_results"; game.reset_stick(); game.clear_skill_taps()
	game.clear_cards("KẾT QUẢ THỬ ĐỒ","10 giây • %.1f sát thương • DPS %.1f\nKhông tiêu thụ vé, không nhận vàng/XP/đồ.\nCác bia đứng yên để so sánh cùng điều kiện." % [practice_damage,practice_damage/10])
	game.add_button("THỬ LẠI CÙNG BỘ",practice.bind(practice_group))
	if game.admin_enabled: game.add_button("TEST MAX NÂNG CẤP",practice_max)
	game.add_button("ĐỔI TRANG BỊ",game.rpg_ui.hub)
	game.add_button("VỀ SẢNH",game.show_menu)
func practice_max() -> void:
	practice(practice_group)
	game.upgrades.assign(Balance.UPGRADE_CAPS)
	game.cooldown = 0

func use_kit() -> void:
	if game.state != "room_choice" or room not in [2,3] or game.progress.repair_kits <= 0 or game.hp >= game.max_hp: return
	game.progress.repair_kits -= 1
	game.hp = mini(game.max_hp,game.hp+3)
	snapshot()
	show_choice()
