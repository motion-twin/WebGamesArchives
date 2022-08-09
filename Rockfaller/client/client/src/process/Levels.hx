package process;

import h2d.Sprite;
import h2d.SpriteBatch;

import mt.deepnight.HParticle;
import mt.deepnight.deprecated.HProcess;
import mt.deepnight.slb.HSprite;
import mt.deepnight.slb.HSpriteBE;

import Common;

import ui.ButtonLevel;
import data.Settings;
import data.LevelDesign;
import data.DataManager;
import manager.AssetManager;
import manager.LifeManager;
import manager.SoundManager;

/**
 * ...
 * @author Tipyx
 */
class Levels extends HProcess implements ProcessManaged
{
	public static var ME	: Levels;

	var pm					: process.ProcessManager;

	public var tweener		: mt.motion.Tweener;

	static var num					: Int	= 0;
	static var DM_BG				: Int	= num++;
	static var DM_SONAR				: Int	= num++;
	static var DM_BTN				: Int	= num++;

	var cMap				: h2d.Layers;

	var txtBeginning		: HSprite;
	var beginHeight 		: Int;
	var arBG				: Array<WorldBitmap>;

	public var bmText		: h2d.SpriteBatch;
	public var bmWay		: h2d.SpriteBatch;
	public var bmMap		: h2d.SpriteBatch;
	public var bmMapOver	: h2d.SpriteBatch;
	var bmBand				: h2d.SpriteBatch;
	var bmFriend			: h2d.SpriteBatch;
	var arFriend			: Array<{hbe:HSpriteBE, bmp:h2d.Bitmap, f:FriendData}>;
	var arAddBand			: Array<HSpriteBE>;

	public var bmFX			: h2d.SpriteBatch;
	public var poolFX		: Array<HParticle>;
	public var bmMapFX		: h2d.SpriteBatch;
	public var poolMapFX	: Array<HParticle>;

	public var arWay		: Array<HSpriteBE>;

	var scaling				: Float;
	var bgScaling			: Float;

	public var uiBottom		: ui.bottom.UIBottomLevels;

	var fxSonar				: HSprite;
	var hsTaupi				: HSprite;
	var hsCanon				: HSprite;

	var arCloud				: Array<HSprite>;
	var cloud1				: HSprite;
	var cloud2				: HSprite;
	var cloud3				: HSprite;
	var messageEnd			: HSprite;
	var hsTopArrow			: ui.Button;
	var hsDownArrow			: ui.Button;

	// Drag'n'drop
	public var rootMouseX	: Float;
	public var rootMouseY	: Float;

	var mouseDragY			: Float;
	var mouseDY				: Float;
	public var mouseLeftDown: Bool;

	var levelFocus			: Int;
	var transition			: Bool;

	var heightMax			: Float;

	var isTweening			: Bool;

	public var lastLevelClicked	: Int;

	var deltaWheel			: Float;

	public var isReady		= false;
	
	public var arLevel					: Array<LevelInfo>;
	public var slbLevels				: mt.deepnight.slb.BLib;
	public var offsetLvl				: Int;
	public var worldZone				: Int;
	static var MAX_WORLD_ZONE			= 2;

