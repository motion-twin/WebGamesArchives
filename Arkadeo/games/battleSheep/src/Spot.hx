import flash.display.Bitmap ;
import flash.display.BitmapData ;
import flash.display.MovieClip ;
import flash.display.Sprite ;
import flash.display.BlendMode ;
import flash.ui.Keyboard ;

import mt.bumdum9.Lib ;
using mt.bumdum9.MBut ;
import mt.bumdum9.Tools ;

import mt.deepnight.SpriteLib ;

import api.AKApi ;


import Game.Race ;
import Game.Coord ;

import Swarm.Animal ;


enum Building {
	Bunker ;
	Watch ;
	Fast ;
	Rage ;
	Plague ;
	MoreSex ;
	Slow ;
	Bonus ;

	Box ;
	TinyBox ;
}



typedef SpotAnimal = {
	var a : DSprite ; 
	var sh : DSprite ; 
	var c : Coord ;
	var jump : mt.fx.Fx ;
}


class Spot {

	public static var BUILDING_INFOS = [
		{id : "Bunker", dx : [0, -16, -12, -6], dy : [0, -4, -12, -12], da : [42, 20], minSize : 1, anim : false}, //Bunker
		{id : "Watch", dx : [0, -13, -10, -4], dy : [0, -22, -26, -26], da : [42, 20], minSize : 1, anim : false}, //Watch 
		{id : "Fast",  dx : [-15, -15, -12, -4], dy : [16, 16, 8, 6], da : [42, 23], minSize : 1, anim : false},	//Fast 
		{id : "Rage",  dx : [-11, -4, 0, 6], dy : [-12, -10, -12, -12], da : [31, 12], minSize : 0, anim : true},	//Rage 
		{id : "Plague",  dx : [-14, -7, -4, 4], dy : [-12, -12, -16, -16], da : [31, 12], minSize : 0, anim : true}, //Plague 
		{id : "MoreSex", dx : [0, -14, -12, -5], dy : [0, -4, -4, -4], da : [44, 20], minSize : 1, anim : true}, //moreSex 
		{id : "Slow", dx : [0, -15, -13, -6], dy : [0, 4, 4, 4], da : [44, 23], minSize : 1, anim : true}, //Slow 

		{id : "Bonus", dx : [-11, -4, 0, 6], dy : [0, 6, 0, 0], da : [31, 12], minSize : 0, anim : false}, //Bonus

		{id : "Box", dx : [0, -17, -13, -6], dy : [0, 9, 1, 1], da : [46, 23], minSize : 1, anim : false},
		{id : "TinyBox", dx : [-12, -4, -1, 6], dy : [9, 9, 2, 1], da : [35, 20], minSize : 0, anim : false},
	] ;


	static var LEAGUE_BUILDING_PROBS = [10, 10, 10, 10, 10, 10, 10, 1] ;


	static var SIZES = [{s : 32, dx : 0, dy : 10, fy : 19, sx : 2, sy : 16, 
						selx : -2, sely : 1, selfx : -2, selfy : 26,
						tselx : 1, tsely : -1, tselfx : 1, tselfy : 28},

						{s : 48, dx : -2, dy : 8, fy : 27, sx : 2, sy : 16,
						 selx : -2, sely : 1, selfx : -2, selfy : 33,
						 tselx : 1, tsely : -1, tselfx : 1, tselfy : 35},

						{s : 56, dx : -4, dy : 8, fy : 27, sx : -2, sy : 8, 
						selx : -2, sely : -3, selfx : -2, selfy : 33,
						tselx : 1, tsely : -5, tselfx : 1, tselfy : 35},

						{s : 72, dx : -4, dy : 8, fy : 35, sx : -2, sy : 8,
						 selx : -2, sely : -3, selfx : -2, selfy : 41,
						 tselx : 1, tsely : -5, tselfx : 1, tselfy : 43}
						] ;

	public static var BUILDING_RADIUS	= 160 ; //pixel
	
	public static var PLAGUE_COOLDOWN 	= 20 ; //frames

	public static var BUNKER_PC = 40 ;
	public static var RAGE_PC = 20 ;

	public static var DP_HITBOX = 0 ;
	public static var DP_SELECTION_BG = 1 ;
	public static var DP_FIELD = 2 ;
	public static var DP_ANIMALS = 3 ;
	public static var DP_FRONT = 6 ;
	public static var DP_SELECTION = 8 ;
	public static var DP_FX = 9 ;



	public var id : Int ;
	public var ldm : mt.DepthManager ;
	public var sp : Sprite ;
	var spBg : Sprite ;
	//sub sprites
	var sGround : Sprite ;
	var sShadow : Sprite ;
	public var sField : Sprite ;
	var sFence : Sprite ; 

	public var hitBox : Sprite ;
	public var clickBox : Sprite ;

	var sSelect : {bg : Sprite, fg : Sprite, line : Array<Sprite>} ;


	public var building : Building ;
	public var hiddenBuilding : Building ;
	public var sBld : DSprite ;

	public var owner : Race ;
	public var ennemy : Bool ;

