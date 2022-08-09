package mt.heaps.slib;

import mt.MLib;

private class AnimInstance {
	var spr : SpriteInterface;
	public var group : String;
	public var frames : Array<Int> = [];

	public var animCursor = 0;
	public var curFrameCpt = 0.0;
	public var plays = 1;
	public var playDuration = -1.;
	public var paused = false;
	public var isStateAnim = false;
	public var killAfterPlay = false;
	public var stopOnLastFrame = false;
	public var speed = 1.0;
	public var reverse = false;

	public function new(s:SpriteInterface, g:String) {
		spr = s;
		group = g;
		if( !spr.lib.exists(group) )
			throw "unknown group "+group;
		frames = spr.lib.getGroup(group).anim;
	}

	public inline function overLastFrame() return animCursor>=frames.length;

	public inline function applyFrame() {
		var f = frames[ reverse ? frames.length-1-animCursor : animCursor ];
		if( spr.groupName!=group )
			spr.set(group, f);
		else if( spr.frame!=f )
			spr.setFrame(f);
	}

	public dynamic function onEnd() {}
	public dynamic function onEachLoop() {}
}


private class StateAnim {
	public var group : String;
	public var priority : Int;
	public var cond : Void->Bool;
	public var spd : Float;

	public function new(g:String, ?cb) {
		group = g;
		priority = 0;
		cond = cb;
		spd = 1.0;
	}
}


private class Transition {
	public var from : String;
	public var to : String;
	public var anim : String;
	public var cond : Void->Bool;
	public var spd : Float;
	public var reverse : Bool;

	public function new(f,t,a,cb) {
		from = f;
		to = t;
		anim = a;
		cond = cb;
		spd = 1.0;
		reverse = false;
	}
}


class AnimManager {
	var spr : SpriteInterface;

	var overlap : Null<AnimInstance>;
	var stack : Array<AnimInstance> = [];
	var stateAnims : Array<StateAnim> = [];
	var transitions : Array<Transition> = [];

	var genSpeed = 1.0;
	var needUpdates = false;
	var destroyed = false;
	var suspended = false;
	var suspendF = 0.;

	public function new(spr:SpriteInterface) {
		this.spr = spr;
	}

	@:allow(mt.heaps.slib.SpriteLib)
	inline function getCurrentAnim() {
		return stack[0];
	}

	public function getDurationF() {
		return !hasAnim() ? 0 : spr.lib.getAnimDurationF( getCurrentAnim().group ) / genSpeed / getCurrentAnim().speed;
	}

	public function getDurationS(fps:Float) {
		return getDurationF() / fps;
	}

	inline function getLastAnim() {
		return stack[stack.length-1];
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
		stack = null;
		spr = null;
	}



	public inline function hasAnim() return !destroyed && stack.length>0;
	public inline function isPlaying(group:String) return hasAnim() && getCurrentAnim().group==group;
	public inline function isAnimFirstFrame() return hasAnim() ? getCurrentAnim().animCursor==0 : false;
	public inline function isAnimLastFrame() return hasAnim() ? getCurrentAnim().animCursor>=getCurrentAnim().frames.length-1 : false;
	public inline function getAnimCursor() return hasAnim() ? getCurrentAnim().animCursor : 0;

	public inline function chain(id:String, ?plays=1) {
		play(id, plays, true);
		return this;
	}

	public inline function chainCustomSequence(id:String, from:Int, to:Int) {
		playCustomSequence(id, from, to, true);
		return this;
	}

	public inline function chainLoop(id:String) {
		play(id, 99999, true);
		return this;
	}

	public inline function chainFor(id:String, durationFrames:Float) {
		play(id, 99999, true);
		if( hasAnim() )
			getLastAnim().playDuration = durationFrames;
		return this;
	}

	public inline function playForF(group:String, dframes:Float) {
		if( dframes>0 ) {
			playAndLoop(group);
			if( hasAnim() )
				getLastAnim().playDuration = dframes;
		}
		return this;
	}

	public inline function playAndLoop(k:String) {
		return play(k).loop();
	}

