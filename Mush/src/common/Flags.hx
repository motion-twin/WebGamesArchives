class Flags<T>
{
	public var rep : Int;
	
	public function new(v:Int = 0)
	{
		rep = v;
	}
	
	public inline function has( v : T ) : Bool return get(v);
	public inline function get( v : T ) : Bool
	{
		return (rep) & (1 << Type.enumIndex(cast v)) != 0;
	}
	
	public inline function set( v : T ) : Void
	{
		rep |= 1 << Type.enumIndex(cast v);
	}
	
	public inline function unset( v : T ) : Void
	{
		rep &= ~(1 << Type.enumIndex(cast v));
	}
	
	public inline function clear()
	{
		rep = 0;
	}
	
	public inline static function ofInt<T>( i : Int ) : Flags<T>
	{
		var res = new Flags(i);
		return res;
	}
	
	public inline function toInt() : Int {
		return rep;
	}
	
	
	public static inline function test<T>( rep, v : T)
	{
		return (rep) & (1 << Type.enumIndex(cast v)) != 0;
	}
	
}