	public var bonusLeague : mt.flash.Volatile<Int> ;


	public var curSwarmed : Bool ;
	public var clash : fx.Clash ;

	public var curPop : mt.flash.Volatile<Int> ;
	var popField : {>MC, _text : TF} ;
	var popFx : {shake : mt.fx.Fx, grow : mt.fx.Fx } ;
	var spBonus : SP ;

	var waitPop : mt.flash.Volatile<Int> ;

	public var size : mt.flash.Volatile<Int> ;
	public var x : mt.flash.Volatile<Int> ;
	public var y : mt.flash.Volatile<Int> ;


	public var animals : Array<SpotAnimal> ;
	public var leftPlaces : Array<Int> ;

	public var waitPlague : mt.flash.Volatile<Int> ;
	var plaguables : Array<{s : Swarm, a : Int}> ;



	public function new(i : Int, sz : Int) {
		id = i + 1 ;
		size = sz ;
		ennemy = false ;
		animals = new Array() ;
		leftPlaces = new Array() ;
		owner = None ;
		curSwarmed = false ;
		bonusLeague = 0 ;
		popFx = {shake : null, grow : null} ;

		waitPop = 0 ;

		initGround() ;

		sp = new Sprite() ;
		ldm = new mt.DepthManager(sp) ;

		sField = Game.me.tiles.getSprite("field_" + size) ; 
		sField.cacheAsBitmap = true ;
		ldm.add(sField, DP_FIELD) ;


		hitBox = new Sprite() ;
		hitBox.alpha = 0.0 ;
		var deltaHit = {x : 2, y : 4} ;
		var sz = getSize() ;
		var hx = sField.x - sz / 2 - deltaHit.x ;
		var hy = sField.y - sz / 2 - ((size < 2) ? -1 * deltaHit.y / 2 : deltaHit.y / 2 ) ;
		
		hitBox.graphics.beginFill(0xFFFFFF) ;
		hitBox.graphics.moveTo(hx ,hy) ;
		hitBox.graphics.lineTo(hx + sz + 2 * deltaHit.x, hy) ;
		hitBox.graphics.lineTo(hx + sz + 2 * deltaHit.x, hy + sz + 2 * deltaHit.y) ;
		hitBox.graphics.lineTo(hx, hy + sz + 2 * deltaHit.y) ;
		hitBox.graphics.lineTo(hx, hy) ;
		hitBox.graphics.endFill() ;

		ldm.add(hitBox, DP_HITBOX) ;

		clickBox = new Sprite() ;
		clickBox.alpha = 0.0 ;
		clickBox.graphics.beginFill(0xFFFFFF) ;
		clickBox.graphics.moveTo(hx ,hy) ;
		clickBox.graphics.lineTo(hx + sz + 2 * deltaHit.x, hy) ;
		clickBox.graphics.lineTo(hx + sz + 2 * deltaHit.x, hy + sz + 2 * deltaHit.y) ;
		clickBox.graphics.lineTo(hx, hy + sz + 2 * deltaHit.y) ;
		clickBox.graphics.lineTo(hx, hy) ;
		clickBox.graphics.endFill() ;

		Game.me.dm.add(clickBox, Game.DP_CLICK) ;

		sFence = Game.me.tiles.getSprite("fence_" + size) ; 
		sFence.y = SIZES[size].fy ;
		sFence.cacheAsBitmap = true ;
		ldm.add(sFence, DP_FRONT) ;	

		Game.me.dm.add(sp, Game.DP_WARFIELD) ;

		if (Type.enumEq(Game.me.mode, GM_PROGRESSION))
			popField = cast new gfx.Pop3() ;
		else 
			popField = cast new gfx.Pop4() ;

		Game.me.dm.add(popField, Game.DP_POP) ;

		clickBox.onMouseDown(callback(Game.me.spotDown, id)) ;
		clickBox.onMouseUp(callback(Game.me.spotUp, id)) ;
		clickBox.onOver(callback(onRollOver, this)) ;
		clickBox.onOut(callback(onRollOut, this)) ;

		setPop(0) ;

		Game.me.ia.initSpot(this) ;
	}


	public function initBonus() {
		spBonus = Game.me.tiles.getSprite("bonusHead") ;
		Game.me.dm.add(spBonus, Game.DP_POP) ;
		bonusLeague = curPop ;
		placeBonus() ;
	}


	public function updateBonusLeague(enn : Bool, ?forceRemove = false) {
		if (bonusLeague <= 0)
			return ;

		var removeIt = forceRemove ;
		if (!removeIt) {
			if (enn) {
				if (isNeutral() && curPop > 0)
					bonusLeague = curPop ;
				else 
					removeIt = true ; 
			} else
				removeIt = true ;
		}

		if (!removeIt)
			return ;

		bonusLeague = 0 ;

		if (spBonus == null)
			return ;
		var b = new mt.fx.Vanish(spBonus) ;
		b.setFadeScale(1, 1) ;
		/*b.onFinish = callback(function(sp : Sprite) {
						sp.parent.removeChild(sp) ;
					}, spBonus) ;*/
		spBonus = null ;

	}


