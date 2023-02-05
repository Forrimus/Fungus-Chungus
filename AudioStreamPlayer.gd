extends AudioStreamPlayer
func _ready():
	play(23.0)
	var s: AudioStreamMP3 = stream
	s.loop = true
	s.loop_offset = 23.0
