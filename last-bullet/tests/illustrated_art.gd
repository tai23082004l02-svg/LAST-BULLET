extends SceneTree
const Art = preload("res://scripts/item_art.gd")
func _initialize() -> void:
	for group in ["weapon","pet"]:
		var fingerprints: Dictionary = {}
		for index in range(12 if group == "weapon" else 6):
			var texture: Texture2D = Art.texture(group,index)
			assert(texture != null and texture == Art.texture(group,index))
			var image := texture.get_image()
			assert(image.get_size() == Vector2i(256,256) and image.has_mipmaps())
			for corner in [Vector2i(0,0),Vector2i(255,0),Vector2i(0,255),Vector2i(255,255)]: assert(image.get_pixelv(corner).a == 0)
			var used := image.get_used_rect()
			assert(used.size.x >= 80 and used.size.y >= 80 and used.size.x <= 234 and used.size.y <= 234)
			var fingerprint := image.get_data().hex_encode().sha256_text()
			assert(not fingerprints.has(fingerprint)); fingerprints[fingerprint] = true
	assert(Art.sheets.size() == 2 and Art.cache.size() == 18)
	print("PASS illustrated_art: 18 unique, transparent, fitted, mipmapped sprites; two shared atlases and stable cache")
	quit()
