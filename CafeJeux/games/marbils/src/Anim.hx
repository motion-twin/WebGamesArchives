interface Anim {
	public var mc : flash.MovieClip;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Int -> Float -> Void;

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
	public var onUpdate : flash.MovieClip -> Int -> Float -> Void;
	public var flip : Bool;
	public var loop : Bool;
	
	var flipDone : Bool;

	public function new( m, p : { start:Int, end:Int }, ?w : Int, ?oe : Void -> Void, ?f: Bool, ?ou : flash.MovieClip -> Int -> Float -> Void, ?l : Bool ){
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
		flipDone = false;
	}

	public function play(){
		var t = mt.Timer.tmod;
		cur += t;
		if( cur >= wait ){
			if( flip && !flipDone ){
					mc._parent._xscale *= -1;
					flipDone = true;
			}

			var f = Std.int(start + cur -wait);
			if( f > end ) f = end;
			
			mc.gotoAndStop( f );
			if( onUpdate != null ) onUpdate( mc, Std.int(cur - wait), t / (end - start) );
		}
		var r = cur >= length;
		if( r && loop ){
			cur -= length;
			return false;
		}else{
			if( r && onEnd != null ){
				onEnd();
				if( flip && flipDone ) mc._parent._xscale *= -1;
			}
			return r;
		}
	}
}

class AnimFadeRemove implements Anim {
	public var mc : flash.MovieClip;
	public var wait : Int;
	public var cur : Float;
	public var length : Int;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Int -> Float -> Void;
	
	public function new( m, ?w : Int, l : Int ){
		mc = m;
		wait = if( w == null ) 0 else w;
		length = l;
		cur = 0;
	}

	public function play(){
		var t = mt.Timer.tmod;
		cur += t;
		if( cur >= wait ){
			mc._alpha = (1-(cur - wait)/(length-wait))*100;
		}
		var r = cur >= length;
		if( r )
			mc.removeMovieClip();
		return r;
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
	public var onUpdate : flash.MovieClip -> Int -> Float -> Void;

	public function new( m, p, d:Int, ?w : Int, ?oe : Void -> Void, ?ou : flash.MovieClip -> Int -> Float -> Void ){
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
			if( onUpdate != null ) onUpdate( mc, Std.int(cur - wait), t / duration );
		}
		var r = cur >= length;
		if( r && onEnd != null ){
			onEnd();
		}
		return r;
	}
}
