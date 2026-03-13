extends Node2D
class_name Bomb

var type : Bombs.Type
var shape : Array
var coordinate : Vector2i
var behaviour : int
var rotations : int = 0
var is_ignited : bool = false
var fuseticks : int = 1

var BombManager : Node2D
var EffectManager : Node2D

# Visuals
var tactical_sprite : Sprite2D
var ortho0 : Sprite2D
var ortho1 : Sprite2D
var ortho2 : Sprite2D
var ortho3 : Sprite2D

func _init(_type: Bombs.Type, _coord: Vector2i, _rotations: int = 0):
	type = _type
	coordinate = _coord
	rotations = _rotations
	behaviour = Bombs.DATA[type]["behaviour"]
	shape = Bombs.DATA[type]["shape"]
	match type:
		Bombs.Type.GRENADE: is_ignited = true
		Bombs.Type.AIRPLANE: is_ignited = true
		Bombs.Type.BOMB_THREAT: is_ignited = true

func ignite():
	if not is_ignited:
		is_ignited = true
		# play animated sprite / ignition effect here

func process_tick():
	if is_ignited:
		if fuseticks > 0:
			fuseticks -= 1
			return
		activate()


func activate():
	match behaviour:
		Bombs.Behaviour.EXPLODE:
			explode()
		Bombs.Behaviour.STINKY:
			stinky()
		Bombs.Behaviour.IMPACT:
			impact()
		Bombs.Behaviour.IMPACT_AIR:
			impact_air()
		Bombs.Behaviour.THREAT:
			threat()
		Bombs.Behaviour.FUSE:
			fuse()
		Bombs.Behaviour.GRENADE:
			grenade()




# can I just reuse local shape or something and get rid of this probably but works perfectly fine
func rotate_offset(offset: Vector2i, rot: int) -> Vector2i:
	var new_offset = offset
	for i in range(rot):
		new_offset = Vector2i(-new_offset.y, new_offset.x)  # clockwise
	return new_offset

var burned_value : int = 0

func explode():
	if BombManager:
		for offset in shape:
			var affected_cell = coordinate + rotate_offset(offset, rotations)
			BombManager.notify_cell_hit(affected_cell, self)
			EffectManager.spawn_effect(affected_cell, behaviour)
		EffectManager.play_sound(coordinate, behaviour)
		EffectManager.spawn_value_popup(coordinate, burned_value) 
	queue_free()  # self-destruct after explosion




#func play_explosion_sound(coordinate: Vector2i, behaviour: int) -> void:
	#print("BOOM!!" + str(coordinate) + str (behaviour))
	## play SFX


func stinky():
	print("stinky")
	pass

func threat():
	print("threat")
	pass

func impact():
	print("impact")
	pass


func impact_air(): 
	print("impact_air")
	#spawn plane
	#plane flies
	#impact
	#BombManager.notify_cell_hit(affected_cell, behaviour)
	#BombManager.spawn_explosion_effect(coordinate, behaviour)
	#BombManager.play_explosion_sound(coordinate, behaviour)
	pass

func fuse():
	print("fuse")
	pass

func grenade():
	print("grenade")
	#start drop animation
	##(matched to tick? I think they could run asynchronous..) let's not hard code and maybe I'll end up with redstone
	#on land
	explode()
