import Race0;
import Race1;
import Datas;
import Constructable;

typedef IsleModification = {
	var food : Int;
	var attack : Int;
	var defense : Int;
	var view : Int;
}

class BuildingLogic extends Constructable {
	public static var ALL : List<BuildingLogic> = new List();

	public var type : _BldType;
	public var btime : Int;
	public var isUnique : Bool;
	public var isUniquePerIsle : Bool;
	public var kind : _Bld;
	public var power : Int;
	public var armor : Int;
	public var maxUnits:Int;
	public var buildingRequired : Array<_Bld>;
	public var technosRequired : Array<_Tec>;
	public var tickResources : Cost;
	public var isleModifications : IsleModification;
	public var searchBonus : Float;
	public var uniqueSearchBonus : Float;
	public var size : Int;
	public var race : Int;

	public function new( race:Int, k:_Bld ){
		ALL.push(this);
		this.race = race;
		this.isUnique = false;
		this.isUniquePerIsle = false;
		this.size = 1;
		this.power = 0;
		this.armor = 0;
		this.kind = k;
		this.life = 100;
		this.btime = life;
		this.cost = { material:0, cloth:0, ether:0, population:0 };
		this.buildingRequired = if (k == _Bld.TOWNHALL || k == _Bld.TEMPLE) [ null ] else [];
		this.technosRequired = [];
		this.tickResources = { material:0, cloth:0, ether:0, population:0 };
		this.isleModifications = { view:0, food:0, attack:0, defense:0 };
	}

	public function isCastel() : Bool {
		return (kind == TOWNHALL || kind == TEMPLE);
	}

	public function getImg() : String {
		return "/gfx/buildings/"+Std.string(kind).toLowerCase()+".png";
	}

	public function getType() : String {
		return switch (type){
			case BT_TEC: "Techno";
			case BT_SPECIAL: "Spécial";
			case BT_POP: "Population";
			case BT_MAIN: "Commandement";
			case BT_FOOD: "Nourriture";
			case BT_CONS: "Construction";
			case BT_RES: "Ressources";
			case BT_DEF: "Défense";
		}
	}

	public function requiresEtherSource() : Bool {
		return switch (kind){
			case PUMP,FOUNDRY,FOUNTAIN,SCULPTOR,HOT_SPRING,STONE_FORGE,SPRAYER,SOURCE,CAULDRON: true;
			default: false;
		}
	}
	
	public function getName() : String {
		return Lang.getBuildingInfo(kind).name;
	}

	public function getDesc() : String {
		return Lang.getBuildingInfo(kind).info;
	}

	public function getFlavour() : String {
		return Lang.getBuildingInfo(kind).back;
	}

	override function getBuildTime() : Float {
		return btime * GamePlay.TIME_FACTOR * GamePlay.BUILDING_BTIME_RATIO;
	}

	public function getId() : Int {
		return Type.enumIndex(kind);
	}

	#if neko

	public function getExtraTickResources( isle:db.Isle ) : { material:Int, ether:Int, cloth:Int } {
		return { material:0, ether:0, cloth:0 };
	}

	public function computeTick( isle:db.Isle, now:Float ) : Bool {
		return false;
	}

	// Called before the building is added to the isle's building list
	//
	public function built( isle:db.Isle, now:Float ){
		var player = isle.getPlayer();
		isle.addFood(isleModifications.food);
		isle.defense += isleModifications.defense;
		isle.attack += isleModifications.attack;
		isle.view = Std.int(Math.max(isle.view, isleModifications.view));
		if (uniqueSearchBonus != null && player.countBuildings(kind) == 0)
			player.addSearchBonus(uniqueSearchBonus, now);
        if (searchBonus != null)
            player.addSearchBonus(searchBonus, now);
        if (maxUnits != null)
            player.increaseMaxUnits(maxUnits);
		player.addBuilding(kind);
		tools.UpdateList.add(player);
	}

	// Called after the building has been removed from the isle's building list
	//
	public function destroyed( isle:db.Isle, now:Float ){
		var player = isle.getPlayer();
		player.delBuilding(kind);
		isle.addFood( -isleModifications.food );
		isle.defense -= isleModifications.defense;
		isle.attack -= isleModifications.attack;
		if (isleModifications.view > 0){
			isle.view = 100;
			for (b in isle.getBuildings()){
				var l = get(b.kind);
				if (l.isleModifications.view > isle.view)
					isle.view = l.isleModifications.view;
			}
		}
        if (searchBonus != null)
            player.delSearchBonus(searchBonus, now);
		if (uniqueSearchBonus != null && player.countBuildings(kind) == 0)
			player.delSearchBonus(uniqueSearchBonus, now);
        if (maxUnits != null)
            player.decreateMaxUnits(maxUnits);
		tools.UpdateList.add(player);
	}

