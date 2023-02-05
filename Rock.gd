tool
extends Node2D

var _type


func _ready():
	_type = rand_range(0, get_children().size() - 1)
	for c in get_children():
		c.visible = false
	get_children()[_type].visible = true

func _process(delta):
	for c in get_children():
		if c.visible:
			for a in c.get_node("Area2D").get_overlapping_areas():
				if a.get_parent().name.findn("Pool") != -1:
					queue_free()
