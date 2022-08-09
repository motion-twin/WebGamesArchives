
import mt.bumdum9.Lib ;
import Game.CGroup ;
import Exit.ExitEffect ;

class Slot {

	public static var SIZE = 60 ;
	public static var SEL_SCALE = 1.10;
	public static var SEL_SCALE_BOUNCE = 0.975 ;

	public var x : mt.flash.Volatile<Int> ;
	public var y : mt.flash.Volatile<Int> ;
	public var stone : Stone ;
	public var exit : Exit ;
	public var group : CGroup ;
	public var selected : Bool ;
	public var waitShine : Null<Float> ;
	public var waitFall : Int ;
	public var g : Float ;
	public var pScore : {> MC, _text : TF} ;

	var curScale : Float ;
	var curDir : Array<Int> ;
	var scaling : Int ;


	public function new(px : Int, py : Int) {
		selected = false ;
		x = px ;
		y = py ;
		stone = new Stone() ;
		curScale = 1.0 ;
		scaling = 0 ;
		waitShine = null ;
		setDefaultStonePos() ;

		Game.me.allSlots.push(this) ;
	}


	public function setExit(e : Exit) {
		if (exit != null)
			throw "can't set an exit on " + x + "," + y ;

		exit = e ;
		e.slot = this ;
		e.setPos(x, y) ;
	}


	public function setDefaultStonePos() {
		var sPos = getStonePos(x, y) ;
		stone.mc.x = Std.int(sPos.x) ;
		stone.mc.y = Std.int(sPos.y) ;
	}

	public static function getStonePos(sx : Int, sy : Int) : {x : Int, y : Int } {
		return {x : Std.int(Game.STAGE_X + (sx + 0.5) * Slot.SIZE) ,
				y : Std.int(Game.STAGE_Y + (sy + 0.5) * Slot.SIZE) } ;
	}

	public function setStone(st : Stone, ?recal = true) {
		stone = st ;
		if (recal)
			setDefaultStonePos() ;
	}


	public function prepareScore(score : Int) {
		pScore = cast new gfx.Score() ;
		pScore._text.text = Std.string(score) ;
		pScore.blendMode = flash.display.BlendMode.ADD ;
		Game.me.dm.add(pScore, Game.DP_SCORE) ;
		var pos = getStonePos(x, y) ;
		pScore.x = pos.x ;
		pScore.y = pos.y ;

		

		var pnb = 2 + Std.random(3) ;
		for (i in 0...pnb) {
			var star : SP = switch(Std.random(3)) {
						case 0 : cast new gfx.Sparkle() ;
						case 1 : cast new gfx.Sparkle2() ;
						case 2 : cast new gfx.Sparkle3() ;
					} ;
			Game.me.dm.add(star, Game.DP_FX) ;
			//star.scaleX = star.scaleY = 0.6 ;
			//star.blendMode = flash.display.BlendMode.ADD ;

			
			star.x = pos.x + (Std.random(2) * 2 - 1) * (5 + Std.random(Std.int(Slot.SIZE / 8))) ;
			star.y = pos.y + (Std.random(2) * 2 - 1) * (5 + Std.random(Std.int(Slot.SIZE / 8))) ;
			var p = new mt.fx.Part(cast star) ;
			p.fadeType = 3 ;
			p.timer = 8 + Std.random(8) ;
			p.weight = -0.15 ;
			p.sleep(3 + Std.random(5)) ;
		
		}
	}


	public function vanishStone(score : Int) {
		if (stone == null)
			return ;
		stone.kill() ;
		stone = null ;

		var rt = Game.me.rand(7) ;
		var p = new mt.fx.Part(pScore) ;
		pScore = null ;
		p.fadeType = 1 ;
		p.timer = 7 + rt ;
		p.fadeLimit = 6 ;
		

		/*pScore.fadeType = 0 ;
		pScore.timer = 12 + rt  ;
		pScore.onFinish = callback(function(s : Slot) { s.pScore = null ; }, this) ;*/

			
		var star = new gfx.Vanish() ;
		Game.me.dm.add(star, Game.DP_STARS) ;
		var pos = Slot.getStonePos(x, y) ;
		star.x = pos.x ;
		star.y = pos.y ;
		var sp = new mt.fx.Part(cast star) ;
		sp.sleep( /*30 + */ rt, true) ;
		sp.timer = 25 ;
		//sp.onFinish = Game.me.waitDone ;
	}


