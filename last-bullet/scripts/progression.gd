extends RefCounted
# Persistent RPG inventory. All actions validate whole requests before mutations.
const SLOTS := ["GIÁP","LÕI","BỘ ĐẨY","CHIP"]
const SETS := ["BĂNG HÀ","THÀNH TRÌ","HỎA NGỤC"]
const RARITIES := ["THƯỜNG","HIẾM","SỬ THI","HUYỀN THOẠI"]
const COLORS := [Color("9caeb9"),Color("69bdff"),Color("d495ff"),Color("ffd077")]
const PETS := ["BEE","MAGNET","MEDIC","BULWARK","FROSTLING","BOMBER"]
const PET_INFO := ["Bắn hỗ trợ mỗi 1 giây.","Hút XP từ xa, gom vật phẩm mỗi 6 giây.","Hồi 1 HP mỗi 22 giây, tối đa 3 lần/trận.","Chặn một phát đánh, hồi sau 16 giây.","Làm chậm nhóm địch mỗi 8 giây.","Ném bom vào chỗ đông địch mỗi 7 giây."]
var items: Array[Dictionary] = []
var equipped: Array[int] = [-1,-1,-1,-1]
var pets: Array[int] = [0]
var pet := 0
var hero_levels: Array[int] = [1,1,1,1,1,1,1]
var hero_cores := 0
var repair_kits := 2
var materials := 30
var sweep_tickets := 0
var daily_day := ""
var next_id := 1
var presets: Array[Dictionary] = [{},{},{}]
var seen: Array[String] = []
var hard_stars: Array[int] = [0,0,0,0,0]
var checkpoint: Dictionary = {}
var receipts: Dictionary = {}
var receipt_order: Array[String] = []
var last_loot: Dictionary = {}
var rng := RandomNumberGenerator.new()
func _init() -> void: rng.randomize()
static func item_name(kind: int) -> String: return SLOTS[kind%4]+" "+SETS[kind/4]
func item(uid: int) -> Dictionary:
	for entry in items:
		if entry.id == uid: return entry
	return {}
func add_item(kind: int, rarity := 0) -> int:
	if items.size() >= 500 or kind not in range(12) or rarity not in range(4): return -1
	var uid := next_id
	next_id += 1
	items.append({"id":uid,"kind":kind,"rarity":rarity,"level":0,"locked":false,"gold":0,"mats":0})
	return uid
func read(config: ConfigFile, admin: bool, cleared: Array[int]) -> void:
	items.clear(); equipped = [-1,-1,-1,-1]; pets = [0]; presets = [{},{},{}]; seen.clear()
	next_id = 1
	var data: Variant = config.get_value("rpg","inventory",[])
	if data is Array:
		for entry in data.slice(0,500):
			if not entry is Dictionary: continue
			var uid := int(entry.get("id",-1)); var kind := int(entry.get("kind",-1)); var rarity := int(entry.get("rarity",-1))
			if uid <= 0 or not item(uid).is_empty() or kind not in range(12) or rarity not in range(4): continue
			items.append({"id":uid,"kind":kind,"rarity":rarity,"level":clampi(int(entry.get("level",0)),0,10),"locked":bool(entry.get("locked",false)),"gold":maxi(0,int(entry.get("gold",0))),"mats":maxi(0,int(entry.get("mats",0)))})
			next_id = maxi(next_id,uid+1)
	# Starter items are granted once by schema, never whenever the bag happens to be empty.
	if not config.has_section_key("rpg","schema"):
		for slot in range(4): add_item(4+slot)
	var slots: Variant = config.get_value("rpg","equipped",equipped)
	if slots is Array:
		for slot in range(mini(4,slots.size())):
			var entry := item(int(slots[slot]))
			equipped[slot] = int(entry.id) if not entry.is_empty() and int(entry.kind)%4 == slot else -1
	var saved_pets: Variant = config.get_value("rpg","pets",[0])
	if saved_pets is Array:
		for id in saved_pets:
			if id is int and id in range(6) and not pets.has(id): pets.append(id)
	for stage in cleared:
		if not pets.has(stage+1): pets.append(stage+1)
	pet = int(config.get_value("rpg","pet",0))
	if not pets.has(pet): pet = 0
	hero_levels = [1,1,1,1,1,1,1]
	var saved_levels: Variant = config.get_value("rpg","hero_levels",[])
	if saved_levels is Array:
		for i in range(mini(7,saved_levels.size())): hero_levels[i] = clampi(int(saved_levels[i]),1,20)
	hero_cores = maxi(0,int(config.get_value("rpg","hero_cores",0)))
	repair_kits = maxi(0,int(config.get_value("rpg","repair_kits",2)))
	materials = maxi(0,int(config.get_value("rpg","materials",30)))
	sweep_tickets = maxi(0,int(config.get_value("rpg","sweep_tickets",0)))
	daily_day = str(config.get_value("rpg","daily_day",""))
	var stored: Variant = config.get_value("rpg","presets",[])
	if stored is Array:
		for i in range(mini(3,stored.size())):
			if stored[i] is Dictionary and stored[i].get("gear") is Array and stored[i].gear.size() == 4:
				presets[i] = stored[i].duplicate(true)
	stored = config.get_value("rpg","seen",[])
	if stored is Array:
		for key in stored:
			if key is String and not seen.has(key): seen.append(key)
	for stage in cleared:
		if not seen.has("boss:"+str(stage)): seen.append("boss:"+str(stage))
	stored = config.get_value("rpg","hard_stars",[])
	hard_stars = [0,0,0,0,0]
	if stored is Array:
		for i in range(mini(5,stored.size())): hard_stars[i] = clampi(int(stored[i]),0,3)
	stored = config.get_value("rpg","checkpoint",{})
	checkpoint = stored.duplicate(true) if stored is Dictionary else {}
	stored = config.get_value("rpg","receipts",{})
	receipts = stored.duplicate(true) if stored is Dictionary else {}
	receipt_order.clear()
	for key in receipts: receipt_order.append(str(key))
	stored = config.get_value("rpg","last_loot",{})
	last_loot = stored.duplicate(true) if stored is Dictionary else {}
	if admin:
		pets = [0,1,2,3,4,5]
		materials = maxi(materials,99999)
		hero_cores = maxi(hero_cores,99999)
		repair_kits = maxi(repair_kits,99)
		for kind in range(12):
			for rarity in range(4):
				var found := false
				for entry in items:
					if entry.kind == kind and entry.rarity == rarity: found = true
				if not found: add_item(kind,rarity)

