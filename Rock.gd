tool
extends Node2D

var _type
#export(int) var type setget set_type, get_type

#func set_type(val):
#	if val >= get_children().size():
#		val = 0
#	elif  val <= -1:
#		val = max(0, get_children().size() - 1)
#	_type = val
#	if get_children().size() > 0:
		
#func get_type():
#	return _type

func _ready():
	_type = rand_range(0, get_children().size() - 1)
	for c in get_children():
		c.visible = false
	get_children()[_type].visible = true

#func _process(delta):
#	type = rand_range(0, get_children().size() - 1)
