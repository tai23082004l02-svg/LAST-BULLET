extends RefCounted
# Deterministic drawing only: no gameplay RNG, collision changes or particle nodes.
const COLORS := [Color("86fff0"),Color("ffe27d"),Color("a1edff"),Color("ff9f54"),Color("dcb2ff"),Color("ffcf91"),Color("8ddaff"),Color("ffa76d"),Color("c5ff9b"),Color("7af2df"),Color("ffc262"),Color("b7ed68")]
static func streak(c: CanvasItem, a: Vector2, b: Vector2, color: Color, width: float, reduced: bool) -> void:
	if not reduced: c.draw_line(a,b,Color(color,0.12),width*4,true)
	c.draw_line(a,b,Color(color,0.65),width*1.8,true)
	c.draw_line(a,b,Color("f1ffff"),maxf(1,width*0.45),true)
static func projectile(c: CanvasItem, style: int, p: Vector2, direction: Vector2, skin: int, age: float, reduced := false, finish := 0) -> void:
	var d := direction.normalized() if direction != Vector2.ZERO else Vector2.RIGHT
	var n := d.orthogonal()
	var color: Color = COLORS[clampi(style,0,11)]
	if style in [0,5,6] and skin > 0 and skin < Balance.SKIN_COLORS.size(): color = Balance.SKIN_COLORS[skin]
	if finish in range(1,4): color = [Color.WHITE,Color("96ffd5"),Color("a5dfff"),Color("dab2ff")][finish]
	if not reduced: c.draw_circle(p,11 if style != 4 else 8,Color(color,0.09))
	match style:
		0,5,6:
			var length := 35.0 if style == 6 else 15.0 if style == 5 else 24.0
			streak(c,p-d*length,p+d*5,color,2.2 if style != 5 else 3.2,reduced)
			c.draw_colored_polygon(PackedVector2Array([p+d*7,p+n*3,p-d*8,p-n*3]),color)
		1:
			var points := PackedVector2Array()
			for i in range(6): points.append(p-d*(i*7)+n*(sin(age*42+i*2.4)*5 if i > 0 else 0))
			if not reduced: c.draw_polyline(points,Color(color,0.16),9,true)
			c.draw_polyline(points,color,3,true); c.draw_circle(p,3,Color.WHITE)
		2:
			streak(c,p-d*26,p,color,2,reduced)
			c.draw_colored_polygon(PackedVector2Array([p+d*13,p+n*7-d*3,p-d*10,p-n*7-d*3]),Color("53a8dd"))
			c.draw_colored_polygon(PackedVector2Array([p+d*13,p-d*6,p+n*7-d*3]),Color("defbff"))
			if not reduced:
				for i in range(3): c.draw_circle(p-d*(15+i*9)+n*sin(i+age*10)*7,2,Color(color,0.6-i*0.15))
		3:
			for i in range(3 if reduced else 5):
				var center := p-d*i*7+n*sin(age*26+i*1.7)*3
				c.draw_circle(center,8+i*1.3,Color(color,(1-i*0.14)*0.22))
			c.draw_colored_polygon(PackedVector2Array([p+d*13,p-d*9+n*8,p-d*5,p-d*13-n*7]),Color("ffb14d"))
			c.draw_colored_polygon(PackedVector2Array([p+d*9,p-d*7+n*3,p-d*4-n*3]),Color("fff1b3"))
		4:
			streak(c,p-d*84,p+d*9,color,4,reduced)
			if not reduced:
				for i in range(2): c.draw_line(p-d*(26+i*30)+n*5,p-d*(18+i*30)+n*5,Color(color,0.65),2,true)
		7:
			streak(c,p-d*(28+sin(age*55)*5),p-d*9,Color("ff9b43"),5,reduced)
			c.draw_colored_polygon(PackedVector2Array([p+d*15,p+d*3+n*6,p-d*11+n*5,p-d*11-n*5,p+d*3-n*6]),Color("506c82"))
			c.draw_colored_polygon(PackedVector2Array([p+d*15,p+d*2+n*6,p+d*2-n*6]),Color("ffb976"))
			c.draw_line(p-d*7,p+d*6,Color("e0eff7"),2,true)
		8:
			streak(c,p-d*42,p,color,2,reduced)
			c.draw_colored_polygon(PackedVector2Array([p+d*15,p-d*1+n*6,p-d*1-n*6]),Color("e9ffbd"))
			for sign_value in [-1,1]: c.draw_line(p-d*17,p-d*24+n*sign_value*5,color,2,true)
		9:
			var angle := age*15
			for i in range(3):
				var blade := Vector2.from_angle(angle+i*TAU/3)
				c.draw_colored_polygon(PackedVector2Array([p+blade*17,p+blade.rotated(0.7)*8,p-blade.orthogonal()*4]),color)
			c.draw_circle(p,4,Color("efffff"))
			if not reduced: c.draw_arc(p,19,angle,angle+PI*1.4,16,Color(color,0.35),2,true)
		10:
			c.draw_circle(p,9,Color("253a4b")); c.draw_arc(p,9,0,TAU,16,color,2,true)
			c.draw_line(p-d*6,p+d*6,Color("eab76e"),5,true)
			c.draw_circle(p+n*8,3,Color("fff1a1"))
			if not reduced: c.draw_circle(p-d*15,3,Color(color,0.25))
		11:
			for i in range(2 if reduced else 4): c.draw_circle(p-d*i*7+n*sin(age*12+i*2)*4,6-i,Color(color,0.25-i*0.04))
			c.draw_circle(p,6,color); c.draw_circle(p+Vector2(-2,-2),2,Color("f2ffcd"))
static func flash(c: CanvasItem, kind: String, style: int, p: Vector2, direction: Vector2, progress: float, reduced := false) -> void:
	var color: Color = COLORS[clampi(style,0,11)]
	var t := clampf(progress,0,1)
	var fade := 1-t
	if fade <= 0.01: return
	var d := direction.normalized() if direction != Vector2.ZERO else Vector2.RIGHT
	var n := d.orthogonal()
	if kind == "muzzle":
		c.draw_colored_polygon(PackedVector2Array([p+d*(20*fade+4),p+n*(7*fade),p-d*5,p-n*(6*fade)]),Color(color,fade))
		if not reduced: c.draw_circle(p,14*fade,Color(color,fade*0.15))
		return
	var radius := (10+t*23) if style not in [7,10] else (14+t*42)
	if not reduced: c.draw_circle(p,radius,Color(color,fade*0.08))
	c.draw_arc(p,radius*0.7,0,TAU,20,Color(color,fade*0.65),2*fade+1,true)
	for i in range(3 if reduced else 7):
		var ray := Vector2.from_angle(i*2.399+style*0.7)
		var start := p+ray*(4+t*radius)
		if style == 2:
			c.draw_colored_polygon(PackedVector2Array([start+ray*5,start+ray.orthogonal()*3,start-ray*5,start-ray.orthogonal()*3]),Color(color,fade))
		elif style == 11: c.draw_circle(start,2+fade*3,Color(color,fade*0.7))
		elif style == 1:
			c.draw_polyline(PackedVector2Array([p+ray*5,start+ray.orthogonal()*5,start+ray*8]),Color(color,fade),2,true)
		else: c.draw_line(start,start+ray*(4+fade*9),Color(color,fade),2,true)
	if style in [3,7,10]: c.draw_circle(p,fade*10,Color("fff0ac",fade*0.8))
