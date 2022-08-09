package ui;

import h2d.Interactive;
import mt.deepnight.slb.HSprite;
import mt.deepnight.TinyProcess;
import process.Home;

import data.Settings;
import data.LevelDesign;
import manager.SoundManager;

/**
 * ...
 * @author Tipyx
 */
class ButtonWorld extends h2d.Sprite
{
	public static var	ALL		: Array<ButtonWorld>	= [];
	
	var hs					: HSprite;
	var hsRollOver			: HSprite;
	
	var arAnimatedSprite	: Array<{hs:HSprite, tp:TinyProcess}>;
	
	var hsUI				: HSprite;
	var txtLevelDone		: h2d.Text;
	var txtLevelMax			: h2d.Text;
	
	public var isLocked		: Bool;
	
	var rx					: Float;
	var ry					: Float;
	
	var w					: Float;
	var h					: Float;
	
	public var world		: World;
	var home				: Home;
	
	var c					: Float;
	
	var maxAlphaRollOver	: Float;
	
	var inter				: Interactive;
	var t					: mt.motion.Tween;
	
	public function new(world:World, h:process.Home) {
		super();
		
		this.home = h;
		this.world = world;
		
		var nameSprite = "earthBg";
		
		switch (world) {
			case World.WEarth :
				nameSprite = "earthBg";
				isLocked = false;
			case World.WMoon :
				nameSprite = "moonBg"; 
				isLocked = true;
		}
		
		hs = Settings.SLB_PLANET.h_get(nameSprite);
		hs.setCenterRatio(0.5, 0.5);
		hs.filter = true;
		this.addChild(hs);
		
		hsRollOver = hs.clone();
		hsRollOver.setCenterRatio(0.5, 0.5);
		hsRollOver.filter = true;
		hsRollOver.alpha = 0;
		this.addChild(hsRollOver);
		
		hsRollOver.colorMatrix = new h3d.Matrix();
		
		hsRollOver.colorMatrix = mt.deepnight.Color.getColorizeMatrixH2d(0xECB96C,0.5,0.5);
		
		arAnimatedSprite = [];
		
		switch (world) {
			case World.WEarth	:
				var wheel1 = Settings.SLB_PLANET.h_get("earthClock");
				wheel1.setCenterRatio(0.5, 0.5);
				wheel1.filter = true;
				this.addChild(wheel1);
				
				var p1 = new TinyProcess(h);
				p1.onUpdate = function () {
					if (wheel1 == null)
						p1.destroy();
					else
						wheel1.rotation += 0.005;
				};
				
				var wheel2 = Settings.SLB_PLANET.h_get("earthAntiClock");
				wheel2.setCenterRatio(0.5, 0.5);
				wheel2.filter = true;
				this.addChild(wheel2);
				
				var p2 = new TinyProcess(h);
				p2.onUpdate = function () {
					if (wheel2 == null)
						p2.destroy();
					else
						wheel2.rotation -= 0.005;
				};
				
				arAnimatedSprite.push({hs:wheel1, tp:p1});
				arAnimatedSprite.push( { hs:wheel2, tp:p2 } );
				
				maxAlphaRollOver = 1;
			case World.WMoon	:
				c = 0;
				maxAlphaRollOver = 0.2;
		}
		
		if (!isLocked) {
			inter = new h2d.Interactive(hs.width, hs.height, hs);
			inter.setPos(Std.int( -hs.width / 2), Std.int( -hs.height / 2));
			inter.onOver = function onClickBtnWorld(e) {
				SoundManager.HOVER_BTN_SFX();
				if (t != null && !t.disposed)
					t.dispose();
				t = home.tweener.create().to(0.2 * Settings.FPS, hsRollOver.alpha = maxAlphaRollOver).ease(mt.motion.Ease.easeOutSine);
			}
			inter.onOut = function onOutBtnWorld(e) {
				if (t != null && !t.disposed)
					t.dispose();
				t = home.tweener.create().to(0.5 * Settings.FPS, hsRollOver.alpha = 0).ease(mt.motion.Ease.easeOutSine);
			}
			inter.onRelease = function onReleaseBtnWorld(e) {
				//home.gotoWorld(world);
			}
		}
		
		//hsUI = Settings.SLB_UI.h_get("separator");
		//hsUI.filter = true;
		//hsUI.setCenterRatio(0.5, 0.5);
		//hsUI.blendMode = Multiply;
		//this.addChild(hsUI);
		
		ALL.push(this);
	}
	
	public function onMouseLeftUp():Bool {
		if (!isLocked
		&&	this.mouseX > -w / 2
		&&	this.mouseX < w / 2
		&&	this.mouseY > -h / 2
		&&	this.mouseY < h / 2) {
			return true;
		}
		else
			return false;
	}
	
