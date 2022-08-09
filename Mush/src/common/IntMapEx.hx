import haxe.ds.IntMap;

typedef IMEAvg = { len:Int, sum:Float,avg:Null<Float> }

class IntMapEx {
	
	public static function iterKV<A>( rep : IntMap<A> , f : Int -> A -> Void){
		for(k in rep.keys())
			f( k, rep.get(k));
		return rep;
	}
	
	public static function mapKV<A,B>( rep : IntMap<A> , f : Int -> A -> B){
		var l = new IntHash();
		for(k in rep.keys())
			l.set( k, f( k, rep.get(k)));
		return l;
	}
	
	public static function mapKVH<T,NT>( rep:IntMap<T>,proc : Int -> T -> NT) : IntMap<NT>{
		var l = new IntMap<NT>();
		for ( k in rep.keys() )
			l.set( k, proc( k, rep.get(k) ) );
		return l;
	}
	
	public static function innerCount<A>( x : IntMap<A>  ) : IntMap<Int>{
		var rep = new IntMap();
		iterKV( x, function(k,v){
			if(!rep.exists(k))		rep.set( k, 1 );
			else					rep.set( k, 1 + rep.get(k) );
		});
		return rep;
	}
	
	public static function innerSumI<A>( x : IntMap<A> , get : A -> Int) : IntMap<Int>{
		var rep = new IntMap();
		iterKV( x, function(k,v){
			if(!rep.exists(k))		rep.set( k, get(v) );
			else					rep.set( k, get(v) + rep.get(k) );
		});
		return rep;
	}
	
	public static function innerSumF<A>( x : IntMap<A> , get : A -> Float) : IntMap<Float>{
		var rep = new IntMap();
		iterKV( x, function(k,v){
			if(!rep.exists(k))		rep.set( k, get(v) );
			else					rep.set( k, get(v) + rep.get(k) );
		});
		return rep;
	}
	
	public static function innerAvg<A>( x : IntMap<A> , get : A -> Float,getLen : A -> Int){
		var rep :IntMap<IMEAvg>= new IntMap();
		iterKV( x, function(k,v){
			if(!rep.exists(k))
				rep.set( k, { len:getLen(v), sum:get(v),avg:null } );
			else{
				var d = rep.get(k);
				rep.set(k,{len:d.len + getLen(v), sum:d.sum + get(v), avg:d.avg});
			}
		});
		
		for ( v in rep)
			if ( v.len != 0) v.avg = v.sum / v.len;
			else v.avg = null;
		return rep;
	}
	
}