package data;
import Game.GameMode ;
import Game.GameInfo ;
import data.ForumGroup ;


typedef Move = {
	var target : Int ;
	var cond : Condition ;
	var hidden : Condition ;
	var valid : Bool ;
	var pa : Int ;
	var from : String ;
	var road : String ;
	var qway : Bool ;
}


typedef Cauldron = {
	var type : String ;
	var forced : Bool ;
	var cond : Condition ;
	var size : Int ;
	var bg : String ;
	var bgInf : String ;
	var desc : String ;
}


typedef NoWay = {
	var cond : Condition ;
	var dialogId : String ;
	var text : String ;
	var cause : Condition ;
	var bg : String ;
	var redir : String ;
}

typedef ExtraAction = {
	var cond : Condition ;
	var actionId : String ;
}




typedef Map = {
	var id : String ;
	var mid : Int ;
	var region : Int ;
	var name : String ;
	var align : String ;
	var bg : String ;
	var bgInf : String ;
	var gameMode : GameInfo ;
	var cauldron : Cauldron ;
	var inf : Null<String> ;
	var desc : String ;
	var noWays : List<NoWay> ;
	var pre : Condition ;
	var goto : Null<Map> ;
	var moves : List<Move> ;
	var extraActions : List<ExtraAction> ;
	var valid : Bool ;
	var randEvent : Int ; //0 : cant be chosen. 1 : normal. 2 : rare choice. 3 : ultra rare choice 
	var fGroup : ForumGroup ;
	var music : String ;
}



class MapXML extends haxe.xml.Proxy<"map.xml",Map> {

	
	public static function parse() {
		return new data.Container<Map,MapXML>(true).parse("map.xml",function(id,iid,p) {
			var res = {
				id : id,
				mid : iid,
				region : Std.parseInt(p.att.region),
				name : p.att.name,
				align : p.att.align,
				bg : if (p.has.bg) p.att.bg else id,
				bgInf : if (p.has.bginf) p.att.bginf else "0:0",
				cauldron : null,
				gameMode : if (!p.hasNode.game) Game.getDefaultGameInfo() else 
				{	mode : if (p.node.game.has.mode) Game.getGameMode(p.node.game.att.mode) else Game.getGameMode(null),
					chain : Tools.intArray(p.node.game.att.chain),
					chainKnown : if (p.node.game.has.chainknown) Std.parseInt(p.node.game.att.chainknown) else 12,
					objects : if (p.node.game.has.obj && Std.parseInt(p.node.game.att.obj) == 1) 0 else -1,
					artefacts : Game.getArtefacts(p.node.game.att.artft),
					bg : if (p.node.game.has.bg) p.node.game.att.bg else "0:0",
					modWeight : if (p.node.game.has.modWeight) Game.parseModWeights(p.node.game.att.modWeight) else null
				},
				inf : if( p.has.inf ) p.att.inf else null,
				desc : Data.TEXTDESC.format(p.node.desc.innerData),
				randEvent : if (!p.has.randevent) 1 else Std.parseInt(p.att.randevent),
				noWays : /*parseNoWays(p),*/ null,
				pre :/* if (p.hasNode.pre) Script.parse(p.node.pre.innerData) else Condition.CTrue,*/ null,
				goto : null,
				moves : new List(),
				extraActions : new List(),
				valid : true,
				noValidCause : null,
				fGroup : null,
				music : if (p.has.music) p.att.music else "gu1"
			} ;
			
			if (res.randEvent < 0 || res.randEvent > 3)
				throw "error : invalid rand event for zone " + id ;
			
			return res ;
		}) ;
	}
	
	
	public static function parseNoWays(p : haxe.xml.Fast) : List<NoWay> {
		var res = new List() ;
		var tooMuchTrue = 0 ;
		for (e in p.nodes.noway) {
			var cond = Condition.CTrue ;
			var cause = null ;
			var redir = null ;
			if (e.has.cond)
				cond = Script.parse(e.att.cond) ;
			if (e.has.cause)
				cause = Script.parse(e.att.cause) ; 
			if (cond == Condition.CTrue) {
				tooMuchTrue++ ;
				if (tooMuchTrue > 1)
					 throw "too many CTrue noways in " + p.att.id ;
			}
			
			var inner = null ;
			try {
				inner = e.innerData ;
			} catch(e : Dynamic) { } ;
			
			res.add({
				cond : cond,
				dialogId : if (e.has.did) e.att.did else null,
				bg : if (e.has.bg) e.att.bg else null,
				redir : if (e.has.redir) e.att.redir else null,
				text : inner,
				cause : cause
			}) ;
		}
		
		return res ;
	}


	public static function check() {
		var x = new haxe.xml.Fast(Data.xml("map.xml")) ;
		for( p in x.elements ) {
			var m = Data.MAP.getName(p.att.id);
			
			m.pre = if (p.hasNode.pre) Script.parse(p.node.pre.innerData) else Condition.CTrue ;
			m.cauldron = if (!p.hasNode.cauldron) null else 
				{	forced : if (p.node.cauldron.has.forced) Std.parseInt(p.node.cauldron.att.forced) == 1 else false,
					size : if (p.node.cauldron.has.size) (if (p.node.cauldron.att.size == "no") null else Std.parseInt(p.node.cauldron.att.size)) else Data.CAULDRON_MIN_SIZE,
					cond : if (p.node.cauldron.has.cond) Script.parse(p.node.cauldron.att.cond) else Condition.CTrue,
					type : if (p.node.cauldron.has.type) p.node.cauldron.att.type else null,
					bg : if (p.node.cauldron.has.bg) p.node.cauldron.att.bg else m.bg,
					bgInf : if (p.node.cauldron.has.bginf) p.node.cauldron.att.bginf else "0:0",
					desc : if (p.node.cauldron.hasNode.desc) Data.TEXTDESC.format(p.node.cauldron.node.desc.innerData) else null,
					
				} ;
			m.noWays = parseNoWays(p) ;
			
			
			for( a in p.nodes.extraaction ) {
				var act = Data.ACTIONS.getName(a.att.aid) ;
				if (act == null)
					throw "unknown extra action : " + a.att.aid ; 
				m.extraActions.add({
					actionId : a.att.aid,
					cond : if (a.has.cond) Script.parse(a.att.cond) else Condition.CTrue
					}) ;
			}
			
			for( e in p.nodes.move ) {
				var m2 = Data.MAP.getName(e.att.to);
				var cond = if (e.has.cond) Script.parse(e.att.cond) else Condition.CTrue ;
				m.moves.add({
					target : m2.mid,
					cond : cond,
					valid : false,
					qway : false,
					hidden : if (e.has.hidden) Script.parse(e.att.hidden) else Condition.CTrue,
					pa : if (e.has.pa) Std.parseInt(e.att.pa) else 1,
					from : null,
					road : if (e.has.road) e.att.road else null
				});
			}
			if (p.has.goto)
				m.goto = Data.MAP.getName(p.att.goto) ;
		}
	}

}


