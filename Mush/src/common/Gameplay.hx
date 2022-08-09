package ;
import Protocol;

import mt.bumdum9.Lib;
import mt.bumdum9.WeightList;
import mt.gx.Pair;

using Ex;

@:publicFields
class Gameplay {//}

	//
	static inline var INITIAL_O2 = 		30;
	static inline var INITIAL_FUEL = 	20;		// -10 de fuel
	static inline var INITIAL_RATION = 	32;

	//
	static var DECAY_POINTS_BASE = 18;		//
	static var DIG_RATE = 6;				// BASE DES RECHERCHES
	static var DIG_BOOST = 4;				// BOOST PAR COMPETENCES DES RECHERCHES
	
	
	static var DMG_SPORE_EXTRACTOR = 3;
	static var PATROLSHIP_EXTRA_AMMO = 6;
	static inline var ARMOUR_CORRIDOR = 1;
	static inline var LAMBDA_PER_MAGE_BOOK = 8;
	static inline var HERO_NOOB_LIMIT = 2;
	
	static inline var ZE_LIST_NB_NAME = 8;
	static inline var ZE_LIST_NAME_PER_DAY = 1;
	
	static inline var ICARUS_EXP_TICKS = 9;
	static inline var PATROL_EXP_TICKS = 3;
	
	static inline var PA_PER_MISSION = 3;
	static inline var DEVOTED_PA_PER_MISSION = 3;
	
	static inline var FIRE_AUTOWATERING_PC = 25;
	static inline var FIRE_MAX_SPREADS = 2;
	static inline var FIRE_SPREAD_PC = 30;
	
	static inline var FIRE_HERO_DMG_MIN = 2;
	static inline var FIRE_HERO_DMG_MAX = 2;
	
	static inline var FIRE_HULL_DMG_PC = 20;
	static inline var FIRE_HULL_DMG_MIN = 2;
	static inline var FIRE_HULL_DMG_MAX = 4;
	static inline var FIRE_OBJ_DMG_PC = 30;
	static inline var PERSISTENT_FACTOR = 1.05;
	
	static inline var 	PILGRED_MOD = 2;
	static var 			PILGRED_TAGS = [ENGINEER, PHYSICIST ];
	
	//modified by mod and re add for each helping tag then divided by succ hit
	static inline var PROJECT_TICK_MIN = 5;
	static inline var PROJECT_TICK_MAX = 10;
	
	static var 			RESEARCH_TAGS =  [BIOLOGIST, MEDIC];
	static var			COMPUTER_FREE_ACTIONS = [DIG_PROJECT, RESEARCH, REMOTE_PLANET_ANALYSIS, DEEP_PLANET_ANALYSIS, SCAN_FOR_PLANETS];
	
	static inline var NERON_BIOS_PROJ_BOOST = 1;
	static inline var NERON_BIOS_RSCH_BOOST = 1;
	
	static inline var MAX_MAGE_BOOK_PER_USER = 1;
	static var BB_BOX_ROOM = SPACESHIP_BAY_AA;
	
	public static var bookSkillTable : Array<{id:SkillId,weight:Int}> =
	[
		{id:ENGINEER, weight: 7 },
		{id:ENGINEER, weight: 7 },
		
		{id:PILOT, weight:6 },
		
		{id:PILOT, weight:6 },
		
		{id:ASTROPHYSICIAN, weight:10 },
		{id:BIOLOGIST, weight:10 },
		{id:BOTANIC, weight:10 },
		{id:GUNMAN, weight:8 },
		{id:MEDIC, weight:8 },
		{id:SPRINT, weight:8 },
		{id:RADIO_EXPERT, weight:8 },
		
		{id:FIREMAN, weight:2 },
		{id:COMPUTER, weight:2 },
		{id:SHRINK, weight:2 },
		{id:DIPLOMACY, weight:2 },
		{id:GUNMAN, weight:2 },
		{id:RADIO_EXPERT, weight:1 },
		
		{id:SHRINK, weight:4	 },
		{id:ROBOTICS, weight:4	 },
		{id:LOGISTICS, weight:2	 },
	];
	
	// GENERE UNE PLANETE
	public static function getPlanet(ship : db.Ship, id:Int) {
		var seed = new mt.Rand(id);
		
		var sz = 2 + seed.random(6) * 2;
		if ( ship.isHardMode())
			sz = 4 + seed.random( 7 ) * 2;
		else if ( ship.isVeryHardMode())
			sz = 6 + seed.random( 8 ) * 2;
			
		var planet:Planet = { size:sz, tags:[], name:"Jupiter" };
		
		// POOL
		var pool = [];
		var all = Type.allEnums(PlanetTag);
		var tot = 0;
		for ( en in all ) {
			var data = Protocol.planetTags[Type.enumIndex(en)];
			if ( data.cond != null && !ActionLogic.doDataCheckS(data.cond, ship ))
				continue;
			tot += data.we;
			pool.push( { data:data, we:data.we, max:data.max } );
		}
		
		// TAGS
		for( i in 0...planet.size ) {
			var rnd = seed.random(tot);
			var sum = 0;
			for( o in pool ) {
				sum += o.we;
				if( sum > rnd ) {
					planet.tags.push({tg:o.data.id,ts:TS_Unknown});
					o.max--;
					if( o.max == 0 ) {
						pool.remove(o);
						sum -= o.we;
					}
					break;
				}
			}
		}
		
		planet.tags.scramble();
		
		// NAME
		var a = Protocol.planetSyl;
		var f = function(n) return a[n].text[Std.random(a[n].text.length)];
		var name = f(0);
		if( seed.random(10) == 0 ) name += f(1);
		if( seed.random(40) == 0 ) name += f(1);
		name += f(2);
		if( seed.random(3) == 0 ) name += " "+f(3);
		else if( seed.random(30) == 0 ) name = f(3) + " " + name;
		planet.name = name;
		
		//
		return planet;
	}
	
