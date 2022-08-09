package entities;
import anim.FrameManager;
import Data;
import flash.display.BitmapData;
import Road;

/**
 * ...
 * @author 01101101
 */

class Drop extends Entity {
	
	public function new () {
		super(OT.ODrop);
		
		w = 32;
		h = 32;
		
		layer = Level.FLOOR_DEPTH;
		
		useCustomBD = true;
		bmp.bitmapData = new BitmapData(w, h, true, 0x80FF00FF);
		FM.copyFrame(bmp.bitmapData, "mine", Game.SHEET_ROAD);
		
		vy = Game.SPEED;
	}
	
}