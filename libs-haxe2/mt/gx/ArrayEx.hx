package mt.gx;

/**
 * ...
 * @author de
 */

class ArrayEx
{
	#if neko
	public static inline function scramble<A>( arr : Array<A>, ?r :neko.Random)
	{
		if ( r == null)
			r = new neko.Random();
			
		for(x in 0...arr.length + r.int(arr.length))
		{
			var b = r.int(arr.length);
			var a = r.int(arr.length);
			var temp = arr[a];
			arr[ a ] = arr[ b ];
			arr[ b ] = temp;
		}
	}
	#else
	public static inline function scramble<A>( arr : Array<A>, ? mr : mt.Rand)
	{
		inline function rd()
			return (mr == null) ? Std.random( arr.length ) : mr.random( arr.length );
			
		for(x in 0...arr.length + rd() )
		{
			var b = rd();
			var a = rd();
			var temp = arr[a];
			arr[ a ] = arr[ b ];
			arr[ b ] = temp;
		}
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
		,?mr:mt.Rand
	) : A
	{
		var v =
		#if neko
			( rd != null )
			? arr[ rd.int( arr.length) ]
			:
		#end
		(mr==null)?arr[ Std.random(arr.length) ]:arr[mr.random(arr.length)];
		
		return v;
	}
	
	public static inline function reserve<A>( n : Int ) : Array<A>
	{
		var r = new Array();
		r[n] = null;
		return r;
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
				max = index;
			else if ( cmp > 0)
				st = index + 1;
			else return val;
		}
		return null;
	}
	
	public static function except<A>( it : Iterable<A>, exc : Iterable<A>)
	{
		return Lambda.filter(it, function( a ) return !Lambda.has(exc, a) );
	}
	
	public static function excepta<A>( it : Iterable<A>, exc : Iterable<A>)
	{
		return Lambda.array( except( it, exc) );
	}
	
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
	
	public static function worst<T>( arr:Array<T>, f : T -> Int )
	{
		if ( arr.length == 0 ) return null;
		else
		{
			var idx = 0;
			for ( i in 1...arr.length)
				if ( f(arr[idx]) > f(arr[i] ))
					idx = i;
					
			return  arr[idx];
		}
	}
	
	public static function best<T>( arr:Array<T>, f : T -> Int )
	{
		if ( arr.length == 0 ) return null;
		else
		{
			var idx = 0;
			for ( i in 1...arr.length)
				if ( f(arr[idx]) < f(arr[i] ))
					idx = i;
					
			return  arr[idx];
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
	
	
	public static function removeAll<A>( a : Array<A>, f:  A -> Bool )
	{
		for( d in a.copy() )
			if( f(d))
				a.remove(d);
	}
	
	public static function findAndRemove<A>( a : Array<A>, f:  A -> Bool ) : Null<A>
	{
		var i = LambdaEx.findIndex(a, f);
		if( i == null || i < 0) return null;
		return a.splice( i,1)[0];
	}
	
	//TEST ME
	/*
	public static function bsearch<A>( a : Array<A>, pred : A -> A -> Bool, ?start_index : Int , ?end_index : Int) : Int
	{
		if ( start_index == null) start_index = 0;
		if ( end_index == null ) end_index = a.length;
		
		var middle_index : Int = (start_index + end_index) >> 1;
		
		if (end_index <= start_index)
			return middle_index;
		else
		{
			if ( pred(data[middle_index], value ))
				return bsearch(value, start_index, middle_index);
			else
				return bsearch(value, middle_index + 1, end_index);
		}
	}
	*/
	
	/**
	 * memory conservative add
	 * Finds a null spot and place the object !
	 */
	public static function put<A>(a:Array<A>, elem : A) : Int{
		for ( i in 0...a.length ) {
			if ( a[i] == null ) {
				a[i] = elem;
				return i;
			}
		}
		a[a.length] = elem;
		return a.length - 1;
	}
	
	/**
	 * memory conservative remove
	 * Finds the object and replace by null
	 * the array will be null crippled
	 */
	public static function rem<A>(a:Array<A>, elem : A) : Bool {
		var idx  = -1;
		for ( i in 0...a.length )
			if ( a[i] == elem ) { 
				a[idx=i] = null; 
				break; 
			}
		
		return -1 != idx;
	}
	
	#if haxe_211
		public static function normRand<E:{weight:Int}>( arr : Array<E>
		#if neko 
		, ? r : neko.Random
		#elseif flash
		, ? r : mt.Rand
		#end
		) : Null<Int>
		{
			var sum : Int = {
				var rs = 0;
				for ( p in arr)
					rs += p.weight;
				rs;
			}
			
			var rval : Null<Int> = null;
			
			#if neko
			if (r != null) rval = r.int(sum);
			#elseif flash
			if (r != null) rval = r.random(sum);
			#end
			
			if ( rval == null ) 
				rval = Std.random(sum);
			
			var svrval = rval;
			
			var i = 0;
			for(x in arr)
			{
				rval -= x.weight;
				if(rval < 0) return i;
				i++;
			}
			
			return null;
		}
	#end
	
	public static function unitTest()
	{
		
	}
}


