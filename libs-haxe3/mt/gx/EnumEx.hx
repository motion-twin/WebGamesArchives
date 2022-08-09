package mt.gx;

/**
 * ...
 * @author de
 */
import haxe.EnumFlags;
using mt.gx.Ex;
class EnumEx
{
	public static inline function random<A>(  e : Enum<A> #if flash, ?rd : mt.Rand #end) : A
	{
		return array(e).random(#if flash rd #end );
	}
	
	public static inline function next<A>( v : A , e:Enum<A> ) : A
	{
		var len = Type.allEnums(e).length;
		return Type.createEnumIndex( e,(index( cast v ) + 1 ) % len );
	}
	
	public static inline function previous<A>( v : A , e:Enum<A> ) : A
	{
		var len = Type.allEnums(e).length;
		return Type.createEnumIndex( e,(index( cast v ) + (len-1) ) % len );
	}
	
	public static inline function array<A>(e : Enum<A>)
	{
		return Type.allEnums(e);
	}
	
	@:allowConstraint
	public static function flags2List<A:EnumValue>( e : Enum<A> , f : EnumFlags<A>) :  List<A>
	{
		var res = new List<A>();
		for ( ef in Type.allEnums(e) )
			if( f.has(ef ) )
				res.push( ef );
		return res;
	}
	

	public static function iterator<A> (e : Enum<A> )
	{
		return Type.allEnums(e).iterator();
	}
	
	@:allowConstraint
	public static function iterFlags<A:EnumValue>( e : Enum<A>, f : EnumFlags<A> , p : A -> Void )
	{
		for ( ef in Type.allEnums(e) )
			if( f.has( ef ) )
				p( ef );
	}
	
	public static inline function index(v : EnumValue ) : Int
	{
		return Type.enumIndex(v);
	}
	
	public static function createI<A>( e:Enum<A>, v : Int ) : A
	{
		return Type.createEnumIndex(e,v);
	}
	
	public static function parseInt<A>( e:Enum<A>, s : String ) : A
	{
		return Type.createEnumIndex(e, Std.parseInt(s) );
	}
	
	public static function createS<A>( e:Enum<A>, v : String ) : A
	{
		return Type.createEnum(e,v);
	}
	
	public static function str<A>(v:A) : String
	{
		return Std.string( v );
	}
	
	#if !js
	public static function length<A>(v:Enum<A>) : Int
	{
		return Type.allEnums(v).length;
	}
	#end
}