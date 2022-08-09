package ;

/**
 * ...
 * @author de
 */

class TypeEx
{
	//this is VERY costly, use at risk
	public static inline function isPhysEq<A>( a:A, b:A) : Bool
	{
		//Tools.profBegin("isPhysEq");
		var r = Std.string( a ) == Std.string( b );
		//Tools.profEnd("isPhysEq");
		return r;
	}
	
	//this is VERY costly, use at risk
	public static function sameAs<A>( a:A) : A->Bool
	{
		return function(x) return Std.string( x ) == Std.string( a );
	}
	
	public static inline function dynCast<A,B>( a:A, b: Class<B> ) : B
	{
		return 
		if ( Std.is( a, b ))
			cast a; 
		else 
			null;
	}
}