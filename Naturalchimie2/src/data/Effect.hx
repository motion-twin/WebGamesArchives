package data;

typedef Effect = {
	var id : String ;
	var eid : Int ;
	var name : String ;
	var desc : String ;
	var icon : String ;
	var hidden : Bool ;
	var session : Bool ;
	var isMap : Bool ;
	var duration : Int ;
}


class EffectXML extends haxe.xml.Proxy<"effects.xml",Effect> {

	public static function parse() {
		return new data.Container<Effect,EffectXML>().parse("effects.xml",function(id,iid,f) {
			return {
				id : id,
				eid : iid,
				name : f.att.name,
				desc : Data.TEXTDESC.format(Tools.format(f.innerData)),
				icon : if( f.has.icon ) f.att.icon else id,
				duration : if (f.has.duration) Std.parseInt(f.att.duration) else null,
				hidden : f.has.hidden || f.has.session,
				session : f.has.session,
				isMap : false 
			};
		});
	}

}
