extends Node2D

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
	
	#this is rough tween you can tweak it
	tween.tween_property(self, "scale", Vector2.ONE, 1.0).from(Vector2.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(self, "global_position:y", clampf(yposstart - 75.0, 75.0, 700.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property($SubViewportContainer.material,"shader_parameter/burn_size",0.5,0.5)
	
	tween.tween_property($SubViewportContainer.material,"shader_parameter/dissolve_value",0.0,1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_callback(func():queue_free())
