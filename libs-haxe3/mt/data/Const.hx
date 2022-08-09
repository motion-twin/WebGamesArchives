package mt.data;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class Const {

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

		var content = sys.io.File.getContent(file);
		var data = null;
		try {
			data = haxe.Json.parse( content );
		}catch( e : Dynamic ){
			var i = 0;
			var reg = ~/at position ([0-9]+)/;
			if( reg.match(Std.string(e)) )
				i = Std.parseInt( reg.matched(1) );
			Context.error(Std.string(e), Context.makePosition({file: file, min: i, max: i}));
		}

		var fields = Context.getBuildFields();

		for( f in Reflect.fields(data) ){
			var expr = Context.makeExpr( Reflect.field(data,f), pos );
			var t = Context.toComplexType(Context.typeof(expr));

			fields.push({
				pos: pos,
				name: f,
				access: [APublic, AStatic],
				doc: null,
				meta: null,
				kind: FVar( t, expr )
			});
		}

		fields.push({
			pos: pos,
			name: "__lastUpdate",
			access: [APrivate, AStatic],
			doc: null,
			meta: [{name: ":noCompletion", pos: pos, params: []}],
			kind: FVar( macro :Float, null )
		});

		fields.push({
			pos: pos,
			name: "update",
			access: [APublic, AStatic],
			doc: null,
			meta: null,
			kind: FFun({
				ret: macro:Void,
				params: [],
				args: [{type: macro: String,opt: false, name: "filePath", value: null}],
				expr: macro {
					var mtime = sys.FileSystem.stat(filePath).mtime.getTime();
					if( __lastUpdate != null && mtime == __lastUpdate )
						return;
					
					__lastUpdate = mtime;
					var obj = haxe.Json.parse( sys.io.File.getContent(filePath) );
					for( f in Reflect.fields(obj) )
						Reflect.setField( Const, f, Reflect.field(obj,f) );
				}
			})
		});

		return fields;
	}

	#end


}
