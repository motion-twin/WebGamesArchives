package process;

import h2d.Sprite;
import h2d.Text;
import hxd.Float32;

import mt.deepnight.TinyProcess;
import mt.deepnight.HProcess;
import mt.deepnight.slb.HSprite;
import mt.motion.Tweener;

import data.Settings;
import data.LevelDesign;
import manager.SoundManager;
import ui.ButtonWorld;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */
class Home extends HProcess
{
	public static var ME	: Home;
	
	static var DM_BG		= 0;
	static var DM_STARS		= 1;
	static var DM_PLANET	= 2;
	static var DM_UI		= 3;
	
	static var DURATION_TRANSITION		= 0.3;
	
	var pm					: process.ProcessManager;
	
	var bgFD				: mt.deepnight.slb.BLib.FrameData;
	var bg					: HSprite;
	
	var arTP				: Array<TinyProcess>;
	
	var bmStarPlanFG		: h2d.SpriteBatch;
	var bmStarPlanMid		: h2d.SpriteBatch;
	var bmStarPlanBG		: h2d.SpriteBatch;
	var arStar				: Array<mt.deepnight.slb.HSpriteBE>;
	
	var hsTitle				: HSprite;
	var hsTitleLight		: HSprite;
	var cLblStart			: h2d.Sprite;
	var lblStart			: Text;
	
	var cWorlds				: Sprite;
	var actualWorldNum		: Int;
	
	public var tweener		: mt.motion.Tweener;
	var t					: mt.motion.Tween;
	var tpLblStart			: mt.deepnight.TinyProcess;
	
	// Drag'n'drop
	public var rootMouseX	: Float;
	public var rootMouseY	: Float;
	
	var mouseDragY			: Float;
	var mouseDY				: Float;
	var mouseLeftDown		: Bool;
	
	public function new() {
		ME = this;
		
		pm = process.ProcessManager.ME;
		
		super(pm);
		
		tweener = new mt.motion.Tweener();
		
	// BG
		bgFD = Settings.SLB_NOTRIM.getFrameData("colorBg");
		bg = Settings.SLB_NOTRIM.h_get("colorBg");
		bg.filter = true;
		root.add(bg, DM_BG);
		
	// WORLDS
		cWorlds = new Sprite();
		root.add(cWorlds, DM_PLANET);
		
		hsTitleLight = Settings.SLB_UI2.h_get("logoBg");
		hsTitleLight.setCenterRatio(0.5, 0.5);
		hsTitleLight.filter = true;
		cWorlds.addChild(hsTitleLight);
		
		hsTitle = Settings.SLB_NOTRIM.h_get("logo");
		hsTitle.setCenterRatio(0.5, 0.5);
		hsTitle.filter = true;
		hsTitle.hasFXAA = true;
		cWorlds.addChild(hsTitle);
		
		cLblStart = new h2d.Sprite(cWorlds);
		lblStart = new h2d.Text(Settings.FONT_MOUSE_DECO_100);
		lblStart.filter = true;
		lblStart.textColor = 0xF6EFD0;
		cLblStart.addChild(lblStart);
		
		tpLblStart = createTinyProcess();
		tpLblStart.onUpdate = function() {
			cLblStart.scaleX = 1 + Math.sin(this.time / 10) / 50;
			cLblStart.scaleY = 1 + Math.sin(this.time / 10) / 50;
		}
		
		actualWorldNum = 0;
		
	// STARS
	
		arStar = [];
		
		//bmStarPlanBG = new h2d.Sprite();
		bmStarPlanBG = new h2d.SpriteBatch(Settings.SLB_UI.tile);
		bmStarPlanBG.filter = true;
		bmStarPlanBG.blendMode = Add;
		root.add(bmStarPlanBG, DM_STARS);
		
		bmStarPlanMid = new h2d.SpriteBatch(Settings.SLB_UI.tile);
		bmStarPlanMid.filter = true;
		bmStarPlanMid.blendMode = Add;
		root.add(bmStarPlanMid, DM_STARS);
		
		bmStarPlanFG = new h2d.SpriteBatch(Settings.SLB_UI.tile);
		bmStarPlanFG.filter = true;
		bmStarPlanFG.blendMode = Add;
		root.add(bmStarPlanFG, DM_STARS);
		
		var rndStar = new mt.RandList(Std.random);
		rndStar.add("A", 50);
		rndStar.add("B", 10);
		rndStar.add("C", 3);
		//rndStar.add("D", 1);
		
		for (i in 0...(rndStar.totalProba * 1)) {
			var t = rndStar.draw();
			var star = null;
			switch (t) {
				//case "D" : 
					//star.alpha = 1;
					//cStarPlanFG.addChild(star);
				case "C" : 
					if (Std.random(2) == 0) {
						star = Settings.SLB_UI.hbe_get(bmStarPlanFG, "star" + t);
						star.alpha = 1;
					}
					else {
						star = Settings.SLB_UI.hbe_get(bmStarPlanMid, "star" + t);
						//star.alpha = rnd(0.5, 0.8);
					}
				case "B" :
					if (Std.random(2) == 0) {
						star = Settings.SLB_UI.hbe_get(bmStarPlanBG, "star" + t);
						star.alpha = rnd(0.2, 0.4);
					}
					else {
						star = Settings.SLB_UI.hbe_get(bmStarPlanMid, "star" + t);
						star.alpha = rnd(0.5, 0.8);
					}
				case "A" : 
					star = Settings.SLB_UI.hbe_get(bmStarPlanBG, "star" + t);
					star.alpha = rnd(0.2, 0.4);
			}
			if (star == null)
				throw "STAR IS NULL MOTHAFUCKA";
			star.setCenterRatio(0.5, 0.5);
			arStar.push(star);
		}
		
	// UI
		arTP = [];
		
		SoundManager.PLAY_MENU_MUSIC();
		
		onResize();
	}
	