	public function isNeutral() {
		return Type.enumEq(owner, None) ;
	}


	public function update() {
		if (isNeutral()) 
			return ;

		if (!curSwarmed && !hasBuilding(Plague)) {
			waitPop-- ;
			if (waitPop <= 0 && curPop < 999) {
				waitPop = getPopCooldown() ;
				addPop(1) ;
			}
		}


		if (clash != null)
			clash.update() ;



		if (plaguables != null) {
			if (plaguables.length > 0) {
				plaguables[Game.me.random(plaguables.length)].s.killFromPlague(this) ;
				waitPlague = Spot.PLAGUE_COOLDOWN ;
			}

			waitPlague-- ;
			plaguables = new Array() ;
		}
	}


	public function addToPlague(s : Swarm, ?n = 1 ) {
		for (p in plaguables) {
			if (p.s != s)
				continue ;
			p.a += n ;
			return ;
		}
		plaguables.push({s : s, a : n}) ;
	}



	public function canBeBuilded(?byIA = false) : Bool {
		if (!Game.me.isProgression())
			return false ;

		if (!byIA && (isNeutral() || ennemy))
			return false ;

		if (hiddenBuilding == null)
			return false ;

		return Type.enumIndex(hiddenBuilding) > 6 ;
	}



	public function shakeAnimals() {

		for (a in animals) {
			if (a.a == null)
				continue ;

			switch(Std.random(3)) {
				case 0 : //nothing to do 
				case 1 : jump(a) ;
				case 2 : new mt.fx.Shake(a.a, 1, 1) ;
			}
		}
	}


	public function initBuilding(?fb : Building, ?hide = false) {
		if (sBld != null)
			sBld.parent.removeChild(sBld) ;

		var choice = (fb != null) ? Type.enumIndex(fb) : Game.randomProbs(LEAGUE_BUILDING_PROBS) ;
		while (size < BUILDING_INFOS[choice].minSize)
			choice = Game.randomProbs(LEAGUE_BUILDING_PROBS) ;

		//### DEBUG
		//choice = (Std.random(1) == 0) ? 4 : 6 ;
		//###

		if (hide) {
			hiddenBuilding = Type.createEnumIndex(Building, choice) ;
			choice = 9 ;
		}

		var bInfos = BUILDING_INFOS[choice] ;

		building = Type.createEnumIndex(Building, choice) ;
		var bName = "bld_" + bInfos.id ;

		
		if (bInfos.anim) {
			sBld = Game.me.tiles.getSpriteAnimated(bName, bName + "_anim") ;
			sBld.offsetAnimFrame() ;
		} else {
			sBld = Game.me.tiles.getSprite(bName) ;
			sBld.cacheAsBitmap = true ;
		}
		

		sBld.x = bInfos.dx[Std.int(size)] + sBld.width / 2 ; 
		sBld.y = -sp.height / 2  + bInfos.dy[Std.int(size)] + sBld.height / 2 ;
		ldm.add(sBld, DP_ANIMALS) ;


		if (choice == Type.enumIndex(Plague) ) { //PLAGUE
			plaguables = new Array() ;
			waitPlague = Spot.PLAGUE_COOLDOWN ;
			Game.me.updatePlagueFx(this) ;
		}


		if (choice == Type.enumIndex(Slow) ) //SLOW
			Game.me.updateSlowFx(this) ;

		//### DEBUG
		/*
		if (choice == Type.enumIndex(Slow) ) { //SLOW
			var cc = new Sprite() ; 
			cc.graphics.beginFill(0xCCCC) ;
			cc.graphics.drawCircle(0, 0, Spot.BUILDING_RADIUS) ;
			cc.graphics.endFill() ;

			cc.alpha = 0.15 ;

			sp.addChild(cc) ;

		}*/
	}



	public function revealBuilding(?forceBld : Building) {
		if (sBld == null)	
			return ;

		var sBox = sBld ; 
		sBld = null ;

		initBuilding((forceBld != null) ? forceBld : hiddenBuilding) ;
		Game.me.updateWatch() ;
		hiddenBuilding = null ;

		sBld.alpha = 0.0 ;

		var shk = new mt.fx.Shake(sBox, 2, 2) ;
		shk.onFinish = callback(function(s : Spot, box : Sprite) {

			var center = {	x : box.x + box.width / 2,
							y : box.y + box.height / 2} ;

			for (p in mt.bumdum9.Tools.slice(box, 4 + Std.random(2))) {
				Game.me.dm.add(p.root, Game.DP_FX) ;
				p.timer = 20 + Std.random(10) ;
				p.frict = 0.90 ;
				p.fadeType = 1 ;
				
				var a = Math.atan2(p.y, p.x);
				var dist = Math.sqrt(p.x * p.x + p.y * p.y);
				p.vx = Math.cos(a) * dist * 0.15;
				p.vy = Math.sin(a) * dist * 0.15 ;

				p.vr = Std.random(5) * ( Std.random(2) * 2 - 1) ;
				
				// POS
				p.x += x;
				p.y += y;
				p.updatePos() ;
			}

			var e = new mt.fx.ShockWave(20, 100, 0.075);
			e.curveIn(0.5);
			e.setPos(center.x, center.y) ;
			ldm.add(e.root, DP_SELECTION) ;
			
			e.root.blendMode = flash.display.BlendMode.ADD ;
			box.parent.removeChild(box) ;


			var speed = 0.05 ;
			s.sBld.alpha = 1.0 ;
			Col.setPercentColor(s.sBld, 1, 0xFFFFFF) ;

			var spw = new mt.fx.Spawn(s.sBld, speed, true, false) ;
			spw.curveIn(3) ;

			var fb = new mt.fx.FadeBack(s.sBld, speed / 2) ;

			s.recalAnimals() ;


		}, this, sBox) ;

	}


