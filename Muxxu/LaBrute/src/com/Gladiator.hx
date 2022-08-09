import Data;

enum LevelUp {
	LCaracs( c1 : Int, ?c2 : Int );
	LBonus( b : _Bonus );
}

class Gladiator{//}

	public static var SHIELD_VALUE = 45;

	public var flSurvival:Bool;
	public var flVandalism:Bool;
	public var flHeavyArms:Bool;
	public var flLeadBones:Bool;
	public var flBallerina:Bool;
	public var flStayer:Bool;
	public var flIncrevable:Bool;
	public var flCounter:Bool;
	public var flIronHead:Bool;

	public var lvl:Int;
	public var id:Int;

	public var name:String;


	public var fol:_Followers;

	public var force:Int;
	public var agility:Int;
	public var speed:Int;
	public var lifeMax:Int;

	public var multiForce:Float;
	public var multiAgility:Float;
	public var multiSpeed:Float;
	public var multiLifeMax:Float;

	public var startInit:Int;
	public var counter:Int;
	public var riposte:Int;

	public var combo:Int;
	public var armor:Int;

	public var parry:Int;
	public var dodge:Int;
	public var disarm:Int;
	public var accuracy:Int;

	public var armorLevel:Int;
	public var shieldLevel:Int;
	public var stanceId:Int;

	var smid:Int;

	public var defaultWeapon : _Weapons;
	public var lastBonus : _Bonus;
	public var lastCarac : Int;

	public var damageCoef:Array<Float>;
	public var bonus:Array<_Bonus>;
	public var weapons:Array<_Weapons>;
	public var followers:Array<_Followers>;
	public var supers:Array<_Super>;


	public var bonusWeight:Array<{id:_Bonus,w:Int}>;
	public var caracWeight:Array<Int>;
	public var totalBonusWeight : Int;


	var seed:mt.Rand;


	public function new(seed_id,?name:String,?fol) {
		this.id = seed_id;
		this.name = name;
		this.fol = fol;

		seed = new mt.Rand(0);
		seed.initSeed(id);

		if( fol!=null ){
			initFollower(fol);
		}else{
			initDestiny();
			initCaracs();
		}
	}

	function initDestiny() {
		// STANCE
		if( seed.random(1000)==0  )stanceId = seed.random(2);

		// CARAC
		caracWeight = [0,0,1,1,2,2,3,3];
		for( i in 0...3 )caracWeight.push(seed.random(4));

		// BONUS
		bonusWeight = [];
		totalBonusWeight = 0;
		for( o in Data.BONUS_WEIGHTS ) {
			bonusWeight.push({id:o.id,w:o.w});
			totalBonusWeight += o.w;
		}

		// RARE ABILITY
		if( seed.random(3)>0 )	setWeight(Super(THIEF),0);
		if( seed.random(3)>0 )	setWeight(Super(DOWNPOUR),0);
		if( seed.random(3)>0 )	setWeight(Super(HYPNO),0);
		if( seed.random(6)>0 )	setWeight(Permanent(IMMORTALITY),0);

		// RARE WEAPONS
		var rareWeapons = [ POIREAU, MUG, POELE, POUSSIN, TROMBONNE, KEYBOARD, NOODLES, RACKET];
		for( wid in rareWeapons )if( seed.random(4)>0 )setWeight(Weapons(wid),0);

		// INCAPACITY
		var a = [ KNIFE,SWORD,LANCE,STICK,TRIDENT,AXE,SCIMETAR,HAMMER,BIG_SWORD,FAN,SHURIKEN,WOOD_CLUB,IRON_CLUB,BONE_CLUB,FLAIL,WHIP ];
		var max = seed.random(3);
		for( i in 0...max )setWeight( Weapons( a[seed.random(a.length)] ), 0 );
	}

