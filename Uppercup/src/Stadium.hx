import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.BlendMode;
import mt.deepnight.Color;
import mt.deepnight.Lib;
import mt.MLib;

import Const;
import TeamInfos;


class Stadium {
	var game				: m.Game;

	public var bg			: Bitmap;
	public var goals		: Array<{rect:{x:Int,y:Int,w:Int,h:Int}, bmp:Bitmap}>;
	public var splatters	: Bitmap;
	var perlin				: BitmapData;
	var waterPerlin			: Null<BitmapData>;
	var gluePerlin			: Null<BitmapData>;
	var snow				: Null<Bitmap>;
	public var hasWalls		: Bool;
	public var hasSideWarp	: Bool;
	//var snowFlattened		: Bool;
	//var snowCache			: Map<Int,Bool>;

	public var wid			: Int;
	public var hei			: Int;
	var pt0					: flash.geom.Point;

	public var colMap		: Array<Array<Float>>;


	public function new() {
		game = m.Game.ME;
		goals = [];
		hasWalls = false;
		hasSideWarp = game.oppTeam.hasPerk(_PSideWarp);
		//snowCache = new Map();
		//snowFlattened = false;
		pt0 = new flash.geom.Point();

		wid = Const.GRID*(Const.FWID+Const.FPADDING*2);
		hei = Const.GRID*(Const.FHEI+Const.FPADDING*2);


		bg = new Bitmap( new BitmapData(wid,hei,false, 0xff294628) );
		game.sdm.add(bg, Const.DP_BG1);

		splatters = new Bitmap( new BitmapData(wid,hei, true, 0x0) );
		game.sdm.add(splatters, Const.DP_BG2);

		perlin = new BitmapData(300,300, false, 0x0);
		perlin.perlinNoise(64,128,1, game.seed, true, false, 1, true);

		//var g = 128;
		//for( cx in 0...MLib.ceil(wid/g) )
			//for( cy in 0...MLib.ceil(hei/g) ) {
				//if( cx>3 || cy<2 || cy>4 )
					//continue;
				//var bmp = new Bitmap( new BitmapData(g,g, false, Color.randomColor(Math.random(), 0.5, 0.7) ) );
				//bmp.x = cx*g;
				//bmp.y = cy*g;
				//game.sdm.add(bmp, Const.DP_BG2);
			//}
	}


	function initCollisions() {
		colMap = new Array();
		for(x in 0...Const.FWID+Const.FPADDING*2) {
			colMap[x] = new Array();
			for(y in 0...Const.FHEI+Const.FPADDING*2)
				colMap[x][y] = 999;
		}

		for( x in 0...Const.FWID )
			for( y in 0...Const.FHEI )
				colMap[Const.FPADDING+x][Const.FPADDING+y] = 0;

		var r = getGoalRectangle(0);
		for( x in r.x...r.x+r.w )
			for( y in r.y...r.y+r.h)
				colMap[x][y] = 0;

		var r = getGoalRectangle(1);
		for( x in r.x...r.x+r.w )
			for( y in r.y...r.y+r.h)
				colMap[x][y] = 0;
	}


	public function initAndRender() {
		goals = new Array();
		goals[0] = { rect:makeGoalRectangle(0), bmp:null };
		goals[1] = { rect:makeGoalRectangle(1), bmp:null };

		initCollisions();
		render();
	}


	public inline function getGoalRectangle(side:Int) {
		return goals[side].rect;
	}

	public inline function getGoalFront(side:Int) {
		var g = getGoalRectangle(side);
		return {
			x	: Const.GRID * (g.x + g.w*0.5) + (side==0 ? 70 : -70),
			y	: Const.GRID * (g.y + g.h*0.5),
		}
	}

