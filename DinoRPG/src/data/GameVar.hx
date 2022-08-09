package data;

typedef GameVar = {
	var id : String;
	var vid : Int;
	var desc : String;
	var temporary : Bool;
}

class GameVarXML extends haxe.xml.Proxy<"gamevars.xml",GameVar> {

	public static function parse() {
		return new data.Container<GameVar,GameVarXML>().parse("gamevars.xml",function(id,iid,v) {
			return {
				id : id,
				vid : iid,
				desc : Tools.format(v.innerData),
				temporary : v.has.temporary ? v.att.temporary == "1" : false,
			};
		});
	}
}