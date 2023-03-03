import Common;
import db.Map;

typedef AttackValue = {
	var value:Int;
}

using Lambda;
class Horde {

	static function getCacheFile( file ) {
		return Config.ROOT + file;
	}
	
	static var ATTACKS = {
		var tmp =ods.Data.parse( "ods/chantiers.ods", "Attaques", AttackValue );
		tmp.map(function(v) return v.value).array();
	}
	
	static public function getAttacks(map:Map) {
		return ATTACKS;
	}

	public static function getTotalAttack(map:Map,day:Int) : Int {
		var list = getAttacks(map);
		if( day > list.length )
			return list[list.length - 1] + (day - list.length) * 1250;
		
		if( day == list.length )
			return list[list.length - 1];
		
		return list[day];
	}

	/*------------------------------------------------------------------------
	CALCUL ATTAQUE D'UNE JOURNÉE
	------------------------------------------------------------------------*/
	public static function getTotalAttackForMap(map:Map, day:Int) : Int {
		var attList = getAttacks(map);
		var diff = map.getDiff();
		var rseed = new mt.Rand(0);
		rseed.initSeed( if( App.PROD ) map.id + day + Const.get.DebugSeed else Std.random(999999) );
		
		if( day == 1 )
			return Math.floor( diff * (attList[1] + rseed.random(10)) );
		// chance que l'attaque soit plus puissante (ie. basée sur jour+1 voire +2)
		if( day >= 2 && day < 8 && rseed.random(100) < 25 && !map.hasFlag("smoothAttack") ) day ++;
		else if( day >= 8 && rseed.random(100) < 20 ) day ++;
		
		if( day >= 5 && day < 8 && rseed.random(100) < 13 && !map.hasFlag("smoothAttack") ) day++;
		
		var prev = getTotalAttack(map, day - 1);
		var today = getTotalAttack(map, day);
		if( today == prev ) { // argh, dépassement du jour max...
			prev = attList[attList.length - 2];
			today = attList[attList.length - 1];
		}
		
		var adjFactor = 1.0;
		if ( map.hasMod("SHAMAN_SOULS") ) {
			var count = db.MapVar.getValue(map, "hauntedSouls", 0);
			adjFactor += soulsFactor(map.isHardcore(), count);
		}
		
		if( map.hasFlag("smoothAttack") ) adjFactor *= 0.75;
		if( map.hasFlag("bigAttack") ) adjFactor *= 1.25;
		
		var coef = 0.01 * db.MapVar.getValue(map, "attackPercent", 100);
		return Math.floor( coef * diff * adjFactor * (prev + rseed.random(today - prev)) );
	}
	
	inline static function soulsFactor(hardcore:Bool, souls:Int) {
		return Math.min( hardcore ? 0.40 : 0.20, souls * 0.04 );
	}
	
	private static function getRange(real:Int, q:Float) : Int {
		var n = 20;
		if( real < 200) n = 70;
		else if(real < 1000) n = 200;
		else if(real < 2000) n = 600;
		else if(real < 3000) n = 1100;
		else if(real < 4000) n = 1600;
		else n = 2500;
		return Math.floor( n * (1 - q) );
	}

	/*------------------------------------------------------------------------
	ESTIMATION (NOUVELLE TOUR DE GARDE)
	------------------------------------------------------------------------*/
	public static function getTotalAttackTowerEst(map:Map,day,quality:Float):{min:Int, max:Int} {
		var rseed = new mt.Rand( map.id + day * day );
		var real = getTotalAttackForMap(map, day);
		var baseRange = getRange(real, 0);
		var range = baseRange;
		var min : Int = Math.ceil(Math.max(0, real-rseed.random(range)));
		var max : Int = real + rseed.random(range);
		var granularity = 40;
		var loops = Math.floor(quality * granularity);
		for( iq in 1...loops ) {
			var move = Math.ceil( range * 0.03 );
			move += rseed.random( Math.ceil( range * 0.04 ) );
			var deltaMin = Math.abs(real - min);
			var deltaMax = Math.abs(real - max);
			var chanceMoveMin = 50;
			if( deltaMin > 1.3 * deltaMax ) chanceMoveMin = 72;
			if( deltaMax > 1.3 * deltaMin ) chanceMoveMin = 28;
			var fl_moveMin = rseed.random(100) <= chanceMoveMin;
			if( fl_moveMin && min+move > real ) fl_moveMin = false;
			if( !fl_moveMin && max-move < real ) fl_moveMin = true;
			if( fl_moveMin ) {
				min += move;
			} else {
				max -= move;
			}
			if( min > real ) min = real - (min-real);
			if( max < real ) max = real + (real-max);
			if( min > max ) min = max;
			range = max - min;
		}
		
		var adjFactor = 1.0;
		if ( map.hasMod("SHAMAN_SOULS") ) {
			var count = db.MapVar.getValue(map, "hauntedSouls", 0);
			adjFactor += soulsFactor(map.isHardcore(), count);
		}
		
		var coef = 0.01 * db.MapVar.getValue(map, "attackPercent", 100);
		min = Math.ceil(min * coef);
		max = Math.ceil(max * coef);
		return {min: Math.floor(min), max:Math.floor(adjFactor*max)};
	}
}
