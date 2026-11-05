class_name SummonSystem
extends RefCounted

const TIERS := ["RARE","EPIC","LEGENDARY"]
const COLORS := [Color("73caff"),Color("cf9aff"),Color("ffd385")]
const POOLS := [[1,5,6],[2,3],[4]]
const SHARD_REWARDS := [5,15,50]
const EXCHANGE_COSTS := [0,30,90,90,300,30,30]
var tickets := 5
var shards := 0
var epic_pity := 0
var legendary_pity := 0
var total_pulls := 0
var last_results: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

func _init() -> void:
	rng.randomize()

func read(config: ConfigFile) -> void:
	tickets = maxi(0,int(config.get_value("summon","tickets",5)))
	shards = maxi(0,int(config.get_value("summon","shards",0)))
	epic_pity = clampi(int(config.get_value("summon","epic_pity",0)),0,9)
	legendary_pity = clampi(int(config.get_value("summon","legendary_pity",0)),0,49)
	total_pulls = maxi(0,int(config.get_value("summon","total",0)))
	last_results.clear()
	var stored: Variant = config.get_value("summon","last_results",[])
	if stored is Array:
		for item in stored.slice(0,10):
			if item is Dictionary and item.get("robot",-1) is int and item.get("tier",-1) is int and int(item.get("robot",-1)) in range(1,7) and int(item.get("tier",-1)) in range(3):
				last_results.append(item)

func write(config: ConfigFile) -> void:
	config.set_value("summon","tickets",tickets)
	config.set_value("summon","shards",shards)
	config.set_value("summon","epic_pity",epic_pity)
	config.set_value("summon","legendary_pity",legendary_pity)
	config.set_value("summon","total",total_pulls)
	config.set_value("summon","last_results",last_results)

func pull(count: int, owned: Array[int], free := false) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if count not in [1,10] or (not free and tickets < count): return results
	# Validate the whole request before spending. Each batch is saved by the owner
	# as one profile update BEFORE animation; skipping never awards or rerolls.
	if not free: tickets -= count
	for i in range(count):
		var roll := rng.randf()
		var tier := 2 if roll >= 0.95 else 1 if roll >= 0.75 else 0
		if legendary_pity >= 49: tier = 2
		elif epic_pity >= 9 and tier == 0: tier = 1
		var pool: Array = POOLS[tier]
		var robot: int = pool[rng.randi_range(0,pool.size()-1)]
		var duplicate := owned.has(robot)
		var reward: int = SHARD_REWARDS[tier] if duplicate else 0
		if duplicate: shards += reward
		else: owned.append(robot)
		epic_pity = 0 if tier > 0 else epic_pity+1
		legendary_pity = 0 if tier == 2 else legendary_pity+1
		total_pulls += 1
		results.append({"robot":robot,"tier":tier,"duplicate":duplicate,"shards":reward})
	last_results = results.duplicate(true)
	return results

func exchange(index: int, owned: Array[int], free := false) -> bool:
	if index <= 0 or index >= EXCHANGE_COSTS.size() or owned.has(index): return false
	if not free and shards < EXCHANGE_COSTS[index]: return false
	if not free: shards -= EXCHANGE_COSTS[index]
	owned.append(index)
	return true
