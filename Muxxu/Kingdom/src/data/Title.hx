package data;

typedef Title = {
	var id : String;
	var tid : Int;
	var name : String;
	var prefix : Array<String>;
	var size : Int;
	var index : Int;
	var goal : Goal;
	var difficulty : Int;
}

class TitleXML extends haxe.xml.Proxy<"titles.xml",Title> {

	static var INDEX = 0;

	public static function parse() {
		return new data.Container<Title,TitleXML>(true).parse("titles.xml",function(id,tid,t) : Title {
			return {
				id : id,
				tid : tid,
				name : t.att.name,
				prefix : ~/[:;]/g.split(t.att.prefix),
				size : Std.parseInt(t.att.size),
				goal : if( t.has.goal ) App.GOALS.resolve(t.att.goal) else null,
				difficulty : Std.parseInt(t.att.difficulty),
				index : INDEX++,
			};
		});
	}

}
