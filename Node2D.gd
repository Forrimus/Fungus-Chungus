extends Node2D

var pool_scn = preload("res://Pool.tscn")
var big_rock_scn = preload("res://Big_Rock.tscn")
var small_rock_scn = preload("res://Small_Rock.tscn")

func _ready():
	print("Here")
	for i in range(0):
		var pool = pool_scn.instance()
		pool.position.x = rand_range($ExtentA.position.x, $ExtentB.position.x)
		pool.position.y = rand_range($ExtentA.position.y, $ExtentB.position.y)
		add_child(pool)
	
	for i in range(25):
		var rock = big_rock_scn.instance()
		rock.position.x = rand_range($ExtentA.position.x, $ExtentB.position.x)
		rock.position.y = rand_range($ExtentA.position.y, $ExtentB.position.y)
		add_child(rock)
	
	for i in range(25):
		var rock = small_rock_scn.instance()
		rock.position.x = rand_range($ExtentA.position.x, $ExtentB.position.x)
		rock.position.y = rand_range($ExtentA.position.y, $ExtentB.position.y)
		add_child(rock)

func _process(delta):
	
	var any_pools = false
	for c in get_children():
		if c.name.findn("Pool") != -1:
			any_pools = true
	if not any_pools:
		get_parent().get_node("Timer").timer_enabled = false
		$Label.visible = true
