class_name NeonArt
extends RefCounted

const SHEET: Texture2D = preload("res://art/neon/robots.png")
const FLOOR: Texture2D = preload("res://art/neon/arena.png")
# Atlas regions select the opaque artwork with a small transparent gutter.
const REGIONS := [Rect2(59,64,327,311),Rect2(524,73,282,303),Rect2(922,96,371,280),Rect2(1384,64,338,312),Rect2(38,516,369,281),Rect2(511,509,308,303),Rect2(894,470,428,360),Rect2(1409,509,288,298)]
static var textures: Array[AtlasTexture] = []

static func texture(index: int) -> AtlasTexture:
	if textures.is_empty():
		for region in REGIONS:
			var part := AtlasTexture.new()
			part.atlas = SHEET
			part.region = region
			part.filter_clip = true
			textures.append(part)
	return textures[clampi(index,0,7)]

static func robot(canvas: CanvasItem, index: int, center: Vector2, width: float, clock: float, lean := 0.0, flash := 0.0, appear := 1.0) -> void:
	var tex := texture(index)
	var height := width*tex.get_height()/tex.get_width()
	var bob := sin(clock*5.0+index)*1.2 if index != 3 else sin(clock*13)*0.5
	canvas.draw_set_transform(center+Vector2(0,width*0.29),0,Vector2(1,0.35))
	canvas.draw_circle(Vector2.ZERO,width*0.43,Color(0.005,0.01,0.025,0.65))
	canvas.draw_set_transform(center+Vector2(0,bob),lean,Vector2.ONE*appear)
	canvas.draw_texture_rect(tex,Rect2(-width*0.5,-height*0.5,width,height),false,Color(1+flash*9,1+flash*9,1+flash*9,1))
	canvas.draw_set_transform(Vector2.ZERO)

static func glow(canvas: CanvasItem, point: Vector2, radius: float, color: Color) -> void:
	for i in range(3,0,-1):
		canvas.draw_circle(point,radius*(1+float(i)*0.45),Color(color,0.035*float(4-i)))
	canvas.draw_circle(point,radius,Color(color,0.35))

static func panel(color: Color, border: Color, radius := 16, width := 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0,0.02,0.04,0.45)
	style.shadow_size = 8
	style.content_margin_left = 16
	style.content_margin_right = 16
	return style

static func style_button(button: Button, accent := Color("67eedc"), primary := false) -> void:
	button.add_theme_stylebox_override("normal",panel(Color("163047") if not primary else Color("164c50"),Color(accent,0.6),14,2))
	button.add_theme_stylebox_override("hover",panel(Color("245367"),accent,14,2))
	button.add_theme_stylebox_override("pressed",panel(Color("0d292f"),Color.WHITE,14,3))
	button.add_theme_stylebox_override("disabled",panel(Color("101f31"),Color("294357"),14))
	button.add_theme_color_override("font_color",Color("d9fbff"))
	button.add_theme_color_override("font_hover_color",Color.WHITE)
	button.add_theme_color_override("font_pressed_color",Color("78ffe4"))
	button.add_theme_color_override("font_disabled_color",Color("7b98aa"))
	button.add_theme_color_override("font_outline_color",Color("071521"))
	button.add_theme_constant_override("outline_size",3)

static func diamond(canvas: CanvasItem, point: Vector2, size: float, color: Color) -> void:
	canvas.draw_colored_polygon(PackedVector2Array([point+Vector2(0,-size),point+Vector2(size*0.65,0),point+Vector2(0,size),point+Vector2(-size*0.65,0)]),color)
	canvas.draw_line(point+Vector2(0,-size*0.6),point+Vector2(-size*0.35,0),Color.WHITE,1)

static func icon(index: int, point: Vector2, canvas: CanvasItem) -> void:
	var color := Color("7aeee4")
	glow(canvas,point,12,color)
	match index:
		0: # heavy impact
			canvas.draw_circle(point,9,color)
			canvas.draw_arc(point,15,0,TAU,20,color,2)
		1: # speed
			for i in range(3):
				var x := point.x-11+i*9
				canvas.draw_polyline(PackedVector2Array([Vector2(x-5,point.y-10),Vector2(x+4,point.y),Vector2(x-5,point.y+10)]),color,3)
		2: # magnet
			canvas.draw_arc(point,12,0,PI,16,color,4)
			canvas.draw_line(point+Vector2(-12,0),point+Vector2(-12,-12),color,4)
			canvas.draw_line(point+Vector2(12,0),point+Vector2(12,-12),color,4)
		3:
			canvas.draw_arc(point,15,0,TAU,24,color,2)
			canvas.draw_line(point,point+Vector2(0,-10),color,3)
			canvas.draw_line(point,point+Vector2(8,4),color,3)
		4:
			canvas.draw_colored_polygon(PackedVector2Array([point+Vector2(-10,10),point+Vector2(-6,-5),point+Vector2(0,0),point+Vector2(6,-16),point+Vector2(12,8),point+Vector2(0,14)]),Color("ffc279"))
		5:
			canvas.draw_line(point-Vector2(18,0),point+Vector2(18,0),color,3)
			canvas.draw_line(point+Vector2(5,-12),point+Vector2(5,12),Color("ffd389"),4)
		6:
			canvas.draw_polyline(PackedVector2Array([point+Vector2(-15,10),point+Vector2(0,-12),point+Vector2(15,10)]),color,3)
			canvas.draw_line(point+Vector2(-20,-16),point+Vector2(20,-16),Color("ffd389"),3)
		_:
			canvas.draw_arc(point,16,0,TAU,32,color,3)
			canvas.draw_circle(point,4,Color.WHITE)

static func title_font() -> FontVariation:
	var font := FontVariation.new()
	font.base_font = ThemeDB.fallback_font
	font.variation_embolden = 0.8
	font.variation_transform = Transform2D(Vector2(1,0),Vector2(-0.16,1),Vector2.ZERO)
	return font

static func heart(canvas: CanvasItem, point: Vector2, filled: bool) -> void:
	var color := Color("8bffe1") if filled else Color("25404f")
	canvas.draw_circle(point+Vector2(-3,-2),4,color)
	canvas.draw_circle(point+Vector2(3,-2),4,color)
	canvas.draw_colored_polygon(PackedVector2Array([point+Vector2(-7,-1),point+Vector2(0,8),point+Vector2(7,-1)]),color)
