extends Node2D


var player_bombs_left : int = 10

var selected_bomb_type : Bombs.Type = Bombs.Type.NONE
var selected_bomb_index : int = -1

var anchor_tile : Vector2i = Vector2i.ZERO
var last_anchor_tile : Vector2i = Vector2i(-999,-999)

var local_shape : Array = []
var last_local_shape : Array = []

var rotations : int = 0

var bombOptions : Array[Bombs.Type] = [Bombs.Type.NONE, Bombs.Type.NONE, Bombs.Type.NONE]

const ROLLABLE_TYPES := [
	Bombs.Type.C4,
	#Bombs.Type.FUSE,
	Bombs.Type.CLAYMORE,
	Bombs.Type.IED,
	Bombs.Type.PIPE_BOMB,
	Bombs.Type.ALT_PIPE_BOMB,
	Bombs.Type.CARPET_BOMB,
	#Bombs.Type.BOMB_THREAT,
	#Bombs.Type.STINKBOMB,
	#Bombs.Type.RC_CARBOMB,
	#Bombs.Type.ALT_RC_CARBOMB,
	#Bombs.Type.AIRPLANE
]

func _ready():
	EffectManager.EffectsNode = $Effects
	EffectManager.MapNode = $Map
	$BombManager.MapNode = $Map
	
	bombOptions.resize(3)
	for i in range(3):
		roll_bomb_option(i)
	$Interface.refresh()

func roll_bomb_option(index:int):
	bombOptions[index] = ROLLABLE_TYPES.pick_random()

func select_bomb(type : Bombs.Type, index : int):
	selected_bomb_type = type
	selected_bomb_index = index
	local_shape = Bombs.DATA[type]["shape"].duplicate()
	rotations = 0


func send_bomb():
	if (selected_bomb_type != Bombs.Type.GRENADE and player_bombs_left <= 0) or selected_bomb_type == Bombs.Type.NONE:
		return
	
	#weird AF
	if (selected_bomb_type != Bombs.Type.GRENADE) :#or (selected_bomb_type != Bombs.Type.BOMB_THREAT) or (selected_bomb_type != Bombs.Type.AIRPLANE):
		for bomb in $BombManager.get_children():
			if bomb.coordinate == anchor_tile:
				return
	
	$BombManager.spawn_bomb(selected_bomb_type, anchor_tile, rotations)
	
	if selected_bomb_type == Bombs.Type.GRENADE:
		$Interface/GrenadeBelt.get_child(selected_bomb_index).disabled = true
	else:
		player_bombs_left -= 1
		roll_bomb_option(selected_bomb_index)
	
	$Map.clear_preview()
	$Interface.refresh()
	
	selected_bomb_type = Bombs.Type.NONE
	selected_bomb_index = -1

func _process(_delta): #just does highlighting currently
	var mouse_pos = get_local_mouse_position()
	var new_tile = Vector2i(mouse_pos.x / 64, mouse_pos.y / 64)
	if new_tile != last_anchor_tile or local_shape != last_local_shape:
		last_local_shape = local_shape
		last_anchor_tile = new_tile
		anchor_tile = new_tile
		
		if selected_bomb_type != Bombs.Type.NONE:
			$Map.preview_shape(anchor_tile, local_shape, Bombs.DATA[selected_bomb_type]["behaviour"])


func _input(_event):
	if Input.is_action_just_pressed("place_bomb"):
		if selected_bomb_type == Bombs.Type.NONE:
			return
		
		var mouse_pos = get_local_mouse_position()
		
		if mouse_pos > Vector2(0,0) \
		and mouse_pos.x < $Map.hcells * 64 \
		and mouse_pos.y < $Map.vcells * 64:
			send_bomb()
	
	if Input.is_action_just_pressed("rotate_bomb"):
		rotateBomb()
	
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func rotateBomb(anticlockwise: bool = false) -> void:
	var rotated = []
	for offset in local_shape:
		var new_offset: Vector2i = Vector2i(offset.y, -offset.x) if anticlockwise else Vector2i(-offset.y, offset.x)
		rotated.append(new_offset)
	local_shape = rotated
	rotations += 1
