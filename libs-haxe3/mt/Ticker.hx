package mt;

using mt.Std;

enum TickerMode {
	AUTO;
	MANUAL;
}

/**
 * IDeas of improvement.
 * > make ticker not static
 * > make possible to listen in the mode we want in order to keep both in parallel
 */
class Ticker 
{
	public static var global(default, null):Ticker = new Ticker(MANUAL);
	
	public var mode(default, null):TickerMode;
	public var listenersCount(default, null):Int = 0;
	public var deltaTime(default, null):Int = 0;
	
	var initialized:Bool = false;
	var lastTick:Int = -1;
	var listeners : List < Void->Void > = new List();
	public function new(p_mode:TickerMode)
	{
		mode = p_mode;
		init();
	}
	
	function init() 
	{
		if( initialized ) return;
		initialized = true;
		
		switch( mode )
		{
			case AUTO:
				#if (flash || openfl)
				flash.Lib.current.stage.addEventListener(flash.events.Event.ENTER_FRAME, broadcastEvent);
				#else
				throw "AUTO MODE not implemented in that platform";
				#end
			case MANUAL:
		}
	}
	
	function broadcastEvent(_) {
		broadcast();
	}
	
	function clean() {
		if( !initialized ) return;
		initialized = false;
		
		switch( mode )
		{
			case AUTO:
				#if (flash || openfl)
				flash.Lib.current.stage.removeEventListener(flash.events.Event.ENTER_FRAME, broadcastEvent);
				#else
				throw "AUTO MODE not implemented in that platform";
				#end
			case MANUAL:
		}
	}
	
	public function listen( cb : Void->Void )
	{
		//if( !initialized ) init();
		listeners.addLast( cb );
		listenersCount ++;
	}
	
	public function unlisten( cb : Void->Void )
	{
		if( listeners.remove(cb ) )
			listenersCount --;
		
		//if ( listeners.length == 0 ) 
		//	clean();
	}
	
	public function broadcast()
	{
		if( !initialized ) return;
		if( lastTick == -1 ) lastTick = flash.Lib.getTimer();
		
		var currentTick = flash.Lib.getTimer();
		for ( listener in listeners.copy() )
		{
			if( listener != null ) listener();
		}
		
		deltaTime = currentTick - lastTick;
		lastTick = currentTick;
	}
	
	public function dispose()
	{
		clean();
		listeners = new List();
		listenersCount = 0;
	}
}
