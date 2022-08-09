package mt.gx.time;

import haxe.Timer;

class Ticker 
{
	/**
	 * Continuous delta time
	 */
	public var dt = 0.0; 
	/** continuous delta frame [0...n]
	 */
	public var df = 0.0; 
	
	/**
	 * discrete whole execution frame count
	 * */
	public var fr = 0; 
	
	/**
	 * discrete whole update count
	 */
	public var ufr = 0; 
	
	var totalFrame = 0.0;
	
	public var prevT = -1.0;
	public var curT = -1.0;
	
	var fps : Float = 0.0;
	
	public function new(fps : Float = 30.0)
	{
		prevT = Timer.stamp();
	    curT = Timer.stamp();
		
		dt = 0.0;
		df = 0.0;
		
		this.fps = fps;
	}
	
	public function update()
	{
		var nt = Timer.stamp();
		
		dt = nt - curT;
		
		//frame correction for loading
		if ( dt > 0.5) dt = 1.0 / fps;
			
		df = fps * dt;
		
		prevT = curT;
		curT = nt;
		
		totalFrame += df;
		fr = Std.int( totalFrame );
		ufr++;
	}
}