package artefact ;

import flash.Key ;
import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import Stage.TempEffect ;
import Game.GameStep ;
import GameData._ArtefactId ;
import anim.Transition ;


/*
Teleport : on sélectionne 2 colonnes l'une après l'autre (colonne vide possible). On inverse ensuite leurs positions
*/


class Teleport extends StageObject {
	
	var cols : Array<{index : Int, objects : Array<StageObject>, fromX : Float, targetX : Float}> ;
	var ls : LineSelector ;
	var lst : Float ;
	var mcLock : Array<flash.MovieClip> ;
	var r : Float ;
	var mcLianeLeft : {fg : flash.MovieClip, bg : flash.MovieClip} ;
	var mcLianeRight : {fg : flash.MovieClip, bg : flash.MovieClip} ;

	public function new ( ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_Teleport) ;
		checkHelp() ;
		autoFall = true ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
			
		if (noOmc)
			return ;
		omc = new ObjectMc(_Teleport, pdm, depth, null, null, null, withBmp, sc) ;
	}
	
	
	function onKeyPress() {
		var n = Key.getCode() ;
		switch(n) {
			case Key.RIGHT :
				if (!Game.me.pause)
					ls.move(1) ;
			case Key.SPACE, Key.DOWN :
				if (!Game.me.pause)
					selectColumn() ;
			case Key.LEFT : 
				if (!Game.me.pause)
					ls.move(-1) ;
		}
	}
	
	
	function selectColumn() {
		cols.push({index : ls.sLine, objects : Game.me.stage.grid[ls.sLine].copy(), targetX : null, fromX : null}) ;
		
		var m = Game.me.mdm.attach("selectedLine", Const.DP_PART) ;
		m._x = ls.mc._x ;
		m._y = ls.mc._y ;
		mcLock.push(m) ;
		ls.blocked = ls.sLine ;
		
		if (cols.length >= 2) {
			prepareRotation() ;
			effectStep = 1 ;
			effectTimer = 0 ;
			ls.kill() ;
			Game.me.restoreKeyListener() ;
			
			Game.me.sound.play("interface_out") ;

		}else {
			if (ls.sLine + 1 >= Stage.WIDTH)
				ls.sLine-- ;
			else 
				ls.sLine++ ;
			ls.moveTo(ls.sLine) ;
			effectStep = 0 ;
		}
	}
	
	function prepareRotation() {
		if (cols[0].index > cols[1].index)
			cols.reverse() ;
		r = (cols[1].index - cols[0].index) / 2 ;
		cols[0].targetX = Stage.X + cols[1].index * Const.ELEMENT_SIZE ;
		cols[1].targetX = Stage.X + cols[0].index * Const.ELEMENT_SIZE ;
		cols[0].fromX = cols[1].targetX ;
		cols[1].fromX = cols[0].targetX ;
		
		for (i in 0...cols.length) {
			var c = cols[i] ;
			var j = c.objects.length - 1 ;
			while (j >= 0) {
				if (c.objects[j] != null) {
					var o = c.objects[j] ;
					Game.me.stage.remove(o, true) ;
					
					if (i == 1)
						o.swapTo(1) ;
					else 
						o.swapTo(Stage.HEIGHT + 1) ;
				}
				j-- ;
			}
		}
	}
	
	
	override public function onFall() {
		cols = new Array() ;
		mcLock = new Array() ;
		Game.me.setStep(ArtefactInUse, this) ;
		
		effectTimer = 100 ;
		lst = 0.0 ;
		effectStep = -1 ;
		
		ls = new LineSelector(0) ;
		ls.init() ;
		ls.moveTo(x) ;
		ls.setKeyListener(onKeyPress) ;
		//ls.showMc(true) ;
		//Game.me.switchKeyListener(ls.k) ;
		Game.me.stage.remove(this, true) ;
		
		return true ;
	}


	override public function updateEffect() {
		switch(effectStep) {
			case -1 :
				effectTimer = Math.max(effectTimer - 10.0 * mt.Timer.tmod, 0) ;
				omc.mc._alpha = effectTimer ;
			
				if (effectTimer == 0) {
					effectStep = 0 ;
					ls.showMc(true) ;
					Game.me.switchKeyListener(ls.k) ; 
				}

			case 0 : //nothing to do, player is choosing a column
				
				
			case 1 : // 
				lst = Math.min(lst + 0.04 * mt.Timer.tmod, 1) ;
				effectTimer = Math.min(effectTimer + 0.02 * mt.Timer.tmod, 1) ;
				for (m in mcLock) {
					var oldy = m._height ;
					m._yscale = 100 + lst * 100 ;
					m._y -= (m._height - oldy) ;
					
					m._alpha = 100 - lst * 100 ;
				}
				
				if (mcLianeLeft == null) {
					mcLianeLeft = { fg : Game.me.stage.dm.attach("vliane", 13),
								 bg : Game.me.stage.dm.attach("vliane", 0)} ;								
					mcLianeLeft.fg._x = Stage.X + Const.ELEMENT_SIZE * (cols[0].index + 0.5) ;
					mcLianeLeft.fg._y = 350 ;
					mcLianeLeft.bg._x = mcLianeLeft.fg._x ;
					mcLianeLeft.bg._rotation = 180 ;
					mcLianeLeft.bg._y = 0 ;
					Col.setPercentColor(mcLianeLeft.bg, 80, 0x000000) ;
								 
					mcLianeRight = { fg : Game.me.stage.dm.attach("vliane", 1),
									bg : Game.me.stage.dm.attach("vliane", 0)} ;								
					mcLianeRight.fg._x = Stage.X + Const.ELEMENT_SIZE * (cols[1].index + 0.5) ;
					mcLianeRight.fg._rotation = 180 ;
					mcLianeRight.fg._y = 0 ;
					mcLianeRight.bg._x = mcLianeRight.fg._x ;
					mcLianeRight.bg._y = 350 ;
					Col.setPercentColor(mcLianeRight.bg, 80, 0x000000) ;
									
					/*mcLianeLeft.fg._alpha = 0 ;
					mcLianeLeft.bg._alpha = 0 ;
					mcLianeRight.fg._alpha = 0 ;
					mcLianeRight.bg._alpha = 0 ;*/
					
				}
				
			
				if (effectTimer == 1) {
					effectTimer = 0 ;
					effectStep = 2 ;
					
					Game.me.sound.play("special_start") ;
					Game.me.sound.play("special_loop", true) ;
				}
				
			
			case 2 :
				effectTimer = Math.min(effectTimer + 0.015 * mt.Timer.tmod, 1.0) ;
				var delta = anim.Anim.getValue(Cubic(-1), effectTimer) ;	
			
				if (effectTimer > 0.2) 
					Game.me.stage.setShake(1, 1, true) ;

				for (i in 0...cols.length) {
					var d = cols[i].targetX - cols[i].fromX ;
					var sc = 100 + 18 * r * Math.sin(3.14 - 3.14 * delta) * d / Math.abs(d) ;
					for (j in 0...cols[i].objects.length) {
						var o = cols[i].objects[j] ;
						if (o == null)
							continue ;						
						
						o.omc.mc._x = cols[i].fromX + delta * d ;
						
						
						o.omc.mc._b._xscale = sc ;
						o.omc.mc._b._yscale = o.omc.mc._b._xscale ;
						
						if (d < 0)
							Col.setPercentColor(o.omc.mc._b, (100 - sc) * 3,0x000000) ;
						
					}
					
					var liane =  switch(i) {
						case 0 : mcLianeLeft ;
						case 1 : mcLianeRight ;
					}
					
					liane.fg._x = cols[i].fromX + (0.5 * Const.ELEMENT_SIZE) + delta * d ;
					liane.fg._xscale = sc ;
					if (d < 0) {
						Col.setPercentColor(liane.fg, (100 - sc) * 3,0x000000) ;
					}
				//	liane.fg._yscale = sc ;
					/*if (liane.fg._y < 300)
						liane.fg._y = delta * -20 ;*/
					liane.bg._x = liane.fg._x ;
					liane.bg._xscale = sc ;
					//liane.bg._yscale = sc ;
					/*if (liane.bg._y < 300)
						liane.bg._y = delta * 10 ;*/
				}
				
			
				if (effectTimer == 1) {
					effectStep = 3 ;
					effectTimer = 0 ;
					Game.me.stage.dm.swap(mcLianeRight.fg, 13) ;
					for (i in 0...cols.length) {
						var j = cols[i].objects.length - 1 ;
						while (j >= 0) {
							var o = cols[i].objects[j] ;
							if (o != null) {
								var oi =  cols[Std.int(Math.abs(i -1))].index ;
								o.place(oi, o.y, Stage.X + oi * Const.ELEMENT_SIZE, o.omc.mc._y) ;
								Game.me.stage.add(o) ; 
								o.swapTo(Stage.HEIGHT - o.y) ;
							}
							j-- ;
						}
					}
					
					//this.setHalo() ;
					Game.me.stage.forceXDepth() ;
					Game.me.sound.stop("special_loop") ;
					Game.me.sound.play("wombat_dent1") ;
					Game.me.sound.play("interface_out", null, null, null, 5) ;
				}
				
			case 3 : 
				effectTimer = Math.min(effectTimer + 0.02 * mt.Timer.tmod, 1.0) ;
				var f = Std.int(Math.max(35 * (1.0 - effectTimer), 1)) ;
			
				if (effectTimer < 0.6) 
					Game.me.stage.setShake(1, 1, true) ;
				
				mcLianeLeft.fg.gotoAndStop(f) ;
				mcLianeLeft.bg.gotoAndStop(f) ;
				mcLianeRight.fg.gotoAndStop(f) ;
				mcLianeRight.bg.gotoAndStop(f) ;
			
				
				if (effectTimer == 1) {
					effectStep = 4 ;
				}
			
			case 4 : 
				Game.me.releaseArtefact(this) ;
				Game.me.setStep(Destroy) ;
				kill() ;
			
				mcLianeLeft.fg.removeMovieClip() ;
				mcLianeLeft.bg.removeMovieClip() ;
				mcLianeRight.fg.removeMovieClip() ;
				mcLianeRight.bg.removeMovieClip() ;
			
		}
		
	}
	
	
	override public function kill() {
		if (ls != null)
			ls.kill() ;
		if (mcLock != null) {
			for (m in mcLock) 
				m.removeMovieClip() ;
		}
		super.kill() ;
	}
	
	
}