	function makeGoalRectangle(side:Int) {
		var grand = new mt.Rand(0);
		grand.initSeed(game.seed + side*55);

		var r = {x:0, y:0, w:3, h:8};

		if( side==1 && game.oppTeam.hasPerk(Perk._PSmallCage) )
			r.h = 4;

		if( side==0 && game.oppTeam.hasPerk(Perk._PPlayerLargeCage) )
			r.h = 16;

		if( side==1 && game.oppTeam.hasPerk(Perk._PLargeCage) )
			r.h = 10;

		r.x = side==0 ? Const.FPADDING - r.w : Const.FPADDING + Const.FWID;
		r.y = Std.int(Const.FPADDING + Const.FHEI*0.5 - r.h*0.5);

		if( side==1 ) {
			if( game.oppTeam.hasPerk(Perk._PRandomCage) )
				r.y = Const.FPADDING + grand.random(Const.FHEI-r.h-1);
			if( game.oppTeam.hasPerk(Perk._PCornerCage) ) {
				if( grand.random(2)==0 )
					r.y = Const.FPADDING + 1 + grand.random(4);
				else
					r.y = Const.FPADDING + Const.FHEI - r.h - 1 - grand.random(4);
			}
		}
		return r;
	}


	public inline function getCollisionHeight(x:Int,y:Int) {
		return
			if( x<0 || x>=Const.FWID+Const.FPADDING*2 || y<0 || y>=Const.FHEI+Const.FPADDING*2 )
				999;
			else
				colMap[x][y];
	}

	function drawCollisions() {
		var s = new Sprite();
		var g = s.graphics;
		g.beginFill(0xFF0000, 0.5);
		for( x in 0...Const.FWID+Const.FPADDING*2 )
			for( y in 0...Const.FHEI+Const.FPADDING*2 )
				if( colMap[x][y]>0 )
					g.drawRect(x*Const.GRID, y*Const.GRID, Const.GRID, Const.GRID);
		bg.bitmapData.draw(s);
	}


	public function destroy() {
		splatters.bitmapData.dispose();
		splatters.bitmapData = null;
		splatters.parent.removeChild(splatters);

		bg.bitmapData.dispose();
		bg.bitmapData = null;
		bg.parent.removeChild(bg);

		for(g in goals) {
			g.bmp.bitmapData.dispose();
			g.bmp.bitmapData = null;
		}
		goals = [];

		perlin.dispose(); perlin = null;

		if( waterPerlin!=null ) {
			waterPerlin.dispose();
			waterPerlin = null;
		}
		if( gluePerlin!=null ) {
			gluePerlin.dispose();
			gluePerlin = null;
		}

		if( snow!=null ) {
			snow.bitmapData.dispose();
			snow.bitmapData = null;
			snow.parent.removeChild(snow);
		}
	}


	public inline function splatter(o:flash.display.DisplayObject) {
		if( !game.lowq )
			splatters.bitmapData.draw(o, o.transform.matrix);
	}


	public inline function checkWaterPerlin(x:Float,y:Float) {
		return waterPerlin!=null && waterPerlin.getPixel(Std.int(x),Std.int(y)) > 0;
	}

	public inline function checkGluePerlin(x:Float,y:Float) {
		return gluePerlin!=null && gluePerlin.getPixel(Std.int(x),Std.int(y)) >= Const.GLUE_THRESHOLD;
	}

	public inline function checkPerlin(x,y) {
		return perlin.getPixel(x%perlin.width, y%perlin.height) >= 0x444444;
	}


