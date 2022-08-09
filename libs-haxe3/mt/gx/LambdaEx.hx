package mt.gx;
import haxe.ds.EnumValueMap.EnumValueMap;
/**
 * ...
 * @author de
 */

using Lambda;

class LambdaEx{
	#if neko
	public static inline function scramble<A>( it : Iterable<A>, ?r :neko.Random) : List<A>
	{
		if ( r == null) r = new neko.Random();
		var arr = Lambda.array( it );
		for(x in 0...arr.length*2)
		{
			var b = r.int(arr.length);
			var a = r.int(arr.length);
			var temp = arr[a];
			arr[ a ] = arr[ b ];
			arr[ b ] = temp;
		}
		return Lambda.list( arr);
	}
	#else
	public static inline function scramble<A>( it : Iterable<A>) : List<A>
	{
		var arr = Lambda.array( it );
		for(x in 0...arr.length*2)
		{
			var b = Std.random(arr.length);
			var a = Std.random(arr.length);
			var temp = arr[a];
			arr[ a ] = arr[ b ];
			arr[ b ] = temp;
		}
		return Lambda.list( arr);
	}
	#end
	
	/**
	 *
	 **/
	public static function find<Elem>( it : Iterable<Elem>, predicate : Elem -> Bool, ? dflt : Elem ) : Null<Elem>
	{
		for ( x in it )
			if(  predicate( x ) )
				return x;
		return dflt;
	}
	
	public static function sum<Elem>( it : Iterable<Elem>, valFunc : Elem -> Int ) : Int
	{
		var v = 0;
		for ( x in it ) v += valFunc( x );
		return v;
	}
	
	public static function avg<Elem>( it : Iterable<Elem>, valFunc : Elem -> Int ) : Float
	{
		var len = Lambda.count( it );
		if ( len == 0 ) return 0;
		
		var v = 0;
		for ( x in it ) v += valFunc( x );
		return v / len;
	}
	
	public static function locate<Elem,Something>( it : Iterable<Elem>, predicate : Elem -> Null<Something>, ? dflt : Something ) : Null<Something>
	{
		for ( x in it )
		{
			var o  = predicate( x );
			if ( o != null)
				return o;
		}
		return dflt;
	}
	
	public static function test<Elem>( it : Iterable<Elem>, predicate : Elem -> Bool ) : Bool
	{
		for ( x in it )
			if(  predicate( x ) )
				return true;
		return false;
	}
	
	public static function allTrue<Elem>( it : Iterable<Elem>, predicate : Elem -> Bool ) : Bool
	{
		for ( x in it )
		{
			if(  !predicate( x ) )
				return false;
		}
		return true;
	}
	
	//first in pair is the valid predicate set, second is the wrong
	public static function partition<Elem>( it : Iterable<Elem>, predicate ) : Pair<List<Elem>,List<Elem>>
	{
		var p = new Pair(new List(),new List());
		for ( x in it )
			if(  predicate( x ) )
				p.first.add( x);
			else
				p.second.add( x);
		return p;
	}
	
	/**
	 *
	 **/
	public static function nth<Elem>( it : Iterable<Elem>, n : Int , ?dflt) : Elem
	{
		var i = 0;
		for ( x in it )
		{
			if( i == n )
				return x;
			i++;
		}
		return dflt;
	}
	
	public static function first<Elem>( it : Iterable<Elem>, ?dflt) : Elem
	{
		return nth(it,0,dflt);
	}
	
	public static function nullStrip<A>( it : Iterable<A>) : List<A>
	{
		return Lambda.filter(it, function(x:A) { return (x != null); } );
	}
	
	public static function reverse<A>( it : Iterable<A>) : List<A>
	{
		var l = new List();
		for(x in it)
			l.push( x);
		return l;
	}
	
