package algo;

/**
 * ...
 * @author de
 */

class MultiEnumHash<K,T>
{
	var rep : EnumHash < K, List<T> > ;
	
	public inline function new(k  : Enum<K>) 
	{
		rep = new EnumHash( k );
	}
	
	public inline function set(k:K,v:T)
	{
		if ( !rep.exists( k ) )
			rep.set( k, new List());
		
		var lv = rep.get(k);
		lv.add(v);
		rep.set( k, lv);
	}
	
	public inline function get(k:K)
	{
		return rep.get(k);
	}
	
	public inline function exists(k)
	{
		if ( !rep.exists( k )) return false;
		if ( rep.get(k).length == 0) return false;
		return true;
	}
}