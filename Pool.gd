extends Node2D
signal Empty
enum PoolType { Pool1, Pool2 }
export(PoolType) var type

var max_resources  = rand_range(50, 250)
var resources = max_resources

func _process(delta):
	if type == PoolType.Pool1:
		$"Pool 1".visible = true
		$"Pool 2".visible = false
	elif type == PoolType.Pool2:
		$"Pool 2".visible = true
		$"Pool 1".visible = false
	
	var scale_base_min = 0.3
	var scale_base_max = 1.2
	
	var scale_base = (max_resources - 50)/(250 - 50) * (1.2 - 0.3) + 0.3
	
	var scale = sqrt(resources / max_resources) * scale_base
	
	self.scale.x = scale
	self.scale.y = scale
