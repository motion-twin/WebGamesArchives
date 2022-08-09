package fight;
import Datas;
import Race1;
import ShipLogic;
import fight.Target;
import GEvent;

class Resolver {
	// fight status booleans
	public var colonized : Bool;
	public var victory : Bool;
	public var fleetDestroyed : Bool;
	var townhallDestroyed : Bool;
	var townhallX : Int;
	var townhallY : Int;
	var cauldrons : Int;
	// log and debug vars
	var logger : Logger;
	// game vars
	public var now : Float;
	public var game : db.Game;
	public var isle : db.Isle;
	public var attacker : db.GameUser;
    public var defender : db.GameUser;
	// fight units and buildings
	public var attackers : Array<fight.FullUnit>;
	public var defenders : Array<fight.FullUnit>;
	public var buildings : Array<Building>;
	var towers : Array<Building>;
	// the building randomizer
	var buildingRandom : BuildingRandom;
	// fight variables
	var popDamages : Int;
	var popTempDamages : Int;
	var popLost : Int;
	var attackerPackTarget : fight.Target;
	var defenderPackTarget : fight.Target;
	// travel parameters
	var autocol : Bool;

	public function new( g:db.Game, now:Float, isle:db.Isle, attacker:db.GameUser, attackerUnits:List<db.Unit>, priorities:List<_BldType>, autocol:Bool ){
		this.logger = new Logger(this);
		this.game = g;
		this.townhallDestroyed = this.victory = this.colonized = this.fleetDestroyed = false;
		this.now = now;
		this.isle = isle;
		this.autocol = autocol;
		this.popDamages = 0;
		this.popTempDamages = 0;
		this.popLost = 0;
		this.attacker = attacker;
		this.defender = isle.getPlayer();
		initAttack(attackerUnits);
		initDefense();
		initBuildings( priorities );
		this.logger.init();
		// special effects before fight
		if (defender != attacker){
			giantTurtleGivesPack();
			scoutDisableInit();
			sprayersCancelsStealth();
			sprayersAlterPriorities();
		}
	}

	// -----------------------------------------------------------------

	function giantTurtleGivesPack(){
		if (Lambda.exists(attackers, function(u) return u.logic.kind == GIANT_TURTLE))
			for (u in attackers)
				u.hasPack = true;
		if (Lambda.exists(defenders, function(u) return u.logic.kind == GIANT_TURTLE))
			for (u in defenders)
				u.hasPack = true;
	}

	function scoutDisableInit(){
		if (Lambda.exists(attackers, function(u) return u.unit.life > 0 && u.hasScout))
			for (u in defenders)
				u.hasInit = false;
		if (Lambda.exists(defenders, function(u) return u.unit.life > 0 && u.hasScout))
			for (u in attackers)
				u.hasInit = false;
	}

	function flowersGivesParasite(){
		// VARNISH prevents parasite
		if (attacker.hasTechno(VARNISH))
			return;
		var flowers = Lambda.filter(
			buildings,
			function(b) return b.life > 0 && b.progress >= 1.0 && b.kind == _Bld.FLOWERS
		);
		if (flowers.length > 0){
			var targets = Lambda.array(attackers);
			while (flowers.length > 0 && targets.length > 0){
				var i = Std.random(targets.length);
				var target = targets[i];
				targets.splice(i,1);
				if (!target.unit.hasStatus(Parasite) && target.unit.life > 0){
					logger.newFlowerGivesParasite(flowers.pop(), target);
					target.unit.addStatus(Parasite);
				}
			}
		}
	}

	function stakesInflictDamages(){
		if (isle.ownerId == null || defender == null || !defender.hasTechno(STAKES))
			return;
		for (ship in attackers.copy()){
			if (ship.unit.life > 0){
				var damages = Std.int(Math.max(0, GamePlay.STAKES_DAMAGES - ship.logic.armor));
				var realDamages = Std.int(Math.min(ship.unit.life, damages));
				logger.newStackesDamages(ship, damages, realDamages);
				ship.unit.life -= realDamages;
				if (ship.unit.life <= 0)
					unitDestroyed(ship);
			}
		}
	}

