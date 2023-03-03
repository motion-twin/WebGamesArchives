import db.Map;
import db.NewsInfo;
import db.User;
import tools.Utils;
import Common;

typedef DailyNewsData = {
	deads			: List<String>,
	zombies			: Int,
	wasDevastated	: Bool,
	deadTown		: Bool,
	deadShaman		: Bool,
	deadGuide		: Bool,
}

class DailyNews {
	private var rseed	: mt.Rand;

	public var data		: DailyNewsData;
	public var map		: Map;
	public var day		: Int;
	public var users	: List<{id:Int, name:String, dead : Bool}>;
	public var cityLogCount : List<{uid : Int, n : Int, day : Int, ckey: String}>;
	public var cadavers : List<db.Cadaver>;
	
	public static function generateCouncil(councilLogs : Array<{u:String,text:String,depth:Int}>):String {
		var currentColor = 0;
		var colors = ["#b37c4a", "#3b3249", "#4b405e", "#4d5537", "#64325", "#cd9c", "#f8699", "#773939", "#ba6767", "#c225b", "#405500", "#965C36", "#324200", "#6c9100", "#587500", "#696486",];
		var colorMap = new Hash<String>();
		for ( log in councilLogs ) {
			if ( !colorMap.exists(log.u) ) {
				colorMap.set(log.u, colors[currentColor++]);
				currentColor %= colors.length;
			}
		}
		
		//border-left: 2px solid #4d5537; margin-left:20px;
		var html = "";
		for ( log in councilLogs )
		{
			var color = log.u != "" ? colorMap.get(log.u) : "";
			var style = "";
			//if ( log.depth > 0 ) style = "border-left: 2px solid " + color + "; margin-left:" + (10 * log.depth) + "px";
			
			html += "<p style='"+style+"'>";
			if (log.u != "")
				html += "<i style='color:"+color+"'>" + log.u +" : </i> " + log.text;
			else
				html += "<quote>" + log.text + "</quote>";
			html += "</p>";
		}
		return html;
	}
	
	public function new(m, ?u, ?c : List<db.Cadaver>) {
		map = m;
		users = if( u != null ) u else Lambda.list( db.User.manager.getNameAndIdByMap( map ) );
		day = map.days; // TODO: day - 1 ?
		cadavers = if( c != null && c.length > 0 ) c else map.getCadaversByDay( DT_Eaten, day-1, true );
		data = {
			deads			: new List(),
			zombies			: 0,
			wasDevastated	: false,
			deadTown		: false,
			deadShaman		: false,
			deadGuide 		: false,
		};
		initRSeed(map.id+map.cityId+day);
	}

	public function initRSeed(s) {
		rseed = new mt.Rand(s);
	}

	private function getRandCitizen() {
		var list = Lambda.array( users );
		if( list.length <= 0 ) {
			return Text.get.OneCitizen;
		}
		var limit = 0;
		var fl_isDead = true;
		var i = -1;
		while( fl_isDead && list.length > 0 ) {
			fl_isDead = false;
			i = rseed.random(list.length);
			var rc = list[i];
			if( rc.dead ) {
				fl_isDead = true;
				list.splice(i,1);
			} else {
				for( d in data.deads ) {
					if( d == rc.name ) {
						fl_isDead = true;
						list.splice(i,1);
						break;
					}
				}
			}
		}

		if( list.length == 0 ) return Text.get.OneCitizen;
		return tools.Utils.print( list[i].name );
	}

	private function getRand(key) {
		var l = XmlData.news.get(key);
		return l[rseed.random(l.length)];
	}

	private function get(tid:String, ?data:{}):String {
		var txt = "";
		var l = XmlData.news.get(tid);
		if( l == null ) {
			txt = "News.hx: unknown TID '"+tid+"' !";
		} else {
			txt = l[rseed.random(l.length)];
		}
		if( data == null ) data = {};
		Reflect.setField(data,"rcitizen",	getRandCitizen());
		Reflect.setField(data,"rpet",		getRand("petNames"));
		Reflect.setField(data,"ranimal",	getRand("petTypes"));
		Reflect.setField(data,"rday",		rseed.random(8)+8 );
		Reflect.setField(data,"dir",		getRand("directions"));
		Reflect.setField(data,"obj",		getRand("objects"));
		return Utils.miniTemplate(txt,data);
	}

	private function quoteOpt() {
		return if( rseed.random(3) == 0 ) " "+get("quote_optimist"); else "";
	}

