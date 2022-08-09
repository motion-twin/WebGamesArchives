package data;

typedef FightAction = {
	var actName : String;
	var monsters : Null<List<Monster>>;
	var allies : List<Monster>;
	var beginText : Null<String>;
	var beginMonster : Monster;
	var winText : Null<String>;
	var lostText : Null<String>;
	var bg : Null<Background>;
	var timeout : Null<Int>;
}

typedef KillInfos = {
	var monsters : List<Monster>;
	var count : Int;
	var force : Bool;
	var zone : Null<Int>;
	var names : Null<String>;
}

typedef DelayedCondition = { c : Condition, s : String };

enum MissionGoal {
	GTalk( name : String, dialog : String, ?avatar : String, ?branches : Array<{ text : String, label : String, cond : DelayedCondition}>, ?frame : String, ?background : String, ?dialect:Null<String> );
	GAction( name : String, desc : String, ?wait : Int );
	GKill( kill : KillInfos );
	GAt( ?pos : Map, hidden : Bool, ?title : String );
	GComplete( group : String );
	GFx( fx : Effect, title : String );
	GFight( monsters : List<Monster> );
	GFightAction( fa : FightAction );
	GUse( o : Object, qty : Int );
	GLock;
	GUseIngr( i : Ingredient, qty : Int );
	GBranch( label : String, cond : DelayedCondition );
	GDig( message : String );
}

enum MissionWin {
	WXp( pts : Int );
	WGold( v : Int );
	WObject( o :  Object, n : Int );
	WCollec( id : Collection );
	WEffect( id : Effect );
	WUVar( v : UserVar );
	WGVar( v : GameVar );
	WNoEffect( id : Effect );
	WIngredient( o :  Ingredient, n : Int );
}

typedef Mission = {
	var id : String;
	var mid : Int;
	var name : String;
	var group : String;
	var begin : String;
	var end : String;
	var goals : List<MissionGoal>;
	var wins : List<MissionWin>;
	var labels : Hash<Int>;
	var cond : Condition;
	var dialog : Dialog;
}

class MissionXML {

	static var CONDS = new Array<DelayedCondition>();

	static function missionFiles() {
		var m = sys.FileSystem.readDirectory(Config.TPL+"../xml/missions");
		m.remove(".svn");
		return m;
	}

	public static function parse() {
		var h = new Container<Mission,Dynamic>(true);
		for( file in missionFiles() )
			h.parse("missions/"+file,parseMission);
		return h;
	}
	
