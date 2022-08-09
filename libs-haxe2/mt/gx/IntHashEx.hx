package mt.gx;


#if haxe3 
typedef IntHash<T> = haxe.ds.IntMap<T>;
#end


/**
 * ...
 * @author de
 */
class IntHashEx
{
	public static function iterKV<A>( rep : IntHash<A> , f : Int -> A -> Void)
	{
		for(k in rep.keys())
			f( k, rep.get(k));
		return rep;
	}
	
	public static function mapKV<A,B>( rep : IntHash<A> , f : Int -> A -> B)
	{
		var l = new IntHash();
		for(k in rep.keys())
			l.set( k, f( k, rep.get(k)));
		return l;
	}
	
	public static inline function filterA<A>( rep : IntHash<A> , f : A -> Bool)
	{
		var r = [];
		for(v in rep)
			if(f(v))
				r.push( v );
		return r;
	}
}