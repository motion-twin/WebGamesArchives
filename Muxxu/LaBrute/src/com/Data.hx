typedef CreateData = {
	var _perso : String;
	var _create : String;
}

typedef InventoryData = {
	var _l : String;
	var _a : Bool;
	var _s : Int;
	var _name : String;
	var _level : Int;
	var _bits : haxe.io.Bytes;
}

typedef ClientData = {
	var _seed : Int;
	var _glads : Array<{ _s : Int, _t : Int, _gfx : String, _lvl : Int, _bits : haxe.io.Bytes, _n : String }>;
	var _mini : String;
	var _end : String;
	var _arena : Int;
	var _p0 : TeamProperty;
	var _p1 : TeamProperty;
}

typedef TournamentData = {
	var _glads : Array<{ _id : Int, _gfx : String, _lvl : Int, _n : String, _u : String, _m : Int }>;
	var _perso : String;
	var _view : String;
	var _fight : String;
	var _user: String;
	var _league: Int;
	var _max : Int;
}

enum _Action  {
	AddFighter(id:Int,team:Int,skin:String,lvl:Int,bits:haxe.io.Bytes,name:String,inter:Bool);
	AddFollower(id:Int,team:Int, ft:_Followers);
	Leave(id:Int);
	Weapon(id:Int,wid:_Weapons,sab:Bool);
	Trash(id:Int);
	Attack(aid:Int,tid:Int,damage:Int,?sab:_Weapons,?dis:Bool,?disShield:Bool,?disAtt:Bool);
	ThrowAttack(aid:Int,tid:Int,damage:Int);

	Steal(aid:Int,tid:Int);
	Grab(aid:Int,tid:Int,damage:Int);
	Bomb(fid:Int,damage:Int);
	Medecine(fid:Int,life:Int);
	Status(fid:Int,sid:Int,flag:Bool);
	Net(aid:Int,tid:Int);
	Escape(aid:Int,a:Array<Int>);
	Hypno(aid:Int,a:Array<Int>);

	MoveTo(aid:Int,tid:Int,dcx:Int);
	MoveBack(id:Int);

	Death(id:Int);
	EndFight(winTeam:Int);
	Downpour( id:Int, a:Array<_Weapons>, dmg:Array<Int> );

	Eat( id:Int, heal:Int, cid:Int );
	Poison( id:Int, damage:Int );
	FxResistDamage( fid:Int );
}

enum _Permanent {
	SUPER_FORCE;
	SUPER_AGILITY;
	SUPER_SPEED;
	SUPER_LIFE;
	IMMORTALITY;
	BLADE_MASTER;
	BRAWL_MASTER;
	VIGILANCE;
	PUGNACITY;
	TWISTER;
	SHIELD;
	ARMOR;
	LEATHER_SKIN;
	UNTOUCHABLE;
	VANDALISM;
	CHOC;
	BLUNT_MASTER;
	MERCILESS;
	SURVIVAL;
	LEAD_BONES;
	BALLERINA;

	STAYER;
	WARM_BLOODED;
	INCREVABLE;

	DIESEL;
	COUNTER;
	IRON_HEAD;
}

enum _Super {
	THIEF;
	BRUTE;
	MEDECINE;
	NET;
	BOMB;
	GRAB;
	SHOUT;
	HYPNO;
	DOWNPOUR;
	TRAPPER;
}

enum _Talent {
	HYPERACTIVE;			// +1 combat d'entrainement par jours
	COOK;					// -1 combat a l'utilisation : Tous les futurs adversaires sont empoisonnées ( 24h ).
	SPY;					// -1 combat a l'utilisation : Les caracs des brutes adverses sont visibles ( 24h ).
	SABOTEUR;				// -1 combat a l'utilisation : Tous les futurs adversaires ont une de leur armes sabotée ( 24h ).
	STRIKER;				// -1 combat a l'utilisation : La brute viendra aider ses collègues de niv superieur au sien en combat ( 24h ).
}

enum _Followers {
	DOG_0;
	DOG_1;
	DOG_2;
	PANTHER;
	BEAR;
}

enum _Weapons {
	HANDS;
	KNIFE;
	SWORD;
	LANCE;
	STICK;
	TRIDENT;
	AXE;
	SCIMETAR;
	HAMMER;
	BIG_SWORD;
	FAN;
	SHURIKEN;	//11
	FANGS;

	WOOD_CLUB;	// 13
	IRON_CLUB;
	BONE_CLUB;
	FLAIL;
	WHIP;
	SAI;		// 18

	POIREAU;	// 19
	MUG;
	POELE;
	POUSSIN;
	HALBERD;
	TROMBONNE;
	KEYBOARD;
	NOODLES;
	RACKET;

}

