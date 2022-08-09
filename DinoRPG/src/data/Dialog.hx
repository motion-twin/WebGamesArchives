package data;

enum DialogEffect {
	EEffect( fx : Effect );
	ENoEffect( fx : Effect );
	ECollection( c : Collection );
	ERCollection(c : Collection );
	ESkill( s : Skill );
	EUrl( url : String );
	EScenario( s : Scenario, phase : Int );
	EScenarioDelta( s : Scenario, delta : Int );
	EGive( obj : Object, count : Int );
	EGiveRandom( objects : Array<Object> );
	EUnlock( m : Mission );
	EFriend( d : Monster );
	EMoveRandom( places:Array<Map>, all:Bool );
	EHeal( h:Int );
	EDialect( l:String );
	ETag( name:String );
	ERMTag( name:String );
	EGVar( v : GameVar, qty : Int );
	EUVar( v : UserVar, qty : Int );
	EGiveIngr( i : Ingredient, count:Int );
}

enum DialogSpecial {
	SNone;
	SFight( m : List<Monster>, friends : List<Monster>, ?bg : Background );
	SMissions( group : String );
	SUse( obj : Object, count : Int );
	SUseIngr( ingr : Ingredient, count : Int );
	SUseGold( amount : Int );
	SStartFight;
	SPopUp;
	SFightGroup( m : List<Monster>, friends : List<Monster>, ?bg : Background );
	SStatus( s : Status );
}

typedef DialogPnj = {
	var gfx : String;
	var image : Bool;
	var frame : String;
	var background : String;
}

typedef DialogPhase = {
	var id : String;
	var name : String;
	var fast : Bool;
	var text : String;
	var next : Array<String>;
	var effects : List<DialogEffect>;
	var special : List<DialogSpecial>;
	var pnj : DialogPnj;
	var needCheck : Bool;
}

typedef DialogLink = {
	var id : String;
	var text : String;
	var target : DialogPhase;
	var cond : Condition;
	var confirm : Bool;
}

typedef Dialog = {
	var id : String;
	var first : String;
	var cond : Condition;
	var place : Map;
	var name : String;
	var pnj : DialogPnj;
	var phases : Hash<DialogPhase>;
	var links : Hash<DialogLink>;
	var inject : List<DialogInjection>;
}

typedef DialogInjection = {
	var did : String;//dialog id
	var pid : String;//phase id
	var links : Hash<DialogLink>;
}

class DialogXML {

	public static function parse() {
		var h = new Hash<Dialog>();
		var path = Config.TPL+"../xml/dialogs";
		for( file in sys.FileSystem.readDirectory(path) ) {
			if( file == ".svn" )
				continue;
			var id = file.split(".xml")[0];
			var n = 1;
			try {
				for( e in Xml.parse(sys.io.File.getContent(path+"/"+file)).elements() ) {
					var id = if( n == 1 ) id else id + "__" + n;
					var data = try
						parseDialog(id,new haxe.xml.Fast(e))
					catch( e : Dynamic ) {
						neko.Lib.rethrow("Error in dialog '"+id+"' : "+Std.string(e));
					}
					h.set(id,data);
					n++;
				}
			} catch ( e : Dynamic ) {
				neko.Lib.println("Impossible de parser le fichier : " + path + "/" + file);
				neko.Lib.print("<br/>");
				neko.Lib.rethrow(e);
			}
		}
		inject(h);
		check(h);
		return h;
	}
	
	static function check(dialogs:Hash<Dialog>) {
		for( dkey in dialogs.keys() ) {
			var d = dialogs.get(dkey);
			if( d.inject.length > 0 )
				continue;
			var phases = d.phases;
			var links = d.links;
			// check phase links
			for( p in phases )
				for( l in p.next )
					if( !links.exists(l) )
						throw "Dialog next does not exist : "+l+" in phase "+p.id+" in dialog "+d.id;
			//check links are all accessible
			for( l in links ) {
				var found = false;
				for( p in phases )
					for( l2 in p.next )
						if( l.id == l2 )
							found = true;
				if(!found)
					throw "A link isn't used anywhere "+l.id+" in dialog "+d.id;
			}
		}
	}
	
