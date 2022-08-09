import flash.display.MovieClip;
import flash.display.StageQuality;
import Text;

class Main
{
	public static var r : MovieClip;
	static function main()
	{
		flash.Lib.current.stage.scaleMode =  flash.display.StageScaleMode.NO_SCALE;
		//flash.Lib.current.stage.quality = StageQuality.HIGH;
		var root = new flash.display.MovieClip();
		var g = new Game();
		flash.Lib.current.addChild( r=root );
		root.y += 20;
		root.addChild( g );
		
		flash.Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, function(_) g.update(_) );
		
		mt.flash.Key.init();
	}
}