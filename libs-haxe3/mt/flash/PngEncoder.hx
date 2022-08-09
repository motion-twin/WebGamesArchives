package mt.flash;

import flash.display.BitmapData;
import flash.utils.ByteArray;

class PngEncoder {

	var crc : Array<UInt>;

	public function new( i : BitmapData ){
		crc = [];
		var c : UInt;
		for (n in 0...256){
			c = n;
			for (k in 0...8)
				if (c & 1 > 0) c = ((0xedb88320) ^ (c >>> 1)) else c = (c >>> 1);
			crc[n] = c;
		}
		img = i;
		init();
	}

	var IDAT : ByteArray;
	var png : ByteArray;
	var line : Int;
	var img : BitmapData;

	function init() : Void {
		png = new ByteArray();
		png.endian = flash.utils.Endian.BIG_ENDIAN;
		// signature
		png.writeUnsignedInt(0x89504e47);
		png.writeUnsignedInt(0x0D0A1A0A);
		var IHDR = new ByteArray();
		IHDR.writeUnsignedInt(img.width);
		IHDR.writeUnsignedInt(img.height);
		IHDR.writeUnsignedInt(0x08060000); // 32bit RGBA
		IHDR.writeByte(0);
		write(png,0x49484452,IHDR);
		IDAT = new ByteArray();
		line = 0;
	}

	public function encode() : ByteArray{
		return encodeLines( img.height );		
	}

	public function encodeLines( nb : Int ) : Null<ByteArray>{
		var max = line + nb;
		if( max > img.height ) max = img.height;
		if (img.transparent){
			for (i in line...max){
				IDAT.writeByte(0); // no filter
				for(j in 0...img.width){
					var p = img.getPixel32(j,i);
					IDAT.writeUnsignedInt(((p&0xFFFFFF) << 8)|(p>>>24));
				}
			}
		}
		else {
			for (i in line...max){
				IDAT.writeByte(0); // no filter
				for(j in 0...img.width){
					var p = img.getPixel(j,i);
					IDAT.writeUnsignedInt((((p&0xFFFFFF) << 8)|0xFF));
				}
			}
		}
		line = max;
		return( line < img.height ) ? null : complete();
	}

 	function complete() : ByteArray{
		IDAT.compress();
		write(png,0x49444154,IDAT);
		// IEND
		write(png,0x49454E44,null);
		return png;
	}

	function write(png:ByteArray, type:UInt, data:ByteArray) {
		var len = 0;
		if (data != null)
			len = data.length;
		png.writeUnsignedInt(len);
		var p = png.position;
		png.writeUnsignedInt(type);
		if (data != null) 
			png.writeBytes(data);
		var e = png.position;
		png.position = p;
		var c = 0xffffffff;
		for (i in 0...(e-p))
			c = (crc[(c ^ png.readUnsignedByte()) & (0xff)] ^ (c >>> 8));
		c = (c ^ (0xffffffff));
		png.position = e;
		png.writeUnsignedInt(c);
	}
}
