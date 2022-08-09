package process.popup;

import mt.deepnight.deprecated.HProcess;

import Protocol;
import Common;

import process.popup.BasePopup;
import data.LevelDesign;
import data.DataManager;
import data.Settings;
import process.popup.BoosterPickaxe;
import manager.SoundManager;
import manager.TutoManager;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */
class BoosterMoves extends BasePopup
{
	public static var ME	: BoosterMoves;
	
	var booster				: BoosterButton;
	
	var lblMoney			: h2d.Text;
	var hsIconCoin			: mt.deepnight.slb.HSpriteBE;
	
	var isDone				: Bool;
	var isTuto				: Bool;
	var oldMoney			: Int;

	public function new(hparent:mt.deepnight.deprecated.HProcess) {
		isDone = false;
		
		isTuto = false;
		if (Game.ME.levelInfo.level <= 3 && LevelDesign.USER_DATA.arHighScore[Game.ME.levelInfo.level] == null)
			isTuto = true;
		
		ME = this;
		
		super(hparent, SizePopUp.SPUSmall);
		
		onClose = close;
		
		if (isTuto)
			disableCloseBtn();
	}
	
	function close() {
		animEnd(function() {
			Game.ME.showEnd(false);
			destroy();				
		});
	}
	
	override function init() {
		var game = Game.ME;
		
		enableDeco = true;
		
		mt.device.EventTracker.view("ui.BuyMoves");
		
		textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPNoMoreMoves);
		
		super.init();
		
	// Miss
		var lblMiss = new h2d.Text(Settings.FONT_BENCH_NINE_90, popUp);
		lblMiss.text = Lang.GET_VARIOUS(TypeVarious.TVMiss);
		lblMiss.maxWidth = 0.7 * Settings.STAGE_WIDTH;
		lblMiss.textAlign = h2d.Text.Align.Center;
		lblMiss.textColor = 0xF8D189;
		lblMiss.x = Std.int((Settings.STAGE_WIDTH - lblMiss.maxWidth) / 2);
		lblMiss.y = Std.int(heiBG * 0.05);
		lblMiss.visible = false;
		arHS.push(lblMiss);
		
		var widBG = 0.;
		
