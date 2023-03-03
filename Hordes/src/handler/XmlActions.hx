package handler;
import db.User;
import db.Map;
import db.Expedition;
import db.NewsInfo;
import db.XmlCache;
import Common;

enum XmlTypes {
	T_Int;
	T_Float;
	T_String;
	T_Bool;
	T_Date;
}

class XmlActions extends Handler<Void>{
	public static var VERSION_MAIN	: Int	= 2;
	public static var VERSION_SUB	: Int	= 171;
	static var DTD_ATT : Hash<String> = new Hash();
	static var DTD_NODES : Hash<List<String>> = new Hash();

	public function new() {
		super();

		free( "default",		doDefault );
		free( "ghost",			doGhost );
		free( "changelog",		doChangelog );
		free( "status",			doStatus );

		free( "city",			doDisabled );
		free( "citizens",		doDisabled );
		free( "bank",			doDisabled );
		free( "map",			doDisabled );
		free( "exp",			doDisabled );

	}

	function fail(str:String,?fl_noUser:Bool) {
		var doc = createBase(fl_noUser);
		var error = createChild(doc, "error");
		addAttribute( error, T_String, "code", str, "name of the error" );
		addChildDtd( doc, getXmlStatus() );
		App.sendXml(doc);
	}

	function boolToStr(b:Bool):String {
		return if( b == true ) "1" else "0";
	}

	function createChild(root:Xml, name:String){
		var c = Xml.createElement(name);
		addChildDtd(root,c);
		return c;
	}

	function createChildWithCdata(root:Xml, name:String, content:String){
		var e = Xml.createElement(name);
		var c = Xml.createCData( makeCData(content) );
		e.addChild(c);
		addChildDtd(root,e);
		return e;
	}


	function createBase(?map:Map,?fl_noUser:Bool) {
		var doc = Xml.createElement("hordes");
		doc.set( "xmlns:content", "http://purl.org/rss/1.0/modules/content/");
		doc.set( "xmlns:dc", "http://purl.org/dc/elements/1.1");
		addChildDtd(doc, getXmlHeaders(map,fl_noUser));
		return doc;
	}

	function createData(?date:Date, fastCache:Bool) {
		var doc = Xml.createElement("data");
		if( db.GameMod.hasMod("XML_CACHE") ) {
			if( date == null ) date = Date.now();
			addAttribute( doc, T_Date,		"cache-date",	date.toString(), true, "generation date & time of this XML (can be missing if the XML cache is deactivated)" );
			addAttribute( doc, T_Bool,		"cache-fast",	fastCache, true, "value is 1 if the refresh rate is set to 'Fast' ("+Const.get.XmlSlowCache+" min)" );
		}
		return doc;
	}

	function addComment(xml, str) {
		if( !isDocMode() ) return;
		var cxml = Xml.createComment(str);
		xml.addChild(cxml);
	}

	function addAttribute( xml:Xml, xtype:XmlTypes, name:String, value:Dynamic, ?optional:Bool, ?infos:String="" ) {
		if(infos != "") infos = " ("+infos+")";
		infos = cleanUp(infos);

		var comment = "ATTRIBUTE "+name+" ("+xtype+") "+(if(optional) "OPTIONAL " else "")+infos;
		if( isDocMode() ) {
			var key = xml.nodeName+" "+name;
			var newValue = "____ "+comment;
			if( DTD_ATT.get(key)==null || DTD_ATT.get(key).length<newValue.length ) {
				DTD_ATT.set( key, newValue );
			}
		}

		if( isDocMode() )
			xml.set(name, getTypeDesc(xtype)+(if(optional) " [optional]" else "")+infos);
		else
			if( !(value == null && optional) )
				switch(xtype) {
					case T_Bool		: xml.set(name, boolToStr(value));
					case T_String	: xml.set(name, cleanUp(value));
					default			: xml.set(name, value);
				}
	}


	function addChildDtd(parent:Xml, child:Xml) {
		if( isDocMode() ) {
			if( DTD_NODES.get(parent.nodeName)==null ) {
				DTD_NODES.set(parent.nodeName, new List());
			}

			if( DTD_NODES.get(child.nodeName)==null ) {
				DTD_NODES.set(child.nodeName, new List());
			}

			var fl_found = false;
			for( n in DTD_NODES.get(parent.nodeName) ) {
				if( n == child.nodeName ) {
					fl_found = true;
					break;
				}
			}
			if( !fl_found ) DTD_NODES.get(parent.nodeName).add(child.nodeName);
		}
		parent.addChild(child);
	}


