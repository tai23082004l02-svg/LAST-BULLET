extends Control
signal finished
var robot := 1
var tier := 0
var progress := 0.0
var done := false
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
	progress = minf(1,progress+delta/1.6)
	if progress >= 1 and not done:
		done = true
		finished.emit()
	queue_redraw()
func skip() -> void:
	progress = 1
	if not done:
		done = true
		finished.emit()
	queue_redraw()
func _draw() -> void:
	var center := size*0.5
	var color: Color = SummonSystem.COLORS[tier]
	NeonArt.glow(self,center,40+progress*20,color)
	for i in range(3):
		draw_arc(center,55+i*17,progress*TAU*(1 if i%2 == 0 else -1),progress*TAU*(1 if i%2 == 0 else -1)+PI*1.6,40,Color(color,0.65),2)
	if progress < 0.65:
		draw_texture_rect(CampaignArt.texture(5),Rect2(center-Vector2(65,80),Vector2(130,160)),false)
		draw_line(center-Vector2(30,0),center+Vector2(30,0),color,3)
	else:
		NeonArt.hero(self,robot,center,150*(0.5+progress*0.5),progress*2)
