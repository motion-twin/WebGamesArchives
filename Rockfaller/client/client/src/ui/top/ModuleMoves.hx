package ui.top ;

import h2d.Sprite;

import data.Settings;
import manager.SoundManager;

/**
 * ...
 * @author Tipyx
 */
class ModuleMoves extends Sprite
{
	public static var TIME_ANIM	= 0.3;
	
	var game				: process.Game;
	
	var actualMoves			: Int;
	
	var cLabel1				: Sprite;
	var cLabel2				: Sprite;
	var lblMoves1			: h2d.Text;
	var lblMoves2			: h2d.Text;

	var hsWarning			: mt.deepnight.slb.HSprite;
	var hsSocle				: mt.deepnight.slb.HSprite;
	var hsWheel				: mt.deepnight.slb.HSprite;
	
	public var addMovePending	: Int;
	var isAdding				: Bool;
	
	public var w			: Float;
	public var h			: Float;

	public function new() 
	{
		super();
		
		game = process.Game.ME;
		
		hsWarning = Settings.SLB_UI.h_get("uiMovesWarning");
		hsWarning.setCenterRatio(0.5, 0);
		hsWarning.filter = true;
		hsWarning.blendMode = Add;
		this.addChild(hsWarning);
		
		hsWheel = Settings.SLB_UI.h_get("uiMovesCircle");
		hsWheel.setCenterRatio(0.5, 0.5);
		hsWheel.filter = true;
		this.addChild(hsWheel);
		
		cLabel1 = new Sprite(this);
		lblMoves1 = new h2d.Text(Settings.FONT_MOUSE_DECO_50, cLabel1);
		lblMoves1.filter = true;
		lblMoves1.textColor = 0x483f38;
		lblMoves1.text = "20";
		
		cLabel2 = new Sprite(this);
		lblMoves2 = new h2d.Text(Settings.FONT_MOUSE_DECO_50, cLabel2);
		lblMoves2.filter = true;
		lblMoves2.textColor = 0x483f38;
		lblMoves2.text = "20";
		
		hsSocle = Settings.SLB_UI.h_get("uiMoves");
		hsSocle.setCenterRatio(0.5, 0);
		hsSocle.filter = true;
		this.addChild(hsSocle);
		
		addMovePending = 0;
		isAdding = false;
	}
	
	public function init() {
		cLabel2.rotation = -3.14 / 2;
		
		actualMoves = game.movesLeft.get();
		
		lblMoves1.text = Std.string(actualMoves);
		lblMoves2.text = Std.string(actualMoves - 1);
		
		checkWarning();
	}
	
	public function costMove() {
		actualMoves -= 1;
		
		game.tweener.create().to(TIME_ANIM * Settings.FPS, hsWheel.rotation += 3.14 / 2).ease(mt.motion.Ease.easeInExpo);
		
		game.tweener.create().to(TIME_ANIM * Settings.FPS, cLabel1.rotation = 3.14 / 2).ease(mt.motion.Ease.easeInExpo);
		var t = game.tweener.create();
		t.to(TIME_ANIM * Settings.FPS, cLabel2.rotation = 0).ease(mt.motion.Ease.easeInExpo);
		function onCompleteTweenCostMove() {
			cLabel1.rotation = 0;
			cLabel2.rotation = -3.14 / 2;
			lblMoves1.text = Std.string(actualMoves);
			lblMoves2.text = Std.string(actualMoves - 1);
			lblMoves1.x = Std.int(-lblMoves1.textWidth / 2);
			lblMoves2.x = Std.int(-lblMoves2.textWidth / 2);
			
			checkWarning();
		};
		t.onComplete = onCompleteTweenCostMove;
	}
	
	public function addMove() {
		actualMoves += 1;
		
		cLabel1.rotation = 3.14 / 2;
		cLabel2.rotation = 0;
		
		lblMoves1.text = Std.string(actualMoves);
		lblMoves2.text = Std.string(actualMoves - 1);
		
		game.tweener.create().to(TIME_ANIM * Settings.FPS, hsWheel.rotation -= 3.14 / 2).ease(mt.motion.Ease.easeInExpo);
		
		game.tweener.create().to(TIME_ANIM * Settings.FPS, cLabel1.rotation = 0).ease(mt.motion.Ease.easeInExpo);
		var t = game.tweener.create();
		t.to(TIME_ANIM * Settings.FPS, cLabel2.rotation = -3.14 / 2).ease(mt.motion.Ease.easeInExpo);
		function onCompleteTweenAddMove() {
			lblMoves1.x = Std.int( -lblMoves1.textWidth / 2);
			lblMoves2.x = Std.int( -lblMoves2.textWidth / 2);
			
			isAdding = false;
			
			checkWarning();
		};
		t.onComplete = onCompleteTweenAddMove;
	}
	
	public function checkWarning() {
		if (actualMoves <= 5) {
			hsWheel.set("uiMovesCircleWarning");
			lblMoves1.textColor = lblMoves2.textColor = 0xFFFFFF;
			hsWarning.visible = true;
		}
		else {
			hsWheel.set("uiMovesCircle");
			lblMoves1.textColor = lblMoves2.textColor = 0x483f38;
			hsWarning.visible = false;
		}
	}
	
	public function resize() {
	// Resize
		hsWheel.scaleX = hsWheel.scaleY = Settings.STAGE_SCALE;
		hsWarning.scaleX = hsWarning.scaleY = Settings.STAGE_SCALE;
		hsSocle.scaleX = hsSocle.scaleY = Settings.STAGE_SCALE;
		
		lblMoves1.dispose();
		lblMoves1 = new h2d.Text(Settings.FONT_MOUSE_DECO_66, cLabel1);
		lblMoves1.filter = true;
		lblMoves1.textColor = 0x483f38;
		lblMoves1.text = Std.string(actualMoves);
		
		lblMoves2.dispose();
		lblMoves2 = new h2d.Text(Settings.FONT_MOUSE_DECO_66, cLabel2);
		lblMoves2.filter = true;
		lblMoves2.textColor = 0x483f38;
		lblMoves2.text = Std.string(actualMoves - 1);
		
	// Replace
		w = hsSocle.width;
		h = hsSocle.height;
		
		lblMoves1.x = Std.int(-lblMoves1.textWidth / 2);
		lblMoves2.x = Std.int(-lblMoves2.textWidth / 2);
		
		lblMoves1.y = lblMoves2.y = Std.int(hsWheel.height * 0.20);
		
		cLabel1.y = cLabel2.y = hsWheel.y = Std.int(hsSocle.height * 0.15);
		
		checkWarning();
	}
	
	public function destroy() {
		hsSocle.dispose();
		hsSocle = null;
		
		hsWarning.dispose();
		hsWarning = null;
		
		hsWheel.dispose();
		hsWheel = null;
		
		lblMoves1.dispose();
		lblMoves1 = null;
		
		lblMoves2.dispose();
		lblMoves2 = null;
	}
	
	public function update() {
		if (!isAdding && addMovePending > 0) {
			addMovePending--;
			isAdding = true;
			addMove();
		}
		
		if (!game.isEndGame)
			hsWarning.alpha = 1 + Math.sin(game.time / 8);
			//hsWarning.alpha = 1 + Math.sin(game.time / (actualMoves * 10));
	}
}