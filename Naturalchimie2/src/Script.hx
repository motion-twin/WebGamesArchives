import data.Condition;


class Script {



	public static function eval( u : db.User, c : data.Condition, ?skipSchool = false) {
		return switch( c ) {
			case CDemo : u.isDemo() ;
			case CFirstPlay : u.firstPlayDone ;
			case CTrue: true;
			case CFalse: false;
			case CEffect(fx) : u.hasEffect(fx) ;
			case CGrade(s, g) : if (s == "") { u.grade >= g ; } else {u.school == Data.schoolIndex(s) && u.grade >= g ;}
			case CReput(s, r) : /*u.school == Data.schoolIndex(s) &&*/ Data.getReputRank(u.level.reput[Data.schoolIndex(s)]) >= r ;
			case CSchool(s): u.school == Data.schoolIndex(s) ;
			case CFullSchool(s, g, r) : u.school == Data.schoolIndex(s) && u.grade >= g && Data.getReputRank(u.level.reput[Data.schoolIndex(s)]) >= r ;
			
			case CRecipeRank(c, r) : u.getRankLevel(Data.CATEGORIES.getName(c).id) >= r ;
			
			case CQuest(q, s) : 
				switch(s) {
					case CQDone : 
						db.Quest.isDone(u, q) ;
					case CQCurrent(progress) : 
						var cq = u.getQuest() ;
						cq != null && q.mid == cq.mid && (progress == null || progress == cq.progress) ;
				}
			case CTime(t):
				var h = Std.int(Date.now().getTime()/(1000.0*60.*60.)) ; // hours
				((h + u.id) % t) == 0;
			case CWeekDay(t): Date.now().getDay() >= t ;
			case CPosition(m): u.mapMid == m.mid ;
			case CNo(c): !eval(u,c);
			case COr(c1,c2): eval(u,c1) || eval(u,c2);
			case CAnd(c1,c2): eval(u,c1) && eval(u,c2);
			case CHasObject(o, qty): u.inventory.has(o, qty) ;
			case CHasQuestObject(o, qty): u.inventory.hasQuest(o, qty) ;
			case CHasCollection(c): u.hasCollection(c) ;
			case CHasAvatar(index, value) : App.user.getFaceValue(index) == value ;
			case CHasRecipe(r) : db.UserRecipe.hasRecipe(App.user.id, r.id) ;
			case CHasGold(g): u.gold >= g ;
			case CHasToken(p): u.getTokens() >= p ;
			case CRandom(n) : Std.random(n) == 0;
			case CNumName : 
				var reg = ~/^.*([0-9]+)$/;
				reg.match(App.user.name) ;
			case CVisit(mid, v) : 
				var m = Data.MAP.getName(mid) ;
				var em = u.getMapEffect(m.mid, false) ;
				if (em == null || em.data.visit == null)
					return false ;
				return v == em.data.visit ;
			case CVersion(n, v) : db.Version.manager.sVersion(n) == v ;
			case CWorldMod(v) : db.Version.manager.sVersion("worldMod") == v ;
			case CAdmin: u.isAdmin;
			case CNewXmasFace : db.XMasFace.checkCurrentFace(App.user) ;
			case CBeta : Config.BETA ;
		};
	}
	
	
	public static function print( u : db.User, c : data.Condition ) {
		return switch( c ) {
			case CDemo: "" ;
			case CFirstPlay : "" ;
			case CTrue: Text.get.script_print_CNothing ;
			case CFalse: Text.get.script_print_CFalse ;
			case CEffect(fx) : Text.get.script_print_CNothing ;
			case CGrade(s, g) : 
				if (s == "")
					Text.format(Text.get.script_print_CAnyGrade, {SG : Text.getText("grade_" + g), G : g}) ; 
				else
					Text.format(Text.get.script_print_CGrade, {SG : Text.getText("grade_" + g), G : g, SCH : Text.getText("school_" + Data.schoolIndex(s))}) ; 
			case CReput(s, r) : Text.format(Text.get.script_print_CReput, {R : Text.getText("reput_cap_" + r), SCH : Text.getText("school_" + Data.schoolIndex(s))}) ;
			case CSchool(s): Text.format(Text.get.script_print_CSchool, {SCH : Text.getText("school_" + Data.schoolIndex(s))}) ;
			case CFullSchool(s, g, r) : Text.format(Text.get.script_print_CFullSchool, {SG : Text.getText("grade_" + g), G : g, SR : Text.getText("reput_cap_" + r), SCH : Text.getText("school_" + Data.schoolIndex(s))}) ;
			case CQuest(q, s) : Text.format(Text.get.script_print_CQuest, {Q : q.name}) ;
			case CTime(t): Text.get.script_print_CNothing ;
			case CPosition(m): Text.get.script_print_CNothing ;
			case CNo(c): "" ; /*"! " + print(u,c) ;*/
			case CWeekDay(t) : "" ;
			case COr(c1,c2): 
				var hackIt = [false, false] ;
				switch(c1) {
					case CSchool(s) : hackIt[0] = true ;
					case CFullSchool(s, g, r) : hackIt[0] = true ;
					case CGrade(s, g) : if (s != "" ) hackIt[0] = true ;
					default : //nothing to do
				}
				switch(c2) {
					case CReput(s, g) : hackIt[1] = true ;
					default : //nothing to do
				}
				
				if (hackIt[0] && hackIt[1]) { //hack school shop : c1 for school only && c2 for others 
					var first = true ;
					switch(c1) {
						case CSchool(s) : first = eval(u, c1) ;
						case CFullSchool(s, g, r) : first = eval(u, CSchool(s)) ;
						case CGrade(s, g) : first = eval(u, CSchool(s)) ;
						default : //nothing to do
					}
					if (first)
						print(u, c1) ;
					else 
						print(u, c2) ;
				} else 
					Text.format(Text.get.script_print_COr, {A : print(u,c1), B : print(u,c2)}) ;
				
			case CAnd(c1,c2): 
				var a = print(u,c1) ;
				var b =print(u,c2) ;			
				if (a != "" && b != "")
					Text.format(Text.get.script_print_CAnd, {A : a, B : b}) ;
				else if (a != "")
					a ;
				else if (b != "")
					b ;
				else 
					"" ;
			case CHasObject(o, qty): Text.format(Text.get.script_print_CHasObject, {QTY : qty, N : Data.getArtefactInfo(o).name}) ;
			case CHasQuestObject(o, qty): Text.format(Text.get.script_print_CHasObject, {QTY : qty, N : Data.getArtefactInfo(o).name}) ;
			case CHasCollection(c): "" ; /*Text.format(Text.get.script_print_CHasObject, {C : c.name}) ;*/
			case CHasAvatar(index, value) : Text.get.script_print_CHasAvatar ;
			case CHasRecipe(r) : Text.format(Text.get.script_print_CHasRecipe, {R : r.name}) ;
			case CHasGold(g): Text.format(Text.get.script_print_CHasGold, {G : g, S : if (g > 1) "s" else ""}) ;
			case CHasToken(g): Text.format(Text.get.script_print_CHasToken, {G : g, S : if (g > 1) "s" else ""}) ;
			case CRandom(n) : Text.get.script_print_CRandom ;
			case CVisit(mid, v) : Text.get.script_print_CNothing ;
				
			case CRecipeRank(c, r) : 
				var cc = Data.CATEGORIES.getName(c) ;
				Text.format(Text.get.script_print_CRecipeRank, {C : cc.name, R : Text.getText("rank_" + r), N : r}) ;
			
			case CAdmin: Text.get.script_print_CAdmin ;
			case CNewXmasFace : "" ;
			case CNumName : "" ;
			case CVersion(n, v) : "" ;
			case CWorldMod(v) : "" ;
			case CBeta : Text.get.beta_lock ;
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
			throw e+" in '"+s+"'";
		}
	}

