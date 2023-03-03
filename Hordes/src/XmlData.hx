import Common;
import MapCommon;
import db.Tool;
import tools.Utils;
import tools.BuildingTool;
import tools.ExploTool;
import data.Explo;
import data.Drop;

typedef ReleaseData = {
	version	: String,
	name	: String,
	url		: String,
	img		: Null<String>,
	items	: List<ReleaseItemData>,
}

typedef ReleaseItemData = {
	name	: String,
	fl_major: Bool,
	mod		: Null<String>,
	help	: Null<String>,
	content	: String,
}

typedef FutureReleaseData = {
	id			: Int,
	name		: String,
	fl_major	: Bool,
	icon		: String,
	desc		: Null<String>,
}

typedef HordeFact = {
	author 		: String,
	message		: String,
}

using Lambda;
class XmlData {
	
	public static var homeUpgrades			: Array<HomeUpgrade>;
	public static var buildings				: IntHash<Building>;		// batiments communautaires
	public static var disabledBuildings		: IntHash<Building>;		// batiments communautaires
	public static var disabledBuildingsHash	: Hash<Building>;		// batiments communautaires
	public static var buildingsHash			: Hash<Building>;
	public static var hashOutsideBuildings	: IntHash<OutsideBuilding>;	// batiments extérieurs
	public static var outsideBuildings		: Array<OutsideBuilding>;	// batiments extérieurs
	public static var jobs					: Array<Job> ;				// métiers
	public static var tools					: IntHash<Tool> ;			// objets
	public static var dropList				: List< {key:String, proba : Int, mod:String} >;	// objets dropés sur la carte
	public static var news					: Hash<Array<String>>;		// journal
	public static var books					: Array<BookData>;			// Livres RP
	public static var cityUpgrades			: List<CityUpgradeData>;
	public static var help					: List<T_HelpData>;
	public static var heroUpgrades			: List<T_HeroUpgrade>;
	public static var nameData				: Hash<Array<{base:String, add:String}>>;
	public static var releases				: List<ReleaseData>;
	public static var futureReleases		: List<FutureReleaseData>;
	public static var hordeFacts			: Array<HordeFact>;
	
	/* ------------------------------------------INIT DE DEPART */
	
	public static function init(rp) : Void {
	 	try {
			initJobs() ;
			initTools() ;
			initBuildings();
			initOutsideBuildings();
			initNames();
			initDropList();
			initNews();
			initHomeUpgrades();
			initBooks();
			initCityUpgrades();
			initHelp();
			initHeroUpgrades();
			initReleases();
			initExploDropList();
			initHordeFacts();
			
		} catch(e:String) {
			var msg = ""+e;
			for( es in haxe.Stack.exceptionStack() )
				msg += "\n"+es;
			db.Error.create("xml init", msg);
			neko.Lib.print("xml init failed : "+msg);
		}
	}
	
	public static function checkXml(raw:String, node:String) { // vérification basique des fermetures
		var n = 0;
		var last = "";
		for( line in raw.split("\n") ) {
			if( line.indexOf("<"+node+" ") >= 0 || line.indexOf("<"+node+">") >= 0 )
				if( n > 0 )
					throw "unclosed node before "+last+"\n"+line;
				else
					n++;
			if( line.indexOf("</"+node+">") >= 0 ) {
				if( n <= 0 )
					throw "unexpected closure near "+last+"\n"+line;
				else
					n--;
			}
			last = line;
		}
	}

