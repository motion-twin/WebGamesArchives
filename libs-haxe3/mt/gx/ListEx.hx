package mt.gx;

class ListEx{

	public static function removeAll<A>( a : List<A>, f:  A -> Bool ) : Int	{
		var nb = 0;
		for( d in a )
			if ( f(d)){
				a.remove(d);
				nb++;
			}
		return nb;
	}
	
	@:generic
	public static inline function findAndRemove<A>(it : List<A>, pred: A -> Bool){
		for ( x in it )
			if ( pred(x)  ) {
				it.remove( x );
				break;
			}
	}
	
	public static function nth<Elem>( it : List<Elem>, n : Int , ?dflt) : Elem{
		var i = 0;
		for ( x in it ){
			if( i == n )
				return x;
			i++;
		}
		return dflt;
	}
	
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
		,?nr:neko.Random
	#end
		,?mtr:mt.Rand
		,?mgxr : mt.gx.Rand
	) : A
	{
		inline function rd(x) : Int {
			return
			if ( mgxr != null)
				mgxr.random(x);
			else 
			if ( mtr != null)
				mtr.random(x);
			else 
			#if neko
			if ( nr != null)
				nr.int(x);
			else
			#end
			
			return Std.random( x );
		}
		return  LambdaEx.nth( it, rd(it.length) );
	}
	
	public static inline function empty<A>() : List<A>
	{
		return new List<A>();
	}
	
	public static inline function from<A>( v : A )  : List<A> {
		var l = new List();
		l.push( v );
		return l;
	}
	
	public static function n<A>() : List<A> {
		return new List<A>();
	}
	
	//returns appended list
	public static function append<A>( those : List<A>,  it : Iterable<A> ) : List<A>	{
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
