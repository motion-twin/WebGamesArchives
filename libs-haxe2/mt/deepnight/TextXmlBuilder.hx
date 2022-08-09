package mt.deepnight;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

/*
 * USAGE :
 *
 * Créer une classe Lang (ou autre, on s'en fout) qui référence le XML source (penser
 * à indiquer le path s'il n'est pas dans le classpath) :
 *
 * @:build( mt.deepnight.TextXmlBuilder.build("texts.fr.xml") ) class Lang { }
 *
 * Appeler "Lang.init( raw )", raw étant la string contenant les données XML à parser
 * (tirée des ressources ou chargée dynamiquement).
 *
 * Utiliser Lang.key ou Lang.key(params) pour retourner une valeur.
 *
 *
 * XML :
 *
 * <texts>
 * 	<t id="key1">value</t>
 * 	<t id="key2">value ::name:: blabla</t>
 * </texts>
 *
 */

class TextXmlBuilder {
	
	#if macro
	
	public static function build( file : String ) {
		var pos = Context.currentPos();
		
		function error(s:String) {
			Context.error("Error in "+file+" : "+s, pos);
		}
		
		try file = Context.resolvePath(file) catch( e : Dynamic ) error("File not found");

		var m = switch( Context.getLocalType() ) {
			case TInst(c, _): c.get().module;
			default: null;
		}
		Context.registerModuleDependency(m, file);
		
		var fields = Context.getBuildFields();
		var tstring = TPath( { pack : [], name :"String", params : [], sub : null } );
		var thash = TPath( { pack : [], name :"Hash", params : [TPType(tstring)], sub : null } );
		var tdynamic = TPath( { pack : [], name :"Dynamic", params : [], sub : null } );
		
		// Ajout ALL
		fields.push({
			pos : pos,
			name : "ALL",
			access : [APublic, AStatic],
			doc : null,
			kind : FVar(thash, macro {new Hash();}),
		});
		
		// Champs
		var content = Xml.parse(neko.io.File.getContent(file));
		for( e in content.firstElement().elements() ) {
			var id = e.get("id");
			var eid = { pos:pos, expr:EConst(CString(id)) };
			var raw = e.firstChild().toString();
			if( id == null ) error("Missing ID for \""+raw+"\"");
			
			var content = raw.split("::");
			if( content.length%2==0 )
				error("Missing '::' for "+id);
			var vars = [];
			content.shift();
			while( content.length > 0 ) {
				var vname = content.shift();
				vars.remove(vname);
				vars.push(vname);
				content.shift();
			}
			
			var getter = macro ALL.get($eid);
			if( vars.length == 0 ) {
				// String simple
				fields.push({
					pos : pos,
					name : id,
					access : [APublic, AStatic, AInline],
					doc : null,
					kind : FVar( tstring, getter ),
				});
			}
			else {
				// String avec variables
				var fl = [];
				for( v in vars )
					fl.push( { pos : pos, name : "_"+v, meta : [], kind : FVar(tdynamic), doc : null, access : [] });
				fields.push( {
					pos : pos,
					name : id,
					access : [APublic,AStatic,AInline],
					doc : null,
					kind : FFun( {
						ret : null,
						params : [],
						args : [{ name : "args", value : null, type : TAnonymous(fl), opt : false }],
						expr : { expr : EReturn({ expr : ECall({ expr : EConst(CIdent("format")), pos : pos },[getter,{ expr : EConst(CIdent("args")), pos : pos }]), pos : pos }), pos : pos },
					}),
				});
			}
		}
		
		// Fonction format()
		fields.push({
			pos : pos,
			name : "format",
			access : [AStatic],
			doc : null,
			kind : FFun({
				ret : null,
				params : [],
				args : [
					{ name : "raw", value : null, type : tstring, opt : false },
					{ name : "args", value : null, type : tdynamic, opt : false },
				],
				expr : macro {
					for( v in Reflect.fields(args) )
						raw = StringTools.replace(raw, "::"+v.substr(1)+"::", Reflect.field(args, v));
					return raw;
				},
			}),
		});
		
		// Fonction resolve()
		fields.push({
			pos : pos,
			name : "resolve",
			access : [APublic, AInline, AStatic],
			doc : null,
			kind : FFun({
				ret : null,
				params : [],
				args : [{ name : "id", value : null, type : tstring, opt : false }],
				expr : macro {
					return ALL.exists(id) ? ALL.get(id) : "#"+id+"#";
				},
			}),
		});
		
		// Fonction init()
		fields.push({
			pos : pos,
			name : "init",
			access : [APublic, AInline, AStatic],
			doc : null,
			kind : FFun({
				ret : null,
				params : [],
				args : [{ name : "raw", value : null, type : tstring, opt : false }],
				expr : macro {
					ALL = mt.deepnight.TextXmlBuilder.parseXml(raw);
				},
			}),
		});
		
		return fields;
	}
	
	#else
	
	public static function parseXml(raw:String) {
		var h = new Hash();
		if( raw==null )
			throw "missing texts";
			
		var xml = Xml.parse(raw);
		for( e in xml.firstElement().elements() ) {
			var id = e.get("id");
			var v = e.firstChild().toString();
			if( id==null )
				throw "missing ID for "+v;
			if( v.split("::").length % 2 == 0 )
				throw "Error in "+id+", invalid number of '::'";
			h.set( id, v );
		}
		return h;
	}
	
	#end
	
}
