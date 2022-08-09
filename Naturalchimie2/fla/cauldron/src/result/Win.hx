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




class Win extends Result {
	
	
	public var posy : Float ;
	public var qty : Int ;
	public var isToken : Bool ;
		
	
	
	
	public function new(token : Int, gold : Int, gotRank : String) {
		super(gotRank) ;
		
		step = Prepare ;
		mc._visible = false ;
		
		isToken = token != null && token > 0 ;
		qty = if (isToken) token else gold ;
			
		initMcs() ; 
	}
	
	
	override function initMcs() {
		super.initMcs() ;
		super.initMcResult(if (isToken) 2 else 1) ;
		
		mc.onRelease = initOut ;
		
		
		mcResult._result._field.text = Std.string(qty) ;
		
		posy = Math.random() * Const.RAD ;
		
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
		m.onEnd = callback(function(w : result.Win) {
						w.step = Exit ;
						w.mcResult.removeMovieClip() ;
						flash.external.ExternalInterface.call("_wtg", if (!w.isToken) w.qty else 0, if (w.isToken) w.qty else 0, -1) ;
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