package ;

/**
 * ...
 * @author de
 */

class ListEx
{

	public static function orderedAdd<A>( it : List<A>, o : A  , order: A -> A -> Bool ) : Void
	{
		if (it.length == 0)
		{
			it.push(o); return;
		}
		
		if ( order( o, it.last() ) )
		{
			it.push(o);
		}
		else
		{
			var old = it.last();
			it.remove( old );
			it.push(o);
			it.push( old );
		}
	}
	
	public static function checkOrder<A>( it : List<A>, order: A -> A -> Bool ) : Bool
	{
		var old = Lambda.list(it);
		
		while( old.length > 1)
		{
			if (!order( old.first(), LambdaEx.nth( old, 1)))
			{
				return false;
			}
			old.pop();
		}
		return true;
	}
	
	public static function random<A>( it : List<A>
	#if neko
	,?rd:neko.Random
	#end
	) : A
	{
		var i : Null<Int>=null;
		#if neko
			if (rd != null) i = rd.int( it.length );
		#end
		if(i==null)
			i = Std.random( it.length );
		return  LambdaEx.nth( it, i );
	}
	
	public static inline function empty<A>() : List<A>
	{
		return new List<A>();
	}
	
	public static inline function from<A>( v : A )  : List<A>
	{
		var l = new List();
		l.push( v );
		return l;
	}
	
	public static function n<A>() : List<A> return new List<A>();
	
	//returns appended list
	public static function append<A>( those : List<A>,  it : Iterable<A> ) : List<A>
	{
		for(x in it )
			those.add( x);
		return those;
	}
	
	public static inline function pushBack<T>( l : List<T>, e : T ) 
	{ l.add(e); return e; }
		
	public static inline function pushFront<T>( l : List<T>, e : T ) 
	{ l.push(e); return e; }
	
	public static inline function best<T>( l:List<T>, f : T -> Int )
	{
		if ( l.length == 0 ) return null;
		else
		{
			var i = 0;

			var idx : Int = 0;
			var elem = null;
			var elV = 0;
			
			for ( el in l)
				if( i != 0)
				{
					var tel = f(el);
					if ( elV < tel )	
					{
						idx = i;
						elem = el;
						elV = tel;
					}
				}
				else 
				{
					idx = 0;
					elem = el;
					elV = f(el);
				}
					
			return elem;
		}
	}
	
	
	public static function unitTest()
	{
		#if debug
		//var l = Lambda.list( [1, 2, 3, 4, 5] );
		//Debug.ASSERT( ListEx.checkOrder( l, function(i, j) return i < j  ) , "not ordered");
		//Debug.ASSERT( !ListEx.checkOrder( l, function(i, j) return i > j  ) , "not ordered");
		
		#end
	}
	
}
