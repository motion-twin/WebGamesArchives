package entities;
import anim.FrameManager;
import Data;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import mt.deepnight.Color;
//import flash.display.Shape;
import Road;

/**
 * ...
 * @author 01101101
 */

class Oil extends Entity {
	
	public var size:Int;
	
	public function new (size:Int = 1) {
		super(OT.OOil);
		
		w = h = 88;
		
		layer = Level.FLOOR_DEPTH;
		
		useCustomBD = true;
		bmp.bitmapData = new BitmapData(w, h, true, 0x80FF00FF);
		
		var fname = "oil_" + Game.RAND.random(3);
		FM.copyFrame(bmp.bitmapData, fname, Game.SHEET_ROAD);
		
		bmp.filters = [
			Color.getColorizeMatrixFilter(0x1c0d22, 1,0),
			new flash.filters.GlowFilter(0x2a2136, 0.7, 8, 8, 1),
			new flash.filters.DropShadowFilter(1, -90, 0x2a2136, 0.7, 0, 0, 1, 1, true)
		];
		
		//bmp.scaleX = 1 + Game.RAND.random(10) / 10;
		//if (Game.RAND.random(20) == 0)	bmp.scaleX += Game.RAND.random(10) / 10;
		//bmp.scaleY = Math.min(1 + Game.RAND.random(7) / 10, bmp.scaleX);
		
		vy = Game.SPEED;
	}
	
}