	static function inject(dialogs:Hash<Dialog>) {
		for( dkey in dialogs.keys() ){
			var d = dialogs.get(dkey);
			try {
				if( !d.inject.isEmpty() ) {
					for( i in d.inject ) {
						var d2 = dialogs.get(i.did);
						if( d2 == null )
							throw("No dialog " + i.did+" exists, referenced in "+dkey );
						var p2 = d2.phases.get(i.pid);
						if( p2 == null )
							throw("No phase " + i.pid+" exists in dialog "+d2.name+" referenced in "+dkey );
						if( Lambda.count(i.links) > 0 ) {
							for ( l in i.links ) {
								var lid = d.id + "_" + l.id;
								p2.next.push( lid );
								var t = copy( d, d2, l.target );
								d2.links.set( lid, { id:lid, target:t, cond:l.cond, text:l.text, confirm:l.confirm } );
							}
						}
					}
					//cleaning
					for( i in d.inject ) {
						if( Lambda.count(i.links) > 0 ) {
							for( l in i.links ) {
								removePhase(d, l.target);
								d.links.remove( l.id );
							}
						}
					}
				}
				//Is useful to keep a reference to it even if it shouldn't be used or displayed
				//if( Lambda.count(d.phases) == 0 )
				//	dialogs.remove( d.id );
			} catch( e:Dynamic ) {
				var info = "";
				for( f in Reflect.fields(d) )
					info += f + ":" + Reflect.field(d, f) + "  ,";
				throw "Error at text injection in dialog : " + info + ". \n" + Std.string(e);
			}
		}
	}
	
	static function removePhase(d:Dialog, p:DialogPhase) {
		for( a in p.next ) {
			var l = d.links.get(a);
			if( l != null ) {
				d.links.remove( l.id );
				removePhase( d, l.target );
			}
		}
		d.phases.remove( p.id );
	}
	
	static function copy( src:Dialog, dest:Dialog, p:DialogPhase ):DialogPhase {
		if(  p == null ) return null;
		//
		var pid = src.id + "_" + p.id;
		if(  dest.phases.exists( pid ) )
			return dest.phases.get( pid );
		//
		var next = p.next.copy();
		var l = next.length;
		while( --l >= 0 )
			next[l] = src.id + "_" + next[l];
		var clone = {	id : pid,
						name : p.name,
						fast : p.fast,
						text : p.text,
						pnj : p.pnj,
						next : next,
						effects : p.effects,
						special : p.special,
						needCheck : p.needCheck,
					};
		dest.phases.set( pid, clone);
		//
		for( a in p.next ){
			var l = src.links.get(a);
			var lid = src.id + "_" + l.id;
			if( ! dest.links.exists( lid ) ){
				var t = copy( src, dest, l.target );
				dest.links.set( lid, { id:lid, target:t, cond:l.cond, text:l.text, confirm:l.confirm } );
			}
		}
		//
		return clone;
	}
	
