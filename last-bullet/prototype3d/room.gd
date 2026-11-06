extends Control
signal exit_requested
const Bot = preload("res://prototype3d/robot.gd")
var view: SubViewport
var container: SubViewportContainer
var world: Node3D
var camera: Camera3D
var player: Node3D
var enemies: Array[Dictionary] = []
var shots: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var obstacles: Array[Rect2] = [Rect2(-3.8,-2.4,2.1,1.4),Rect2(1.7,1.0,2.1,1.4)]
var status := "playing"
var hp := 5
var wave := 0
var kills := 0
var elapsed := 0.0
var fire_clock := 0.0
var invulnerable := 0.0
var cooldown := 0.0
var spawn_wait := 0.7
var moving_fire := false
var high_quality := true
var pointers: Dictionary = {}
var primary := -1
var drag_vector := Vector2.ZERO
var last_tap_time := -10.0
var last_tap_position := Vector2.ZERO
var last_touch_ms := -1000
var touch_clock := 0.0
var closing := false
var last_shot_id := 0
var sounds_enabled := true
var audio: Node
var ring_mesh: TorusMesh
var header: Panel
var title_label: Label
var hud: Label
var footer: Label
var status_label: Label
var overlay: PanelContainer
var overlay_box: VBoxContainer
var pause_button: Button
var exit_button: Button
var quality_button: Button
var moving_button: Button
var input_overlay: Control
var materials: Dictionary = {}
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	container = SubViewportContainer.new(); container.stretch = true; container.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(container)
	view = SubViewport.new(); view.own_world_3d = true; view.handle_input_locally = false; view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; view.msaa_3d = Viewport.MSAA_2X; container.add_child(view)
	world = Node3D.new(); view.add_child(world)
	audio = preload("res://scripts/audio.gd").new(); add_child(audio); audio.enabled = sounds_enabled
	ring_mesh = TorusMesh.new(); ring_mesh.inner_radius = 0.9; ring_mesh.outer_radius = 1; ring_mesh.rings = 8; ring_mesh.ring_segments = 20
	build_world(); build_ui()
	resized.connect(layout); layout(); restart()
func mat(key: String, color: Color, emission := false) -> StandardMaterial3D:
	if not materials.has(key): materials[key] = Bot.material(color,emission)
	return materials[key]
func part(kind: String, dimensions: Vector3, point: Vector3, material: Material) -> MeshInstance3D: return Bot.part(world,kind,dimensions,point,material)
func build_world() -> void:
	var environment := WorldEnvironment.new(); var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR; settings.background_color = Color("08131e")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; settings.ambient_light_color = Color("9ab9cb"); settings.ambient_light_energy = 0.65
	environment.environment = settings; world.add_child(environment)
	var key := DirectionalLight3D.new(); key.rotation_degrees = Vector3(-52,-28,0); key.light_color = Color("fff0d1"); key.light_energy = 1.3; key.shadow_enabled = false; world.add_child(key)
	var fill := DirectionalLight3D.new(); fill.rotation_degrees = Vector3(-32,145,0); fill.light_color = Color("6ca9d9"); fill.light_energy = 0.45; world.add_child(fill)
	camera = Camera3D.new(); camera.projection = Camera3D.PROJECTION_ORTHOGONAL; camera.size = 25.0; camera.position = Vector3(0,21,19); camera.near = 0.1; camera.far = 60; world.add_child(camera); camera.look_at(Vector3(0,0.3,0)); camera.current = true
	var floor_material := mat("floor",Color("263a4b")); var edge := mat("edge",Color("192836")); var bright := mat("cyan",Color("42b5b8"),true)
	part("box",Vector3(12.6,0.3,26.6),Vector3(0,-0.17,0),floor_material)
	for i in range(-5,6): part("box",Vector3(0.018,0.008,26),Vector3(i,0.001,0),mat("grid",Color("30495b")))
	for i in range(-12,13): part("box",Vector3(12,0.008,0.018),Vector3(0,0.002,i),materials.grid)
	for sign_value in [-1,1]:
		part("box",Vector3(0.4,0.65,26.6),Vector3(sign_value*6.2,0.2,0),edge)
		part("box",Vector3(0.06,0.055,26.2),Vector3(sign_value*5.98,0.17,0),bright)
		part("box",Vector3(12.6,0.65,0.4),Vector3(0,0.2,sign_value*13.15),edge)
		part("box",Vector3(11.9,0.055,0.06),Vector3(0,0.17,sign_value*12.93),bright)
		for z in [-11.4,-4.0,4.0,11.4]:
			part("box",Vector3(0.55,1.05,0.9),Vector3(sign_value*6.15,0.52,z),mat("rim",Color("3e5365")))
			part("box",Vector3(0.59,0.13,0.5),Vector3(sign_value*6.15,0.83,z),mat("amber",Color("e3a456"),true))
	for box in obstacles:
		var point := Vector3(box.get_center().x,0.74,box.get_center().y)
		part("box",Vector3(box.size.x,1.48,box.size.y),point,mat("crate",Color("526778")))
		part("box",Vector3(box.size.x+0.08,0.16,box.size.y+0.08),point+Vector3(0,0.6,0),edge)
		part("box",Vector3(box.size.x*0.6,0.08,box.size.y+0.1),point+Vector3(0,0.1,0),mat("crate_stripe",Color("b8a86a")))
		part("box",Vector3(0.15,0.38,0.06),point+Vector3(0,0,-box.size.y*0.5-0.04),bright)
	for sign_value in [-1,1]: part("box",Vector3(0.42,2.8,0.5),Vector3(sign_value*1.25,1.4,-12.9),edge)
	part("box",Vector3(2.9,0.42,0.6),Vector3(0,2.8,-12.9),mat("gate",Color("4d7987")))
	part("box",Vector3(2.0,0.08,0.62),Vector3(0,2.86,-12.9),bright)
	player = Bot.new(); world.add_child(player); player.build(false)
