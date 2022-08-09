private class AllTexts extends haxe.xml.Proxy<"../xml/lang.client.fr.xml",String> {
}

private class AllTextsFormat extends haxe.xml.Proxy<"../xml/lang.client.fr.xml",Dynamic->String> {
}

class Lang {

	public static var TEXTS = init();

	static function init() {
		var xml = Xml.parse(haxe.Resource.getString("xml_lang_"+Manager.LANG)).firstElement();
		var h = new Hash();
		for( x in xml.elements() ) {
			var id = x.get("id");
			if( id == null )
				throw "Missing 'id' in data.xml";
			if( h.exists(id) )
				throw "Duplicate id '"+id+"' in data.xml";
			var buf = new StringBuf();
			for( c in x )
				buf.add(c.toString());
			h.set(id,parse(buf.toString()));
		}
		return h;
	}

	public static var get = new AllTexts(TEXTS.get);
	static function parse(str) {
		str = StringTools.replace(str, "&quot;", "\"");
		str = StringTools.replace(str, "&apos;", "'");
		str = StringTools.replace(str, "|", "\n");
		return str;
	}

	static function _fmt(k:String){
		return function(data){
			return replaceVars(TEXTS.get(k),data);
		}
	}
	public static var fmt = new AllTextsFormat(_fmt);

	public static function format(k:String, data:Dynamic) {
		var str = TEXTS.get(k);
		if ( str==null )
			Manager.fatal("Lang : invalid key "+k);
		return replaceVars(str,data);
	}

	public static function replaceVars(str:String,data:Dynamic) {
		for (field in Reflect.fields(data))
			str = StringTools.replace(str, "::"+field.substr(1)+"::", Std.string(Reflect.field(data, field)));
		return str;
	}

}