	public function addPop(n : Int, ?race : Race, ?from : Coord) {

		//trace("pre add " + curPop + " + " + n) ;

		if (race == null) {
			curPop = Std.int(Math.max(0, curPop + n )) ;
			if (n > 0)
				insertAnimals(n) ;
			else {
				if (curPop < animals.length)
					killAnimals( Std.int(Math.min(Math.abs(n), animals.length - curPop)) ) ;
			}
		} else {
			if (isNeutral()) {
				var tn = Std.int(Math.min(curPop, n)) ;

				addLeaguePoints(tn, race) ;

				curPop = Std.int(Math.max(0, curPop - tn )) ;

				if (curPop <= 0) {
					checkLeagueBonusPoints(race) ;
					setOwner(race) ;
					if (n - tn > 0) {
						curPop += n - tn ;
						insertAnimals(curPop) ;
					}
				}
			} else {
				if (Type.enumEq(race, owner)) {
					curPop = Std.int(Math.max(0, curPop + n )) ;
					if (n > 0)
						insertAnimals(n) ;
					else {
						if (curPop < animals.length)
							killAnimals(Std.int(Math.min(Math.abs(n), animals.length - curPop))) ; 
					}
				} else { //fight
					setSwarmed(true, from) ;
					var tn = Std.int(Math.min(curPop, n)) ;
					curPop = Std.int(Math.max(0, curPop - tn )) ;

					if (curPop < animals.length)
						killAnimals(Std.int(Math.min(Math.abs(n), animals.length - curPop))) ; 

					if (curPop <= 0) {
						setOwner(race) ;
						if (n - tn > 0) {
							curPop += n - tn ;
							insertAnimals(curPop) ;
						}
					}
				}
			}

			if (popFx.shake == null) {
				popFx.shake = new mt.fx.Shake(popField, 1, 2) ;
				popField.scaleX = 1.5 ;
				popField.scaleY = popField.scaleX ;
				popFx.shake.onFinish = callback(function(s : Spot) { s.popFx.shake = null ; } , this) ;

				if (popFx.grow != null) {
					popFx.grow.kill() ;
					popFx.grow = null ;
				}

			}
		}

	//	trace("### POST ADD : " + curPop + " # animals : " + (animals.length - leftPlaces.length) + "/" + animals.length + " # leftPlaces : " + leftPlaces.length ) ;

		showPop() ;
	}



	function addLeaguePoints(p : Int, race : Race) {
		if (!Game.me.isPlaying() || !Type.enumEq(Game.me.mode, GM_LEAGUE))
			return ;

		if (!isNeutral() || Game.me.isEnnemy(race))
			return ;

		Game.me.addLeagueScore(p  * Game.LEAGUE_POP_POINT.get()) ;
	}

	function checkLeagueBonusPoints(race : Race) {
		if (bonusLeague <= 0)
			return ;

		if (!Game.me.isPlaying() || !Type.enumEq(Game.me.mode, GM_LEAGUE))
			return ;

		if (!isNeutral() || Game.me.isEnnemy(race)) {
			updateBonusLeague(Game.me.isEnnemy(race), true) ;
			return ;
		}

		var value = bonusLeague  * Game.LEAGUE_BONUS_POINT.get() ;
		Game.me.addLeagueScore(value) ;

		var up = new mt.fx.Tween(spBonus, spBonus.x, spBonus.y - 20) ;
		up.curveInOut() ;

		up.onFinish = callback(function(sp : Sprite) {
						var b = new mt.fx.Blink(sp, 27, 3, 3) ;
						b.onFinish = callback(function(spp : Sprite) {
								spp.parent.removeChild(spp) ;
							}, sp) ;

					}, spBonus) ;

		var bonusInfo : {>MC, _text : TF} = cast new gfx.Pop4() ;
		//Game.me.dm.add(bonusInfo, Game.DP_POP) ;
		spBonus.addChild(bonusInfo) ;
		bonusInfo.x = 25 ;
		//bonusInfo.y = spBonus.y ;
		bonusInfo._text.text = "+" + Std.string(value) ;
		new mt.fx.Flash(spBonus) ;


		spBonus = null ;

	}


