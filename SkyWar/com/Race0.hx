import Datas;

#if neko
import GEvent;
#end

class Race0Building extends BuildingLogic {
	public function new( k:_Bld ){
		super(0, k);
	}

	public override function getIsleBuildTime( b:List<_Bld>, t:List<_Tec> ) : Float {
		var bonus = 1.0;
		if (kind == QUARRY && Lambda.has(t, VRILLE))
			bonus *= 0.5;
		if (Lambda.has(b, ARCHITECT))
			bonus *= 0.7;
		if (Lambda.has(t, MARTIAL_LAW))
			bonus *= 1.25;
		return getBuildTime() * bonus;
	}
}

class Townhall extends Race0Building {
	public static var instance : BuildingLogic = new Townhall();

	function new(){
		super(_Bld.TOWNHALL);
		type = BT_MAIN;
		isUnique = true;
		life = 300;
		btime = life;
		cost.material = 250;
		maxUnits = 20;
		isleModifications.food = 5;
		tickResources.material = 7;
		size = 2;
	}
}

class Quarry extends Race0Building {
	public static var instance = new Quarry();

	function new(){
		super(_Bld.QUARRY);
		type = BT_RES;
		life = 200;
		btime = 300;
		cost.material = 100;
		tickResources.material = 4;
		isUniquePerIsle = true;
		size = 2;
	}

    #if neko
	override public function getExtraTickResources( isle:db.Isle ) : { material:Int, ether:Int, cloth:Int } {
		if (isle.getPlayer().hasTechno(_Tec.GEOLOGY)){
			return { material:1, ether:0, cloth:0 };
		}
		return super.getExtraTickResources(isle);
	}
    #end
}

class Field extends Race0Building {
	public static var instance = new Field();

	function new(){
		super(_Bld.FIELD);
		type = BT_FOOD;
		life = 50;
		btime = 40;
		cost.material = 15;
		isleModifications.food = 2;
		size = 2;
	}

	#if neko
	override public function built( isle:db.Isle, now:Float ){
		super.built(isle, now);
		if (isle.hasBuilding(_Bld.WINDMILL))
			isle.addFood(WindMill.BONUS);
		if (isle.getPlayer().hasTechno(FERTILIZER))
			isle.addFood(GamePlay.TEC_FERTILIZER_BONUS);
		if (isle.getPlayer().hasTechno(TRACTOR))
			isle.addFood(GamePlay.TEC_TRACTOR_BONUS);
	}
	override public function destroyed( isle:db.Isle, now:Float ){
		super.destroyed(isle, now);
		if (isle.hasBuilding(_Bld.WINDMILL))
			isle.addFood(-WindMill.BONUS);
		if (isle.getPlayer().hasTechno(FERTILIZER))
			isle.addFood(-GamePlay.TEC_FERTILIZER_BONUS);
		if (isle.getPlayer().hasTechno(TRACTOR))
			isle.addFood(-GamePlay.TEC_TRACTOR_BONUS);
	}
	#end
}

class Weaver extends Race0Building {
	public static var instance = new Weaver();

	function new(){
		super(_Bld.WEAVER);
		type = BT_CONS;
		life = 100;
		btime = 150;
		cost.material = 120;
	}
}

class Workshop extends Race0Building {
	public static var instance = new Workshop();

	function new(){
		super(_Bld.WORKSHOP);
		type = BT_CONS;
		life = 100;
		btime = 150;
		cost.material = 150;
	}

	#if neko
	override public function computeTick( isle:db.Isle, now:Float ) : Bool{
		if (!isle.getPlayer().hasTechno(RESTORE))
			return false;
		// gives 5 life to a damaged ship per turn ( need tech restore )
		var units = isle.getUnits();
		for (u in units){
			var max = ShipLogic.get(u.getKind()).applyUserTechnos(isle.getPlayer().getTechnos()).life;
			if (u.life < max){
				u.life = Std.int(Math.min(max, u.life + 5));
				tools.UpdateList.add(u);
				return false;
			}
		}
		return false;
	}
	#end
}

class Pump extends Race0Building {
	public static var instance = new Pump();

	function new(){
		super(_Bld.PUMP);
		type = BT_RES;
		life = 50;
		btime = 100;
		cost.material = 60;
		tickResources.ether = 1;
	}

	#if neko
	override public function getExtraTickResources( isle:db.Isle ) : { material:Int, ether:Int, cloth:Int } {
		if (isle.getPlayer().hasTechno(_Tec.ETHERODUC))
			return { material:0, ether:1, cloth:0 };
		return super.getExtraTickResources(isle);
	}
	#end

}

