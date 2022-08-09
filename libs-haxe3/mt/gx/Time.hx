package mt.gx;

class Time 
{
	/**
	 * Continuous delta time in s
	 */
	public var dt = 0.0; 
	
	/** 
	 * continuous delta frame [0...n]
	 */
	public var df = 0.0; 
	
	/**
	 * discrete delta frame for this tick [0...n]
	 */
	public var dfr = 0; 
	
	/**
	 * discrete whole execution frame count
	 * */
	public var fr = 0; 
	
	/**
	 * discrete whole update calls count
	 */
	public var ufr = 0; 
	
	public var prevT = -1.0;
	public var curT = -1.0;
	
	var totalFrame = 0.0;
	var fps : Float = 0.0;
	var timer = 0;
	var delayed : List<{func:Void->Void,end:Int}>;
	var ticked : List<{func:Float->Void,end:Int,dur:Int}>;
	
	public function new(fps : Float = 30.0)
	{
		prevT = haxe.Timer.stamp();
	    curT = haxe.Timer.stamp();
		
		dt = 0.0;
		df = 0.0;
		
		this.fps = fps;
		delayed = new List(); ticked = new List();
	}
	
	public function update()
	{
		var nt = haxe.Timer.stamp();
		
		dt = nt - curT;
		
		//frame correction for loading
		if ( dt > 0.5) dt = 1.0 / fps;
			
		df = fps * dt;
		
		prevT = curT;
		curT = nt;
		
		totalFrame += df;
		
		var ofr = fr;
		fr = Std.int( totalFrame );
		ufr++;
		
		dfr = fr - ofr;
			
		updateDelays(dfr);
	}
	
	
	/**
	 * @param	func	Function to call after *delay* frames
	 * @param	delay	Delay in frames
	 */
	public function delay(func:Void->Void,delay:Int) {
		delayed.push( { func:func, end:ufr+delay} );
	}
	
	/**
	 * @param	func	Function to call every frame with ratio of advancement
	 * @param	delay	Delay in frames
	 */
	public function tick(func:Float->Void,dur:Int) {
		func(0.0);
		ticked.push( { func:func, end:ufr+dur,dur:dur} );
	}
	
	function updateDelays(dfr) {
		for( i in 0...dfr){
			for (a in delayed) {
				if(ufr >= a.end) {
					a.func();
					delayed.remove(a);
				}
			}
			
			for (a in ticked) {
				a.func( 1.0 - ((a.end - ufr) / a.dur) );
				if(ufr >= a.end) {
					ticked.remove(a);
				}
			}
		}
	}
	
	public function clear() {
		delayed.clear();
		ticked.clear();
		timer = 0;
	}
	
	public inline function getFrameRate() return 1.0 / dt;
}