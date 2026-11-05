class_name ArenaEnemy
extends Node2D

var kind := 0
var hp := 1.0
var max_hp := 1.0
var radius := 19.0
var speed := 85.0
var phase := 0.0
var dash := Vector2.ZERO
var capture_ready := 5.0
var flash := 0.0

func setup(type: int, wave: int) -> void:
	kind = type
	radius = [19.0, 21.0, 28.0, 53.0][kind]
	hp = [1.0, 2.0, 5.0, 65.0][kind] + floorf(float(wave - 1) / 3)
	max_hp = hp
	speed = [85.0, 100.0, 48.0, 40.0][kind] + minf(wave * 3, 50)
	phase = randf_range(0, 2)

func advance(delta: float, player: Vector2) -> void:
	phase += delta
	capture_ready -= delta
	flash = maxf(0, flash - delta)
	var direction := (player - position).normalized()
	if kind == 1:
		var cycle := fmod(phase, 3.2)
		if cycle < 1.9:
			position += direction * speed * delta
		elif cycle < 2.5:
			dash = direction
		else:
			position += dash * 470 * delta
	else:
		position += direction * speed * delta
	position = position.clamp(Balance.ARENA.position + Vector2.ONE * radius, Balance.ARENA.end - Vector2.ONE * radius)
	queue_redraw()

func _draw() -> void:
	var color := Color("ff697d") if flash <= 0 else Color.WHITE
	if kind == 1:
		draw_colored_polygon(PackedVector2Array([Vector2(0,-radius), Vector2(radius,radius), Vector2(-radius,radius)]), color)
		if fmod(phase,3.2) >= 1.9 and fmod(phase,3.2) < 2.5:
			draw_line(Vector2.ZERO, dash * 150, Color(1,0.6,0.2,0.7), 4)
	elif kind == 2:
		draw_rect(Rect2(-Vector2.ONE * radius, Vector2.ONE * radius * 2), color)
	else:
		draw_circle(Vector2.ZERO, radius, color)
		if kind == 3:
			draw_circle(Vector2.ZERO, radius * 0.6, Color("071022"))
			draw_arc(Vector2.ZERO, radius + 8, 0, TAU * clampf(capture_ready / 9,0,1), 32, Color("ffd17c"), 4)
	if hp < max_hp:
		draw_line(Vector2(-radius,-radius-10), Vector2(radius,-radius-10), Color("402639"), 4)
		draw_line(Vector2(-radius,-radius-10), Vector2(-radius + radius*2*hp/max_hp,-radius-10), Color("ffd17c"), 4)
