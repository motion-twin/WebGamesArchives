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




class Fail extends Result {

	public var mcFail : flash.MovieClip ;
	var timer : Float ;
	var upDone : Bool ;
	
	
	public function new() {
		super() ;
		step = Prepare ;
		initMcs() ; 
	}
	
	
	override function initMcs() {
		super.initMcs() ;
		
		step = Wait ;
		timer = 0 ;
		//mc.onRelease = initOut ;
		upDone = false ;
		/*var a = new anim.Anim(mcFail, Scale, Bounce(-1), {x : 100, y : 100, speed : 0.05}) ;
		a.onEnd = callback(function(f : result.Fail) {
						f.step = Wait ;
						f.mc.onRelease = f.initOut ;
				}, this) ;
		a.start() ;*/
	}

	
	override public function loop() {
		
		switch(step) {
			case Wait : 
				Cauldron.me.setShake(1,1) ;
				timer = Math.min (timer + 0.027 * mt.Timer.tmod, 1) ;
				
				if (timer == 1) {
					Cauldron.me.setShake(3,4) ;
					mcFail = dm.attach("fail", Result.DP_OBJECTS) ; 
					mcFail._x = 9 ;
					mcFail._y = 3 ;
					timer = 0 ;
					step = GoOut ;
				}
				
				
			case GoOut : 
				timer = Math.min (timer + 0.02 * mt.Timer.tmod, 1) ;
			
				if (timer < 0.8)
					Cauldron.me.setShake(1,4) ;
			
				if (timer > 0.2 && !upDone) {
					Cauldron.me.resetSubmitAnim(true) ;
					upDone = true ;
				}

				
			
				if (timer == 1) {
					mcFail.removeMovieClip() ;
					step = Exit ;
				}
					
	
			case Prepare : 
				//nothing to do
			case Exit : 
				kill() ;
				//Cauldron.me.setStep(Default) ;
				Cauldron.me.postResult() ;
				
		}
	}
	
	
	public function initOut() {
		mc.onRelease = null ;
		//Cauldron.me.resetSubmitAnim() ;
		
		/*var m = new anim.Anim(mcFail, Translation, Quint(1), {x : 510, y : mcFail._y, speed : 0.05}) ;
		m.onEnd = callback(function(f : result.Fail) {
						f.step = Exit ;
				}, this) ;
		m.start() ;*/
	}
	
	override public function kill() {
		if (mc != null)
			mc.removeMovieClip() ;
		
		super.kill() ;
	}
	
	
}