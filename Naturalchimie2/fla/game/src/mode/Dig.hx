package mode ;

import GameData._ArtefactId ;
import Game.GameStep ;
import StageObject.DestroyMethod ;
import anim.Transition ;
import anim.Anim.AnimType ;




class Dig extends GameMode {
	
	static public var SCORE_BY_BLOCK = 100 ;
	static var STAGE_RECAL = 220.0 ;
	
	static var REWARDS = [
		{weight : 300, r : _Elt(0)},
		{weight : 340, r : _Elt(1)},
		{weight : 340, r : _Elt(2)},
		{weight : 500, r : _Elt(3)},
		{weight : 500, r : _Elt(4)},
		{weight : 300, r : _Elt(5)},
		{weight : 360, r : _Elt(6)},
		{weight : 300, r : _Elt(7)},
		{weight : 140, r : _Elt(8)},
		{weight : 60, r : _Elt(12)},
		{weight : 60, r : _Elt(16)},
		{weight : 60, r : _Elt(20)},
		{weight : 60, r : _Elt(24)},
		{weight : 6, r : _Elt(9)},
		{weight : 4, r : _Elt(10)},
		{weight : 260, r : _Pa},
		{weight : 300, r : _Stamp}, 
		//limit of normal reward mode : 16 elements
		{weight : 3, r : _Elt(11)},
		{weight : 120, r : _Alchimoth},
		{weight : 120, r : _Dynamit(0)},
		{weight : 80, r : _Dynamit(1)},
		{weight : 10, r : _Dynamit(2)},
		{weight : 130, r : _Protoplop(0)},
		{weight : 100, r : _Protoplop(1)},
		{weight : 80, r : _PearGrain(0)},
		{weight : 2, r : _PearGrain(1)},
		{weight : 1, r : _Dalton},
		{weight : 100, r : _Wombat},
		{weight : 1, r : _MentorHand},
		{weight : 120, r : _Jeseleet(0)},
		{weight : 40, r : _Jeseleet(1)},
		{weight : 80, r : _Delorean(0)},
		{weight : 1, r : _Dollyxir(0)},
		{weight : 5, r : _RazKroll},
		{weight : 110, r : _Detartrage},
		{weight : 135, r : _Grenade(0)},
		{weight : 60, r : _Grenade(1)},
		{weight : 2, r : _Teleport},
		{weight : 120, r : _PolarBomb},
		{weight : 2, r : _Pistonide},
		{weight : 1, r : _Tejerkatum},
		{weight : 1, r : _Patchinko}
		] ;
	
	static var BLOCKS_PERCENT = [
					[45, 25, 25, 5],
					[25, 45, 25, 5],
					[20, 45, 25, 10],
					[20, 40, 25, 15],
					[17, 43, 25, 15],
					[15, 38, 27, 20],
					[14, 33, 29, 24],
					[11, 29, 33, 27],
					[11, 29, 30, 30],
					[12, 30, 28, 35],
					[12, 30, 28, 35],
					[10, 22, 28, 40],
					[10, 20, 30, 40],
					[5, 15, 30, 50],
					[0, 20, 30, 50]
					] ;
	
