import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

enum DebriefState {
	APPEAR;
	WAIT;
	DONE;
}

class LevelDebriefingScreen {
	public var level : Int;
	public var stats : GameLevelStat;
	public var state : DebriefState;
	public var gfx : Sprite;
	public var timing : Float;

	public function new( lidx:Int, st:GameLevelStat ){
		level = lidx;
		stats = st;
		state = APPEAR;
		gfx = new Sprite();
		gfx.graphics.beginFill(0xFFFFFF);
		gfx.graphics.drawRect(0,0,200,100);
		gfx.graphics.endFill();
		var h1 = new Text("WELL DONE!", 20);
		h1.x = 10;
		h1.y = 10;
		gfx.addChild(h1);
		var t = new Text("Percent: "+st.pcent+" / "+st.goal, 16);
		t.x = 20;
		t.y = 30;
		gfx.addChild(t);
		var t = new Text("Perfect: "+Math.round((st.slow/(st.slow+st.fast))*1000)/10+"%", 16);
		t.x = 20;
		t.y = 50;
		gfx.addChild(t);
		var t = new Text("Bonuses: "+0, 16);
		t.x = 20;
		t.y = 70;
		gfx.addChild(t);

		gfx.x = 50;
		gfx.y = -110;
		timing = 0;
	}

	inline public static function bounce( p:Float ) : Float {
		var value = 0.0;
		var a = 0.0;
		var b = 1.0;
		while (true){
			if (p >= (7 - 4 * a) / 11){
				value = -Math.pow((11- 6*a - 11*p) / 4, 2) + b*b;
				break;
			}
			a += b;
			b /= 2.0;
		}
		return value;
	}

	public function update() : Bool {
		timing += mt.Timer.deltaT * 1000;
		return timing >= 1000.0;
		switch (state){
			case APPEAR:
				var ratio = Math.min(1.0, timing/500);
				gfx.y = -110 + 200 * (1 - bounce(1-ratio));
				if (ratio >= 1.0){
					timing = 0;
					state = WAIT;
				}

			case WAIT:
				var ratio = Math.min(1.0, timing/500);
				var value = stats.pcent * (1 - bounce(1-ratio));
				if (ratio >= 1.0){
					timing = 0;
					state = DONE;
				}

			case DONE:
		}
		return (state == DONE) && timing > 500;
	}

	public function render( view:BitmapData ){
		// Game.drawAt(view, gfx, gfx.x, gfx.y);
	}
}