enum _Status {
	ST_BRUTE;
	ST_NET;
}

enum _Bonus {
	Permanent( p : _Permanent );
	Super( s : _Super );
	Followers( f : _Followers );
	Talent( e : _Talent );
	Weapons( w : _Weapons );
}

typedef TeamProperty = {
	_poi:Bool,
	_sab:Bool,
	_st:{_s:Int,_gfx:String,_lvl:Int,_bits:haxe.io.Bytes},
}

typedef BonusSlot = {
	id:_Bonus,
	w:Int
}

typedef Weap  ={
	id:_Weapons,
	toss:Int,
	deg:Int,
	tempo:Int,
	rip:Int,
	zone:Int,
	rap:Int,
	dod:Int,
	per:Int,
	par:Int,
	combo:Int,
	dt:Int,
	dis:Int,
	type:WeaponType,
	anim:StrikeType
}

typedef Sup  ={
	id:_Super,
	toss:Int,
	use:Int
}

enum WeaponType {
	Throw;
	Brawl;
}

enum StrikeType {
	Fist;
	Slash;
	Estoc;
	Whip;
}

class Data{//}
	public static var WEAPONS:Array<Weap> = [

		{ id:HANDS,	toss:10, deg:5, tempo:120, rip:0,  zone:0, rap:20,   dod:10,  per:0,   par:-25,	dis:5, combo:0,  type:Brawl, anim:Fist, dt:0 },

		{ id:KNIFE,	toss:5, deg:7,  tempo:60,  rip:0,  zone:0, rap:50,   dod:10,   per:0,   par:0,	dis:0, combo:30,  type:Brawl, anim:Estoc, dt:1  },
		{ id:SWORD,	toss:5, deg:10, tempo:120, rip:10, zone:1, rap:0,    dod:0,   per:0,   par:15,	dis:15, combo:0,   type:Brawl, anim:Slash, dt:1  },
		{ id:LANCE,	toss:2, deg:12, tempo:120, rip:-10,  zone:3, rap:0,    dod:0,   per:0,   par:0,	dis:10, combo:0,   type:Brawl, anim:Estoc, dt:2  },
		{ id:STICK,	toss:3, deg:6,  tempo:100, rip:30, zone:3, rap:0,    dod:5,   per:0,   par:25,	dis:25, combo:10,   type:Brawl, anim:Estoc, dt:2 },
		{ id:TRIDENT,	toss:3, deg:14, tempo:140, rip:5,  zone:3, rap:0,    dod:0,   per:0,   par:0, 	dis:20, combo:0,   type:Brawl, anim:Estoc, dt:2  },
		{ id:AXE,	toss:3, deg:17, tempo:150, rip:0,  zone:1, rap:0,    dod:0,   per:0,   par:-10,	dis:0, combo:0,   type:Brawl, anim:Slash, dt:3  },
		{ id:SCIMETAR,	toss:3, deg:10, tempo:80,  rip:0,  zone:1, rap:20,    dod:0,   per:0,   par:10,	dis:0, combo:15,  type:Brawl, anim:Slash, dt:1  },

		{ id:HAMMER,	toss:5, deg:55, tempo:230, rip:-20,zone:1, rap:-30, dod:-40, per:50,  par:-50,	dis:10, combo:-40, type:Brawl, anim:Slash, dt:4  },
		{ id:BIG_SWORD,	toss:5, deg:28, tempo:180, rip:0,  zone:2, rap:-10, dod:-20, per:-20, par:0,	dis:10, combo:0,   type:Brawl, anim:Slash, dt:1  },

		{ id:FAN,	toss:5, deg:4,  tempo:28,  rip:50, zone:0, rap:50,  dod:60,  per:0,   par:-50,	dis:-50, combo:45,   type:Brawl, anim:Slash, dt:5 },
		{ id:SHURIKEN,	toss:5,  deg:3,	 tempo:12,   rip:0, zone:0, rap:0,   dod:15,   per:0,   par:-10, dis:-50, combo:30, type:Throw, anim:Fist, dt:6    },

		{ id:FANGS,	toss:10, deg:3,	 tempo:100,  rip:0, zone:0, rap:0,   dod:0,   per:0,   par:0,	dis:0, combo:10, type:Brawl, anim:Fist, dt:0  },

		{ id:WOOD_CLUB,	toss:5,  deg:30, tempo:200,  rip:-30, zone:1, rap:-35, dod:-30, per:30,  par:-30, dis:10, combo:-60, type:Brawl, anim:Slash, dt:4 },
		{ id:IRON_CLUB,	toss:5,  deg:20, tempo:150,  rip:0,   zone:1, rap:-5,   dod:-10,   per:30,  par:0,   dis:10, combo:0,   type:Brawl, anim:Slash, dt:4 },
		{ id:BONE_CLUB,	toss:5,  deg:14, tempo:160,  rip:0,   zone:1, rap:0,   dod:0,   per:50,  par:0,   dis:10, combo:-10,   type:Brawl, anim:Slash, dt:4 },
		{ id:FLAIL,	toss:5,  deg:36, tempo:220,  rip:0,   zone:1, rap:-10, dod:-30, per:150, par:-50, dis:-20, combo:30,  type:Brawl, anim:Slash, dt:4 },
		{ id:WHIP,	toss:5,  deg:10, tempo:150,  rip:-10, zone:5, rap:30, dod:30,  per:-20, par:-20, dis:30, combo:35,  type:Brawl, anim:Whip,  dt:7 },
		{ id:SAI,	toss:5,  deg:8,  tempo:60,    rip:0,   zone:0, rap:25, dod:10,  per:0, par:30, dis:100, combo:30,  type:Brawl, anim:Estoc,  dt:2 },

		{ id:POIREAU,	toss:2,  deg:5,  tempo:110,  rip:100, zone:1, rap:100, dod:0,   per:200, par:-50, dis:0, combo:200,   type:Brawl, anim:Slash, dt:4 },
		{ id:MUG,	toss:2,  deg:8,  tempo:90,  rip:0,   zone:0, rap:30,  dod:15,  per:0,   par:-10, dis:0, combo:40,   type:Brawl, anim:Estoc, dt:0 },
		{ id:POELE,	toss:2,  deg:17, tempo:120,  rip:0,  zone:1, rap:0,   dod:0,   per:0,   par:40,  dis:0, combo:-40,  type:Brawl, anim:Slash, dt:4 },
		{ id:POUSSIN,	toss:2,  deg:5,  tempo:32,   rip:0,  zone:0, rap:0,   dod:0,   per:0,   par:-10, dis:0, combo:0,    type:Throw, anim:Fist, dt:6    },
		{ id:HALBERD,	toss:2,  deg:24, tempo:180,  rip:0,  zone:4, rap:-40,   dod:0,   per:0,   par:0,  dis:10, combo:0,   type:Brawl, anim:Slash, dt:1  },
		{ id:TROMBONNE,	toss:2,  deg:20, tempo:250,  rip:0,  zone:2, rap:-10,   dod:0,   per:20,  par:20,  dis:50, combo:30,  type:Brawl, anim:Slash, dt:4 },
		{ id:KEYBOARD,	toss:2,  deg:7,  tempo:100,  rip:0,  zone:1, rap:20,  dod:10,  per:0,   par:0,   dis:0, combo:50,  type:Brawl, anim:Slash, dt:4 },
		{ id:NOODLES,	toss:2,  deg:10, tempo:45,   rip:0,  zone:0, rap:0,   dod:10,   per:0,   par:-10, dis:0, combo:30,  type:Throw, anim:Fist, dt:6    },
		{ id:RACKET,	toss:2,  deg:6,  tempo:80,  rip:100, zone:1, rap:0,   dod:10,   per:0,   par:20,  dis:0, combo:0,   type:Brawl, anim:Slash, dt:4 },



	];

