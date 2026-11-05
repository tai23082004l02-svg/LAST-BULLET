extends SceneTree
var game: Node2D
const PROFILE := "user://polish-test.cfg"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for path in [PROFILE,"user://polish-test-language.cfg"]: DirAccess.remove_absolute(path)
	game = load("res://scenes/Main.tscn").instantiate(); game.save_path = PROFILE
	root.add_child(game); game.set_physics_process(false); game.audio.enabled = false
	assert(game.locale.language == "vi")
	assert(TranslationServer.translate("BACK") == "QUAY LẠI")
	game.locale.set_language("en")
	assert(TranslationServer.translate("KHO VŨ KHÍ") == "ARSENAL")
	assert(TranslationServer.translate("LÊN CẤP 5") == "LEVEL 5")
	game.progress.hero_cores = 100
	var gold: int = game.coins
	assert(game.progress.train_hero(0,0,false).is_empty())
	var receipt: Dictionary = game.progress.train_hero(0,100,false)
	assert(receipt.gold == 100 and game.progress.hero_levels[0] == 2 and game.progress.hero_cores == 98)
	assert(game.progress.stats(0).damage > 1 and game.progress.stats(1).damage == 1)
	game.progress.hero_levels[0] = 20
	assert(game.progress.train_hero(0,999999,true).is_empty())
	game.start_campaign(0)
	game.adventure.room = 2; game.adventure.enter_room(); game.hp = 1
	var count: int = game.progress.repair_kits
	game.adventure.use_kit()
	assert(game.hp == 4 and game.progress.repair_kits == count-1 and game.progress.checkpoint.hp == 4)
	game.show_menu(); count = game.progress.repair_kits; game.adventure.use_kit(); assert(game.progress.repair_kits == count)
	var art = load("res://scripts/item_art.gd")
	for group in ["weapon","gear","pet","skill","item"]:
		for i in range({"weapon":12,"gear":12,"pet":6,"skill":7,"item":4}[group]):
			var texture: Texture2D = art.texture(group,i)
			assert(texture != null and texture.get_width() == 256 and art.texture(group,i) == texture)
	for i in range(100): game.effects.damage_number(Vector2.ZERO,2.0)
	assert(game.effects.numbers.size() == 20)
	game.effects.advance(1.0); assert(game.effects.numbers.is_empty())
	game.effects.reduced = true; game.effects.damage_number(Vector2.ZERO,5.0); assert(game.effects.numbers.is_empty())
	game.effects.reduced = false
	var cores_before: int = game.progress.hero_cores
	var loot: Dictionary = game.progress.loot(0,true,true)
	assert(loot.cores == 4 and game.progress.hero_cores == cores_before+4)
	assert(loot.kits in [0,1])
	game.progress.repair_kits = 0
	game.save_profile(); game.audio.shutdown(); game.queue_free(); await process_frame
	game = load("res://scenes/Main.tscn").instantiate(); game.save_path = PROFILE
	root.add_child(game); game.set_physics_process(false); game.audio.enabled = false
	assert(game.locale.language == "en" and game.progress.hero_levels[0] == 20 and game.progress.repair_kits == 0)
	game.audio.shutdown(); game.queue_free(); await process_frame
	for path in [PROFILE,"user://polish-test-language.cfg"]: DirAccess.remove_absolute(path)
	print("PASS polish: bilingual templates/persistence, 41 cached vector assets, hero training guards/stats/save, repair kit usage/checkpoint")
	quit()
