package r3d;

private class PShader extends h3d.Shader {
	static var SRC = {
		var input : {
			pos : Float3,
		};
		
		var uv : Float2;
		var tnorm : Float3;
		var cview : Float3;
		
		function vertex( mproj : M44, camPos : Float3, rot : Float2 ) {
			var t = (pos.y * 3.1416 + rot.y) % 3.1416;
			var p = (pos.x * 3.1416 + rot.x) % (3.1416 * 2);
			var st = t.sin();
			var h = 1 + pos.z * st;
			st *= h;
			var spos = [st * p.cos(), st * p.sin(), h * t.cos(), 1];
			out = spos * mproj;
			uv = pos.xy * [-1,1];
			tnorm = spos.xyz.normalize();
			cview = (camPos - spos.xyz).normalize();
		}
		
		function fragment( tex : Texture, tbump : Texture, tgrid : Texture, light : Float3, ambient : Float, bumpPower : Float, specularPower : Float, specularSize : Float, gridSize : Float ) {
			var t = [ -tnorm.y, tnorm.x, tnorm.z]; // tangent
			var nbump = (tbump.get(uv,wrap).xyz - 0.5).normalize() * bumpPower;
			var n = (tnorm + nbump.x * t - nbump.y * tnorm.cross(t)).normalize();
						
			var half = (light + cview).normalize();
			var spec = n.dot(half).sat().pow(specularSize);
			var diff = light.dot(n).sat();
			
			var light = ambient + (1 - ambient) * diff * (1 + spec * specularPower);
			out = tex.get(uv, wrap) * tgrid.get(uv * gridSize,wrap,mm_linear) * light;
		}
	};
}

class Planet extends h3d.Object {
	
	var size : Int;
	var map : flash.display.BitmapData;
	var hmap : flash.display.BitmapData;
	var bump : flash.display.BitmapData;
	
	public var shader(default,null) : PShader;
	
	var water : Int;
	var height : Float;
	
	public function new( engine, map : flash.display.BitmapData, hmap : flash.display.BitmapData, water : Int, gridSize = 0.5, height = 1., ?size ) {
		
		var light = new h3d.Vector(-3, 4, 5);
		light.normalize();
		light.scale3(1.2);

		shader = new PShader();
		shader.light = light;
		shader.ambient = 0.25;
		shader.bumpPower = 0.5;
		shader.specularSize = 10;
		shader.specularPower = 2.0;
		
		super(null, new h3d.mat.Material(shader));
		
		if( size == null ) size = hmap.width;
		if( size > 128 ) size = 128;
		
		if( size != hmap.width || size != hmap.height ) {
			var tmp = new flash.display.BitmapData(size, size);
			var m = new flash.geom.Matrix();
			m.scale(size / hmap.width, size / hmap.height);
			var stage = flash.Lib.current.stage;
			var old = stage.quality;
			stage.quality = flash.display.StageQuality.LOW;
			tmp.draw(hmap, m);
			stage.quality = old;
			hmap.dispose();
			hmap = tmp;
		}
		bump = new flash.display.BitmapData(size, size, true, 0);
		makeBump(hmap, bump, 1.3, water);
		
		var msize = map.width;
		map = resizeSquare(map);
		
		this.map = map;
		this.hmap = hmap;
		this.water = water;
		this.height = height;
		this.size = size;
		shader.gridSize = gridSize * msize;
		
		this.primitive = allocPrim(engine);
		initTextures(engine, gridSize == 0);
	}
	
	static inline function hget(w,x,y) {
		return flash.Memory.getByte(((x + y * w) << 2) + 1);
	}
	
	static function resizeSquare( src : flash.display.BitmapData ) {
		var size = 1;
		var max = src.width;
		if( src.height > max ) max = src.height;
		if( max < 512 ) max = 512;
		while( size < max )
			size <<= 1;
		if( size == src.width && size == src.height )
			return src;
		var nbmp = new flash.display.BitmapData(size, size, true, 0);
		var m = new flash.geom.Matrix();
		m.scale(size / src.width, size / src.height);
		nbmp.draw(src, m);
		src.dispose();
		return nbmp;
	}
	
