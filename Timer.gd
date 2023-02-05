extends Label

var timer = 0
var timer_enabled = false


# Called when the node enters the scene tree for the first time.
func _ready():
	timer_enabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer_enabled == true:
		timer += 1*delta
	
	text = "%.1f s" % timer
	update()


func _on_Timer_gui_input(event):
	pass # Replace with function body.
