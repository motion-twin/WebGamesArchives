package mt;
class StringEx
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
	
	/**
	 * removes all occurences of prefix
	 */
	inline public static function eat(str:String, prefix:String) {
		var strSpl = str.split(prefix);
		strSpl.shift();
		return strSpl.join(prefix);
	}
}