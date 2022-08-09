import flash.Key ;
import mt.bumdum.Lib ;
import anim.Anim.AnimType ;
import anim.Transition ;


class ZoneEffect {
	
	static var STR_MAX = 6 ;
	static var STR_MIN = 6 ;
	static var GLOW_COL = 0x339900 ;
	static var BLUR = 250 ;
	static var AL_MAX = 100 ;
	static var AL_MIN = 50 ;
	
	static var WIDTH = 500 ;
	static var HEIGHT = 300 ;
	
	static var parent : Dynamic ;
	var glowId : String ;
	public var dm : mt.DepthManager ;
	public var mc : flash.MovieClip ;
	var bmp : flash.display.BitmapData ;
	var matrix : flash.geom.Matrix ;
	var timer : Float ;
	var step : Int ;
	var side : Int ;
	var fromOut : Float ;
	

	
	
	public function new(gid : String, parent, dp : Int) {
		ZoneEffect.parent = parent ;
		
		mc = parent.me.mdm.empty(dp) ;
		dm = new mt.DepthManager(mc) ;
		mc.beginFill(1, 0) ;
		mc.moveTo(0, 0) ;
		mc.lineTo(WIDTH, 0) ;
		mc.lineTo(WIDTH, HEIGHT) ;
		mc.lineTo(0, HEIGHT) ;
		mc.lineTo(0, 0) ;
		mc.endFill() ;
		
		step = 0 ;
		timer = 0.0 ;
		side = -1 ;
		
		glowId = gid ;
		startGlow() ;
	}
	

	public function startGlow() {
		switch(glowId) {
			case "cthulo" : 
				bmp = new flash.display.BitmapData(WIDTH, HEIGHT, false, 0x777777) ;
				mc.attachBitmap(bmp, 1) ;
				mc._alpha = 0 ;
				mc.blendMode = "overlay" ;
				
				var fl = new flash.filters.GlowFilter() ;
				fl.blurX = BLUR ;
				fl.blurY = BLUR ;
				fl.strength =  STR_MAX ;
				fl.color = GLOW_COL ;
				fl.inner = true ;
				fl.quality = 1 ;

				var a = mc.filters ;
				a.push(fl) ;
				mc.filters = a ;
		}
	}
	
	
	public function update() {
		switch (glowId) {
			case "cthulo" : 
				switch (step) {
					case 0 : //wait
						timer = Math.min(timer + 0.02 * mt.Timer.tmod, 1) ;
						var delta = 1 - anim.TransitionFunctions.quad(1 - timer) ;
					
						mc._alpha = AL_MAX * delta ;
					
						parent.me.setShake(1,1) ;
						
						if (timer == 1) {
							step = 1 ;
							timer = 0.0 ;
						}
					case 1 : 
						timer = Math.min(timer + 0.02 * mt.Timer.tmod, 1) ;
					
						parent.me.setShake(1,1) ;
					
						var t = if (side > 0)
									1 - anim.TransitionFunctions.quad(1 - timer) ;
								else 
									1 - anim.TransitionFunctions.quad(timer) ;
						mc._alpha = AL_MIN + (AL_MAX - AL_MIN) * t ;
					
						if (timer == 1) {
							side = side * -1 ;
							timer = 0.0 ;								
						}
					
					

					case 2 : //go out
						timer = Math.min(timer + 0.02 * mt.Timer.tmod, 1) ;
						var delta = 1 - anim.TransitionFunctions.quad(1 - timer) ;
					
						mc._alpha = fromOut * (1.0 - delta) ;
					
						if (timer == 1)
							kill() ;
				}
		}
		
		
	}
	
	
	public function goOut() {
		switch(glowId) {
			case "cthulo" : 
				fromOut = mc._alpha ; 
				timer = 0.0 ;
				step = 2 ;
		
		}
	}
	
	
	function kill() {
		if (bmp != null)
			bmp.dispose() ;
		if (mc != null)
			mc.removeMovieClip() ;
		glowId = null ;
		parent.me.effect = null ;
	}
		
	
}