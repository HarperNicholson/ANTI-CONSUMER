extends Node2D

var MapNode : Node2D


func spawn_bomb(type: Bombs.Type, coord: Vector2i, rots: int = 0) -> void:
	var bomb = Bomb.new(type, coord, rots)
	add_child(bomb)
	bomb.BombManager = self
	bomb.position = Vector2i(32,32) + coord * 64
	bomb.rotation = rots * PI/2
	
	# also add a sprite for tactical view
	
	bomb.tactical_sprite = Sprite2D.new()
	var _name = Bombs.Type.find_key(type)
	#so, if preloaded sprite in table lookup is not null, spawn it. otherwise fuckyu
	bomb.tactical_sprite.texture = load("res://prototype/bomb/SPRITE_%s.png" % _name) #should have this preloaded!
	#but also.... it's so much work...
	#and odds are... the amount of bombs loaded will be less than loading the entire spritebase....
	bomb.add_child(bomb.tactical_sprite)



func process_tick() -> void:
	print("tick")
	for bomb in get_children():  # iterate all live bombs
		bomb.process_tick()

# Called by bombs. 
func notify_cell_hit(coordinate: Vector2i) -> void:
	var cell_at_coordinate : Node2D = MapNode.MapArray[coordinate.x][coordinate.y]
	
	
	cell_at_coordinate.take_damage()
	
	var other_bomb = get_bomb_at(coordinate)
	if other_bomb and not other_bomb.is_ignited:
		other_bomb.ignite()


# optional helper: fast lookup
func get_bomb_at(cell: Vector2i) -> Bomb:
	for bomb in get_children():
		if bomb.coordinate == cell:
			return bomb
	return null
