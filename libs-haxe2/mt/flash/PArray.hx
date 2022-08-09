package mt.flash;

class PArray<T> extends Array<T> {

	public var cheat(getCheat,null) : Bool;
	var realLength : mt.flash.Volatile<Int>;

	public function new() {
		super();
		realLength = 0;
		cheat = false;
	}

	// concat
	// copy

	public override function insert( pos : Int, x : T ) {
		untyped Array["prototype"]["splice"]["call"](this,pos,0,x);
		realLength++;
		checkCheat();
	}

	// iterator
	// join

	public override function pop() {
		var x = super.pop();
		if( realLength > 0 ) realLength--;
		checkCheat();
		return x;
	}

	public override function push( x : T ) {
		var r = super.push(x);
		realLength++;
		checkCheat();
		return r;
	}

	// reverse

	public override function shift() {
		var x = super.shift();
		if( realLength > 0 ) realLength--;
		checkCheat();
		return x;
	}

	// slice
	// sort

	public override function splice( pos, len ) {
		var a = super.splice(pos,len);
		realLength -= a.length;
		checkCheat();
		return a;
	}

	// toString

	public override function unshift(x) {
		super.unshift(x);
		realLength++;
		checkCheat();
	}

	public function set(pos,v:T) {
		this[pos] = v;
		if( realLength <= pos ) realLength = pos + 1;
		checkCheat();
	}

	inline function checkCheat() {
		if( realLength != length ) cheat = true;
	}

	function getCheat() {
		checkCheat();
		return cheat;
	}

	static function initProto() untyped {
		var p : Dynamic = mt.flash.PArray.prototype;
		p["insert"] = p.insert;
		p["pop"] = p.pop;
		p["push"] = p.push;
		p["shift"] = p.shift;
		p["splice"] = p.splice;
		p["unshift"] = p.unshift;
	}

	static function __init__() initProto()

}
