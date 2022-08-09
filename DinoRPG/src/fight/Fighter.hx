package fight;
import Fight;
import data.Skill.SkillType;

enum CancelEvent {
	Exception;
}

enum StatusTime {
	DShort;
	DMedium;
	DLong;
	DInfinite;
}

typedef AttackInfos = {
	var from : Fighter;
	var target : Fighter;
	var lost : Int;
	var dmg : Array<Int>;
	var assault : Bool;
	var esquive : Bool;
	var invoc : Bool;
}

typedef Event<T,N> = {
	var priority : Int;
	var proba : Int;
	var notify : N;
	var fx : T;
	var energy : Int;
}

typedef StatusInfos = {
	var status : _Status;
	var time : Int;
	var rem : Int;
	var cycle : Bool;
	var cancel : Void -> Void;
}

enum EventNotify {
	NSkill( s : data.Skill );
	NObject( o : data.Object );
}

enum Restriction {
	RObject;
	RMagicObject;
	REffects;
}

typedef TAEvent = Array<Event<Void->Void, EventNotify>>;
typedef TAAttack = Array<Event<Void->Void, data.Skill>> ;

class Fighter {

	inline public static var DEFAULT_MAX_ENERGY = 100;
	static var DEFENSES = [1,0.5,0.5,1.5,1.5];

	//Nombre d'attaques qu'un combattant enchaine
	public var combo : Int;
	// INFOS
	public var id(default,null) : Int;
	public var dino : db.Dino;
	public var monster : data.Monster;
	public var level : Int;
	public var name : String;
	public var side : Bool;
	public var originalSide(default,null) : Bool;
	public var elements : Array<Int>;
	public var elementsOrder : Array<Int>;
	public var time : Int;
	public var life : Int;
	public var startLife : Int;

	public var maxEnergy(default, setMaxEnergy) : Int;
	public var energy(default, setEnergy ) : Int;
	
	public var deleteObjects : Bool = true;
	
	// BONUSES
	public var assaultsBonus : Array<Int>;
	public var powerBonus : Array<Int>;
	public var allAssaultsBonus : Int;
	public var nextAssaultBonus : Int;
	public var nextAssaultMultiplier : Float;
	public var assaultMultiplier:Float;
	public var armor : Int;
	public var defense : Array<Float>;

	// SPECIAL BONUSES
	public var multiAttack : Float;
	public var counterAttack : Float;
	public var esquive : Float;
	public var minDamage : Int;
	
	public var minAssaultDamage : Int;

	public var timeMultiplier(default, set) : Float;
	function set_timeMultiplier(v:Float):Float {
		if( v <=  0.25 ) v = 0.25;
		timeMultiplier = v;
		return timeMultiplier;
	}
	
	public var timeMultipliers : Array<Float>;
	public var objectProbaMultiplier : Float;
	public var initMultiplier : Float;
	public var recoveryMultiplier : Float;
	
	public var perception : Bool;
	public var canFightIntang : Bool;
	public var canFightFlying : Bool;
	public var canEscape : Bool;
	public var cancelArmor : Bool;
	public var markAsRock : Bool;
	public var costumeFlag : Bool;
	public var flyAfterAttack : Bool;
	public var superEsquive : Float;// to esquive assault and events
	
	public var cloneDefaultLife : Int;
	public var nextAttack : Null<Event<Void->Void, data.Skill>> ;
	public var nextEvent : Null<Event<Void->Void, EventNotify>> ;
	public var restrictions : Array<Restriction>;
	public var lockedElement : Bool;
	public var cantEsquiveAssault : Bool;
	public var cantReduceMaxEnergy : Bool;
	// EVENTS
	public var afterAttack : List<AttackInfos->Void>;
	public var afterDefense : List<AttackInfos->Void>;
	public var afterFight : List<Void->Void>;
	
	public var targetFilters : Array<Array<Fighter>->Array<Fighter>>;
	
	public var onStatus : List<_Status->Bool>;
	public var onKill : List<Void->Bool>;
	public var onLost : List<Int->Int> ;
	public var beforeTurn : List<Void->Void> ;

	public var events : TAEvent;
	public var eventsFilters : Array<TAEvent->TAEvent> ;
	
	public var attacks : TAAttack;
	public var attacksFilters : Array<TAAttack->TAAttack> ;
	
	public var defenses : List<AttackInfos->Void> ;
	public var onTargeted : List<Fighter->Fighter> ;

