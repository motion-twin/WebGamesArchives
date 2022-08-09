package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import Game.GameStep ;
import StageObject.DestroyMethod ;
import GameData._ArtefactId ;

//fait disparaitre tous les éléments d'id eid

class Destroyer extends StageObject {
	
	public var targetId : mt.flash.Volatile<Int> ;
	public var targets : Array<StageObject> ;
	var gTimer : Float ;
	var pick : PickUp ;
	
	
	public function new(eid : Int, ?dm : mt.DepthManager, ?depth : Int, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_Destroyer(eid)) ;
		checkHelp() ;
		
		if (eid == null) {
			var ae = Game.me.stage.getAvailableElements() ;
			var ee = new Array() ;
			for (e in ae) {
				switch(e) {
					case _Elt(id) : 
						ee.push(e) ;
					default : 
				}
			}
			
			if (ee.length > 0) {
				switch(ee[Std.random(ee.length)]) {
					case _Elt(id) : 
						targetId = id ;
					default :
				}
			}else 
				targetId = Std.random(4) ;
		} else 
			targetId = eid ;
		
		autoFall = true ;
		pdm = if (dm != null) dm else Game.me.stage.dm ;
		gTimer = 0.5 ;
		
		if (noOmc) 
			return ;
		omc = new ObjectMc(_Destroyer(targetId), pdm, depth, null, null, null, withBmp, sc) ;
	}

	
	override public function update() { //visual effect like Sprites
		if (gTimer == null) {
			omc.mc.filters = [] ;
			return ;
		}
		
		gTimer += 0.06 ;
		var f = Math.sin(gTimer) ;
		if ( f < 0.5 ) {
			gTimer = 0.5 ;
			f=0.5 ;
		}
		omc.mc.filters = [new flash.filters.GlowFilter(0xE61ABD,f,10, 10,2)] ;
	}
	
	
	override public function onFall() {
		effectTimer = 100 ;
		effectStep = 0 ;
		
		targets = cast Game.me.stage.getAllElements(targetId) ;
		targets.push(this) ;
		
		Game.me.setStep(ArtefactInUse, this) ;
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
						
						Game.me.sound.play("transmutation_destructrice") ;
						Game.me.sound.play("shake", null, null, null, 10) ;

					} else {
						effectStep = 2 ;
						effectTimer = 0.0 ;
					}
				}
				
			case 1 : 
				resonance(mt.Timer.tmod) ; 
				if (!pick.nearAllIsDone())
					Game.me.stage.updatePick() ;
				else {
					setHalo(null, 1.4, 8) ;
					effectStep = 2 ;
					effectTimer = 0.0 ;
				}
			
				/*effectTimer = Math.max(effectTimer - 1.5 * mt.Timer.tmod, 0) ;
				for (o in targets) {
					o.resonance(effectTimer) ;

					
					if (effectTimer == 0)
						o.toDestroy(Warp, Math.random() * 4) ;
				}
			
			
				if (effectTimer == 0) {
					Game.me.releaseArtefact(this) ;
					Game.me.setStep(Destroy) ;
				}*/
				
				
			case 2 : 
				if (colder()) {
					this.toDestroy(Flame(true), 8, "wombat_dent2") ;
					Game.me.releaseArtefact(this) ;
					Game.me.setStep(Destroy) ;
				}
		}
	}
	
	
	
}