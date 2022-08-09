package ui;

import anim.FrameManager;
import Data;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

/**
 * ...
 * @author 01101101
 */

class Hint extends Sprite {
	
	public var xx:Float;
	var iconBD:BitmapData;
	var iconB:Bitmap;
	
	public function new () {
		super();
		iconBD = FM.getFrame("hint", Game.SHEET_ROAD);
		iconB = new Bitmap(iconBD);
		iconB.x = -Std.int(iconB.width / 2);
		addChild(iconB);
	}
	
	public function update () {
		if (xx < -Level.instance.container.x + iconB.width / 2 + 8)							x = -Level.instance.container.x + iconB.width / 2 + 8;
		else if (xx > -Level.instance.container.x + Game.SIZE.width - iconB.width / 2 - 8)	x = -Level.instance.container.x + Game.SIZE.width - iconB.width / 2 - 8;
		else x = xx;
	}
	
}










