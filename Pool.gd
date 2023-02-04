tool
extends Node2D
signal Empty
enum PoolType { Pool1, Pool2 }
export(PoolType) var type

var Resources  = rand_range(50, 250)

func _process(delta):
	if type == PoolType.Pool1:
		$"Pool 1".visible = true
		$"Pool 2".visible = false
	elif type == PoolType.Pool2:
		$"Pool 2".visible = true
		$"Pool 1".visible = false
	
	self.scale.x = Resources / 100
	self.scale.y = Resources / 100
	
	if Resources <= 0:
		emit_signal("Empty")
		queue_free()
