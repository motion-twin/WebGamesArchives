import data.Condition;

enum SwampState {
	SSOk;
	SSFog;
	SSFlood;
}

enum RockState {
	RSNorth;
	RSSouth;
	RSWest;
	RSEast;
}

class Script {
	
	public static function swampState() {
		var cfg = db.GConfig.get();
		return 	if( cfg.war != null && cfg.war.isRunning() ) SSOk
				else [SSOk,SSFog,SSFlood,SSOk,SSFlood,SSFog,SSOk][(Date.now().getDay() + 5) % 7];
	}
	
	public static function rockState() {
		var h = Std.int(Date.now().getTime() / DateTools.minutes(15)) + 3;
		var r = new neko.Random();
		r.setSeed( Date.now().getDay() );
		var dirs = data.Tools.shuffle([RSNorth, RSSouth, RSEast, RSWest], r);
		return dirs[h % 4];
	}
	
	static function compare( a : Int, b : Int, c : Null<Bool> ) {
		return 	if( c == null ) a == b
				else if( c ) a >= b
				else a <= b;
	}
	
	static function fcompare( a : Float, b : Float, c : Null<Bool> ) {
		return 	if( c == null ) a == b
				else if( c ) a >= b
				else a <= b;
	}
	
	public static function iter( c : data.Condition, f : data.Condition -> Bool -> Void, ?isNo = false ) {
		f(c, isNo);
		switch( c ) {
			case CNo(c): iter(c, f, !isNo);
			case COr(c1, c2): iter(c1, f, isNo); iter(c2, f, isNo);
			case CAnd(c1, c2): iter(c1, f, isNo); iter(c2, f, isNo);
			default:
		};
	}
	
