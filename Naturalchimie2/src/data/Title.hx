package data ;


typedef TitleLevel = {
	id : Int,
	name		: String,
	min			: Int,
}

typedef Title = {
	id		: String,
	mid		: Int,
	desc	: String,
	levels	: Array<TitleLevel>
}



	
class TitleXML extends haxe.xml.Proxy<"titles.xml",Title> {

	public static function parse() {
		return new data.Container<Title,TitleXML>().parse("titles.xml",function(id,iid,f) {
			var res =  {
				id : id,
				mid : iid,
				desc : Data.TEXTDESC.format(Tools.format(f.att.desc)),
				levels : new Array()
			};
						
			var i = 0 ;
			for (l in f.nodes.l) {
				res.levels.push({id : i, name : l.att.name, min : Std.parseInt(l.att.n)}) ;
				i++ ;
			}
			
			return res ;
		});
	}

}

