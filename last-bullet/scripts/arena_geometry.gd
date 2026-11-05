class_name ArenaGeometry
extends RefCounted

# Static central reflector. Expanded slab sweep is conservative at rounded corners.
static var PILLAR := Rect2(305,460,110,110)

static func sweep_rect(origin: Vector2, motion: Vector2, box: Rect2) -> Dictionary:
	var enter := -INF
	var leave := INF
	var normal := Vector2.ZERO
	for axis in range(2):
		if absf(motion[axis]) < 0.00001:
			if origin[axis] < box.position[axis] or origin[axis] > box.end[axis]:
				return {}
			continue
		var first: float = (box.position[axis]-origin[axis])/motion[axis]
		var second: float = (box.end[axis]-origin[axis])/motion[axis]
		var axis_normal := Vector2.ZERO
		axis_normal[axis] = -signf(motion[axis])
		if first > second:
			var swap := first
			first = second
			second = swap
		if first > enter:
			enter = first
			normal = axis_normal
		leave = minf(leave,second)
	if enter > leave or leave < 0 or enter < 0 or enter > 1:
		return {}
	return {"fraction":enter,"normal":normal}

static func resolve(point: Vector2, radius: float) -> Vector2:
	var box := PILLAR.grow(radius)
	if not box.has_point(point):
		return point
	var distances := [point.x-box.position.x,box.end.x-point.x,point.y-box.position.y,box.end.y-point.y]
	var side := distances.find(distances.min())
	match side:
		0: point.x = box.position.x-0.1
		1: point.x = box.end.x+0.1
		2: point.y = box.position.y-0.1
		3: point.y = box.end.y+0.1
	return point

static func navigation_target(origin: Vector2, goal: Vector2, radius: float) -> Vector2:
	var box := PILLAR.grow(radius)
	if sweep_rect(origin,goal-origin,box).is_empty():
		return goal
	var corners: Array[Vector2] = [box.position-Vector2.ONE,Vector2(box.end.x+1,box.position.y-1),box.end+Vector2.ONE,Vector2(box.position.x-1,box.end.y+1)]
	# Tiny visibility graph: origin, four corners, goal. Dijkstra finds a route
	# around either side without placing an enemy inside the obstacle.
	var nodes: Array[Vector2] = [origin]
	nodes.append_array(corners)
	nodes.append(goal)
	var costs := [0.0,INF,INF,INF,INF,INF]
	var previous := [-1,-1,-1,-1,-1,-1]
	var visited: Array[int] = []
	for step in range(6):
		var current := -1
		for i in range(6):
			if not visited.has(i) and (current < 0 or costs[i] < costs[current]): current = i
		if current < 0 or costs[current] == INF: break
		if current == 5: break
		visited.append(current)
		for next in range(6):
			if next == current or visited.has(next): continue
			if not sweep_rect(nodes[current],nodes[next]-nodes[current],box).is_empty(): continue
			var distance: float = costs[current]+nodes[current].distance_to(nodes[next])
			if distance < costs[next]:
				costs[next] = distance
				previous[next] = current
	var first := 5
	for step in range(6):
		if previous[first] <= 0: break
		first = previous[first]
	return nodes[first] if previous[first] == 0 else goal

static func resolve_box(point: Vector2, radius: float, obstacle: Rect2) -> Vector2:
	var box := obstacle.grow(radius)
	if not box.has_point(point): return point
	var distances := [point.x-box.position.x,box.end.x-point.x,point.y-box.position.y,box.end.y-point.y]
	match distances.find(distances.min()):
		0: point.x = box.position.x-0.1
		1: point.x = box.end.x+0.1
		2: point.y = box.position.y-0.1
		3: point.y = box.end.y+0.1
	return point

static func resolve_all(point: Vector2, radius: float, obstacles: Array[Rect2]) -> Vector2:
	for box in obstacles: point = resolve_box(point,radius,box)
	return point

static var route_cache: Dictionary = {}

static func visible_segment(start: Vector2, end: Vector2, boxes: Array[Rect2]) -> bool:
	for box in boxes:
		if not sweep_rect(start,end-start,box).is_empty(): return false
	return true

static func navigate(origin: Vector2, goal: Vector2, radius: float, obstacles: Array[Rect2]) -> Vector2:
	if obstacles.is_empty(): return goal
	var boxes: Array[Rect2] = []
	for obstacle in obstacles: boxes.append(obstacle.grow(radius))
	if visible_segment(origin,goal,boxes): return goal
	var key := str(boxes)
	if not route_cache.has(key):
		if route_cache.size() >= 24: route_cache.clear()
		var corners: Array[Vector2] = []
		for box in boxes:
			corners.append_array([box.position-Vector2.ONE,Vector2(box.end.x+1,box.position.y-1),box.end+Vector2.ONE,Vector2(box.position.x-1,box.end.y+1)])
		var edges: Array = []
		for i in range(corners.size()):
			var row: Array[float] = []
			for j in range(corners.size()): row.append(corners[i].distance_to(corners[j]) if i != j and visible_segment(corners[i],corners[j],boxes) else INF)
			edges.append(row)
		route_cache[key] = {"corners":corners,"edges":edges}
	var cached: Dictionary = route_cache[key]
	var nodes: Array[Vector2] = [origin]
	nodes.append_array(cached.corners)
	nodes.append(goal)
	var count := nodes.size()
	var costs: Array[float] = []
	var previous: Array[int] = []
	for i in range(count):
		costs.append(0.0 if i == 0 else INF)
		previous.append(-1)
	var visited: Array[int] = []
	for step in range(count):
		var current := -1
		for i in range(count):
			if not visited.has(i) and (current < 0 or costs[i] < costs[current]): current = i
		if current < 0 or costs[current] == INF or current == count-1: break
		visited.append(current)
		for next in range(count):
			if next == current or visited.has(next): continue
			var distance := INF
			if current > 0 and next > 0 and current < count-1 and next < count-1:
				distance = cached.edges[current-1][next-1]
			elif visible_segment(nodes[current],nodes[next],boxes):
				distance = nodes[current].distance_to(nodes[next])
			if costs[current]+distance < costs[next]:
				costs[next] = costs[current]+distance
				previous[next] = current
	var first := count-1
	for step in range(count):
		if previous[first] <= 0: break
		first = previous[first]
	return nodes[first] if previous[first] == 0 else goal
