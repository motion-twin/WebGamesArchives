package manager;

import data.DataManager;
import data.LevelDesign;
import data.Settings;
import process.Game;

import Common;
import Protocol;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */

typedef StepTuto = {
	var level		: Int;
	var step		: Int;
	var left		: Bool;
	var done		: Bool;
	var button		: Bool;
}
 
class TutoManager
{
	public static var AR_TUTO			: Array<StepTuto> 	= [];
	public static var ACTUAL_TUTO		: StepTuto			= null;
	
	static var TIME_ANIM				: Float				= 0.5;
	//static var TIME_ANIM				: Float				= 1;
	
	static var hsBubble					: mt.deepnight.slb.HSprite;
	static var text						: h2d.Text;
	static var hsOtto					: mt.deepnight.slb.HSprite;
	static var btn						: ui.Button;
	static var hsArrow					: mt.deepnight.slb.HSprite;
	
	static var t						: mt.motion.Tween;
	static var tp						: mt.deepnight.deprecated.TinyProcess;
	static var tpHLPack					: mt.deepnight.deprecated.TinyProcess;
	
	static var lootFocus				: Rock				= null;
	
	static var isTweening				: Bool				= false;
	
	public static var coordFocus		: { x:Int, y:Int, pack:Array<Rock> }	= null;
	
	public static var countMoves		: Int				= 0;

	public static function INIT() {
		var step = 1;
		
		// LEVEL 1
		step = 1;
		AR_TUTO.push( { level:1, step:step++, left:false, done:false, button:true } );
		AR_TUTO.push( { level:1, step:step++, left:true, done:false, button:false } );
		AR_TUTO.push( { level:1, step:step++, left:false, done:false, button:false } );
		AR_TUTO.push( { level:1, step:step++, left:true, done:false, button:false } );
		AR_TUTO.push( { level:1, step:step++, left:false, done:false, button:true } );
		// LEVEL 2
		step = 1;
		AR_TUTO.push( { level:2, step:step++, left:false, done:false, button:false } );
		AR_TUTO.push( { level:2, step:step++, left:true, done:false, button:false } );
		// LEVEL 3
		step = 1;
		AR_TUTO.push( { level:3, step:step++, left:true, done:false, button:false } );
		AR_TUTO.push( { level:3, step:step++, left:true, done:false, button:false } );
		// LEVEL 4
		step = 1;
		AR_TUTO.push( { level:4, step:step++, left:false, done:false, button:true } );
		AR_TUTO.push( { level:4, step:step++, left:true, done:false, button:true } );
		// LEVEL 5
		step = 1;
		AR_TUTO.push( { level:5, step:step++, left:false, done:false, button:true } );
		AR_TUTO.push( { level:5, step:step++, left:true, done:false, button:false } );
		// LEVEL 6
		step = 1;
		AR_TUTO.push( { level:6, step:step++, left:false, done:false, button:true } );
		AR_TUTO.push( { level:6, step:step++, left:false, done:false, button:true } );
		// LEVEL 7
		step = 1;
		AR_TUTO.push( { level:7, step:step++, left:false, done:false, button:true } );
		AR_TUTO.push( { level:7, step:step++, left:true, done:false, button:false } );
		// LEVEL 8
		step = 1;
		AR_TUTO.push( { level:8, step:step++, left:true, done:false, button:true } );
		// LEVEL 10
		step = 1;
		AR_TUTO.push( { level:10, step:step++, left:true, done:false, button:false } );
		AR_TUTO.push( { level:10, step:step++, left:false, done:false, button:false } );
		// LEVEL 12
		step = 1;
		AR_TUTO.push( { level:12, step:step++, left:false, done:false, button:false } );
		AR_TUTO.push( { level:12, step:step++, left:true, done:false, button:false } );
		// LEVEL 13
		step = 1;
		AR_TUTO.push( { level:13, step:step++, left:false, done:false, button:false } );
		// LEVEL 16
		step = 1;
		AR_TUTO.push( { level:16, step:step++, left:true, done:false, button:false } );
		// LEVEL 36
		step = 1;
		AR_TUTO.push( { level:36, step:step++, left:false, done:false, button:true } );
		// LEVEL 56
		step = 1;
		AR_TUTO.push( { level:56, step:step++, left:false, done:false, button:true } );
		// LEVEL 76
		step = 1;
		AR_TUTO.push( { level:76, step:step++, left:false, done:false, button:true } );
		AR_TUTO.push( { level:76, step:step++, left:true, done:false, button:true } );
		// LEVEL 96
		step = 1;
		AR_TUTO.push( { level:96, step:step++, left:false, done:false, button:true } );
		// LEVEL 121
		step = 1;
		AR_TUTO.push( { level:121, step:step++, left:false, done:false, button:false } );
		// Level -2 : Life (See Mail.hx)
	}
	
