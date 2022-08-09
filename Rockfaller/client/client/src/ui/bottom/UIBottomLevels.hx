package ui.bottom ;

import h2d.Sprite;
import h2d.Text;

import mt.deepnight.slb.HSprite;

import Common;

import process.Levels;
import data.Lang;
import data.Settings;
import data.LevelDesign;
import process.popup.Collection;

/**
 * ...
 * @author Tipyx
 */
class UIBottomLevels extends h2d.Layers
{
	var offset				: Int;
	
	var uiMenuLeft			: HSprite;
	var uiMenuRight			: HSprite;
	var uiMenuMail			: HSprite;
	var uiMenuLife			: HSprite;
	public var uiLife		: ui.ModuleLife;

	var btnCollec			: ui.Button;
	var btnPause			: ui.Button;
	var btnMail				: ui.Button;
	var btnGold				: ui.Button;
	var hsNotif				: HSprite;
	var hsGold				: HSprite;
	var lblNotif			: Text;
	var lblGold				: Text;
	
	var oldMoney			: Float;
	
	var hsMobBar			: HSprite;
	var lblMobile			: h2d.Text;
	var hsIconCoin			: HSprite;
	var hsMobLeft			: HSprite;
	var interMob			: h2d.Interactive;
	var hsMobRight			: HSprite;
	
	public var scaling		: Float;
	
	public function new() {
		super();
		
		oldMoney = 0;
		
		offset = Std.int(10 * Settings.STAGE_SCALE);
		scaling = Settings.STAGE_SCALE;
		
		uiMenuLife = Settings.SLB_UI.h_get("uiMenuTop");
		uiMenuLife.setCenterRatio(1, 0);
		uiMenuLife.filter = true;
		this.addChild(uiMenuLife);
		
		uiMenuLeft = Settings.SLB_UI.h_get("uiMenu");
		uiMenuLeft.setCenterRatio(0, 1);
		uiMenuLeft.filter = true;
		this.addChild(uiMenuLeft);
		
		btnPause = new ui.Button("uiBtOption", "", function () {
			process.ProcessManager.ME.showPause(Levels.ME);
		});
		this.addChild(btnPause);
		
		if (LevelDesign.USER_DATA.arLoots.length > 0) {
			uiMenuRight = Settings.SLB_UI.h_get("uiMenu");
			uiMenuRight.setCenterRatio(0, 1);
			uiMenuRight.filter = true;
			this.addChild(uiMenuRight);
			
			btnCollec = new ui.Button("uiBtLoot", "", function () {
				process.ProcessManager.ME.showCollection(Levels.ME);
			});
			this.addChild(btnCollec);			
		}
		
		uiMenuMail = Settings.SLB_UI.h_get("uiMenu");
		uiMenuMail.setCenterRatio(0, 1);
		uiMenuMail.filter = true;
		this.addChild(uiMenuMail);
		
		btnMail = new ui.Button("uiBtMail", "", function () {
			process.ProcessManager.ME.showMail(Levels.ME);
		});
		this.addChild(btnMail);
		
		hsNotif = Settings.SLB_UI2.h_get("notif");
		hsNotif.setCenterRatio(0, 0.5);
		hsNotif.visible = false;
		this.addChild(hsNotif);
		
		lblNotif = new h2d.Text(Settings.FONT_BENCH_NINE_50, this);
		lblNotif.textAlign = h2d.Text.Align.Center;
		lblNotif.visible = false;
		lblNotif.textColor = 0x683400;
		
		btnGold = new ui.Button("btMore", "", function () {
			process.ProcessManager.ME.showShop(Levels.ME);
		});
		this.addChild(btnGold);
		
		hsGold = Settings.SLB_UI.h_get("iconGold");
		hsGold.setCenterRatio(0.5, 0.5);
		this.addChild(hsGold);
		
		uiLife = new ui.ModuleLife();
		this.addChild(uiLife);
		
		updateHLMail( LevelDesign.USER_DATA.requestsCount );
		checkHKCollec();
	}
	
	function setMobilePub() {
		if (hsMobBar != null)
			hsMobBar.dispose();
		hsMobBar = Settings.SLB_UI.h_get("uiMobileCore");
		hsMobBar.setCenterRatio(0, 1);
		hsMobBar.filter = false;			
		this.addChild(hsMobBar);
		
		var mw = 0.;
		
		if (lblMobile != null)
			lblMobile.dispose();
		lblMobile = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_50);
		lblMobile.text = Lang.GET_VARIOUS(TypeVarious.TVPlayMobile);
		lblMobile.text = mt.Utf8.lowercase(lblMobile.text);
		lblMobile.y = Std.int(Settings.STAGE_HEIGHT - lblMobile.height);
		this.addChild(lblMobile);
		
