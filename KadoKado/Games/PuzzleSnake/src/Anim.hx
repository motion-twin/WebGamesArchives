interface Anim {
	public var mc : flash.MovieClip;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;

	public function play() : Bool;
}

class AnimPlay implements Anim {
	public var mc : flash.MovieClip;
	public var start : Int;
	public var end : Int;
	public var wait : Int;
	public var cur : Float;
	public var length : Int;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var flip : Bool;
	public var loop : Bool;

	public function new( m, p : { start:Int, end:Int }, ?w : Int, ?oe : Void -> Void, ?f: Bool, ?ou : flash.MovieClip -> Float -> Void, ?l : Bool ){
		mc = m;
		start = p.start;
		end = p.end;
		wait = if( w == null ) 0 else w;
		cur = 0;
		length = end - start + wait;
		onEnd = oe;
		onUpdate = ou;
		flip = f;
		loop = l;
		if( flip ) mc._xscale *= -1;
	}

	public function play(){
		var t = mt.Timer.tmod;
		cur += t;
		if( cur >= wait ){
			mc.gotoAndStop( Std.int(start + cur -wait) );
			if( onUpdate != null ) onUpdate( mc, t / (end - start) );
		}
		var r = cur >= length;
		if( r && loop ){
			cur -= length;
			return false;
		}else{
			if( r && onEnd != null ){
				onEnd();
				if( flip ) mc._xscale *= -1;
			}
			return r;
		}
	}
}

class AnimMove implements Anim {	
	public var mc : flash.MovieClip;
	public var start : {x: Float,y: Float};
	public var end : {x: Float,y: Float};
	public var wait : Int;
	public var cur : Float;
	public var duration : Int;
	public var length : Int;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;

	public function new( m, p, d:Int, ?w : Int, ?oe : Void -> Void, ?ou : flash.MovieClip -> Float -> Void ){
		mc = m;
		start = p.start;
		end = p.end;
		duration = d;
		wait = if( w == null ) 0 else w;
		cur = 0;
		length = wait + duration;
		onEnd = oe;
		onUpdate = ou;
	}

	public function play(){
		var t = mt.Timer.tmod;
		cur += t;
		if( cur >= wait ){
			mc._x = start.x + (end.x - start.x) * ((cur - wait) / duration);
			mc._y = start.y + (end.y - start.y) * ((cur - wait) / duration);
			if( onUpdate != null ) onUpdate( mc, t / duration );
		}
		var r = cur >= length;
		if( r ){
			mc._x = end.x;
			mc._y = end.y;
			if( onEnd != null ) onEnd();
		}
		return r;
	}
}

class BeurkAnim implements Anim {
	public var mc : flash.MovieClip;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;

	var ended : Bool;

	var wait : Int;
	var cur : Float;
	var length : Int;
	
	public function new( w : Int, oe : Void -> Void, l : Int ){
		wait = w;
		cur = 0;
		length = l;
		onEnd = oe;
		ended = false;
	}

	public function play(){	
		cur += mt.Timer.tmod;

		var r = cur >= wait;
		if( r && !ended ){
			ended = true;
			if( onEnd != null ) onEnd();
		}
		r = cur >= wait + length;
		return r;
	}
}
