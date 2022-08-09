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
	
	var oldScore			: Float;
	
	var lblScore			: h2d.Text;
	var lblNumScore			: h2d.Text;
	
	var w					: Float;
	var offsetX				: Int;
	var offsetY				: Int;
	
	public function new() {
		super();
		
		offsetX = Std.int(15 * Settings.STAGE_SCALE);
		offsetY = Std.int(20 * Settings.STAGE_SCALE);
		
		game = process.Game.ME;
		
		oldScore = game.score.get();
		
		lblScore = new h2d.Text(Settings.FONT_MOUSE_DECO_66, this);
		lblScore.textColor = 0xe59537;
		lblScore.text = "SCORE";
		
		lblNumScore = new h2d.Text(Settings.FONT_MOUSE_DECO_100/*, this*/);
		lblNumScore.letterSpacing = Std.int( -5 * Settings.STAGE_SCALE);
		lblNumScore.textColor = 0xFFEFB4;
	}
	
	public function updateScore() {
		lblScore.x = Std.int(Settings.STAGE_WIDTH - lblScore.textWidth - offsetX);
		
		lblNumScore.y = Std.int(lblScore.y + lblScore.textHeight + offsetY);
		
		function onUpdate(e) {
			lblNumScore.text = Std.string(Std.int(oldScore));
			lblNumScore.x = Std.int(Settings.STAGE_WIDTH - lblNumScore.textWidth - offsetX);			
		}
		game.tweener.create().to(0.2 * Settings.FPS, oldScore = game.score.get()).onUpdate = onUpdate;
	}
	
	public function resize() {
		offsetX = Std.int(15 * Settings.STAGE_SCALE);
		offsetY = Std.int(20 * Settings.STAGE_SCALE);
		
	// Resize
		lblScore.dispose();
		lblScore = new h2d.Text(Settings.FONT_MOUSE_DECO_66, this);
		lblScore.textColor = 0xe59537;
		lblScore.text = "SCORE";
	
		lblNumScore.dispose();
		lblNumScore = new h2d.Text(Settings.FONT_MOUSE_DECO_100, this);
		lblNumScore.letterSpacing = Std.int( -5 * Settings.STAGE_SCALE);
		lblNumScore.textColor = 0xFFEFB4;
		
	// Replace
		updateScore();
	}
	
	public function destroy () {
		lblScore.dispose();
		lblScore = null;
		
		lblNumScore.dispose();
		lblNumScore = null;
	}
}