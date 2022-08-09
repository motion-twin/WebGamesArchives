package ;

import h2d.Sprite;

import mt.deepnight.slb.HSprite;
import mt.deepnight.slb.HSpriteBE;

import Common;

import data.Settings;

/**
 * ...
 * @author Tipyx
 */
class Wall extends Sprite
{
	var game					: process.Game;
	
	var bmWallBG				: h2d.SpriteBatch;
	var bmFX					: h2d.SpriteBatch;
	
	var arHS					: Array<HSprite>;
	var arHSBE					: Array<HSpriteBE>;
	
	var fd 						: mt.deepnight.deprecated.SpriteLibBitmap.FrameData;
	var scaleValue				: Float;
	
	var offsetY					: Int;
	var reposY					: Float;
	
	var leftX					: Float;
	var rightX					: Float;
	
	var actualBiomeID			= "classic";
	var slb						: mt.deepnight.slb.BLib;
	
	public function new() 
	{
		super();
		
		game = process.Game.ME;
		
		switch (game.levelInfo.biome) {
			case TypeBiome.TBClassic	: 
				actualBiomeID = "classic";
			case TypeBiome.TBFreeze		: 
				actualBiomeID = "ice";
			case TypeBiome.TBMagma		: 
				actualBiomeID = "magma";
			case TypeBiome.TBWater		: 
				actualBiomeID = "water";
			case TypeBiome.TBCiv		: 
				actualBiomeID = "civ";
			case TypeBiome.TBCentEarth	: 
				actualBiomeID = "core";
			case TypeBiome.TBNightmare	: 
				actualBiomeID = "nightmare";
			case TypeBiome.TBLimbo	: 
				actualBiomeID = "tree";
		}
		slb = switch( data.LevelDesign.GET_BIOME_UNIVERS(game.levelInfo.biome) ){
			case 0: Settings.SLB_UNIVERS1;
			case 1: Settings.SLB_UNIVERS2;
			case 2: Settings.SLB_UNIVERS3;
			default: null;
		}
		
		bmWallBG = new h2d.SpriteBatch(slb.tile, this);
		bmWallBG.optimizeForStatic(true);
		
		bmFX = new h2d.SpriteBatch(Settings.SLB_UI.tile, this);
		bmFX.blendMode = h2d.BlendMode.Multiply;
		bmFX.optimizeForStatic(true);
		bmFX.visible = false;
		
		arHS = [];
		arHSBE = [];
		
		redrawWall();
	}
	
