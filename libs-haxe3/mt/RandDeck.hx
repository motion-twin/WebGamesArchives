package mt;
import haxe.ds.Vector;

class RandDeck<T> {
	public var size (default, null) : Int;
	var a    : Vector<T>;
	var cur  : Int;
	var max  : Int;
	var rnd  : Int->Int;

	public function new(?rnd : Int->Int) {
		cur  = 0;
		max  = 0;
		size = 0;
		this.rnd = (rnd == null) ? Std.random : rnd;
	}

	function grow(min = 0) {
		max = max * 2 + 8;
		if (max < min) max = min;

		var old = a;
		// fix for haxe 3.3 (see https://github.com/HaxeFoundation/haxe/issues/5093)
		#if flash
		untyped a = new flash.Vector(max, true);
		#else
		a = new Vector(max);
		#end
		Vector.blit(old, 0, a, 0, size);
	}

	public function push(v : T, n = 1) {
		var newSize = size + n;
		if (newSize > max) grow(newSize);
		for (i in size...newSize) a[i] = v;
		size = newSize;
	}

	public function shuffle() {
		cur = 0;
		for (i in 0...(size-1)) {
			var j = rnd(size - i);
			var tmp = a[i];
			a[i] = a[i + j];
			a[i + j] = tmp;
		}
	}

	public inline function countRemaining() return size-cur;

	public function clear() {
		cur  = 0;
		size = 0;
	}

	public function pop() : Null<T> {
		if( size==0 ) return null;
		if (++cur == size)
			shuffle();
		return a[cur];
	}

	public function peek() : Null<T> {
		return a[cur];
	}

	// Removes all elements for which cond returns false from deck
	// Keep current deck order, updates cur and size
	public function filter( cond : T -> Bool ){
		var i = 0;
		while( i < size ){
			if( cond( a[i] ) )
				i++;
			else{
				if( i <= cur )
					cur--;
				if( size - 1 - i > 0 )
					haxe.ds.Vector.blit(a,i+1,a,i,size-i-1);
				size--;
			}
		}
	}
}