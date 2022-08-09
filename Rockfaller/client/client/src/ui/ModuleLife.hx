package ui;

import h2d.Sprite;
import h2d.Text;

import process.Levels;
import data.Settings;
import data.LevelDesign;
import manager.LifeManager;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */
class ModuleLife extends Sprite
{
	var lblLife			: Text;
	var lblNextLife		: Text;
	var lblCountdown	: Text;
	
	var hsLife			: mt.deepnight.slb.HSprite;
	var btnMoreLife		: ui.Button;
	
	var offset			: Int;
	var scaling			: Null<Float>;
	
	public function new() {
		super();
		
		offset = 0;
		scaling = Settings.STAGE_SCALE;
		
		btnMoreLife = new ui.Button("btMore", "", function () { process.ProcessManager.ME.showLife(Levels.ME); } );
		this.addChild(btnMoreLife);
		
		lblLife = new Text(Settings.FONT_MOUSE_DECO_80, this);
		lblLife.textColor = 0xFFEFB4;
		
		hsLife = Settings.SLB_UI.h_get("iconLife");
		hsLife.setCenterRatio(0.5, 0.5);
		hsLife.filter = true;
		this.addChild(hsLife);
		
		lblNextLife = new Text(Settings.FONT_MOUSE_DECO_36, this);
		lblNextLife.textColor = 0x00DCFD;
		
		lblCountdown = new Text(Settings.FONT_MOUSE_DECO_80, this);
		lblCountdown.textColor = 0x00DCFD;
		
		lblCountdown.text = "88:88";
	}
	
	public function updateLife() {
		lblLife.text = Std.string(LevelDesign.GET_LIFE());
		lblLife.scaleX = lblLife.scaleY = scaling / Settings.STAGE_SCALE;
		lblLife.letterSpacing = -Std.int(lblLife.textWidth * 0.05);
		lblLife.x = Std.int(btnMoreLife.x - offset * 5 - lblLife.textWidth * lblLife.scaleX);
		lblLife.y = Std.int(hsLife.height * 0.5 - lblLife.textHeight * 0.6 * lblLife.scaleY);
		
		if (LevelDesign.GET_LIFE() == 0)
			btnMoreLife.showHL(Levels.ME);
		else
			btnMoreLife.hideHL();
	}
	
	public function resize(offset:Int, newScaling:Null<Float>) {
		this.offset = offset;
		this.scaling = newScaling;
		
	// RESIZE
		btnMoreLife.resize(scaling);
		btnMoreLife.x = Std.int( -btnMoreLife.w - offset);
		
		hsLife.scaleX = hsLife.scaleY = scaling;
		hsLife.x = Std.int(btnMoreLife.x - offset * 2);
		hsLife.y = Std.int(btnMoreLife.height * 0.5);
		
		lblLife.dispose();
		lblLife = new Text(Settings.FONT_MOUSE_DECO_80, this);
		lblLife.filter = true;
		lblLife.text = Std.string(LevelDesign.GET_LIFE());
		
		lblNextLife.dispose();
		lblNextLife = new Text(Settings.FONT_MOUSE_DECO_36, this);
		lblNextLife.textColor = 0x00DCFD;
		lblNextLife.text = Lang.GET_VARIOUS(TypeVarious.TVNextLife);
		lblNextLife.letterSpacing = -Std.int(lblNextLife.textWidth * 0.02);
		
		lblCountdown.dispose();
		lblCountdown = new Text(Settings.FONT_MOUSE_DECO_80, this);
		lblCountdown.textColor = 0x00DCFD;
		lblCountdown.text = LifeManager.GET_STRING_TIME();
		lblCountdown.letterSpacing = -Std.int(lblCountdown.textWidth * 0.02);
		
	// REPLACE
		updateLife();
		
		update();
	}
	
	public function update() {
		lblNextLife.visible = LevelDesign.GET_LIFE() == LevelDesign.GET_MAX_LIFES() ? false : true;
		lblNextLife.scaleX = lblNextLife.scaleY = scaling / Settings.STAGE_SCALE;
		lblNextLife.x = Std.int( -lblNextLife.width * lblNextLife.scaleX - offset);
		lblNextLife.y = Std.int(hsLife.y + hsLife.height * 0.5 + offset * lblNextLife.scaleY);
		
		lblCountdown.visible = LevelDesign.GET_LIFE() == LevelDesign.GET_MAX_LIFES() ? false : true;
		lblCountdown.text = LifeManager.GET_STRING_TIME();
		lblCountdown.scaleX = lblCountdown.scaleY = scaling / Settings.STAGE_SCALE;
		lblCountdown.x = Std.int( -lblCountdown.width * lblCountdown.scaleX - offset);
		lblCountdown.y = Std.int(lblNextLife.y + lblNextLife.textHeight + offset * 0.5 * lblCountdown.scaleY);
	}
	
	public function destroy() {
		hsLife.dispose();
		hsLife = null;
		
		lblLife.dispose();
		lblLife = null;
		
		lblCountdown.dispose();
		lblLife = null;
	}
}