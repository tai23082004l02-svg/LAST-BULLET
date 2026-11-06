extends Control
const Items = preload("res://scripts/item_art.gd")
var group := "item"
var index := 0
var accent := Color("83ead6")
func _ready() -> void: mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	if group == "featured":
		draw_style_box(NeonArt.panel(Color("102d41"),Color("398d98"),16),Rect2(Vector2.ZERO,size))
		for i in range(8): draw_line(Vector2(i*80,0),Vector2(i*80-80,size.y),Color(0.2,0.8,0.8,0.05),2,true)
		NeonArt.hero(self,0,Vector2(size.x*0.18,size.y*0.52),116,0)
		Items.draw(self,"item",1,Vector2(size.x*0.46,size.y*0.5),100)
		Items.draw(self,"gear",4,Vector2(size.x*0.66,size.y*0.5),114)
		Items.draw(self,"pet",0,Vector2(size.x*0.85,size.y*0.5),112)
		return
	var center := size*0.5
	var width := minf(size.x,size.y)*0.86
	draw_circle(center,width*0.48,Color(accent,0.06))
	draw_arc(center,width*0.46,-0.6,PI*1.4,40,Color(accent,0.25),2,true)
	if group in ["pet","gear","weapon"]: Items.draw(self,group,index,center,width)
	else:
		var box := Rect2(center-Vector2(width*0.35,width*0.22),Vector2(width*0.7,width*0.49))
		draw_style_box(NeonArt.panel(Color("16374a"),Color("527784"),12),box)
		draw_line(box.position+Vector2(8,8),box.position+Vector2(box.size.x-8,8),accent,3,true)
		draw_line(box.position+Vector2(8,box.size.y-9),box.end-Vector2(8,9),Color(accent,0.45),2,true)
		Items.draw(self,"item",index,center,width*0.63)
