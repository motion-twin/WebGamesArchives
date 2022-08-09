import Race0;
import Race1;
import Datas;
import Constructable;

class ShipLogic extends Constructable {
	public static var SHIELD_DRAKKAR_LIFE = 30;
	public static var STEROID_OAT_LIFE = 20;
	public static var POROUS_MARBLE_LIFE_DEC = 15;

	public static var ALL : Array<ShipLogic> = new Array();

	public var race : Int;
	public var kind : _Shp;
	public var btime : Int;
	public var power : Int;
	public var armor : Int;
	public var speed : Int;
	public var range : Int;
	public var capacities : Array<ShipCapacity>;
	public var requiredTechnos : Array<_Tec>;
	public var requiredBuildings : Array<_Bld>;

	function new( race:Int, k:_Shp, caracs, cost:Cost, btime:Int, ?capas, ?techs, ?buildings ){
		ALL[Type.enumIndex(k)] = this;
		this.race = race;
		this.kind = k;
		this.cost = cost;
		this.btime = btime;
		this.life = caracs.life;
		this.power = caracs.power;
		this.armor = caracs.armor;
		this.speed = caracs.speed;
		this.range = caracs.range;
		this.capacities = if (capas == null) [] else capas;
		this.requiredTechnos = if (techs == null) [] else techs;
		this.requiredBuildings = if (buildings == null) [] else buildings;
	}

	public function getIcon() : String {
		return "/gfx/ships/ic_"+Std.string(kind).toLowerCase()+".png";
	}

	public function getImg() : String {
		return "/gfx/ships/aide_"+Std.string(kind).toLowerCase()+".jpg";
	}

	public function getName() : String {
		return Lang.getShipInfo(kind).name;
	}

	public function hasCapacity( capa:ShipCapacity ) : Bool {
		return Lambda.has(capacities, capa);
	}

	public function getUnitsCost() : Int {
		return Std.int(Math.max(1, cost.population));
	}

	override public function getBuildTime() : Float {
		return btime * GamePlay.TIME_FACTOR * GamePlay.SHIP_BTIME_RATIO;
	}

	override public function getIsleBuildTime( b:List<_Bld>, t:List<_Tec> ) : Float {
		var bonus = 1.0;
		switch (race){
			case 0:
				if (Lambda.has(t, SEWING_MACHINE) && (kind == BALLOON || kind == BOMBER || kind == MIRE || kind == ATLAS || kind == DRAKKAR ))
					bonus *= 0.7;
				if (Lambda.has(b, _Bld.ARCHITECT))
					bonus *= 0.8;
				var nfactories = Lambda.count(Lambda.filter(b, function(bld) return bld == _Bld.FACTORY));
				if (nfactories > 0)
					bonus *= Math.pow(Factory.SHIP_PRODUCTION_FACTOR, nfactories);

			case 1:
				if (isInvocation()){
					var nShrines = Lambda.count(Lambda.filter(b, function(bld) return bld == _Bld.SHRINE));
					if (nShrines > 0)
						bonus *= Math.pow(Shrine.INVOCATION_TIME_BONUS, nShrines);
				}
				else {
					if (Lambda.has(t, _Tec.LASER_FIREFLY))
						bonus *= GamePlay.LASER_FIREFLY_FACTOR;
					var nSculptors = Lambda.count(Lambda.filter(b, function(bld) return bld == _Bld.SCULPTOR));
					bonus *= Math.pow(Sculptor.UNIT_CONSTRUCTION_BONUS, nSculptors);
				}
		}
		return bonus * getBuildTime();
	}

	public function isInvocation() : Bool {
		return switch (kind){
			case TURTLE, HIPPOCAMP, SNAIL, GIANT_TURTLE, SQUID: true;
			default: false;
		}
	}

	public function buildingReqMet( isleBuildings:List<_Bld>, playerTechno:List<_Tec> ){
		var a = [];
		for (b in requiredBuildings ){
			if (!Lambda.has(isleBuildings, b))
				a.push(_LackBld(b));
		}

		for( t in requiredTechnos )
			if (!Lambda.has(playerTechno, t))
				a.push(_LackTec(t));
		return a;
	}


