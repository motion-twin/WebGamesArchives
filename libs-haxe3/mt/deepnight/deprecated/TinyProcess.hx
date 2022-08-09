package mt.deepnight.deprecated;

import mt.Cooldown;
import mt.Delayer;
import mt.deepnight.Tweenie;

class TinyProcess {
	var parent				: Process;

	public var tw			: Tweenie;
	public var cd			: Cooldown;
	public var delayer		: Delayer;

	public var time(default,null)			: Float;
	public var itime(get, null)				: Int;
	public var paused(default,null)			: Bool;
	public var destroyAsked(default,null)	: Bool;


	public function new(parent:Process) {
		this.parent = parent;
		parent.tinyProcesses.push(this);
		paused = false;
		destroyAsked = false;
		time = 0;

		delayer = new Delayer(parent.baseFps);
		tw = new Tweenie(parent.baseFps);
		cd = new Cooldown();
	}

	public dynamic function onUpdate() {}
	public dynamic function onDispose() {}
	public inline function destroy() destroyAsked = true;

	inline function get_itime() return Std.int(time);

	function dispose() {
		onDispose();

		parent.tinyProcesses.remove(this);
		pause();

		cd.destroy();
		delayer.destroy();
	}

	public function pause() {
		paused = true;
	}
	public function resume() {
		paused = false;
	}


	private function updateInternals(dt:Float) {
		delayer.update(dt);
		cd.update(dt);
		tw.update(dt);
	}


	public static function updateArray(all:Array<TinyProcess>, dt:Float) {
		for(p in all)
			if( !p.paused && !p.destroyAsked ) {
				p.updateInternals(dt);

				if( p.destroyAsked )
					continue;

				p.onUpdate();
				p.time+=dt;
			}

		// Garbage collector
		var i = 0;
		while( i<all.length )
			if( all[i].destroyAsked )
				all[i].dispose();
			else
				i++;
	}
}