	public static var FOLLOWERS = [
		{ force:6, agility:5, speed:3, 	  lifeMax:-6, counter:0, riposte:0, combo:10, parry:0, dodge:0, 	init:10,   dw:FANGS	}, // DOG_0
		{ force:6, agility:5, speed:3, 	  lifeMax:-6, counter:0, riposte:0, combo:10, parry:0, dodge:0, 	init:10,   dw:FANGS	}, // DOG_1
		{ force:6, agility:5, speed:3, 	  lifeMax:-6, counter:0, riposte:0, combo:10, parry:0, dodge:0,	 	init:10,   dw:FANGS	}, // DOG_2
		{ force:23, agility:16, speed:24, lifeMax:-4,  counter:0, riposte:0, combo:60, parry:0, dodge:20, 	init:60, dw:FANGS	}, // PANTHER
		{ force:40, agility:2, speed:1,   lifeMax:10, counter:0, riposte:0, combo:-20, parry:0, dodge:0,  	init:360, dw:HANDS	}, // BEAR

	];

	public static var SUPERS = [
		{ id:THIEF,	toss:8,   use:2 },
		{ id:BRUTE,	toss:5,   use:1 },
		{ id:MEDECINE,	toss:5,   use:1 },
		{ id:NET,	toss:5,   use:1 },
		{ id:BOMB,	toss:2,   use:2 },
		{ id:GRAB,	toss:2,   use:1 },
		{ id:SHOUT,	toss:8,   use:2 },
		{ id:HYPNO,	toss:3,   use:1 },
		{ id:DOWNPOUR,	toss:2,   use:1 },
		{ id:TRAPPER,	toss:20,   use:4 },

	];


