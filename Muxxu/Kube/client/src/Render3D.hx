import mt.m3d.T;

class Shader extends format.hxsl.Shader {
	public static inline var STRIDE = 6;
	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			shade : Float,
		};
		var fog : Float;
		var tuv : Float2;
		var tshade : Float;
		
		function vertex( mproj : Matrix ) {
			var tpos = pos.xyzw * mproj;
			out = tpos;
			fog = 1 - (tpos.z - 10) / 100;
			tuv = uv;
			tshade = shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest);
			tmp.a *= fog;
			tmp.rgb = tmp.rgb * tshade;
			out = tmp;
		}
	}
}

class FogShader extends format.hxsl.Shader {
	static var SRC = {
		var input : {
			pos : Float2
		};
		var h : Float;
		function vertex( dy : Float ) {
			h = (1 - pos.y * 0.5 - dy).sat();
			out = [pos.x * 2 - 1, pos.y * 2 - 1, 0, 1];
		}
		function fragment( col : Color, col2 : Color ) {
			out = if( h < 0.4 ) col2 * (1 - h * 2.5) + col * h * 2.5 else col * (1 - (h - 0.4) * 1.667) + [1, 1, 1, 1] * ((h - 0.4) * 1.667);
		}
	}
}

class FadeShader extends format.hxsl.Shader {
	static var SRC = {
		var input : {
			pos : Float2
		};
		function vertex() {
			out = [pos.x * 2 - 1, pos.y * 2 - 1, 0, 1];
		}
		function fragment( color : Color ) {
			out = color;
		}
	}
}

class SelectShader extends format.hxsl.Shader {
	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
		};
		var tuv : Float2;
		function vertex( mpos : Float4, tex : Float3, mproj : Matrix ) {
			out = (pos.xyzw + mpos) * mproj;
			var ruv = uv;
			ruv.x = if( tex.z < 0 ) 1 - ruv.x else ruv.x;
			tuv = (ruv + tex.xy) / 16;
		}
		function fragment( tex : Texture ) {
			out = tex.get(tuv, nearest) * 1.2;
		}
	};
}

class Buffer {
	static inline var E = 1.0;
	static inline var TE = 0.999;
	public var v : VirtualBuffer;
	public var pos : Int;
	
	var m : VirtualBuffer.Manager;
	var x : Float;
	var y : Float;
	var z : Float;
	var t : Int;
	var shade : Float;

	public function new( m : VirtualBuffer.Manager ) {
		this.m = m;
		v = m.alloc(65536 * Shader.STRIDE * 4);
		pos = 0;
	}
	public inline function init(x, y, z) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	public inline function tex( t : Level.Texture, shade : Float ) {
		this.t = t.index;
		this.shade = shade;
	}
	public inline function addSide(dx, dy, dz, tu, tv) {
		var tu = ((t & 15) + tu * TE) * 0.0625; // div 16
		var tv = ((t >> 4) + tv * TE) * 0.0625;
		v.setFloat(pos++, x + dx * E);
		v.setFloat(pos++, y + dy * E);
		v.setFloat(pos++, z + dz * E);
		v.setFloat(pos++, tu);
		v.setFloat(pos++, tv);
		v.setFloat(pos++, shade);
	}
	
	public function alloc( ctx : Context, indices : flash.utils.ByteArray, ?pos=0 ) {
		var nvect = Std.int(this.pos / Shader.STRIDE);
		if( nvect == 0 ) return null;
		var vbuf = ctx.createVertexBuffer(nvect, Shader.STRIDE);
		vbuf.uploadFromByteArray(m.bytes, v.getPos(), 0, nvect);
		var ibuf = ctx.createIndexBuffer(nvect);
		ibuf.uploadFromByteArray(indices, pos, 0, nvect);
		return new DrawBuffer(vbuf, ibuf, nvect);
	}
}

class DrawBuffer {
	public var v : VBuf;
	public var i : IBuf;
	public var count : Int;
	public function new(v, i, n) {
		this.v = v;
		this.i = i;
		this.count = n;
	}
	public function dispose() {
		v.dispose();
		i.dispose();
		v = null;
		i = null;
	}
}

class Render3D {

	static inline var BUFBITS = 4;
	static inline var REV_MAX = 65400;
	
