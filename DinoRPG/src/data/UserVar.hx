package data;

typedef UserVar = {
	var id : String;
	var vid : Int;
	var desc : String;
	var temporary : Bool;
}

class UserVarXML extends haxe.xml.Proxy<"uservars.xml", UserVar> {

	public static function parse() {
		return new data.Container<UserVar,UserVarXML>().parse("uservars.xml",function(id,iid,v) {
			return {
				id : id,
				vid : iid,
				desc : Tools.format(v.innerData),
				temporary : v.has.temporary ? v.att.temporary == "1" : false,
			};
		});
	}
	
}
