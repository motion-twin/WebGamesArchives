
class Dino {

	public var mc : flash.MovieClip;
	public var px : Float;
	public var py : Float;
	public var tx : Float;
	public var ty : Float;
	public var speed : Float;
	public var delay : Float;
	public var flip : Bool;
	public var moving : Bool;
	var gfx : String;
	var name : String;
	var curAnim : String;

	public function new(inf,mc) {
		gfx = inf._g;
		name = inf._n;
		this.mc = mc;
		delay = 0;
		var l = new flash.MovieClipLoader();
		var me = this;
		var k = 0;
		l.onLoadComplete = l.onLoadInit = function(_) {
			k++;
			if( k == 2 ) {
				me.playAnim("");
				me.mc._visible = false;
				me.onLoaded();
			}
		};
		l.loadClip(View.DATA._sdino,mc);
	}

	public function update() {
		if( delay > 0 ) {
			delay--;
			return;
		}
		var dx = tx - px;
		var dy = ty - py;
		var d = Math.sqrt(dx*dx+dy*dy);
		if( d < 0.1 ) {
			px = tx;
			py = ty;
			moving = false;
			playAnim("stand");
		} else {
			if( d > speed ) {
				dx *= speed / d;
				dy *= speed / d;
			}
			px += dx;
			py += dy;
			moving = true;
			playAnim("walk");
		}
		mc._xscale = flip ? -100 : 100;
		mc._x = px * View.SIZE + (flip?40:0);
		mc._y = py * View.SIZE;
	}

	public dynamic function onLoaded() {
	}

	public function playAnim( a : String ) {
		if( curAnim == a )
			return;
		curAnim = a;
		var skin : Dynamic = mc;
		skin._p0._p1._anim.gotoAndStop(a);
		skin._init(gfx,0,true);
		skin._p0._s._visible = false;
	}

}
