import flash.display.Shape;


class CutParticle {
	public var matrix : flash.geom.Matrix;
	public var dx : Float;
	public var dy : Float;
	public var rs : Float;
	public var sx : Float;
	public var sy : Float;
	public var x : Float;
	public var y : Float;
	public var r : Float;
	public var alive : Bool;

	public function new( ox:Float, oy:Float, dx:Float, dy:Float, rs:Float, sx:Float, sy:Float ){
		this.matrix = new flash.geom.Matrix();
		this.dx = dx;
		this.dy = dy;
		this.rs = rs;
		this.sx = sx;
		this.sy = sy;
		this.x = ox;
		this.y = oy;
		this.r = rs;
		this.alive = true;
	}

	public function update(){
		x += dx;
		y += dy;
		r += rs;
		matrix = new flash.geom.Matrix();
		matrix.scale(sx, sy);
		matrix.rotate(r);
		matrix.translate(x, y);
		sx -= 0.02;
		sy -= 0.02;
		if (sx <= 0 || sy <= 0)
			alive = false;
	}

	inline public function render( dest:flash.display.BitmapData ){
		var shape = MyGrass.wildGrass[Std.random(MyGrass.wildGrass.length)];
		dest.draw(shape, matrix);
	}
}

class CutParticleSystem {
	static var maxDensity = 4;
	static var maxSize : Float = 200*200;
	static var maxParticles : Float = 1000;
	var particles : Array<CutParticle>;

	inline static function random( low:Float, max:Float ) : Float {
		return low + (max - low) * Math.random();
	}

	public function new( bitmapShape:flash.display.BitmapData, mask:UInt=0xFFFFFFFF, color:UInt ){
		particles = new Array();
		var rect = bitmapShape.getColorBoundsRect(mask, color, true);
		var surface = (rect.width * rect.height);
		var nparticles = maxParticles*surface / maxSize;
		nparticles = Math.min(maxParticles, nparticles);
		var step = Math.round(Math.sqrt(surface/nparticles));
		for (i in 0...Math.ceil(rect.width/step)){
			for (j in 0...Math.ceil(rect.height/step)){
				var x = Math.round(rect.x + step*i);
				var y = Math.round(rect.y + step*j);
				var c : UInt = bitmapShape.getPixel32(x,y) & mask;
				if (c == color)
					particles.push(
						new CutParticle(
							x + random(-3,3),
							y - random(2,4),
							random(-0.3, 0.3),
							random(-1,  -0.5),
							random(-Math.PI/80, Math.PI/80),
							0.3 + Math.random(),
							0.3 + Math.random()
						)
					);
			}
		}
	}

	public function update() : Bool {
		var complete = true;
		for (p in particles)
			if (p.alive){
				complete = false;
				p.update();
			}
		return complete;
	}

	public function render( b:flash.display.BitmapData ){
		for (p in particles)
			if (p.alive){
				var shape = MyGrass.wildGrass[Std.random(MyGrass.wildGrass.length)];
				b.draw(shape, p.matrix);
			}
	}
}
