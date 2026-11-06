extends Node
# Local-currency shop; synchronous validated transactions, persisted limits and receipts.
var game: Node2D
var counts: Dictionary = {}
var themes: Array[int] = [0]
var theme := 0
var history: Array = []
var pending: Dictionary = {}
var serial := 0
const THEME_NAMES := ["NGUYÊN BẢN","NGỌC BÍCH","BĂNG TINH","TỬ TINH"]
const THEME_COLORS := [Color.WHITE,Color("96ffd5"),Color("a5dfff"),Color("dab2ff")]
func catalog() -> Array[Dictionary]:
	var offers: Array[Dictionary] = [
		{"id":"daily","name":"QUÀ MỖI NGÀY","tab":0,"price":0,"currency":"gold","limit":1,"daily":true,"reward":{"gold":20,"materials":5,"sweep":1},"art":"item","index":3},
		{"id":"starter","name":"GÓI TÂN THỦ","tab":0,"price":120,"currency":"gold","limit":1,"reward":{"gold":200,"tickets":3,"materials":30},"gear":true,"art":"gear","index":4},
		{"id":"ticket","name":"VÉ TRIỆU HỒI","tab":1,"price":200,"currency":"gold","reward":{"tickets":1},"art":"item","index":3},
		{"id":"sweep","name":"5 VÉ CÀN QUÉT","tab":1,"price":150,"currency":"gold","reward":{"sweep":5},"art":"item","index":3},
		{"id":"repair","name":"3 BỘ SƠ CỨU","tab":1,"price":90,"currency":"gold","reward":{"kits":3},"art":"item","index":0},
		{"id":"material","name":"10 VẬT LIỆU","tab":1,"price":60,"currency":"gold","reward":{"materials":10},"art":"item","index":2},
		{"id":"core","name":"3 LÕI HERO","tab":1,"price":120,"currency":"gold","reward":{"cores":3},"art":"item","index":1},
		{"id":"hero_pack","name":"GÓI NÂNG HERO","tab":2,"price":300,"currency":"gold","limit":1,"reward":{"gold":100,"cores":8,"materials":20},"art":"item","index":1},
		{"id":"adventure","name":"GÓI THÁM HIỂM","tab":2,"price":250,"currency":"gold","limit":1,"daily":true,"reward":{"sweep":8,"kits":3,"materials":20},"art":"skill","index":5}
	]
	for family in range(3):
		offers.append({"id":"set"+str(family),"name":"GÓI "+game.Progress.SETS[family],"tab":2,"price":600,"currency":"gold","limit":1,"reward":{},"set":family,"art":"gear","index":family*4})
		offers.append({"id":"gear"+str(family),"name":"ĐỔI ĐỒ "+game.Progress.SETS[family],"tab":3,"price":20,"currency":"shards","limit":3,"daily":true,"reward":{},"family":family,"art":"gear","index":family*4})
	for pet in range(1,6): offers.append({"id":"pet"+str(pet),"name":game.Progress.PETS[pet],"tab":3,"price":40 if pet == 1 else 90 if pet in [2,3] else 140,"currency":"shards","reward":{},"pet":pet,"art":"pet","index":pet})
	for i in range(1,4): offers.append({"id":"theme"+str(i),"name":"BỘ "+THEME_NAMES[i],"tab":4,"price":50,"currency":"shards","reward":{},"theme":i,"art":"weapon","index":[0,0,2,4][i]})
	return offers
func offer(id: String) -> Dictionary:
	for entry in catalog():
		if entry.id == id: return entry
	return {}
func read(config: ConfigFile, admin: bool) -> void:
	var value: Variant = config.get_value("shop","counts",{})
	counts = {}
	if value is Dictionary:
		for key in value:
			if key is String and value[key] is int: counts[key] = maxi(0,value[key])
	value = config.get_value("shop","themes",[0]); themes = [0]
	if value is Array:
		for i in value:
			if i is int and i in range(1,4) and not themes.has(i): themes.append(i)
	if admin: themes = [0,1,2,3]
	theme = int(config.get_value("shop","theme",0)); theme = theme if themes.has(theme) else 0
	value = config.get_value("shop","history",[]); history = []
	if value is Array:
		for receipt in value.slice(-20):
			if receipt is Dictionary: history.append(receipt.duplicate(true))
	pending.clear()
func write(config: ConfigFile) -> void:
	for pair in [["counts",counts],["themes",themes],["theme",theme],["history",history]]: config.set_value("shop",pair[0],pair[1].duplicate(true) if pair[1] is Array or pair[1] is Dictionary else pair[1])
func count_key(entry: Dictionary) -> String:
	return entry.id+("@"+Time.get_date_string_from_system(true) if entry.get("daily",false) else "")
