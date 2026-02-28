extends Node2D

var explosionEffect = preload("res://polished/animation/explosion_effect.tscn")

func set_effects(affected_cells, state : String):
	match state:
		"exploding":
			for offset in affected_cells:
				var explosionInstance = explosionEffect.instantiate()
				explosionInstance.position = offset * 64 + Vector2i(32,32)
				add_child(explosionInstance)
				print("EFFECT: " + str(explosionInstance))
		"stinky":
			for offset in affected_cells:
				
				#replace with stinky shader 
				
				var stinkInstance = "stinkeh"#explosionEffect.instantiate()
				#stinkInstance.position = offset * 64 + Vector2i(32,32)
				print(stinkInstance)
				#add_child(stinkInstance)
	
