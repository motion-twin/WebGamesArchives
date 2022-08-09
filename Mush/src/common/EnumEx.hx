package ;

/**
 * ...
 * @author de
 */
import haxe.EnumFlags;
using Lambda;
using ArrayEx;

enum Freq
{
	Once;
	NTimes( n : Int);
	Allways;
}

class EnumEx
{

	public static inline function random<A>( e : Enum<A> ) : A
	{
		return array(e).random();
	}
	
	public static inline function next<A:EnumValue>( v : A , e:Enum<A> ) : A
	{
		var len = Type.allEnums(e).length;
		return Type.createEnumIndex( e,(index( cast v ) + 1 ) % len );
	}
	
	public static inline function previous<A:EnumValue>( v : A , e:Enum<A> ) : A
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
	
	public static inline function createI<A>( e:Enum<A>, v : Int ) : A
	{
		return Type.createEnumIndex(e,v);
	}
	
	public static inline function createS<A>( e:Enum<A>, v : String ) : A
	{
		return Type.createEnum(e,v);
	}
	
	public static inline function safeCreateS<A>( e:Enum<A>, v : String ) : A{
		try {
			return Type.createEnum(e, v);
		}catch(d:Dynamic){
			return null;
		}
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

	public static function getOpt<A>( v:Option<A>) : A
	{
		switch(v)
		{
			case Some( b ): return b;
			default: throw "invalid option depackaging";
		}
	}
}