	/* ------------------------------------------ CITY NAMES */
	public static function getRandomCityName(?lang) : String {
		if( lang == null )
			lang = App.LANG;
		var name : String = null;
		while( name == null || name.length > 32 ) {
			switch(lang) {
				case "fr" :
					var pre = randomElement(nameData.get("cityprefixes"));
					var suf = randomElement(nameData.get("citysuffixes"));
					var adj = randomElement(nameData.get("cityadjectives"));
					if( Std.random(100) < 35 )
						name = pre.base +" "+ accord( adj.base, pre.add );
					else
						if( Std.random(100) < 30 )
							name = pre.base+" "+accord(adj.base,pre.add)+" "+suf.base;
						else
							name = pre.base+" "+suf.base;

				case "de" :
					var singChance = 70;
					if( Std.random(100) < 40 ) {
						var p1 =
							if( Std.random(100)<33 )
								randomElement(nameData.get("citynames_m"));
							else if( Std.random(100)<50 )
								randomElement(nameData.get("citynames_f"));
							else
								randomElement(nameData.get("citynames_n"));
						var p2 = randomElement(nameData.get("city_attributes"));
						name = p1.base + " " + p2.base;
					} else {
						if( Std.random(100) < 33 ) {
							// masculin
							var p1 = randomElement(nameData.get("citynames_m"));
							var p2 = randomElement(nameData.get("cityadjectives_m"));
							if( Std.random(100) < singChance ) // singular
								name = p2.base + " " + p1.base;
							else // plural
								name =
									( if(lastChar(p2.base) == "r") p2.base.substr(0,p2.base.length-1) else p2.base ) + " " +
									( p1.base + p1.add );
						} else if(Std.random(100) < 50) {
							// féminin
							var p1 = randomElement(nameData.get("citynames_f"));
							var p2 = randomElement(nameData.get("cityadjectives_f"));
							if( Std.random(100) < singChance ) // singular
								name = p2.base +" "+ p1.base;
							else // plural
								name = p2.base + " " + p1.base + p1.add;
						} else {
							// neutre
							var p1 = randomElement(nameData.get("citynames_n"));
							var p2 = randomElement(nameData.get("cityadjectives_n"));
							if( Std.random(100) < singChance ) // singular
								name = p2.base +" "+ p1.base;
							else // plural
								name =	( if(lastChar(p2.base)=="s") p2.base.substr(0,p2.base.length-1) else p2.base ) + " " +
										( p1.base + p1.add );
						}
					}
				case "en" :
					var pre	= randomElement(nameData.get("cityprefixes"));
					var suf	= randomElement(nameData.get("citysuffixes"));
					var kind = randomElement(nameData.get("citykinds"));
					if( Std.random(100) < 40 ) {
						name = capitalize(pre.base) +" "+kind.base+" "+suf.base;
					} else {
						if( Std.random(100) < 50 ) {
							if( Std.random(100) < 33 )
								name = "The "+pre.base+" "+kind.base;
							else
								name = capitalize(pre.base)+" "+kind.base;
						} else {
							if( Std.random(100) < 33 )
								name = "The "+kind.base+" "+suf.base;
							else
								name = capitalize(kind.base) + " " + suf.base;
						}
					}
				case "es" :
					var pref_category = if( Std.random(100) < 50 ) "m" else "f";
					var prefixes = "cityprefixes_" + pref_category;
					var pre = randomElement(nameData.get(prefixes));
					var suf = randomElement(nameData.get("citysuffixes"));
					var adj = randomElement(nameData.get("cityadjectives")).base;
					//
					if( pref_category == "f" && lastChar(adj) == "o" ) {
						adj = adj.substr(0, adj.length - 1) + "a";
					}
					if( Std.random(100) < 35 ) {
						name = pre.base+" "+accord( adj, pre.add );
					} else {
						if( Std.random(100) < 30 )
							name = pre.base+" "+accord( adj, pre.add )+" "+suf.base;
						else
							name = pre.base+" "+suf.base;
					}
				default :
					return "not implemented yet";
			}
		}
		return name;
	}

	static function randomElement( a : Array<{base:String, add:String}> ) {
		return a[Std.random(a.length)];
	}
	
	static function lastChar(str) {
		return str.charAt(str.length-1);
	}

	public static function getPetName(rseed : mt.Rand) {
		var preList = nameData.get("petprefixes");
		var sufList = nameData.get("petsuffixes");
		return
			preList[ rseed.random(preList.length) ].base +
			sufList[ rseed.random(sufList.length) ].base;
	}

	static function capitalize(str:String) {
		return str.charAt(0).toUpperCase() + str.substr(1);
	}

