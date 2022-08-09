private class AllTexts extends haxe.xml.Proxy<"lang.fr.xml", String> {
}

class Lang {

	public static var TEXTS = init();

	static function init() {
		var xml = Xml.parse(haxe.Resource.getString("xml_lang")).firstElement();
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
			h.set(id,buf.toString());
		}
		return h;
	}

	public static var get = new AllTexts(TEXTS.get);
	public static function getText(id) {
		var str = TEXTS.get(id);
		str = StringTools.replace(str, "&apos;", "'");
		return str;
	}

}
