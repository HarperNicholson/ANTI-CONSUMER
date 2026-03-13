extends Sprite2D

@export var h : int = -99
@export var v : int = -99
@export var type : String = "unassigned"
@export var height : int = 0 #determines height of building type 
@export var hp : int = 0 #determins standing height
@export var damaged : bool = false #each cell should have two art versions
@export var indoor_population : int = 0
@export var attractiveness : int = 0 #buildings will be 0, but a park would be like 4 or something. makes for foot traffic
@export var value : int = 0 #set according to cell type, factor of height and some randomness

#more nice stuff in high metrocity. more playgrounds and ads in low metrocity.

#this script is like the base class, and also deals with cosmetic/decorative stuff. 

func set_cell_type(type_to_set : String):
	type = type_to_set
	load_texture()

func set_cell_height(target_height):
	height = target_height
	value = height * 1000
	set_cell_hp(target_height)

func set_cell_hp(target_hp):
	hp = clampi(target_hp, 0, target_hp)
	$Label.text = (str(hp) if hp > 0 else "")

func take_damage():
	if damaged == false:
		damaged = true
	set_cell_hp(hp - 1)
	#civilians
	#scoring
	#load_texture/animation for damaged variant
	

func load_texture():
	var texture_load_path = ("res://prototype/" + type + ("_dmged" if damaged else "") + ".png")
	if FileAccess.file_exists(texture_load_path):
		texture = load(texture_load_path)
	else:
		texture = load("res://prototype/unassigned.png")

func specialize(metrocity):
	var chance = clamp(0.20 * (metrocity/metrocity/metrocity), 0.0, 1.0)
	#high metrocity = high chance
	if randf() < chance:
		match randi_range(1,3):
			1:type = "advert"
			2:type = "playground"
			3:type = "trees"
	else:
		match randi_range(1,3):
			1:type = "garden"
			2:type = "statue"
			3:type = "advert"

#self correcting tile logic for roads, alleys, specials, boulevards. like life games logic
