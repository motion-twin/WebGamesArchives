package data ;

typedef Category = {
	var id : Int ;
	var code : String ;
	var name : String ;
	var desc : String ;
}


class CategoryXML extends haxe.xml.Proxy<"categories.xml",Category> {

	public static function parse() {
		/*return new data.Container<Category,CategoryXML>().parse("categories.xml",function(id,iid,f) {
			return {
				id : Std.parseInt(f.att.id),
				code : f.att.code,
				name : f.att.name,
				desc : Data.TEXTDESC.format(f.innerData)
			} ;
		}) ;*/
		
		var res = new data.Container<Category,CategoryXML>(false, false) ;
		for( e in Data.xml("categories.xml").elements() ) {
			var f = new haxe.xml.Fast(e) ;
			var c = {
				id : Std.parseInt(f.att.id),
				code : f.att.code,
				name : f.att.name,
				desc : Data.TEXTDESC.format(f.innerData)
			} ;
			
			res.h.set(c.code,c) ;
			res.i.set(c.id,c) ; 
		}
		return res ;
	}

}
