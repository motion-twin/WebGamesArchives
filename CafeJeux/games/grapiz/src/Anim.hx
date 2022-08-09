import mt.bumdum.Lib;

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
		if( r && onEnd != null ){
			onEnd();
		}
		return r;
	}
}

class AnimGlow implements Anim {	
	public var mc : flash.MovieClip;
	public var cur : Float;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	var speed : Int;

	public function new( m, ?s : Int ){
		mc = m;
		cur = 0;
		speed = s;
		if( speed == null ) speed = 5;
		play();
	}

	public function play(){
		var t = mt.Timer.tmod;
		cur += t;

		var p = 5 + 5 * Math.sin( cur / speed );
		mc._alpha = p;

		return false;
	}
}

class AnimFly implements Anim {
	public var mc : flash.MovieClip;
	var to : flash.MovieClip;
	var cur : Float;
	var length : Float;
	var start : {x: Float,y: Float};
	var zoom : Float;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;	
	
	public function new( m : flash.MovieClip, from: flash.MovieClip, t : flash.MovieClip ){
		mc = m;
		to = t;
		cur = 0;
		mc._x = from._x;
		mc._y = from._y;
		zoom = 0;
		start = {x: mc._x,y: mc._y };
		length = Math.sqrt( Math.pow( to._x - mc._x, 2 ) + Math.pow( to._y - mc._y, 2 ) );
	}

	public function play(){
		var t = mt.Timer.tmod * 8;
		cur += t;
	
		if( cur > length / 2 ){
			zoom -= t/length * 40;
		}else{
			zoom += t/length * 40;
		}

		mc._x = start.x + (to._x - start.x) * (cur / length);
		mc._y = start.y + (to._y - start.y) * (cur / length) - zoom / 4;

		mc._xscale = 100+zoom;
		mc._yscale = 100+zoom;

		if( cur >= length ){
			onEnd();
			return true;
		}
		onUpdate(mc,t/length);
		return false;
	}
}