	public function new(levelFocus:Int, transition:Bool) {
		ME = this;
		
		this.transition = transition;
		this.levelFocus = levelFocus;
		
		arLevel = [];
		
		MAX_WORLD_ZONE = Std.int((LevelDesign.MAX_LEVEL_CLIENT - 1) / 120) + 1;
		
		if (levelFocus >= LevelDesign.MAX_LEVEL_CLIENT)
			levelFocus = LevelDesign.MAX_LEVEL_CLIENT;
		
		if (levelFocus <= 120) {
			slbLevels = Settings.SLB_LEVELS1;
			offsetLvl = 0;
			worldZone = 0;
			for (i in 0...120)
				if (LevelDesign.AR_LEVEL[i] != null)
					arLevel.push(LevelDesign.AR_LEVEL[i]);
		}
		else if (levelFocus <= 240) {
			slbLevels = Settings.SLB_LEVELS2;
			offsetLvl = 120;
			worldZone = 1;
			for (i in 120...240)
				if (LevelDesign.AR_LEVEL[i] != null)
					arLevel.push(LevelDesign.AR_LEVEL[i]);
		}

		pm = process.ProcessManager.ME;

		super(pm);
		
		LifeManager.SET_LIFE();

		tweener = new mt.motion.Tweener();

		cMap = new h2d.Layers();
		root.add(cMap, 0);

		lastLevelClicked = 0;

		deltaWheel = 0;

	// BG
		arBG = [];

		scaling = mt.Metrics.w() / AssetManager.WIDTH;
		var worlds = AssetManager.WORLDS[worldZone];
		for( w in worlds ) {
			if( w.minLevel > data.LevelDesign.MAX_LEVEL_CLIENT )
				continue;

			var bmp = AssetManager.GET_BD(w.id);
			cMap.add(bmp, DM_BG);
			arBG.push( bmp );
		}
		bgScaling = mt.Metrics.w() / AssetManager.BG_WIDTH;
		for( bmp in arBG )
			bmp.setScale( bgScaling );

		if (worldZone == 0) {
			txtBeginning = Settings.SLB_LANG.h_get("beginning_" + (Settings.SLB_LANG_IS_DL ? data.Lang.LANG : "en"));
			txtBeginning.scaleX = txtBeginning.scaleY = scaling #if !standalone / 0.65 #end;
			txtBeginning.blendMode = Add;
			//txtBeginning.filter = true;
			cMap.add(txtBeginning, DM_BG);
		}

	// CLOUDS END
		arCloud = [];

		cloud1 = Settings.SLB_UI2.h_get("cloud");
		cloud1.setCenterRatio(0.25, 0.35);
		cMap.add(cloud1, DM_BG);
		arCloud.push(cloud1);

		cloud3 = Settings.SLB_UI2.h_get("cloud");
		cloud3.setCenterRatio(0.75, 0.35);
		cMap.add(cloud3, DM_BG);
		arCloud.push(cloud3);

		cloud2 = Settings.SLB_UI2.h_get("cloud");
		cloud2.setCenterRatio(0.5, 0.60);
		cMap.add(cloud2, DM_BG);
		arCloud.push(cloud2);
		
		if (worldZone == MAX_WORLD_ZONE - 1) {
			messageEnd = Settings.SLB_LANG.h_get("endTxt_" + (Settings.SLB_LANG_IS_DL ? data.Lang.LANG : "en"));
			messageEnd.setCenterRatio(0.5, -0.4);
			cMap.add(messageEnd, DM_BG);
			arCloud.push(messageEnd);			
		}

	// Levels
		bmWay = new SpriteBatch(slbLevels.tile);
		bmWay.optimizeForStatic(true);
		cMap.add(bmWay, DM_BG);
		
		bmMap = new SpriteBatch(slbLevels.tile);
		bmMap.optimizeForStatic(true);
		cMap.add(bmMap, DM_BTN);

		bmMapOver = new SpriteBatch(slbLevels.tile);
		bmMapOver.blendMode = Add;
		cMap.add(bmMapOver, DM_BTN);

		bmFX = new SpriteBatch(Settings.SLB_FX.tile);
		bmFX.filter = true;
		bmFX.blendMode = Add;
		root.add(bmFX, 1);

		poolFX = HParticle.initPool(bmFX, 500);

		bmMapFX = new SpriteBatch(Settings.SLB_FX.tile);
		cMap.add(bmMapFX, DM_SONAR);

		poolMapFX = HParticle.initPool(bmMapFX, 50);

		arWay = [];
		
		for (l in arLevel) {
			var hsWay = slbLevels.hbe_get(bmWay, "wayLevel", l.level - 1 - offsetLvl);
			hsWay.scaleX = hsWay.scaleY = scaling;
			hsWay.setCenterRatio(0, 1);
			arWay[l.level] = hsWay;

			var btnLevel = new ButtonLevel(l.level, this, scaling);
			function onClickBtnLevel() {
				showPopUp(btnLevel.numLevel);
			}
			btnLevel.onClick = onClickBtnLevel;
			cMap.add(btnLevel, DM_BTN);
		}
		
		if (LevelDesign.FRIENDS.length > 0) {
			bmBand = new SpriteBatch(Settings.SLB_UI.tile);
			bmBand.blendMode = Add;
			cMap.add(bmBand, DM_SONAR);
			
			bmFriend = new SpriteBatch(Settings.SLB_UI.tile);
			cMap.add(bmFriend, DM_SONAR);
			
			arFriend = [];
			arAddBand = [];
			
			for (f in LevelDesign.FRIENDS) {
				//trace(f);
				if (arWay[f.levelMax - 1] != null) {
					var hsBgAvatar = Settings.SLB_UI.hbe_get(bmFriend, "uiBgAvatar");
					hsBgAvatar.setCenterRatio(0.5, 0.5);
					hsBgAvatar.x = 50;
					hsBgAvatar.y = arWay[f.levelMax - 1].y;
					var bmpAvatar = null;
					arFriend.push( { hbe:hsBgAvatar, bmp:bmpAvatar, f:f } );					
				}
			}
		}
		
		hsTaupi = Settings.SLB_UI.h_getAndPlay("exportMapTaupi");
		hsTaupi.a.setGeneralSpeed(2);
		hsTaupi.filter = true;
		hsTaupi.setCenterRatio(0.5, 0.5);
		cMap.add(hsTaupi, DM_SONAR);

		if (worldZone == 0) {
			hsCanon = Settings.SLB_UI.h_get("canon");
			hsCanon.filter = true;
			hsCanon.scaleX = hsCanon.scaleY = scaling;
			cMap.add(hsCanon, DM_SONAR);			
		}

		fxSonar = Settings.SLB_FX.h_getAndPlay("fxSonar");
		fxSonar.filter = true;
		fxSonar.setCenterRatio(0.5, 0.5);
		fxSonar.blendMode = Add;
		if (LevelDesign.USER_DATA.arHighScore[LevelDesign.AR_LEVEL.length] != null)
			fxSonar.visible = false;
		cMap.add(fxSonar, DM_SONAR);
		
		if (worldZone < MAX_WORLD_ZONE - 1) {
			hsTopArrow = new ui.Button("warp", function () {
				var levelAsked = (worldZone + 1) * 120 + 1;
				ProcessManager.ME.goTo(this, Levels, [levelAsked, false]);
			});
			cMap.add(hsTopArrow, DM_BTN);
			
			createTinyProcess(function (p) {
				hsTopArrow.y = -heightMax + cloud1.height * 0.25 + 10 * Settings.STAGE_SCALE * Math.sin(p.time / 10);
			});
		}
		
		if (worldZone > 0) {
			hsDownArrow = new ui.Button("warp", function () {
				var levelAsked = (worldZone) * 120;
				ProcessManager.ME.goTo(this, Levels, [levelAsked, false]);
			});
			hsDownArrow.rotation = 3.14;
			cMap.add(hsDownArrow, DM_BTN);
			
			createTinyProcess(function (p) {
				hsDownArrow.y = -cloud1.height * 0.15 + 10 * Settings.STAGE_SCALE * Math.sin(p.time / 10);
			});
		}

	// UI
		uiBottom = new ui.bottom.UIBottomLevels();
		root.addChild(uiBottom);

		onResize();

		if (arWay[levelFocus - 1] == null || arWay[levelFocus] == null)
			levelFocus = LevelDesign.GET_MAXLEVEL();

		isTweening = false;
		
		SoundManager.PLAY_MENU_MUSIC();
	}
	
