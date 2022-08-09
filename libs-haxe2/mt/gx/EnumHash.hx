package mt.gx;

using mt.gx.Ex;
/**
 * ...
 * @author de
 */

class EnumHash<E,T>
{
	var data : IntHash<T>;
	var e : Enum<E>;
	
	public inline function new( e : Enum<E> ) : Void
	{
		data = new IntHash();
		this.e = e;
	}
	
	public inline function clear()
	{
		data = new IntHash();
	}
	
	public inline function exists( key : E ) : Bool
	{
		return data.exists( Type.enumIndex(cast key) );
	}
	
	public inline function get( key : E ) : Null<T>
	{
		return data.get( Type.enumIndex( cast key ));
	}
	
	public inline function remove( key : E ) : Bool
	{
		return data.remove( Type.enumIndex(cast key));
	}
		
	public inline function set( key : E, value : T ) : Void
	{
		mt.gx.Ex.assert( value , "do you really want to nullify that?" );
		data.set( Type.enumIndex(cast key), value );
	}
	
	public inline  function toString() : String
	{
		var s = "";
		for( e in keys() )
		{
			s += e +" = " + Std.string(get(e)) +" ; ";
		}
		return s;
	}
	
	public inline function getArray()
	{
		return Lambda.array(data);
	}
	
	public inline function iterator() : Iterator<T>
	{
		return data.iterator();
	}
	
	public function keys() : Iterator<E>
	{
		var iter = data.keys();
		return
		{
			next : function() return Type.createEnumIndex( e, iter.next() ),
			hasNext : iter.hasNext
		};
	}
	
	public function iterKV( proc : E -> T -> Void) 
	{
		for ( k in keys() )
			proc( k, get(k) );
	}
	
	public function mapKV<R>( proc : E -> T -> R) : List<R>
	{
		var l = new List();
		for ( k in keys() )
			l.add( proc( k, get(k) ) );
		return l;
	}
	
	public function filterKV( proc : E -> T -> Bool ) : List<T>
	{
		var l = new List();
		for ( k in keys() )
		{
			var v = get( k );
			if( proc( k, v ) )
				l.add( v );
		}
		return l;
	}
	
	function hxSerialize( s : haxe.Serializer )
	{
		s.serialize( Std.string( Type.getEnumName(e) ));
		s.serialize( data );
    }
	
    function hxUnserialize( s : haxe.Unserializer )
	{
        var p :String = s.unserialize();
		e = cast Type.resolveEnum( p );
		data = s.unserialize();
		
    }
	
}