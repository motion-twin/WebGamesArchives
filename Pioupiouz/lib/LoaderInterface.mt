class LoaderInterface
{
	static var startGame : void -> void;
	static var loadLevel : (Xml -> void) -> LoadVars;
	static var exitGame : { $time: int, $piouz:int, $pid:String, $theme:int, $soluce:String } -> LoadVars;
	static var saveLevel : String -> (void -> void) -> LoadVars; 

	static function init(){
		startGame = Std.getGlobal("startGame");
		loadLevel = Std.getGlobal("loadLevel");
		exitGame = Std.getGlobal("exitGame");
		saveLevel = Std.getGlobal("saveLevel");
	}
}
