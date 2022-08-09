import mt.m3d.T;
import Common;
import Shaders;
import Buffers;

class Render3D {
	
	var kube : Kube;
	var s3d : flash.display.Stage3D;
	var ctx : Context;
	
	public var builder : Builder;

	var shaders : {
		def : DefShader,
		water : WaterShader,
		alpha : AlphaShader,
		trans  : TransShader,
		dummy : DummyShader,
		fade : FadeShader,
		select : SelectShader,
	};
	
	var camera : mt.m3d.Camera;
	var tex : flash.display3D.textures.Texture;
	var fog : { shader : FogShader, vbuf : VBuf, ibuf : IBuf };
	
	var selectPrim : mt.m3d.Polygon;
	var texBmp : flash.display.BitmapData;
	var bufWidth : Int;
	var bufHeight : Int;
	
	var sky : CubeTexture;
	var skyBox : mt.m3d.Skybox;
	var skyPos : { px : Float, py : Float, m : flash.geom.Matrix3D };
	var camTangent : Float;
	var planetCurve : Float;

	var currentBuffer : VBuf;
	var currentDX : Int;
	var currentDY : Int;
	var project : flash.geom.Matrix3D;
	var camPosition : flash.geom.Vector3D;
	var constants : flash.Vector<Float>;
	var frame : Int;
	
	public var software : Bool;
	public var triCount : Int;
	public var bufCount : Int;
	public var drawCalls : Int;
	public var rebuiltTime : Int;
	public var rebuiltCount : Int;
	
	public function new(k) {
		this.kube = k;
		builder = new Builder(k);
		
		var stage = flash.Lib.current.stage;
		skyPos = { px : 0., py : 0., m : new flash.geom.Matrix3D() };
		
		camera = new mt.m3d.Camera(60, 1.);
		camera.zNear = 0.01;
		camera.zFar = 256;
		s3d = stage.stage3Ds[0];
		s3d.addEventListener(flash.events.Event.CONTEXT3D_CREATE, function(_) onCreate());
//		software = true;
		s3d.requestContext3D( software ? "software" : "auto" );
	}
	
	public function driverName() {
		return ctx.driverInfo.split(" ")[0];
	}
	
