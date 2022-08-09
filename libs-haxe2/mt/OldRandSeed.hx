package mt;

// Linear feedback shift register, used by OCaml standard library
// suitable for 31-bit integer calculus

class OldRandSeed {

	var idx : Int;
	var vals : Array<Int>;

	public function new( ?seed : Int ) {
		if( seed == null )
			seed = 0;
		idx = 0;
		vals = new Array();
		// use BSD PNRG mod 31bits to init seed
		for( i in 0...55 ) {
			seed = Std.int(seed * 1103515245.0) & 0x3FFFFFFF;
			seed += 12345;
			seed &= 0x3FFFFFFF;
			vals.push(seed);
		}
	}

	public function int() {
		idx = (idx + 1) % 55;
		var v = (vals[(idx + 24)%55] + idx) & 0x3FFFFFFF;
		vals[idx] = v;
		return v;
	}

	public function random( max ) {
		return int() % max;
	}

	public function rand() {
		return int() / 1073741824.0; // floating (1 << 30)
	}

}
