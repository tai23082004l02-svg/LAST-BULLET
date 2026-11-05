class_name RobotRoster
extends RefCounted
const SHEET: Texture2D = preload("res://art/neon/heroes.png")
const NAMES := ["AEGIS","VOLT","FROST","EMBER","NOVA","COBALT","SCOUT"]
const COSTS := [0,40,70,100,140,180,220] # Legacy coin prices; existing ownership is retained.
const COLORS := [Color("8bffe1"),Color("ffda67"),Color("c6f4ff"),Color("ffac6d"),Color("d3a4ff"),Color("83bdff"),Color("91e8e0")]
const NOTES := ["Mint armor • the original pilot","Electric yellow • angular armor","Ice silver • rounded armor","Molten orange • heavy armor","Violet • sharp silhouette","Cobalt blue • reinforced armor","Turquoise • single-eye explorer"]
const REGIONS := [Rect2(98,59,353,383),Rect2(586,60,364,383),Rect2(1060,64,412,383),Rect2(105,566,342,382),Rect2(588,567,362,382),Rect2(1099,584,336,364)]
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
