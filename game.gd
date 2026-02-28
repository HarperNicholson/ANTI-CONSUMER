extends Node2D

#right click to rotate. left click to place

#you can choose from 3 bombs at a time. each bomb has random type
#tetris shapes plus 3x3 stink bomb, plus specials. airplanes fly in a straight line and hit the first tall building they come across
#ortho and topdown. topdown for planning, ortho for demolition

const BOMB_TYPES : Array[String] = [
	"C4", 
	"FUSE", 
	"CLAYMORE", 
	"IED", 
	"PIPE_BOMB", 
	"ALT_PIPE_BOMB", 
	"CARPET_BOMB", 
	"RC_CARBOMB", 
	"ALT_RC_CARBOMB", 
	"BOMB_THREAT", 
	"STINKBOMB", 
	"AIRPLANE"
	]

var player_bombs_left = 10

var selected_bomb = ""

var bombButtonTypes : Array = [BOMB_TYPES.pick_random(), BOMB_TYPES.pick_random(), BOMB_TYPES.pick_random()]

var anchor_tile := Vector2i.ZERO
var affected = []
var local_shape = []
var rots = 0


# Vector2i(0,0), is a given because it will always originate from the point of click. 
#therefore it doesn't really need to be stored in the shape data at all.
#things like "IED_DATA" don't serve a particular purpose, besides responding to their call from the bomb script


const C4_DATA = [
	Vector2i(0,0),
	Vector2i(1,0),
	Vector2i(1,1),
	Vector2i(0,1),
]

const FUSE_DATA : Array[Vector2i] = [
	Vector2i(0,0),
	Vector2i(1,0),
	Vector2i(2,0),
	Vector2i(3,0),
]

const CLAYMORE_DATA  = [
	Vector2i(0,0),
	Vector2i(0,1),
	Vector2i(1,1),
	Vector2i(-1,1),
]

const IED_DATA = [
	Vector2i(0,0)
]


const PIPE_BOMB_DATA = [
	Vector2i(0,0),
	Vector2i(2,1),
]

const ALT_PIPE_BOMB_DATA = [
	Vector2i(0,0),
	Vector2i(-2,1),
]

const CARPET_BOMB_DATA = [
	Vector2i(0,0),
	Vector2i(1,0),
	Vector2i(2,0),
	Vector2i(3,0),
]
# "type": "IMPACT"
const RC_CARBOMB_DATA = [
	Vector2i(0,0),
	Vector2i(1,0),
	Vector2i(1,1),
	Vector2i(1,2),
]

const ALT_RC_CARBOMB_DATA = [
	Vector2i(0,0),
	Vector2i(-1,0),
	Vector2i(-1,1),
	Vector2i(-1,2),
]
# "type": "THREAT"
const BOMB_THREAT_DATA = [
	Vector2i(0,0)
]
#, "type": "STINK" }
const STINKBOMB_DATA = [
	Vector2i(0,0),
	Vector2i(1,0),
	Vector2i(-1,0),
	Vector2i(0,1),
	Vector2i(1,1),
	Vector2i(-1,1),
	Vector2i(0,-1),
	Vector2i(1,-1),
	Vector2i(-1,-1),
]

#just a really long line. can definitely do this better. smart alec.
#type = "IMPACT"
const AIRPLANE_DATA = [
	Vector2i(-1,0),
	Vector2i(-2,0),
	Vector2i(-3,0),
	Vector2i(-4,0),
	Vector2i(-5,0),
	Vector2i(-6,0),
	Vector2i(-7,0),
	Vector2i(-8,0),
	Vector2i(-9,0),
	Vector2i(-10,0),
	Vector2i(-11,0),
	Vector2i(-12,0),
	Vector2i(-13,0),
	Vector2i(-14,0),
	Vector2i(-15,0),
	Vector2i(-16,0),
	Vector2i(-17,0),
	Vector2i(-18,0),
	Vector2i(-19,0),
	Vector2i(-20,0),
	Vector2i(0,0),
	Vector2i(1,0),
	Vector2i(2,0),
	Vector2i(3,0),
	Vector2i(4,0),
	Vector2i(5,0),
	Vector2i(6,0),
	Vector2i(7,0),
	Vector2i(8,0),
	Vector2i(9,0),
	Vector2i(10,0),
	Vector2i(11,0),
	Vector2i(12,0),
	Vector2i(13,0),
	Vector2i(14,0),
	Vector2i(15,0),
	Vector2i(16,0),
	Vector2i(17,0),
	Vector2i(18,0),
	Vector2i(19,0),
	Vector2i(20,0),
	]

#, "type": "IGNITE"}
#this can also be done better. grenade has no shape data it's just the origin of the click.
const GRENADE_DATA = [
	Vector2i(0,0)
]

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
