package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import Game.GameStep ;
import StageObject.DestroyMethod ;
import GameData.ArtefactId ;

/*
Alchimoth
détruit tous les éléments identiques à celui sous elle (pas d'effet si ce n'est pas un élément)
*/

class Alchimoth extends StageObject {
	
	var elementId : Int ;
	var targets  : Array<StageObject> ;
	var gTimer : Float ;
	var pick : PickUp ;
	
	
	public function new(?dm : mt.DepthManager, ?depth : Int, ?noOmc = false) {
		super() ;
		id = Alchimoth ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		gTimer = 0.5 ;
		
		if (noOmc)
			return ;
		
		omc = new ObjectMc(
					id,
					pdm,
					if (depth == null) 2 else depth) ;
	}
	
	
	override public function onGround() {
		super.onGround() ;
		
		effectTimer = 100 ;
		effectStep = 0 ;
		Game.me.setStep(ArtefactInUse, this) ;
		
		var e : Element = cast Game.me.stage.grid[x][y - 1] ;
		if (e != null && Std.is(e, Element)) {
			elementId = e.getId() ;
			targets = if (elementId != null) cast Game.me.stage.getAllElements(elementId) else new Array() ;
		} else
			targets = new Array() ;
		
		targets.push(this) ;
		
		return true ;
	}
	
	
	override public function updateEffect() {
		switch (effectStep) {
			case 0 :
				effectTimer = Math.max(effectTimer - 10 * mt.Timer.tmod, 0) ;
				for (o in targets) {
					Col.setPercentColor(o.omc.mc, 100 - effectTimer, 0xFFFFFF) ;
					var f = Math.sin(gTimer) ;
					if ( f < 0.5 ) {
						gTimer = 0.5 ;
						f=0.5 ;
					}
					o.omc.mc.filters = [new flash.filters.GlowFilter(0xffffff,f,10, 10,2)] ;
				}
				
				if (effectTimer == 0) {
					effectStep = 1 ;
					effectTimer = 100 ;
					
					var c = getCenter() ;
					pick = Game.me.initPickUp(true, omc.mc, c) ;
					pick.mcTarget = null ;
					pick.showWins = false ;
					
					if (targets.length > 1) {
						var t = flash.Lib.getTimer() ;
						for (o in targets) {
							if (o == this)
								continue ;
							
							o.forcePickUp(t) ;
							o.effectTimer = 0.0 ;
						}
						
					} else {
						effectStep = 2 ;
						effectTimer = 0.0 ;
					}
				}
				
			case 1 : 
				
				resonance(mt.Timer.tmod, true) ; 
				if (!pick.nearAllIsDone())
					Game.me.stage.updatePick() ;
				else {
					setHalo(null, 1.4, 8) ;
					effectStep = 2 ;
					effectTimer = 0.0 ;
				}
				
			case 2 : 
				/*if (effectTimer < 0) { //sleep					
					effectTimer = Math.min(effectTimer + 3 * mt.Timer.tmod, 0) ;
					if (effectTimer >= 0)
						effectTimer = 100.0 ;
					return ;
				}*/
			
				if (colder()) {
					this.toDestroy(Flame(true), 8) ;
					Game.me.releaseArtefact(this) ;
					Game.me.setStep(Destroy) ;
				}
			
			
				/*effectTimer = Math.max(effectTimer - 4 * mt.Timer.tmod, 0) ;
				for (o in targets) {
					o.resonance(effectTimer) ;
					
					if (effectTimer == 0)
						o.toDestroy(Warp, Math.random() * 4) ;
				}
			
			
				if (effectTimer == 0) {
					Game.me.releaseArtefact(this) ;
					Game.me.setStep(Destroy) ;
				}*/
		}
	}

	
	
}