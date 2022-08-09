class Spell{//}

		
	static var spellList = [
		
		{ id:1,		freq:500,	min:1,	lvl:20,	cost:2	 } 	// DIG
		{ id:2,		freq:750,	min:0,	lvl:10,	cost:1	 }	// MINOR
		{ id:3,		freq:200,	min:12,	lvl:80,	cost:6	 }	// MASS
		{ id:4,		freq:350,	min:3,	lvl:10,	cost:3	 }	// STAR EATER
		{ id:5,		freq:100,	min:4,	lvl:40,	cost:4	 }	// DECOMPRESSION
		{ id:6,		freq:150,	min:4,	lvl:28,	cost:3	 }	// FOSSILISATION
		{ id:7,		freq:800,	min:0,	lvl:15,	cost:1	 }	// ASCENSION
		{ id:8,		freq:50,	min:6,	lvl:40,	cost:3	 }	// BERSERK
		{ id:9,		freq:300,	min:0,	lvl:10,	cost:2	 }	// SLICE
		{ id:10,	freq:500,	min:1,	lvl:20,	cost:1	 }	// SILENCE
		{ id:11,	freq:100,	min:6,	lvl:40,	cost:7	 }	// DESTRUCTION
		{ id:12,	freq:700,	min:0,	lvl:15,	cost:1	 }	// SHIELD
		{ id:13,	freq:20,	min:7,	lvl:25,	cost:5	 }	// NOVA
		{ id:14,	freq:150,	min:8,	lvl:50,	cost:4	 }	// BAN
		{ id:15,	freq:300,	min:1,	lvl:25,	cost:3	 }	// LIGHTBOLT
		{ id:16,	freq:2,		min:14,	lvl:20,	cost:3	 }	// PAINT
		
		{ id:20,	freq:0,		min:99,	lvl:10,	cost:1	 }	// LIGHT BALL
		{ id:21,	freq:500,	min:0,	lvl:18,	cost:2	 }	// LIGHT BEAM
		{ id:22,	freq:400,	min:1,	lvl:22,	cost:3	 }	// SOLERO
		{ id:23,	freq:300,	min:2,	lvl:28,	cost:4	 }	// WISP
		{ id:24,	freq:50,	min:3,	lvl:36,	cost:5	 }	// GLUE
		{ id:25,	freq:150,	min:4,	lvl:50,	cost:6	 }	// FLAME
		{ id:26,	freq:300,	min:3,	lvl:30,	cost:8	 }	// HOLYBALL
		{ id:27,	freq:200,	min:3,	lvl:100,cost:10	 }	// PHANTOM
		
	]


	// STATIC
	static function getRandomId(fi){
		// HERE
		
		// CONSTRUCTION DE LA LISTE
		var list = new Array();
		var sum = 0;
		for( var i=0; i<spellList.length; i++ ){
			var o = spellList[i]
			if( ( fi.fs.$level >= o.min || o.min == null ) && ( fi.carac[5]*2 >= o.cost || o.cost == null ) ){
				list.push([o.id,o.freq])
				sum += o.freq;
			}
		}
		// TIRAGE
		var n = Std.random(sum)
		var s = 0;
		for( var i=0; i<list.length; i++ ){
			s += list[i][1];
			if( s > n ){
				return list[i][0];
			}
		}
		Manager.log("ERROR: erreur dans le tirage de sort")
		return null;
	}
	
	
	static function newSpell(n):spell.Base{
		var s = null
		//*
		switch(n){

			case 0:
				s = Std.cast( new spell.Swap() );
				break;
			case 1:
				s = Std.cast( new spell.Dig() );
				break;			
			case 2:
				s = Std.cast( new spell.ShapeSmall() );
				break;
			case 3:
				s = Std.cast( new spell.Mass() );
				break
			case 4:
				s = Std.cast( new spell.StarEater() );
				break;
			case 5:
				s = Std.cast( new spell.Decompression() );
				break;
			case 6:
				s = Std.cast( new spell.Fossilisation() );
				break;	
			case 7:
				s = Std.cast( new spell.Ascension() );
				break;
			case 8:
				s = Std.cast( new spell.Berserk() );
				break;
			case 9:
				s = Std.cast( new spell.Slice() );				
				break;
			case 10:
				s = Std.cast( new spell.Silence() );				
				break;
			case 11:
				s = Std.cast( new spell.Destruction() );				
				break;
			case 12:
				s = Std.cast( new spell.Shield() );				
				break;
			case 13:
				s = Std.cast( new spell.Nova() );				
				break;
			case 14:
				s = Std.cast( new spell.Ban() );				
				break;			
			case 15:
				s = Std.cast( new spell.LightBolt() );				
				break;			
			case 16:
				s = Std.cast( new spell.Paint() );				
				break;
				
				
				
				
			case 20:
				s = Std.cast( new spell.shot.LightBall() );				
				break;
			case 21:
				s = Std.cast( new spell.shot.LightBeam() );				
				break;
			case 22:
				s = Std.cast( new spell.shot.Solero() );				
				break;
			case 23:
				s = Std.cast( new spell.shot.Wisp() );				
				break;
			case 24:
				s = Std.cast( new spell.shot.Glue() );				
				break;
			case 25:
				s = Std.cast( new spell.shot.Flame() );				
				break;
			case 26:
				s = Std.cast( new spell.shot.HolyBall() );				
				break;
			case 27:
				s = Std.cast( new spell.shot.Phantom() );				
				break;					
				
		}
		s.sid = n
		//*/
		return s
	}
	
	
	
//{	
}












