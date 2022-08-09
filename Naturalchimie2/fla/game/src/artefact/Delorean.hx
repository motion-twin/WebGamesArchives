package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import Stage.TempEffect ;
import Game.GameStep ;
import GameData._ArtefactId ;

/*
Epine de distorsion
Que des triplets pendant une période x
*/

class Delorean extends StageObject {
	
	var level : Int ; 
	var plays : Int ;

	public function new (lvl : Int, ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		level = lvl ;
		plays = if (level == 0) 4 else 8 ;
		autoFall = true ;
		id = Const.getArt(_Delorean(lvl)) ;
		checkHelp() ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
			
		if (noOmc)
			return ;
		omc = new ObjectMc(_Delorean(lvl), pdm, depth, null, null, null, withBmp, sc) ;
	}
	
	
	override public function onFall() {
		effectTimer = 100 ;
		effectStep = 0 ;
		Game.me.setStep(ArtefactInUse, this) ;
		return true ;
	}
	
	
	override public function updateEffect() {
		
		switch(effectStep) {
			case 0 :
				effectTimer = Math.max(effectTimer - 10 * mt.Timer.tmod, 0) ;
				omc.mc._alpha =effectTimer ;
				if (effectTimer == 0) {
					effectStep = 1 ;
					Game.me.stage.remove(this, true) ;
				}
			
			case 1 :
				omc.mc._x = -1000 ;
				omc.mc._alpha  = 100 ;
				Game.me.stage.addEffect(FxDelorean, this, plays) ;
				Game.me.releaseArtefact(this) ;
				kill() ;
		
		}
	}
	
	
	
	
	
	
	

	
	
}