package process.popup;

import mt.deepnight.deprecated.HProcess;
import mt.device.Cash.Product;
import process.popup.Shop.ShopButton;

import Protocol;
import Common;

import process.popup.BasePopup;
import data.LevelDesign;
import data.DataManager;
import data.Settings;
import data.Lang;
import ui.Button;
import process.popup.*;

/**
 * ...
 * @author Tipyx
 */
class Shop extends BasePopup
{
	public static var ME	: process.popup.Shop;
	
	var arSB				: Array<ShopButton>;
	var pd					: mt.device.Cash.ProductsData;
	var btnOther			: Button;
	var btnLogin			: Button;
	
	var firstInit			: Bool;

	public function new(hparent:HProcess) {
		ME = this;
		
		arSB = [];
		
		super(hparent, SizePopUp.SPUBig);
		
		onClose = close;
		
		firstInit = false;
	}
	
	function close() {
		if (Life.ME != null)
			Life.ME.giveGold();
			
		if (BoosterMoves.ME != null)
			BoosterMoves.ME.giveGold();
			
		if (BoosterPickaxe.ME != null)
			BoosterPickaxe.ME.giveGold();
		
		animEnd(function() {
			process.ProcessManager.ME.hideShop(hparent, this);
		});
	}
	
	override function init() {
		enableDeco = true;
		
		arSB = [];
		
		mt.device.EventTracker.view("ui.Shop");
		
		textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPShop);
		
		super.init();
		
	//	CONTENT
		//if (!Common.HAS_FLAG(LevelDesign.USER_DATA, UserFlags.UFFirstPurchase)) {
			var lblFirstPurchase = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_70, popUp);
			lblFirstPurchase.text = Lang.GET_VARIOUS(TypeVarious.TVOneMoreLife);
			lblFirstPurchase.x = Std.int((Settings.STAGE_WIDTH - lblFirstPurchase.textWidth) * 0.5);
			lblFirstPurchase.y = Std.int(heiBG * 0.1 - lblFirstPurchase.textHeight * 0.5);
			arHS.push(lblFirstPurchase);			
		//}
		
		#if standalone
		var canBuy = mt.device.User.isLogged();
		#else
		var canBuy = true;
		#end
		
		if ( canBuy ) {
			if (pd == null) {
				if (!firstInit) {
					firstInit = true;
					Main.ME.showLoading();
					
					mt.device.Cash.listProducts("gold", function (pd) {
						Main.ME.hideLoading();
						if (pd != null)
							initData(pd);
					});
				}
			}
			else
				initData(pd);
		}
		else {
			btnLogin = new ui.Button("btGreen", data.Lang.GET_BUTTON(TypeButton.TBLogIn), function () {
				mt.device.User.login();
			});
			btnLogin.resize();
			btnLogin.x = Std.int((Settings.STAGE_WIDTH - btnLogin.w) * 0.5);
			btnLogin.y = Std.int((Settings.STAGE_HEIGHT - btnLogin.h) * 0.5);
			popUp.addChild(btnLogin);
		}
	}
	
	function initData(pd:mt.device.Cash.ProductsData) {
		this.pd = pd;
		
		pd.list.sort(function(a, b) return a._moneyA._quantity - b._moneyA._quantity);
		
		var l = 0;
		var r = 0;
		
		if (pd.list[0] != null) {
			var sb0 = new ShopButton(0, pd.list[0]);
			sb0.x = l = Std.int(Settings.STAGE_WIDTH * 0.27 - sb0.wid * 0.5);
			sb0.y = Std.int(heiBG * 0.175);
			arSB.push(sb0);
			popUp.addChild(sb0);			
		}
		
		if (pd.list[1] != null) {
			var sb1 = new ShopButton(1, pd.list[1]);
			sb1.x = Std.int(Settings.STAGE_WIDTH * 0.5 - sb1.wid * 0.5);
			sb1.y = Std.int(heiBG * 0.175);
			arSB.push(sb1);
			popUp.addChild(sb1);
		}
		
		if (pd.list[2] != null) {
			var sb2 = new ShopButton(2, pd.list[2]);
			sb2.x = r = Std.int(Settings.STAGE_WIDTH * 0.73 - sb2.wid * 0.5);
			r += sb2.wid;
			sb2.y = Std.int(heiBG * 0.175);
			arSB.push(sb2);
			popUp.addChild(sb2);
		}
		
		if (pd.list[3] != null) {
			var sb3 = new ShopButton(3, pd.list[3]);
			if (l > 0)
				sb3.x = Std.int(l);
			else
				sb3.x = Std.int(Settings.STAGE_WIDTH * 0.4 - sb3.wid);
			sb3.y = Std.int(heiBG * 0.475);
			arSB.push(sb3);
			popUp.addChild(sb3);
		}
		
		if (pd.list[4] != null) {
			var sb4 = new ShopButton(4, pd.list[4]);
			if (r > 0)
				sb4.x = Std.int(r - sb4.wid);
			else
				sb4.x = Std.int(Settings.STAGE_WIDTH * 0.6);
			sb4.y = Std.int(heiBG * 0.475);
			arSB.push(sb4);
			popUp.addChild(sb4);
		}
		
		if (pd.otherPayment != null) {
			btnOther = new ui.Button("btGreen", Lang.GET_VARIOUS(TypeVarious.TVOtherPayment), function () {
				pd.otherPayment(function onBuyCB(t:mt.device.Cash.Transaction) {
					DataManager.DO_PROTOCOL(ProtocolCom.DoCheckTransaction);
				});
			});
			btnOther.resize();
			btnOther.x = Std.int((Settings.STAGE_WIDTH - btnOther.w) * 0.5);
			btnOther.y = Std.int(heiBG * 0.9 - btnOther.h * 0.5);
			popUp.addChild(btnOther);
		}
	}
	
	public function validPurchase() {
		onClose();
			
		if (Life.ME != null)
			Life.ME.giveGold();
			
		if (BoosterMoves.ME != null)
			BoosterMoves.ME.giveGold();
			
		if (BoosterPickaxe.ME != null)
			BoosterPickaxe.ME.giveGold();
	}
	
	var curW : Null<Int> = null;
	var curH : Null<Int> = null;
	override function onResize() {
		// Ignore fake resize
		var w = mt.Metrics.w();
		var h = mt.Metrics.h();
		if( curW == w && curH == h )
			return;
		curW = w;
		curH = h;

		
		for (sb in arSB)
			sb.destroy();
			
		arSB = [];
		
		if ( btnOther != null) {
			btnOther.destroy();
			btnOther = null;			
		}
		
		if (btnLogin != null) {
			btnLogin.destroy();
			btnLogin = null;
		}
		
		super.onResize();
	}
	
	override function unregister() {
		for (sb in arSB)
			sb.destroy();
			
		arSB = [];
		
		if (btnOther != null) {
			btnOther.destroy();
			btnOther = null;			
		}
		
		if (btnLogin != null) {
			btnLogin.destroy();
			btnLogin = null;
		}
		
		pd = null;
		
		ME = null;
		
		super.unregister();
	}
	
	override function update() {
		Settings.SLB_FX2.updateChildren();
		
		super.update();
	}
}

