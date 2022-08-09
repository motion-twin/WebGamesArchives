import db.Isle;
import Datas;

/**
   Handles isle's yard manipulations.
   This class is an Isle manipulator specialized on yard data (production).
**/
class Yard {
	var isle : Isle;

	public function new( isle:Isle ){
		this.isle = isle;
	}

	function setProductions( l:List<Production> ) {
		untyped isle.productions = l;
		untyped isle.productionsModified = true;
	}

	public function destroy(){
		setProductions(new List());
		isle.nextProductionEnd = null;
		isle.nextProductionStop = null;
		isle.nextProductionStart = null;
	}

	public function getProductions() : List<Production> {
		if (untyped isle.productions == null)
			untyped isle.productions = if (isle.sproductions == null) new List() else haxe.Unserializer.run(isle.sproductions);
		return untyped isle.productions;
	}

	public function getCurrentProduction() : Production {
		if (isle.nextProductionEnd == null)
			return null;
		return getProductions().first();
	}

	public function canComputeProduction( now:Float ){
		if (isle.nextProductionEnd == null || isle.nextProductionEnd > now)
			return false;
		var curr = getCurrentProduction();
		if (curr == null)
			return false;
		switch (curr.kind){
			case Ship(kind):
				var l = ShipLogic.get(kind).applyUserTechnos(isle.getPlayer().getTechnos());
				if (l.cost.population > 0 && l.cost.population > isle.population)
					return false;
			case Building(kind,x,y):
				return true;
		}
		return true;
	}

	public function computeProduction( now:Float ){
		var prods = getProductions();
		var dif = now - isle.nextProductionEnd;
		var curr = prods.pop();
		switch (curr.kind){
			case Ship(kind):
				var p = isle.getPlayer();
				var l = ShipLogic.get(kind).applyUserTechnos(p.getTechnos());
				if (l.cost.population > 0){
					if (l.cost.population > isle.population){
						curr.progress = 1.0;
						prods.push(curr);
						setProductions(prods);
						return false;
					}
					isle.setPopulation(isle.population - l.cost.population, now, true);
				}
				var u = new db.Unit();
				u.gameId = isle.gameId;
				u.ownerId = isle.ownerId;
				u.isleId = isle.id;
				u.setKind(kind);
				u.life = l.life;
				u.people = l.cost.population;
				u.insert();
				p.addPower(l.cost);
				p.getStats().shipConstructed(u);
				isle.addNews({ _date:now, _type:_NewShip(kind) });
				if (kind != APICOPTER && p.hasTechno(_Tec.ESCORT) && !Lambda.has(p.getDisabledTechnos(), _Tec.ESCORT) &&
					isle.population > 1 && p.units < p.getMaxUnits()){
					isle.setPopulation(isle.population - 1, now, true);
					var kind = APICOPTER;
					var l = ShipLogic.get(kind).applyUserTechnos(p.getTechnos());
					var u = new db.Unit();
					u.gameId = isle.gameId;
					u.ownerId = isle.ownerId;
					u.isleId = isle.id;
					u.setKind(kind);
					u.life = l.life;
					u.people = l.cost.population;
					u.insert();
					p.addPower(l.cost);
					p.getStats().shipConstructed(u);
					p.units += l.getUnitsCost();
					isle.addNews({ _date:now, _type:_NewShip(kind) });
				}

			case Building(kind, x, y):
				isle.addBuilding(new Building(kind, x, y, curr.damages, 1.0), isle.nextProductionEnd);
				isle.getPlayer().addPower(BuildingLogic.get(kind).cost);
				isle.getPlayer().getStats().buildingConstructed(kind);
				isle.addNews({ _date:now, _type:_NewBuilding(kind) });
		}
		isle.nextProductionEnd = null;
		isle.nextProductionStop = null;
		setProductions(prods);
		startNextProduction(now - dif);
		return true;
	}

	public function isProducing( b:_Bld ) : Bool {
		if (isle.nextProductionEnd == null)
			return false;
		var p = getProductions().first();
		return switch (p.kind){
			case Building(bld, x, y):
				(bld == b);
			default:
				false;
		}
	}

	public function addProduction( p:ProductionKind, now:Float ){
		var productions = getProductions();
		productions.add({kind:p, progress:0.0, damages:0});
		setProductions(productions);
		if (isle.nextProductionEnd == null)
			startNextProduction(now);
	}

