package ;
import flash.display.Sprite;
using mt.flash.Lib;
class TopView extends Sprite
{

	public function new() 
	{
		super();
		//
		var bg = new gfx.Render();
		bg.scaleX = flash.Lib.current.stage.stageWidth / bg.width;
		bg.scaleY = flash.Lib.current.stage.stageHeight / bg.height;
		addChild( bg );
		
		var bg = new gfx.Rays();
		bg.scaleX = flash.Lib.current.stage.stageWidth / bg.width;
		bg.scaleY = flash.Lib.current.stage.stageHeight / bg.height;
		addChild( bg );
		
		this.flatten(0, true, true);
	}
	
}