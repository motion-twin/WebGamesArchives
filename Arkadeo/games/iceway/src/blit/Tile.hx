package blit;
import Lib;


using mt.kiroukou.geom.RectangleTools;
class Tile
{
	public static function createFromDrawable( sprite : Sprite, x : Float, y : Float )
	{
		var bounds = sprite.getBounds( sprite );
		var m = new Matrix();
		m.translate( -bounds.x, -bounds.y );
		var bmp = new BitmapData( Std.int(bounds.width + .5), Std.int(bounds.height + .5), true, 0 );
		bmp.draw( sprite, m );
		
		var r = new Rectangle(0, 0, bounds.width, bounds.height );
		return new Tile( bmp, r, new Vec2(x+bounds.x, y+bounds.y) );
	}
	
	public static function createFromBitmap( bmp : Bitmap, x : Float, y : Float )
	{
		var bmp = bmp.bitmapData.clone();
		return new Tile( bmp, bmp.rect, new Vec2(x,y) );
	}
	
	var texture : BitmapData;
	var rect : Rectangle;
	public var position : Vec2;
	
	var outputRect:Rectangle;
	var outputPosition:Point;
	
	public function new(texture : BitmapData, rect : Rectangle, ?position:Vec2)
	{
		this.texture = texture;
		this.rect = rect;
		this.position = position == null ? new Vec2() : position;
		
		this.outputRect = this.rect.clone();
		this.outputPosition = new Point();
	}
	
	public function render( bitmap : BitmapData, scaleFactor:Int = 1 )
	{
		outputRect.cpy(rect);
		outputRect.scale(scaleFactor);
		
		outputPosition.x = position.x * scaleFactor;
		outputPosition.y = position.y * scaleFactor;
		
		bitmap.copyPixels(texture, outputRect, outputPosition);
	}
}