	//lookup iterable for first match, apply proc and exit
	public static function when<A>( it :Iterable<A> , match : A ->Bool , proc : A -> Void ) : Void
	{
		for ( x in it )
			if( match(x) )
			{
				proc( x );
				return;
			}
	}
	
	public static function singletons<A>( it : Iterable<A> , ?eqFunc : A -> A -> Bool) : List<A>
	{
		var infer = new List<A>();
		Lambda.iter(
			it,
			function(x)
			{
				//if ( !Lambda.has(infer, x , eqFunc) )
				if ( eqFunc == null )
				{
					if ( Lambda.has( infer, x ) == false ) infer.add(x);
				}
				else
				{
					var exist = false;
					for ( e in infer )
					{
						if ( eqFunc(x, e) )
						{
							exist = true;
							break;
						}
					}
					if(!exist) infer.add(x);
				}
			}
		);
		return infer;
	}
	
	public static function range<A>( it : Iterable<A>, min:Int,max:Null<Int> ) : List<A>
	{
		var l = new List();
		var i = 0;
		for( k in it )
		{
			if ( i >= min)
				l.add( k );
			i++;
			if ( i == max)
				break;
		}
		
		return l;
	}
	
	public static function packSimilar<A>( it : Iterable<A>, ?eq : A->A->Bool) : List<{v:A,nb:Int}>
	{
		var a = new List();
		
		if ( eq == null)
			eq = function(a, b) return a == b;
			
		for ( v in it)
		{
			if ( a.last() == null )
				a.add( { v:v, nb:1 } );
			else if ( eq(a.last().v , v) )
				a.last().nb++;
			else
				a.add( { v:v, nb:1 } );
		}
		
		return a;
	}
	
	public static function removeOne<A>( it : Iterable<A> , testFunc :  A -> Bool) : List<A>
	{
		var res = new List<A>();
		var done = false;
		for (x in it)
		{
			if(!done && testFunc(x))
				done = true;
			else
				res.push(x);
		}
		return res;
	}
	
	//inject n times na elem
	public static function inject<A>( it : Array<A>, n : Int , v : A)
	{
		for (x in 0...n)
			it.push(v);
		return it;
	}
	
	public static function head<A>( it : Iterable<A>, n : Int ) : List<A>
	{
		var i = 0;
		var l = new List();
		for ( e in it )
		{
			if ( i >= n ) return l;
			l.add( e );
			i++;
		}
		
		return l;
	}
	
	public static function tail<A>( it : Iterable<A>, n : Int ) : List<A>
	{
		var i = 0;
		var len = Lambda.count( it );
		return Lambda.filter( it, function(x) return( i++ >= (len - n ) ) );
	}
	
	//return a subset of the array of length n
	public static function randomSubset<A>( it : Array<A> , n : Int) : List<A>
	{
		var len = it.length;
		var res = new List();
		var mark = new Array<Bool>();
		
		LambdaEx.inject(mark, it.length, true );
		
		while( n > 0)
		{
			for (x in 0...it.length)
			{
				if ( 	(Std.random( len ) == 0 )
				&&		mark[x])
				{
					res.push( it[x] );
					n--;
					mark[x] = false;
				}
			}
		}
		
		return res;
	}
	
	public static function sortAbsOrder<A>( it : Iterable<A> , order : A -> A -> Bool ) : List<A>
	{
		var arr = Lambda.array( it );
		var f =
		function(x, y)
		{
			if( order(x,y) )
			{
				return -1;
			}
			else
			{
				return 1;
			}
		}
		
		arr.sort(f);
		
		return Lambda.list(arr);
	}
	
	public static function sortRelOrder<A>( it : Iterable<A> , order : A -> A -> Int ) : List<A>
	{
		var arr = Lambda.array( it );
		
		arr.sort(order);
		
		return Lambda.list(arr);
	}
	
