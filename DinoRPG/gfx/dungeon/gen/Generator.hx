package gen;
import gen.Data;

class Generator {

	var r : mt.Rand;
	var inf : LevelInfos;

	public function new() {
	}

	function select(inf) {
		this.inf = inf;
		r = new mt.Rand(inf.seed);
	}

	inline function random(n) {
		return r.random(n);
	}

	inline function rand(a,b) {
		return a + random(b - a + 1);
	}

	inline function proba(n) {
		return random(n) == 0;
	}

	function ntry(f,n) {
		var trys = n * 100;
		while( n > 0 ) {
			if( f() ) {
				n--;
				continue;
			}
			if( --trys == 0 )
				return false;
		}
		return true;
	}

	function vtry<T>(f : Void -> T) : T {
		while( true ) {
			var v = f();
			if( v != null )
				return v;
		}
		return null;
	}

	function loop( f : Void -> Bool ) {
		while( !f() ) {
		}
	}

}