	public function render() {
		var seed = game.getLevel();
		var rseed = new mt.Rand(0);

		var bbd = bg.bitmapData;

		// Sol
		var s = game.tiles.get("gazon", 0);
		if( game.oppTeam.hasPerk(Perk._PLeather) )
			s.setFrame(1);
		s.x = Const.FPADDING*Const.GRID;
		s.y = Const.FPADDING*Const.GRID;
		bbd.draw(s, s.transform.matrix);
		s.dispose();

		// Saleté
		rseed.initSeed(seed);
		if( !game.oppTeam.hasPerk(_PGlue) && !game.oppTeam.hasPerk(Perk._PLeather) ) {
			var dirt = new BitmapData(bbd.width, bbd.height, true, 0x0);
			var s = game.tiles.get("taches");
			for(i in 0...60) {
				var x,y;
				var tries = 500;
				do {
					x = Const.GRID * ( rseed.random(Const.FWID+Const.FPADDING*2) );
					y = Const.GRID * ( rseed.random(Const.FHEI+Const.FPADDING*2) );
				} while( !checkPerlin(x,y) && tries-->0 );

				s.setRandomFrame(rseed.random);
				s.x = x;
				s.y = y;
				s.scaleX = s.scaleY = rseed.range(1,3);
				s.rotation = rseed.rand()*360;
				s.alpha = rseed.range(0.4, 0.9);
				dirt.draw(s, s.transform.matrix, s.transform.colorTransform, MULTIPLY);
			}
			dirt.colorTransform( dirt.rect, mt.deepnight.Color.getColorizeCT(0x858043, 1) );
			bbd.draw(dirt);
			dirt.dispose();
			s.dispose();
		}

		// Cuir
		rseed.initSeed(seed);
		if( game.oppTeam.hasPerk(Perk._PLeather) || rseed.random(100)<20 ) {
			var x = 0;
			var y = 0;
			var d = 30;
			var s = game.tiles.get("leatherTexture");
			while(y<bbd.height) {
				while(x<bbd.width) {
					if( checkPerlin(x,y) ) {
						//var mc = new lib.LeatherTexture();
						s.x = x;
						s.y = y;
						s.setRandomFrame(rseed.random);
						bbd.draw(s, s.transform.matrix, OVERLAY);
					}
					x+=d;
				}
				x = 0;
				y+=d;
			}
			s.dispose();
		}

		// Noise
		rseed.initSeed(seed);
		if( !game.oppTeam.hasPerk(Perk._PLeather) ) {
			var noise = mt.deepnight.Lib.flatten(new lib.Noise());
			var texture = new Sprite();
			texture.graphics.beginBitmapFill(noise.bitmapData, true);
			texture.graphics.drawRect(0,0,wid,hei);
			texture.alpha = Lib.rnd(0.5, 0.8);
			bbd.draw(texture, texture.transform.colorTransform, OVERLAY);

			noise.bitmapData.dispose();
			noise.bitmapData = null;
			texture.graphics.clear();
		}

		// EAU
		rseed.initSeed(seed);
		if( game.oppTeam.hasPerkAmong([Perk._PWet, Perk._PSuperWet]) ) {
			waterPerlin = new BitmapData(wid,hei,false,0x0);

			var threshold = game.oppTeam.hasPerk(Perk._PSuperWet) ? Const.WATER_THRESHOLD_MUCH : Const.WATER_THRESHOLD_FEW;
			if( game.oppTeam.hasPerk(Perk._PSuperWet) )
				waterPerlin.perlinNoise(100,60,4, game.seed, true,true, 1, true);
			else
				waterPerlin.perlinNoise(130,80,4, game.seed, true,true, 1, true);
				//waterPerlin.perlinNoise(150,100,4, game.seed, true,true, 1, true);
			waterPerlin.threshold(waterPerlin, waterPerlin.rect, pt0, "<", mt.deepnight.Color.addAlphaF(threshold), 0x0);
			var c = 0x04848E;
			var bd = new BitmapData(wid,hei,true,0x0);
			bd.threshold(waterPerlin, waterPerlin.rect, pt0, ">", 0x0, Color.addAlphaF(c));
			var texBase = game.tiles.getBitmapData("Ice");
			var tex = Lib.createTexture(texBase, bd.width, bd.height, true);
			bd.copyPixels(tex, bd.rect, pt0, bd, true);
			tex.dispose();
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0xffffff,0.8, 4,4,1, 1,true ));
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0x0,0.4, 0,0));
			bbd.draw(bd, new flash.geom.ColorTransform(1,1,1,0.6), NORMAL);
		}

		// GLUE
		rseed.initSeed(seed);
		if( game.oppTeam.hasPerk(Perk._PGlue) ) {
			gluePerlin = new BitmapData(wid,hei,false,0x0);
			gluePerlin.perlinNoise(130,100,4, game.seed, true,true, 1, true);
			var c = 0x733582;
			var bd = new BitmapData(wid,hei,true,0x0);
			bd.threshold(gluePerlin, gluePerlin.rect, pt0, ">", mt.deepnight.Color.addAlphaF(Const.GLUE_THRESHOLD), mt.deepnight.Color.addAlphaF(c));
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0xffffff,0.4, 32,32,1, 1,true));
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(1,-90, 0xffffff,0.5, 2,2,1, 1,true));
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x4B7843,1, 16,16,1, 1,true));
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(20,90, 0xffffff,0.1, 16,16,1, 1,true));
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x4B7843,0.7, 4,4,1));
			bbd.draw(bd, new flash.geom.ColorTransform(1,1,1,0.7), NORMAL);
		}


		// Fleurs
		if( !game.oppTeam.hasPerk(Perk._PLeather) )
			for(i in 0...120) {
				var mc = new lib.Item_deco();
				mc.x = Const.GRID * ( rseed.random(Const.FWID+Const.FPADDING*2) );
				mc.y = Const.GRID * ( rseed.random(Const.FHEI+Const.FPADDING*2) );
				mc.gotoAndStop( rseed.random(mc.totalFrames)+1 );
				mc.alpha = rseed.rand()*0.3 + 0.5;
				bbd.draw(mc, mc.transform.matrix, mc.transform.colorTransform);
			}



		// Public gauche
		if( !game.oppTeam.hasPerk(Perk._PPlayerLargeCage) ) {
			var mc = new lib.Public_cotes();
			mc.x = 72;
			bbd.draw(mc, mc.transform.matrix);
		}

		// Public droite
		if( !game.oppTeam.hasPerk(_PRandomCage) && !game.oppTeam.hasPerk(_PCornerCage) && !game.oppTeam.hasPerk(_PLargeCage) ) {
			var mc = new lib.PublicDroit();
			mc.x = 72;
			bbd.draw(mc, mc.transform.matrix);
		}

		// Gradins
		var mc = new lib.Gradins_fixe();
		mc.x = Const.FPADDING*Const.GRID;
		bbd.draw(mc, mc.transform.matrix);

		// Murets
		var wallTmp = new BitmapData(wid,hei, true, 0x0);
		game.tiles.drawIntoBitmap(wallTmp, Const.FPADDING*Const.GRID-10, Const.FPADDING*Const.GRID-14, "muret", hasSideWarp ? 1 : 0);

		// Trous des buts
		var r = getGoalRectangle(0);
		wallTmp.fillRect(new flash.geom.Rectangle(r.x*Const.GRID,r.y*Const.GRID-15, 20+r.w*Const.GRID, r.h*Const.GRID+10), 0x0);
		var r = getGoalRectangle(1);
		wallTmp.fillRect(new flash.geom.Rectangle(r.x*Const.GRID-20,r.y*Const.GRID-15, r.w*Const.GRID, r.h*Const.GRID+10), 0x0);

		bbd.copyPixels(wallTmp, wallTmp.rect, pt0, true);
		wallTmp.dispose();

		// But 0
		var g = drawGoal(0);
		var m = new flash.geom.Matrix();
		m.translate( Const.GRID*(g.rect.x-1)-10, Const.GRID*(g.rect.y-3));
		bbd.draw(g.ground, m);
		var bmp = new Bitmap(g.front);
		game.sdm.add(bmp, Const.DP_GOAL_CAGE);
		bmp.transform.matrix = m;
		goals[0].bmp = bmp;

		// But 1
		var g = drawGoal(1);
		var m = new flash.geom.Matrix();
		m.scale(-1, 1);
		m.translate(g.ground.width, 0);
		m.translate( Const.GRID*(g.rect.x)-5, Const.GRID*(g.rect.y-3));
		bbd.draw(g.ground, m);
		var bmp = new Bitmap(g.front);
		game.sdm.add(bmp, Const.DP_GOAL_CAGE);
		bmp.transform.matrix = m;
		goals[1].bmp = bmp;


		// Ambiant
		rseed.initSeed(seed);
		var teint = getTeintFilter();
		if( teint!=null ) {
			bbd.applyFilter(bbd, bbd.rect, pt0, teint);
			for(i in 0...2) {
				var gbd = goals[i].bmp.bitmapData;
				gbd.applyFilter(gbd, gbd.rect, pt0, teint);
			}
		}
	}

	public function debugRender() {
		var bd = bg.bitmapData.clone();
		for(cx in 0...Const.FWID+Const.FPADDING*2)
			for(cy in 0...Const.FHEI+Const.FPADDING*2) {
				var r = new flash.geom.Rectangle( cx*Const.GRID, cy*Const.GRID, Const.GRID, Const.GRID );
				bd.fillRect(r, (cx+cy)%2==0 ? 0xff6372B6 : 0xffA76BAD );
			}
		bg.bitmapData.draw(bd, new flash.geom.ColorTransform(1,1,1, 0.5));
		drawCollisions();
	}


	function getTeintFilter() {
		if( game.oppTeam.hasPerk(Perk._PLeather) )
			return null;

		var rseed = new mt.Rand(0);
		#if video
		rseed.initSeed(Std.random(9999));
		#else
		rseed.initSeed(game.getLevel());
		#end
		var colors = [
			{c:0x0, r:0.},
			{c:0x806031, r:0.5},
			{c:0x40715F, r:0.5},
			{c:0x783848, r:0.5},
			{c:0xA35A4E, r:0.5},
			{c:0x6D4A30, r:0.6},
			{c:0x425B49, r:0.6},
			{c:0x732B37, r:0.5},
			{c:0x382D71, r:0.5},
			{c:0x382D71, r:0.5},
			{c:0x306D5B, r:0.4},
			{c:0xFF8040, r:0.4},
			{c:0x978562, r:0.6},
			{c:0x3D4439, r:0.8},
		];
		var c = colors[rseed.random(colors.length)];
		if( c.r>0 )
			return mt.deepnight.Color.getColorizeFilter(c.c, c.r, 1-c.r);
		else
			return null;
	}



	function drawGoal(side:Int) {
		var r = getGoalRectangle(side);

		var b = new BitmapData(Const.GRID*5, (r.h+4)*Const.GRID, true, 0x0);
		var f = b.clone();

		// Fond
		var top = new lib.But_back_shadow();
		b.draw(top, top.transform.matrix);
		var bottom = new lib.But_front_shadow();
		bottom.y = Const.GRID*r.h;
		b.draw(bottom, bottom.transform.matrix);
		for(y in 3...r.h) {
			var mc = new lib.But_tile_shadow();
			mc.y = Const.GRID*y;
			b.draw(mc, mc.transform.matrix);
		}

		// Filet
		var top = new lib.But_back();
		f.draw(top, top.transform.matrix);
		var bottom = new lib.But_front();
		bottom.y = Const.GRID*r.h;
		f.draw(bottom, bottom.transform.matrix);
		for(y in 3...r.h) {
			var mc = new lib.But_tile();
			mc.y = Const.GRID*y;
			f.draw(mc, mc.transform.matrix);
		}

		return { rect:r, front:f, ground:b }
	}


	public function addWall(cx) {
		var rseed = new mt.Rand(0);
		rseed.initSeed( game.getLevel()+cx );

		hasWalls = true;
		for(cy in Const.FPADDING...Const.FPADDING+Const.FHEI) {
			var cx = Const.FPADDING+cx;
			for(cx in cx...cx+2)
				colMap[cx][cy] = Const.OBSTACLE_HEIGHT;

			if( cy%2==0 ) {
				var k = rseed.random(100)<20 ? "wall" : "tree";
				game.tiles.drawIntoBitmapRandom(
					bg.bitmapData,
					(cx+1)*Const.GRID + rseed.irange(0,3,true),
					cy*Const.GRID + rseed.irange(0,2,true),
					k, 0.5, 0.5
				);
			}
		}
	}


	public function addGoalWall(side:Int) {
		hasWalls = true;
		var r = getGoalRectangle(side);
		for( cy in r.y-3...r.y+r.h+4 ) {
			var cx = side==1 ? r.x - 10 : r.x+r.w-1 + 10;
			colMap[cx][cy] = Const.OBSTACLE_HEIGHT;
			game.tiles.drawIntoBitmap(
				bg.bitmapData,
				(cx+0.5)*Const.GRID - Lib.irnd(0,3),
				(cy+1)*Const.GRID + 4 - Lib.irnd(0,1),
				"wheels",0, 0.5,0.5
			);
		}

	}

	public function initSnow() {
		if( snow!=null ) {
			snow.bitmapData.dispose();
			snow.parent.removeChild(snow);
		}

		var c = 0x8EA2B9;
		var w = MLib.ceil( Const.GRID*Const.FWID / Const.SNOW_SCALE );
		var h = MLib.ceil( Const.GRID*Const.FHEI / Const.SNOW_SCALE );
		snow = new Bitmap( new BitmapData(w,h,true,0x0), NEVER, false );
		game.sdm.add(snow, Const.DP_SNOW);
		snow.bitmapData.fillRect( snow.bitmapData.rect, mt.deepnight.Color.addAlphaF(c) );

		snow.scaleX = snow.scaleY = Const.SNOW_SCALE;
		var perlin = snow.bitmapData.clone();
		perlin.perlinNoise(16,8, 1,game.seed, true,false, 1, true);
		snow.bitmapData.draw(perlin, new flash.geom.ColorTransform(1,1,1, 0.1), OVERLAY);
		perlin.dispose();

		snow.x = Const.FPADDING*Const.GRID;
		snow.y = Const.FPADDING*Const.GRID;

		var teint = getTeintFilter();
		if( teint!=null )
			snow.bitmapData.applyFilter( snow.bitmapData, snow.bitmapData.rect, pt0, teint );

		var bd = snow.bitmapData;
		var s = game.tiles.get("taches");
		s.setCenter(0.5, 0.5);
		var off = 5;
		for(cy in 0...Const.FHEI) {
			if( cy%3!=0 )
				continue;

			s.scaleX = s.scaleY = Lib.rnd(0.5,1);
			s.rotation = Lib.rnd(0,360);

			// Left
			s.x = -Lib.rnd(0,off);
			s.y = cy*Const.GRID / Const.SNOW_SCALE;
			bd.draw(s, s.transform.matrix, ERASE);

			// Right
			s.x = Const.FWID*Const.GRID / Const.SNOW_SCALE + Lib.rnd(0,off);
			bd.draw(s, s.transform.matrix, ERASE);
		}
		for(cx in 0...Const.FWID) {
			if( cx%3!=0 )
				continue;
			s.scaleX = s.scaleY = Lib.rnd(0.5,1);
			s.rotation = Lib.rnd(0,360);

			// Top
			s.x = cx*Const.GRID / Const.SNOW_SCALE;
			s.y = -Lib.rnd(0,off);
			bd.draw(s, s.transform.matrix, ERASE);

			// Bottom
			s.y = Const.FHEI*Const.GRID / Const.SNOW_SCALE + Lib.rnd(0,off);
			bd.draw(s, s.transform.matrix, ERASE);
		}
		s.dispose();

		//if( game.lowq )
			//flattenSnow();
	}


	//public function flattenSnow() {
		//if( !game.hasSnow () || snow==null || snowFlattened )
			//return;