	function makeCData(str:String) {
		if( str == null ) {
			return "";
		} else {
			if( isDocMode() ) {
				return " .....CDATA..... ";
			} else {
				return str;
			}
		}
	}

	function getVersion() {
		return VERSION_MAIN+"."+VERSION_SUB;
	}

	function isSecureRequest(?key:String) {
		if( key != null )
			return db.Site.isSecureKey(key);
		else
			return db.Site.isSecureKey(App.request.get("k"));
	}

	function isDocMode() {
		return App.request.exists("comment");
	}

	function getUser() : User {
		if( !App.request.exists("k") ) {
			fail("missing_key",true);
			return null;
		}
		var k = App.request.get("k");
		var user = null;
		if( isSecureRequest(k) ) {
			var sk = App.request.get("sk");
			if( sk == null ) {
				fail("site_key_required_for_secure_key", true);
				return null;
			}
			var userId = db.Site.getUserId(k);
			user = User.manager.get(userId, false);
			if( db.Site.getSecureKey(user, sk) != k ) {
				fail("invalid_keys", true);
				return null;
			} else {
				return user;
			}
		} else {
			user = User.manager.getByApiKey(k);
			if( user == null ) {
				fail("user_not_found", true);
				return null;
			}
		}
		return user;
	}

	function getMap(?u:User) {
		if( u == null ) u = getUser();
		if( u == null ) return null;

		var map = db.Map.manager.get( u.mapId, false );
		if( map == null ) {
			fail("not_in_game");
			return null;
		}

		return map;
	}

	function cleanUp(str) {
		if( str==null ) return "";
		str = StringTools.replace(str,'"',"'");
		return StringTools.htmlEscape(str);
	}

	function getTypeDesc(xtype:XmlTypes) : String {
		switch (xtype) {
			case T_Int		: return "Int";
			case T_Float	: return "Float";
			case T_String	: return "String";
			case T_Bool		: return "1/0";
			case T_Date		: return "Date (YYYY-MM-DD hh:mm:ss)";
		}
	}

	/*------------------------------------------------------------------------
	ACTION HANDLERS
	------------------------------------------------------------------------*/

	function doDefault() {
		if( !db.GameMod.hasMod("XML") ) {
			fail("xml_disabled",true);
			return;
		}

		if( App.HORDE_ATTACK ) {
			fail("horde_attacking",true);
			return;
		}

		if( App.MAINTAIN ) {
			fail("maintain",true);
			return;
		}

		var useFastCache = false;
		var site = null;
		if( App.request.exists( "sk" ) ) {
			var key = App.request.get( "sk" );
			site = db.Site.manager.getSiteByKey( key );
			if( site != null )
				useFastCache = true;
		}

		var user = getUser();
		if( user == null ) return;
		var map = getMap(user);
		if( map == null ) return;

//		db.SiteStat.create( if(site!=null) site.id else null, map.id, neko.Web.getClientHeader( "X-Referer" ));

		var cache = if(isDocMode()) null else XmlCache.manager.getCache("map"+map.id, useFastCache, getVersion());
		if( cache != null ) {
			var dataDoc = cache.getXml();
			dataDoc.set( "cache-fast", boolToStr(useFastCache) );
			var fullDoc = createBase(map);
			addChildDtd(fullDoc, dataDoc);
			App.sendXml(fullDoc);
		} else {
			var dataDoc = createData(useFastCache);
			addChildDtd( dataDoc, getXmlCity(map) );
			addChildDtd( dataDoc, getXmlBank(map) );
			addChildDtd( dataDoc, getXmlExp(map) );
			addChildDtd( dataDoc, getXmlCitizens(map) );
			addChildDtd( dataDoc, getXmlCadavers(map) );
			addChildDtd( dataDoc, getXmlMap(map) );
			if( !map.isHardcore() ) {
				addChildDtd( dataDoc, getXmlUpgrades(map) );
				addChildDtd( dataDoc, getXmlEstim(map,user) );
			}
			// puts data into cache
			if( !isDocMode() )
				XmlCache.create("map"+map.id, dataDoc, useFastCache, getVersion());

			var fullDoc = createBase(map);
			addChildDtd( fullDoc, dataDoc );

//			if( isDocMode() ) {
//				addComment( fullDoc, getDoc() );
//			}
			App.sendXml( fullDoc );
		}
	}


