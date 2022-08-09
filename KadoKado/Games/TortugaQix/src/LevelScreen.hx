import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import Cursor;

enum LevelScreenState {
	APPEAR;
	WAIT;
	DISAPPEAR;
}

class LevelScreen {
	public var level : Int;
	public var anim : flash.display.BitmapData;
	public var timing : Float;
	public var ratio : Float;
	public var state : LevelScreenState;
	public var back : BitmapData;
	public var turtle : Tortue;
	public var direction : Int;

	public function new( n:Int, bg:BitmapData ){
		state = APPEAR;
		direction = 1;
		back = bg.clone();
		level = n;
		timing = 0.0001;
		anim = new flash.display.BitmapData(Game.VW, Game.VH, true, 0x000000);
		var s = MyGrass.drawLawn(3, 10);
		var text = new Text("LEVEL "+n, 60, 0xFFF0F0F0, 0xFF000000);
		text.x = (Game.VW - text.width) / 2;
		text.y = (Game.VH/2) - text.height;
		s.addChild(text);
		anim.draw(s);
		turtle = new Tortue();
		turtle.gotoAndStop(1);
	}

	inline public static function expo( ratio:Float ) : Float {
		return Math.pow(2, 8 * (ratio-1));
	}

	public function update( subProcessReady:Bool ) : Bool {
		timing += mt.Timer.deltaT * 1000;
		switch (state){
			case APPEAR:
				ratio = Math.min(1.0, timing / 1000);
				if (ratio >= 1.0){
					timing = 0.0;
					back.dispose();
					back = null;
					state = WAIT;
				}

			case WAIT:
				if (timing >= 1000 && subProcessReady){
					timing = 0.0;
					direction = -1;
					state = DISAPPEAR;
				}

			case DISAPPEAR:
				ratio = 1 - Math.min(1.0, timing / 1000);
				if (ratio <= 0){
					anim.dispose();
					return true;
				}
		}
		return false;
	}

	static var nbands = 10;

	public function render( view:BitmapData ){
		if (back != null)
			view.copyPixels(back, back.rect, new Point(0,0));
		if (Math.isNaN(ratio))
			return;
		var th = turtle.height; th = 18;
		var tw = turtle.width; tw = 36;
		var matrix = new flash.geom.Matrix();
		var fxratio = expo(ratio);
		turtle.cacheAsBitmap = true;
		for (i in 0...nbands){
			var brect = new flash.geom.Rectangle(0, i*Game.VH/nbands, Game.VW, Game.VH/nbands);
			var x = (i%2 == 0) ? (1-fxratio) * (Game.VW + tw) : (1 - fxratio) * -(Game.VW + tw);
			view.copyPixels(anim, brect, new Point(x, brect.y));
			matrix.identity();
			if (i % 2 == 1){
				matrix.scale(direction, 1);
				matrix.translate(x+Game.VW+tw/2, brect.y+th);
			}
			else {
				matrix.scale(-1*direction, 1);
				matrix.translate(x-tw/2, brect.y+th);
			}
			view.draw(turtle, matrix);
		}
	}
}