	public function onReady() {
		if (arWay[levelFocus - 2] == null || arWay[levelFocus - 1] == null)
			return;
		
		if (transition) {
			cMap.y = Settings.STAGE_HEIGHT / 2 - arWay[levelFocus - 1].y;
			setMap();
			var nextY = Settings.STAGE_HEIGHT / 2 - arWay[levelFocus].y;
			if (nextY >= Settings.STAGE_HEIGHT - beginHeight && nextY <= heightMax) {
				isTweening = true;
				var t = tweener.create();
				t.to(1 * Settings.FPS, cMap.y = nextY);
				function onCompleteTweenTransitionLevels() {
					setMap();
					isTweening = false;
					if (levelFocus <= LevelDesign.USER_DATA.levelMax && LevelDesign.GET_LIFE() > 0)
						showPopUp(levelFocus);
				#if standalone
					else if (!LevelDesign.USER_DATA.flags.has(UserFlags.UFPlayMobile) && LevelDesign.GET_LIFE() <= 0)
						process.ProcessManager.ME.showAskMobile(Levels.ME);
				#end
				}
				t.onComplete = onCompleteTweenTransitionLevels;				
			}
		}
		else {
			cMap.y = Settings.STAGE_HEIGHT / 2 - arWay[levelFocus - 1].y;
			setMap();
			if (!LevelDesign.USER_DATA.flags.has(UserFlags.UFPlayMobile) && LevelDesign.GET_LIFE() <= 0)
					process.ProcessManager.ME.showAskMobile(Levels.ME);
		}
		
		#if standalone
		if (!mt.device.User.isLogged()) {
			if (levelFocus == 5 || levelFocus == 10)
				process.ProcessManager.ME.showAskLog(this, true);
		}
		#end
	}
	
