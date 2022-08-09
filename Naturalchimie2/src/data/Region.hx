package data;

typedef Region = {
	var id : String ;
	var iid : Int ;
	var name : String ;
	var inf : String ;
	var dplace : String ;
}


class RegionXML extends haxe.xml.Proxy<"regions.xml",Region> {

	public static function parse() {
		return new data.Container<Region,RegionXML>().parse("regions.xml",function(id,iid,f) {
			return {
				id : f.att.id,
				iid : Std.parseInt(f.att.iid),
				name : f.att.name,
				inf : f.att.inf,
				dplace : f.att.defaultPlace
			};
		});
	}

}