	static function uncapitalize(str:String) {
		return str.charAt(0).toLowerCase() + str.substr(1);
	}

	public static function accord(str:String, add:String) {
		if( add == null ) return str;
		for( c in add.split("") )
			if( str.charAt( str.length-1 ) != c ) str += c;
		return str;
	}

	public static function getDropList() {
		return Lambda.filter( dropList, function(d) {
			return d.mod == null || db.GameMod.hasMod(d.mod);
		});
	}

	public static function getSeasonName(season:Int) {
		var snames = Text.get.RankingSeasons;
		if(snames == null)
			snames = "TODO";
		var list = snames.split(",");
		for(s in list) {
			var parts = s.split(":");
			if( Std.parseInt(parts[0]) == season )
				return parts[1];
		}
		return Text.get.UnknownSeason;
	}
	
	public static function getRandomFact() {
		return hordeFacts[ Std.random(hordeFacts.length) ];
	}

	/* ------------------------------------------JOBS */
	public static function hasJob( jbid : Int ) : Bool {
		if( jobs == null )
			return false;
		return jobs[ jbid ] != null;
	}

	public static function getJob( jbid : Int ) {
		return jobs[ jbid ];
	}

	public static function getJobToolIds() {
		var list = new List();
		for( t in tools )
			if( t != null && t.hasType(JobTool) )
				list.add(t.toolId);
		return list;
	}

	/* ------------------------------------------BOOKS */
	public static function getBookData( bkey : String ) : BookData {
		for( data in books ) {
			if( data.key == bkey )
				return data;
		}
		return null;
	}

	/* ------------------------------------------TOOLS */
	public static function hasTool(tid:Int) : Bool {
		return tools != null && tools.exists(tid);
	}

	public static function getTool( tid:Int ) {
		if( tid == null )
			return null;
		var t = tools.get(tid);
		if( t != null )
			t.isBroken = false;
		return t;
	}

	public static function getRandomTool() {
		if( tools == null )
			return null;
		var t = tools.get( Std.random(Lambda.count(tools)) );
		if( t != null ) t.isBroken = false;
		return t;
	}

	public static function getToolByKey( key : String ):Tool {
		if( key == null ) return null;
		for( tool in tools ) {
			if( tool == null )
				continue;
			if( tool.key == key ) {
				tool.isBroken = false;
				return tool;
			}
		};
		return null;
	}

	public static function getToolsByType( type : ToolType  ) {
		var tpe = Std.string( type );
		return Lambda.filter( tools, function( tool : Tool ) {
			if( tool == null )
				return false ;
			if( tool.types == null )
				return false;
			for( tp in tool.types ) {
				if( tpe == tp ) {
					return true;
				}
			}
			return false;
		}
		);
	}

	/* ------------------------------------------METIERS */
	public static function getJobByKey(k) {
		for( j in jobs )
			if( j != null && j.key == k )
				return j;
		return null;
	}

	public static function getAllJobs() {
		if( jobs == null )
			return null;
		return Lambda.list( jobs ).filter(function(j) {
			return (j != null) ;
		}) ;
	}

	public static function getCommonJobs() {
		if( jobs == null )
			return null;
		return Lambda.list( jobs ).filter(function(j) {
			return ( j != null );
		}) ;
	}

	/* ------------------------------------------ OUTSIDE BUILDINGS */
	public static function getOutsideBuilding( id : Int, ?includeExplorable = false ) {
		var b = hashOutsideBuildings.get( id );
		if( b != null && b.isExplorable && !includeExplorable ) b = null;
		return b;
	}

	public static function getOutsideBuildings(?includeExplorable = false) {
		if( includeExplorable )		return outsideBuildings;
		else return outsideBuildings.filter(function(b) return !b.isExplorable).array();
	}

	// Used for SWF map
	public static function getOutsideBuildingNames(?includeExplorable = false) : Array<OutMapBuildings> {
		var a = new Array();
		for( ob in outsideBuildings ) {
			if( ob.isExplorable && !includeExplorable ) continue;
			a.push( {_id:ob.id, _n:ob.name} );
		}
		return a;
	}

