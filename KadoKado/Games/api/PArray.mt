
class PArray<'item> extends Array<'item> {

	var cheat : bool;
	volatile var realLength : int;

	public function new() {
		super();
		realLength = 0;
		cheat = false;
	}

	// duplicate

	public function insert( pos, x ) {
		downcast(Array).prototype.splice.call(this,pos,0,x);
		realLength++;
		if( realLength != length ) cheat = true;
	}

	// join

	public function pop() {
		var x = super.pop();
		if( realLength > 0 ) realLength--;
		if( realLength != length ) cheat = true;
		return x;
	}

	public function push(x) {
		var r = super.push(x);
		realLength++;
		if( realLength != length ) cheat = true;
		return r;
	}

	// remove : use splice
	// reverse

	public function shift() {
		var x = super.shift();
		if( realLength > 0 ) realLength--;
		if( realLength != length ) cheat = true;
		return x;
	}

	// slice
	// sort

	public function splice( pos, len ) {
		var a = super.splice(pos,len);
		realLength -= cast(a).length;
		if( realLength != length ) cheat = true;
		return a;
	}

	// toString

	public function unshift(x) {
		super.unshift(x);
		realLength++;
		if( realLength != length ) cheat = true;
	}

	public function getCheat() {
		if( realLength != length ) cheat = true;
		return cheat;
	}

}
