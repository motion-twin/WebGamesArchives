package ui;

import data.Settings;
import manager.SoundManager;

/**
 * ...
 * @author Tipyx
 */

enum TypeButton {
	TBResume;
	TBMusic;
	TBSound;
	TBGiveUp;
	TBRetry;
	TBHome;
	TBNext;
	TBAskToFriend;
	TBAsk;
	TBContinue;
	TBRefill;
	TBPlay;
	TBMobo;
	TBShop;
	TBReload;
	TBLogOut;
	TBLogIn;
	TBLater;
	TBHint;
	TBInvite;
}
 
class Button extends h2d.Sprite
{
	var offset			: Int;
	
	var hs				: mt.deepnight.slb.HSprite;
	var hsHL			: mt.deepnight.slb.HSprite;
	var nameBtn			: String;
	var lblBtn			: h2d.Text;
	
	public var onClick	: Void->Void;
	var nameImg			: String;
	
	public var w		: Float;
	public var h		: Float;
	
	var isEnable		: Bool;
	
	var inter			: h2d.Interactive;
	var scaling			: Null<Float>;
	
	public function new(nameImg:String, nameBtn:String = "", newOnClick:Void->Void = null) {
		super();
		
		offset = 20;
		
		scaling = Settings.STAGE_SCALE;
		
		this.nameImg = nameImg;
		this.nameBtn = nameBtn;
		this.onClick = newOnClick;
		
		hs = Settings.SLB_UI2.h_getAndPlay(nameImg);
		hs.filter = true;
		this.addChild(hs);
		
		lblBtn = new h2d.Text(Settings.FONT_BENCH_NINE_90, this);
		lblBtn.textColor = 0x000000;
		lblBtn.alpha = 0.6;
		lblBtn.filter = true;
		lblBtn.text = mt.Utf8.uppercase(nameBtn);
		
		inter = new h2d.Interactive(hs.width, hs.height, this);
		inter.setPos(-hs.frameData.realFrame.x, -hs.frameData.realFrame.y);
		//inter.backgroundColor = 0x55FF0000;
		inter.onClick = onClickButton;
		inter.onPush = onPushButton;
		inter.onRelease = onReleaseOutButton;
		#if standalone
		inter.onOver = onOverButton;
		inter.onOut = onReleaseOutButton;
		#end
	}
	
	function onClickButton(e) {
		if (hs != null)
			hs.a.playAndLoop(nameImg);
		if (onClick != null)
			onClick();
	}
	
	function onOverButton(e) {
		if (hs != null && Settings.SLB_UI2.exists(nameImg + "Over"))
			hs.a.playAndLoop(nameImg + "Over");
		SoundManager.HOVER_BTN_SFX();
	}
	
	function onPushButton(e) {
		if (hs != null && Settings.SLB_UI2.exists(nameImg + "Active"))
			hs.a.playAndLoop(nameImg + "Active");
		if (lblBtn != null)
			lblBtn.y = Std.int(-0.5 * lblBtn.textHeight * lblBtn.scaleY + 0.6 * h);
	}
	
	function onReleaseOutButton(e) {
		if (hs != null)
			hs.a.playAndLoop(nameImg);
		if (lblBtn != null)
			lblBtn.y = Std.int(-0.5 * lblBtn.textHeight * lblBtn.scaleY + 0.5 * h);
	}
	
	public function setLbl(v:String) {
		lblBtn.text = nameBtn = v;
		lblBtn.text = mt.Utf8.uppercase( lblBtn.text );
		
		lblBtn.x = Std.int(-hs.frameData.realFrame.x * scaling + (w - lblBtn.width) / 2);
		lblBtn.y = Std.int(-0.5 * lblBtn.textHeight * lblBtn.scaleY + 0.5 * h);
	}
	
	public function showHL(hp:mt.deepnight.deprecated.HProcess) {
		if (hsHL == null && Settings.SLB_UI2.exists(nameImg + "Over")) {
			hsHL = Settings.SLB_UI2.h_getAndPlay(nameImg + "Over");
			hsHL.scaleX = hsHL.scaleY = scaling;
			hsHL.filter = true;
			this.addChild(hsHL);
			
			var tp = hp.createTinyProcess();
			tp.onUpdate = function () {
				if (hsHL == null)
					tp.destroy();
				else
					hsHL.alpha = Math.sin(hp.time / 5);
			}
		}
	}
	
	public function hideHL() {
		if (hsHL != null) {
			hsHL.dispose();
			hsHL = null;
		}
	}
	
	public function resize(newScaling:Null<Float> = null) {
		if (newScaling == null)
			scaling = Settings.STAGE_SCALE;
		else
			scaling = newScaling;
		
		hs.scaleX = hs.scaleY = scaling;
		inter.scaleX = inter.scaleY = scaling;
		
		if (hsHL != null)
			hsHL.scaleX = hsHL.scaleY = scaling;
		
		w = hs.width;
		h = hs.height;
		
		lblBtn.dispose();
		lblBtn = new h2d.Text(Settings.FONT_BENCH_NINE_90, this);
		lblBtn.filter = true;
		lblBtn.textColor = 0x000000;
		lblBtn.alpha = 0.6;
		lblBtn.text = mt.Utf8.uppercase( nameBtn );
		if (lblBtn.textWidth > w * 0.9)
			lblBtn.scaleX =	lblBtn.scaleY = (w * 0.9) / lblBtn.textWidth;
		
		lblBtn.x = Std.int(-hs.frameData.realFrame.x * scaling + (w - lblBtn.width * lblBtn.scaleX) / 2);
		lblBtn.y = Std.int( -0.5 * lblBtn.textHeight * lblBtn.scaleY + 0.5 * h);
	}
	
	public function destroy() {
		hs.dispose();
		hs = null;
		
		if (hsHL != null) {
			hsHL.dispose();
			hsHL = null;
		}
		
		lblBtn.dispose();
		lblBtn = null;
		
		inter.dispose();
		inter = null;
		
		super.dispose();
	}
}
