package time;

/**
 * ...
 * @author de
 */

class Spin 
{
	var lim:Int;
	var n:Int;
	public function new(v) 
	{
		n = v;
		lim = n - 1;
	}
	
	//force a true tick next
	public function force()
		n = lim;
		
	//force a full cycle before tick
	public function shallow()
	{
		n = 0; return this;
	}
	
	public function tick() : Bool
	{
		if ( ++n >= lim)
		{
			n = 0;
			return true;
		}
		return false;
	}
}