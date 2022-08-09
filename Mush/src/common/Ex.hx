#if neko 
import Protocol;
#end

typedef EmbedArrayEx = ArrayEx;
typedef EmbedLambda = Lambda;
typedef EmbedLambdaEx = LambdaEx;
typedef EmbedListEx = ListEx;
typedef EmbedEnumEx = EnumEx;
typedef EmbedMathEx = MathEx;
typedef EmbedHashEx = HashEx;
typedef EmbedIntHashEx = IntHashEx;
typedef EmbedStringEx = StringEx;
typedef EmbedOption<A> = Option<A>;
typedef Rd = RandomEx;
typedef EmbedDateEx = DateEx;

#if js
typedef EmbedJqEx = JqEx;
#end

#if neko
typedef EmbedNekoEx = NekoEx;
typedef EmbedObjectEx= ObjectEx;
#end

#if flash
typedef EmbedAs3Tools = As3Tools;
#end

@:publicFields
class Ex 
{
	public static inline function whether<A,B>( d : A , f : A->B, dfl : B = null )
	{
		return ( d == null) ? dfl
		: f(d);
	}
	
	public static inline function dflt<B>( d : Null<B> , dfl : B )
	{
		return ( d == null) ? dfl
		: d;
	}
	
	public static inline function assert<B>( d : Null<B> , msg:String = "" )
	{
		if ( d == null)
		{
			throw "assert "+msg;
		}
		else return d;
	}
	
}

#if neko
class DeathIdEX { public static inline function data(d:DeathId) return Protocol.deathList[Type.enumIndex(d)];  }
class HeroIdEX 	{ public static inline function data(d:HeroId) 	return Protocol.heroesList[Type.enumIndex(d)];  }
class RoomIdEX 	{ public static inline function data(d:RoomId) 	return Protocol.roomList[Type.enumIndex(d)];  }
#end