	public static function INIT_GAME() {
		hsBubble = Settings.SLB_UI2.h_get("tutoBubble");
		hsBubble.setCenterRatio(1, 0);
		hsBubble.filter = true;
		hsBubble.scaleX = -Settings.STAGE_SCALE * 2;
		hsBubble.scaleY = Settings.STAGE_SCALE * 2;
		
		hsOtto = Settings.SLB_NOTRIM.h_get("tutoPnj");
		hsOtto.setCenterRatio(0, 1);
		hsOtto.filter = true;
		hsOtto.scaleX = -Settings.STAGE_SCALE;
		hsOtto.scaleY = Settings.STAGE_SCALE;
		hsOtto.x = Settings.STAGE_WIDTH;
		hsOtto.y = Settings.STAGE_HEIGHT;
		
		btn = new ui.Button("uiBtOk", "", ALLOWED_CLICK);
		
		hsArrow = Settings.SLB_UI2.h_get("arrow");
		hsArrow.alpha = 0;
		Game.ME.root.add(hsArrow, Settings.DM_FX_UI);
	}
	
	public static function DESTROY_GAME() {
		if (t != null && !t.disposed)
			t.dispose();
			
		t = null;
		
		if (tp != null)
			tp.destroy();
		
		hsBubble.dispose();
		hsBubble = null;
		
		hsOtto.dispose();
		hsOtto = null;
		
		hsArrow.dispose();
		hsArrow = null;
		
		btn.destroy();
		btn = null;
		
		coordFocus = null;
		
		hideHighlight(true);
		
		if (text != null)
			text.dispose();
			text = null;
			
		ACTUAL_TUTO = null;
	}
	
	public static function GET(level:Int, step:Int):StepTuto {
		for (t in AR_TUTO)
			if (t.level == level && t.step == step)
				return t;
				
		return null;
	}
	
	public static function SHOW_POPUP(level:Int, step:Int, onEndAnim:Void->Void = null) {
		if (ACTUAL_TUTO == GET(level, step))
			return;
		
		ACTUAL_TUTO = GET(level, step);
		
		if (ACTUAL_TUTO == null)
			throw "NO TUTO FOR LEVEL : " + level;
		
		if (t != null && !t.disposed)
			t.dispose();
			
		mt.device.EventTracker.tutorialPresented("level : " + level + " - " + " step : " + step);
		
		hsBubble.scaleX = -Settings.STAGE_SCALE * 2;
		hsBubble.scaleY = Settings.STAGE_SCALE * 2;
		if (lootFocus != null && level == 6) {
			if (lootFocus.cY < 3)
				hsBubble.y = (lootFocus.cY + 4) * Rock.SIZE_OFFSET;
		}
		else if (level == 3)
			hsBubble.y = 1 * Rock.SIZE_OFFSET;
		else if (level == 4)
			hsBubble.y = 4 * Rock.SIZE_OFFSET;
		else if (level == 5 && step == 2)
			hsBubble.y = 2 * Rock.SIZE_OFFSET;
		else if (level == 7)
			hsBubble.y = 3 * Rock.SIZE_OFFSET;
		else if (level == 10)
			hsBubble.y = 6 * Rock.SIZE_OFFSET;
		Game.ME.root.add(hsBubble, Settings.DM_FX_UI);
		
		if (text != null)
			text.dispose();
		text = new h2d.Text(Settings.FONT_BENCH_NINE_50);
		text.textAlign = h2d.Text.Align.Center;
		text.text = Lang.GET_TUTO(level, step);
		//text.text = mt.Utf8.uppercase( text.text );
		text.filter = true;
		text.textColor = 0x431F03;
		//text.lineSpacing = Std.int(-10 * Settings.STAGE_SCALE);
		text.maxWidth = Std.int(hsBubble.width * 0.75);
		text.x = Std.int(hsBubble.x + hsBubble.width * 0.5 - text.textWidth * 0.5);
		text.y = Std.int(hsBubble.y + hsBubble.height * 0.5 - text.textHeight * 0.5);
		Game.ME.root.add(text, Settings.DM_FX_UI);
		
		btn.resize();
		btn.visible = ACTUAL_TUTO.button;
		btn.y = hsBubble.y + hsBubble.height * 0.7;
		Game.ME.root.add(btn, Settings.DM_FX_UI);
		
		hsOtto.scaleX = Settings.STAGE_SCALE;
		hsOtto.scaleY = Settings.STAGE_SCALE;
		hsOtto.x = Settings.STAGE_WIDTH;
		hsOtto.y = Settings.STAGE_HEIGHT;
		Game.ME.root.add(hsOtto, Settings.DM_FX_UI);
		
		isTweening = true;
		
		if (ACTUAL_TUTO.left) {
			hsBubble.x = -Std.int(hsBubble.width);
			text.x = Std.int(hsBubble.x + hsBubble.width * 0.12);
			btn.x = Std.int(hsBubble.x + hsBubble.width * 0.75);
			hsOtto.set("storyPnj");
			hsOtto.x = Std.int(Settings.STAGE_WIDTH);
			t = Game.ME.tweener.create().to(TIME_ANIM * Settings.FPS, hsBubble.x = 0, hsOtto.x = Settings.STAGE_WIDTH - hsOtto.width);
			t.ease(mt.motion.Ease.easeOutBack);
			function onUpdateLeft(e) {
				text.x = Std.int(hsBubble.x + hsBubble.width * 0.12);
				btn.x = Std.int(hsBubble.x + hsBubble.width * 0.75);				
			}
			function onCompleteLeft() {
				isTweening = false;
				SHOW_ARROW();
				if (onEndAnim != null)
					onEndAnim();
			}
			t.onUpdate = onUpdateLeft;
			t.onComplete = onCompleteLeft;
		}
		else {
			hsBubble.scaleX = Settings.STAGE_SCALE * 2;
			hsBubble.x = Settings.STAGE_WIDTH + hsBubble.width;
			text.x = Std.int(hsBubble.x - hsBubble.width * 0.88);
			btn.x = Std.int(hsBubble.x - hsBubble.width * 0.90);
			hsOtto.set("tutoPnj");
			hsOtto.x = Std.int(- hsOtto.width);
			t = Game.ME.tweener.create().to(TIME_ANIM * Settings.FPS, hsBubble.x = Settings.STAGE_WIDTH, hsOtto.x = 0);
			t.ease(mt.motion.Ease.easeOutBack);
			function onUpdateRight(e) {
				text.x = Std.int(hsBubble.x - hsBubble.width * 0.88);
				btn.x = Std.int(hsBubble.x - hsBubble.width * 0.90);				
			}
			function onCompleteRight() {
				isTweening = false;
				SHOW_ARROW();
				if (onEndAnim != null)
					onEndAnim();
			}
			t.onUpdate = onUpdateRight;
			t.onComplete = onCompleteRight;
		}
	}
	