	function setMap() {
		if( cMap.y < Settings.STAGE_HEIGHT - beginHeight )
			cMap.y = Settings.STAGE_HEIGHT - beginHeight;
		else if( cMap.y > heightMax )
			cMap.y = heightMax;			
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
	}

	function onMouseLeftUp() {
		mouseLeftDown = false;
	}

	function onWheel(d:Float) {
		deltaWheel += d;
	}

	function showPopUp(numLevel:Int) {
		if (!isTweening) {
			lastLevelClicked = numLevel;
			#if debug
				new process.popup.GoalLevels(LevelDesign.GET_LEVEL(numLevel), false);
				return;
			#end
			#if standalone
			if (!mt.device.User.isLogged() && numLevel >= 16)
				process.ProcessManager.ME.showAskLog(this, false);
			else #end if (numLevel <= LevelDesign.USER_DATA.levelMax && LevelDesign.GET_LIFE() > 0)
				new process.popup.GoalLevels(LevelDesign.GET_LEVEL(numLevel), false);
			else if (LevelDesign.GET_LIFE() == 0) {
				process.ProcessManager.ME.showLife(Levels.ME);
			}
		}
	}

	override function onResize() {
		scaling = mt.Metrics.w() / AssetManager.WIDTH;
		bgScaling = mt.Metrics.w() / AssetManager.BG_WIDTH;

		if (txtBeginning != null)
			txtBeginning.scaleX = txtBeginning.scaleY = scaling #if !standalone / 0.65 #end;
		
		bmWay.invalidate();
		bmMap.invalidate();

		var posY : Int = 0;

		var first = true;
		for ( bg in arBG ) {
			bg.scaleX = bg.scaleY = bgScaling;

			var h : Int = Math.floor( bg.height );
			bg.height = h;
			bg.scaleX = bg.scaleY;

			if (first && worldZone == 0) {
				posY = beginHeight = h-1;
				first = false;
			}

			bg.y = posY - h;
			posY -= (h - 1);
		}

		heightMax = -posY;

		var lastPosBG = 0.;

		for (hsWay in arWay) {
			if (hsWay != null) {
				hsWay.scaleX = hsWay.scaleY = scaling;
				hsWay.y = lastPosBG;
				lastPosBG -= Std.int(hsWay.height);				
			}
		}

		cloud1.scaleX = cloud1.scaleY = Settings.STAGE_SCALE * 2;
		cloud1.y = -heightMax;

		cloud3.scaleX = cloud3.scaleY = Settings.STAGE_SCALE * 2;
		cloud3.x = Settings.STAGE_WIDTH;
		cloud3.y = -heightMax;

		cloud2.scaleX = cloud2.scaleY = Settings.STAGE_SCALE * 2;
		cloud2.x = Settings.STAGE_WIDTH * 0.5;
		cloud2.y = -heightMax;

		if (messageEnd != null) {
			messageEnd.scaleX = messageEnd.scaleY = Settings.STAGE_SCALE #if !standalone / 0.65 #end;
			messageEnd.x = Settings.STAGE_WIDTH * 0.5;
			messageEnd.y = -heightMax;
		}
		
		if (hsTopArrow != null) {
			hsTopArrow.resize();
			hsTopArrow.x = Std.int((Settings.STAGE_WIDTH - hsTopArrow.w) * 0.5);	
		}
		
		if (hsDownArrow != null) {
			hsDownArrow.resize();
			hsDownArrow.x = Std.int((Settings.STAGE_WIDTH + hsDownArrow.w) * 0.5);	
		}
		
		if (bmText != null)
			bmText.dispose();
		bmText = new h2d.SpriteBatch(Settings.FONT_MOUSE_DECO_66.tile);
		cMap.add(bmText, DM_BTN);

		ButtonLevel.RESIZE(scaling);
		
		var arTemp:Array<Null<Int>> = [];
		
		function setAvatarFriend(f: { hbe:HSpriteBE, bmp:h2d.Bitmap, f:FriendData } ) {
			if (arTemp[f.f.levelMax] < 2) {
				var xBtn = ButtonLevel.ALL[f.f.levelMax].x;
				if (arTemp[f.f.levelMax] == 0) {
					var hs = Settings.SLB_UI.hbe_get(bmBand, "fxBottom_a");
					hs.setCenterRatio(0.5, 1);
					hs.scaleX = scaling * 3;
					hs.scaleY = scaling * 0.5;
					hs.alpha = 0.4;
					hs.x = xBtn;
					hs.y = arWay[f.f.levelMax].y - arWay[f.f.levelMax].height;
					hs.rotation = xBtn > Settings.STAGE_WIDTH * 0.5 ? -3.14 * 0.5 : 3.14 * 0.5;
					arAddBand.push(hs);
				}
				
				f.hbe.visible = true;
				
				f.hbe.scaleX = f.hbe.scaleY = scaling * 0.75;
				f.hbe.y = arWay[f.f.levelMax].y - arWay[f.f.levelMax].height;
				var xBtn = ButtonLevel.ALL[f.f.levelMax].x;
				if (xBtn > Settings.STAGE_WIDTH  * 0.5)
					f.hbe.x = xBtn - f.hbe.width * (2 + arTemp[f.f.levelMax] * 1.5);
				else
					f.hbe.x = xBtn + f.hbe.width * (2 + arTemp[f.f.levelMax] * 1.5);
				
				f.bmp.scaleX = f.hbe.width / f.bmp.tile.width * 0.9;
				f.bmp.scaleY = f.hbe.height / f.bmp.tile.height * 0.9;
				f.bmp.x = f.hbe.x;
				f.bmp.y = f.hbe.y;
				
				arTemp[f.f.levelMax]++;				
			}
		}
		
		if (arFriend != null) {
			for (b in arAddBand) {
				b.dispose();
				b = null;
			}
			
			arAddBand = [];
			
			for (f in arFriend) {
				if (arTemp[f.f.levelMax] == null)
					arTemp[f.f.levelMax] = 0;
				
				f.hbe.visible = false;
				if (f.f.avatar != null) {
					if (f.bmp != null) {
						setAvatarFriend(f);
					}
					else {
						DataManager.DOWNLOAD_AVATAR(this, f.f.avatar, function(t) {
							if (t != null && arTemp[f.f.levelMax] < 2 && ButtonLevel.ALL[f.f.levelMax] != null) {
								var bmpAvatar = new h2d.Bitmap(t);
								bmpAvatar.filter = true;
								bmpAvatar.tile = bmpAvatar.tile.center();
								cMap.add(bmpAvatar, DM_BTN);
								f.bmp = bmpAvatar;
								
								setAvatarFriend(f);
							}
						});
					}
				}
			}
		}

		var btActual = ButtonLevel.ALL[LevelDesign.USER_DATA.levelMax];
		var btPrevious = ButtonLevel.ALL[LevelDesign.USER_DATA.levelMax - 1];

		if (btActual != null) {
			hsTaupi.scaleX = hsTaupi.scaleY = scaling * 0.75;
			if (btPrevious != null) {
				hsTaupi.x = Std.int(btPrevious.x + (btActual.x - btPrevious.x) * 0.5);
				hsTaupi.y = Std.int(btPrevious.y + (btActual.y - btPrevious.y) * 0.5);
				hsTaupi.rotation = Math.atan2(btPrevious.y - btActual.y, btPrevious.x - btActual.x) - 3.14 / 2;
			}
			else {
				hsTaupi.x = Std.int(ButtonLevel.ALL[LevelDesign.USER_DATA.levelMax].x);
				hsTaupi.y = Std.int(ButtonLevel.ALL[LevelDesign.USER_DATA.levelMax].y + hsTaupi.height * 0.5);
			}
			
			if (hsCanon != null)
				hsCanon.scaleX = hsCanon.scaleY = scaling;
			
			fxSonar.scaleX = fxSonar.scaleY = scaling * 1.5;
			fxSonar.x = btActual.x;
			fxSonar.y = btActual.y;	
			
			cMap.y = Settings.STAGE_HEIGHT / 2 - arWay[levelFocus].y;		
		}
		else {
			hsTaupi.visible = fxSonar.visible = false;
		}
		
		uiBottom.onResize();
		
		setMap();
		
		super.onResize();
	}

