extends Node

@onready var Game = get_parent()

func _ready() -> void:
	$TEMPMetrocityLabel.text = "METROCITY: " + str($"../Map".metrocity) #ph
	for btn in $BombSelection.get_children():
		btn.toggle_mode = true
		btn.toggled.connect(_on_button_toggled.bind(btn))
	
	for grenadebtn in $GrenadeBelt.get_children():
		grenadebtn.toggle_mode = true
		grenadebtn.toggled.connect(_on_grenade_button_toggled.bind(grenadebtn))

func _process(_delta: float) -> void:  #placeholder currently
	$BombsLeftLabel.text = "BOMBS: " + str(Game.player_bombs_left) #ph

func _on_grenade_button_toggled(toggled_on: bool, grenadebtn: TextureButton) -> void:
	if toggled_on:
		Game.select_bomb(Bombs.Type.GRENADE, grenadebtn.get_index())

func refresh():
	for i in range(3):
		var btn = $BombSelection.get_child(i)
		var grenadebtn = $GrenadeBelt.get_child(i)
		var type = Game.bombOptions[i]
		
		if type != Bombs.Type.NONE:
			var _name = Bombs.Type.find_key(type)
			btn.texture_normal = load("res://prototype/bomb/SPRITE_%s.png" % _name)
		
		btn.button_pressed = false
		grenadebtn.button_pressed = false
	
	
	
	$BombSelectionHighlight.hide() 
	#BombInfoScreen.hide()


func _on_button_toggled(button_pressed: bool, btn: TextureButton) -> void:
	if not button_pressed:
		refresh()
		return
	
	for other in $BombSelection.get_children():
		if other != btn:
			other.set_pressed_no_signal(false)
	
	var index = btn.get_index()
	var type = Game.bombOptions[index]
	
	Game.select_bomb(type, index)
	
	#BombInfoScreen.show()
	#BombInfoScreen.display_new_bomb_description()    ##quickly unfolding character-by-character description
	$BombSelectionHighlight.global_position = btn.global_position
	$BombSelectionHighlight.show()
