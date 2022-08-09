package mt.gx.algo;
import mt.gx.MathEx;


class RingBuffer<T>{
	public var repo : Array<T>;
	var cur:Int; //cur is last pushable entry
	var max:Int;
	public var length(get, never):Int;
	inline function get_length() return mt.gx.MathEx.mini( max, repo.length );
	
	public function new(max) {
		cur = 0;
		this.max = max;
		repo = [];
	}
	
	public inline function push(e) {
		var maxLen = repo.length+1 < max ? repo.length+1 : max;
		var idx = MathEx.posMod(cur, maxLen);
		repo[idx] = e;
		
		var maxLen = repo.length+1 < max ? repo.length+1 : max;
		cur = MathEx.posMod(cur+1, maxLen);
	}
	
	public inline function writePos() {
		return cur;
	}
	
	public inline function last() {
		return get(cur-1);
	}
	
	public function get(i) {
		return repo[ MathEx.posMod( writePos()+i, length) ];
	}
	
}