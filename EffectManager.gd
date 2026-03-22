extends Node2D

var EffectsNode : Node2D
var MapNode : Node2D


var animated_effect_scene : PackedScene = preload("res://polished/animation/animated_effect.tscn")
var value_popup_scene : PackedScene = preload("res://polished/animation/value_popup.tscn")
var explosion_particle_effect_scene : PackedScene = preload("res://polished/animation/explosion_particle_effect.tscn")
var blood_splat_particle_effect_scene : PackedScene = preload("res://polished/animation/blood_splat_particle_effect.tscn")
var blood_pool_particle_effect_scene : PackedScene = preload("res://polished/animation/blood_pool_particle_effect.tscn")
var limb_scene : PackedScene = preload("res://polished/animation/limb.tscn")


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
	animated_effect_instance.global_position = Vector2i(32,32) + coordinate * 64
	
	EffectsNode.add_child(animated_effect_instance)

func spawn_particle_effect(cell_coordinate: Vector2i):
	# ooooh.... but what if they had shadows...... they need it.
	var explosion_particle_effect_instance = explosion_particle_effect_scene.instantiate()
	
	var affected_cell_material = MapNode.get_cell_material(cell_coordinate)
	
	match affected_cell_material:
		MapNode.MATERIAL_TYPES.CONCRETE: explosion_particle_effect_instance.color = Color.GRAY
		MapNode.MATERIAL_TYPES.WOOD: explosion_particle_effect_instance.color = Color.SADDLE_BROWN
		MapNode.MATERIAL_TYPES.DIRT: explosion_particle_effect_instance.color = Color("360a00")
		MapNode.MATERIAL_TYPES.SAND: explosion_particle_effect_instance.color = Color.WHEAT
		MapNode.MATERIAL_TYPES.WATER: explosion_particle_effect_instance.color = Color.LIGHT_BLUE
	
	
	explosion_particle_effect_instance.emitting = true
	explosion_particle_effect_instance.global_position = Vector2i(32,32) + cell_coordinate * 64
	
	
	EffectsNode.add_child(explosion_particle_effect_instance)

func spawn_blood_splat_particle_effect(_position : Vector2):
	
	var blood_splat_particle_effect_instance = blood_splat_particle_effect_scene.instantiate()
	
	blood_splat_particle_effect_instance.emitting = true
	blood_splat_particle_effect_instance.global_position = _position
	
	EffectsNode.add_child(blood_splat_particle_effect_instance)

func spawn_blood_pool_particle_effect(_position : Vector2):
	
	var blood_pool_particle_effect_instance = blood_pool_particle_effect_scene.instantiate()
	
	blood_pool_particle_effect_instance.emitting = true
	blood_pool_particle_effect_instance.global_position = _position
	
	EffectsNode.add_child(blood_pool_particle_effect_instance)

func set_limb_physics(limb):
	limb.vel = Vector2(randf_range(-50,50), randf_range(-80,80))
	limb.vz = randf_range(180,260)
	limb.rot_v = randf_range(-50,50)

func spawn_limb(from: Sprite2D):
	var limb = limb_scene.instantiate()
	
	limb.texture = from.texture
	limb.self_modulate = from.self_modulate
	limb.global_position = from.global_position
	limb.scale = from.scale * 4.0
	limb.rotation = from.global_rotation
	
	set_limb_physics(limb)
	
	EffectsNode.add_child(limb)

func spawn_head(head: Sprite2D, hair: Sprite2D, hat: Sprite2D):
	var limb = limb_scene.instantiate()
	limb.global_position = head.global_position
	limb.scale = Vector2(4.0,4.0)
	
	# new head sprite
	var new_head = Sprite2D.new()
	new_head.texture = head.texture
	new_head.self_modulate = head.self_modulate
	new_head.scale = head.scale
	
	# new hair
	var new_hair = Sprite2D.new()
	new_hair.texture = hair.texture
	new_hair.self_modulate = hair.self_modulate
	new_hair.position = hair.position
	new_hair.visible = hair.visible
	
	# new hat
	var new_hat = Sprite2D.new()
	new_hat.texture = hat.texture
	new_hat.self_modulate = hat.self_modulate
	new_hat.position = hat.position
	new_hat.visible = hat.visible
	
	# build hierarchy
	limb.add_child(new_head)
	new_head.add_child(new_hair)
	new_head.add_child(new_hat)
	
	# physics
	set_limb_physics(limb)
	
	EffectsNode.add_child(limb)
