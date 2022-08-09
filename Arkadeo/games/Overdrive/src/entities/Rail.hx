package entities;
import anim.FrameManager;
import Data;
import flash.display.BitmapData;
import flash.geom.Point;

/**
 * ...
 * @author 01101101
 */

class Rail extends Entity {
	
	public var infinite(default, null):Bool;
	
	public function new (v:Int = 0, infinite:Bool = false, flip:Bool = false) {
		super(OT.ORail);
		
		w = 32;
		h = v * Game.TILE_SIZE;
		
		this.infinite = infinite;
		
		layer = Level.FLOOR_DEPTH;
		
		useCustomBD = true;
		
		bmp.bitmapData = new BitmapData(w, h, true, 0x80FF00FF);
		
		var p = new Point();
		var max = Math.ceil(h / Game.TILE_SIZE);
		for (i in 0...max) {
			p.y = i * Game.TILE_SIZE;
			if (!infinite) {
				if (i == 0)				FM.copyFrame(bmp.bitmapData, "middleRail_top", Game.SHEET_ROAD, p);
				else if (i == max - 1)	FM.copyFrame(bmp.bitmapData, "middleRail_bottom", Game.SHEET_ROAD, p);
				else					FM.copyFrame(bmp.bitmapData, "middleRail_middle_" + Std.random(2), Game.SHEET_ROAD, p);
			} else {
				if (flip)	FM.copyFrame(bmp.bitmapData, "sideRail_middle", Game.SHEET_ROAD, p);
				else		FM.copyFrame(bmp.bitmapData, "sideRail_middle_flip", Game.SHEET_ROAD, p);
			}
		}
		
		//baseColor = 0x999999;
		
		vy = Game.SPEED;
	}
	
	static public function simulateTime () :Int {
		// Calculate the number of frames required to reach 70% overdrive
		var f = Math.ceil(Player.MAXIMUM_OVERHEAT * 0.6 / Player.BASE_OH);
		return f;
	}
	
}










