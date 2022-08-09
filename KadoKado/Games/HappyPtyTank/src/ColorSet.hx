@:bind
class ColorSet extends flash.display.MovieClip {
	static var NBR = 9;
	var bmp : flash.display.BitmapData;

	public function new(){
		super();
		bmp = new flash.display.BitmapData(Std.int(width), Std.int(height));
		bmp.draw(this);
	}

	public function random() : UInt {
		return getColor(Std.random(NBR));
	}

	public function getColor( index:Int ) : UInt {
		var n = index % NBR;
		return bmp.getPixel(5+10*n, 5);
	}

	public static function setColor( mc:flash.display.Sprite, c:UInt ){
		var ct = new flash.geom.ColorTransform();
		ct.color = c;
		mc.transform.colorTransform = ct;
	}

	public static function setColorBitmap( mc:flash.display.BitmapData, c:UInt ){
		//var ct = new flash.geom.ColorTransform();
		//ct.color = c;
		var r = (c & 0xFF0000) >> 16;
		var g = (c & 0x00FF00) >> 8;
		var b = (c & 0x0000FF);
		//var ct = new flash.geom.ColorTransform(r/255, g/255, b/255);
		var ct = new flash.geom.ColorTransform(r/125, g/125, b/125);
		mc.colorTransform(new flash.geom.Rectangle(0, 0, mc.width, mc.height), ct);
	}
}