package mt.gx;

/**
 * ...
 * @author de
 */

class StringEx
{
	public static inline function contains(str : String,pattern : String)
	{	return str.indexOf( pattern ) >= 0; }
	
	public static inline function isBlank( c:String )
	{
		return c == ' ' || c == '\t' || c == '\r' || c == '\n' || StringTools.fastCodeAt( c, 0) == 160;
	}
	
	public static inline function trimWhiteSpace( s : String )
	{
		return s.split(" ").join("")
		.split("\r").join("")
		.split("\n").join("")
		
		.split("\t").join("");
	}
	
	public static inline function filterAlphaNum( s : String )
	{
		var res = new StringBuf();
		for( x in 0...s.length)
		{
			var c = StringTools.fastCodeAt( s, x);
			
			if(		(	c >= 'a'.code
					&&	c <= 'z'.code	)
			
			|| 		(	c >= 'A'.code
					&&	c <= 'Z'.code	)
			
			|| 		(	c >= '0'.code
					&&	c <= '9'.code	)
				)
			{
				res.addChar( c );
			}
		}
		return res.toString();
	}
	
	public static function firstBlankIndex(str) : Int
	{
		for( k in 0...str.length)
			if( isBlank(str.chartAt( k ) ))
				return k;
		return -1 ;
	}
	
	public static inline function zeroPad( digits : Int, nb : Int) : String
	{
		var nbd = Std.string( nb);
		for(i in 0...digits-nbd.length)
			if( nb < MathEx.powi( 10, nb)  )
				nbd = "0" + nbd;
		return nbd;
	}
	
	/**
	 * returns the content between parenthesis
	 */
	public static function readParen( r :String ) 
	{
		var lp = r.indexOf( '(' );
		var rp = r.lastIndexOf( ')' );
		if ( lp < 0 || rp < 0)
			return null;
			
		return r.substr( lp+1, rp - lp - 1 );
	}
	
	public static function parseWord( r , w) 
	{
		if ( r.startsWith( w ))
			return r.sub( w.length );
		else return null;
	}
	
	/**
	 * returns first word encountered [a-zA-Z] ant the rest
	 */
	public static function readWord( r :String ) : { word:String, rest:String}
	{
		var end = 0;
		while ( 	(r.charAt( end ) >= 'a' 
		&&			r.charAt( end ) <= 'z' )
		||			(r.charAt( end ) >= 'A' 
		&&			r.charAt( end ) <= 'Z' )
		&& 			end < r.length)
			end++;
		return { word:r.substr( 0, end), rest:r.substr(end) };
	}
	
	public static inline function replace(str, pat,sub)
	{
		return str.split(pat).join(sub);
	}
	
	public static inline function reverse( str :String ) : String{
		var s = new StringBuf();
		for ( i in 0...str.length ) {
			var j = str.length -i - 1;
			s.addChar( StringTools.fastCodeAt( str,j ));
		}
		return s.toString();
	}
}