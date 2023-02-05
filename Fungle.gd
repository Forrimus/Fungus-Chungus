extends Node2D
class_name Fungle

const deg120 = TAU / 3.0
const start_length = 3.0
const base_speed = 30.0

var mouse_position = Vector2.ZERO

var neibs = []
func propagate_before_update(from, delta):
	for n in neibs:
		if n == from:
			continue
		n.propagate_before_update(self, delta)
	_before_update(delta)

func propagate_after_update(from, delta):
	for n in neibs:
		if n == from:
			continue
		n.propagate_after_update(self, delta)

var stuck = false
var on_nodule = false
var nodule = null
var nodule_flow = 0.0
var priority = 1.0
func _before_update(delta):
	priority = max(0.01, priority * 0.995)
	if neibs.size() > 1:
		
		var priority_from = []
		var supply_from = []
		for i in range(neibs.size()):
			var n = neibs[i]
			var lower_parent_priority = 0.8
			priority_from.append(n.receive_priority(self) * lower_parent_priority)
			supply_from.append(n.receive_supply(self))
		
		var denoms = []
		for i in range(neibs.size()):
			var denom = 0
			for j in range(neibs.size()):
				if i == j:
					continue
				denom += priority_from[j]
			denoms.append(denom)
		
		for i in range(neibs.size()):
			var supply_to = 0.0
			for j in range(neibs.size()):
				if i == j:
					continue
				supply_to += supply_from[j] * (priority_from[i] / denoms[j])
			neibs[i].send_supply(self, supply_to)
		
		for i in range(neibs.size()):
			neibs[i].send_priority(self, denoms[i] + priority)
	
	elif neibs.size() == 1:
		if on_nodule:
			neibs[0].send_supply(self, nodule_flow)
			neibs[0].send_priority(self, 0.001)
			nodule.resources = max(0.0, nodule.resources - nodule_flow * delta)
			if nodule.resources <= 0.0:
				on_nodule = false
				nodule.queue_free()
				nodule = null
				nodule_flow = 0.0
		else:
			neibs[0].send_priority(self, priority)
			if neibs[0].receive_supply(self) >= 1:
				neibs[0].send_supply(self, 0.0)
			else:
				neibs[0].send_supply(self, 0.5)
	else:
		queue_free()

var time_alive = 0
func _process(delta):
	time_alive += delta
	var growth_speed = max(0, base_speed - time_alive*5.0)
	if is_growing():
		position += neibs[0].get_direction(self) * growth_speed * delta
	elif is_shrinking():
		var is_stuck = false
		for a in $Area2D.get_overlapping_areas():
			if a.get_parent() is Tendril:
				is_stuck = true
		position -= neibs[0].get_direction(self) * base_speed * 0.5 * delta
	
func _neighbour_die(n):
	neibs.erase(n)
	n._neighbour_die(self)
	if neibs.size() == 0:
		queue_free()

func _neighbour_dead(n):
	neibs.erase(n)
	if neibs.size() == 0:
		queue_free()

func _draw():
	if is_tip() and self.global_position.distance_to(mouse_position) < 10:
		draw_circle(Vector2.ZERO, 10, Color.palegreen)

func is_tip():
	return not stuck and not on_nodule and neibs.size() == 1

func is_growing():
	return not stuck and not on_nodule and neibs.size() == 1 and neibs[0].receive_supply(self) >= 1

func is_shrinking():
	return not on_nodule and neibs.size() == 1 and neibs[0].receive_supply(self) < 1

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
		update()
	assert(get_parent().name == "RootNetwork")
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed() and get_parent().click_timer <= 0:
			if is_tip() and self.global_position.distance_to(mouse_position) < 10:
				get_parent().click_timer = 0.2
				spawn_cluster()

func spawn_cluster():
	priority += 1.0
	assert(is_tip())
	var num = randi() % 3 + 3
	print("Spawned", num)
	var spread = TAU / 3
	var start_angle = -TAU/6 + (randf() - 0.5) * TAU / 9
	for i in range(num):
		var angle = start_angle + (float(i)/float(num-1)) * spread
		spawn(angle)

func spawn(direction):
	var fungle_scn = load("res://Fungle.tscn")
	var tendril_scn = load("res://Tendril.tscn")
	var fungle = fungle_scn.instance()
	fungle.position = position + neibs[0].get_direction(self).rotated(direction) * 10.0
	var tendril = tendril_scn.instance()
	fungle.neibs.append(tendril)
	neibs.append(tendril)
	tendril.a = self
	tendril.b = fungle
	get_parent().add_child(tendril)
	get_parent().add_child(fungle)

func _on_Area2D_area_entered(area):
	if area.get_parent() is Tendril:
		for n in neibs:
			if area.get_parent() == n:
				return
		stuck = true
	elif area.get_parent().name.findn("Fungle") != -1:
		stuck = true
	elif area.get_parent().name.findn("Pool") != -1:
		var nod = area.get_parent().get_parent()
		if not nod.connected:
			global_position = area.global_position
			nodule = nod
			on_nodule = true
			nodule_flow = 8.0
			nod.connected = true
		else:
			stuck = true
	elif area.get_parent().name.findn("Rock") != -1:
		stuck = true


func _on_Area2D_area_exited(area):
	if area.get_parent() is Tendril:
		for n in neibs:
			if area.get_parent() == n:
				return
		stuck = false
