class Manager {

	static var root_mc : MovieClip;
	static var mode : { main : void -> void, destroy : void -> void };

	static function init( mc ) {
		if( !KKApi.available() )
			return;
		root_mc = mc;
		if ( KKApi.available() )
		  mode = new Game(root_mc);
		Log.setColor(0x00FF00);
	}

	static function main() {
		Timer.update();
		mode.main();		
	}

}