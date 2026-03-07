extends Node2D
class_name Bomb

var type : Bombs.Type
var shape : Array[Vector2i]
var coordinate : Vector2i
var behaviour : int
var rotations : int = 0
var is_ignited : bool = false

var BombsManager : Node2D

# Visuals
var sprite: Sprite2D

func _init(_type: Bombs.Type, _coord: Vector2i, _rotations: int = 0):
	type = _type
	coordinate = _coord
	rotations = _rotations
	behaviour = Bombs.DATA[type].behaviour
	shape = Bombs.DATA[type].shape
	BombsManager = get_parent()

func ignite():
	if not is_ignited:
		is_ignited = true
		# play animated sprite / ignition effect here
		if sprite:
			sprite.modulate = Color(1,0.7,0.7) # temporary visual feedback

func process_tick():
	if is_ignited:
		explode()

func explode():
	
	# tell BombsManager / Map / Effects node
	if BombsManager:
		for offset in shape:
			var affected_cell = coordinate + rotate_offset(offset, rotations)
			BombsManager.notify_cell_hit(affected_cell, behaviour)
			BombsManager.spawn_explosion_effect(coordinate, behaviour)
		BombsManager.play_explosion_sound(coordinate, behaviour)

	queue_free()  # self-destruct after explosion

func rotate_offset(offset: Vector2i, rot: int) -> Vector2i:
	var new_offset = offset
	for i in range(rot):
		new_offset = Vector2i(-new_offset.y, new_offset.x)  # clockwise
	return new_offset