class ShopButton extends h2d.Sprite {
	var num				: Int;
	
	var hs				: mt.deepnight.slb.HSprite;
	var lblAmount		: h2d.Text;
	var hsGold			: mt.deepnight.slb.HSprite;
	var btn				: ui.Button;
	var hsAddText		: mt.deepnight.slb.HSprite;
	var hsLoading		: mt.deepnight.slb.HSprite;
	
	var inter			: h2d.Interactive;
	var product			: Product;
	
	public var wid			: Int;
	
	public function new(num:Int, product:Product) {
		super();
		
		this.product = product;
		this.num = num;
		
		trace(product);
		
		hs = Settings.SLB_NOTRIM.h_get("shopPrice", num);
		hs.scaleX = hs.scaleY = Settings.STAGE_SCALE;
		this.addChild(hs);
		
		btn = new ui.Button(num < 3 ? "uiBtPriceSmall" : "uiBtPriceBig", product._localEstimatedPrice != null ? product._localEstimatedPrice : product._price, function () {
			onClickShopButton(null);
		});
		btn.resize();
		btn.y = Std.int(hs.height + 30 * Settings.STAGE_SCALE);
		this.addChild(btn);
		
		if (num == 1 || num == 4) {
			hsAddText = Settings.SLB_LANG.h_get("shopTxt_" + (Settings.SLB_LANG_IS_DL ? data.Lang.LANG : "en"), num == 1 ? 0 : 1);
			hsAddText.setCenterRatio(0.5, 0.4);
			hsAddText.scaleX = hsAddText.scaleY = Settings.STAGE_SCALE #if !standalone / 0.65 #end;
			hsAddText.x = Std.int(hs.width * 0.5);
			this.addChild(hsAddText);
		}
		
		var wAmount = 0.;
		
		lblAmount = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_70);
		lblAmount.text = Std.string(product._moneyA._quantity);
		lblAmount.y = Std.int(hs.height - lblAmount.textHeight + 2 * Settings.STAGE_SCALE);
		this.addChild(lblAmount);
		
		hsGold = Settings.SLB_UI.h_get("iconGold");
		hsGold.setCenterRatio(0, 0.5);
		hsGold.scaleX = hsGold.scaleY = Settings.STAGE_SCALE * 0.5;
		hsGold.y = Std.int(lblAmount.y + lblAmount.textHeight * 0.5);
		this.addChild(hsGold);
		
		wAmount += lblAmount.width + hsGold.width;
		
		lblAmount.x = Std.int((hs.width - wAmount) * 0.5);
		hsGold.x = Std.int(lblAmount.x + lblAmount.textWidth);
		
		inter = new h2d.Interactive(hs.width, hs.height);
		inter.onClick = onClickShopButton;
		this.addChild(inter);
		
		hsLoading = Settings.SLB_FX2.h_getAndPlay("loading");
		hsLoading.scaleX = hsLoading.scaleY = Settings.STAGE_SCALE;
		hsLoading.setCenterRatio(0.5, 0.5);
		hsLoading.visible = false;
		hsLoading.x = Std.int(hs.width * 0.5);
		hsLoading.y = Std.int(btn.y + btn.h * 0.5);
		this.addChild(hsLoading);
		
		wid = Std.int(hs.width);
	}
	
	function onClickShopButton(e) {
		hsLoading.visible = true;
		btn.visible = false;
		product._buy(onBuyCB);
	}
	
	function onBuyCB(t:mt.device.Cash.Transaction) {
		if( hsLoading != null && btn != null ){
			hsLoading.visible = false;
			btn.visible = true;
		}

		DataManager.DO_PROTOCOL(ProtocolCom.DoCheckTransaction);
	}
	
	public function destroy() {
		hs.dispose();
		hs = null;
		
		btn.destroy();
		btn = null;
		
		lblAmount.dispose();
		lblAmount = null;
		
		hsGold.dispose();
		hsGold = null;
		
		if (hsAddText != null) {
			hsAddText.dispose();
			hsAddText = null;
		}
		
		hsLoading.dispose();
		hsLoading = null;
		
		dispose();
	}
}