package mt.deepnight.deprecated;

#if (flash || openfl)
import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
import mt.Cooldown;
import mt.Delayer;
import mt.Metrics;
#end

class Process {
	public static var GLOBALS : Array<Process> = [];

	public var name(default,set)		: String;
	public var baseFps(default,null)	: Int;
	public var tw						: Tweenie;
	public var cd						: Cooldown;
	public var delayer					: Delayer;
	var clientActive					: Bool;
	public var tinyProcesses			: Array<TinyProcess>;
	var parent(default,set)				: Null<Process>;
	var childProcesses					: Array<Process>;

	public var time(default,null)			: Int;
	public var rendering(default,null)		: Bool;
	public var paused(default,null)			: Bool;
	public var destroyAsked(default,null)	: Bool;
	var uniqId(null,null)					: Int;

	var updatedOnce							: Bool;

	public function new(?p:Process) {
		name = "Process";
		GLOBALS.push(this);
		uniqId = 0;
		#if (flash || openfl)
		baseFps = Std.int(flash.Lib.current.stage.frameRate);
		#else
		baseFps = 30;
		#end
		paused = false;
		clientActive = true;
		destroyAsked = false;
		time = 0;
		tinyProcesses = [];
		childProcesses = [];
		updatedOnce = false;

		parent = p;

		delayer = new Delayer(baseFps);
		tw = new Tweenie(baseFps);
		cd = new Cooldown();

		#if (flash || openfl)
		if( flash.Lib.current.stage==null )
			flash.Lib.current.addEventListener( flash.events.Event.ADDED_TO_STAGE, _onAddedToStage);
		else
			_onAddedToStage(null);
		#else
		_onAddedToStage(null);
		#end
	}

	public function toString() {
		return ( parent!=null ? parent.name+"." : "" ) + name+"(t="+time+")";
	}

	function set_name(s:String) {
		return name = s;
	}



	function set_parent(p:Process) {
		if( parent!=null ) {
			GLOBALS.push(this);
			parent.childProcesses.remove(this);
		}
		parent = p;
		if( parent!=null ) {
			GLOBALS.remove(this);
			parent.childProcesses.push(this);
		}
		return parent;
	}

	public function getUniqId() return uniqId++;

	function _onAddedToStage(_) {
		#if (flash || openfl)
		flash.Lib.current.removeEventListener( flash.events.Event.ADDED_TO_STAGE, _onAddedToStage);
		flash.Lib.current.stage.addEventListener( flash.events.Event.RESIZE, _onResize );
		flash.Lib.current.stage.addEventListener( flash.events.Event.ACTIVATE, _onActivate);
		flash.Lib.current.stage.addEventListener( flash.events.Event.DEACTIVATE, _onDeactivate);
		#end
	}


	// Misc useful functions (Note: do not INLINE to allow inheritance)
	#if (flash || openfl)
	public function w() return Metrics.w();
	public function h() return Metrics.h();
	public inline function wcm() return Metrics.px2cm( w() );
	public inline function hcm() return Metrics.px2cm( h() );
	inline function alpha(rgb:UInt,?alpha=1.0) : UInt return Color.addAlphaF(rgb, alpha);
	#end
	function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	function irnd(min,max,?sign) return Lib.irnd(min,max,sign);
	inline function pretty(v:Float, ?precision=2) return Lib.prettyFloat(v, precision);
	inline function secondsToFrames(s:Float) return s*baseFps;
	inline function framesToSeconds(f:Float) return f/baseFps;



	public inline function destroy() { // inlined to forbid inheritance: DO NOT CHANGE THIS!
		destroyAsked = true;
	}


	#if (flash || openfl)
	inline function _onResize(_) onResize();
	function onResize() {}

	inline function emitResizeEvent() emitResizeEventToAll();
	public static function emitResizeEventToAll() {
		for( p in GLOBALS ) {
			p.onResize();
			for( s in p.childProcesses )
				s.onResize();
		}
	}

