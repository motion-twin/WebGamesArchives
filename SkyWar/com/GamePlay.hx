import Datas;

class GamePlay {//}

	public static var WORLD_WIDTH = 800;
	public static var WORLD_HEIGHT = 500;
	public static var INTER_BH = 50;

	// public static var TIME_FACTOR = 60.0 * 1000.0; // 1 time unit 1 minute
	public static var TIME_FACTOR = 45.0 * 1000.0; // 1 time unit is 45 second

	// game tick : duration of one game round
	public static var TICK = 10.0 * TIME_FACTOR;

	public static var BUILDING_BTIME_RATIO = 1.0;
	public static var SHIP_BTIME_RATIO = 1;
	public static var TRAVEL_TIME_RATIO = 3;
	public static var SEARCH_TIME_RATIO = 1;

	public static var START_MATERIAL = 100;
	public static var START_CLOTH = 0;
	public static var START_ETHER = 30;

	public static var MAX_UNITS = 99;

	public static var FOOD_STARVATION_LIMIT = 2;

	public static var PILLAGE_RATE = 0.25;
	public static var GRAVEYARD_ETHER_RATE = 0.2;
	public static var MARTIAL_ART_BONUS = 3;
	public static var ETHERAL_FIST_BONUS = 10;
	public static var GRANIT_SKIN_BONUS = 3;
	public static var BREEDING_BONUS = 3;
	public static var STAKES_DAMAGES = 5;
	public static var PARASITE_SPEED = 0.5;
	public static var ZORETH_STONE_BONUS = 0.25;
	public static var MARTIAL_ART_ATTACK_BONUS = 3;
	public static var MISSILE_BONUS = 5;
	public static var LASER_FIREFLY_FACTOR = 0.50; /* 0.90 => 10% bonus */
	public static var ETHERAL_GATE_BONUS = 1; // buildings armor bonus
	public static var WATCH_TOWER_COEF = 1.3;

	public static var DIVINE_HARPOON_BONUS = 3;

	public static function getPopulationGrowTime( food:Int, people:Int ) : Float {
		if( people >= food ) return 1000000000.0;
		return TIME_FACTOR * Std.int( 240/Math.min(20,food-people) );
	}

	public static function getPopulationStarveTime( food:Int, people:Int ) : Float {
		var limit = food + FOOD_STARVATION_LIMIT;
		if( people <= limit ) return 1000000000.0;
		return TIME_FACTOR * Std.int( 240/Math.min(20,people-limit) );
	}

	static var FREE = 0;
	static var TP_1 = 3;
	static var TP_2 = 10;
	static var TP_3 = 30;
	static var TP_4 = 100;

	public static function canBeDisabled( t:_Tec ) : Bool {
		return switch (t){
			case ESCORT: true;
			default: false;
		}
	}

