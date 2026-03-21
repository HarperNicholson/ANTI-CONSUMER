extends Node2D

@export var skin_gradient : Gradient
@export var hair_gradient : Gradient

var type : CIVILIAN_TYPE = CIVILIAN_TYPE.NONE

enum CIVILIAN_TYPE {
	NONE = -1,
	POLICE,
	GREEN_ALIEN
}

func die(nuked : bool = false):
	#ashy stain from nuked
	#or explode with blood and limbs
	queue_free()

func random_color():
	var color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	return color

func random_from_gradient(grad: Gradient) -> Color:
	return grad.sample(randf())

func _ready() -> void:
		match type:
			CIVILIAN_TYPE.NONE: make_regular_civilian()
			CIVILIAN_TYPE.POLICE: make_police_officer()
			CIVILIAN_TYPE.GREEN_ALIEN: make_green_alien()

func make_regular_civilian():
	$Head.self_modulate = random_from_gradient(skin_gradient) # roll for rare chance at random color
	$Head/Hair.modulate = random_from_gradient(hair_gradient)
	$Pants.modulate = random_color()
	$Shirt.modulate = random_color()
	$Head/Hat.hide()

func make_police_officer():
	$Shirt.modulate = Color("224a87")
	$Pants.modulate = Color("272727")
	$Head/Hat.modulate = Color("224a87")
	$Head/Hat.show()

func make_green_alien():
	$Head.self_modulate = Color.LIME_GREEN
	$Head/Hair.modulate = Color.LIME_GREEN
	$Pants.modulate = Color.LIME_GREEN
	$Shirt.modulate = Color.LIME_GREEN
	$Head/Hat.hide()
