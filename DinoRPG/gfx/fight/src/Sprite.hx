class Sprite {

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
	public var shadeType : Int ;

	public function new(?mc : flash.MovieClip) {
		root = mc ;
		var mmc = cast root;
		mmc.obj = this;
		x = 0 ;
		y = 0 ;
		z = 0 ;
		ray = 0 ;
		scale = 100 ;
		shadeType = 0 ;
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
		var by = Scene.getY(y);
		root._x = x ;
		root._y = by + z * 0.5;
		if( flShade ) {
			shade._x = x ;
			shade._y = by ;
		}
	}
	
	public static function get3D( x:Float, y:Float ): { x:Float, y:Float, z:Float } {
		return { x: x, y : Scene.getGY(y), z:(y - Scene.getGY(y)) * 2 };
	}

	public function setRay(r : Float) {
		ray = r ;
		if( flShade) updateShadeSize();
	}

	public function dropShadow() {
		if(flShade) return;
		flShade = true ;
		shade = Main.me.scene.dm.attach("mcShade", Scene.DP_SHADE) ;
		shade._alpha = 40 ;
		updateShadeSize();
		shade._x = -10000;
		shade.gotoAndStop(shadeType+1);
	}
	
	public function updateShadeSize(?c:Float){
		if(c == null) c = 1;
		shade._xscale = ray * c * 5 ;
		shade._yscale = ray * c * 5 * 0.5 ;
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
		if(force != null)forceList.remove(this) ;
		shade.removeMovieClip() ;
		root.removeMovieClip() ;
	}
}
