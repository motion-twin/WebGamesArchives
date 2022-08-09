import Datas;

typedef Path = Array<Int>;

class Power {
	public static function evaluate( u:db.Unit ) : Int {
		if (u.life <= 0)
			return 0;
		var lifePercent = u.life / u.getLogic().life;
		lifePercent = Math.max(0.3, lifePercent);
		return Math.round(lifePercent * (u.getLogic().power + u.getLogic().armor + u.getLogic().life));
	}

	public static function ofFleet( l:List<db.Unit> ) : Int {
		var result = 0;
		for (u in l)
			result += evaluate(u);
		return result;
	}
}

class BotIsle {
	public var idx : Int;
	public var townhall : Bool;
	public var pow : Int;
	public var owner : Int;
	public var isle : db.Isle;
	public var avgRange : Float;
	// human danger (neighboors and incoming)
	public var danger : Float;	
	// computer reinforcements
	public var reinforcement : Int;
	// stationnary units
	public var units : List<db.Unit>;

	public function new( idx:Int, isle:db.Isle ){
		this.idx = idx;
		this.isle = isle;
		this.owner = isle.ownerId;
		this.townhall = isle.hasBuilding(_Bld.TOWNHALL);
		this.units = isle.getUnits();
		if (owner == null && units.length > 0)
			owner = units.first().ownerId;
		pow = 0;
		danger = 0.0;
		avgRange = 0;
		reinforcement = 0;
		for (u in units){
			pow += Power.evaluate(u);
			avgRange += u.getLogic().range;
		}
		avgRange = avgRange / units.length;
	}
}

//
// Find a way to select an offensive position (high danger) or a defensive position (0 danger)
//
class ColonizationSelector {

	var origin : BotIsle;
	var bot : Bot;
	var map : BotMap;
	var empire : List<BotIsle>;
	var selected : IntHash<Bool>;
	var neutrals : List<BotIsle>;

	public function new( bot:Bot, map:BotMap ){
		this.bot = bot;
		this.map = map;
		this.selected = new IntHash();
		// compute our empire
		this.neutrals = new List();
		this.empire = new List();
		for (i in map.isles)
			if (i.owner == bot.me.userId)
				this.empire.push(i);
			else if (i.owner == null)
				this.neutrals.push(i);
	}

	public function select( from:db.Isle, range:Int, ?inspected:IntHash<Bool>=null ) : BotIsle {
		if (neutrals.length == 0)
			return null;
		var origin = map.getIsle(from.id);
		for (i in neutrals){
			if (map.isInRange(origin, i, range)){
				neutrals.remove(i);
				return i;
			}
		}
		if (inspected == null)
			inspected = new IntHash();
		inspected.set(origin.idx, true);
		for (i in empire){
			if (!inspected.exists(i.idx)){
				var result = select(i.isle, range, inspected);
				if (result != null)
					return result;
			}
		}
		return null;
	}
}

class BotMap {
	public var isles : Array<BotIsle>;
	var distances : Array<Array<Float>>;

	public function new( isles:List<db.Isle> ){
		var idx = 0;
		this.isles = [];
		for (i in isles)
			this.isles.push(new BotIsle(idx++,i));
		computeDistances();
	}

	public function init( botId:Int, travels:List<db.Travel> ){
		computeDanger(botId, travels);
	}

	public function findMotherIsland( player:db.GameUser ){
		for (i in isles)
			if (i.townhall && i.owner == player.userId)
				return i;
		return null;
	}

	public function findPath( source:BotIsle, dest:BotIsle, range:Int ) : Array<BotIsle> {
		var p = getBestPath(source.idx, dest.idx, range);
		var r = [];
		for (idx in p)
			r.push(isles[idx]);
		return r;
	}

	function getNeighboors( isle:BotIsle, range:Int ) : List<BotIsle> {
		var result = new List();
		for (i in 0...distances[isle.idx].length)
			if (i != isle.idx && distances[isle.idx][i] <= range)
				result.push(isles[i]);
		return result;
	}

	function getBestPath( a:Int, b:Int, range:Int ) : Path {
		var props = findPathes([a], b, range );
		return electPath(props);
	}

	function electPath( list:List<Path> ){
		var bestSize = 9999;
		var props = [];
		for (p in list){
			if (p.length < bestSize){
				props = [p];
				bestSize = p.length;
			}
			else if (p.length == bestSize){
				props.push(p);
			}
		}
		return props[Std.random(props.length)];
	}

	function findPathes( from:Path, to:Int, range:Int ) : List<Path> {
		var curr = from[from.length - 1];
		if (curr == to){
			var res = new List(); 
			res.push(from);
			return res;
		}
		var props = new List();
		for (i in 0...distances.length){
			if (i != curr && distances[curr][i] <= range && !Lambda.has(from, i)){
				var p = from.copy();
				p.push(i);
				for (np in findPathes(p, to, range))
					props.push(np);
			}
		}
		return props;
	}
	
	function computeDanger( botId, travels:List<db.Travel> ){
		for (isle in isles){
			if (isle.owner != botId && isle.pow > 0){
				var neighboors = new List();
				for (i in 0...distances[isle.idx].length){
					var d = distances[isle.idx][i];
					if (d == 0)
						continue;
					if (d < isle.avgRange)
						neighboors.push(isles[i]);
				}
				var danger = isle.pow / neighboors.length;
				for (i in neighboors)
					i.danger += danger;
			}
		}
		for (t in travels){
			var isle = getIsle(t.destId);
			if (t.ownerId == botId)
				isle.reinforcement += Power.ofFleet(t.getUnits());
			else
				isle.danger += Power.ofFleet(t.getUnits());
		}
	}

	public function isInRange( a:BotIsle, b:BotIsle, range:Int ){
		return distances[a.idx][b.idx] <= range;
	}

	public function getIsle( dbId:Int ){
		for (i in isles)
			if (i.isle.id == dbId)
				return i;
		return null;
	}

	function computeDistances(){
		distances = new Array();
		for (x in 0...isles.length){
			distances[x] = new Array();
			for (y in 0...isles.length){
				distances[x][y] = distance(isles[x].isle, isles[y].isle);
			}
		}
	}

	function distance( a:db.Isle, b:db.Isle ){
		return Math.sqrt(Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2));
	}
}