	public static function eval( d : db.Dino, c : data.Condition ) {
		return switch( c ) {
		case CTrue: true;
		case CFalse: false;
		case CCaushRock(d):	return compare(Type.enumIndex(rockState()), d, null);
		case CLevel(l): d.level >= l;
		case CEffect(fx): d.hasEffect(fx);
		case CCollection(c): d.uid != null && d.owner.hasCollection(c);
		case CMission(m,f):
			switch( f ) {
			case CMDone:
				d.hasDoneMission(m);
			case CMCurrent( progress ):
				var mdata = d.mission;
				mdata != null && m.mid == mdata.mid && (progress == null || progress == mdata.progress);
			}
		case CPosition(m): d.pos == m.mid;
		case CSkill(s): d.hasSkill(s);
		case CNo(c): !eval(d,c);
		case COr(c1,c2): eval(d,c1) || eval(d,c2);
		case CAnd(c1,c2): eval(d,c1) && eval(d,c2);
		case CCanFight(m): fight.Result.monsterLevelProba(d.level,100,m.level) > 0;
		case CHasObject(o): d.uid != null && d.owner.hasObject(o,true);
		case CHasIngredient(i, qty, mm):
			if( d.uid == null ) return false;
			var inf = db.Ingredient.get(i, d.owner);
			return inf != null && compare(inf.qty, qty, mm);
		case CDate(date, mm):
			var n = Date.now();
			return fcompare(n.getTime(), date.getTime(), mm);
		case CTime(t,user):
			var h = Std.int(Date.now().getTime()/(1000.0*60.*60.)); // hours
			var seed = h + (user ? d.uid : d.id);
			var r = new mt.Rand(0);
			r.initSeed(seed);
			r.random(t) == 0;
		case CHour( hour, min_max):
			var h = Date.now().getHours();
			return compare(h, hour, min_max);
		case CRandom(n, target, seeded, base, mm):
			var val;
			if( !seeded ) {
				val = Std.random(n);
			} else {
				var r = switch( base ) {
					case RandBase.CRDay : new mt.Rand( Std.int(Date.now().getTime()/(1000.0 * 60. * 60. * 24.)) );
					case RandBase.CRDino: new mt.Rand( d.id );
					case RandBase.CRUser: new mt.Rand( d.uid );
					case RandBase.CRHour: new mt.Rand( Std.int(Date.now().getTime() / (1000.0 * 60. * 60.)) );
					case RandBase.CRDialog: new mt.Rand( App.session.dialogSeed );
				}
				val = r.random(n);
			}
			return compare(val,target,mm);
		case CAdmin: d.uid != null && d.owner.isAdmin;
		case CScenario(s,phase,mm):
			if( d.uid == null ) return false;
			var n = db.Scenario.get(s, d.owner);
			return compare(n, phase, mm);
		case CUVar(v,value,mm):
			if( d.uid == null ) return false;
			var n = db.UserVar.getValue( d.owner, v, 0 );
			return compare(n, value, mm);
		case CGVar(v,value,mm):
			if( d.uid == null ) return false;
			var n = db.GameVar.getValue( v, 0 );
			return compare(n, value, mm);
		case CLife(l,mm):
			return compare(d.life,l,mm);
		case CDinoz(n):
			return d.uid != null && d.owner.listDinos().length >= n;
		case CRace(f):
			return d.getFamily() == f;
		case CEquip(o):
			return d.hasEquip(o);
		case CScenarioWait(s,time):
			var n = db.Scenario.manager.getWithKeys({ uid : d.uid, sid : s.sid },false);
			return Date.now().getTime() - ((n==null)?0:n.date.getTime()) > DateTools.hours(time);
		case CDungeon(dj):
			return db.Dungeon.manager.count({ uid : d.uid, did : dj.did, completed : true }) > 0;
		case CClanAction(a):
			if( a.act.active ) {
				var ccact = db.ClanAction.get( a, d.owner, false );
				if( ccact != null ) {
					return ccact.isFinished();
				} else {
					return false;
				}
			} else {
				return false;
			}
		case CStatus(s):
			return d.status != null;
		case CFriend(f):
			if(  f == null && d.friend == null )
				return true;
			else if(  f == null )
				return false;
			else
				return d.friend == f.mid;
		case CTag(name):
			var tags = App.session.stags;
			if( tags == null ) return false;
			for( n in tags )
				if( n == name )
					return true;
			return false;
		
		case CEvent(name):
			var cfg = db.GConfig.get();
			if( cfg.event == null || cfg.event.get() == null ) return false;
			return cfg.event.isRunning() && (Type.enumConstructor(cast cfg.event.get()).toLowerCase() == name.toLowerCase());
			
		case CWar(name):
			var cfg = db.GConfig.get();
			if ( cfg.war == null || cfg.war.get() == null ) return false;
			return cfg.war.isRunning() && (Type.enumConstructor(cast cfg.war.get()).toLowerCase() == name.toLowerCase());
			
		case CPromo(name):
			var cfg = db.GConfig.get();
			if ( cfg.promo == null || cfg.promo.get() == null ) return false;
			return cfg.promo.isRunning() && (Type.enumConstructor(cast cfg.promo.get()).toLowerCase() == name.toLowerCase());
			
		case CConfig(name):
			var cfg = db.GConfig.get();
			if (cfg.promo != null && (Type.enumConstructor(cast cfg.promo.get()).toLowerCase() == name.toLowerCase())) return true;
			if (cfg.event != null && (Type.enumConstructor(cast cfg.event.get()).toLowerCase() == name.toLowerCase())) return true;
			if (cfg.war != null && (Type.enumConstructor(cast cfg.war.get()).toLowerCase() == name.toLowerCase())) return true;
			return false;
		
		case CTab(name):
			return App.session != null && App.session.currentTab != null && App.session.currentTab.toLowerCase() == name.toLowerCase();
		};
	}

	public static function parse( s : String ) : Condition {
		try {
			var pos = { p : 0 };
			var e = parseExpr(s,pos,true);
			if( pos.p < s.length )
				throw "Expression too long";
			return e;
		} catch( e : String ) {
			neko.Lib.rethrow(e+" in '"+s+"'");
			return null;
		}
	}

	static function parseMM( s : String, pos : { p : Int } ) : Null<Bool> {
		return switch( s.charAt(pos.p) ) {
			case "+": pos.p++; true;
			case "-": pos.p++; false;
			default: null;
		};
	}

