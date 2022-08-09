import Protocol;
import mt.bumdum.Lib;





enum WaveType {
	Path( id:Int, fam:BadFamily, max:Int );


}


class Stykades {//}

	public static var FL_TEST_WAVE = false;
	//public static var FL_TEST_WAVE = true;


	static var WAVES = [

		{ lvl:0,	danger:80, 	type:Path(14,DRONE,6) 			},
		{ lvl:1,	danger:60, 	type:Path(0, DRONE,4) 			},
		{ lvl:2,	danger:40, 	type:Path(0, DRONE,6) 			},
		{ lvl:3,	danger:80, 	type:Path(16,KOBOLD,6) 			},
		{ lvl:4,	danger:80, 	type:Path(1, DRONE,10) 			},
		{ lvl:4,	danger:100, 	type:Path(20,KOBOLD,6) 			},
		{ lvl:5,	danger:35, 	type:Path(10,SENTINELLE,1) 		},
		{ lvl:5,	danger:110, 	type:Path(19,KOBOLD,8) 			},
		{ lvl:5,	danger:110, 	type:Path(19,KOBOLD,8) 			},
		{ lvl:6,	danger:60, 	type:Path(5, DRONE,8) 			},
		{ lvl:6,	danger:80, 	type:Path(15,DRONE,8) 			},
		{ lvl:7,	danger:100, 	type:Path(17,KOBOLD,8) 			},
		{ lvl:7,	danger:60, 	type:Path(8, DRONE,5) 			},
		{ lvl:8,	danger:160,	type:Path(3, SENTINELLE,4) 		},
		{ lvl:9,	danger:80, 	type:Path(6, DRONE,8) 			},
		{ lvl:10,	danger:80, 	type:Path(25,DRONE,6) 			},
		{ lvl:10,	danger:240, 	type:Path(7, ZILA,1)	 		},
		{ lvl:10,	danger:100, 	type:Path(21,KOBOLD,6) 			},
		{ lvl:12,	danger:110, 	type:Path(18,KOBOLD,8) 			},
		{ lvl:14,	danger:240, 	type:Path(23, ZILA,1)	 		},
		{ lvl:14,	danger:240, 	type:Path(22, ZILA,1)	 		},
		{ lvl:14,	danger:240, 	type:Path(24, ZILA,1)	 		},
		{ lvl:15,	danger:200,	type:Path(3, SENTINELLE,6) 		},
		{ lvl:17,	danger:220,	type:Path(9, ASSASSIN,4) 		},
		{ lvl:17,	danger:220,	type:Path(12,ASSASSIN,4) 		},
		{ lvl:20,	danger:260,	type:Path(2, SENTINELLE,6) 		},
		{ lvl:27,	danger:180,	type:Path(13,ASSASSIN,4) 		},
		{ lvl:28,	danger:340, 	type:Path(26,BEHEMOTH,1) 		},
		{ lvl:28,	danger:340, 	type:Path(27,BEHEMOTH,1) 		},
		{ lvl:28,	danger:340, 	type:Path(28,BEHEMOTH,1) 		},
		{ lvl:30,	danger:80, 	type:Path(4, DRONE,30) 			},
		{ lvl:30,	danger:240, 	type:Path(11,VOLT_BALL,1)		},
		{ lvl:40,	danger:400, 	type:Path(22, ZILA,3)	 		},
		{ lvl:40,	danger:400, 	type:Path(23, ZILA,3)	 		},
		{ lvl:40,	danger:400, 	type:Path(24, ZILA,3)	 		},

	];

	var rid:Int;


	public var danger:Float;
	var lvl:Float;
	var acc:Float;


	var seed:mt.Rand;

	public function new(n){
		seed = new mt.Rand(n);
		danger = 0 ;
		lvl = 0;
		acc = 1;
		rid = 0;
		if( !Game.FL_TEST ) danger = -50;
	}


