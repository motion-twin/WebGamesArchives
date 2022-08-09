#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class TextGenBuilder {
	#if !macro
	var _all				: Hash<Array<String>>;
	public var postProcess	: String->String;
	
	var vars				: Hash<String>;

	
	public function new(raw:String) {
		_all = _parse(raw);
		postProcess = function(s) return s;
		vars = new Hash();
	}
	
	public function setVar(k:String, v:Dynamic) {
		vars.set(StringTools.trim(k).toLowerCase(), Std.string(v));
	}
	
	function _resolve(k:String, ?depth=0) {
		if( depth>=100 )
			return "[stack overflow]";
		if( !_all.exists(k) )
			return "#!"+k+"!#";
		var values = _all.get(k);
		var v = values[Std.random(values.length)];
		var parts = v.split("%");
		if( parts.length%2==0 )
			return postProcess(v);
		
		var res = "";
		for(i in 0...parts.length)
			if( i%2==0 )
				res+=parts[i];
			else
				res+=_resolve(parts[i], depth+1);
		
		// Variables
		if( res.indexOf("::")>=0 ) {
			var parts = res.split("::");
			res = "";
			for(i in 0...parts.length)
				if( i%2==0 )
					res+=parts[i];
				else {
					var k = StringTools.trim(parts[i]).toLowerCase();
					res+=vars.exists(k) ? vars.get(k) : "!!"+k+"!!";
				}
		}
		return postProcess(res);
	}
	
	#end
	
	static function _parse(raw:String) {
		var h = new Hash();
		var l = 0;
		var lastKey : String = null;
		var keyLines = new Hash();
		var comments = ~/<!--(.*?)-->/g;
		for(line in raw.split("\n")) {
			l++;
			var tabbed = line.charAt(0)=="\t";
			var line = comments.replace(line, "");
			if( line.charAt(0)==" " )
				throw "First character is a SPACE at line "+l;
			var line = StringTools.trim(line);
			if( line.length==0 )
				continue;
			if( !tabbed && line.charAt(line.length-1)!=":" )
				throw "Missing ':' or TAB at line "+l;
			if( tabbed && line.charAt(line.length-1)==":" )
				throw "Unexpected ':' at end of line "+l;
			if( tabbed && lastKey==null )
				throw "Missing key at line "+l;
				
			if( !tabbed ) {
				lastKey = StringTools.trim(line.split(":")[0]);
				keyLines.set(lastKey, l);
				if( h.exists(lastKey) )
					throw "Duplicate key at line "+l;
				h.set(lastKey, new Array());
			}
			else {
				if( line.indexOf("%")>=0 )
					if( line.split("%").length%2==0 )
						throw "Missing '%' at line "+l;
				if( line.indexOf("::")>=0 )
					if( line.split("::").length%2==0 )
						throw "Missing '::' at line "+l;
				h.get(lastKey).push(line);
			}
		}
		
		// Vérification des références
		for( k in h.keys() ) {
			var values = h.get(k);
			for( line in values )
				if( line.indexOf("%")>=0 ) {
					var parts = line.split("%");
					for(i in 0...parts.length)
						if( i%2!=0 && !h.exists(parts[i]) ) {
							throw "Unknown key '"+parts[i]+"' near line "+keyLines.get(k);
						}
				}
		}
		
		return h;
	}
	
	
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
		
		// Parsing
		var f = neko.io.File.getContent(file);
		var raw = haxe.Utf8.sub( f, 1, haxe.Utf8.length(f)-2 );
		var h = new Hash();
		try { h = _parse(raw); }
		catch(e:String) {
			error(e);
		}
		
		// Ajout des champs
		for( id in h.keys() ) {
			var eid = { pos:pos, expr:EConst(CString(id)) };
			fields.push({
				pos : pos,
				name : id,
				access : [APublic],
				doc : null,
				kind : FFun({
					ret : tstring,
					params : [],
					args : [],
					expr : macro {
						return _resolve($eid);
					},
				}),
			});
		}
			
		return fields;
	}
	
	#end
	
}
