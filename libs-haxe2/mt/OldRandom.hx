package mt;

// Linear feedback shift register, used by OCaml standard library
// suitable for 31-bit integer calculus

class OldRandom {

	var prec : Int;
	var idx : Int;
	var vals : Array<Int>;

	public function new( ?seed : Int, ?prec:Int ) {
		if( prec == null )
			prec = 55;
		if( seed == null )
			seed = 0;

		this.prec = prec;
		idx = 0;
		vals = new Array();
		var int : Float -> Int = #if neko untyped __dollar__int #else Std.int #end;
		// use BSD PNRG mod 31bits to init seed
		for( i in 0...prec) {
			seed = int(seed * 1103515245.0) & 0x3FFFFFFF;
			seed += 12345;
			seed &= 0x3FFFFFFF;
			var sbig = seed & 0x3FFF0000;
			seed = int(seed * 1103515245.0) & 0x3FFFFFFF;
			seed += 12345;
			seed &= 0x3FFFFFFF;
			vals.push((seed >> 16) | sbig);
		}
	}

	public function int() {
		idx = (idx + 1) % prec;
		var v = (vals[(idx + 24)%prec] + idx) & 0x3FFFFFFF;
		vals[idx] = v;
		return v;
	}

	public function random( max ) {
		return int() % max;
	}

	public function rand() {
		// we can't use maximum precision
		// because the random is less effective
		// for the integer highest bits
		return (int() % 1000) / 1000.0;
	}

	public function clone() {
		var r = new OldRandom();
		r.prec = prec;
		r.idx = idx;
		r.vals = vals.copy();
		return r;
	}

}
