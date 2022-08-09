import fl.bg.Fields;
import fl.bg.Graveyard;
import fl.bg.Mountain;
import fl.bg.Pierre;
import Protocole;
import mt.bumdum9.Lib;


class Scene extends SP {//}

	public static var DP_BG = 			0;
	public static var DP_UNDER_FX = 	1;
	public static var DP_FOLKS = 		2;
	public static var DP_GROUND = 		3;
	
	public static var DP_FX = 			6;
	public static var DP_FOREGROUND = 	8;
	
	public static var HEIGHT = 120;
	public static var GH = 4;
	
	public static var MONSTER_POS = (Cs.mcw>>1) +160;
	
	public var bg:SP;
	var bgColor:Int;
	var foreground:SP;
	public var bmp:BMD;
	
	public var dm:mt.DepthManager;
	public static var me:Scene;
	
	

	public function new(loc) {
		super();
		me = this;
		dm = new mt.DepthManager(this);
		
		
		var gfx  = graphics;
		gfx.beginFill(0x444444);
		gfx.drawRect(0, 0, Cs.mcw, HEIGHT);
		
		// BG
		initBg(loc);
		
		//

		

	}
	
	public function attach(str, mcname) {
		return Main.player.attach(str,Type.createInstance(Type.resolveClass(mcname),[]));
	}
	
