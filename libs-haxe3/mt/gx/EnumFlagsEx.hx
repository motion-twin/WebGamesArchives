
package mt.gx;

#if neko 
import haxe.EnumFlags.EnumFlags;
import sys.db.Types;
class SFlagsEx
{
	public static inline function length<T:EnumValue>( h : SFlags<T>)
		return MathEx.log2i( h.toInt() );
		
	public static inline function list<T:EnumValue>( h : SFlags<T>, e : Enum<T>)
	{
		var r = new List();
		for ( v in Type.allEnums( e ))
			if ( h.has(v) )
				r.push( v );
		return r;
	}
}
#end


class EnumFlagsEx
{
	#if !js
	public static inline function length<T:EnumValue>( h : haxe.EnumFlags<T>)
	{ return MathEx.log2i( h.toInt() ); }
	#end	
	
	public static inline function list<T:EnumValue>( h : haxe.EnumFlags<T>, e : Enum<T>)
	{
		var r = new List();
		for ( v in Type.allEnums( e ))
			if ( h.has(v) )
				r.push( v );
		return r;
	}
	
	public static inline function mix<T:EnumValue>(v0:T, ?v1:T, ?v2:T, ?v3:T ){
		var e : haxe.EnumFlags<T>= cast(0);
		e.set(v0);
		if (null == v1) e.set(v1);
		if (null == v2) e.set(v2);
		if (null == v3) e.set(v3);
		return e;
	}
	
	/**
	* test if common bit set is empty
	*/
	public static inline function hasSome<T:EnumValue>( h0 : haxe.EnumFlags<T>, h1 : haxe.EnumFlags<T> ) : Bool{
		return h0.toInt() & h1.toInt() != 0;
	}
	
	/**
	* test if common bit set is empty
	*/
	public static inline function hasAll<T:EnumValue>( h0 : haxe.EnumFlags<T>, h1 : haxe.EnumFlags<T> ) : Bool{
		return h0.toInt() & h1.toInt() == h1.toInt();
	}
	
	
	public static inline function mset<T:EnumValue>(e:haxe.EnumFlags<T>, v0:T, v1:T, ?v2:T, ?v3:T ) {
		e.set( v0 );
		e.set( v1 );
		if (null != v2) e.set(v2);
		if (null != v3) e.set(v3);
		return e;
	}
	
	public static inline function munset<T:EnumValue>(e:haxe.EnumFlags<T>, v0:T, v1:T, ?v2:T, ?v3:T ) {
		e.unset( v0 );
		e.unset( v1 );
		if (null != v2) e.unset(v2);
		if (null != v3) e.unset(v3);
		return e;
	}
	
	public static inline function mhasAll<T:EnumValue>(e:haxe.EnumFlags<T>, v0:T, v1:T, ?v2:T, ?v3:T ) {
		var i = 0;
		
		i |= Type.enumIndex(v0);
		i |= Type.enumIndex(v1);
		
		if(v2!=null) i |= Type.enumIndex(v2);
		if(v3!=null) i |= Type.enumIndex(v3);
		
		return (e.toInt() & i) == i ;
	}
	
	public static inline function mhasSome<T:EnumValue>(e:haxe.EnumFlags<T>, v0:T, v1:T, ?v2:T, ?v3:T ) {
		var i = 0;
		
		i |= Type.enumIndex(v0);
		i |= Type.enumIndex(v1);
		
		if(v2!=null) i |= Type.enumIndex(v2);
		if(v3!=null) i |= Type.enumIndex(v3);
		
		return e.toInt() & i != 0;
	}
	
	
}