	function sprayersAlterPriorities(){
		if (Lambda.exists(buildings, function(b) return b.life > 0 && b.progress >= 1.0 && b.kind == _Bld.SPRAYER))
			buildingRandom.alterPriorities();
	}

	function sprayersCancelsStealth(){
		if (Lambda.exists(buildings, function(b) return b.life > 0 && b.progress >= 1.0 && b.kind == _Bld.SPRAYER))
			for (a in attackers)
				a.hasStealth = false;
	}

	// -----------------------------------------------------------------

	function initAttack( units:List<db.Unit> ){
		var technos = attacker.getTechnos();
		this.attackers = Lambda.array(Lambda.map(units, function(unit) return new fight.FullUnit(unit, true, technos)));
		if (Lambda.has(technos, GOLEMISSARY) && attackers.length == 1 && (attackers[0].logic.kind == HOPLITE || attackers[0].logic.kind == GOLIATH)){
			attackers[0].damageFactor = 2.0;
		}
	}

	function initDefense(){
		var technos = if (isle.ownerId == null) new List() else defender.getTechnos();
		this.defenders = [];
		for (u in isle.getUnits()){
			if (u.ownerId == attacker.userId){
				attackers.push(new fight.FullUnit(u, true, attacker.getTechnos()));
			}
			else {
				if (defender == null){
					defender = u.getPlayer();
					technos = defender.getTechnos();
				}
				defenders.push(new fight.FullUnit(u, technos)); 
			}
		}
	}

	function initBuildings( priorities:List<_BldType> ){
		// init real buildings
		this.buildings = Lambda.array(isle.getBuildings());
		// cauldrons count
		this.cauldrons = 0;			
		// available towers
		this.towers = new Array();
		for (b in buildings){
			if (b.life > 0 && BuildingLogic.get(b.kind).power > 0)
				this.towers.push(b);
			if (b.life > 0 && b.kind == CAULDRON)
				this.cauldrons++;
		}
		
		// init yard
		var first = true;
		for (p in isle.getYard().getProductions()){
			switch (p.kind){
				case Ship(k):
					// Ships cannot be targetted 
				case Building(k,x,y):
					if (first)
						p.progress = isle.getYard().getCurrentProgress(now);
					if (p.progress > 0)
						this.buildings.push(new Building(k, x, y, p.damages, p.progress));
			}
			first = false;
		}
		// init building random table
		var percents = attacker.getPriorityPercents();
		for (u in attackers)
			if (u.unit.life > 0 && u.fleetTarget > 0 && !Lambda.has(percents, u.fleetTarget))
				percents.push(u.fleetTarget);
		percents.sort(function (a,b) return -1 * Reflect.compare(a,b));
		
		this.buildingRandom = new BuildingRandom(buildings, priorities, percents, isle.population);
		// buildings ids
		var id = 1;
		for (b in buildings)
			Reflect.setField(b, "id", id++);
	}

	// ----------------------------------------------------------------

	function setPackTarget( u:fight.FullUnit, t:Target ) : Target {
		if (!u.hasPack)
			return t;
		if (u.isAttacker)
			attackerPackTarget = t;
		else
			defenderPackTarget = t;
		return t;
	}

	function getPackTarget( u:fight.FullUnit ) : Target {
		if (!u.hasPack)
			return null;

		var me = this;
		var checkDeath = function( packTarget ){
			if (packTarget == null)
				return null;
			switch (packTarget){
				case TShip(ship):
					if (ship.unit.life <= 0)
						return null;
				case TBuilding(bld):
					if (bld.life <= 0)
						return null;
				case TPop:
					if (me.isle.population <= 0)
						return null;
			}
			return packTarget;
		}
		attackerPackTarget = checkDeath(attackerPackTarget);
		defenderPackTarget = checkDeath(defenderPackTarget);
		return if (u.isAttacker) attackerPackTarget else defenderPackTarget;
	}

	function findTarget( u:fight.FullUnit ) : Target {
		var result = getPackTarget(u);
		if (result != null)	{
			var l = new db.Log();
			l.add("using pack target");
			l.insert();
			return result;
		}
		var aerialChoices = if (u.isAttacker) defenders else attackers;
		if (aerialChoices.length > 0)
			return setPackTarget(u, Target.TShip(aerialChoices[Std.random(aerialChoices.length)]));
		if (!u.isAttacker)
			return null;
		return findBuildingTarget(u);
	}

