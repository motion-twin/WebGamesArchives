package mt.deepnight.slb;

import mt.MLib;

typedef AnimInstance = {
	var group			: String;
	var frames			: Array<Int>;
	var animCursor		: Int;
	var curFrameCpt		: Float;
	var plays			: Int;
	var paused			: Bool;
	var isStateAnim		: Bool;
	var killAfterPlay	: Bool;
	var speed			: Float;
	var onEnd			: Null< Void->Void >;
}

class AnimManager {
	var needUpdates	: Bool;
	var genSpeed	: Float;
	var animStack	: Array<AnimInstance>;
	var spr			: SpriteInterface;
	var stateAnims	: Array<{group:String, priority:Int, condition:Void->Bool}>;
	var suspendTime	: Int;
	var destroyed	: Bool;

	var isPlaying	: Bool;

	public function new(spr:SpriteInterface) {
		this.spr = spr;
		needUpdates = false;
		animStack = [];
		stateAnims = [];
		suspendTime = 0;
		genSpeed = 1;
		destroyed = false;
		isPlaying = false;
	}

	inline function getCurrentAnim() {
		return animStack[0];
	}

	inline function getLastAnim() {
		return animStack[animStack.length-1];
	}

	inline function startUpdates() {
		needUpdates = true;
	}

	inline function stopUpdates() {
		needUpdates = false;
	}

	public function destroy() {
		destroyed = true;
		stopWithoutStateAnims();
		stopUpdates();
		stateAnims = null;
		animStack = null;
		spr = null;
	}

	inline function hasAnim() {
		return !destroyed && animStack.length>0;
	}

	public inline function isPlayingAnim(?group:String) {
		return hasAnim() && !isSuspended() && (group==null || getCurrentAnim().group==group);
		//return hasAnim() && (group==null || getCurrentAnim().group==group);
	}

	public inline function getAnimCursor() {
		return hasAnim() ? getCurrentAnim().animCursor : 0;
	}

	public inline function isAnimFirstFrame() {
		return hasAnim() ? getCurrentAnim().animCursor==0 : false;
	}

	public inline function isAnimLastFrame() {
		return hasAnim() ? getCurrentAnim().animCursor>=getCurrentAnim().frames.length-1 : false;
	}

	public function chain(id:String) {
		play(id, true);
		return this;
	}

	public inline function chainAndLoop(k:String) {
		return chain(k).loop();
	}

	public inline function playAndLoop(k:String) {
		return play(k).loop();
	}

	public inline function playWithSpeed(k:String, s:Float) {
		play(k);
		getCurrentAnim().speed = s;
		return this;
	}

	public inline function playAndWait(k:String, durationFrame:Int) {
		return play(k,1).onEnd(function() {
			suspendFor(durationFrame, k, spr.frame);
		});
	}

	public function play(group:String, ?plays=1, ?queueAnim=false) {
		var g = spr.lib.getGroup(group);
		if( g==null ) {
			trace("WARNING: unknown anim "+group);
			return this;
		}

		//var aframes = g.anim;
		if( g.anim==null || g.anim.length==0 )
			return this;

		if( !queueAnim && hasAnim() )
			stopWithoutStateAnims();

		var a : AnimInstance = {
			group		: group,
			paused		: false,
			curFrameCpt	: 0,
			animCursor	: 0,
			plays		: plays,
			frames		: g.anim,
			isStateAnim	: false,
			killAfterPlay: false,
			onEnd		: null,
			speed		: 1.0,
		}
		isPlaying = true;
		animStack.push(a);
		startUpdates();
		suspendTime = 0;

		if( !queueAnim )
			initCurrentAnim();

		return this;
	}

	public function loop() {
		if( hasAnim() )
			getLastAnim().plays = 999999;
		return this;
	}

	public function killAfterPlay() {
		if( hasAnim() )
			getCurrentAnim().killAfterPlay = true;
		return this;
	}

	public function stopOnEnd() {
		if( hasAnim() )
			getLastAnim().onEnd = function() stopWithoutStateAnims();
		return this;
	}

	public function onEnd(cb:Void->Void) {
		if( hasAnim() )
			getLastAnim().onEnd = cb;
		return this;
	}

	static var UNSYNC : Map<String,Int> = new Map();
	public function unsync() {
		if( !hasAnim() )
			return this;

		var a = getCurrentAnim();
		if( !UNSYNC.exists(a.group) )
			UNSYNC.set(a.group, 1);
		else
			UNSYNC.set(a.group, UNSYNC.get(a.group)+1);

		var offset = MLib.ceil(a.frames.length/3);
		a.animCursor = ( offset * UNSYNC.get(a.group) + Std.random(100) ) % a.frames.length;
		return this;
	}

