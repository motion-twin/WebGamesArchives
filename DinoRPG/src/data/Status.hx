package data;

typedef Status = {
	var id : String;
	var sid : Int;
	var desc : String;
	var timer : Bool;
}

class StatusXML extends haxe.xml.Proxy<"status.xml",Status> {

	public static function parse() {
		return new data.Container<Status,StatusXML>().parse("status.xml",function(id,sid,s) {
			return {
				id : id,
				sid : sid,
				desc : s.innerData,
				timer : s.has.timer,
			};
		});
	}

}