	override function onEvents(e:hxd.Event) {
		switch(e.kind) {
			case hxd.Event.EventKind.EPush		: onMouseLeftDown();
			case hxd.Event.EventKind.ERelease	: onMouseLeftUp();
			default								:
		}
	}
	
	function onMouseLeftDown() {
		rootMouseX = root.mouseX;
		rootMouseY = root.mouseY;
		
		mouseDragY = rootMouseY;
		mouseLeftDown = true;
		mouseDY = 0;
	}
	
	function onMouseLeftUp() {
		mouseLeftDown = false;
		
		pm.initClouds();
	}
	
	function shootingStar() {
		var hs = Settings.SLB_FX.h_getAndPlay("shootingStar", 1, true);
		hs.filter = true;
		hs.x = Std.random(Std.int(Settings.STAGE_WIDTH / 2));
		hs.y = Std.random(Settings.STAGE_HEIGHT * 0);
		hs.scaleX = hs.scaleY = Settings.STAGE_SCALE;
		hs.rotation = 3.14 / 4 + rnd(0, 3.14 / 16, true);
		bmStarPlanBG.addChild(hs);
	}
	
	override function onResize() {
	// RESIZE
		bg.scaleX = Settings.STAGE_WIDTH / bgFD.wid;
		bg.scaleY = Settings.STAGE_HEIGHT / bgFD.hei;
		
		for (tp in arTP) {
			tp.destroy();
			tp = null;
		}
		
		arTP = [];
		
		for (s in arStar) {
			s.scaleX = s.scaleY = Settings.STAGE_SCALE * s.alpha;
			var wSqr = s.width * s.width * 2;
			var b = false;
			while (!b) {
				b = true;
				s.x = Std.random(Settings.STAGE_WIDTH);
				s.y = Std.random(Settings.STAGE_HEIGHT * 1);
				for (st in arStar) {
					if (st != s && mt.deepnight.Lib.distanceSqr(s.x, s.y, st.x, st.y) < wSqr)
						b = false;
				}
			}
		}
		
		hsTitle.scaleX = hsTitle.scaleY = Settings.STAGE_SCALE;
		hsTitleLight.scaleX = hsTitleLight.scaleY = Settings.STAGE_SCALE;
		
		ButtonWorld.RESIZE();
		
	// REPLACE
		hsTitleLight.x = hsTitle.x = Std.int(Settings.STAGE_WIDTH / 2);
		hsTitleLight.y = hsTitle.y = Std.int(0 * Settings.STAGE_HEIGHT + Settings.STAGE_HEIGHT / 3);
		
		lblStart.dispose();
		lblStart = new h2d.Text(Settings.FONT_MOUSE_DECO_100);
		lblStart.filter = true;
		lblStart.textColor = 0x242424;
		#if mobile
			lblStart.text = Lang.GET_VARIOUS(TypeVarious.TVTouchToBegin);
		#else
			lblStart.text = Lang.GET_VARIOUS(TypeVarious.TVClickToBegin);
		#end
		lblStart.x = Std.int( - lblStart.textWidth * 0.5);
		cLblStart.addChild(lblStart);
		
		cLblStart.x = Std.int(Settings.STAGE_WIDTH / 2);
		cLblStart.y = Std.int(0 * Settings.STAGE_HEIGHT + Settings.STAGE_HEIGHT * 2 / 3);
		
		cWorlds.y = -(0 - actualWorldNum) * Settings.STAGE_HEIGHT;
		
		super.onResize();
		
		trace("----------------------------------------------------");
		trace("SLB_GRID : " + Settings.SLB_GRID.countChildren());
		trace("SLB_TAUPI : " + Settings.SLB_TAUPI.countChildren());
		trace("SLB_UI : " + Settings.SLB_UI.countChildren());
		trace("SLB_UI2 : " + Settings.SLB_UI2.countChildren());
		trace("SLB_FX : " + Settings.SLB_FX.countChildren());
		trace("SLB_FX2 : " + Settings.SLB_FX2.countChildren());
		trace("SLB_UNIVERS1 : " + Settings.SLB_UNIVERS1.countChildren());
		trace("SLB_UNIVERS2 : " + Settings.SLB_UNIVERS2.countChildren());
		trace("SLB_LEVELS1 : " + Settings.SLB_LEVELS1.countChildren());
		trace("SLB_NOTRIM : " + Settings.SLB_NOTRIM.countChildren());
		trace("SLB_LANG : " + Settings.SLB_LANG.countChildren());
		trace("SLB_FONT_BIRM : " + Settings.SLB_FONT_BIRM.countChildren());
		trace("SLB_FONT_BENCH : " + Settings.SLB_FONT_BENCH.countChildren());
	}
	
	override function unregister() {
		bg.dispose();
		bg = null;
		
		for (s in arStar) {
			s.dispose();
			s = null;
		}
		
		tpLblStart.destroy();
		tpLblStart = null;
		
		hsTitle.dispose();
		hsTitle = null;
		
		hsTitleLight.dispose();
		hsTitleLight = null;
		
		lblStart.dispose();
		lblStart = null;
		
		tweener.dispose();
		tweener = null;
		
		ME = null;
		
		super.unregister();
	}
	
	override function update() {
		tweener.update();
		
		//trace(cWorlds.y);
		
		bmStarPlanBG.y = cWorlds.y / 8;
		bmStarPlanMid.y = cWorlds.y / 6;
		bmStarPlanFG.y = cWorlds.y / 4;
		
		//if (!cd.hasSet("star", (1) * Settings.FPS))
		if (!cd.hasSet("star", (Std.random(2) + 1) * Settings.FPS))
			shootingStar();
		
		ButtonWorld.UPDATE();
		
		Settings.SLB_FX.updateChildren();
		
		super.update();
	}
}