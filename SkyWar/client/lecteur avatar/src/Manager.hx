

class Manager {//}


	static var DP_BG = 	1;
	static var DP_GAME = 	2;


	static var _main :{update:Void->Void};
	public static var dm:mt.DepthManager;
	public static var mcLog:{>flash.MovieClip,field:flash.TextField,str:String};


	public static function main(){
		// INIT
		try {
			dm = new mt.DepthManager(flash.Lib._root);
			var mc = dm.empty(DP_GAME);
			_main = cast new Game(mc);
		}
		catch (e:Dynamic){
			haxe.Firebug.trace(Std.string(e));
		}
		flash.Lib._root.onEnterFrame = _main.update;

	}

	// LOG
	public static function log(str){

	}


	//{
}


