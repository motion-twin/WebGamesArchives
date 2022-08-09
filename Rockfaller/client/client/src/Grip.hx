package ;

import h2d.Sprite;

import mt.deepnight.slb.HSprite;

import Common;

import Rock;
import process.Game;
import data.Settings;
import manager.StateManager;
import manager.SoundManager;

/**
 * ...
 * @author Tipyx
 */

class Grip extends h2d.Layers
{
	//static var TIME_ANIM		= 0.2;
	static var TIME_ANIM		= 0.75;
	//static var TIME_ANIM		= 5;
	
	public var arRockToDo	: Array<Rock>;
	
	var game		: Game;
	
	var hsGrip		: mt.deepnight.slb.HSprite;
	var hsClaw		: mt.deepnight.slb.HSprite;
	var hsChain		: mt.deepnight.slb.HSprite;
	var arChain		: Array<mt.deepnight.slb.HSprite>;
	
	var hsRock		: mt.deepnight.slb.HSprite;
	
	var t			: mt.motion.Tween;
	
	public var arRockDeleted : Array<{cX:Int, cY:Int, type:TypeRock}>;
	
	public var isPicking 	: Bool;
	
	public function new() {
		super();
		
		arRockToDo = [];
		
		arRockDeleted = [];
		
		game = Game.ME;
		
		isPicking = false;
		
		hsGrip = Settings.SLB_TAUPI.h_get("gripAnim",0);
		hsGrip.setCenterRatio(0.5, 0);
		hsGrip.filter = true;
		this.add(hsGrip, 0);
		
		hsClaw = Settings.SLB_TAUPI.h_get("gripTopAnim");
		hsClaw.setCenterRatio(0.5, 0);
		hsClaw.filter = true;
		this.add(hsClaw, 2);
		
		
		var numFrameChain = Settings.SLB_UI.countFrames("chainTaut");
		hsChain = Settings.SLB_UI.h_get("chainTaut", Std.random(Settings.GRID_WIDTH) % numFrameChain);
		hsChain.filter = true;
		hsChain.setCenterRatio(0.5, 1);
		this.add(hsChain, 0);
		
		arChain = [];
		
		var heiChain = Settings.SLB_UI.getFrameData("chainTaut").hei * Settings.STAGE_SCALE;
		
		for (i in 0...Std.int(Settings.STAGE_WIDTH / heiChain)) {
			var hsExt = Settings.SLB_UI.h_get("chainTaut");
			hsExt.filter = true;
			hsExt.setCenterRatio(0.5, 1);
			this.add(hsExt, 0);
			arChain.push(hsExt);
		}
	}
	
