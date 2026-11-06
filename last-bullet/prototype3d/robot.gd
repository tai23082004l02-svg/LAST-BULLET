extends Node3D
# Original articulated rigid-mesh prototype, not a production skinned model.
static var meshes: Dictionary = {}
var enemy := false
var armor: StandardMaterial3D
var base_color := Color("358f88")
var dark: StandardMaterial3D
var light: StandardMaterial3D
var body: Node3D
var head: Node3D
var gun: Node3D
var muzzle: Marker3D
var muzzle_light: MeshInstance3D
var legs: Array[Node3D] = []
var arms: Array[Node3D] = []
var clock := 0.0
var recoil := 0.0
var hit_time := 0.0
static func material(color: Color, emission := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new(); m.albedo_color = color; m.roughness = 0.48; m.metallic = 0.22
	if emission: m.emission_enabled = true; m.emission = color; m.emission_energy_multiplier = 1.6
	return m
static func shape(kind: String, dimensions: Vector3) -> Mesh:
	var key := kind+str(dimensions)
	if meshes.has(key): return meshes[key]
	var mesh: Mesh
	if kind == "sphere":
		var sphere := SphereMesh.new(); sphere.radius = 0.5; sphere.height = 1; sphere.radial_segments = 12; sphere.rings = 6; mesh = sphere
	elif kind == "cylinder":
		var cylinder := CylinderMesh.new(); cylinder.top_radius = 0.5; cylinder.bottom_radius = 0.5; cylinder.height = 1; cylinder.radial_segments = 12; mesh = cylinder
	else:
		var box := BoxMesh.new(); box.size = Vector3.ONE; mesh = box
	meshes[key] = mesh
	return mesh
static func part(parent: Node3D, kind: String, dimensions: Vector3, point: Vector3, mat: Material) -> MeshInstance3D:
	var visual := MeshInstance3D.new(); visual.mesh = shape(kind,Vector3.ONE); visual.scale = dimensions; visual.position = point; visual.material_override = mat; parent.add_child(visual)
	return visual
func build(is_enemy := false) -> void:
	enemy = is_enemy; base_color = Color("a64248") if enemy else Color("358f88")
	armor = material(base_color); dark = material(Color("172738")); light = material(Color("ff795c") if enemy else Color("8bffe4"),true)
	var silver := material(Color("9aafbe")); var gold := material(Color("e2a559"))
	var shadow := material(Color(0.01,0.025,0.04,0.28)); shadow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; shadow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	part(self,"cylinder",Vector3(1.45,0.008,1.05),Vector3(0,0.012,0),shadow).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body = Node3D.new(); body.position.y = 1.22; add_child(body)
	part(body,"sphere",Vector3(1.03,0.85,0.68),Vector3.ZERO,armor)
	part(body,"box",Vector3(0.62,0.43,0.12),Vector3(0,0.05,-0.33),dark)
	part(body,"box",Vector3(0.45,0.10,0.035),Vector3(0,0.09,-0.405),light)
	part(body,"box",Vector3(0.25,0.13,0.08),Vector3(0,-0.22,-0.34),gold)
	part(body,"box",Vector3(0.65,0.4,0.24),Vector3(0,0.03,0.35),dark)
	for sign_value in [-1,1]:
		part(body,"box",Vector3(0.1,0.28,0.1),Vector3(sign_value*0.23,0.06,0.5),silver)
		var arm := Node3D.new(); arm.position = Vector3(sign_value*0.62,0.14,0); body.add_child(arm); arms.append(arm)
		part(arm,"sphere",Vector3(0.44,0.46,0.48),Vector3.ZERO,armor)
		part(arm,"cylinder",Vector3(0.22,0.42,0.22),Vector3(0,-0.29,-0.08),dark)
		part(arm,"sphere",Vector3(0.3,0.25,0.32),Vector3(0,-0.47,-0.14),silver)
		var leg := Node3D.new(); leg.position = Vector3(sign_value*0.29,0.84,0); add_child(leg); legs.append(leg)
		part(leg,"cylinder",Vector3(0.26,0.45,0.26),Vector3(0,-0.2,0),dark)
		part(leg,"sphere",Vector3(0.39,0.36,0.4),Vector3(0,-0.37,-0.04),armor)
		part(leg,"box",Vector3(0.37,0.17,0.52),Vector3(0,-0.69,-0.1),dark)
		part(leg,"box",Vector3(0.3,0.1,0.26),Vector3(0,-0.58,-0.21),silver)
	head = Node3D.new(); head.position = Vector3(0,1.94,0); add_child(head)
	part(head,"sphere",Vector3(1.05,0.82,0.88),Vector3.ZERO,armor)
	part(head,"sphere",Vector3(0.91,0.48,0.36),Vector3(0,-0.06,-0.36),dark)
	part(head,"box",Vector3(0.64,0.12,0.06),Vector3(0,-0.06,-0.555),light)
	part(head,"box",Vector3(0.22,0.16,0.5),Vector3(0,0.31,-0.05),silver)
	for sign_value in [-1,1]: part(head,"sphere",Vector3(0.14,0.36,0.3),Vector3(sign_value*0.53,0,0),gold)
	gun = Node3D.new(); gun.position = Vector3(0.6,1.22,-0.35); add_child(gun)
	part(gun,"box",Vector3(0.32,0.3,0.68),Vector3.ZERO,dark)
	part(gun,"box",Vector3(0.35,0.19,0.46),Vector3(0,0.05,-0.13),armor)
	part(gun,"box",Vector3(0.37,0.055,0.35),Vector3(0,0.08,-0.15),light)
	var barrel := part(gun,"cylinder",Vector3(0.14,0.52,0.14),Vector3(0,0,-0.53),silver); barrel.rotation.x = PI/2
	part(gun,"box",Vector3(0.18,0.25,0.2),Vector3(0,-0.22,0.06),gold)
	part(gun,"box",Vector3(0.12,0.12,0.23),Vector3(0,0.23,0.08),dark)
	muzzle = Marker3D.new(); muzzle.position = Vector3(0,0,-0.84); gun.add_child(muzzle)
	muzzle_light = part(gun,"sphere",Vector3(0.18,0.18,0.3),muzzle.position,light); muzzle_light.visible = false
	gun.visible = not enemy
func kick() -> void: recoil = 0.11
func hit() -> void: hit_time = 0.14
func animate(delta: float, speed: float) -> void:
	clock += delta*(3+speed*8); recoil = maxf(0,recoil-delta); hit_time = maxf(0,hit_time-delta)
	body.position.y = 1.22+sin(clock*2)*0.035*speed; head.position.y = 1.94+sin(clock*2)*0.025*speed
	for i in range(2):
		legs[i].rotation.x = sin(clock+i*PI)*0.55*speed
		arms[i].rotation.x = sin(clock+i*PI)*0.28*speed if enemy else -0.45
	gun.position.z = -0.35+recoil
	muzzle_light.visible = recoil > 0.07
	armor.albedo_color = base_color.lerp(Color("efffff"),clampf(hit_time*5,0,0.7))
