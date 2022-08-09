package data;

typedef Object = {
	var id : String;
	var oid : Int;
	var name : String;
	var desc : String;
	var max : Int;
	var effect : Null<String>;
	var fight : Null<{ proba : Int, priority : Int }>;
	var trade : Null<Int>;
	var lock : Bool;
	var icon:String;
	var limit:Null<Int>;
	var family:Null<String>;
}

class ObjectXML extends haxe.xml.Proxy<"objects.xml",Object> {

	public static function parse() {
		return new data.Container<Object,ObjectXML>(true).parse("objects.xml",function(id,iid,o) {
			var fight = null;
			var max = Std.parseInt(o.att.max);
			var desc = Tools.format(o.node.desc.innerData);
			if( o.hasNode.fight ) {
				var f = o.node.fight;
				fight = {
					proba : Std.parseInt(f.att.proba),
					priority : Std.parseInt(f.att.priority),
				}
			}
			return {
				id : id,
				oid : iid,
				name : o.att.name,
				desc : desc,
				max : max,
				effect : if( o.hasNode.effect ) Tools.format(o.node.effect.innerData) else null,
				fight : fight,
				trade : if( o.has.trade ) Std.parseInt(o.att.trade) else null,
				lock : o.has.lock,
				icon : if ( o.has.icon ) o.att.icon else id,
				limit : if ( o.has.limit ) Std.parseInt(o.att.limit) else null,
				family : if( o.has.family ) o.att.family else null,
			};
		});
	}
}