	var stage : Stage ;
	var rewardCount : mt.flash.Volatile<Int> ;
	var digLevel : mt.flash.Volatile<Int> ;
	var digStep : Int ;
	var digObjects : Array<StageObject> ;
	var newLevelObjects : Array<{o : StageObject, startY : Float, endY : Float}> ;
	var timer : Float ;
	var patterns : Array<{g : Array<Int>, h : Int, c : Int, flip : Bool}> ;
	var saveLevelMax : Int ;
	
	
	public function new() {
		super() ;
		initPatterns() ;
		rewardCount = 0 ;
	}
	
	
	function initPatterns() {
		patterns = [
			{c : 0, g : [0, 1, 2, 3, 4, 5], h : 2, flip : true},
			{c : 0, g : [1, 2, 3, 4, 5, 6], h : 1, flip : true},
			{c : 0, g : [1, 2, 0, 4, 5, 6], h : 1, flip : true},
			{c : 0, g : [2, 3, 4, 5, 6, 7], h : 0, flip : true},
			{c : 0, g : [3, 2, 1, 1, 2, 3], h : 4, flip : false},
			{c : 0, g : [0, 2, 1, 1, 2, 0], h : 5, flip : false},
			{c : 0, g : [0, 2, 2, 1, 0, 0], h : 5, flip : true},
			{c : 0, g : [0, 3, 3, 0, 0, 0], h : 4, flip : true},
			{c : 0, g : [0, 3, 2, 0, 2, 2], h : 4, flip : true},
			{c : 0, g : [0, 3, 3, 0, 1, 0], h : 4, flip : true},
			{c : 0, g : [0, 3, 3, 0, 2, 0], h : 4, flip : true},
			{c : 0, g : [0, 3, 3, 0, 1, 0], h : 4, flip : true},
			{c : 0, g : [0, 3, 2, 3, 0, 2], h : 4, flip : true},
			{c : 0, g : [3, 0, 4, 4, 0, 3], h : 3, flip : false},
			{c : 0, g : [3, 1, 4, 1, 2, 2], h : 3, flip : true},
			{c : 0, g : [0, 3, 0, 1, 1, 0], h : 4, flip : true},
			{c : 0, g : [1, 2, 1, 2, 1, 2], h : 5, flip : true},
			{c : 0, g : [2, 0, 2, 0, 2, 0], h : 4, flip : true},
			{c : 0, g : [3, 4, 1, 1, 4, 3], h : 3, flip : true},
			{c : 0, g : [3, 6, 2, 2, 5, 4], h : 1, flip : true},
			{c : 0, g : [4, 3, 4, 4, 2, 5], h : 2, flip : true},
			{c : 0, g : [5, 6, 3, 3, 3, 0], h : 1 ,flip : true},
			{c : 0, g : [7, 5, 3, 1, 0, 0], h : 0 ,flip : true},
			{c : 0, g : [6, 4, 2, 0, 0, 1], h : 1 ,flip : true},
		] ;
			
		for (p in patterns) {
			for (n in p.g)
				p.c += n ;
			
		}
	}
	
	
	override public function initStage(st : Stage) {
		stage = st ;
		digLevel = 0 ;
		initDigLevel(false) ;
	}
	
	
	override public function updateScore() {
		return staticScore ;
	}
	
	
	override public function getFinalLevel() {
		return curChainKnown ;
	}
	
	
	override public function checkFallEnd() : Bool {
		var res = stage.hasArtefact(_Block(0)) ;
		
		if (!res) { //no more Blocks : go to next Level
			Game.me.setStep(Mode) ;
			digObjects = stage.getAll() ;
			digStep = if (digObjects.length > 0) 0 else 2 ;
			if (digStep == 0)
				Game.me.sound.play("dynamite") ;

			var g = stage.nexts.pop() ;
			g.move(g.getNextPosX(), g.getNextPosY() + 100, false, callback(function(g : Group) {g.kill() ;}, g)) ;
		}
		
		return !res ;
	}
	
	
	override public function onGameOver() {
		if (saveLevelMax != null)
			level = saveLevelMax ;
	}
	
	
	function initDigLevel(?hide = true) {
		if (hide)
			newLevelObjects = new Array() ;
		
		var pattern = patterns[Std.random(patterns.length)] ;
		var h = 0 ;
		var d = 0 ;
		var nMax = 0 ;		
		
		if (digLevel > 2)
			d = Std.random(2) ; 
		
		if (pattern.h > 0) {
			h = Std.random(pattern.h) ;
			if (digLevel > 2 && digLevel < 4)
				h = Std.int(Math.min(h + Std.random(Std.int(pattern.h / 2)), pattern.h - d)) ;
				//h = Std.int(Math.max(h - Std.random(Std.int(pattern.h / 2)), 0)) ;
			else if (digLevel < 4)
				h = Std.int(Math.min(h + pattern.h / 2 + Std.random(Std.int(pattern.h / 2)), pattern.h - d)) ;
			else if (digLevel >= 4)
				h = pattern.h - Std.random(2) - d ;
		}
		
		var totalBlocks = pattern.c + Std.int((h + d / 2) * Stage.WIDTH) ;
		var bpc = BLOCKS_PERCENT[Std.int(Math.min(digLevel, BLOCKS_PERCENT.length - 1))] ;
		var percents = new Array() ;
		for (i in 0...bpc.length) {
			var p = {level : i, c : Std.int(totalBlocks / 100 * bpc[i])} ;
			if (p.c > 0)
				percents.push(p) ;
				//percents[i] = p ;
		}
		
		var rBlocks = new Array() ;
		while (percents.length > 0) {
			var p = percents[Std.random(percents.length)] ;
			
			rBlocks.push({b : p.level, r : null}) ;
			p.c-- ;
			if (p.c <= 0)
				percents.remove(p) ;
		}

		initRewards(rBlocks) ;
		
		if (pattern.flip && Std.random(2) == 0)
			pattern.g.reverse() ;
			
		for (x in 0...Stage.WIDTH) {
			var n = pattern.g[x] + h + Std.random(d + 1) * (Std.random(2) * 2 - 1) ;
			n = Std.int(Math.min(Math.max(0, n), Stage.LIMIT - 1)) ;
			
			if (n > nMax)
				nMax = n ;
			
			for (y in 0...n) {
				if (stage.grid[x][y] != null)
					continue ;
				
				var p = if (rBlocks.length > 0) rBlocks.shift() else {b : Std.random(4), r : null} ;
				var o : StageObject= null ;
				if (p.b != null)
					o = new artefact.DigBlock(p.b + 1, stage.dm, Stage.HEIGHT - y) ;
				else {
					o = new artefact.DigReward(p.r, stage.dm, Stage.HEIGHT - y) ;
				}
				o.place(x, y, Stage.X + x * Const.ELEMENT_SIZE, Const.HEIGHT - (Stage.BY + (y + 1) * Const.ELEMENT_SIZE) + (if (hide) STAGE_RECAL else 0)) ;
				
				if (hide)
					newLevelObjects.push({o : cast o, startY : o.omc.mc._y, endY : o.omc.mc._y - STAGE_RECAL}) ;
				
				stage.add(o) ;
			}
		}
		stage.forceXDepth() ;
	}
	
	
	function initRewards(blocks : Array<{b : Int, r : _ArtefactId}>) {
		var d = [0, 0, 0] ;
		switch(digLevel) {
			case 0 : 		d = [0, 2, 200] ;
			case 1 : 		d = [8, 10, 8] ;
			case 2 : 		d = [8, 10, 7] ;
			case 3, 4 : 	d = [8, 10 + Std.int(rewardCount / 4), 6] ;
			default : 	d = [8, 10 + Std.int(rewardCount / 4), 5] ;
		}

		var cMax = 1 ;
		while (cMax < 4) {
			var rand = Std.random(d[1] * cMax) ;
			//trace(rand + " # " + d[0] + " / " + (d[1] * cMax)) ;
			if (rand > d[0]) // no reward
				return ;
			
			var reward = getRandomReward(if (Std.random(d[2]) == 0) REWARDS else REWARDS.slice(0, 17)) ;
			
			var place = Std.random(blocks.length) ;
			while (blocks[place].b == null)
				place = Std.random(blocks.length) ;
			blocks[place].b = null ;
			blocks[place].r =  reward ;
			rewardCount++ ;
			
			cMax++ ;
		}
		
		
	}
	
	
	function getRandomReward(t) : _ArtefactId {
		return Const.randomObjectProbs(cast t).r ;
	}
	
	
	
