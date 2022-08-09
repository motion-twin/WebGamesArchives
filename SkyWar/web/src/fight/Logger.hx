package fight;
import Datas;

class Logger {
	var resolver : Resolver;
	var debug : db.Log;	
	var resume : DataAttack; // isle mini resume
	var history : DataFight; // real fight resume
	var kills : Array<Int>;
	var assaults : Array<DataAssault>;
	var flowers : Array<DataAssault>;
	var stakes : Array<DataAssault>;
	var resumeRequired : Bool;

	public function new( r:Resolver ){
		debug = new db.Log();
		resolver = r;
		resumeRequired = false;
	}

	public function init(){
		debug.add("Fight "+resolver.attacker.user.name+" vs "+(if (resolver.isle.ownerId == null) "<null>" else App.gamedb.getPlayer(resolver.isle.ownerId).user.name));
		resume = { 
			_fightId: null,
			_from: resolver.attacker.userId, 
			_to: if (resolver.defender != null) resolver.defender.userId else null, 
			_damageYard: 0, 
			_damageBld: 0,
			_damagePop: 0,
			_casualtyPop: 0, 
			_damageAtt: 0,
			_damageDef: 0,
			_damageTwr: 0,
			_casualtyAtt: [],
			_casualtyDef: [],
			_casualtyBld: [],
		};
		history = {
			_defenderId: if (resolver.defender != null) resolver.defender.userId else null,
			_bld: [],
			_ships: [],
			_history: [],
		};
		for (b in resolver.buildings)
			history._bld.push({
				_id: Reflect.field(b, "id"), 
				_type: b.kind, 
				_life: b.life, 
				_x: b.x, 
				_y: b.y, 
				_progress: if (b.isYard()) b.progress else 1.0 
			});
		for (list in [resolver.defenders, resolver.attackers])
			for (s in list)
				history._ships.push({ 
					_id : s.unit.id,
					_type: s.logic.kind,
					_life: s.unit.life,
					_pid: resolver.isle.id,
					_tid: null,
					_owner : s.unit.ownerId,
					_status : s.unit.status
				});
	}

	public function invading(){
		debug.add("Invading isle");
	}
	
	public function startFight(){
		debug.add("Start fight");
		resumeRequired = (resolver.isle.ownerId != null) || (resolver.defenders.length > 0);
		kills = [];
		assaults = [];
	}

	public function unitDestroyed( u ){
		kills.push(u.unit.id);
		if (u.isAttacker){
			resume._casualtyAtt.push(u.logic.kind);
			resolver.defender.getStats().shipDestroyed(u.logic.kind);
		}
		else {
			resume._casualtyDef.push(u.logic.kind);
			resolver.attacker.getStats().shipDestroyed(u.logic.kind);
		}
	}

	public function buildingDestroyed( b ){
		kills.push(Reflect.field(b, "id"));
		resume._casualtyBld.push(b.kind);
		resolver.attacker.getStats().buildingDestroyed(b.kind);
	}

	public function populationDestroyed(){
		kills.push(0);
	}

	public function clearDeaths(){
		newSalve();
		if (kills.length == 0)
			return;
		history._history.push(Destroy(kills));
		kills = [];
	}

	public function newSalve(){
		if (assaults != null && assaults.length > 0){
			history._history.push(Assault(assaults));
			assaults = [];
		}
		if (stakes != null && stakes.length > 0){
			history._history.push(Stakes(stakes));
			stakes = [];
		}
	}

	function newAssault( attId, defId, damages ){
		assaults.push({ _id:attId, _trg:defId, _damage:damages });
	}

	public function newShipVsShipAssault( att:FullUnit, def:FullUnit, damages:Int, realDamages:Int ){
		newAssault(att.unit.id, def.unit.id, damages);
		if (realDamages > 0){
			if (att.isAttacker)
				resume._damageAtt += realDamages;
			else
				resume._damageDef += realDamages;
		}
	}

	public function newShipVsShipDamageRepartition( att:FullUnit, def:FullUnit, damages:Int, realDamages:Int ){
		newAssault(att.unit.id, def.unit.id, damages);
		if (realDamages > 0){
			if (att.isAttacker)
				resume._damageAtt += realDamages;
			else
				resume._damageDef += realDamages;
		}
	}

	public function newShipVsBuildingAssault( att:FullUnit, def:Building, damages:Int, realDamages:Int ){
		newAssault(att.unit.id, Reflect.field(def, "id"), damages);
		if (realDamages > 0)
			resume._damageBld += realDamages;
	}

	public function newTowerVsShipAssault( t:Building, def:FullUnit, damages:Int, realDamages:Int ){
		newAssault(Reflect.field(t,"id"), def.unit.id, damages);
		if (realDamages > 0)
			resume._damageTwr += realDamages;
	}

	public function newPopulationVsShipAssault( def:FullUnit, damages:Int, realDamages:Int ){
		newAssault(0, def.unit.id, damages);
		if (realDamages > 0)
			resume._damageTwr += realDamages;
	}

	public function newShipVsPopulationAssault( att:FullUnit, damages:Int ){
		newAssault(att.unit.id, 0, damages);
	}

	public function newFlowerGivesParasite( att:Building, ship:FullUnit ){
		if (flowers == null)
			flowers = [];
		flowers.push({ _id:Std.int(Reflect.field(att,"id")), _trg:Std.int(ship.unit.id), _damage:0 });
	}

	public function newStackesDamages( def:FullUnit, damages:Int, realDamages:Int ){
		if (stakes == null)
			stakes = [];
		stakes.push({ _id:null, _trg:def.unit.id, _damage:damages });
		if (realDamages > 0)
			resume._damageTwr += realDamages;
	}
	
	public function populationLost( n:Int ){
		debug.add(n+" population lost");
		resume._casualtyPop += n;
	}

	public function unitsWithInitiativeAttack(){
		debug.add("- Initiative");
	}

	public function unitsWithoutInitiativeAttack(){
		debug.add("- Aerian Regular");
	}

	public function townhallDestroyedDuringAttack(){
		debug.add("townhall destroyed, owner looses the isle");
	}

	public function colonizing(){
		debug.add("colonizer found and ownerId is null, colonizing");
	}

	public function beginOfTowersAttackPhase(){
		debug.add("- Towers attack");
	}

	public function unitDidNotFoundAnyTarget( unit:FullUnit ){
		debug.add(unit.logic.kind+" did not find any target");
	}

	public function finalize( victory:Bool, popDamages:Int ){
		debug.add("victory : "+victory);
		// DEBUG: debug.insert();
		resume._damagePop = popDamages;
		if (flowers != null)
			history._history.push(Flower(flowers));
		insertFight();
		if (resumeRequired)
			resolver.isle.addNews({_date:resolver.now, _type:_Attack(resume)});
	}

	function insertFight(){
		if (resume._to == null || resume._to == resume._from)
			return;
		// if (history._history.length == 0)
		//	return;
		var f = new db.Fight();
		f.isleId = resolver.isle.id;
		f.gameId = resolver.isle.gameId;
		f.date = resolver.now;
		f.data = haxe.Serializer.run(history);
		f.insert();
		resume._fightId = f.id;
	}
}