	static function parseExpr( s : String, pos : { p : Int }, next : Bool ) : Condition {
		var c = s.charCodeAt(pos.p++);
		var e = if( c == 33 ) // !
			CNo(parseExpr(s,pos,false));
		else if( c == 40 ) { // (
			var e = parseExpr(s,pos,true);
			if( s.charCodeAt(pos.p++) != 41 ) // )
				throw "Unclosed parenthesis";
			e;
		} else if( c >= 97 && c <= 122 ) { // a...z
			pos.p -= 1;
			var cmd = parseIdent(s,pos);
			if( s.charCodeAt(pos.p++) != 40 ) // (
				throw "Syntax error "+cmd;
			var e = switch( cmd ) {
			case "true": CTrue;
			case "false": CFalse;
			case "date":
				var d = parseDate(s, pos);
				if( s.charAt(pos.p) == "," )
					pos.p++;
				var mm = parseMM(s, pos);
				CDate(d, mm);
				
			case "caushrock":
				CCaushRock(parseInt(s, pos));
			case "level":
				CLevel(parseInt(s,pos));
			case "fx":
				CEffect(Data.EFFECTS.getName(parseIdent(s,pos)));
			case "collec":
				CCollection(Data.COLLECTION.getName(parseIdent(s,pos)));
			case "time":
				CTime(parseInt(s,pos),false);
			case "utime":
				CTime(parseInt(s, pos), true);
			case "hour":
				var hour = parseInt(s, pos);
				var mm = parseMM(s,pos);
				if(  hour < 0 || hour > 24 ) throw "Time isn't valid";
				CHour(hour, mm);
			case "mission":
				CMission(Data.MISSIONS.getName(parseIdent(s,pos)),CMDone);
			case "curmission":
				var m = Data.MISSIONS.getName(parseIdent(s,pos));
				var progress = if( s.charAt(pos.p) == "," ) { pos.p++; parseInt(s,pos); } else null;
				CMission(m,CMCurrent(progress));
			case "skill":
				CSkill(Data.SKILLS.getName(parseIdent(s,pos)));
			case "canfight":
				CCanFight(Data.MONSTERS.getName(parseIdent(s,pos)));
			case "pos":
				CPosition(Data.MAP.getName(parseIdent(s,pos)));
			case "disable":
				CFalse;
			case "hasobject":
				CHasObject(Data.OBJECTS.getName(parseIdent(s,pos)));
			case "random":
				var mm = null;
				var n = parseInt(s, pos);
				var target = 0;
				if( s.charAt(pos.p) == "," ) {
					pos.p++;
					target = parseInt(s, pos);
					mm = parseMM(s, pos);
				}
				CRandom(n, target, false, null, mm);
			case "dayrand":
				var mm = null;
				var n = parseInt(s, pos);
				var target = 0;
				if( s.charAt(pos.p) == "," ) {
					pos.p++;
					target = parseInt(s, pos) - 1;
					mm = parseMM(s, pos);
				}
				CRandom(n, target, true, RandBase.CRDay, mm);
			case "drand":
				var mm = null;
				var n = parseInt(s, pos);
				var target = 0;
				if( s.charAt(pos.p) == "," ) {
					pos.p++;
					target = parseInt(s, pos) - 1;
					mm = parseMM(s, pos);
				}
				CRandom(n, target, true, RandBase.CRDialog, mm);
			case "hourrand":
				var mm = null;
				var n = parseInt(s, pos);
				var target = 0;
				if( s.charAt(pos.p) == "," ) {
					pos.p++;
					target = parseInt(s, pos) - 1;
					mm = parseMM(s, pos);
				}
				CRandom(n, target, true, RandBase.CRHour, mm);
			case "admin":
				CAdmin;
			case "scenario":
				var sc = Data.SCENARIOS.getName(parseIdent(s,pos));
				if( s.charAt(pos.p++) != "," ) throw "Missing parameter";
				var k = parseInt(s,pos);
				var mm = parseMM(s,pos);
				CScenario(sc, k, mm);
			case "uvar":
				var uv = Data.USERVARS.getName(parseIdent(s, pos));
				var mm = true;
				var k = 1;
				if( s.charAt(pos.p) == "," ) {
					pos.p++;
					k = parseInt(s,pos);
					mm = parseMM(s, pos);
				}
				CUVar(uv, k, mm);
			case "gvar":
				var uv = Data.GAMEVARS.getName(parseIdent(s, pos));
				var mm = true;
				var k = 1;
				if( s.charAt(pos.p) == "," ) {
					pos.p++;
					k = parseInt(s,pos);
					mm = parseMM(s, pos);
				}
				CGVar(uv,k,mm);
			case "life":
				var k = parseInt(s,pos);
				var mm = parseMM(s,pos);
				CLife(k,mm);
			case "dinoz":
				CDinoz(parseInt(s, pos));
			case "race":
				var name = parseIdent(s, pos);
				var f = Data.DINOZ.getName(name);
				if( f == null )
					throw "Unknown Dinoz race : " + name;
				CRace(f);
			case "equip":
				CEquip(Data.OBJECTS.getName(parseIdent(s,pos)));
			case "swait":
				var sc = Data.SCENARIOS.getName(parseIdent(s,pos));
				if( s.charAt(pos.p++) != "," ) throw "Missing parameter";
				var k = parseInt(s,pos);
				CScenarioWait(sc,k);
			case "dungeon":
				CDungeon(Data.DUNGEONS.getName(parseIdent(s,pos)));
			case "hasingr":
				var ingr = Data.INGREDIENTS.getName(parseIdent(s, pos));
				var qty = 1;
				var mm = true;
				if(  s.charAt(pos.p) == "," ) {
					pos.p++;
					qty = parseInt(s,pos);
					mm = parseMM(s, pos);
				}
				CHasIngredient(ingr, qty, mm);
			case "active":
				Data.isActive(parseIdent(s,pos)) ? CTrue : CFalse;
			case "clanact":
				CClanAction(Data.CLAN_ACTIONS.getName(parseIdent(s,pos)));
			case "status":
				CStatus( Data.STATUS.getId( parseInt(s, pos ) ) );
			case "friend":
				var monsterid = parseIdent(s, pos);
				if(  !Data.MONSTERS.existsName(monsterid ) )
					throw "Unknown monster:" + monsterid;
				CFriend( Data.MONSTERS.getName( monsterid ) );
			case "event":
				CEvent( parseIdent(s, pos) );
			case "promo":
				CPromo( parseIdent(s, pos) );
			case "war":
				CWar( parseIdent(s, pos) );
			case "config":
				CConfig( parseIdent(s, pos) );
			case "tag":
				CTag( parseIdent(s, pos) );
			case "tab":
				CTab( parseIdent(s, pos) );
			default:
				throw "Unknown command "+cmd;
			}
			if( s.charCodeAt(pos.p++) != 41 ) // )
				throw "Unclosed parenthesis";
			e;
		} /*else if(  c >= 48 && c <= 57 ) { // 0-9
			return parseInt(s, pos);
		} */else
			throw "Invalid char " + s.charAt(pos.p - 1);
		if( !next )
			return e;
		var c = s.charCodeAt(pos.p++);
		if( c == null )
			return e;
		if( c == 43 ) // +
			return CAnd(e,parseExpr(s,pos,true));
		if( c == 124 ) // -
			return COr(e,parseExpr(s,pos,true));
		if( c == 41 ) { // )
			pos.p--;
			return e;
		}
		throw "Invalid char "+s.charAt(pos.p-1);
	}

	static function parseIdent( s : String, pos : { p : Int } ) {
		var start = pos.p;
		var c;
		while( ((c = s.charCodeAt(pos.p)) >= 97 && c <= 122) || (c >= 48 && c <= 57) )
			pos.p++;
		return s.substr(start,pos.p - start);
	}

	static function parseInt( s : String, pos : { p : Int } ) {
		var x = 0;
		var c;
		while( (c = s.charCodeAt(pos.p)) >= 48 && c <= 57 ) {
			x = x * 10 + (c - 48);
			pos.p++;
		}
		return x;
	}
	
	static function parseDate( s : String, pos : { p : Int } ) {
		var start = pos.p;
		while(true) {
			// 45(-)  32(SPACE) 48-57(0-9)  58(:)
			var c = s.charCodeAt(pos.p);
			if((c >= 48 && c <= 57) || c == 45 || c == 32 || c == 58) 
				pos.p++;
			else 
				break;
		}
		var sdate = s.substr(start, pos.p - start);
		return Date.fromString(sdate);
	}
}