	function redrawWall() {
	// REMOVE PREVIOUS
		for (hs in arHS) {
			hs.dispose();
			hs = null;
		}
		arHS = [];
		
		for (hs in arHSBE) {
			hs.dispose();
			hs = null;
		}
		arHSBE = [];

	// GENERATE NEW ONE
		var scale = Settings.STAGE_SCALE #if !standalone / 0.65 #end;
	
		var fd = slb.getFrameData("bgGlobal_" + actualBiomeID, 1);
		
		for (i in 0...Std.int(Settings.STAGE_WIDTH / (fd.wid * scale)) + 1) {
			for (j in 0...Std.int(Settings.STAGE_HEIGHT / (fd.hei * scale)) + 1) {
				var bg = slb.hbe_get(bmWallBG, "bgGlobal_" + actualBiomeID, 1);
				bg.scaleX = bg.scaleY = scale;
				bg.x = i * Std.int(fd.wid * scale);
				bg.y = j * Std.int(fd.hei * scale);
				bg.changePriority(1);
				arHSBE.push(bg);
			}
		}
	
		var widFill = Std.int(slb.getFrameData("bgGlobal_" + actualBiomeID, 0).wid * scale);
		
		var newX = 0;
	
		// WALL LEFT
		var wallLeft = slb.hbe_get(bmWallBG, "wall_" + actualBiomeID, 0);
		wallLeft.scaleX = wallLeft.scaleY = scale;
		wallLeft.setCenterRatio(1, 0);
		wallLeft.x = newX = Std.int(game.cRocks.x - widFill * 0.25);
		wallLeft.changePriority(0);
		arHSBE.push(wallLeft);
		
		newX -= Std.int(wallLeft.frameData.realFrame.realWid * scale);
			
		for (i in 0...Std.int((wallLeft.x - wallLeft.width) / widFill) + 1) {
			var fillLeft = slb.hbe_get(bmWallBG, "bgGlobal_" + actualBiomeID, 0);
			fillLeft.scaleX = fillLeft.scaleY = scale;
			fillLeft.setCenterRatio(1, 0);
			fillLeft.x = newX;
			fillLeft.changePriority(0);
			arHSBE.push(fillLeft);
			
			newX -= widFill;
		}
	
		// WALL RIGHT
		var wallRight = slb.hbe_get(bmWallBG, "wall_" + actualBiomeID, 0);
		wallRight.scaleX = -scale;
		wallRight.scaleY = scale;
		wallRight.setCenterRatio(1, 0);
		wallRight.x = newX = Std.int(game.cRocks.x) + Std.int(game.gridWidth + widFill * 0.25);
		wallRight.changePriority(0);
		
		arHSBE.push(wallRight);
		
		newX += Std.int(wallRight.frameData.realFrame.realWid * scale);
			
		for (i in 0...Std.int((Settings.STAGE_WIDTH - wallRight.x - wallRight.width) / widFill) + 1) {
			var fillRight = slb.hbe_get(bmWallBG, "bgGlobal_" + actualBiomeID, 0);
			fillRight.scaleX = -scale;
			fillRight.scaleY = scale;
			fillRight.setCenterRatio(1, 0);
			fillRight.x = newX;
			fillRight.changePriority(0);
			arHSBE.push(fillRight);
			
			newX += widFill;
		}
	// FX
		// WALL
		var fxHeiWall = Std.int(Settings.SLB_UI.getFrameData("fxWall").hei * Settings.STAGE_SCALE);
		
		var fxWallLeft = Settings.SLB_UI.hbe_get(bmFX, "fxWall");
		fxWallLeft.scaleX = Settings.STAGE_SCALE;
		fxWallLeft.scaleY = fxHeiWall * (Std.int(Settings.STAGE_HEIGHT / fxHeiWall) + 1);
		arHSBE.push(fxWallLeft);
		
		var fxWallRight = Settings.SLB_UI.hbe_get(bmFX, "fxWall");
		fxWallRight.scaleX = -Settings.STAGE_SCALE;
		fxWallRight.scaleY = fxWallLeft.scaleY;
		fxWallRight.x = Settings.STAGE_WIDTH;
		arHSBE.push(fxWallRight);
		
		//HOT
		var fxWidHot = Std.int(Settings.SLB_UI.getFrameData("fxBottom_a").wid);
		
		var fxHot = Settings.SLB_UI.h_get("fxBottom_a");
		fxHot.filter = true;
		fxHot.setCenterRatio(0, 1);
		fxHot.scaleX = Settings.STAGE_WIDTH / fxWidHot;
		fxHot.scaleY = Settings.STAGE_SCALE;
		fxHot.y = Settings.STAGE_HEIGHT;
		fxHot.blendMode = h2d.BlendMode.SoftOverlay;
		arHS.push(fxHot);
		this.addChild(fxHot);
	}
	
	public function resize() {
		redrawWall();
	}
	
	public function destroy() {
		for (hs in arHS) {
			hs.dispose();
			hs = null;
		}
		
		for (hs in arHSBE) {
			hs.dispose();
			hs = null;
		}
		
		bmWallBG.dispose();
		bmWallBG = null;
		
		bmFX.dispose();
		bmFX = null;
		
		arHS = null;
		arHSBE = null;
	}
}
