package ui.top ;

import mt.deepnight.slb.HSprite;

import Common;

import data.Settings;

/**
 * ...
 * @author Tipyx
 */
class ModuleScore extends h2d.Sprite
{
	var game				: process.Game;
	var levelInfo			: LevelInfo;
	
	var oldScore			: Int;
	
	var lblScore			: h2d.Text;
	var barEmpty			: mt.deepnight.slb.HSprite;
	var barFull				: mt.deepnight.slb.HSprite;
	var barStar				: mt.deepnight.slb.HSprite;
	
	var wStep				: Float;
	var arStarStep			: Array<HSprite>;
	
	var w					: Float;
	
	public function new() {
		super();
		
		game = process.Game.ME;
		levelInfo = game.levelInfo;
		
	// LABEL
		lblScore = new h2d.Text(Settings.FONT_MOUSE_DECO_32, this);
		lblScore.textColor = 0x06cfe5;
		
	// BAR
		
		barEmpty = Settings.SLB_UI.h_get("uiScoreBg");
		barEmpty.setCenterRatio(0, 0.5);
		barEmpty.filter = true;
		
		barFull = Settings.SLB_UI.h_get("uiScore");
		barFull.setCenterRatio(0, 0.5);
		barFull.scaleX = 0;
		barFull.filter = true;
		
		barStar = Settings.SLB_UI.h_get("uiScoreStar");
		barStar.setCenterRatio(0.5, 0.5);
		barStar.filter = true;
		
		arStarStep = [];
		
		this.addChild(barEmpty);
		this.addChild(barFull);
		this.addChild(barStar);
		
		for (i in 0...3) {
			var hsStar = Settings.SLB_UI.h_get("starRankOff", i);
			hsStar.setCenterRatio(0.5, 0);
			hsStar.filter = true;
			arStarStep.push(hsStar);
			this.addChild(hsStar);
		}
	}
	
	public function updateScore() {
		lblScore.text = "Score : " + Std.string(game.score);
		lblScore.textColor = 0xFFEFB4;
		
		lblScore.x = Std.int((wStep - lblScore.textWidth) / 2);
		
		var max = game.score / game.levelInfo.arStepScore[2];
		if (max > 1)
			max = 1;
		
		function onUpdate(e) {
			barStar.x = barFull.x + barFull.width;
			for (i in 0...arStarStep.length)
				if (barStar.x >= arStarStep[i].x)
					arStarStep[i].set("starRank", i);			
		}
		game.tweener.create().to(0.2 * Settings.FPS, barFull.scaleX = max * Settings.STAGE_SCALE).onUpdate = onUpdate;
	}
	
	public function resize() {
	// Resize
		wStep = Settings.SLB_UI.getFrameData("uiScore").wid * Settings.STAGE_SCALE;
		
		barEmpty.scaleX = barEmpty.scaleY = Settings.STAGE_SCALE;
		barFull.scaleY = Settings.STAGE_SCALE;
		barStar.scaleX = barStar.scaleY = Settings.STAGE_SCALE;
		
		lblScore.dispose();
		lblScore = new h2d.Text(Settings.FONT_MOUSE_DECO_32, this);
		lblScore.textColor = 0x06cfe5;
		
		for (i in 0...arStarStep.length) {
			var hs = arStarStep[i];
			hs.scaleX = hs.scaleY = Settings.STAGE_SCALE;
			hs.x = wStep * (levelInfo.arStepScore[i] / levelInfo.arStepScore[2]);
			hs.y = lblScore.textHeight;
		}
		
	// Replace
		barFull.x = 1;
		barStar.y = barFull.y = barEmpty.y = lblScore.textHeight + 20 * Settings.STAGE_SCALE;
	
		barStar.x = barFull.x + barFull.scaleX * wStep;
		
		updateScore();
	}
	
	public function destroy () {
		lblScore.dispose();
		lblScore = null;
		
		barEmpty.destroy();
		barEmpty = null;
		
		barFull.destroy();
		barFull = null;
		
		barStar.destroy();
		barStar = null;
		
		for (hs in arStarStep) {
			hs.destroy();
			hs = null;
		}
	}
}