package data;

typedef GoalTitle = {
	var name : String;
	var count : Int;
	var points : Int;
	var prefix : Bool;
	var suffix : Bool;
}

typedef Goal = {
	var id : String;
	var gid : Int;
	var name : String;
	var hidden : Bool;
	var rare : Bool;
	var desc : String;
	var titles : List<GoalTitle>;
}

/**
 * ...
 * @author Thomas
 */

class GoalXML extends haxe.xml.Proxy<"../tpl/goals.xml", Goal> {

	public static function parse() {
		return new data.Container<Goal, GoalXML>().parse("../tpl/goals.xml", function(id, gid, g) {
			var titles = new List();
			for( t in g.nodes.title ) {
				titles.add( {
					name	: t.att.name,
					count	: Std.parseInt(t.att.k),
					points 	: t.has.points ? Std.parseInt(t.att.points) : 0,
					prefix 	: t.has.prefix && t.att.prefix == "1",
					suffix 	: t.has.suffix && t.att.suffix == "1",
				} );
			}
				
			return {
				id 		: id,
				gid		: gid,
				name	: g.att.name,
				hidden  : g.has.hidden && g.att.hidden == "1",
				rare	: g.has.rare && g.att.rare != "0",
				desc	: if(g.has.desc) g.att.desc else "",
				titles	: titles,
			}
		}, "goal");
	}
	
}
