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

class Jeseleet extends StageObject {
	
	static var plays = 5 ;
	var level : Int ; //0 => triplets, 1 => quatuors
	var fx : TempEffect ;
	
	

	public function new (lvl : Int, ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		level = lvl ;
		autoFall = true ;
		id = Const.getArt(_Jeseleet(lvl)) ;
		checkHelp() ;
		fx = if (level == 0)
				FxJeseleet3 ;
			else
				FxJeseleet4 ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
	
		if (noOmc) 
			return ;
		omc = new ObjectMc(_Jeseleet(lvl), pdm, depth, null, null, null, withBmp, sc) ;
	}
	
	
	override public function onStage() {
		var old = Game.me.stage.effect ;
		Game.me.stage.effect = {fx : fx, leftPlays : 2, from : null} ;
		
		for(g in Game.me.stage.nexts) {
			var g = Game.me.stage.nexts.pop() ;
			g.kill() ;
		}
		Game.me.stage.nexts.add(new Group(true)) ;
		Game.me.stage.nexts.first().mc.setMask(Game.me.gui._group_mask) ;
		
		Game.me.stage.effect = old ;
		
		var o = Game.me.stage.nexts.first() ;
		o.move(o.mc._x, o.getNextPosY()) ;
		
		super.onStage() ;
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
				Game.me.stage.addEffect(fx, this, plays) ;
				Game.me.releaseArtefact(this) ;
				kill() ;
		
		}
	}
	
}