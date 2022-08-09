package mt.kiroukou.compress;
/**
* Compresses and decompresses text with the LZW algorithm.
*/
using StringTools;
class LZW
{
	public static function encode(src:String):String
	{
		var original = src;
		var dict = new Hash<Int>();
		var count = 257;
		for( i in 0...count )
			dict.set( String.fromCharCode(i), i);
			
		var result = new haxe.Utf8();
		var w = original.charAt(0);
		for( i in 1...original.length )
		{
			var c = original.charAt(i);
			if( !dict.exists(w + c) )
			{
				result.addChar( dict.get(w) );
				dict.set(w + c, count++);
				w = c;
			}
			else
			{
				w += c;
			}
		}
		result.addChar( dict.get(w) );
		return result.toString();
	}

	public static function decode(src:String):String
	{
		var original = src;
		var dict = new IntHash<String>();
		var count = 257;
		for( i in 0...count )
			dict.set( i, String.fromCharCode(i) );
		var charCodeAt = callback(haxe.Utf8.charCodeAt, original);
		var length = haxe.Utf8.length(original);
		var buffer = dict.get( charCodeAt(0) );
		var result = buffer;
		for( i in 1...length )
		{
			var code = charCodeAt(i);
			var p = if( code > 255  )
						if( dict.exists(code) ) dict.get(code);
						else buffer + buffer.charAt(0);
					else
						String.fromCharCode(code);
			
			result += p;
			dict.set( count++, buffer + p.charAt(0) );
			buffer = p;
		}
		return result;
	}
}
