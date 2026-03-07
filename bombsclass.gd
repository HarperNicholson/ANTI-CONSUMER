class_name Bombs


enum Type {
	C4,
	FUSE,
	CLAYMORE,
	IED,
	PIPE_BOMB,
	ALT_PIPE_BOMB,
	CARPET_BOMB,
	BOMB_THREAT,
	STINKBOMB,
	RC_CARBOMB,
	ALT_RC_CARBOMB,
	AIRPLANE,
	GRENADE
}

enum Behaviour {
	EXPLODE,
	STINKY,
	IMPACT,
	IMPACT_AIR,
	THREAT,
	FUSE,
	GRENADE
}

const DATA := {
	Type.C4: {
		"shape" : [
		Vector2i(1,0),
		Vector2i(1,1),
		Vector2i(0,1),
		],
		"behaviour" : Behaviour.EXPLODE
	},
	Type.FUSE: {
		"shape" : [
			Vector2i(1,0),
			Vector2i(2,0),
			Vector2i(3,0),
		],
		"behaviour" : Behaviour.FUSE
	},
	Type.CLAYMORE: {
		"shape" : [
		Vector2i(0,1),
		Vector2i(1,1),
		Vector2i(-1,1),
		],
		"behaviour" : Behaviour.EXPLODE
	},
	Type.IED: {
		"shape" : [],
		"behaviour" : Behaviour.EXPLODE
	},
	Type.PIPE_BOMB: {
		"shape" : [Vector2i(2,1)],
		"behaviour" : Behaviour.EXPLODE
	},
	Type.ALT_PIPE_BOMB: {
		"shape" : [Vector2i(-2,1)],
		"behaviour" : Behaviour.EXPLODE
	},
	Type.CARPET_BOMB: {
		"shape" : [Vector2i(1,0),Vector2i(2,0),Vector2i(3,0)],
		"behaviour" : Behaviour.EXPLODE
	},
	Type.BOMB_THREAT: {
		"shape" : [],
		"behaviour" :  Behaviour.THREAT
	},
	Type.STINKBOMB: {
		"shape" : [
			Vector2i(1,0),
			Vector2i(-1,0),
			Vector2i(0,1),
			Vector2i(1,1),
			Vector2i(-1,1),
			Vector2i(0,-1),
			Vector2i(1,-1),
			Vector2i(-1,-1)
			],
		"behaviour" : Behaviour.STINKY
	},
	Type.RC_CARBOMB: {
		"shape" : [Vector2i(1,0),Vector2i(1,1),Vector2i(1,2)],
		"behaviour" : Behaviour.IMPACT
	},
	Type.ALT_RC_CARBOMB: {
		"shape" : [
			Vector2i(-1,0),
			Vector2i(-1,1),
			Vector2i(-1,2)],
		"behaviour" : Behaviour.IMPACT
	},
	Type.AIRPLANE: {
		#just a really long line. can definitely do this better. smart alec.
		"shape" : [
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
			Vector2i(20,0)],
		"behaviour" : Behaviour.IMPACT_AIR
	},
	Type.GRENADE: {
		"shape" : [],
		"behaviour" : Behaviour.GRENADE
	}
}
