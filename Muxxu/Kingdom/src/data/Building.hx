package data;

typedef BuildingLevel = {
	var cost : Array<{ r : Resource, n : Int }>;
	var turns : Int;
	var title : Null<data.Title>;
}

typedef Building = {
	var id : String;
	var bid : Int;
	var name : String;
	var desc : String;
	var up : String;
	var action : String;
	var levels : Array<BuildingLevel>;
	var requires : Array<{ b : Building, bid : String }>;
	var unit : Null<data.Unit>;
}

class BuildingXML extends haxe.xml.Proxy<"buildings.xml",Building> {

	public static function parse() {
		return new data.Container<Building,BuildingXML>(true).parse("buildings.xml",function(id,bid,b) : Building {
			var cost = new List();
			var turns = 0;
			var requires = [];
			var build = b.node.build;
			for( a in build.x.attributes() ) {
				var v = build.att.resolve(a);
				switch( a ) {
				case "turns":
					turns = Std.parseInt(v);
				case "require":
					for( r in v.split(":") )
						requires.push({ b : null, bid : r });
				default:
					cost.add({ r : Data.RESOURCES.getName(a), n : Std.parseInt(v) });
				}
			}
			var levels = new Array<BuildingLevel>();
			levels.push(null);
			for( l in 0...5 ) {
				var cost = cost.map(function(c) return { r : c.r, n : Rules.getLevelCost(l,c.r) * c.n });
				levels.push({
					cost : Lambda.array(cost),
					turns : Rules.getLevelCost(l,null) * turns,
					title : null,
				});
			}
			if( id == "palace" )
				levels[1] = { cost : [{ r : Data.RESOURCES.list.wood, n : 15 }], turns : 2, title : null };
			if( b.has.titles ) {
				var n = 1;
				for( t in b.att.titles.split(":") )
					levels[n++].title = Data.TITLES.getName(t);
			}
			return {
				id : id,
				bid : bid,
				name : b.att.name,
				action : b.has.action ? b.att.action : null,
				desc : Data.format(b.node.desc.innerData),
				up : Data.format(b.node.up.innerData),
				levels : levels,
				requires : requires,
				unit : b.has.unit ? Data.UNITS.getName(b.att.unit) : null,
			};
		});
	}

	public static function check() {
		for( b in Data.BUILDINGS )
			for( r in b.requires ) {
				r.b = Data.BUILDINGS.getName(r.bid);
				r.bid = null;
			}
	}

}
