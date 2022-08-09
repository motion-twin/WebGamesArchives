package data;


typedef Collection = {
	var id : String ;
	var mid : Int ;
	var name : String ;
	var desc : String ;
	var icon : String ;
}


	
	
class CollectionXML extends haxe.xml.Proxy<"collection.xml",Collection> {

	public static function parse() {
		return new data.Container<Collection,CollectionXML>().parse("collection.xml",function(id,iid,f) {
			return {
				id : id,
				mid : iid,
				name : f.att.name,
				desc : Data.TEXTDESC.format(Tools.format(f.innerData)),
				icon : if( f.has.icon ) f.att.icon else id
			};
		});
	}

}

