extends SceneTree
class FailingGame extends "res://scripts/game.gd":
	var fail_saves := false
	func save_profile() -> bool:
		return false if fail_saves else super.save_profile()
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game := FailingGame.new(); game.save_path = "user://shop-rollback.cfg"; root.add_child(game); game.set_physics_process(false); game.audio.enabled = false
	game.coins = 1000; game.summon.shards = 500; game.show_shop(); game.fail_saves = true
	var count: int = game.progress.items.size()
	assert(game.shop.buy(game.shop.quote("starter",7)).has("error")); assert(game.coins == 1000 and game.summon.tickets == 5 and game.progress.items.size() == count and game.shop.counts.is_empty() and game.shop.history.is_empty())
	assert(game.shop.buy(game.shop.quote("theme2")).has("error")); assert(game.shop.themes == [0] and game.summon.shards == 500 and game.owned_skins == [0])
	game.fail_saves = false; assert(not game.shop.buy(game.shop.quote("starter",7)).has("error"))
	game.audio.shutdown(); game.queue_free(); await process_frame
	DirAccess.remove_absolute("user://shop-rollback.cfg")
	print("PASS shop_rollback: failed saves restore currencies, inventory, cosmetics, limits and receipts; retry succeeds")
	quit()
