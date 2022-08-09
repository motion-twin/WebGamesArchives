package ui.top ;

import h2d.Sprite;
import manager.TutoManager;

import mt.deepnight.slb.HSpriteBE;

import Protocol;
import Common;

import ui.bottom.ButtonBooster;
import process.Game;
import data.Settings;
import data.DataManager;
import data.LevelDesign;
import Rock;

/**
 * ...
 * @author Tipyx
 */
class UITop extends h2d.Layers
{
	static var SIZE_TEXT	= 34;
	
	static var num		= 0;
	static var DM_BG	= num++;
	static var DM_DECO	= num++;
	static var DM_FX	= num++;
	static var DM_BTN	= num++;
	
	var game					: process.Game;
	
	public var pickaxeEnable	: Bool;
	public var waitServ			: Bool;
	public var offset			: Int;
	
	// TOP
	var bmUI					: h2d.SpriteBatch;
	var uiTopLeft				: HSpriteBE;
	var uiTopRight				: HSpriteBE;
	var uiBotLeft				: HSpriteBE;
	var uiBotRight				: HSpriteBE;
	
	public var modMoves			: ui.top.ModuleMoves;
	var modScore				: ui.top.ModuleScore;
	public var modGoal			: ui.top.ModuleGoal;
	
	// BOT
	var btnPause				: ui.Button;
	public var btnPickaxe		: ButtonBooster;
	
	public var lblNumBooster	: h2d.Text;
	
	public var scaling		: Float;
	
	public function new() {
		super();
		
		game = process.Game.ME;
		
		scaling = Settings.STAGE_SCALE;
		
		pickaxeEnable = false;
		waitServ = false;
		
		bmUI = new h2d.SpriteBatch(Settings.SLB_UI.tile, this);
		bmUI.optimizeForStatic(true);
		bmUI.invalidate();
		
		uiTopLeft = Settings.SLB_UI.hbe_get(bmUI, "uiBgLeft");
		uiTopRight = Settings.SLB_UI.hbe_get(bmUI, "uiBgLeft");
		uiBotLeft = Settings.SLB_UI.hbe_get(bmUI, "uiMenu");
		uiBotLeft.setCenterRatio(0, 1);
		
		if (game.levelInfo.level >= 12) {
			uiBotRight = Settings.SLB_UI.hbe_get(bmUI, "uiMenu");
			uiBotRight.setCenterRatio(0, 1);
			
			btnPickaxe = new ButtonBooster(this);
			this.addChild(btnPickaxe);		
		}
		
		modMoves = new ui.top.ModuleMoves();
		this.add(modMoves, DM_BTN);
		
		modScore = new ui.top.ModuleScore();
		this.add(modScore, DM_BTN);
		
		modGoal = new ui.top.ModuleGoal();
		this.add(modGoal, DM_BTN);
		
		btnPause = new ui.Button("uiBtMenu", "", function () {
			if (!game.isEndGame && process.popup.Pause.ME == null)
				process.ProcessManager.ME.showPause(game);
		});
		this.addChild(btnPause);
		
		if (game.levelInfo.level == 1) {
			uiTopLeft.visible = false;
			modMoves.visible = modGoal.visible = false;
		}
		else if (game.levelInfo.level == 2 || game.levelInfo.level == 3) {
			modMoves.visible = false;
		}
	}
	
	public function init() {
		modMoves.init();
		modGoal.init();
	}
	
	public function updateScore() {
		modScore.updateScore();	
	}
	
	public function updateGoal(r:Rock = null) {
		modGoal.updateValue(r);
	}
	
	public function addMoves(num:Int) {
		modMoves.addMovePending += num;
	}
	
	public function costMove() {
		if (game.levelInfo.level <= 2) {
			TutoManager.countMoves++;
		}
		else {
			game.movesLeft.addValue(-1);
			modMoves.costMove();
		}
	}
	
	public function getHeightTop():Float {
		return Settings.SLB_UI.getFrameData("uiMoves").hei * Settings.STAGE_SCALE;
	}
	
	public function costBooster() {
		if (btnPickaxe != null) {
			btnPickaxe.disable();
			
			game.pickaxeUsed++;
			
			lblNumBooster.text = "$ " + (LevelDesign.USER_DATA.pickaxe - 1);
			lblNumBooster.x = Std.int(btnPickaxe.x - lblNumBooster.textWidth / 2);
			
			if (LevelDesign.TUTO_IS_DONE(12) || Game.ME.levelInfo.level > 12)
				DataManager.DO_PROTOCOL(ProtocolCom.DoUsePickaxe);
			else
				LevelDesign.USER_DATA.pickaxe = 1;
			
			pickaxeEnable = false;			
		}
	}
	
