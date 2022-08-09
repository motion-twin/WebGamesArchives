package mt.gx;

/**
 * ...
 * @author de
 */

class ArrayEx{
	
	public static inline function scramble<A>( arr : Array<A>
	#if neko
		,?nr:neko.Random
	#end
		,?mtr:mt.Rand
		,?mgxr : mt.gx.Rand
	)
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
		
		for(x in 0...arr.length + rd( arr.length ) )
		{
			var b = rd(arr.length);
			var a = rd(arr.length);
			var temp = arr[a];
			arr[ a ] = arr[ b ];
			arr[ b ] = temp;
		}
		
		return arr;
	}
	
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
		
		return arr[rd(arr.length)];
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
	
	/** 
	 *  In place filtering for arrays
	 */
	public static inline function strip<A>( a : Array<A>, f:  A -> Bool ) : Array<A>
	{
		var top = a.length -1;
		while( --top >= 0 )
			if ( f(a[top])) a.splice( top , 1 );
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
	public static function bsearch<K,S>( a : Array<S>, key : K, f : K -> S -> Int ) : S	{
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
	
	public static function removeLast<T>( arr:Array<T> ) : Void {
		arr.pop();
	}
	
	public static function findAndRemove<A>( a : Array<A>, f:  A -> Bool ) : Null<A> {
		var i = LambdaEx.findIndex(a, f);
		if( i == null || i < 0) return null;
		return a.splice( i,1)[0];
	}
	
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
	
	public static function modGet<A>(arr:Array<A>,idx:Int) {
		return arr[ MathEx.posMod( idx , arr.length ) ];
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
	
	
	public static function normRand < E: { weight:Int } > ( arr : Array<E>
	#if neko
		,?nr:neko.Random
	#end
		, ?mtr:mt.Rand
		, ?mgxr:mt.gx.Rand
	) : Null<Int> {
		
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
		
		var sum : Int = {
			var rs = 0;
			for ( p in arr)
				rs += p.weight;
			rs;
		}
		
		var rval = rd(sum);
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
	
	public static function flatten<T>( arr : Array<Array<T>> ):Array<T> {
		var res : Array <T> = [];
		for ( ars in arr )
			for ( a in ars ) 
				res.push( a );
		return res;
	}
	
	public static function head<A>( it : Array<A>, n : Int ) : Array<A>	{
		return it.slice( 0, n );
	}
	
	public static function tail<A>( it : Array<A>, n : Int ) : Array<A>	{
		if ( n < 0 ) {
			return it.slice( -n );
		}
		else if ( n == 0 ) return [];
		else //n>0
		{
			return it.slice( it.length - n );
		}
	}
	
	public static function unitTest()
	{
		
	}
}


