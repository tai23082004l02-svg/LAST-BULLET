extends Control
var skin := 0
var actor := -1
var clock := 0.0
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
	clock += delta
	queue_redraw()
func _draw() -> void:
	if actor >= 0:
		NeonArt.robot(self,actor,Vector2(size.x*0.5,size.y*0.48),minf(size.y*0.85,110),clock)
	else:
		PermanentBullet.draw_skin_preview(self,skin,clock)