	function doGhost() {
		if( !db.GameMod.hasMod("XML") ) {
			fail("xml_disabled", true);
			return;
		}

		if( App.HORDE_ATTACK ) {
			fail("horde_attacking", true);
			return;
		}

		var site = null;
		if( App.request.exists("sk") ) {
			var key = App.request.get("sk");
			site = db.Site.manager.getSiteByKey( key );
		}

		var user = getUser();
		if( user == null ) return;
		var map = getMap(user);
		if( map == null ) return;

		if( !isSecureRequest()  && !App.DEBUG ) {
			fail("only_available_to_secure_request");
			return;
		}

		var cache = if( isDocMode() ) null else XmlCache.manager.getPermanentCache("ghost"+user.id, getVersion());
		if( cache != null ) {
			var dataDoc = cache.getXml();
			dataDoc.set( "cache-fast", boolToStr(false) );
			var fullDoc = createBase(map);
			addChildDtd(fullDoc, dataDoc);
			App.sendXml(fullDoc);
		} else {
			var dataDoc = createData(false);
			addChildDtd( dataDoc, getXmlRewards(user) );
			addChildDtd( dataDoc, getXmlPlayedMaps(user) );
			// puts data into cache
			if( !isDocMode() )
				XmlCache.create("ghost"+user.id, dataDoc, false, getVersion());
			var fullDoc = createBase(map);
			addChildDtd( fullDoc, dataDoc );
			App.sendXml( fullDoc );
		}
	}

	function doStatus() {
		if( !db.GameMod.hasMod("XML") ) {
			fail("xml_disabled",true);
			return;
		}
		var doc = createBase(true);
		addChildDtd( doc, getXmlStatus() );
		App.sendXml(doc);
	}

	function doChangelog() {
		App.sendText("xmlChangelog.txt");
	}

	function doDisabled() {
		fail("this_sub_xml_has_been_disabled",true);
	}

	/*------------------------------------------------------------------------
	XML GETTERS
	------------------------------------------------------------------------*/

	function getDoc() {
		var finalDtd = new List();
		for( node in DTD_NODES.keys() ) {
			var list = DTD_NODES.get(node);
			finalDtd.add( "NODE " + node + (if(list.length>0) " CONTAINS NODE"+(if(list.length>1) "S" else "")+" : "+list.join(", ") else "") );
			for( a in DTD_ATT.keys() ) {
				if( a.split(" ")[0] == node ) {
					finalDtd.add(DTD_ATT.get(a));
				}
			}
		}
		return finalDtd.join("\n");
	}

	function getXmlHeaders(?map:Map, ?fl_noUser:Bool) {
		var xml_headers = Xml.createElement("headers");
		addAttribute(xml_headers, T_String,	"link",			App.URL+"/xml" );
		addAttribute(xml_headers, T_String,	"author",		"Motion Twin <http://www.motion-twin.com>" );
		addAttribute(xml_headers, T_String,	"generator",	"haxe" );
		addAttribute(xml_headers, T_String,	"language",		App.LANG );
		addAttribute(xml_headers, T_Float,	"version",		getVersion() );
		addAttribute(xml_headers, T_String,	"iconurl",		App.IMG+"/gfx/icons/", "base URL for all images (items, buildings...), don't forget to append '.gif'." );
		addAttribute(xml_headers, T_String,	"avatarurl",	App.IMGUP_URL, "base URL for users avatars" );
		addAttribute(xml_headers, T_Bool,	"secure",		isSecureRequest(), "value is 1 if this XML uses secure mode" );

		if( !fl_noUser && isSecureRequest() ) {
			var user = getUser();
			if( user!=null )
				addChildDtd( xml_headers, getXmlOwner(user, map) );
		} else
			addComment(xml_headers, "optional : owner node in secure XML mode");

		if( map != null )
			addChildDtd( xml_headers, getXmlGame(map) );
		else
			addComment(xml_headers, "optional : game node if this player is in a city");

		return xml_headers;
	}

