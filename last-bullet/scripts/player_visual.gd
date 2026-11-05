extends Node2D
var clock := 0.0
var robot := 0
var lean := 0.0
var target_lean := 0.0
var moving := 0.0
var flash := 0.0
func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
func _process(delta: float) -> void:
	clock += delta*(2.0+moving*6)
	lean = lerpf(lean,target_lean,1-exp(-delta*14))
	queue_redraw()
func _draw() -> void:
	NeonArt.hero(self,robot,Vector2(0,sin(clock)*moving*1.3),58,clock*0.2,lean,flash)