	private function quotePess() {
		return if( rseed.random(4) == 0 ) " "+get("quote_pessimist"); else "";
	}

	private function clearFirstCap(str:String):String {
		if( str == "" ) return str;
		var list = str.split("");
		list[0] = list[0].toLowerCase();
		return list.join("");
	}

	private function forceFirstCap(str:String):String {
		if( str == "" ) return str;
		var list = str.split("");
		list[0] = list[0].toUpperCase();
		return list.join("");
	}

	private function averageZombies() {
		var z = Math.round(data.zombies/10)*10;
		return if(z == 0) data.zombies else z;
	}

	private function setNBSP(str) {
		if( str == null ) return null;
		str = StringTools.replace(str," ?","&nbsp;?");
		str = StringTools.replace(str," !","&nbsp;!");
		return str;
	}

	public function generate(?fl_fake:Bool):String {
		if( App.user == null || !App.user.isAdmin ) {
			fl_fake = null; // interdit aux non-admins
		}
		var attack = setNBSP( generateAttack(fl_fake) );
		var gossip = setNBSP( generateGossip(fl_fake) );
		
		var output;
		// pas de gossip
		if( gossip.length == 0 ) {
			output = "<p>" + attack + "</p>";
		}
		// attaque + gossip
		else if( rseed.random(2) == 0 ) {
			output = "<p>"+forceFirstCap(attack)+"</p>"+"<p>"+get("GossipIntro")+" "+clearFirstCap(gossip)+"</p>";
		} else {
			output = "<p>"+forceFirstCap(gossip)+"</p>"+"<p>"+get("AttackIntro")+" "+clearFirstCap(attack)+"</p>";
		}
		
		return output;
	}

	public function generateReactorDestroyed() {
		return "<p>"+get("ReactorDestroyed", { city:map.name } )+"</p>";
	}
	
	public function generateLast() {
		var article = "";
		if( data.deadTown )
			article = get("DeadTown",{city:map.name});
		else if( data.wasDevastated )
			article = get("Devastation",{city:map.name});
		else if( map.days >= 20 )
			article = get("LastDayLegend",{city:map.name, days:map.days});
		else if( map.days >= 10 )
			article = get("LastDayLong",{city:map.name, days:map.days});
		else
			article = get("LastDayShort",{city:map.name, days:map.days});
		return "<p>"+article+"</p>";
	}

	function generateAttack(?fl_fake:Bool) {
		var articles = new Array();
		var quote = "";
		var doorMan = User.manager.getDoorMan(map);
		var deads = data.deads;

		if( day == 1 ) {
			articles.push( get("DayOne",{city:map.name}) );
		} else {
			if( deads.length > 0 && map.hasDoorOpened() && doorMan != null ) {
				var hour = doorMan.date.getHours();
				if( doorMan.date.getMinutes() > 40 ) hour ++;
				if( hour >= 24 ) hour -= 24;
				// door was opened late
				if( doorMan.date.getHours() >= 21 ) {
					if(deads.length <= 2) {
						articles.push( get("DoorCriminalFewDeaths",{name:doorMan.u.print(), h:hour, n:deads.length}) + quotePess() );
					} else {
						articles.push( get("DoorCriminalManyDeaths",{name:doorMan.u.print(), h:hour, n:deads.length}) + quotePess() );
					}
				} else {
					if( deads.length <= 2 ) {
						articles.push( get("DoorFewDeaths",{name:doorMan.u.print(), h:hour, n:deads.length}) + quotePess() );
					} else {
						articles.push( get("DoorManyDeaths",{name:doorMan.u.print(), h:hour, n:deads.length}) + quotePess() );
					}
				}
			} else {
				// door was closed
				// generic deaths
				if( deads.length == 0 ) {
					articles.push( get("NoDeath", {z:averageZombies()}) );
				} else if( deads.length == 1 ) {
					articles.push( get("SingleDeath", {name:deads.first()}) + quoteOpt() );
				} else if( deads.length < 4 ) {
					articles.push( get("FewDeaths", {n:deads.length}) + quotePess() );
				} else {
					articles.push( get("ManyDeaths", {n:deads.length, z:averageZombies()} ) + quotePess() );
				}
			}
		}
		
		var article = if( articles == null || articles.length <= 0 )
						"";
					else
						articles[rseed.random(articles.length)];
		
		if (data.deadShaman ) {
			article += get("ShamanDied", { city:map.name } ) + quotePess();
		}
		if (data.deadGuide ) {
			article += get("GuideDied", { city:map.name } ) + quotePess();
		}
		return article;
	}


