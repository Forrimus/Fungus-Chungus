extends Node2D

const fungle = preload("res://Fungle.tscn")

func _ready():
	
	var nodule = fungle.instance()
	var tendril = fungle.instance()
	
	nodule.on_nodule = true
	nodule.nodule_flow = 50.0
	
	tendril.set_p(nodule)
	nodule.set_p(tendril)
	
	tendril.position = nodule.position + Vector2.UP.rotated(-TAU/3) * 10.0
	
	add_child(nodule)
	add_child(tendril)

func _process(delta):
	for c in get_children():
		if c is Fungle:
			c.propagate_before_update(null)
			break
	for c in get_children():
		if c is Fungle:
			c.propagate_after_update(null)
			break
	
	if Input.is_action_just_pressed("Escape"):        #Quit Game
		get_tree().quit()
		
