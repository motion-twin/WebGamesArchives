package data;

typedef Family = {
	var id : String;
	var did : Int;
	var gfx : Int;
	var name : String;
	var price : Int;
	var item : Null<Collection>;
	var elements : Array<Int>;
	var levelup : Array<Int>;
	var desc : String;
	var skill : Null<Skill>;
	var demon : Null<{ price : Int, skill : Skill, collec : Null<Collection> }>;
	var proba : Int;
	var active : Bool;
}

class FamilyXML extends haxe.xml.Proxy<"dinoz.xml",Family> {

	public static function parse() {
		return new data.Container<Family,FamilyXML>().parse("dinoz.xml",function(id,iid,d) {
			var demon = null;
			if( d.has.demon ) {
				var inf = d.att.demon.split(":");
				var price = Std.parseInt( inf[0] );
				var skill = Data.SKILLS.getName( inf[1] );
				var collec = if( inf.length > 2 ) Data.COLLECTION.getName(inf[2]) else null;
				demon = { price : price, skill : skill, collec : collec };
			}
			return {
				id : id,
				did : iid,
				gfx : Std.parseInt(d.att.gfx),
				name : d.att.name,
				price : Std.parseInt(d.att.price),
				item : if( d.has.item ) Data.COLLECTION.getName(d.att.item) else null,
				elements : Tools.intArray(d.att.elts),
				levelup : Tools.intArray(d.att.levelup),
				desc : Tools.format(d.innerData),
				skill : if( d.has.skill ) Data.SKILLS.getName(d.att.skill) else null,
				demon : demon,
				proba : if( d.has.proba ) Std.parseInt(d.att.proba) else 100,
				active : if( d.has.active ) Data.ACTIVE.get(d.att.active) else true,
			};
		});
	}

}
