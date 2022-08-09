package ;

import mt.motion.FlumpTP;

import data.Settings;
import manager.SoundManager;

/**
 * ...
 * @author Tipyx
 */

enum StateTaupi {
	STIdle;
	STTransition;
	STEnd;
}
 
class Taupi extends h2d.Sprite
{
	public static var ANIM_END_TIME	= 2;
	public static var OFFSET_GRIP	: Float;
	
	var game				: process.Game;
	
	var cTaupi				: h2d.Sprite;
	var fe					: mt.motion.FlumpTP.FlumpElement;
	
	var fxTaupiLight		: mt.deepnight.slb.HSprite;
	var fxWidTaupiLight		: Int;
	
	var w					: Float;
	var h					: Float;
	
	public var animAfterTransition	: Void->Void;
	public var animAfterEnd			: Void->Void;
	
	var state				: StateTaupi;
	var tp					: mt.deepnight.deprecated.TinyProcess;
	
	public function new() {
		super();
		
		game = process.Game.ME;
		
		state = StateTaupi.STIdle;
		
		fxTaupiLight = Settings.SLB_NOTRIM.h_get("taupiLight");
		fxTaupiLight.filter = true;
		fxTaupiLight.setCenterRatio(0.5, 1);
		fxTaupiLight.blendMode = h2d.BlendMode.SoftOverlay;
		this.addChild(fxTaupiLight);
		
		cTaupi = new h2d.Sprite(this);
		fe = FlumpTP.GET("taupi", "taupinotronIdle", false);
		fe.launchAnim();
		cTaupi.addChild(fe.s);
		
		resize();
		
		update();
	}
	
	public function resize() {
		OFFSET_GRIP = 50 * Settings.STAGE_SCALE;
		
		switch (state) {
			case StateTaupi.STIdle :
				w = 1370 * Settings.STAGE_SCALE #if standalone * 0.65 #end;
				h = 900 * Settings.STAGE_SCALE #if standalone * 0.65 #end;
			case StateTaupi.STEnd :
				w = 1120 * Settings.STAGE_SCALE #if standalone * 0.65 #end;
				h = 1000 * Settings.STAGE_SCALE #if standalone * 0.65 #end;
			case StateTaupi.STTransition :
				w = 1370 * Settings.STAGE_SCALE #if standalone * 0.65 #end;
				h = 900 * Settings.STAGE_SCALE #if standalone * 0.65 #end;
		}
		
		fe.s.scaleX = Settings.STAGE_SCALE #if standalone * 0.65 #end;
		fe.s.scaleY = -Settings.STAGE_SCALE #if standalone * 0.65 #end;
		
		fxTaupiLight.scaleX = Settings.STAGE_SCALE * 1.25;
		fxTaupiLight.scaleY = Settings.STAGE_SCALE * 2;
		fxTaupiLight.y = -h * 0.7;
		
		fxTaupiLight.x = Std.int(Settings.STAGE_WIDTH * 0.5);
		cTaupi.x = Std.int((Settings.STAGE_WIDTH - w) * 0.5);
		this.y = Std.int(game.cRocks.y + game.gridHeight + OFFSET_GRIP + h);
	}
		
	public function animEnd(success:Bool) {
		state = StateTaupi.STTransition;
		
		fe.destroy();
		fe = FlumpTP.GET("taupi", "taupinotronTransition", false);
		fe.launchAnim();
		
		cTaupi.addChild(fe.s);
		
		resize();
		
		game.delayer.addFrameBased(function () {
			animAfterTransition();
			
			tp = game.createTinyProcess();
			tp.onUpdate = function () {
				Main.MAIN_SCENE.x = Std.int(Math.sin(tp.time));
			}
			tp.onDispose = function () {
				Main.MAIN_SCENE.x = 0;
			}
			
			state = StateTaupi.STEnd;
			
			fe.destroy();
			
			fe = FlumpTP.GET("taupi", "taupinotronAnim", true);
			fe.launchAnim();
			
			cTaupi.addChild(fe.s);
			
			resize();
			
			fxTaupiLight.visible = false;
			
			var t = game.tweener.create();
			if (!success) {
				SoundManager.TAUPI_GO_DOWN_SFX();
				t.to((ANIM_END_TIME * Settings.FPS), this.y += Settings.STAGE_HEIGHT);
			}
			else {
				SoundManager.TAUPI_GO_UP_SFX();
				t.to((ANIM_END_TIME * Settings.FPS), this.y -= Settings.STAGE_HEIGHT + this.h);
			}
			t.onComplete = animEndTaupi;
		}, fe.duration);
	}
	
	function animEndTaupi() {
		animAfterEnd();
		tp.destroy();
	};
	
	public function destroy() {
		fe.destroy();
		fe = null;
		
		fxTaupiLight.dispose();
		fxTaupiLight = null;
		
		cTaupi.dispose();
		cTaupi = null;
	}
	
	public function update() {
		if (state == StateTaupi.STIdle
		&&	!game.cd.hasSet("taupiIdle", fe.duration + Std.random(2 * 60 * Settings.FPS))) {
			SoundManager.TAUPI_MOVE_SFX();
			fe.launchAnim();
		}
			
		//#if !mobile
			fe.update();
		//#end
	}
}