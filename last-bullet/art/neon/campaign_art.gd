class_name CampaignArt
extends RefCounted
const SHEET: Texture2D = preload("res://art/neon/campaign.png")
const REGIONS := [Rect2(39,59,441,376),Rect2(539,78,458,350),Rect2(1043,58,473,378),Rect2(38,562,442,390),Rect2(528,522,479,453),Rect2(1111,548,337,418)]
static var textures: Array[AtlasTexture] = []
static func texture(index: int) -> AtlasTexture:
	if textures.is_empty():
		for region in REGIONS:
			var tex := AtlasTexture.new()
			tex.atlas = SHEET
			tex.region = region
			tex.filter_clip = true
			textures.append(tex)
	return textures[clampi(index,0,5)]
static func boss(canvas: CanvasItem, index: int, width: float, clock: float, lean: float, flash: float, appear: float) -> void:
	var tex := texture(index)
	var height := width*tex.get_height()/tex.get_width()
	canvas.draw_set_transform(Vector2(0,width*0.3),0,Vector2(1,0.35))
	canvas.draw_circle(Vector2.ZERO,width*0.42,Color(0.005,0.01,0.025,0.65))
	canvas.draw_set_transform(Vector2(0,sin(clock*3)*1.2),lean,Vector2.ONE*appear)
	canvas.draw_texture_rect(tex,Rect2(-width*0.5,-height*0.5,width,height),false,Color(1+flash*9,1+flash*9,1+flash*9,1))
	canvas.draw_set_transform(Vector2.ZERO)
