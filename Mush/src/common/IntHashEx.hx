
typedef Avg = { len:Int, sum:Float,avg:Null<Float> }
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
	
	public static function mapKVH<T,NT>( rep:IntHash<T>,proc : Int -> T -> NT) : IntHash<NT>
	{
		var l = new IntHash<NT>();
		for ( k in rep.keys() )
			l.set( k, proc( k, rep.get(k) ) );
		return l;
	}
	
	public static function innerCount<A>( x : IntHash<A>  ) : IntHash<Int>
	{
		var rep = new IntHash();
		iterKV( x, function(k,v)
		{
			if(!rep.exists(k))		rep.set( k, 1 );
			else					rep.set( k, 1 + rep.get(k) );
		});
		return rep;
	}
	
	public static function innerSumI<A>( x : IntHash<A> , get : A -> Int) : IntHash<Int>
	{
		var rep = new IntHash();
		iterKV( x, function(k,v)
		{
			if(!rep.exists(k))		rep.set( k, get(v) );
			else					rep.set( k, get(v) + rep.get(k) );
		});
		return rep;
	}
	
	public static function innerSumF<A>( x : IntHash<A> , get : A -> Float) : IntHash<Float>
	{
		var rep = new IntHash();
		iterKV( x, function(k,v)
		{
			if(!rep.exists(k))		rep.set( k, get(v) );
			else					rep.set( k, get(v) + rep.get(k) );
		});
		return rep;
	}
	
	public static function innerAvg<A>( x : IntHash<A> , get : A -> Float,getLen : A -> Int)
	{
		var rep :IntHash<Avg>= new IntHash();
		iterKV( x, function(k,v)
		{
			if(!rep.exists(k))
				rep.set( k, { len:getLen(v), sum:get(v),avg:null } );
			else
			{
				var d = rep.get(k);
				/*
				d.len++;
				d.val += get(v);
				*/
				rep.set(k,{len:d.len + getLen(v), sum:d.sum + get(v), avg:d.avg});
			}
		});
		
		for ( v in rep)
			if ( v.len != 0) v.avg = v.sum / v.len;
			else v.avg = null;
		return rep;
	}
	
}
