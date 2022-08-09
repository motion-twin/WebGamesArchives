package mt.kiroukou;

/**
 * A Timebase is a constantly ticking source of time.
 */

#if !macro
class Timebase implements mt.kiroukou.events.Signaler
{
	static var _instance:Timebase = null;
	inline public static function get():Timebase
	{
		return _instance == null ? (_instance = new Timebase()) : _instance;
	}

	/**
	 * Converts <code>x</code> seconds to ticks.
	 */
	inline public static function secondsToTicks(x:Float):Int
	{
		return Math.round(x / get().getTickRate());
	}

	/**
	 * Converts <code>x</code> ticks to seconds.
	 */
	inline public static function ticksToSeconds(x:Int):Float
	{
		return x * get().getTickRate();
	}
	
	
	@:signal
	public function onTick(delta:Float):Void { }
	
	@:signal
	public function onRender(count:Float):Void { }
	
	@:signal
	public function onHalt():Void { }
	
	@:signal
	public function onResume():Void { }
	
	@:signal
	public function onFreezeBegin():Void { }
	
	@:signal
	public function onFreezeEnd():Void { }
	

	var _tickRate:Float;
	var _nTicks:Int;
	var _nFrames:Int;
	var _timeScale:Float;
	var _realTime:Float;
	var _gameTime:Float;
	var _gameTimeDelta:Float;
	var _realTimeDelta:Float;
	var _past:Float;
	var _accumulator:Float;
	var _accumulatorLimit:Float;
	var _freezeDelay:Float;
	var _halted:Bool;

	#if js
	var _requestAnimFrame:Dynamic;
	#end

