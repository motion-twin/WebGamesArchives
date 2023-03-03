import tools.Utils;
import Common;

private class AllRewards extends haxe.xml.Proxy<"tpl/fr/goals.xml", GhostRewardData> {
}

class GR {

	public static var ILIST : IntHash<GhostRewardData>  = new IntHash();
	public static var LIST : Hash<GhostRewardData> = {
		var xml = new haxe.xml.Fast( Xml.parse(neko.io.File.getContent(Config.TPL+"goals.xml")).firstElement() );
		var h = new Hash();
		for( r in xml.nodes.goal ) {
			var id = r.att.id;
			if( id == null )
				throw "Missing 'id' in ghost_rewards.xml";
			if( h.exists(id) )
				throw "Duplicate id '"+id+"' in ghost_rewards.xml";
			var data : GhostRewardData = {
				key		: id,
				ikey	: mt.db.Id.encode(id),
				name	: r.att.name,
				rare	: r.has.rare && r.att.rare != "0",
				desc	: if(r.has.desc) r.att.desc else "",
				critical: if(r.has.hordes_critical && r.att.hordes_critical!="0") true else false,
				levels	: new List(),
			}
			for( t in r.nodes.title ) {
				data.levels.add({
					name	: t.att.name,
					min		: Std.parseInt(t.att.k),
				});
			}
			h.set(id, data);
			ILIST.set(data.ikey, data);
		}
		h;
	}

	public static var get = new AllRewards(LIST.get);

	public static function getById(k) {
		var v = ILIST.get(k);
		if( v == null ) {
			throw("Invalid reward key '"+k+"' !");
			return null;
		}
		return v;
	}

	public static function getByKey(k) {
		var v = LIST.get(k);
		if( v == null ) {
			throw("Invalid reward key '"+k+"' !");
			return null;
		}
		return v;
	}
}