	public static var BONUS_WEIGHTS:Array<BonusSlot> = [

		{ id:Permanent(SUPER_FORCE), 	w:60 		},
		{ id:Permanent(SUPER_AGILITY), 	w:60		},
		{ id:Permanent(SUPER_SPEED), 	w:60		},
		{ id:Permanent(SUPER_LIFE), 	w:60		},
		{ id:Permanent(IMMORTALITY), 	w:1 		},
		{ id:Permanent(BLADE_MASTER), 	w:10		},
		{ id:Permanent(BRAWL_MASTER),  	w:10 		},
		{ id:Permanent(VIGILANCE), 		w:20 		},
		{ id:Permanent(PUGNACITY), 		w:4 		},
		{ id:Permanent(TWISTER), 		w:10 		},
		{ id:Permanent(SHIELD), 		w:20 		},
		{ id:Permanent(ARMOR), 			w:4 		},
		{ id:Permanent(LEATHER_SKIN), 	w:30 		},
		{ id:Permanent(UNTOUCHABLE), 	w:1 		},
		{ id:Permanent(VANDALISM), 		w:3 		},
		{ id:Permanent(CHOC), 			w:10 		},
		{ id:Permanent(BLUNT_MASTER),	w:5 		},
		{ id:Permanent(MERCILESS),		w:1 		},
		{ id:Permanent(SURVIVAL),		w:4 		},
		{ id:Permanent(LEAD_BONES),		w:4 		},
		{ id:Permanent(BALLERINA),		w:4 		},
		{ id:Permanent(STAYER),			w:4 		},
		{ id:Permanent(WARM_BLOODED),	w:8, 		},
		{ id:Permanent(INCREVABLE),		w:3, 		},
		{ id:Permanent(DIESEL),			w:1, 		},
		{ id:Permanent(COUNTER),		w:10, 		},
		{ id:Permanent(IRON_HEAD),		w:4, 		},

		{ id:Super(THIEF), 			w:10	},
		{ id:Super(BRUTE), 			w:20	},
		{ id:Super(MEDECINE), 		w:8		},
		{ id:Super(NET), 			w:16	},
		{ id:Super(BOMB), 			w:6		},
		{ id:Super(GRAB), 			w:1		},
		{ id:Super(SHOUT), 			w:4		},
		{ id:Super(HYPNO), 			w:2		},
		{ id:Super(DOWNPOUR), 		w:2		},
		{ id:Super(TRAPPER),		w:4, 	},

		{ id:Followers(DOG_0), 		w:20 	},
		{ id:Followers(DOG_1), 		w:8		},
		{ id:Followers(DOG_2), 		w:2 	},
		{ id:Followers(BEAR), 		w:1 	},
		{ id:Followers(PANTHER), 	w:1 	},

		{ id:Weapons(KNIFE), 		w:80		},
		{ id:Weapons(SWORD), 		w:100		},
		{ id:Weapons(LANCE), 		w:40		},
		{ id:Weapons(STICK), 		w:70 		},
		{ id:Weapons(TRIDENT), 		w:10 		},
		{ id:Weapons(AXE), 			w:40 		},
		{ id:Weapons(SCIMETAR),		w:6 		},
		{ id:Weapons(HAMMER), 		w:3 		},
		{ id:Weapons(BIG_SWORD), 	w:4 		},
		{ id:Weapons(FAN), 			w:2 		},
		{ id:Weapons(SHURIKEN),		w:8			},


		{ id:Weapons(WOOD_CLUB),	w:50	},
		{ id:Weapons(IRON_CLUB),	w:6		},
		{ id:Weapons(BONE_CLUB),	w:20	},
		{ id:Weapons(FLAIL),		w:4		},
		{ id:Weapons(WHIP),			w:3		},
		{ id:Weapons(SAI),			w:6		},

		{ id:Weapons(POIREAU),		w:2		},
		{ id:Weapons(MUG),			w:2		},
		{ id:Weapons(POELE),		w:2		},
		{ id:Weapons(POUSSIN),		w:2		},
		{ id:Weapons(HALBERD),		w:2		},
		{ id:Weapons(TROMBONNE),	w:2		},
		{ id:Weapons(KEYBOARD),		w:2		},
		{ id:Weapons(NOODLES),		w:2		},
		{ id:Weapons(RACKET),		w:2		},


		{ id:Talent(HYPERACTIVE), w : 3 },
		{ id:Talent(COOK), w : 3 },
		{ id:Talent(SPY), w : 3 },
		{ id:Talent(SABOTEUR), w : 3 },
		{ id:Talent(STRIKER), w : 5 },
	];

//{
}