	public function removeStone() {
		if (stone == null)
			return ;
		stone.kill() ;
		stone = null ;

	}


	public function setShine() {
		waitShine = (x + y) * 0.1 ;
	}


	public function update() {
		var step = Type.enumIndex(Game.me.step) ;

		if (step < 2)
			updateShine() ;



		var scaleSpeed =   /* 0.048*/ 0.038 * ((SEL_SCALE - 1.0) / 0.1) ;
	
		var rotSpeed = Game.DELTA_SELECT / ((SEL_SCALE - 1.0) / scaleSpeed) ;

		switch(scaling ) {
			//### DEPRECATED
			/*case -4 : //unselect bounce
				if (curScale == 1.0) {
					scaling = 0 ;
					Game.me.dm.under(stone.mc) ;
					curDir = null ;
					setDefaultStonePos() ;
					stone.mc.rotation = 0 ;
					return ;
				}

				curScale = Math.min(curScale + scaleSpeed, 1.0) ;
				stone.mc.scaleX = curScale ;
				stone.mc.scaleY = stone.mc.scaleX ;

			case -3 : //unselect bounce
				if (curScale == SEL_SCALE_BOUNCE) {
					scaling = -4 ;
					return ;
				}

				curScale = Math.max(curScale - scaleSpeed, SEL_SCALE_BOUNCE) ;
				stone.mc.scaleX = curScale ;
				stone.mc.scaleY = stone.mc.scaleX ;

			case -2 : //unselect
				if (curScale == 1.0) {
					scaling = -3 ;
					
					return ;
				}

				curScale = Math.max(curScale - scaleSpeed, 1.0) ;
				stone.mc.scaleX = curScale ;
				stone.mc.scaleY = stone.mc.scaleX ;

				stone.mc.x += curDir[0] * rotSpeed * -1 ;
				stone.mc.y += curDir[1] * rotSpeed * -1 ;
				stone.mc.rotation += rotSpeed * -1 ;
			*/

			case -1 : //unselect
				if (curScale == 1.0) {
					scaling = 0 ;
					Game.me.dm.under(stone.mc) ;
					curDir = null ;
					setDefaultStonePos() ;
					stone.mc.rotation = 0 ;
					stone.mc.scaleX = stone.mc.scaleY = 1.0 ;
					return ;
				}

				curScale = Math.max(curScale - scaleSpeed, 1.0) ;
				/*stone.mc.scaleX = curScale ;
				stone.mc.scaleY = stone.mc.scaleX ;*/

				stone.mc.x += curDir[0] * rotSpeed * -1 ;
				stone.mc.y += curDir[1] * rotSpeed * -1 ;
				stone.mc.rotation += rotSpeed * -1 ;

			case 0 : //nothing to do

			case 1 : //select rotate
				if (curScale == SEL_SCALE) {
					//scaling = 2 ;
					scaling = 0 ;
					curScale = 1.0 ;
					return ;
				}

				curScale = Math.min(curScale + scaleSpeed, SEL_SCALE) ;
				/*stone.mc.scaleX = curScale ;
				stone.mc.scaleY = stone.mc.scaleX ;*/

				stone.mc.x += curDir[0] * rotSpeed ;
				stone.mc.y += curDir[1] * rotSpeed ;
				stone.mc.rotation += rotSpeed ;

			//### DEPRECATED
			/*case 2 : //select grow
				if (curScale == SEL_SCALE) {
					scaling = 0 ;
					setDefaultStonePos() ;
					stone.mc.x += curDir[0] * Game.DELTA_SELECT ;
					stone.mc.y += curDir[1] * Game.DELTA_SELECT ;
					return ;
				}

				curScale = Math.min(curScale + scaleSpeed, SEL_SCALE) ;
				stone.mc.scaleX = curScale ;
				stone.mc.scaleY = stone.mc.scaleX ;*/
		}
	}