	public function incDanger(n){

		var level = Std.int(lvl);
		lvl += n*0.01;
		if(level!=Std.int(lvl))Game.me.setLevel(Std.int(lvl));

		danger += n*acc;

		acc += n*0.0001;
		//haxe.Log.clear();
		//haxe.Log.trace(Std.int(acc*100)/100);


		if( danger>0 ){

			// CREE LA LISTE DES WAVE POSSIBLES
			var list = [];
			for( w in WAVES )if(w.lvl<=lvl)list.push(w);
			var w = list[seed.random(list.length)];

			if(FL_TEST_WAVE)w = list[0];


			switch( w.type ){
				case Path(wid,fam,max):

					if( fam==DRONE && seed.rand()*lvl >15 )fam = SUPER_DRONE;

					var flMirror = seed.random(2)==0;
					var mr = seed.rand();
					for( i in 0...max ){
						rid++;
						var b = new Bad( Game.me.dm.attach("mcBad",Game.DP_BADS), rid);
						b.setFamily(fam);
						var dest = DESTINIES[wid]( i, mr, seed, max );
						if(flMirror)dest = mirror(dest);
						b.setSeed( seed.random(9999) );
						b.addDestiny( dest,true );
						if( rid==Game.me.robertId )b.setLabel(0xFF0000,"ROBERT");


					}
			}

			danger -= w.danger;
		}
	}

	public function gma(a:Float,?mod:Float){
		if(a==null)return null;
		if(mod==null)mod = 3.14;
		var da = Num.hMod(1.57-a,mod);
		return Num.hMod(1.57+da,mod);
	}

	public function mirror(a:Array<Command>){
		var na = [];
		var mx = Std.int(Cs.mcw*0.5);
		//trace("!");

		for( cmd in a ){
			switch(cmd){

				case Pos(px,py) : 		na.push( Pos(Cs.mcw-px,py) );
				case StarPos(px,py,a,d) :	na.push( StarPos(Cs.mcw-px,py,gma(a),d) );
				case Impulse(n,a) :		na.push( Impulse(n,gma(a)) );

				case Rot(n) :			na.push( Rot(-n) );
				case Angle(a) :			na.push( Angle(gma(a)) );
				case Turn( n, t ) :		na.push( Turn(-n,t) );

				// SHOOT
				case Shoot(ca,ra) :		na.push( Shoot(-ca,ra) );
				case Fire(ca,ra) :		na.push( Fire(-ca,ra) );
				case Aim(ra,sp) :		na.push( Aim(ra,sp) );

				// TURRET
				case Turret( cs ) :		return a;
				case TurretStrafe(sp) :		return a;
				case TurretCycle( n ) :		return a;

				default:			na.push(cmd);

			}
		}
		return na;
	}

