extends Node2D


#probably chain reaction logic, and storing placed bombs here too

#color code the pipe bombs - big pipe in, small pipe out. paired color code

var reaction_started = false

var placed_bombs: Array = []

func evacuate_cell(evac_cell : Vector2i):
	print("EVAC CELL: " + str(evac_cell))

func damage_cell(dmg_cell : Vector2i):
	print("DMG CELL: " + str(dmg_cell))

func place_bomb(bomb_type: String, bomb_coordinate: Vector2i, rots: int = 0):
	var bomb = {
		#"shape_data": 
		#"type" as just "stink", "grenade", "threat", "standard", "fuse", "motion_impact" etc
		"type": bomb_type,
		"coordinate": bomb_coordinate,
		"rotation": rots % 4,
		"state": null,  # could be "idle", "ignited", "exploding", 
		#----these others would be redundant because they are all essentially "exploding" right? 
		#their effect can be additive to the world instead of remaining "alive", 
		#in the case of stinkbomb it can summon a cloud
		#stinky", or maybe moving or something for the weirder ones like airplane and carbomb
		"sprite": null
	}
	
	#--- cast the above to the instantiated bomb class
	
	
	#weird and placeholder but currently functional
	if bomb["type"] == "GRENADE":
		bomb["state"] = "ignited"
	else: 
		bomb["state"] = "idle" 
	
	if bomb["state"] == "idle": #just sprites
		var bomb_sprite: Sprite2D = Sprite2D.new()
		bomb_sprite.texture = load("res://prototype/proto bomb sprites/SPRITE_%s.png" % bomb_type)
		bomb_sprite.position = bomb_coordinate * 64 + Vector2i(32, 32)
		bomb_sprite.rotation = bomb["rotation"] * PI / 2
		add_child(bomb_sprite)
		
		bomb["sprite"] = bomb_sprite
		#once proper graphics installed, edit y position to match building heights
		#conditionally, add extra sprites for pipe bombs and other stuff to help track orientation
		if bomb_type == "PIPE_BOMB" or bomb_type == "ALT_PIPE_BOMB":
			#place the extra sprite in the right spot according to rots
			pass
	
	
	
	
	
	#
	
	placed_bombs.append(bomb) #is placed_bombs necessary if instantiated bombs are child of $Bombs (self)?
	#answer: no. GET RID! now that i have actual bomb class
	
	if reaction_started == false and bomb["type"] == "GRENADE":
		$"../BombTick".start()

func process_chain_reaction(): #this runs every time BombTick runs out
	reaction_started = true
	print("tick")
	$"../BombTick".start()
	
	var new_ignitions: Array = []
	var to_remove: Array = []
	for bomb in placed_bombs:
		if bomb["state"] == "ignited": #then we will explode
			bomb["state"] = "exploding"
			var affected_cells = get_affected_cells(bomb)
			for affected_cell in affected_cells: #damage and evac placeholders
				
				#take type for fuse bomb car etc for composite bombs (if those still exist)
				#then work through each case
				if $"../Map".in_bounds(affected_cell):
					if bomb["type"] == "STINKBOMB":
						evacuate_cell(affected_cell)
					#else:
					# damage
					#composite bombs are STUPID
			
				
				
				#it's actually not causing a chain reaction currently.
				print(str(affected_cell) + "affected cell")
				
			for other in placed_bombs: # ignite or trigger other bombs
				if other["state"] == "idle" and other["coordinate"] in affected_cells:
					if other["type"] == "FUSE":
						other["state"] = "ignited"
					elif other["type"] == "STINKBOMB":
						other["state"] = "stinky"
					else:
						new_ignitions.append(other)
			
			print(str(bomb["state"]))
			$"../Effects".set_effects(affected_cells, bomb["state"])
			to_remove.append(bomb) # mark this bomb for removal

	# update new_ignitions to ignite next tick
	for bomb in new_ignitions:
		bomb["state"] = "ignited"

	# actually remove exploded bombs ?? this looks funky. i might just need line 95 and 96 on their own, without the conditions. idk if to_remove is actually needed
	for bomb in to_remove:
		if bomb["sprite"] != null:
			bomb["sprite"].queue_free()
		placed_bombs.erase(bomb)



func get_affected_cells(bomb: Dictionary):
	var shape_data = get_parent().get(bomb["type"] + "_DATA")

	print(shape_data)
	var rotated_shape: Array[Vector2i] = []

	for item in shape_data:
		var rotated_offset = rotate_offset(item["offset"], bomb["rotation"])
		rotated_shape.append(bomb["coordinate"] + rotated_offset)
	return rotated_shape


func rotate_offset(offset, bomb_rots):
	var new_offset: Vector2i = offset
	for rot in range(bomb_rots):
		new_offset = Vector2i(-new_offset.y, new_offset.x) # clockwise
	return new_offset
