import Common;

interface Anim {
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public function play() : Bool;
	public function clean() : Void;
}

class CanonIn implements Anim {
	
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;

	var c : Canon;
	var i : Float;
	var delay : Float;
	var max : Float;
	static var count = 0;

	public function new(c : Canon ) {
		count++;
//		trace( count );
		this.c = c;
		i = 0.0;
		delay = Std.random( 20 );
		max = Const.CANON_WIDTH;
	}

	public function play() {
		if( delay-- > 0 ) return false;
		c.moveX( 1 );

		if( i++ >= max ) {
			return true;
		}
		return false;
	}

	public function clean() {
	}	
}

class MoveFireAnim implements Anim {
	
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;

	var c : Canon;
	var i : Int;
	var max : Int;
	var r : Float;
	var a : Float;

	public function new(c : Canon, target : Canon ) {
		this.c = c;
		i = 0;
		max = 15;
		r = 0.0;
		a = 0.0;

		if( c.invert ) {
			a = 90 + Math.atan2( target.mc.x - c.mc.x , target.mc.y - c.mc.y ) / Math.PI * 180 + this.c.mc.smc._rotation;
		}
		else {
			a = 90 - Math.atan2( target.mc.x - c.mc.x, target.mc.y - c.mc.y ) / Math.PI * 180 - this.c.mc.smc._rotation;
		}

		r = if( Math.floor( a ) == 0 ) 0 else a / max;
	}

	public function play() {
		if( c.invert ) 
			this.c.mc.smc._rotation -= r;
		else
			this.c.mc.smc._rotation += r;

		if( ++i >= max ) {
			return true;
		}
		return false;
	}

	public function clean() {
	}	
}

class FireAnim implements Anim {

	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;

	var c : Canon;
	var i : Int;
	var max : Int;
	var a : Float;
	var inc : Float;
	var maxW : Float;
	var radRot : Float;
	var rot : Float;

	public function new( c : Canon ) {
		this.c = c;
		i = 0;
		max = 15;
		a = 90;
		inc = 180 / max;
		maxW = this.c.mc.smc._width / 2;
		radRot = this.c.mc.smc._rotation * Math.PI / 180;
		rot = this.c.mc.smc._rotation;
	}

	public function play() {
		var rad = a * Math.PI / 180;

		var xrad = Math.cos( radRot ) * maxW;
		var yrad = Math.sin( radRot ) * maxW;

		var xr = xrad * Math.cos( rad );
		var yr = yrad * Math.cos( rad );

		if( rot == 0 ) 
			this.c.mc.smc._x = xr;
		else {
			this.c.mc.smc._x = xr;
			this.c.mc.smc._y = yr;
		}
	
		a += inc;
		if( ++i >= max ) {
			return true;
		}
		return false;
	}

	public function clean() {
	}	
}

class CanonOut implements Anim {
	
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;

	var c : Canon;
	var i : Float;
	var delay : Float;
	var max : Float;

	public function new(c : Canon ) {
		this.c = c;
		i = 0.0;
		max = Math.ceil( c.mc._width / 2 );
	}

	public function play() {
		c.moveX( -2 );

		if( i++ >= max ) {
			return true;
		}
		return false;
	}

	public function clean() {
		c.clean();
	}	
}

class Beware implements Anim {
	
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;

	var mc : flash.MovieClip;
	var i : Float;
	var max : Float;

	public function new( game : Game ) {
		mc = game.dm.attach( "mcBeware", Const.DP_CANON );
		mc._x = Const.HEIGHT / 2;
		mc._y = -15;
		mc._alpha = 0;
		i = 0.0;
		max = 20;
		onEnd = ending;
	}

	public function play() {
		mc._y++;
		mc._alpha += 5;

		if( i++ >= max ) {
			return true;
		}
		return false;
	}

	function ending() {
		var p = new mt.bumdum.Phys( mc );
		p.timer = 20;
		p.fadeLimit = 15;
		p.fadeType = 5;
	}

	public function clean() {
	}	
}
