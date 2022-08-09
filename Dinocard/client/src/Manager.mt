class Manager {//}

	static var root_mc : MovieClip;
	static var mode : { main : void -> void };
	
	static var speed:int;
	
	static function init( mc ) {
		flash.Init.init()
		Cs.init();
		root_mc = mc;
		speed = 1
		mode = new Game(root_mc);
	}

	static function main() {
		Timer.update();
		for( var i=0; i<speed; i++)mode.main();
	}

//{
}
