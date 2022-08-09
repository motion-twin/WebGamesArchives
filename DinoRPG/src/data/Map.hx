package data;

typedef Move = {
	var target : Int;
	var cond : Condition;
	var difficulty : Int;
}

typedef Map = {
	var id : String;
	var mid : Int;
	var zone : Int;
	var name : String;
	var inf : Null<String>;
	var desc : String;
	var pre : Array<String>;
	var goto : Null<Map>;
	var moves : List<Move>;
	var background : Background;
	var real : Map;
	var gather : List<Gather>;
	var shops : List<Shop>;
	var hide : Bool;
	var dungeon : Null<Dungeon>;
	var sneaks : Null<List<Sneak>>;
	var active : Bool;
}

class MapXML extends haxe.xml.Proxy<"map.xml",Map> {

	static var NO_PRE = ["","","",""];

	public static function parse() {
		return new data.Container<Map,MapXML>(true).parse("map.xml",function(id,iid,p) {
			var bg = if( p.has.bg ) Data.BACKGROUNDS.getName(p.att.bg) else Data.BACKGROUNDS.getName(id);
			var pre = if( p.has.pre ) p.att.pre.split(":") else NO_PRE;
			while( pre.length < 4 )
				pre.push(pre[0]);
			return {
				id : id,
				mid : iid,
				zone : Std.parseInt(p.att.zone),
				name : p.att.name,
				inf : if( p.has.inf ) p.att.inf else null,
				desc : p.node.desc.innerData,
				pre : pre,
				real : null,
				goto : null,
				moves : new List(),
				background : bg,
				gather : new List(),
				shops : new List(),
				hide : p.has.hide,
				dungeon : null,
				sneaks : null,
				active : if(p.has.active) Data.ACTIVE.get(p.att.active) else true,
			};
		});
	}

	public static function check() {
		var x = new haxe.xml.Fast(Data.xml("map.xml"));
		for( e in x.elements ) {
			var m = Data.MAP.getName(e.att.id);
			for( e in e.nodes.move ) {
				var m2 = Data.MAP.getName(e.att.to);
				var cond = if( e.has.cond ) Script.parse(e.att.cond) else Condition.CTrue;
				m.moves.add({
					target : m2.mid,
					cond : cond,
					difficulty : if( e.has.pow ) Std.parseInt(e.att.pow) else 1,
				});
			}
			m.real = if( e.has.real ) Data.MAP.getName(e.att.real) else m;
			if( e.has.goto )
				m.goto = Data.MAP.getName(e.att.goto);
			if( e.has.gather )
				m.gather = Lambda.map(e.att.gather.split(":"),Data.GATHER.getName);
		}
	}

}