	function getXmlOwner(user:User, map:Map) {
		var xml  = Xml.createElement("owner");
		addChildDtd( xml, getXmlOneCitizen(map, user) );
		if( user.isPlaying() && map != null && !map.isHardcore() && !map.chaos )
			addChildDtd( xml, getXmlZone( user, map, user.getZoneForDisplay() ) );
		return xml;
	}

	function getXmlGame(map:Map) {
		var xml  = Xml.createElement("game");
		addAttribute(xml, T_Int,	"id",			map.id );
		addAttribute(xml, T_Int,	"days",			map.days );
		addAttribute(xml, T_Date,	"datetime",		Date.now() );
		addAttribute(xml, T_Bool,	"quarantine",	map.isQuarantined() );
		return xml;
	}

	function getXmlCitizens(map:Map) {
		var xml_citizens = Xml.createElement("citizens");
		for( u in User.manager.getMapUsers(map, false, false) ) {
			addChildDtd( xml_citizens, getXmlOneCitizen(map, u) );
		}
		return xml_citizens;
	}

	function getXmlOneCitizen(map:Map, u:User) {
		var zone = u.getZoneForDisplay();
		var xml_citizen = Xml.createElement("citizen");
		var c = Xml.createCData( makeCData(u.homeMsg) );
		xml_citizen.addChild(c);
		addAttribute(xml_citizen, T_Int,	"id",		u.id );
		addAttribute(xml_citizen, T_String,	"name",		u.name );
		if( u.isPlaying() ) {
			if( !map.chaos ) {
				addAttribute(xml_citizen, T_Int,	"x",		zone.x, true, "missing if in CHAOS mode" );
				addAttribute(xml_citizen, T_Int,	"y",		zone.y, true, "missing if in CHAOS mode" );
			}
			addAttribute(xml_citizen, T_String,	"job",		if( u.jobId!= null ) u.job.key else "" );
			addAttribute(xml_citizen, T_Bool,	"out",		u.isOutside, "value is 1 if the citizen is outside the city" );
			addAttribute(xml_citizen, T_Int,	"baseDef",	u.getHome().def );
			addAttribute(xml_citizen, T_Bool,	"ban",		u.isCityBanned);
		}
		addAttribute(xml_citizen, T_String,	"avatar",	u.avatar, true, "don't forget to use the URL provided in the header" );
		addAttribute(xml_citizen, T_Bool,	"hero",		u.hero );
		if( !App.HORDE_ATTACK ) {
			addAttribute(xml_citizen, T_Bool,	"dead",		u.dead );
		}
		return xml_citizen;
	}

	function getXmlCadavers(map:Map) {
		var xml_cadavers = Xml.createElement("cadavers");
		for( c in map.getAllCadavers() ) {
			var xml_cadaver = createChild(xml_cadavers,"cadaver");
			addAttribute(xml_cadaver, T_Int,	"id",		c.userId );
			addAttribute(xml_cadaver, T_String,	"name",		c.name );
			addAttribute(xml_cadaver, T_Int,	"day",		c.mapDay );
			addAttribute(xml_cadaver, T_Int,	"dtype",	c.deathType, "death reason" );
			if( c.garbaged != null || c.watered != null ) {
				var clean = createChild(xml_cadaver,"cleanup");
				if( c.garbaged != null ) {
					addAttribute(clean, T_String,	"user",	c.garbaged );
					addAttribute(clean, T_String,	"type",	"garbage", "possible values : {garbage, water}" );
				}
				if( c.watered != null ) {
					addAttribute(clean, T_String,	"user",	c.watered );
					addAttribute(clean, T_String,	"type",	"water", "possible values : {garbage, water}" );
				}
			} else {
				addComment( xml_cadaver, "optional : cleanup node if this cadaver was garbaged");
			}
			var msg = createChildWithCdata(xml_cadaver,"msg", c.deathMessage);
			addComment(msg, "Death message");
		}
		return xml_cadavers;
	}

	function getXmlBank(map:Map) {
		var xml = Xml.createElement("bank");
		for( node in getXmlItems(map._getCity().getItems()) )
			addChildDtd( xml, node );
		return xml;
	}
	
