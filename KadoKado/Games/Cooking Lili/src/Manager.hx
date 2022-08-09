class Manager {
	static var _main : Game;

	public static function init(){
		if( KKApi.available()!=true )
			return;

		_main = new Game(flash.Lib.current);
	}

	public static function main() {
//		mt.Timer.update();
		// hack : disable tmod
		mt.Timer.tmod = 1;
		mt.Timer.deltaT = 1 / mt.Timer.wantedFPS;
		_main.update();
	}

}
