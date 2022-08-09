class Manager {

	static var _main : Main;
	
	public static function main() {
		_main = new Main(flash.Lib._root);
		//mt.Timer.tmod_factor = .01;
		var ref = flash.Lib._root.onEnterFrame;
		flash.Lib._root.onEnterFrame = function() { 
			if ( ref != null ) ref(); 
			mt.kiroukou.motion.Tween.updateTweens(1 / 25); 
			_main.update(); 
		}
	}
}
