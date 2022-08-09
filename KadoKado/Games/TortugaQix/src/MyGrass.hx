import flash.display.BitmapData;

class MyGrass {
	static var zoom = 1;
	public static var grass : BitmapData;
	static var buffer : BitmapData;
	static var seed : Null<Int> = null;
	public static var wildGrass : Array<BitmapData> = [];
	static var fastGrass : Array<BitmapData> = [];
	static var slowGrass : Array<BitmapData> = [];
	static var borderGrass : Array<BitmapData> = [];

	static function init(){
		grass = new BitmapData(Game.W, Game.H, true, Colors.GRASS_BG);
		buffer = new BitmapData(Game.W, Game.H, true, Colors.GRASS_BG);
		seed = Std.random(9999);
		var genGrass = function(height:Float, colors){
			var g = new Grass(
				zoom * (1 + 1 * Math.random()),
				zoom * height,
				(0.5 + 0.3 * Math.random()),
				(0.3 * (Math.random() * 2 - 1)),
				colors
			);
			var b = new flash.display.BitmapData(Math.ceil(g.width), Math.ceil(g.height), true, 0x00000000);
			var m = new flash.geom.Matrix();
			m.translate(g.width/2, g.height);
			b.draw(g,m);
			return b;
		}
		for (i in 0...100){
			wildGrass.push(genGrass(10 + i/10, Colors.WILD_GRASS));
			fastGrass.push(genGrass(6, Colors.FAST_GRASS));
			slowGrass.push(genGrass(3, Colors.SLOW_GRASS));
		}
		for (i in 0...20){
			borderGrass.push(genGrass(4, Colors.BORDER_GRASS));
		}
	}

	inline static var LINES_PER_FRAME = 3;
	static var line = 0;
	static var done = false;
	static var rnd : mt.Rand;

	// TODO: optimisation
	// Idea: We render grass for some time and when time's up we echap the function.
	// Drawback: We no longer know how many frames it will take to do this
	public static function update(clear:Bool=false, newLevel:Bool=false) : Bool {
		if (seed == null)
			init();
		var step = 4;
		var step = step * zoom;
		if (clear){
			if (newLevel)
				seed = Std.random(9999);
			done = false;
			rnd = new mt.Rand(seed);
			buffer.fillRect(new flash.geom.Rectangle(0,0,Game.W,Game.H), Colors.BORDER_GRASS_BG);
			buffer.fillRect(Game.field, Colors.GRASS_BG);
			line = 0;
		}
		if (done)
			return true;
		while (line < Std.int(Game.H/step)+3){
			var y = line;
			for (x in 0...Std.int(Game.W/step)+3){
				var rx = Std.int(x * step + rnd.rand()*step/2);
				var ry = Std.int(y * step + rnd.rand()*step/2);
				var g : BitmapData = null;
				var c = Game.getPixel(rx, ry);
				if (c == 0 || c == Colors.OUTSIDE)
					g = borderGrass[rnd.random(borderGrass.length)];
				else if (Colors.isConqueredSlow(c))
					g = slowGrass[rnd.random(slowGrass.length)];
				else if (Colors.isConqueredFast(c))
					g = fastGrass[rnd.random(fastGrass.length)];
				else
					g = wildGrass[rnd.random(wildGrass.length)];
				var m = new flash.geom.Matrix();
				m.translate(rx+g.width/2, ry-g.height);
				buffer.draw(g, m);
			}
			++line;
			if (line % LINES_PER_FRAME == 0){
				break;
			}
		}
		if (line < Std.int(Game.H/step)+3)
			return false;
		done = true;
		grass.draw(buffer);
		var tmp = new flash.display.BitmapData(Game.W, Game.H, true, 0x00000000);
		var nShad = 5+rnd.random(7);
		for (i in 0...nShad){
			var shadow = new flash.display.Shape();
			shadow.graphics.beginFill(0x1A1A00 | rnd.random(40));
			shadow.graphics.drawEllipse(0, 0, 70+60*rnd.rand(), 70 + 60*rnd.rand());
			shadow.graphics.endFill();
			var m = new flash.geom.Matrix();
			m.rotate(rnd.rand() * Math.PI);
			m.translate(rnd.random(Game.W), rnd.random(Game.H));
			tmp.draw(shadow, m);
		}
		tmp.applyFilter(tmp, tmp.rect, new flash.geom.Point(0,0), new flash.filters.BlurFilter(30,30,4));
		grass.draw(new flash.display.Bitmap(tmp), flash.display.BlendMode.DIFFERENCE);
		tmp.dispose();
		return true;
	}


	public static function drawLawn(step=4, zoom=2) : flash.display.Sprite {
		var result = new flash.display.Sprite();
		result.graphics.beginFill(0x335500);
		result.graphics.drawRect(0,0,300,300);
		result.graphics.endFill();
		var step = step * zoom;
		for (x in 0...Std.int(300/step)+1){
			for (y in 0...Std.int(300/step)+3){
				var g = new Grass(
					zoom* (1+1*Math.random()),
				    zoom* (10+40*Math.random()),
					(0.5 + 0.3*Math.random()),
					(0.4 * (Math.random()*2 - 1))
				);
				g.x = x * step + Math.random()*step/2;
				g.y = y * step + Math.random()*step/2;
				result.addChild(g);
			}
		}
		return result;
	}
}