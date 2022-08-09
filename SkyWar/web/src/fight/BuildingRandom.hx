package fight;
import Datas._BldType;

/**
	This class helps the FightResolver to select a building using player's attack priorities.
**/
class BuildingRandom {
	var table : Array<{p:Int, a:Array<Target>}>;

	public function new( buildings:Array<Building>, priorities:List<_BldType>, pcents:Array<Int>, population ){
		table = [];
		var copy = buildings.copy();
		var i = 0;
		var popAdded = false;
		for (p in priorities){
			if (i >= pcents.length)
				break;
			switch (p){
				case BT_POP:
					if (population > 0)
						this.add(pcents[i], [Target.TPop]);
					popAdded = true;
				default:
					var a = tools.Utils.amap(
						Lambda.filter(copy, function(b) return BuildingLogic.get(b.kind).type == p), 
						function(x) return Target.TBuilding(x)
					);
					for (b in a){
						switch (b){
							case TBuilding(bld):
								copy.remove(bld);
							default:
						}
					}
					this.add(pcents[i], a);
			}
			++i;
		}
		var last = tools.Utils.amap(copy, function(b) return Target.TBuilding(b));
		if (!popAdded && population > 0)
			last.push(Target.TPop);
		this.add(0, last);
	}

	function add( p:Int, a:Array<Target> ){
		if (a.length == 0)
			return;
		table.push({ p:p, a:a });
		table.sort(function(a,b) return -1 * Reflect.compare(a.p, b.p));
	}

	public function destroyed( b:Target ){
		for (v in table.copy()){
			if (v.a.remove(b)){
				if (v.a.length == 0)
					table.remove(v);
				break;
			}
		}
	}

	public function random() : Target {
		if (table.length == 0)
			return null;
		for (v in table){
			if (v.p == 0 || table.length == 1)
				return v.a[Std.random(v.a.length)];
			if (v.p > Std.random(100))
				return v.a[Std.random(v.a.length)];
		}
		var i = Std.random(table.length);
		return table[i].a[Std.random(table[i].a.length)];
	}

	public function alterPriorities(){
		for (v in table){
			v.p = Math.round(v.p / 2);
		}
	}
	
	/*
	public function cancelPriorities(){
		var all = [];
		for (v in table)
			all = all.concat(v.a);
		table = if (all.length == 0) [] else [{p:0, a:all}];
	}
	*/
}
