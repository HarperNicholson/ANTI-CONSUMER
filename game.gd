extends Node2D

var player_bombs_left = 10

var selected_bomb

var anchor_tile : Vector2i = Vector2i.ZERO

var local_shape = []
var rots = 0

var bombOptions : Array[Bombs.Type]

@onready var buttons: Array[TextureButton] = [
	$"Interface/BombSelection/0",
	$"Interface/BombSelection/1",
	$"Interface/BombSelection/2"
]


func type_to_color(tile_type):
	match tile_type:
		"FUSE": return Color(1.0, 0.6, 0.0)
		"THREAT": return Color.BLUE
		"BOMB": return Color(0.8, 0.8, 0.0)
		"IMPACT": return Color(0.5, 0.0, 1.0)
		"IGNITE": return Color(1.0, 0.1, 0.1)
		"STINK": return Color.GREEN
		_: return Color.WHITE



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
		
		selected_bomb = btn
		
		rots = 0
		
		$Interface/BombSelection/BombButton1.texture_normal = load("res://prototype/proto bomb sprites/SPRITE_" + str(bombOptions[0]) + ".png")
		$Interface/BombSelection/BombButton2.texture_normal = load("res://prototype/proto bomb sprites/SPRITE_" + str(bombOptions[1]) + ".png")
		$Interface/BombSelection/BombButton3.texture_normal = load("res://prototype/proto bomb sprites/SPRITE_" + str(bombOptions[2]) + ".png")
	
	$Interface/BombSelection/Highlight.position = btn.position
	$Interface/BombSelection/Highlight.show()


#i want highlights to only update when absolutely necessary. i also want map to handle pretty much all of it
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
		
		#if selected_bomb == "GRENADE":
			if mouse_pos > Vector2(0,0) and mouse_pos.x < $Map.hcells * 64 and mouse_pos.y < $Map.vcells * 64:
				send_bomb()
		
	if Input.is_action_just_pressed("rotate_bomb"):
		rotateBomb()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func send_bomb(bombButton = null):
	if player_bombs_left <= 0:
		return

	var type = Bombs.Type.GRENADE if bombButton == null else bombOptions[int(bombButton.name.trim_prefix("BombButton")) - 1]
	BombsManager.spawn_bomb(type, anchor_tile, rots)

	if bombButton != null:
		bombOptions[int(bombButton.name.trim_prefix("BombButton")) - 1] = BOMB_TYPES.pick_random()

	player_bombs_left -= 1
	selected_bomb = ""
	$Interface/BombSelection/Highlight.hide()
	
	
	
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
