import Common;

interface Anim {
	public var mc : flash.MovieClip;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public function play() : Bool;
}

class ElevationAnim implements Anim {
	public var mc : flash.MovieClip;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var destinationY : Float;
	public var jump : Float;
	public var alphaJump :Float;
	public var steps : Int;
	public var useAlpha : Bool;
		
	public function new( mcc, destinationY : Float, useAlpha : Bool) {
		steps = 10;
		this.destinationY = destinationY;
		mc = mcc;
		jump = ( mc._y - destinationY ) / steps;
		this.useAlpha = useAlpha;
		if( useAlpha ) {
			alphaJump = 100 / steps;
			mc._alpha = 0;
		}
	}

	public function play() {
		var t = mt.Timer.tmod;
		mc._y -= jump * t;
		if( useAlpha ) 
			mc._alpha += alphaJump;
			
		if( steps-- <= 0 || mc._y <= destinationY ) {
			mc._alpha = 100;
			mc._y = destinationY;
			return true;
		}
		return false;
	}	
}

class SteppedAnim implements Anim {

	public var mc : flash.MovieClip;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var cur : Float;

	public function new( mcc, frame ) {
		mc = mcc;
		mc._visible = true;
		mc.gotoAndStop(frame);
		cur = 0;
	}

	public function play() {
		var t = mt.Timer.tmod;
		cur += t;
		mc.smc.gotoAndStop( Std.int( cur ) );
		onUpdate(mc,cur);
		if( cur >= mc.smc._totalframes -1 ) {
			mc._visible = false;
			return true;
		}
		return false;
	}
}
