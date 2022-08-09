class Manager {

	static var mode : {
		main : void -> void,
		destroy : void -> void
	};

	static var root_mc : MovieClip;

	static function init( mc ) {
		if( !KKApi.available() )
			return;
		root_mc = mc;
		mode = new Game(root_mc,[4,2,10,8,5,1,1,3]);
	}

	static function main() {
		Timer.update();
		mode.main();
	}

}