extends Node

var type
var rotations
var state # idle or ignited or exploding? or stinky? or moving?
##their effect can be additive to the world instead of remaining "alive", ie a bomb should be able to die 
#or be deleted/exploded from the world while it's effect could still persist. either that or a bomb has an
#hp and can only be killed once, after which it decides for itself to remain as a stink cloud etc or just vanish

#should have a child sprite/animatedsprite

#style idea: fuses could have a sine wave sorta cable drawn like a minecraft fishing rod from bomb to bomb
