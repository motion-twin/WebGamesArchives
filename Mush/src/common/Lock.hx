package ;

/**
 * ...
 * @author de
 */

class Lock
{
	var lock : Bool;
	
	public function new(lk : Bool)
	{
		lock = lk;
	}

	public function tryLock() : Bool
	{
		if( lock ) return false;
		
		lock = true;
		return lock;
	}
	
	public function release()
	{
		Debug.ASSERT( lock == true );
		lock = false;
	}
	
}