	// VARIABLES
	public var curTarget : Fighter;
	public var noReturn : Bool;
	public var status : List<StatusInfos>;
	public var balanced : Bool;
	public var castleAttacks : Int;
	public var dinoRef : db.Dino;
	public var cyclePos : Int;
	public var hypnotized : Bool;
	public var underFuca : Bool;
	public var invocations : Int;
	public var hasUsedFujin:Bool;
	
	public var hasSifflet:Bool;
	
	public function new( id, lf, elts, side ) {
		this.id = id;
		this.side = originalSide = side;
		timeMultiplier = 1;
		combo = 0;
		objectProbaMultiplier = 1;
		initMultiplier = 1.0;
		//
		maxEnergy = DEFAULT_MAX_ENERGY;
		energy = maxEnergy;
		recoveryMultiplier = 1.0;
		//
		underFuca = false;
		elements = elts;
		timeMultipliers = [1.,1.,1.,1.,1.,1.];
		assaultsBonus = [0,0,0,0,0,0];
		powerBonus = [0,0,0,0,0,0];
		defense = computeDefenses( elts );
		allAssaultsBonus = 0;
		nextAssaultBonus = 0;
		nextAssaultMultiplier = 1;
		assaultMultiplier = 1.0;
		counterAttack = 1;
		multiAttack = 1;
		invocations = 1;
		hasUsedFujin = false;
		hasSifflet = false;
		armor = 0;
		esquive = 1;
		minDamage = 1;
		minAssaultDamage = 1;
		superEsquive = 1;
		restrictions = new Array();
		events = new Array();
		eventsFilters = new Array();
		attacks = new Array();
		attacksFilters = new Array();
		defenses = new List();
		targetFilters = new Array();
		onTargeted = new List();
		//
		startLife = lf;
		life = lf;
		//
		cloneDefaultLife = 1;
		afterAttack = new List();
		afterDefense = new List();
		afterFight = new List();
		status = new List();
		onStatus = new List();
		onKill = new List();
		onLost = new List();
		beforeTurn = new List();
		var tmp = new Array();
		var count = if( elements[Data.VOID] > 0 ) 6 else 5;
		for( i in 0...count )
			tmp.push({ e : i, v : elements[i] + (Std.random(100) / 200) });
		tmp.sort(function(a, b) { return (b.v < a.v) ? -1 : 1; });
		elementsOrder = Lambda.array(Lambda.map(tmp, function(e) { return e.e; }));
		cyclePos = 0;
		castleAttacks = 1;
		castleAttacks = 1;
		cancelArmor = false;
		lockedElement = false;
		cantEsquiveAssault = false;
		cantReduceMaxEnergy = false;
		canEscape = true;
	}
	
	public function getMajorElement():Int {
		var best:Int = elements[0];
		var bestId:Int = 0;
		for( i in 1...elements.length ) {
			if( elements[i] > best ) {
				best = elements[i];
				bestId = i;
			}
		}
		return bestId;
	}
	
	function setMaxEnergy( value : Int ) {
		this.maxEnergy = 	if( value > 200 ) 200
							else if( value < 0 ) 1
							else value;
		
		if( this.maxEnergy < DEFAULT_MAX_ENERGY && cantReduceMaxEnergy )
			this.maxEnergy = DEFAULT_MAX_ENERGY;
		
		return this.maxEnergy;
	}
	
	function setEnergy( value : Int ) {
		this.energy = 	if( value > maxEnergy ) maxEnergy
						else if( value < 0 ) 0
						else value;
		return this.energy;
	}
	
	public static function computeDefenses( elements : Array<Int> ) {
		var defense = [0.,0.,0.,0.,0.,0.];
		for( i in 0...5 ) {
			var k = 0.;
			for( j in 0...5 )
				k += elements[(i+j)%5] * DEFENSES[j];
			defense[i] = k;
			defense[Data.VOID] += elements[i];
		}
		return defense;
	}

