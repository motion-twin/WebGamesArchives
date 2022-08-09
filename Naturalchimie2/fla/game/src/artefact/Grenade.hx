package artefact ;

import flash.Key ;
import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import Stage.TempEffect ;
import Game.GameStep ;
import GameData._ArtefactId ;
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
	var selected : StageObject ;
	var mcAnim : flash.MovieClip ;

	public function new (lvl : Int,  ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		level = lvl ;
		id = Const.getArt(_Grenade(lvl)) ;
		checkHelp() ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		targets = new Array() ;	
		if (noOmc)
			return ;
		omc = new ObjectMc(_Grenade(lvl), pdm, depth, null, null, null, withBmp, sc) ;
		if (level == 1)
			initAnim() ;
		if (level == 2)
			autoFall = true ;
	}
	
	
	function initAnim() {
		mcAnim = omc.mc.attachMovie("grenade1", "grenade1", 5) ;
		mcAnim._x = -4 ;
		mcAnim._y = -13 ;
		mcAnim._alpha = 0 ;
	}
	
	
	override public function copy(dm : mt.DepthManager, ?depth : Int) : StageObject {
		depth = if (depth == null) 2 else depth ;
		
		var m = new Grenade(level, dm, depth, false, omc.mc._b._m._p, omc.initScale) ;
		m.isFalling = isFalling ;
		
		m.mcAnim.gotoAndPlay(mcAnim._currentframe) ;
		if (level == 0)
			return m ;
		
		if (mcAnim._alpha > 0) {
			m.mcAnim._alpha = mcAnim._alpha ;
			m.omc.mc._b._alpha = 0 ;
		}
		
		return m ;
	}
	
	
	override public function onStage() {
		super.onStage() ;
		if (level == 1) {
			omc.mc._b._alpha = 0 ;
			mcAnim._alpha = 100 ;
		}
		
	}
	

	override public function onFall() {
		if (level == 1) {
			omc.mc._b._alpha = 0 ;
			mcAnim._alpha = 100 ;
		}

		if (level == 2) {
			Game.me.setStep(ArtefactInUse, this) ;
			Game.me.stage.remove(this, true) ;

			selected = getFirstChoice() ;

			effectTimer = 100 ;
			effectStep = -5 ;

			return true ;
		}

		return false ;
	}


	function getFirstChoice() : StageObject {
		var res = null ;
		var cy = y ;
		while (cy >= 0) {
			if (Game.me.stage.grid[x][cy] != null)
				return Game.me.stage.grid[x][cy] ;
			cy-- ;
		}

		var all = Game.me.stage.getAll() ;
		if (all == null || all.length == 0)
			return null ;
		
		return all[Std.random(all.length)] ;
	}
	

	function onKeyPress() {
		var n = Key.getCode() ;
		switch(n) {
			case Key.UP :
				if (!Game.me.pause)
					move(0) ;				
			case Key.RIGHT :
				if (!Game.me.pause)
					move(1) ;
			case Key.DOWN :
				if (!Game.me.pause)
					move(2) ;
			case Key.LEFT : 
				if (!Game.me.pause)
					move(3) ;
			case Key.SPACE : 
				if (!Game.me.pause)
					chooseIt() ;		
		}
	}


	function move(d : Int) {
		var next = switch(d) {
						case 0 : Game.me.stage.grid[selected.x][selected.y + 1] ; 
						case 1 : 
							var nx = selected.x + 1 ;
							var f = null ;
							while (nx < Stage.WIDTH) {
								var n = Game.me.stage.grid[nx][selected.y] ; 
								if (n != null) {
									f = n ;
									break ;
								} else 
									nx++ ;
							}
							f ;
						case 2 :  if (y > 0) Game.me.stage.grid[selected.x][selected.y - 1]  else null ; 
						case 3 : 
							var nx = selected.x - 1 ;
							var f = null ;
							while (nx >= 0) {
								var n = Game.me.stage.grid[nx][selected.y] ; 
								if (n != null) {
									f = n ;
									break ;
								} else 
									nx-- ;
							}
							f ;
		} ;

		if (next == null)
		return ;

		setGlow(selected, false) ;
		selected = next ;
		setGlow(selected, true) ;
	}


	function chooseIt() {
		Game.me.restoreKeyListener() ;
		selected.effectTimer = 100 ;
		setGlow(selected, false) ;
		effectStep = -3 ;
		Game.me.sound.play("dynamite") ;
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
		
		Game.me.sound.play("dynamite", null, null, null, 5) ;
		
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
		Game.me.sound.play("dynamite", null, null, null, 5) ;
	}


	function setGlow(o : StageObject, on : Bool) {
		if (on)
			Filt.glow(o.omc.mc, 7, 10, 0xFFFFFF) ;
		else
			o.omc.mc.filters = [] ;
			
	}
	
	
	override public function updateEffect() {
		switch (effectStep) {
			//GRENADE 2
			case -5 : 
				effectTimer = Math.max(effectTimer - 10.0 * mt.Timer.tmod, 0) ;
				omc.mc._alpha = effectTimer ;
			
				if (effectTimer == 0) {
					if (selected != null) {
						setGlow(selected, true) ;

						effectStep = -4 ;
						Game.me.switchKeyListener({onKeyDown:callback(onKeyPress), onKeyUp:callback(Game.me.onKeyRelease) }) ;
					} else {
						Game.me.releaseArtefact(this) ;
						Game.me.setStep(Destroy) ;
						kill() ;
					}
				}
			case -4 : //nothing to do, player is choosing an object

			case -3 :
				if (selected.warm(8.0)) {
					effectStep = -2 ;
					selected.effectTimer = 100 ;
				}
				
			case -2 : 
				if (selected.blink()) {
					selected.toDestroy(Flame(true)) ;
				
					Game.me.stage.setShake(8, null, true) ;
					Game.me.releaseArtefact(this) ;
					Game.me.setStep(Destroy) ;
					kill() ;
				}


			//GRENADE 0 & 1
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
				
				Game.me.stage.setShake(8, null, true) ;
				Game.me.releaseArtefact(this) ;
				Game.me.setStep(Destroy) ;
		}
	}
	
	
	override public function kill() {
		if (mcAnim != null)
			mcAnim.removeMovieClip() ;
		super.kill() ;
	}

	
}