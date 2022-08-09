package data;


typedef Updates = {
	var date : Date;
	var desc : String;
	var type : String;
}

class UpdatesXML extends haxe.xml.Proxy<"updates.xml",Updates> {

	public static function parse() {
		return new data.Container<Updates,UpdatesXML>(true, true).parse("updates.xml",function(id,_,u) {
			return {
				id 	 : id,
				date : Date.fromString(u.att.date),
				desc : StringTools.trim(u.innerHTML),
				type : StringTools.trim(u.att.type),
			};
		});
	}
}