	override public function resume() {
		if (uiBottom != null) {
			uiBottom.updateHLMail( LevelDesign.USER_DATA.requestsCount );
			uiBottom.checkHKCollec();			
		}

		super.resume();
	}

	override function unregister() {
		if (txtBeginning != null)
			txtBeginning.dispose();
		txtBeginning = null;

		for (bg in arBG) {
			bg.deactivate();
			bg.dispose();
		}

		hsTaupi.dispose();
		hsTaupi = null;

		if (hsCanon != null)
			hsCanon.dispose();
		hsCanon = null;

		fxSonar.dispose();
		fxSonar = null;

		bmWay.dispose();
		bmWay = null;

		bmMap.dispose();
		bmMap = null;

		bmMapOver.dispose();
		bmMapOver = null;
		
		if (arFriend != null) {
			for (f in arFriend) {
				f.hbe.dispose();
				f.hbe = null;
				
				if( f.bmp != null )
					f.bmp.dispose();
				f.bmp = null;
			}
			arFriend = null;
			
			bmFriend.dispose();
			bmFriend = null;
			
			for (b in arAddBand) {
				b.dispose();
				b = null;
			}
			arAddBand = null;
			
			bmBand.dispose();
			bmBand = null;			
		}

		for (p in poolFX) {
			p.dispose();
			p = null;
		}
		poolFX = null;

		bmFX.dispose();
		bmFX = null;

		for (p in poolMapFX) {
			p.dispose();
			p = null;
		}
		poolMapFX = null;

		bmMapFX.dispose();
		bmMapFX = null;

		for (hs in arWay) {
			if (hs != null)
				hs.dispose();
			hs = null;
		}

		for (c in arCloud) {
			c.dispose();
			c = null;
		}
		
		if (hsTopArrow != null)
			hsTopArrow.dispose();
		hsTopArrow = null;
		
		if (hsDownArrow != null)
			hsDownArrow.dispose();
		hsDownArrow = null;

		ButtonLevel.DESTROY();

		uiBottom.destroy();
		uiBottom = null;

		if (process.popup.GoalLevels.ME != null)
			process.popup.GoalLevels.ME.destroy();

		ME = null;

		super.unregister();
	}