	function getXmlCity(map:Map) {
		var xml = Xml.createElement("city");
		addAttribute( xml,	T_String,	"city",		map.name );
		addAttribute( xml,	T_Int,		"water",	map.water );
		var city = map._getCity();
		addAttribute( xml,	T_Int,		"x",		city.x );
		addAttribute( xml,	T_Int,		"y",		city.y );
		addAttribute( xml,	T_Bool,		"door",		map.getDoorOpened(), "1 if the door is CLOSED" );
		addAttribute( xml,	T_Bool,		"chaos",	map.chaos, "1 if in CHAOS MODE" );
		if( db.GameMod.hasMod("CAMP") )
			addAttribute( xml,	T_Bool,		"devast",	map.devastated, "1 if in DEVASTATED MODE" );
		if( db.GameMod.hasMod("HARDCORE") )
			addAttribute( xml,	T_Bool,		"hard",		map.isHardcore(), "1 if in HARDCORE MODE" );

		// chantiers
		if( !map.isHardcore() ) {
			var buildings = db.CityBuilding.manager.getDoneBuildings(map);
			if( buildings.length==0 ) {
				addComment( xml, "optional : many building nodes (one for each completed building)" );
			}
			for (b in buildings) {
				var binfos = b.getInfos();
				var xml_building = createChildWithCdata(xml,"building", binfos.description );
				addAttribute( xml_building,	T_Int,		"id",		binfos.id );
				addAttribute( xml_building,	T_String,	"name",		binfos.name );
				addAttribute( xml_building,	T_String,	"img",		binfos.icon );
				var parent = binfos.getParent();
				addAttribute( xml_building,	T_Int,		"parent",	if(parent!=null) parent.id else null, true, "parent building ID (the one required to build this one)" );
				addAttribute( xml_building,	T_Bool,		"temporary",	binfos.temporary, "value is 1 if this building is to be destroyed during next attack" );
			}
		}

//		if( map.version<20 ) { // TODO : bientôt obsolète !
//			var m1 = db.CityBuilding.manager.hasBuilding( XmlData.getBuildingByKey("mirador").id, map._getCity() );
//			var m2 = db.CityBuilding.manager.hasBuilding( XmlData.getBuildingByKey("mirador2").id, map._getCity() );
//			var xml_est = createChild(xml,"estimation");
//			if( m1 || m2 ) {
//				addAttribute( xml_est,	T_Int,		"z",		map.getAttackEstimationNoCache(m1,m2).z );
//			}
//		}

		var news = NewsInfo.manager.getLast(map.id);
		if( news!=null ) {
			var xml_news = createChild(xml,"news");
			addAttribute( xml_news,	T_Int,		"z",		news.zombiesCount );
			addAttribute( xml_news,	T_Int,		"def",		news.def, "value is 0 if the doors were open" );
			createChildWithCdata(xml_news,"content",news.article);
//			var xml_out = createChildWithCdata(xml_news,"outside","soon...");  // TODO
//			var xml_in = createChildWithCdata(xml_news,"intown","soon..."); // TODO
		}
		else {
			addComment( xml, "optional : news node (contains the CITY daily news if it exists)" );
		}

		if( !map.isHardcore() ) {
			var xml_def = createChild(xml,"defense");
			var items = db.ZoneItem.manager._getZoneItems( city, false );
			var bhash = db.CityBuilding.manager.getDoneBuildingsHash(map);
			var def = map.getCityDefense(items, bhash);
			addAttribute( xml_def,	T_Int,		"total",		def.total );
			addAttribute( xml_def,	T_Int,		"base",			Const.get.BaseDefense, "base city defense" );
			addAttribute( xml_def,	T_Int,		"buildings",	def.buildings, "buildings (base value, not modified by daily upgrades)" );
			addAttribute( xml_def,	T_Int,		"upgrades",		def.upgradeInfos.total, "bonus provided by daily upgrades" );
			addAttribute( xml_def,	T_Int,		"items",		def.itemInfos.items, "defense items count (not their value)" );
			addAttribute( xml_def,	T_Float,	"itemsMul",		def.itemInfos.mul, "defense items multiplier");
			addAttribute( xml_def,	T_Int,		"citizen_homes",		def.userInfos.homes, "personal houses + personal improvements" );
			addAttribute( xml_def,	T_Int,		"citizen_guardians",	def.userInfos.guards, "guardians bonus" );
		}

		return xml;
	}


