package fx;

using mt.gx.Ex;

class Shade extends mt.fx.Fx
{
	static var ALL = [];
	var bmp :  flash.display.Bitmap;
	var timer = 0;
	
	var alphaStart = 0.6;
	var fadeAlpha = true;
	public function new(mc, timer, ?col ) 
	{
		super();
		bmp = mt.deepnight.Lib.flatten( mc,null,0,true );
		bmp.putAfter( mc );
		
		if ( col != null )
		{
			var ct = new flash.geom.ColorTransform();
			ct.mul(0.3,0.3,0.3);
			ct.ofs( col >> 16, (col >> 8) & 0xFF, col & 0xFF);
			
			bmp.transform.colorTransform = ct; 
		}
		bmp.alpha = alphaStart;
		this.timer = timer;
	}
	
	public override function update()
	{
		super.update();
		
		if ( timer-- <= 0)
			kill();
		else
		{
			if( fadeAlpha )
				bmp.alpha -= alphaStart * 1.0 / timer;
		}
	}
	
	public override function kill()
	{
		super.kill();
		bmp.detach();
		bmp.bitmapData.dispose();
		bmp.bitmapData = null;
		bmp = null;
	}
}