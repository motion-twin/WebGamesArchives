package ;
import flash.display.Bitmap;
import flash.display.Sprite;

using mt.Std;
using mt.flash.Lib;
class BackgroundView extends Sprite
{
	var clouds:List<Bitmap>;
	public function new() 
	{
		super();
		//
		var bg = new gfx.Background();
		bg.scaleX = Cs.VIEW_WIDTH / bg.width;
		bg.scaleY = Cs.VIEW_HEIGHT / bg.height;
		addChild( bg.flatten(0, true, true) );
		
		clouds = new List();
		for ( i in 0...3 )
		{
			var cloud = new gfx.Clouds();
			cloud.x = mt.MLib.randRange(0, Cs.VIEW_WIDTH);
			cloud.y = mt.MLib.randRange(50, Cs.VIEW_HEIGHT - 50);
			cloud.scale( mt.MLib.frandRange(0.4, 1.0) );
			cloud.randomFrame();
			
			var cloud = cloud.flatten(0, true, true);
			cloud.name = Std.string(mt.MLib.frandRange(0.1, 0.8));			
			clouds.addLast( cloud );
			addChild(cloud);
		}
		
		addEventListener(flash.events.Event.ENTER_FRAME, updateFrame);
	}
	
	function updateFrame(_)
	{
		for ( cloud in clouds )
		{
			cloud.x += Std.parseFloat(cloud.name);
			if ( cloud.x > Cs.VIEW_WIDTH )
				cloud.x = -cloud.width;
		}
	}	
}