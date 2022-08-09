class Manager {//}

	static var root_mc : MovieClip;
	static var mode : { main : void -> void };


	
	
	static function init( mc ) {

		Log.setColor(0xFFFFFF)
		Cs.init();
		if( !KKApi.available() )
			return;
		root_mc = mc;
		if ( KKApi.available() )
			mode = new Game(root_mc);

	}

	static function main() {
		Timer.update();
		mode.main();
	}

//{
}