	/* ------------------------------------------BATIMENTS COMMUNAUTAIRES */
	
	public static function getBuildingByKey( key : String) {
		return buildingsHash.get( key );
	}

	public static function getBuildingNeededTools() {
		var ids = new IntHash();
		for( b in buildings ) {
			if( b == null ) continue;
			for( n in b.needList ) {
				ids.set( n.t.id, 0 );
			}
		}
		return Lambda.list( { iterator : ids.keys });
	}

	public static function getBuildingById( id : Int ) : Building {
		return buildings.get(id);
	}

	public static function getCityUpgradeByParent(b:Building) {
		for( up in cityUpgrades )
			if( up.parent.key == b.key )
				return up;
		return null;
	}

	public static function getHelp(?showMods=true) {
		return Lambda.filter(help, function(h) {
			if(showMods)
				return h.mod == null || h.mod == "" || db.GameMod.hasMod(h.mod);
			else
				return h.mod == null || h.mod == "";
		});
	}

	/* ------------------------------------------ÉVOLUTIONS DES HÉROS */

	public static function hasHeroUpgrade(user:db.User, key:String) {
		return hasHeroUpgradeWithoutObject( user.spentHeroDays, user.hero, key );
	}

	public static function hasHeroUpgradeWithoutObject(spentHeroDays:Int, hero:Bool, key:String) {
		if ( !hero ) return false;
		key = key.toLowerCase();
		for( up in heroUpgrades )
			if( up.key == key )
				return spentHeroDays >= up.days;
		throw "Unknown heroUpgrade : "+key;
	}

	public static function getHeroUpProgress(user:db.User) {
		var prev = null;
		var next = null;
		var level = 0;
		for( up in heroUpgrades ) {
			if( up.days <= user.spentHeroDays ) {
				prev = up;
				level++;
			}
			if( next == null && up.days > user.spentHeroDays )
				next = up;
		}
		var ratio = 0.0;
		var age = 0;
		if( prev == null ) {
			ratio = user.spentHeroDays / next.days;
		} else {
			age = user.spentHeroDays - prev.days;
			if( next != null ) {
				ratio = age / (next.days - prev.days);
			}
		}

		return {
			prev	: prev,
			next	: next,
			ratio	: ratio,
			level	: level,
			recent	: (age <= 2),
		}
	}

	public static function getHeroUpgrade(key:String) {
		for( up in heroUpgrades )
			if( up.key == key )
				return up;
		return null;
	}

	public static function getRelease(url:String) {
		for( r in releases )
			if( r.url == url )
				return r;
		return null;
	}

	public static function getLatestRelease() {
		return releases.first();
	}

	static function load(xml, ?nodeName:String) {
		var raw = "";
		try{
			raw = neko.io.File.getContent(Config.XML_PATH+xml);
			raw = StringTools.replace(raw, "::ignore::", "");
			return Xml.parse(raw);
		} catch( e : Dynamic ) {
			if( nodeName != null )
				checkXml(raw, nodeName);
			neko.Lib.rethrow(e);
			return null;
		}
	}

	/*** THE BIG INIT LIST ***/
	static function initNames() : Void {
		nameData = new Hash();
		var xml = load("names.xml", "t");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		for( group in doc.elements )
			if( group.hasNode.t ) {
				var list = new Array();
				for( node in group.nodes.t )
					list.push ({base:node.innerData, add : if(node.has.add) node.att.add else null} );
				nameData.set(group.att.name.toLowerCase(), list);
			}
	}

	static function initDropList() : Void {
		var xml = load("drop_list.xml", "tool");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		dropList = new List();
		for( n in doc.nodes.tool )
			dropList.add( {
				key		: n.att.key,
				proba	: Std.parseInt( n.att.proba ),
				mod		: if(n.has.mod) n.att.mod else null,
			} );
	}
	
	static function initHordeFacts() : Void {
		var xml = load("hordefacts.xml", "hordefact");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		hordeFacts = new Array();
		for( n in doc.nodes.hordefact )
			hordeFacts.push( {
				author		: n.att.author,
				message		: n.innerHTML,
			} );
	}
	
