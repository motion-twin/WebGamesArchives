package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import GameData._ArtefactId ;
import Game.GameStep ;
import StageObject.DestroyMethod ;
import mt.bumdum.Phys ;
import anim.Transition ;


/*
main du mentor
prend un élément et le remonte. Element récupéré à la fin de la partie. 
*/

class MentorHand extends StageObject {
	
	static var DELTA_Y = 27.0 ;
	var ground_y : Float ;
	var grabed : StageObject ;
	var mcAnim : flash.MovieClip ;
	
	
	public function new (?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		this.id = Const.getArt(_MentorHand) ;
		checkHelp() ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
			
		if (noOmc)
			return ;
		omc = new ObjectMc(_MentorHand, pdm,depth,
				/*callback(function(mh : artefact.MentorHand) { mh.postMc() ; }, this)*/null,
				withBmp, sc) ;
				
		initAnim() ;
	}
	
	override public function copy(dm : mt.DepthManager, ?depth : Int) : StageObject {
		depth = if (depth == null) 2 else depth ;
		
		var m = new MentorHand(dm, depth, false, omc.mc._b._m._p, omc.initScale) ;
		m.isFalling = isFalling ;
		
		m.mcAnim.gotoAndStop(mcAnim._currentframe) ;
		if (mcAnim._alpha > 0) {
			m.mcAnim._alpha = mcAnim._alpha ;
			m.omc.mc._b._alpha = 0 ;
		}
		
		return m ;
	}
	
	
	/*public function postMc() {
		omc.mc.smc.smc.smc.gotoAndStop(1) ;
	}
	*/
	override public function setOmc(no : ObjectMc) {
		super.setOmc(no) ;
		//postMc() ;
	}
	
	
	override public function onStage() {
		super.onStage() ;
		
		omc.mc._b._alpha = 0 ;
		mcAnim._alpha = 100 ;
		
	}
	
	
	function initAnim() {
		mcAnim = omc.mc.attachMovie("mHandAnim", "mHandAnim", 5) ;
		mcAnim.gotoAndStop(1) ;
		mcAnim._alpha = 0 ;
	}
	
	override public function onFall() {
		//omc.mc.smc.smc.smc.gotoAndStop(2) ; 
		
		omc.mc._b._alpha = 0 ;
		mcAnim._alpha = 100 ;
		mcAnim.gotoAndStop(2) ; //open hand
		return false ;
	}
	
	
	override public function onGround() {
		super.onGround() ;
		
		var valid = y > 0 ;
		
		if (valid) {
			var sub = Game.me.stage.grid[x][y - 1] ;
			if (sub != null) {
				switch(sub.getArtId()) {
					case _Elt(e) :
						valid = true ;
						grabed = sub ;
					default :
						valid = false ;
				}
			} else 
				valid = false ;
		}
		
		
		if (valid) {
			effectStep = 1 ; //ok, grab element
			swapTo(Stage.HEIGHT + 1) ;
			//omc.mc.smc.smc.smc.gotoAndStop(2) ; //open hand
			mcAnim.gotoAndStop(2) ; //close hand
			Game.me.sound.play("wombat_dent1") ;
			ground_y = omc.mc._y ;
		}else {
			//omc.mc.smc.smc.smc.gotoAndStop(3) ;
			mcAnim.gotoAndStop(3) ; //close hand
			effectStep = 0 ; // invalid use : disappear
		}
		
		
		effectTimer = 100 ;
		Game.me.setStep(ArtefactInUse, this) ;		
		return true ;
	}
	
	
	override public function updateEffect() {
		
		switch(effectStep) {
			case 0 : //invalid : explode
				effectTimer = Math.max(effectTimer - 10 * mt.Timer.tmod, 0) ;
				Col.setPercentColor(omc.mc, 100 - effectTimer, 0xFFFFFF) ;
				if (effectTimer == 0) {
					effectStep = 4 ;
					this.toDestroy(Warp/*, Math.random() * 4*/) ;
				}
				
			case 1 : //grab
				effectTimer = Math.max(effectTimer - (10.0 + g) * mt.Timer.tmod, 0) ;
				g += 0.2 ;
				omc.mc._y = ground_y + DELTA_Y * (100 - effectTimer) / 100 ;
			
				if (effectTimer == 0) {
					mcAnim.gotoAndStop(3) ;
					grabed.setHalo() ;
					
					effectStep = 2 ;
					effectTimer = 0 ;
					ground_y = omc.mc._y ;
				}
				
				
			case 2 : //go back upward with grabed element
				effectTimer = Math.min(effectTimer + 3 * mt.Timer.tmod, 100) ;
			
				var delta = anim.Anim.getValue(Quint(1), effectTimer / 100) ;
				var cy = ground_y * (1 - delta) + -50 * delta ;
				
				omc.mc._y = cy ;
				grabed.omc.mc._y = cy ;
				
			
				if (effectTimer == 100) {
					effectStep = 3 ;
				}
				
			case 3 : //back upward done => finalize grab
				Game.me.log.addReward(Const.fromArt(this.id), grabed.getArtId()) ;
				this.toDestroy(Flame(false)) ;
				Game.me.releaseArtefact(this) ;
				grabed.toDestroy(Flame(false)) ;
			
				Game.me.setStep(Destroy) ;			
				
			case 4 : //done
				Game.me.releaseArtefact(this) ;
				if (grabed != null)
					kill() ;
				
				Game.me.setStep(Destroy) ;
				

			
		}
		
		
	}
	
	
	override public function kill() {
		if (mcAnim != null)
			mcAnim.removeMovieClip() ;
		super.kill() ;
	}
	

	
	
}