	public function resize() {
	// Resize
		hsGrip.scaleX = Settings.STAGE_SCALE #if standalone * 0.65 #end;
		hsGrip.scaleY = -Settings.STAGE_SCALE #if standalone * 0.65 #end;
		
		hsClaw.scaleX = Settings.STAGE_SCALE #if standalone * 0.65 #end;
		hsClaw.scaleY = -Settings.STAGE_SCALE #if standalone * 0.65 #end;
		
		hsChain.scaleX = Settings.STAGE_SCALE #if standalone * 0.65 #end;
		hsChain.scaleY = -Settings.STAGE_SCALE #if standalone * 0.65 #end;
		
		hsChain.y = Std.int( -30 * Settings.STAGE_SCALE #if standalone * 0.65 #end);
		
		var newY = hsChain.height - 15 * Settings.STAGE_SCALE #if standalone * 0.65 #end;
		
		for (c in arChain) {
			c.scaleX = Settings.STAGE_SCALE #if standalone * 0.65 #end;
			c.scaleY = -Settings.STAGE_SCALE #if standalone * 0.65 #end;
			c.y = Std.int(hsChain.y + newY);
			newY += c.height;
		}
		
	// Replace
		this.x = Std.int(Settings.STAGE_WIDTH * 0.5);
		this.y = Std.int(Settings.STAGE_HEIGHT + 50 * Settings.STAGE_SCALE);
	}
	
	public function pick() {
		isPicking = true;
		var r = arRockToDo.shift();
		
		if (r == null || r.isDestroy) {
			throw "rock to grip is null";
		}
		
		SoundManager.LOOT_SFX();
		
		var tr = r.type;
		var id = r.ram.typeID;
		
		if (game.sm.arQueueState[0] != State.SGrip)
			game.sm.arQueueState.unshift(State.SGrip);
		
		var mid = Std.int(Settings.GRID_WIDTH * 0.5);
		var ratio = (r.cX - mid) / (mid * 2);
		
		this.rotation = 3.14 / 2 + Math.atan2(	Std.int(game.cRocks.y + Rock.GET_POS(r.cY + 1)) - this.y,
												Std.int(game.cRocks.x + Rock.GET_POS(r.cX - ratio)) - this.x);
		
		t = game.tweener.create().to(TIME_ANIM * Settings.FPS,	this.x = Std.int(game.cRocks.x + Rock.GET_POS(r.cX - ratio)),
																this.y = Std.int(game.cRocks.y + Rock.GET_POS(r.cY + 1)));
		t.ease(mt.motion.Ease.easeInCubic);
		function onCompleteTweenToTaupi() {
			game.showLoot(id);
			FX.GRIP_SSB(this.x).rotation = this.rotation;
			switch (tr) {
				case TypeRock.TRLoot(id) :
					game.arLoots.push( { id:id, num:1 } );
				default :
					throw tr + "Is not Lootable";
			}
			
			hsRock.dispose();
			hsRock = null;
			
			isPicking = false;
			
			hsGrip.set("gripAnim", 0);
			hsClaw.set("gripTopAnim");
			var numFrameChain = Settings.SLB_UI.countFrames("chainLoose");
			hsChain.set("chainLoose", Std.random(Settings.GRID_WIDTH) % numFrameChain);
			
			this.rotation = 0;
			
			if (arRockToDo.length > 0)
				pick();
			else {
				game.sm.arQueueState.shift();
				manager.SpecialManager.END_SOLVER(arRockDeleted);
			}
		}
		function onCompleteTweenToLoot() {
			hsGrip.a.play("gripAnim");
			hsClaw.a.play("gripTopAnim");
			hsChain.a.play("chainAnim");
			hsGrip.a.onEnd(function () {
				hsRock = r.ram.slb.h_get(id);
				hsRock.filter = true;
				hsRock.setCenterRatio(0.5, 0.5);
				hsRock.scaleX = hsRock.scaleY = Settings.STAGE_SCALE;
				hsRock.y = hsGrip.y - Rock.SIZE_OFFSET;
				hsRock.rotation = - this.rotation;
				this.add(hsRock, 1);
				
				r.destroy(false, false, true);
				
				t = game.tweener.create().to(TIME_ANIM * Settings.FPS,	this.x = Std.int(Settings.STAGE_WIDTH * 0.5),
																		this.y = Std.int(Settings.STAGE_HEIGHT + 50 * Settings.STAGE_SCALE));
				t.ease(mt.motion.Ease.easeInCubic);
				t.onComplete = onCompleteTweenToTaupi;			
			});
		}
		t.onComplete = onCompleteTweenToLoot;
	}
	
	public function destroy() {
		hsGrip.dispose();
		hsGrip = null;
		
		hsClaw.dispose();
		hsClaw = null;
		
		hsChain.dispose();
		hsChain = null;
		
		if (hsRock != null) {
			hsRock.dispose();
			hsRock = null;
		}
		
		if (t != null) {
			t.dispose();
			t = null;			
		}
	}
	
	public function update() {
		//if (arRockToDo.length > 0 && !isPicking) {
			//pick(arRockToDo.shift());
		//}
	}
}