	public function setSwarmed(b = true, ?from : Coord) {
		curSwarmed = b ;
		if (!curSwarmed) {
			if (clash != null)
				clash.kill() ;
		} else {
			if (clash == null)
				clash = new fx.Clash(this) ;
			clash.touch(from) ;
		}
	}


	public function hasBuilding(b : Building) {
		return building != null && Type.enumEq(b, building) ;
	}


	public function hasActiveBuilding(b : Building, with : Race) {
		if (!hasBuilding(b))
			return false ;
		return !isNeutral() && !Type.enumEq(with, owner) ;

	}


	public function unGrowPop() {
		if (popField.scaleX == 1.0 || popFx.grow != null)
			return ;

		curSwarmed = false ;

		popFx.grow = new mt.fx.Grow(popField) ;
		popFx.grow.onFinish = callback(function(s : Spot) { s.popFx.grow = null ; } , this) ;
	}


	public function showPop(?forceVisility : Bool) {
		popField._text.text = Std.string(curPop) ;

		if (forceVisility == null)
			return ;
		popField.alpha = (forceVisility) ? 1.0 : 0.0 ;

	}

	public function setPop(p : Int) {
		curPop = p ;
		showPop() ;

		if (Type.enumEq(owner, None))
			return ;
		killAnimals() ;
		insertAnimals(curPop, false) ;
	}


	public function setPos(px : Int, py : Int ) {
		x = px ;
		y = py ;
		spBg.x = px ;
		spBg.y = py ;
		sp.x = px ;
		sp.y = py ;

		clickBox.x = px ;
		clickBox.y = py ;

		initPopField() ;
	}	


	public function initPopField() {
		showPop() ;
		popField.x = x ;
		popField.y = y - SIZES[size].s / 2 ;		

		if (spBonus != null)
			placeBonus() ;
	}


	function placeBonus() {
		spBonus.x = popField.x + ((curPop > 9) ? 18 : 15) ;
		spBonus.y = popField.y ;
	}


	public function initGround() {
		//clear
		if (sShadow != null && sShadow.parent != null)
			sShadow.parent.removeChild(sShadow) ;
		if (sGround != null && sGround.parent != null)
			sGround.parent.removeChild(sGround) ;
		if (spBg != null && spBg.parent != null)
			spBg.parent.removeChild(spBg) ;

		spBg = new Sprite() ;
		sGround = Game.me.tiles.getSprite("ground_" + size + "_" + Game.getSpriteName(owner, true)) ;
		sGround.x += SIZES[size].dx ;
		sGround.y += SIZES[size].dy ;
		sGround.cacheAsBitmap = true ;
		spBg.addChild(sGround) ;

		sShadow = Game.me.tiles.getSprite("shadow_" + size) ;
		sShadow.x += SIZES[size].sx ;
		sShadow.y += SIZES[size].sy ;
		sShadow.cacheAsBitmap = true ;
		spBg.addChild(sShadow) ;

		
		if (sp != null) {
			spBg.x = x ;
			spBg.y = y ;
		}

		Game.me.dm.add(spBg, Game.DP_SPOT_BG) ;
	}



	public function setOwner(o : Race) {

		
		Game.me.ia.onNewOwner(this, o) ;
		owner = o ;
		ennemy = Game.me.isEnnemy(owner) ;

		if (Game.me.isProgression())
			Game.me.setProgressionScore() ;


		if (hiddenBuilding != null) {
			switch(Game.me.mode) {
				case GM_PROGRESSION : //nothing to do
					
				case GM_LEAGUE : 
					revealBuilding() ;

				default : // mssion, clan ???? 
			}
		}


		/*if (ennemy) 
			sp.onClick(callback(Game.me.selectTo, this)) ;
		else
			sp.onClick(callback(Game.me.selectFrom, this)) ;*/


		initGround() ;

		var lastScale = popField.scaleX ;
		popField.parent.removeChild(popField) ;
		popField = (ennemy) ? cast new gfx.Pop1() : cast new gfx.Pop2() ;
		popField.scaleX = lastScale ;
		popField.scaleY = lastScale ;
		Game.me.dm.add(popField, Game.DP_POP) ;
		initPopField() ;

		popField.alpha = (ennemy) ? 0.0 : 1.0 ;

		killAnimals() ; 
		//insertAnimals(curPop) ;

		waitPop = getPopCooldown() ;

		//if (building != null)
		Game.me.updateWatch() ;
	}





	function killAnimals(?n : Int, ?noAnim = false) {
		//trace("killAnimals on " + id + " => " + n) ;

		var tokill = (n == null) ? 9999 : Math.abs(n) ;

		var avIdx = [] ;
		for (i in 0...animals.length) {
			if (animals[i].a != null)
				avIdx.push(i) ;
		}

		while (avIdx.length > 0 && tokill > 0) {
			var idx = Std.random(animals.length) ;

			var idx = avIdx[Std.random(avIdx.length)] ;
			avIdx.remove(idx) ;
			var a = animals[idx] ;

			var fKill = function(aa : DSprite, ash : DSprite) {
				aa.destroy() ;
				ash.destroy() ;
			}

			if (!noAnim) {
				var s = new mt.fx.Spawn(a.a, 0.2, false, true) ;
				var s2 = new mt.fx.Spawn(a.sh, 0.2, true, true) ;
				s.reverse() ;
				s2.reverse() ;
				s2.onFinish = callback(fKill, a.a, a.sh) ;
				//fKill(a) ;

			} else 
				fKill(a.a, a.sh) ;
			
			a.a = null ;
			a.sh = null ;
			if (a.jump != null)
				a.jump.kill() ;

			leftPlaces.push(idx) ;
			tokill-- ;

		}
	}


