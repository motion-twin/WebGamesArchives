package process.popup;

import manager.TutoManager;
import mt.deepnight.deprecated.HProcess;
import ui.Button;

import Protocol;
import Common;

import process.popup.BasePopup;
import data.DataManager;
import data.LevelDesign;
import data.Settings;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */
class BoosterPickaxe extends BasePopup
{
	public static var OFFSET_Y		: Int		= 100;
	public static var ME			: BoosterPickaxe;
	
	
	//static var AMOUNT		= [1, 5, 10, 20];
	static var AMOUNT							= [5];
	
	var booster				: BoosterButton;

	var actualPageNum		: Int;
	
	var lblMoney			: h2d.Text;
	var hsIconCoin			: mt.deepnight.slb.HSprite;
	var isTuto				: Bool;
	var isDone				: Bool;
	var oldMoney			: Int;

	public function new(hparent:HProcess) {
		ME = this;
		
		OFFSET_Y = Std.int(100 * Settings.STAGE_SCALE);
		
		isDone = false;
		
		isTuto = false;
		//if (!LevelDesign.TUTO_IS_DONE(5))
			//isTuto = true;
		
		super(hparent, SizePopUp.SPUSmall);
		
		onClose = close;
		
		if (isTuto)
			btnClose.visible = false;
	}
	
	function close() {
		animEnd(function() {
			process.ProcessManager.ME.hidePickaxeShop(hparent, this);				
		});
	}
	
	override function init() {
		enableDeco = true;
		
		mt.device.EventTracker.view("ui.BuyPickaxe");
		
		textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPBoughtPickaxe);
		
		super.init();
		
	// BTN SHOP
		var lblAskMoney = new h2d.Text(Settings.FONT_BENCH_NINE_90, popUp);
		lblAskMoney.filter = true;
		if (isTuto)
			lblAskMoney.text = Lang.GET_VARIOUS(TypeVarious.TVFree);
		lblAskMoney.maxWidth = 0.7 * Settings.STAGE_WIDTH;
		lblAskMoney.textAlign = h2d.Text.Align.Center;
		lblAskMoney.textColor = 0x9D6434;
		lblAskMoney.x = Std.int((Settings.STAGE_WIDTH - lblAskMoney.maxWidth) * 0.5);
		lblAskMoney.y = Std.int(heiBG * 0.20);
		arHS.push(lblAskMoney);
		
		booster = new BoosterButton("boostPickaxe", 5, "pioche", isTuto ? 0 : Protocol.PRICE_5_PICKAXE, function() {
			if (!isDone) {
				isDone = true;
				oldMoney = LevelDesign.USER_DATA.gold;
				booster.showLoading();
				if (isTuto)
					DataManager.DO_PROTOCOL(ProtocolCom.DoBuyPickaxes(true));
				else if (LevelDesign.USER_DATA.gold >= Protocol.PRICE_5_PICKAXE)
					DataManager.DO_PROTOCOL(ProtocolCom.DoBuyPickaxes(false));
				else
					ProcessManager.ME.showShop(this);				
			}
		});
		if (isDone)
			booster.showLoading();
		booster.x = Std.int(Settings.STAGE_WIDTH * 0.5);
		booster.y = Std.int(lblAskMoney.y + lblAskMoney.textHeight + booster.hei);
		popUp.add(booster, 1);
		
	// MONEY
		lblMoney = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
		lblMoney.filter = true;
		lblMoney.text = (Lang.GET_VARIOUS(TypeVarious.TVYouHave) + " " + (LevelDesign.USER_DATA.gold)).toLowerCase();
		lblMoney.y = Std.int(heiBG * 0.75);
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
	
	public function validPurchase() {
		var game = Game.ME;
		disableCloseBtn();
		booster.hideAll();
		
		function onComplete() {
			var t = tweener.create().delay(0.5 * Settings.FPS);
			t.onComplete = endValidPurchase;
		}
		if (isTuto) {
			onComplete();
		}
		else {
			mt.device.EventTracker.creditSpent("gold", Protocol.PRICE_5_PICKAXE, "buy.Pickaxe");
			
			var c = 0.;
			var actualMoney = LevelDesign.USER_DATA.gold;
			var t = tweener.create().to(0.5 * Settings.FPS, c = Protocol.PRICE_5_PICKAXE);
			function onUpdate(e) {
				lblMoney.text = (Lang.GET_VARIOUS(TypeVarious.TVYouHave) + " " + (actualMoney - Std.int(c))).toLowerCase();
				lblMoney.x = Std.int((Settings.STAGE_WIDTH - (lblMoney.textWidth + hsIconCoin.width)) / 2);
				hsIconCoin.x = Std.int(lblMoney.x + lblMoney.textWidth);
			}
			t.onUpdate = onUpdate;
			t.onComplete = onComplete;
		}
	}
	
	function endValidPurchase() {
		var game = Game.ME;
		LevelDesign.USER_DATA.gold -= Protocol.PRICE_5_PICKAXE;
		LevelDesign.USER_DATA.pickaxe = 5;
		game.resume();
		animEnd(function() {
			game.uiTop.refill();
			destroy();
		});
	}
	
	public function giveGold() {
		booster.hideLoading();
		isDone = false;
		lblMoney.text = (Lang.GET_VARIOUS(TypeVarious.TVYouHave) + " " + LevelDesign.USER_DATA.gold).toLowerCase();
		lblMoney.x = Std.int((Settings.STAGE_WIDTH - (lblMoney.textWidth + hsIconCoin.width)) / 2);
		hsIconCoin.x = Std.int(lblMoney.x + lblMoney.textWidth);
	}
	
