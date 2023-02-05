extends Node2D


func _ready():
	randomize()
	var fungle_scn = load("res://Fungle.tscn")
	var tendril_scn = load("res://Tendril.tscn")
	var pool_scn = load("res://Pool.tscn")
	
	var nodule = fungle_scn.instance()
	var tendril = tendril_scn.instance()
	var tip = fungle_scn.instance()
	var pool = pool_scn.instance()
	tendril.a = nodule
	tendril.b = tip
	tip.neibs.append(tendril)
	nodule.neibs.append(tendril)
	
	nodule.on_nodule = true
	nodule.nodule_flow = 10.0
	nodule.nodule = pool
	
	tip.position = nodule.position + Vector2.UP.rotated(TAU/3) * 100.0
	
	add_child(pool)
	pool.resource_override = 300
	add_child(nodule)
	add_child(tendril)
	add_child(tip)

var click_timer = 0.0
func _process(delta):
	click_timer -= delta
	for c in get_children():
		if c is Fungle:
			c.propagate_before_update(null, delta)
			break
	for c in get_children():
		if c is Fungle:
			c.propagate_after_update(null, delta)
			break
		
	var any_tips = false
	for c in get_children():
		if c is Fungle and c.is_tip():
			any_tips = true
	if not any_tips:
		# game over
		get_parent().get_node("AudioStreamPlayer").stop()
	
	if Input.is_action_just_pressed("Escape"):        #Quit Game
		get_tree().quit()