	static function makeBump( src : flash.display.BitmapData, dst : flash.display.BitmapData, bump : Float, water : Int ) {
		var hbytes = src.getPixels(src.rect);
		var out = hbytes.length;
		hbytes.length += out;
		flash.Memory.select(hbytes);
				
		var width = src.width;
		var xmax = src.width - 1;
		var ymax = src.height - 1;
		
		for( y in 0...src.height ) {
			var yp = y == 0 ? ymax : y - 1;
			var yn = y == ymax ? 0 : y + 1;
			for( x in 0...width ) {
				var xp = x - 1; if( xp < 0 ) xp += width;
				var xn = x + 1; if( xn > xmax ) xn -= width;

				var h00 = hget(width, xp, yp);
				var h10 = hget(width, x, yp);
				var h20 = hget(width, xn, yp);

				var h01 = hget(width, xp, y);
				var h21 = hget(width, xn, y);

				var h02 = hget(width, xp, yn);
				var h12 = hget(width, x, yn);
				var h22 = hget(width, xn, yn);

				// sobel 3x3 operator
				var gx = h00 - h20 + 2. * h01 - 2. * h21 + h02 - h22;
				var gy = h00 + 2. * h10 + h20 - h02 - 2. * h12 - h22;
				var gz = gx * gx + gy * gy;
				if( gz > 1.0 ) gz = 1.0;
				var gz = Math.sqrt(1.0 - gz);
				gx *= bump;
				gy *= bump;
				
				// normalize
				var len = 1.0 / Math.sqrt(gx * gx + gy * gy + gz * gz);
				if( hget(width, x, y) == water ) len = 0;
				gx *= len;
				gy *= len;
				gz *= len;
				
				// store as bgra
				var r = Std.int((gx + 1.0) * 127.5);
				var g = Std.int((gy + 1.0) * 127.5);
				var b = Std.int((gz + 1.0) * 127.5);
				flash.Memory.setByte(out++, b);
				flash.Memory.setByte(out++, g);
				flash.Memory.setByte(out++, r);
				flash.Memory.setByte(out++, 0xFF);
			}
		}
		hbytes.position = src.width * src.height * 4;
		dst.setPixels(dst.rect, hbytes);
	}
	
	public override function dispose() {
		super.dispose();
		map.dispose();
		hmap.dispose();
		bump.dispose();
		shader.tex.dispose();
		shader.tbump.dispose();
		shader.tgrid.dispose();
		shader.dispose();
	}
	
	function allocPrim( engine : h3d.Engine ) {
		var pts = new flash.Vector<Float>();
		var indexes = new flash.Vector<UInt>();
		var p = 0, i = 0;
		var dx = 1, dy = size * 2 + 1;
		var hscale = height / 255;
		for( y in 0...size+1 )
			for( x in 0...size * 2 + 1 ) {
				pts[p++] = x / size;
				pts[p++] = y / size;
				pts[p++] = ((hmap.getPixel32((size-1) - (x % size), y % size) & 0xFF) - water) * hscale;
				if( y < size && x < size*2 ) {
					var p = x + y * dy;
					indexes[i++] = p;
					indexes[i++] = p + dy;
					indexes[i++] = p + dx;

					indexes[i++] = p + dx;
					indexes[i++] = p + dy;
					indexes[i++] = p + dx + dy;
				}
			}
		return new h3d.prim.RawPrimitive(engine, pts, 3, indexes);
	}
		
	function initTextures( engine : h3d.Engine, noGrid ) {
		shader.tex = engine.mem.allocTexture(map.width, map.height);
		shader.tex.upload(map);

		shader.tbump = engine.mem.allocTexture(size, size);
		shader.tbump.upload(bump);
		
		var gsize = 128;
		var galpha = 0.15;
		var color = Std.int((1 - galpha) * 255);
		color = color | (color << 8) | (color << 16) | 0xFF000000;
		var mip = 0;
		
		if( noGrid ) {
			color = 0xFFFFFFFF;
			gsize = 1;
		}
		shader.tgrid = engine.mem.allocTexture(gsize, gsize);
		while( gsize > 0 ) {
			var grid = new flash.display.BitmapData(gsize, gsize, true);
			for( x in 0...gsize ) {
				grid.setPixel32(x, 0, color);
				grid.setPixel32(0, x, color);
			}
			shader.tgrid.upload(grid,mip++);
			grid.dispose();
			gsize >>= 1;
		}
	}
	
	override function render( engine : h3d.Engine ) {
		shader.mproj = engine.camera.m;
		shader.camPos = engine.camera.pos;
		super.render(engine);
	}
	
}