	static function parseMission( id : String, iid : Int, m : haxe.xml.Fast ) : Mission {
		var goals = new List();
		var wins = new List();
		var labels = new Hash();
		var labelsToCheck = new List();
		for( g in m.elements )
			switch( g.name ) {
			case "begin", "end":
			case "goto":
				goals.add(	GAt(Data.MAP.getName(g.att.v),
							g.has.hide	? Std.parseInt(g.att.hide) != 0:false,
							g.has.title	? g.att.title:null) );
			case "nogoto":
				goals.add(GAt(null,false,null));
			case "talk":
				var text, branches = null;
				if( !g.hasNode.text )
					text = g.innerData;
				else {
					text = g.node.text.innerData;
					branches = new Array();
					for( b in g.nodes.branch ) {
						var cond = null;
						if( b.has.cond ) {
							cond = { c : null, s : b.att.cond };
							CONDS.push(cond);
						}
						labelsToCheck.add(b.att.v);
						branches.push({ label : b.att.v, text : b.innerData, cond : cond });
					}
				}
				goals.add(GTalk(g.att.v,text,g.has.gfx ? g.att.gfx : null,branches, g.has.frame ? g.att.frame : null, g.has.background ? g.att.background : null, g.has.dialect ? g.att.dialect : null));
			case "action":
				goals.add(GAction(g.att.v,g.innerData,g.has.wait ? Std.parseInt(g.att.wait) : null));
			case "kill":
				goals.add(GKill({
					monsters : if( g.has.v ) Lambda.map(g.att.v.split(":"),Data.MONSTERS.getName) else null,
					count : Std.parseInt(g.att.n),
					force : g.has.v && !g.has.rare,
					zone : if( g.has.zone ) Std.parseInt(g.att.zone) else null,
					names : g.has.name?g.att.name:null,
				}));
			case "fight":
				goals.add(GFight(Lambda.map(g.att.v.split(":"),Data.MONSTERS.getName)));
			case "require":
				goals.add(GFx(Data.EFFECTS.getName(g.att.v),g.att.title));
			case "actfight":
				var ml = if( g.has.monsters ) g.att.monsters.split(":") else null;
				if( ml != null )
					ml.remove("");
				var fa : FightAction = {
					actName : g.att.act,
					monsters : if( ml == null ) null else Lambda.map(ml,Data.MONSTERS.getName),
					allies : if( g.has.allies ) Lambda.map(g.att.allies.split(":"),Data.MONSTERS.getName) else new List(),
					beginText : if( g.hasNode.begin ) StringTools.trim(g.node.begin.innerData) else null,
					beginMonster : if( g.hasNode.begin && g.node.begin.has.m ) Data.MONSTERS.getName(g.node.begin.att.m) else null,
					winText : if( g.hasNode.win ) StringTools.trim(g.node.win.innerData) else null,
					lostText : if( g.hasNode.lost ) StringTools.trim(g.node.lost.innerData) else null,
					bg : if( g.has.bg ) Data.BACKGROUNDS.getName(g.att.bg) else null,
					timeout : if( g.has.timeout ) Std.parseInt(g.att.timeout) else null,
				};
				goals.add(GFightAction(fa));
			case "use":
				var obj = Data.OBJECTS.getName(g.att.v);
				var qty = Std.parseInt(g.att.n);
				if( obj.max < qty )
					throw "Invalid amount of object "+obj.name+", maximum is "+obj.max+", requested is "+qty;
				goals.add(GUse(obj, qty));
			case "lock":
				goals.add(GLock);
			case "useingr":
				var ingr = Data.INGREDIENTS.getName(g.att.v);
				var qty = Std.parseInt(g.att.n);
				if( ingr.max < qty )
					throw "Invalid amount of ingredient "+ingr.name+", maximum is "+ingr.max+", requested is "+qty;
				goals.add(GUseIngr(ingr,qty));
			case "label":
				if( labels.exists(g.att.v) )
					throw "Duplicate label '"+g.att.v+"'";
				labels.set(g.att.v,goals.length);
			case "branch":
				var l = g.att.v;
				labelsToCheck.add(l);
				var cond = null;
				if( g.has.cond ) {
					cond = { c : null, s : g.att.cond };
					CONDS.push(cond);
				}
				goals.add(GBranch(l,cond));
			// wins
			case "xp":
				wins.add(WXp(Std.parseInt(g.att.v)));
			case "gold":
				wins.add(WGold(Std.parseInt(g.att.v)));
			case "collec":
				wins.add(WCollec(Data.COLLECTION.getName(g.att.v)));
			case "fx":
				wins.add(WEffect(Data.EFFECTS.getName(g.att.v)));
			case "nofx":
				wins.add(WNoEffect(Data.EFFECTS.getName(g.att.v)));
			case "item":
				var n = if( g.has.n ) Std.parseInt(g.att.n) else 1;
				wins.add(WObject(Data.OBJECTS.getName(g.att.v), n));
			case "ingr":
				var n = if( g.has.n ) Std.parseInt(g.att.n) else 1;
				wins.add(WIngredient(Data.INGREDIENTS.getName(g.att.v),n));
			case "dig":
				goals.add( GDig( g.innerData ) );
			case "uvar":
				wins.add( WUVar( Data.USERVARS.getName(g.att.v) ) );
			case "gvar":
				wins.add( WGVar( Data.GAMEVARS.getName(g.att.v) ) );
			default:
				throw "Invalid case "+g.name+" in mission "+id;
			}
		for( l in labelsToCheck )
			if( !labels.exists(l) )
				throw "Missing label '"+l+"'";
		if( wins.isEmpty() || goals.isEmpty() )
			throw "Mission "+id+" is incomplete";
		return {
			id : id,
			mid : iid,
			name : m.att.name,
			group : m.att.group,
			begin : format(m.node.begin.innerData),
			end : m.node.end.innerData,
			goals : goals,
			wins : wins,
			labels : labels,
			cond : Condition.CTrue,
			dialog : null,
		};
	}

	public static function format(str) {
		str="<p>"+str;
		str=str+"</p>";
		str = StringTools.replace(str,"|","</p><p>");
		return str;
	}

	public static function check() {
		for( c in CONDS ) {
			c.c = Script.parse(c.s);
			c.s = null;
		}
		CONDS = new Array();
		for( file in missionFiles() ) {
			var x = new haxe.xml.Fast(Data.xml("missions/"+file));
			for( e in x.elements ) {
				var m = Data.MISSIONS.getName(e.att.id);
				if( e.has.cond )
					m.cond = Script.parse(e.att.cond);
			}
		}
	}

}
