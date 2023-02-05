extends Node2D
class_name Tendril

const min_width = 3.0

var a
var b

var supply_from_a = null
var supply_from_b = null
var supply_to_a = 0.0
var supply_to_b = 0.0
func receive_supply(node):
	if node == a:
		return supply_to_a
	else:
		return supply_to_b
func send_supply(node, val):
	if node == a:
		supply_from_a = val
	else:
		supply_from_b = val

var priority_from_a = null
var priority_from_b = null
var priority_to_a = 1.0
var priority_to_b = 1.0
func receive_priority(node):
	if node == a:
		return priority_to_a
	else:
		return priority_to_b
func send_priority(node, val):
	if node == a:
		priority_from_a = val
	else:
		priority_from_b = val

func other(node):
	if node == a:
		return b
	if node == b:
		return a

func get_direction(node):
	if node == a:
		return (a.position - b.position).normalized()
	else:
		return (b.position - a.position).normalized()

func get_length():
	return (a.position - b.position).length()

func propagate_before_update(from, delta):
	if from == a:
		b.propagate_before_update(self, delta)
	if from == b:
		a.propagate_before_update(self, delta)

func propagate_after_update(from, delta):
	if from == a:
		b.propagate_after_update(self, delta)
	if from == b:
		a.propagate_after_update(self, delta)
	
	supply_to_a = supply_from_b
	supply_from_b = null
	supply_to_b = supply_from_a
	supply_from_a = null
	priority_to_a = priority_from_b
	priority_from_b = null
	priority_to_b = priority_from_a
	priority_from_a = null


func _ready():
	$Area2D/CollisionShape2D.shape = $Area2D/CollisionShape2D.shape.duplicate()

func _process(delta):
	update()
	position = (a.position + b.position) / 2.0
	rotation = (b.global_position - a.global_position).angle()
	$"Area2D/CollisionShape2D".shape.extents = Vector2(get_length() / 2.0, 1.0)
	
	var length = (a.position - b.position).length()
	if length < 0.1:
		a._neighbour_die(self)
		b._neighbour_die(self)

func _neighbour_die(from):
	if from == a:
		b._neighbour_dead(self)
	if from == b:
		a._neighbour_dead(self)
	queue_free()

func _draw():
	var net_supply = abs(supply_to_a - supply_to_b)
	var c = (log(net_supply) + 2.0) / 6.0 + 0.3
	draw_line(to_local(a.global_position), to_local(b.global_position), Color(c, c, 0.7), min_width)
	
	
