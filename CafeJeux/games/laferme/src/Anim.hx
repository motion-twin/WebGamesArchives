import Common;

interface Anim {
	public var mc : flash.MovieClip;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public function play() : Bool;
}

class FallAnim implements Anim {

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
