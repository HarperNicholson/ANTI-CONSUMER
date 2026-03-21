extends Node2D

var EffectsNode : Node2D
var MapNode : Node2D


var animated_effect_scene : PackedScene = preload("res://polished/animation/animated_effect.tscn")
var value_popup_scene : PackedScene = preload("res://polished/animation/value_popup.tscn")
var explosion_particle_effect_scene : PackedScene = preload("res://polished/animation/explosion_particle_effect.tscn")

func play_sound(coordinate, behaviour):
	print("play " + str(Bombs.Behaviour.find_key(behaviour)) + "sound at " + str(coordinate))

func spawn_value_popup(coordinate, value): #WIP FINISH THIS.
	var value_popup_instance = value_popup_scene.instantiate()
	value_popup_instance.value = value
	
	#gate this so it doesn't overreach the borders of screen
	value_popup_instance.position = Vector2i(32,32) + coordinate * 64 
	
	EffectsNode.add_child(value_popup_instance)

func spawn_animated_effect(coordinate: Vector2i, behaviour: Bombs.Behaviour) -> void:
	var animated_effect_instance = animated_effect_scene.instantiate()
	
	
	animated_effect_instance.animation = "%s" % Bombs.Behaviour.find_key(behaviour)
	animated_effect_instance.position = Vector2i(32,32) + coordinate * 64
	
	EffectsNode.add_child(animated_effect_instance)

func spawn_particle_effect(cell_coordinate: Vector2i):
	
	var explosion_particle_effect_instance = explosion_particle_effect_scene.instantiate()
	
	var affected_cell_material = MapNode.get_cell_material(cell_coordinate)
	
	match affected_cell_material:
		MapNode.MATERIAL_TYPES.CONCRETE: explosion_particle_effect_instance.color = Color.GRAY
		MapNode.MATERIAL_TYPES.WOOD: explosion_particle_effect_instance.color = Color.SADDLE_BROWN
		MapNode.MATERIAL_TYPES.DIRT: explosion_particle_effect_instance.color = Color("360a00")
		MapNode.MATERIAL_TYPES.SAND: explosion_particle_effect_instance.color = Color.WHEAT
		MapNode.MATERIAL_TYPES.WATER: explosion_particle_effect_instance.color = Color.LIGHT_BLUE
	
	
	explosion_particle_effect_instance.position = Vector2i(32,32) + cell_coordinate * 64
	explosion_particle_effect_instance.emitting = true
	
	EffectsNode.add_child(explosion_particle_effect_instance)