func label(parent: Node, value: String, font_size := 24) -> Label:
	var node := Label.new(); node.text = value; node.mouse_filter = Control.MOUSE_FILTER_IGNORE; node.add_theme_font_size_override("font_size",font_size); node.add_theme_color_override("font_color",Color("d7f6f1")); parent.add_child(node); return node
func button(parent: Node, value: String, action: Callable) -> Button:
	var node := Button.new(); node.text = value; node.focus_mode = Control.FOCUS_NONE; node.add_theme_font_size_override("font_size",22); node.custom_minimum_size = Vector2(0,72); NeonArt.style_button(node,Color("7adfd2")); node.pressed.connect(action); parent.add_child(node); return node
func build_ui() -> void:
	input_overlay = Control.new(); input_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(input_overlay); input_overlay.draw.connect(draw_controls)
	header = Panel.new(); header.mouse_filter = Control.MOUSE_FILTER_IGNORE; header.add_theme_stylebox_override("panel",NeonArt.panel(Color("0d2435"),Color("346879"),18)); add_child(header)
	title_label = label(header,"LAST BULLET • 3D LAB",26); title_label.position = Vector2(20,12)
	hud = label(header,"",22); hud.position = Vector2(20,53)
	pause_button = button(header,"Ⅱ",toggle_pause)
	exit_button = button(header,"VỀ SẢNH",request_exit)
	quality_button = button(self,"HÌNH ẢNH: ĐẸP",toggle_quality)
	moving_button = button(self,"BẮN KHI DI CHUYỂN: TẮT",toggle_moving_fire)
	footer = label(self,"Kéo để né • Thả tay tự bắn\nNhấn đúp: xung năng lượng • Space trên PC",21); footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label = label(self,"THỬ NGHIỆM 3D • KHÔNG PHÁT THƯỞNG",18); status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay = PanelContainer.new(); overlay.add_theme_stylebox_override("panel",NeonArt.panel(Color("0d2435"),Color("65b8bd"),20)); add_child(overlay)
	var margin := MarginContainer.new(); margin.add_theme_constant_override("margin_left",24); margin.add_theme_constant_override("margin_right",24); margin.add_theme_constant_override("margin_top",28); margin.add_theme_constant_override("margin_bottom",28); overlay.add_child(margin)
	overlay_box = VBoxContainer.new(); overlay_box.add_theme_constant_override("separation",16); margin.add_child(overlay_box)
