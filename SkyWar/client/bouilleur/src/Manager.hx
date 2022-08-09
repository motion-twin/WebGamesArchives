

class Manager {//}


	static var DP_BG = 	0;
	static var DP_GAME = 	1;


	static var _main :{update:Void->Void};
	public static var dm:mt.DepthManager;
	public static var mcLog:{>flash.MovieClip,field:flash.TextField,str:String};


	public static function main(){

		// INIT
		dm = new mt.DepthManager(flash.Lib._root);
		_main = cast new Game(dm.empty(DP_GAME));
		flash.Lib._root.onEnterFrame = _main.update;


	}

	// LOG
	public static function log(str){

	}


	//{
}


