extends Node

var bomb_data = null
var bomb_shape : Array[Vector2i] = Bombs.DATA[bomb_data.shape]
var bomb_behaviour = Bombs.DATA[bomb_data.behaviour]

var rotations : int

var is_ignited : bool = false
#idle when not ignited. when hit by explosion, becomes ignited. when ignited, does "explosion" on next tick.

#should have a child of sprite/animatedsprite

#style idea: fuses could have a sine wave sorta cable drawn like a minecraft fishing rod from bomb to bomb