	// Renvoie la liste des effets des médicaments de la partie
	public static function genDrugList() : Array<Array<ConsumableEffectType>>{
		var list = [];
		
		// INITIAL EFFECT
		for( e in DRUG_BASE_EFFECT ) list.push([PACKAGED,e]);
		Arr.shuffle(list);
		
		// ADD EXTRA EFFECTS
		var extra = DRUG_EXTRA_EFFECT.copy();
		while( extra.length > 0 ) {
			var a = list[Std.random(list.length)];
			
			var ok = true;
			for( k in a ) {
				switch(k) {
					case INC_MORAL(n), INC_MOVE(n), INC_ACTION(n), INC_LIFE(n) :
						ok = ok && Type.enumIndex(k) != Type.enumIndex(extra[extra.length - 1]);
					default:
				}
			}
			if( ok )a.push(extra.pop());
		}
		
		return list;
	}
	
	// Renvoie la liste des effets des plantes de la partie
	public static function genFruitList() : Array<Array<ConsumableEffectType>>{
		var list = [];
		
		// INITIAL EFFECT
		for( i in 0...Protocol.skinList.length ) {
			list.push([INC_ACTION(1), INC_NUTRITION(1)]);
			if( i%3 != 2 ) list[i].push(INC_MORAL(1));
		}
		
		var banana = list.shift();
		banana.push(INC_LIFE(1));
		
		Arr.shuffle(list);
		
		// DISEASE LISTS
		var give = new WeightList();
		var cure = new WeightList();
		for( data in Protocol.diseaseList ) {
			if( data.fr_give ) give.add(data.id, data.weight, 1);
			if( data.fr_cure ) cure.add(data.id, data.weight, 1);
		}
		
		// RANDOM EFFECT
		for( i in 0...Protocol.skinList.length-1 ) {
			
			var e:ConsumableEffectType = null;
			switch( i%5 ) {
				case 0,1 : e = CURE(cure.getRandom());
				case 2,3 : e = SET_DISEASE(give.getRandom(), Std.random(12), 1 + Std.random(8));
				case 4 : e = INC_ACTION(1);
			}
			
			if( Std.random(3) == 0 ) e = UNSTABLE(e, 25 + Std.random(10)*5);
			var a = list[Std.random(list.length)];
			a.push(e);
		}
		Arr.shuffle(list);
		
		list.unshift(banana);
		mt.gx.Debug.assert( list.length == Protocol.skinList.length );
		return list;
		
	}
	
	// Renvoie la liste des caracs d'arbres
	public static function genTreeList():Array<TreeData> {
		
		var grow = [	48, 24, 16,
						12, 12, 8, 8,
						8, 8, 8, 4,
						2];
						
		for ( i in grow.length...Protocol.skinList.length) {
			grow.push( 8 ) ;
		}
					
		///std chance
		var efx =
		[
			//grant one hp
			//[ OnCycle( RoomEffect( GrantHP(1) ) ) ],
			[],
			//incr transfert chance of hurt
			//[IncrPMPerTransfert( 2 ) ],
			[],
			//undirtify chance of item break
			[],
			//cleanse psy chance of phy dis
			[],
			//grant moral chance of break door
			[],
			//chance of grantPA chance of decr moral
			[],
			//double fruit production but dry faster
			[],
			//double oxy prod but spread fire
			[],
			//incr triumph by 16 but subject is dead
			[],
			//free spores
			[],
			//produce add metal scraps but hurt
			[],
			//grant moral chance of sex disease
			[],
		];
		
		
		Arr.shuffle(grow);
		Arr.shuffle(efx);
		
		var a = [];
		
		for ( x in 0...Protocol.skinList.length)
			a.push( {  grow:grow.pop() , effects:efx.pop()} );
			
		a.unshift( { grow:36, effects:[]  } );
		
		return a;
	}
	
	static var DRUG_BASE_EFFECT = [
		INC_MORAL(1), INC_MORAL(3),
		INC_ACTION(1), INC_ACTION(3),
		INC_MOVE(2), INC_MOVE(4),
		CURE(COLD),
		CURE(GASTROENTERITIS),
		CURE(VITAMIN_DEFICIT),
		CURE(TAPROOT),
		CURE(FLU),
		CURE(CHRONIC_HEADACHE),
	];
	
	static var DRUG_EXTRA_EFFECT = [
		CURE(SINUS_STORM),
		CURE(RUBEOLA),
		CURE(SYPHILIS),
		CURE(DEPRESSION),
		CURE(RASH),
		CURE(PARANOIA),
		CURE(SEPSIS),
		INC_LIFE(-1),
		INC_LIFE(-3),
		INC_MORAL(-2),
		INC_MOVE(-2),
		INC_MOVE(-5),
	];
	
	public static var CANT_LOVE = [RALUCA_TOMESCU];
	public static var FORBIDDEN_LOVE = [ new Pair( GIOELE_RINALDO, PAOLA_RINALDO) ];

	public static var CRISTAL_TO_GO = 3;
	static inline var HUNTER_PER_SHIP = 4;
//{
}





