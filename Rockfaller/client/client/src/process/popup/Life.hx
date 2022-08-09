package process.popup;

import manager.LifeManager;
import mt.deepnight.deprecated.HProcess;

import Protocol;

import process.popup.BasePopup;
import data.LevelDesign;
import data.DataManager;
import data.Settings;
import process.popup.BoosterPickaxe;
import manager.SoundManager;
import ui.Button;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */
class Life extends process.popup.BasePopup
{
	public static var ME	: Life;
	
	public var lastLevelTry	: Int;
	
	var booster				: BoosterButton;
	var btnAsk				: Button;
	
	var lblMoney			: h2d.Text;
	var lblTime				: h2d.Text;
	var hsIconCoin			: mt.deepnight.slb.HSprite;
	var isDone				: Bool;
	
	var hasNoLife			: Bool;

	public function new(hparent:HProcess) {
		isDone = false;
		
		ME = this;
		
		hasNoLife = LevelDesign.GET_LIFE() == 0;
		
		super(hparent, hasNoLife ? SizePopUp.SPUNormal : SizePopUp.SPUSmall);
		onClose = close;
		
		lastLevelTry = LevelDesign.USER_DATA.levelMax;
		
		inter.onClick = onClickBG;
	}
	
	function close() {
		animEnd(function() {
			process.ProcessManager.ME.hideLife(hparent, this);
			if (Game.ME != null) {
				ProcessManager.ME.goTo(Game.ME, Levels, [lastLevelTry, false]);
			}
		});
	}
	
	function onClickBG(e) {
		if (!isTweening && (root.mouseY < popUp.y || root.mouseY > popUp.y + heiBG) && isCome)
			onClose();
	}
	
	override function init() {
		enableDeco = true;
		
		mt.device.EventTracker.view("ui.MoreLifes");
		
		textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPMoreLifes);
		
		super.init();
		
		if (LevelDesign.GET_LIFE() < LevelDesign.GET_MAX_LIFES()) {
			lblTime = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
			lblTime.filter = true;
			lblTime.maxWidth = Settings.STAGE_WIDTH;
			lblTime.textAlign = h2d.Text.Align.Center;
			lblTime.text = (Lang.GET_VARIOUS(TypeVarious.TVNextLife) + " : " + LifeManager.GET_STRING_TIME() + " !").toLowerCase();
			if (!hasNoLife)
				lblTime.y = Std.int(heiBG * 0.25 - lblTime.textHeight * 0.5);
			else
				lblTime.y = Std.int(heiBG * 0.2 - lblTime.textHeight * 0.5);
			arHS.push(lblTime);
			
			var bgTime = new h2d.Bitmap(h2d.Tile.fromColor(0xFF110A02, Settings.STAGE_WIDTH,Std.int(lblTime.textHeight)));
			bgTime.y = lblTime.y;
			arHS.push(bgTime);
			
			popUp.addChild(bgTime);
			popUp.addChild(lblTime);			
		}
		
		var lblAskMoney = new h2d.Text(Settings.FONT_BENCH_NINE_90, popUp);
		lblAskMoney.filter = true;
		if (LevelDesign.GET_LIFE() == 0)
			lblAskMoney.text = Lang.GET_VARIOUS(TypeVarious.TVAskBoughtLife);
		else
			lblAskMoney.text = Lang.GET_VARIOUS(TypeVarious.TVAskYourFriends);
		lblAskMoney.maxWidth = 0.75 * Settings.STAGE_WIDTH;
		lblAskMoney.textAlign = h2d.Text.Align.Center;
		lblAskMoney.textColor = 0x9D6434;
		lblAskMoney.x = Std.int((Settings.STAGE_WIDTH - lblAskMoney.maxWidth) * 0.5);
		if (!hasNoLife)
			lblAskMoney.y = Std.int(heiBG * 0.35);
		else
			lblAskMoney.y = Std.int(heiBG * 0.275);
		lblAskMoney.lineSpacing = Std.int(-lblAskMoney.textWidth / 20);
		arHS.push(lblAskMoney);
		
	// Btn
		btnAsk = new Button("btGreen", data.Lang.GET_BUTTON(TypeButton.TBAskToFriend), function () {
			//onClose();
			ProcessManager.ME.showAskLife(this, FriendRequestType.R_AskLife);
			//ProcessManager.ME.showAskLife(hparent);
		});
		btnAsk.resize();
		btnAsk.x = Std.int((Settings.STAGE_WIDTH - btnAsk.w) * 0.5);
		if (!hasNoLife)
			btnAsk.y = Std.int(heiBG * 0.65);
		else
			btnAsk.y = Std.int(heiBG * 0.55);
		popUp.addChild(btnAsk);
		
