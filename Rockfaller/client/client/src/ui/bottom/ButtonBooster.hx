package ui.bottom ;

import data.DataManager;
import mt.deepnight.slb.HSprite;
import mt.deepnight.deprecated.TinyProcess;

import Protocol;
import Common;

import data.Settings;
import data.LevelDesign;
import process.Game;
import manager.TutoManager;

/**
 * ...
 * @author Tipyx
 */

 
class ButtonBooster extends h2d.Layers
{
	var game			: Game;
	var uiTop			: ui.top.UITop;
	
	var hsBG			: HSprite;
	var hsRollOver		: HSprite;
	var hsBtn			: HSprite;
	
	var isEnable		: Bool;
	
	public var w		: Float;
	public var h		: Float;
	public var size		: Float;
	
	var inter			: h2d.Interactive;
	var t				: mt.motion.Tween;
	
	var arFXCollect		: Array<{ hs:HSprite, tp:TinyProcess }>;
	var hlIsVisible		: Bool;
	
	var isTuto			: Bool;
	
	public function new(uiBottom:ui.top.UITop) {
		super();
		
		game = Game.ME;
		
		this.uiTop = uiBottom;
		
		arFXCollect = [];
		
		hlIsVisible = false;
		
		hsBG = Settings.SLB_UI.h_get("uiBgBt");
		hsBG.setCenterRatio(0.5, 1);
		hsBG.filter = true;
		w = hsBG.width;
		h = hsBG.height;
		this.add(hsBG, 0);
		
		hsRollOver = Settings.SLB_FX2.h_get("uiBgBtLight");
		hsRollOver.setCenterRatio(0.5, 1);
		hsRollOver.filter = true;
		hsRollOver.alpha = 0;
		this.add(hsRollOver, 1);
		
		hsBtn = Settings.SLB_UI.h_get("boostPickaxe");
		hsBtn.setCenterRatio(0.5, 0.55);
		hsBtn.filter = true;
		
		this.add(hsBtn, 3);
		
		inter = new h2d.Interactive(hsBG.width, hsBG.height, hsBG);
		inter.setPos(Std.int( -hsBG.width / 2), Std.int( -hsBG.height));
		inter.onOver = onOverBtnBooster;
		inter.onOut = onOutBtnBooster;
		inter.onClick = onClick;
		
		isEnable = false;
		
		if (TutoManager.ACTUAL_TUTO != null && TutoManager.ACTUAL_TUTO.level == 12 && TutoManager.ACTUAL_TUTO.step == 1)
			isTuto = true;
		else
			isTuto = false;
	}
	
	function onOverBtnBooster(e) {
		t = process.Game.ME.tweener.create().to(0.2 * Settings.FPS, hsRollOver.alpha = 1).ease(mt.motion.Ease.easeOutSine);
	}
	
	function onOutBtnBooster(e) {
		if (!isEnable)
			t = process.Game.ME.tweener.create().to(0.5 * Settings.FPS, hsRollOver.alpha = 0).ease(mt.motion.Ease.easeOutSine);
	}
	
	function onClick(e) {
		if (TutoManager.ACTUAL_TUTO != null && TutoManager.ACTUAL_TUTO.level == 12) {
			if (TutoManager.ACTUAL_TUTO.step == 1) {
				toggle();
				hideHL();
				TutoManager.HIDE_POPUP(function () {
					Game.ME.setRollOverPickaxe(4, 5);
					Game.ME.showRollOverPickaxe();
					Rock.AR_SEL = [Rock.GET_AT(4, 5)];
					TutoManager.SHOW_POPUP(12, 2);
					uiTop.hidePickaxe();
				});
			}
			return;
		}
		
		if (LevelDesign.USER_DATA.pickaxe > 0) {
			toggle();
			hideHL();
		}
		else {
			process.ProcessManager.ME.showPickaxeShop(process.Game.ME);
			hideHL();
		}		
	}
	
	public function toggle(newIsEnable:Null<Bool> = null) {
		if (newIsEnable == null)
			isEnable = !isEnable;
		else
			isEnable = newIsEnable;
		
		if (t != null && !t.disposed)
			t.dispose();
			
		if (isEnable) {
			if (hsRollOver.alpha == 0)
				t = process.Game.ME.tweener.create().to(0.2 * Settings.FPS, hsRollOver.alpha = 1).ease(mt.motion.Ease.easeOutSine);
			hsRollOver.a.playAndLoop("activeBooster");
			
			if (TutoManager.ACTUAL_TUTO != null && TutoManager.ACTUAL_TUTO.level == 12 && TutoManager.ACTUAL_TUTO.step == 1)
				uiTop.pickaxeEnable = true;
			else {
				DataManager.DO_PROTOCOL(ProtocolCom.DoCheckPickaxe, function (d) {
					enablePickaxe(false);
				});
				uiTop.waitServ = true;
			}
		}
		else {
			if (hsRollOver.alpha == 1)
				t = process.Game.ME.tweener.create().to(0.2 * Settings.FPS, hsRollOver.alpha = 0).ease(mt.motion.Ease.easeOutSine);
			hsRollOver.set("uiBgBtLight", 0, true);
			uiTop.pickaxeEnable = false;
			uiTop.waitServ = false;
		}
	}
	
