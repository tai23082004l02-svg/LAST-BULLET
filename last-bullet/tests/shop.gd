extends SceneTree
var game: Node2D
const PROFILE := "user://shop-test.cfg"
func _initialize() -> void: call_deferred("run")
func buy(id: String, choice := 0) -> Dictionary:
	return game.shop.buy(game.shop.quote(id,choice))
func run() -> void:
	for p in [PROFILE,"user://shop-test-admin.cfg","user://shop-test-mode.cfg","user://shop-test-language.cfg"]: DirAccess.remove_absolute(p)
	game = load("res://scenes/Main.tscn").instantiate(); game.save_path = PROFILE; root.add_child(game); game.set_physics_process(false); game.audio.enabled = false
	game.show_shop(); var coins: int = game.coins; var mats: int = game.progress.materials
	var token: String = game.shop.quote("daily")
	assert(not game.shop.buy(token).has("error")); assert(game.coins == coins+20 and game.progress.materials == mats+5)
	assert(game.shop.buy(token).has("error") and buy("daily").has("error"))
	assert(buy("ticket").has("error")); assert(game.summon.tickets == 5)
	game.shop.pending = {}
	game.shop.quote("daily"); game.shop.pending.day = "2000-01-01"
	assert(game.shop.buy(game.shop.pending.token).has("error"))
	game.coins = 5000; game.summon.shards = 500
	var size: int = game.progress.items.size()
	var receipt: Dictionary = buy("starter",11)
	assert(not receipt.has("error") and game.progress.items.size() == size+1 and game.progress.items[-1].kind == 11 and game.progress.items[-1].rarity == 1)
	assert(game.coins == 5080 and game.summon.tickets == 8 and buy("starter").has("error"))
	assert(not buy("set0").has("error") and game.progress.items.size() == size+5)
	assert(not buy("gear2",2).has("error") and game.progress.items[-1].kind == 10)
	assert(not buy("pet1").has("error") and game.progress.pets.has(1)); assert(buy("pet1").has("error"))
	assert(not buy("theme1").has("error") and game.shop.themes.has(1) and game.owned_skins.has(1))
	assert(game.shop.theme == 0 and game.shop.equip_theme(1) and game.selected_skin == 1)
	game.start_run(); assert(game.player_actor.finish == 1)
	game.player_actor.active = true; game.player_actor.moving = 1
	for i in range(40): game.player_actor.position.x += 2; game.player_actor._process(0.05)
	assert(game.player_actor.trail.size() <= 12 and game.player_actor.trail.size() > 0)
	game.player_actor.reduced = true; game.player_actor._process(0.01); assert(game.player_actor.trail.is_empty())
	game.show_menu()
	var balance: int = game.coins
	token = game.shop.quote("ticket"); game.show_settings(); assert(game.shop.buy(token).has("error") and game.coins == balance)
	game.show_shop(); token = game.shop.quote("ticket"); game.show_menu(); assert(game.shop.buy(token).has("error") and game.coins == balance)
	game.show_shop(); token = game.shop.quote("ticket"); game.state = "playing"; assert(game.shop.buy(token).has("error")); game.show_menu()
	# Inventory cap is checked before charging/granting; even a four-piece bundle is atomic.
	var original: Array = game.progress.items.duplicate(true)
	while game.progress.items.size() < 499: game.progress.add_item(0)
	balance = game.coins; assert(buy("set1").has("error") and game.coins == balance and game.progress.items.size() == 499)
	game.progress.items.assign(original)
	assert(game.save_profile()); game.audio.shutdown(); game.queue_free(); await process_frame
	game = load("res://scenes/Main.tscn").instantiate(); game.save_path = PROFILE; root.add_child(game); game.set_physics_process(false); game.audio.enabled = false
	assert(game.shop.theme == 1 and buy("starter").has("error") and buy("daily").has("error"))
	game.show_menu(); game.switch_admin(true); game.show_shop(); balance = game.coins
	assert(not buy("ticket").has("error") and game.coins == balance)
	game.switch_admin(false); game.show_shop(); assert(game.shop.theme == 1 and game.shop.themes == [0,1])
	game.locale.set_language("en"); assert(TranslationServer.translate("CỬA HÀNG") == "SHOP")
	game.audio.shutdown(); game.queue_free(); await process_frame
	for p in [PROFILE,"user://shop-test-admin.cfg","user://shop-test-mode.cfg","user://shop-test-language.cfg"]: DirAccess.remove_absolute(p)
	print("PASS shop: grants/costs/choices, no double-claim, limits, capacity, stale/state guards, reload/admin isolation, cosmetics and EN")
	quit()
