package mt.flash;

class DecodeBitmap {
	
	public static function run( b : flash.display.BitmapData ) {
		var n = (b.width + b.height * 51) & 0xFFFFF;
		var h = 5381;
		var mask = new Array();
		for( i in 0...11 ) {
			h = (h << 5) + h + (n & 0xFF);
			h = (h << 5) + h + ((n >> 8) & 0xFF);
			h = (h << 5) + h + ((n >> 16) & 0xFF);
			h = (h << 5) + h + (n >> 24);
			n = (h + i) & 0x3FFFFFFF;
			mask[i] = n & 0xFFFFFF;
		}
		b.lock();
		var i = 0;
		for( y in 0...b.height )
			for( x in 0...b.width )	{
				b.setPixel32(x, y, b.getPixel32(x, y) ^ mask[i%11]);
				i++;
			}
		b.unlock();
	}
	
}