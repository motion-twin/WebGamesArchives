package mt.kiroukou.compress;
/*
 * Copyright (C) 2012 Jean-Philippe Auclair
 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
 * Base64 library
 */

import flash.utils.ByteArray;

class Base64
{
	private static inline var _encodeChars:Array<Int> = initEncoreChar();
	private static inline var _decodeChars:Array<Int> = initDecodeChar();
	
	public static function decode( str:String ) : String
	{
		var b = decodeByteArray( str );
		b.position = 0;
		b.uncompress();
		return b.toString();
	}
	
	public static function encode( str:String ) :String
	{
		var b = new flash.utils.ByteArray();
		b.writeUTFBytes( str );
		b.compress();
		return encodeByteArray( b );
	}
	
	public static function encodeByteArray(data:ByteArray):String
	{
		var out:ByteArray = new ByteArray();
		//Presetting the length keep the memory smaller and optimize speed since there is no "grow" needed
		out.length = Std.int((2 + data.length - ((data.length + 2) % 3)) * 4 / 3);
		var i:Int = 0;
		var r:Int = data.length % 3;
		var len:Int = data.length - r;
		var c:UInt; //read (3) character AND write (4) characters
		var outPos:Int = 0;
		while(i < len)
		{
			//Read 3 Characters (8bit * 3 = 24 bits)
			c = data[i++] << 16 | data[i++] << 8 | data[i++];
			
			out[outPos++] = _encodeChars[c >>> 18];
			out[outPos++] = _encodeChars[c >>> 12 & 0x3f];
			out[outPos++] = _encodeChars[c >>> 6 & 0x3f];
			out[outPos++] = _encodeChars[c & 0x3f];
		}
		
		if(r == 1) //Need two "=" padding
		{
			//Read one char, write two chars, write padding
			c = data[i];
			
			out[outPos++] = _encodeChars[c >>> 2];
			out[outPos++] = _encodeChars[(c & 0x03) << 4];
			out[outPos++] = 61;
			out[outPos++] = 61;
		}
		else if(r == 2) //Need one "=" padding
		{
			c = data[i++] << 8 | data[i];
			
			out[outPos++] = _encodeChars[c >>> 10];
			out[outPos++] = _encodeChars[c >>> 4 & 0x3f];
			out[outPos++] = _encodeChars[(c & 0x0f) << 2];
			out[outPos++] = 61;
		}
		
		return out.readUTFBytes(out.length);
	}
	
	public static function decodeByteArray(str:String):ByteArray
	{
		var c1:Int;
		var c2:Int;
		var c3:Int;
		var c4:Int;
		var i:Int = 0;
		var len:Int = str.length;
		
		var byteString:ByteArray = new ByteArray();
		byteString.writeUTFBytes(str);
		var outPos = 0;
		while(i < len)
		{
			//c1
			c1 = _decodeChars[byteString[i++]];
			if(c1 == -1)
				break;
			
			//c2
			c2 = _decodeChars[byteString[i++]];
			if(c2 == -1)
				break;
			
			byteString[outPos++] = (c1 << 2) | ((c2 & 0x30) >> 4);
			
			//c3
			c3 = byteString[i++];
			if(c3 == 61)
			{
				byteString.length = outPos;
				return byteString;
			}
			
			c3 = _decodeChars[c3];
			if(c3 == -1)
				break;
			
			byteString[outPos++] = ((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2);
			
			//c4
			c4 = byteString[i++];
			if(c4 == 61)
			{
				byteString.length = outPos;
				return byteString;
			}
			
			c4 = _decodeChars[c4];
			if(c4 == -1)
				break;
			
			byteString[outPos++] = ((c3 & 0x03) << 6) | c4;
		}
		byteString.length = outPos;
		return byteString;
	}
	
	static function initEncoreChar():Array<Int>
	{
		var encodeChars = new Array<Int>();
		// We could push the number directly
		// but I think it's nice to see the characters (with no overhead on encode/decode)
		var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		for( i in 0...64 )
		{
			encodeChars[i] = chars.charCodeAt(i);
		}
		
		return encodeChars;
	}
	
	static function initDecodeChar():Array<Int>
	{
		var decodeChars = [
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 
			52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, 
			-1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 
			15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, 
			-1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
			41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1, 
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1];
		
		return decodeChars;
	}

}

