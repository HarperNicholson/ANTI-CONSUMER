extends Node2D

var player_bombs_left = 10

var selected_bomb

###var bombButtonTypes : Array = [BOMB_TYPES.pick_random(), BOMB_TYPES.pick_random(), BOMB_TYPES.pick_random()]
 
var anchor_tile : Vector2i = Vector2i.ZERO

var affected = []

var local_shape = []
var rots = 0



var reaction_started = false

 


func evacuate_cell(evac_cell : Vector2i):
	print("EVAC CELL: " + str(evac_cell))

func damage_cell(dmg_cell : Vector2i):
	print("DMG CELL: " + str(dmg_cell))

func place_bomb(bomb_type: String, bomb_coordinate: Vector2i, rots: int = 0):
	var bomb
	
	#--- cast the above to the instantiated bomb class
	
	
	#replace bomb[] with bomb.type etc
	if bomb["type"] == "GRENADE":
		bomb["state"] = "ignited"
	else: 
		bomb["state"] = "idle" 
	
	if bomb["state"] == "idle": #just sprites
		var bomb_sprite: Sprite2D = Sprite2D.new()
		bomb_sprite.texture = load("res://prototype/proto bomb sprites/SPRITE_%s.png" % bomb_type)
		bomb_sprite.position = bomb_coordinate * 64 + Vector2i(32, 32)
		bomb_sprite.rotation = bomb["rotation"] * PI / 2
		#add_child(bomb_sprite)
		
		bomb["sprite"] = bomb_sprite
		#once proper graphics installed, edit y position to match building heights
		#conditionally, add extra sprites for pipe bombs and other stuff to help track orientation
		if bomb_type == "PIPE_BOMB" or bomb_type == "ALT_PIPE_BOMB":
			#place the extra sprite in the right spot according to rots
			pass
	

	if reaction_started == false and bomb["type"] == "GRENADE":
		$"../BombTick".start()

func process_chain_reaction(): #this runs every time BombTick runs out
	reaction_started = true
	print("tick")
	$"../BombTick".start()
	
	var new_ignitions: Array = []
	var to_remove: Array = []
	for bomb in $Bombs:
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
				
			for other in $Bombs: # ignite or trigger other bombs
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
	var shape_data = get_parent().get(bomb["type"])

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

@onready var buttons: Array[TextureButton] = [
	$Interface/BombSelection/BombButton1,
	$Interface/BombSelection/BombButton2,
	$Interface/BombSelection/BombButton3
]

func _ready() -> void:
	$Interface/MetrocityLabel.text = "METROCITY: " + str($Map.metrocity)
	
	for btn in buttons:
		btn.toggle_mode = true
		btn.toggled.connect(_on_button_toggled.bind(btn))

func _on_button_toggled(pressed: bool, btn: TextureButton) -> void:
	if pressed:
		for other in buttons:
			if other != btn:
				other.set_pressed_no_signal(false)
		
		selected_bomb = bombButtonTypes[int(btn.name.trim_prefix("BombButton")) - 1]
		
		rots = 0
		
		$Interface/BombSelection/BombButton1.texture_normal = load("res://prototype/proto bomb sprites/SPRITE_" + bombButtonTypes[0] + ".png")
		$Interface/BombSelection/BombButton2.texture_normal = load("res://prototype/proto bomb sprites/SPRITE_" + bombButtonTypes[1] + ".png")
		$Interface/BombSelection/BombButton3.texture_normal = load("res://prototype/proto bomb sprites/SPRITE_" + bombButtonTypes[2] + ".png")
		
		print("SELECTED: " + selected_bomb)
	
	$Interface/BombSelection/Highlight.position = btn.position
	$Interface/BombSelection/Highlight.show()

func _process(_delta):
	var mouse_pos = get_local_mouse_position()
	anchor_tile = Vector2i(mouse_pos.x / 64, mouse_pos.y / 64)
	
	$Map.clear_highlight(affected)
	affected.clear()
	
	for offset in local_shape:
		var vec2i = anchor_tile + offset
		affected.append(vec2i)
	
	$Interface/Bombs.text = "BOMBS: " + str(player_bombs_left) #ph
	if selected_bomb != "" and mouse_pos.x >= 0 and mouse_pos.x < $Map.hcells * 64 and mouse_pos.y >= 0 and mouse_pos.y < $Map.vcells * 64:
		$Map.highlight_cells(affected)


func _input(_event):
	if Input.is_action_just_pressed("place_bomb"):
		var mouse_pos = get_local_mouse_position()
		for bombButton in $Interface/BombSelection.get_children():
			if bombButton is TextureButton and bombButton.button_pressed and mouse_pos > Vector2(0,0) and mouse_pos.x < $Map.hcells * 64 and mouse_pos.y < $Map.vcells * 64:
				bombButton.set_pressed_no_signal(false)
				send_bomb(bombButton)
		
		if selected_bomb == "GRENADE":
			if mouse_pos > Vector2(0,0) and mouse_pos.x < $Map.hcells * 64 and mouse_pos.y < $Map.vcells * 64:
				send_bomb()
		
	if Input.is_action_just_pressed("rotate_bomb"):
		rotateBomb()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func send_bomb(bombButton = null):
	$Map.clear_highlight(affected)
	affected.clear()
	
	if bombButton != null:
		$Bombs.place_bomb(bombButtonTypes[int(bombButton.name.trim_prefix("BombButton")) - 1], anchor_tile, rots)
		
		#anchor_tile as coord
		
		if player_bombs_left >= 1:
			bombButtonTypes[int(bombButton.name.trim_prefix("BombButton")) - 1] = BOMB_TYPES.pick_random()
			player_bombs_left -= 1
			
		print("placing BOMB at " + str(anchor_tile))
	else:
		$Bombs.place_bomb("GRENADE", anchor_tile)
		$Interface/BombSelection.hide()
		print("placing GRENADE at " + str(anchor_tile))
	
	
	
	selected_bomb = ""
	$Interface/BombSelection/Highlight.hide()

func rotateBomb(anticlockwise: bool = false) -> void:
	$Map.clear_highlight(affected)
	affected.clear()
	var rotated = []
	for cell_info in local_shape:
		var offset: Vector2i = cell_info["offset"]
		var new_offset: Vector2i = Vector2i(offset.y, -offset.x) if anticlockwise else Vector2i(-offset.y, offset.x)
		rotated.append(new_offset)
	local_shape = rotated
	rots += 1


func _on_ignite_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		selected_bomb = "GRENADE"
	else:
		selected_bomb = ""
	$Interface/BombSelection/BombButton1.button_pressed = false
	$Interface/BombSelection/BombButton2.button_pressed = false
	$Interface/BombSelection/BombButton3.button_pressed = false
