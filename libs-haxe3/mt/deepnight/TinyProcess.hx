package mt.deepnight;

import mt.Cooldown;
import mt.Delayer;

class TinyProcess {
	var parent				: Process;

	public var tw			: Tweenie;
	public var cd			: Cooldown;
	public var delayer		: Delayer;

	public var time(default,null)			: Int;
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
	public dynamic function onDestroy() {}


	public inline function destroy() {
		destroyAsked = true;
	}

	function unregister() {
		onDestroy();

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


	private function updateInternals() {
		delayer.update();
		cd.update();
		tw.update();
	}


	public static function updateArray(arr:Array<TinyProcess>) {
		for(p in arr)
			if( !p.paused && !p.destroyAsked ) {

				p.updateInternals();
				if( p.destroyAsked )
					continue;

				p.onUpdate();

				p.time++;

			}

		// Flush destructions
		var i = 0;
		while( i<arr.length )
			if( arr[i].destroyAsked )
				arr[i].unregister();
			else
				i++;
	}
}
