package data;

typedef Effect = {
	var id : String;
	var eid : Int;
	var name : String;
	var desc : String;
	var icon : String;
	var hidden : Bool;
	var session : Bool;
}


class EffectXML extends haxe.xml.Proxy<"effects.xml",Effect> {

	public static function parse() {
		return new data.Container<Effect,EffectXML>().parse("effects.xml",function(id,iid,f) {
			return {
				id : id,
				eid : iid,
				name : f.att.name,
				desc : Tools.format(f.innerData),
				icon : if( f.has.icon ) f.att.icon else id,
				hidden : f.has.hidden || f.has.session,
				session : f.has.session,
			};
		});
	}

}