	function findBuildingTarget( u:fight.FullUnit ) : Target {
		if (!u.isAttacker)
			return null;
		if (buildings.length > 0 || isle.population > 0)
			return buildingRandom.random();
		return null;
	}
	
	/*
	  Select a target for a tower attack.
	*/
	function findTowerTarget() : fight.FullUnit {
		if (attackers.length == 0)
			return null;
		var choices = Lambda.array(Lambda.list(attackers).filter(function(u) return !u.hasStealth));
		return choices[Std.random(choices.length)];
	}

	// ----------------------------------------------------------------

	inline public function hasDefenders() : Bool {
		return defenders.length > 0 && !townhallDestroyed;
	}

	static function sortUnits( u:Array<fight.FullUnit> ) : Array<fight.FullUnit> {
		u.sort(function(a,b){
			var cmpx = -1 * Reflect.compare(a.unit.kind, b.unit.kind);
			if (cmpx == 0)
				return -1 * Reflect.compare(a.unit.ownerId, b.unit.ownerId);
			return cmpx;
		});
		return u;
	}

	// ----------------------------------------------------------------

	/*
	  Resolves fight.
	*/
	public function resolve(){
		logger.startFight();

		var allInits = new Array();
		var allUnits = new Array();
		for (u in attackers) if (u.hasInit) allInits.push(u) else allUnits.push(u);
		for (u in defenders) if (u.hasInit) allInits.push(u) else allUnits.push(u);
		allInits = sortUnits(allInits);
		allUnits = sortUnits(allUnits);
		
		logger.unitsWithInitiativeAttack();
		unitsAttack(allInits);
		clearDeaths(allInits, allUnits);

		logger.unitsWithoutInitiativeAttack();
		unitsAttack(allUnits);

		logger.beginOfTowersAttackPhase();
		if (isle.ownerId != null){
			for (t in towers)
				towerAttack(t, findTowerTarget());
			if (defender.hasTechno(MISSILE_STRAWMAN))
				fieldsAttack();
			for (i in 0...isle.population)
				planetAttack(findTowerTarget());
		}
		clearDeaths(allInits, allUnits);

		// special effects after fight
		stakesInflictDamages();
		flowersGivesParasite();
		for (u in attackers){
			if (u.unit.life > 0 && u.bomb > 0){
				var repartition = unitAttack(u, findBuildingTarget(u), true);
				while (u.hasRepartition && repartition > 0)
					repartition = unitAttack(u, findBuildingTarget(u), true, repartition);
			}
		}
		clearDeaths(allInits, allUnits);

		if (townhallDestroyed && isle.ownerId != null){
			game.addEvent(now, GEventKind.Frag(attacker.userId, isle.ownerId));
			logger.townhallDestroyedDuringAttack();
			isle.raz();
			attacker.frags++;
		}
		if (isle.ownerId != null && isle.isNeutralized()){
			game.addEvent(now, GEventKind.IsleRaz(attacker.userId, isle.ownerId));
			isle.raz();
		}
		if (townhallDestroyed && attacker.hasTechno(INVASION)){
			doInvasion();
		}
		victory = (isle.ownerId == null && !hasDefenders());
		doColonization();
		updateDbObjects();
		logger.finalize(victory, popDamages);
		fleetDestroyed = (attackers.length == 0);
		if (colonized)
			isle.addNews({_date:now, _type:_Colonize(isle.ownerId)});
	}

	function unitsAttack( list:Array<fight.FullUnit> ){
		var currentPlayer = null;
		var currentKind = null;
		for (u in list){
			if (currentPlayer == null){
				currentPlayer = u.unit.ownerId;
				currentKind = u.unit.kind;
			}
			if (currentPlayer != u.unit.ownerId || currentKind != u.unit.kind){
				logger.newSalve();
				currentPlayer = u.unit.ownerId;
				currentKind = u.unit.kind;
			}
			if (u.logic.power + u.raid > 0)
				for (x in 0...u.multi){
					var repartition = unitAttack(u, findTarget(u));
					while (u.hasRepartition && repartition > 0)
						repartition = unitAttack(u, findTarget(u), repartition);
				}
		}
		logger.newSalve();
	}

