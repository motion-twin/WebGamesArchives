package fx;
import mt.bumdum9.Lib;
import Protocol;
private typedef FPart = { x:Float, y:Float, vx:Float, vy:Float, momentum:Float };

/**
 * unused particle field
 */
class PartField extends mt.fx.Fx {//}
	
	var base:SP;
	var perl:BMD;
	
	var xmax:Int;
	var ymax:Int;
	var scale:Int;
	var seed:Int;
	
	var parts:Array<FPart>;
	
	var screen:BMD;
	var pos:PT;
	
	var width:Int;
	var height:Int;
	var loopX:Int;
	var loopY:Int;
	
	var ct:CT;
	
	public function new(mcw, mch,loopX,loopY ) {
		super();
		width = Math.ceil(mcw/loopX);
		height = Math.ceil(mch/loopY);
		this.loopX = loopX;
		this.loopY = loopY;
		
		
		base = new SP();
		Game.me.dm.add(base, Game.DP_FILTER);
		
		scale = 16;
		seed = Game.me.rnd(10000);
		pos = new PT(0, 0);
		
		xmax = Math.ceil(width / scale);
		ymax = Math.ceil(height/ scale);
		perl = new BMD(xmax, ymax, false, 0xFF0000);
		majPerl();
		
		ct =  new CT(1, 1, 1, 1, -40, -5, -5, -10);
		
		// PARTS
		parts = [];
		var max = 256;
		for( i in 0...max ) {
			var momentum = i / max;
			var o = { x:Math.random() * width, y:Math.random() * height, momentum:momentum, vx:0.0, vy:0.0 };
			parts.push(o);
		}
		
		
		
		
		// SHOW
		var show = new BMP(perl);
		show.scaleX = show.scaleY = scale;
		//base.addChild(show);
		
		
		//
		screen = new BMD(width, height, true, 0);
		for( x in 0...loopX ) {
			for( y in 0...loopY ) {
				var mc = new BMP(screen);
				mc.x = x * width;
				mc.y = y * height;
				base.addChild(mc);
				
				Filt.glow(mc, 4, 1,0xFFFFFF);
				mc.blendMode = flash.display.BlendMode.ADD;
					
				
			}
		}

		
		

		
	}
	
	override function update() {
		super.update();
		
		
		//screen.fillRect(screen.rect,0xFF000000);
		screen.lock();
		//screen.fillRect(screen.rect,0);
		//screen.colorTransform(screen.rect,new CT(1, 1, 1, 1, -40, -5, -5, -10));
		screen.colorTransform(screen.rect,ct);
		
		
		for( p in parts ) {
			var speed = getZoneTurb(p.x, p.y);
			var co = 0.1 + p.momentum;
			var sp = 6;// 4 + speed.coef * 6;
			p.x += speed.x * sp * co;
			p.y += speed.y * sp * co;
			p.x = Num.sMod(p.x, width);
			p.y = Num.sMod(p.y, height);
			screen.setPixel32(Std.int(p.x), Std.int(p.y), 0xFFFFFFFF);
		}
		screen.unlock();
		
		majPerl();
	}
	
	function getZoneTurb(x:Float,y:Float) {
		var px = Std.int(x / scale);
		var py = Std.int(y / scale);
		var pix = perl.getPixel(px, py);
		var o = Col.colToObj(pix);
		return {
			x:(o.r-128)/255,
			y:(o.g - 128) / 255,
			coef:o.b / 256,
		}
	}
	
	function majPerl() {
		perl.perlinNoise(xmax, ymax, 3, seed, false, false, 3, false,[pos,pos,pos,pos]);
		pos.x+=4/scale;
	}
	

}