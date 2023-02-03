extends Node2D

var deg120 = TAU / 3.0

var mouse_position = Vector2.ZERO

var points = [
	{ 'active': false, 'flow': 100, 'on_nodule': true, 'nodule_power': 100, 'parent': Vector2.ZERO, 'length': 30.0, 'direction': Vector2.UP },
	{ 'active': true, 'flow': 0, 'parent': Vector2.ZERO, 'length': 0.0, 'direction': Vector2.UP.rotated(deg120) },
	{ 'active': true, 'flow': 0, 'parent': Vector2.ZERO, 'length': 0.0, 'direction': Vector2.UP.rotated(-deg120) },
]

export(Color) var linecolor = Color.whitesmoke
export(float) var min_width = 3.0
export(float) var base_speed = 8.0


func _draw():

	for p in points:
		var point = p.parent + p.direction * p.length
		draw_line(p.parent, point, linecolor, min_width)
		if p.active and point.distance_to(mouse_position) < 20:
			var color = Color(max(0, 100 - p.flow), max(0, p.flow+100), 50)
			draw_circle(point, 20, color)

func _process(delta):
	for p in points:
		if p.active:
			p.length += base_speed * delta
	update()


func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position - self.global_position
		
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			var clicked_points = []
			for i in range(len(points)):
				var p = points[i]
				if p.active:
					var point = p.parent + p.direction * p.length
					if point.distance_to(mouse_position) < 20:
						clicked_points.append(i)
			for i in clicked_points:
				var p = points[i]
				var point = p.parent + p.direction * p.length
				p.active = false
				points.append({
					'active': true,
					'parent': point,
					'length': 0.0,
					'direction': p.direction.rotated(TAU/6),
				})
				points.append({
					'active': true,
					'parent': point,
					'length': 0.0,
					'direction': p.direction.rotated(-TAU/6),
				})
				
