package artefact ;

import flash.Key ;
import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import Stage.TempEffect ;
import Game.GameStep ;
import StageObject.DestroyMethod ;
import GameData._ArtefactId ;


/*
Tejerkatum : destruction d'une ligne entiere au choix
(impossible de ne rien détruire)
*/

class Tejerkatum extends StageObject {
	
	var ls : LineSelector ;
	var mcLiane : flash.MovieClip ;
	var lst : Float ;
	

	public function new ( ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_Tejerkatum) ;
		checkHelp() ;
		autoFall = true ;
		pdm = if (dm != null) dm else Game.me.stage.dm ;
		if (noOmc)
			return ;
		omc = new ObjectMc(_Tejerkatum, pdm, depth, null, null, null, withBmp, sc) ;
	}
	
	
	function onKeyPress() {
		var n = Key.getCode() ;
		switch(n) {
			case Key.UP :
				if (!Game.me.pause)
					ls.move(1) ;
			case Key.SPACE, Key.ENTER :
				if (!Game.me.pause)
					selectLine() ;
			case Key.DOWN : 
				if (!Game.me.pause)
					ls.move(-1) ;
				
		}
		
	}
	
	
	function selectLine() {
		
		effectStep = 3 ;
		effectTimer = 100 ;
		
		ls.selectLine() ;
		
		for (i in 0...Stage.WIDTH) {
			var o = Game.me.stage.grid[i][ls.sLine] ;
			if (o == null)
				continue ;
			o.effectTimer = 100 ;
		}
		
		Game.me.sound.play("special_start") ;
		Game.me.sound.play("special_loop", true) ;
	}
	
	
	override public function onFall() {
		ls = new LineSelector(1) ;
		ls.setKeyListener(onKeyPress) ;
		
		effectTimer = 100 ;
		effectStep = 1 ;
		lst = 100 ;
		Game.me.setStep(ArtefactInUse, this) ;
		
		if (!ls.init()) {
			effectStep = 0 ;
			return true ;
		}
		
		ls.moveTo(Std.int(ls.sMax / 2)) ;
		
		return true ;
	}

	
	override public function updateEffect() {
		
		switch (effectStep) {
			case 0 : //empty stage => destroy tejerkatum
				if (this.warm(10)) {
					this.toDestroy(Warp) ;
					effectStep = 6 ;
				}
				
			case 1 :
				effectTimer = Math.max(effectTimer - 10.0 * mt.Timer.tmod, 0) ;
				omc.mc._alpha =effectTimer ;
			
				if (effectTimer == 0) {
					effectStep = 2 ;
					Game.me.stage.remove(this, false) ;
					
					ls.showMc(true) ;
					Game.me.switchKeyListener(ls.k) ; 
				}
				
			case 2 : 
				//nothing to do => choose your line
			
			case 3 : //line selected
				var speed = 3.2 ;
				lst = Math.max(lst - 10 * mt.Timer.tmod, 0) ;
				effectTimer = Math.max(effectTimer - speed * mt.Timer.tmod, 0) ;
			
				ls.mc._alpha = lst ;
			
				if (effectTimer < 30) 
					Game.me.stage.setShake(1, 2) ;

			
				if (mcLiane == null) {
					mcLiane = Game.me.stage.dm.attach("hliane", 13) ;
					mcLiane._x = Stage.X ;
					mcLiane._y = Const.HEIGHT - (Stage.BY + (ls.sLine + 1) * Const.ELEMENT_SIZE) ;
				}
				
				if (effectTimer == 0) {
					effectStep = 4 ;
					effectTimer = 100 ;
					
				}
				
			case 4 : 
				var speed = 3.2 ;
				effectTimer = Math.max(effectTimer - speed * mt.Timer.tmod, 0) ;	
			
				Game.me.stage.setShake(1, 2) ;
			
				for (i in 0...Stage.WIDTH) {
					var o = Game.me.stage.grid[i][ls.sLine] ;
					if (o == null)
						continue ;
					
					o.warm(speed) ;
				}
				
				if (effectTimer == 0) {
					effectStep = 5 ;
					effectTimer = 100 ;
					Game.me.sound.stop("special_loop") ;
					Game.me.sound.play("transmutation_destructrice") ;
				}
			
			case 5 : 

				var nbParts = 25 ;
				for(i in 0...nbParts) {
					var mc = Game.me.mdm.attach("partWhiteleaf", Const.DP_PART) ;
					Col.setPercentColor(mc, 70 + Std.random(30), 0xFFCC00) ;
					mc._xscale = mc._yscale = 110 + Std.random(100) ;
					mc.gotoAndStop(Std.random(4)+ 1) ;
					var sp = new Phys(mc) ;
					var a = Math.random()*-3.14 ;
					var ca = Math.cos(a) ;
					var sa = Math.sin(a) ;
					
					var speed = if (Std.int(Math.round(i / 2)) == Std.int(i / 2))
								5 + Math.random() * 7 ;
							else
								Math.random() * 2 * (Std.random(2) * 2 - 1) ;
					
					sp.x = Stage.X + i * (Const.ELEMENT_SIZE * 6 / nbParts) + ca * 4 ;
					sp.y = mcLiane._y + sa * 4 ;
					sp.vx = ca * speed ;
					sp.vy = sa * speed ;
					sp.vr = (1.2 + Math.random() * 2) * (Std.random(2) * 2 - 1) ;
					//sp.vsc = 1.01  * (Std.random(2) * 2 - 1) ;
					sp.frict = 0.77 + Math.random() * 0.16 ;
					sp.fadeType = 5 ;
					sp.timer = 30 + Std.random(50) ;
					sp.weight = 0.1 + Math.random() * 0.2 ;
				}
				mcLiane.removeMovieClip() ;
				
		
				for (i in 0...Stage.WIDTH) {
					var o = Game.me.stage.grid[i][ls.sLine] ;
					if (o == null)
						continue ;
					o.toDestroy(Flame(false)) ;
				}
				
				ls.kill() ;
			
				Game.me.releaseArtefact(this) ;
				//Game.me.restoreKeyListener() ;
				
				Game.me.setStep(Destroy) ;
				kill() ;
				
				case 6 : 
					Game.me.releaseArtefact(this) ;
					Game.me.restoreKeyListener() ;
					Game.me.setStep(Destroy) ;
					
				
		}
		
		
	}
	
	
	

	
	
}