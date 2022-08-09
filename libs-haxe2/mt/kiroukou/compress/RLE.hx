

package mt.kiroukou.compress;

using Lambda;
using mt.kiroukou.tools.StringTools;
class RLE
{
	public static function encode(s:String):String
	{
		var output = "";
		var length = s.length;
		var i = 0;
		while( i < length )
		{
			var l = 1;
			while( i + 1 < length && s.charAt(i) == s.charAt(i + 1) )
			{
				i++;
				l++;
			}
			output += l + "" + s.charAt(i);
			i++;
		}
		return output;
	}
	
	public static function decode(s:String):String
	{
		var output = "";
		var length = s.length;
		var buffer = s.charAt(0);
		for( i in 1...length )
		{
			var char = s.charAt(i);
			if( char.isNum() )
			{
				buffer += char;
			}
			else
			{
				var count = Std.parseInt(buffer);
				for( j in 0...count )
					output += char;
				buffer = "";
			}
		}
		return output;
	}
}