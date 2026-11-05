extends SceneTree
const RPG = preload("res://scripts/progression.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var model = RPG.new()
	var config := ConfigFile.new()
	model.read(config,false,[])
	assert(model.items.size() == 4 and model.stats().hp == 5 and model.pets == [0])
	model.write(config)
	for entry in model.items.duplicate(): model.items.erase(entry)
	model.write(config); model.read(config,false,[])
	assert(model.items.is_empty()) # No repeat starter grant when bag is empty.
	var a: int = model.add_item(0,1); var b: int = model.add_item(0,1); var c: int = model.add_item(0,1)
	model.materials = 1000
	assert(model.upgrade(a,0,false).is_empty())
	var paid := 0
	for i in range(5): paid += int(model.upgrade(a,10000,false).gold)
	var other_paid := int(model.upgrade(b,10000,false).gold)
	model.equipped[0] = a
	model.item(b).locked = true
	assert(model.fusion_preview(a,[b,c]).is_empty())
	model.item(b).locked = false
	assert(model.fusion_preview(a,[b,b]).is_empty())
	model.presets[0] = {"gear":[b,-1,-1,-1],"pet":0,"weapon":-1}
	var preview: Dictionary = model.fusion_preview(a,[b,c])
	assert(preview.level == 5 and preview.rarity == 2 and preview.gold == other_paid)
	var refund: Dictionary = model.fuse(a,[b,c])
	assert(refund.gold == other_paid and model.item(a).level == 5 and model.item(a).rarity == 2)
	assert(model.equipped[0] == a and model.presets[0].gear[0] == a and model.item(b).is_empty())
	assert(model.fuse(a,[b,c]).is_empty())
	assert(model.dismantle(a).is_empty())
	model.equipped[0] = -1; model.item(a).locked = true
	assert(model.dismantle(a).is_empty())
	model.item(a).locked = false
	assert(model.dismantle(a).gold == paid)
	for i in range(4): model.equipped[i] = model.add_item(8+i,3)
	var stats: Dictionary = model.stats()
	assert(stats.sets[2] == 4 and stats.legend_fire and stats.burn > 0 and stats.damage > 1)
	model.write(config)
	model.read(config,false,[0,1])
	assert(model.pets.has(1) and model.pets.has(2) and model.stats().sets[2] == 4)
	assert(model.claim_daily("2026-11-05") and not model.claim_daily("2026-11-05") and model.sweep_tickets == 5)
	assert(model.mark("receipt") and not model.mark("receipt"))
	assert(model.discover("monster:1") and not model.discover("monster:1"))
	for i in range(1600): model.mark(str(i))
	assert(model.receipts.size() <= 1500)
	model.read(config,true,[])
	for kind in range(12):
		for rarity in range(4):
			var found := false
			for entry in model.items:
				if entry.kind == kind and entry.rarity == rarity: found = true
			assert(found)
	assert(model.pets.size() == 6)
	print("PASS RPG inventory: migration, no duplicate starter, costs, fusion validation/refund/protection/presets, dismantle, sets, admin, receipts/daily")
	quit()