	static function initExploDropList() : Void {
		var xml = load("explodrops.xml", "tool");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		function grabTool(n : haxe.xml.Fast) {
			var t = n.has.key ? getToolByKey(n.att.key) : getTool(Std.parseInt(n.att.id));
			if( t == null ) throw "No tool correspond to the node " + (n.has.key?n.att.key:n.att.id)+ " in explodrops.xml";
			return t;
		}
		
		function grabBuilding(n : haxe.xml.Fast) {
			var b = n.has.key ? getBuildingByKey(n.att.key) : getBuildingById(Std.parseInt(n.att.id));
			if( b == null ) {
				b = disabledBuildingsHash.get(n.att.key);
				if( b == null ) throw "No building correspond to the node " + (n.has.key?n.att.key:n.att.id) + " in explodrops.xml";
			}
			if( b.drop == Drop.c ) throw "common plan "+b.name+" / "+b.key;
			return b;
		}

		for( n in doc.node.bunker.node.common.nodes.tool )
			ExploTool.addResource( Bunker, Common, grabTool(n) );
		for( n in doc.node.bunker.node.rare.nodes.tool )
			ExploTool.addResource( Bunker, Rare, grabTool(n) );
		for( n in doc.node.bunker.node.unusual.nodes.tool )
			ExploTool.addResource( Bunker, Unusual, grabTool(n) );
		// grab plans
		for( n in doc.node.bunker.node.plans.nodes.plan )
			ExploTool.addBuilding( Bunker, grabBuilding(n) );
			
		for( n in doc.node.hotel.node.common.nodes.tool )
			ExploTool.addResource( Hotel, Common, grabTool(n) );
		for( n in doc.node.hotel.node.rare.nodes.tool )
			ExploTool.addResource( Hotel, Rare, grabTool(n) );
		for( n in doc.node.hotel.node.unusual.nodes.tool )
			ExploTool.addResource( Hotel, Unusual, grabTool(n) );
		// grab plans
		for( n in doc.node.hotel.node.plans.nodes.plan )
			ExploTool.addBuilding( Hotel, grabBuilding(n) );
			
		for( n in doc.node.hospital.node.common.nodes.tool )
			ExploTool.addResource( Hospital, Common, grabTool(n) );
		for( n in doc.node.hospital.node.rare.nodes.tool )
			ExploTool.addResource( Hospital, Rare, grabTool(n) );
		for( n in doc.node.hospital.node.unusual.nodes.tool )
			ExploTool.addResource( Hospital, Unusual, grabTool(n) );
		// grab plans
		for( n in doc.node.hospital.node.plans.nodes.plan )
			ExploTool.addBuilding( Hospital, grabBuilding(n) );
	}

	static function initBuildings() : Void {
		var allMods = db.GameMod.getAllMods();
		buildings = new IntHash();
		disabledBuildings = new IntHash();
		buildingsHash = new Hash();
		disabledBuildingsHash = new Hash();
		var buildingList : List<Building> = try BuildingTool.generateBuildings()  catch ( e : Dynamic ) { neko.Lib.rethrow(e); }
		for( bu in buildingList ) {
			if( bu.id == null || bu.name == null || bu.key == null || bu.paCost == null ) throw "Missing important data in : " + bu.name + "(" + bu.id + ")" + bu;
			if( bu.mod != null && !db.GameMod.hasMod(bu.mod) ) {
				disabledBuildings.set(bu.id, bu);
				disabledBuildingsHash.set(bu.key, bu) ;
			} else {
				buildings.set(bu.id, bu) ;
				buildingsHash.set(bu.key, bu);
			}
		}
		var xml = load("buildings.xml", "b");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		var easterNode = null;
		for( node in doc.nodes.b )
			if( node.has.key ) {
				var bu = buildingsHash.get(node.att.key);
				if( bu == null )
					bu = disabledBuildingsHash.get(node.att.key);
				if( node.att.key == "eastercross" ) {
					easterNode = node;
					continue;
				}
				if( bu == null )
					throw "ERROR : unknown building " + node.att.key + " in XML";
				//we can override a name
				if( node.has.name && node.att.name.length > 0 ) bu.name = StringTools.trim(node.att.name);
				bu.description = StringTools.replace(StringTools.trim(node.innerHTML), "\n", "");
				if( node.has.icon ) bu.icon = node.att.icon;
			}
		if( App.isEvent("paques") && easterNode != null ) {
			buildingsHash.get("hanger").description = StringTools.replace(StringTools.trim(easterNode.innerHTML), "\n", "");
			if( easterNode.has.icon ) buildingsHash.get("hanger").icon = easterNode.att.icon;
		}
		
		for( b in buildings ) {
			if( b.description=="#DESC" )
				throw "missing description for " + b.key + " (" + b.name + ")";
		}
	}

