package mt.data;

import haxe.macro.Context;
class MkFat {
	
	/**Does not work...
	public macro static function macroMake(?rootDir:String) {
		return Context.makeExpr(make(rootDir), Context.currentPos());
	}
	*/
	
	#if sys
	public static function make(?rootDir:String) {
		var prefix = null;
		if ( rootDir != null ) {
			Sys.setCwd(rootDir);
			prefix = mt.Std.ArrayStd.last(rootDir.split("/"));
		}
		
		var d : Array<Dynamic> = [];
		var fat : Dynamic = { fs:d };
		var loop = null;
		loop = function(path:String) {
			try{
				if ( sys.FileSystem.isDirectory(path) ) {
					for ( d in sys.FileSystem.readDirectory(path))
						if( d != "." && d!="..")
							loop( path + "/" + d );
				}
				else 
					d.push( { path: prefix!=null?prefix+"/"+path:path, sig: Std.string(haxe.crypto.Crc32.make( sys.io.File.getBytes(path))) } );
			}
			catch (d:Dynamic) {
				#if neko
				neko.Web.logMessage( "error:" + d+" at "+path);
				#else
				
				#end
			}
		}
		
		for ( d in sys.FileSystem.readDirectory("."))
			loop(d);
			
		var str = haxe.Json.stringify(fat);
		
		#if debug
		str = mt.deepnight.HaxeJson.prettify(str);
		#end
			
		return str;
	}
	
	public static function main() {
		Sys.print(make(Sys.args()[0]));
	}
	#end
}