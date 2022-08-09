package fx;

using mt.gx.Ex;

class Shade2 extends mt.fx.Fx
{
	static var ALL = [];
	var bmp :  flash.display.Bitmap;
	var timer = 0;
	var dur  = 0;
	
	var alphaStart = 0.6;
	var ct : flash.geom.ColorTransform;
	var basecol : Int;
	public function new(mc, timer, col ) 
	{
		super();
		bmp = mt.deepnight.Lib.flatten( mc,null,0,true );
		bmp.putAfter( mc );
		
		ct = new flash.geom.ColorTransform();
		ct.mul(0.2,0.2,0.2);
		ct.ofs(col >> 16, (col >> 8) & 0xFF, col & 0xFF);
		
		bmp.transform.colorTransform = ct; 
		bmp.blendMode = OVERLAY;
		//bmp.alpha = alphaStart;
		this.timer = timer;
		basecol = col;
		dur = timer;
		ALL.pushBack(this);
	}
	
	public override function update()
	{
		super.update();
		
		var r = 1.0 - (timer / dur);
		
		if ( timer-- <= 0)
			kill();
		else
		{
			var c = mt.deepnight.Color.desaturateInt( basecol, r );
			ct.ofs( c >> 16, (c >> 8) & 0xFF, c & 0xff,0 );
			bmp.transform.colorTransform = ct;
			bmp.alpha = 0.1 + alphaStart * (1.0 - r);
			//bmp.alpha = 0.5;
		}
	}
	
	public override function kill()
	{
		super.kill();
		bmp.detach();
		bmp.bitmapData.dispose();
		bmp.bitmapData = null;
		bmp = null;
		ALL.remove(this);
	}
}