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
Pistonide : remonter une ligne tout en haut 
*/

class Pistonide extends StageObject {
	
	static var LINE_UP = 3 ;
	
	var ls : LineSelector ;
	var initY : Float ;
	var endY : Float ;
	var moved : Array<StageObject> ;
	var mcPiston : flash.MovieClip ;



	public function new ( ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_Pistonide) ;
		checkHelp() ;
		autoFall = true ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		if (noOmc)
			return ;
		omc = new ObjectMc(_Pistonide, pdm, depth, null, null, null, withBmp, sc) ;
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
			if (initY == null)
				initY = o.omc.mc._y ;
			
			o.effectTimer = 100 ;
			
			o.swapTo(12 + (Stage.WIDTH - i)) ;
			moved.push(o) ;
		}
		
		Game.me.sound.play("interface_out") ;
		
		endY = Const.HEIGHT - (Stage.Y + (Stage.HEIGHT - LINE_UP) * Const.ELEMENT_SIZE) ;
	}
	
	
	override public function onFall() {
		ls = new LineSelector(1, true) ;
		ls.setKeyListener(onKeyPress) ;
		
		moved = new Array() ;
		
		effectTimer = 100 ;
		effectStep = 1 ;
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
					effectStep = 7 ;
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
				var speed = 6.0 ; 
				effectTimer = Math.max(effectTimer - speed * mt.Timer.tmod, 0) ;
				ls.mc._alpha =effectTimer ;
			
			
				
				if (mcPiston == null) {
					mcPiston = Game.me.stage.dm.attach("piston", 13) ;
					mcPiston._x = Stage.X ;
					mcPiston._y = Const.HEIGHT - (Stage.BY + (ls.sLine + 1) * Const.ELEMENT_SIZE) ;
				}
				
				if (effectTimer == 0) {
					effectTimer = 0 ;
					Game.me.stage.setShake(1,1, true) ;
					effectStep = 4 ;
				}
				
			case 4 :  
				var speed = 8.0 ; //grow
				effectTimer = Math.max(effectTimer - speed * mt.Timer.tmod, 0) ;
			
				var delta = anim.Anim.getValue(Quint(-1), (100 - effectTimer) / 100) ;
			
				for (i in 0...Stage.WIDTH) {
					var o = Game.me.stage.grid[i][ls.sLine] ;
					if (o == null)
						continue ;
						
					o.omc.mc._b._xscale = 100 + delta * 35 ;
					o.omc.mc._b._yscale = o.omc.mc._b._xscale ;
				}
				
				/*mcPiston._xscale = 100 + delta * 35 ;
				mcPiston._yscale  = mcPiston._xscale  ;
				mcPiston._x -= delta * 35 ;
				*/
				
				if (effectTimer == 0) {
					effectTimer = 0 ;
					effectStep = 5 ;
				}
			
			case 5 : // move up
				effectTimer = Math.min(effectTimer + 0.03 * mt.Timer.tmod, 1) ;
				var delta = anim.Anim.getValue(Quint(-1), effectTimer) ;
			
				for (o in moved) {
					o.omc.mc._y = initY - (initY - endY) * delta ;
				}
				
				mcPiston._y = moved[0].omc.mc._y ;
				
				if (effectTimer == 1) {
					effectTimer = 0 ;
					effectStep = 6 ;
					//Game.me.sound.stop("special_loop") ;
					Game.me.sound.play("interface_in") ;
				}
			
			case 6 : //reduce
				effectTimer = Math.min(effectTimer + 0.1 * mt.Timer.tmod, 1) ;
				var delta = anim.Anim.getValue(Quint(1), effectTimer) ;
			
				for (o in moved) {
					o.omc.mc._b._xscale = 100 + (1 - delta) * 35 ;
					o.omc.mc._b._yscale = o.omc.mc._b._xscale ;
				}
				
				/*mcPiston._xscale = 100 + (1 - delta) * 35 ;
				mcPiston._yscale  = mcPiston._xscale  ;
				mcPiston._x += delta * 35 ;*/
				
				if (effectTimer == 1) {
					for(o in moved) {
						Game.me.stage.remove(o, true) ;
						o.place(o.x, Stage.HEIGHT - LINE_UP, Stage.X + o.x * Const.ELEMENT_SIZE, endY) ;
						Game.me.stage.add(o) ;
					}
					effectTimer = 0 ;
					effectStep = 7 ;
					Game.me.stage.forceXDepth() ;
				}
				
			case 7 : 
				effectTimer = Math.min(effectTimer + 0.2 * mt.Timer.tmod, 1) ;
			
				effectTimer = Math.min(effectTimer + 0.02 * mt.Timer.tmod, 1.0) ;
				var f = Std.int(Math.max(10 * (1.0 - effectTimer), 1)) ;
			
				if (effectTimer < 0.6) 
					Game.me.stage.setShake(1, 1, true) ;
				
				mcPiston.gotoAndStop(f) ;
				
				if (effectTimer == 1) {
					effectStep = 8 ;
				}
					
				
				
			case 8 : //end & fall
				ls.kill() ;
				Game.me.releaseArtefact(this) ;
				Game.me.setStep(Destroy) ;
		}
		
	}
	
	
	
	

	
	
}