	public function playCustomSequence(group:String, from:Int, to:Int, ?queueAnim=false) {
		var g = spr.lib.getGroup(group);
		if( g==null ) {
			#if debug
			trace("WARNING: unknown anim "+group);
			#end
			return this;
		}

		if( !queueAnim && hasAnim() )
			stopWithoutStateAnims();

		var a = new AnimInstance(spr,group);
		stack.push(a);
		a.reverse = from>to;
		a.frames = [];
		if( from>to ) {
			var tmp = from;
			from = to;
			to = tmp;
		}
		for(f in from...to+1)
			a.frames.push(f);

		startUpdates();
		if( !queueAnim )
			initCurrentAnim();

		return this;
	}

	public function play(group:String, ?plays=1, ?queueAnim=false) : AnimManager {
		var g = spr.lib.getGroup(group);
		if( g==null ) {
			#if debug
			trace("WARNING: unknown anim "+group);
			#end
			return this;
		}

		if( g.anim==null || g.anim.length==0 )
			return this;

		if( !queueAnim && hasAnim() )
			stopWithoutStateAnims();

		var a = new AnimInstance(spr,group);
		stack.push(a);
		a.plays = plays;

		startUpdates();
		if( !queueAnim )
			initCurrentAnim();

		return this;
	}

	public function playOverlap(g:String, ?spd=1.0) {
		overlap = new AnimInstance(spr,g);
		overlap.speed = spd;
		overlap.applyFrame();
	}

	public function loop() {
		if( hasAnim() )
			getLastAnim().plays = 999999;
		return this;
	}

	public function stopOnLastFrame() {
		if( hasAnim() )
			getLastAnim().stopOnLastFrame = true;
		return this;
	}

	public function reverse() {
		if( hasAnim() ) {
			getLastAnim().reverse = true;
			if( getLastAnim()==getCurrentAnim() )
				getCurrentAnim().applyFrame();
		}
		return this;
	}

	public function killAfterPlay() {
		if( hasAnim() )
			getLastAnim().killAfterPlay = true;
		return this;
	}

	public function onEnd(cb:Void->Void) {
		if( hasAnim() )
			getLastAnim().onEnd = cb;
		return this;
	}