	#if neko
	// Note: population is checked at the end of the construction.
	override public function canBuild( i:db.Isle ) : Bool {
		var user = i.getPlayer();
		return (user.units + Math.max(1, cost.population)) <= user.getMaxUnits()
            && cost.material <= user.material
			&& cost.cloth <= user.cloth
			&& cost.ether <= user.ether
			&& buildingRequirementsMet(i)
			&& technoRequirementsMet(i);
	}

	public function isAvailable( i:db.Isle ) : Bool {
		return buildingRequirementsMet(i) && technoRequirementsMet(i);
	}

	function buildingRequirementsMet( i:db.Isle ) : Bool {
		for (b in requiredBuildings)
			if (!i.hasBuilding(b))
				return false;
		return true;
	}

	function technoRequirementsMet( i:db.Isle ) : Bool {
		if (requiredTechnos.length == 0)
			return true;
		var technos = i.getPlayer().getTechnos();
		for (t in requiredTechnos)
			if (!Lambda.has(technos, t))
				return false;
		return true;
	}
	#end

	public function requirementsMet( blds, tecs, ?userRessources:_Cost ) : Array<_Lack>{
		var a = [];

		for (b in requiredBuildings)
			if (!Lambda.has(blds, b)) a.push( _LackBld(b) );


		for (t in requiredTechnos)
			if (!Lambda.has(tecs, t)) a.push( _LackTec(t) );

		if( userRessources!= null ){

			var c:_Cost = {
				_pop: 		cost.population - (userRessources._pop-1),
				_material: 	cost.material - userRessources._material,
				_cloth:		cost.cloth - userRessources._cloth,
				_ether:		cost.ether - userRessources._ether,
			};

			if( c._cloth>0 || c._ether>0 || c._pop>0 || c._material>0 )	a.push(_LackCost(c));
		}


		return a;
	}

	public function getId() : Int {
		return Type.enumIndex(kind);
	}

	public static function get( k:_Shp ) : ShipLogic {
		return ALL[Type.enumIndex(k)];
	}

	public function applyUserTechnos( technos:List<_Tec> ) : ShipLogic {
		var u = Reflect.copy(this);
		u.capacities = capacities.copy();
		for (t in technos){
			switch (t){
				// RACE0 ---------------------------------------------------------------------------
				case PARACHUTE:
					switch (u.kind){ case APICOPTER: u.capacities.push(Colonization); default: }

				case FORTIFIED_CLOTH:
					switch (u.kind){ case BALLOON,BOMBER,MIRE,ATLAS: u.armor += 1; default: }

				case SHIELDS:
					if (DRAKKAR == u.kind){
						u.life += SHIELD_DRAKKAR_LIFE;
						u.armor += 1;
					}
				case FLEXIBLE_PISTON:
					switch (u.kind){ case CONDOR,HARPIE,GAIA: u.speed += 100; default: }

				case HELICE:
					u.speed += 20;
					if (u.kind == APICOPTER) u.speed += 80;

				case STRETCH_SAIL:
					if (DRAKKAR == u.kind)
						u.speed += 100;

				case LENS:
					if (MIRE == u.kind){
						u.power += 20;
						u.capacities.push(Repartition);
					}

				case MARTIAL_LAW:
					u.power += 2;

				case ACIETHER:
					switch (u.kind){ case CONDOR,GAIA,GHOST: u.armor += 3; default: }

				case VARNISH:
					u.life += GamePlay.TEC_VARNISH_BONUS;
					// TODO protection a l'acide

				case NAPALMIEL:
					if (ATLAS == u.kind)
						u.capacities.push(Bomb(50));

				case ASTRONOMY:
					switch (u.kind){ case APICOPTER,DRAKKAR,BALLOON,BOMBER,HARPIE: u.range += 100; default: }

				case ETHERAL_PROPULSION :
					//switch (u.kind){ case GAIA,ATLAS: u.speed = Math.round(u.speed * 1.5); default: }

				case CUBIC_FUSION :
					switch (u.kind){ case MIRE,ATLAS: u.speed += 100; default: }

				case MISSILE:
					switch (u.kind){ case GHOST,CONDOR: u.power += GamePlay.MISSILE_BONUS; default: }

				case DIVINE_HARPOON:
					switch (u.kind){ case APICOPTER,DRAKKAR: u.power += GamePlay.DIVINE_HARPOON_BONUS; default: }

				// RACE1 ---------------------------------------------------------------------------

				case TRANSLUCID_PAPER:
					if (u.kind == FISH)
						u.capacities.push(Stealth);

				case RAZOR_FIN:
					if (u.kind == FISH)
						u.power += 3;

				case PILON:
					if (u.kind == HOPLITE)
						u.capacities.push(Bomb(20));

				case ETHERAL_FIST:
					switch (u.kind){ case HOPLITE,GOLIATH: u.power += GamePlay.ETHERAL_FIST_BONUS; default: }

				case FIRE_BREATH:
					if (u.kind == DRAGON)
						u.capacities.push(Repartition);

				case POROUS_MARBLE:
					switch (u.kind){
						case HOPLITE,GOLIATH:
							u.speed += 100;
							u.life -= POROUS_MARBLE_LIFE_DEC;
						default:
					}

				case GRANIT_SKIN:
					switch (u.kind){
						case HOPLITE,GOLIATH:
							u.armor += GamePlay.GRANIT_SKIN_BONUS;
						default:
					}

				case STEROID_OAT:
					switch (u.kind){
						case TURTLE,HIPPOCAMP,SNAIL,GIANT_TURTLE,SQUID:
							u.life += STEROID_OAT_LIFE;
						default:
					}

				case MARTIAL_ART:
					if (u.kind == HIPPOCAMP || u.kind == SKYWALKER )
						u.power += 3;

				case TELESCOPIC_SPEAR:
					if (u.kind == HIPPOCAMP)
						u.capacities.push(Init);

				case HARE_POTION:
					switch (u.kind) {
						case TURTLE,GIANT_TURTLE,HIPPOCAMP,SNAIL:
							u.speed += 100;
						default:
					}

				case POISON_CLAWS:
					if (u.kind == TURTLE){
						u.power += 5;
						u.capacities.push(Corrosive);
					}

				case FLEXIBLE_CUIRASS:
					switch (u.kind){
						case SNAIL,SQUID,HIPPOCAMP:
							u.armor += 2;
						default:
					}

				case ARCADIE_FLAME:
					u.power += 1;

				default:
			}
		}
		return u;
	}