	function getXmlMap(map:Map) {
		var xml_map = Xml.createElement("map");
		addAttribute( xml_map,	T_Int,		"wid",	map.width );
		addAttribute( xml_map,	T_Int,		"hei",	map.width );
		
		addAttribute( xml_map, T_Int, "bonusPts", map.getVarValue("extraPoints") );
		
		xml_map.set( "wid", Std.string(map.width) );
		xml_map.set( "hei", Std.string(map.width) );
		xml_map.set( "bonusPts", Std.string(map.getVarValue("extraPoints")) );
		
		var fl_betterMap = map.hasCityBuilding("betterMap");
		var zones = map.getKnownZones(false);
		for( zone in zones ) {
			var xml_zone = createChild(xml_map, "zone");
			addAttribute( xml_zone,	T_Int,		"x",	zone.x );
			addAttribute( xml_zone,	T_Int,		"y",	zone.y );
			addAttribute( xml_zone,	T_Int,		"tag",	if(zone.infoTag>0) zone.infoTag else null, true, "zone tag" );
			if( zone.tempChecked && zone.zombies>0 ) {
				if( fl_betterMap )	{
					addAttribute( xml_zone,	T_Int,		"z",	zone.zombies, "zombie count" );
					xml_zone.set( "z", Std.string(zone.zombies) );
				} else {
					var seed = map.id+zone.x+zone.y*map.width;
					addAttribute( xml_zone,	T_Int,		"danger",	MapCommon.zombieDanger(seed,zone.zombies,false)+1, "zombie count estimation" );
				}
			}
			addAttribute( xml_zone,	T_Bool,		"nvt",	!zone.tempChecked, "value is 1 was already discovered, but Not Visited Today" );
			if( zone.type>1 ) {
				if( zone.diggers>0 ) {
					var bdata = XmlData.getOutsideBuilding(zone.type, true);
					var desc = createChild(xml_zone,"building");
					addAttribute( desc,	T_Int,		"type",	-1, "value is -1 if this building is buried" );
					addAttribute( desc,	T_String,	"name",	Text.get.UndiggedBuilding );
					addAttribute( desc,	T_Int,		"dig",	zone.diggers, "remaining 'dig' actions to reveal this building" );
				} else {
					var bdata = XmlData.getOutsideBuilding(zone.type, true);
					if( bdata != null ) {
						var desc = createChildWithCdata(xml_zone,"building",bdata.description);
						addAttribute( desc,	T_Int,		"type",	zone.type, "value is -1 if this building is buried" );
						addAttribute( desc,	T_String,	"name",	bdata.name );
						addAttribute( desc,	T_Int,		"dig",	zone.diggers, "remaining 'dig' actions to reveal this building" );
					}
				}
			} else {
				addComment( xml_zone, "optional : building node if there is a building in this sector" );
			}
		}
		return xml_map;
	}

	function getXmlExp(map:Map) {
		var xml = Xml.createElement("expeditions");
		var elist = Expedition.manager.getByMapId(map);
		if( elist.length==0 ) {
			addComment( xml, "optional : expedition nodes (one for each expedition)" );
		}
		for (e in elist) {
			var xml_exp = createChild(xml,"expedition");
			addAttribute( xml_exp,	T_String,	"name",		e.name );
			addAttribute( xml_exp,	T_Int,		"authorId",	e.userId );
			addAttribute( xml_exp,	T_String,	"author",	e.user.name );
			addAttribute( xml_exp,	T_Int,		"length",	e.getLength() );
			var ef = e.getFullPath(true);
			if( ef != null ) {
				for (pt in e.getFullPath(true)) {
					var xml_coord = createChild(xml_exp,"point");
					addAttribute( xml_coord,	T_Int,	"x",		pt.x );
					addAttribute( xml_coord,	T_Int,	"y",		pt.y );
				}
			}
		}
		return xml;
	}
	