	public function initCaracs(){
		damageCoef=[1.0,1,1,1,1,1,1,1,1,1];

		force = 2;
		agility = 2;
		speed = 2;
		lifeMax = 2;

		lvl = 0;
		bonus = [];
		weapons = [];
		followers = [];
		supers = [];
		armor = 0;
		counter = 0;
		riposte = 0;
		combo = 0;
		parry = 0;
		dodge = 0;
		disarm = 0;
		accuracy = 0;
		startInit = 0;

		armorLevel = 0;
		shieldLevel = 0;

		defaultWeapon = HANDS;
		smid = 0;

		for( i in 0...2 )
			caracUp(caracWeight[seed.random(caracWeight.length)],1);
	}

	public function initFollower(fol){
		var datas = Data.FOLLOWERS[Type.enumIndex(fol)];

		lvl = 0;
		damageCoef=[1.0,1,1,1,1,1,1,1,1,1];

		bonus = [];
		weapons = [];
		followers = [];
		supers = [];

		force = 	datas.force;
		agility =	datas.agility;
		speed =		datas.speed;
		lifeMax =	datas.lifeMax;

		armor = 	0;

		counter = 	datas.counter;
		riposte = 	datas.riposte;
		combo =		datas.combo;
		parry =		datas.parry;
		dodge = 	datas.dodge;
		startInit = datas.init;

		disarm = 0;
		accuracy = 0;

		defaultWeapon = datas.dw;
	}

	public function nextLevel() {
		var c0 = seed.random(4);
		var bonus = null;
		if( lvl < 80 || seed.random(lvl) < 80 ) {
			var k = seed.random(totalBonusWeight);
			for( b in bonusWeight ) {
				k -= b.w;
				if( k < 0 ) {
					bonus = b.id;
					break;
				}
			}
			for( bid in this.bonus )
				if( bid == bonus ) {
					bonus = null;
					break;
				}
		}
		if( bonus != null )
			return [LBonus(bonus),LCaracs(c0)];
		var c1 = (c0 + 1 + seed.random(3)) % 4;
		var c2 = (c1 + 1 + seed.random(3)) % 4;
		return [LCaracs(c0),LCaracs(c1,c2)];
	}


	public function setLevels( n:Int, ?levels : haxe.io.Bytes ){

		if( levels == null ){
			levels = haxe.io.Bytes.alloc(Math.ceil(n/8));
			for( i in 0...levels.length )
				levels.set(i,seed.random(256));
		}


		multiForce =	1.0;
		multiAgility =	1.0;
		multiSpeed =	1.0;
		multiLifeMax =	1.0;
		initCaracs();
		while(lvl<n) {
			var l = nextLevel();
			var bit = (levels.get(lvl>>3)>>(lvl&7)) & 1;
			if( bit > 0 )
				seed.addSeed(seed.random(10007) + 131);
			switch( l[bit] ) {
				case LCaracs(c0,c1): if( c1 == null ) caracUp(c0,3) else { caracUp(c0,2); caracUp(c1,1); }
				case LBonus(b):		addBonus(b);
			}
			lvl++;
		}
		applyMulti();
	}

	public function applyMulti(){
		force = 	Std.int( force*multiForce );
		agility = 	Std.int( agility*multiAgility );
		speed = 	Std.int( speed*multiSpeed );
		lifeMax = 	Std.int( lifeMax*multiLifeMax );
	}