	static function parseDialog( id, d : haxe.xml.Fast ) : Dialog {
		var dname = d.att.name;
		var pnjData:DialogPnj = { image:false, gfx:"", frame:"speak", background:"1" };
		if( d.has.img ) {
			pnjData.image = true;
			pnjData.gfx = d.att.img;
		}
		if( d.has.gfx )
			pnjData.gfx = d.att.gfx;
		if( d.has.frame )
			pnjData.frame = d.att.frame;
		if( d.has.background )
			pnjData.background = d.att.background;
		
		var first = null;
		var dCond = if( d.has.cond ) Script.parse(d.att.cond) else Condition.CTrue;
		// list different phases
		var phases = new Hash();
		var missions = new List<List<Mission>>();
		for( p in d.nodes.phase ) {
			var id = p.att.id;
			if( phases.exists(id) )
				throw "Duplicate dialog phase : "+id;
			if( first == null )
				first = id;
			var pname = dname;
			var effects = new List();
			var special = new List();
			var pnjData = if( p.has.gfx || p.has.background || p.has.img || p.has.frame ) Reflect.copy(pnjData) else null;
			for( name in p.x.attributes() ) {
				var v = p.x.get(name);
				switch( name ) {
				case "id", "next", "fast", "bg", "nocheck":
				case "name":
					pname = Std.string(v);
				case "gfx":
					pnjData.gfx = Std.string(v);
				case "frame":
					pnjData.frame = Std.string(v);
				case "background":
					pnjData.background = Std.string(v);
				case "img":
					pnjData.image = true;
					pnjData.gfx = Std.string(v);
				case "fight":
					var m = v.split("|");// we allow to add friends monster to the fight
					var ml = Lambda.map(m[0].split(":"), Data.MONSTERS.getName);
					var fl = if( m.length > 1 ) Lambda.map(m[1].split(":"), Data.MONSTERS.getName) else new List();
					special.add( SFight(ml, fl, if( p.has.bg ) Data.BACKGROUNDS.getName(p.att.bg) else null ) );
				case "fightgroup":
					var m = v.split("|");// we allow to add friends monster to the fight
					var ml = Lambda.map(m[0].split(":"), Data.MONSTERS.getName);
					var fl = if( m.length > 1 ) Lambda.map(m[1].split(":"), Data.MONSTERS.getName) else new List();
					special.add( SFightGroup(ml, fl, if( p.has.bg ) Data.BACKGROUNDS.getName(p.att.bg) else null ) );
				case "missions":
					missions.add(handler.Missions.group(v)); // check group exists
					special.add( SMissions(v) );
				case "use":
					for( uv in v.split(',') ) {
						var p = uv.split(":");
						special.add( SUse(Data.OBJECTS.getName(p[0]), if(  p[1] == null ) 1 else Std.parseInt(p[1]) ) );
					}
				case "useingr":
					for( iv in v.split(',') ) {
						var p = iv.split(":");
						special.add( SUseIngr(Data.INGREDIENTS.getName(p[0]), if(  p[1] == null ) 1 else Std.parseInt(p[1]) ) );
					}
				case "give":
					//todo allow give multiple objects
					var p = v.split(":");
					effects.add( EGive(Data.OBJECTS.getName(p[0]), if ( p[1] == null ) 1 else Std.parseInt(p[1]) ) );
				
				case "giveingr":
					//todo allow give multiple ingredients
					var p = v.split(":");
					effects.add( EGiveIngr(Data.INGREDIENTS.getName(p[0]), if ( p[1] == null ) 1 else Std.parseInt(p[1]) ) );
					
				case "effect":
					for( e in v.split(":") )
						effects.add(EEffect(Data.EFFECTS.getName(e)));
				case "noeffect":
					for( e in v.split(":") )
						effects.add(ENoEffect(Data.EFFECTS.getName(e)));
				case "collection":
					effects.add(ECollection(Data.COLLECTION.getName(v)));
				case "rmcollection":
					effects.add(ERCollection(Data.COLLECTION.getName(v)));
				case "skill":
					effects.add(ESkill(Data.SKILLS.getName(v)));
				case "url":
					effects.add(EUrl(v));
				case "scenario":
					var s = v.split(":");
					if( Std.parseInt(s[1]) == null ) throw "Error in Dialog " + dname + " scenario synthax is  scenario='name:increment'";
					
					effects.add(EScenario(Data.SCENARIOS.getName(s[0]), Std.parseInt(s[1])));
				
				case "uvar":
					var s = v.split(":");
					if( Std.parseInt(s[1]) == null ) throw "Error in Dialog " + dname + " uvar synthax is  uvar='varname:increment'";
					effects.add(EUVar(Data.USERVARS.getName(s[0]), Std.parseInt(s[1])));
					
				case "gvar":
					var s = v.split(":");
					if( Std.parseInt(s[1]) == null ) throw "Error in Dialog " + dname + " gvar synthax is  gvar='varname:increment'";
					effects.add(EGVar(Data.GAMEVARS.getName(s[0]), Std.parseInt(s[1])));
					
				case "startfight":
					special.add( SStartFight );
				case "unlock":
					effects.add(EUnlock(Data.MISSIONS.getName(v)));
				case "usegold":
					special.add( SUseGold(Std.parseInt(v)) );
				case "rnditem":
					effects.add(EGiveRandom(Lambda.array(Lambda.map(v.split(":"), Data.OBJECTS.getName))));
				case "move":
					effects.add(EMoveRandom(Lambda.array(Lambda.map(v.split(":"), Data.MAP.getName)), false));
				case "moveAll":
					effects.add(EMoveRandom(Lambda.array(Lambda.map(v.split(":"), Data.MAP.getName)), true));
				case "scenarioIncr":
					effects.add(EScenarioDelta(Data.SCENARIOS.getName(v),1));
				case "popup":
					special.add( SPopUp );
				case "status":
					special.add( SStatus(Data.STATUS.getName(v) ) );
				case "dialect":
					effects.add( EDialect(v) );
				case "heal":
					effects.add(EHeal(Std.parseInt(v)));
				case "tag":
					for( e in v.split(":") )
						effects.add(ETag(e));
				case "rmtag":
					for( e in v.split(":") )
						effects.add(ERMTag(e));
				case "friend":
					if(  v == "" )
						effects.add( EFriend( null ) );
					else
						effects.add( EFriend( Data.MONSTERS.getName(v) ) );
				default:
					throw "Dialog effect not supported : "+name;
				}
			}
			//
			phases.set(id,{
				id : id,
				name : pname,
				text : Tools.format(p.innerData, false),
				next : if( p.has.next ) p.att.next.split(":") else [],
				effects : effects,
				special : special,
				fast : p.has.fast,
				pnj : pnjData,
				needCheck : if( p.has.nocheck ) Std.parseInt( p.att.nocheck ) != 1 else true,
			});
		}
		// add links
		var links = new Hash<DialogLink>();
		for( a in d.nodes.a ) {
			var id = a.att.id;
			if( links.exists(id) )
				throw "Duplicate dialog link : "+id;
			var target = if( a.has.target ) a.att.target else id;
			var p = phases.get(target);
			if( p == null )
				throw "Dialog phase not found : "+target;
			links.set(id,{
				id : id,
				text : Tools.format(a.innerData, true),
				target : p,
				cond : if(  a.has.cond ) Script.parse(a.att.cond) else Condition.CTrue,
				confirm : a.has.confirm,
			});
		}
		
		// add injections
		var injections = new List<DialogInjection>();
		for( i in d.nodes.inject ) {
			var refPhase = null, refDialog = null, ilinks = new Hash(), text = null;
			for( name in i.x.attributes() ) {
				var v = i.x.get(name);
				switch( name ) {
					case "id":
						var refId = v.split(":");
						refDialog = refId[0];
						refPhase = refId[1];
					case "next":
						var linksId = v.split(":");
						for( lid in linksId ){
							var l = links.get(lid);
							if( l == null )
								throw( "A link '"+lid+" isn't recognized in dialog "+id);
							l.cond = Condition.CAnd( l.cond, dCond);
							ilinks.set( lid, l );
						}
					default:
				}
			}
			injections.push( {did:refDialog, pid:refPhase, links:ilinks} );
		}
		
		//check if among effects and specials there's something given or used with a corresponding scenario update
		for ( p in phases ) {
			if(  p.pnj != null && p.name == dname && p.pnj.gfx != pnjData.gfx ) {
				throw( "The GFX change must be followed by a name attribution" );
			}
			//
			if( p.needCheck == false )
				continue;
			var hasGive = false;
			var hasTest = false;
			for( e in p.effects ){
				switch( e ) {
					case EScenario(_, _), EScenarioDelta(_, _), EEffect(_), ENoEffect(_):
						hasTest = true;
					case EGive(_,_):
						hasGive = true;
					default:
				}
			}
			for( spe in p.special ){
				switch( spe ) {
					case SUse(_, _), SUseIngr(_, _):
						hasGive = true;
					default:
				}
			}
			if( hasGive && !hasTest ){
				throw( "Giving an object without scenario increment or test is dangerous in phase "+p.id);
			}
		}
		
		if( !phases.exists("begin") && injections.isEmpty() )
			throw "No begin phase or injection";
				
		var d : Dialog = {
			id : id,
			first : first,
			cond : dCond,
			place : Data.MAP.getName(d.att.place),
			name : dname,
			pnj : pnjData,
			phases : phases,
			links : links,
			inject : injections,
		};
		for( ml in missions )
			for( m in ml )
				m.dialog = d;
		return d;
	}

}