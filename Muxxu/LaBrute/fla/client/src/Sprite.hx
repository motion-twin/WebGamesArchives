import mt.bumdum.Lib;
class Sprite{//}

	static public var SHADOW_ALPHA = 70;

	static public var spriteList : Array<Sprite> = new Array() ;
	static public var forceList : Array<Sprite> = new Array() ;

	public var x : Float ;
	public var y : Float ;
	public var z : Float ;
	public var ray : Float ;
	public var force : Float ;
	public var scale : Float ;
	public var flShade : Bool ;
	public var root : flash.MovieClip ;
	public var shade : flash.MovieClip ;


	public function new(?mc : flash.MovieClip) {

		root = mc ;

		var mmc = cast root;
		mmc.obj = this;

		x = 0 ;
		y = 0 ;
		z = 0 ;
		ray = 0 ;
		scale = 100 ;
		flShade = false ;
		spriteList.push(this) ;
	}


	public function setScale(n) {
		scale = n ;
		root._xscale =  n ;
		root._yscale =  n ;
	}

	public function update() {

		updatePos();
	}
	public function updatePos(){
		var by = Cs.HOR + y * (1-Cs.CZ) ;
		root._x = x ;
		root._y =  by + z * Cs.CZ ;
		if (flShade) {
			shade._x = x ;
			shade._y = by ;
		}
	}


	public function setRay(r : Float) {
		ray = r ;
		if (flShade) updateShadeSize();
	}

	public function dropShadow() {
		if(flShade)return;
		flShade = true ;
		shade = Game.me.dm.attach("mcShade", Game.DP_SHADE) ;

		updateShadeSize();
		shade._x = -10000;
		Col.setColor(shade,0x663300,0);
		shade._alpha = SHADOW_ALPHA ;
		//shade.blendMode = "overlay";

	}
	public function updateShadeSize(?c:Float){
		if(c==null)c=1;
		shade._xscale = ray *2* c  ;
		shade._yscale = ray *2* c * Cs.CZ ;

	}


	public function getDist(o : {x : Float, y : Float}) {
		var dx = x - o.x ;
		var dy = y - o.y ;
		return Math.sqrt(dx * dx + dy * dy) ;
	}
	public function getAng(o : {x : Float, y : Float}) {
		var dx = x - o.x ;
		var dy = y - o.y ;
		return Math.atan2(dy, dx) ;
	}

	public function setForce(n : Float) {
		force = n ;
		forceList.push(this) ;
	}

	public function kill() {
		spriteList.remove(this) ;
		if(force!=null)forceList.remove(this) ;
		shade.removeMovieClip() ;
		root.removeMovieClip() ;

	}




//{
}