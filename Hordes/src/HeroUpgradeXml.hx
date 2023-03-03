import tools.Utils;
import Common;

private class AllUpgrades extends haxe.xml.Proxy<"home.xml",HUpgrade> {
}

class HeroUpgradeXml {

	public static var LIST : Hash<HUpgrade> = {
		var xml = new haxe.xml.Fast( Xml.parse(neko.io.File.getContent(Config.XML_PATH+"home.xml")).firstElement() );
		var h = new Hash();
		for (r in xml.nodes.u){

			var key = r.att.key;
			if (key == null)
				throw "Missing 'key' in home.xml";

			if (h.exists(key))
				throw "Duplicate key '"+key+"' in home.xml";

			var reqs : List<HomeUpgradeReqs> = new List();
			if( r.has.reqs ) {
				reqs = extractReqs( r.att.reqs );
			}

			var levels : List<HUpgradeLevel> = new List();
			for (l in r.nodes.l) {
				var reqs : List<HomeUpgradeReqs> = new List();

				if( l.has.reqs ) {
					reqs = extractReqs( l.att.reqs );
				}

				levels.add({
					pa		: if( l.has.pa ) Std.parseInt( l.att.pa ) else 0,
					def		: if( l.has.def ) Std.parseInt( l.att.def ) else 0,
					cap		: if( l.has.cap ) Std.parseInt( l.att.cap ) else 0,
					limit	: if( l.has.limit ) Std.parseInt( l.att.limit ) else 1,
					lock	: if( l.has.lock ) true else false,
					hide	: if( l.has.hide ) true else false,
					alarm	: if( l.has.alarm ) true else false,
					desc	: if( l.has.desc ) l.att.desc else "",
					reqs	: reqs,
				});
			}

			var currentLevelInfo = {
					pa		: if( r.has.pa ) Std.parseInt( r.att.pa ) else 0,
					def		: if( r.has.def ) Std.parseInt( r.att.def ) else 0,
					cap		: if( r.has.cap ) Std.parseInt( r.att.cap ) else 0,
					limit	: if( r.has.limit ) Std.parseInt( r.att.limit ) else 1,
					lock	: if( r.has.lock ) true else false,
					alarm	: if( r.has.alarm ) true else false,
					hide	: if( r.has.hide ) true else false,
					desc	: if( r.has.desc ) r.att.desc else "",
					reqs	: reqs,
				};

			var data : HUpgrade = {
				key		: key,
				ikey	: mt.db.Id.encode(key),
				level	: currentLevelInfo,
				name	: if(r.has.name) r.att.name else "",
				desc	: if(r.has.desc) r.att.desc else "",
				icon	: if(r.has.icon) r.att.icon else "",
				actName	: if(r.has.actName) r.att.actName else "",
				levels	: levels
			}
			h.set(key,data);
		}
		h;
	}

	private static function extractReqs( r ) {
		var reqs = new List();
		if( r == null || StringTools.trim( r ) == ""  || r.length <=0 )
			return reqs;

		var infos = r.split(";");
		for( info in infos ) {
			var i = info.split(":");
			if( i!= null && i.length >0  ) {
				var a = Lambda.array(i);
				if( a[0] == null ) continue;
				if( a[1] == null ) continue;
				reqs.add( { key : Std.string( a[0] ), n : Std.parseInt( a[1] ) } );
			}
		}
		return reqs;
	}

	public static var get = new AllUpgrades(LIST.get);

	public static function hasEnoughPa( upgrade : HUpgrade = null, level, userPa ) {
		var l = getLevel( upgrade, level );
		if( l == null )
			throw "problem!";

		return userPa > l.pa;
	}

	public static function hasAllReqs( upgrade : HUpgrade = null, level, tools : List<db.Tool>  ) {
		var l = getLevel( upgrade, level );
		if( l == null ) return false;
		if( l.reqs.length <= 0 ) return true;

		for( r in l.reqs ) {
			var found = 0;
			var rt = XmlData.getToolByKey( r.key );
			for( t in tools ) {
				if( t.key == rt.key )
					found++;
			}
			if( found < r.n ) return false;
		}
		return true;
	}

	private static function getLevel(upgrade : HUpgrade = null, level:Int ) {
		if( upgrade == null )
			return null;


		var currentLevel = null;
		if( level <= 0 )
			return upgrade.level;
		else {
			if(upgrade.levels.length <= 0 ) // ne devrait bien entendu jamais arriver...
				return null;

			var i = 0;
			for( l in upgrade.levels ) {
				if( i++ == level ) {
					return l;
				}
			}
		}

		return null;
	}

	public static function getCurrentLevel(upgrade : HUpgrade = null, dbLevel:Int ) {
		if( upgrade == null )
			return null;
		if ( dbLevel<=1 ) return upgrade.level;
		var n=2;
		for (l in upgrade.levels) {
			if ( n==dbLevel ) return l;
			n++;
		}
		return null;
	}


	public static function getByKey(k) {
		var v = LIST.get(k);
		if ( v==null ) {
			return null;
		}
		return v;
	}

	public static function getAll() {
		var lst = new List();
		for( k in LIST.keys() ) {
			lst.add( LIST.get( k ) );
		}
		return lst;
	}
}
