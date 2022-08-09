package artefact ;

import flash.Key ;
import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import Stage.TempEffect ;
import Game.GameStep ;
import GameData._ArtefactId ;
import StageObject.DestroyMethod ;
import anim.Transition ;

/*
Patchinko : 
les éléments en jeu défilent, appui sur espace pr récupérer la sélection en cours à la fin de partie
(l'élément est retiré du jeu)
*/

class Patchinko extends StageObject {
	
	static var rollColor = 0xFFFFFF ;
	static var brake = 6 ;
	static var waitMax = 8.0 ;
	
	var wait : Float ;
	var wPow : Float ;
	var elements : Array<{ o : StageObject, timer : Float}> ;
	var rollIndex : Int ;
	var chosen : Int ;
	var cBrake : Int ;
	var soundNumber : Int ;
	var soundMax : Int ;

	
	public function new ( ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_Patchinko) ;
		checkHelp() ;
		autoFall = true ;
		soundNumber = 0 ;
		soundMax = 10 ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		if (noOmc)
			return ;
		omc = new ObjectMc(_Patchinko, pdm, depth, null, null, null, withBmp, sc) ;
	}
	
	
	function onKeyPress() {
		var n = Key.getCode() ;
		switch(n) {
			case Key.SPACE :
				selectElement() ;
		}
	}
	
	
	function selectElement() {
		if (effectStep > 1)
			return ;
		effectStep = 2 ;
		chosen = rollIndex ;
		//setHalo() ;
		Game.me.log.addReward(Const.fromArt(this.id), elements[chosen].o.getArtId()) ;
		cBrake = 0 ;
		Game.me.restoreKeyListener() ;
	}
	
	
	override public function onFall() : Bool {
		elements = new Array() ;
		
		var yy = Stage.LIMIT - 1 ;
		while (yy >= 0) {
			var xx = 0 ;
			while (xx < Stage.WIDTH) {
				var o = Game.me.stage.grid[xx][yy] ;
				if (o != null) {
					switch(o.getArtId()) {
						case _Elt(n) :
							elements.push({o :o, timer : if (elements.length > 0) null else 100.0}) ;
						default : //nothing to do
					}
				}
				
				xx++ ;
			}
			
			yy-- ;
		}
		
		Game.me.setStep(ArtefactInUse, this) ;
		
		effectTimer = 0 ;
		effectStep = 0 ;
		rollIndex = 0 ;
		
		if (elements.length > 0) {
			effectStep = -1 ;
			effectTimer = 100 ;
			
			wait = 2.4 ;
			wPow = Math.max(1.6 - elements.length * 0.08, 1.25) ;
			
			Game.me.stage.resetGroups() ;
			
			
			Game.me.switchKeyListener({onKeyDown:callback(onKeyPress),
									onKeyUp:callback(Game.me.onKeyRelease)}) ; 
		}
			
		return true ;
	}
	
	
	override public function updateEffect() {
		
		wheel() ;
		
		switch (effectStep) {
			case -1 :
				effectTimer = Math.max(effectTimer - 10.0 * mt.Timer.tmod, 0) ;
				omc.mc._alpha = effectTimer ;
			
				if (effectTimer == 0) {
					effectStep = 1 ;
				}
			
			
			case 0 : //empty stage => destroy
				if (this.warm()) {
					this.toDestroy(Warp) ;
					effectStep = 5 ;
				}
				
			case 1 : //wheel of fortune style
				effectTimer += 1.0 * mt.Timer.tmod ;
						
				if (effectTimer > wait) {
					effectTimer = 0.0 ;
					
					elements[rollIndex].o.omc.mc.filters = [] ;
					
					rollIndex++ ;
					if (rollIndex >= elements.length)
						rollIndex = 0 ;
					var o = elements[rollIndex] ;
					
					o.timer = 0.0 ;
					
					Filt.glow(o.o.omc.mc, 7, 10, rollColor) ;
					Game.me.sound.play("tigidy" + Std.string(soundNumber + 1)) ;
					soundNumber = (soundNumber + 1) % soundMax ;
				
				}
				
			case 2 : //slow
				effectTimer += 1.0 * mt.Timer.tmod ;
				
				if (effectTimer > wait) {
					effectTimer = 0.0 ;
					
					elements[rollIndex].o.omc.mc.filters = [] ;
					
					rollIndex++ ;
					cBrake++ ;
					
					if (rollIndex >= elements.length) 
						rollIndex = 0 ;
					
					if (cBrake > brake) {
						cBrake = 0 ;
						wait = Math.min(wait * Math.pow(1.5, mt.Timer.tmod), waitMax + 0.2) ;
					}
					
					var o = elements[rollIndex] ;
					
					o.timer = 0.0 ;
					Filt.glow(o.o.omc.mc, 7, 10, rollColor) ;
					Game.me.sound.play("tigidy" + Std.string(soundNumber + 1)) ;
					soundNumber = (soundNumber + 1) % soundMax ;
					
					if (rollIndex == chosen && wait > waitMax) {
						effectStep = 3 ;
						o.o.effectTimer = 100 ;
						o.o.omc.mc.filters = [] ;
						o.o.setHalo() ;
						
						Game.me.stage.setShake(2, 2, true) ;
						o.o.forcePickUp(flash.Lib.getTimer()) ;
						Game.me.sound.play("transmutation_destructrice") ;
					}
				
				}
				
			case 3 : //end && destroy
				Game.me.releaseArtefact(this) ;				
				Game.me.setStep(Transform) ;
				Game.me.stage.remove(this) ;
		}
	}
	
	
	function wheel() {
		for (e in elements) { //update color
			if (e.timer == null)
				continue ;
			
			var max = 60 ;
			e.timer =  Math.min((e.timer * Math.pow(wPow, mt.Timer.tmod)) + 2, max) ;
			Col.setPercentColor(e.o.omc.mc, max - e.timer, rollColor) ;
			
			if (e.timer == max)
				e.timer = null ;
		}
	}
	
	
	override public function kill() {
		super.kill() ;
		
	}
	
	
}