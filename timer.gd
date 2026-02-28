extends Label

var elapsed_time := 0.0

var midnightMode := false    # toggle this to enable countdown
var countdown_time := 600.0  # 10 minutes in seconds

func _process(delta: float) -> void:
	if midnightMode:
		countdown_time = max(countdown_time - delta, 0)
		text = format_time(countdown_time)
		if countdown_time <= 0:
			explode()
	else:
		elapsed_time += delta
		text = format_time(elapsed_time)

func format_time(seconds: float) -> String:
	var ms = int((seconds - floor(seconds)) * 1000)
	var s = int(seconds) % 60
	@warning_ignore("integer_division")
	var m = (int(seconds) / 60) % 60
	@warning_ignore("integer_division")
	var h = int(seconds) / 3600
	return "%02d:%02d:%02d:%03d" % [h, m, s, ms]

func explode() -> void:
	print("BOOM!")
	# explode the nuke