class Barrack extends Race0Building {
	public static var instance = new Barrack();

	function new(){
		super(_Bld.BARRACKS);
		type = BT_DEF;
		life = 100;
		btime = 50;
		armor = 0;
		maxUnits = 2;
		cost.material = 75;
		isleModifications.attack = 1;
	}
}

class WatchTower extends Race0Building {
	public static var instance = new WatchTower();

	function new(){
		super(_Bld.WATCH_TOWER);
		isUniquePerIsle = true;
		type = BT_SPECIAL;
		life = 50;
		btime = 50;
		cost.material = 75;
	}
}

class School extends Race0Building {
	public static var instance = new School();

	function new(){
		super(_Bld.SCHOOL);
		life = 100;
		btime = 100;
		isUniquePerIsle = true;
		type = BT_TEC;
		cost.material = 100;
		uniqueSearchBonus = 0.25;
	}
}

class University extends Race0Building {
	public static var instance = new University();

	function new(){
		super(_Bld.UNIVERSITY);
		isUniquePerIsle = true;
		type = BT_TEC;
		life = 200;
		btime = 200;
		cost.material = 200;
		cost.ether = 80;
		buildingRequired.push(_Bld.WORKSHOP);
		buildingRequired.push(_Bld.SCHOOL);
		uniqueSearchBonus = 0.40;
		size = 2;
	}
}

class Laboratory extends Race0Building {
	public static var instance = new Laboratory();

	function new(){
		super(_Bld.LABORATORY);
		type = BT_TEC;
		life = 50;
		btime = 100;
		cost.material = 100;
		cost.ether = 30;
		buildingRequired.push(_Bld.WORKSHOP);
		buildingRequired.push(_Bld.UNIVERSITY);
		searchBonus = 0.10;
	}
}

class Farm extends Race0Building {
	public static var instance = new Farm();

	function new(){
		super(_Bld.FARM);
		type = BT_FOOD;
		life = 50;
		btime = 100;
		cost.material = 150;
		buildingRequired.push(_Bld.WORKSHOP);
		buildingRequired.push(_Bld.FIELD);
		isleModifications.food = 3;
	}
}

class WindMill extends Race0Building {
	public static var BONUS = 2;
	public static var instance = new WindMill();

	function new(){
		super(_Bld.WINDMILL);
		isUniquePerIsle = true;
		type = BT_FOOD;
		life = 100;
		btime = 100;
		cost.material = 100;
		buildingRequired.push(_Bld.WEAVER);
	}

	#if neko
	override public function built( isle:db.Isle, now:Float ){
		super.built(isle, now);
		if (!isle.hasBuilding(_Bld.WINDMILL))
			isle.addFood(isle.countBuildings(_Bld.FIELD) * BONUS);
	}
	override public function destroyed( isle:db.Isle, now:Float ){
		super.destroyed(isle, now);
		if (!isle.hasBuilding(_Bld.WINDMILL))
			isle.addFood(-isle.countBuildings(_Bld.FIELD) * BONUS);
	}
	#end
}

class Canon extends Race0Building {
	public static var instance = new Canon();

	function new(){
		super(_Bld.CANON);
		type = BT_DEF;
		life = 100;
		btime = 50;
		power = 20;
		cost.material = 60;
		technosRequired.push( CANON_POWDER );
	}
}

class FireStation extends Race0Building {
	public static var instance = new FireStation();

	function new(){
		super(_Bld.FIRE_STATION);
		type = BT_SPECIAL;
		life = 100;
		btime = 100;
		cost.material = 75;
		cost.ether = 15;
		buildingRequired.push(_Bld.WORKSHOP);
	}

	#if neko
	override public function computeTick( isle:db.Isle, now:Float ) : Bool {
		var buildings = isle.getBuildings();
		var modified = false;
		for (b in buildings){
			var max = BuildingLogic.get(b.kind).life;
			if (b.life < max){
				b.life = Std.int(Math.min(max, b.life + 1));
				isle.buildingsModified = true;
				modified = true;
			}
		}
		return modified;
	}
	#end
}

class Factory extends Race0Building {
	public static var instance = new Factory();

	public static var SHIP_PRODUCTION_FACTOR = 0.9;

	function new(){
		super(_Bld.FACTORY);
		type = BT_CONS;
		life = 200;
		btime = 300;
		cost.material = 450;
		cost.ether = 200;
		buildingRequired.push(_Bld.WORKSHOP);
		size = 2;
	}
}

class Yeller extends Race0Building {
	public static var instance = new Yeller();

