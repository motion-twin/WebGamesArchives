package data;

typedef Unit = {
	var id : String;
	var uid : Int;
	var name : String;
	var life : Int;
	var desc : String;
	var machine : Bool;
}

class UnitXML extends haxe.xml.Proxy<"units.xml",Unit> {

	public static function parse() {
		return new data.Container<Unit,UnitXML>().parse("units.xml",function(id,uid,u) : Unit {
			return {
				id : id,
				uid : uid,
				name : u.att.name,
				life : Std.parseInt(u.att.life),
				desc : Data.format(u.innerData),
				machine : u.has.machine,
			};
		});
	}

}