	public function enablePickaxe(canUse:Bool) {
		uiTop.waitServ = false;
		if (canUse)
			uiTop.pickaxeEnable = true;
		else
			toggle(false);
	}
	
	public function showHL() {
		hlIsVisible = true;
		for (fx in arFXCollect)
			game.tweener.create().to(0.1 * Settings.FPS, fx.hs.alpha = 1);
	}
	
	public function hideHL() {
		hlIsVisible = false;
		for (fx in arFXCollect)
			game.tweener.create().to(0.1 * Settings.FPS, fx.hs.alpha = 0);
	}
	
	function setHL(symbol:HSprite) {
		var color = "fxShineWhite";
		
		var hs1 = Settings.SLB_FX.h_get(color + "A");
		hs1.setCenterRatio(0.5, 0.5);
		hs1.blendMode = Add;
		hs1.filter = true;
		hs1.alpha = hlIsVisible ? 1 : 0;
		hs1.scaleX = hs1.scaleY = Settings.STAGE_SCALE * 2;
		hs1.x = Std.int(symbol.x);
		hs1.y = Std.int(symbol.y);
		this.add(hs1, 2);
		
		var tp1 = game.createTinyProcess();
		tp1.onUpdate = function () {
			if (hs1 == null)
				tp1.destroy();
			else
				hs1.rotation += 0.02;
		}
		
		arFXCollect.push( { hs:hs1, tp:tp1 } );
		
		var hs2 = Settings.SLB_FX.h_get(color + "B");
		hs2.setCenterRatio(0.5, 0.5);
		hs2.blendMode = Add;
		hs2.filter = true;
		hs2.alpha = hlIsVisible ? 1 : 0;
		hs2.x = hs1.x;
		hs2.y = hs1.y;
		hs2.scaleX = hs2.scaleY = Settings.STAGE_SCALE * 2;
		this.add(hs2, 2);
		
		var tp2 = game.createTinyProcess();
		tp2.onUpdate = function () {
			if (hs2 == null)
				tp2.destroy();
			else
				hs2.rotation -= 0.02;
		}
		
		arFXCollect.push( { hs:hs2, tp:tp2 } );
		
		var hs3 = Settings.SLB_FX.h_get(color + "C");
		hs3.setCenterRatio(0.5, 0.5);
		hs3.blendMode = Add;
		hs3.filter = true;
		hs3.alpha = hlIsVisible ? 1 : 0;
		hs3.x = hs1.x;
		hs3.y = hs1.y;
		hs3.scaleX = hs3.scaleY = Settings.STAGE_SCALE * 2;
		this.add(hs3, 2);
		
		var tp3 = game.createTinyProcess();
		tp3.onUpdate = function () {
			if (hs3 == null)
				tp3.destroy();
			else
				hs3.rotation -= 0.01;
		}
		
		arFXCollect.push( { hs:hs3, tp:tp3 } );
		
		color = "fxShineWhite";
	}
	
	public function disable() {
		isEnable = false;
		
		t = process.Game.ME.tweener.create().to(0.5 * Settings.FPS, hsRollOver.alpha = 0).ease(mt.motion.Ease.easeOutSine);
	}
	
	public function resize(scaling:Null<Float>) {
		hsBG.scaleX = hsBG.scaleY = scaling;
		hsRollOver.scaleX = hsRollOver.scaleY = scaling;
		hsBtn.scaleX = hsBtn.scaleY = scaling;
		
		for (fx in arFXCollect) {
			fx.hs.dispose();
			fx.hs = null;
			fx.tp.destroy();
		}
		
		arFXCollect = [];
		
		w = hsBG.width;
		h = hsBG.height;
		
		size = hsBtn.height;
		
		hsBtn.y = -Std.int(h / 2);
		
		setHL(hsBtn);
	}
	
	public function destroy() {
		for (fx in arFXCollect) {
			fx.hs.dispose();
			fx.hs = null;
			fx.tp.destroy();
		}
		
		arFXCollect = [];
		
		hsBG.dispose();
		hsBG = null;
		
		hsRollOver.dispose();
		hsRollOver = null;
		
		hsBtn.dispose();
		hsBtn = null;
		
		inter.dispose();
		inter = null;
	}
}