		mw += lblMobile.textWidth;
		
		if (hsIconCoin != null)
			hsIconCoin.dispose();
		hsIconCoin = Settings.SLB_UI.h_get("iconGold");
		hsIconCoin.setCenterRatio(0, 0.5);
		hsIconCoin.scaleX = hsIconCoin.scaleY = lblMobile.textHeight / hsIconCoin.height;
		hsIconCoin.y = Std.int(lblMobile.y + lblMobile.textHeight * 0.5);
		this.addChild(hsIconCoin);
		
		mw += hsIconCoin.width;
		
		lblMobile.x = Std.int((Settings.STAGE_WIDTH - mw) * 0.5);
		
		hsIconCoin.x = lblMobile.x + lblMobile.textWidth;
		
		hsMobBar.scaleX = (mw * 1.1) / hsMobBar.width;
		hsMobBar.scaleY = hsIconCoin.scaleY * 2.2;
		hsMobBar.x = Std.int((Settings.STAGE_WIDTH - hsMobBar.width) * 0.5);
		hsMobBar.y = Std.int(Settings.STAGE_HEIGHT);
		
		if (interMob != null)
			interMob.dispose();
		var interMob = new h2d.Interactive(hsMobBar.width, hsMobBar.height);
		interMob.x = hsMobBar.x;
		interMob.y = hsMobBar.y - hsMobBar.height;
		interMob.onClick = function(e) {
			process.ProcessManager.ME.showAskMobile(Levels.ME);
		}
		this.addChild(interMob);
		
		if (hsMobLeft != null)
			hsMobLeft.dispose();
		hsMobLeft = Settings.SLB_UI.h_get("uiMobileLeft");
		hsMobLeft.setCenterRatio(1, 1);
		hsMobLeft.scaleX = hsMobLeft.scaleY = hsMobBar.scaleY;
		hsMobLeft.x = hsMobBar.x;
		hsMobLeft.y = Std.int(Settings.STAGE_HEIGHT);
		this.addChild(hsMobLeft);
		