	static function initJobs() : Void {
		var xjobs = load("jobs.xml");
		jobs = new Array();
		for( job in xjobs.firstElement().elements() ) {
			var jb = new Job() ;

			if( job.exists( "id" ) ) {
				jb.id = Std.parseInt(job.get( "id" ));
			}

			if( job.exists( "key" ) ){
				jb.key = job.get( "key" );
			}

			if( job.exists( "name" ) ){
				jb.name = job.get( "name" );
			}

			if( job.exists( "icon" ) ){
				jb.icon = job.get( "icon" );
			}

			if( job.exists( "hero" ) ){
				jb.hero = job.get( "hero" )=="1";
			}

			if( job.exists( "tool" ) ){
				jb.tool = Std.parseInt( job.get( "tool" ) );
			}

			jb.description = StringTools.trim(job.firstChild().nodeValue);

			jobs[jb.id] = jb ;
		}
	}

	static function initTools() : Void {
		var xml = load("tools.xml","tool");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		tools = new IntHash();
		for(node in doc.nodes.tool) {
			var tool = new Tool();
			tool.id = Std.parseInt(node.att.id);
			tool.toolId = Std.parseInt(node.att.id);
			tool.key = node.att.key;
			tool.name = node.att.name;
			tool.icon = node.att.icon;
			tool.isHeavy = node.has.isHeavy;
			tool.description = StringTools.trim( node.innerHTML );
			tool.isBroken = false;
			
			if( node.has.action )	tool.action = node.att.action;
			if( node.has.bonus)		tool.bonus = node.att.bonus;
			if( node.has.limit)		tool.limit = node.att.limit;
			if( node.has.lock)		tool.lock = node.att.lock;
			if( node.has.broken )	tool.broken = Std.parseInt(node.att.broken);
			if( node.has.power)		tool.power = Std.parseFloat(node.att.power);
			if( node.has.random )	tool.random = Std.parseInt(node.att.random);
			if( node.has.deco )		tool.deco = Std.parseInt(node.att.deco);
			if( node.has.transport )tool.transport = Std.parseInt(node.att.transport);
			if( node.has.loss_probability ) tool.loss_probability = Std.parseInt(node.att.loss_probability);
			if(node.has.type) throw "syntax error in tools.xml (type instead of types)";
			
			if( node.has.ghoulProba ) tool.ghoulProba = Std.parseInt( node.att.ghoulProba );
			else tool.ghoulProba = 0;
			
			if( node.has.replacement ) {
				tool.replacement = new Array();
				for(t in node.att.replacement.split("|")) tool.replacement.push(t);
			}
			tool.parts = new List();
			if( node.has.parts ) {
				for(t in node.att.parts.split("|")) tool.parts.push(t);
			}
			tool.types = new List();
			if( node.has.types ) {
				for( t in node.att.types.split( "|" ) ) {
					tool.types.add( StringTools.trim(t) );
				}
			}
			if( tool.id == null || tool.key == null ) throw "Missing important data in : "+node;
			tools.set(tool.id, tool);
		}
	}