	public function onEachLoop(cb:Void->Void) {
		if( hasAnim() )
			getLastAnim().onEachLoop = cb;
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

	public function pauseCurrentAnim() {
		if( hasAnim() )
			getCurrentAnim().paused = true;
	}

	public function resumeCurrentAnim() {
		if( hasAnim() )
			getCurrentAnim().paused = false;
	}

	public function stopWithStateAnims() {
		overlap = null;
		stack = [];
		applyStateAnims();
	}

	public function stopWithoutStateAnims(?k:String,?frame:Int) {
		overlap = null;
		stack.splice(0, stack.length);
		if( k!=null )
			spr.set(k, frame!=null ? frame : 0);
		else if( frame!=null )
			spr.setFrame(frame);
	}


	public function suspend() {
		suspended = true;
		suspendF = 9999;
	}

	public function unsuspend() { // the name sucks, but its easier to understand
		suspended = false;
		suspendF = 0;
	}

	public function suspendForF(durationFrame:Float) {
		suspendF = durationFrame + 1;
	}


	public inline function getGlobalSpeed() return genSpeed;
	public inline function setGlobalSpeed(s:Float) {
		genSpeed = s;
		return this;
	}

	public inline function setSpeed(s:Float) {
		if( hasAnim() )
			getLastAnim().speed = s;
		return this;
	}

	inline function initCurrentAnim() {
		// Transitions
		var t = getTransition( spr.groupName, getCurrentAnim().group );

		if ( t != null ) {
			var exists = spr.lib.exists(t.anim);
			if (exists) {
				var a = new AnimInstance(spr, t.anim);
				stack.insert(0,a);
				a.speed = t.spd;
				a.reverse = t.reverse;
			} else {
				#if debug
				trace("WARNING: unknown anim "+t.anim);
				#end
			}

		}

		getCurrentAnim().applyFrame();
	}


	public inline function registerTransitions(from:String, tos:Array<String>, animId:String, ?spd=1.0, ?reverse=false) {
		for(to in tos)
			registerTransition(from,to, animId, spd, reverse);
	}

	function alwaysTrue() return true;

	public function registerTransition(from:String, to:String, animId:String, ?spd=1.0, ?reverse=false, ?cond:Void->Bool) {
		for(t in transitions)
			if( t.from==from && t.to==to ) {
				t.anim = animId;
				t.spd = spd;
				return;
			}

		var t = new Transition(from,to, animId, cond==null ? alwaysTrue : cond);
		t.spd = spd;
		t.reverse = reverse;
		transitions.push(t);
	}

	function getTransition(from:String, to:String) {
		for(t in transitions)
			if( (t.from=="*" || t.from==from) && (t.to=="*" || t.to==to) && t.cond() )
				return t;
		return null;
	}

	public function registerStateAnim(group:String, priority:Int, ?spd=1.0, ?condition:Void->Bool) {
		if( condition==null )
			condition = function() return true;

		removeStateAnim(group, priority);
		var s = new StateAnim(group, condition);
		s.priority = priority;
		s.spd = spd;
		stateAnims.push(s);
		stateAnims.sort( function(a,b) return -Reflect.compare(a.priority, b.priority) );

		applyStateAnims();
	}

	public function setStateAnimSpeed(group:String, spd:Float) {
		for(s in stateAnims)
			if( s.group==group )
				s.spd = spd;
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

	function applyStateAnims() {
		if( hasAnim() && !getCurrentAnim().isStateAnim )
			return;

		for(sa in stateAnims)
			if( sa.cond() ) {
				if( hasAnim() && getCurrentAnim().group==sa.group )
					break;

				playAndLoop(sa.group).setSpeed(sa.spd);
				if( hasAnim() )
					getLastAnim().isStateAnim = true;
				break;
			}
	}


	public function toString() {
		return
			"AnimManager("+spr+")" +
			(hasAnim() ? "Playing(stack="+stack.length+")" : "NoAnim");
	}


	public inline function update(dt:Float) {
		if( needUpdates )
			_update(dt);
	}

	function _update(dt:Float) {
		if( suspended ) {
			suspendF-=dt;
			if( suspendF<=0 )
				unsuspend();
			return;
		}

		// State anims
		applyStateAnims();

		// Playback
		var a = getCurrentAnim();
		if( a!=null && !a.paused ) {
			a.curFrameCpt += dt * genSpeed * a.speed;

			// Duration playback
			if( a.playDuration>0 ) {
				a.playDuration-=dt;
				if( a.playDuration<=0 ) {
					a.plays = 0;
					a.animCursor = a.frames.length;
					a.curFrameCpt = 1; // force entering the loop
				}
			}

			while( a.curFrameCpt>1 ) {
				a.curFrameCpt--;
				a.animCursor++;

				// Normal frame
				if( !a.overLastFrame() ) {
					a.applyFrame();
					continue;
				}

				// Anim complete
				a.animCursor = 0;
				a.plays--;

				// Loop
				if( a.plays>0 || a.playDuration>0 ) {
					a.onEachLoop();
					a = getCurrentAnim();
					a.applyFrame();
					continue;
				}

				if( a.stopOnLastFrame )
					stopWithoutStateAnims();

				// No loop
				a.onEnd();

				if( a.killAfterPlay ) {
					spr.remove();
					break;
				}

				// Next anim
				if( hasAnim() ) {
					stack.shift();
					if( stack.length==0 )
						stopWithStateAnims();
					else
						initCurrentAnim();
					a = getCurrentAnim();
				}

				if( !hasAnim() )
					break;
			}

			if( overlap!=null && !spr.destroyed ) {
				overlap.curFrameCpt += dt * genSpeed * overlap.speed;
				while( overlap.curFrameCpt>1 ) {
					overlap.curFrameCpt--;
					overlap.animCursor++;
					if( overlap.overLastFrame() ) {
						overlap = null;
						if( getCurrentAnim()!=null )
							getCurrentAnim().applyFrame();
						break;
					}
				}
				if( overlap!=null )
					overlap.applyFrame();
			}
		}

		// Nothing to do
		if( !destroyed && !hasAnim() )
			stopUpdates();
	}
}