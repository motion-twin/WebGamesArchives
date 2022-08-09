package mt.deepnight.deprecated;

class Range {
	public var min(default,setMin)	: Int;
	public var max(default,setMax)	: Int;
	public var inclusive			: Bool;
	
	public function new(a:Int, b:Int, inclusive:Bool) {
		if (a>=b) {
			max = a;
			min = b;
		}
		else {
			max = b;
			min = a;
		}
		this.inclusive = inclusive;
	}
	
	public function iter() {
		return if(inclusive) new IntIter(min, max+1) else new IntIter(min, max);
	}
	
	public function setMin(v:Int) {
		min = v;
		if (min>max)
			throw "invalid range "+this;
		return min;
	}

	public function setMax(v:Int) {
		max = v;
		if (max<min)
			throw "invalid range "+this;
		return max;
	}

	
	// --- Constructeurs
	public static function makeInclusive(a:Int, b:Int) { // tirage [a,b]
		return new Range(a, b, true);
	}
	public static function makeNonInclusive(a:Int, b:Int) { // b exclu, tirage [a,b[
		return new Range(a, b, false);
	}
	public static function single(a) {
		return new Range(a, a, true);
	}
	// ------------------
	
	
	public inline function getLength() {
		return max-min + if(inclusive) 1 else 0;
	}
	
	public inline function draw(?randMethod:Int->Int) {
		if (randMethod==null)
			randMethod = Std.random;
		if (min==max)
			return min;
		else
			if(inclusive)
				return min + randMethod( max-min+1 );
			else
				return min + randMethod( max-min );
	}
	
	public function toString() {
		return "[" + min+"=>"+max + (inclusive?"]":"[");
	}
	
	public inline function clone() {
		return new Range(min,max,inclusive);
	}
	
	public inline function isIn(n:Int) {
		return n>=min && (inclusive && n<=max || !inclusive && n<max);
	}
	
	public inline function isOut(n:Int) {
		return !isIn(n);
	}
}
