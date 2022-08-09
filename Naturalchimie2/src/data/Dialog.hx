package data ;

import GameData._ArtefactId ;

enum ActionEffect {
	EUrl( url : String ) ;
	EUrlAuto( url : String ) ;
	
	EEffect( fx : Effect ) ;
	ENoEffect( fx : Effect ) ;
	ECollection( c : Collection ) ;
	ENoCollection( c : Collection) ;
	EGive(o : _ArtefactId, qty : Int) ;
	ETake(o : _ArtefactId, qty : Int) ;
	EQuestGive(o : _ArtefactId, qty : Int) ;
	EQuestTake(o : _ArtefactId, qty : Int) ;
	ERecipe(r : Recipe, forceFlash : Bool) ;
	ENoRecipe(r : Recipe) ;
	EGold(g : Int) ;
	ERefill(p : Int) ;
	EReput(s : String, r : Int) ;
	EDirectReput(s : String, r : Int) ;
	EDirectTake(o : _ArtefactId, qty : Int) ;
}


enum ActionSpecial {
	SNone ;
	SQuest(from : String) ;
}


typedef DialogPhase = {
	var id : String ;
	var off : Bool ;
	var text : String ;
	var frame : String ;
	var fast : Int ;
	var next : Array<String> ;
	var effects : Array<ActionEffect> ;
	var special : ActionSpecial ;
}


typedef Dialog = {
	var id : String ;
	var first : String ;
	var cond : Condition ;
	var questCan : Condition ;
	var questCant : Condition ;
	var place : Map ;
	var name : String ;
	var auto : Bool ;
	var gfx : String ;
	var phases : Hash<DialogPhase> ;
	var links : Hash<{
		var id : String ;
		var text : String ;
		var target : DialogPhase ;
		var cond : Condition ;
		var url : {url : String, auto : Bool} ;
		var special : ActionSpecial ;
	}>;
}

class DialogXML {

	public static function parse(dir : String) {
		var h = new Hash();
		var path = Config.TPL+dir ;
		for( file in neko.FileSystem.readDirectory(path) ) {
			if( file == ".svn" || file == "cauldron" || file == "quest")
				continue;
			var id = file.split(".xml")[0];
			var n = 1;
			for( e in Xml.parse(neko.io.File.getContent(path+"/"+file)).elements() ) {
				var id = if( n == 1 ) id else id + "__" + n;
				var data = try
					parseDialog(id,new haxe.xml.Fast(e))
				catch( e : Dynamic ) {
					neko.Lib.rethrow("Error in dialog '"+id+"' : "+Std.string(e)) ;
				}
				h.set(id,data) ;
				n++ ;
			}
		}
		return h;
	}


