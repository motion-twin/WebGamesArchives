package ui;

import data.Settings;
import data.LevelDesign;
import manager.SoundManager;
import process.Levels;


/**
 * ...
 * @author Tipyx
 */

enum LevelState {
	LSUndone;
	LSDone;
	LSActual;
	LSSpecial;
}
 
class ButtonLevel extends h2d.Sprite
{
	public static var ALL			: Array<ButtonLevel>	= [];
	static var AR_POS				: Array<Float>			= [];
	
	var levels				: process.Levels;
	var be					: mt.deepnight.slb.HSpriteBE;
	var beOver				: mt.deepnight.slb.HSpriteBE;
	var beStars				: mt.deepnight.slb.HSpriteBE;
	var inter				: h2d.Interactive;
	var lblNum				: h2d.TextBatchElement;
	
	var t					: mt.motion.Tween;
	
	public var numLevel		: Int;
	var nameImg				: String;
	var state				: LevelState;
	
	var scaling				: Float;
	public var realHei		: Int;
	public var onClick		: Void->Void;
	
	
	public function new(num:Int, levels:process.Levels, newScaling:Float) {
		super();
		
		this.levels = levels;
		this.scaling = newScaling;
		
		//num = 11;
		numLevel = num;
		
		if (LevelDesign.USER_DATA.levelMax == numLevel && LevelDesign.USER_DATA.arHighScore[numLevel] == null)
			state = LevelState.LSActual;
		else if (LevelDesign.USER_DATA.levelMax > numLevel || LevelDesign.USER_DATA.arHighScore[numLevel] != null)
			state = LevelState.LSDone;
		else
			state = LevelState.LSUndone;
			
		switch (state) {
			case LevelState.LSUndone :
				nameImg = "level";
			case LevelState.LSDone :
				nameImg = "levelDone";
			case LevelState.LSActual, LevelState.LSSpecial :
				nameImg = "levelBonus";
		}
		
		var fd = levels.slbLevels.getFrameData(nameImg);
		
		be = levels.slbLevels.hbe_get(levels.bmMap, nameImg);
		be.setCenterRatio(0.5, 0.5);
		be.scaleX = be.scaleY = scaling;
		if (!Common.VALIDATE_LEVEL(LevelDesign.GET_LEVEL(num)))
			be.alpha = 0.5;
		
		beOver = levels.slbLevels.hbe_get(levels.bmMapOver, "levelOver");
		beOver.setCenterRatio(0.5, 0.5);
		beOver.scaleX = beOver.scaleY = scaling;
		beOver.alpha = 0;
		
		realHei = Std.int(be.frameData.realFrame.realHei * scaling);
		
		inter = new h2d.Interactive(fd.wid, fd.hei, this);
		//inter.backgroundColor = 0xAAAAAAAA;
		if (Common.VALIDATE_LEVEL(LevelDesign.GET_LEVEL(num))) {
			inter.onClick = onClickButtonLevel;
		}
		inter.onRelease = onReleaseButtonLevel;
		inter.onPush = onOverButtonLevel;
		#if !mobile
			inter.onOver = onOverButtonLevel;
			inter.onOut = onOutButtonLevel;
		#end
		
		if (state != LevelState.LSUndone)
			setStars();
		
		ALL[numLevel] = this;
	}
	
	function onClickButtonLevel(e) {
		trace(numLevel);
		onClick();
	}
	
	function onReleaseButtonLevel(e) {
		onOutButtonLevel(e);
		if (Levels.ME != null)
			Levels.ME.mouseLeftDown = false;
	}
	
	function onOverButtonLevel(e) {
		SoundManager.HOVER_BTN_SFX();
		if (t != null)
			t.dispose();
		t = levels.tweener.create().to(0.2 * Settings.FPS, beOver.alpha = 1);
	}
	
	function onOutButtonLevel(e) {
		if (t != null)
			t.dispose();
		t = levels.tweener.create().to(0.2 * Settings.FPS, beOver.alpha = 0);
	}
	
