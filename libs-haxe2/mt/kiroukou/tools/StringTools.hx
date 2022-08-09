package mt.kiroukou.tools;

class StringTools
{
	inline public static function isAlpha( c : String ) :Bool
	{
		return (c > 'a' && c < 'z') || (c > 'A' && c < 'Z');
	}
	
	inline public static function isNum( c : String ) :Bool
	{
		return (c >= '0' && c <= '9');
	}
	
	inline public static function capitalizeWord( t:String ) :String
	{
		var a = t.charAt(0).toUpperCase();
		return a + t.substr(1);
	}
	
	inline public static function fromBase255(val:String):Int
	{
		var l = val.length;
		var r = 0;
		for(i in 0...l)
		{
			r += val.charCodeAt(i) * Math.floor( Math.pow( 255,  l - i - 1) );
		}
		return r;
	}
	
	inline public static function toIntFromBase2(s:String):Int {
		var l = s.length;
		var n = 0;
		for( i in 0...l )
		{
			if( s.charAt(i) == "1" )
				n |= (1 << (l-1-i));
		}
		return n;
	}
}