func safe_margins() -> Vector2:
	if OS.get_name() != "Android": return Vector2(12,12)
	var safe := DisplayServer.get_display_safe_area(); var window := DisplayServer.window_get_size()
	if safe.size.y <= 0 or window.y <= 0: return Vector2(16,16)
	return Vector2(maxf(12,safe.position.y*size.y/window.y),maxf(12,(window.y-safe.end.y)*size.y/window.y))
func layout() -> void:
	if not is_instance_valid(container): return
	var margins := safe_margins(); var width := maxf(320,size.x)
	header.position = Vector2(16,margins.x); header.size = Vector2(width-32,118)
	pause_button.position = Vector2(width-244,16); pause_button.size = Vector2(64,74)
	exit_button.position = Vector2(width-170,16); exit_button.size = Vector2(120,74)
	title_label.add_theme_font_size_override("font_size",clampi(int(width*0.035),16,26))
	container.position = Vector2(0,margins.x+132); container.size = Vector2(width,maxf(200,size.y-margins.x-margins.y-310))
	camera.size = maxf(22.0,14.3*container.size.y/maxf(1,container.size.x))
	container.stretch_shrink = 1 if high_quality else 2
	input_overlay.position = Vector2.ZERO; input_overlay.size = size
	quality_button.position = Vector2(18,size.y-margins.y-156); quality_button.size = Vector2(width*0.39,64)
	moving_button.position = Vector2(width*0.42,size.y-margins.y-156); moving_button.size = Vector2(width*0.56-18,64); moving_button.add_theme_font_size_override("font_size",18)
	footer.position = Vector2(10,size.y-margins.y-82); footer.size = Vector2(width-20,56)
	status_label.position = Vector2(10,size.y-margins.y-28); status_label.size = Vector2(width-20,28)
	overlay.position = Vector2(width*0.1,size.y*0.28); overlay.size = Vector2(width*0.8,0)
func refresh_hud() -> void:
	hud.text = "HP %d/5 • ĐỢT %d/3 • HẠ %d/11\n%02d:%02d • XUNG %s" % [hp,maxi(1,wave),kills,int(elapsed)/60,int(elapsed)%60,"SẴN SÀNG" if cooldown <= 0 else "%.1fs" % cooldown]
func show_overlay(title: String, description: String) -> void:
	for child in overlay_box.get_children(): overlay_box.remove_child(child); child.queue_free()
	var heading := label(overlay_box,title,32); heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var body := label(overlay_box,description,23); body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if status == "paused": button(overlay_box,"TIẾP TỤC",toggle_pause)
	button(overlay_box,"CHƠI LẠI PHÒNG THỬ",restart); button(overlay_box,"VỀ SẢNH",request_exit)
	overlay.show(); layout()
func _exit_tree() -> void:
	if is_instance_valid(audio): audio.shutdown()

func clear_input() -> void: pointers.clear(); primary = -1; drag_vector = Vector2.ZERO; last_tap_time = -10
func restart() -> void:
	clear_input()
	for entry in enemies:
		if is_instance_valid(entry.actor): entry.actor.queue_free()
	for entry in shots+effects:
		if is_instance_valid(entry.node): entry.node.queue_free()
	enemies.clear(); shots.clear(); effects.clear(); hp = 5; wave = 0; kills = 0; elapsed = 0; fire_clock = 0; cooldown = 0; invulnerable = 0; spawn_wait = 0.7; status = "playing"
	player.position = Vector3(0,0,5.2); player.rotation = Vector3.ZERO; player.recoil = 0; player.hit_time = 0; player.clock = 0; player.animate(0,0)
	overlay.hide(); view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; refresh_hud()
func toggle_quality() -> void:
	high_quality = not high_quality; quality_button.text = "HÌNH ẢNH: ĐẸP" if high_quality else "HÌNH ẢNH: NHẸ"
	view.msaa_3d = Viewport.MSAA_2X if high_quality else Viewport.MSAA_DISABLED; layout()
	if status != "playing": view.render_target_update_mode = SubViewport.UPDATE_ONCE
func toggle_moving_fire() -> void:
	moving_fire = not moving_fire; moving_button.text = "BẮN KHI DI CHUYỂN: BẬT" if moving_fire else "BẮN KHI DI CHUYỂN: TẮT"
func toggle_pause() -> void:
	if status not in ["playing","paused"]: return
	audio.stop_all()
	clear_input(); status = "paused" if status == "playing" else "playing"
	if status == "paused": show_overlay("TẠM DỪNG","Phòng thử 3D • tiến trình 2D được giữ nguyên."); view.render_target_update_mode = SubViewport.UPDATE_ONCE
	else: overlay.hide(); view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