	public function show() {
	}
	
	public function hide() {
	}
	
	public function resize() {
	// RESIZE
		hs.scaleX = hs.scaleY = Settings.STAGE_SCALE;
		hsRollOver.scaleX = hsRollOver.scaleY = Settings.STAGE_SCALE;
		w = hs.width;
		h = hs.height;
		
		//hsUI.scaleX = hsUI.scaleY = Settings.STAGE_SCALE;
		
		for (as in arAnimatedSprite) {
			as.hs.scaleX = as.hs.scaleY = Settings.STAGE_SCALE;
		}
		
	// REPLACE
		this.x = Std.int(Settings.STAGE_WIDTH / 2);
		switch (world) {
			case World.WEarth :		this.y = ((ALL.length) * Settings.STAGE_HEIGHT) - Std.int(Settings.STAGE_HEIGHT / 2);
			case World.WMoon :		this.y = ((ALL.length - 1) * Settings.STAGE_HEIGHT) - Std.int(Settings.STAGE_HEIGHT / 2);
		}
		
		//hsUI.y = Std.int(Settings.STAGE_HEIGHT / 2);
		
		//if (txtLevelDone != null)
			//txtLevelDone.dispose();
		//txtLevelDone = new h2d.Text(Settings.FONT_BIRMINGHAM_120);
		//txtLevelDone.text = Std.string(LevelDesign.MAX_LEVEL);
		//txtLevelDone.textColor = 0x000000;
		//txtLevelDone.x = Std.int( txtLevelDone.textWidth / 2);
		//txtLevelDone.y = Std.int(hsUI.y);
		//this.addChild(txtLevelDone);
		
		//if (txtLevelMax != null)
			//txtLevelMax.dispose();
		//txtLevelMax = new h2d.Text(Settings.FONT_BIRMINGHAM_120);
		//txtLevelMax.text = Std.string(LevelDesign.AR_LEVEL.length);
		//txtLevelMax.textColor = 0x000000;
		//txtLevelDone.x = Std.int( -txtLevelMax.textWidth / 2);
		//txtLevelMax.y = Std.int(hsUI.y + txtLevelMax.textHeight);
		//this.addChild(txtLevelMax);
	}
	
	public function destroy() {
		hs.dispose();
		hs = null;
		
		for (as in arAnimatedSprite) {
			as.hs.dispose();
			as.hs = null;
			
			as.tp.destroy();
			as.tp = null;
		}
		
		if (inter != null) {
			inter.dispose();
			inter = null;
		}
		
		arAnimatedSprite = [];
		
		ALL.remove(this);
	}
	
	public function update() {
		switch (world) {
			case World.WEarth	:
			case World.WMoon	:
				if (c % 30 == 0) {
					c = 0;
					var hs = Settings.SLB_FX.h_get("fxSmoke");
					hs.setCenterRatio(0.5, 0.5);
					hs.scaleX = Settings.STAGE_SCALE * mt.deepnight.Lib.rnd(0.75, 1.25);
					hs.scaleY = Settings.STAGE_SCALE * mt.deepnight.Lib.rnd(0.75, 1.25);
					hs.x = -192 * Settings.STAGE_SCALE;
					hs.y = -40 * Settings.STAGE_SCALE;
					hs.rotation = Std.random(628) / 100;
					hs.alpha = 0;
					this.addChild(hs);
					var tp = new TinyProcess(home);
					var dx:Float = 3 + Std.random(3);
					var dy:Float = Std.random(2) == 0 ? dx + 1 : dx - 1;
					dx /= 4;
					dy /= 4;
					var da = 0.01 + Std.random(3) / 100;
					var b = true;
					tp.onUpdate = function () {
						if (hs == null)
							tp.destroy();
						else {
							hs.x -= dx;
							hs.y -= dy;
							if (b) {
								hs.alpha += da;
								if (hs.alpha > 0.5)
									b = false;
							}
							else
								hs.alpha -= da / 10;
							
							if (hs.alpha <= 0)
								tp.destroy();							
						}
					}
					tp.onDestroy = function () {
						if (hs == null)
							hs.dispose();
						hs = null;
					}
				}
				
				c++;
		}
	}
	
// STATIC
	public static function ON_MOUSE_LEFT_UP():World {
		for (bw in ALL)
			if (bw.onMouseLeftUp())
				return bw.world;
				
		return null;
	}

	public static function RESIZE() {
		for (bw in ALL)
			bw.resize();
	}
	
	public static function DESTROY() {
		for (bw in ALL)
			bw.destroy();
			
		ALL = [];
	}
	
	public static function UPDATE() {
		for (bw in ALL)
			bw.update();
	}
}