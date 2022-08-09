package mt.deepnight.deprecated;

class Profiler {
	var chronos		: Hash< Array<Int> >;
	var stack		: Array<{k:String, t:Int}>;
	
	public var result	: flash.text.TextField;
	
	public function new() {
		chronos = new Hash();
		stack = new Array();
		
		result = new flash.text.TextField();
		result.textColor = 0xFFFF00;
		result.width = 250;
		result.height = 500;
		result.multiline = result.wordWrap = true;
		result.filters = [ new flash.filters.GlowFilter(0x0,1, 2,2,5) ];
		result.mouseEnabled = result.selectable = false;
		
		newCycle();
	}
	
	public inline function newCycle() {
		for(c in chronos)
			if( c.length>60 )
				c.splice(0, c.length-60);
		stack = new Array();
	}
	
	public inline function begin(k:String) {
		stack.push({k:k, t:now()});
	}
	
	public inline function endLatest() {
		if( stack.length>0 ) {
			//var s = stack[stack.length-1];
			var s = stack.pop();
			return stopChrono(s.k, s.t);
		}
		else
			return -1;
	}
	
	
	public function endSpecific(k:String) {
		for(s in stack)
			if( s.k==k ) {
				stack.remove(s);
				return stopChrono(s.k, s.t);
			}
				
		return -1;
	}
	
	inline function stopChrono(k:String, t:Int) {
		var d = now()-t;
		if( !chronos.exists(k) )
			chronos.set(k, []);
		var c = chronos.get(k);
		c.push(d);
		return d;
	}
	
	inline function now() {
		return flash.Lib.getTimer();
	}
	
	public function updateResult(?append:String) {
		var res = [];
		for( k in chronos.keys() ) {
			var c = chronos.get(k);
			var max = -1.;
			var avg = -1.;
			for( t in c ) {
				if( t>max )
					max = t;
				if( avg==-1 )
					avg = t;
				else
					avg+=t;
			}
			if( c.length>0 )
				avg/=c.length;
			res.push({k:k, avg:Math.round(avg*10)/10, max:max});
		}
		res.sort(function(a,b) return Reflect.compare(b.avg, a.avg));
		var lines = Lambda.map(res, function(r) return r.k+" --> "+r.avg+"ms ("+r.max+"ms)");
		if( append!=null )
			lines.push(append);
		if( result.visible )
			result.text = lines.join("\n");
	}
}