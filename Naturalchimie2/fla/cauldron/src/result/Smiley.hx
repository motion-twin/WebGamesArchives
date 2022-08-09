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




class Smiley extends Result {
	
	
	public var img : String ;
	public var nb : Int ;
	var mcImg : flash.MovieClip ;
	
	
	public function new(img : String, nb : Int, gotRank : String) {
		super(gotRank) ;
		
		step = Prepare ;
		mc._visible = false ;
		
		this.img = img ;
		this.nb = nb ;
					
		initMcs() ; 
	}
	
	
	override function initMcs() {
		super.initMcs() ;
		super.initMcResult(4) ;
		
		mcResult._result._field.text = Std.string(nb) ;
		mcImg = dm.empty(3) ;
		mcImg._x = 251 ;
		mcImg._y = 105 ;
		
		var me = this ;
		var mcl = new flash.MovieClipLoader() ;
				
		mcl.onLoadError = function(_,err) {
		}
		mcl.onLoadInit = function(_) {
			me.mc.onRelease = me.initOut ;
			me.makeClouds(me.mcResult._x, me.mcResult._y) ;
			me.mc._visible = true ;
			Cauldron.me.updateSprites() ;
			me.mcResult._visible = true ;
			
			me.mcMask.gotoAndPlay(1) ;
			me.step = Wait ;
		}
		mcl.loadClip(img,mcImg) ;
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
		m.onEnd = callback(function(w : result.Smiley) {
						w.step = Exit ;
						w.mcResult.removeMovieClip() ;
				}, this) ;
		m.start() ;
		m = new anim.Anim(mcImg, Alpha(-1), Quint(-1), {x : 0, y : 0, speed : 0.05}) ;
		m.start() ;
	}
	
	override public function kill() {
		super.kill() ;
		
		if (mcImg != null)
			mcImg.removeMovieClip() ;
		if (mc != null)
			mc.removeMovieClip() ;
		
		super.kill() ;
	}
	
	
}