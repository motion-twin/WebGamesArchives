package ;


using Ex;
/**
 * ...
 * @author de
 */

class FlagsArray<T>
{
	var ba : BitArray;
	var e : Enum<T>;
	
	public function new( e : Enum<T>)
	{
		ba = new BitArray();
		this.e = e;
	}
	
	public function isEmpty() : Bool
	{
		for (v in ba.data)
			if (v != 0)
				return false;
		
		return true;
	}
	
	public inline function get( v : T ) : Bool
	{
		return ba.get( Type.enumIndex( cast v) );
	}
	
	public inline function has( v : T ) : Bool
	{
		return get(v);
	}
	
	public inline function clear()					ba.clear();
	public inline function rawFill(a:Array<Int>)	{ ba.rawFill(a); return this; }
	public function rawData() : Array<Int> 			return ba.rawData();
	
	public inline function fill(v : Bool)
	{
		for (i in e.array())
			set(i,v);
	}

	public inline function set( v : T, b : Bool = true  ) : Void
	{
		ba.set( Type.enumIndex( cast v), b );
	}
	
	public inline function unset( v : T ) : Void
	{
		ba.set( Type.enumIndex(cast v), false );
	}
	
	public inline function readArray( arr : Array<T> ) 
	{
		clear();
		for ( x in arr)
			set( x, true );
			
		return this;
	}

	public function getArray(){
		return e.array().filter( function(i) return ba.get( Type.enumIndex(cast i)));
	}

	public function iterator()
	{
		var l = new List();
		for(x in e.array())
		{
			if( ba.get( Type.enumIndex( cast x ) ))
				l.push(x);
		}
		return l.iterator();
	}
	
	function hxSerialize( s : haxe.Serializer )
	{
		mt.gx.Debug.assert( s != null);
		mt.gx.Debug.assert( e != null);
		s.serialize( Std.string( Type.getEnumName(e) ));
		s.serialize( ba );
    }
	
    function hxUnserialize( s : haxe.Unserializer )
	{
        var p :String = s.unserialize();
		e = cast Type.resolveEnum( p );
		ba = s.unserialize();
    }
	
}