	function insertAnimals(n : Int, ?noAnim = false) {

		var spn = Game.getSpriteName(owner) ;
		if (spn == null)
			return ;

		if (leftPlaces.length == 0)
			return ;

		while(leftPlaces.length > 0 && n > 0) {

			var idx = leftPlaces[Std.random(leftPlaces.length)] ;
			var a = animals[idx] ;

			if (a.a != null)
				continue ;

			a.a = Game.me.tiles.getSprite(spn) ;
			if (Std.random(2) == 0)
				a.a.scaleX = -1 ;

			a.a.x = a.c.x ;
			a.a.y = a.c.y ;
			ldm.add(a.a, DP_ANIMALS) ;

			a.sh = Game.me.tiles.getSprite("shadow_" + spn) ;
			a.sh.x = a.c.x ;
			a.sh.y = a.c.y + 1 ;
			spBg.addChild(a.sh) ;

			if (!noAnim) {
				var blob = new mt.fx.Blob(a.a) ;
				blob.onFinish = callback(function(sp : Sprite) { if (sp != null) sp.cacheAsBitmap = true ; }, a.a) ; 
			} else 
				a.a.cacheAsBitmap = true ;
			n-- ;
			leftPlaces.remove(idx) ;
		}

		ldm.ysort(DP_ANIMALS) ;
	}


	public function initAnimals() {
		var bInfos = (building != null) ? BUILDING_INFOS[Type.enumIndex(building)] : null ;
		var dBorder = {x : 8 , y : 4 } ;

		var nl = size + 2 + Game.me.random(3) ;
		var from = {x : -1 * (getSize() / 2) + dBorder.x, y : -1 * (getSize() / 2) + 10 } ;

		var line = from.y ;
		var dy = ( getSize() - (dBorder.y * 2)) / nl ;
		for (i in 0...nl) {
			var n = size + 2 + Game.me.random(4) ;
			var pos = new Array() ;
			var w = from.x ;
			var dx = (getSize() - (dBorder.x * 2)) / n ;

			/*if (bInfos != null)
				trace("######"); */

			for (j in 0...n) {
				var x = Std.int(Math.round(w + Game.me.random( Std.int(Math.max(2, dx * 2 / 3 )) ) )) ;
				var y = Std.int(Math.round(line + Game.me.random( Std.int(Math.max(2, dy / 2)) ) )) ;


				y = Std.int(Math.min(y, getSize() / 2 - dBorder.y )) ;

				if (bInfos != null) {
					if (y < from.y + bInfos.da[1] && x > getSize() / 2 - bInfos.da[0])
						continue ;
				}

				var p : Coord = {x : x, y : y} ;
				if (Game.me.random(2) == 0) pos.push(p) else pos.unshift(p) ;

				/*if (bInfos != null) {
					trace("==> " + w + ", " + line) ;
					trace(getSize() + " # " + p) ;
				}*/

				w += dx ;
			}

			for (p in pos) {
				leftPlaces.push(animals.length) ;
				animals.push({a : null, sh : null, c : p, jump : null}) ;
			}

			line += dy ;
		}

		ldm.ysort(DP_ANIMALS) ;
	}


	public function recalAnimals() {
		if (building == null)
			return ;

		if (animals.length == 0) {
			initAnimals() ;
			return ;
		}

		var dBorder = {x : 8 , y : 4 } ;
		var nl = size + 2 + Game.me.random(3) ;
		var from = {x : -1 * (getSize() / 2) + dBorder.x, y : -1 * (getSize() / 2) + 10 } ;
		var bInfos = BUILDING_INFOS[Type.enumIndex(building)] ;

		var test = {	x : getSize() / 2 - bInfos.da[0], 
						y : from.y + bInfos.da[1]} ;

		for (a in animals) {

			if (a.c.x <= test.x || a.c.y >= test.y)
				continue ; //nothing to do

			var to = {x : a.c.x, y : a.c.y} ;
			if (a.c.y <= test.y - bInfos.da[1] / 4)  //recal X only
				to.x = from.x + (test.x - from.x) / 2 + Std.random(Std.int((test.x - from.x) / 4)) ;
			else if (a.c.x > test.x + bInfos.da[0] / 4)  //recal Y only
				to.y = test.y + Std.random(Std.int(getSize() / 2 - dBorder.y - test.y / 2)) ;
			 else { //recal both X and Y
			 	to.x = from.x + (test.x - from.x) / 2 + Std.random(Std.int((test.x - from.x) / 4)) ;
			 	to.y = test.y + Std.random(Std.int(getSize() / 2 - dBorder.y  - test.y / 2)) ;
			}

			a.c = to ;

			if (a.a == null)
				continue ;

			a.a.x = to.x ;
			a.a.y = to.y ;

			a.sh.x = to.x ;
			a.sh.y = to.y + 1 ;


			/*var tw = new mt.fx.Tween(a.a, to.x, to.y) ;
			tw.curveIn(2) ;
			tw.reverse() ;
			var stw = new mt.fx.Tween(a.sh, to.x, to.y + 1) ;
			stw.curveIn(2) ;
			stw.reverse() ;*/

		}

		ldm.ysort(DP_ANIMALS) ;
	}


