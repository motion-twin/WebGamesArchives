class Manager {
	static var _main : Game;

	public static function init(){
		if( KKApi.available()!=true )
			return;
		_main = new Game(flash.Lib.current);
	}

	public static function main() {
		mt.Timer.update();
		_main.update();
	}
}