	var kube : Kube;
	var s3d : flash.display.Stage3D;
	var ctx : Context;
	var vbufs : Array<{ b : DrawBuffer, z : Float, trans : Array<DrawBuffer>, special : DrawBuffer }>;
	var camera : mt.m3d.Camera;
	var shader : Shader;
	var tex : flash.display3D.textures.Texture;
	var fog : { shader : FogShader, vbuf : VBuf, ibuf : IBuf };
	var fadeShader : FadeShader;
	var indices : flash.utils.ByteArray;
	var revIndices : flash.utils.ByteArray;
	var manager : VirtualBuffer.Manager;
	var blocks : VirtualBuffer;
	var btrans : VirtualBuffer;
	var tmpBuf : Buffer;
	var specBuf : Buffer;
	var select : mt.m3d.Cube;
	var selectShader : SelectShader;
	var texBmp : flash.display.BitmapData;
	var bufWidth : Int;
	var bufHeight : Int;
	public var triCount : Int;
	
	public function new(k,fov) {
		this.kube = k;
		var stage = flash.Lib.current.stage;
		indices = new flash.utils.ByteArray();
		for( i in 0...65536 ) {
			indices.writeByte(i & 0xFF);
			indices.writeByte(i >> 8);
		}
		revIndices = new flash.utils.ByteArray();
		for( i in 0...REV_MAX ) {
			var i2 = REV_MAX - 6 - Std.int(i / 6) * 6 + (i % 6);
			revIndices.writeByte(i2 & 0xFF);
			revIndices.writeByte(i2 >> 8);
		}
		manager = new VirtualBuffer.Manager();
		blocks = manager.alloc( 256 * 256 * 32 );
		btrans = manager.alloc( kube.level.blocks.length );
		tmpBuf = new Buffer(manager);
		specBuf = new Buffer(manager);
		manager.select();
		var pos = 0;
		for( b in kube.level.blocks ) {
			if( b == null ) {
				btrans.setByte(pos++, 1);
				continue;
			}
			if( b.isSpecial || (b.parent != null && b.parent.isSpecial) )
				btrans.setByte(pos, 2);
			else if( b.tlr.isTransparent || b.tu.isTransparent || b.td.isTransparent )
				btrans.setByte(pos, 1);
			pos++;
		}
		camera = new mt.m3d.Camera(fov, 1.);
		camera.zFar = 256;
		s3d = stage.stage3Ds[0];
		s3d.addEventListener(flash.events.Event.CONTEXT3D_CREATE, function(_) onCreate());
		s3d.requestContext3D();
	}
	
	public function driverName() {
		return ctx.driverInfo.split(" ")[0];
	}
	
	public function setFullScreen(full) {
		var aa = 0;
		s3d.x = kube.bmpFull.x;
		s3d.y = kube.bmpFull.y;
		var width = kube.width, height = kube.height;
		if( full ) {
			var stage = flash.Lib.current.stage;
			width = Std.int(stage.stageWidth - kube.bmpFull.x - 10);
			height = Std.int(stage.stageHeight - kube.bmpFull.y - 10);
		}
		camera.ratio = width / height;
		bufWidth = width;
		bufHeight = height;
		try {
			ctx.configureBackBuffer(width, height, aa);
		} catch( e : Dynamic ) {
		}
	}
	
	function onCreate() {
		ctx = s3d.context3D;
		ctx.enableErrorChecking = true;
		setFullScreen(kube.fullScreen);
		shader = new Shader(ctx);
		vbufs = [];
		initKubes();
		initTexture();
		initFog();
		select = new mt.m3d.Cube();
		var e = 0;
		select.scale(1 + e * 2);
		select.translate( -e, -e, -e );
		select.addTCoords();
		select.alloc(ctx);
		selectShader = new SelectShader(ctx);
		fadeShader = new FadeShader(ctx);
		if( StringTools.startsWith(ctx.driverInfo, "Software") )
			kube.interf.warning(kube.texts.software_mode);
	}
	
	function initTexture() {
		tex = ctx.createTexture(256, 256, TextureFormat.BGRA, false);
		texBmp = new flash.display.BitmapData(256, 256, true, 0);
		function argb(a, r, g, b) return (a << 24) | (r << 16) | (g << 8) | b;
		for( t in kube.level.allTextures ) {
			var color : Null<Int> = null;
			if( t.block != null )
			switch( t.block.k ) {
			case BInvisible: color = 0;
			case BAmethyste: color = argb(0x20,100,40,125);
			case BEmeraude: color = argb(0x20,10,150,70);
			case BRubis: color = argb(0x20,110,5,40);
			case BSaphir: color = argb(0x40,0,56,214);
			case BShade: color = 0x80000000;
			case BLight: color = 0x20FFFFFF;
			case BFog: color = 0x80FFFFFF;
			default:
			}
			if( color == null )
				texBmp.copyPixels(t.bmp, t.bmp.rect, new flash.geom.Point((t.index % 16) * 16, Std.int(t.index / 16) * 16), t.bmp);
			else
				texBmp.fillRect(new flash.geom.Rectangle((t.index % 16) * 16, Std.int(t.index / 16) * 16, 16, 16), color);
		}
		tex.uploadFromBitmapData(texBmp);
	}
	