	static function initOutsideBuildings() : Void {
		var xml = load("outside_buildings.xml","building");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		hashOutsideBuildings = new IntHash();
		outsideBuildings = new Array();
		for(n in doc.nodes.building) {
			var ob = new OutsideBuilding();
			ob.id			= Std.parseInt( n.att.id );
			ob.name			= n.att.name;
			ob.description	= if( n.has.description ) Utils.miniTemplate(n.att.description) else "???";
			if( n.has.banner )
				ob.banner		= n.att.banner;
			if( n.has.level )
				ob.level		= Std.parseInt(n.att.level);
			if( n.has.probaEmpty )
				ob.probaEmpty	= Std.parseInt(n.att.probaEmpty);
			if( n.has.probaMap )
				ob.probaMap		= Std.parseInt(n.att.probaMap);
			if( n.has.def )
				ob.baseDefense	= Std.parseInt(n.att.def);
			if( n.has.isExplorable )
				ob.isExplorable = n.att.isExplorable != "0";
			else
				ob.isExplorable = false;
			for( tool in n.nodes.tool )
				ob.addTool(
					tool.att.key,
					if(tool.has.proba) Std.parseInt(tool.att.proba) else 1
				);
			
			if( ob.isExplorable && ob.id < Const.get.MaxNormalOutsideBuilding )
				throw "Error : l'index " + ob.id + " n'est pas disponible pour les bâtiments explorables, il vous faut éditer la constante MaxNormalOutsideBuilding";
			
			hashOutsideBuildings.set(ob.id, ob) ;
			outsideBuildings.push(ob);
		}
	}

	static function initNews() {
		var xml = load("news.xml", "n");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		news = new Hash();
		for(n in doc.nodes.n) {
			var l = new Array();
			if( n.hasNode.t ) {
				for(t in n.nodes.t) {
					l.push(StringTools.trim(t.innerData));
				}
			} else {
				l.push(StringTools.trim(n.innerData));
			}
			news.set( n.att.id, l );
		}
	}

	static function initHomeUpgrades() : Void {
		var xml = load("home_upgrades.xml", "up");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		homeUpgrades = new Array();
		for(up in doc.nodes.up) {
			var hu = {
				level		: Std.parseInt(up.att.level),
				name		: up.att.name,
				icon		: up.att.icon,
				reqs		: new List(),
				def			: Std.parseInt(up.att.def),
				pa			: Std.parseInt(up.att.pa),
				hasLock		: up.has.hasLock && Std.parseInt(up.att.hasLock)==1,
			}
			if( up.has.require && up.att.require != "" ) {
				var reqs = up.att.require.split(";");
				for(r in reqs) {
					var key = r.split(":")[0];
					var n = Std.parseInt(r.split(":")[1]);
					hu.reqs.push( {key:key, n:n} );
				}
			}
			homeUpgrades[hu.level] = hu;
		}
	}

	static function initBooks() : Void {
		var xml = load("books.xml", "book");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		books = new Array();
		for(node in doc.nodes.book) {
			var chance = Std.parseInt(node.att.chance);
			var b = {
				key		: node.att.key,
				name	: node.att.name,
				design	: node.att.design,
				chance	: if(Math.isNaN(chance)) 0 else chance,
				author	: if(node.has.author)node.att.author else null,
				bg		: node.att.bg,
				content	: node.innerData,
			}
			books.push(b);
		}
	}

	static function initCityUpgrades() : Void {
		var xml = load("cityUpgrades.xml", "up");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		cityUpgrades = new List();
		for(node in doc.nodes.up) {
			var up : CityUpgradeData = {
				parent		: getBuildingByKey(node.att.parent),
				levels		: new Array(),
			}
			for(nodeLevel in node.nodes.l) {
				up.levels[Std.parseInt(nodeLevel.att.n)] = {
					desc		: nodeLevel.att.desc,
					value		: if(nodeLevel.has.v) Std.parseFloat(nodeLevel.att.v),
					value2		: if(nodeLevel.has.v2) Std.parseFloat(nodeLevel.att.v2),
					value3		: if(nodeLevel.has.v3) Std.parseFloat(nodeLevel.att.v3),
				}
			}
			cityUpgrades.add(up);
			//we specify that the building has some extensions levels
			if( up.parent != null )
				up.parent.hasLevels = true;
			else
				throw "a city upgrades has a building parent reference null  " + up;
		}
	}