	public function getSendPop() {
		if (curPop < 2)
			return 0 ;

		return Std.int(Math.max(1, Math.floor(curPop / 2))) ;
	}


	public function select() {
		if (sSelect != null)
			unselect() ;

		drawSelection() ;

		jumpAll() ;

	}


	public function jumpAll() {
		for (a in animals) {
			if (a.a != null && Std.random(8) > 0)
				jump(a) ;
		}
	}

	public function drawSelection(?dy = 0, ?alpha = 1.0) {
		if (sSelect != null)
			unselect() ;

		sSelect = {	bg : Game.me.tiles.getSprite("select_" + size),
					fg : Game.me.tiles.getSprite("front_select_" + size),
					line : []} ;
		sSelect.bg.x = SIZES[size].selx ;
		sSelect.bg.y = SIZES[size].sely + dy ;
		sSelect.fg.x = SIZES[size].selfx ;
		sSelect.fg.y = SIZES[size].selfy + dy ;

		sSelect.bg.alpha = alpha ;
		sSelect.fg.alpha = alpha ;
		
		ldm.add(sSelect.bg, DP_SELECTION_BG) ;
		ldm.add(sSelect.fg, DP_SELECTION) ;
	}


	public function drawTargetSelection(?dy = 0, ?alpha = 1.0) {
		if (sSelect != null)
			unselect() ;

		sSelect = {	bg : Game.me.tiles.getSprite("target_select_" + size),
					fg : Game.me.tiles.getSprite("target_front_select_" + size),
					line : []} ;
		sSelect.bg.x = SIZES[size].tselx ;
		sSelect.bg.y = SIZES[size].tsely + dy ;
		sSelect.fg.x = SIZES[size].tselfx ;
		sSelect.fg.y = SIZES[size].tselfy + dy ;

		sSelect.bg.alpha = alpha ;
		sSelect.fg.alpha = alpha ;
		
		ldm.add(sSelect.bg, DP_SELECTION_BG) ;
		ldm.add(sSelect.fg, DP_SELECTION) ;

		var from = Game.me.selectedSpot ;
		if (from == null)
			return ;

		var line = new Sprite() ;

		line.blendMode = BlendMode.LAYER ;

		var toLine = [	{c : 0x000000, dy : 9, dx : -3, a : 0.3},
						{c : 0x47b5b5, dy : 6, dx : 0, a : 1.0},
						{c : 0x3da1a1, dy : 3, dx : 0, a : 1.0},
						{c : 0x348585, dy : 1, dx : 0, a : 1.0},
						{c : 0xFFFFFF, dy : 0,dx : 0, a : 1.0} ] ;

		for (lInfo in toLine) {
			line.graphics.lineStyle(6.0, lInfo.c, lInfo.a, true, null, flash.display.CapsStyle.SQUARE) ;
			line.graphics.moveTo(from.x + lInfo.dx, from.y + lInfo.dy) ;
			line.graphics.lineTo(this.x + lInfo.dx, this.y + lInfo.dy) ;
		}

		var top = (from.y < this.y) ? from : this ;

		var Y = Math.abs(from.y - this.y) ;
		var X = Math.abs(from.x - this.x) ;

		for (spot in [from, this]) {
			var m1 = new Sprite() ;
			var m1Size = getMaskInfo(spot.size) ;

			m1.graphics.beginFill(0xCCCC) ;
			m1.graphics.drawRect(0, 0, m1Size.w, m1Size.h) ;
			m1.graphics.endFill() ;

			m1.alpha = 1.0 ;

			m1.x = Std.int(Math.round(spot.x - m1.width / 2)) ;
			m1.y = Std.int(Math.round(spot.y - m1.height / 2)) + m1Size.dy ; 

			m1.blendMode = ERASE ;
			line.addChild(m1) ;

			if (spot.id != top.id) 
				continue ;
			var tTan = X / Y ;
			var aTan = Math.atan(tTan) ;
			var dTan = aTan * 180 / Math.PI ;

			/**trace("X :" + X + ", Y : " + Y);
			trace("tan : " + tTan + " # aTan : " + aTan + " # degré : " + dTan) ;*/

			var m2 = new Sprite() ;
			m2.alpha = 1.0 ;

			if (dTan < 45) {
				m2.graphics.beginFill(0x555555) ;
				m2.graphics.drawRect(0, 0, 25, 6) ;
				m2.graphics.endFill() ;

				var my = Std.int(Math.round( m1.height / 2)) + m1Size.dy ;
				var mx = ((top.id != from.id) ? from.x - this.x : this.x - from.x) / (Y / my) ;

				m2.y = m1.y + m1.height ;

				var dx = 3 / Math.cos(aTan) ;

				if (mx < 0)
					m2.x = top.x + mx + dx ;
				else
					m2.x = top.x + mx - dx - m2.width ;

			} else {
				m2.graphics.beginFill(0xAAAA) ;
				m2.graphics.drawRect(0, 0, m1Size.w, 6) ;
				m2.graphics.endFill() ;

				m2.x = m1.x ;
				m2.y = m1.y + m1.height ;
			}
			m2.blendMode = ERASE ;
			line.addChild(m2) ;

		}


		Game.me.dm.add(line, Game.DP_INTER) ;
		//Game.me.dm.ysort(Game.DP_WARFIELD) ;
		sSelect.line.push(line) ;



		


	}