	public function updateTextures() {
		if( tex == null ) return;
		for( t in kube.level.allTextures ) {
			if( t.speed == 0 ) continue;
			var bytes = kube.bytes;
			bytes.position = t.address;
			texBmp.setPixels( new flash.geom.Rectangle((t.index % 16) * 16, Std.int(t.index / 16) * 16,16,16), bytes);
		}
		tex.uploadFromBitmapData(texBmp);
	}
		
	function initFog() {
		fog = {
			shader : new FogShader(ctx),
			vbuf : ctx.createVertexBuffer(4, 2),
			ibuf : ctx.createIndexBuffer(6),
		};
		var a : Array<UInt> = [0, 3, 1, 0, 2, 3];
		fog.vbuf.uploadFromVector(flash.Vector.ofArray([0., 0., 1., 0., 0., 1., 1., 1.]), 0, 4);
		fog.ibuf.uploadFromVector(flash.Vector.ofArray(a), 0, 6);
	}
		
	inline function addTri( v : Buffer, sx, sy, sz, dx1, dy1, dz1, dx2, dy2, dz2, tu, tv, tu1, tv1, tu2, tv2, side ) {
		v.addSide(sx, sy, sz, tu, tv);
		if( side ) {
			v.addSide(sx + dx1, sy + dy1, sz + dz1, tu1, tv1);
			v.addSide(sx + dx2, sy + dy2, sz + dz2, tu2, tv2);
		} else {
			v.addSide(sx + dx2, sy + dy2, sz + dz2, tu2, tv2);
			v.addSide(sx + dx1, sy + dy1, sz + dz1, tu1, tv1);
		}
	}
	
	inline function addQuad( v : Buffer, sx, sy, sz, dx, dy, dz, side : Bool ) {
		if( dx == 0 ) {
			addTri(v, sx, sy, sz, 0, dy, dz, 0, 0, dz, 0, 0, 1, 1, 0, 1, side);
			addTri(v, sx, sy, sz, 0, dy, 0, 0, dy, dz, 0, 0, 1, 0, 1, 1, side);
		} else if( dy == 0 ) {
			addTri(v, sx, sy, sz, 0, 0, dz, dx, 0, dz, 0, 0, 0, 1, 1, 1, side);
			addTri(v, sx, sy, sz, dx, 0, dz, dx, 0, 0, 0, 0, 1, 1, 1, 0, side);
		} else {
			addTri(v, sx, sy, sz, dx, 0, 0, dx, dy, 0, 0, 0, 1, 0, 1, 1, side);
			addTri(v, sx, sy, sz, dx, dy, 0, 0, dy, 0, 0, 0, 1, 1, 0, 1, side);
		}
	}
	
	inline function isTransparent( b : Int ) {
		return b == 0 || btrans.getByte(b) != 0;
	}

	inline function isTransparent2( b : Int ) {
		return b == 0 || btrans.getByte(b) == 1;
	}
	