	// BG
	function initBg(?loc) {
		var rnd = new mt.Rand(0);
		//rnd.initSeed(Std.random(1000000));
		
		
		bmp = new BMD(Cs.mcw, Scene.HEIGHT, true, 0xFFC0C0C0);
		var tmp = bmp.clone();
		
		#if dev
		loc = getCacheLocation();
		#end
		
		rnd.initSeed(loc.seed);
			

		var bg:{ bg : MC, mood : MC, clouds : MC, elements : MC, soil : MC, colorSet : MC, tex : MC, dirts:MC };

		switch(loc.wid) {
			case 0 :  bg = new fl.bg.Grass();
			case 1 :  bg = new fl.bg.Rock();
			case 2 :  bg = new fl.bg.Sand();
			case 3 :  bg = new fl.bg.Ground();
			case 4 :  bg = new fl.bg.Marecage();
			case 5 :  bg = new fl.bg.Gravier();
			case 6 :  bg = new fl.bg.Ice();
			case 7 :  bg = new fl.bg.Lava();
			case 8 :  bg = new fl.bg.Pierre();
			case 9 :  bg = new fl.bg.Water();

			case 10 :  bg = new fl.bg.Graveyard();
			case 11 :  bg = new fl.bg.Fields();
			case 12 :  bg = new fl.bg.Jungle();
			case 13 :  bg = new fl.bg.Mountain();
			
			default :
				bg = new fl.bg.Grass();
			
		}
		
		
		var m = new flash.geom.Matrix();
		var p0 = new flash.geom.Point();

		// BG
		//trace(loc.bg);
		bg.bg.gotoAndStop( Std.int( loc.bg%bg.bg.totalFrames) + 1 );
		var m = new flash.geom.Matrix();
		//m.scale(Cs.mcw/bg.mood.width,1.3);	// HACK NEW SIZE
		bmp.draw(bg.bg,m);

		
		//

		
		// clouds (plan 6)
		for( i in 0...3 ) {
			m.identity();
			var sCloud = 0.4 + rnd.random(60)/100; 		//_Hk_
			m.scale(sCloud, sCloud);
			m.tx = rnd.random(800) - 100;
			m.ty = rnd.random(70);
			bg.clouds.gotoAndStop(  Std.int( rnd.random(bg.clouds.totalFrames) + 1 ) );
			tmp.draw(bg.clouds, m);
		}
		bmp.draw(tmp, new flash.geom.ColorTransform(1, 1, 1, 0.4));
		
		
		// VERSION FACTORISE
		var horizon = Std.int(HEIGHT*0.65);
		var hh = 25;

		var elements = [5, 5, 2, 5, 1, 4, 1, 2, 0, 0];
		
		
		var max = 5;
		for ( i in 0...max ) {
			//if ( i == max-1 ) continue;
			var sc = [0.5, 0.75, 1, 1.1, 3][i];				// 4
			var blur = [2.5, 2, 1.5, 1, 4][i];
			
			tmp.fillRect(tmp.rect, 0);
			m.identity();
			m.scale(sc, sc);
			
			var c = i / (max - 2);
			var ty = horizon + Math.pow(c,1.65)* ( (Scene.HEIGHT-horizon)-18 );

			var min = elements.shift();
			var inc = elements.shift();
			
			
			for( i in 0...min + rnd.random(inc) ) {
				m.identity();
				m.scale(sc*(Std.random(2)*2-1), sc);
				m.tx = rnd.random(Cs.mcw);
				m.ty = ty;
				bg.elements.gotoAndStop( rnd.random(bg.elements.totalFrames) + 1 );
				tmp.draw(bg.elements,m);
			}
			
			m.identity();
			m.scale(sc, sc);
			m.ty = ty;
			m.tx = -Std.random(i*250);
			tmp.draw(bg.soil, m);
			m.translate(660*sc, 0);
			tmp.draw(bg.soil, m);
			tmp.applyFilter(tmp,tmp.rect,p0,new flash.filters.BlurFilter(blur, blur, 3));
			//bmp.draw(tmp, new flash.geom.ColorTransform(1, 1, 1, 0.24), flash.display.BlendMode.MULTIPLY);
			switch(i) {
				case 0 :	bmp.draw(tmp, new flash.geom.ColorTransform(1, 1, 1, 0.24), flash.display.BlendMode.MULTIPLY);
				case 1 :	bmp.draw(tmp, new flash.geom.ColorTransform(1, 1, 1, 1, 90, 90, 90, 0));
				case 2 :	bmp.draw(tmp, new flash.geom.ColorTransform(1, 1, 1, 1, 51, 51, 51, 0));
				case 3 :	bmp.draw(tmp);
				
				case 4 : //
					foreground = new SP();
					dm.add(foreground, DP_FOREGROUND);
					var gfx = foreground.graphics;
					gfx.beginFill(0);
					gfx.drawRect(0, HEIGHT, Cs.mcw,40);
					var fade = new FadeToBlack();
					foreground.addChild(fade);
					fade.y = HEIGHT;
					fade.blendMode = flash.display.BlendMode.OVERLAY;
					
					//
					var bmp = tmp.clone();
					var bdata = new flash.display.Bitmap(bmp);
					foreground.addChild(bdata);
					bmp.fillRect(new flash.geom.Rectangle(0, 0, Cs.mcw, HEIGHT), 0);
					var ct = new CT(0, 0, 0, 1, 0, 0, 0, 0);
					for ( i in 0...5 ) {
						m.identity();
						m.tx = rnd.random(Cs.mcw);
						m.ty = HEIGHT;// -GH;
						bg.dirts.gotoAndStop( rnd.random(bg.dirts.totalFrames) + 1 );
						
						bmp.draw(bg.dirts,m,ct);
					}
					
					/*
					var bmp = tmp.clone();
					var bdata = new flash.display.Bitmap(bmp);
					foreground.addChild(bdata);
					foreground.alpha = 0.7;
					*/
				
				
				// FRONT LAYER
				//case 4 :	bmp.draw(tmp, new flash.geom.ColorTransform(1, 1, 1, .95));
				
			
			}
		}
		
		// moodz
		//bg.width = Cs.mcw;
		bg.mood.gotoAndStop( Std.int( loc.mood%bg.mood.totalFrames) + 1 );
		var m = new flash.geom.Matrix();			// HACK NEW SIZE
		m.scale(Cs.mcw/bg.mood.width,1.3);		// HACK NEW SIZE
		bmp.draw(bg.mood,m);

		// filter
		bg.colorSet.gotoAndStop( Std.int( loc.colorSet%bg.colorSet.totalFrames) + 1);
		bmp.applyFilter( bmp, bmp.rect, p0, bg.colorSet.getChildAt(0).filters[0] );
		
		// extract color
		bgColor = bmp.getPixel(0, 0);
			
		
		// BG
		this.bg = new SP();
		this.bg.addChild(new flash.display.Bitmap(bmp));
		dm.add(this.bg, DP_BG);
		
		// TEXT AMBIENT
		var max = bg.tex.totalFrames;
		var tex = new BMD(30*max, 30, false, 0xFF0000);
		for ( n in 0...max ) {
			bg.tex.gotoAndStop(n + 1);
			var m = new MX();
			m.translate(n * 30, 0);
			tex.draw(bg.tex, m);
		}
		var xmax = Math.ceil(Cs.mcw / 30);
		var ymax = 16;
		
		var bmp = new BMD(xmax * 30, ymax * 30, false, 0x00FF00);
		for ( x in 0...xmax ) {
			for ( y in 0...ymax ) {
				bmp.copyPixels( tex, new flash.geom.Rectangle(Std.random(max) * 30, 0, 30, 30), new PT(x * 30, y * 30) );
			}
		}
		
		var sp = new flash.display.Bitmap(bmp);
		Game.me.dm.add(sp, Game.DP_BG);
		Game.me.dm.over(Game.me.ambient );
		
		
		
		/*
		var text = new BMD(30, 30, false, 0xFF0000);
		bg.tex.gotoAndStop(rnd.random(bg.tex.totalFrames) + 1);
		text.draw( bg.tex );
		var g = Game.me.ambient.graphics;
		g.clear();
		g.beginBitmapFill(text, new MX(), true, true);
		g.drawRect(0, 0, Cs.mcw, Cs.mch - Scene.HEIGHT);
		*/
		
		
		// CLEAN
		//text.dispose();
		tmp.dispose();
		
	}
		
