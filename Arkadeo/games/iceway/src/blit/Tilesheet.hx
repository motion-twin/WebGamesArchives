package blit;

import Lib;
import blit.Tile;

class Tilesheet
{
	public var bitmap : BitmapData;
	public var useAlpha(default, null):Bool;
	var _allocX:Int;
	var _allocY:Int;
	var _allocHeight:Int;
	var _smooth:Bool;
	var _space:Int;

	public var width(getWidth, null):Int;
	public var height(getHeight, null):Int;

	static public inline var BORDERS_NONE        = 0x00;
	static public inline var BORDERS_TRANSPARENT = 0x01;
	static public inline var BORDERS_DUPLICATE   = 0x02;
	static public inline var INTERP_SMOOTH       = 0x04;

	public function new(data:BitmapData, flags:Int = BORDERS_NONE)
	{
		bitmap = data;
		_allocHeight = _allocX = _allocY = 0;
		_space = flags & 0x03;
		_smooth = (flags & INTERP_SMOOTH) != 0;
		useAlpha = bitmap.transparent;
	}

	public static function create(inW:Float, inH:Float, inFlags:Int = BORDERS_NONE)
	{
		var bmp = new BitmapData( Std.int(Math.ceil(inW)), Std.int(Math.ceil(inH)),true, 0xFF000000 );
		return new Tilesheet(bmp, inFlags);
	}

	public function addTile(inData:BitmapData, ?position_x:Float=0., ?position_y:Float=0.) : Tile
	{
		var sw = inData.width;
		var sh = inData.height;
		var w = sw + _space;
		var h = sh + _space;
		var tw = bitmap.width;
		var th = bitmap.height;
		if( w >= tw ) return null;
		
		while(true)
		{
			if(_allocY + h > th)
				return null;
			if(_allocX + w < tw)
				break;
			
			_allocY += _allocHeight;
			_allocHeight = 0;
			_allocX = 0;
		}

		var x = _allocX;
		var y = _allocY;
		
		_allocX += w;
		if( h > _allocHeight ) _allocHeight = h;
		if( _space == 2 )
		{
			x++;
			y++;
			bitmap.copyPixels(inData, new Rectangle(0,0,1,1), new Point(x-1,y-1), null, null, true );
			bitmap.copyPixels(inData, new Rectangle(0,0,sw,1), new Point(x,y-1), null, null, true );
			bitmap.copyPixels(inData, new Rectangle(sw-1,0,1,1), new Point(x+sw,y-1), null, null, true );

			bitmap.copyPixels(inData, new Rectangle(0,0,1,sh), new Point(x-1,y), null, null, true );
			bitmap.copyPixels(inData, new Rectangle(sw-1,0,1,sh), new Point(x+sw,y), null, null, true );

			bitmap.copyPixels(inData, new Rectangle(0,sh-1,1,1), new Point(x-1,y+sh), null, null, true );
			bitmap.copyPixels(inData, new Rectangle(0,sh-1,sw,1), new Point(x,y+sh), null, null, true );
			bitmap.copyPixels(inData, new Rectangle(sw-1,sh-1,1,1), new Point(x+sw,y+sh), null, null, true );
		}

		bitmap.copyPixels(inData, new Rectangle(0,0,sw,sh), new Point(x,y), null, null, true );
		return new Tile(this.bitmap, new Rectangle(x, y, sw, sh), new Vec2(position_x, position_y) );
	}

	public function addTileRect(inData:BitmapData, inRect:Rectangle) : Tile
	{
		var bmp = new BitmapData(Std.int(inRect.width), Std.int(inRect.height),true, 0xFF000000 );
		bmp.copyPixels(inData, inRect, new Point(0,0), null, null, true );
		return addTile(bmp);
	}

	public function partition(inTW:Int, inTH:Int, inOffsetX:Int=0, inOffsetY:Int=0, inGapX:Int=0, inGapY:Int=0, ?inLimitX:Int, ?inLimitY:Int ) : Array<Tile>
	{
		var tiles_x = Std.int( (bitmap.width-inOffsetX+inGapX)/(inTW+inGapX) );
		if (inLimitX != null && tiles_x > inLimitX)
			tiles_x = inLimitX;
			
		var tiles_y = Std.int( (bitmap.height-inOffsetY+inGapY)/(inTH+inGapY) );
		if (inLimitY != null && tiles_y > inLimitY)
			tiles_y = inLimitY;

		var result = new Array<Tile>();
		var y = inOffsetY;
		for(ty in 0...tiles_y)
		{
			var x = inOffsetX;
			for(tx in 0...tiles_x)
			{
				result.push(new Tile(this.bitmap, new Rectangle(x,y,inTW,inTH)));
				x += inTW+inGapX;
			}
			y += inTH+inGapY;
		}
		return result;
	}

	inline public function getWidth() : Int { return bitmap.width; }
	inline public function getHeight() : Int { return bitmap.height; }
}