extends Node2D



var animated_effect_scene : PackedScene = preload("res://polished/animation/animated_effect.tscn")

var value_popup : PackedScene = preload("res://polished/animation/value_popup.tscn")

func play_sound(coordinate, behaviour):
	print("play " + str(Bombs.Behaviour.find_key(behaviour)) + "sound at " + str(coordinate))

func spawn_value_popup(coordinate, value): #WIP FINISH THIS.
	var value_popup_instance = value_popup.instantiate()
	value_popup_instance.value = value
	
	#gate this so it doesn't overreach the borders of screen
	value_popup_instance.position = Vector2i(32,32) + coordinate * 64 
	
	add_child(value_popup_instance)

func spawn_effect(coordinate: Vector2i, behaviour: Bombs.Behaviour) -> void:
	var animated_effect_instance = animated_effect_scene.instantiate()
	
	animated_effect_instance.animation = "%s" % Bombs.Behaviour.find_key(behaviour)
	animated_effect_instance.position = Vector2i(32,32) + coordinate * 64
	
	add_child(animated_effect_instance)
	
	# add particles based on matching cell coordinate
