extends Node2D


func _ready():
	var fungle_scn = load("res://Fungle.tscn")
	var tendril_scn = load("res://Tendril.tscn")
	
	var nodule = fungle_scn.instance()
	var tendril = tendril_scn.instance()
	var tip = fungle_scn.instance()
	tendril.a = nodule
	tendril.b = tip
	tip.neibs.append(tendril)
	nodule.neibs.append(tendril)
	
	nodule.on_nodule = true
	nodule.nodule_flow = 50.0
	
	tip.position = nodule.position + Vector2.UP.rotated(-TAU/3) * 10.0
	
	add_child(nodule)
	add_child(tendril)
	add_child(tip)

func _process(delta):
	for c in get_children():
		if c is Fungle:
			c.propagate_before_update(null, delta)
			break
	for c in get_children():
		if c is Fungle:
			c.propagate_after_update(null, delta)
			break
		
