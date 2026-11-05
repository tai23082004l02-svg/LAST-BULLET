extends Control
var skin := 0
var actor := -1
var actor_width := 110.0
var clock := 0.0
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
	clock += delta
	queue_redraw()
func _draw() -> void:
	if actor >= 0:
		NeonArt.hero(self,actor,Vector2(size.x*0.5,size.y*0.48),minf(size.y*0.85,actor_width),clock)
	else:
		BulletVisual.draw_skin_preview(self,skin,clock)