	public static function HIDE_POPUP(cb:Void->Void = null) {
		var time = 0.5;
		
		if (t != null && !t.disposed)
			t.dispose();
		
		var at = ACTUAL_TUTO;
		at.done = true;
		
		HIDE_ARROW();
		
		isTweening = true;
		
		if (ACTUAL_TUTO != null) {
			mt.device.EventTracker.tutorialCompleted("level : " + at.level + " - " + " step : " + at.step);
			
			if (at.left) {
				t = Game.ME.tweener.create().to(time * Settings.FPS, hsBubble.x = -Std.int(hsBubble.width), hsOtto.x = Std.int(Settings.STAGE_WIDTH));
				t.ease(mt.motion.Ease.easeOutBack);
				function onUpdateLeft(e) {
					text.x = Std.int(hsBubble.x + hsBubble.width * 0.12);
					btn.x = Std.int(hsBubble.x + hsBubble.width * 0.75);					
				}
				function onCompleteLeft() {
					Game.ME.root.removeChild(hsBubble);
					if (text != null)
						text.dispose();
					Game.ME.root.removeChild(hsOtto);
					Game.ME.root.removeChild(btn);
					ACTUAL_TUTO = null;
					isTweening = false;
					if (cb != null)
						cb();
				}
				t.onUpdate = onUpdateLeft;
				t.onComplete = onCompleteLeft;
			}
			else {
				t = Game.ME.tweener.create().to(time * Settings.FPS, hsBubble.x = Settings.STAGE_WIDTH + hsBubble.width, hsOtto.x = Std.int(-hsOtto.width));
				t.ease(mt.motion.Ease.easeOutBack);
				function onUpdateRight(e) {
					text.x = Std.int(hsBubble.x - hsBubble.width * 0.88);
					btn.x = Std.int(hsBubble.x - hsBubble.width * 0.90);					
				}
				function onCompleteRight() {
					Game.ME.root.removeChild(hsBubble);
					if (text != null)
						text.dispose();
					Game.ME.root.removeChild(hsOtto);
					Game.ME.root.removeChild(btn);
					ACTUAL_TUTO = null;
					isTweening = false;
					if (cb != null)
						cb();					
				}
				t.onUpdate = onUpdateRight;
				t.onComplete = onCompleteRight;
			}
		}
	}
	
