package mode ;

import GameData._ArtefactId ;
import mode.GameMode.TransFormPos ;

class Wind extends GameMode {
	
	static var RAND_WIND = 17 ;
	static var MIN_RAND_WIND = 3 ;
	static var DELTA_RAND_WIND = 1 ;
	
	public var mcWind : flash.MovieClip ;
	var targetRot : Float ;
	var rotStep : Int ;
	var rotTimer : Float ;
	var rotSpeed : Float ;
	var rotSide : Int ;
	var initRot : Float ;
	var toRot : Float ;
	var curRand : Int ;
	
	
	
	public function new() {
		super() ;
		hideSpirit = true ;
		initMc() ;
		curRand = RAND_WIND ;
		tpos = null ;
	}
	
	
	function initMc() {
		mcWind = Game.me.mdm.attach("windArrow", Const.DP_INVENTORY) ;
		mcWind._x = 247 ;
		mcWind._y = 78 ;
	}
	
	
	override public function initStage(st : Stage) { 
		chooseWind() ;
	}
	
	
	override public function checkEnd() { 
		if (Std.random(curRand) == 0) {
			chooseWind() ;
			curRand = RAND_WIND ;
		} else {
			if (curRand > MIN_RAND_WIND)
				curRand -= DELTA_RAND_WIND ;
		}
		return false ;
	}
	
	
	public function chooseWind() {
		var old = if (tpos != null) Type.enumIndex(tpos) else null ;
		var np = old ;
		while(np == old) {
			np = Std.random(4) ;
		}
		
		Game.me.sound.play("vent", null, null, null, 1) ;

		
		tpos = Type.createEnumIndex(TransFormPos, np) ;
		targetRot =  getTargetRot(np) ;
		
		rotStep = 0 ;
		rotTimer = 0.0 ;
		rotSpeed = 0.025 ;
		rotSide = Std.random(2) * 2 - 1 ;
		initRot = getTargetRot(old) ;
		toRot = if (rotSide > 0) {
				if (targetRot > getTargetRot(old))
					Math.abs(targetRot - getTargetRot(old))
				else 
					targetRot +  6.28 - getTargetRot(old) ;
			} else {
				if (getTargetRot(old) > targetRot)
					Math.abs(targetRot - getTargetRot(old))
				else
					getTargetRot(old) +  Math.abs(targetRot - 6.28 ) ;
			}
				
		toRot += 3 * 6.28 ;
	}
	
	
	function getTargetRot(i : Int) {
		return switch(i) {
				case null : 0 ; //init game
				case 0 : 3.925 ; //BottomLeft
				case 1 : 2.355 ; //BottomRight
				case 2 : 5.495 ; //TopLeft
				case 3 : 0.785 ; //TopRight
			}
	}
	
	
	override public function updateEffect() {
		if (rotStep != null) {
			switch(rotStep) {
				case 0 : 
					
					rotTimer = Math.min(rotTimer + rotSpeed * mt.Timer.tmod, 1.0) ;
				
					mcWind.smc._rotation = 180 * (initRot + rotSide * Math.pow(rotTimer, 3) * toRot) / 3.14 ;
					if (rotTimer == 1.0) {
						rotStep = 1 ;
						rotTimer = 0.0 ;
						initRot = targetRot ;
						Game.me.sound.play("shake") ;
					}
				
				case 1 :
					rotTimer = Math.min(rotTimer + rotSpeed * mt.Timer.tmod, 1.0) ;
					var delta = 1 - anim.TransitionFunctions.elastic(0.8, 1 - rotTimer) ;
					mcWind.smc._rotation = 180 * (initRot + rotSide * delta * 6.28) / 3.14 ;
				
					if (rotTimer == 1.0) {
						rotStep = null ;
					}
				
			}
			
			
		}
		
	}
	
	
}