		if (hsMobRight != null)
			hsMobRight.dispose();
		hsMobRight = Settings.SLB_UI.h_get("uiMobileLeft");
		hsMobRight.setCenterRatio(1, 1);
		hsMobRight.scaleX = -hsMobBar.scaleY;
		hsMobRight.scaleY = hsMobBar.scaleY;
		hsMobRight.x = Std.int(hsMobBar.x + hsMobBar.width);
		hsMobRight.y = Std.int(Settings.STAGE_HEIGHT);
		this.addChild(hsMobRight);
	}
	
	public function updateHLMail( count : Int ) {
		if ( count > 0 ) {
			btnMail.showHL(Levels.ME);
			hsNotif.visible = true;
			lblNotif.visible = true;
			lblNotif.text = Std.string(count > 9 ? "9+" : count);
		}
		else {
			btnMail.hideHL();
			lblNotif.visible = false;
			hsNotif.visible = false;
		}
	}
	
	public function checkHKCollec() {
		if (btnCollec != null) {
			if (Collection.NEW_LOOT)
				btnCollec.showHL(Levels.ME);
			else
				btnCollec.hideHL();			
		}
	}
	
	public function onResize() {
		scaling = Settings.STAGE_SCALE;
	#if mBase
		uiMenuLeft.scaleX = uiMenuLeft.scaleY = scaling;
		if (mt.Metrics.px2cm(uiMenuLeft.width) < 2)
			scaling = Settings.STAGE_SCALE * 1.5;
	#end
			
		uiMenuLeft.scaleX = uiMenuLeft.scaleY = scaling;
		offset = Std.int(0.1 * uiMenuLeft.width);
		uiMenuLeft.x = Std.int( - offset);
		uiMenuLeft.y = Std.int(Settings.STAGE_HEIGHT + offset);
		
		btnPause.resize(scaling);
		btnPause.x = Std.int(offset * 0.5);
		btnPause.y = Std.int(Settings.STAGE_HEIGHT - btnPause.h - offset * 0.5);
		
		uiMenuMail.scaleX = scaling;
		uiMenuMail.scaleY = -scaling;
		uiMenuMail.x = Std.int( -offset );
		uiMenuMail.y = Std.int( -offset );
		
		btnMail.resize(scaling);
		btnMail.x = Std.int(offset * 0.5);
		btnMail.y = Std.int(offset * 1);
		
		if (btnCollec != null) {
			uiMenuRight.scaleX = -scaling;
			uiMenuRight.scaleY = scaling;
			uiMenuRight.x = Std.int(Settings.STAGE_WIDTH + offset);
			uiMenuRight.y = Std.int(Settings.STAGE_HEIGHT + offset);
			
			btnCollec.resize(scaling);
			btnCollec.x = Std.int(Settings.STAGE_WIDTH - btnCollec.w - offset * 0.5);
			btnCollec.y = Std.int(Settings.STAGE_HEIGHT - btnCollec.h - offset * 0.5);		
		}
		
		hsNotif.scaleX = hsNotif.scaleY = scaling;
		hsNotif.x = btnMail.x + btnMail.w + offset;
		hsNotif.y = btnMail.y + btnMail.h * 0.5;
		
		if (lblNotif != null)
			lblNotif.dispose();
		lblNotif = new h2d.Text(Settings.FONT_BENCH_NINE_50, this);
		lblNotif.textAlign = h2d.Text.Align.Center;
		lblNotif.visible = false;
		lblNotif.textColor = 0x683400;
		lblNotif.maxWidth = hsNotif.width * 0.5;
		lblNotif.x = hsNotif.x + hsNotif.width * 0.5;
		lblNotif.y = hsNotif.y - lblNotif.textHeight * 0.5;
		updateHLMail( LevelDesign.USER_DATA.requestsCount );
		
		setGold(true);
		
		uiMenuLife.scaleX = uiMenuLife.scaleY = scaling;
		uiMenuLife.x = Settings.STAGE_WIDTH;
		
		uiLife.resize(offset, scaling);
		uiLife.x = Settings.STAGE_WIDTH;
		uiLife.y = Std.int(btnGold.y + btnGold.h + offset * 1);
		
	#if standalone
		if (!LevelDesign.USER_DATA.flags.has(UserFlags.UFPlayMobile))
			setMobilePub();
	#end
	}
	
	public function setGold(isResizing:Bool = false) {
		btnGold.resize(scaling);
		btnGold.x = Settings.STAGE_WIDTH - btnGold.w - offset * 1;
		btnGold.y = offset * 0.5;
		
		hsGold.scaleX = hsGold.scaleY = scaling;
		hsGold.x = btnGold.x - offset * 2;
		hsGold.y = btnGold.y + btnGold.h * 0.5;
		
		if (isResizing) {
			if (lblGold != null)
				lblGold.dispose();
			lblGold = new h2d.Text(Settings.FONT_MOUSE_DECO_80, this);			
			lblGold.text = Std.string(LevelDesign.USER_DATA.gold);
			lblGold.letterSpacing = -Std.int(lblGold.textWidth * 0.05);
			lblGold.scaleX = lblGold.scaleY = scaling / Settings.STAGE_SCALE;
			lblGold.x = btnGold.x - offset * 5 - (lblGold.textWidth * lblGold.scaleX);
			lblGold.y = hsGold.y - lblGold.textHeight * 0.4 * lblGold.scaleY;
			oldMoney = LevelDesign.USER_DATA.gold;
		}
		else if (oldMoney < LevelDesign.USER_DATA.gold) {
			var t = Levels.ME.tweener.create().delay(1 * Settings.FPS).to(0.5 * Settings.FPS, oldMoney = LevelDesign.USER_DATA.gold);
			function onUpdate(e) {
				lblGold.text = Std.string(Std.int(oldMoney));
				lblGold.x = btnGold.x - offset * 5 - (lblGold.textWidth * lblGold.scaleX);
			}
			function onComplete() {
				lblGold.y = hsGold.y - lblGold.textHeight * 0.4 * lblGold.scaleY;
				lblGold.letterSpacing = -Std.int(lblGold.textWidth * 0.05);
				oldMoney = LevelDesign.USER_DATA.gold;
				FX.EXPLODE_GOLD(hsGold);
			}
			t.onUpdate = onUpdate;
			t.onComplete = onComplete;			
		}
	}
	
	public function destroy() {
		if (btnCollec != null) {
			btnCollec.destroy();
			btnCollec = null;
			
			uiMenuRight.dispose();
			uiMenuRight = null;
		}
		
		uiMenuLeft.dispose();
		uiMenuLeft = null;
		
		uiMenuLife.dispose();
		uiMenuLife = null;
		
		uiMenuMail.dispose();
		uiMenuMail = null;
		
		btnPause.destroy();
		btnPause = null;
		
		btnMail.destroy();
		btnMail = null;
		
		btnGold.destroy();
		btnGold = null;
		
		uiLife.destroy();
		uiLife = null;
		
		hsNotif.dispose();
		hsNotif = null;
		
		hsGold.dispose();
		hsGold = null;
		
		lblNotif.dispose();
		lblNotif = null;
		
		lblGold.dispose();
		lblGold = null;
	}
	
	public function update() {
		if (LevelDesign.GET_LIFE() == LevelDesign.GET_MAX_LIFES())
			uiMenuLife.set("uiMenuTop");
		else
			uiMenuLife.set("uiMenuTopNext");
		
		uiLife.update();
	}
}