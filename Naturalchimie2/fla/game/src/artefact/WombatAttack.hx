package artefact ;

import flash.Key ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import Game.GameStep ;
import StageObject.DestroyMethod ;
import GameData._ArtefactId ;

/*
grignote de gauche à droite jusqu'à disparaitre. Déplacement anarchique
*/

class WombatAttack extends StageObject {
	
	static var V = 2 ;
	static var G = 9.8 ;
	
	public var activate : Bool ;
	public var start : {x : Int, y : Int} ;
	public var next : {x : Int, y : Int, posX : Float, posY : Float} ;
	var nextDir : Int ;
	var ls : LineSelector ;
	var v : Float ;
	var wAnim : flash.MovieClip ;
	var soundTooth : Int ;
	
	public var pause : Bool ;
	
	public function new(?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_Wombat) ;
		soundTooth = 0 ;
		checkHelp() ;
		autoFall = true ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		nextDir = 1 ; //east
		v = V ;
		
		pause = false ;
		
		if (noOmc) 
			return ;
		omc = new ObjectMc(_Wombat, pdm, depth, null, null, null, withBmp, sc) ;
		
	}
	
	
	override public function onFall() {
		ls = new LineSelector(1) ;
		ls.setKeyListener(onKeyPress) ;
				
		effectTimer = 100 ;
		effectStep = 1 ;
		Game.me.setStep(ArtefactInUse, this) ;
		
		if (!ls.init()) {
			effectStep = 0 ;
			return true ;
		}
		
		ls.moveTo(Std.int(ls.sMax / 2)) ;
		
		return true ;
		
		/*effectTimer = 100 ;
		effectStep = 0 ;
		start = {x : -1, y : 0} ;
		for (y in 0...Stage.HEIGHT) {
			start.y = y ;
			if (Game.me.stage.grid[0][y] == null)
				break ;
		}
		start.y = Std.random(start.y) ;
		setNext(0, start.y) ;
		
		Game.me.setStep(ArtefactInUse, this) ;
		Game.me.stage.remove(this, true) ;
		omc.mc.smc.smc.smc.gotoAndPlay(1) ;
		return true ;*/
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
		
		start = {x : -1, y : ls.sLine} ;
		
		setNext(0, start.y) ;
		
		Game.me.stage.remove(this, true) ;
		//omc.mc.
		//omc.mc.smc.smc.smc.gotoAndPlay(1) ;
		wAnim = pdm.attach("wAnim", 2) ;
		
		wAnim._x = Stage.X + (start.x) * Const.ELEMENT_SIZE ;
		wAnim._y = Const.HEIGHT - (Stage.BY + (start.y + 1) * Const.ELEMENT_SIZE) ;
		x = start.x ;
		y = start.y ;
		
		
		pdm.swap(wAnim, Stage.HEIGHT + 1) ;
		wAnim.setMask(Game.me.stage.animMasks[0]) ;
		
		Game.me.sound.play("wombat_loop", true) ;
		
	}
	
	
	
	override public function updateEffect() {
		if (pause)
			return ;
		
		switch(effectStep) {
			case 0 : //empty stage => destroy tejerkatum
				if (this.warm()) {
					this.toDestroy(Warp) ;
					effectStep = 4 ;
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

				
			case 3 : 
				var speed = 8.0 ; //grow
				effectTimer = Math.max(effectTimer - speed * mt.Timer.tmod, 0) ;
				ls.mc._alpha =effectTimer ;	
			
			
				Game.me.stage.destroy() ;
			
			
			
				if (!isOnNext()) {
					switch (nextDir) {
						case 0 : //north
							
							wAnim._y -= Math.min(v * mt.Timer.tmod, Math.abs(wAnim._y - next.posY)) ;
						case 1 : //east
							wAnim._x += Math.min(v * mt.Timer.tmod, Math.abs(wAnim._x - next.posX)) ;
						case 2 : //south
							wAnim._y += Math.min(v * mt.Timer.tmod, Math.abs(wAnim._y - next.posY)) ;
						case 3 : //west
							wAnim._x -= Math.min(v * mt.Timer.tmod, Math.abs(wAnim._x - next.posX)) ;
					}					
				} else {
					x = next.x ;
					y = next.y ;
					wAnim._x = next.posX ;
					wAnim._y = next.posY ;
					
					var o = Game.me.stage.grid[x][y] ;
					if (o != null) {
						o.toDestroy(Flame(true)) ;
						Game.me.sound.play("wombat_dent" + Std.string(soundTooth + 1)) ;
						soundTooth = (soundTooth + 1) % 2;
						Game.me.stage.setShake(2, null, true) ;
					}
					//else 
					
					if (onRightStage()) {//end
						effectStep = 4 ;
						Game.me.sound.stop("wombat_loop", true) ;
						return ;
					}
					
					nextDir = setNextDir() ;
					wAnim._xscale = 100 ;
					switch (nextDir) {
						case 0 :
							setNext(x, y + 1) ;
							wAnim.smc._rotation = -90 ;
						case 1 :
							setNext(x + 1, y) ;
							wAnim.smc._rotation = 0 ;
						case 2 :
							setNext(x, if (v == V) y - 1 else getHigher(x)) ;
							wAnim.smc._rotation = if (v == V) 90 else 0 ;
						case 3 :
							setNext(x - 1, y) ;
							wAnim.smc._rotation = 0 ;
							wAnim._xscale = -100 ;
					}
				}
				
			case 4 : 
				ls.kill();
				Game.me.releaseArtefact(this) ;
				if (wAnim != null)
					wAnim.removeMovieClip() ;
			
				kill() ;
				Game.me.setStep(Destroy) ;
			
			
		}
		
	}
	
	
	function getHigher(col : Int) : Int {
		for (i in 0...Stage.HEIGHT) {
			if (Game.me.stage.grid[col][i] == null)
				return i ;
		}
		return 0 ;
	}
	
	function isOnNext() : Bool {
		var dx = 2 ;
		var dy = if (v == V) 2 else G ;
		return Math.abs(wAnim._x - next.posX) < dx && Math.abs(wAnim._y - next.posY) < dy ;
	}
	
	
	function setNext(nx : Int, ny : Int) {
		next = {x : nx,
			y : ny,
			posX : Stage.X + nx * Const.ELEMENT_SIZE,
			posY : Const.HEIGHT - (Stage.BY + (ny + 1) * Const.ELEMENT_SIZE)
			} ;
	}
	
	
	function setNextDir() : Int {
		v = V ;
		var nd = [] ;
		for (i in 0...3) {
			/*if (Const.sMod(i + 2, 4) == nextDir)
				continue ;*/
			switch (i) {
				case 0 : //north
					if (Game.me.stage.grid[x][y + 1] != null)
						nd.push(0) ;
				case 1 : //east
					if (Game.me.stage.grid[x + 1][y] != null)
						nd = nd.concat([1, 1]) ;
				case 2 : //south
					if (Game.me.stage.grid[x][y - 1] != null)
						nd = nd.concat([2, 2, 1]) ;
			}
		}
		
		if (Game.me.stage.grid[x][y - 1] == null && nextDir != 0) {
			if (y == 0)
				return 1 ;
			v = G ;
			return 2 ;
		} else if (nd.length == 1 && nd[0] == 0) //unforced up
			return 1 ;
		
		
		return nd[Std.random(nd.length)] ;
	}
	
	
	function onRightStage() : Bool {
		return x >= Stage.WIDTH ;
	}

	
	
	
}