	static function SHOW_ARROW() {
		var game = Game.ME;
		
		if (tp != null)
			tp.destroy();
		tp = game.createTinyProcess();
		tp.onUpdate = function () {
			if (hsArrow == null)
				tp.destroy();
			else
				hsArrow.setCenterRatio(1.5 + 0.25 * Math.sin(game.time / 10), 0.5);
		}
		
		hsArrow.scaleX = hsArrow.scaleY = Settings.STAGE_SCALE;
		
		if (ACTUAL_TUTO.level == 1) {
			//if (ACTUAL_TUTO.step == 2) {
				//hsArrow.rotation = - 3.14 / 4 - 3.14 / 2;
				//hsArrow.x = game.cRocks.x + Rock.GET_POS(coordFocus.x + 0.5);
				//hsArrow.y = game.cRocks.y + Rock.GET_POS(coordFocus.y + 0.5);
				//game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
			//}
			//else if (ACTUAL_TUTO.step == 3) {
				//hsArrow.rotation = - 3.14 / 4;
				//hsArrow.x = game.cRocks.x + Rock.GET_POS(coordFocus.x + 0.5);
				//hsArrow.y = game.cRocks.y + Rock.GET_POS(coordFocus.y + 0.5);
				//game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
			//}
			//else if (ACTUAL_TUTO.step == 4) {
				//hsArrow.rotation = - 3.14 / 4;
				//hsArrow.x = game.cRocks.x + Rock.GET_POS(coordFocus.x + 0.5);
				//hsArrow.y = game.cRocks.y + Rock.GET_POS(coordFocus.y + 0.5);
				//game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
			//}
		}
		else if (ACTUAL_TUTO.level == 2)  {
			if (ACTUAL_TUTO.step == 1) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = - 3.14 / 4 - 3.14 / 2;
				hsArrow.x = game.cRocks.x + Rock.GET_POS(3.5);
				hsArrow.y = game.cRocks.y + Rock.GET_POS(4.5);
			}
			if (ACTUAL_TUTO.step == 2) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = - 3.14 / 4;
				hsArrow.x = game.cRocks.x + Rock.GET_POS(coordFocus.x + 0.5);
				hsArrow.y = game.cRocks.y + Rock.GET_POS(coordFocus.y + 0.5);
			}
		}
		else if (ACTUAL_TUTO.level == 3)  {
			if (ACTUAL_TUTO.step == 1) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = 3.14 / 4;
				hsArrow.x = game.cRocks.x + Rock.GET_POS(coordFocus.x + 0.5);
				hsArrow.y = game.cRocks.y + Rock.GET_POS(coordFocus.y + 0.5);				
			}
			else if (ACTUAL_TUTO.step == 2) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = 3.14 / 4;
				hsArrow.x = game.cRocks.x + Rock.GET_POS(coordFocus.x + 0.5);
				hsArrow.y = game.cRocks.y + Rock.GET_POS(coordFocus.y + 0.5);	
			}
		}
		else if (ACTUAL_TUTO.level == 4)  {
			if (ACTUAL_TUTO.step == 1) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = - 3.14 / 4 - 3.14 / 2;
				hsArrow.x = Settings.STAGE_WIDTH * 0.15;
				hsArrow.y = game.uiTop.offset * 5;		
			}
			else if (ACTUAL_TUTO.step == 2) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = - 3.14 / 4 - 3.14 / 2;
				hsArrow.x = Settings.STAGE_WIDTH * 0.5;
				hsArrow.y = game.uiTop.offset * 5;		
			}
		}
		else if (ACTUAL_TUTO.level == 5)  {
			if (ACTUAL_TUTO.step == 1) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = - 3.14 + 3.14 / 4;
				hsArrow.x = game.uiTop.modGoal.getPos(0).x;
				hsArrow.y = game.uiTop.modGoal.getPos(0).y;
			}
			else if (ACTUAL_TUTO.step == 2) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = - 3.14 / 4;
				hsArrow.x = game.cRocks.x + Rock.GET_POS(coordFocus.x + 0.5);
				hsArrow.y = game.cRocks.y + Rock.GET_POS(coordFocus.y + 0.5);
			}
		}
		else if (ACTUAL_TUTO.level == 6)  {
			if (lootFocus != null && ACTUAL_TUTO.step == 1) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = 3.14 / 4 + 3.14 / 2;
				hsArrow.x = game.cRocks.x + Rock.GET_POS(lootFocus.cX);
				hsArrow.y = game.cRocks.y + Rock.GET_POS(lootFocus.cY);				
			}
		}
		else if (ACTUAL_TUTO.level == 7)  {
			if (ACTUAL_TUTO.step == 1) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = 3.14 + 3.14 / 4;
				hsArrow.x = game.uiTop.modGoal.getPos(0).x;
				hsArrow.y = game.uiTop.modGoal.getPos(0).y;
			}
			else if (ACTUAL_TUTO.step == 2) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = 3.14 / 4 + 3.14 / 2;
				hsArrow.x = game.cRocks.x + Rock.GET_POS(coordFocus.x + 0.5);
				hsArrow.y = game.cRocks.y + Rock.GET_POS(coordFocus.y + 0.5);	
			}
		}
		else if (ACTUAL_TUTO.level == 8)  {
			game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
			hsArrow.rotation = 3.14 + 3.14 / 4;
			hsArrow.x = game.cRocks.x + Rock.GET_POS(1.5);
			hsArrow.y = game.cRocks.y + Rock.GET_POS(4.5);
		}
		else if (ACTUAL_TUTO.level == 12)  {
			if (ACTUAL_TUTO.step == 1 || ACTUAL_TUTO.step == 3) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = 3.14 / 4;
				var pickaxebtn = game.uiTop.btnPickaxe;
				var p = game.root.localToGlobal(new h2d.col.Point(pickaxebtn.x, pickaxebtn.y - pickaxebtn.h * 0.75));
				hsArrow.x = p.x;
				hsArrow.y = p.y;
			}
			else if (ACTUAL_TUTO.step == 2) {
				game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
				hsArrow.rotation = - 3.14 / 4 - 3.14 / 2;
				hsArrow.x = game.cRocks.x + Rock.GET_POS(4.5);
				hsArrow.y = game.cRocks.y + Rock.GET_POS(5.5);
			}
		}
		else if (ACTUAL_TUTO.level == 16)  {
			game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
			hsArrow.rotation = 3.14 / 4;
			var pickaxebtn = game.uiTop.btnPickaxe;
			var p = game.root.localToGlobal(new h2d.col.Point(pickaxebtn.x, pickaxebtn.y - pickaxebtn.h * 0.75));
			hsArrow.x = p.x;
			hsArrow.y = p.y;
		}
		else if (ACTUAL_TUTO.level == 16)  {
			game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
			hsArrow.rotation = - 3.14 / 4 - 3.14 / 2;
			hsArrow.x = game.cRocks.x + Rock.GET_POS(2.5);
			hsArrow.y = game.cRocks.y + Rock.GET_POS(2.5);
		}
		else if (ACTUAL_TUTO.level == 56)  {
			game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
			hsArrow.rotation = - 3.14 / 4 - 3.14 / 2;
			hsArrow.x = game.cRocks.x + Rock.GET_POS(4);
			hsArrow.y = game.cRocks.y + Rock.GET_POS(4);
		}
		else if (ACTUAL_TUTO.level == 76)  {
			game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
			hsArrow.rotation = - 3.14 / 4 - 3.14 / 2;
			hsArrow.x = game.cRocks.x + Rock.GET_POS(4);
			hsArrow.y = game.cRocks.y + Rock.GET_POS(4.5);
		}
		else if (ACTUAL_TUTO.level == 121)  {
			game.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 1);
			hsArrow.rotation = - 3.14 / 4 - 3.14 / 2;
			hsArrow.x = game.cRocks.x + Rock.GET_POS(4.5);
			hsArrow.y = game.cRocks.y + Rock.GET_POS(3.5);
		}
	}
	
	static function HIDE_ARROW() {
		if (tp != null)
			tp.destroy();
		Game.ME.tweener.create().to(0.2 * Settings.FPS, hsArrow.alpha = 0);
	}
	
	public static function ALLOWED_ROLLOVER():Bool {
		if (ACTUAL_TUTO == null)
			return true;
		
		return false;
	}
	
	public static function ALLOWED_CLICK():Bool {
		if (ACTUAL_TUTO == null)
			return true;
		
		if (isTweening)
			return false;
			
		function check(cX:Int, cY:Int):Bool {
			var checkCX = Std.int(Std.int(Game.ME.cRocks.mouseX) / Rock.SIZE_OFFSET);
			var checkCY = Std.int(Std.int(Game.ME.cRocks.mouseY) / Rock.SIZE_OFFSET);
			return (checkCX >= cX && checkCX <= cX + 1 && checkCY >= cY && checkCY <= cY + 1);
		}
		
	// LEVEL 1
		if (ACTUAL_TUTO.level == 1) {
			if (ACTUAL_TUTO.step == 1) {
				HIDE_POPUP(function () {
					while (!Rock.checkHintIsDone)
						Rock.CHECK_HINT();
						
					coordFocus = Rock.arHint[Std.random(Rock.arHint.length)];
				
					GET(1, 2).left = coordFocus.x < Std.int(Settings.GRID_WIDTH / 2) ? true : false;
					
					TutoManager.SHOW_POPUP(1, 2, function() {
						Rock.SET_ROLLOVER(coordFocus.x, coordFocus.y, false);
						showHighlight();
						showHLPack();
					} );
				});
				
				return false;
			}
			else if (ACTUAL_TUTO.step == 2) {
				if (check(coordFocus.x, coordFocus.y)) {
					hideHLPack();
					hideHighlight();
					HIDE_POPUP();
					return true;
				}
			}
			else if (ACTUAL_TUTO.step == 3) {
				if (check(coordFocus.x, coordFocus.y)) {
					hideHLPack();
					hideHighlight();
					HIDE_POPUP();
					return true;
				}
			}
			else if (ACTUAL_TUTO.step == 4) {
				if (check(coordFocus.x, coordFocus.y)) {
					hideHLPack();
					hideHighlight();
					HIDE_POPUP();
					return true;
				}
			}
			else if (ACTUAL_TUTO.step == 5) {
				HIDE_POPUP();
				return false;
			}
		}
	// LEVEL 2
		else if (ACTUAL_TUTO.level == 2) {
			if (ACTUAL_TUTO.step == 1) {
				if (check(3, 4)) {
					HIDE_POPUP();
					hideHighlight();
					return true;
				}
			}
			else if (ACTUAL_TUTO.step == 2) {
				if (check(4, 6)) {
					HIDE_POPUP();
					hideHighlight();
					return true;
				}
			}
		}
	// LEVEL 3
		else if (ACTUAL_TUTO.level == 3) {
			if (ACTUAL_TUTO.step == 1) {
				if (check(3, 6)) {
					HIDE_POPUP();
					hideHighlight();
					return true;					
				}
			}
			else if (ACTUAL_TUTO.step == 2) {
				if (check(3, 6)) {
					HIDE_POPUP();
					hideHighlight();
					return true;
				}
			}
		}
	// LEVEL 4
		else if (ACTUAL_TUTO.level == 4) {
			if (ACTUAL_TUTO.step == 1) {
				HIDE_POPUP();
				SHOW_POPUP(4, 2);
				return false;
			}
			else if (ACTUAL_TUTO.step == 2) {
				HIDE_POPUP();
				hideHighlight();
				DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(4));
				return false;
			}
		}
	// LEVEL 5
		else if (ACTUAL_TUTO.level == 5) {
			if (ACTUAL_TUTO.step == 1) {
				HIDE_POPUP(function () {
					while (!Rock.checkHintIsDone)
						Rock.CHECK_HINT();
						
					for (h in Rock.arHint)
						if (h.x == 3 && h.y == 5)
							coordFocus = h;
						
					TutoManager.SHOW_POPUP(5, 2, function() {
						Rock.SET_ROLLOVER(coordFocus.x, coordFocus.y);
						showHighlight();
					} );
				});
				
				
				return false;
			}
			else if (ACTUAL_TUTO.step == 2) {
				if (check(coordFocus.x, coordFocus.y)) {
					Game.ME.uiTop.modGoal.hideHL();
					HIDE_POPUP();
					hideHighlight();
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(5));					
					return true;
				}
			}
		}
	// LEVEL 6
		else if (ACTUAL_TUTO.level == 6) {
			if (ACTUAL_TUTO.step == 1) {
				HIDE_POPUP();
				return false;
			}
			else if (ACTUAL_TUTO.step == 2) {
				HIDE_POPUP();
				DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(6));
				return false;
			}
		}
	// LEVEL 7
		else if (ACTUAL_TUTO.level == 7) {
			if (ACTUAL_TUTO.step == 1) {
				HIDE_POPUP(function () {
					while (!Rock.checkHintIsDone)
						Rock.CHECK_HINT();
						
					coordFocus = null;
					for (h in Rock.arHint)
						if (h.x == 2 && h.y == 6)
							coordFocus = h;
					
					TutoManager.SHOW_POPUP(7, 2, function() {
						Rock.SET_ROLLOVER(2, 6);
						showHighlight(true);
					} );
				});
				return true;
			}
			else if (ACTUAL_TUTO.step == 2) {
				if (check(2, 6)) {
					Game.ME.uiTop.modGoal.hideHL();
					HIDE_POPUP();
					hideHighlight();
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(7));
					return true;					
				}
			}
		}
	// LEVEL 8
		else if (ACTUAL_TUTO.level == 8) {
			if (ACTUAL_TUTO.step == 1) {
				HIDE_POPUP();
				hideHighlight();
				DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(8));
				return true;					
			}
		}
	// LEVEL 10
		else if (ACTUAL_TUTO.level == 10) {
			if (ACTUAL_TUTO.step == 1) {
				if (check(2, 2)) {
					hideHLPack();
					hideHighlight();
					HIDE_POPUP(function () {
						while (!Rock.checkHintIsDone)
							Rock.CHECK_HINT();
						
						for (h in Rock.arHint)
							if (h.x == 3 && h.y == 2)
								coordFocus = h;
						
						TutoManager.SHOW_POPUP(10, 2, function() {
							Rock.SET_ROLLOVER(coordFocus.x, coordFocus.y, false);
							showHLPack();
							showHighlight();
						} );
					});
					return true;
				}
			}
			else if (ACTUAL_TUTO.step == 2) {
				if (check(3, 2)) {
					hideHLPack();
					HIDE_POPUP();
					hideHighlight();
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(10));
					return true;
				}
			}
		}
	// LEVEL 12
		else if (ACTUAL_TUTO.level == 12) {
			if (ACTUAL_TUTO.step == 1) {
				return false;
			}
			else if (ACTUAL_TUTO.step == 2) {
				if (check(4, 5) && Game.ME.uiTop.pickaxeEnable) {
					HIDE_POPUP();
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(12));
					return true;					
				}
			}
		}
	// LEVEL 13
		else if (ACTUAL_TUTO.level == 13) {
			if (ACTUAL_TUTO.step == 1) {
				HIDE_POPUP();
				Game.ME.uiTop.btnPickaxe.hideHL();
				DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(13));
				return false;
			}
		}
	// LEVEL 16
		else if (ACTUAL_TUTO.level == 16) {
			if (ACTUAL_TUTO.step == 1) {
				if (check(2, 3)) {
					HIDE_POPUP();
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(16));
					return true;
				}
			}
		}
	// LEVEL 36
		else if (ACTUAL_TUTO.level == 36) {
			if (ACTUAL_TUTO.step == 1) {
				HIDE_POPUP();
				DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(36));
				return false;
			}
		}
	// LEVEL 56
		else if (ACTUAL_TUTO.level == 56) {
			if (ACTUAL_TUTO.step == 1) {
				HIDE_POPUP();
				DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(56));
				return false;
			}
		}
	// LEVEL 76
		else if (ACTUAL_TUTO.level == 76) {
			if (ACTUAL_TUTO.step == 1) {
				HIDE_POPUP();
				return false;
			}
			else if (ACTUAL_TUTO.step == 2) {
				DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(76));
				HIDE_POPUP();
				return false;
			}
		}
	// LEVEL 96
		else if (ACTUAL_TUTO.level == 96) {
			if (ACTUAL_TUTO.step == 1) {
				HIDE_POPUP();
				DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(96));
				return false;
			}
		}
	// LEVEL 121
		else if (ACTUAL_TUTO.level == 121) {
			if (ACTUAL_TUTO.step == 1) {
				if (check(4, 3)) {
					HIDE_POPUP();
					hideHighlight();
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateTuto(121));
					return true;					
				}
			}
		}
		trace("trololo");
		return false;
	}
	
	public static function END_TURN() {
		if (Game.ME.levelInfo.level == 1 && !LevelDesign.TUTO_IS_DONE(1)) {
			if (GET(1, 2).done && !GET(1, 3).done) {
				Game.ME.deleteOldHint();
				
				while (!Rock.checkHintIsDone)
					Rock.CHECK_HINT();
					
				coordFocus = Rock.arHint[Std.random(Rock.arHint.length)];
				
				GET(1, 3).left = coordFocus.x < Std.int(Settings.GRID_WIDTH / 2) ? true : false;
				
				TutoManager.SHOW_POPUP(1, 3, function() {
					Rock.SET_ROLLOVER(coordFocus.x, coordFocus.y, false);
					showHLPack();
					showHighlight();
				} );
			}
			else if (GET(1, 3).done && !GET(1, 4).done) {
				Game.ME.deleteOldHint();
				
				while (!Rock.checkHintIsDone)
					Rock.CHECK_HINT();
					
				coordFocus = Rock.arHint[Std.random(Rock.arHint.length)];
				
				GET(1, 4).left = coordFocus.x < Std.int(Settings.GRID_WIDTH / 2) ? true : false;
				
				TutoManager.SHOW_POPUP(1, 4, function() {
					Rock.SET_ROLLOVER(coordFocus.x, coordFocus.y, false);
					showHLPack();
					showHighlight();
				} );
			}
			else if (GET(1, 4).done && !GET(1, 5).done)
				TutoManager.SHOW_POPUP(1, 5);
		}
		else if (Game.ME.levelInfo.level == 2 && !LevelDesign.TUTO_IS_DONE(2)) {
			if (GET(2, 1).done && !GET(2, 2).done) {
				Game.ME.deleteOldHint();
				
				while (!Rock.checkHintIsDone)
					Rock.CHECK_HINT();
					
				for (h in Rock.arHint)
					if (h.x == 4 && h.y == 6)
						coordFocus = h;
				
				coordFocus.pack.push(Rock.GET_AT(3, 5));
				
				TutoManager.SHOW_POPUP(2, 2, function() {
					Rock.SET_ROLLOVER(coordFocus.x, coordFocus.y);
					showHighlight();
				} );
			}
		}
		else if (Game.ME.levelInfo.level == 3 && !LevelDesign.TUTO_IS_DONE(3)) {
			if (GET(3, 1).done && !GET(3, 2).done) {
				Game.ME.deleteOldHint();
				
				while (!Rock.checkHintIsDone)
					Rock.CHECK_HINT();
					
				for (h in Rock.arHint)
					if (h.x == 3 && h.y == 6)
						coordFocus = h;
				
				coordFocus.pack.push(Rock.GET_AT(3, 8));
				
				TutoManager.SHOW_POPUP(3, 2, function() {
					Rock.SET_ROLLOVER(coordFocus.x, coordFocus.y);
					showHighlight();
				} );
			}
		}
		else if (!GET(6, 1).done && ACTUAL_TUTO == null && !LevelDesign.TUTO_IS_DONE(6)) {
			lootFocus = null;
			for (r in Rock.ALL)
				if (r != null && r.type.match(TypeRock.TRLoot))
					lootFocus = r;
			
			if (lootFocus != null) {
				GET(6, 1).left = lootFocus.cX < Std.int(Settings.GRID_WIDTH / 2) ? true : false;
				SHOW_POPUP(6, 1);
			}
		}
		else if (Game.ME.levelInfo.level == 36 && !GET(36, 1).done && !LevelDesign.TUTO_IS_DONE(36)) {
			var cX = -1;
			for (m in SpecialManager.AR_MAGMA)
				if (m.life < 4)
					cX = m.cX;
			if (cX > -1) {
				GET(36, 1).left = cX < Std.int(Settings.GRID_WIDTH / 2) ? true : false;
				SHOW_POPUP(36, 1);
			}
		}
		else if (Game.ME.levelInfo.level == 76 && GET(76, 1).done&& !GET(76, 2).done && !LevelDesign.TUTO_IS_DONE(76)) {
			SHOW_POPUP(76, 2);
		}
	}
	
	public static function RESIZE() {
		if (ACTUAL_TUTO != null) {
			hsBubble.scaleX = -Settings.STAGE_SCALE * 2;
			hsBubble.scaleY = Settings.STAGE_SCALE * 2;
			
			if (lootFocus != null && ACTUAL_TUTO.level == 6) {
				if (lootFocus.cY < 3)
					hsBubble.y = (lootFocus.cY + 4) * Rock.SIZE_OFFSET;
			}
			else if (ACTUAL_TUTO.level == 3)
				hsBubble.y = 1 * Rock.SIZE_OFFSET;
			else if (ACTUAL_TUTO.level == 4)
				hsBubble.y = 4 * Rock.SIZE_OFFSET;
			else if (ACTUAL_TUTO.level == 5 && ACTUAL_TUTO.step == 2)
				hsBubble.y = 2 * Rock.SIZE_OFFSET;
			else if (ACTUAL_TUTO.level == 7)
				hsBubble.y = 3 * Rock.SIZE_OFFSET;
			else if (ACTUAL_TUTO.level == 10)
				hsBubble.y = 6 * Rock.SIZE_OFFSET;
			
			if (Game.ME != null)
				Game.ME.root.add(hsBubble, Settings.DM_FX_UI);
			
			if (text != null)
				text.dispose();
			text = new h2d.Text(Settings.FONT_BENCH_NINE_50);
			text.textAlign = h2d.Text.Align.Center;
			var t : String = Lang.GET_TUTO(ACTUAL_TUTO.level, ACTUAL_TUTO.step);
			//text.text = mt.Utf8.uppercase( t );
			text.text = t;
			text.filter = true;
			text.textColor = 0x431F03;
			text.maxWidth = Std.int(hsBubble.width * 0.75);
			text.x = Std.int(hsBubble.x + hsBubble.width * 0.5 - text.textWidth * 0.5);
			text.y = Std.int(hsBubble.y + hsBubble.height * 0.5 - text.textHeight * 0.5);
			if (Game.ME != null)
				Game.ME.root.add(text, Settings.DM_FX_UI);
			
			SHOW_ARROW();
			
			btn.resize();
			btn.visible = ACTUAL_TUTO.button;
			btn.y = hsBubble.y + hsBubble.height * 0.7;
			if (Game.ME != null)
				Game.ME.root.add(btn, Settings.DM_FX_UI);
			
			//hsOtto.scaleX = -Settings.STAGE_SCALE;
			hsOtto.scaleX = Settings.STAGE_SCALE;
			hsOtto.scaleY = Settings.STAGE_SCALE;
			hsOtto.x = Settings.STAGE_WIDTH;
			hsOtto.y = Settings.STAGE_HEIGHT;
			if (Game.ME != null)
				Game.ME.root.add(hsOtto, Settings.DM_FX_UI);
			
			isTweening = false;
				
			if (ACTUAL_TUTO.left) {
				hsBubble.x = 0;
				text.x = Std.int(hsBubble.x + hsBubble.width * 0.12);
				btn.x = Std.int(hsBubble.x + hsBubble.width * 0.75);
				hsOtto.x = Settings.STAGE_WIDTH - hsOtto.width;
			}
			else {
				hsBubble.scaleX = Settings.STAGE_SCALE * 2;
				hsBubble.x = Settings.STAGE_WIDTH;
				text.x = Std.int(hsBubble.x -hsBubble.width * 0.88);
				btn.x = Std.int(hsBubble.x - hsBubble.width * 0.90);
				
				hsOtto.scaleX = Settings.STAGE_SCALE;
				hsOtto.x = 0;
			}
			
			if (bmpHL != null) {
				hideHighlight(true);
				showHighlight(true);
			}
		}
	}
	
	static var bmpHL		: h2d.Bitmap	= null;
	
	public static function showHighlight(instant:Bool = false) {
		var game = Game.ME;
		
		if (bmpHL != null) {
			bmpHL.tile.dispose();
			bmpHL.tile = null;
			bmpHL.dispose();
			bmpHL = null;
		}
		
		bmpHL = new h2d.Bitmap(h2d.Tile.fromColor(0xFF000000, Settings.STAGE_WIDTH, Settings.STAGE_HEIGHT));
		bmpHL.alpha = 0.75;
		game.root.add(bmpHL, Settings.DM_GRID);
		
	// CACHE
		var x = 0;
		var y = 0;
		
		var width = Rock.SIZE_OFFSET * 1.25;
		
		var bd = new openfl.display.BitmapData(Std.int(bmpHL.width), Std.int(bmpHL.height), true, 0xFFFFFFFF);
		
		function doCircle(cX:Int, cY:Int) {
			var circle = new openfl.display.Shape();
			circle.graphics.beginFill(0x000000);
			circle.graphics.drawRect(0, 0, width, width); 
			circle.graphics.endFill();
			circle.filters = [new openfl.filters.BlurFilter(16, 16)];
			
			x = Std.int(game.cRocks.x + Rock.GET_POS(cX) - width * 0.5);
			y = Std.int(game.cRocks.y + Rock.GET_POS(cY) - width * 0.5);
			bd.draw(circle, new openfl.geom.Matrix(1, 0, 0, 1, x, y));	
		}
		
		if (coordFocus != null) {
			for (i in coordFocus.x...coordFocus.x + 2) {
				for (j in coordFocus.y...coordFocus.y + 2) {
					doCircle(i, j);
				}
			}
			
			for (p in coordFocus.pack) {
				doCircle(p.cX, p.cY);
			}
		}
		
		
		var tileCache = h2d.Tile.fromFlashBitmap(bd);
		
		bd.dispose();
		bd = null;
		
		bmpHL.alphaMap = tileCache;
		
		if (!instant) {
			bmpHL.alpha = 0;
			game.tweener.create().to(0.2 * Settings.FPS, bmpHL.alpha = 0.75);			
		}
	}
	
	public static function hideHighlight(instant:Bool = false) {
		if (bmpHL != null) {
			if (instant) {
				bmpHL.tile.dispose();
				bmpHL.tile = null;
				bmpHL.dispose();
				bmpHL = null;
			}
			else {
				Game.ME.tweener.create().to(0.2 * Settings.FPS, bmpHL.alpha = 0).onComplete = function () {
					bmpHL.tile.dispose();
					bmpHL.tile = null;
					bmpHL.dispose();
					bmpHL = null;
				};			
			}			
		}
	}
	
	static var hsTurnArrow	: mt.deepnight.slb.HSprite;
	
	public static function showHLPack() {
		var actual = 0;
		var isUpscale = true;
		
		hsTurnArrow = Settings.SLB_FX.h_get("arrow");
		hsTurnArrow.setCenterRatio(0.5, 0.5);
		hsTurnArrow.scaleX = hsTurnArrow.scaleY = Settings.STAGE_SCALE;
		hsTurnArrow.x = Rock.GET_POS(coordFocus.x + 0.5);
		hsTurnArrow.y = Rock.GET_POS(coordFocus.y + 0.5);
		Game.ME.cRocks.add(hsTurnArrow, Game.DM_ROVER);
		
		tpHLPack = Game.ME.createTinyProcess();
		tpHLPack.onUpdate = function () {
			hsTurnArrow.rotation += 0.1;
		}
		
		for (p in coordFocus.pack) {
			p.ram.setIsLoot();
			p.ram.resize();
		}
	}
	
	public static function hideHLPack() {
		tpHLPack.destroy();
		tpHLPack = null;
		
		hsTurnArrow.dispose();
		hsTurnArrow = null;
	}
}