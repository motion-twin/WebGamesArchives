/*class Hash<T> extends haxe.ds.StringMap<T> {
	
}
*/

class HashEx
{

	public static function filterKV<T>( rep:Hash<T>, proc : String -> T -> Bool ) : Hash<T>
	{
		var l = new Hash();
		for ( k in rep.keys() )
		{
			var v = rep.get( k );
			if( proc( k, v ) )
				l.set(k, v);
		}
		return l;
	}
	
	public static function mapKV<A,B>( rep : Hash<A> , f : String -> A -> B)
	{
		var l = new Hash();
		for(k in rep.keys())
			l.set(  k, f( k, rep.get(k)));
		return l;
	}
	
	public static function iterKV<A>( rep : Hash<A> , f : String -> A -> Void)
	{
		for(k in rep.keys())
			f( k, rep.get(k));
		return rep;
	}
	
}