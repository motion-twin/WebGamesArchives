
class Log {

	public static dynamic function add( v : Dynamic, ?pos : #if debug haxe.PosInfos #else Dynamic #end ) {
		haxe.Log.trace(v, pos);
	}
	
	public static dynamic function debug( v : Dynamic, ?pos : #if debug haxe.PosInfos #else Dynamic #end ) {
	}
	
}