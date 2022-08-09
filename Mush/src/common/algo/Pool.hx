package algo;
import haxe.FastList.FastList;

/**
 * ...
 * @author de
 */

class Pool<T>
{
	var free : FastList < T >;
	var used : FastList < T >;
	
	public function create() : T
	{
		var n = free.pop();
		if( n == null ) return null;
		used.add(n);
		return n;
	}
	
	public function getUsed()
	{
		return used;
	}
	
	public function getFree()
	{
		return free;
	}
	
	public function getAll()
	{
		return Lambda.concat( used,free);
	}
	
	
	public inline function destroy( o : T ) : Void
	{
		Debug.ASSERT(o!=null);
		var ok = used.remove( o );
		if (ok)
			free.add(o);
	}
	
	public function new(  )
	{
		free = new FastList<T>();
		used = new FastList<T>();
	}
	
	public function reserve( len : Int, new_me : Void->T )
	{
		for (i in 0...len)
			free.add( new_me() );
		return this;
	}
	
	public function reset()
	{
		for (o in used)
		{
			free.add( o );
		}
		used=new FastList<T>();
	}
	
}