	#if flash
	public function applyStatus(status:Int){
		for( i in 0...6 ){
			if( Cs.isStatus(status, i ) ) speed = Std.int(speed*GamePlay.PARASITE_SPEED );
		}
//if( Cs.isStatus(mc.data._status, Type.enumIndex(Parasite) ) ) speed;
	}
	#end

	static var __init = {
		// RACE0
		new ShipLogic(0, _Shp.APICOPTER,
			{ power:5, life:20, armor:0, speed:200, range:300 },
			{ population:1, material:30, cloth:0, ether:0, }, 50,
			null, null, [ _Bld.WORKSHOP ]
		);
		new ShipLogic(0, _Shp.DRAKKAR,
			{ power:15, life:60, armor:1, speed:100, range:400 },
			{ population:2, material:90, cloth:0, ether:0 }, 160,
			null, null, [ _Bld.WORKSHOP,_Bld.WEAVER ]
		);
		new ShipLogic(0, _Shp.BALLOON,
			{ power:0, life:25, armor:0, speed:100, range:300 },
			{ population:5, material:30, cloth:0, ether:20 }, 100,
			[ Colonization ], null, 
			[ _Bld.WEAVER ]
		);
		new ShipLogic(0, _Shp.BOMBER,
			{ power:0, life:25, armor:0, speed:100, range:300 },
			{ population:1, material:40, cloth:0, ether:20 }, 100,
			[ Bomb(40) ],
			[ _Tec.CANON_POWDER ],
			[ _Bld.WEAVER ]
		);
		new ShipLogic(0, _Shp.HARPIE,
			{ power:0, life:30, armor:1, speed:200, range:300 },
			{ population:1, material:60, cloth:0, ether:0 }, 50,
			[ Raid(15) ], null, 
			[ _Bld.WORKSHOP, _Bld.BARRACKS ]
		);
		new ShipLogic(0, _Shp.MIRE,
			{ power:30, life:90, armor:0, speed:100, range:400 },
			{ population:3, material:150, cloth:0, ether:80 }, 130,
			null, null, [ _Bld.WEAVER ]
		);
		new ShipLogic(0, _Shp.CONDOR,
			{ power:10, life:40, armor:4, speed:300, range:400 },
			{ population:1, material:110, cloth:0, ether:15 }, 90,
			[ Raid(20) ], null, 
			[ _Bld.FACTORY, _Bld.BARRACKS ]
		);
		new ShipLogic(0, _Shp.ATLAS,
			{ power:10, life:150, armor:0, speed:100, range:400 },
			{ population:3, material:220, cloth:0, ether:160 }, 260,
			[ Multi(10) ], null, 
			[ _Bld.FACTORY, _Bld.WEAVER ]
		);
		new ShipLogic(0, _Shp.GHOST,
			{ power:20, life:20, armor:1, speed:300, range:600 },
			{ population:1, material:50, cloth:0, ether:50 }, 70,
			[ Init, Stealth ],
			[ _Tec.ETHERAL_PROPULSION],
			[ _Bld.FACTORY ]
		);
		new ShipLogic(0, _Shp.GAIA,
			{ power:35, life:400, armor:4, speed:100, range:400 },
			{ population:5, material:500, cloth:0, ether:200 }, 400,
			[ Multi(4) ],
			[ _Tec.CUBIC_FUSION ],
			[ _Bld.FACTORY, _Bld.UNIVERSITY ]
		);

		// RACE1
		new ShipLogic(1, _Shp.TURTLE,
			{ power:8, life:30, armor:2, speed:100, range:400 },
			{ population:1, material:10, ether:20, cloth:0 }, 80,
			[ Colonization ], null, 
			[ _Bld.MENHIR ]
		);
		new ShipLogic(1, _Shp.FISH,
			{ power:5, life:15, armor:0, speed:300, range:400 },
			{ population:0, material:20, ether:5, cloth:0 }, 25,
			null, null, [ _Bld.SCULPTOR ]
		);
		new ShipLogic(1, _Shp.HOPLITE,
			{ power:20, life:75, armor:1, speed:100, range:300 },
			{ population:0, material:110, ether:30, cloth:0 }, 130,
			null, null, [ _Bld.SCULPTOR ]
		);
		new ShipLogic(1, _Shp.HIPPOCAMP,	// HYDRON
			{ power:12, life:40, armor:0, speed:200, range:400 },
			{ population:1, material:10, ether:40, cloth:0 }, 100,
			null, null, [ _Bld.MENHIR, _Bld.DOJO ]
		);
		new ShipLogic(1, _Shp.SNAIL,
			{ power:25, life:60, armor:0, speed:100, range:400 },
			{ population:2, material:0, ether:100, cloth:0 }, 260,
			[ Scout, Corrosive ], null, 
			[ _Bld.MENHIR, _Bld.SHRINE ]
		);
		new ShipLogic(1, _Shp.GIANT_TURTLE,
			{ power:40, life:100, armor:6, speed:100, range:400 },
			{ population:2, material:80, ether:230, cloth:0 }, 260,
			[ Regeneration, Aura(Pack) ], // +les unités du groupe gagnent la capacité meute
			null, [ _Bld.ORB ]
		);
		new ShipLogic(1, _Shp.SQUID,
			{ power:20, life:150, armor:-2, speed:200, range:500 },
			{ population:2, material:50, ether:400, cloth:0 }, 320,
			[ Multi(7) ], null, 
			[ _Bld.ORB ]
		);
		new ShipLogic(1, _Shp.DRAGON,
			{ power:100, life:200, armor:1, speed:200, range:400 },
			{ population:0, material:350, ether:100, cloth:0 }, 550,
			[ Raid(100) ],
			[ _Tec.ADV_SCULPTOR ],
			[ _Bld.SCULPTOR ]
		);
		new ShipLogic(1, _Shp.GOLIATH,
			{ power:30, life:120, armor:3, speed:100, range:300 },
			{ population:0, material:160, ether:100, cloth:0 }, 260,
			[ Multi(2) ],
			[ _Tec.ADV_SCULPTOR ],
			[ _Bld.SCULPTOR ]
		);
		new ShipLogic(1, _Shp.SKYWALKER,
			{ power:2, life:10, armor:0, speed:200, range:400 },
			{ population:1, material:0, ether:2, cloth:0 }, 40,
			[ Colonization, FleetTarget(40) ],
			[ _Tec.LEVITATION ],
			[ _Bld.DOJO ]
		);
		true;
	}


}