	function rebuildBuffer( bx : Int, by : Int ) {
		var buf = tmpBuf;
		var blocks = blocks;
		var btrans = btrans;
		var hasTrans = false;
		buf.pos = 0;
		for( cx in 0...1 << BUFBITS )
			for( cy in 0...1 << BUFBITS )
				for( z in 0...Level.ZSIZE ) {
					var x = cx + (bx << BUFBITS);
					var y = cy + (by << BUFBITS);
					var p = kube.level.addr(x, y, z);
					var b = blocks.getByte(p);
					if( b == 0 ) continue;
					if( btrans.getByte(b) != 0 ) {
						hasTrans = true;
						continue;
					}
					var block = kube.level.blocks[b];
					// z-bottom
					buf.init(x, y, z);
					if( z > 0 && isTransparent(blocks.getByte(p - (1 << Level.Z))) ) {
						buf.tex(block.td, block.fshadeDown);
						addQuad(buf, 0, 0, 0, 1, 1, 0, false);
					}
					// z-top
					if( z == Level.ZSIZE - 1 || isTransparent(blocks.getByte(p + (1 << Level.Z))) ) {
						buf.tex(block.tu, block.fshadeUp);
						addQuad(buf, 0, 0, 1, 1, 1, 0, true);
					}
					// left
					if( x > 0 && isTransparent(blocks.getByte(p - (1 << Level.X))) ) {
						buf.tex(block.tlr, block.fshadeX);
						addQuad(buf, 0, 0, 0, 0, 1, 1, false);
					}
					// up
					if( y > 0 && isTransparent(blocks.getByte(p - (1 << Level.Y))) ) {
						buf.tex(block.tlr, block.fshadeY);
						addQuad(buf, 0, 0, 0, 1, 0, 1, false);
					}
					// right
					if( x < Level.XYSIZE-1 && isTransparent(blocks.getByte(p + (1 << Level.X))) ) {
						buf.tex(block.tlr, block.fshadeX);
						addQuad(buf, 1, 0, 0, 0, 1, 1, true);
					}
					// down
					if( y < Level.XYSIZE-1 && isTransparent(blocks.getByte(p + (1 << Level.Y))) ) {
						buf.tex(block.tlr, block.fshadeY);
						addQuad(buf, 0, 1, 0, 1, 0, 1, true);
					}
				}
				
		var pos = by + bx * (Level.XYSIZE >> BUFBITS);
		var old = vbufs[pos];
		if( old != null ) {
			old.b.dispose();
			if( old.special != null )
				old.special.dispose();
			for( t in old.trans ) {
				if( t == null ) continue;
				t.dispose();
			}
		}
		
		var trans = [];
		vbufs[pos] = { b : buf.alloc(ctx,indices), trans : trans, special : null, z : 0. };
		
		if( !hasTrans )
			return;
		
		specBuf.pos = 0;
		for( face in 0...6 ) {
			buf.pos = 0;
			for( cx in 0...1 << BUFBITS )
				for( cy in 0...1 << BUFBITS )
					for( z in 0...Level.ZSIZE ) {
						var x = cx + (bx << BUFBITS);
						var y = cy + (by << BUFBITS);
						var p = kube.level.addr(x, y, z);
						var b = blocks.getByte(p);
						if( b == 0 || btrans.getByte(b) == 0 ) continue;
						var block = kube.level.blocks[b];
						var buf = block.isSpecial ? specBuf : buf;
						buf.init(x, y, z);
						switch( face ) {
						case 0:
							// z-bottom
							if( z > 0 && isTransparent2(blocks.getByte(p - (1 << Level.Z))) ) {
								buf.tex(block.td, block.fshadeDown);
								addQuad(buf, 0, 0, 0, 1, 1, 0, false);
							}
						case 1:
							// z-top
							if( z == Level.ZSIZE - 1 || isTransparent2(blocks.getByte(p + (1 << Level.Z))) ) {
								buf.tex(block.tu, block.fshadeUp);
								addQuad(buf, 0, 0, 1, 1, 1, 0, true);
							}
						case 2:
							// left
							if( x > 0 && isTransparent2(blocks.getByte(p - (1 << Level.X))) ) {
								buf.tex(block.tlr, block.fshadeX);
								addQuad(buf, 0, 0, 0, 0, 1, 1, false);
							}
						case 3:
							// right
							if( x < Level.XYSIZE-1 && isTransparent2(blocks.getByte(p + (1 << Level.X))) ) {
								buf.tex(block.tlr, block.fshadeX);
								addQuad(buf, 1, 0, 0, 0, 1, 1, true);
							}
						case 4:
							// up
							if( y > 0 && isTransparent2(blocks.getByte(p - (1 << Level.Y))) ) {
								buf.tex(block.tlr, block.fshadeY);
								addQuad(buf, 0, 0, 0, 1, 0, 1, false);
							}
						case 5:
							// down
							if( y < Level.XYSIZE-1 && isTransparent2(blocks.getByte(p + (1 << Level.Y))) ) {
								buf.tex(block.tlr, block.fshadeY);
								addQuad(buf, 0, 1, 0, 1, 0, 1, true);
							}
						}
					}
			if( face & 1 == 0 )
				trans[face] = buf.alloc(ctx, revIndices, (REV_MAX - Std.int(buf.pos / Shader.STRIDE)) * 2 );
			else
				trans[face] = buf.alloc(ctx, indices);
		}
		vbufs[pos].special = specBuf.alloc(ctx, indices);
	}
	
