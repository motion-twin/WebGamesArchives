package fx;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;

/**
 * ...
 * @author de
 */

class Mosaic extends mt.fx.Fx
{
	public static var me : Mosaic = null;
	var pixelisation : BitmapData; 
	var pixObj : Bitmap;
	var trans : flash.geom.Matrix;
	var timer : Float;
	
	var svParent : DisplayObjectContainer;
	var svObj : DisplayObject;
	
	var svData : { x:Float, y:Float, oldIndex : Int };
	var selfKill : Bool;
	
	public function new( object : DisplayObject, selfKill : Bool ) 
	{
		super();
		this.selfKill = selfKill;
		me = this;
		timer = 0.75;
		
		svParent = object.parent;
		svObj = object;

		svData = { x:svObj.x, y:svObj.y, oldIndex: svParent.getChildIndex( svObj ) };
		svParent.removeChild( svObj );
		
		pixelisation =  new flash.display.BitmapData( flash.Lib.current.stage.stageWidth, flash.Lib.current.stage.stageHeight, true, 0x0 );
		trans = new flash.geom.Matrix();
		pixObj = new flash.display.Bitmap(pixelisation, flash.display.PixelSnapping.AUTO, false);
		svParent.addChildAt( pixObj , svData.oldIndex);
	}
	
	public override function update()
	{
		super.update();
		trans.identity();
		trans.translate( svData.x, svData.y);
		
		var r = timer;// Math.pow( timer , 0.33 );
		r = Math.max( timer, 0.1);
		
		trans.scale(r, r);
		
		pixelisation.fillRect( new flash.geom.Rectangle( 0, 0, flash.Lib.current.stage.stageWidth, flash.Lib.current.stage.stageHeight), 0x0);
		pixelisation.draw( svObj, trans);
		
		pixObj.scaleX = 1.0/r;
		pixObj.scaleY = 1.0/r;
		
		if(timer >= 0.1)
		{
			//timer = timer * 0.92;
			timer -= mt.Timer.deltaT;
		}
		else 
			if( selfKill ) kill();
	}
	
	public override function kill()
	{
		super.kill();
		
		svParent.removeChild( pixObj );
		svParent.addChildAt( svObj, svData.oldIndex );
		
		pixObj = null;
		pixelisation.dispose();
		pixelisation = null;
		
		me =  null;
	}
}