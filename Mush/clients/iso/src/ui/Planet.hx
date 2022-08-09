package ui;

//import flash.display.Shape;
import flash.display.Bitmap;

class Planet extends Bitmap
{
	var bmp : flash.display.BitmapData;
	public var seed : Int;
	
	function getData()
	{
		return Main.actServerData.add.planet;
	}
	
	public function new( bmp : flash.display.BitmapData ,s : Int )
	{
		super();
		mt.gx.Debug.assert( bmp != null);
		this.bmp = bmp;
		bitmapData = bmp;
		seed = s;
		
		//graphics.beginBitmapFill(bmp);
		//graphics.drawRect(0, 0, bmp.width, bmp.height);
		//graphics.endFill();
		
		x = Window.W()-width;
		y = Window.H()-height;
		
		cacheAsBitmap = true;
	}
	
	public function clean()
	{
		bmp.dispose();
		bmp = null;
		if(parent != null)
			parent.removeChild(this);
	}
}