	override function update() {
		tweener.update();

		rootMouseX = root.mouseX;
		rootMouseY = root.mouseY;

		var irnd = mt.deepnight.Lib.irnd;

		cloud1.x = Math.sin(time / 50) * 10 * Settings.STAGE_SCALE;
		cloud1.y = Math.sin((time + 10) / 50) * 5 * Settings.STAGE_SCALE - heightMax;

		cloud2.x = Math.sin((time + 11) / 55) * 10 * Settings.STAGE_SCALE + Settings.STAGE_WIDTH * 0.5;
		cloud2.y = Math.sin((time + 22) / 55) * 5 * Settings.STAGE_SCALE - heightMax;

		cloud3.x = Math.sin((time + 45) / 60) * 10 * Settings.STAGE_SCALE + Settings.STAGE_WIDTH;
		cloud3.y = Math.sin((time + 33) / 60) * 5 * Settings.STAGE_SCALE - heightMax;

		var activeMargin = Settings.STAGE_HEIGHT * 0.4;
		var minPosY = Settings.STAGE_HEIGHT - beginHeight;
		var maxPosY = heightMax;

		//trace('POS=${cMap.y} / min=$minPosY / max=$maxPosY' );

		var bgReady = false;
		var bgActiveNotReady = false;
		for( bg in arBG ) {
			if( !bgReady && bg.isReady ){
				minPosY = Std.int( Settings.STAGE_HEIGHT - bg.y - bg.height );
				bgReady = true;
			}else if( bgReady && !bg.isReady ){
				maxPosY = -bg.y - bg.height;
				bgReady = false;
			}

			if( bg.y+bg.height+cMap.y > -activeMargin && bg.y+cMap.y < Settings.STAGE_HEIGHT+activeMargin ){
				bg.activate();
				if( !bg.isReady )
					bgActiveNotReady = true;
			}else{
				bg.deactivate();
			}
		}
		if( !bgActiveNotReady && !isReady )
			isReady = true;

		function setMapY( y : Float ){
			if( y < minPosY )
				y = minPosY;
			else if( y > maxPosY )
				y = maxPosY;
			return cMap.y = Std.int(y);
		}

		if (mouseLeftDown
		&&	rootMouseX > 0
		&&	rootMouseX < Settings.STAGE_WIDTH
		&&	rootMouseY > 0
		&&	rootMouseY < Settings.STAGE_HEIGHT) {
			mouseDY = rootMouseY - mouseDragY;
			setMapY( cMap.y + mouseDY );
			mouseDragY = rootMouseY;
		}

		if (mouseDY != 0) {
			var d = Settings.STAGE_HEIGHT * 0.6;
			var frictPos = cMap.y == maxPosY ? 1 : Math.max(  1, (d-(maxPosY - cMap.y))*0.03 );
			var frictNeg = cMap.y == minPosY ? -1 : Math.min( -1, (-d+(cMap.y - minPosY))*0.03 );

			//trace('POS=${cMap.y} / min=$minPosY / max=$maxPosY / frictPos=$frictPos / frictNeg=$frictNeg / mouseDY=$mouseDY' );

			if (mouseDY > frictPos)
				mouseDY -= frictPos;
			else if (mouseDY < frictNeg)
				mouseDY -= frictNeg;
			else {
				mouseDY = 0;
			}

			if (!mouseLeftDown) {
				setMapY( cMap.y + mouseDY );
			}
		}

		if (deltaWheel != 0.0 && !paused) {
			setMapY( cMap.y - deltaWheel * 100 * Settings.STAGE_SCALE );
			deltaWheel = 0;
		}

		uiBottom.update();
		
		if (hsTaupi.visible)
			doFXTaupi();

		for (p in poolFX)
			p.update(true);

		for (p in poolMapFX)
			p.update(true);

		Settings.SLB_UI.updateChildren();
		Settings.SLB_UI2.updateChildren();
		Settings.SLB_FX.updateChildren();

		super.update();
	}
	
	function doFXTaupi() {
		var rnd = mt.deepnight.Lib.rnd;
		
		//if (Std.random(Settings.FPS) == 0) {
		if (Std.random(Std.int(Settings.FPS / 2)) == 0) {
			var part = mt.deepnight.HParticle.allocFromPool(poolMapFX, Settings.SLB_FX.getTile("mudPartSmall"));
			part.scaleX = part.scaleY = scaling * rnd(0.5, 1);
			part.setPos(hsTaupi.x, hsTaupi.y);
			part.life = Std.int((rnd(0, 0.5) + 0.5) * Settings.FPS);
			if (Std.random(2) == 0)
				part.moveAng(rnd(3.14 * (2 / 3), 3.14 * (5 / 4), false) + hsTaupi.rotation, (15 + Std.random(10)) * Settings.STAGE_SCALE);
			else
				part.moveAng(rnd(3.14 / 3, -3.14 / 4, false) + hsTaupi.rotation, (15 + Std.random(10)) * Settings.STAGE_SCALE);
			part.frictX = part.frictY = 0.95;
			part.gy = 0.4 * Settings.STAGE_SCALE;
			part.dr = 0.2;
		}
	}
}