	public function addProductionDamages( x:Int, y:Int, damages:Int ) : Bool {
		var productions = getProductions();
		for (p in productions){
			switch (p.kind){
				case Ship(k):
				case Building(k,bx,by):
					if (bx == x && by == y){
						p.damages += damages;
						setProductions(productions);
						return true;
					}
			}
		}
		return false;
	}

	public function delProductionAt( x:Int, y:Int, now:Float, restoreRsc=true ) : Bool {
		var idx = 0;
		for (p in getProductions()){
			switch (p.kind){
				case Ship(k):
				case Building(k,bx,by):
					if (bx == x && by == y){
						cancelProduction(idx, now, restoreRsc);
						return true;
					}
			}
			idx++;
		}
		return false;
	}

	public function cancelProduction( idx:Int, now:Float, restoreRsc:Bool=true ){
		var productions = Lambda.array(getProductions());
		var me = this;
		var restoreResources = function(prod : Production){
			var gu = me.isle.getPlayer();
			var logic : Constructable = null;
			switch (prod.kind){
				case Ship(kind):
					var l = ShipLogic.get(kind);
					gu.units -= l.getUnitsCost();
					logic = cast l;
				case Building(kind, x, y):
					logic = cast BuildingLogic.get(kind);
			}
			gu.addResources(logic.cost);
			tools.UpdateList.add(gu);
		}
		if (idx == 0){
			var prod = productions.shift();
			setProductions(Lambda.list(productions));
			// this production was started, restore resources and start next
			if (isle.nextProductionEnd != null){
				isle.nextProductionEnd = null;
				isle.nextProductionStop = null;
				if (restoreRsc)
					restoreResources(prod);
			}
			startNextProduction(now);
		}
		else {
			var production = productions[idx];
			if (production == null)
				throw "Production "+idx+" not in list";
			if (production.progress > 0.0 && restoreRsc)
				restoreResources(production);
			productions.splice(idx, 1);
			setProductions(Lambda.list(productions));
		}
	}

	public function getCurrentProgress( now:Float ) : Float {
		if (now == null)
			return 0.0;
		if (isle.nextProductionStop != null)
			return isle.nextProductionStop;
		if (isle.nextProductionStart != null && isle.nextProductionEnd != null)
			return Math.max(0.00000001, Math.min(1.0, (now - isle.nextProductionStart) / (isle.nextProductionEnd - isle.nextProductionStart)));
		return 0.0;
	}

	public function swapProduction( idx:Int, destIdx:Int, now:Float ){
		var productions = Lambda.array(getProductions());
		destIdx = Std.int(Math.max(0, destIdx));
		destIdx = Std.int(Math.min(productions.length, destIdx));
		if (productions.length <= 1 || idx == destIdx || idx < 0 || idx >= productions.length){
			return;
		}
		productions[0].progress = getCurrentProgress(now);
		// count started productions
		var startedProductions = 0;
		for (p in productions)
			if (p.progress > 0.0)
				startedProductions++;
		// refuse to swap non started production with first production if already 3 productions are started
		if (startedProductions >= 3 && destIdx == 0)
			if (productions[idx].progress == 0.0)
				throw MAX_STARTED_PROD_LIMIT_REACHED;

		if (idx == 0 || destIdx == 0){
			isle.nextProductionEnd = null;
			isle.nextProductionStop = null;
			isle.nextProductionStart = null;
		}
		var removed = productions.splice(idx, 1);
		if (destIdx == 0)
			productions.unshift(removed[0]);
		else
			productions.insert(destIdx, removed[0]);

		if (startedProductions >= 3 && productions[0].progress == 0.0)
			throw MAX_STARTED_PROD_LIMIT_REACHED;

		setProductions(Lambda.list(productions));
		if (now != null && isle.nextProductionEnd == null)
			startNextProduction(now);
	}

