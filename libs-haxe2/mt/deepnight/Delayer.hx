package mt.deepnight;

class Delayer {
	var delays		: Array<{t:Float, cb:Void->Void}>;
	var now			: mt.flash.Volatile<Float>;
	var fps			: Float;
	
	public function new(?fps=30) {
		now = 0;
		this.fps = fps;
		delays = new Array();
	}
	
	public function setFPS(f) {
		fps = f;
	}
	
	public function skip() {
		var limit = delays.length+100;
		while( delays.length>0 && limit-->0 ) {
			var d = delays[0];
			delays.splice(0,1);
			d.cb();
		}
	}
	
	public function add(cb:Void->Void, ms:Float) {
		delays.push({t:now+ms/1000*fps, cb:cb});
		delays.sort( function(a,b) return Reflect.compare(a.t, b.t) );
	}
	
	public function addFrame(cb:Void->Void, frames:Float) {
		delays.push({t:now+frames, cb:cb});
		delays.sort( function(a,b) return Reflect.compare(a.t, b.t) );
	}
	
	public function update() {
		while( delays.length>0 && delays[0].t<=now ) {
			var d = delays[0];
			delays.splice(0,1);
			d.cb();
		}
		now++;
	}
}