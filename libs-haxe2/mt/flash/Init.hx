package mt.flash;

@:noDoc
class Init {
	public static function check() {
		var url = #if flash9 flash.Lib.current.loaderInfo.loaderURL #else flash.Lib._root._url #end;
		var parts = url.split("?");
		parts.shift();
		parts = parts.join("?").split("&");
		for( p in parts ) {
			var v = p.split("=")[0];
			if( v != "" && v != "v" ) throw "Vars not allowed";
		}
	}
}