func request_exit() -> void:
	if closing: return
	closing = true; status = "closed"; clear_input(); audio.stop_all(); view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	if exit_requested.get_connections().is_empty(): get_tree().change_scene_to_file("res://scenes/Main.tscn")
	else: exit_requested.emit()
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready() and status == "playing": toggle_pause()
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_node_ready(): request_exit()
static func flat(point: Vector3) -> Vector2: return Vector2(point.x,point.z)
static func space(point: Vector2, height := 0.0) -> Vector3: return Vector3(point.x,height,point.y)
func resolve(point: Vector2, radius: float) -> Vector2:
	point = point.clamp(Vector2(-5.7,-12.5)+Vector2.ONE*radius,Vector2(5.7,12.5)-Vector2.ONE*radius)
	for box in obstacles:
		var closest := point.clamp(box.position,box.end); var delta := point-closest
		if delta.length_squared() >= radius*radius: continue
		if delta.length_squared() > 0.000001: point = closest+delta.normalized()*radius
		else:
			var distances := [absf(point.x-box.position.x),absf(box.end.x-point.x),absf(point.y-box.position.y),absf(box.end.y-point.y)]
			var side: int = distances.find(distances.min())
			match side:
				0: point.x = box.position.x-radius
				1: point.x = box.end.x+radius
				2: point.y = box.position.y-radius
				3: point.y = box.end.y+radius
	return point
func wall_fraction(start: Vector2, motion: Vector2) -> float:
	var result := 1.0
	for box in obstacles:
		var hit := ArenaGeometry.sweep_rect(start,motion,box.grow(0.08))
		if not hit.is_empty(): result = minf(result,float(hit.fraction))
	return result
static func circle_fraction(start: Vector2, motion: Vector2, center: Vector2, radius: float) -> float:
	var offset := start-center
	if offset.length_squared() <= radius*radius: return 0
	var a := motion.length_squared()
	if a < 0.000001: return INF
	var b := 2*offset.dot(motion); var c := offset.length_squared()-radius*radius; var discriminant := b*b-4*a*c
	if discriminant < 0: return INF
	var t := (-b-sqrt(discriminant))/(2*a)
	return t if t >= 0 and t <= 1 else INF
func spawn_wave() -> void:
	wave += 1
	var count := 3 if wave == 1 else 4
	var points := [Vector2(-4.6,-6.8),Vector2(4.6,-6.8),Vector2(0,-7.6),Vector2(-4.8,4.5)]
	for i in range(count):
		var actor := Bot.new(); world.add_child(actor); actor.build(true); actor.scale = Vector3.ONE*0.82; actor.position = space(points[(i+wave-1)%points.size()])
		enemies.append({"actor":actor,"hp":3,"timer":1.5+i*0.4,"locked":Vector2.ZERO,"warned":false})
		burst_visual(actor.position,Color("ffad65"),0.7,0.6)
func burst_visual(point: Vector3, color: Color, radius: float, life: float) -> void:
	if effects.size() >= 24:
		var first: Dictionary = effects.pop_front(); first.node.queue_free()
	var node := MeshInstance3D.new(); node.mesh = ring_mesh; node.material_override = mat("fx"+color.to_html(),color,true); node.position = Vector3(point.x,0.08,point.z); node.scale = Vector3.ONE*0.1; world.add_child(node)
	effects.append({"node":node,"age":0.0,"life":life,"radius":radius})
func shoot(origin: Vector3, direction: Vector2, friendly: bool) -> void:
	if shots.size() >= 48 or direction == Vector2.ZERO: return
	var node := Bot.part(world,"sphere" if not friendly else "cylinder",Vector3(0.22,0.22,0.22) if not friendly else Vector3(0.095,0.52,0.095),origin,mat("friendly" if friendly else "hostile",Color("8ffff0") if friendly else Color("ff9353"),true))
	if friendly: node.rotation = Vector3(PI/2,atan2(-direction.x,-direction.y),0)
	shots.append({"node":node,"p":flat(origin),"v":direction.normalized()*(14 if friendly else 5.2),"life":1.8 if friendly else 3.2,"friendly":friendly})
	last_shot_id += 1
