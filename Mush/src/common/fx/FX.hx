package fx;

/**
 * ...
 * @author de
 */

class FX
{
	public var duration : Null<Float>;
	var t0 : Float;
	
	public function new(q : String = null, d : Null<Float>)
	{
		duration = d;
		t0 = StdEx.time();
		FXManager.self.add(q,this);
		
		onKill = function() { };
	}

	public function reset()
	{
		t0 = StdEx.time();
	}

	
	/**
	 * Time ratio [0 ... 1] of the current update
	 * 
	 */
	public inline function t() : Float
	{
		return (StdEx.time() - t0) / duration;
	}
	
	//in seconds
	public function date()
	{
		return (StdEx.time() - t0);
	}
	
	//please only set by terminal user, otherwise override kill
	public dynamic function onKill()
	{
		
	}
	
	public function kill()
	{
		onKill();
		duration = 0;
	}
	
	//return false whence wanna kill
	public function update() :  Bool
	{
		if(duration != null)
		{
			var resp = StdEx.time() <= t0 + duration;
			if( resp == false )
				kill();
			return resp;
		}
		else
		{
			//never expire
			return true;
		}
	}
}