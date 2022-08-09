package mt.gx;

/**
 * Uses two tandemed array to provide efficient pooling
 * Resizes by one if pool size is insufficient
 * free and used iteration should test for null
 * 
 * next opt stage, mark used with bits
 */
class Pool<T>
{
	public var free(default,null) : Array< Null<T> >;
	public var used(default,null) : Array< Null<T> >;
	
	public var new_proc : Void->T;
	public var del_proc : T->Void;
	
	static inline var debug = false;
	
	public function new( ?res = 32, new_proc, ?del_proc=null ) {
		free = [];
		used = [];
		this.new_proc = new_proc;
		this.del_proc = del_proc == null ? function(_) { } : del_proc;
		
		reserve(res);
	}
	
	public function create() : T {
		var n = null;
		for ( i in 0...free.length ) 
			if ( free[i] != null) 
			{ 
				n = free[i];
				free[i] = null;
				used[i] = n;
				break;
			}
			
		if ( n == null )
		{
			n = new_proc();
			//both sizes are mirrored;
			free[free.length] = null;
			used[used.length] = null;
			if (debug) trace("creating");
		}
		else if (debug) trace("reusing");
			
		return n;
	}
	
	public function destroy( o : T ) {
		if (debug) trace("destr");
		
		for ( i in 0...used.length) {
			if ( used[i] == o )
			{
				used[i] = null;
				free[i] = o;
				return true;
			}
		}
		
		return false;
	}
	
	
	public function reserve( len : Int ) {
		var ol = free.length;
		for (i in 0...len)
		{
			free[ol+i] = new_proc();
			used[ol + i] = null;
		}
		return this;
	}
	
	
	public function reset() {
		for (i in 0...used.length)
			if( used[i] != null ){
				free[i] = used[i];
				used[i] = null;
			}
			
		//used not containes only nulls
		return this;
	}
	
	/**
	 * frees all memory
	 */
	public function dispose() {
		for ( u in used ) if ( u != null ) del_proc(u);
		for ( f in free ) if ( f != null ) del_proc(f);
		
		used = null;
		free = null;
		new_proc = null;
		del_proc = null;
	}
	
}