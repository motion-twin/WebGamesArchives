import Datas;

class Race1Building extends BuildingLogic {
	function new( k:_Bld ){
		super(1, k);
	}

	override public function getIsleBuildTime( b:List<_Bld>, t:List<_Tec> ) : Float {
		var bonus = 1.0;
		if (kind == GOLEM && Lambda.has(b, SCULPTOR)){
			var n = 0;
			for (l in b)
				if (l == SCULPTOR)
					n++;
			bonus *= Math.pow((1.0 - Sculptor.GOLEM_CONTRUCTION_BONUS), n);
		}
		if (kind == FOREST && Lambda.has(t, FOSSIL_SEED))
			bonus *= 1/2;
		if (Lambda.has(t, DRAGONFLY_TROWEL))
			bonus *= 0.70;
		return bonus * super.getIsleBuildTime(b, t);
	}
}

class Temple extends Race1Building {
	public static var instance = new Temple();

	function new(){
		super(_Bld.TEMPLE);
		size = 2;
		life = 300;
		type = BT_MAIN;
		isUnique = true;
		maxUnits = 20;
		isleModifications.food = 5;
		tickResources.material = 5;
		tickResources.ether = 2;
		btime = 400;
	}

	#if neko
	override public function getExtraTickResources( isle:db.Isle ) : { material:Int, ether:Int, cloth:Int } {
		if (isle.getPlayer().hasTechno(HORN_OF_PLENTY))
			return { material:8, ether:8, cloth:0 };
		return super.getExtraTickResources(isle);
	}
	#end
}

class Fountain extends Race1Building {
	public static var instance : BuildingLogic = new Fountain();

	function new(){
		super(_Bld.FOUNTAIN);
		life = 100;
		type = BT_RES;
		tickResources.ether = 2;
		cost.material = 75;
		btime = 75;
	}

	#if neko
	override public function computeTick( isle:db.Isle, now:Float ) : Bool {
		var player = isle.getPlayer();
		if (player.hasTechno(STERILIZING_BATH)){
			for (u in isle.getUnits()){
				if (u.status != 0){
					if (u.hasStatus(Parasite))
						u.delStatus(Parasite);
					else if (u.hasStatus(Poison))
						u.delStatus(Poison);
					tools.UpdateList.add(u);
					return false;
				}
			}
		}
		return false;
	}
	#end
}

class Corn extends Race1Building {
	public static var instance : BuildingLogic = new Corn();

	function new(){
		super(_Bld.CORN);
		life = 50;
		type = BT_FOOD;
		isleModifications.food = 1;
		cost.material = 40;
		btime = 40;
	}
}

class Menhir extends Race1Building {
	public static var instance : BuildingLogic = new Menhir();

	function new(){
		super(_Bld.MENHIR);
		size = 2;
		life = 200;
		type = BT_CONS;
		isUniquePerIsle = true;
		cost.material = 120;
		cost.ether = 30;
		btime = 200;
	}
}

class Hut extends Race1Building {
	public static var instance : BuildingLogic = new Hut();

	function new(){
		super(_Bld.HUT);
		life = 75;
		type = BT_DEF;
		maxUnits = 1;
		isleModifications.defense = 1;
		cost.material = 30;
		btime = 50;
	}
}

class Sculptor extends Race1Building {
	// Golem contruction time is reduced by 50%
	public static var GOLEM_CONTRUCTION_BONUS = 0.5;
	// Non organic Unit construction time is reduced by 10%
	public static var UNIT_CONSTRUCTION_BONUS = 0.9;
	public static var instance : BuildingLogic = new Sculptor();

	function new(){
		super(_Bld.SCULPTOR);
		life = 100;
		type = BT_CONS;
		cost.material = 100;
		cost.ether = 0;
		btime = 100;
	}
}

class Gardener extends Race1Building {
	public static var instance : BuildingLogic = new Gardener();

	function new(){
		super(_Bld.GARDENER);
		life = 50;
		type = BT_FOOD;
		isUniquePerIsle = true;
		isleModifications.food = 2;
		cost.material = 30;
		cost.ether = 30;
		btime = 100;
	}
}

class HotSpring extends Race1Building {
	public static var instance : BuildingLogic = new HotSpring();