	public function setFullScreen(full) {
		var aa = 0;
		var width = kube.width, height = kube.height;
		if( full ) {
			var stage = flash.Lib.current.stage;
			width = stage.stageWidth;
			height = stage.stageHeight;
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
		software = ctx.driverInfo.toLowerCase().indexOf("software") != -1;
		if( software ) {
			kube.level.getBlock(BWater).type = BTFull;
			kube.animWater = null;
		}
		if( kube.animWater != null ) {
			var w = kube.animWater;
			var k = (w.width * kube.planetSize) % (Math.PI * 2);
			w.width -= k / kube.planetSize;
		}
		if( Kube.DATA == null )
			ctx.enableErrorChecking = true;
		setFullScreen(kube.fullScreen);
		shaders = {
			def : new DefShader(ctx),
			water : new WaterShader(ctx),
			alpha : new AlphaShader(ctx),
			trans : new TransShader(ctx),
			dummy : new DummyShader(ctx),
			fade : new FadeShader(ctx),
			select : new SelectShader(ctx),
		};
		builder.init(ctx);
		initTexture();
		initFog();
		initSky();
		initSelect();
		kube.needRedraw = true;
	}
	
	function initSelect() {
		var ind = new Array<UInt>();
		var pts = [];
		
		var pixel = Math.max(1 / bufWidth, 1 / bufHeight) * 2;
		var stride = 4;

		function vertex(v:mt.m3d.Vector,f) {
			pts.push(v.x);
			pts.push(v.y);
			pts.push(v.z);
			pts.push(f);
		}
		
		function add(x, y, z, x2, y2, z2) {
			var a = new mt.m3d.Vector(x, y, z);
			var b = new mt.m3d.Vector(x2, y2, z2);

			var p = Std.int(pts.length / stride);
			vertex(a, 0);
			vertex(b, 0);
			vertex(a, pixel);
			vertex(b, pixel);
			
			ind.push(p);
			ind.push(p + 1);
			ind.push(p + 3);

			ind.push(p);
			ind.push(p + 3);
			ind.push(p + 2);
		}
		add(0, 0, 0, 1, 0, 0);
		add(0, 0, 0, 0, 1, 0);
		add(0, 0, 0, 0, 0, 1);

		add(1, 0, 0, 1, 1, 0);
		add(1, 0, 0, 1, 0, 1);
				
		add(0, 1, 0, 1, 1, 0);
		add(0, 1, 0, 0, 1, 1);

		add(0, 0, 1, 1, 0, 1);
		add(0, 0, 1, 0, 1, 1);

		add(1, 1, 1, 0, 1, 1);
		add(1, 1, 1, 1, 0, 1);
		add(1, 1, 1, 1, 1, 0);
		
		var count = Std.int(pts.length / stride);
		selectPrim = new mt.m3d.Polygon([]);
		selectPrim.vbuf = ctx.createVertexBuffer(count,stride);
		selectPrim.vbuf.uploadFromVector(flash.Vector.ofArray(pts), 0,count);
		selectPrim.ibuf = ctx.createIndexBuffer(ind.length);
		selectPrim.ibuf.uploadFromVector(flash.Vector.ofArray(ind), 0, ind.length);
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
			case BAmethyste: color = argb(0x60,100,40,125);
			case BEmeraude: color = argb(0x60,10,150,70);
			case BRubis: color = argb(0x60,110,5,40);
			case BSaphir: color = argb(0x60,0,56,214);
			case BShade: color = 0x80000000;
			case BLight: color = 0x80FFFFFF;
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
	
	function initSky() {
		var size = 1024;
		skyBox = new mt.m3d.Skybox(ctx);
		sky = ctx.createCubeTexture(size, TextureFormat.BGRA, false);
		var skyBmp = new flash.display.BitmapData(size, size, true, 0);
		for( i in 0...(size * size) >> 7 ) {
			var x = Std.random(size);
			var y = Std.random(size);
			var k = Std.random(200) + 32;
			skyBmp.setPixel32(x, y, (k << 24) | 0xFFFFFF);
		}
			
		for( i in 0...6 ) {
			sky.uploadFromBitmapData(skyBmp, i, 0);
			var s = size >> 1;
			var mip = 1;
			while( s > 0 ) {
				var b = new flash.display.BitmapData(s, s, true, 0);
				b.draw(skyBmp, new flash.geom.Matrix(s / size, 0, 0, s / size));
				sky.uploadFromBitmapData(b, i, mip++);
				s >>= 1;
			}
		}
	}
	
	public function pick( mx : Int, my : Int, empty : Bool ) {
		
		var fpx = camPosition.x;
		var fpy = camPosition.y;
		var fpz = camPosition.z;
		
		var mx = (mx / bufWidth) * 2 - 1;
		var my = (my / bufHeight) * 2 - 1;
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
		var d = 0.;
		var dd = Math.sqrt(dx * dx + dy * dy);
		var c = kube.getPlanetCurve();
		
		var ox = -1, oy = -1, oz = -1;
		while( true ) {
			var x = Std.int(fpx);
			var y = Std.int(fpy);
			var z = Std.int(fpz + d*d*c);
			var rx = (x + kube.planetSize) % kube.planetSize;
			var ry = (y + kube.planetSize) % kube.planetSize;
			var rz = (z + kube.planetSize) % kube.planetSize;
			// check if we have made one full turn
			if( rz < 0 || (rz >= Const.ZSIZE * 2) || rx < 0 || ry < 0 || rz < 0 || rx >= kube.planetSize || ry >= kube.planetSize || rz >= kube.planetSize )
				break;
			if( rz < Const.ZSIZE && kube.level.has(rx, ry, rz) ) {
				var b = kube.level.blocks[Type.enumIndex(kube.level.get(rx, ry, rz)) + 1];
				switch( b.type ) {
				case BTWater, BTInvisible:
				default:
					if( empty ) {
						if( ox == -1 ) break;
						return { x : ox, y : oy, z : oz, b : null };
					}
					return { x : x, y : y, z : z, b : b };
				}
			}
			ox = x;
			oy = y;
			oz = z;
			fpx += dx;
			fpy += dy;
			fpz += dz;
			d += dd;
		}
		return null;
	}
	
	function draw( c : CellBuffer, type ) {
		var b = c.getBuffer(type);
		while( b != null ) {
			if( currentBuffer != b.b.v ) {
				currentBuffer = b.b.v;
				shaders.def.bind(b.b.v);
				bufCount++;
			}
			if( currentDX != c.viewX || currentDY != c.viewY ) {
				currentDX = c.viewX;
				currentDY = c.viewY;
				var m = project.clone();
				m.prependTranslation(currentDX, currentDY, 0);
				m.transpose();
				for( i in 0...16 )
					constants[i] = m.rawData[i];
				constants[16] = camPosition.x - c.viewX;
				constants[17] = camPosition.y - c.viewY;
				updateConstants();
			}
			var ntri = Std.int(b.nvect / 3);
			ctx.drawTriangles(builder.bmanager.ibuf, b.pos, ntri);
			drawCalls++;
			triCount += ntri;
			b = b.next;
		}
	}

	function pointClip( x:Float, y:Float, z : Float ) {
		var m = camera.mcam;
		
		z -= (x * x + y * y) * planetCurve;
		
		var cz = -(x * m._13 + y * m._23 + z * m._33);
		// behind the camera
		if( cz < 0 ) return 1;

		var cx = x * m._11 + y * m._21 + z * m._31;
		var aux = cz * camTangent;
		if( cx > aux )
			return 2;
		if( cx < -aux )
			return 3;
		return 0;
	}
	
	function sortCells( c1 : CellBuffer, c2 : CellBuffer ) {
		return c1.z - c2.z;
	}
	
	function updateConstants() {
		ctx.setProgramConstantsFromVector(flash.display3D.Context3DProgramType.VERTEX, 0, constants);
	}
	
	public function setPos(px:Float, py:Float, pz:Float, angle : Float, angleZ : Float ) {
		
		angleZ = Math.PI/2 - angleZ;
		
		camera.pos.set(px, py, pz);
		camera.target.set(px + Math.cos(angle) * Math.sin(angleZ), py + Math.sin(angle) * Math.sin(angleZ), pz + Math.cos(angleZ));
		camera.update();

		camTangent = Math.tan(camera.fov * 0.5 * Math.PI / 180);
		planetCurve = kube.getPlanetCurve();
		
		camPosition = new flash.geom.Vector3D(px, py, pz, planetCurve);
		project = camera.m.toMatrix();
	}
	
	public function render() {
		if( ctx == null ) return;
		
		var px = camPosition.x;
		var py = camPosition.y;
		var pz = camPosition.z;
		
		triCount = 0;
		bufCount = 0;
		drawCalls = 0;
		currentDX = 0;
		currentDY = 0;
		currentBuffer = null;
		
		try {
			ctx.clear(0,0,0,0);
		} catch( e : Dynamic ) {
			// disposed
			ctx = null;
			return;
		}

		var rx = ((px - skyPos.px) * Math.PI * 2 / kube.planetSize) % (Math.PI * 2);
		var ry = ((py - skyPos.py) * Math.PI * 2 / kube.planetSize) % (Math.PI * 2);
		var mtmp = new mt.m3d.Matrix();
		mtmp.initRotateY(-rx);
		skyPos.m.append(mtmp.toMatrix());
		mtmp.initRotateX(ry);
		skyPos.m.append(mtmp.toMatrix());
		skyPos.px = px;
		skyPos.py = py;
		
		skyBox.show(camera, sky, skyPos.m, new flash.geom.Vector3D(100,100,100,1));
		
		
		var todraw = new Array<CellBuffer>();
		var pos = 0;
		
		
		var half = 1 << (Builder.CELL - 1);
		var rayDist = Math.pow(half * Math.sqrt(2), 2);
		var psize = kube.planetSize;
		var viewSize = (psize < 256 ? psize : 256) >> (Builder.CELL + 1);
		var cpx = Std.int(px) >> Builder.CELL;
		var cpy = Std.int(py) >> Builder.CELL;
		
		frame++;
		
		for( dx in -viewSize+1...viewSize+1 )
			for( dy in -viewSize + 1...viewSize + 1 ) {
				var cx = (((cpx + dx) << Builder.CELL) + half) - px;
				var cy = (((cpy + dy) << Builder.CELL) + half) - py;
			
				var c = pointClip(cx - half, cy - half, -pz);
				
				if( c != 0 && c == pointClip(cx - half, cy + half, -pz) && c == pointClip(cx + half, cy - half, -pz) && c == pointClip(cx + half, cy + half, -pz) &&
					c == pointClip(cx - half, cy - half, Const.ZSIZE - pz) && c == pointClip(cx - half, cy + half, Const.ZSIZE - pz) && c == pointClip(cx + half, cy - half, Const.ZSIZE - pz) && c == pointClip(cx + half, cy + half, Const.ZSIZE - pz)
					)
					continue;

				var x = (cpx + dx + builder.cellStride) % builder.cellStride;
				var y = (cpy + dy + builder.cellStride) % builder.cellStride;
				var z = Std.int((cx * cx + cy * cy) * 1000);
				var c = builder.getCell(x, y);
				if( c.frame == frame && c.z < z ) continue;
				c.viewX = ((cpx + dx) - c.x) << Builder.CELL;
				c.viewY = ((cpy + dy) - c.y) << Builder.CELL;
				c.z = z;
				if( c.frame != frame ) {
					c.frame = frame;
					todraw.push(c);
				}
			}
		todraw.sort(sortCells);
		
		var t0 = flash.Lib.getTimer();
		var rebuilt = 0;
		for( c in todraw ) {
			if( !c.dirty ) continue;
			if( builder.rebuild(c) ) {
				rebuilt++;
				if( flash.Lib.getTimer() - t0 > 100 ) {
					kube.needRedraw = true;
					break;
				}
			}
		}
		if( rebuilt > 0 ) {
			rebuiltTime += flash.Lib.getTimer() - t0;
			rebuiltCount += rebuilt;
			builder.bmanager.finalize();
		}
		
		constants = shaders.def.getVertexConstants( { mproj : project, cam : camPosition } );
		updateConstants();
		ctx.setTextureAt(0, tex);
		ctx.setDepthTest( true, Compare.LESS_EQUAL );
		ctx.setCulling( Face.BACK );
		
		// write opaque data (front-to-back)
		shaders.def.select();
		ctx.setBlendFactors(Blend.ONE, Blend.ZERO);
		for( c in todraw )
			draw(c,BTFull);

		// write transparent pixels
		shaders.trans.select();
		for( c in todraw )
			draw(c,BTTransp);
					
		// dummies
		var drot = project.clone();
		drot.appendRotation(kube.time, new flash.geom.Vector3D(0, 0, 1));
		for( d in kube.dummies ) {
//			shaders.dummy.init( { mproj : drot, cam : camPosition, rpos : new flash.geom.Vector3D(d.x, d.y, d.z), ruv : new flash.geom.Vector3D(0, 0) } );
		}
			
		// start water
		var awater = kube.animWater;
		if( awater != null ) {
			var wscale = awater.width;
			var wspeed = kube.time * awater.speed;
			var water = new flash.geom.Vector3D(wspeed, wspeed, awater.scale * 0.5, wscale);
			constants = shaders.water.getVertexConstants( { mproj : project, cam : camPosition, water : water } );
			updateConstants();
			currentDX = 0;
			currentDY = 0;
			shaders.water.select();
		}

		// write to z-buffer only
		ctx.setBlendFactors(Blend.ZERO, Blend.ONE );
		ctx.setDepthTest( true, Compare.LESS_EQUAL );
		for( c in todraw )
			draw(c,BTWater);
		ctx.setDepthTest( false, Compare.EQUAL );

		// write water color
		ctx.setBlendFactors(Blend.SOURCE_ALPHA, Blend.ONE_MINUS_SOURCE_ALPHA);
		ctx.setColorMask(true, true, true, false);
		for( c in todraw )
			draw(c,BTWater);

		// write water alpha
		ctx.setBlendFactors(Blend.SOURCE_ALPHA, Blend.ZERO);
		ctx.setColorMask(false, false, false, true);
		for( c in todraw )
			draw(c,BTWater);
		ctx.setColorMask(true, true, true, true);

		// reset constants
		if( awater != null ) {
			constants = shaders.def.getVertexConstants( { mproj : project, cam : camPosition } );
			updateConstants();
			currentDX = 0;
			currentDY = 0;
		}
		
		// alpha
		ctx.setBlendFactors(Blend.ZERO, Blend.ONE );
		ctx.setDepthTest( true, Compare.LESS_EQUAL );
		shaders.alpha.select();
		for( c in todraw )
			draw(c, BTAlpha);
		ctx.setDepthTest( false, Compare.EQUAL );
		ctx.setBlendFactors(Blend.ONE, Blend.ONE_MINUS_SOURCE_ALPHA);
		for( c in todraw )
			draw(c, BTAlpha);
		
		shaders.def.unbind();
		
		var sel = kube.select;
		if( sel != null ) {
			var b = sel.b == null ? kube.build : sel.b;
			ctx.setDepthTest(false, Compare.LESS_EQUAL);
			ctx.setCulling( Face.NONE );
			shaders.select.init( { mpos : new flash.geom.Vector3D(sel.x, sel.y, sel.z, 0), mproj : project, cam : camPosition, scale : 1 + kube.selectPower * 30 } , {});
			shaders.select.draw(selectPrim.vbuf, selectPrim.ibuf);
			shaders.select.unbind();
			ctx.setCulling( Face.BACK );
		}
		
		ctx.setDepthTest(false, Compare.ALWAYS);
		ctx.setBlendFactors(Blend.ONE_MINUS_DESTINATION_ALPHA, Blend.DESTINATION_ALPHA);
		fog.shader.init( { dy : kube.hero.angleZ / (Math.PI / 2) }, { col : kube.bgColor | 0xFF000000, col2 : ((kube.bgColor>>>1) & 0x7F7F7F) | 0xFF000000 } );
		if( !software ) fog.shader.draw(fog.vbuf, fog.ibuf);
		fog.shader.unbind();

		var fadeFX = kube.fadeFX;
		if( fadeFX != null ) {
			var t = fadeFX.t;
			var r = (fadeFX.col >> 16) * t / 255.0;
			var g = ((fadeFX.col >> 8) & 0xFF) * t / 255.0;
			var b = (fadeFX.col & 0xFF) * t / 255.0;
			ctx.setDepthTest(false, Compare.ALWAYS);
			ctx.setBlendFactors(Blend.SOURCE_ALPHA, Blend.ONE_MINUS_SOURCE_ALPHA);
			shaders.fade.init( {}, { color : fadeFX.col | (Std.int(t*128) << 24) } );
			shaders.fade.draw(fog.vbuf, fog.ibuf);
			shaders.fade.unbind();
		}

		ctx.present();
	}
	
}