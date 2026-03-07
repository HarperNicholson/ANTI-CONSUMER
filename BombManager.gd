extends Node2D

var effect_scene : PackedScene = preload("res://polished/animation/animated_effect.tscn")



func spawn_bomb(type: Bombs.Type, coord: Vector2i, rots: int = 0) -> void:
	var bomb = Bomb.new(type, coord, rots)
	add_child(bomb)
	
	# optional: add a sprite for tactical view
	bomb.sprite = Sprite2D.new()
	bomb.sprite.texture = load("res://prototype/proto bomb sprites/SPRITE_%s.png" % str(type))
	bomb.sprite.position = Vector2(32,32)
	bomb.sprite.rotation = rots * PI/2
	bomb.add_child(bomb.sprite)

func process_tick() -> void:
	for bomb in get_children():  # iterate all live bombs
		bomb.process_tick()

# Called by bombs
func notify_cell_hit(cell: Vector2i, behaviour: int) -> void:
	#should damage_map_cell_at(cell)
	var other_bomb = get_bomb_at(cell)
	if other_bomb and not other_bomb.is_ignited:
		other_bomb.ignite()

func spawn_explosion_effect(cell: Vector2i, behaviour: int) -> void:
	var explosion_effect_instance = effect_scene.instantiate()
	explosion_effect_instance.position = Vector2i(32,32) * cell
	add_child(explosion_effect_instance)
	#may use behaviour to determine effect animation
	# add particles

func play_explosion_sound(cell: Vector2i, behaviour: int) -> void:
	pass
	# play SFX

# optional helper: fast lookup
func get_bomb_at(cell: Vector2i) -> Bomb:
	for bomb in get_children():
		if bomb.coordinate == cell:
			return bomb
	return null
