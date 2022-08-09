import haxe.ds.GenericStack in GS;

class Pool<T>
{
	public var free(default,null) : GS < T >;
	public var used(default,null) : GS < T >;
	
	var new_proc : Void->T;
	var del_proc : T->Void;
	
	static inline var debug = false;
	
	public function new( new_proc,?del_proc,?n=0 )
	{
		free = new GS<T>();
		used = new GS<T>();
		
		this.new_proc = new_proc;
		this.del_proc = del_proc;
		if ( n != 0 ) reserve( n );
	}
	
	public function create() : T
	{
		var n = free.pop();
		if ( n == null )
		{
			n = new_proc();
			if (debug) trace("creating");
		}
		else if (debug) trace("reusing");
			
		used.add(n);
		return n;
	}
	
	public inline function getUsed() : GS<T>
		return used;
	
	public inline function getFree() : GS<T>
		return free;
	
	public function getAll() : List<T>
	{
		return Lambda.concat( used,free);
	}
	
	public inline function destroy( o : T ) : Void
	{
		if (debug) trace("destr");
		
		var ok = used.remove( o );
		if (ok) free.add(o);
		else	if (debug) trace("destr failed to retr src");
	}
	
	public function reserve( len : Int )
	{
		for (i in 0...len)
			free.add( new_proc() );
		return this;
	}
	
	public function reset()
	{
		for (o in used) free.add( o );
		used = new GS();
	}
	
	public function kill()
	{
		for (u in used )
			if ( del_proc != null)
				del_proc( u );
		used = new GS();
		
		for (f in free )
			if ( del_proc != null)
				del_proc( f );
		free = new GS();
		
		used = null;
		free = null;
		new_proc = null;
	}
	
}