	function setText() {
		if (lblNum != null)
			lblNum.dispose();
		//lblNum = new h2d.Text(Settings.FONT_MOUSE_DECO_66, this);
		lblNum = new h2d.TextBatchElement(Settings.FONT_MOUSE_DECO_66, levels.bmText);
		lblNum.text = Std.string(numLevel);
		switch (state) {
			case LevelState.LSActual :
				lblNum.textColor = 0xFFFFFFFF;
			case LevelState.LSUndone :
				lblNum.textColor = 0xFFB4E6FF;
			case LevelState.LSDone :
				lblNum.textColor = 0xFFFFD13A;
			case LevelState.LSSpecial :
				lblNum.textColor = 0xFF2A0808;
		}
		lblNum.x = this.x + Std.int(-lblNum.textWidth * 0.5);
		lblNum.y = this.y + Std.int(-lblNum.textHeight * 0.5);
	}
	
	function setStars() {
		var li = LevelDesign.GET_LEVEL(numLevel);
		var userHS = LevelDesign.GET_USER_HIGHSCORE(numLevel);
		
		var num = -1;
		
		if (userHS >= li.arStepScore[2])		num = 2;
		else if (userHS >= li.arStepScore[1])	num = 1;
		else if (userHS >= li.arStepScore[0])	num = 0;
		
		var nameStars = "";
		
		switch (state) {
			case LevelState.LSUndone :
			//nameStars = "stars";
			case LevelState.LSDone :
				nameStars = "stars";
			case LevelState.LSActual, LevelState.LSSpecial :
				nameStars = "starsRed";
		}
		
		//num = Std.random(3);
		
		// TODO : Special stars
		if (num > -1) {
			beStars = levels.slbLevels.hbe_get(levels.bmMap, nameStars, num);
			beStars.scaleX = beStars.scaleY = scaling;
			beStars.setCenterRatio(0.5, 0.5);
			beStars.x = Std.int(inter.x + be.width / 2);
		}
	}
	
	public function resize(newScaling:Float) {
		this.scaling = newScaling;
		
		inter.scaleX = inter.scaleY = scaling;
		be.scaleX = be.scaleY = scaling;
		beOver.scaleX = beOver.scaleY = scaling;
		
		if (beStars != null) {
			beStars.scaleX = beStars.scaleY = scaling;
		}
		this.x = Std.int(AR_POS[numLevel - 1] * newScaling);
		this.y = Std.int(levels.arWay[numLevel].y - levels.arWay[numLevel].height);
		
		inter.x = - Std.int(be.width / 2);
		inter.y = - Std.int(be.height / 2);
		
		be.x = beOver.x = this.x;
		be.y = beOver.y = this.y;
		if (beStars != null) {
			beStars.x = be.x;
			beStars.y = be.y;
		}
		
		setText();
	}
	
	public function destroy() {
		be.dispose();
		be = null;
		
		if (beStars != null)
			beStars.dispose();
		beStars = null;
		
		inter.dispose();
		inter = null;
		
		lblNum.dispose();
		lblNum = null;
		
		ALL.remove(this);
	}
	
	public function update() {
		
	}
	
// STATIC
	public static function SET_POS(from:Int, to:Int, slb:mt.deepnight.slb.BLib) {
		//if (AR_POS.length == 0) {
			//trace(slb);
			//trace(slb.getFrameData("wayLevel", 0));
			//trace(slb.getFrameData("wayLevel", 121));
			for (pos in from...to) {
				var t = slb.getTile("wayLevel", pos - from);
				var fd = slb.getFrameData("wayLevel", pos - from);
				var tex = t.getTexture();
			#if mBase
				var pix = tex.pixels;
				for (i in t.x...t.x + t.width) {
					switch (pix.getPixel(i, t.y) & 0x00ffffff) {
						case 0xFF0000, 0xFC0000, 0xFE0000 :
							AR_POS[pos] = i - t.x - fd.realFrame.x;
							break;
					}
				}
				pix = null;
			#else
				var bmp = tex.bmp;
				for (i in t.x...t.x + t.width) {
					switch (bmp.getPixel(i, t.y) & 0x00ffffff) {
						case 0xFF0000, 0xFC0000, 0xFE0000 :
							AR_POS[pos] = i - t.x - fd.realFrame.x;
							break;
					}
				}
				bmp = null;
			#end
				t = null;
				tex = null;
				fd = null;
			}
		//}
		
		trace(AR_POS);
	}

	public static function RESIZE(scaling) {
		for (bl in ALL)
			if (bl != null)
				bl.resize(scaling);
	}
	
	public static function DESTROY() {
		for (bl in ALL)
			if (bl != null)
				bl.destroy();
			
		ALL = [];
	}
	
	public static function UPDATE() {
		for (bl in ALL)
			if (bl != null)
				bl.update();
	}
}