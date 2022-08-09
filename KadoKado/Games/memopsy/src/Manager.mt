class Manager {

	static var root_mc : MovieClip;
	static var mode : { main : void -> void, destroy : void -> void };

	static function init( mc : MovieClip ) {
		if( !KKApi.available() )
			return;
		root_mc = mc;
		mode = new Game(mc);
	}

	static function main() {
		Timer.update();
		mode.main();
	}

}