package mt.gx;

class Pool<T>
{
	var free : List < T >;
	var used : List < T >;
	
	var new_proc : Void->T;
	
	static inline var debug = false;
	
	public function create() : T
	{
		var n = free.pop();
		if ( n == null )
		{
			n = new_proc();
			if (debug) trace("creating");
		}
		else if (debug) trace("reusing");
			
		used.push(n);
		return n;
	}
	
	public inline function nbUsed() return used.length
	public function getUsed() : List<T>
	{
		return used;
	}
	
	public function getFree() : List<T>
	{
		return free;
	}
	
	public function getAll() : List<T>
	{
		return Lambda.concat( used,free);
	}
	
	public inline function destroy( o : T ) : Void
	{
		if (debug) trace("destr");
		
		var ok = used.remove( o );
		if (ok) free.push(o);
		else	if (debug) trace("destr failed to retr src");
	}
	
	public function new( new_proc )
	{
		free = new List<T>();
		used = new List<T>();
		this.new_proc = new_proc;
	}
	
	public function reserve( len : Int )
	{
		for (i in 0...len)
			free.push( new_proc() );
		return this;
	}
	
	public function reset()
	{
		for (o in used) free.push( o );
		used.clear();
	}
	
	public function kill()
	{
		used.clear();
		free.clear();
		
		used = null;
		free = null;
		new_proc = null;
	}
	
}