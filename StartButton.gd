extends Node2D
enum ButtonType { Start50, Start85 }
export(ButtonType) var type

var mouse_position = Vector2.ZERO




func _process(delta):
	if self.global_position.distance_to(mouse_position) < 50:
		pass
	if type == ButtonType.Start50:
		$"Start50".visible = true
		$"Start85".visible = false
	elif type == ButtonType.Start85:
		$"Start85".visible = true
		$"Start50".visible = false
