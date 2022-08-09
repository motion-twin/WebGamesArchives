package mt;

import mt.deepnight.Lib;

class Process {
	static var UNIQ_ID = 0;
	static var ROOTS : Array<Process> = [];

	public var rendering(default, null) : Bool; // if that process update frame is a rendering one
	public var uniqId					: Int;
	public var ftime(default, null)		: Float; // elapsed frames
	public var itime(get, never)		: Int;
	public var paused(default, null)	: Bool;
	public var destroyed(default, null)	: Bool;
	public var speedMod                 : Float;
	var parent(default, null)			: Process;
	var dt								: Float;

	public var name			: String;
	var children			: Array<Process>;

	// Tools
	public var delayer		: mt.Delayer;
	public var cd			: mt.Cooldown;
	public var tw			: mt.deepnight.Tweenie;

	// Optional graphic context
	#if( heaps || h3d )
	public var root			: Null<h2d.Layers>;
	public var engine(get,never)	: h3d.Engine;
	#elseif flash
	public var root			: Null<flash.display.Sprite>;
	var pt0					: flash.geom.Point;
	#end

	public function new(?parent : Process) {
		init();
		
		if (parent == null) {
			ROOTS.push(this);
		} else {
			parent.addChild(this);
		}
	}
	
	public function init(){
		name = "process";
		uniqId = UNIQ_ID++;
		children = [];
		destroyed = false;
		ftime = 0;
		dt = 1;
		speedMod = 1.0;

		delayer = new mt.Delayer( getDefaultFrameRate() );
		cd = new mt.Cooldown( getDefaultFrameRate() );
		tw = new mt.deepnight.Tweenie( getDefaultFrameRate() );
	}

	// -----------------------------------------------------------------------
	// Graphic context (optional)
	// -----------------------------------------------------------------------

	public function createRoot( #if( heaps || h3d )    ?ctx:h2d.Sprite    #else    ?ctx:flash.display.Sprite   #end) {
		if( root!=null )
			throw this+": root already created!";

		if( ctx==null ) {
			if( parent==null || parent.root==null )
				throw this+": context required";
			ctx = parent.root;
		}

		#if( heaps || h3d )
		root = new h2d.Layers(ctx);
		#else
		root = new flash.display.Sprite();
		ctx.addChild(root);
		pt0 = new flash.geom.Point();
		#end
	}

	#if heaps
	public function createRootInLayers(ctx:h2d.Layers, plan:Int) {
		if( root!=null )
			throw this+": root already exists";
		root = new h2d.Layers();
		ctx.add(root, plan);
	}
	#end


	// -----------------------------------------------------------------------
	// overridable functions
	// -----------------------------------------------------------------------

	public function update() { }
	public function postUpdate() { }
	public function onResize() { }
	public function onDispose() { }

	public dynamic function onUpdateCb() {}
	public dynamic function onDisposeCb() {}


	// -----------------------------------------------------------------------
	// private api
	// -----------------------------------------------------------------------