	override public function loop() {
		if (digStep == null) {
			trace("dig step is null in loop mode") ;
			return ;
		}
				
		if (digStep < 4)
			stage.setShake(1, 1, true) ;
		
		
		switch (digStep) {
			case 0 :
				for (o in digObjects) {
					if (o.warm(8.0)) {
						o.effectTimer = null ;
						digStep = 1 ;
					}
				}

			case 1 :
				for (o in digObjects) {
					if (o.blink(/*5*/)) {
						o.effectTimer = null ;
						o.toDestroy(Flame(true), Std.random(4) * 0.2) ;
						digStep = 2 ;
					} 
				}
	
			case 2 :  
				if (!stage.destroy()) {
					digLevel++ ;
					initDigLevel() ;
					
					digObjects = stage.getAll() ;
					timer = 0 ;
					digStep = 3 ;
				}
				
			case 3 :
				timer = Math.min(timer + 3 * mt.Timer.tmod, 100) ;
				if (timer == 100) {
					timer = 0 ;
					digStep = 4 ;
					Game.me.sound.play("interface_out") ;
				}
				
			case 4 : 
				timer = Math.min(timer + 1.2 * mt.Timer.tmod, 100) ;
				var delta = anim.Anim.getValue(Quart(-1), timer / 100) ;
				for (o in newLevelObjects) {
					o.o.omc.mc._y = o.endY + (1 - delta) * (o.startY - o.endY) ;
				}
				
				if (timer == 100) {
					//stage.setShake(4, null, true) ;
					timer = 0 ;
					digStep = 5 ;
					saveLevelMax = level ;
					initLevel() ;
					stage.initNext() ;
				}
				
			case 5 : 
				digStep = null ;
				Game.me.setStep(Fall) ;
			
		}
		
	}
	
	
	
	
	
	
}