	public function clone(fid,?startLife) {
		var c = new fight.Fighter(fid, if( startLife == null ) this.startLife else startLife, elements, originalSide);
		c.allAssaultsBonus = allAssaultsBonus;
		c.armor = armor;
		c.assaultsBonus = assaultsBonus.copy();
		c.canFightFlying = canFightFlying;
		c.canFightIntang = canFightIntang;
		c.cancelArmor = cancelArmor;
		c.counterAttack = counterAttack;
		c.defense = defense.copy();
		c.esquive = esquive;
		c.superEsquive = superEsquive;
		c.level = level;
		c.markAsRock = markAsRock;
		c.minDamage = minDamage;
		c.monster = monster;
		c.multiAttack = multiAttack;
		c.name = name;
		c.objectProbaMultiplier = objectProbaMultiplier;
		c.perception = perception;
		c.powerBonus = powerBonus.copy();
		c.side = side;
		c.timeMultiplier = timeMultiplier;
		c.timeMultipliers = timeMultipliers.copy();
		c.startLife = startLife;
		c.time = time;
		c.balanced = balanced;
		c.minDamage = minDamage;
		c.minAssaultDamage = minAssaultDamage;
		if( dino != null )
			c.dinoRef = dino;
		if( dinoRef != null )
			c.dinoRef = dinoRef;
		return c;
	}

	function calculateSize( d : db.Dino ) {
		if( d != null )
			return d.maxLife;
		return monster.size;
	}

	public function infos() : FighterInfos {
		var d = if( dinoRef != null ) dinoRef else dino;
		return {
			_fid : id,
			_side : side,
			_name : name,
			_life : life,
			_size : calculateSize(d),
			_gfx : if( d != null ) d.gfx else if( monster.gfx != null ) monster.gfx else monster.frame,
			_dino : d != null || monster.gfx != null,
			_props : if( monster == null ) [] else Lambda.array(monster.props),
		};
	}

	public function isBoss() {
		if( monster == null )
			return false;
		for( p in monster.props )
			if( p == _PBoss )
				return true;
		return false;
	}

	public function attack( elt : Int, mult : Int ) {
		var a = [0,0,0,0,0,0];
		a[elt] = elements[elt] * mult;
		return a;
	}

	public function customAttack( fire, wood, water, thunder, air ) {
		var c = [fire, wood, water, thunder, air, 0];
		for( i in 0...5 )
			c[i] *= elements[i];
		return c;
	}

	public function addEvent(prio, proba, s, f) {
		var e = {
			priority : prio,
			proba : proba,
			notify : NSkill(s),
			fx : f,
			energy : s.energy,
		};
		events.push(e);
		return e;
	}

	public function addObject(prio, proba, o, f) {
		var e = {
			priority : prio,
			proba : proba,
			notify : NObject(o),
			fx : null,
			energy : 0,
		};
		var me = this;
		e.fx = function() {
			f();
			me.events.remove(e);
		};
		events.push(e);
		return e;
	}

	public function addAttack(prio, proba, s, f) {
		attacks.push({
			priority : prio,
			proba : proba,
			notify : s,
			fx : f,
			energy : s.energy,
		});
	}

	public function modDefense( elt : Int, v : Int ) {
		for( i in 0...5 )
			defense[i] += v * DEFENSES[(elt - i + 5) % 5];
	}

	//decroissant
	static function sortEvents<T,N>(e1 : Event<T,N>, e2 : Event<T,N>) {
		return e2.priority - e1.priority;
	}

	public function finalize() {
		events.sort(sortEvents);
		attacks.sort(sortEvents);
	}

	public function currentElement( ?incr ) {
		var e = elementsOrder[cyclePos % elementsOrder.length];
		if( incr && !lockedElement )
			cyclePos++;
		return e;
	}

	public function hasStatus(pst : _Status) {
		var st : EnumValue = cast pst;
		if( Type.enumParameters(st).length != 0 ) {
			var cstr = Type.enumConstructor(st);
			for( s in status )
				if( Type.enumConstructor(cast s.status) == cstr )
					return true;
		} else {
			for( s in status )
				if( s.status == pst )
					return true;
		}
		return false;
	}

	public function toString() {
		return name + "#" + id;
	}

	public function assaultValue( e : Int ) {
		return elements[e] * 5 + allAssaultsBonus + assaultsBonus[e];
	}

	public function calculatePower() {
		var p = 0.;
		var s = new Array();
		for( e in 0...5 ) {
			var delta = (assaultValue(e) * 1.1) * 0.9 - Math.ceil(defense[e]);
			if( delta < 1 ) delta = 1;
			delta = Math.ceil(Math.pow(delta,0.6));
			p += delta;
			s.push(delta);
		}
		return { p : p, s : s };
	}
}
