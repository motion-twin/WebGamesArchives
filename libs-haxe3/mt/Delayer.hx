package mt;


private class Task { //classes are faster

	public var t	: Float;
	public var id	: String;
	public var cb	: Void->Void;

	public inline function new(id, t,cb) { //inline new classes are faster faster
		this.t = t;
		this.cb = cb;
		this.id = id;
	}

	public inline function toString() return t + " " + cb;
}

class Delayer {
	var delays		: Array<Task>;
	var now			: mt.flash.Volatile<Float>;
	var fps			: Float;

	public function new(fps:Float) { //no need for nullability because no other nullable args
		now = 0;
		this.fps = fps;
		delays = new Array();
	}

	public function toString() {
		return "Delayer(now="+now+",timers="+delays.map(function(d) return d.t).join(",")+")";
	}

	public inline function isDestroyed() return delays == null;

	public function destroy() {
		delays = null;
	}

	public function skip() {
		var limit = delays.length+100;
		while( delays.length>0 && limit-->0 ) {
			var d = delays.shift();
			d.cb();
			d.cb = null;//help garbage
		}
	}

	public function cancelEverything() {
		delays = [];
	}

	public function hasId(id:String) {
		for(e in delays)
			if( e.id==id )
				return true;
		return false;
	}

	public function cancelById(id:String) {
		var i = 0;
		while( i<delays.length )
			if( delays[i].id==id )
				delays.splice(i,1);
			else
				i++;
	}

	public function runImmediatly(id:String) {
		var i = 0;
		while( i<delays.length )
			if( delays[i].id==id ) {
				var cb = delays[i].cb;
				delays.splice(i,1);
				cb();
			}
			else
				i++;
	}

	inline function cmp(a:Task, b:Task) {
		return
			if ( a.t < b.t ) -1
			else if ( a.t > b.t ) 1;
			else 0;
	}

	public function addMs(?id:String, cb:Void->Void, ms:Float) {
		delays.push( new Task( id, now + ms / 1000 * fps, cb) );
		haxe.ds.ArraySort.sort(delays, cmp);
	}

	public function addS(?id:String, cb:Void->Void, sec:Float) {
		delays.push( new Task( id, now + sec*fps, cb) );
		haxe.ds.ArraySort.sort(delays, cmp);
	}

	public function addF(?id:String, cb:Void->Void, frames:Float) {
		delays.push( new Task( id, now + frames, cb ) );
		haxe.ds.ArraySort.sort(delays, cmp);
	}

	public function update(dt:Float) {
		while( delays.length>0 && delays[0].t<=now ) {
			var d = delays.shift();
			d.cb();
			d.cb = null;//help garbage
		}
		now+=dt;
	}
}
