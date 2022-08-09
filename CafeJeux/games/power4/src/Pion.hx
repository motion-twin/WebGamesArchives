enum PionKind {
	PNeutral;
	PMine;
	POther;
}

class Pion {

	var x : Int;
	var y : Int;
	public var kind : PionKind;
	public var mc : {> flash.MovieClip, sub : {> flash.MovieClip, sub : flash.MovieClip }};
	public var onMoveDone : Void -> Void;
	var game : Game;

	var glow : flash.filters.GlowFilter;
	var flare : flash.MovieClip;
	var time : Float;

	public function new( g, x, y, k ) {
		game = g;
		mc = cast game.dmanager.attach("pion",Const.PLAN_PION);
		kind = k;
		mc.gotoAndStop(switch( k ) { case PNeutral: 1; case PMine: if( game.first ) 2 else 3; case POther: if( game.first ) 3 else 2; });
		setPos(x,y);
	}

	public function setPos( x, y ) {
		this.x = x;
		this.y = y;
		mc._x = x * Const.SIZE;
		mc._y = y * Const.SIZE;
	}

	public function moveTo( x, y ) {
		this.x = x;
		this.y = y;
		game.anims.remove(this);
		game.anims.push(this);
	}

	public function update() {
		var tx = x * Const.SIZE;
		var ty = y * Const.SIZE;
		var p = Math.pow(0.6,mt.Timer.tmod);
		mc._x = mc._x * p + (1 - p) * tx;
		mc._y = mc._y * p + (1 - p) * ty;
		if( Math.abs(mc._x - tx) + Math.abs(mc._y - ty) < 2 ) {
			mc._x = tx;
			mc._y = ty;
			onMoveDone();
			return false;
		}
		return true;
	}

	public function visible( flag ) {
		mc._visible = flag;
		flare._visible = flag;
	}

	public function initGlow() {
		glow = new flash.filters.GlowFilter(0xFFFFFF,50,2,2,10);
		flare = game.dmanager.attach("flare",2);
		time = 0;
		mc._alpha = 80;
		mc.filters = [glow];
	}

	public function updateGlow( rot : Float ) {
		time += mt.Timer.tmod;
		glow.blurX = glow.blurY = 2 + Math.abs(Math.sin(time/10)) * 5;
		flare._x = mc._x;
		flare._y = mc._y;
		var trot = rot * 180 / Math.PI;
		var cur = flare._rotation;
		if( trot < 0 )
			trot += 360;
		if( cur < 0 )
			cur += 360;
		var delta = trot - cur;
		if( delta < 0 )
			delta += 360;
		if( delta > 180 ) {
			cur -= 20 * mt.Timer.tmod;
			if( cur < trot )
				cur = trot;
		} else {
			cur += 20 * mt.Timer.tmod;
			if( cur > trot )
				cur = trot;
		}
		flare._rotation = cur;
		mc.filters = [glow];
	}

	public function loopAnim() {
		var t = new haxe.Timer(1000);
		var me = this;
		t.run = playAnim;
	}

	public function playAnim() {
		mc.sub.sub.play();
	}

}
