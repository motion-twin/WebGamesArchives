package ;

//import anim.FrameManager;
//import entities.Rail;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
//import haxe.Resource;
//import mt.Rand;
//import flash.events.Event;
//import flash.geom.Rectangle;
import flash.Lib;
//import Road;

/**
 * ...
 * @author 01101101
 */

//@:bitmap("../gfx/img/road_slice.jpg") class RoadSliceBM extends BitmapData {}
//@:bitmap("../gfx/img/sand_debug.jpg") class SandBM extends BitmapData { }
//@:bitmap("../gfx/img/sand.jpg") class SandBM extends BitmapData { }
//@:bitmap("../gfx/img/road.jpg") class RoadBM extends BitmapData { }
//@:bitmap("../gfx/img/test.jpg") class TestBM extends BitmapData { }
//@:bitmap("../gfx/img/map_test.png") class MapBM extends BitmapData { }


//@:bitmap("../gfx/img/sprites_bg.png") class SpritesBgBM extends BitmapData { }
//@:bitmap("../gfx/img/sprites.png") class SpritesBM extends BitmapData { }

class Main {
	
	//static public var RAND:Rand;
	
	static function main () {
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		
		Lib.current.stage.addChild(new Game());
		//Lib.current.addChild(new Joyride());
		
		/*trace(0x80);
		trace(0x8000);
		trace(0x8000 >> 8);
		trace(0x80 << 8);*/
		
		/*var bdA = new BitmapData(48, 48, false, 0xFFFF00);
		var bdB = new BitmapData(96, 96, false);

		bdA.fillRect(new Rectangle(16, 16, 16, 16), 0xFF0000);
		bdA.fillRect(new Rectangle(17, 17, 14, 14), 0xFFCC00);

		var bA = new Bitmap(bdA);
		bA.x = bA.y = 1;
		Lib.current.stage.addChild(bA);

		var bB = new Bitmap(bdB);
		bB.x = bA.x + bA.width + 1;
		bB.y = bA.y;
		Lib.current.stage.addChild(bB);

		var r = new Rectangle(0, 0, 32, 32);// Do not define x and y of the area to clip, apply future scale to area with/height (WTF ADOBE?!)
		var m = new Matrix();
		m.translate(-16, -16);// These define the x and y of the area to clip
		m.scale(2, 2);
		bdB.draw(bdA, m, null, null, r);*/
		
		//FrameManager.store("ROAD", new SpritesBgBM(0, 0), Resource.getString("spritesBgJson"));
		//FrameManager.store("SPRITES", new SpritesBM(0, 0), Resource.getString("spritesJson"));
		//var h = 4;
		
		//RAND = new Rand(12345678);
		//RAND.rand();
		
		//Lib.current.addChild(new ScrollV2());
		//Lib.current.addChild(new RenderV2());
		
		
		/*var r = RoadEngine.createRoad();
		
		var h = 0;
		for (s in r.slices) {
			h += s.bd.height;
		}
		
		var bd = new BitmapData(RW.XL + 10, h, false, 0xFFEEEEEE);
		Lib.current.addChild(new Bitmap(bd));
		
		var i = 0;
		for (s in r.slices) {
			bd.copyPixels(s.bd, s.bd.rect, new Point(0, bd.height - s.bd.height - i));
			i += s.bd.height;
		}*/
		
		/*var rl = new RandList();
		rl.setFastDraw();
		
		rl.add(0, 1);
		rl.add(1, 1);
		
		var count = 0;
		var draws = 1000;
		var drawTrace = function () {
			count = 0;
			for (i in 0...draws) {
				if (rl.draw() == 1)	count++;
			}
			trace(Std.int((draws - count) / 10) + "% - " + Std.int(count / 10) + "%");
		}
		
		for (i in 0...5)	drawTrace();
		
		trace("----");
		rl.add(0, 1);
		
		for (i in 0...5)	drawTrace();
		
		trace("----");
		rl.add(0, 1);
		
		for (i in 0...5)	drawTrace();
		
		trace("----");
		rl.add(1, 2);
		
		for (i in 0...5)	drawTrace();*/
		
		//{
		/*trace(0xFF + " / " + 0x0000FF);
		trace(0xFF0000);
		trace(0x000000);
		trace((0xFFFFFF & 0xFF0000) + " / " + (0xFFFFFF & 0x00FFFF));
		trace((0x00FFFF & 0xFF0000) + " / " + (0x00FFFF & 0x00FFFF));
		trace((0xFF0001 & 0xFF0000) + " / " + (0xFF0001 & 0x00FFFF));
		trace((0x000001 & 0xFF0000) + " / " + (0x000001 & 0x00FFFF));
		trace("----");
		trace(0xFF0000 + 256);
		trace(0xFF0000 + 0x80);
		trace(0xFF0000 | 0x80);*/
		
		
		/*trace(17 | 42 << 8);
		trace(10769 & 0xFF);
		trace(10769 >> 8);*/
		
		
		//var r:RoadV2;
		//var b:Bitmap;
		
		/*r = new RoadV2(0);
		
		var sd:SliceData;
		
		sd = r.generate();
		b = new Bitmap(sd.bitmapData);
		b.y = (b.height + 1) * 3;
		Lib.current.stage.addChild(b);
		b = new Bitmap(sd.perlin);
		b.x = 10;
		b.y = (b.height + 1) * 3;
		Lib.current.stage.addChild(b);
		
		sd = r.generate(h);
		b = new Bitmap(sd.bitmapData);
		b.y = (b.height + 1) * 2;
		Lib.current.stage.addChild(b);
		b = new Bitmap(sd.perlin);
		b.x = 10;
		b.y = (b.height + 1) * 2;
		Lib.current.stage.addChild(b);
		
		sd = r.generate(h);
		b = new Bitmap(sd.bitmapData);
		b.y = (b.height);
		Lib.current.stage.addChild(b);*/
		
		//sd = r.generate(h);
		//b = new Bitmap(sd.bitmapData);
		//Lib.current.stage.addChild(b);
		//b = new Bitmap(sd.perlin);
		//b.x = 71;
		//Lib.current.stage.addChild(b);
		
		//var screenData = new BitmapData(19, 15, false);
		//var screen = new Bitmap(screenData);
		//screen.scaleX = screen.scaleY = 4;
		//screen.x = screen.y = 100;
		//Lib.current.stage.addChild(screen);
		//}
	}
	
}










