import Protocole;


class Main
{//}

	
	

	public static var root:flash.display.MovieClip;
	public static var dm :mt.DepthManager;

	public static var module:Module;
	
	static function main() {
		haxe.Log.setColor(0xFF0000);
		//
		haxe.Serializer.USE_ENUM_INDEX = true;
		Data.init();
		Gfx.init();
		
		//
		root = flash.Lib.current;
		dm = new mt.DepthManager(root);
		
		
		//
		//new PubSquare();
		new Pub500();
		
		
	}


	
//{
}












