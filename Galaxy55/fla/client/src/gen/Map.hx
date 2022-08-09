package gen;
import Common;

class Map {

	public static function make( level : Level, texBmp : flash.display.BitmapData, ?smoothWater : BlockKind ) {
		var size = level.size << Const.BITS;
		
		// extract color and height maps
		var colors = getColors(texBmp);
		var pixels = new flash.Vector<UInt>(size * size);
		var hvalues = new flash.Vector<UInt>(size * size);
		for( cy in 0...level.size )
			for( cx in 0...level.size ) {
				var c = level.cells[cx][cy];
				var dx = cx << Const.BITS;
				var dy = cy << Const.BITS;
				flash.Memory.select(c.t);
				for( y in 0...Const.SIZE ) {
					var p = dx + (dy + y) * size;
					for( x in 0...Const.SIZE ) {
						var z = Const.ZSIZE - 1;
						var addr = ((x | (y << Const.BITS)) << Const.ZBITS) + z;
						while( z > 0 && flash.Memory.getUI16(addr<<1) == 0 ) {
							z--;
							addr--;
						}
						pixels[p] = colors[flash.Memory.getUI16(addr << 1)];
						hvalues[p] = 0xFF000000 | z | (z << 8) | (z << 16);
						p++;
					}
				}
			}
		if( smoothWater != null ) {
			var p = -1;
			var cwater : UInt= colors[Type.enumIndex(smoothWater)];
			for( y in 0...size ) {
				var yp = y == 0 ? (size - 1) * size : -size;
				var yn = y == size-1 ? - (size - 1) * size  : size;
				for( x in 0...size ) {
					if( pixels[++p] != cwater )
						continue;
					var h = hvalues[p];
					var xp = x == 0 ? size - 1 : -1;
					var xn = x == size-1 ? - (size - 1) : 1;
					hvalues[p + xp] = hvalues[p + xn] = hvalues[p + yp] = hvalues[p + yn] = hvalues[p + xp + yp] = hvalues[p + xp + yn] = hvalues[p + xn + yp] = hvalues[p + xn + yn] = h;
				}
			}
		}
			
		var map = new flash.display.BitmapData(size, size);
		var height = new flash.display.BitmapData(size, size);
		map.setVector(map.rect, pixels);
		height.setVector(height.rect, hvalues);
		return { map : map, height : height };
	}
	
	static var COLORS : flash.Vector<Int> = null;
	public static function getColors(tex:flash.display.BitmapData) {
		if( COLORS != null ) return COLORS;
		COLORS = new flash.Vector();
		var tmp = new flash.display.BitmapData(64*3, 64*3,true,0);
		var mscale = new flash.geom.Matrix();
		mscale.scale(3 / 32, 3 / 32);
		tmp.draw(new flash.display.Bitmap(tex,flash.display.PixelSnapping.ALWAYS,true), mscale);
		for( b in Block.all ) {
			var t = b.tu;
			COLORS.push(0xFF000000 | tmp.getPixel((t & 63) * 3 + 1, (t >> 6) * 3 + 1));
		}
		COLORS[0] = 0xFFFF00FF;
		tmp.dispose();
		return COLORS;
	}
	
}