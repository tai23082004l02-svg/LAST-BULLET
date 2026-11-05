extends Control
var group := "gear"
var index := 0
var rarity := 0
var owned := true
var clock := 0.0
func _ready() -> void: mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
	clock += delta
	queue_redraw()
func _draw() -> void:
	var center := size*0.5
	var width := minf(size.x,size.y)*0.65
	var color: Color = [Color("9caeb9"),Color("69bdff"),Color("d495ff"),Color("ffd077")][rarity]
	if not owned: color = Color("415365")
	if owned:
		draw_circle(center,width*0.52,Color(color,0.06))
		draw_arc(center,width*0.54,clock*0.25,clock*0.25+TAU*0.8,40,Color(color,0.45),2)
	if group == "hero":
		modulate = Color.WHITE if owned else Color(0.24,0.29,0.34)
		NeonArt.hero(self,index,center,width,clock)
	elif group in ["monster","boss"]:
		modulate = Color.WHITE if owned else Color(0.24,0.29,0.34)
		if group == "boss":
			var texture := CampaignArt.texture(index)
			var dimensions := Vector2(width,width*texture.get_height()/texture.get_width())
			draw_texture_rect(texture,Rect2(center-dimensions*0.5+Vector2(0,sin(clock*2)*2),dimensions),false)
		else: NeonArt.robot(self,[1,2,3,6,4,5][index],center,width,clock)
	elif group == "pet":
		draw_pet(self,center,width*0.28,index,clock,owned)
	elif group == "weapon":
		preload("res://scripts/combat.gd").draw_round(self,index,center,Vector2.RIGHT,0,clock)
	else:
		var scale := width/60
		draw_set_transform(center,0,Vector2.ONE*scale)
		var family_color: Color = [Color("9fe4ff"),Color("99f5db"),Color("ffba79")][index/4] if owned else color
		match index%4:
			0:
				draw_colored_polygon(PackedVector2Array([Vector2(-20,-24),Vector2(20,-24),Vector2(24,5),Vector2(0,28),Vector2(-24,5)]),Color("163141"))
				draw_polyline(PackedVector2Array([Vector2(-20,-24),Vector2(20,-24),Vector2(24,5),Vector2(0,28),Vector2(-24,5),Vector2(-20,-24)]),family_color,3)
				draw_line(Vector2(0,-14),Vector2(0,15),color,5)
			1:
				draw_circle(Vector2.ZERO,24,Color("153247"))
				draw_arc(Vector2.ZERO,24,0,TAU,32,family_color,4)
				NeonArt.diamond(self,Vector2.ZERO,14,color)
			2:
				for x in [-15,15]:
					draw_rect(Rect2(x-9,-22,18,34),Color("193343"))
					draw_rect(Rect2(x-9,-22,18,34),family_color,false,3)
					draw_colored_polygon(PackedVector2Array([Vector2(x-6,15),Vector2(x,28+sin(clock*8)*3),Vector2(x+6,15)]),color)
			3:
				draw_rect(Rect2(-22,-22,44,44),Color("193343"))
				draw_rect(Rect2(-22,-22,44,44),family_color,false,3)
				for i in range(4):
					var ray := Vector2.from_angle(i*PI/2)
					draw_line(ray*22,ray*31,color,4)
				NeonArt.diamond(self,Vector2.ZERO,11,color)
		draw_set_transform(Vector2.ZERO)
	if not owned:
		var lock := Vector2(size.x-24,size.y-22)
		draw_arc(lock+Vector2(0,-5),6,PI,TAU,12,Color("93a5b5"),2)
		draw_rect(Rect2(lock-Vector2(8,0),Vector2(16,12)),Color("93a5b5"),false,2)

static func draw_pet(canvas: CanvasItem, point: Vector2, radius: float, type: int, time: float, lit := true) -> void:
	var color: Color = [Color("ffe18a"),Color("8ae7ff"),Color("a3ffd6"),Color("a6c8ff"),Color("d0ebff"),Color("ffb77f")][type] if lit else Color("526479")
	var p := point+Vector2(0,sin(time*3)*2)
	canvas.draw_circle(p,radius,Color("173044"))
	canvas.draw_arc(p,radius,0,TAU,24,color,2)
	canvas.draw_rect(Rect2(p+Vector2(-radius*0.65,-radius*0.2),Vector2(radius*1.3,radius*0.4)),color)
	if type == 0:
		for side in [-1,1]: canvas.draw_arc(p+Vector2(side*radius,0),radius*0.6,-PI/2,PI/2,12,Color(color,0.6),2)
	elif type == 1:
		canvas.draw_arc(p,radius*0.5,0,PI,12,color,3)
	elif type == 2:
		canvas.draw_line(p+Vector2(-radius*0.4,-radius*0.65),p+Vector2(radius*0.4,-radius*0.65),color,3)
		canvas.draw_line(p+Vector2(0,-radius),p+Vector2(0,-radius*0.3),color,3)
	elif type == 3: canvas.draw_arc(p,radius*1.3,-PI*0.9,-PI*0.1,18,color,3)
	elif type == 4:
		for i in range(6):
			var ray := Vector2.from_angle(i*TAU/6)
			canvas.draw_line(p+ray*radius,p+ray*radius*1.4,color,2)
	else:
		canvas.draw_line(p+Vector2(radius*0.4,-radius*0.8),p+Vector2(radius,-radius*1.3),color,3)
		canvas.draw_circle(p+Vector2(radius,-radius*1.3),3,color)
