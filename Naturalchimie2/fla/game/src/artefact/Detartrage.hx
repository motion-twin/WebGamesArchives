package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import Stage.TempEffect ;
import Game.GameStep ;
import GameData._ArtefactId ;
import anim.Transition ;

/*
Epine de distorsion
Que des triplets pendant une période x
*/

class Detartrage extends StageObject {
	
	static var DELTA_Y = Stage.LIMIT * Const.ELEMENT_SIZE ;
	
	var falls : Array<{o : StageObject, sY : Float}> ;
	
	

	public function new (?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		autoFall = true ;
		id = Const.getArt(_Detartrage) ;
		checkHelp() ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
			
		if (noOmc) 
			return ;
		omc = new ObjectMc(_Detartrage, pdm, depth, null, null, null, withBmp, sc) ;
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
					
					falls = new Array() ;
					for (c in [0, Stage.WIDTH - 1]) {
						for (o in Game.me.stage.grid[c]) {
							if (o == null)
								break ;
							falls.push({o : o, sY : o.omc.mc._y}) ;
						}
					}
										
					effectTimer = 0 ;
					effectStep = 1 ;
					
					Game.me.sound.play("chute_accentue", null, null, null, 0) ;
				}
			
			case 1 :
				effectTimer = Math.min(effectTimer + 5 * mt.Timer.tmod, 100) ;
				var d = anim.Anim.getValue(Quart(1), effectTimer / 100) ;
				for (f in falls) {
					f.o.omc.mc._y = f.sY + d * DELTA_Y ;
					if (effectTimer == 100)
						Game.me.stage.remove(f.o) ;
				}
				
				
				
				if (effectTimer == 100)
					effectStep = 2 ;
				else if (effectTimer > 25)
					Game.me.stage.setShake(1, 1, true) ;
				
			case 2 : 
				effectTimer = Math.max(effectTimer - 4 * mt.Timer.tmod, 0) ;
				if (effectTimer == 0) {
					Game.me.stage.setShake(6) ;
					effectStep = 3 ;
				}
					
		
			case 3 : 
				Game.me.releaseArtefact(this) ;
				kill() ;
		}
	}
	
	

	
	
}