	public static function random<A>( it : Iterable<A>
	#if neko
	,?rd:neko.Random
	#else
	,?mr:mt.Rand
	#end
	
	) : A
	{
		var i : Null<Int> = null;
		
		#if neko
		if (rd != null) i = rd.int( Lambda.count(it) );
		#else
		if ( mr != null ) i = mr.random( Lambda.count( it ));
		#end
		
		if (i == null) i = Std.random( Lambda.count(it) );
		
		return  LambdaEx.nth( it, i );
	}
	
	//returns whence first is found
	public static inline function findIndex<A>( it : Iterable<A>, p : A -> Bool ) : Null<Int>{
		var i = 0;
		var found = false;
		for( x in it){
			if ( p(x) ){
				found=true;
				break;
			}
			i++;
		}
		return found?i:null;
	}
	
	public static inline function wrap<A>( x : A )
	{
		var l = new List();
		l.push( x );
		return l;
	}
	
	public static inline function unwrap<A>( i : Iterable<Iterable<A>> ) : Iterable<A>
	{
		var l = new List();
		for (x in i )
			for ( y in x )
				l.add( y );
		return l;
	}
	
	public static function dispatch<A>( x : Iterable<A> , f : A -> Int) : haxe.ds.IntMap<List<A>>
	{
		var rep = new haxe.ds.IntMap();
		
		for(e in x)
		{
			var i = f( e );
			if(!rep.exists(i))
				rep.set( i, new List());
			rep.get(i).add(e);
		}
		return rep;
	}
	
	public static function dispatchA<A>( x : Iterable<A> , f : A -> Int) : haxe.ds.IntMap<Array<A>>
	{
		var rep = new haxe.ds.IntMap();
		
		for(e in x)
		{
			var i = f( e );
			if(!rep.exists(i))
				rep.set( i, []);
			rep.get(i).push(e);
		}
		return rep;
	}
	
	public static function dispatchByEnum<A,E:EnumValue>( x : Iterable<A>, f : A -> E) : EnumValueMap<E,List<A>>{
		var rep = new haxe.ds.EnumValueMap();
		for(v in x)
		{
			var e = f( v );
			if(!rep.exists(e))
				rep.set( e, new List());
			rep.get(e).add(v);
		}
		return rep;
	}
	
	public static function dispatchByEnumA<A,E:EnumValue>( x : Iterable<A>, f : A -> E) : EnumValueMap<E,Array<A>>{
		var rep = new haxe.ds.EnumValueMap();
		for(v in x)
		{
			var e = f( v );
			if(!rep.exists(e))
				rep.set( e, []);
			rep.get(e).push(v);
		}
		return rep;
	}
	
	public static inline function flatten<A>( x : Iterable< Iterable<A>> ) : List<A>
	{
		var nl = new List();
		for( l in x )
			for(e in l)
				nl.push( e );
				
		return nl;
	}
	
	public static inline function iso<A>(x : Iterable<A>,p : A->A )
		return Lambda.map( x, p );
		
	public static inline function mapa<A,B>(x : Iterable<A>,p : A->B )  : Array<B>
		return x.map( p ).array();

	
	public static function bestF<T,F>( l:Iterable<T>, f : T -> Float ) : Null<T>
	{
		var velem = null;
		var vw : Null<Float> = null;
		for ( i in l)
		{
			var vwi = f( i );
			if ( velem == null)
			{
				velem = i;
				vw = vwi;
			}
			else if ( vwi > vw)
			{
				velem = i;
				vw = vwi;
			}
		}
				
		return  velem;
	}
	
	public static function worstF<T,F>( l:Iterable<T>, f : T -> Float ) : Null<T>
	{
		var velem = null;
		var vw : Null<Float> = null;
		for ( i in l)
		{
			var vwi = f( i );
			if ( velem == null)
			{
				velem = i;
				vw = vwi;
			}
			else if ( vwi < vw)
			{
				velem = i;
				vw = vwi;
			}
		}
				
		return  velem;
	}
	
}