	function jump(a : SpotAnimal) {
		
		if (a.jump != null)
			return ;
		var upY = 1 + Std.random(7) ;
		a.jump = new mt.fx.Tween(a.a, a.a.x, a.a.y - upY, 0.13 + Std.random(4) / 100) ;
		a.jump.curveIn(2) ;
		a.jump.reverse() ;
		a.jump.onFinish = function() {
									if (a.a == null) {
										a.jump = null ;
										return ;
									}
									a.jump = new mt.fx.Tween(a.a, a.a.x, a.a.y, 0.13 + Std.random(4) / 100) ;
									a.jump.curveIn(2) ; 
									a.jump.onFinish = callback(function(aa) {aa.jump = null ;}, a) ;
								} ;

	}


	public static function onRollOver(sp : Spot) {
		if (AKApi.isReplay())
			return ;

		if (sp.isNeutral() || sp.ennemy) {
			if (Game.me.selectedSpot != null) {
				sp.drawTargetSelection() ;
			}

		} else {
			if (Game.me.selectedSpot == null) {
				sp.drawSelection(-6, 0.5) ;
			} else {
				if (sp != Game.me.selectedSpot) 
					sp.drawTargetSelection() ;
			}
		}

		if (sp.building != null) {
			if ( !(sp == Game.me.selectedSpot && sp.canBeBuilded()))
				Game.me.showBuildingInfo(sp) ;
		}

	}


	public static function onRollOut(sp : Spot) {
		if (sp.isNeutral() || sp.ennemy) {
			sp.unselect() ;
		} else {

			if (Game.me.selectedSpot != sp)
				sp.unselect() ;
		}

		if (sp.building != null) {
			if (Game.me.selectedSpot != null && Game.me.selectedSpot.canBeBuilded()) {
				if (Game.me.selectedSpot != sp)
					Game.me.showBuildingList(sp) ;
			} else 
				Game.me.hideBuildingInfo() ;

		}

	}



	public function unselect() {
		if (sSelect != null) {
			sSelect.bg.parent.removeChild(sSelect.bg) ;
			sSelect.fg.parent.removeChild(sSelect.fg) ;
			if (sSelect.line.length > 0)
				for (l in sSelect.line)
					l.parent.removeChild(l) ;			
			sSelect = null ;
		}
	}


	public function getBoundingBox() {


		return {xMin : x - hitBox.width / 2,
				yMin : y - hitBox.height / 2,
				xMax : x + hitBox.width / 2,
				yMax : y + hitBox.height / 2
				} ;
	}

	public function getSize() {
		return SIZES[size].s ;
	}

	public function getCoord() : Coord {
		return {x : x, y : y} ;
	}


	public function getPopCooldown() : Int {

		var c = switch(Std.int(size)) {
			case 0 : 40 ;
			case 1 : 30 ;
			case 2 : 20 ;
			case 3 : 10 ;
			default : 1000 ;
		}

		if (hasBuilding(MoreSex))
			c = Std.int(Math.round( c * 3 / 4)) ;

		return c ;
	}


	public static function getMaskInfo(s : Int) {
		return switch(Std.int(s)) {
					case 0 : {w : 44, h : 41, dy : 3} ;
					case 1 : {w : 60, h : 56, dy : 3} ;
					case 2 : {w : 68, h : 64, dy : -1} ;
					case 3 : {w : 84, h : 80, dy : -1} ;
				} ;
	}


	public static function getInitRadius(s : Int) : Int  {
		return Std.int(Math.round(
							switch(s) {
								case 0 : 3.5 * 16 / 2 ;
								case 1 : 4.2 * 16 / 2 ;
								case 2 : 5 * 16 / 2 ;
								case 3 : 5.5 * 16 / 2;
							})) ;
	}

	public static function getMinDist(s0 : Int, s1 : Int) : Int {
		return Std.int(Math.round(Game.MIN_DIST + SIZES[s0].s / 2 + SIZES[s1].s / 2)) ;
	}


	public function kill() {

	}



}