	function toString() return name+":"+uniqId;
	inline function get_itime() return Std.int(ftime);
	#if( heaps || h3d )
	inline function get_engine() return h3d.Engine.getCurrent();
	#end
	inline function alpha(c:Int, ?a=1.0) : #if flash UInt #else Int #end {
		return Std.int(a*255)<<24 | c;
	}
	inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);
	inline function rndSign() return Std.random(2)*2-1;
	inline function pretty(v:Float, ?precision=2) return Lib.prettyFloat(v, precision);
	inline function rndSecondsF(min,max,?sign) return secToFrames( Lib.rnd(min,max,sign) );
	inline function irndSecondsF(min,max,?sign) return secToFrames( Lib.rnd(min,max,sign) );

	public function secToFrames(v:Float) return v*getDefaultFrameRate();
	public function framesToSec(v:Float) return v/getDefaultFrameRate();

	public inline function msToFrames(v:Float) return (v/1000)*getDefaultFrameRate();
	public inline function framesToMs(v:Float) return 1000*v/getDefaultFrameRate();

	function getDefaultFrameRate() : Float {
		#if heaps
		return hxd.Timer.wantedFPS;
		#else
		return flash.Lib.current.stage.frameRate;
		#end
		//#if heaps
		//return hxd.System.getDefaultFrameRate();
		//#elseif h3d
		//return hxd.Stage.getInstance().getFrameRate();
		//#else
		//return flash.Lib.current.stage.frameRate;
		//#end
	}


	// -----------------------------------------------------------------------
	// public api
	// -----------------------------------------------------------------------

	#if( mBase || standalone || gameBase )
	public function w() return mt.Metrics.w();
	public function h() return mt.Metrics.h();
	public inline function wcm() return mt.Metrics.px2cm( w() );
	public inline function hcm() return mt.Metrics.px2cm( h() );
	#else
	public function w() {
		mt.deepnight.MacroTools.error("You need -D standalone to use w().");
		return 0;
	}
	public function h() {
		mt.deepnight.MacroTools.error("You need -D standalone to use h().");
		return 0;
	}
	#end

	public function pause() paused = true;
	public function resume() paused = false;
	public inline function togglePause() paused ? resume() : pause();
	public inline function destroy() destroyed = true;

	public function addChild( p : Process ) {
		if (p.parent == null) ROOTS.remove(p);
		else p.parent.children.remove(p);
		p.parent = this;
		children.push(p);
	}

	public function removeChild( p : Process ) {
		if( p.parent != this ) throw "invalid parent access";
		p.parent = null;
		children.remove(p);
	}

	public function createChildProcess( ?onUpdate:Process->Void, ?onDispose:Process->Void, ?runUpdateImmediatly=false ) : Process {
		var p = new mt.Process(this);
		p.name = "childProcess";
		if( onUpdate!=null )
			p.onUpdateCb = function() {
				onUpdate(p);
			}

		if( onDispose!=null )
			p.onDisposeCb = function() {
				onDispose(p);
			}

		if( runUpdateImmediatly )
			_update(p,1);

		return p;
	}

	public function killAllChildrenProcesses() {
		for(p in children)
			p.destroy();
	}

	// -----------------------------------------------------------------------
	// static api
	// -----------------------------------------------------------------------

	public static function updateAll(dt : Float, ?rendering:Bool=true) {
		for (p in ROOTS)
			_update(p, dt, rendering);

		for (p in ROOTS)
			_postUpdate(p);

		_checkDestroyeds(ROOTS);
	}

	public static function resizeAll() {
		for ( p in ROOTS )
			_resize(p);
	}

	static inline function _resize(p : Process) {
		if ( !p.destroyed ){
			p.onResize();
			for ( p in p.children )
				_resize(p);
		}
	}

	// -----------------------------------------------------------------------
	// internals statics
	// -----------------------------------------------------------------------
	static function _update(p : Process, dt : Float, ?rendering:Bool=true) {
		if( p.paused || p.destroyed )
			return;

		dt *= p.speedMod;

		p.rendering = rendering;
		p.dt = dt;
		p.ftime += dt;

		p.delayer.update(dt);
		p.cd.update(dt);
		p.tw.update(dt);

		if( !p.paused && !p.destroyed ) {
			p.update();
			if( p.onUpdateCb != null )
				p.onUpdateCb();
		}

		if( !p.paused && !p.destroyed )
			for (p in p.children)
				_update(p, dt, rendering);
	}

	static inline function _postUpdate(p : Process) {
		if( p.paused || p.destroyed )
			return;

		p.postUpdate();

		if( !p.destroyed )
			for (c in p.children)
				_postUpdate(c);
	}

	static function _checkDestroyeds(plist:Array<Process>) {
		var i = 0;
		while (i < plist.length) {
			var p = plist[i];
			if( p.destroyed )
				_dispose(p);
			else {
				_checkDestroyeds(p.children);
				i++;
			}
		}
	}

	static function _dispose(p : Process) {
		// Children
		for(p in p.children)
			p.destroy();
		_checkDestroyeds(p.children);

		// Tools
		p.delayer.destroy();
		p.cd.destroy();
		p.tw.destroy();

		// Unregister from lists
		if (p.parent != null) {
			p.parent.children.remove(p);
		}
		else
			ROOTS.remove(p);

		// Graphic context
		if( p.root!=null ) {
			#if( heaps || h3d )
			p.root.remove();
			#else
			p.root.parent.removeChild(p.root);
			#end
		}

		// Callbacks
		p.onDispose();
		if( p.onDisposeCb != null )
			p.onDisposeCb();

		// Clean up
		p.parent = null;
		p.children = null;
		p.delayer = null;
		p.cd = null;
		p.tw = null;
		#if( heaps || h3d )
		p.root = null;
		#else
		p.root = null;
		p.pt0 = null;
		#end
	}
}
