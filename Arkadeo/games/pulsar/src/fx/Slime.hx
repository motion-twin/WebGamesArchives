package fx;
import Protocol;
import mt.bumdum9.Lib;


class Slime extends mt.fx.Fx {
	
	public static var SCALE = 1;

	var layer:SP;
	var bmp:BMD;
	var disp:BMD;
	var timer:Int;
	// BRUSH
	var cadaver:EL;
	var spot:gfx.SlimeSpot;

	public function new() {
		super();
		timer = 0;
		
		layer = new SP();
		Game.me.dm.add(layer,Game.DP_SHADE);
		
		var mx = Game.BORDER_X;
		var my = Game.BORDER_Y;
		var ww = Std.int((Game.WIDTH - mx * 2)/SCALE);
		var hh = Std.int((Game.HEIGHT - my * 2)/SCALE);
		
		bmp = new BMD(ww, hh, true, 0);
		disp =  bmp.clone();
		var mc = new flash.display.Bitmap(disp);
		mc.scaleX = mc.scaleY = SCALE;
		layer.addChild(mc);
		layer.x = mx;
		layer.y = my;
		//
		spot = new gfx.SlimeSpot();
		cadaver = new EL();
		cadaver.goto("follower_cadaver");
		
		Filt.glow(layer, 12, 2.4, 0x107D00, true);
		layer.filters = [
			new flash.filters.DropShadowFilter(5,90,0x88FF88,1,2,2,1,1,true),		// LIGHT
			//new flash.filters.GlowFilter(0x107D00, 1, 12, 12, 2.4, 1, true),		// SHADE
			new flash.filters.GlowFilter(0x055400, 1, 12, 12, 1.6, 1, true),		// SHADE
			new flash.filters.DropShadowFilter(2,90,0,0.5,4,4,1),					// SHADOW
		];
		
		layer.blendMode = flash.display.BlendMode.OVERLAY;
	}

	override function update() {
		super.update();
		timer++;
		//return;
		if( timer % 8 > 0 ) return;
		
		if( Game.me.needRedraw )
		{
			// REDUCTION
			var fl = new flash.filters.GlowFilter(0x0000FF, 1, 2, 2, 1, 1, true);
			bmp.applyFilter(bmp, bmp.rect, Cs.PT , fl);
			var m = [
				1, 0, 0.1, 0, 0,
				0, 1, 0.6, 0, 0,
				0, 0, 0, 0, 0,
				0, 0, -0.5, 1, 0,
			];
			var fl = new flash.filters.ColorMatrixFilter(m);
			bmp.applyFilter(bmp, bmp.rect, Cs.PT , fl);
			render();
		}
	}
	
	public function render() {
		disp.lock();
		disp.copyPixels(bmp, disp.rect,Cs.PT);
		
		var a = [
			new flash.filters.DropShadowFilter(5,90,0x88FF88,1,2,2,1,1,true),		// LIGHT
			//new flash.filters.GlowFilter(0x107D00, 1, 12, 12, 2.4, 1, true),		// SHADE
			new flash.filters.GlowFilter(0x055400, 1, 12, 12, 1.6, 1, true),		// SHADE
			//new flash.filters.DropShadowFilter(2,90,0,0.5,4,4,1),					// SHADOW
		];
		
		a = [];//???BEN WTF
		for ( fl in a ) {
			disp.applyFilter(disp,disp.rect,Cs.PT,fl);
		}
		disp.unlock();
	}
	
	public function splash2(mc:SP, x, y, an = 0.0, sc = 1.0, speed = 12.0) {
		var p = new mt.fx.Part(mc);
		p.setPos(x, y);
		p.frict = 0.7;
		p.vx = Math.cos(an) * speed;
		p.vy = Math.sin(an) * speed;
		p.timer = 8;
		p.onFinish = callback( draw, mc );
		p.twist(30, 0.5);
		p.setScale(sc);
		layer.addChild(mc);
		
		new mt.fx.Spawn(mc, 0.2, false, true);
		return p;
	}
	
	function draw(mc:SP) {
		
		bmp.draw(mc, mc.transform.matrix);
		render();
	}
	
	public function isSticky(x:Float, y:Float) {
		return ( bmp.getPixel32(Std.int(x), Std.int(y))>>> 24) > 0;
	}

}