	static var DESTINIES:Array< Int->Float->mt.Rand->Int->Array<Command> > = [

		// 0
		function(i,mr:Float,s:mt.Rand,max) return
		[  	Wait(8+5*i), Pos(50+s.rand()*200,-10), Gear(2.5), Angle(1.57), Wait(20),
			SetOrient(Front(0.5)), Turn(0.2+s.rand()*0.5,20), Wait(40), Turn(-2.5,20), Fire( 0.1-s.rand()*0.5 ), Wait(15), Acc(5,10)  ],
		// 1
		function(i,mr:Float,s:mt.Rand,max) return
		[	Wait(8+7*i), Pos(100+mr*100,-10), Gear(2.5), Angle(1.57-i*0.1), Wait(20), Turn(2.5,20) , Wait(20+Std.int(s.rand()*25)),
			Turn(-2.5,20), Wait(15), Acc(5,10), SetOrient(Front(0.5)), Wait(10+s.rand()*20), Aim(0.1),Wait(1),Back(2,2)  ],
		// 2
		function(i,mr:Float,s:mt.Rand,max) return
		[	Wait(i*2), StarPos( 150, 150, -2.85+i*0.5, 240 ), SetOrient(Front(0.5)), Turret(12),
			Impulse(12), Frict(0.9), Wait(42), TurretStrafe(0.3), Wait(10), Back(2,20), Turn(3.14,20), Acc(5,10) 	],
		// 3
		function(i,mr:Float,s:mt.Rand,max) return	// 0
		[	Wait(5), Pos( 30+Std.int(i*240/(max-1)), -20 ),  Frict(0.9), Turret(12), Wait(10+i*6), TurretCycle(0),
			Impulse(5), Wait(20), TurretStrafe(0.5), Wait(5), Back(2,2), Wait(60), Back(6,2), SetOrient(Front(0.5)), Acc(6,10), Turn(3.14,20)	],
		// 4
		function(i,mr:Float,s:mt.Rand,max) return
		[  	Wait(8+4*i), Pos(50+s.rand()*200,-10), Gear(2.5), Angle(1.57+(s.rand()*2-1)*0.3), Wait(50+s.rand()*30),
			SetOrient(Front(0.5)), Turn(-3.14,20), Fire( (s.rand()*2-1)*0.5 ), Wait(15), Acc(5,10)	],
		// 5
		function(i,mr:Float,s:mt.Rand,max) return	// SIDE DRONE 1
		[  	Wait(8+12*i), Pos(-20,15+i*25), Gear(2.5), Angle(0),SetOrient(Front(0.5)), Wait(60+mr*20-i*5), Turn(4.5+i*0.3,50), Acc(5,20), Wait(20-i*2), Shoot( 0 )	],
		// 6
		function(i,mr:Float,s:mt.Rand,max) return	// SIDE DRONE 2
		[  	Wait(8+8*i), Pos(-20,30), Gear(2.5), Angle(0), SetOrient(Front(0.5)), Wait(10), Turn(1.57,20), Wait(40+s.rand()*40), Fire((s.rand()*2-1)*0.25-0.5),
			Acc(5,10), Turn(-4,30) //Turn(i*0.2-4,40)
		],
		// 7
		function(i,mr:Float,s:mt.Rand,max) return	// ZILA
		[  	Pos(50+s.rand()*200,-40), AddStatus(INVINCIBLE), Frict(0.9), Angle(1.57), Impulse(12,1.57), Spin(0,22),  Wait(40),
			Spin(0,0), PlayAnim("open"),SetOrient(Incline(5)),RemoveStatus(INVINCIBLE),
			AddBehaviour( new bh.Sinuso( 40, 220, mr*50, 80+mr*50, 3, 14 ) ),  AddBehaviour( new bh.Zila() ),
			Wait(500), RemoveBehaviour(0), Angle(-1.57), Acc(5,10)

		],
		// 8
		function(i,mr:Float,s:mt.Rand,max) return	// SIDE DRONE 3
		[  	Wait(8+12*i), Pos(-20,100), Gear(2.5), Angle(0), SetOrient(Front(0.5)), Wait(30), Turn(1.2,20),
			Wait(15), Wait(s.rand()*5), Fire( (s.rand()*2-1)*0.1 - 0.2 ), Turn(-2,20),
			Wait(45), Turn(-2,20), Wait(35+s.rand()*20), Fire( (s.rand()*2-1)*0.2 )
		],
		// 9
		function(i,mr:Float,s:mt.Rand,max) return	// ASSASSIN
		[  	Wait(8+12*i), Pos(-20,120), Gear(4), Angle(0), SetOrient(Incline(3)), Wait(40), Turn(-3,30), Wait(40-i*10),
			Frict(0.8), Impulse(20,0), Aim(0.2), Wait(3), Back(2,2), Wait(30), Impulse(-20,0), Back(5,2), Angle(-1.57),Gear(5)
		],
		// 10
		function(i,mr:Float,s:mt.Rand,max) return	// SENTINELLE SINGLE
		[  	Wait(0), Pos(50+mr*200,-20), SetOrient(Incline(5)), Gear(1.5),  Wait(30+s.rand()*100), Turn(-0.75*(s.random(2)*2-1),30), Acc(1,50),
			Wait(10), Fire( 0, s.rand()*0.15 ), Wait(6), Back(2,2)
		],
		// 11
		function(i,mr:Float,s:mt.Rand,max) return	// VOLT_BALL
		[  	 Pos(50+s.rand()*200,-30), Frict(0.9), Angle(1.57), Impulse(10,1.57), Wait(10),
			 AddBehaviour( new bh.Mosquito( 30, 80, 0, 60, Cs.mch-100 ) ), AddBehaviour( new bh.Volt() ),
			 Wait(500), RemoveBehaviour(0), Angle(1.57), Acc(10,20)
		],
		// 12
		function(i,mr:Float,s:mt.Rand,max) return	// ASSASSIN 2
		[  	Wait(12*i), Pos(44,-20), Gear(4), SetOrient(Incline(3)), Wait(40), Turn(-2,30), Wait(50-i*10),
			Frict(0.8), Impulse(25,-1.8), Aim(0.2), Wait(3), Back(2,2), Wait(10-i*2),
			Wait(30), Impulse( 12-i*8, 1.57 ), Aim(0.2), Wait(3), Back(2,2),
			Wait(30), Impulse( -12+i*8, 1.57 ), Aim(0.2), Wait(3), Back(2,2),
			Wait(30), Impulse( 9-i*6, 0 ), Aim(0.2),
			Back(14,1),Gear(4),Angle(-1.57)
		],
		// 13
		function(i,mr:Float,s:mt.Rand,max) return	// ASSASSIN 3
		[  	Wait(12*i), Pos(-20,280), Angle(0), Gear(4), SetOrient(Incline(3)), Wait(60), Turn(-2-i*0.1,30), Wait(60-i*4),
			Frict(0.9), Impulse(20,-3.14), Aim(0.2), Wait(3), Back(2,4),
			Angle(-3.14),Gear(4),Turn(3.14,10),

		],
		// 14
		function(i,mr:Float,s:mt.Rand,max) return	// DRONE BASE
		[  	Wait(10*i), Pos(110,-20), Gear(2.5), Angle(1.57+((i/max)*2-1)*0.5), SetOrient(Front(0.5)), Wait(70), Turn(-3,30), Fire( (s.rand()*2-1)*0.2 )

		],
		// 15
		function(i,mr:Float,s:mt.Rand,max) return	// DRONE
		[  	Wait(10*i), Pos(30,-20), Gear(2.5), Angle(1.57-(i/max)*1), SetOrient(Front(0.5)), Wait(70+i*2), Turn(-3+(i/max)*1  ,30), Fire( (s.rand()*2-1)*0.2 ),

		],
		// 16
		function(i,mr:Float,s:mt.Rand,max) return	// KOBOLD
		[  	Wait(6*i), Pos(-20,200), Gear(5), Angle(-0.6-(i/max)*0.85), SetOrient(Front(0.5)), Wait(58-i*5),
			//Gear(0),Impulse(3,1.57), Frict(0.9),PlayAnim("open"), SetOrient(Incline(3))
			Turn(2+(i/max)*1.2,10), Wait(10),Gear(1),PlayAnim("open"), SetOrient(Incline(8)),
			Fire(0,0.1),Wait(55),Back(2,1), Gear(3), Turn(1.57,10)
		],
		// 17
		function(i,mr:Float,s:mt.Rand,max) return	// KOBOLD
		[  	Wait(5*i), Pos(-10,-10), Gear(5), Angle(0.75), SetOrient(Front(0.5)), Wait(60),
			Turn(-2.2-i*0.15,10), Wait(30), Turn(-2,10), Wait(20), Turn(-3.5,10), Wait(15),
			Gear(1),PlayAnim("open"), SetOrient(Incline(8)),
			Fire(0,0.1),Wait(55),Back(2,1)
		],
		// 18
		function(i,mr:Float,s:mt.Rand,max) return	// KOBOLD FUSEE
		[  	Wait(5*i), Pos(150,-15), Gear(5), SetOrient(Front(0.5)), Wait(58),
			Turn(-1.7*((i%2)*2-1),10), Wait(30), Turn(-(2.4-i*0.1) * ((i%2)*2-1),10), Wait(40),
			Turn( ((i%2)*2-1), 60 ),
			Gear(1),PlayAnim("open"), SetOrient(Incline(8)),
			Fire(0,0.1),Wait(55),Back(2,1)
		],
		// 19
		function(i,mr:Float,s:mt.Rand,max) return	// KOBOLD
		[  	Wait(5*i), Pos(130,-15), Gear(5), Angle(2.2),SetOrient(Front(0.5)), Wait(38),
			Turn(-(2.5+0.25*(i%3)),10), Wait(30-i*2), Wait(5),
			Gear(1),PlayAnim("open"), SetOrient(Incline(8)),
			Fire(0,0.1),Wait(55),Back(2,1),Gear(3),Turn(-2,30)
		],
		// 20
		function(i,mr:Float,s:mt.Rand,max) return	// KOBOLD
		[  	Wait(5*i), Pos(80+mr*40,-15), Gear(5), SetOrient(Front(0.5)), Wait(5), Turn(0.6,10), Wait(30-i), Turn(-3+i*0.15,10),Wait(20+i*4),
			Gear(1),PlayAnim("open"), SetOrient(Incline(8)),
			Fire(0,0.1),Wait(55-i*3),Back(2,1),Gear(3),Turn(-2,30)
		],
		// 21
		function(i,mr:Float,s:mt.Rand,max) return	// KOBOLD
		[  	Wait(5*i), Pos(-15,140), Gear(5), Angle(0.5),SetOrient(Front(0.5)), Wait(57-i*2), Turn(-2-i*0.16,10), Wait(30),
			Gear(1),PlayAnim("open"), SetOrient(Incline(8)),
			Fire(0,0.1),Wait(50),Back(2,1),Gear(3),Turn(-1,30)
		],
		// 22
		function(i,mr:Float,s:mt.Rand,max) return	// ZILA
		[  	Wait(i*20),Pos(75,-40), AddStatus(INVINCIBLE), Frict(0.9), Angle(1.57), Impulse(12,1.57), Spin(0,22),  Wait(40),
			Spin(0,0), PlayAnim("open"),SetOrient(Incline(5)),RemoveStatus(INVINCIBLE),AddBehaviour( new bh.Zila() ),
			Push(0.45), Wait(26), Angle(-1.2), Wait(20), Angle(3.14), Wait(20), Angle(-1.2), Wait(20), Angle(0), Wait(50),
			Angle(2), Wait(40), Angle(-2), Wait(30), Angle(0), Wait(45), Angle(-3.14), RemoveBehaviour(0), Wait(60),Turn(-3.14,50)
		],
		// 23
		function(i,mr:Float,s:mt.Rand,max) return	// ZILA
		[  	Wait(i*20),Pos(75,-40), AddStatus(INVINCIBLE), Frict(0.9), Angle(1.57), Impulse(12,1.57), Spin(0,22),  Wait(40),
			Spin(0,0), PlayAnim("open"),SetOrient(Incline(5)),RemoveStatus(INVINCIBLE),AddBehaviour( new bh.Zila() ),
			Push(0.45), Angle(-0.3), Wait(26), Angle(0.3), Wait(26), Angle(2), Wait(40), Angle(-1.6), Wait(35), Turn(-3.14,60),
			Wait(105), Angle(-0.7), RemoveBehaviour(0), Wait(75), Angle(-3.14)
		],
		// 24
		function(i,mr:Float,s:mt.Rand,max) return	// ZILA
		[  	Wait(i*20),Pos(75,-40), AddStatus(INVINCIBLE), Frict(0.9), Angle(1.57), Impulse(12,1.57), Spin(0,22),  Wait(40),
			Spin(0,0), PlayAnim("open"),SetOrient(Incline(5)),RemoveStatus(INVINCIBLE),AddBehaviour( new bh.Zila() ),
			Push(0.45), Angle(0.75), Wait(26), Angle(-1.9),  Wait(36), Angle(1.9), Wait(30),Turn(-6,60), Wait(70), Angle(-0.5),
			Wait(55), Angle(1), Wait(25), Angle(-2.5),  Wait(15),Turn(-2.5,80), Wait(90), RemoveBehaviour(0), Angle(-1.57)
		],
		// 25
		function(i,mr:Float,s:mt.Rand,max) return	// DRONE
		[	Wait(5+i*2), StarPos( 100, 150, -2.85+i*0.5, 240 ), SetOrient(Front(0.5)), Gear(2.5), Wait(70),
			Turn(-3,20), Wait(5),Fire((s.rand()*2-1)*0.2),Acc(5,10) 	],
		// 26
		function(i,mr:Float,s:mt.Rand,max) return	// BEHEMOTH
		[	Pos( -40, 80), Angle(0), SetOrient(Front(0.5)), Gear(10), Wait(25),Turn(-4.7,30), Wait(32),
			PlayAnim("open"), Acc(-9,10),SetOrient(Incline(8)),Wait(10),Frict(0.9),Push(0.35),AddBehaviour( new bh.Errant(40,40,80)),
			Wait(20),AddBehaviour( new bh.Behemoth()),Wait(580),RemoveBehaviour(1),
			Wait(650),RemoveBehaviour(0),Angle(1.75),SetOrient(Front(0.5)),PlayAnim("close"),Gear(0),Acc(10,15),Wait(5),Turn(-3.14,20)
		],
		// 27
		function(i,mr:Float,s:mt.Rand,max) return	// BEHEMOTH 2
		[	Pos( 50, -40), SetOrient(Front(0.5)), Gear(10), Wait(10),Turn(-6.28,40), Wait(40),
			PlayAnim("open"), Acc(-9,10),SetOrient(Incline(6)),Wait(10),Frict(0.9),Push(0.35),AddBehaviour( new bh.Errant(40,40,80)),
			Wait(20),AddBehaviour( new bh.Behemoth()),Wait(580),RemoveBehaviour(1),
			Wait(650),RemoveBehaviour(0),Angle(1.75),SetOrient(Front(0.5)),PlayAnim("close"),Gear(0),Acc(10,15),Wait(5),Turn(-3.14,20)
		],
		// 28
		function(i,mr:Float,s:mt.Rand,max) return	// BEHEMOTH 3
		[	Pos( 150, -40), SetOrient(Front(0.5)), Gear(10), Wait(25),Turn(-4.7,50), Wait(50),
			PlayAnim("open"), Acc(-9,10),SetOrient(Incline(6)),Wait(10),Frict(0.9),Push(0.35),AddBehaviour( new bh.Errant(40,40,80)),
			Wait(20),AddBehaviour( new bh.Behemoth()),Wait(580),RemoveBehaviour(1),
			Wait(650),RemoveBehaviour(0),Angle(1.75),SetOrient(Front(0.5)),PlayAnim("close"),Gear(0),Acc(10,15),Wait(5),Turn(-3.14,20)
		],

	];

	// REVOIR ARRIVEE ZILA
	// MULTIPLE ARRIVE ZILA


	/*
	=== Controle des appareils

Lorsque votre appareil (Wallis) sera détruit pour la première  fois, le niveau est réinitialisé et vous pouvez tenter une seconde fois votre chance avec deux appareils ( Wallis & Futuna ) au lieu d'un.

Vous prenez alors le controle de Futuna et Wallis retrace la partie jouée précédemment.

Si Futuna est detruit au cours de la partie, tous vos ennemis seront pulvérisés et vous prenez le controle de Wallis.

Si Wallis est detruit au cours de la partie, tous vos ennemis seront pulvérisés.

Si vous parvenez jusqu'a l'instant ou Wallis a été détruit dans la première partie, son assassin ( Robert ) apparaitra en rouge. Détruisez-le pour obtenir un bonus spécial et sauver Wallis de sa destinée.

*/
//{
}

