func remaining(entry: Dictionary) -> int:
	return maxi(0,int(entry.get("limit",999999))-int(counts.get(count_key(entry),0)))
func owned(entry: Dictionary) -> bool:
	return (entry.has("pet") and game.progress.pets.has(entry.pet)) or (entry.has("theme") and themes.has(entry.theme))
func quote(id: String, choice := 0) -> String:
	var entry := offer(id)
	if entry.is_empty() or choice not in range(12): return ""
	serial += 1
	var token := str(Time.get_unix_time_from_system())+":"+str(serial)
	pending = {"token":token,"id":id,"choice":choice,"profile":game.save_path,"revision":game.ui_revision,"day":Time.get_date_string_from_system(true)}
	return token
func buy(token: String) -> Dictionary:
	if pending.is_empty() or token != pending.token or game.state != "menu" or game.save_path != pending.profile or game.ui_revision != pending.revision: return {"error":"GIAO DỊCH ĐÃ HẾT HIỆU LỰC"}
	var request := pending.duplicate(true); pending.clear()
	var entry := offer(request.id)
	if request.day != Time.get_date_string_from_system(true): return {"error":"NGÀY ĐÃ THAY ĐỔI • MỞ LẠI SHOP"}
	if entry.is_empty() or owned(entry) or (not game.admin_enabled and remaining(entry) <= 0): return {"error":"ĐÃ NHẬN HOẶC HẾT LƯỢT"}
	var price: int = 0 if game.admin_enabled else entry.price
	if (game.coins if entry.currency == "gold" else game.summon.shards) < price: return {"error":"KHÔNG ĐỦ TÀI NGUYÊN"}
	var gear_count := 4 if entry.has("set") else 1 if entry.get("gear",false) or entry.has("family") else 0
	if game.progress.items.size()+gear_count > 500: return {"error":"TÚI ĐỒ ĐÃ ĐẦY"}
	var snapshot := ConfigFile.new(); game.progress.write(snapshot); write(snapshot)
	var old_gold: int = game.coins; var old_tickets: int = game.summon.tickets; var old_shards: int = game.summon.shards
	var old_skins: Array = game.owned_skins.duplicate()
	if entry.currency == "gold": game.coins -= price
	else: game.summon.shards -= price
	var rewards: Dictionary = entry.reward.duplicate(true)
	game.coins += int(rewards.get("gold",0)); game.summon.tickets += int(rewards.get("tickets",0))
	game.progress.materials += int(rewards.get("materials",0)); game.progress.hero_cores += int(rewards.get("cores",0))
	game.progress.repair_kits += int(rewards.get("kits",0)); game.progress.sweep_tickets += int(rewards.get("sweep",0))
	var gear: Array[int] = []
	if entry.has("set"):
		for slot in range(4): gear.append(int(entry.set)*4+slot)
	elif entry.get("gear",false): gear.append(int(request.choice))
	elif entry.has("family"): gear.append(int(entry.family)*4+int(request.choice)%4)
	for kind in gear: game.progress.add_item(kind,1)
	if entry.has("pet"): game.progress.pets.append(int(entry.pet))
	if entry.has("theme"):
		themes.append(int(entry.theme))
		var skin: int = entry.theme
		if not game.owned_skins.has(skin): game.owned_skins.append(skin)
	counts[count_key(entry)] = int(counts.get(count_key(entry),0))+1
	# Retain one-time limits; old UTC-day counts need not accumulate forever.
	for key in counts.keys():
		if str(key).contains("@") and not str(key).ends_with(request.day): counts.erase(key)
	var receipt := {"id":token,"offer":entry.id,"name":entry.name,"price":price,"currency":entry.currency,"rewards":rewards,"gear":gear,"pet":entry.get("pet",-1),"theme":entry.get("theme",-1),"time":Time.get_datetime_string_from_system(true)}
	history.append(receipt); history = history.slice(-20)
	if not game.save_profile():
		game.coins = old_gold; game.summon.tickets = old_tickets; game.summon.shards = old_shards; game.owned_skins.assign(old_skins)
		var cleared: Array[int] = []
		game.progress.read(snapshot,false,cleared); read(snapshot,false)
		return {"error":"KHÔNG LƯU ĐƯỢC • CHƯA TRỪ TÀI NGUYÊN"}
	return receipt
func equip_theme(index: int) -> bool:
	if game.state != "menu" or not themes.has(index): return false
	var previous := theme; var skin: int = game.selected_skin
	theme = index
	if game.owned_skins.has(index): game.selected_skin = index
	if not game.save_profile(): theme = previous; game.selected_skin = skin; return false
	return true
