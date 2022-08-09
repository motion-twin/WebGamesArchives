package data;
import GatherData;

enum GatherFound {
	FIngr( i : Array<Ingredient> );
	FObject( o : Array<Object>, qty : Int );
	FGold( count : Int );
}

typedef Gather = {
	var id : String;
	var gid : Int;
	var act : Action;
	var skill : Skill;
	var object : Object;
	var skin : _GatherSkin;
	var size : Int;
	var clicks : Int;
	var found : List<{ f : GatherFound, cond : Condition, count : Int }>;
	var type : String;
	var cond : Condition;
}

using Lambda;
class GatherXML extends haxe.xml.Proxy<"gather.xml",Gather> {

	public static function parse() {
		return new data.Container<Gather,GatherXML>().parse("gather.xml",function(id,gid,g) {
			var skin = Reflect.field(_GatherSkin,"S"+g.att.skin);
			if( skin == null )
				throw "Unknown skin "+g.att.skin;
			var found = new List();
			var gather = {
				id  : id,
				gid : gid,
				act : Data.ACTIONS.getName(g.att.act),
				skill  : if( g.has.skill ) Data.SKILLS.getName(g.att.skill) else null,
				object : if( g.has.object ) Data.OBJECTS.getName(g.att.object) else null,
				skin : skin,
				size : Std.parseInt(g.att.size),
				clicks : Std.parseInt(g.att.clicks),
				found  : found,
				type : g.att.type,
				cond : if(  g.has.cond ) Script.parse(g.att.cond ) else Condition.CTrue,
			};
			
			if( gather.skill == null && gather.object == null && gather.cond == null )
				throw "No gather condition";
			
			for( i in g.elements ) {				
				var f = if( i.has.gold )
							FGold( Std.parseInt(i.att.gold) )
						else if( i.has.object )
							FObject( i.att.object.split(",").map(function(o) return Data.OBJECTS.getName(o)).array(), if( i.has.n ) Std.parseInt(i.att.n) else 1 );
						else {
							FIngr(i.att.v.split(",").map(function(i) {								
								var ingr = Data.INGREDIENTS.getName(i);
								if( ingr.gather == null ) ingr.gather = gather;
								return ingr;
							}).array());
						}
				found.add({
					f : f,
					cond : if( i.has.cond ) Script.parse(i.att.cond) else Condition.CTrue,
					count : Std.parseInt(i.att.count),
				});
			}
			return gather;
		});
	}
}