	// FX
	public function fxGroundImpact(cx,ray,max=12,pow=5.0, vx=0.0) {
		
		for( i in 0...max  ) {
			var c = (i / (max - 1)) * 2 - 1;
			if( max == 1 ) c = 0.5;
			var p = getStone();
			
			p.vx = c * pow  + vx + Math.random()*vx;
			p.vy = -(pow*0.5 + Math.cos(c * 1.57) * pow);
			
			p.x = cx + c * ray;
			p.y = HEIGHT+p.vy-GH;
			
			p.twist(24, 0.95);
		}
		
		
		
	}
	public function getStone() {
		var p = new mt.fx.Part( new McDirt() );
		p.y = Scene.HEIGHT - 1;
		
		var sc = 0.5 + Math.random();
		p.setScale(sc);
		p.frict = 0.98;
		p.weight = sc * (0.2 + Math.random() * 0.1);
		p.timer = 200 + Std.random(50);
		
		p.root.gotoAndStop(Std.random(p.root.totalFrames) + 1);
		dm.add(p.root, (Std.random(2) == 0)?DP_FX:DP_UNDER_FX);
		
		p.setGround(Scene.HEIGHT-Scene.GH, 0.8, 0.5);
		
		return p;

	}
	public function fxShake() {
		new mt.fx.Shake(this, 0, 8);
	}
	
	// FX - FADE
	public function fadeTo(color,spc=0.05) {
		return new mt.fx.FadeTo( Scene.me.bg,spc, -40, color );
	}
	public function fadeBack(co=0.05) {
		new mt.fx.FadeBack( Scene.me.bg, co );
	}
	public function fadeInstant(color,spc=0.05) {
		Scene.me.fadeTo(color, 1).update();
		Scene.me.fadeBack(spc);
	}
	
	// TOOLS
	public function getMask() {
		var sp = new SP();
		sp.graphics.beginFill(0xFF0000);
		sp.graphics.drawRect(0, 0, Cs.mcw, HEIGHT);
		return sp;
	}
	public function getPart(mc:SP) {
		var p = new mt.fx.Part(mc);
		dm.add(p.root, Scene.DP_FX);
		
		return p;
	}
	
	#if dev
	// DEV
	function getCacheLocation() {
		
		var so = flash.net.SharedObject.getLocal("loc");
		var loc:Location = so.data.loc;
		if( loc == null ){
			loc = { wid:Std.random(4), bg:0, mood:0, colorSet:0, seed:0 };
			saveLocation(loc);
		}
		
	
		return loc;
	}
	
	function saveLocation(loc) {
		var so = flash.net.SharedObject.getLocal("loc");
		so.data.loc = loc;
		so.flush();
	}
		
	function refreshBg() {
		bg.parent.removeChild(bg);
		bmp.dispose();
		foreground.parent.removeChild(foreground);
		initBg();
	}
	
	public function nextWorld() {
		var loc = getCacheLocation();
		loc.wid = (loc.wid + 1) % 14;
		saveLocation(loc);
		refreshBg();
	}
	public function nextBg() {
		var loc = getCacheLocation();
		loc.bg = (loc.bg + 1) % 5;
		saveLocation(loc);
		refreshBg();
	}
	public function nextMood() {
		var loc = getCacheLocation();
		loc.mood = (loc.mood + 1) % 5;
		saveLocation(loc);
		refreshBg();
	}
	public function nextLight() {
		var loc = getCacheLocation();
		loc.colorSet = (loc.colorSet + 1) % 3;
		saveLocation(loc);
		refreshBg();
	}
	public function nextSeed() {
		var loc = getCacheLocation();
		loc.seed = (loc.seed + 1) % 100;
		saveLocation(loc);
		refreshBg();
	}
	public function randomize() {
		var loc = getCacheLocation();
		loc.seed = Std.random(0x1000000);
		loc.colorSet = Std.random(3);
		loc.mood = Std.random(5);
		loc.bg = Std.random(5);
		saveLocation(loc);
		refreshBg();
	}
	
	#end
	
//{
}