	function planetAttack( target:fight.FullUnit ){
		if (target == null)
			return;
		if (isle.population == 0)
			return;
		var damages = Std.int(Math.max(0, isle.attack - target.logic.armor));
		var realDamages = Std.int(Math.min(target.unit.life, damages));
		logger.newPopulationVsShipAssault(target, damages, realDamages);
		target.unit.life -= realDamages;
		if (target.unit.life <= 0)
			unitDestroyed(target);
	}

	function fieldsAttack(){
		for (f in Lambda.filter(buildings, function(b) return b.life > 0 && b.kind == _Bld.FIELD && !b.isYard())){
			for (i in 0...2){
				var target = findTowerTarget();
				if (target == null)
					return;
				var damages = Std.int(Math.max(0, 10 - target.logic.armor));
				var realDamages = Std.int(Math.min(target.unit.life, damages));
				logger.newTowerVsShipAssault(f, target, damages, realDamages);
				target.unit.life -= realDamages;
				if (target.unit.life <= 0)
					unitDestroyed(target);
			}
		}
	}
	
	function towerAttack( tower:Building, target:fight.FullUnit ){
		if (target == null)
			return;
		var bonus = 0;
		if (tower.kind == DOJO && defender.hasTechno(MARTIAL_ART)) 
			bonus = GamePlay.MARTIAL_ART_BONUS;
		else if (tower.kind == GOLEM && defender.hasTechno(ETHERAL_FIST))
			bonus = GamePlay.ETHERAL_FIST_BONUS;
		if (tower.kind == GOLEM)
			bonus += cauldrons * Cauldron.GOLEM_POWER_BONUS;
		var damages = Std.int(Math.max(0, bonus + BuildingLogic.get(tower.kind).power - target.logic.armor));
		var realDamages = Std.int(Math.min(target.unit.life, damages));
		logger.newTowerVsShipAssault(tower, target, damages, realDamages);
		target.unit.life -= realDamages;
		if (target.unit.life <= 0)
			unitDestroyed(target);
	}

	public static function getBuildingArmor( b:BuildingLogic, p:db.GameUser ) : Int {
		var armor = b.armor;
		if (b.kind == GOLEM && p.hasTechno(GRANIT_SKIN))
			armor += GamePlay.GRANIT_SKIN_BONUS;
		if (p.hasTechno(ETHERAL_GATE))
			armor += GamePlay.ETHERAL_GATE_BONUS;
		return armor;
	}
	
	function unitAttack( unit:fight.FullUnit, target:Target, bombing=false, ?damages:Int=null ) : Int {
		if (target == null){
			logger.unitDidNotFoundAnyTarget(unit);
			return 0;
		}
		switch (target){
			case TShip(ship):
				if (ship == null)
					return 0;
				
				var damages = if (damages != null) damages else (unit.logic.power + unit.raid);
				var damages = Std.int(Math.round(Math.max(0, damages - ship.logic.armor) * unit.damageFactor));
				var realDamages = Std.int(Math.min(ship.unit.life, damages));
				ship.unit.life -= realDamages;
				logger.newShipVsShipAssault(unit, ship, damages, realDamages);
				if (ship.unit.life <= 0){
					unitDestroyed(ship);
				}
				else if (unit.hasCorosive){
					// TODO: add Poison to log
					ship.unit.addStatus(Poison);
				}
				return Std.int(Math.max(0, damages - realDamages));

			case TBuilding(building):
				if (building == null)
					return 0;
                if (building.life <= 0)
                    return 0;
				
				var damages = if (damages != null) damages else if (bombing) unit.bomb else unit.logic.power;

				var armor = getBuildingArmor(BuildingLogic.get(building.kind), defender);
				damages = Math.round((damages - armor) * unit.damageFactor);

				var realDamages = Std.int(Math.min(building.life, damages));
				logger.newShipVsBuildingAssault(unit, building, damages, realDamages);
				if (realDamages > 0){
					building.life -= realDamages;
					if (building.isYard()){
						if (building.life <= 0)
							buildingDestroyed(target, building, now);
						else
							isle.getYard().addProductionDamages(building.x, building.y, damages);
					}
					else {
						isle.buildingsModified = true;
						if (building.life <= 0)
							buildingDestroyed(target, building, now);
					}
				}
				return Std.int(Math.max(0, damages - realDamages));				

			case TPop:
				var damages = if (damages != null) damages else if (bombing) unit.bomb else unit.logic.power;
				damages = Math.round(damages * unit.damageFactor);
				logger.newShipVsPopulationAssault(unit, damages);
				popTempDamages += damages ;
				popDamages += damages;
				var popKilled = Math.floor(popTempDamages / (10 * isle.defense));
				if (popKilled > 0){
					popLost += popKilled;
					popTempDamages -= popKilled * 10 * isle.defense;
					if (popLost >= isle.population){
						// TODO: compute extra damages for repartition
						buildingRandom.destroyed(Target.TPop);
						logger.populationDestroyed();
					}
				}
				return 0;
		}
	}

