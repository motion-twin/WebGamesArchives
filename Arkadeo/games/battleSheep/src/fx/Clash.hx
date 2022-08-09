package fx ; 

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

import Game.Race ;
import Game.Coord ;




typedef LocalClash = {
	var coord : Coord ;
	var duration : Int ;
	var nextPart : Int ; 
	var avCoords : Array<Coord> ;
	var curClouds : Array<mt.fx.Part<DSprite>> ;
}


class Clash {

	static var DEFAULT_DURATION = 25 ;
	static var DEFAULT_SHAKE = 5 ;
	static var MIN_DIST = 15 ;

	var spot : Spot ;
	var nextShake : Int ;
	var lclashes : Array<LocalClash> ;


	public function new(s : Spot) {
		spot = s ;
		nextShake = DEFAULT_SHAKE ;
		lclashes = new Array() ;
	}


	public function touch(from : Coord) {
		for (lc in lclashes) {
			if (Game.dist(lc.coord, from) < MIN_DIST) {
				lc.duration = DEFAULT_DURATION ;
				return ;
			}
		}

		initLocal(from) ;
	}


	public function initLocal(from : Coord) {
		var lc : LocalClash = {	coord : from,
								duration : DEFAULT_DURATION,
								nextPart : 5 + Std.random(5),
								avCoords : [],
								curClouds : []
							} ;

		if (spot.size == 0)
			lc.coord = spot.getCoord() ;

		var c = {x : lc.coord.x - (lc.coord.x - spot.x) / 3, y : lc.coord.y - (lc.coord.y - spot.y) / 3} ;
		var md = 9 ; //dist min
		var delta = 12 ; //random


		lc.avCoords.push(c) ;
		lc.avCoords.push({x : c.x + md + Std.random(delta), y : c.y + md + Std.random(delta)}) ;
		lc.avCoords.push({x : c.x - md - Std.random(delta), y : c.y + md + Std.random(delta)}) ;
		lc.avCoords.push({x : c.x + md + Std.random(delta), y : c.y - md -  Std.random(delta)}) ;
		lc.avCoords.push({x : c.x - md - Std.random(delta), y : c.y - md - Std.random(delta)}) ;

		for (i in 0...3)
			makeCloud(lc) ;

		lclashes.push(lc) ;
	}


	public function makeCloud(lc : LocalClash) {
		if (lc.avCoords.length == 0)
			return ;

		var cc = lc.avCoords[Std.random( Std.int(Math.min(1, lc.avCoords.length - 1)))] ; //choose coord
		lc.avCoords.remove(cc) ;

		var cloud  = Game.me.tiles.getSpriteAnimated("cloud_" + Std.random(3), "cloud_anim") ;
		cloud.offsetAnimFrame() ;

		cloud.x = cc.x ; 
		cloud.y = cc.y ;

		switch(Std.random(3)) {
			case 0 : //nothing to do 
			case 1 :	cloud.scaleX = cloud.scaleY = 1.25 ;
			case 2 : cloud.scaleX = cloud.scaleY = 1.5 ;
		}

		
		Game.me.dm.add(cloud, Game.DP_FX) ;

		var p = new mt.fx.Part(cloud) ;
		p.timer = 25 + Std.random(15) ;
		p.fadeType = 1 ;


		p.onFinish = callback(function(l : LocalClash, pp : mt.fx.Part<DSprite>) {
			l.avCoords.push({x : pp.x, y : pp.y}) ;
			pp.root.destroy() ;
			l.curClouds.remove(pp) ;
		}, lc, p) ;

		lc.curClouds.push(p) ;
	}


	function addPart(lc : LocalClash) {
		var delta = 5 ;
		var sp : DSprite = null ;
		if (Std.random(5) == 0) {
			sp = Game.me.tiles.getSpriteAnimated("clash_" + Game.getSpriteName(spot.owner), "clash_anim", 1) ;
			//sp.offsetAnimFrame() ;
			sp.fl_killOnEndPlay = true ;
			delta = 0 ;

			/*var p = new mt.fx.Part(sp) ;
			p.fadeType = 1 ;
			p.fadeLimit = 5 ;
			p.timer = 20 + Std.random(20) ;*/

		} else {
			sp = Game.me.tiles.getSpriteAnimated("hit", "hit_anim", 1) ;
			sp.fl_killOnEndPlay = true ;

			switch(Std.random(3)) {
				case 0 : sp.scaleX = sp.scaleY = 1.25 ;
				case 1 : sp.scaleX = sp.scaleY = 1.5 ;
				case 2 : sp.scaleX = sp.scaleY = 2.0 ;
			}

		}

		Game.me.dm.add(sp, Game.DP_FX_2) ;

		var cloud = lc.curClouds[Std.random(lc.curClouds.length)] ;
		
		sp.x = cloud.x + Std.random(delta) * (Std.random(2)*2-1) ;
		sp.y = cloud.y + Std.random(delta) * (Std.random(2)*2-1) ;
		sp.rotation = Math.random() ;
		
		lc.nextPart = 10 + Std.random(10) ;
	}


	public function update() {
		var newCloudProb = [0, 20, 5, 1, 1, 1] ;

		for (lc in lclashes.copy()) {
			lc.duration-- ;


			if (lc.avCoords.length > 0 && Std.random(newCloudProb[lc.avCoords.length]) == 0)
				makeCloud(lc) ;


			lc.nextPart-- ;
			if (lc.nextPart <= 0)
				addPart(lc) ;


			if (lc.duration <= 0)
				lclashes.remove(lc) ;
		}


		nextShake-- ;
		if (nextShake <= 0) {
			spot.shakeAnimals() ;
			nextShake = DEFAULT_SHAKE ;
		}

		if (lclashes.length == 0)
			kill() ;

	}


	public function kill() {
		if (spot.clash == this)
			spot.clash = null ;
	}



}