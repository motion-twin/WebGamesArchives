package mt.gx;
import mt.Rand;

typedef Data<T> = Array<T>;

@:publicFields
@:generic
private class _Slots<T> {
	var content : Data<T>;
	var cur : Int;
	
	var allocLength : Int;
	
	inline function iterator() {
		throw "DONT USE THIS at all";
	}
	
	inline function new(len) {
		allocLength = len;
		content=[];
		content[len] = content[0];
		cur = 0;
	}
	
}

@:generic
abstract Slots<T>(_Slots<T>) {
	
	public inline function new(len) {
		this = new _Slots<T>(len);
	}
	
	public var length(get, set):Int;
	
	inline function get_length() {
		return this.cur;
	}
	
	inline function set_length(len) {
		#if debug
			if ( len <= this.allocLength) throw "insufficient capacity";
		#end
		
		return this.cur=len;
	}
	
	/**
	 * add data at the end of the buffer
	 */
	public inline function push(v:T) : T {
		#if debug
			if ( this.cur > this.allocLength) throw "insufficient capacity";
		#end
		
		return this.content[this.cur++] = v;
	}
	
	public inline function getNull(){
		return this.content[this.allocLength];
	}
	
	/**
	 * remove data and bring back last elem in current place
	 * 
	 *  NEVER REMOVE in a forward loop, for loop with removal prefer backward loop 
	 * 
	 * var i = vec.length;
	 * while(i-->0){
	 *  var e = vec[i];
	 * 	foo(e);
	 *  remove(i);
	 * }
	 */
	public function remove(idx:Int){
		if(this.cur>0){
			this.content[idx] = this.content[this.cur - 1];
			this.content[this.cur - 1] = getNull();
			this.cur--;
		}
	}
	
	public inline function fill(v) : Slots<T>{
		for ( i in 0...this.cur ) this.content[i] = v;
		return cast this;
	}
	
	/**
	 * can't clear pointed values because it depends of the backing type so you might want to make a 
	 * fill(null/0/false);
	 * clear();
	 * to clear the actual data adequately
	 */
	public inline function clear() : Slots<T> {
		for ( i in 0...this.cur ) this.content[i] = getNull();
		this.cur = 0;
		return cast this;
	}

	@:arrayAccess private inline function arrayRead(idx:Int) : T {
		#if debug
		if( idx >= this.allocLength) throw "Slot read overflow";
		#end
		return this.content[idx];
	}
	
	@:arrayAccess private inline function arrayWrite(idx:Int, v :  T) : T {
		#if debug 
			if ( idx >= this.allocLength ) throw "Slot write overflow";
			if ( idx < 0 )   throw "Slot write  underflow";
		#end
		
		this.cur = idx + 1;
		return this.content[idx] = v;
	}
	
	#if !js
	/**
	 * Normalised random table pick
	 * if weight is zero, element will never be considered
	 */
	public static function nRand<Elem:{weight:Int}>( sl : Slots<Elem>,r : mt.Rand ) : Elem
	{
		var sum : Int = 0;
		for (i in 0...sl.length) 
			sum += sl[i].weight;
			
		if ( sum == 0 )return null;
			
		var rd : Int = 1+r.random(sum-1);
		for (i in 0...sl.length) {
			var x = sl[i];
			rd -= x.weight;
			if (rd <= 0 && x.weight != 0 ){
				mt.gx.Debug.assert( x.weight != 0);
				return x;
			}
		}
		return null;
	}
	#end
}