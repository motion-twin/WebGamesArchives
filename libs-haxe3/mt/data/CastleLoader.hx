package mt.data;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class CastleLoader {
	macro public static function getCdb( file : String, resource_name : String ) {
		 	
		var p = Context.currentPos();
		var rname = {expr: EConst(CString(resource_name)), pos: p};

		if( Context.defined("openfl") && !Context.defined("standalone") ){
			var afile = {expr: EConst(CString("assets/"+file)), pos: p};
			return macro (function(){
				var v = haxe.Resource.getString($rname);
				if( v != null )
					return v;
				return openfl.Assets.getText($afile);
			})();
		}else if( !Context.defined("flash") ){
			return macro haxe.Resource.getString($rname);
		}

		var data = haxe.Json.parse(sys.io.File.getContent(Context.resolvePath(file)));
		if ( data == null ) throw "unable to find cdb file : " + resource_name;
		var fields = new Map<String,Bool>();
		function loop(d){
			switch( Type.typeof(d) ) {
			case TObject:
				for( f in Reflect.fields(d) ){
					fields.set(f,true);
					loop(Reflect.field(d,f));
				}
			case TClass(c):
				if( c == Array ){
					var d : Array<Dynamic> = d;
					for( e in d )
						loop(e);
				}
			default:
			}
		}
		loop(data);

		var arr = [];
		for( f in fields.keys() ){
			var sf = {expr: EConst(CString(f)), pos: p};
			var of = macro __unprotect__($sf);

			arr.push( macro $sf => $of );
		}
		var map = {expr: EArrayDecl(arr), pos: p};
		
		return macro mt.data.CastleLoader.convert(haxe.Resource.getString($rname),$map);
	}

	#if flash
	public static function convert( d : String, m : Map < String, String > ) {
		if ( d == null ) throw "unable to find cdb content in >"+d+"<";	
		for( k in m.keys() )
			d = d.split('"$k":').join('"${escape(m.get(k))}":');
		var d : {sheets: Array<{columns: Array<{name: String}>}>} = haxe.Json.parse(d);
		for( sheet in d.sheets )
			for( c in sheet.columns )
				c.name = m.get(c.name);
		var d = haxe.Json.stringify(d);
		return d;
	}

	public static function escape( s : String ) {
		var i = 0;
		var sb = new StringBuf();
		while( true ) {
			var c = StringTools.fastCodeAt(s, i++);
			if( StringTools.isEof(c) ) break;
			switch( c ) {
			case '"'.code: sb.add('\\"');
			case '\\'.code: sb.add('\\\\');
			case '\n'.code: sb.add('\\n');
			case '\r'.code: sb.add('\\r');
			case '\t'.code: sb.add('\\t');
			case 8: sb.add('\\b');
			case 12: sb.add('\\f');
			default:
				if( c < 32 )
					sb.add('\\u'+StringTools.hex(c,4))
				else if( c >= 128 ) 
					sb.add(String.fromCharCode(c))
				else
					sb.addChar(c);
			}
		}
		return sb.toString();
	}
	#end
}
