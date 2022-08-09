
package mt.gx;

#if neko 
import sys.db.Types;
class SFlagsEx
{
	public static inline function length<T:EnumValue>( h : SFlags<T>)
		return MathEx.log2i( h.toInt() )
		
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
}