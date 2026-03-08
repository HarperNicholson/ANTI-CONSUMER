extends Node2D

var player_bombs_left : int = 10

var selected_bomb_type : Bombs.Type = -1

var anchor_tile : Vector2i = Vector2i.ZERO
var last_anchor_tile : Vector2i = Vector2i(-999,-999)

var local_shape : Array[Vector2i] = []
var last_local_shape : Array[Vector2i] = []

var rots : int = 0

var bombOptions : Array[Bombs.Type]

@onready var buttons: Array[TextureButton] = [
	$"Interface/BombSelection/0",
	$"Interface/BombSelection/1",
	$"Interface/BombSelection/2"
]



func _ready() -> void: #all UI logic and placeholder 
	$Interface/MetrocityLabel.text = "METROCITY: " + str($Map.metrocity) #ph
	
	for btn in buttons:
		btn.toggle_mode = true
		btn.toggled.connect(_on_button_toggled.bind(btn))

func _on_button_toggled(pressed: bool, btn: TextureButton) -> void:
	if pressed:
		for other in buttons:
			if other != btn:
				other.set_pressed_no_signal(false)
		
		# selected_bomb_type = btn Bombs.Type
		
		
		rots = 0
		
		for i in range(buttons.size()):
			buttons[i].texture_normal = load("res://prototype/proto bomb sprites/SPRITE_" + str(bombOptions[i]) + ".png")
	
	$Interface/BombSelection/Highlight.position = btn.position
	$Interface/BombSelection/Highlight.show()


func _process(_delta):
	
	$Interface/Bombs.text = "BOMBS: " + str(player_bombs_left) #ph
	
	var mouse_pos = get_local_mouse_position()
	var new_tile = Vector2i(mouse_pos.x / 64, mouse_pos.y / 64)
	
	if new_tile != last_anchor_tile or local_shape != last_local_shape:
		last_local_shape = local_shape
		last_anchor_tile = new_tile
		anchor_tile = new_tile
		
		$Map.preview_shape(anchor_tile, local_shape, Bombs.DATA[selected_bomb_type]["behaviour"])


func _input(_event):
	if Input.is_action_just_pressed("place_bomb"):
		var mouse_pos = get_local_mouse_position()
		for bombButton in $Interface/BombSelection.get_children():
			if bombButton is TextureButton and bombButton.button_pressed and mouse_pos > Vector2(0,0) and mouse_pos.x < $Map.hcells * 64 and mouse_pos.y < $Map.vcells * 64:
				bombButton.set_pressed_no_signal(false)
				send_bomb(bombButton)
		
		if selected_bomb_type == Bombs.Type.GRENADE:
			if mouse_pos > Vector2(0,0) and mouse_pos.x < $Map.hcells * 64 and mouse_pos.y < $Map.vcells * 64:
				send_bomb()
		
	if Input.is_action_just_pressed("rotate_bomb"):
		rotateBomb()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func send_bomb(bombButton = null):
	if player_bombs_left <= 0:
		return

	#var type = Bombs.Type.GRENADE if grenade condition else its the bomb selected
	$BombsManager.spawn_bomb(selected_bomb_type, anchor_tile, rots)
   
	#this is to give a new bomb option
	#if bombButton != null: 
	#	bombOptions[int(bombButton.name.trim_prefix("BombButton")) - 1] = BOMB_TYPES.pick_random()

	player_bombs_left -= 1
	selected_bomb_type = -1  # nullify the selected bomb
	
	#$Interface/BombSelection/Highlight.hide()  should have a UI manager probably

func rotateBomb(anticlockwise: bool = false) -> void:
	var rotated = []
	for offset in local_shape:
		var new_offset: Vector2i = Vector2i(offset.y, -offset.x) if anticlockwise else Vector2i(-offset.y, offset.x)
		rotated.append(new_offset)
	local_shape = rotated
	rots += 1
