extends Node2D
# One bounded renderer; no gameplay bodies/projectiles or per-spark nodes.
var reduced := false
var effects: Array[Dictionary] = []
var numbers: Array[Dictionary] = []
var number_font: Font = ThemeDB.fallback_font
var clock := 0.0
var active := true

func burst(point: Vector2, color: Color, kind := "hit", direction := Vector2.ZERO) -> void:
	var cap := 24 if reduced else 80
	if effects.size() >= cap: effects.pop_front()
	effects.append({"p":point,"color":color,"kind":kind,"age":0.0,"life":0.55 if kind == "death" else 0.35,"dir":direction})

func damage_number(point: Vector2, amount: float) -> void:
	if reduced: return
	if numbers.size() >= 20: numbers.pop_front()
	numbers.append({"p":point,"age":0.0,"text":"%.1f" % amount if amount < 1 else str(roundi(amount)),"large":amount >= 3})

func advance(delta: float) -> void:
	if not active: return
	clock += delta
	while effects.size() > (24 if reduced else 80): effects.pop_front()
	for i in range(effects.size()-1,-1,-1):
		effects[i].age += delta
		if effects[i].age >= effects[i].life: effects.remove_at(i)
	for i in range(numbers.size()-1,-1,-1):
		numbers[i].age += delta
		if numbers[i].age >= 0.65: numbers.remove_at(i)
	if reduced: numbers.clear()
	queue_redraw()

func _draw() -> void:
	for effect in effects:
		var t: float = effect.age/effect.life
		var color: Color = effect.color
		color.a = (1-t)*0.8
		var point: Vector2 = effect.p
		if effect.kind in ["perfect","death","pickup"]:
			draw_arc(point,5+t*(60 if effect.kind == "perfect" else 25),0,TAU,24,color,2*(1-t)+1)
		if effect.kind == "pickup": continue
		for i in range(3 if reduced else 6):
			var angle: float = float(i)*TAU/6+effect.dir.angle()
			var direction := Vector2.from_angle(angle)
			var distance := t*(45 if effect.kind == "death" else 25)
			if effect.kind == "death":
				draw_set_transform(point+direction*distance,angle+t*5)
				draw_rect(Rect2(-Vector2.ONE*3,Vector2.ONE*6*(1-t)),color)
				draw_set_transform(Vector2.ZERO)
			else:
				draw_line(point+direction*distance,point+direction*(distance+8*(1-t)),color,2)
	for number in numbers:
		var alpha: float = 1-float(number.age)/0.65
		var point: Vector2 = number.p+Vector2(-12,-24-number.age*36)
		draw_string(number_font,point+Vector2(1,1),number.text,HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color(0.01,0.03,0.05,alpha))
		draw_string(number_font,point,number.text,HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color(1,0.85,0.5,alpha) if number.large else Color(0.82,1,0.97,alpha))