func write(config: ConfigFile) -> void:
	for pair in [["schema",1],["hero_levels",hero_levels],["hero_cores",hero_cores],["repair_kits",repair_kits],["inventory",items],["equipped",equipped],["pets",pets],["pet",pet],["materials",materials],["sweep_tickets",sweep_tickets],["daily_day",daily_day],["presets",presets],["seen",seen],["hard_stars",hard_stars],["checkpoint",checkpoint],["receipts",receipts],["last_loot",last_loot]]:
		var value: Variant = pair[1]
		config.set_value("rpg",pair[0],value.duplicate(true) if value is Array or value is Dictionary else value)
func mark(key: String) -> bool:
	if receipts.has(key): return false
	receipts[key] = true; receipt_order.append(key)
	# Keep current run receipts and a bounded recent history.
	var scans := 0
	while receipt_order.size() > 1500 and scans < receipts.size():
		var old: String = receipt_order.pop_front()
		if not checkpoint.is_empty() and old.begins_with(str(checkpoint.get("run_id","!"))+":"):
			receipt_order.append(old); scans += 1
		else: receipts.erase(old)
	return true
func discover(key: String) -> bool:
	if seen.has(key): return false
	seen.append(key); return true
func stats(hero := 0) -> Dictionary:
	var result := {"hp":5,"damage":1.0,"speed":1.0,"crit":0.0,"cooldown":1.0,"cold":0.0,"burn":0.0,"barrier":false,"legend_shield":false,"legend_cold":false,"legend_fire":false,"sets":[0,0,0]}
	for uid in equipped:
		var entry := item(uid)
		if entry.is_empty(): continue
		var r: int = entry.rarity; var lv: int = entry.level; var slot: int = int(entry.kind)%4; var family: int = int(entry.kind)/4
		result.sets[family] += 1
		match slot:
			0: result.hp += 1+r+lv/5
			1: result.damage += 0.03*(r+1)+0.004*lv
			2: result.speed += 0.03*(r+1)+0.004*lv
			3: result.crit += 0.02*(r+1)+0.003*lv
		if r >= 1: result.cooldown -= 0.01*(r+1)
		if r >= 2:
			if family == 0: result.cold += 0.15
			if family == 1: result.barrier = true
			if family == 2: result.burn += 0.15
		if r == 3:
			if family == 0: result.legend_cold = true
			elif family == 1: result.legend_shield = true
			else: result.legend_fire = true
	if result.sets[0] >= 2: result.cold += 0.4
	if result.sets[0] >= 4: result.damage += 0.1
	if result.sets[1] >= 2: result.hp += 1
	if result.sets[1] >= 4: result.barrier = true
	if result.sets[2] >= 2: result.damage += 0.08
	if result.sets[2] >= 4: result.burn += 0.5
	result.hp += hero_levels[hero]/5
	result.damage *= 1+0.02*(hero_levels[hero]-1)
	result.cooldown = maxf(0.65,result.cooldown)
	return result