func try_fire() -> void:
	var target: Dictionary = {}; var distance := 8.5*8.5
	for entry in enemies:
		var delta := flat(entry.actor.position-player.position)
		if delta.length_squared() < distance and wall_fraction(flat(player.position),delta) >= 1:
			distance = delta.length_squared(); target = entry
	if target.is_empty(): return
	var direction := flat(target.actor.position-player.position).normalized()
	player.rotation.y = atan2(-direction.x,-direction.y); player.kick()
	shoot(player.muzzle.global_position,(flat(target.actor.position)-flat(player.muzzle.global_position)).normalized(),true)
	audio.play_event("shoot")
func hurt() -> void:
	if invulnerable > 0 or status != "playing": return
	hp -= 1; invulnerable = 1; player.hit(); audio.play_event("player_hit")
	if hp <= 0: finish(false)
func damage_enemy(entry: Dictionary, power: int) -> void:
	if not enemies.has(entry): return
	entry.hp -= power; entry.actor.hit()
	if entry.hp <= 0:
		burst_visual(entry.actor.position,Color("ffc27a"),0.9,0.32); entry.actor.queue_free(); enemies.erase(entry); kills += 1
func use_skill() -> void:
	if status != "playing" or cooldown > 0: return
	audio.play_event("skill")
	cooldown = 8; burst_visual(player.position,Color("79e9e7"),3.1,0.45)
	for entry in enemies.duplicate():
		var delta := flat(entry.actor.position-player.position)
		if delta.length() < 3.1 and wall_fraction(flat(player.position),delta) >= 1:
			damage_enemy(entry,2)
			if enemies.has(entry): entry.actor.position = space(resolve(flat(entry.actor.position)+delta.normalized()*1.2,0.4))
func finish(won: bool) -> void:
	status = "won" if won else "lost"; clear_input(); refresh_hud()
	show_overlay("HOÀN TẤT PHÒNG THỬ" if won else "THỬ LẠI NHÉ", "%d / 11 quái • %02d:%02d\nPhòng thử không tiêu tài nguyên và không phát thưởng." % [kills,int(elapsed)/60,int(elapsed)%60]); view.render_target_update_mode = SubViewport.UPDATE_ONCE
func _physics_process(delta: float) -> void:
	touch_clock += delta
	if status != "playing": return
	elapsed += delta; cooldown = maxf(0,cooldown-delta); invulnerable = maxf(0,invulnerable-delta); fire_clock -= delta
	var movement := drag_vector
	if primary == -1:
		movement = Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	if movement.length() > 1: movement = movement.normalized()
	player.position = space(resolve(flat(player.position)+movement*delta*4.3,0.43))
	if movement.length() > 0.05: player.rotation.y = atan2(-movement.x,-movement.y)
	player.animate(delta,movement.length())
	if fire_clock <= 0 and (moving_fire or movement.length() < 0.1): fire_clock = 0.28; try_fire()
	if enemies.is_empty():
		spawn_wait -= delta
		if spawn_wait <= 0:
			if wave < 3: spawn_wave(); spawn_wait = 0.8
			else: finish(true); return
	for entry in enemies.duplicate():
		var delta_position := flat(player.position-entry.actor.position); var distance := delta_position.length(); var direction := delta_position.normalized()
		var movement_enemy := direction if distance > 4.2 else direction.orthogonal()*sin(elapsed+entry.timer)*0.22
		for other in enemies:
			if other == entry: continue
			var separation := flat(entry.actor.position-other.actor.position)
			if separation.length() < 1.05 and separation.length() > 0.01: movement_enemy += separation.normalized()*0.7
		entry.actor.position = space(resolve(flat(entry.actor.position)+movement_enemy*delta*1.45,0.4))
		entry.actor.rotation.y = atan2(-direction.x,-direction.y); entry.actor.animate(delta,minf(1,movement_enemy.length()))
		if distance < 0.83: hurt()
		entry.timer -= delta
		if distance < 8 and not entry.warned and entry.timer <= 0.35 and wall_fraction(flat(entry.actor.position),delta_position) >= 1:
			entry.warned = true; entry.locked = flat(player.position); burst_visual(player.position,Color("d7784b"),0.6,0.35)
		if entry.timer <= 0:
			if entry.warned:
				shoot(entry.actor.position+Vector3(0,1.22,0),(entry.locked-flat(entry.actor.position)).normalized(),false)
				audio.play_event("enemy_shoot")
			entry.timer = 2.6; entry.warned = false
		if status != "playing": return
	for shot in shots.duplicate():
		var start: Vector2 = shot.p; var motion: Vector2 = shot.v*minf(delta,shot.life); var fraction := wall_fraction(start,motion); var target: Dictionary = {}
		if shot.friendly:
			for entry in enemies:
				var hit := circle_fraction(start,motion,flat(entry.actor.position),0.47)
				if hit <= fraction: fraction = hit; target = entry
		else:
			var hit := circle_fraction(start,motion,flat(player.position),0.43)
			if hit <= fraction: fraction = hit; target = {"player":true}
		shot.p = start+motion*fraction; shot.life -= delta; shot.node.position = space(shot.p,1.22)
		if not target.is_empty():
			if shot.friendly: damage_enemy(target,1)
			else: hurt()
		if not target.is_empty() or fraction < 1 or shot.life <= 0 or absf(shot.p.x) > 6 or absf(shot.p.y) > 13:
			if fraction < 1: burst_visual(space(shot.p),Color("b0e5d7") if shot.friendly else Color("ffac78"),0.35,0.2)
			shot.node.queue_free(); shots.erase(shot)
		if status != "playing": return
	for effect in effects.duplicate():
		effect.age += delta; var t: float = effect.age/effect.life; effect.node.scale = Vector3.ONE*maxf(0.01,effect.radius*t)
		if t >= 1: effect.node.queue_free(); effects.erase(effect)
	refresh_hud(); input_overlay.queue_redraw()
