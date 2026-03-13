extends AnimatedSprite2D
#explosions should clear lingering effects on tile
var behaviour : Bombs.Behaviour
func _on_animation_finished() -> void:
	match behaviour:
		Bombs.Behaviour.STINKY: animation = "STINKY_LINGER"; return #can change this to summon a shader effect later
		Bombs.Behaviour.THREAT: animation = "THREAT_LINGER"; return #this would be police tape and flashing cars etc
	queue_free()

func lingering_effect_clear():
	#tween back alpha, or conditional death animations for certain effect behaviours, then
	queue_free()