	function getGossip(articles, list, key) {
		if( list.length > 0 ) {
			if( list.length == 1 ) {
				articles.push( get(key+"Single",{name:list.first().print()}) );
			} else {
				articles.push( get(key,{n:list.length}) );
			}
		}
	}

	function getLogGossip( articles, logKey, min, newsKey, ?d:Int) {
		// CACHE
		if( cityLogCount == null ) {
			cityLogCount = db.CityLog.manager.getCountsByMap( map );
		}
		if( cityLogCount.length <= 0 )
			return null;

		var listYesterday: Array<{n:Int,uid:Int}> = null;
		if( d == null ) {
			var hier = day - 1;
			listYesterday = Lambda.array( Lambda.map(  Lambda.filter( cityLogCount, function( info ) { return info.day == hier && info.ckey==logKey; } ), function( info ) { return {n:info.n, uid:info.uid}; } ) );
		}
		var list : Array<{n:Int,uid:Int}> = Lambda.array( Lambda.map(  Lambda.filter( cityLogCount, function( info ) { return info.day == d && info.ckey==logKey; } ), function( info ) { return {n:info.n, uid:info.uid}; } ) );
		if( list.length > 0 ) {
			list.sort( function(a, b) {
				if( a.n > b.n ) return -1;
				if( a.n < b.n ) return 1;
				return 0;
			});

			// parmi les joueurs trouvés, on filtre ceux qui n'ont pas fait cette action la veille
			if( d == null ) {
				list = Lambda.array( Lambda.filter( list, function(stat) {
					for( statYest in listYesterday ) {
						if( statYest.uid == stat.uid ) return true;
					}
					return false;
				}));
			}
			if( list.length > 0 && list[0].n >= min ) {
				var u = db.User.manager.get( list[0].uid );
				articles.push( get(newsKey, {name:u.print(), n:list[0].n}) );
				return u;
			}
		}
		return null;
	}

	function generateGossip(?fl_fake:Bool) {
		var articles = new Array();
		var d_outside = new List();
		var d_suicide = new List();
		var d_water = new List();
		var d_hanged = new List();
		var d_crucified = new List();
		var d_infect = new List();
		var d_murder = new List();
		var d_haunted = new List();
		var me = this;
		var clist = cadavers;
		var otherDeads = Lambda.filter( clist, function(c:db.Cadaver) {
			return c.mapDay == me.day-1;
		});

		for( c in otherDeads )
			switch( c.deathType ) {
				case Type.enumIndex( DT_Dehydrated )	: if(c.diedInTown) d_water.push(c);
				case Type.enumIndex( DT_KilledOutside )	: d_outside.push(c);
				case Type.enumIndex( DT_Cyanure )		: d_suicide.push(c);
				case Type.enumIndex( DT_Abandon )		: d_suicide.push(c);
				case Type.enumIndex( DT_HangedDown )	: d_hanged.push(c);
				case Type.enumIndex( DT_Crucified )		: d_crucified.push(c);
				case Type.enumIndex( DT_Infected )		: if(c.diedInTown) d_infect.push(c);
				case Type.enumIndex( DT_Poison )		: d_murder.push(c);
				case Type.enumIndex( DT_Haunted ) 		: d_haunted.push(c);
			}

		if( fl_fake ) {
			var c = new db.Cadaver();
			c.user = App.user;
			d_murder.push(c);
		}

		getGossip( articles, d_suicide, "Suicide" );
		getGossip( articles, d_infect, "Infected" );
		getGossip( articles, d_water, "Water" );
		getGossip( articles, d_hanged, "Hanged" );
		getGossip( articles, d_crucified, "Crucified" );
		getGossip( articles, d_outside, "Outside" );
		getGossip( articles, d_haunted, "Haunted" );//TODO

		getLogGossip( articles, "CL_GiveInventory", 25, "GaveMany", day-1 );
		getLogGossip( articles, "CL_TakeInventory", 15, "TookMany", day-1 );
		getLogGossip( articles, "CL_Thief", 2, "Thief" );
		getLogGossip( articles, "CL_WellExtra", 2, "WaterThief", day-1 );
		getLogGossip( articles, "CL_Ban", 1, "Ban" );
		getLogGossip( articles, "CL_Refined", 5, "Refiner" );

		if( d_murder.length > 0 )
			return get( "Murder", {name:d_murder.first().print(), poison:getRand("poisons")} );
		else
			if( articles.length > 0 )
				return articles[rseed.random(articles.length)];
			else
				return "";
	}

}