		switch (game.levelInfo.type) {
			case TypeGoal.TGScoring(v) :
				if (v - game.score.get() < 5000) {
					lblMiss.visible = true;
					var lblScore = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
					lblScore.text = (v - game.score.get()) + " points";
					lblScore.x = Std.int((Settings.STAGE_WIDTH - lblScore.width) / 2);
					lblScore.y = Std.int(heiBG * 0.225);
					widBG = lblScore.width;
					arHS.push(lblScore);
					popUp.add(lblScore, 2);
				}
			case TypeGoal.TGCollect(ar) :
				var arEl = [];
				for (e in ar) {
					var num = 0;
					for (er in game.goalManager.arRockRecovered) {
						if (er.tr.equals(e.tr)) {
							if (e.num > er.num)
								num = er.num;
							else
								num = e.num;
						}
					}
					
					arEl.push( { tr:e.tr, num:e.num - num} );
				}
				var sum = 0;
				for (e in arEl)
					sum += e.num;
					
				if (sum < 15) {
					var cSprite = new h2d.Sprite(popUp);
					cSprite.y = Std.int(heiBG * 0.225);	
					lblMiss.visible = true;
					var wx = 0.;
					for (e in arEl) {
						if (e.num > 0) {
							var txt = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90, cSprite);
							txt.text = Std.string(e.num);
							txt.x = wx;
							wx += txt.textWidth * 1.1;
							arHS.push(txt);
							
							var hs = Settings.SLB_GRID.h_get(Common.GET_HSID_FROM_TYPEROCK(e.tr, game.levelInfo.biome));
							hs.setCenterRatio(0.5, 0.5);
							hs.scaleX = hs.scaleY = Settings.STAGE_SCALE * 0.75;
							hs.x = wx + Rock.SIZE_OFFSET * 0.5;
							hs.y = Std.int(Rock.SIZE_OFFSET * 0.5);
							cSprite.addChild(hs);
							arHS.push(hs);
							wx += Rock.SIZE_OFFSET * 1.1;							
						}
					}
					cSprite.x = Std.int((Settings.STAGE_WIDTH - wx) * 0.5);
					popUp.add(cSprite, 2);
					widBG = wx;
					arHS.push(cSprite);
				}
			case TypeGoal.TGGelatin(ar) :
				if (game.arGelatin.length < 8) {
					lblMiss.visible = true;
					var txt = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
					txt.text = Std.string(game.arGelatin.length);
					txt.y = Std.int(heiBG * 0.225);	
					popUp.add(txt, 2);
					arHS.push(txt);
					
					var hs = Settings.SLB_GRID.h_get("mudBack");
					hs.setCenterRatio(0, 0.55);
					hs.scaleX = hs.scaleY = Settings.STAGE_SCALE * 0.6;
					hs.y = Std.int(heiBG * 0.225 + Rock.SIZE_OFFSET * 0.5);
					popUp.add(hs, 2);
					arHS.push(hs);
					
					widBG = txt.width + hs.width;
					
					txt.x = Std.int(Settings.STAGE_WIDTH * 0.5 - widBG * 0.5);
					hs.x = Std.int(Settings.STAGE_WIDTH * 0.5 - widBG * 0.5 + txt.width);
				}
			case TypeGoal.TGMercury(numReq, ar) :
				if (numReq - game.arMerc.length < 8) {
					lblMiss.visible = true;
					var txt = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
					txt.text = Std.string(numReq - game.arMerc.length);
					txt.y = Std.int(heiBG * 0.225);
					popUp.add(txt, 2);
					arHS.push(txt);
					
					var hs = Settings.SLB_GRID.h_get("mercury");
					hs.setCenterRatio(0, 0.55);
					hs.scaleX = hs.scaleY = Settings.STAGE_SCALE * 0.5;
					hs.y = Std.int(heiBG * 0.225 + Rock.SIZE_OFFSET * 0.5);
					popUp.add(hs, 2);
					arHS.push(hs);
					
					widBG = txt.width + hs.width;
					
					txt.x = Std.int(Settings.STAGE_WIDTH * 0.5 - widBG * 0.5);
					hs.x = Std.int(Settings.STAGE_WIDTH * 0.5 - widBG * 0.5 + txt.width);
				}
		}
		
		if (lblMiss.visible) {
			var bgMiss = Settings.SLB_UI.hbe_get(bm, "bgElements");
			bgMiss.scaleX = (widBG * 1.1) / bgMiss.width;
			bgMiss.scaleY = Settings.STAGE_SCALE;
			bgMiss.x = Std.int((Settings.STAGE_WIDTH - bgMiss.width) * 0.5);
			bgMiss.y = Std.int(heiBG * 0.225);
			arBE.push(bgMiss);
			
			var leftBGMiss = Settings.SLB_UI.hbe_get(bm, "bgElementsLeft");
			leftBGMiss.setCenterRatio(1, 0);
			leftBGMiss.scaleX = leftBGMiss.scaleY = Settings.STAGE_SCALE;
			leftBGMiss.x = Std.int(bgMiss.x);
			leftBGMiss.y = Std.int(heiBG * 0.225);
			arBE.push(leftBGMiss);
			
			var rightBGMiss = Settings.SLB_UI.hbe_get(bm, "bgElementsLeft");
			rightBGMiss.setCenterRatio(1, 0);
			rightBGMiss.scaleX = -Settings.STAGE_SCALE;
			rightBGMiss.scaleY = Settings.STAGE_SCALE;
			rightBGMiss.x = Std.int(bgMiss.x + bgMiss.width);
			rightBGMiss.y = Std.int(heiBG * 0.225);
			arBE.push(rightBGMiss);
		}
		
	// Btn
		var lblAskMoney = new h2d.Text(Settings.FONT_BENCH_NINE_90, popUp);
		if (isTuto)
			lblAskMoney.text = Lang.GET_VARIOUS(TypeVarious.TVFreeFirstLevel);
		else
			lblAskMoney.text = Lang.GET_VARIOUS(TypeVarious.TVMoreMoves);
		lblAskMoney.maxWidth = 0.9 * Settings.STAGE_WIDTH;
		lblAskMoney.textAlign = h2d.Text.Align.Center;
		lblAskMoney.textColor = 0x9D6434;
		lblAskMoney.x = Std.int((Settings.STAGE_WIDTH - lblAskMoney.maxWidth) / 2);
		if (lblMiss.visible)
			lblAskMoney.y = Std.int(heiBG * 0.4);
		else
			lblAskMoney.y = Std.int(heiBG * 0.25);
		arHS.push(lblAskMoney);
		
		booster = new BoosterButton("moves", 5, "5 additional moves", isTuto ? 0 : Protocol.PRICE_5_MOVES, function() {
			if (!isDone) {
				isDone = true;
				oldMoney = LevelDesign.USER_DATA.gold;
				booster.showLoading();
				if (isTuto)
					DataManager.DO_PROTOCOL(ProtocolCom.DoBuyMoves(true));
				else if (LevelDesign.USER_DATA.gold >= Protocol.PRICE_5_MOVES)
					DataManager.DO_PROTOCOL(ProtocolCom.DoBuyMoves(false));
				else
					ProcessManager.ME.showShop(this);
			}
		});
		if (isDone)
			booster.showLoading();
		booster.x = Std.int(Settings.STAGE_WIDTH * 0.5);
		if (lblMiss.visible)
			booster.y = Std.int(heiBG * 0.65);
		else
			booster.y = Std.int(heiBG * 0.5);
		popUp.addChild(booster);
		
	// MONEY
		lblMoney = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
		lblMoney.filter = true;
		lblMoney.text = (Lang.GET_VARIOUS(TypeVarious.TVYouHave) + " " + (LevelDesign.USER_DATA.gold)).toLowerCase();
		if (lblMiss.visible)
			lblMoney.y = Std.int(heiBG * 0.75);
		else
			lblMoney.y = Std.int(heiBG * 0.6);
		arHS.push(lblMoney);
		popUp.addChild(lblMoney);
		
		hsIconCoin = Settings.SLB_UI.hbe_get(bm, "iconGold");
		hsIconCoin.setCenterRatio(0, 0.5);
		hsIconCoin.scaleX = hsIconCoin.scaleY = Settings.STAGE_SCALE;
		hsIconCoin.y = Std.int(lblMoney.y + lblMoney.textHeight / 2);
		arBE.push(hsIconCoin);
		
		lblMoney.x = Std.int((Settings.STAGE_WIDTH - (lblMoney.textWidth + hsIconCoin.width)) / 2);
		hsIconCoin.x = Std.int(lblMoney.x + lblMoney.textWidth);
	}
	
	public function validPurchase() {
		disableCloseBtn();
		booster.hideAll();
		mt.device.EventTracker.creditSpent("gold", Protocol.PRICE_5_MOVES, "buy.Moves");
		var c = 0.;
		var t = tweener.create().to(0.5 * Settings.FPS, c = isTuto ? 0 : Protocol.PRICE_5_MOVES);
		function onUpdate(e) {
			lblMoney.text = (Lang.GET_VARIOUS(TypeVarious.TVYouHave) + " " + (oldMoney - Std.int(c))).toLowerCase();
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
		//LevelDesign.USER_DATA.gold -= Protocol.PRICE_5_MOVES;
		animEnd(function() {
			Game.ME.addMove(5);
			Game.ME.enableClick();
			SoundManager.ADD_MOVES_SFX();
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
	
	override function onResize() {
		if (booster != null) {
			booster.destroy();
			booster = null;
		}
		
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