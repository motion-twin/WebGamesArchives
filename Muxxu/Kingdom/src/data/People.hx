package data;

typedef People = {
	var id : String;
	var pid : Int;
	var name : String;
	var desc : String;
}

class PeopleXML extends haxe.xml.Proxy<"people.xml",People> {

	public static function parse() {
		return new data.Container<People,PeopleXML>().parse("people.xml",function(id,pid,p) : People {
			return {
				id : id,
				pid : pid,
				name : p.att.name,
				desc : Data.format(p.innerData),
			};
		});
	}

}
