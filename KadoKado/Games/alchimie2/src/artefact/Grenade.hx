package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import Stage.TempEffect ;
import Game.GameStep ;
import GameData.ArtefactId ;
import StageObject.DestroyMethod ;

/*
Grenade : 
- level 0 => détruit l'élément en dessous 
- level 1 : détruit tout autour de lui quand on pose quelque chose sur le gros bouton rouge au dessus (comme le détonateur de la v1)


### 
level 1 to do : anim de bouton qui clignote lentement dans objectMc.fla

*/


class Grenade extends StageObject {
	
	static var targetXY = [[-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1], [1, 0], [1, 1]] ;
	
	var level : Int ;
	var targets : Array<StageObject> ;

	public function new (lvl : Int,  ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false) {
		super() ;
		level = lvl ;
		id = Grenade(lvl) ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		targets = new Array() ;	
		if (noOmc)
			return ;
		omc = new ObjectMc(id, pdm, depth) ;
	}
	
	
	
	override public function copy(dm : mt.DepthManager, ?depth : Int) : StageObject {
		depth = if (depth == null) 2 else depth ;
		
		var m = new Grenade(level, dm, depth) ;
		m.isFalling = isFalling ;
		
		
		return m ;
	}
	
	
	override public function onStage() {
		return super.onStage() ;
		
	}
	
	override public function onFall() {
		
		return false ;
	}
	
	
	
	
	override public function onGround() {
		super.onGround() ;
		
		if (level != 0) //only for grenade(0)
			return false ;
		
		var o = Game.me.stage.grid[x][y - 1] ;
		if (o != null)
			targets.push(o) ;
		
		effectTimer = 100 ;
		effectStep = 0 ;
		Game.me.setStep(ArtefactInUse, this) ;
			
		return true ;
	}
	
	
	public function onCover() {
		if (level != 1) //only for grenade(1)
			return ;
				
		for (pos in targetXY) {
			var o = Game.me.stage.grid[x + pos[0]][y + pos[1]] ;
			if (o != null)
				targets.push(o) ;
		}
		
		effectTimer = 100 ;
		effectStep = 0 ;
		
		Game.me.setStep(ArtefactInUse, this) ;
	}
	
	
	override public function updateEffect() {
		switch (effectStep) {
			case 0 :
				if (warm(8.0)) {
					effectStep = 1 ;
					effectTimer = 100 ;
				}
				
			case 1 : 
				if (blink()) {
					effectStep = 2 ;
					for (i in 0...2)
						setHalo(null, 1.3 + i, 7 - 1) ;
				}
				
			case 2 : 
				for(o in targets) {
					o.toDestroy(Flame(true)) ;
				}
				
				this.toDestroy(Flame(true), 0) ;
				
				Game.me.stage.setShake(8, null) ;
				Game.me.releaseArtefact(this) ;
				Game.me.setStep(Destroy) ;
		}
	}
	
	
	override public function kill() {
		super.kill() ;
	}

	
}