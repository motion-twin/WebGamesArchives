package result ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import mt.bumdum.Sprite ;
import anim.Anim.AnimType ;
import anim.Transition ;
import CauldronData.CauldronResult ;
import Cauldron.Step ;
import GameData._ArtefactId ;
import result.Result.ResultStep ;
import Inventory.InvObject ;




class Forbidden extends Result {
	
	static var STR_MAX = 6 ;
	static var STR_MIN = 6 ;
	static var GLOW_COL = 0xFF3300 ;
	static var BLUR = 250 ;
	static var AL_MAX = 100 ;
	static var AL_MIN = 65 ;

	var tstep : Int ;
	var timer : Float ;
	var side : Int ;
	var fromOut : Float ;
	var bmp : flash.display.BitmapData ;
	

	public function new() {
		super() ;
		step = Prepare ;
		initMcs() ; 
		tstep = 0 ;
		timer = 0.0 ;
		side = -1 ;
	}
	
	
	override function initMcs() {
		super.initMcs() ;
		
		bmp = new flash.display.BitmapData(500, 300, false, 0x777777) ;
		mc.attachBitmap(bmp, 1) ;
		mc._alpha = 0 ;
		mc.blendMode = "overlay" ;
		//Filt.glow(mc, BLUR, STR_MAX, GLOW_COL, true) ;
		
		var fl = new flash.filters.GlowFilter();
		fl.blurX = BLUR ;
		fl.blurY = BLUR ;
		fl.strength =  STR_MAX ;
		fl.color = GLOW_COL ;
		fl.inner = true ;
		fl.quality = 1 ;

		var a = mc.filters ;
		a.push(fl) ;
		mc.filters = a ;
			
		step = Wait ;
			
	}

	
	override public function loop() {
		
		switch(step) {
			case Prepare, GoOut : //nothing to do
				
				
			case Wait : 
				Cauldron.me.setShake(1,1) ;
			
				switch (tstep) {
					case 0 : //wait
						timer = Math.min(timer + 0.02 * mt.Timer.tmod, 1) ;
						var delta = 1 - anim.TransitionFunctions.quad(1 - timer) ;
					
						//Filt.glow(mc, BLUR, STR_MAX * delta, GLOW_COL, true) ;
						mc._alpha = AL_MAX * delta ;
						
						
						if (timer == 1) {
							tstep = 1 ;
							timer = 0.0 ;
							mc.onRelease = initOut ;
						}
					case 1 : 
						timer = Math.min(timer + 0.04 * mt.Timer.tmod, 1) ;
					
						//mc.filters = [] ;
					
						var t = if (side > 0)
									1 - anim.TransitionFunctions.quad(1 - timer) ;
								else 
									1 - anim.TransitionFunctions.quad(timer) ;
						//Filt.glow(mc, BLUR, STR_MIN + (STR_MAX - STR_MIN) * t, GLOW_COL, true) ;
						mc._alpha = AL_MIN + (AL_MAX - AL_MIN) * t ;
					
						if (timer == 1) {
							side = side * -1 ;
							timer = 0.0 ;
						}
					
					

					case 2 : //go out
						timer = Math.min(timer + 0.02 * mt.Timer.tmod, 1) ;
						var delta = 1 - anim.TransitionFunctions.quad(1 - timer) ;
					
						//mc.filters = [] ;
						//Filt.glow(mc, BLUR, STR_MAX * (1.0 - delta), GLOW_COL, true) ;
						mc._alpha = fromOut * (1.0 - delta) ;
					
						if (timer == 1)
							step = Exit ;
						
					
				}

			case Exit : 
				kill() ;
				//Cauldron.me.setStep(Default) ;
				Cauldron.me.postResult() ;
		}
	}
	
	
	public function initOut() {
		mc.onRelease = null ;
		Cauldron.me.resetSubmitAnim() ;
		//step = Exit ;
		fromOut = mc._alpha ; 
		timer = 0.0 ;
		tstep = 2 ;
		
	}
	
	
	override public function kill()  {
		if (mc != null)
			mc.removeMovieClip() ;
		
		super.kill() ;
	}
	
	
}