package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import Game.GameStep ;
import GameData._ArtefactId ;
import anim.Transition ;

/*
graine de poirier
//inverse le plateau en vertical
*/

class PearGrain extends StageObject {
	
	var level : Int ;
	var cols : Array<{col : Int, timer : Float, maxX : Int, l : Array<{o : StageObject, initY : Float, initX : Float, r : Int}>}> ;
	var swapDone : Bool ;
	
	
	public function new (lvl : Int, ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		level = lvl ;
		autoFall = lvl > 0 ;
		id = Const.getArt(_PearGrain(lvl)) ;
		checkHelp() ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		
		if (noOmc)
			return ;
		omc = new ObjectMc(_PearGrain(lvl), pdm, depth, null, null, null, withBmp, sc) ;
	}
	
	
	override public function onFall() {
		effectTimer = 1 ;
		effectStep = 0 ;
		
		var from = if (level == 1) 0 else x ;
		var to = if (level == 1) Stage.WIDTH else x + 1 ;
		cols = new Array() ;
		
		var wait = if (level == 0) 0.0 else -0.08 ;
		
		for (c in from...to) {
			var cc = {col : c, timer : wait, maxX : 15, l : new Array()} ;
			for (i in 0...Stage.LIMIT) {
				var so = Game.me.stage.grid[c][i] ;
				if (so != null)
					cc.l.push({o : so, initY : so.omc.mc._y, initX : so.omc.mc._x, r : Std.int(Math.abs(so.y - 3))}) ;
			}
			wait -= 0.08 ;
			cols.push(cc) ;
		}
		Game.me.stage.setShake(level, 2) ;
		
		Game.me.setStep(ArtefactInUse, this) ;
		return true ;
	}
	
	
	override public function updateEffect() {
		switch (effectStep) {
			case 0 :
				effectTimer = Math.max(effectTimer - 0.1 * mt.Timer.tmod, 0) ;
				omc.mc._alpha = effectTimer * 100 ;
				if (effectTimer == 0) {
					effectStep = 1 ;
					Game.me.stage.remove(this) ;
					if (level == 0)
						Game.me.sound.play("inversion") ;
					else 
						Game.me.sound.play("inversion_chorus") ;
					
				}
				
				
			case 1 : 
				var d = 0.02 * mt.Timer.tmod ;
				effectTimer = Math.min(effectTimer + d, 1.0) ;
				var delta = anim.Anim.getValue(Quint(-1), effectTimer) ;
				
				var padding = 55 ;
				var maxScale = 35 ;
			
				if (effectTimer < 0.4)
					Game.me.stage.setShake(1, 2) ;
			
				for (col in cols) {
					col.timer = Math.min(col.timer + d, 1.0) ;
					if (col.timer < 0.0 || col.timer == 1.0) //waiting/finished col
						continue ;
					
					var delta = anim.Anim.getValue(Quint(-1), col.timer) ;
					
					for (c in col.l) {
						var s = if (c.o.y < 3) 1.0 else -1.0 ;
						var h = (c.r * 2 ) * Const.ELEMENT_SIZE * (1.36 - c.o.y * 0.02) ;
						
						c.o.omc.mc._y = c.initY - h * delta * s -  padding * delta  ;
						c.o.omc.mc._x = c.initX + s * (c.r * col.maxX) * (if (delta <= 0.5) delta else 1.0 - delta) * 2 ;
						
						var sc = 100 + s * (c.r * maxScale) * (if (delta <= 0.5) delta else 1.0 - delta) * 2 ;
						/*c.o.omc.mc.smc.smc._xscale = sc ;
						c.o.omc.mc.smc.smc._yscale = c.o.omc.mc.smc.smc._xscale ;*/
						
						c.o.omc.mc._b._xscale = sc ;
						c.o.omc.mc._b._yscale = c.o.omc.mc._b._xscale ;
						
						if (sc <= 100)
							Col.setPercentColor(c.o.omc.mc._b, 100 - sc,0x000000) ;
					}
				}
				
			
				if (cols[cols.length - 1].timer== 1.0) {
					effectStep = 2 ;
					
					for (col in cols) {
						var gc = col.l ;
						for (i in 0...Stage.LIMIT)
							Game.me.stage.grid[col.col][i] = null ;
						
						for (i in 0...Stage.LIMIT) {
							var n = Stage.LIMIT - 1 - i ;
							
							var o = gc[n].o ;
							Game.me.stage.grid[col.col][i + 1] = o ;
							
							if (o != null) {
								o.y = i + 1 ;
								o.swapTo(Stage.HEIGHT - o.y) ;
							}
						}
						
						
					}
					
				}
			
			
			case 2 : 
				Game.me.releaseArtefact(this) ;
				Game.me.setStep(Destroy) ;
		}
	}
}