	override public function resume() {
		giveGold();
		
		super.resume();
		
		onResize();
	}
	
	override function onResize() {
		if (booster != null)
			booster.destroy();
		
		OFFSET_Y = Std.int(100 * Settings.STAGE_SCALE);
		
		super.onResize();
	}
	
	override function unregister() {
		booster.destroy();
		booster = null;
		
		ME = null;
		
		super.unregister();
	}
	
	override function update() {
		booster.update();
		
		super.update();
	}
}

class BoosterButton extends h2d.Sprite {
	static var OFFSET_X	: Int		= 20;
	
	var amount			: Int;
	
	public var hei		: Int;
	
	var btn				: Button;
	
	var hsBGIcon		: mt.deepnight.slb.HSprite;
	var hsIcon			: mt.deepnight.slb.HSprite;
	var lblAmount		: h2d.Text;
	
	var hsBGPrice		: mt.deepnight.slb.HSprite;
	var hsIconCoin		: mt.deepnight.slb.HSprite;
	var lblPrice		: h2d.Text;
	var hsLoading		: mt.deepnight.slb.HSprite;
	
	public function new(idIcon:String, amount:Int, title:String, price:Int, onClick:Void->Void) {
		super();
		
		OFFSET_X = Std.int(20 * Settings.STAGE_SCALE);
		
		this.amount = amount;
		
	// BUTTON
		btn = new Button("btOrange", data.Lang.GET_BUTTON(TypeButton.TBRefill), onClick);
		btn.resize();
		btn.x = Std.int(-btn.w * 0.5);
		btn.y = Std.int(-btn.h * 0.5);
		this.addChild(btn);
		
	// ICON GAME
		hsBGIcon = Settings.SLB_UI.h_get("bgPrice");
		hsBGIcon.setCenterRatio(1, 0.5);
		hsBGIcon.filter = true;
		hsBGIcon.scaleX = hsBGIcon.scaleY = Settings.STAGE_SCALE;
		hsBGIcon.x = Std.int( -btn.w * 0.5 - OFFSET_X);
		this.addChild(hsBGIcon);
		
		hsIcon = Settings.SLB_UI.h_get(idIcon);
		hsIcon.setCenterRatio(0.5, 0.5);
		hsIcon.filter = true;
		hsIcon.scaleX = hsIcon.scaleY = Settings.STAGE_SCALE;
		hsIcon.x = Std.int(hsBGIcon.x - hsBGIcon.width * 0.25);
		this.addChild(hsIcon);
		
		if (amount > 0) {
			lblAmount = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_70, this);
			lblAmount.letterSpacing = Std.int(5 * Settings.STAGE_SCALE);
			lblAmount.text = "$" + amount;
			lblAmount.filter = true;
			lblAmount.x = Std.int(hsBGIcon.x - hsBGIcon.width * 0.75 - lblAmount.textWidth * 0.5);
			lblAmount.y = Std.int(-lblAmount.textHeight * 0.5);			
		}
		
	// ICON PRICE
		hsBGPrice = Settings.SLB_UI.h_get("bgPrice");
		hsBGPrice.setCenterRatio(0, 0.5);
		hsBGPrice.filter = true;
		hsBGPrice.scaleX = hsBGPrice.scaleY = Settings.STAGE_SCALE;
		hsBGPrice.x = Std.int(btn.w * 0.5 + OFFSET_X);
		this.addChild(hsBGPrice);
		
		hsIconCoin = Settings.SLB_UI.h_get("iconGold");
		hsIconCoin.setCenterRatio(0.5, 0.5);
		hsIconCoin.filter = true;
		hsIconCoin.scaleX = hsIconCoin.scaleY = Settings.STAGE_SCALE;
		hsIconCoin.x = Std.int(hsBGPrice.x + hsBGPrice.width * 0.75);
		this.addChild(hsIconCoin);
		
		lblPrice = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_70, this);
		lblPrice.text = Std.string(price);
		lblPrice.filter = true;
		lblPrice.x = Std.int(hsBGPrice.x + hsBGPrice.width * 0.25 - lblPrice.textWidth * 0.5);
		lblPrice.y = Std.int( -lblPrice.textHeight * 0.5);
		
		hsLoading = Settings.SLB_FX2.h_getAndPlay("loading");
		hsLoading.scaleX = hsLoading.scaleY = Settings.STAGE_SCALE;
		hsLoading.setCenterRatio(0.5, 0.5);
		hsLoading.visible = false;
		this.addChild(hsLoading);
		
		hei = Std.int(btn.h);
	}
	
	public function showLoading() {
		btn.visible = false;
		hsLoading.visible = true;
	}
	
	public function hideLoading() {
		btn.visible = true;
		hsLoading.visible = false;
	}
	
	public function hideAll() {
		btn.visible = false;
		hsLoading.visible = false;
	}
	
	public function destroy() {
		btn.destroy();
		btn = null;
		
		hsBGIcon.dispose();
		hsBGIcon = null;
		
		hsIcon.dispose();
		hsIcon = null;
		
		if (lblAmount != null) {
			lblAmount.dispose();
			lblAmount = null;			
		}
		
		hsBGPrice.dispose();
		hsBGPrice = null;
		
		hsIconCoin.dispose();
		hsIconCoin = null;
		
		lblPrice.dispose();
		lblPrice = null;
		
		hsLoading.dispose();
		hsLoading = null;
	}
	
	public function update() {
		hsLoading.a.update();
	}
}