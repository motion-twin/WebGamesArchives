

class Loader {
	var map : Map ;

	function new( root : flash.MovieClip ) {
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
		
		map = new Map(root) ;
		flash.Lib.current.onEnterFrame = map.loop ;
	}
	
	
	static function main() {
		new Loader(flash.Lib.current) ;
	}
	
}