	function new(){
		super(_Bld.HOT_SPRING);
		life = 30;
		type = BT_TEC;
		searchBonus = 0.15;
		cost.material = 0;
		cost.ether = 30;
		btime = 50;
	}
}

class Dojo extends Race1Building {
	public static var instance : BuildingLogic = new Dojo();

	function new(){
		super(_Bld.DOJO);
		size = 2;
		life = 150;
		type = BT_DEF;
		isleModifications.attack = 3;
		maxUnits = 5;
		cost.material = 100;
		btime = 100;
	}

	#if neko
	override public function built( isle:db.Isle, now:Float ){
		super.built(isle, now);
		if (isle.getPlayer().hasTechno(MARTIAL_ART))
			isle.attack += GamePlay.MARTIAL_ART_ATTACK_BONUS;
	}

	override public function destroyed( isle:db.Isle, now:Float ){
		super.destroyed(isle, now);
		if (isle.getPlayer().hasTechno(MARTIAL_ART))
			isle.attack -= GamePlay.MARTIAL_ART_ATTACK_BONUS;
	}
	#end
}

class Golem extends Race1Building {
	public static var instance : BuildingLogic = new Golem();

	function new(){
		super(_Bld.GOLEM);
		life = 100;
		type = BT_DEF;
		power = 10;
		cost.material = 40;
		cost.ether = 20;
		armor = 3;
		btime = 400;
	}
}

class Forest extends Race1Building {
	public static var instance : BuildingLogic = new Forest();

	function new(){
		super(_Bld.FOREST);
		size = 2;
		life = 50;
		type = BT_RES;
		tickResources.material = 1;
		cost.material = 10;
		btime = 200;
		buildingRequired = [ GARDENER ];
	}

	#if neko
	override public function getExtraTickResources( isle:db.Isle ) : { material:Int, ether:Int, cloth:Int  } {
		if (isle.getPlayer().hasTechno(DRYAD))
			return { material:0, ether:1, cloth:0 };
		return super.getExtraTickResources(isle);
	}
	#end
}

class Mine extends Race1Building {
	public static var instance : BuildingLogic = new Mine();

	function new(){
		super(_Bld.MINE);
		size = 2;
		life = 200;
		type = BT_RES;
		cost.material = 80;
		btime = 200;
		isUniquePerIsle = true;
		buildingRequired = [ GOLEM ];
	}

	#if neko
	override public function getExtraTickResources( isle:db.Isle ) : { material:Int, ether:Int, cloth:Int  } {
		// Each golem produce 1 material
		return { material:isle.countBuildings(GOLEM), ether:0, cloth:0 };
	}
   	#end
}

class Cauldron extends Race1Building {
	public static var GOLEM_POWER_BONUS = 15;
	public static var instance : BuildingLogic = new Cauldron();

	function new(){
		super(_Bld.CAULDRON);
		life = 100;
		type = BT_DEF;
		cost.material = 50;
		cost.ether = 150;
		btime = 75;
		buildingRequired = [ GOLEM ];
		// FightResolver.hx: les golems gagnent +X dégâts
	}
}

class StoneForge extends Race1Building {
	public static var instance : BuildingLogic = new StoneForge();

	function new(){
		super(_Bld.STONE_FORGE);
		life = 200;
		type = BT_SPECIAL;
		cost.material = 150;
		cost.ether = 150;
		btime = 75;
	}

	#if neko
	override public function computeTick( isle:db.Isle, now:Float ) : Bool {
		// Repairs 3PV on a non organic unit
		var units = isle.getUnits();
		for (u in units){
			var logic = ShipLogic.get(u.getKind());
			if (logic.isInvocation())
				continue;
			logic = logic.applyUserTechnos(isle.getPlayer().getTechnos());
			var max = logic.life;
			if (u.life < max){
				u.life = Std.int(Math.min(max, u.life + 3));
				tools.UpdateList.add(u);
				break;
			}
		}
		var modified = false;
		// Repairs 5PV on a damaged building
		var buildings = isle.getBuildings();
		for (b in buildings){
			if (b.life < b.logic.life){
				b.life = Std.int(Math.min(b.logic.life, b.life + 5));
				isle.buildingsModified = true;
				modified = true;
				break;
			}
		}
		return modified;
	}
	#end
}

