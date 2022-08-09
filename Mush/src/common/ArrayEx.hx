import mt.gx.Pair;

class ArrayEx
{
	#if neko
	public static inline function scramble<A>( arr : Array<A>, ?r :neko.Random)
	{
		if ( r == null)
			r = new neko.Random();
			
		for(x in 0...3 *( arr.length + r.int(arr.length)))
		{
			var b = r.int(arr.length);
			var a = r.int(arr.length);
			var temp = arr[a];
			arr[ a ] = arr[ b ];
			arr[ b ] = temp;
		}
		return arr;
	}
	#else
	public static inline function scramble<A>( arr : Array<A>)
	{
		for(x in 0...3 * (arr.length + Std.random(arr.length)))
		{
			var b = Std.random(arr.length);
			var a = Std.random(arr.length);
			var temp = arr[a];
			arr[ a ] = arr[ b ];
			arr[ b ] = temp;
		}
		return arr;
	}
	#end
	
	public static inline function first<A>( arr : Array<A> )
	{
		return arr[0];
	}
	
	public static inline function last<A>( arr : Array<A> )
	{
		return arr[arr.length-1];
	}
	
	public static inline function random<A>( arr : Array<A>
	#if neko
		,?rd:neko.Random
	#end
	) : A
	{
		return
		#if neko
			( rd != null )
			? arr[ rd.int( arr.length) ]
			:
		#end
		arr[ Std.random(arr.length) ];
	}
	
	public static inline function reserve<A>( n : Int ) : Array<A>
	{
		var r = new Array();
		r[n] = null;
		return r;
	}
	
	public static inline function rfind<A>( arr : Array<A>, proc : A->Bool )
	{
		var res = null;
		for ( i in 0...arr.length)
		{
			var idx = arr.length - i - 1;
			if ( proc( arr[idx] ) )
			{
				res = arr[idx]; 
				break;
			}
		}
		return res;
	}
	
	public static inline function clear<A>(  arr : Array<A> )
	{
		arr.splice( 0, arr.length ) ;
	}
	
	public static inline function removeByIndex<A>(  arr : Array<A>,i : Int )
	{
		arr.splice( i, 1 );
	}
	
	//append iterable at end of array and returns this array
	public static function enqueue<A>( a : Array<A>, b : Iterable<A>) : Array<A>
	{
		for(x in b )
			a.push( x );
		return a;
	}
	
	//in place filtering for arrays
	public static inline function strip<A>( a : Array<A>, f:  A -> Bool ) : Array<A>
	{
		var top = a.length -1;
		while( top >= 0 )
		{
			if ( f(a[top])) a.splice( top , 1 );
			top--;
		}
		return a;
	}
	
	/**
	 * add x shallow copy of e in the array
	 * @param	e
	 * @param	nb
	 */
	public static function splat<S>( arr:Array<S>, nb, e)
	{
		for(i in 0...nb) arr.push( Reflect.copy(e) );
		return arr;
	}

	public static function wrap<S>( arr:Array<S>, pre:String, post:String) : Array<String>
	{
		var r = [];
		for( k in arr )
			r.push( pre + k + post );
		return r;
	}
	
	//TODO test me
	public static function bsearch<K,S>( a : Array<S>, key : K, f : K -> S -> Int ) : S
	{
		var st = 0;
		var max = a.length;
		
		var index = - 1;
		while(st < max)
		{
			index = ( st + max ) >> 1;
			var val = a[index];
			
			var cmp = f( key, val);
			if( cmp < 0  )
			{
				max = index;
			}
			else if ( cmp > 0)
			{
				st = index + 1;
			}
			else return val;
		}
		return null;
	}
	
	public static function except<A>( it : Iterable<A>, exc : Iterable<A>)
		return Lambda.filter(it, function( a ) return !Lambda.has(exc, a) );
	
	public static function excepta<A>( it : Iterable<A>, exc : Iterable<A>)
		return Lambda.array( except( it, exc) );
	
	public static inline function pushBack<T>( l : Array<T>, e : T )
	{	l.push(e); return e; }
		
	public static inline function pushFront<T>( l : Array<T>, e : T )
	{	l.unshift(e); return e; }
		
	public static function partition<Elem>( it : Array<Elem>, predicate ) : Pair<Array<Elem>,Array<Elem>>
	{
		var p = new Pair([],[]);
		for ( x in it )
			if(  predicate( x ) )
				p.first.push( x);
			else
				p.second.push( x);
		return p;
	}
	
	public static function removeLast<T>( arr:Array<T> ) : Void
	{
		arr.pop();
	}
	
	public static function best<T>( arr:Array<T>, f : T -> Int )
	{
		if ( arr.length == 0 ) return null;
		else
		{
			var i = 0;
			var idx = 0;
			for ( i in 0...arr.length)
				if ( f(arr[idx]) < f(arr[i] ))
					idx = i;
					
			return  arr[i];
		}
	}
	
	public static function bestNZ<T>( arr:Array<T>, f : T -> Int ) : T
	{
		if ( arr.length == 0 ) return null;
		else
		{
			var cur : Null<Int> = null;
			var idx : Null<Int> = null;
			
			for ( i in 0...arr.length)
			{
				var nv = f(arr[i]);
				
				if ( nv != 0 )
				{
					if ( idx == null)
					{
						idx = i;
						cur = f(arr[idx]);
					}
					else
					{
						if ( nv > cur )
						{
							idx = i;
							cur = nv;
						}
					}
				}
			}
			return (idx != null) ? arr[idx] : null;
		}
	}
	
	public static function worstNZ<T>( arr:Array<T>, f : T -> Int ) : T
	{
		if ( arr.length == 0 ) return null;
		else
		{
			var i = 0;
			var cur : Int = 0;
			var idx : Null<Int>= null;
			for ( i in 0...arr.length)
			{
				var nv = f(arr[i]);
				
				if ( nv != 0 )
				{
					if ( idx == null)
					{
						idx = 0;
						cur = f(arr[idx]);
					}
					else
					{
						if ( nv < cur )
						{
							idx = i;
							cur = nv;
						}
					}
				}
			}
			return (idx != null) ? arr[idx] : null;
		}
	}
	
	
	public static function worst<T>( arr:Array<T>, f : T -> Int )
	{
		if ( arr.length == 0 ) return null;
		else
		{
			var i = 0;
			var idx = 0;
			for ( i in 1...arr.length)
				if ( f(arr[idx]) > f(arr[i] ))
					idx = i;
					
			return  arr[i];
		}
	}
	
	public static function removeAll<A>( a : Array<A>, f:  A -> Bool )
	{
		for( d in a.copy() )
			if( f(d))
				a.remove(d);
	}
}


