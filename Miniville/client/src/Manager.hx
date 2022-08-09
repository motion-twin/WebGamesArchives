class Manager {

	static var _main : Game;
	
	public static function main(){
		_main = new Game(flash.Lib._root);
		flash.Lib._root.onEnterFrame = function(){ _main.update(); }
	}
	
}
