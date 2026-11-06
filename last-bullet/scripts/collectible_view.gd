extends Control
var group := "gear"
var index := 0
var rarity := 0
var owned := true
var clock := 0.0
var clipping_scroll: ScrollContainer
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var parent := get_parent()
	while parent != null:
		if parent is ScrollContainer: clipping_scroll = parent; break
		parent = parent.get_parent()
func _process(delta: float) -> void:
	if not is_visible_in_tree() or (clipping_scroll != null and not get_global_rect().intersects(clipping_scroll.get_global_rect())): return
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
	elif group in ["pet","weapon","gear","skill","item"]:
		preload("res://scripts/item_art.gd").draw(self,group,index,center,width*(1.65 if group in ["pet","weapon"] else 1.2),Color.WHITE if owned else Color(0.48,0.52,0.58))
	if not owned:
		var lock := Vector2(size.x-24,size.y-22)
		draw_arc(lock+Vector2(0,-5),6,PI,TAU,12,Color("93a5b5"),2)
		draw_rect(Rect2(lock-Vector2(8,0),Vector2(16,12)),Color("93a5b5"),false,2)

static func draw_pet(canvas: CanvasItem, point: Vector2, radius: float, type: int, time: float, lit := true) -> void:
	preload("res://scripts/item_art.gd").draw(canvas,"pet",type,point+Vector2(0,sin(time*3)*2),radius*3,Color.WHITE if lit else Color(0.3,0.33,0.38))