	static function parseDialog(id,d : haxe.xml.Fast ) : Dialog {
		// list different phases
		var phases = new Hash() ;
		var first = null ;
		var quests = new List<List<Quest>>() ;
		var toCheckQuestAccess = new Array() ;
		for( p in d.nodes.phase ) {
			var id = p.att.id ;
			if (phases.exists(id))
				throw "Duplicate dialog phase : "+id ;
			if( first == null )
				first = id ;
			var effects = new Array() ;
			
			var special = SNone ;
			for( name in p.x.attributes() ) {
				var v = p.x.get(name) ;
				switch( name ) {
				case "id", "next", "off", "bg", "frame", "fast" :
				case "url" :
					effects.push(EUrl(v)) ;
				case "urlauto" :
					effects.push(EUrlAuto(v)) ;
				case "quest" :
					quests.add(handler.Quests.getFrom(v)) ; // check group exists
					special = SQuest(v) ;
					toCheckQuestAccess.push(v) ;	
				case "give":
					var p = v.split(":");
					effects.push(EGive(Data.parseArtefact(p[0]), if( p[1] == null ) 1 else Std.parseInt(p[1]) )) ;
				case "take":
					var p = v.split(":");
					effects.push(ETake(Data.parseArtefact(p[0]), if( p[1] == null ) 1 else Std.parseInt(p[1]) )) ;
				case "qgive":
					var p = v.split(":");
					effects.push(EQuestGive(Data.parseArtefact(p[0]), if( p[1] == null ) 1 else Std.parseInt(p[1]) )) ;
				case "qtake":
					var p = v.split(":");
					effects.push(EQuestTake(Data.parseArtefact(p[0]), if( p[1] == null ) 1 else Std.parseInt(p[1]) )) ;
				case "effect":
					for(e in v.split(":"))
						effects.push(EEffect(Data.EFFECTS.getName(e))) ;
				case "noeffect":
					for( e in v.split(":") )
						effects.push(ENoEffect(Data.EFFECTS.getName(e))) ;
				case "collection":
					effects.push(ECollection(Data.COLLECTION.getName(v))) ;
				case "nocollection":
					effects.push(ENoCollection(Data.COLLECTION.getName(v))) ;
				case "recipe":
					var infos = v.split(":") ;
					var r = null ;
					var forceFlash = false ;
					if (infos.length == 1)
						r = v ;
					else {
						r = infos[0] ;
						forceFlash = Std.parseInt(infos[1]) == 1 ;
					}
					effects.push(ERecipe(Data.RECIPES.getName(r), forceFlash)) ;
				case "norecipe":
					effects.push(ENoRecipe(Data.RECIPES.getName(v))) ;
				case "gold":
					effects.push(EGold(Std.parseInt(v))) ;
				case "refill":
					effects.push(ERefill(if (v == "") null else Std.parseInt(v))) ;
				case "reput":
					var p = v.split(":") ;
					if (p.length != 2)
						throw "invalid dialog effect : reput " + v ;
				
					effects.push(EReput(p[0], Std.parseInt(p[1]))) ;
					
				case "dreput":
					var p = v.split(":") ;
					if (p.length != 2)
						throw "invalid dialog effect : dreput " + v ;
				
					effects.push(EDirectReput(p[0], Std.parseInt(p[1]))) ;
					
				case "dtake":
					var p = v.split(":");
					effects.push(EDirectTake(Data.parseArtefact(p[0]), if( p[1] == null ) 1 else Std.parseInt(p[1]) )) ;
					
				
				
				default:
					throw "Dialog effect not supported : "+name;
				}
			}
			phases.set(id,{
				id : id,
				text : p.innerData,
				next : if( p.has.next ) p.att.next.split(":") else [],
				effects : effects,
				special : special,
				off : p.has.off,
				frame : if( p.has.frame ) p.att.frame else null,
				fast : if( p.has.fast ) Std.parseInt(p.att.fast) else 1,
			});
		}
		// add links
		var links = new Hash() ;
		var qc = null ;
		var qct = null ;
		
		for( a in d.nodes.a ) {
			var id = a.att.id ;
			
			if( links.exists(id) )
				throw "Duplicate dialog link : "+id ;
			var target = if( a.has.target ) a.att.target else id ;
			var p = phases.get(target) ;
			
			var l = {
				id : id,
				text : a.innerData,
				target : p,
				cond : if( a.has.cond ) Script.parse(a.att.cond) else Condition.CTrue,
				url : if (a.has.url) {url : a.att.url, auto : false} else if (a.has.urlauto) {url : a.att.urlauto, auto : true} else null,
				special : null
			}
			
			if (a.has.quest) {
				quests.add(handler.Quests.getFrom(a.att.quest)) ; // check group exists
				l.special = SQuest(a.att.quest) ;
				toCheckQuestAccess.push(a.att.quest) ;
			}
			
			if( p == null && id != "end" && id != "exit" && l.url == null && l.special == null) //no special link (end, exit, redirect)
				throw "Dialog phase not found : "+target ;
			
			links.set(id,l);
			
		}
		
		var qa = {c : null, ct : null} ;
		if (toCheckQuestAccess.length > 0) {
			qa = Data.checkQuestAccess(toCheckQuestAccess) ;
		}
		
		
		// check phase links
		for( p in phases )
			for( l in p.next )
				if( !links.exists(l) && !phases.exists(l) )
					throw "Dialog next does not exist : "+l;
		if( !phases.exists("begin"))
			throw "No begin ";
		
		var d : Dialog = {
			id : id,
			first : first,
			cond : if( d.has.cond ) Script.parse(d.att.cond) else Condition.CTrue,
			questCan : qa.c,
			questCant : qa.ct,
			place : if (d.has.place && d.att.place != "") Data.MAP.getName(d.att.place) else null,
			name : d.att.name,
			auto : d.has.auto && Std.parseInt(d.att.auto) == 1 ,
			//weight : if (d.has.weight) Std.parseInt(d.att.weight) else null,
			//keeper : if (d.has.keeper) d.att.keeper else null,
			gfx : d.att.gfx,
			phases : phases,
			links : links,
		};
		
		if (d.place != null) {
			for (ql in quests) {
				for (q in ql) {
					if (q.endMid == null)
						q.endMid = d.place.mid ;
				}
			}
		}
		
		return d ;
	}

}