	static function parseExpr( s : String, pos : { p : Int }, next : Bool ) : Condition {
		var c = s.charCodeAt(pos.p++);
		var e = if( c == 33 ) // !
			CNo(parseExpr(s,pos,false));
		else if( c == 40 ) { // (
			var e = parseExpr(s,pos,true);
			if( s.charCodeAt(pos.p++) != 41 ) // )
				throw "Unclosed parenthesis at " + pos.p;
			e;
		} else if( c >= 97 && c <= 122 ) { // a...z
			pos.p -= 1;
			var cmd = parseIdent(s,pos);
			if( s.charCodeAt(pos.p++) != 40 ) // (
				throw "Syntax error";
			var e = switch( cmd ) {
			case "fx":
				CEffect(Data.EFFECTS.getName(parseIdent(s,pos)));
			case "grade":
				var sc = parseIdent(s,pos) ;
				if( s.charCodeAt(pos.p++) != 44) // ,
					throw "Syntax error";
				CGrade(sc, parseInt(s, pos)) ;
			case "reput":
				var sc = parseIdent(s,pos) ;
				if( s.charCodeAt(pos.p++) != 44) // ,
					throw "Syntax error";
				CReput(sc, parseInt(s, pos)) ;
			case "rank":
				var cat = parseIdent(s,pos) ;
				if( s.charCodeAt(pos.p++) != 44) // ,
					throw "Syntax error";
				CRecipeRank(cat, parseInt(s, pos)) ;
			case "sch":
				CSchool(parseIdent(s,pos)) ;
			case "fsch":
				var sc = parseIdent(s,pos) ;
				if( s.charCodeAt(pos.p++) != 44) // ,
					throw "Syntax error";
				var g = parseInt(s,pos) ;
				if( s.charCodeAt(pos.p++) != 44) // ,
					throw "Syntax error";
				CFullSchool(sc, g, parseInt(s,pos)) ;
			case "time":
				CTime(parseInt(s,pos)) ;
			case "weekday":
				CWeekDay(parseInt(s,pos)) ;
			case "quest" : 
				CQuest(Data.QUESTS.getName(parseIdent(s, pos)), CQDone) ;
			case "curquest" : 
				var q = Data.QUESTS.getName(parseIdent(s,pos)) ;
				var progress = if( s.charAt(pos.p) == "," ) { pos.p++; parseInt(s,pos); } else null ;
				CQuest(q,CQCurrent(progress)) ;
			case "pos":
				CPosition(Data.MAP.getName(parseIdent(s,pos))) ;
			case "disable":
				CFalse;
			case "demo" : 
				CDemo ;
			case "firstplaydone" : 
				CFirstPlay ;
			case "hasobject":
				var o = Data.parseArtefact(s, pos) ;
				pos.p++ ;
				var c = parseInt(s, pos) ;
				CHasObject(o, c) ;
			case "hasqobject":
				var o = Data.parseArtefact(s, pos) ;
				pos.p++ ;
				var c = parseInt(s, pos) ;
				CHasQuestObject(o, c) ;
			case "hascollection":
				CHasCollection(Data.COLLECTION.getName(parseIdent(s,pos))) ;
			case "hasavatar":
				var index = parseInt(s,pos) ;
				if( s.charCodeAt(pos.p++) != 44) // ,
					throw "Syntax error";
				CHasAvatar(index, parseInt(s, pos)) ;
			case "hasrecipe":
				var rid = parseIdent(s, pos) ; 
				var r = Data.RECIPES.getName(rid) ;
				if (r == null)
					throw "invalid recipe id " + rid + "in condition" + s ;
				CHasRecipe(r) ;
			case "hasgold":
				CHasGold(parseInt(s, pos)) ;
			case "hastoken":
				CHasToken(parseInt(s, pos)) ;
			case "random":
				CRandom(parseInt(s,pos));
			case "admin":
				CAdmin;
			case "xmasface":
				CNewXmasFace;
			case "beta":
				CBeta ;
			case "numname":
				CNumName;
			case "version":
				var name = parseIdent(s,pos) ;
				if( s.charCodeAt(pos.p++) != 44) // ,
					throw "Syntax error";
				CVersion(name, parseIdent(s, pos)) ;
			case "worldmod" : 
				CWorldMod(parseIdent(s, pos)) ;
			case "visit" : 
				var mid = parseIdent(s,pos) ;
				if( s.charCodeAt(pos.p++) != 44) // ,
					throw "Syntax error";
				CVisit(mid, parseInt(s, pos)) ;
			default:
				throw "Unknown command "+cmd;
			}
			if( s.charCodeAt(pos.p++) != 41 ) // )
				throw "Unclosed parenthesis at " + pos.p ;
			e;
		} else
			throw "invalid char "+s.charAt(pos.p-1) + " " + s.charCodeAt(pos.p-1) ;
		if( !next )
			return e;
		var c = s.charCodeAt(pos.p++);
		if( c == null )
			return e;
		if( c == 43 ) // +
			return CAnd(e,parseExpr(s,pos,true));
		if( c == 124 ) // |
			return COr(e,parseExpr(s,pos,true));
		if( c == 41 ) { // )
			pos.p--;
			return e;
		}
		throw "Invalid char "+s.charAt(pos.p-1) + " # " + c ;
	}

	public static function parseIdent( s : String, pos : { p : Int }, ?withMaj = false) {
		var start = pos.p;
		var c;
		while( ((c = s.charCodeAt(pos.p)) >= 97 && c <= 122) || (c >= 48 && c <= 57) || (withMaj && (c >= 65 && c <= 90)))
			pos.p++;
		return s.substr(start,pos.p - start);
	}

	public static function parseInt( s : String, pos : { p : Int } ) {
		var x = 0;
		var c;
		var side = 1 ;
		if (s.charCodeAt(pos.p) == "-".charCodeAt(0)) {
			side =  -1 ;
			pos.p++ ;
		}
		
		while( (c = s.charCodeAt(pos.p)) >= 48 && c <= 57 ) {
			x = x * 10 + (c - 48);
			pos.p++;
		}
		return side * x;
	}

}
