package mt;

class Timer {

	public static var wantedFPS = 32;
	public static var maxDeltaTime = 0.5;
	public static var oldTime = haxe.Timer.stamp() * 1000.0;
	public static var tmod_factor = 0.95;
	public static var calc_tmod : Float = 1;
	public static var tmod : Float = 1;
	public static var deltaT : Float = 1;
	static var frameCount = 0;
	static var paused = false;

	public inline static function update() {
		if( !paused ) {
			frameCount++;
			
			var newTime_sec = haxe.Timer.stamp();
			var newTime_ms = newTime_sec * 1000.0;
			
			deltaT = (newTime_ms - oldTime) / 1000.0;
			oldTime = newTime_ms;
			if( deltaT < maxDeltaTime )
				calc_tmod = calc_tmod * tmod_factor + (1 - tmod_factor) * deltaT * wantedFPS;
			else
				deltaT = 1 / wantedFPS;
			tmod = calc_tmod;
		}
	}

	public inline static function fps() : Float {
		return wantedFPS/tmod ;
	}
	
	public inline static function pause() {
		paused = true;
	}
	
	public inline static function resume() {
		paused = false;
		oldTime = flash.Lib.getTimer();
	}
	

}
