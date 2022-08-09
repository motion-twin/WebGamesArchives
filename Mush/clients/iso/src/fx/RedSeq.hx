package fx;

import flash.display.DisplayObject;
import flash.display.Sprite;
import haxe.Timer;

class RedSeq  extends FX
{
	var colTrans : flash.geom.ColorTransform;
	var dummy : flash.geom.ColorTransform;
	
	var mc : DisplayObject;
	
	public function new( q : String = null, mc : DisplayObject)
	{
		super( q, 1.2 );
		dummy = new flash.geom.ColorTransform();
		colTrans = new flash.geom.ColorTransform();
		colTrans.blueMultiplier = 0.3;
		colTrans.greenMultiplier = 0.3;
		colTrans.redOffset = 200;
						
		this.mc = mc;
	}
	
	public function stdTick()
	{
		mc.transform.colorTransform = dummy;
	}
	
	public function redTick()
	{
		mc.transform.colorTransform = colTrans;
	}
	
	public override function kill()
	{
		super.kill();
		Timer.delay( function() mc.transform.colorTransform = new flash.geom.ColorTransform(), 15 );
	}
	
	public override function update()
	{
		var e = super.update();
		
		var step = MathEx.squareSignal( date(), 0.1 );
		
		if ( step ) 	stdTick();
		else 			redTick();
		
		return e;
	}
}