	function _onDeactivate(_) {
		if( clientActive ) {
			clientActive = false;
			onDeactivate();
		}
	}
	function onDeactivate() {}

	function _onActivate(_) {
		if( !clientActive ) {
			onActivate();
			clientActive = true;
		}
	}
	function onActivate() {}
	#end


	public function createTinyProcess( ?onUpdate:TinyProcess->Void, ?runUpdateImmediatly=false ) {
		var p = new TinyProcess(this);
		if( onUpdate!=null ) {
			p.onUpdate = onUpdate.bind(p);
			if( runUpdateImmediatly )
				p.onUpdate();
		}
		return p;
	}


	public function killAllTinyProcesses() {
		for(p in tinyProcesses)
			p.destroy();
		TinyProcess.updateArray(tinyProcesses,1);
		tinyProcesses = [];
	}


	public function killAllChildrenProcesses() {
		for(p in childProcesses)
			p.destroy();
	}


	function unregister() { // Must never be called directly, use destroy()
		if( parent!=null )
			parent.childProcesses.remove(this);
		else
			GLOBALS.remove(this);
		pause();

		// Children destructions
		if( childProcesses.length>0 ) {
			while( childProcesses.length>0 ) {
				childProcesses[0].destroyAsked = true;
				childProcesses[0].unregister();
			}
			childProcesses = null;
		}

		#if (flash || openfl)
		flash.Lib.current.removeEventListener( flash.events.Event.ADDED_TO_STAGE, _onAddedToStage);
		if( flash.Lib.current.stage!=null ) {
			flash.Lib.current.stage.removeEventListener( flash.events.Event.ACTIVATE, _onActivate );
			flash.Lib.current.stage.removeEventListener( flash.events.Event.DEACTIVATE, _onDeactivate );
			flash.Lib.current.stage.removeEventListener( flash.events.Event.RESIZE, _onResize );
		}
		#end

		for(p in tinyProcesses)
			p.destroy();
		TinyProcess.updateArray(tinyProcesses, 1);
		tinyProcesses = null;

		onNextUpdate = null;

		cd.destroy();
		cd = null;

		delayer.destroy();
		delayer = null;

		tw.destroy();
		tw = null;
	}

	public function pause() {
		paused = true;
	}
	public function resume() {
		paused = false;
	}
	public function togglePause() {
		paused = !paused;
	}

	@:noCompletion function updateProcessInternals() {
		delayer.update();
		cd.update();
		tw.update();
		TinyProcess.updateArray(tinyProcesses, 1);
	}

	@:noCompletion function internalLoop(rend:Bool) {
		rendering = rend && !paused;
		if( !paused && !destroyAsked ) {
			if( onNextUpdate!=null ) {
				var cb = onNextUpdate;
				onNextUpdate = null;
				cb();
			}

			updateProcessInternals();

			if( !destroyAsked )
				preUpdate();

			if( !destroyAsked )
				update();

			if( !destroyAsked && rendering )
				render();

			// Children
			var i = 0;
			while( i<childProcesses.length )
				if( childProcesses[i].destroyAsked )
					childProcesses[i].unregister();
				else {
					childProcesses[i].internalLoop(rendering);
					i++;
				}

			time++;
		}
	}

	public dynamic function onNextUpdate() {}
	private function preUpdate() {}
	private function update() {}
	private function render() {}


	public static function updateAll(?render = true) {
		#if h3d
		if( HProcess.GLOBAL_SCENE!=null )
			HProcess.GLOBAL_SCENE.checkEvents();
		#end

		for(p in GLOBALS)
			p.internalLoop(render);

		// Flush destructions
		var i = 0;
		while( i<GLOBALS.length ) {
			var p = GLOBALS[i];

			if( p.destroyAsked )
				p.unregister();
			else
				i++;
		}
	}

}