	public function initKubes() {
		if( ctx == null || kube.level.t == null ) return;
		var t0 = flash.Lib.getTimer();
		manager.copy(kube.bytes, kube.levelPosition, blocks, Level.XYSIZE * Level.XYSIZE * Level.ZSIZE);
		manager.select();
		for( dx in 0...Level.XYSIZE >> BUFBITS )
			for( dy in 0...Level.XYSIZE >> BUFBITS )
				rebuildBuffer(dx, dy);
		//trace(flash.Lib.getTimer() - t0);
		flash.Memory.select(kube.bytes);
	}
	
	public function updateKube(x, y, z) {
		if( ctx == null )
			return;
		var t0 = flash.Lib.getTimer();

		var max = 1 << BUFBITS;
		var px = x >> BUFBITS;
		var py = y >> BUFBITS;
		var rx = x % max;
		var ry = y % max;
		manager.select();
		manager.copy(kube.bytes, kube.levelPosition, blocks, Level.XYSIZE * Level.XYSIZE * Level.ZSIZE);
		rebuildBuffer(px, py);
		if( px > 0 && rx == 0 )
			rebuildBuffer(px - 1, py);
		if( py > 0 && ry == 0 )
			rebuildBuffer(px, py - 1);
		if( px < Level.XYSIZE >> BUFBITS - 1 && rx == max - 1 )
			rebuildBuffer(px + 1, py);
		if( py < Level.XYSIZE >> BUFBITS - 1 && ry == max - 1 )
			rebuildBuffer(px, py + 1);
			
		flash.Memory.select(kube.bytes);
		//trace(flash.Lib.getTimer() - t0);
	}
	
	public function pick( fpx : Float, fpy : Float, fpz : Float, empty : Bool ) {
		var mx = ((flash.Lib.current.stage.mouseX - s3d.x) / bufWidth) * 2 - 1;
		var my = ((flash.Lib.current.stage.mouseY - s3d.y) / bufHeight) * 2 - 1;
		var rdir = new flash.geom.Vector3D(mx, -my, camera.zNear);
		var m = camera.mproj.toMatrix();
		m.invert();
		rdir = m.transformVector(rdir);
		m = camera.mcam.toMatrix();
		m.invert();
		rdir = m.transformVector(rdir);
		rdir.x -= fpx;
		rdir.y -= fpy;
		rdir.z -= fpz;
		rdir.normalize();

		var dx = rdir.x * 0.1;
		var dy = rdir.y * 0.1;
		var dz = rdir.z * 0.1;
		
		
		var ox = -1, oy = -1, oz = -1;
		while( true ) {
			var x = Std.int(fpx);
			var y = Std.int(fpy);
			var z = Std.int(fpz);
			if( kube.level.outside(x,y,z) )
				break;
			var b = flash.Memory.getByte(kube.levelPosition + kube.level.addr(x,y,z));
			if( b > 0 ) {
				if( empty ) {
					if( ox == -1 ) break;
					return { x : ox, y : oy, z : oz, b : null };
				}
				return { x : x, y : y, z : z, b : kube.level.blocks[b] };
			}
			ox = x;
			oy = y;
			oz = z;
			fpx += dx;
			fpy += dy;
			fpz += dz;
		}
		return null;
	}
	
	function draw( shader : format.hxsl.Shader, b : DrawBuffer ) {
		shader.bind(b.v);
		ctx.drawTriangles(b.i);
		triCount += Std.int(b.count / 3);
	}
	
