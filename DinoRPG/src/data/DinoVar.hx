package data;

typedef DinoVar = {
	var id : String;
	var vid : Int;
	var desc : String;
	var temporary : Bool;
}

class DinoVarXML extends haxe.xml.Proxy<"dinovars.xml", DinoVar> {

	public static function parse() {
		return new data.Container<DinoVar, DinoVarXML>().parse("dinovars.xml",function(id,iid,v) {
			return {
				id : id,
				vid : iid,
				desc : Tools.format(v.innerData),
				temporary : v.has.temporary ? v.att.temporary == "1" : false,
			};
		});
	}
}
