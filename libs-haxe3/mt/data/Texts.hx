package mt.data;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class Texts {

	#if macro

	public static function build( file : String, ?obfuSafe=true ) {
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
		var tstring = macro : String;
		var thash = macro : haxe.ds.StringMap<String>;
		var tdynamic = macro : Dynamic;
		var tbool = macro : Bool;
		var mextern = [ { pos : pos, params : [], name : ":extern" } ];

		// Ajout ALL
		fields.push({
			pos : pos,
			name : "ALL",
			access : [APublic, AStatic],
			doc : null,
			kind : FVar(thash, null),
		});

		// Ajout FALLBACK
		fields.push({
			pos : pos,
			name : "FALLBACK",
			access : [APublic, AStatic],
			doc : null,
			kind : FVar(thash, null),
		});

		var content = Xml.parse(sys.io.File.getContent(file));
		for( e in content.firstElement().elements() ) {
			var id = e.get("id");
			var raw = e.toString();
			if( id == null ) error("Missing id for \""+raw+"\"");

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

			if( vars.length == 0 ) {
				// String simple
				fields.push({
					pos : pos,
					name : id,
					access : [APublic, AStatic],
					meta : mextern,
					doc : null,
					kind : FProp("get_" + id, "null", tstring),
				});
				fields.push( {
					pos : pos,
					name : "get_" + id,
					access : [AStatic,AInline],
					doc : null,
					meta : mextern,
					kind : FFun( {
						ret : null,
						params : [],
						args : [],
						expr : ({ expr : EReturn({ expr : ECall({ expr : EConst(CIdent("resolve")), pos : pos },[{ expr : EConst(CString(id)), pos : pos }]), pos : pos }), pos : pos }),
					}),
				});
			} else {
				// String avec variables
				var fl = [];
				for( v in vars )
					fl.push( { pos : pos, name : obfuSafe?("_"+v):v, meta : [], kind : FVar(tdynamic), doc : null, access : [] });
				fields.push( {
					pos : pos,
					name : id,
					access : [APublic,AStatic,AInline],
					doc : null,
					meta : mextern,
					kind : FFun( {
						ret : null,
						params : [],
						args : [{ name : "args", value : null, type : TAnonymous(fl), opt : false }],
						expr : ({ expr : EReturn({ expr : ECall({ expr : EConst(CIdent("format")), pos : pos },[{ expr : EConst(CString(id)), pos : pos },{ expr : EConst(CIdent("args")), pos : pos }]), pos : pos }), pos : pos }),
					}),
				});
			}
		}

		var mv = if( obfuSafe ) macro v.substr(1) else macro v;
		// Fonction format()
		fields.push({
			pos : pos,
			name : "format",
			access : [AStatic,APublic],
			doc : null,
			kind : FFun({
				ret : null,
				params : [],
				args : [
					{ name : "id", value : null, type : tstring, opt : false },
					{ name : "args", value : null, type : tdynamic, opt : false },
				],
				expr : (macro {
					var raw = resolve(id);
					for( v in Reflect.fields(args) )
						raw = StringTools.replace(raw, "::"+$mv+"::", Reflect.field(args, v));
					return raw;
				}),
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
				expr : (macro {
					return ALL.exists(id) ? ALL.get(id) : ((FALLBACK!=null && FALLBACK.exists(id)) ? FALLBACK.get(id) : "#"+id+"#");
				}),
			}),
		});

		// Fonction init()
		fields.push({
			pos : pos,
			name : "init",
			access : [APublic, AInline, AStatic],
			doc : null,
			kind : FFun({
				ret : tbool,
				params : [],
				args : [{ name : "raw", value : null, type : tstring, opt : false }],
				expr : (macro {
					ALL = mt.data.Texts.parseXml(raw);
					return true;
				}),
			}),
		});

		// Fonction initFallback()
		fields.push({
			pos : pos,
			name : "initFallback",
			access : [APublic, AInline, AStatic],
			doc : null,
			kind : FFun({
				ret : tbool,
				params : [],
				args : [{ name : "raw", value : null, type : tstring, opt : false }],
				expr : (macro {
					FALLBACK = mt.data.Texts.parseXml(raw);
					return true;
				}),
			}),
		});

		return fields;
	}

	#else

	public static function parseXml(raw:String) {
		var h = new haxe.ds.StringMap();
		if( raw==null )
			throw "missing texts";

		var xml = Xml.parse(raw);
		for( e in xml.firstElement().elements() ) {
			var id = e.get("id");
			if( id==null )
				throw "missing id for "+e.toString();
			var buf = new StringBuf();
			for( c in e )
				buf.add( c.toString() );
			var v = buf.toString();
			if( v.split("::").length % 2 == 0 )
				throw "Error in "+id+", invalid number of '::'";
			h.set( id, v );
		}
		return h;
	}

	#if neko

	public static function parseFile( file : String ){
		return parseXml( sys.io.File.getContent( file ) );
	}

	#end

	#end

}
