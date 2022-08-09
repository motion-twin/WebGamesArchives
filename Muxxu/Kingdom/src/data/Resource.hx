package data;

enum RKind {
	RFood;
	RWood;
	RGold;
	RMetal;
	RLin;
	RHorse;
}

typedef Resource = {
	var id : String;
	var k : RKind;
	var rid : Int;
	var name : String;
	var desc : String;
	var place : String;
	var placePre : String;
	var mapGfx : Int;
}

class ResourceXML extends haxe.xml.Proxy<"resources.xml",Resource> {

	public static function parse() {
		return new data.Container<Resource,ResourceXML>().parse("resources.xml",function(id,rid,r) : Resource {
			var k = Reflect.field(RKind,"R"+id.charAt(0).toUpperCase()+id.substr(1));
			if( k == null ) throw "Missing rkind "+id;
			return {
				id : id,
				k : k,
				rid : rid,
				name : r.att.name,
				desc : Data.format(r.innerData),
				place : r.has.place ? r.att.place : "???",
				placePre : r.has.placePre ? r.att.placePre : "",
				mapGfx : r.has.mapGfx ? Std.parseInt(r.att.mapGfx) : null,
			};
		});
	}

}