//
		//snowFlattened = true;
//
		//var m = new flash.geom.Matrix();
		//m.scale(Const.SNOW_SCALE, Const.SNOW_SCALE);
		//bg.bitmapData.draw(snow, m, new flash.geom.ColorTransform(1,1,1, 0.9));
//
		//snow.parent.removeChild(snow);
		//snow.bitmapData.dispose();
		//snow = null;
	//}

	public function snowHole(x:Float,y:Float) {
		if( snow==null )
			return;

		var x = Std.int( (x-Const.FPADDING*Const.GRID) / Const.SNOW_SCALE ) + Lib.irnd(0,2,true);
		var y = Std.int( (y-Const.FPADDING*Const.GRID) / Const.SNOW_SCALE ) + Lib.irnd(0,1,true);
		var bd = snow.bitmapData;
		for( i in 0...3 ) {
			var p = bd.getPixel32(x,y);
			var rgba = Color.intToRgba(p);
			rgba.a = Std.int( 255*Lib.rnd(0.4, 0.7) );
			bd.setPixel32( x,y, Color.rgbaToInt(rgba) );
		}
	}



	public function preUpdate() {
		if( snow!=null )
			snow.bitmapData.lock();
	}


	public function update() {
		if( snow!=null ) {
			snow.bitmapData.unlock();
			snow.bitmapData.setPixel32(0,0, 0x0);
		}

		splatters.visible = !game.lowq;
	}

}