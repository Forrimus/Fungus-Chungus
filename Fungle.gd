extends Node2D
class_name Fungle

var fungle = load("res://Fungle.tscn")

const deg120 = TAU / 3.0
const start_length = 3.0
const base_speed = 10.0
const min_width = 3.0

var mouse_position = Vector2.ZERO

func get_direction():
	return (position - p.position).normalized()

var before_updated = false
func propagate_before_update(from):
	after_updated = false
	if not before_updated:
		if from == null:
			if p != null:
				p.propagate_before_update(self)
			if a != null:
				a.propagate_before_update(self)
			if b != null:
				b.propagate_before_update(self)
		elif from == p:
			if a != null:
				a.propagate_before_update(self)
			if b != null:
				b.propagate_before_update(self)
		elif from == a:
			if b != null:
				b.propagate_before_update(self)
		_before_update()
	before_updated = true

var after_updated = false
func propagate_after_update(from):
	before_updated = false
	if not after_updated:
		if from == null:
			if p != null:
				p.propagate_after_update(self)
			if a != null:
				a.propagate_after_update(self)
			if b != null:
				b.propagate_after_update(self)
		elif from == p:
			if a != null:
				a.propagate_after_update(self)
			if b != null:
				b.propagate_after_update(self)
		elif from == a:
			if b != null:
				b.propagate_after_update(self)
		_after_update()
	after_updated = true

var growing = false
var shrinking = false
var on_nodule = false
var nodule_flow = 0.0
var staging = {
	'supply_to_p': 0.0,
	'supply_to_a': 0.0,
	'supply_to_b': 0.0,
	'priority_to_p': 0.0,
	'priority_to_a': 0.0,
	'priority_to_b': 0.0,
}
var extra_priority = 0.0
func _before_update():
	if on_nodule:
		assert(p != null)
		assert(a == null)
		assert(b == null)
		staging.priority_to_p = 0.01
		staging.supply_to_p = nodule_flow
	elif p != null and a != null and b != null:
		growing = false
		shrinking = false
		var p_priority = p.priority_to(self)
		var a_priority = a.priority_to(self)
		var b_priority = b.priority_to(self)
		
		var supply_from_p = p.supply_to(self)
		var supply_from_a = a.supply_to(self)
		var supply_from_b = b.supply_to(self)
		
		var ab_priority = a_priority + b_priority
		var pa_priority = p_priority + a_priority
		var pb_priority = p_priority + b_priority
		
		staging.supply_to_p = supply_from_a * (p_priority / pb_priority) + supply_from_b * (p_priority / pa_priority)
		staging.supply_to_a = supply_from_p * (a_priority / ab_priority) + supply_from_b * (a_priority / pa_priority)
		staging.supply_to_b = supply_from_p * (b_priority / ab_priority) + supply_from_a * (b_priority / pb_priority)
		
		staging.priority_to_p = a_priority + b_priority + extra_priority
		staging.priority_to_a = p_priority + b_priority + extra_priority
		staging.priority_to_b = p_priority + a_priority + extra_priority
		
	elif p != null and a != null:
		growing = false
		shrinking = false
		var p_priority = p.priority_to(self)
		var a_priority = a.priority_to(self)
		
		staging.supply_to_p = a.supply_to(self)
		staging.supply_to_a = p.supply_to(self)
		
		staging.priority_to_p = a_priority + extra_priority
		staging.priority_to_a = p_priority + extra_priority
	elif p != null:
		var net_supply = p.supply_to(self)
		if net_supply >= 1.0:
			# growing
			growing = true
			shrinking = false
			staging.supply_to_p = 0.0
		else:
			growing = false
			shrinking = true
			staging.supply_to_p = 0.5
		staging.priority_to_p = priority_to_p
		
func _after_update():
	supply_to_p = staging.supply_to_p
	supply_to_a = staging.supply_to_a
	supply_to_b = staging.supply_to_b
	priority_to_p = staging.priority_to_p
	priority_to_a = staging.priority_to_a
	priority_to_b = staging.priority_to_b

func remove_neighbour(node):
	if node == p:
		p = null
	elif node == a:
		a = null
	elif node == b:
		b = null

func _process(delta):
	
	if growing:
		position += get_direction() * base_speed * delta
		update()
	elif shrinking:
		position -= get_direction() * base_speed * delta
		update()
		if global_position.distance_to(p.global_position) < 0.1:
			queue_free()
			p.remove_neighbour(self)
			p = null
	if growing or shrinking:
		priority_to_p = max(0.00001, priority_to_p * 0.99)
	update()
	
		
func _draw():
	if p != null and not on_nodule:
		var c = (log(p.supply_to(self)) + 4.0) / 8.0
		draw_line(Vector2.ZERO, p.global_position - self.global_position, Color(c, c, c), min_width)
	if growing and self.global_position.distance_to(mouse_position) < 20:
		draw_circle(Vector2.ZERO, 20, Color.palegreen)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
		
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			
			if growing and self.global_position.distance_to(mouse_position) < 20:
				a = fungle.instance()
				b = fungle.instance()
				a.position = position + get_direction().rotated(TAU/6) * 3.0
				b.position = position + get_direction().rotated(-TAU/6) * 3.0
				a.p = self
				b.p = self
				get_parent().add_child(a)
				get_parent().add_child(b)
				

var supply_to_p = 0.0
var supply_to_a = 0.0
var supply_to_b = 0.0
func supply_to(node):
	if node == p:
		return supply_to_p
	if node == a:
		return supply_to_a
	if node == b:
		return supply_to_b
	

var priority_to_p = 1.0
var priority_to_a = 0.0
var priority_to_b = 0.0
func priority_to(node):
	if node == p:
		return priority_to_p
	if node == a:
		return priority_to_a
	if node == b:
		return priority_to_b

var p: Fungle = null setget set_p
func set_p(node):
	if node == null:
		if b != null:
			p = b
			b = null
		elif a != null:
			b = a
			set_a(null)
	else:
		p = node

var a: Fungle setget set_a
func set_a(node):
	if node == null:
		if b != null:
			a = b
			b = null
	else:
		a = node

var b: Fungle = null

var node_count = 0
func set_node_count():
	var nc = 0
	if p != null:
		nc += 1
	if a != null:
		nc += 1
	if b != null:
		nc += 1
	node_count = nc
