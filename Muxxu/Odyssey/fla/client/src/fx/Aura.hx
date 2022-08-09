package fx;
import Protocole;
import mt.bumdum9.Lib;

//private typedef Move = { folk:Folk, tw:Tween, spc:Float };

class Aura extends mt.fx.Fx {//}
	
	
	static var WIDTH = 100;
	static var HEIGHT = 100;

	var bmp:BMD;
	var canvas:flash.display.Bitmap;
	var folk:Folk;
	
	var cycle:Float;
	var fadeStart:Null<Int>;
	var fadeValue:Null<Int>;

	
	public function new(f:Folk) {
		super();

		folk = f;

		bmp = new BMD(WIDTH, HEIGHT, true, 0);
		canvas = new flash.display.Bitmap(bmp);
		Scene.me.dm.add(canvas, Scene.DP_UNDER_FX);
		
		cycle = 0;
		
		
	}

	
	// UPDATE
	override function update() {
		super.update();
		
		canvas.x = folk.x-Std.int(WIDTH>>1);
		canvas.y = folk.y-HEIGHT;
	

		
		// CYCLE
		cycle = (cycle + 0.02) % 1;
		var col = { r:255, g:80 + Std.int(Math.cos(cycle * 6.28) * 80), b:0 };
		
		// DRAW
		var m = new MX();
		m.translate(WIDTH>>1,HEIGHT);
		var ct = new CT(0,0,0,1,col.r,col.g,col.b,0);
		bmp.draw(folk,m,ct);
		
		//*
		var ct = new CT(1, 1, 1, 1, 0, 0, 0, -10);
		bmp.colorTransform(bmp.rect, ct);
		
		//
		bmp.scroll(0, -1);
		
		
		
		
		// FADE;
		if ( fadeValue != null ) {
			fadeValue--;
			canvas.alpha = fadeValue / fadeStart;
			if ( fadeValue == 0) {
				kill();
			}
		}
		
		
	}
	
	override function kill() {
		super.kill();
		canvas.parent.removeChild(canvas);
		bmp.dispose();
	}
	
	public function fade(n = 10) {
		fadeStart = fadeValue = n;
	}
	
	

	
	
//{
}