	function new(){
		super(_Bld.YELLER);
		type = BT_DEF;
		life = 100;
		btime = 100;
		cost.material = 120;
		cost.ether = 40;
		power = 35;
		buildingRequired.push(_Bld.FACTORY);
	}
}

class Archimortar extends Race0Building {
	public static var TURN_DAMAGES = 30;
	public static var ATTACK_RANGE = 300;

	public static var instance = new Archimortar();

	function new(){
		super(_Bld.ARCHIMORTAR);
		type = BT_SPECIAL;
		life = 200;
		btime = 500;
		cost.material = 900;
		cost.ether = 400;
		buildingRequired.push(_Bld.FACTORY);
		technosRequired.push(CANON_POWDER);
		size = 2;
	}

	#if neko
	override public function computeTick( isle:db.Isle, now:Float ){
		var isles = App.gamedb.getIsles();
		var nearest = null;
		var nearestDistance = null;
		var clanOk = function(i){
			if (App.gamedb.game.mode != GameMode.ClanDuel)
				return true;
			return isle.getPlayer().clanId != i.getPlayer().clanId;
		}
		for (i in isles){
			if (i.ownerId != null && i.ownerId != isle.ownerId && i.getBuildings().length > 0 && clanOk(i)){
				var dist = i.distanceTo(isle);
				if (dist <= ATTACK_RANGE && (nearest == null || nearestDistance > dist)){
					nearest = i;
					nearestDistance = dist;
				}
			}
		}
		if (nearest != null){
			var nearest = db.Isle.manager.get(nearest.id, true);
			var buildings = nearest.getBuildings();
			var target = Lambda.array(buildings)[Std.random(buildings.length)];
			if (target == null)
				return false;
			var logic = BuildingLogic.get(target.kind);
			var damages = Std.int(Math.max(0, TURN_DAMAGES - fight.Resolver.getBuildingArmor(logic, nearest.getPlayer())));
			var news = {
				_from:isle.ownerId,
				_to:nearest.ownerId,
				_fightId:null,
				_damageYard:0,
				_damageBld:damages,
				_casualtyPop:0,
				_damagePop:0,
				_damageAtt:0,
				_damageTwr:0,
				_casualtyAtt:[],
				_casualtyDef:[],
				_damageDef:0,
				_casualtyBld:[],
			};
			target.life -= damages;
			if (target.life <= 0){
				news._casualtyBld = [target.kind];
				buildings = nearest.delBuilding(target, now);
				nearest.addRuin(target);
				isle.getPlayer().getStats().buildingDestroyed(target.kind);
				if (target.kind == TOWNHALL || target.kind == TEMPLE){
					App.gamedb.game.addEvent(now, GEventKind.Frag(isle.ownerId, nearest.ownerId));
					isle.getPlayer().frags++;
					nearest.raz();
				}
				else if (nearest.isNeutralized()){
					App.gamedb.game.addEvent(now, GEventKind.IsleRaz(isle.ownerId, nearest.ownerId));
					nearest.raz();
				}
			}
			nearest.addNews({ _date:now, _type:_Archimortar(news) });
			nearest.buildingsModified = true;
			tools.UpdateList.add(nearest);
		}
		return false;
	}
	#end
}

class Bunker extends Race0Building {
	public static var instance = new Bunker();

	function new(){
		super(_Bld.BUNKER);
		type = BT_DEF;
		life = 100;
		btime = 100;
		armor = 5;
		isleModifications.defense = 3;
		cost.material = 100;
		buildingRequired.push(_Bld.FOUNDRY);

	}
}

class Architect extends Race0Building {
	public static var instance = new Architect();

	function new(){
		super(_Bld.ARCHITECT);
		type = BT_SPECIAL;
		life = 100;
		btime = 100;
		cost.material = 100;
		isUniquePerIsle = true;
		buildingRequired.push(_Bld.SCHOOL);
	}
}

class Fort extends Race0Building {
	public static var instance = new Fort();

	function new(){
		super(_Bld.FORT);
		type = BT_DEF;
		btime = 100;
		cost.material = 200;
		life = 300;
		armor = 2;
		power = 60;
		isleModifications.defense = 4;
		technosRequired.push( CANON_POWDER );
		size = 2;
	}
}

class Foundry extends Race0Building {
	public static var instance = new Foundry();

	function new(){
		super(_Bld.FOUNDRY);
		type = BT_RES;
		life = 100;
		btime = 100;
		cost.material = 60;
		cost.ether = 60;
		tickResources.material = 2;
		buildingRequired.push(_Bld.WORKSHOP);
		buildingRequired.push(_Bld.QUARRY);
	}
}