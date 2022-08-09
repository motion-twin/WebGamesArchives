package data;

typedef Building = {
	var id : String;
	var bid : Int;
	var name : String;
	var desc : String;
	var price : Int;
	var time : Int;
	var require : Building;
	var manaWar : Bool;
}

class BuildingXML extends haxe.xml.Proxy<"buildings.xml",Building> {

	public static function parse() {
		return new data.Container<Building,BuildingXML>(true).parse("buildings.xml",function(id,bid,b) {
			return {
				id : id,
				bid : bid,
				name : b.att.name,
				desc : StringTools.trim(b.innerData),
				price : Std.parseInt(b.att.price),
				time : Std.parseInt(b.att.time),
				require : null,
				manaWar : b.has.manaWar ? Std.parseInt(b.att.manaWar) == 1 : false,
			};
		});
	}

	public static function check() {
		var x = new haxe.xml.Fast(Data.xml("buildings.xml"));
		for( e in x.elements ) {
			var b = Data.BUILDINGS.getName(e.att.id);
			if( e.has.require )
				b.require = Data.BUILDINGS.getName(e.att.require);
		}
	}

}