	function startNextProduction( now:Float ){
		if (now == null)
			return false;
		var p = getProductions().first();
		if (p == null)
			return false;
		var isShip = false;
		var logic : Constructable = null;
		switch (p.kind){
			case Ship(kind):
				logic = ShipLogic.get(kind);
                isShip = true;
			case Building(kind, x, y):
				logic = BuildingLogic.get(kind);
		}
		if (p.progress > 0.0 || logic.canBuild(isle)){
			if (p.progress == 0.0){
				var gu = isle.getPlayer();
				gu.delResources(logic.cost);
				if (isShip)
					gu.units += (cast logic).getUnitsCost();
				tools.UpdateList.add(gu);
			}
			var duration = getProductionDuration(logic);
			isle.nextProductionStart = now - duration * p.progress;
			isle.nextProductionEnd = now + duration * (1 - p.progress);
			isle.nextProductionStop = null;
			updateProductionTime(now);
			return true;
		}
		return false;
	}

	public function getProductionDuration( ?logic:Constructable ) : Float {
		if (isle.population == 0)
			return 1000000000000.0;
		if (logic == null){
			var p = getProductions().first();
			if (p == null)
				return null;
			switch (p.kind){
				case Ship(kind):
					logic = ShipLogic.get(kind);
				case Building(kind, x, y):
					logic = BuildingLogic.get(kind);
			}
		}
		return Math.round(
			GamePlay.getPopulationBuildBonus(isle.population)
			* logic.getIsleBuildTime(
				Lambda.map(isle.getBuildings(), function(x) return x.kind),
				isle.getPlayer().getTechnos())
			);
	}

	public function getProductionAt( x:Int, y:Int ) : Production {
		for (p in getProductions())
			switch (p.kind){
				case Building(kind,cx,cy):
					if (cx == x && cy == y)
						return p;
				default:
			}
		return null;
	}

	function pauseProduction( now:Float ){
		if (isle.nextProductionStop != null)
			return;
		var oldt = isle.nextProductionEnd - isle.nextProductionStart;
		if (oldt == null || oldt == 0)
			return;
		isle.nextProductionStop = (now - isle.nextProductionStart) / oldt;
		isle.nextProductionEnd = isle.nextProductionStart + oldt * 1000;
	}

	function resumeProduction( now:Float ){
		if (isle.nextProductionStop == null)
			return;
		// restart paused productions
		var newt = getProductionDuration();
		var done = Math.round(newt * isle.nextProductionStop);
		var remain = newt - done;
		isle.nextProductionStart = now - done;
		isle.nextProductionEnd = now + remain;
		isle.nextProductionStop = null;
	}

	function canStillBuildCurrentProduction() : Bool {
		var prod = getProductions().first();
		if (prod == null)
			return true;
		return switch (prod.kind){
			case Ship(kind): ShipLogic.get(kind).isAvailable(isle);
			case Building(kind, x, y): cast BuildingLogic.get(kind).buildingRequirementsMet(isle, true);
		};
	}

	public function updateProductionTime( now:Float ){
		if (getProductions().length == 0){
			isle.nextProductionStart = null;
			isle.nextProductionEnd = null;
			isle.nextProductionStop = null;
			return;
		}
		if (isle.nextProductionEnd == null && isle.nextProductionStop == null && getProductions().length > 0){
			startNextProduction(now);
		}
		if (isle.nextProductionEnd == null || isle.nextProductionStart == null){
			return;
		}
		var oldt = isle.nextProductionEnd - isle.nextProductionStart;
		if (oldt == null || oldt == 0){
			return;
		}
		if (!canStillBuildCurrentProduction()){
			if (isle.nextProductionStop != null){
				return;
			}
			pauseProduction(now);
			return;
		}
		if (isle.population <= 0 && isle.nextProductionStop == null){
			pauseProduction(now);
		}
		else if (isle.population <= 0){
			// already stopped, do nothing
		}
		else if (isle.nextProductionStop != null){
			resumeProduction(now);
		}
		else {
			var remain = isle.nextProductionEnd - now;
			var newt = getProductionDuration();
			if (newt == null || newt == 0){
				var log = new db.Log();
				log.add("Unable to retrieve production duration : ");
				log.add("Yard=");
				log.add(getProductions().join("\n"));
				log.add("nextProductionStart = "+isle.nextProductionStart);
				log.add("nextProductionEnd   = "+isle.nextProductionEnd);
				log.add("nextProductionStop  = "+isle.nextProductionStop);
				log.add("remain = "+remain);
				log.add("oldt = "+oldt);
				return;
			}
			remain = Math.round(remain * (newt / oldt));
			isle.nextProductionEnd = now + remain;
			isle.nextProductionStart = isle.nextProductionEnd - newt;
			isle.nextProductionStop = null;
		}
	}
}
