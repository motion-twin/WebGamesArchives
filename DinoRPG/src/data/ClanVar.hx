package data;

typedef ClanVar = {
	var id : String;
	var vid : Int;
	var desc : String;
	var temporary : Bool;
}

class ClanVarXML extends haxe.xml.Proxy<"clanvars.xml", ClanVar> {

	public static function parse() {
		return new data.Container<ClanVar, ClanVarXML>().parse("clanvars.xml",function(id,iid,v) {
			return {
				id : id,
				vid : iid,
				desc : Tools.format(v.innerData),
				temporary : v.has.temporary ? v.att.temporary == "1" : false,
			};
		});
	}
}