	public function refill() {
		if (btnPickaxe != null) {
			manager.SoundManager.ADD_MOVES_SFX();
			btnPickaxe.showHL();
			var c = 0.;
			var t = Game.ME.tweener.create().to(1 * Settings.FPS, c = LevelDesign.USER_DATA.pickaxe);
			function onUpdate(e) {
				lblNumBooster.text = "$ " + Std.int(c);
				lblNumBooster.x = Std.int(btnPickaxe.x - lblNumBooster.textWidth / 2);				
			}
			function onComplete() {
				t = Game.ME.tweener.create().delay(0.5 * Settings.FPS);
				t.onComplete = function () {
					if (btnPickaxe != null)
						btnPickaxe.hideHL();
				}				
			}
			t.onUpdate = onUpdate;
			t.onComplete = onComplete;
		}
	}
	
	public function hidePickaxe() {
		btnPickaxe.visible = false;
		lblNumBooster.visible = false;
		bmUI.invalidate();
		uiBotRight.visible = false;
	}
	
	public function resize() {
		bmUI.invalidate();
		
		scaling = Settings.STAGE_SCALE;
	#if mBase
		uiBotLeft.scaleX = uiBotLeft.scaleY = Settings.STAGE_SCALE;
		if (mt.Metrics.px2cm(uiBotLeft.width) < 2)
			scaling = Settings.STAGE_SCALE * 1.5;
	#end
		
	//	UI TOP
		uiTopLeft.scaleX = uiTopLeft.scaleY = Settings.STAGE_SCALE;
		offset = Std.int(uiTopLeft.height * 0.1);
		
		uiTopLeft.x = uiTopLeft.y = -offset;
		
		uiTopRight.scaleX = -Settings.STAGE_SCALE;
		uiTopRight.scaleY = Settings.STAGE_SCALE;
		uiTopRight.x = Std.int(Settings.STAGE_WIDTH + offset);
		uiTopRight.y = Std.int(-offset);
		
		modGoal.resize();
		modGoal.x = Std.int(offset);
		modGoal.y = Std.int(offset * 0.5);
		
		modMoves.resize();
		modMoves.x = Std.int(Settings.STAGE_WIDTH / 2);
		modMoves.y = Std.int(-offset);
	
		modScore.resize();
		modScore.y = Std.int(offset * 0.5);
		
	//	UI BOTTOM
		uiBotLeft.scaleX = uiBotLeft.scaleY = scaling;
		offset = Std.int(0.1 * uiBotLeft.width);
		uiBotLeft.x = Std.int( -offset );
		uiBotLeft.y = Std.int(Settings.STAGE_HEIGHT + offset);
		trace(uiBotLeft.y);
		
		btnPause.resize(scaling);
		btnPause.x = Std.int(offset * 0.5);
		btnPause.y = Std.int(Settings.STAGE_HEIGHT - btnPause.h - offset * 0.5);
		
		if (uiBotRight != null) {
			uiBotRight.scaleX = -scaling;
			uiBotRight.scaleY = scaling;
			uiBotRight.x = Std.int(Settings.STAGE_WIDTH + offset);
			uiBotRight.y = Std.int(Settings.STAGE_HEIGHT + offset);
			
			btnPickaxe.resize(scaling);
			btnPickaxe.x = Std.int(Settings.STAGE_WIDTH - btnPickaxe.w * 0.5 - offset * 0.5);
			btnPickaxe.y = Std.int(Settings.STAGE_HEIGHT - offset * 0.5);
			
			if (lblNumBooster != null)
				lblNumBooster.dispose();
			lblNumBooster = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_50, this);
			lblNumBooster.text = "$ " + LevelDesign.USER_DATA.pickaxe;
			lblNumBooster.filter = true;
			lblNumBooster.scaleX = lblNumBooster.scaleY = scaling / Settings.STAGE_SCALE;
			lblNumBooster.x = Std.int(btnPickaxe.x - lblNumBooster.textWidth * 0.5 * lblNumBooster.scaleX);
			lblNumBooster.y = Std.int(btnPickaxe.y - btnPickaxe.h - lblNumBooster.textHeight * lblNumBooster.scaleY - offset * 0.5);
		}
	}
	
	public function destroy() {
		bmUI.dispose();
		bmUI = null;
		
		uiTopLeft.dispose();
		uiTopLeft = null;
		uiTopRight.dispose();
		uiTopRight = null;
		uiBotLeft.dispose();
		uiBotLeft = null;
		if (uiBotRight != null)
			uiBotRight.dispose();
		uiBotRight = null;
		
	//	MODULES
		modMoves.destroy();
		modMoves = null;
		
		modScore.destroy();
		modScore = null;
	
		modGoal.destroy();
		modGoal = null;
		
		btnPause.destroy();
		btnPause = null;
		
		if (btnPickaxe != null)
			btnPickaxe.destroy();
		btnPickaxe = null;
		
		if (lblNumBooster != null)
			lblNumBooster.dispose();
		lblNumBooster = null;
	}
	
	public function update() {
		modMoves.update();
	}
}