func special(point: Vector2) -> bool:
	if status != "playing": return true
	for node in [pause_button,exit_button,quality_button,moving_button]:
		if node.get_global_rect().has_point(point): return true
	return false
func pointer_down(index: int, point: Vector2) -> void:
	if special(point): return
	pointers[index] = {"start":point,"last":point,"time":touch_clock,"dragged":false}
	if primary == -1: primary = index
func pointer_move(index: int, point: Vector2) -> void:
	if not pointers.has(index): return
	var pointer: Dictionary = pointers[index]; pointer.last = point
	if point.distance_to(pointer.start) >= 12: pointer.dragged = true
	if index == primary and pointer.dragged: drag_vector = ((point-pointer.start)/82).limit_length(1)
func pointer_up(index: int, point: Vector2, canceled := false) -> void:
	if not pointers.has(index): return
	var pointer: Dictionary = pointers[index]; pointers.erase(index)
	if index == primary: primary = -1; drag_vector = Vector2.ZERO
	if canceled or pointer.dragged or point.distance_to(pointer.start) >= 12 or touch_clock-pointer.time > 0.22: last_tap_time = -10; return
	if touch_clock-last_tap_time <= 0.3 and point.distance_to(last_tap_position) <= 48: last_tap_time = -10; use_skill()
	else: last_tap_time = touch_clock; last_tap_position = point
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE: toggle_pause(); get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SPACE: use_skill(); get_viewport().set_input_as_handled()
	if event is InputEventScreenTouch:
		last_touch_ms = Time.get_ticks_msec()
		if event.pressed: pointer_down(event.index,event.position)
		else: pointer_up(event.index,event.position,event.canceled)
	elif event is InputEventScreenDrag:
		last_touch_ms = Time.get_ticks_msec(); pointer_move(event.index,event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.device != -1 and Time.get_ticks_msec()-last_touch_ms > 500:
		if event.pressed: pointer_down(-2,event.position)
		else: pointer_up(-2,event.position)
	elif event is InputEventMouseMotion and primary == -2 and event.device != -1: pointer_move(-2,event.position)
func draw_controls() -> void:
	if primary == -1 or not pointers.has(primary) or not pointers[primary].dragged: return
	var origin: Vector2 = pointers[primary].start
	input_overlay.draw_circle(origin,60,Color(0.1,0.4,0.42,0.13)); input_overlay.draw_arc(origin,60,0,TAU,32,Color(0.4,0.9,0.87,0.4),2,true)
	input_overlay.draw_circle(origin+drag_vector*38,18,Color(0.5,1,0.9,0.45))
