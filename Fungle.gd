extends Node2D

export(bool) var active
export(bool) var split

var p
var a = null
var b = null

var p_demand = null
var p_supply = null
var a_demand = null
var a_supply = null
var b_demand = null
var b_supply = null

var direction setget ,get_direction

func get_direction():
	return (p.position - self.position).normalized()

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
