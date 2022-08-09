package mt.pix;
import flash.display.BitmapData;
import flash.geom.Rectangle;

class Frame
{
	public static var PT = new flash.geom.Point();
	public var swapX:Bool;
	public var swapY:Bool;
	public var rot:Null<Float>;
	
	public var ddx:Int;
	public var ddy:Int;
	
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var texture:BitmapData;
	public var rectangle:Rectangle;
	
	#if nme 
	public var nmeFr : Int = -1; //make it explode if wrong
	#end

	var _backup : Null<BitmapData>;
	
	public function new( ?text, ?x, ?y, ?w, ?h, fx=false, fy=false, ?rot ) {
		texture = text;
		this.x = x;
		this.y = y;
		this.rot = rot;
		width = w;
		height = h;
		rectangle = new Rectangle(x, y, w, h);
		swapX = fx;
		swapY = fy;
		ddx = 0;
		ddy = 0;
		_backup = null;
	}
	
	/**
	 * Backup the original texture in order to be able to apply transforms to current texture, and then restore to original texture version
	 **/
	public function backup()
	{
		if( _backup == null ) _backup = texture.clone();
		_backup.copyPixels( texture, texture.rect, PT );
	}
	
	/**
	 * restore to original texture if any available
	 ***/
	public function restore()
	{
		if( _backup == null ) return;
		texture.copyPixels( _backup, texture.rect, PT );
	}
	
	public function drawAt(bmp:BitmapData, x:Int, y:Int) {
		var point = new flash.geom.Point( x+ddx , y+ddy );
		bmp.copyPixels(texture, rectangle, point);
	}
	public function drawAtWithAlpha(bmp:BitmapData, x:Int, y:Int) {
		var sp = new Element();
		sp.drawFrame(this, 0, 0);
		var m = new flash.geom.Matrix();
		m.translate(x, y);
		bmp.draw(sp,m);
	}
	
	public function slice(dx,dy,ww,hh) {
		return new Frame(texture, x + dx, y + dy, ww, hh, swapX, swapY, rot);
	}
	
	public function getPix(dx:Int, dy:Int) {
		return texture.getPixel32(x + dx, y + dy);
	}
	
//{
}