	public function updateShine() {
		if (waitShine == null)
			return ;

		waitShine -= 0.1 ;
		if (waitShine > 0.0)
			return ;

		waitShine = null ;
		stone.mc._stone.gotoAndPlay(1) ;
	}


	public function select(dir : Array<Int>) {
		Game.me.dm.over(stone.mc) ;
		if (scaling < 0) {
			setDefaultStonePos() ;
			stone.mc.scaleX = 1.0 ;
			stone.mc.scaleY = 1.0 ;
			curScale = 1.0 ;
			stone.mc.rotation = 0 ;
			//return ;
		}
		selected = true ;
		Game.me.selected.push(this) ;

		Game.me.dm.over(stone.mc) ;
		Filt.glow(stone.mc, 1.7, 10, 0xFFFFFF) ;

		curDir = dir ;

		/*setDefaultStonePos() ;
		/*stone.mc.x += dir[0] * Game.DELTA_SELECT ;
		stone.mc.y += dir[1] * Game.DELTA_SELECT ;*/

		scaling = 1 ;

		stone.mc.scaleX = stone.mc.scaleY = SEL_SCALE ;
	}


	public function unselect() {
		if (!selected)
			return ;
		selected = false ;
		Game.me.selected.remove(this) ;
		stone.mc.filters = [] ;

		/*if (stone.mc.scaleX > 1.0)
			scaling = -2 ;
		else */

		scaling = -1 ;

		//setDefaultStonePos() ;
	}


	public function rotate(dIdx : Int, ?fEnd : Void -> Void) {
		stone.mc.rotation = 0 ;

		var nSlot = Game.me.grid[x + Game.DIRS[dIdx][0]][y + Game.DIRS[dIdx][1]] ;
		var dest = getStonePos(nSlot.x, nSlot.y) ;

		var deltaSel = Game.DIRS[(dIdx + 1 ) % Game.DIRS.length] ;
		var nx = dest.x + deltaSel[0] * Game.DELTA_SELECT ;
		var ny = dest.y + deltaSel[1] * Game.DELTA_SELECT ;

		Game.me.waitingFx++ ;
		stone.rfx = new mt.fx.Tween(stone.mc, nx, ny, 0.16) ;
		//stone.rfx.curveIn(4) ;
		stone.rfx.curveInOut() ;
		stone.rfx.onFinish = callback(function(f : Void -> Void) { Game.me.waitDone() ; if (f != null) f() ; }, fEnd) ;

	}


	public function setFall(?wait = 0) {
		waitFall = wait ;
		var nPos = getStonePos(x, y) ;
		/*
		Game.me.waitingFx++ ;
		stone.rfx = new mt.fx.Tween(stone.mc, nPos.x, nPos.y, 0.1250.0125) ;
		stone.rfx.onFinish = callback(function(s : Stone, f : Void -> Void) { stone.breakIt() ; Game.me.waitDone() ; if (f != null) f() ; }, stone, fEnd) ;
		*/
		g = 1.4 ;
		Game.me.falls.push(this) ;
	}


	public function fall() {
		if (waitFall > 0) {
			waitFall-- ;
			return ;
		}

		
		var nPos = getStonePos(x, y) ;
		var t = Math.min( 10.0 + g, nPos.y - stone.mc.y) ;
		g = Math.min(g * g, 25.0) ;
				
		stone.mc.y += t ;

		if (nPos.y - stone.mc.y < 4) {
			stone.mc.y = nPos.y ;
			Game.me.falls.remove(this) ;
			
			stone.breakIt() ;
			
			//pierres finissent de tomber
			#if sound
			var snd = Game.me.sound;
			var s = [snd(new sound.Rock_fall1()),snd(new sound.Rock_fall2()),snd(new sound.Rock_fall3()),snd(new sound.Rock_fall4()),snd(new sound.Rock_fall5()),snd(new sound.Rock_fall6()),snd(new sound.Rock_fall7()),snd(new sound.Rock_fall8()),snd(new sound.Rock_fall9()),];
			s[Std.random(s.length)].play();
			#end

		}

	}


	public function killGroup() {
		group = null ;
	}


	public function kill() {
		if (stone != null)
			stone.kill() ;

		if (exit != null)
			exit.mc.parent.removeChild(exit.mc) ;
	}



}