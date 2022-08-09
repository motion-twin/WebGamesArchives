

class Spirit {
	
	
	static public var DATA_URL : String = null ;
	static  var PNJ_DX = 0 ;
	static  var PNJ_DY = 0 ;
	static 	var RAD	= 6.28;
	static 	var MCH	= 180;
	static 	var MCW	= 120;
	static 	var MAXDEV	= 6;
	
	var pos : Float;
	public var y : Float ;
	public var x : Float ;
	
	public var id : String ;
	public var pf : Void -> Void ;
	public var mc : {>flash.MovieClip, _next : Void -> Void, _sfloat : Int -> Void, _shake : Int -> Void} ;
	
	var flShake : Bool ;
	var flFloat : Bool ;
	var shakeTimer : Float ;
	var frot : Float ;
	var frotdone : Bool ;
	public var initDone : Bool ;
	
	
	
	
	public function new(id : String, mc : flash.MovieClip, ff : Void -> Void) {
		
		this.id = id ;
		//pos = Math.random()*RAD ;
		pos = 3.14 / 2 ;
		
		flFloat = false ;
		flShake = false ;
		frot = 2 ;
		frotdone = true ;
		initDone = false ;

		pf = ff ;
		this.mc = cast mc ;
		
		init() ;
	}
	
	/*public function initGamePos(){
		mc._x = -MCW/2;
		mc._y = -MCH/2 ;	
	}*/
	
	public function setFrame(f : Dynamic) {
		mc.smc.gotoAndStop(f) ;
	}
	
	
	public function play(f : Dynamic) {
		if (f == null)
			return ;
		mc.smc.gotoAndPlay(f) ;
	}
	
	
	function init() {
		mc.gotoAndStop(1) ;
		setFrame(1) ;
		y = mc._y ;
		x = mc._x ;
		mc._rotation = Math.sin(pos) * frot ;
		Reflect.setField(mc, "_next", pf) ;
		Reflect.setField(mc, "_sfloat", sfloat) ;
		Reflect.setField(mc, "_shake", shake) ;
	}
	
	
	public function kill() {
		if (mc != null)
			mc.removeMovieClip() ;
	}
	
	
	public function sfloat(c : Int) {
		flFloat = c == 1 ;
	}
	
	
	public function shake(c : Int) {
		var old = flShake ;
		flShake = c == 1 ;
		if (flShake && flShake != old)
			shakeTimer = 1.0 ;
	}
	
	
	public function update() {
		if (!initDone)
			return ;
		
		if (flFloat || Math.abs(y - mc._y) > 2.0) {
			pos = (pos - 0.05) % RAD;
			mc._y =  y + (Math.cos(pos)*MAXDEV) ;
			mc._rotation = Math.sin(pos) * frot ;
			if (Math.abs(mc._rotation) < 0.12 && frotdone && Std.random(3) == 0) {
				frotdone = false ;
				frot = Math.random() * 3  * (Std.random(2) * 2 - 1) ;
			} else 
				frotdone = true ;
		}
		
		
		if (flShake || shakeTimer > 0.0) {
			mc._x = x + Std.random(Math.round(shakeTimer * 6)) / 6 * (Std.random(2) * 2 - 1) ;
			mc._y = y + Std.random(Math.round(shakeTimer * 3)) / 3 * (Std.random(2) * 2 - 1) ;
			
			if (!flShake)
				shakeTimer -= 0.2 ;
		}
	}
	
	
	
}