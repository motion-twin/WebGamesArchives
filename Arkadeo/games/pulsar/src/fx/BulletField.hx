package fx;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
import Protocol;
import api.AKApi;

class BulletField extends mt.fx.Fx {//}
	
	static var SCALE = 8;
	static var WIDTH = 	Std.int(Game.WIDTH/SCALE);
	static var HEIGHT = Std.int(Game.HEIGHT/SCALE);
	
	var active:Bool;
	var bmd:BMD;
	var viewer:BMP;
	var line:gfx.Shotline;
	
	
	public function new() {
		super();
		bmd = new BMD(WIDTH, HEIGHT, false, 0);
		line = new gfx.Shotline();
		active = false;
	}
	
	override function update() {
		super.update();
		if( !active ) return;
		//FIXME : should be flaged with needRedraw BUT used for game logic in getRed !
		var m = new MX();
		for( sh in Game.me.shots ) {
			m.identity();
			m.rotate(sh.rotation * 0.0174);
			m.translate(sh.x, sh.y);
			m.scale(1 / SCALE, 1 / SCALE);
			bmd.draw(line, m, null, flash.display.BlendMode.ADD);
		}
		var ct = new CT(1, 1, 1, 1, -5, 0, 0, 0);
		bmd.colorTransform(bmd.rect, ct);
		var fl = new flash.filters.BlurFilter(2, 2);
		bmd.applyFilter(bmd, bmd.rect, Cs.PT, fl);
		active = false;
	}
	
	public function getEscape(x, y, test = 4, dist = 3) {
		active = true;
		var best = 256.0;
		var angle = 0.0;
		for( i in 0...test ) {
			var a = i * 6.28 / test;
			var nx = x + Math.cos(a) * dist;
			var ny = y + Math.sin(a) * dist;
			var red = getRed(nx, ny) + Game.me.seed.rand();
			if( red < best ) {
				best = red;
				angle = a;
			}
		}
		return angle;
	}
	
	public function getRed(x:Float, y:Float) {
		var px = Std.int(x / SCALE);
		var py = Std.int(y / SCALE);
		
		var ma = 5;
		if( px < ma || px > WIDTH-ma || py < ma || py > HEIGHT-ma ) return 255;
		
		var col = bmd.getPixel(px, py);
		return Col.colToObj(col).r;
	}
}