	function getXmlUpgrades(map:Map) {
		var xml = Xml.createElement("upgrades");
		var ups = db.CityUpgrade.manager.getUpgrades(map);
		var total = 0;
		if( ups.length==0 ) {
			addComment( xml, "optional : up nodes (one for each daily upgrade)" );
		}
		for (up in ups) {
			var xml_up = createChildWithCdata(xml, "up", up.getDesc() );
			var b = up.getBuilding();
			addAttribute( xml_up,	T_Int,		"buildingId",	b.id );
			addAttribute( xml_up,	T_String,	"name",			b.name );
			addAttribute( xml_up,	T_Int,		"level",		up.level );
			total += up.level;
		}
		addAttribute( xml,	T_Int,	"total",		total, "number of voted daily upgrades" );
		return xml;
	}
	
	function getXmlEstim(map:Map,user:User) {
		var xml = Xml.createElement("estimations");
		var fl_none = true;
		if( user.hasCityBuilding("tower") ) {
			var eData= CityActions.getEstim(map,user);
			if( !eData.tooLow ) {
				var exml = createChild(xml, "e");
				addAttribute( exml,	T_Int,	"day",		map.days );
				addAttribute( exml,	T_Int,	"min",		eData.estim.min );
				addAttribute( exml,	T_Int,	"max",		eData.estim.max );
				addAttribute( exml,	T_Bool,	"maxed",	eData.maxed , "value is 1 if this estimation is the best possible" );
				fl_none = false;
			}
			if( eData.hasNextDay && eData.maxed ) {
				var exml = createChild(xml, "e");
				addAttribute( exml,	T_Int,	"day",		map.days+1 );
				addAttribute( exml,	T_Int,	"min",		eData.estimNext.min );
				addAttribute( exml,	T_Int,	"max",		eData.estimNext.max );
				addAttribute( exml,	T_Bool,	"maxed",	eData.maxedNext , "value is 1 if this estimation is the best possible" );
				fl_none = false;
			}
		}
		if( fl_none ) {
			addComment( xml, "optional : one 'e' node for each estimation (tonight + optional next day)" );
		}
		return xml;
	}
	
	function getXmlZone(user:User, map:Map, zone:db.Zone) {
		var xml = Xml.createElement("myZone");
		if( !user.isOutside || zone.id == map.cityId ) {
			addComment( xml, "this node contains informations about the World Beyond" );
		} else {
			addAttribute( xml, T_Int,	"z",		zone.zombies,		"zombie score, like seen by the player" );
			addAttribute( xml, T_Int,	"h",		zone.humans,		"human score, like seen by the player" );
			addAttribute( xml, T_Bool,	"dried",	zone.dropCount<=0,	"value is 1 if the sector is depleted" );

			var zitems = zone.getItems(false,true);
			for(node in getXmlItems(zitems))
				addChildDtd( xml, node );
		}
		return xml;
	}
	
//	function getXmlItem(zitem:db.ZoneItem) {
//		var xml = Xml.createElement("item");
//		var tinfo = XmlData.getTool(zitem.toolId);
//		if( tinfo.hasType(Fake) ) {
//			var rep = tinfo.getReplacement();
//			if( rep!=null )
//				tinfo = tinfo.getReplacement(); // on camoufle les items empoisonnés
//		}
//		addAttribute( xml,	T_Int,		"id",		tinfo.toolId );
//		addAttribute( xml,	T_String,	"name",		tinfo.name );
//		addAttribute( xml,	T_Int,		"count",	zitem.count );
//		addAttribute( xml,	T_Bool,		"broken",	zitem.isBroken );
//		addAttribute( xml,	T_String,	"img",		tinfo.icon, "ajouter '.gif' et l'attribut iconurl de la node 'headers'" );
//		var cat = db.Tool.getCategory(tinfo);
//		addAttribute( xml,	T_String,	"cat",		if(cat==null) "Misc" else Std.string(cat), "catégorie de l'objet" );
//		return xml;
//	}

