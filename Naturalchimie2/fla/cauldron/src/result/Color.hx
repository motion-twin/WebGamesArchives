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




class Color extends Result {
	
	
	public var color : Int ;
	
	
	public function new(col : Int, gotRank : String) {
		super(gotRank) ;
		
		step = Prepare ;
		mc._visible = false ;
		
		color = col ;
					
		initMcs() ; 
	}
	
	
	override function initMcs() {
		super.initMcs() ;
		super.initMcResult(3) ;
		
		mc.onRelease = initOut ;
		mcResult._result.smc.gotoAndStop(color + 1) ;
		
		makeClouds(mcResult._x, mcResult._y) ;

		
		mc._visible = true ;
		Cauldron.me.updateSprites() ;
		mcResult._visible = true ;
		
		mcMask.gotoAndPlay(1) ;
		
		step = Wait ;
	}

	
	override public function loop() {
		
		switch(step) {
			case Prepare, GoOut : 
				//nothing to do
				
			case Wait : 
				/*posy = (posy - 0.05) % Const.RAD ;
				mcWin._y =  (Math.cos(posy) * 10) + Result.OBJECT_Y  ;*/
			
			case Exit : 
				kill() ;
				//Cauldron.me.setStep(Default) ;
				Cauldron.me.postResult() ;
		}
	}
	
	
	public function initOut() {
		if (Cauldron.me.dialog != null)
			return ;
		
		mc.onRelease = null ;
		Cauldron.me.resetSubmitAnim() ;
		resultOut() ;
		var m = new anim.Anim(mcResult, Alpha(-1), Quint(-1), {x : 0, y : 0, speed : 0.05}) ;
		m.onEnd = callback(function(w : result.Color) {
						w.step = Exit ;
						w.mcResult.removeMovieClip() ;
				}, this) ;
		m.start() ;
	}
	
	override public function kill() {
		super.kill() ;
		if (mc != null)
			mc.removeMovieClip() ;
		
		super.kill() ;
	}
	
	
}