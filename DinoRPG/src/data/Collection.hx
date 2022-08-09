package data;

typedef Collection = {
	var id : String;
	var order : Int;
	var oid : Int;
	var name : String;
	var desc : String;
}

class CollectionXML extends haxe.xml.Proxy<"collection.xml",Collection> {

	public static function parse() {
		var order = 0;
		return new data.Container<Collection,CollectionXML>().parse("collection.xml",function(id,iid,o) {
			return {
				id : id,
				order : order++,
				oid : iid,
				name : o.att.name,
				desc : Tools.format(o.innerData),
			};
		});
	}

}
