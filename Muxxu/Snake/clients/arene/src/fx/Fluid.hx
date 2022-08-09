package fx;
import Protocole;
import mt.bumdum9.Lib;

private typedef FPart = { x:Float, y:Float, vx:Float, vy:Float, dp:Float, t:Int, col:Int };

class Fluid extends CardFx {//}

	var ww:Int;
	var hh:Int;

	var dec:Float;
	var res:Float;

	var canvas:mt.fx.FluidCanvas;
	var bmp:flash.display.BitmapData;
	var screen:flash.display.BitmapData;
	var mcScreen:flash.display.Bitmap;
	
	var parts:Array<FPart>;
	
	
	public function new(ca) {
		super(ca);
		ww = Stage.me.width;
		hh = Stage.me.height;
		

		res = 12;
		dec = 0;
		parts = [];
		
		canvas = new mt.fx.FluidCanvas( ww, hh, res );
		
		canvas.fadeSpeed = 0.01;
		canvas.visc = 0.0001;

		screen = new BMD(ww, hh, true, 0);
		mcScreen = new flash.display.Bitmap(screen);
		Stage.me.dm.add(mcScreen, Stage.DP_UNDER_FX);
		mcScreen.blendMode = flash.display.BlendMode.ADD;
			
		Filt.glow(mcScreen, 8, 1, 0xFFFFFF);
	
		//canvas.initColors();
		//bmp = new BMP(canvas.xmax, canvas.ymax, false, 0);

		
	}
	
	override function update() {
		super.update();
		
		if( sn == null ) return;
		if( sn.dead ) {
			vanish();
			return;
		}
		
		// ADD  FORCE & COLOR
		var pow = 0.1;
		var vx = -Snk.cos(sn.angle) * sn.realSpeed * pow;
		var vy = -Snk.sin(sn.angle) * sn.realSpeed * pow;
				
		canvas.addForce(sn.x, sn.y, vx, vy);
		dec = (dec + 0.05) % 1;
		
		var ec = 6;
		var p = addPart();
		p.x = sn.x + (Math.random()*2-1)*ec;
		p.y = sn.y + (Math.random()*2-1)*ec;
		//canvas.addColor(sn.x, sn.y, Col.getRainbow2(dec) );
		
		//
		var pow = 30.0;
		for( p in Game.me.parts ) {
			var o = canvas.getForce(p.x, p.y);
			p.x += o.x*pow;
			p.y += o.y*pow;
		}

		//
		var power = 100;
		var momentum = 0.5;
		var a = parts.copy();
		for( p in parts ) {
			var pow = canvas.getForce(p.x, p.y);
		
			p.vx = (pow.x * power * p.dp)  + p.vx * momentum;
			p.vy = (pow.y * power * p.dp)  + p.vy * momentum;
			
			p.x += p.vx ;
			p.y += p.vy ;
			
			
			
			if( p.x > 0 || p.x < ww ) {
				p.x = Num.mm(0, p.x, ww);
				p.vx *= -1;
			}
			if( p.y > 0 || p.y < hh ) {
				p.y = Num.mm(0, p.y, hh);
				p.vy *= -1;
			}
			
			
			screen.setPixel32(Std.int(p.x), Std.int(p.y), p.col );
			if(p.t-- <= 0 ) parts.remove(p);
			
		}
		
		// SCREEN
		var ct = new flash.geom.ColorTransform(1, 1, 1, 1, 0, 0, 0, -100);
		screen.colorTransform(screen.rect,ct);
		//screen.applyFilter(screen, screen.rect, new flash.geom.Point(0, 0), new flash.filters.BlurFilter(2, 2, 2));
		
		
		// DRAW
		//renderColors();

	}
	
	function renderColors() {
		canvas.drawBmp(bmp);
		
		var m = new flash.geom.Matrix();
		m.scale(res, res);
		screen.draw(bmp, m, null, flash.display.BlendMode.ADD);
		
		var ct = new flash.geom.ColorTransform(1, 1, 1, 1, 0, 0, 0, -50);
		screen.colorTransform(screen.rect, ct);
		screen.applyFilter( screen, screen.rect, new flash.geom.Point(0, 0), new flash.filters.BlurFilter(2, 2, 2) );
	}
	

	override function vanish() {
		sn = null;
		mcScreen.parent.removeChild(mcScreen);
		screen.dispose();
		super.vanish();
	}
	
	
	function addPart() {
		
		var color = Col.getRainbow2(dec) + 0xFF000000;
		var p = { x:0.0, y:0.0, vx:0.0, vy:0.0, dp:0.5+Math.random()*0.5, t:300, col:color };
		parts.push(p);
		return p;
	}
	



	
//{
}












