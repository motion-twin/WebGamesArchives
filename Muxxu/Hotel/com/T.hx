private class AllData extends haxe.xml.Proxy<"xml/fr/lang.xml",String > { }
private class AllDataFormat extends haxe.xml.Proxy<"xml/fr/lang.xml",Dynamic->String> {}

import Protocol;

class T {
	static var ALL : Hash<String>;
	#if neko
	public static var get : AllData = parse();
	#else
	public static var get : AllData;
	#end
	
	public static function init() {
		get = parse();
	}

	private static function parse() {
		try {
			#if flash
			var raw = haxe.Resource.getString(Game.LANG+".lang.xml");
			#elseif neko
			var raw = neko.io.File.getContent(Config.TPL+"../../xml/"+Config.LANG+"/lang.xml");
			#end

			var h = new Hash();
			var xml = Xml.parse(raw);
			var fast = new haxe.xml.Fast(xml.firstChild());
			
			for (n in fast.nodes.t)
				h.set(n.att.id, htmlize(n.innerHTML));
			
			ALL = h;
			return new AllData(ALL.get);
		}
		catch (e:Dynamic) {
			trace(e);
			throw "FAILED";
		}
	}
	
	private static function htmlize(str:String) {
		#if neko
		str = replaceTag(str, "--", "<strong class='bad'>", "</strong>");
		str = replaceTag(str, "++", "<strong class='good'>", "</strong>");
		//str = replaceTag(str, "*", "<strong>", "</strong>");
		#end
		str = replaceTag(str, "*", "<strong><span class='strong'>", "</span></strong>");
		return str;
	}
	
	private static function replaceTag(str:String, char, open, close) {
		var list = str.split(char);
		if ( list.length==0 )
			return str;
		str = "";
		var bool = true;
		var i = 0;
		for (part in list) {
			if (i==list.length-1)
				str += part;
			else
				if (i%2==0)
					str += part + open;
				else
					str += part + close;
			i++;
		}
				
		return str;
	}


	static function _format(k:String){
		return function(data){
			var str = if(ALL.exists(k)) ALL.get(k) else "#"+k+"#";
			for (field in Reflect.fields(data))
				str = StringTools.replace(str, "::"+field.substr(1)+"::", Std.string(Reflect.field(data, field)));
			return str;
		}
	}
	public static var format = new AllDataFormat(_format);
	
	
	public static function getByKey(k:String) {
		return
			if (ALL.exists(k))
				ALL.get(k);
			else
				"#"+k+"#";
	}

	public static function formatByKey(k:String, data:Dynamic) {
		return
			if (ALL.exists(k))
				_format(k)(data);
			else
				"#"+k+"#";
	}
	
	public static function getClientRule(type:_MonsterFamily) {
		return getByKey("Rule_"+Std.string(type).substr(4));
	}
	
	public static function getItemText(item:_Item) {
		var raw = getByKey( Std.string(item).substr(1) );
		if (raw.indexOf("|")<0)
			raw+="||";
		raw = StringTools.replace( raw, "| ", "|" );
		var slist = raw.split("|");
		return {
			_name		: StringTools.trim(slist[0]),
			_ambiant	: StringTools.trim(slist[1]),
			_rule		: StringTools.trim(slist[2]),
		}
	}
}