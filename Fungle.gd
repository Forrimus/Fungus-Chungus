extends Node2D
class_name Fungle

const deg120 = TAU / 3.0
const start_length = 3.0
const base_speed = 10.0

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
var nodule_flow = 0.0
var priority = 1.0
func _before_update(delta):
	
	if neibs.size() > 1:
		priority = 0.2
		var priority_from = []
		var supply_from = []
		for n in neibs:
			priority_from.append(n.receive_priority(self))
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
	
	else:
		assert(neibs.size() == 1)
		
		if on_nodule:
			neibs[0].send_supply(self, nodule_flow)
			neibs[0].send_priority(self, 0.01)
		else:
			priority = max(0.1, priority * 0.995)
			neibs[0].send_priority(self, priority)
			if neibs[0].receive_supply(self) >= 1:
				neibs[0].send_supply(self, 0.0)
			else:
				neibs[0].send_supply(self, 0.5)

func _process(delta):
	if is_growing():
		position += neibs[0].get_direction(self) * base_speed * delta
	elif is_shrinking():
		position -= neibs[0].get_direction(self) * base_speed * 0.8 * delta
	
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
	if is_growing() and self.global_position.distance_to(mouse_position) < 10:
		draw_circle(Vector2.ZERO, 10, Color.palegreen)

func is_growing():
	return not stuck and not on_nodule and neibs.size() == 1 and neibs[0].receive_supply(self) >= 1

func is_shrinking():
	return not on_nodule and neibs.size() == 1 and neibs[0].receive_supply(self) < 1

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
		update()
		
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			if is_growing() and self.global_position.distance_to(mouse_position) < 10:
				spawn_cluster()

func spawn_cluster():
	assert(is_growing())
	var num = randi() % 2 + randi() % 2 + randi() % 2 + 1
	print("Spawned", num)
	var spread = TAU / 3
	var start_angle = -TAU/6 + (randf() - 0.5) * TAU / 9
	for i in range(num+1):
		var angle = start_angle + (float(i)/float(num)) * spread
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
	if not area.get_parent() is Tendril:
		return
	for n in neibs:
		if area.get_parent() == n:
			return
	print("Collision")
	stuck = true