class Shrine extends Race1Building {
	// Reduce of 15% the invocation time of living units
	public static var INVOCATION_TIME_BONUS = 0.85;
	public static var instance : BuildingLogic = new Shrine();

	function new(){
		super(_Bld.SHRINE);
		life = 50;
		type = BT_SPECIAL;
		cost.material = 50;
		cost.ether = 50;
		btime = 50;
		buildingRequired = [ MENHIR ];
	}
}

class Flowers extends Race1Building {
	public static var instance : BuildingLogic = new Flowers();

	function new(){
		super(_Bld.FLOWERS);
		life = 10;
		type = BT_DEF;
		cost.material = 5;
		cost.ether = 20;
		btime = 30;
		buildingRequired = [ GARDENER ];
	}
}

class PurificationTank extends Race1Building {
	public static var instance : BuildingLogic = new PurificationTank();

	function new(){
		super(_Bld.PURIFICATION_TANK);
		life = 100;
		type = BT_RES;
		isUniquePerIsle = true;
		cost.material = 75;
		cost.ether = 50;
		btime = 100;
		buildingRequired = [ MENHIR ];
	}

	#if neko
	override public function getExtraTickResources( isle:db.Isle ) : { material:Int, ether:Int, cloth:Int } {
		return { ether:isle.countBuildings(FOUNTAIN) + isle.countBuildings(SOURCE), material:0, cloth:0 };
	}
	#end
}

class Orb extends Race1Building {
	public static var instance : BuildingLogic = new Orb();

	function new(){
		super(_Bld.ORB);
		size = 2;
		life = 200;
		type = BT_CONS;
		isUniquePerIsle = true;
		cost.material = 150;
		cost.ether = 400;
		btime = 240;	// was 300
		buildingRequired = [ MENHIR ];
	}
}

class Sprayer extends Race1Building {
	public static var instance : BuildingLogic = new Sprayer();

	function new(){
		super(_Bld.SPRAYER);
		life = 75;
		type = BT_SPECIAL;
		cost.material = 50;
		cost.ether = 100;
		btime = 75;
		buildingRequired = [ ORB ];
	}
}

class Source extends Race1Building {
	public static var instance : BuildingLogic = new Source();

	function new(){
		super(_Bld.SOURCE);
		life = 100;
		type = BT_RES;
		isUniquePerIsle = true;
		tickResources.ether = 4;
		cost.material = 150;
		cost.ether = 50;
		btime = 200;
		buildingRequired = [ MENHIR, DOJO ];
	}

	#if neko
	override public function getExtraTickResources( isle:db.Isle ) : { material:Int, ether:Int, cloth:Int } {
		if (isle.getPlayer().hasTechno(ETHERUPTION))
			return { material:0, ether:4, cloth:0 };
		return super.getExtraTickResources(isle);
	}
	#end
}

class MagicTree extends Race1Building {
	public static var instance : BuildingLogic = new MagicTree();

	function new(){
		super(_Bld.MAGIC_TREE);
		life = 30;
		type = BT_SPECIAL;
		cost.material = 50;
		cost.ether = 100;
		btime = 100;
		buildingRequired = [ GARDENER ];
	}

	#if neko
	override public function computeTick( isle:db.Isle, now:Float ) : Bool {
		// Repairs 1PV on a organic unit
		var units = isle.getUnits();
		for (u in units){
			var logic = ShipLogic.get(u.getKind());
			if (!logic.isInvocation())
				continue;
			logic = logic.applyUserTechnos(isle.getPlayer().getTechnos());
			var max = logic.life;
			if (u.life < max){
				u.life = Std.int(Math.min(max, u.life + 1));
				tools.UpdateList.add(u);
				break;
			}
		}
		return false;
	}
	#end
}

class GolemLauncher extends Race1Building {
	public static var instance : BuildingLogic = new GolemLauncher();

	function new(){
		super(_Bld.GOLEM_LAUNCHER);
		life = 100;
		/*		size = 2; */
		type = BT_SPECIAL;
		size = 2;
		cost.material = 200;
		cost.ether = 200;
		btime = 200;
		isUniquePerIsle = true;
		buildingRequired = [ STONE_FORGE ];
	}
}
