there are comments throughout codebase pointing the general direction.
I should next establish "damage" to buildings, along with civilian count and placeholder value
value, "height", civilian count should reflect what bombs are doing to that building
use of value effect popup would be nice
sooooooooooooooooooo duh. bombs should be instantiated from class "bomb". type determines shape etc. bomb shape data is a separate lookup. solved.

to get there:
bomb script is overcrowded with shadowed variables and unnecessary data (like Vector2i(0,0) as part of every shape)
it was also unecessarily storing "type" for every point in a shape, but i have simplified and all bombs may only be of one type
so reducing from a Dictionary to an Array[Vector2i] is sure to break things for now
also the issue, that reducing this data leaves one-tile bombs (like grenade or IED or bombthreat) as effectively useless shape data variables
so the initiation should happen some other way when those bombs are being used.
it calls for a cleanup of the bomb and game scripts.

further down the line, after all that is solid, SFX and basic particle effects maybe
