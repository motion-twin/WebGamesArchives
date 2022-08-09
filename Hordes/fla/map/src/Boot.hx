class Boot {
	public static var man : Manager = null;
	static var debug : flash.TextField;
	static function main() {
		var root = flash.Lib.current;
		
		#if (debug)
		debug = root.createTextField("debug", 2, 0, 0, 400, 200 );
		debug.border = true;
		debug.borderColor = 0x0000FF;
		debug.textColor = 0xFF0000;
		debug.selectable = false;
		debug.tabEnabled = false;
		log( "[DEBUG AREA]" );
		#end
		
		var mc = root.createEmptyMovieClip("mroot", 1);
		man = new Manager(mc);
		mc.onEnterFrame = onEnterFrame;
		
		Reflect.setField(flash.Lib._global, "api", FlashMap);
	}

	static var listeners = new List();
	
	public static function addListener( f : Void -> Void ) {
		listeners.add(f);
	}
	
	public static function removeListener( f : Void -> Void ) {
		listeners.remove(f);
	}
		
	static function onEnterFrame() {
		#if debug
		//debug.text = "";
		#end
		for( f in listeners )
			f();
		man.main();
	}
	
	inline static public function log(msg:Dynamic ) {
		#if debug
		debug.text += msg + "\n";
		debug.scroll = debug.bottomScroll;
		#end
	}

}
