package data;

typedef ChipsetData = {
	id		: String,
	price	: Int,
	name	: String,
	desc	: String,
	level	: Int,
}

private class AllData extends haxe.xml.Proxy<"../xml/chipsets.xml",ChipsetData> {
}

class ChipsetsXml {

	static var FILE = "chipsets.xml";
	public static var ALL : Hash<ChipsetData> = new Hash();
	public static var get : AllData = null;
	#if neko
		static var autoRun = init();
	#end

	public static function init() {
		#if flash
			var raw = Manager.getEncodedXml("chipsets");
		#end
		#if neko
			var raw = neko.io.File.getContent( neko.Web.getCwd() + Const.get.XML + FILE );
		#end
		var h : Hash<ChipsetData> = new Hash();
		var xml = Xml.parse(raw);
		var doc = new haxe.xml.Fast( xml.firstElement() );
		for( node in doc.nodes.c ) {
			var id = node.att.id.toLowerCase();
			if( id == null )
				throw "Missing 'id' in "+FILE;
			if( h.exists(id) )
				throw "Duplicate id '"+id+"' in "+FILE;
			var data : ChipsetData = {
				id		: id,
				price	: Std.parseInt(node.att.pr),
				name	: node.att.name,
				desc	: node.innerHTML,
				level	: if (node.has.l) Std.parseInt(node.att.l) else 0,
			}
			h.set(id,data);
		}

		ALL = h;
		get = new AllData(ALL.get);
	}




	public static function isAvailable(c:ChipsetData, gameLevel:Int) {
		#if debug
			return true;
		#end
		return c.price>0 && c.level<=gameLevel;
	}
}
