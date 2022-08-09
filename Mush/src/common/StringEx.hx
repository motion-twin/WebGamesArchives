package ;
import mt.Rand;

/**
 * ...
 * @author de
 */

class StringEx
{
	public static inline function contains(str : String,pattern)
		return str.indexOf( pattern ) >= 0;
	
	public static function isBlank( c )
	{
		return c == ' ' || c == '\t' || c == '\r' || c == '\n' || StringTools.fastCodeAt( c, 0) == 160;
	}
	
	public static function trimWhiteSpace( s : String )
	{
		return s.split(" ").join("")
		.split("\r").join("")
		.split("\n").join("")
		
		.split("\t").join("");
	}
	
	public static function filterAlphaNum( s : String )
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
	
	public static function zeroPad( digits : Int, nb : Int) : String
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
	
	public static inline function startsWith(s1, s2)
		return StringTools.startsWith( s1, s2 );
		
	public static function endsWith(s1:String, s2:String)
	{
		return s1.substr( s1.length - s2.length ) == s2;
	}
	
	public static function reverse( str :String ) : String {
		#if neko
		var s = new StringBuf();
		var j=0;
		for ( i in 0...str.length ) {
			j = str.length -i - 1;
			s.addChar( str.charCodeAt(j) );
		}
		return s.toString();
		#else
		var a = str.split("");
		a.reverse();
		return a.join("");
		#end
	}
	
	#if ((flash) || (neko))
	static inline function innScramble<A>( arr : Array<A>, r : mt.Rand ){
		for(x in 0...3 *( arr.length + r.random(arr.length)))
		{
			var b = r.random(arr.length);
			var a = r.random(arr.length);
			var temp = arr[a];
			arr[ a ] = arr[ b ];
			arr[ b ] = temp;
		}
		return arr;
	}
	
	//reindex and interlace
	public static inline function getIndex(seed, nb) : Array<Int>{
		var idx : Array<Int> = [for (i in 0...nb) i];
		var rd = new Rand(seed);
		rd.initSeed(0xdead + 0xbeef + seed - nb + 0x1337);
		innScramble( idx, rd );
		return idx;
	}
	
	public static inline function reindex(str:String,seed:Int){
		var idx = getIndex( seed,str.length );
		var s = new StringBuf();
		for ( i in 0...str.length)
			s.add( str.charAt(idx[i])  );
		return s;
	}
	
	public static inline function deindex(str,seed){
		var idx = getIndex( seed,str.length );
		var a = [];
		for ( i in 0...str.length ) {
			a[idx[i]] = str.charAt(i);
		}
		return a.join("");
	}
	#end
}