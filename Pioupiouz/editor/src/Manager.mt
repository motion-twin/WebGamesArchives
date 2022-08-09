class Manager {//}

	static var root_mc : MovieClip;
	static var mode : { main : void -> void };
	
	
	static function init( mc ) {
		flash.Init.init()
		Cs.init();
		root_mc = mc;
		mode = new Game(root_mc);

	}

	static function main() {
		Timer.update();
		mode.main();
	}

//{
}