	static function initHelp() {
		var allMods = db.GameMod.getAllMods();
		var xml = load("help.xml", "h");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		help = new List();
		var phonem = new mt.db.Phoneme();
		for(node in doc.nodes.h) {
			var content = node.innerHTML.split("\r\n\r\n").join("</p><p>");
			// variables
			var list = content.split("::");
			for(n in 0...list.length) {
				if( (n%2)!=0 )
					if( list[n]=="url" )
						list[n] = App.URL;
					else if( list[n]=="LANG" || list[n]=="lang" )
						list[n] = App.LANG;
					else
						list[n] = Const.getStringByKey(list[n]);
			}
			content = list.join("");
			// balises MOD
			content = StringTools.replace(content,"[/mod]", "[mod");
			content = StringTools.replace(content,"[mod ", "[mod");
			var list = content.split("[mod");
			for(n in 0...list.length) {
				if( (n%2)!=0 ) {
					// bloc avec condition de MOD
					var block = list[n];
					var modId = StringTools.trim( block.substr(0, block.indexOf("]")) );
					if( modId==null || modId.length==0 )
						throw "syntax error in help.xml : invalid [mod] tag !";
					if( !db.GameMod.hasMod( modId) )
						list[n] = "";
					else
						list[n] = block.substr( block.indexOf("]" )+1, 99999 );
				}
			}
			content = list.join("");
			var hdata : T_HelpData = {
				key			: node.att.id,
				title		: node.att.title,
				icon		: if(node.has.icon) node.att.icon,
				sub			: node.has.sub,
				content		: content,
				url			: Utils.urlFromTitle(node.att.title),
				ph_title	: phonem.make(node.att.title),
				ph_content	: phonem.make(content),
				mod			: if(node.has.mod) node.att.mod else null,
			}
			help.add(hdata);
		}
	}

	static function initHeroUpgrades() {
		var xml = load("heroUpgrades.xml", "up");
		var doc = new haxe.xml.Fast( xml.firstElement() );
		var arr = new Array();
		for(node in doc.nodes.up) {
			var up : T_HeroUpgrade = {
				days	: Std.parseInt(node.att.d),
				key		: node.att.k.toLowerCase(),
				name	: node.att.name,
				desc	: node.innerHTML,
				icon	: node.att.icon,
			}
			arr.push(up);
		}
		arr.sort( function(a,b) {
			if( a.days<b.days ) return -1;
			if( a.days>b.days ) return 1;
			return 0;
		} );
		heroUpgrades = Lambda.list(arr);
	}

	static function initReleases() {
		var xml = load("releases.xml", "release");
		var doc = new haxe.xml.Fast( xml );
		releases = new List();
		for(r in doc.node.releases.nodes.release) {
			var list = new List();
			for(nitem in r.nodes.item) {
				if(nitem.has.mod && !db.GameMod.hasMod(nitem.att.mod))
					continue;
				var data : ReleaseItemData = {
					name	: nitem.att.name,
					help	: if(nitem.has.help) nitem.att.help else null,
					fl_major: nitem.has.major && nitem.att.major=="1",
					mod		: if(nitem.has.mod) nitem.att.mod else null,
					content	: nitem.innerHTML,
				}
				list.add(data);
			}
			releases.add({
				name	: r.att.name,
				url		: Utils.urlFromTitle(r.att.name),
				version	: r.att.version,
				img		: if(r.has.img) r.att.img else null,
				items	: list,
			});
		}
		futureReleases = new List();
		var id = 0;
		for(node in doc.node.futureReleases.nodes.future)
			futureReleases.add( {
				id			: id++,
				name		: node.att.name,
				icon		: node.att.icon,
				fl_major	: node.has.major && node.att.major=="1",
				desc		: node.innerHTML,
			});
	}
}
