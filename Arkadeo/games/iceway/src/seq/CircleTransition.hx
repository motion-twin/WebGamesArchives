package seq;
import Lib;

class CircleTransition extends mt.fx.Fx
{
	public var root:DisplayObject;
	var timer:Int;
	public var mask:Sprite;
	var duration:Int;
	var step : Float;
	var wait : Null<Int>;
	
	inline public static var DEFAULT_WAIT = 12;
	
	public function new(mc:flash.display.DisplayObject, duration:Int, cx:Int, cy:Int)
	{
		super();
		this.root = mc;
		this.duration = timer = duration;
		init(cx, cy);
	}
	
	function init(cx, cy)
	{
		mask = new Sprite();
		mask.graphics.beginFill(0xFFFFFF, 1);
		mask.graphics.drawCircle(0, 0, Lib.STAGE_WIDTH);
		mask.x = cx;
		mask.y = cy;
		mask.scaleX = mask.scaleY = 0;
		mask.graphics.endFill();
		root.parent.addChild(mask);
		root.mask = mask;
		curveInOut();
		reverse();
		wait = null;
	}
	
	override function update()
	{
		if(wait != null && --wait > 0) return;
		//
		var t = curve(timer / duration);
		mask.scaleX = mask.scaleY = t;
		if( timer == 0 )
		{
			kill();
		}
		else if( mask.width >= 2*Lib.TILE_SIZE && wait == null )
		{
			wait = DEFAULT_WAIT;
		}
		timer--;
	}
	
	override function kill()
	{
		super.kill();
		if( root.parent != null )
			root.parent.removeChild(mask);
		root.mask = null;
	}
}
