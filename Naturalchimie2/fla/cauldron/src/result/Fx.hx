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




class Fx extends Result {
	
	static var STR_MAX = 6 ;
	static var STR_MIN = 6 ;
	static var GLOW_COL = 0x339900 ;
	static var BLUR = 250 ;
	static var AL_MAX = 100 ;
	static var AL_MIN = 65 ;

	public var id : String ;
	public var mcAnim : flash.MovieClip ;
	public var mcKeeper : flash.MovieClip ;
	var bmp : flash.display.BitmapData ;
	var matrix : flash.geom.Matrix ;
	var side : Int ;
	var scount : Int ;
	var fromOut : Float ;
	var tstep : Int ;
	var tRedux : Array<Int> ;
	var lastScale : Float ;
	var timer : Float ;
	
	
	
	public function new(fid : String) {
		super() ;
		id = fid ;
		step = Prepare ;
		initMcs() ; 
		tstep = 0 ;
		timer = 0.0 ;
	}
	
	
	override function initMcs() {
		super.initMcs() ;
		
		switch(id) {
			case "umbra" : 
				mcKeeper = Cauldron.me.keeper.mc ;
			
			
				matrix = new flash.geom.Matrix() ;
				matrix.c = Math.tan(0.0) ;
						
				mcAnim = Cauldron.me.mdm.attach("vanish", Cauldron.DP_BG) ;
				mcAnim._x = 500 ;
				mcAnim._y = 300 ;
				mcAnim.gotoAndStop(1) ;
				mcAnim._visible = false ;
			
				mcMask = Cauldron.me.mdm.attach("vanishMask", Cauldron.DP_ELEMENTS_BG) ;
				mcMask._x = 515 ;
				mcMask._y = 305 ;
			
				mcKeeper.setMask(mcMask) ;
				
				step = Wait ;
				
				
			case "redux" : 
				mcKeeper = Cauldron.me.keeper.mc ;
				tRedux = [5, 15, 30, 50] ;
				lastScale = 100 ;
				Cauldron.me.setShake(3,4) ;
				scount = 0 ;
				
				step = Wait ;
				
			case "coliq" :
				mcKeeper = Cauldron.me.keeper.mc ;
				
				bmp = new flash.display.BitmapData(500, 300, false, 0x777777) ;
				mc.attachBitmap(bmp, 1) ;
				mc._alpha = 0 ;
				mc.blendMode = "overlay" ;
				
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
		
	}
	
	function setSquew(r : Float, ?xsc : Float, ?ysc : Float) {
		matrix.c = Math.tan(r) ;
		
		if (xsc != null)
			matrix.a = xsc ;
		
		if (ysc != null)
			matrix.d = ysc ;
		
		mcKeeper.transform.matrix = matrix ;
		mcKeeper._x = 500 ;
		mcKeeper._y = 300 ;
	}

	
	override public function loop() {
		
		switch(step) {
			case Prepare, GoOut : 
				//nothing to do
				
			case Wait : 
			
				switch(id) {
					case "umbra" : 
						
						var maxSquew = 0.480 ;	
							
						Cauldron.me.setShake(1,2) ;
					
						switch (tstep) {
							case 0 : //wait
								timer = Math.min(timer + 0.03 * mt.Timer.tmod, 1) ;
							
								if (timer == 1) {
									tstep = 1 ;
									timer = 0.0 ;
									setSquew(-0.08) ;
									mcAnim._visible = true ;
									mcAnim.gotoAndPlay(1) ;
									
								}
							case 1 : 
								timer = Math.min(timer + 0.07 * mt.Timer.tmod, 1) ;
							
								if (timer == 1) {
									tstep = 2 ;
									timer = 0.0 ;
									setSquew(-0.085) ;
								}
							
							case 2 : 
								timer = Math.min(timer + 0.055 * mt.Timer.tmod, 1) ;
								setSquew(-0.13 + timer * 0.13) ;
							
								if (timer == 1) {
									tstep = 3 ;
									timer = 0.0 ;
								}
								
							case 3 : 
								timer = Math.min(timer + 0.31 * mt.Timer.tmod, 1) ;
								setSquew(timer * maxSquew) ;
							
								if (timer == 1) {
									tstep = 4 ;
									timer = 0.0 ;
								}
								
							case 4 : 
								timer = Math.min(timer + 0.22 * mt.Timer.tmod, 1) ;
								setSquew(maxSquew + timer * 0.4, 1 - 0.4 * timer, 1 + 0.7 * timer) ;
								//mcKeeper._yscale = 100 + 50 * timer ;
							
							
								if (timer == 1) {
									tstep = 5 ;
									timer = 0.0 ;
								}
								
							case 5 : 
								timer = Math.min(timer + 0.22 * mt.Timer.tmod, 1) ;
								mcKeeper.filters = [] ;
								Filt.blur(mcKeeper, 26 * timer, 68 * timer) ;
							
								//setSquew(maxSquew) ;
								mcKeeper._x = (500 - 177) * timer + 500 * (1 - timer) ;
								mcKeeper._y = (300 - 288) * timer + 300 * (1 - timer) ;
								
							
								if (timer == 1) {
									tstep = 6 ;
									timer = 0.0 ;
									mcKeeper._x = 500 - 168 ; //recal
									mcKeeper._y = 0 ;
								}
								
							case 6 : 
								timer = Math.min(timer + 0.1 * mt.Timer.tmod, 1) ;
								mcKeeper._alpha = 100 - timer * 100 ;
							
								if (timer == 1) {
									timer = 0.0 ;
									tstep = 7 ;
								}
									
								
							case 7 : //wait, end shake
								timer = Math.min(timer + 0.01 * mt.Timer.tmod, 1) ;
							
								if (timer == 1)
									initOut() ;
								
							
						}
					
					case "redux" :
						switch (tstep) {
							case 0 : //wait
								timer = Math.min(timer + 0.025 * mt.Timer.tmod, 1) ;
								var delta = 1 - anim.TransitionFunctions.elastic(1.5, 1 - timer) ;
							
								mcKeeper._xscale = mcKeeper._yscale = lastScale - tRedux[scount] * delta ;
								
								if (timer == 1) {
									timer = 0.0 ;
									scount++ ;
									if (scount >= tRedux.length) {
										tstep = 2 ;
										Cauldron.me.resetSubmitAnim() ;
										step = Exit ;
									} else
										tstep = 1 ;
								}
								
							case 1 : //wait
								timer = Math.min(timer + 0.5 * mt.Timer.tmod, 1) ;
							
								if (timer == 1) {
									tstep = 0 ;
									timer = 0.0 ;
									lastScale = mcKeeper._xscale ; 
									Cauldron.me.setShake(scount + 4,scount+ 5) ;
								}
							
							
						}
						
					case "coliq" : 
						switch (tstep) {
							case 0 : //wait
								timer = Math.min(timer + 0.02 * mt.Timer.tmod, 1) ;
								var delta = 1 - anim.TransitionFunctions.quad(1 - timer) ;
							
							
								mc._alpha = AL_MAX * delta ;
								
								
								if (timer == 1) {
									tstep = 1 ;
									timer = 0.0 ;
									scount = 0 ;
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
									scount++ ;
									
									if (scount == 6) {
										var a = new anim.Anim(mcKeeper, Translation, Quart(1), {x : mcKeeper._x + 200, y : mcKeeper._y, speed : 0.12}) ;
										a.addOnCoef(0.4, callback(function(m : flash.MovieClip) { Filt.blur(m, 20, 0) ; }, mcKeeper)) ;
										a.start() ;
									}
									if (scount == 12) {
										Cauldron.me.resetSubmitAnim() ;
										fromOut = mc._alpha ; 
										tstep = 2 ;
									}
										
								}
							
							

							case 2 : //go out
								timer = Math.min(timer + 0.02 * mt.Timer.tmod, 1) ;
								var delta = 1 - anim.TransitionFunctions.quad(1 - timer) ;
							
								mc._alpha = fromOut * (1.0 - delta) ;
							
								if (timer == 1)
									step = Exit ;
								
							
						}
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
		step = Exit ;
	}
	
	
	override public function kill() {
		if (mcAnim != null)
			mcAnim.removeMovieClip() ;
		if (Cauldron.me.keeper != null)
			Cauldron.me.keeper.kill() ;
		if (mcMask != null)
			mcMask.removeMovieClip() ;
		
		if (mc != null)
			mc.removeMovieClip() ;
		
		super.kill() ;
	}
	
	
}