	public static function getTechno( t:_Tec ) : { kind:_Tec, race:Int, time:Float, price:Int } {

		var result = switch (t){
			// RACE 0
			case HELICE:             { race:0, time: 240, price:TP_1 };
			case FORTIFIED_CLOTH:    { race:0, time: 240, price:TP_2 };
			case MILITARY_SERVICE:   { race:0, time: 240, price:FREE };

			case PARACHUTE:          { race:0, time: 360, price:TP_1 };
			case SHIELDS:            { race:0, time: 360, price:FREE };
			case VRILLE:             { race:0, time: 360, price:TP_2 };
			case STRETCH_SAIL:       { race:0, time: 360, price:TP_1 };
			case WINCH:              { race:0, time: 360, price:TP_4 };
			case CANON_POWDER:       { race:0, time: 360, price:FREE };
			case INVASION:           { race:0, time: 360, price:TP_2 };

			case ROYAL_CHIMNEY:      { race:0, time: 540, price:FREE };
			case PILLAGE:            { race:0, time: 540, price:TP_3 };

			case GEOLOGY:            { race:0, time: 720, price:TP_1 };
			case ASTRONOMY:          { race:0, time: 720, price:TP_2 };
			case ETHERODUC:          { race:0, time: 720, price:FREE };

			case FLEXIBLE_PISTON:    { race:0, time: 720, price:TP_2 };
			case LENS:               { race:0, time: 1120, price:FREE };		// was 720
			case SEWING_MACHINE:     { race:0, time: 720, price:TP_2 };
			case FERTILIZER:         { race:0, time: 720, price:FREE };
			case BOMBING_TACTIC:     { race:0, time: 720, price:TP_3 };
			case COMMUNICATION:      { race:0, time: 720, price:FREE };
			case MARTIAL_LAW:        { race:0, time: 720, price:TP_3 };

			case MISSILE:            { race:0, time:1200, price:TP_2 };
			case ACIETHER:           { race:0, time:1200, price:TP_3 };
			case NAPALMIEL:          { race:0, time:1400, price:FREE };
			case RESTORE:            { race:0, time:1120, price:TP_2 };		// was 1400
			case VARNISH:            { race:0, time:1800, price:FREE };
			case TRACTOR:            { race:0, time:1680, price:TP_2 };		// was 2160
			case ETHERAL_PROPULSION: { race:0, time:1760, price:TP_1 };		// was 2800
			case CUBIC_FUSION:       { race:0, time:2200, price:TP_3 };
			// UPDATE 1
			case DIVINE_HARPOON:     { race:0, time: 240, price:TP_2 };
			// UPDATE 3
			case MISSILE_STRAWMAN:   { race:0, time: 360, price:TP_2 };
			// UPDATE 5
			case ESCORT:             { race:0, time: 720, price:TP_2 };

			// RACE1
			case DANGREN_HERITAGE:   { race:1, time: 240, price:FREE };
			case FOSSIL_SEED:        { race:1, time: 240, price:FREE };
			case ETHERAL_GATE:       { race:1, time: 240, price:TP_2 };

			case CONCLAVE_AID:       { race:1, time: 360, price:TP_2 };
			case GRAVEYARD:          { race:1, time: 360, price:TP_4 };
			case MARTIAL_ART:        { race:1, time: 360, price:FREE };
			case LEVITATION:         { race:1, time: 360, price:TP_2 };
			case PILON:              { race:1, time: 360, price:FREE };

			case STAKES:             { race:1, time: 540, price:TP_1 };
			case TRANSLUCID_PAPER:   { race:1, time: 540, price:TP_2 };
			case ZORETH_STONE:       { race:1, time: 540, price:TP_1 };
			case GRANIT_SKIN:        { race:1, time: 540, price:TP_1 };
			case RECYCLE:            { race:1, time: 540, price:FREE };
			case HARE_POTION:        { race:1, time: 540, price:TP_1 };
			case POROUS_MARBLE:      { race:1, time: 540, price:TP_3 };
			case GOLEMISSARY:        { race:1, time: 540, price:TP_2 };

			case RAZOR_FIN:          { race:1, time: 720, price:FREE };
			case ETHERAL_FIST:       { race:1, time: 720, price:FREE };
			case BREEDING:           { race:1, time: 720, price:TP_2 };
			case TELESCOPIC_SPEAR:   { race:1, time: 720, price:FREE };
			case DRAGONFLY_TROWEL:   { race:1, time: 720, price:FREE };
			case STERILIZING_BATH:   { race:1, time: 720, price:TP_2 };

			case POISON_CLAWS:       { race:1, time:1080, price:TP_2 };
			case ADV_SCULPTOR:       { race:1, time:1200, price:TP_2 };
			case LASER_FIREFLY:      { race:1, time:1200, price:FREE };

			case STEROID_OAT:        { race:1, time:1400, price:TP_1 };
			case DRYAD:              { race:1, time:1800, price:TP_1 };
			case FIRE_BREATH:        { race:1, time:2400, price:TP_3 };
			case ETHERUPTION:        { race:1, time:1760, price:FREE };		// was 2800
			case HORN_OF_PLENTY:     { race:1, time:1760, price:TP_4 };		// was 3600
			// UPDATE 2
			case FLEXIBLE_CUIRASS:   { race:1, time:720,  price:TP_2 };
			// UPDATE 4
			case ARCADIE_FLAME:      { race:1, time:540,  price:TP_2 };
		}
		return {
			race: result.race,
				time: result.time * TIME_FACTOR * SEARCH_TIME_RATIO,
				price: result.price,
				kind: t
				};
	}

