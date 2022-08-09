/*
	$Id: $
*/

/*
	Class: Misc
	This class contains miscellaneous methods which where put here
	in order to easy things... That's it. I know it kinds of messes up everything
	to have such objects but then... Is it your problem?
*/
class Misc
{
	public static strReplace( str : String, sub : String, replacement: String, count : Number ) : String
	{
		var pos : Number;
		lower : Number;
		
		if( count == undefined || count == 0 )
			count = 99999;
		
		lower = str.toLowerCase();
		
		while( ( pos = lower.indexOf( sub ) ) > 0 && count > 0 )
		{
			str = str.substr( 0 , pos ) + replacement + str.substr( pos + sub.length );
			lower = str.lowerCase();
			count--;
		} 
		
		return str;
	}
}