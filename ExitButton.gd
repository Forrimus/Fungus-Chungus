extends Node2D
enum ButtonType { Exit50, Exit85 }
export(ButtonType) var type

var mouse_position = Vector2.ZERO




func _process(delta):
	if self.global_position.distance_to(mouse_position) < 50:
		pass
	if type == ButtonType.Exit50:
		$"Exit50".visible = true
		$"Exit85".visible = false
	elif type == ButtonType.Exit85:
		$"Exit85".visible = true
		$"Exit50".visible = false