	public function render(px:Float,py:Float,pz:Float,angle:Float,dz:Float) {
		if( ctx == null ) return;
		
		triCount = 0;
		
		try {
			ctx.clear(0,0,0,0);
		} catch( e : Dynamic ) {
			// disposed
			ctx = null;
			return;
		}
		ctx.setDepthTest( true, Compare.LESS_EQUAL );
		ctx.setCulling( Face.BACK );
		
		camera.pos.set(px, py, pz);
		camera.target.set(px + Math.cos(angle), py + Math.sin(angle), pz + dz);
		camera.update();

		var project = camera.m.toMatrix();
		
		var bufs = vbufs.copy();
		var pos = 0;
		var eye = new mt.m3d.Vector(px, py, 0);
		for( cx in 0...Level.XYSIZE >> BUFBITS )
			for( cy in 0...Level.XYSIZE >> BUFBITS ) {
				var b = bufs[pos++];
				var d0 = new mt.m3d.Vector(cx << BUFBITS, cy << BUFBITS, 0).sub(eye).length();
				var d1 = new mt.m3d.Vector((cx + 1) << BUFBITS, cy << BUFBITS, 0).sub(eye).length();
				var d2 = new mt.m3d.Vector(cx << BUFBITS, (cy + 1) << BUFBITS, 0).sub(eye).length();
				var d3 = new mt.m3d.Vector((cx + 1) << BUFBITS, (cy + 1) << BUFBITS, 0).sub(eye).length();
				var dmax = Math.max( Math.max(d0,d1), Math.max(d2,d3) );
				b.z = dmax;
			}
		bufs.sort(function(b1, b2) return Reflect.compare(b1.z, b2.z));

		shader.init( { mproj : project }, { tex : tex } );
		
		// write opaque data (front-to-back)
		ctx.setBlendFactors(Blend.ONE, Blend.ZERO);
		for( v in bufs )
			draw(shader, v.b);

		bufs.reverse();
		
		// write transparent pixels
		ctx.setBlendFactors(Blend.SOURCE_ALPHA, Blend.ONE_MINUS_SOURCE_ALPHA );
		ctx.setDepthTest( true, Compare.LESS_EQUAL );
		for( v in bufs ) {
			for( face in [2,3,4,5,0,1] ) {
				var t = v.trans[face];
				if( t == null ) continue;
				draw(shader, t);
			}
		}

		// write to z-buffer only
		ctx.setBlendFactors(Blend.ZERO, Blend.ONE );
		ctx.setDepthTest( true, Compare.LESS_EQUAL );
		for( v in bufs ) {
			if( v.special == null ) continue;
			draw(shader, v.special);
		}

		// only write pixels with same Z
		ctx.setBlendFactors(Blend.ONE, Blend.ONE_MINUS_SOURCE_ALPHA);
		ctx.setDepthTest( false, Compare.EQUAL );
		for( v in bufs ) {
			if( v.special == null ) continue;
			draw(shader, v.special);
		}
		
		
		shader.unbind();
		
		var sel = kube.select;
		if( sel != null ) {
			var b = sel.b == null ? kube.build : sel.b;
			var faces = [ { t : b.tlr, i : 1 }, { t : b.tlr, i : -1 }, { t : b.tu, i : 1 } , { t : b.tlr, i : 1 }, { t : b.tlr, i : -1 }, { t : b.td, i : 1 }  ];
			ctx.setDepthTest(false, sel.b == null ? Compare.LESS_EQUAL : Compare.EQUAL);
			ctx.setBlendFactors(Blend.SOURCE_ALPHA, Blend.ONE_MINUS_SOURCE_ALPHA);
			selectShader.bind(select.vbuf);
			var face = 0;
			for( f in faces ) {
				var t = f.t.index;
				selectShader.init( { mpos : new flash.geom.Vector3D(sel.x, sel.y, sel.z, 0), mproj : project, tex : new flash.geom.Vector3D(t%16,Std.int(t/16),f.i) }, { tex : tex } );
				ctx.drawTriangles(select.ibuf, face++ * 6, 2);
			}
			selectShader.unbind();
		}
		
		ctx.setDepthTest(false, Compare.ALWAYS);
		ctx.setBlendFactors(Blend.ONE_MINUS_DESTINATION_ALPHA, Blend.DESTINATION_ALPHA);
		fog.shader.init( { dy : kube.angleZ / (Math.PI / 2) }, { col : kube.bg.col | 0xFF000000, col2 : ((kube.bg.col>>>1) & 0x7F7F7F) | 0xFF000000 } );
		fog.shader.draw(fog.vbuf, fog.ibuf);

		var fadeFX = kube.fadeFX;
		if( fadeFX != null ) {
			var t = fadeFX.t;
			var r = (fadeFX.col >> 16) * t / 255.0;
			var g = ((fadeFX.col >> 8) & 0xFF) * t / 255.0;
			var b = (fadeFX.col & 0xFF) * t / 255.0;
			ctx.setBlendFactors(Blend.SOURCE_ALPHA, Blend.ONE_MINUS_SOURCE_ALPHA);
			fadeShader.init( {}, { color : fadeFX.col | (Std.int(t*128) << 24) } );
			fadeShader.draw(fog.vbuf, fog.ibuf);
		}

		ctx.present();
	}
	
}