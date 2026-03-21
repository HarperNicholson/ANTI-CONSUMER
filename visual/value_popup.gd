extends Node2D

#this should only happen when a building dies!

@onready var yposstart = global_position.y

var value : int = 0
#need to pool across ticks too. in another script.

func _ready() -> void: #can only run once even when this object is instantiated. 
	if value <= 0:
		queue_free()
	
	$SubViewportContainer/SubViewport/Label.text = str(value)
	
	#randomize offset x and y
	
	$SubViewportContainer.material = $SubViewportContainer.material.duplicate()
	$SubViewportContainer.material.set_shader_parameter("offset", Vector2(randf(), randf()))
	
	var tween := create_tween()
	
	#tween the text up by 10s with value from 0
	tween_text_value_up_by_tens_from_zero()
	
	#this is rough tween you can tweak it
	tween.tween_property(self, "scale", Vector2.ONE, 1.0).from(Vector2.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(self, "global_position:y", clampf(yposstart - 75.0, 75.0, 700.0), 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property($SubViewportContainer.material,"shader_parameter/burn_size",0.5,0.5)
	
	tween.tween_property($SubViewportContainer.material,"shader_parameter/dissolve_value",0.0,1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_callback(func():queue_free())


func tween_text_value_up_by_tens_from_zero():
	var label = $SubViewportContainer/SubViewport/Label
	
	label.text = "$0"
	label.show()

	var t := create_tween()

	t.tween_method(
		func(v):
			var display := int(v / 10.0) * 10
			label.text = "$%d" % display,
		0, value, 0.5)

	t.tween_callback(func():
		label.text = "$%d" % value
	)
