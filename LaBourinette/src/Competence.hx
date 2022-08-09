//
// TODO: Use the new mt.data.Mods to parse the docs/skills.ods file and get rid of the xml file.
//

import GameParameters;

private class Proxy extends haxe.xml.Proxy<"lang/fr/tpl/competences.xml",Competence> {
}

class Competence {
	public static var SALL : Hash<Competence>;
	public static var ALL = {
		#if neko
		var xml = Xml.parse(neko.io.File.getContent(Config.TPL+"competences.xml")).firstElement();
		#else
		var xml = Xml.parse(haxe.Resource.getString("competences.xml")).firstElement();
		#end
		Competence.SALL = new Hash();
		var h = new Hash();
		for (x in xml.elements()){
			var id = x.get("id");
			if (id == null)
				throw "Missing 'id' in competences.xml";
			if (h.exists(id))
				throw "Duplicate id '"+id+"' in competences.xml";
			var dbid = x.get("dbid");
			if (dbid == null)
				throw "Missing 'dbid' in competences.xml";
			if (dbid.charAt(0) == "-")
				continue;
			if (Competence.SALL.exists(dbid))
				throw "Duplicate dbid '"+dbid+"' in competences.xml";
			var c = new Competence(x);
			h.set(id, c);
			SALL.set(dbid, c);
		}
		h;
	}
	public static var get = new Proxy(ALL.get);
	public static function getById( id:String ) : Competence {
		return ALL.get(id);
	}
	public static function getByDbId( dbid:String ) : Competence {
		return SALL.get(dbid);
	}

	public var id : String;
	public var dbid : String;
	public var power : Int;
	public var charisma : Int;
	public var agility : Int;
	public var accuracy : Int;
	public var endurance : Int;
	public var icon : String;
	public var name : String;
	public var desc : String;
	public var pcent : Int;
	public var pen : Int;
	public var ambiants : Array<String>;
	public var pos : String;

	function new( xml:Xml ){
		id = xml.get("id");
		dbid = xml.get("dbid");
		power = if (xml.get("costPow") == null) 0 else Std.parseInt(xml.get("costPow"));
		charisma = if (xml.get("costCha") == null) 0 else Std.parseInt(xml.get("costCha"));
		agility = if (xml.get("costAgi") == null) 0 else Std.parseInt(xml.get("costAgi"));
		accuracy = if (xml.get("costAcc") == null) 0 else Std.parseInt(xml.get("costAcc"));
		endurance = if (xml.get("costEnd") == null) 0 else Std.parseInt(xml.get("costEnd"));
		var s = xml.get("pcent");
		var v = s == "*" ? 100 : Std.parseInt(s);
		pcent = (v == null) ? 100 : v;
		pen = Std.parseInt(xml.get("penal"));
		icon = id;
		name = xml.get("name");
		desc = childContent(xml, "desc");
		desc = StringTools.trim(desc);
		desc = StringTools.replace(desc, "\n", "<br/>");
		#if neko
		if (pen != null && pen != 0)
			desc += Text.format(Text.get.skill_fault, {pcent:pen});
		#end
		ambiants = childContent(xml, "ambiant").split("\n");
		pos = xml.get("sector");

	}

	public function canBetrigeredAtPos( p:Pos ){
		if (p == null || pos == "*")
			return pos == "*";
		switch (p){
			case Def(dp):
				switch (dp){
					case Thro: return pos == "D" || pos == "Thro";
					case DefL,DefM,DefR,DefF: return pos == "D" || pos == "Def" || pos == "Def/Att";
					case DSub: return false;
				}
			case Att(ap):
				switch (ap){
					case AttL,AttR: return pos == "A" || pos == "Att" || pos == "Def/Att";
					case Bat1,Bat2,Bat3: return pos == "A" || pos == "Bat";
					case ASub: return false;
				}
			case Bat:
				return pos == "Bat" || pos == "A";
		}
	}

	public function getAmbiant( ?seed:mt.Rand ) : String {
		return ambiants[ (seed != null ? seed.random : Std.random)(ambiants.length) ];
	}

	public function toString() : String {
		return id;
	}

	public static function list( str:String ) : List<Competence> {
		if (str == null || str == "" || str == ",")
			return new List();
		var l = str.split(",");
		l.pop();
		return Lambda.filter(
			Lambda.map(l, function(id) return Competence.getByDbId(id)),
			function(c) return c != null
		);
	}

	static function childContent( parent:Xml, nodeName:String ) : String {
		var children = parent.elementsNamed(nodeName);
		var buffer = new StringBuf();
		for (child in children)
			for (sub in child)
				buffer.add(sub.toString());
		return buffer.toString();
	}

	public static function stats(comps:Array<Competence>){
		var result = {
			att:0,
			def:0,
			any:0,
		};
		for (c in comps){
			switch (c.pos){
				case "*","Att/Def": result.any++;
				case "D","Def","Thro": result.def++;
				case "A","Att","Bat": result.att++;
			}
		}
		return result;
	}

	public static function randomForAtt(pos:AttPos, forceSpecial:Bool, ?seed, notIn){
		var comp = Lambda.list(ALL);
		comp = comp.filter(function(c) return !Lambda.has(notIn,c));
		var common = comp.filter(function(c){
			return c.pos == "*";
		});
		var special = comp.filter(function(c){
			switch (pos){
				case Bat1,Bat2,Bat3: return c.pos == "Bat";
				case AttL,AttR: return c.pos == "A" || c.pos == "Att" || c.pos == "Def/Att";
				case ASub: return false;
			}
		});
		var table = Lambda.array(special);
		if (!forceSpecial)
			table = table.concat(Lambda.array(common));
		return table[(seed != null ? seed.random(table.length) : Std.random(table.length))];
	}

	public static function randomForDef(pos:DefPos, forceSpecial:Bool, ?seed, notIn){
		var comp = Lambda.list(ALL);
		comp = comp.filter(function(c) return !Lambda.has(notIn,c));
		var common = comp.filter(function(c){
			return c.pos == "*";
		});
		var special = comp.filter(function(c){
			switch (pos){
				case Thro: return c.pos == "Thro";
				case DefL,DefM,DefR,DefF: return c.pos == "D" || c.pos == "Def" || c.pos == "Def/Att";
				case DSub: return false;
			}
		});
		var table = Lambda.array(special);
		if (!forceSpecial)
			table = table.concat(Lambda.array(common));
		while (table.remove(null)){}
		if (table.length == 0)
			throw "cannot find any competence for "+pos+" not in "+notIn;
		return table[(seed != null ? seed.random(table.length) : Std.random(table.length))];
	}
}