	public dynamic function onEachLoop() {
	}

	public function pause() {
		if( hasAnim() )
			getCurrentAnim().paused = true;
	}

	public function resume() {
		if( hasAnim() )
			getCurrentAnim().paused = false;
	}

	public function stop() {
		isPlaying = false;
		suspendTime = 0;
		animStack.splice(0, animStack.length);
		applyStateAnims();
	}

	public function stopWith(group:String, ?frame=0) {
		stopWithoutStateAnims();
		spr.set(group, frame);
	}

	public function stopWithoutStateAnims() {
		isPlaying = false;
		animStack.splice(0, animStack.length);
	}

	public function suspendFor(durationFrame:Int, ?group:String, ?frame=0) {
		suspendTime = durationFrame + 1;
		if( group!=null )
			spr.set(group, frame);
	}

	inline function isSuspended() {
		return suspendTime>0;
	}


	public inline function getGeneralSpeed() return genSpeed;
	public function setGeneralSpeed(s:Float) {
		genSpeed = s;
		return this;
	}

	public function setCurrentAnimSpeed(s:Float) {
		getCurrentAnim().speed = s;
		return this;
	}

	function nextAnim() {
		if( getCurrentAnim().killAfterPlay ) {
			spr.dispose();
			return;
		}

		animStack.shift();
		if( animStack.length==0 ) {
			// End
			stop();
		}
		else {
			// Init next
			initCurrentAnim();
		}
	}

	function initCurrentAnim() {
		var a = getCurrentAnim();
		spr.set(a.group, a.frames[0]);
	}



	public function registerStateAnim(group:String, priority:Int, ?condition:Void->Bool) {
		if( condition==null )
			condition = function() return true;

		removeStateAnim(group, priority);
		stateAnims.push({
			group		: group,
			priority	: priority,
			condition	: condition,
		});
		stateAnims.sort( function(a,b) return -Reflect.compare(a.priority, b.priority) );
	}

	public function removeStateAnim(group:String, priority:Int) {
		var i = 0;
		while( i<stateAnims.length )
			if( stateAnims[i].group==group && stateAnims[i].priority==priority )
				stateAnims.splice(i,1);
			else
				i++;
	}

	public function removeAllStateAnims() {
		stateAnims = [];
	}

	public function applyStateAnims() {
		if( isSuspended() )
			return;

		if( hasAnim() && !getCurrentAnim().isStateAnim )
			return;

		for(sa in stateAnims)
			if( sa.condition() ) {
				if( hasAnim() && getCurrentAnim().group==sa.group )
					break;

				playAndLoop(sa.group);
				if( hasAnim() )
					getLastAnim().isStateAnim = true;
				break;
			}
	}


	public function toString() {
		return
			"AnimManager("+spr+")" +
			(hasAnim() ? "Playing(stack="+animStack.length+")" : "NoAnim");
	}


	public inline function update() {
		if( needUpdates )
			_update();
	}

	function _update() {
		// Suspended
		if( isSuspended() ) {
			suspendTime--;
			if( isSuspended() )
				return;
			else {
				suspendTime = 0;
				if( hasAnim() ) {
					var a = getCurrentAnim();
					spr.set( a.group, a.frames[a.animCursor] ); // back to previous state
				}
			}
		}

		// State anims
		applyStateAnims();

		// Playback
		var a = getCurrentAnim();
		if( a!=null && !a.paused ) {
			a.curFrameCpt += genSpeed * a.speed;

			while( a.curFrameCpt>1 ) {
				a.curFrameCpt--;
				a.animCursor++;
				if( a.animCursor>=a.frames.length ) {
					// Last frame reached
					a.animCursor = 0;
					a.plays--;
					if(a.plays<=0) {
						// Playback end
						if( a.onEnd!=null ) {
							var cb = a.onEnd;
							a.onEnd = null;
							cb();
						}
						if( hasAnim() )
							nextAnim();
						
						if( !hasAnim() )
							break;
					}
					else {
						// Loop
						if( onEachLoop!=null )
							onEachLoop();
						if( spr.frame!=a.frames[a.animCursor] )
							spr.setFrame( a.frames[a.animCursor] );
					}
				}
				else {
					// Normal frame
					if( spr.frame!=a.frames[a.animCursor] )
						spr.setFrame( a.frames[a.animCursor] );
				}
			}
		}

		// Nothing to do
		if( !destroyed && !hasAnim() && !isSuspended() )
			stopUpdates();
	}
}