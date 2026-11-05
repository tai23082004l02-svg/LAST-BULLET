class_name CampaignData
extends RefCounted

const STAGES := [
 {"name":"TRAINING BAY","boss":"SENTINEL","at":90.0,"color":Color("9ce9dd"),"tip":"Learn the timing. Dodge the Sentinel's marked charge.","pool":[0,0,1]},
 {"name":"REFLECTION WORKS","boss":"MIRROR WARDEN","at":105.0,"color":Color("9eb9ff"),"tip":"Bank around two pillars. Attack while the Warden's shield is down.","pool":[0,1,2,4]},
 {"name":"ENERGY FURNACE","boss":"FURNACE HEART","at":120.0,"color":Color("ffc18b"),"tip":"Amber tiles warn before heating. Leave the marks before they turn red.","pool":[0,1,2,5]},
 {"name":"MAGNETIC STATION","boss":"POLARIS","at":120.0,"color":Color("d9aeff"),"tip":"Magnetic coils bend the single bullet. Dodge the locked strike marks.","pool":[1,2,4,5]},
 {"name":"MACHINE CORE","boss":"CORE PRIME","at":135.0,"color":Color("ffe3a7"),"tip":"All hazards combine. Return the captured bullet; phase two adds charges.","pool":[0,1,2,4,5]}
]

static func data(stage: int) -> Dictionary:
	return STAGES[clampi(stage,0,4)]

static func obstacles(arena: Rect2, stage: int) -> Array[Rect2]:
	var center := arena.get_center()
	var boxes: Array[Rect2] = []
	if stage == 1:
		boxes = [Rect2(center+Vector2(-155,-150),Vector2(90,110)),Rect2(center+Vector2(65,75),Vector2(90,110))]
	elif stage == 4:
		boxes = [Rect2(center+Vector2(-55,-100),Vector2(110,110))]
	return boxes

static func hot_zones(arena: Rect2, stage: int) -> Array[Rect2]:
	var boxes: Array[Rect2] = []
	if stage not in [2,4]: return boxes
	for i in range(3):
		boxes.append(Rect2(arena.position+Vector2(65+i*190,arena.size.y*(0.28 if i%2 == 0 else 0.65)),Vector2(150,90)))
	return boxes

static func heat_state(time: float, index: int) -> int:
	var cycle := fmod(time+index*1.4,6.0)
	return 1 if cycle < 1.2 else 2 if cycle < 3.2 else 0

static func magnets(arena: Rect2, stage: int) -> Array[Vector2]:
	var points: Array[Vector2] = []
	if stage in [3,4]:
		points = [arena.position+arena.size*Vector2(0.25,0.36),arena.position+arena.size*Vector2(0.75,0.68)]
	return points

static func steer(position: Vector2, velocity: Vector2, delta: float, arena: Rect2, stage: int, stronger := false) -> Vector2:
	for field in magnets(arena,stage):
		var distance := position.distance_to(field)
		if distance < 145 and distance > 12:
			var turn := velocity.angle_to(field-position)
			var limit := delta*(1.0 if stronger else 0.6)*(1-distance/170)
			velocity = velocity.rotated(clampf(turn,-limit,limit))
	return velocity

static func draw_arena(canvas: CanvasItem, arena: Rect2, stage: int, time: float) -> void:
	var color: Color = data(stage).color
	canvas.draw_rect(arena,Color(color,0.035))
	var index := 0
	for box in hot_zones(arena,stage):
		var state := heat_state(time,index)
		var tint := Color("ffc16b") if state == 1 else Color("ff654c") if state == 2 else Color("4c4342")
		canvas.draw_rect(box,Color(tint,0.25 if state == 2 else 0.08))
		canvas.draw_rect(box,Color(tint,0.85 if state > 0 else 0.2),false,2)
		if state > 0:
			for stripe in range(4):
				canvas.draw_line(box.position+Vector2(10+stripe*35,12),box.position+Vector2(30+stripe*35,35),Color(tint,0.55),3)
		index += 1
	for point in magnets(arena,stage):
		canvas.draw_circle(point,145,Color(0.6,0.35,1,0.035))
		canvas.draw_arc(point,145,0,TAU,48,Color(0.7,0.5,1,0.32),1)
		for ring in range(3):
			var radius := fmod(time*28+ring*42,135.0)+8
			canvas.draw_arc(point,radius,time,time+PI*1.6,32,Color(0.7,0.55,1,0.18),1.5)
		canvas.draw_circle(point,14,Color("282543"))
		canvas.draw_arc(point,14,0,TAU,24,Color("c4a2ff"),3)
