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
class Home extends HProcess // WITH WORLD
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
	var heiFX				: Int;
	var fxLeft				: HSprite;
	var fxRight				: HSprite;
	
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
	var numPlanet			: Int;
	var actualWorldNum		: Int;
	
	var heiNavBG			: Int;
	var navBGUp				: HSprite;
	var navBGDown			: HSprite;
	var arrowUp				: HSprite;
	var arrowDown			: HSprite;
	var initYArrowUp		: Int;
	var initYArrowDown		: Int;
	
	var lblChoose			: Text;
	
	public var tweener		: mt.motion.Tweener;
	var t					: mt.motion.Tween;
	var tpLblStart			: mt.deepnight.TinyProcess;
	
	var isAnimated			: Bool;
	var isHome				: Bool;
	
	var prct				: Float;
	
	// Drag'n'drop
	var previousCWorldY		: Float;
	public var rootMouseX	: Float;
	public var rootMouseY	: Float;
	
	var mouseDragY			: Float;
	var mouseDY				: Float;
	var mouseLeftDown		: Bool;
	var hasMoved			: Bool;
	
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
		
		heiFX = Settings.SLB_UI.getFrameData("fxLeft").hei;
		fxLeft = Settings.SLB_UI.h_get("fxLeft");
		fxLeft.blendMode = h2d.BlendMode.SoftOverlay;
		fxLeft.filter = true;
		root.add(fxLeft, DM_BG);
		
		fxRight = Settings.SLB_UI.h_get("fxRight");
		fxRight.setCenterRatio(1, 0);
		fxRight.blendMode = h2d.BlendMode.SoftOverlay;
		fxRight.filter = true;
		root.add(fxRight, DM_BG);
		
		fxLeft.alpha = fxRight.alpha = 0.2;
		
	// WORLDS
		cWorlds = new Sprite();
		root.add(cWorlds, DM_PLANET);
		
		hsTitleLight = Settings.SLB_UI2.h_get("logoBg");
		hsTitleLight.setCenterRatio(0.5, 0.5);
		hsTitleLight.filter = true;
		cWorlds.addChild(hsTitleLight);
		
		hsTitle = Settings.SLB_UI3.h_get("logo");
		hsTitle.setCenterRatio(0.5, 0.5);
		hsTitle.filter = true;
		hsTitle.hasFXAA = true;
		cWorlds.addChild(hsTitle);
		
		cLblStart = new h2d.Sprite(cWorlds);
		lblStart = new h2d.Text(Settings.FONT_MOUSE_DECO_66);
		lblStart.filter = true;
		lblStart.textColor = 0xF6EFD0;
		lblStart.text = "Press Start";
		cLblStart.addChild(lblStart);
		
		tpLblStart = createTinyProcess();
		tpLblStart.onUpdate = function() {
			cLblStart.scaleX = 1 + Math.sin(this.time / 10) / 50;
			cLblStart.scaleY = 1 + Math.sin(this.time / 10) / 50;
		}
		
		actualWorldNum = 0;
		
		for (w in World.createAll()) {
			var btnPlanet = new ui.ButtonWorld(w, this);
			cWorlds.addChild(btnPlanet);
		}
		
		numPlanet = ButtonWorld.ALL.length;
		
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
		
		for (i in 0...(rndStar.totalProba * numPlanet)) {
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
		navBGUp = Settings.SLB_UI.h_get("arrowNavBg");
		navBGUp.setCenterRatio(0.5, 1);
		navBGUp.filter = true;
		navBGUp.alpha = 0;
		root.add(navBGUp, DM_UI);
		
		navBGDown = Settings.SLB_UI.h_get("arrowNavBg");
		navBGDown.setCenterRatio(0.5, 1);
		navBGDown.filter = true;
		navBGDown.alpha = 0;
		root.add(navBGDown, DM_UI);
		
		arrowUp = Settings.SLB_UI.h_get("arrowNav");
		arrowUp.setCenterRatio(0.5, 0.5);
		arrowUp.filter = true;
		arrowUp.alpha = 0;
		root.add(arrowUp, DM_UI);
		var tp1 = createTinyProcess();
		tp1.onUpdate = function () {
			arrowUp.y = initYArrowUp + Math.sin(tp1.time / 10) * 5;
		};
		
		arrowDown = Settings.SLB_UI.h_get("arrowNav");
		arrowDown.setCenterRatio(0.5, 0.5);
		arrowDown.filter = true;
		arrowDown.alpha = 0;
		root.add(arrowDown, DM_UI);
		var tp2 = createTinyProcess();
		tp2.onUpdate = function () {
			arrowDown.y = initYArrowDown + Math.sin(tp2.time / 10) * 5;
		};
		
		lblChoose = new Text(Settings.FONT_MOUSE_DECO_36);
		lblChoose.alpha = 0;
		lblChoose.text = Lang.GET_VARIOUS(TypeVarious.TVChoosePlanet);
		lblChoose.filter = true;
		root.add(lblChoose, DM_UI);
	
		isAnimated = false;
		isHome = true;
		
		hasMoved = false;
		
		arTP = [];
		
		SoundManager.PLAY_MENU_MUSIC();
		
		onResize();
	}
	
	override function onEvents(e:hxd.Event) {
		switch(e.kind) {
			case hxd.Event.EventKind.EPush		: onMouseLeftDown();
			case hxd.Event.EventKind.ERelease	: onMouseLeftUp();
			case hxd.Event.EventKind.EWheel		: onWheel(e.wheelDelta);
			default								:
		}
	}
	
	function onMouseLeftDown() {
		rootMouseX = root.mouseX;
		rootMouseY = root.mouseY;
		
		mouseDragY = rootMouseY;
		mouseLeftDown = true;
		mouseDY = 0;
		
		previousCWorldY = cWorlds.y;
	}
	
	function onMouseLeftUp() {
		mouseLeftDown = false;
		
		if (isHome) {
			isAnimated = true;
			
			actualWorldNum = 1;
			
			if (lblStart.alpha == 1)
				tweener.create().to((DURATION_TRANSITION * Settings.FPS) / 2, lblStart.alpha = 0);
			
			tweener.create().to(DURATION_TRANSITION * Settings.FPS * 2, cWorlds.y = -(numPlanet - actualWorldNum) * Settings.STAGE_HEIGHT).ease(mt.motion.Ease.easeInQuad).onComplete = function () {
				isAnimated = false;
				isHome = false;
				showArrows(true);
				previousCWorldY = cWorlds.y;
				tweener.create().to(0.2 * Settings.FPS, lblChoose.alpha = 1);
			};
		}
		else {
			if (!hasMoved)
				updateTransition(true);
		}
		
		hasMoved = false;
	}
	
	function onWheel(d:Float) {
		if (!isAnimated) {
			if (isHome) {
				isAnimated = true;
				
				actualWorldNum = 1;
				
				if (lblStart.alpha == 1)
					tweener.create().to((DURATION_TRANSITION * Settings.FPS) / 2, lblStart.alpha = 0);
					
				tweener.create().to(DURATION_TRANSITION * Settings.FPS * 2, cWorlds.y = -(numPlanet - actualWorldNum) * Settings.STAGE_HEIGHT).ease(mt.motion.Ease.easeInQuad).onComplete = function () {
					isAnimated = false;
					isHome = false;
					showArrows(true);
					previousCWorldY = cWorlds.y;
					tweener.create().to(0.2 * Settings.FPS, lblChoose.alpha = 1);
				};
			}
			else if (d > 0 && actualWorldNum > 1) {
				actualWorldNum--;
				animTransition(true);
			}
			else if (d < 0 && actualWorldNum < numPlanet) {
				actualWorldNum++;
				animTransition(true);
			}
		}
	}
	
	public function gotoWorld(w:World) {
		if (!hasMoved && !isAnimated) {
			switch(w) {
				case World.WEarth	:
					tweener.create().to(1 * Settings.FPS, ButtonWorld.ALL[actualWorldNum - 1].scaleX = 6, ButtonWorld.ALL[actualWorldNum - 1].scaleY = 6);
					pm.initClouds();
				case World.WMoon	:
			}			
		}
	}
	
	function animTransition(isBtn:Bool = false) {
		mouseLeftDown = false;
		
		prct = (((numPlanet - actualWorldNum) * Settings.STAGE_HEIGHT) + cWorlds.y) / (Settings.STAGE_HEIGHT);
		
		if (prct != 0 || isBtn) {
			var r = prct > 0 ? prct : -prct;
			r *= 2;
			
			if (isBtn || r > 1)
				r = 1;
				
			isAnimated = true;
			hasMoved = true;
			
			SoundManager.CLOUDS_SFX();
			
			t = tweener.create();
			t.to(DURATION_TRANSITION * Settings.FPS * r, cWorlds.y = -(numPlanet - actualWorldNum) * Settings.STAGE_HEIGHT).ease(mt.motion.Ease.easeOutQuad).onComplete = function () {
				isAnimated = false;
				hasMoved = false;
				mouseDY = 0;
				previousCWorldY = cWorlds.y;
				if (ButtonWorld.ALL[actualWorldNum - 1].isLocked)
					lblChoose.text = Lang.GET_VARIOUS(TypeVarious.TVComingSoon);
				else
					lblChoose.text = Lang.GET_VARIOUS(TypeVarious.TVChoosePlanet);
				lblChoose.x = Std.int(Settings.STAGE_WIDTH - lblChoose.textWidth) / 2;
			};
		}
	}
	
	function showArrows(up:Bool) {
		if (up && arrowUp.alpha == 0) {
			tweener.create().to(0.2 * Settings.FPS, arrowUp.alpha = 1);
			tweener.create().to(0.2 * Settings.FPS, navBGUp.alpha = 1);
		}
		else if (!up && arrowDown.alpha == 0) {
			tweener.create().to(0.2 * Settings.FPS, arrowDown.alpha = 1);
			tweener.create().to(0.2 * Settings.FPS, navBGDown.alpha = 1);
		}
	}
	
	function hideArrows(up:Bool) {
		if (up && arrowUp.alpha == 1) {
			tweener.create().to(0.2 * Settings.FPS, arrowUp.alpha = 0);
			tweener.create().to(0.2 * Settings.FPS, navBGUp.alpha = 0);
		}
		else if (!up && arrowDown.alpha == 1) {
			tweener.create().to(0.2 * Settings.FPS, arrowDown.alpha = 0);
			tweener.create().to(0.2 * Settings.FPS, navBGDown.alpha = 0);
		}
	}
	
	function shootingStar() {
		var hs = Settings.SLB_FX.h_getAndPlay("shootingStar", 1, true);
		hs.filter = true;
		hs.x = Std.random(Std.int(Settings.STAGE_WIDTH / 2));
		hs.y = Std.random(Settings.STAGE_HEIGHT * numPlanet);
		hs.scaleX = hs.scaleY = Settings.STAGE_SCALE;
		hs.rotation = 3.14 / 4 + rnd(0, 3.14 / 16, true);
		bmStarPlanBG.addChild(hs);
		
		SoundManager.SHOOTING_STAR_SFX();
	}
	
	override function onResize() {
	// RESIZE
		bg.scaleX = Settings.STAGE_WIDTH / bgFD.wid;
		bg.scaleY = Settings.STAGE_HEIGHT / bgFD.hei;
		
		fxLeft.scaleX = Settings.STAGE_SCALE;
		fxLeft.scaleY = Settings.STAGE_HEIGHT / heiFX;
		fxRight.scaleX = Settings.STAGE_SCALE;
		fxRight.scaleY = Settings.STAGE_HEIGHT / heiFX;
		
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
				s.y = Std.random(Settings.STAGE_HEIGHT * numPlanet);
				for (st in arStar) {
					if (st != s && mt.deepnight.Lib.distanceSqr(s.x, s.y, st.x, st.y) < wSqr)
						b = false;
				}
			}
		}
		
		hsTitle.scaleX = hsTitle.scaleY = Settings.STAGE_SCALE;
		hsTitleLight.scaleX = hsTitleLight.scaleY = Settings.STAGE_SCALE;
		
		heiNavBG = Std.int(Settings.SLB_UI.getFrameData("arrowNavBg").hei * Settings.STAGE_SCALE);
		
		navBGUp.scaleX = Settings.STAGE_SCALE;
		navBGUp.scaleY = -Settings.STAGE_SCALE;
		navBGDown.scaleX = navBGDown.scaleY = Settings.STAGE_SCALE;
		
		arrowUp.scaleX = arrowUp.scaleY = Settings.STAGE_SCALE;
		arrowDown.scaleX = Settings.STAGE_SCALE;
		arrowDown.scaleY = -Settings.STAGE_SCALE;
		
		ButtonWorld.RESIZE();
		
	// REPLACE
		fxRight.x = Settings.STAGE_WIDTH;
		
		navBGUp.x = navBGDown.x = Std.int(Settings.STAGE_WIDTH / 2);
		navBGDown.y = Std.int(Settings.STAGE_HEIGHT);
		
		initYArrowUp = Std.int(arrowUp.height);
		arrowUp.x = Std.int((Settings.STAGE_WIDTH) / 2);
		arrowUp.y = initYArrowUp;
		
		initYArrowDown = Std.int(Settings.STAGE_HEIGHT - arrowDown.height);
		arrowDown.x = Std.int((Settings.STAGE_WIDTH) / 2);
		arrowDown.y = initYArrowDown;
		
		hsTitleLight.x = hsTitle.x = Std.int(Settings.STAGE_WIDTH / 2);
		hsTitleLight.y = hsTitle.y = Std.int(numPlanet * Settings.STAGE_HEIGHT + Settings.STAGE_HEIGHT / 3);
		
		lblStart.dispose();
		lblStart = new h2d.Text(Settings.FONT_MOUSE_DECO_66);
		lblStart.filter = true;
		lblStart.textColor = 0x242424;
		#if mobile
			lblStart.text = "Touch to begin";
			lblStart.text = Lang.GET_VARIOUS(TypeVarious.TVTouchToBegin);
		#else
			lblStart.text = Lang.GET_VARIOUS(TypeVarious.TVClickToBegin);
		#end
		lblStart.x = Std.int( - lblStart.textWidth * 0.5);
		cLblStart.addChild(lblStart);
		
		cLblStart.x = Std.int(Settings.STAGE_WIDTH / 2);
		cLblStart.y = Std.int(numPlanet * Settings.STAGE_HEIGHT + Settings.STAGE_HEIGHT * 2 / 3);
		
		var prevAlpha = lblChoose.alpha;
		lblChoose.dispose();
		lblChoose = new Text(Settings.FONT_MOUSE_DECO_36);
		lblChoose.filter = true;
		lblChoose.alpha = prevAlpha;
		lblChoose.text = Lang.GET_VARIOUS(TypeVarious.TVChoosePlanet);
		lblChoose.x = Std.int(Settings.STAGE_WIDTH - lblChoose.textWidth) / 2;
		lblChoose.y = Std.int(Settings.STAGE_HEIGHT - heiNavBG * 2);
		root.add(lblChoose, DM_UI);
		
		cWorlds.y = -(numPlanet - actualWorldNum) * Settings.STAGE_HEIGHT;
		
		super.onResize();
	}
	
	override function unregister() {
		bg.dispose();
		bg = null;
		
		fxLeft.dispose();
		fxLeft = null;
		
		fxRight.dispose();
		fxRight = null;
		
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
		
		ButtonWorld.DESTROY();
		
		navBGUp.dispose();
		navBGUp = null;
		
		navBGDown.dispose();
		navBGDown = null;
		
		arrowUp.dispose();
		arrowUp = null;
		
		arrowDown.dispose();
		arrowDown = null;
		
		lblChoose.dispose();
		lblChoose = null;
		
		tweener.dispose();
		tweener = null;
		
		ME = null;
		
		super.unregister();
	}
	
	override function update() {
		tweener.update();
		
		trace(cWorlds.y);
		
		bmStarPlanBG.y = cWorlds.y / 8;
		bmStarPlanMid.y = cWorlds.y / 6;
		bmStarPlanFG.y = cWorlds.y / 4;
		
		rootMouseX = root.mouseX;
		rootMouseY = root.mouseY;
		
		if (!isHome) {
			if (!isAnimated
			&&	mouseLeftDown
			&&	rootMouseX > 0
			&&	rootMouseX < Settings.STAGE_WIDTH
			&&	rootMouseY > 0
			&&	rootMouseY < Settings.STAGE_HEIGHT) {
				cWorlds.y += rootMouseY - mouseDragY;
				
				mouseDragY = rootMouseY;
			}
			
			if (cWorlds.y < -Settings.STAGE_HEIGHT * (numPlanet - 1))
				cWorlds.y = -Settings.STAGE_HEIGHT * (numPlanet - 1);
			else if (cWorlds.y > 0)
				cWorlds.y = 0;
			
			updateTransition();
			
			//prct = (((numPlanet - actualWorldNum) * Settings.STAGE_HEIGHT) + cWorlds.y) / (Settings.STAGE_HEIGHT);
			
			//if (prct >= 0)
				//ButtonWorld.ALL[actualWorldNum - 1].rotation = 3.14 * 2 * prct;
				
			if (actualWorldNum == numPlanet)	hideArrows(true);
			else								showArrows(true);
			
			if (actualWorldNum == 1)			hideArrows(false);
			else								showArrows(false);
		}
		
		//if (!cd.hasSet("star", (1) * Settings.FPS))
		if (!cd.hasSet("star", (Std.random(2) + 1) * Settings.FPS))
			shootingStar();
		
		ButtonWorld.UPDATE();
		
		Settings.SLB_FX.updateChildren();
		
		super.update();
	}
	
	function updateTransition(mouseUp:Bool = false) {
		var newAWN = numPlanet - Std.int(( -cWorlds.y + Settings.STAGE_HEIGHT / 2) / Settings.STAGE_HEIGHT);
		if (!isAnimated) {
			if (newAWN != actualWorldNum) {
				actualWorldNum = newAWN;
				animTransition();
			}
			else if (mouseUp) {
				if ((cWorlds.y - previousCWorldY > 100 * Settings.STAGE_SCALE
				||	rootMouseY < (heiNavBG * 1.5))
				&&	actualWorldNum < numPlanet) {
					actualWorldNum++;
				}
				else if ((cWorlds.y - previousCWorldY < -100 * Settings.STAGE_SCALE
				||	rootMouseY > Settings.STAGE_HEIGHT - (heiNavBG * 1.5))
				&&	actualWorldNum > 1) {
					actualWorldNum--;
				}
				animTransition();
			}
		}
	}
}