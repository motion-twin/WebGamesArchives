class Manager {//}

	static var root_mc : MovieClip;
	static var mode : { main : void -> void, destroy : void -> void };

	static function init( mc ) {
		if( !KKApi.available() )
			return;
		root_mc = mc;
		mode = new Game(root_mc);
	}

	static function main() {
		Timer.update();
		mode.main();
	}
//{
}