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
	if nuked:
		print("nuked")
		#ashy stain from nuked
	else:
		EffectManager.spawn_limb($Pants/LegL)
		EffectManager.spawn_limb($Pants/LegR)
		EffectManager.spawn_limb($Shirt/ArmL)
		EffectManager.spawn_limb($Shirt/ArmR)
		EffectManager.spawn_limb($Shirt)
		EffectManager.spawn_limb($Pants)
		EffectManager.spawn_head($Head, $Head/Hair, $Head/Hat)
		
		EffectManager.spawn_blood_splat_particle_effect(position)
	queue_free()

func random_color():
	var color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	return color

func random_from_gradient(grad: Gradient) -> Color:
	return grad.sample(randf())

func _ready() -> void:
	if randf() < 0.01: type = CIVILIAN_TYPE.values().pick_random()
	match type:
		CIVILIAN_TYPE.NONE: make_regular_civilian()
		CIVILIAN_TYPE.POLICE: make_police_officer()
		CIVILIAN_TYPE.GREEN_ALIEN: make_green_alien()
	await get_tree().create_timer(1.0).timeout
	die()

func make_regular_civilian():
	$Head.self_modulate = random_from_gradient(skin_gradient) # roll for rare chance at random color
	$Head/Hair.self_modulate = random_from_gradient(hair_gradient)
	$Head/Hair.visible = randf() < 0.9  # 90% chance
	if randf() < 0.03:
		$Head/Hair.self_modulate = random_color()  # weird hair
	$Pants.self_modulate = random_color()
	$Pants/LegR.self_modulate = $Pants.self_modulate
	$Pants/LegL.self_modulate = $Pants.self_modulate
	$Shirt.self_modulate = random_color()
	$Shirt/ArmR.self_modulate = $Shirt.self_modulate
	$Shirt/ArmL.self_modulate = $Shirt.self_modulate
	$Head/Hat.hide()

func make_police_officer():
	$Shirt.self_modulate = Color("224a87")
	$Shirt/ArmR.self_modulate = $Shirt.self_modulate
	$Shirt/ArmL.self_modulate = $Shirt.self_modulate
	$Pants.self_modulate = Color("272727")
	$Pants/LegR.self_modulate = $Pants.self_modulate
	$Pants/LegL.self_modulate = $Pants.self_modulate
	$Head/Hat.self_modulate = Color("224a87")
	$Head/Hat.show()

func make_green_alien():
	$Head.self_modulate = Color.LIME_GREEN
	$Head/Hair.self_modulate = Color.LIME_GREEN
	$Pants.self_modulate = Color.LIME_GREEN
	$Pants/LegR.self_modulate = $Pants.self_modulate
	$Pants/LegL.self_modulate = $Pants.self_modulate
	$Shirt.self_modulate = Color.LIME_GREEN
	$Shirt/ArmR.self_modulate = $Shirt.self_modulate
	$Shirt/ArmL.self_modulate = $Shirt.self_modulate
	$Head/Hat.hide()