	function new()
	{
		useFixedTimeStep  = false;
		_tickRate         = 1 / 30;
		_accumulatorLimit = 10 * _tickRate;
		_accumulator      = 0;
		_nTicks           = 0;
		_nFrames          = 0;
		_timeScale        = 1;
		_realTime         = 0;
		_gameTime         = 0;
		_gameTimeDelta    = 0;
		_realTimeDelta    = 0;
		_freezeDelay 	  = 0;
		_past             = _stamp();

		#if (flash || cpp)
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, _onEnterFrame);
		#elseif js
		_requestAnimFrame = function(cb:Dynamic):Void
		{
			var w:Dynamic = js.Lib.window;
			var f:Dynamic =
			if (w.requestAnimationFrame != null)
				w.requestAnimationFrame;
			else
			if (w.webkitRequestAnimationFrame != null)
				w.webkitRequestAnimationFrame;
			else
			if (w.mozRequestAnimationFrame != null)
				w.mozRequestAnimationFrame;
			else
			if (w.oRequestAnimationFrame != null)
				w.oRequestAnimationFrame;
			else
			if (w.msRequestAnimationFrame != null)
				w.msRequestAnimationFrame;
			else
				function(x) { w.setTimeout(x, _tickRate * 1000); };
			f(cb);
		}
		_step();
		#end
	}

	/**
	 * Destroys the system by removing all registered observers and explicitly nullifying all references for GC'ing used resources.
	 * The system is automatically reinitialized once an observer is attached.
	 */
	public function free()
	{
		if (_instance == null) return;
		_instance = null;

		#if (flash || cpp)
		flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, _onEnterFrame);
		#elseif js
		_requestAnimFrame = null;
		#end
	}

	/**
	 * If true, time is consumed using a fixed time step (see <em>Timebase.get().getTickRate()</em>).<br/>
	 * Default is true.
	 */
	public var useFixedTimeStep:Bool;

	/**
	 * The update rate measured in seconds per tick.<br/>
	 * The default update rate is 60 ticks per second (or ~16.6ms per step).
	 */
	inline public function getTickRate():Float
	{
		return _tickRate;
	}

	/**
	 * Sets the update rate measured in ticks per second, e.g. a value of 60 indicates that <em>TimebaseEvent.TICK</em> is fired 60 times per second (or every ~16.6ms).
	 * @param max The accumulator limit in seconds. If omitted, <code>max</code> is set to ten times <code>ticksPerSecond</code>.
	 */
	public function setTickRate(ticksPerSecond:Int, max = -1.):Void
	{
		_tickRate         = 1 / ticksPerSecond;
		_accumulator      = 0.;
		_accumulatorLimit = (max == -1. ? 10 : max * _tickRate);
	}

	/**
	 * Processed time in seconds.
	 */
	inline public function getRealTime():Float
	{
		return _realTime;
	}

	/**
	 * Processed 'virtual' time in seconds (includes scaling).
	 */
	inline public function getGameTime():Float
	{
		return _gameTime;
	}

	/**
	 * Frame delta time in seconds.
	 */
	inline public function getRealTimeDelta():Float
	{
		return _realTimeDelta;
	}

	/**
	 * 'Virtual' frame delta time in seconds (includes scaling).
	 */
	inline public function getGameTimeDelta():Float
	{
		return _gameTimeDelta;
	}

	/**
	 * Returns the current time scale.
	 */
	inline public function getScale():Float
	{
		return _timeScale;
	}

	/**
	 * Scales the time by the factor <code>x</code>.
	 */
	inline public function setScale(x:Float)
	{
		_timeScale = x;
	}

	/**
	 * The total number of processed ticks since the first observer received a <em>TimebaseEvent.TICK</em> update.
	 */
	inline public function getProcessedTicks():Int
	{
		return _nTicks;
	}

	/**
	 * The total number of rendered frames since the first observer received a <em>TimebaseEvent.RENDER</em> update.
	 */
	inline public function getProcessedFrames():Int
	{
		return _nFrames;
	}

	/**
	 * Stops the flow of time.<br/>
	 * Triggers a <em>TimebaseEvent.HALT</em> update.
	 */
	public function halt():Void
	{
		if (!_halted)
		{
			_halted = true;
			dispatchOnHalt();
		}
	}

	/**
	 * Resumes the flow of time.<br/>
	 * Triggers a <em>TimebaseEvent.RESUME</em> update.
	 */
	public function resume():Void
	{
		if (_halted)
		{
			_halted = false;
			_accumulator = 0.;
			_past = _stamp();
			dispatchOnResume();
		}
	}

	/**
	 * Toggles (halt/resume) the flow of time.<br/>
	 * Triggers a <em>TimebaseEvent.HALT</em> or em>TimebaseEvent.RESUME</em> update.
	 */
	public function haltToggle():Void
	{
		_halted ? resume() : halt();
	}

	/**
	 * Freezes the flow of time for <code>x</code> seconds.<br/>
	 * Triggers a <em>TimebaseEvent.FREEZE_BEGIN</em> update.
	 */
	public function freeze(x:Float):Void
	{
		_freezeDelay = x;
		_accumulator = 0;
		dispatchOnFreezeBegin();
	}

	/**
	 * Performs a manual update step.<br/>
	 * Silently fails if <code>halt()</code> hasn't been called before.
	 */
	public function manualStep():Void
	{
		if (_halted)
		{
			_realTimeDelta = _tickRate;
			_realTime += _realTimeDelta;

			_gameTimeDelta = _tickRate * _timeScale;
			_gameTime += _gameTimeDelta;

			dispatchOnTick(_tickRate);
			_nTicks++;

			dispatchOnRender(1);
			_nFrames++;
		}
	}

	function _step()
	{
		#if js
		if(_requestAnimFrame == null) return;
		_requestAnimFrame(_step);
		#end
		
		if(_halted) return;

		var now = _stamp();
		var dt = (now - _past);
		_past = now;
		_realTimeDelta = dt;
		_realTime += _realTimeDelta;
	
		if(_freezeDelay > 0.)
		{
			_freezeDelay -= _realTimeDelta;
			dispatchOnTick(0.);
			dispatchOnRender(1.);
			if (_freezeDelay <= 0.)
				dispatchOnFreezeEnd();
			return;
		}

		if(useFixedTimeStep)
		{
			_accumulator += _realTimeDelta * _timeScale;
			//clamp accumulator to prevent 'spiral of death'
			if(_accumulator >= _accumulatorLimit)
			{
				#if debug
				trace("Warning, accumulator has been clamped");
				#end
				//notify for accumulator clamp ?
				_accumulator = _accumulatorLimit;
			}

			_gameTimeDelta = _tickRate * _timeScale;
			while(_accumulator >= _tickRate)
			{
				_accumulator -= _tickRate;
				_gameTime += _gameTimeDelta;
				dispatchOnTick(_tickRate);
				_nTicks++;
			}

			var alpha = _accumulator / _tickRate;
			dispatchOnRender(alpha);
			_nFrames++;
		}
		else
		{
			_accumulator = 0;
			_gameTimeDelta = dt * _timeScale;
			_gameTime += _gameTimeDelta;
			dispatchOnTick( _gameTimeDelta );
			dispatchOnRender(1.);
		}
		//SET _past VALUE HERE ?  Would be maybe different that real time, but real logic time !
	}

	#if (flash || cpp)
	function _onEnterFrame(e:flash.events.Event):Void
	{
		_step();
	}
	#end

	inline function _stamp():Float
	{
		/*
		return	#if flash
				Date.now().getTime() / 1000
				#else
				haxe.Timer.stamp()
				#end
				;
		*/
		return Date.now().getTime() / 1000;
	}
}
#end
