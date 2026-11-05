class_name BulletVisual
extends RefCounted
# Cosmetic preview only. Combat is simulated in combat.gd.
static func draw_core(canvas: CanvasItem, point: Vector2, index: int, clock: float, powered := false) -> void:
	var color: Color = Balance.SKIN_COLORS[index]
	canvas.draw_circle(point,13,Color(0.01,0.04,0.07,0.8))
	NeonArt.glow(canvas,point,7,color)
	if index == 3:
		var star := PackedVector2Array()
		for i in range(10):
			star.append(point+Vector2.from_angle(-PI/2+i*PI/5+clock*0.5)*(10 if i%2 == 0 else 4))
		canvas.draw_colored_polygon(star,color)
	elif index == 2:
		canvas.draw_colored_polygon(PackedVector2Array([point+Vector2(0,-10),point+Vector2(8,0),point+Vector2(0,10),point+Vector2(-8,0)]),color)
	else:
		canvas.draw_circle(point,8,color)
	canvas.draw_circle(point,5,Color("f4ffff"))
	canvas.draw_circle(point-Vector2(1,1),2,Color.WHITE)
	if powered:
		canvas.draw_arc(point,14,clock*2,clock*2+PI*1.4,24,Color("fff0ad"),2)

static func draw_skin_preview(canvas: Control, index: int, clock := 0.0) -> void:
	var color: Color = Balance.SKIN_COLORS[index]
	var center := Vector2(canvas.size.x*0.5+40,12)
	for i in range(20):
		var point := center-Vector2(i*5,sin(float(i)*0.3+clock*2)*4)
		if index == 2: point.y += sin(i*2.0+clock*8)*3
		canvas.draw_circle(point,maxf(1,5.0-float(i)*0.23),Color(color,(1-float(i)/20)*0.7))
	draw_core(canvas,center,index,clock)