	public static function costToPower( race:Int, cost ) : Int {
		return Math.round(switch (race){
			case 0: cost.material + cost.ether * 2.5;
			case 1: cost.material * 2 + cost.ether * 2;
			default: throw "Unsupported race "+race;
			});
	}

	public static function getTechnoSearchTime( t:_Tec ){
		return getTechno(t).time;
	}

	public static function getTechnoRaceId( t:_Tec ){
		return getTechno(t).race;
	}

	public static function getFreeTechnos( raceId:Int ){
		var res = [];
		for (c in Type.getEnumConstructs(_Tec)){
			var t =  getTechno(Reflect.field(_Tec,c));
			if (t.race == raceId && t.price == 0)
				res.push(t.kind);
		}
		return res;
	}

	public static function getPopulationBuildBonus( people:Int ) : Float {
		if (people == 0)
			return 1000000000000.0;
		var p = Math.max(0.5, people/2);
		return Math.pow(4/p, 0.5);
	}


	public static var TEC_FERTILIZER_BONUS = 2;
	public static var TEC_TRACTOR_BONUS = 4;
	public static var TEC_VARNISH_BONUS = 10;


	#if neko

	inline public static function doMilitaryService( isle:db.Isle ){
		isle.attack ++;
		isle.defense ++;
	}

	inline public static function doCommunication( user:db.GameUser ){
		user.increaseMaxUnits(30);
	}

	inline public static function doFertilizer( i:db.Isle ) : Bool {
		var mod = i.countBuildings(_Bld.FIELD);
		if (mod > 0){
			i.addFood(mod * TEC_FERTILIZER_BONUS);
			return true;
		}
		else
			return false;
	}

	inline public static function doTractor( i:db.Isle ) : Bool {
		var mod = i.countBuildings(_Bld.FIELD);
		if (mod > 0){
			i.addFood(mod * TEC_TRACTOR_BONUS);
			return true;
		}
		else
			return false;
	}

	inline public static function doShield( u:db.Unit ) : Bool {
		if (u.getKind() == _Shp.DRAKKAR){
			u.life += ShipLogic.SHIELD_DRAKKAR_LIFE;
			return true;
		}
		else
			return false;
	}

	inline public static function doVarnish( u:db.Unit ) : Bool {
		u.life += TEC_VARNISH_BONUS;
		if (u.hasStatus(Parasite))
			u.delStatus(Parasite);
		return true;
	}

	// RACE1

	inline public static function doSteroid( u:db.Unit ) : Bool {
		return switch (u.getKind()){
			case TURTLE,HIPPOCAMP,SNAIL,GIANT_TURTLE,SQUID:
				u.life += ShipLogic.STEROID_OAT_LIFE;
				true;
			default:
				false;
		}
	}

	inline public static function doPorousMarble( u:db.Unit, t:List<_Tec> ) : Bool {
		return switch (u.getKind()){
			case HOPLITE, GOLIATH:
				var maxLife = u.getLogic().applyUserTechnos(t).life;
				u.life = Std.int(Math.min(u.life, maxLife));
				// u.life = Std.int(Math.max(1, u.life - ShipLogic.POROUS_MARBLE_LIFE_DEC));
				true;
			default:
				false;
		}
	}
	#end

//{
}
