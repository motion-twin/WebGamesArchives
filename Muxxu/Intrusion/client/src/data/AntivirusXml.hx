package data;
import Types;

private class AllData extends haxe.xml.Proxy<"../xml/antivirus.xml",Antivirus> {
}

class AntivirusXml {

	public static var ALL : Hash<Antivirus> = new Hash();
	public static var get : AllData = null;

	public static function init() {
		var raw = Manager.getEncodedXml("antivirus");
		var xml = Xml.parse(raw).firstElement();
		var h : Hash<Antivirus> = new Hash();
		for( x in xml.elements() ) {
			var k = x.get("id").toLowerCase();
			if( k == null )
				throw "Missing 'id' in antivirus.xml";
			if( h.exists(k) )
				throw "Duplicate id '"+k+"' in antivirus.xml";
			var data : Antivirus = {
				key		: k,
				diff	: Std.parseInt(x.get("diff")),
				minLevel: Std.parseInt(x.get("minLvl")),
				max		: if(x.exists("max")) Std.parseInt(x.get("max")) else 9999,
				desc	: x.firstChild().nodeValue,
				power	: if(x.exists("p")) Std.parseInt(x.get("p")) else 0,
			}
			h.set(k,data);
		}

		/*** force un seul Antivirus *
		for (av in h)
			if ( av.key!="syslock" && av.key!="passwd" )
				av.diff = 9999;
		/***/
		ALL = h;
		get = new AllData(ALL.get);
	}


	public static function check() {
		for (av in ALL) {
			if( av.power!=0 && Lang.TEXTS.get("AV_"+av.key)==null )
				throw "missing AV_"+av.key+" in Lang";
		}
	}


}