	// MONEY
		if (LevelDesign.GET_LIFE() == 0) {
			booster = new BoosterButton("iconLife", LevelDesign.GET_MAX_LIFES(), LevelDesign.GET_MAX_LIFES() + " additional lifes", Protocol.PRICE_5_LIFES, function() {
				if (!isDone) {
					isDone = true;
					booster.showLoading();
					if (LevelDesign.USER_DATA.gold >= Protocol.PRICE_5_LIFES)
						DataManager.DO_PROTOCOL(ProtocolCom.DoBuyLifes);
					else
						ProcessManager.ME.showShop(this);				
				}
			});
			if (isDone)
				booster.showLoading();
			booster.x = Std.int(Settings.STAGE_WIDTH * 0.5);
			booster.y = Std.int(heiBG * 0.75);
			popUp.addChild(booster);
			
			lblMoney = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
			lblMoney.filter = true;
			lblMoney.text = (Lang.GET_VARIOUS(TypeVarious.TVYouHave) + " " + (LevelDesign.USER_DATA.gold)).toLowerCase();
			lblMoney.y = Std.int(heiBG * 0.9 - lblMoney.textHeight * 0.5);
			arHS.push(lblMoney);
			popUp.addChild(lblMoney);
			
			hsIconCoin = Settings.SLB_UI.h_get("iconGold");
			hsIconCoin.setCenterRatio(0, 0.5);
			hsIconCoin.filter = true;
			hsIconCoin.scaleX = hsIconCoin.scaleY = Settings.STAGE_SCALE;
			hsIconCoin.y = Std.int(lblMoney.y + lblMoney.textHeight / 2);
			arHS.push(hsIconCoin);
			popUp.addChild(hsIconCoin);
			
			lblMoney.x = Std.int((Settings.STAGE_WIDTH - (lblMoney.textWidth + hsIconCoin.width)) / 2);
			hsIconCoin.x = Std.int(lblMoney.x + lblMoney.textWidth);
		}
	}
	
	public function validPurchase() {
		disableCloseBtn();
		booster.hideAll();
		mt.device.EventTracker.creditSpent("gold", Protocol.PRICE_5_LIFES, "buy.Life");
		var c = 0.;
		var actualMoney = LevelDesign.USER_DATA.gold;
		var t = tweener.create().to(0.5 * Settings.FPS, c = Protocol.PRICE_5_LIFES);
		function onUpdate(e) {
			lblMoney.text = (Lang.GET_VARIOUS(TypeVarious.TVYouHave) + " " + (actualMoney - Std.int(c))).toLowerCase();
			lblMoney.x = Std.int((Settings.STAGE_WIDTH - (lblMoney.textWidth + hsIconCoin.width)) / 2);
			hsIconCoin.x = Std.int(lblMoney.x + lblMoney.textWidth);			
		}
		function onComplete() {
			t = tweener.create().delay(0.5 * Settings.FPS);
			t.onComplete = endValidPurchase; 
		}
		t.onUpdate = onUpdate;
		t.onComplete = onComplete;
	}
	
	function endValidPurchase() {
		animEnd(function() {
			process.ProcessManager.ME.hideLife(hparent, this);
			if (Levels.ME != null && Levels.ME.lastLevelClicked > 0) {
				#if standalone
				if (!mt.device.User.isLogged() && Levels.ME.lastLevelClicked >= 16)
					process.ProcessManager.ME.showAskLog(Levels.ME, false);
				else
				#end
					new process.popup.GoalLevels(LevelDesign.GET_LEVEL(Levels.ME.lastLevelClicked), false);
			}
			else if (Game.ME != null && GoalLevels.ME != null)
				GoalLevels.ME.goToLevel();
			else if (Game.ME != null) {
				ProcessManager.ME.goTo(Game.ME, Game, [lastLevelTry, true]);
			}
		});
	}
	
	public function giveGold() {
		booster.hideLoading();
		isDone = false;
		
		lblMoney.text = (Lang.GET_VARIOUS(TypeVarious.TVYouHave) + " " + LevelDesign.USER_DATA.gold).toLowerCase();
		lblMoney.x = Std.int((Settings.STAGE_WIDTH - (lblMoney.textWidth + hsIconCoin.width)) / 2);
		hsIconCoin.x = Std.int(lblMoney.x + lblMoney.textWidth);
	}
	
	override function onResize() {
		if (btnAsk != null) {
			btnAsk.destroy();
			btnAsk = null;			
		}
		
		if (booster != null) {
			booster.destroy();
			booster = null;			
		}
		
		super.onResize();
	}
	
	override function unregister() {
		if (btnAsk != null) {
			btnAsk.destroy();
			btnAsk = null;			
		}
		
		if (booster != null) {
			booster.destroy();
			booster = null;			
		}
		
		ME = null;
		
		super.unregister();
	}
	
	override function update() {
		if (lblTime != null) {
			if (hasNoLife) {
				if (LevelDesign.GET_LIFE() > 0)
					lblTime.text = (Lang.GET_VARIOUS(TypeVarious.TVNewLife)).toLowerCase();
				else
					lblTime.text = (Lang.GET_VARIOUS(TypeVarious.TVNextLife) + " " + LifeManager.GET_STRING_TIME()).toLowerCase();
			}
			else
				lblTime.text = (Lang.GET_VARIOUS(TypeVarious.TVNextLife) + " " + LifeManager.GET_STRING_TIME()).toLowerCase();
		}
		
		if (booster != null)
			booster.update();
		
		super.update();
	}
}