	override public function canBuild( i:db.Isle ) : Bool {
		var user = i.getPlayer();
		return user.race == race
			&& cost.material <= user.material
			&& cost.cloth <= user.cloth
			&& cost.ether <= user.ether
			&& cost.population < i.population
			&& buildingRequirementsMet(i);
	}

	public function buildingRequirementsMet( i:db.Isle, ?alreadyInYard=false ){
		if (isUnique && i.getPlayer().countBuildings(kind) > 0)
			return false;
		if (!alreadyInYard && isUniquePerIsle && (i.hasBuilding(kind) || i.getYard().isProducing(kind)))
			return false;
		for (b in buildingRequired)
			if (!i.hasBuilding(b))
				return false;
		if (technosRequired.length == 0)
			return true;
		var player = i.getPlayer();
		for (t in technosRequired)
			if (!player.hasTechno(t))
				return false;
		return true;
	}

	#end

	public function buildingReqMet( isleBuildings:List<_Bld> ){
		var a = [];

		for (b in buildingRequired){

			if (!Lambda.has(isleBuildings, b))a.push( _LackBld(b) );
		}

		return a;
	}

	public function requirementsMet( isleBuildings:List<_Bld>, ?isleYard:List<_Bld>, userTechnos:List<_Tec>, ?userRessources:_Cost, ?alreadyInYard=false ) : Array<_Lack> {


		var a = [];

		for (b in buildingRequired){
			if (!Lambda.has(isleBuildings, b)) a.push( _LackBld(b) );
		}

		if ( !alreadyInYard && isUniquePerIsle && ((Lambda.has(isleBuildings, kind) || (isleYard != null && Lambda.has(isleYard, kind))))  )
			a.push( _LackUnique(kind) );

		for (t in technosRequired)
			if (!Lambda.has(userTechnos, t)) a.push( _LackTec(t) );

		if( userRessources!= null ){

			var c:_Cost = {
				_pop: 		cost.population - userRessources._pop,
				_material: 	cost.material - userRessources._material,
				_cloth:		cost.cloth - userRessources._cloth,
				_ether:		cost.ether - userRessources._ether,
			};

			if( c._cloth>0 || c._ether>0 || c._pop>0 || c._material>0 )	a.push(_LackCost(c));
		}

		return a;
	}


	public static function get( k:_Bld ) : BuildingLogic {
		return switch (k){
			// RACE0
			case TOWNHALL: Townhall.instance;
			case WORKSHOP: Workshop.instance;
			case FACTORY: Factory.instance;
			case QUARRY: Quarry.instance;
			case WEAVER: Weaver.instance;
			case PUMP: Pump.instance;
			case FIELD: Field.instance;
			case FARM: Farm.instance;
			case WINDMILL: WindMill.instance;
			case SCHOOL: School.instance;
			case UNIVERSITY: University.instance;
			case LABORATORY: Laboratory.instance;
			case BARRACKS: Barrack.instance;
			case WATCH_TOWER: WatchTower.instance;
			case CANON: Canon.instance;
			case YELLER: Yeller.instance;
			case ARCHIMORTAR: Archimortar.instance;
			case FIRE_STATION: FireStation.instance;
			case BUNKER: Bunker.instance;
			case ARCHITECT: Architect.instance;
			case FORT: Fort.instance;
			case FOUNDRY: Foundry.instance;

			// RACE1
			case TEMPLE: Temple.instance;
			case FOUNTAIN: Fountain.instance;
			case CORN: Corn.instance;
			case MENHIR: Menhir.instance;
			case HUT: Hut.instance;
			case SCULPTOR: Sculptor.instance;
			case GARDENER: Gardener.instance;
			case HOT_SPRING: HotSpring.instance;
			case DOJO: Dojo.instance;
			case GOLEM: Golem.instance;
			case FOREST: Forest.instance;
			case MINE: Mine.instance;
			case CAULDRON: Cauldron.instance;
			case STONE_FORGE: StoneForge.instance;
			case SHRINE: Shrine.instance;
			case FLOWERS: Flowers.instance;
			case PURIFICATION_TANK: PurificationTank.instance;
			case ORB: Orb.instance;
			case SPRAYER: Sprayer.instance;
			case SOURCE: Source.instance;
			case MAGIC_TREE: MagicTree.instance;
			case GOLEM_LAUNCHER: GolemLauncher.instance;
		}
	}


}