	function updateDbObjects(){
		for (u in attackers) tools.UpdateList.add(u.unit);
		for (u in defenders) tools.UpdateList.add(u.unit);
		tools.UpdateList.add(isle);
	}

	function doInvasion(){
		logger.invading();
		isle.changeOwner(attacker, now, true);
		isle.setPopulation(1, now);
		isle.addBuilding(new Building(FORT, townhallX, townhallY, 0), now);
		colonized = true;
	}
	
	function doColonization(){
		if (!autocol)
			return;
		if (isle.ownerId != null || hasDefenders())
			return;
		var colonizer = tools.Utils.find(attackers, function(u) return u.unit.life > 0 && u.hasColonization);
		if (colonizer != null){
			logger.colonizing();
			isle.changeOwner(attacker, now, true);
			isle.setPopulation(isle.population + colonizer.logic.cost.population, now);
			colonizer.unit.delete();
			attackers.remove(colonizer);
			colonized = true;
		}
	}

	function clearDeaths( allInits:Array<fight.FullUnit>, allUnits:Array<fight.FullUnit> ){
		logger.clearDeaths();
		for (u in allInits.copy()) if (u.unit.life <= 0) allInits.remove(u);
		for (u in allUnits.copy()) if (u.unit.life <= 0) allUnits.remove(u);
		for (t in towers.copy()) if (t.life <= 0) towers.remove(t);
		if (popLost > 0){
			var realLost = Std.int(Math.min(isle.population, popLost));
			logger.populationLost(realLost);
			isle.setPopulation(isle.population - realLost, now);
			if (isle.population <= 0){
				buildingRandom.destroyed(Target.TPop);
				logger.populationDestroyed();
			}
			popLost = 0;
		}
	}

	// DESTRUCTION METHODS

	function unitDestroyed( u:fight.FullUnit ){
		logger.unitDestroyed(u);
		u.unit.delete();
		if (u.isAttacker){
			attackers.remove(u);
		}
		else {
			defenders.remove(u);
		}
		var owner = u.unit.getPlayer();
		if (owner.hasTechno(GRAVEYARD)){
			owner.ether += Math.round(u.logic.cost.ether * GamePlay.GRAVEYARD_ETHER_RATE);
			tools.UpdateList.add(owner);
		}
	}

	function buildingDestroyed( t:Target, b:Building, now:Float ){
		logger.buildingDestroyed(b);
		if (b.kind == _Bld.TOWNHALL || b.kind == _Bld.TEMPLE){
			townhallDestroyed = true;
			townhallX = b.x;
			townhallY = b.y;
		}
		if (b.isYard())
			isle.getYard().delProductionAt(b.x, b.y, now, false);
		else
			isle.delBuilding(b,now);
		buildings.remove(b);
		isle.addRuin(b);
		buildingRandom.destroyed(t);
		if (attacker.hasTechno(PILLAGE)){
			var logic = BuildingLogic.get(b.kind);
			var bonus = {
				material: Math.round(logic.cost.material * GamePlay.PILLAGE_RATE),
				ether: Math.round(logic.cost.ether * GamePlay.PILLAGE_RATE),
				cloth: Math.round(logic.cost.cloth * GamePlay.PILLAGE_RATE),
				population: 0,
			};
			attacker.addResources(bonus);
			tools.UpdateList.add(attacker);
		}
	}
}
