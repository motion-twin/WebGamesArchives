package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import Stage.TempEffect ;
import Game.GameStep ;
import GameData._ArtefactId ;
import StageObject.DestroyMethod ;

/*
PolarBomb  => 2 ou + de polarBomb sur une ligne /colonne ==> ça pete entre elles (et elles avec)
*/

class PolarBomb extends StageObject {
	
	var others : Array<StageObject> ;
	var targets : Array<{o : StageObject, wait : Float, step : Int, dist : Int}> ;
	var wait : Int ;
	var mcLine : flash.MovieClip ;
	var mcAnim : flash.MovieClip ;
	
	var points : Array<Array<{x : Float, y : Float}>> ;
	
	

	public function new ( ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_PolarBomb) ;
		checkHelp() ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		if (noOmc)
			return ;
		omc = new ObjectMc(_PolarBomb, pdm, depth, null, null, null, withBmp, sc) ;
		initAnim() ;
	}
	
	
	function initAnim() {
		mcAnim = omc.mc.attachMovie("polar", "polar", 5) ;
		mcAnim._x = 15 ;
		mcAnim._y = 15 ;
		mcAnim._alpha = 0 ;
	}
	
	
	override public function copy(dm : mt.DepthManager, ?depth : Int) : StageObject {
		depth = if (depth == null) 2 else depth ;
		
		var m = new PolarBomb(dm, depth, false, omc.mc._b._m._p, omc.initScale) ;
		m.isFalling = isFalling ;
		
		m.mcAnim.gotoAndPlay(mcAnim._currentframe) ;
		if (mcAnim._alpha > 0) {
			m.mcAnim._alpha = mcAnim._alpha ;
			m.omc.mc._b._alpha = 0 ;
		}
		
		return m ;
	}
	
	
	override public function onStage() {
		super.onStage() ;
		
		omc.mc._b._alpha = 0 ;
		mcAnim._alpha = 100 ;
		
	}
	
	override public function onFall() {
		omc.mc._b._alpha = 0 ;
		mcAnim._alpha = 100 ;
		return false ;
	}
	
	
	override public function onGround() {
		super.onGround() ;
		others = new Array() ;
		targets = new Array() ;
		
		var tothers = new Array() ;
		var tempTargets : Array<{o : StageObject, wait : Float, step : Int, dist : Int}> = new Array() ;
		
		for (s in [0, 1]) {
			tempTargets = new Array() ;
			tothers[s] = new Array() ;
			var n = if (s == 0) Stage.WIDTH else Stage.HEIGHT ;
			for (i in 0...n) {
				var o = if (s == 0) Game.me.stage.grid[i][y] else Game.me.stage.grid[x][i] ;
				if (o == null)
					continue ;
				
				if (o.getArtId() == _PolarBomb) {
					if (tempTargets.length > 0) {
						for (j in 0...tempTargets.length) {
							var tt = tempTargets[j] ;
							if (j + 1.0 <= tempTargets.length / 2.0)
								tt.dist = j + 1 ;
							else 
								tt.dist = Std.int(tempTargets.length - j) ;
							
							tt.wait = tt.dist * tt.dist * 2.0 ;
							tt.o.effectTimer = 100.0 ;
							targets.push(tt) ;
							
						}
						tempTargets = new Array() ;
					}
					tothers[s].push(o) ;
				} else if (tothers[s].length > 0)
						tempTargets.push({o : o, dist : null, wait : 0.0, step : 0}) ;
			}
		}
		
		if (tothers[0].length < 2 && tothers[1].length < 2)
			return false ;
		
		Game.me.sound.play("clic") ;
		for (s in tothers) {
			for (o in s) {
				o.effectTimer = 100 ;
				o.setHalo() ;
				if (!Lambda.exists(others, function(x) { return x.x == o.x && x.y == o.y ; }))
					others.push(o) ;
			}
		}
		
		
		effectStep = -1 ;
		Game.me.setStep(ArtefactInUse, this) ;
		return true ;
	}
	
	
	override public function updateEffect() {
		switch (effectStep) {
			case -1 : //quick wait for halo
				effectTimer = Math.max(effectTimer - 8 * mt.Timer.tmod, 0) ;
			
				if (effectTimer == 0) {
					effectStep = 0 ;
					effectTimer = 100 ;
					Game.me.sound.play("arcelectrique") ;
				}
			
			case 0 :
				if (mcLine != null)
					mcLine.removeMovieClip() ;
				mcLine = Game.me.mdm.empty(Const.DP_PART) ;
				var w = warm(1.7) ;
				var eft = this.effectTimer ;
				for (o in others) {
					
					if (o != this) {
						o.warm(1.7) ;
						
						var delta = 6 ;
						var de = Const.ELEMENT_SIZE / 2 ;
						var sx = o.omc.mc._x + de ;
						var sy = o.omc.mc._y + de ;
						
						mcLine.lineStyle(5,0x14a4d9,50, false, null, "none") ;
						mcLine._alpha = 70 ;
						Col.setPercentColor(mcLine, 100 - eft, 0xffffff) ;
						Filt.glow(mcLine, 4, 4, 0xffffff) ;
						
						mcLine.moveTo(sx, sy) ;
						if (o.x == this.x) { //vertical
							var n = if (eft == 0)
									0
								else
									Std.int(Math.max(Math.abs(o.y - this.y), 1)) ;
							for (i in 0...n) {
								mcLine.lineTo(sx + delta * Math.random() * Std.random(2) * 2 -1,
											sy + i * (this.omc.mc._y - o.omc.mc._y) / n + delta * Math.random() * Std.random(2) * 2 -1) ;
								
							}
							
						} else { //horizontal
							var n = if (this.effectTimer == 0)
									0
								else
									Std.int(Math.max(Math.abs(o.x - this.x) , 1)) ;
							for (i in 0...n) {
								mcLine.lineTo(sx + i * (this.omc.mc._x - o.omc.mc._x) / n + delta * Math.random() * Std.random(2) * 2 -1,
											sy + delta * Math.random() * Std.random(2) * 2 -1) ;
								
							}
						}
						mcLine.lineTo(this.omc.mc._x + de, this.omc.mc._y + de) ;
						
					}
					
				}
				
				if (w) {
					effectStep = 1 ;
					effectTimer = 0 ;
				}
				
			case 1 : 
				effectTimer = Math.min(effectTimer + 2.5 * mt.Timer.tmod, 100) ;
				/*for (o in others) {
					var b = o.blink(3) ;
					if (o == this && b) {
						effectStep = 2 ;
						wait = targets.length ;
					}
				}*/
			
				if (effectTimer > 40)
					Game.me.stage.setShake(1, 1, true) ;
				
				mcLine._alpha = this.omc.mc._alpha ;
				mcLine.filters = [] ;
				
				var delta = 1 - anim.TransitionFunctions.quint(1 - effectTimer / 100) ;
			
			
				var pc = 100 - effectTimer ;
				Filt.glow(mcLine, 4 + delta * 20, 4 + delta * 20, 0xffffff) ;
				
				
				
				for (t in targets)
					t.o.warm(2.5) ;
					//t.o.omc.mc._alpha = others[0].omc.mc._alpha ;
				
				if (effectTimer == 100) {
					effectStep = 2 ;
					wait = targets.length ;
				}
				
				
			case 2 : 
				Game.me.stage.setShake(1, 2, true) ;
				
				for (t in targets) {
					if (t.step == 0) {
						if (t.wait > 0.0) {
							t.wait = Math.max(t.wait - 1.0 * mt.Timer.tmod, 0) ;
							continue ;
						}
						
						if (t.o.warm(6.0)) {
							t.step = 1 ;
							wait-- ;
							t.o.toDestroy(Flame(false), t.dist * 1.2) ;
							
						}
					}
				}
				
				if (wait <= 2) {
					for (o in others) {
						if (o.blink())
							o.effectTimer = 100 ;
					}
					for (t in targets)
						t.o.omc.mc._alpha = others[0].omc.mc._alpha ;
					mcLine._alpha = others[0].omc.mc._alpha ;
				}
					
				
				
				
				
				if (wait == 0)
					effectStep = 3 ;

				
			case 3 : 
				for(o in others) {
					o.toDestroy(Flame(true)) ;
				}
			
				Game.me.releaseArtefact(this) ;
				Game.me.setStep(Destroy) ;	
				mcLine.removeMovieClip() ;
				Game.me.stage.setShake(6, true) ;
		}
		
	}
	
	
	override public function kill() {
		if (mcAnim != null)
			mcAnim.removeMovieClip() ;
		super.kill() ;
	}
	

	
	
}