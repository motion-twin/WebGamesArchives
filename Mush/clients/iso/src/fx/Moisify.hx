package fx;

import flash.display.DisplayObject;
import flash.display.Sprite;
import haxe.Timer;

using mt.gx.Ex;

class Moisify extends FX
{
var colTrans : flash.geom.ColorTransform;
	
	var dummy : flash.geom.ColorTransform; 
	var mc : DisplayObject;
	
	public function new( mc : DisplayObject){
		super( 8.0 );
		
		dummy = new flash.geom.ColorTransform();
		colTrans = new flash.geom.ColorTransform();
		
		this.mc = mc;
	}
	
	
	public override function kill(){
		super.kill();
		Timer.delay(function(){
		mc.transform.colorTransform = new flash.geom.ColorTransform();
		},1);
	}
	
	var g = 0.5;
	public override function update()
	{
		var e = super.update();
			
		var ratio = t();
		if( ratio > 0.5){
			g += 0.025;
		}
		if ( g > 1.0) {
			g = 1.0;
		}
		colTrans.mul(g,1.0,g);
		mc.transform.colorTransform = colTrans;
		
		
		
		return e;
	}
}