//
// TODO: Use the new mt.data.Mods to parse the docs/vices.ods file and get rid of the xml file.
//

private class Proxy extends haxe.xml.Proxy<"lang/fr/tpl/vices.xml",Vice> {
}

enum ViceWhen {
	_Always;
	_BeforeGame;
	_Pause;
	_InGame;
	_Code;
	_AfterGame;
	_TeamFault;
}

class Vice {
	static var SALL : Hash<Vice>;
	public static var ALL : Hash<Vice> = {
		#if neko
		var xml = Xml.parse(neko.io.File.getContent(Config.TPL+"vices.xml")).firstElement();
		#else
		var xml = Xml.parse(haxe.Resource.getString("vices.xml")).firstElement();
		#end
		Vice.SALL = new Hash();
		var h = new Hash();
		for (x in xml.elements()){
			var skey = x.get("skey");
			var id = x.get("id");
			if (id == null)
				id = skey;
			if (id == "" || id == null || skey == "" || skey == null)
				continue;
			if (skey.charAt(0) == "-")
				continue;
			if (h.exists(id))
				throw "Duplicate ID '"+id+"' in vices.xml";
			var vice = new Vice(x);
			if (Vice.SALL.exists(vice.skey))
				throw "Duplicate SKEY '"+vice.skey+"' in vices.xml";
			h.set(id, vice);
			Vice.SALL.set(vice.skey, vice);
		}
		h;
	}

	public static var get = new Proxy(ALL.get);
	public static function getBySkey( id:String ) : Vice {
		return SALL.get(id);
	}

	public var skey : String;
	var key : String;
	public var name : String;
	public var desc : String;
	public var pcent : Null<Float>;
	public var when : ViceWhen;
	public var act : ViceAct;
	public var ambiants : Array<String>;

	function new( xml:Xml ){
		key = xml.get("id");
		skey = xml.get("skey");
		name = xml.get("name");
		when = if (xml.get("when") == null) _Always else tools.EnumTools.fromString(ViceWhen, "_"+xml.get("when"));
		if (when == null)
			throw "Unsupported Vice 'when' "+xml.get("when");
		desc = tools.XmlTools.contentToString(xml.elementsNamed("desc").next());
		var event = tools.XmlTools.contentToString(xml.elementsNamed("event").next());
		ambiants = (event == null) ? [] : event.split("\n");
		if (xml.get("act") != null)
			act = new ViceAct(xml.get("act"), xml.elementsNamed("actText").next());
		var pc = xml.get("pcent");
		var reg = ~/^([0-9]+[\.,][0-9]+)%$/;
		if (pc == null || !reg.match(pc))
			return;
		var str = reg.matched(1);
		str = StringTools.replace(str, ",", ".");
		pcent = Std.parseFloat(str);
	}

	public function toString() : String {
		return name;
	}

	public function getAmbiant( ?seed:mt.Rand ) : String {
		if (ambiants == null)
			return null;
		return ambiants[ (seed != null ? seed.random : Std.random)(ambiants.length) ];
	}

	public static function list( s:String ) : List<Vice> {
		if (s == null || s == "" || s == ",")
			return new List();
		var n = s.split(",");
		n.pop();
		return Lambda.filter(
			Lambda.map(n, function(v) return Vice.getBySkey(v)),
			function(v) return v != null
		);
	}

	public static function random( n:Int, ?seed:mt.Rand ) : List<Vice> {
		var vices = new List();
		var avail : Array<Vice> = Lambda.array(ALL);
		for (i in 0...n){
			var v = avail.splice(seed == null ? Std.random(avail.length) : seed.random(avail.length), 1)[0];
			if (v == null)
				break;
			vices.push(v);
		}
		return vices;
	}
}

class ViceAct {
	public var label : String;
	public var pa : Int;
	public var money : Int;
	public var pcent : Float;

	public function new(act:String, x:Xml){
		var reg = ~/^([A-Za-z0-9_]+)\((.*?)\)$/;
		if (!reg.match(act))
			throw "Malformed ViceAct : "+act;
		var name = reg.matched(1);
		var params = reg.matched(2);
		var params = Lambda.map(params.split(","), function(p) return Std.parseFloat(p));
		if (params.length != 3)
			throw "Bad number of parameters for ViceAct : "+act;
		pa = Std.int(params.pop());
		money = Std.int(params.pop());
		pcent = params.pop();
		label = tools.XmlTools.contentToString(x);
	}
}