func upgrade(uid: int, gold: int, admin: bool) -> Dictionary:
	var entry := item(uid)
	if entry.is_empty() or entry.level >= 10: return {}
	var cost: int = 20*(int(entry.level)+1)*(int(entry.rarity)+1); var mats: int = 2*(int(entry.level)+1)
	if not admin and (gold < cost or materials < mats): return {}
	entry.level += 1
	if not admin:
		entry.gold += cost; entry.mats += mats; materials -= mats
	return {"gold":0 if admin else cost}
func fusion_candidates(uid: int) -> Array[int]:
	var base := item(uid); var result: Array[int] = []
	if base.is_empty() or base.rarity >= 3: return result
	var choices: Array[Dictionary] = []
	for entry in items:
		if entry.id != uid and entry.kind == base.kind and entry.rarity == base.rarity and not entry.locked and not equipped.has(entry.id): choices.append(entry)
	choices.sort_custom(func(a,b): return a.level < b.level if a.level != b.level else a.id < b.id)
	for entry in choices.slice(0,2): result.append(entry.id)
	return result
func fusion_preview(uid: int, ingredients: Array[int]) -> Dictionary:
	var base := item(uid)
	if base.is_empty() or base.rarity >= 3 or ingredients.size() != 2 or ingredients[0] == ingredients[1] or ingredients.has(uid): return {}
	var group: Array[Dictionary] = [base]
	for id in ingredients:
		var entry := item(id)
		if entry.is_empty() or entry.kind != base.kind or entry.rarity != base.rarity or entry.locked or equipped.has(id): return {}
		group.append(entry)
	var strongest := group[0]
	var paid_gold := 0; var paid_mats := 0
	for entry in group:
		paid_gold += int(entry.gold); paid_mats += int(entry.mats)
		if entry.level > strongest.level: strongest = entry
	return {"level":strongest.level,"rarity":int(base.rarity)+1,"gold":paid_gold-int(strongest.gold),"mats":paid_mats-int(strongest.mats),"kept_gold":strongest.gold,"kept_mats":strongest.mats}
func fuse(uid: int, ingredients: Array[int]) -> Dictionary:
	var preview := fusion_preview(uid,ingredients)
	if preview.is_empty(): return {}
	var base := item(uid)
	base.level = preview.level; base.rarity = preview.rarity; base.gold = preview.kept_gold; base.mats = preview.kept_mats
	for id in ingredients: items.erase(item(id))
	for preset in presets:
		if preset.get("gear") is Array:
			for i in range(4):
				if ingredients.has(int(preset.gear[i])): preset.gear[i] = uid
	materials += int(preview.mats)
	return preview
func dismantle(uid: int) -> Dictionary:
	var entry := item(uid)
	if entry.is_empty() or entry.locked or equipped.has(uid): return {}
	var result := {"gold":entry.gold,"mats":int(entry.mats)+4*(int(entry.rarity)+1)}
	materials += int(result.mats)
	items.erase(entry)
	for preset in presets:
		if preset.get("gear") is Array:
			for i in range(4):
				if int(preset.gear[i]) == uid: preset.gear[i] = -1
	return result
func loot(stage: int, hard: bool, force := false) -> Dictionary:
	var result := {"gold":int((40+stage*20)*(1.5 if hard else 1.0)),"mats":int((8+stage*2)*(1.5 if hard else 1.0)),"gear":[],"cores":(2 if hard else 1)+(2 if force else 0),"kits":1 if rng.randf() < 0.25 else 0}
	if force or rng.randf() < (0.55 if hard else 0.35):
		var family: int = [1,0,2,0,2][stage] if stage < 4 else rng.randi_range(0,2)
		var roll := rng.randf()
		var rarity := 2 if force or roll >= (0.92 if hard else 0.98) else 1 if roll >= (0.65 if hard else 0.8) else 0
		var id := add_item(family*4+rng.randi_range(0,3),rarity)
		if id >= 0: result.gear.append(id)
		else: result.mats += 8
	materials += int(result.mats)
	hero_cores += int(result.cores); repair_kits += int(result.kits)
	last_loot = result.duplicate(true)
	return result
func claim_daily(day: String) -> bool:
	if daily_day == day: return false
	daily_day = day; sweep_tickets += 5
	return true

func train_hero(index: int, gold: int, admin: bool) -> Dictionary:
	if index not in range(7) or hero_levels[index] >= 20: return {}
	var cost: int = hero_levels[index]*100; var cores: int = 2+hero_levels[index]/3
	if not admin and (gold < cost or hero_cores < cores): return {}
	hero_levels[index] += 1
	if not admin: hero_cores -= cores
	return {"gold":0 if admin else cost}