	function getXmlItems(list:List<db.ZoneItem>) : List<Xml> {
		var all = new List();
		var h = new Hash();
		// premier parcours pour compter en aggrégeant les items camouflés (empoisonnés)
		for(zitem in list) {
			var tinfo = XmlData.getTool(zitem.toolId);
			var toolId =
				if( tinfo.hasType(Fake) ) {
					// on camoufle les items empoisonnés
					var rep = tinfo.getReplacement();
					if( rep!=null )
						rep.toolId;
					else
						null;
				}
				else
					tinfo.toolId;

			// stockage
			if( toolId!=null ) {
				var hkey = toolId+"_"+zitem.isBroken;
				var data = if(h.exists(hkey)) h.get(hkey) else {
					n		: 0,
					zitem	: zitem,
				}
				data.n+=zitem.count;
				h.set(hkey, data);
			}
		}

		// on crée le XML...
		for(data in h) {
			var zitem = data.zitem;
			var n = data.n;
			if( n <= 0 )
				continue;
			var tinfo = XmlData.getTool(zitem.toolId);
			var xml = Xml.createElement("item");
			addAttribute( xml,	T_Int,		"id",		tinfo.toolId );
			addAttribute( xml,	T_String,	"name",		tinfo.name );
			addAttribute( xml,	T_Int,		"count",	n );
			addAttribute( xml,	T_Bool,		"broken",	zitem.isBroken );
			addAttribute( xml,	T_String,	"img",		tinfo.icon, "don't forget to add '.gif' and iconurl from the headers node" );
			var cat = db.Tool.getCategory(tinfo);
			addAttribute( xml,	T_String,	"cat",		if(cat==null) "Misc" else Std.string(cat), "item category" );
			all.add(xml);
		}
		return all;
	}

	
	function getXmlRewards(user:User) {
		var xml = Xml.createElement("rewards");
		var ih : IntHash<Int> = mt.db.Twinoid.goals.getAll(user);
		
		for( g in GR.LIST ) {
			var k : Int = mt.db.Twinoid.GoalsApi.hash(g.key);
			var count = ih.get(k);
			if( count != null && count > 0 ) {
				var gr = GR.getByKey(g.key);
				var xmlGR = createChild( xml, "r" );
				addAttribute( xmlGR,	T_String,	"name",		gr.name );
				addAttribute( xmlGR,	T_Int,		"n",		count );
				addAttribute( xmlGR,	T_Int,		"img",		"r_"+gr.key, "don't forget to add '.gif' and iconurl from the headers node" );
				addAttribute( xmlGR,	T_Bool,		"rare",		gr.rare );
				addAttribute( xmlGR,	T_String,	"desc",		gr.desc );
				
				var level = null;
				for( l in gr.levels )
					if( count >= l.min )
						level = l;
				if( level != null ) {
					var xmlLev = createChild( xmlGR, "title" );
					addAttribute( xmlLev,	T_String,	"name",		level.name );
				}
			}
		}
		return xml;
	}
	

	function getXmlPlayedMaps(user:User) {
		var xml = Xml.createElement("maps");
		var cadavers = db.Cadaver.manager.getBestMaps(user, -1, -1, 9999);
		var maps = new IntHash();
		for (c in cadavers) {
			var xmlPM = createChildWithCdata( xml, "m", c.comment );
			addAttribute( xmlPM,	T_Int,		"id",		c.oldMapId, "city ID");
			addAttribute( xmlPM,	T_String,	"name",		c.mapName );
			addAttribute( xmlPM,	T_Bool,		"v1",		c.isV1() );
			addAttribute( xmlPM,	T_Int,		"d",		Math.max(0,c.survivalDays), "survived days" );
			addAttribute( xmlPM,	T_Int,		"score",	Math.max(0,c.getSurvivalPoints()), "soul points earned" );
			addAttribute( xmlPM,	T_Int,		"season",	c.season, "season ID, 0 for old maps" );
			maps.set(c.oldMapId, 1);
		}
		return xml;
	}

	function getXmlStatus() {
		var xml = Xml.createElement("status");
		var fl_open = true;
		var str = "";
		if( App.MAINTAIN || App.HORDE_ATTACK ) {
			fl_open = false;
			if( App.MAINTAIN ) {
				str = "Le site est actuellement en maintenance.";
			}
			if( App.HORDE_ATTACK ) {
				str = "Le site est assailli par les hordes de zombies !";
			}
		}
		addAttribute( xml,	T_Bool,		"open",		fl_open, "value is 0 if the site is in maintenance" );
		addAttribute( xml,	T_String,	"msg",		str, "extra information related to the site status" );
		return xml;
	}
}