	function caracUp(c,inc) {
		switch(c) {
		case 0 :	force	+=inc;
		case 1 :	agility	+=inc;
		case 2 :	speed	+=inc;
		case 3 :	lifeMax	+=inc;
		}
	}
	function addBonus(id) {
		lastBonus = id;
		bonus.push(id);

		var mult = 1.5;
		var inc = 3;

		switch(id){
		case Permanent(p) :
			switch(p){
			case SUPER_FORCE :
				force += inc;
				multiForce *= 	1.5;
				superMalus();
			case SUPER_AGILITY :
				agility += inc;
				multiAgility *= 1.5;
				superMalus();
			case SUPER_SPEED :
				speed += inc;
				multiSpeed *= 	1.5;
				superMalus();
			case SUPER_LIFE :
				lifeMax += inc;
				multiLifeMax *= 1.5;
				superMalus();
			case IMMORTALITY :
				multiLifeMax *= 3.5;//2.75;
				multiForce *= 	0.75;
				multiAgility *= 0.75;
				multiSpeed *= 	0.75;
			case BLADE_MASTER :	damageCoef[1] += 0.5;
			case BRAWL_MASTER :	damageCoef[0] += 1;
			case VIGILANCE :	counter += 1;
			case PUGNACITY :	riposte += 30;
			case TWISTER :		combo += 20;
			case SHIELD :		parry += SHIELD_VALUE;	shieldLevel = 1;
			case ARMOR :
				armor += 5;
				multiSpeed *= 0.9;
				armorLevel +=1;
			case LEATHER_SKIN :	armor += 2;
			case UNTOUCHABLE :	dodge += 30;
			case VANDALISM : 	flVandalism = true;
			case CHOC : 		disarm += 50;
			case BLUNT_MASTER : flHeavyArms = true;
			case MERCILESS :	accuracy += 30;
			case SURVIVAL :		flSurvival = true;
			case LEAD_BONES :	flLeadBones = true;
			case BALLERINA :	flBallerina = true;
			case STAYER :		flStayer = true;
			case WARM_BLOODED :	startInit -= 200;
			case INCREVABLE :	flIncrevable = true;
			case DIESEL :
				speed += 5;
				multiSpeed *= 2.5;
				startInit += 200;
			case COUNTER :
				flCounter = true;
				parry += 10;
			case IRON_HEAD :
				flIronHead = true;

			default :

		}

		case Super(s) :	supers.push(s);
		case Followers(f) :
			followers.push(f);
			switch(f){
			case DOG_0 :	lifeMax -= 2;
			case DOG_1 :	lifeMax -= 2;
			case DOG_2 :	lifeMax -= 2;
			case PANTHER : 	lifeMax -= 6;
			case BEAR : 	lifeMax -= 8;
			}
			if(lifeMax<0)lifeMax = 0;
			if( seed.random(1000) >0 ){
				if( f==PANTHER )	setWeight( Followers(BEAR),0 );
				if( f==BEAR )		setWeight( Followers(PANTHER),0 );
			}
		case Weapons(w) :	weapons.push(w);
		case Talent(t) :
			// only one talent allowed
			for( t in Type.getEnumConstructs(_Talent) )
				setWeight(Talent(Type.createEnum(_Talent,t)),0);
		}
	}

	function superMalus(){
		var a = [ SUPER_FORCE, SUPER_AGILITY, SUPER_SPEED, SUPER_LIFE ];
		for( id in a )
			setWeight(Permanent(id), [3,1,0,0][(smid>3)?3:smid]);
		smid++;
	}

	public function setWeight(id,w) {
		for( o in bonusWeight ) {
			if( Type.enumEq(id,o.id) ) {
				totalBonusWeight += w - o.w;
				o.w = w;
				break;
			}
		}
	}

	// UTILS
	public function getLife(){
		return Std.int( 50 + (lifeMax+lvl*0.25)*6 );
	}

	// TOOLS
	public static function getSample( a:Array<_Bonus>, lvl:Int, base=0 ){
		var id = 2+base;
		var gl = null;
		for( i in 0...500 ){
			gl = new Gladiator(id);
			gl.setLevels(lvl);
			var ok = true;
			for( bon in a ){
				if( !gl.have(bon) ){
					ok = false;
					break;
				}
			}
			if( ok ) break;
			id++;
		}
		return id;
	}
	public function have(bon){
		for( b in bonus )if( Type.enumEq(b,bon) ) return true;
		return false;
	}

//{
}




