package ;

import h2d.Sprite;

import mt.deepnight.slb.HSprite;
import mt.deepnight.slb.HSpriteBE;

import Common;

import data.Settings;

/**
 * ...
 * @author Tipyx
 //*/
class Background extends Sprite
{
	var game					: process.Game;
	
	var bm						: h2d.SpriteBatch;
	
	var arHS					: Array<HSpriteBE>;
	
	var actualBiomeID			= "a";
	var slb						: mt.deepnight.slb.BLib;

	public function new() 
	{
		super();
		
		game = process.Game.ME;
		
		switch (game.levelInfo.biome) {
			case TypeBiome.TBClassic	: 
				actualBiomeID = "classic";
				slb = Settings.SLB_UNIVERS1;
			case TypeBiome.TBFreeze		: 
				actualBiomeID = "ice";
				slb = Settings.SLB_UNIVERS1;
			case TypeBiome.TBMagma		: 
				actualBiomeID = "magma";
				slb = Settings.SLB_UNIVERS1;
			case TypeBiome.TBWater		: 
				actualBiomeID = "water";
				slb = Settings.SLB_UNIVERS2;
			case TypeBiome.TBCiv		: 
				actualBiomeID = "civ";
				slb = Settings.SLB_UNIVERS2;
			case TypeBiome.TBCentEarth		: 
				actualBiomeID = "core";
				slb = Settings.SLB_UNIVERS2;
		}
		
		bm = new h2d.SpriteBatch(slb.tile, this);
		bm.filter = true;
		
		arHS = [];
		
		redrawBG();
	}
	
	function redrawBG() {
		for (hs in arHS) {
			hs.dispose();
			hs = null;
		}
		
		arHS = [];
		
		var fd = slb.getFrameData("bgGlobal_" + actualBiomeID, 1);
		
		for (i in 0...Std.int(Settings.STAGE_WIDTH / (fd.wid * Settings.STAGE_SCALE)) + 1) {
			for (j in 0...Std.int(Settings.STAGE_HEIGHT / (fd.hei * Settings.STAGE_SCALE)) + 1) {
				var bg = slb.hbe_get(bm, "bgGlobal_" + actualBiomeID, 1);
				bg.scaleX = bg.scaleY = Settings.STAGE_SCALE;
				bg.x = i * Std.int(fd.wid * Settings.STAGE_SCALE);
				bg.y = j * Std.int(fd.hei * Settings.STAGE_SCALE);
				arHS.push(bg);
			}
		}
	}
	
	public function resize() {
		redrawBG();
	}
	
	public function destroy() {
		for (hs in arHS) {
			hs.dispose();
			hs = null;
		}
		
		arHS = [];
		
		bm.dispose();
		bm = null;
	}
}