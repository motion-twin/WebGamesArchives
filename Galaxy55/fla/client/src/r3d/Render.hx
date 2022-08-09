package r3d;

import h3d.mat.Data;
import Common;
import r3d.Shaders;
import r3d.Buffers;
import r3d.AbstractGame.GameEffects;

class Render {
	
	static var BASE_FOV = 54.4;
	static var SHOW_OTHER_LAZER  = true;
	
	var game : AbstractGame;
	var engine : h3d.Engine;
	
	public var builder : Builder;

	var shaders : {
		def : DefShader,
		water0 : WaterShader0,
		water1 : WaterShader1,
		water2 : WaterShader2,
		alpha0 : AlphaShader0,
		alpha1 : AlphaShader1,
		alpha2 : AlphaShader2,
		trans  : TransShader,
		dummy : DummyShader,
		icon : IconShader,
		breaks : BreaksShader,
		model : ModelShader,
		sprite : SpriteShader,
		fogColor : FogColorShader,
	};
	var materials : Array<Array<h3d.mat.Material>>;
	var baseShaders : Array<BaseShader>;
	
	var tex : h3d.mat.Texture;
	var tfog : h3d.CustomObject<TexFogShader>;
	var fade : h3d.CustomObject<FadeShader>;
	var select : h3d.CustomObject<SelectShader>;
	var matDummy : h3d.mat.Material;
	
	var fogTexture : h3d.mat.Texture;
	var fogTScale : Float;
	var fogColorCache : String;
	
	var lazer : h3d.CustomObject<PolyTexShader>;
	var lazerTex : Array<h3d.mat.Texture>;
	var shipDock : h3d.CustomObject<PolyTexShader>;
	var lazerModel : h3d.CustomObject<ModelShader>;
	
	var skyBox : Skybox;
	var skyPos : { px : Float, py : Float, m : h3d.Matrix };
	var camTangent : Float;
	var planetCurve : Float;
	var curLight : Null<Float>;
	var blackWhite : h3d.mat.Texture;
	var baseFov : Float;
	
	var angle : Float;
	var angleZ : Float;
	
	var namesContainer : flash.display.Sprite;
	var userNames : IntHash<flash.text.TextField>;

	public var camPosition(default,null) : h3d.Vector;
	public var fogPower(default,null) : Float;
	
	var curShader : { base : BaseShader, value : BlockShader };
	var frame : Int;
	
	var heroBody : h3d.CustomObject<SharpModelShader>;
	var heroBase : h3d.CustomObject<SharpModelShader>;
	var entitiesTex : flash.utils.TypedDictionary< h3d.mat.PngBytes, h3d.mat.Texture >;
	var worldLazer : r3d.fx.Lazer; 
	public var parts : Particles;
	
	public var hud : Array<h3d.fx.Bitmap>;
	
	public var rebuiltTime : Int;
	public var rebuiltCount : Int;
	
	
	public var texCache : flash.utils.TypedDictionary< Class<h3d.mat.PngBytes>, h3d.mat.Texture >;
	public inline function getEngine() return engine
	
	public function new(g) {
		this.game = g;
		userNames = new IntHash();
		namesContainer = new flash.display.Sprite();
		g.render = this;
		texCache = new flash.utils.TypedDictionary();
		this.engine = g.engine;
		parts = new Particles(g);
		builder = new Builder(g);
		engine.camera.zoom = 1;
		engine.camera.zNear = 0.1;
		engine.camera.zFar = 256;
		hud = [];
		entitiesTex = new flash.utils.TypedDictionary();
		resize(engine.width, engine.height);
	}
	
	
	
	public function init() {
		if( !engine.hardware ) {
			var colors = gen.Map.getColors(Data.TEXTURE);
			for( b in Block.all )
				if( b.type == BTWater || (b.type == BTTransp && !b.hasFlag(BFNoOptimize)) ) {
					var tex = Data.TEXTURE;
					var col = ((colors[b.index]>>1) & 0x7F7F7F)  | 0xFF000000;
					for( t in [b.tu, b.td, b.tlr] ) {
						var tx = (t & 63) << 5;
						var ty = (t >> 6) << 5;
						for( x in 0...32 )
							for( y in 0...32 )
								if( tex.getPixel32(x + tx, y + ty)>>>24 == 0 )
									tex.setPixel32(x + tx, y + ty, col);
					}
				}
			game.planet.animWater = null;
		}
		var lastTex = 4095;
		for( b in Block.all )
			for( f in b.flags )
				switch( f ) {
				case BFAlpha(alpha):
					var tex = Data.TEXTURE;
					for( t in [b.tu, b.td, b.tlr] ) {
						var tx = (t & 63) << 5;
						var ty = (t >> 6) << 5;
						for( x in 0...32 )
							for( y in 0...32 ) {
								var c = tex.getPixel32(x + tx, y + ty);
								var a = Std.int((c >>> 24) * alpha);
								if( a < 0 ) a = 0 else if( a > 255 ) a = 255;
								tex.setPixel32(x + tx, y + ty, (c & 0xFFFFFF) | (a << 24));
							}
					}
				case BFColor(color,_):
					var tex = Data.TEXTURE;
					var use = false;
					if( b.tlr == 0xFFF ) { b.tlr = lastTex; use = true; }
					if( b.tu == 0xFFF ) { b.tu = lastTex; use = true; }
					if( b.td == 0xFFF ) { b.td = lastTex; use = true; }
					if( use ) {
						var tu = lastTex & 63;
						var tv = lastTex >> 6;
						tex.fillRect(new flash.geom.Rectangle(tu * 32, tv * 32, 32, 32), 0xFF000000 | color);
						lastTex--;
					}
				default:
				}
	
		if( game.planet.animWater != null ) {
			var w = game.planet.animWater;
			var k = (w.width * game.planet.totalSize) % (Math.PI * 2);
			w.width -= k / game.planet.totalSize;
		}
		
		shaders = {
			def : new DefShader(),
			water0 : new WaterShader0(),
			water1 : new WaterShader1(),
			water2 : new WaterShader2(),
			alpha0 : new AlphaShader0(),
			alpha1 : new AlphaShader1(),
			alpha2 : new AlphaShader2(),
			trans : new TransShader(),
			dummy : new DummyShader(),
			icon : new IconShader(),
			breaks : new BreaksShader(),
			model : new ModelShader(),
			sprite : new SpriteShader(),
			fogColor : new FogColorShader(),
		};
		baseShaders = [
			shaders.def,
			shaders.water0,
			shaders.water1,
			shaders.water2,
			shaders.alpha0,
			shaders.alpha1,
			shaders.alpha2,
			shaders.trans,
			shaders.sprite,
			shaders.fogColor,
		];
		
		materials = [];
		materials[Type.enumIndex(BTFull)] = [new h3d.mat.Material(shaders.def)];
		materials[Type.enumIndex(BTTransp)] = [new h3d.mat.Material(shaders.trans)];
		materials[Type.enumIndex(BTWater)] = {
			var m0 = new h3d.mat.Material(shaders.water0);
			m0.blend(Zero, DstAlpha);
			m0.setColorMask(true, true, true, false);
			var m1 = new h3d.mat.Material(shaders.water1);
			m1.blend(One, OneMinusSrcAlpha);
			m1.depth(false,Equal);
			m1.setColorMask(true, true, true, false);
			var m2 = new h3d.mat.Material(shaders.water2);
			m2.blend(One,Zero);
			m2.depth(false,Equal);
			m2.setColorMask(false, false, false, true);
			[m0,m1,m2];
		}
		
		if( !engine.hardware )
			materials[Type.enumIndex(BTWater)] = [new h3d.mat.Material(shaders.def)];
		
		materials[Type.enumIndex(BTAlpha)] = {
			var m0 = new h3d.mat.Material(shaders.fogColor);
			m0.blend(OneMinusDstAlpha, DstAlpha);
			m0.setColorMask(true, true, true, false);
			var m1 = new h3d.mat.Material(shaders.alpha1);
			m1.blend(One, OneMinusSrcAlpha);
			m1.setColorMask(true, true, true, false);
			var m2 = new h3d.mat.Material(shaders.alpha2);
			m2.blend(One, Zero);
			m2.setColorMask(false, false, false, true);
			// software have some issues with this mode
			if( engine.hardware ) {
				m1.depth(false, Equal);
				m2.depth(false, Equal);
				[m0, m1, m2];
			} else {
				// there is currently a bug in software mode that seems to affect m0
				// this will cause a dark BG + fog removal through alpha blocks
				m1.depth(false, LessEqual);
				m2.depth(false, LessEqual);
				[m0, m1, m2];
			}
		}
		materials[Type.enumIndex(BTModel2Side)] = [ {
			var m = new h3d.mat.Material(shaders.trans);
			m.culling = Face.None;
			m;
		}];
		
		materials[Type.enumIndex(BTSprite)] = [new h3d.mat.Material(shaders.sprite)];
		
		matDummy = new h3d.mat.Material(shaders.dummy);
		matDummy.culling = Face.None; // for 2x sides models
		matDummy.blend(Blend.SrcAlpha, Blend.OneMinusSrcAlpha);

		builder.init();
		initTextures();
		initFog();
		initFade();
		initSelect();
		initLazer();
		worldLazer = new r3d.fx.Lazer(this);
		initShipDock();
		initShip();
		initHero();
		
		parts.init(tex);
		
		
	}
	
	function initHero() {
		
		var mshader = new SharpModelShader();
		
		var pcyl = new h3d.prim.Cylinder(16,0.4,1.3);
		pcyl.addTCoords();
		pcyl.addNormals();
		for( p in pcyl.getPoints() )
			if( p.z > 0 ) {
				p.x *= 0.002;
				p.y *= 0.002;
			}
		
		heroBody = new h3d.CustomObject(pcyl, mshader);
		
		var base = new h3d.prim.Cube(0.8, 0.8, 0.1);
		base.translate( -0.4, -0.4, 0);
		base.addTCoords();
		base.addNormals();
		heroBase = new h3d.CustomObject(base, mshader);
		
		game.needRedraw();
	}
	
	
	
	public function dispose() {
		// actually nothing right now (assume all hardware dispose are done on Context3D.dispose)
	}
	
	public function resize( width : Int, height : Int ) {
		for( h in hud )
			if( h != null ) {
				h.scaleX = width / (h.bmp.width-50);
				h.scaleY = height / (h.bmp.height - 400);
			}
		baseFov = Math.atan( (width / height) * Math.tan(BASE_FOV * Math.PI / 180)) * 180 / Math.PI;
		engine.camera.fov = baseFov;
	}
	
	function initShip() {
		var extra = game.level.extra;
		if( extra == null || extra.t == null )
			return;
		var shipLevel = new Level(game.level.size);
		shipLevel.cells[0][0] = extra;
		builder.extra = new Builder.BuilderLevel(shipLevel);
		builder.extra.posX = extra.posX;
		builder.extra.posY = extra.posY;
		builder.extra.posZ = extra.posZ;
		for( c in builder.extra.cells )
			c.dirty = true;
	}

	public function initHud( h : h3d.mat.PngBytes, index : Int ) {
		var hbmp = h.getBitmapBytes();
		var hud = engine.hardware ? new h3d.fx.Bitmap(hbmp) : new h3d.fx.SoftBitmap(hbmp, game.softHudContext);
		this.hud[index] = hud;
		return hud;
	}
	
	
	function initLazer() {
		var pts = [], uvs = [];
		var angles = 4;
		
		var a = new h3d.prim.UV(0, 1);
		var b = new h3d.prim.UV(0, 0);
		var c = new h3d.prim.UV(1, 1);
		var d = new h3d.prim.UV(1, 0);
	
		for( r in 0...angles ) {
			var ang = r * Math.PI / angles;
			var x = Math.cos(ang);
			var y = Math.sin(ang);
			var x2 = Math.cos(ang + Math.PI);
			var y2 = Math.sin(ang + Math.PI);
			pts.push(new h3d.Point(0, x, y));
			pts.push(new h3d.Point(0, x2, y2));
			pts.push(new h3d.Point(1, x, y));
			pts.push(new h3d.Point(1, x2, y2));
			
			uvs.push(a);
			uvs.push(b);
			uvs.push(c);
			uvs.push(d);
		}
		var q = new h3d.prim.Quads(pts,uvs);
		lazer = new h3d.CustomObject(q, new PolyTexShader());
		lazer.material.blend(SrcAlpha, One);
		lazer.material.culling = Face.None;
		lazer.material.depthWrite = false;
		
		var a = 0.3;
		var a = 1;
		lazerTex = [];
		lazer.shader.color = new h3d.Vector(a,a,a,a);
		lazer.shader.zScale = 0;
		
		//lazerModel = new h3d.CustomObject(new LazerData().getModel(), new ModelShader());
	}
	
	
	
	
	function initShipDock() {
		var segs = 6;
		var c = new h3d.prim.Cylinder(segs, 0.48, 1);
		c.addTCoords();
		shipDock = new h3d.CustomObject(c, new PolyTexShader());
		shipDock.material.blend(SrcAlpha, One);
		shipDock.material.culling = Face.None;
		shipDock.material.depthWrite = false;
		shipDock.shader.uvScale = new h3d.Vector(segs / 3, 1);
		var a = 0.5;
		shipDock.shader.color = new h3d.Vector(a,a,a,a);
	}
	
	function initTextures() {
		tex = engine.mem.allocTexture(2048, 2048);
		tex.uploadMipMap(Data.TEXTURE, true);
		
		var bmp = new flash.display.BitmapData(2, 2, false, 0);
		bmp.setPixel32(0, 0, 0xFFFFFFFF);
		blackWhite = engine.mem.makeTexture(bmp);
		bmp.dispose();
	}
	
	function initSelect() {
		var ind = new flash.Vector<UInt>();
		var pts = new flash.Vector<Float>();
		
		var stride = 4;
		var stage = flash.Lib.current.stage;
		var pixel = Math.max(1 / engine.width, 1 / engine.height) * 2;

		function vertex(v:h3d.Vector,f) {
			pts.push(v.x);
			pts.push(v.y);
			pts.push(v.z);
			pts.push(f);
		}
		
		function add(x, y, z, x2, y2, z2) {
			var a = new h3d.Vector(x, y, z);
			var b = new h3d.Vector(x2, y2, z2);

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
		
		select = new h3d.CustomObject(new h3d.prim.RawPrimitive(engine, pts, stride, ind), new SelectShader());
		select.material.depthWrite = false;
		select.material.blend(SrcAlpha,OneMinusSrcAlpha);
		select.material.culling = Face.None;
	}
	
	function initFog() {
		var idx : Array<UInt> = [0, 3, 1, 0, 2, 3];
		tfog = new h3d.CustomObject(
			new h3d.prim.RawPrimitive(engine, flash.Vector.ofArray([0., 0., 1., 0., 0., 1., 1., 1.]), 2, flash.Vector.ofArray(idx)),
			new TexFogShader()
		);
		tfog.material.depth(false,Always);
		tfog.material.blend(OneMinusDstAlpha, DstAlpha);
	}
	
	function initFade() {
		fade = new h3d.CustomObject(tfog.primitive, new FadeShader());
		fade.material.depth(false,Always);
		fade.material.blend(SrcAlpha,OneMinusSrcAlpha);
	}
	
	public function initSky( sky : Array<flash.display.BitmapData> ) {
		var size = sky[0].width;
		skyBox = new Skybox(engine.mem.allocCubeTexture(size));
		for( i in 0...6 )
			skyBox.texture.uploadMipMap(sky[i], false, i);
		skyPos = { px : 0., py : 0., m : new h3d.Matrix() };
		skyPos.m.identity();
	}
	
	function doPick( px : Float, py : Float, pz : Float, dir : h3d.Vector, dx : Float, dy : Float, dz : Float ) {
		var size = game.planet.totalSize;
		var x = Math.floor(px), y = Math.floor(py), z = Std.int(pz);
		var rx = (x + size) % size;
		var ry = (y + size) % size;
		var rz = z;
		if( rz < 0 || rx < 0 || ry < 0 || rx >= size || ry >= size || rz > Const.SIZE*2 )
			return { v : null };
		var b = game.level.get(rx, ry, rz);
		if( b == null || !b.hasProp(PCanPick) )
			return null;
		if( b.size != null ) {
			var s = b.size;
			
			var ax = px, ay = py, az = pz;
			if( dx < 0 ) ax++;
			if( dy < 0 ) ay++;
			if( dz < 0 ) az++;
			
			// ray-box intersection
			var tnear = Math.NEGATIVE_INFINITY;
			var tfar = Math.POSITIVE_INFINITY;
			
			if( Math.abs(dir.x) < 1e-8 ) {
				if( ax < x + s.x1 || ax > x + s.x2 )
					return null;
			} else {
				var t1 = (s.x1 + x - ax) / dir.x;
				var t2 = (s.x2 + x - ax) / dir.x;
				if( t1 > t2 ) {
					var tmp = t1;
					t1 = t2;
					t2 = tmp;
				}
				if( t1 > tnear ) tnear = t1;
				if( t2 < tfar ) tfar = t2;
			}

			if( Math.abs(dir.y) < 1e-8 ) {
				if( ay < y + s.y1 || ay > y + s.y2 )
					return null;
			} else {
				var t1 = (s.y1 + y - ay) / dir.y;
				var t2 = (s.y2 + y - ay) / dir.y;
				if( t1 > t2 ) {
					var tmp = t1;
					t1 = t2;
					t2 = tmp;
				}
				if( t1 > tnear ) tnear = t1;
				if( t2 < tfar ) tfar = t2;
			}
		
			if( Math.abs(dir.z) < 1e-8 ) {
				if( az < z + s.z1 || az > z + s.z2 )
					return null;
			} else {
				var t1 = (s.z1 + z - az) / dir.z;
				var t2 = (s.z2 + z - az) / dir.z;
				if( t1 > t2 ) {
					var tmp = t1;
					t1 = t2;
					t2 = tmp;
				}
				if( t1 > tnear ) tnear = t1;
				if( t2 < tfar ) tfar = t2;
			}
			
			if( tnear > tfar || tfar < 0 )
				return null;
				
			//TODO update px py pz regarding intersection point on actual face
		}
		var s = new Selection(x, y, z);
		s.b = b;
		s.pt = new h3d.Point(px, py, pz);
		return { v : s };
	}

	public function pick( mx : Float, my : Float, put : Block, maxDist : Float ) {
		var camera = engine.camera;
		
		var fpx = camPosition.x;
		var fpy = camPosition.y;
		var fpz = camPosition.z;
		
		var stage = flash.Lib.current.stage;
		var mx = (mx / engine.width) * 2 - 1;
		var my = (my / engine.height) * 2 - 1;
		
		var rdir = new h3d.Vector(mx, -my, camera.zNear,1);
		var tmp = new h3d.Matrix();
		tmp.inverse(camera.mproj);
		rdir.project(tmp);
		tmp.inverse(camera.mcam);
		rdir.project(tmp);
		
		rdir.x -= fpx;
		rdir.y -= fpy;
		rdir.z -= fpz;
		rdir.normalize();

		var curve = game.planet.curve;
		var size = game.planet.totalSize;
		var dist : Float = maxDist;
		var found = null;
		
		var px:Float, py:Float, pz:Float;
		var dx:Float, dy:Float, dz:Float, dd:Float;
		var rdelta, rdist;
		
		if( rdir.x < 0 ) { dx = -1; px = Math.floor(fpx); } else { dx = 1; px = Math.ceil(fpx); }
		var xdist = (px - fpx) / rdir.x;
		var xfound = null;
		dy = rdir.y / (rdir.x * dx);
		dz = rdir.z / (rdir.x * dx);
		dd = Math.sqrt(1 + dy * dy + dz * dz);
		py = fpy + xdist * rdir.y;
		pz = fpz + xdist * rdir.z;
		rdelta = Math.sqrt(dx * dx + dy * dy);
		rdist = Math.sqrt((fpx - px) * (fpx - px) + (fpy - py) * (fpy - py));
		if( dx < 0 ) px--;
		
		while( xdist < dist ) {
			var r = doPick(px, py, pz + rdist * rdist * curve, rdir, dx, 0, 0);
			if( r != null ) {
				xfound = r.v;
				break;
			}
			px += dx;
			py += dy;
			pz += dz;
			xdist += dd;
			rdist += rdelta;
		}
		
		if( xfound != null && xdist < dist ) {
			found = xfound;
			dist = xdist;
		}
	
		if( rdir.y < 0 ) { dy = -1; py = Math.floor(fpy); } else { dy = 1; py = Math.ceil(fpy); }
		var ydist = (py - fpy) / rdir.y;
		var yfound = null;
		dx = rdir.x / (rdir.y * dy);
		dz = rdir.z / (rdir.y * dy);
		dd = Math.sqrt(1 + dx * dx + dz * dz);
		px = fpx + ydist * rdir.x;
		pz = fpz + ydist * rdir.z;
		rdelta = Math.sqrt(dx * dx + dy * dy);
		rdist = Math.sqrt((fpx - px) * (fpx - px) + (fpy - py) * (fpy - py));
		if( dy < 0 ) py--;
		
		while( ydist < dist ) {
			var r = doPick(px, py, pz + rdist * rdist * curve, rdir, 0, dy, 0);
			if( r != null ) {
				yfound = r.v;
				break;
			}
			px += dx;
			py += dy;
			pz += dz;
			ydist += dd;
			rdist += rdelta;
		}
		
		if( yfound != null && ydist < dist ) {
			found = yfound;
			dist = ydist;
		}
		
		var zdist = 0.;
		var zfound = null;
		var px = fpx, py = fpy, pz = fpz;
		var dx = rdir.x / rdir.z;
		var dy = rdir.y / rdir.z;
		var rdelta = Math.sqrt(dx * dx + dy * dy);
		rdist = 0.;
		if( curve == 0 ) curve = 1e-8;
		while( zdist < dist ) {
			// next real-z
			var rz = pz + rdist * rdist * curve;
			var znext = if( rdir.z < 0 ) Math.floor(rz - 0.001) else Math.ceil(rz + 0.001);
			// calculate how much we need to jump to get there
			var c = rz - znext;
			var a = rdelta * rdelta * curve;
			var b = 1 + curve * 2 * rdelta * rdist;
			var det = Math.sqrt(b * b - 4 * a * c);
			var dz = -(b - det) / (2 * a);
			// move there
			pz += dz;
			zdist += dz / rdir.z;
			px += dz * dx;
			py += dz * dy;
			rdist += dz * rdelta;
			var r = doPick(px, py, znext + (dz < 0 ? -1 : 0), rdir, 0, 0, dz);
			if( r != null ) {
				zfound = r.v;
				break;
			}
		}
		
		if( zfound != null && zdist < dist ) {
			found = zfound;
			dist = zdist;
		}
		
		if( found != null ) {
			if( found == xfound && rdir.x < 0 )
				found.pt.x++;
			else if( found == yfound && rdir.y < 0 )
				found.pt.y++;
			else if( found == zfound && rdir.z < 0 )
				found.pt.z++;
			found.dir = rdir;
		}
		
		if( found != null && put != null ) {
			var face = LeftRight, dx = 0, dy = 0, dz = 0;
			if( found == xfound )
				dx = rdir.x < 0 ? 1 : -1;
			else if( found == yfound )
				dy = rdir.y < 0 ? 1 : -1;
			else {
				face = rdir.z < 0 ? Up : Down;
				dz = rdir.z < 0 ? 1 : -1;
			}
			if( !found.b.hasMagnet(face) )
				return null;
			var old = game.level.get((found.x + dx + size) % size, (found.y + dy + size) % size, found.z + dz);
			// it might be a block which we can't pick
			if( old != null && !old.canOverride() ) return null;
			found.x += dx;
			found.y += dy;
			found.z += dz;
			found.b = null;
		}
		
		return found;
	}

	function syncCurrentShader(x,y,z) {
		var s = curShader.value;
		if( s.currentDX != x || s.currentDY != y || s.currentDZ != z ) {
			s.currentDX = x;
			s.currentDY = y;
			s.currentDZ = z;
			var m = engine.camera.m.copy();
			m.prependTranslate(s.currentDX, s.currentDY, s.currentDZ);
			curShader.base.mproj = m;
			var tmp = camPosition.copy();
			tmp.x -= x;
			tmp.y -= y;
			tmp.z -= z;
			curShader.base.cam = tmp;
			// force constants refresh
			engine.selectShader(curShader.value);
		}
	}
	
	function draw( c : CellBuffer, type ) {
		var b = c.getBuffer(type);
		if( b == null ) return;
		syncCurrentShader(c.viewX,c.viewY,c.viewZ);
		engine.renderQuads(b);
	}

	function pointClip( x:Float, y:Float, z : Float ) {
		var m = engine.camera.mcam;
		
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

	public function setPos(px:Float, py:Float, pz:Float, angle : Float, angleZ : Float, ?fovDistort = 1.0 ) {
		var camera = engine.camera;

		this.angle = angle;
		this.angleZ = angleZ;
		
		angleZ = Math.PI/2 - angleZ;
		
		camera.fov = baseFov * fovDistort;
		
		camera.pos.set(px, py, pz);
		camera.target.set(px + Math.cos(angle) * Math.sin(angleZ), py + Math.sin(angle) * Math.sin(angleZ), pz + Math.cos(angleZ));
		camera.update();

		camTangent = Math.tan(camera.fov * 0.5 * Math.PI / 180);
		planetCurve = game.planet.curve;
		
		camPosition = new h3d.Vector(px, py, pz, planetCurve);
	}
	
	inline function selectMaterial( t : BlockType, pass = 0 ) {
		var m = materials[Type.enumIndex(t)][pass];
		curShader = { base : cast m.shader, value : cast m.shader };
		engine.selectMaterial(m);
	}
	
	public function testRebuildAll() {
		var count = 0, tri = 0;
		for( c in builder.level.cells )
			if( builder.rebuild(c) ) {
				for( b in c.buffers ) {
					var b = b;
					while( b != null ) {
						tri += b.nvert >> 1;
						b = b.next;
					}
				}
				count++;
			}
		return { chunks : count, tri : tri };
	}
	
	public function takeScreenShot( bmp : flash.display.BitmapData ) {
		engine.begin();
		render(true);
		if( !bmp.transparent ) forceAlpha();
		engine.saveTo(bmp);
		engine.end();
	}
	
	inline function viewX( v : Float ) {
		return camPosition.x + game.realDist(v - camPosition.x);
	}

	inline function viewY( v : Float ) {
		return camPosition.y + game.realDist(v - camPosition.y);
	}
	
	public function renderBlock( block : Block, size : Int, bgColor = 0 ) {
		var oldW = engine.width, oldH = engine.height, oldBG = engine.backgroundColor;
		var upScale = 2;

		builder.initBuffer();
		builder.addBufferBlock(block, 0, 0, 0, 1.0);
		var buf = builder.allocBuffer();
		
		// this is quite an ugly way to do a isometric projection, but anyway...
		var mpos = h3d.Matrix.T( -0.5, -0.5, -0.5);
		var scale = 2.3 / Math.tan(Math.PI / 3);
		var scaleZ = 0.9;
		var angle = Math.PI / 4;
		
		if( block.model != null )
			switch( block.model ) {
			case MCross: angle = Math.PI / 2;
			case MPlanX: angle = Math.PI / 2; scaleZ = 1.2;
			case MPlanY: angle = 0; scaleZ = 1.2;
			default:
			}
		
		mpos.scale(scale, scale, scale * scaleZ);
		shaders.icon.mpos = mpos;
	
		var mproj = h3d.Matrix.I();
		mproj.rotate(new h3d.Vector(0, 0, 1), -angle);
		mproj.rotate(new h3d.Vector(1, 0, 0), -Math.PI / 3);
		mproj.scale(-1, -1, -1);
		mproj.translate(0, 0, 1.5);
		shaders.icon.mproj = mproj;
		shaders.icon.spriteScale = block.type == BTSprite ? new h3d.Vector(100,-100) : new h3d.Vector(0, 0);
				
		shaders.icon.tex = tex;
		shaders.icon.depthScale = 0.001;
				
		var mpos = new h3d.Matrix();
		engine.resize(size * upScale, size * upScale);
		engine.backgroundColor = bgColor;
		engine.begin();
		
		var mat = new h3d.mat.Material(shaders.icon);
		mat.culling = Face.None;
		engine.selectMaterial(mat);
		engine.renderIndexes(buf, engine.mem.quadIndexes, 2, 0, builder.blockTriangles(block));
		buf.dispose();
		var bmp = new flash.display.BitmapData(size * upScale, size * upScale, true);
		engine.saveTo(bmp);
		// NO engine.end()
		
		engine.resize(oldW, oldH);
		engine.backgroundColor = oldBG;
		
		var bmp2 = new flash.display.BitmapData(size, size, true, 0);
		bmp2.draw(new flash.display.Bitmap(bmp, flash.display.PixelSnapping.ALWAYS, true), new flash.geom.Matrix(1/upScale, 0, 0, 1/upScale));
		bmp.dispose();
		
		bmp2.applyFilter(bmp2, bmp2.rect, new flash.geom.Point(0,0), new flash.filters.GlowFilter(0x0,1, 2,2, 1));
		
		return bmp2;
	}
	
	function drawBlock( block : Block, shade ) {
		builder.initBuffer();
		builder.addBufferBlock(block, 0, 0, 0, shade);
		var buf = builder.allocBuffer();
		if( buf != null ) {
			engine.renderIndexes(buf, engine.mem.quadIndexes, 2, 0, builder.blockTriangles(block));
			buf.dispose();
		}
	}
	
	function forceAlpha() {
		fade.shader.color = 0xFF000000;
		fade.material.setColorMask(false, false, false, true);
		fade.render(engine);
		fade.material.setColorMask(true, true, true, true);
	}
	
	function cst()
	{
		return game.constants;
	}
	
	function getTex( c : Class<h3d.mat.PngBytes> )
	{
		mt.gx.Debug.assert(c != null,c+" cannot be used for tex creation");
		var t  = texCache.get( c );
		if ( t == null ) texCache.set(c, t = engine.mem.makeTexture( Type.createEmptyInstance(c).getBitmapBytes()));
		return t;
	}
	
	public function render( screenShot = false ) {
		var px = camPosition.x;
		var py = camPosition.y;
		var pz = camPosition.z;
		var psize = game.planet.totalSize;
		
		// setup effects
		var fx : r3d.AbstractGame.GameEffects = game.getEffects(px, py, pz);
		
		// setup fog
		var fogDY = angleZ / (Math.PI / 2) + 0.1;
		fogPower = 0.01 * fx.fogPower;
		var colors = Std.string(fx.fogColors);
		if( colors != fogColorCache ) {
			fogColorCache = colors;
			var ncol = fx.fogColors.length;
			var pow2 = 1;
			while( pow2 < fx.fogColors.length )
				pow2 <<= 1;
			if( fogTexture != null && fogTexture.width != pow2 ) {
				fogTexture.dispose();
				fogTexture = null;
			}
			if( fogTexture == null ) {
				fogTexture = engine.mem.allocTexture(pow2, 1);
				fogTScale = ncol / pow2;
			}
			var bmp = new flash.display.BitmapData(pow2, 1, true, 0);
			for( i in 0...ncol )
				bmp.setPixel32(i, 0, fx.fogColors[i]);
			if( ncol < pow2 )
				bmp.setPixel32(ncol, 0, fx.fogColors[ncol-1]);
			fogTexture.upload(bmp);
			bmp.dispose();
		}

		// cells
		
		var todraw = new Array<CellBuffer>();
		var pos = 0;
		
		
		var half = 1 << (Builder.CELL - 1);
		var rayDist = Math.pow(half * Math.sqrt(2), 2);
		var viewSize = (psize < 256 ? psize : 256) >> (Builder.CELL + 1);
		var cpx = Std.int(px) >> Builder.CELL;
		var cpy = Std.int(py) >> Builder.CELL;
		
		if( !engine.hardware ) viewSize = Math.ceil(viewSize * 0.5);
		
		frame++;

		for( dx in -viewSize+1...viewSize )
			for( dy in -viewSize + 1...viewSize ) {
				var cx = (((cpx + dx) << Builder.CELL) + half) - px;
				var cy = (((cpy + dy) << Builder.CELL) + half) - py;
			
				var c = pointClip(cx - half, cy - half, -pz);
				
				if( c != 0 && c == pointClip(cx - half, cy + half, -pz) && c == pointClip(cx + half, cy - half, -pz) && c == pointClip(cx + half, cy + half, -pz) &&
					c == pointClip(cx - half, cy - half, Const.ZSIZE - pz) && c == pointClip(cx - half, cy + half, Const.ZSIZE - pz) && c == pointClip(cx + half, cy - half, Const.ZSIZE - pz) && c == pointClip(cx + half, cy + half, Const.ZSIZE - pz)
					)
					continue;

				var x = builder.level.real(cpx + dx);
				var y = builder.level.real(cpy + dy);
				var z = Std.int((cx * cx + cy * cy) * 1000);
				var c = builder.level.getCell(x, y);
				if( c.frame == frame && c.z < z ) continue;
				c.viewX = ((cpx + dx) - c.x) << Builder.CELL;
				c.viewY = ((cpy + dy) - c.y) << Builder.CELL;
				c.z = z;
				if( c.frame != frame ) {
					c.frame = frame;
					todraw.push(c);
				}
			}
			
		if( builder.extra != null ) {
			var ix = Math.floor(px);
			var iy = Math.floor(py);
			for( y in 0...Const.SIZE >> Builder.CELL )
				for( x in 0...Const.SIZE >> Builder.CELL ) {
					var c = builder.extra.getCell(x, y);
					if( !c.dirty && c.buffers.length == 0 )
						continue;
					var ax = Std.int(game.realDist( game.real( (x << Builder.CELL) + builder.extra.posX ) - ix )) + ix;
					var ay = Std.int(game.realDist( game.real( (y << Builder.CELL) + builder.extra.posY ) - iy )) + iy;
					c.viewX = ax - (x << Builder.CELL);
					c.viewY = ay - (y << Builder.CELL);
					c.viewZ = builder.extra.posZ;
					c.z = Std.int((ax * ax + ay * ay) * 1000);
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
				if( flash.Lib.getTimer() - t0 > 60 && !screenShot ) {
					game.needRedraw();
					break;
				}
			} else {
				var c = game.level.cells[(c.x << Builder.CELL) >> Const.BITS][(c.y << Builder.CELL) >> Const.BITS];
				if( !c.loading ) {
					c.loading = true;
					game.loadChunk(c.x,c.y);
				}
			}
		}

		if( rebuilt > 0 ) {
			rebuiltTime += flash.Lib.getTimer() - t0;
			rebuiltCount += rebuilt;
		}
		
		var camera = engine.camera;
		for( s in baseShaders ) {
			s.tex = tex;
			s.mproj = camera.m;
			s.cam = camPosition;
			s.fogPower = fogPower;
			s.currentDX = 0;
			s.currentDY = 0;
			s.currentDZ = 0;
		}

		// write opaque data (front-to-back)
		selectMaterial(BTFull);
		for( c in todraw )
			draw(c, BTFull);
			
		// write entities
		var m = new h3d.Matrix();
		heroBody.shader.cam = camPosition;
		heroBody.shader.fogPower = fogPower;
		heroBody.shader.mproj = camera.m;
		while( namesContainer.numChildren > 0 )
			namesContainer.removeChildAt(0);
		game.softHudContext.addChild(namesContainer);
		for( e in fx.entities ) {
			
			if( e.z > Const.SHIP_Z )
				continue;
			
			m.initRotateZ(e.angle);
			m.translate(game.realDist(e.x - px) + px, game.realDist(e.y - py) + py, e.z);
			
			var pt = new h3d.Vector(0,0,e.camera ? 1.0 : 1.75);
			pt.project(m);
			var dist = pt.sub(new h3d.Vector(px, py, pz)).length();
			pt.z -= dist * dist * planetCurve;
			pt.project(camera.m);
			
			var tf = userNames.get(e.id);
			if( tf == null ) {
				tf = game.makeField();
				tf.autoSize = flash.text.TextFieldAutoSize.LEFT;
				tf.height = 20;
				tf.width = 0;
				tf.text = e.name;
				userNames.set(e.id, tf);
			}
			var size = 3 / Math.sqrt(dist);
			var name = e.name;
			if( size > 2 ) size = 2;
			if( size < 0.8 ) {
				size = 0.8;
				name = "?";
			}
			if( pt.z > 0 && pt.z < 1 ) {
				var s = new flash.display.Sprite();
				var k = 0.98;
				s.addChild(tf);
				if( pt.y < -k ) {
					pt.y = -k;
					name = "\\/";
				}
				if( pt.y > k ) {
					pt.y = k;
					name = "^";
				}
				if( pt.y < -k ) {
					pt.y = -k;
					name = "\\/";
				}
				if( pt.x < -k ) {
					pt.x = -k;
					name = "<";
				}
				if( pt.x > k ) {
					pt.x = k;
					name = ">";
				}
				tf.text = name;
				tf.x = -tf.textWidth * 0.5;
				tf.y = -tf.textHeight * 0.5;
				s.x = (pt.x + 1) * engine.width * 0.5;
				s.y = (1 - pt.y) * engine.height * 0.5;
				s.scaleX = s.scaleY = size;
				namesContainer.addChild(s);
			}
			
			var tex : h3d.mat.Texture = null;
			if ( (tex=entitiesTex.get( e.bmp )) == null )
			{
				tex = engine.mem.makeTexture( e.bmp.getBitmapBytes() );
				entitiesTex.set( e.bmp, tex );
			}
			
			if( e.camera )
				continue;
			
			heroBody.shader.mpos = m;
			heroBody.shader.tex = tex;
			heroBody.render(engine);

			heroBase.shader.mpos = m;
			heroBase.shader.tex = tex;
			heroBase.render(engine);
			
		
		}

		// write transparent pixels
		selectMaterial(BTTransp);
		for( c in todraw )
			draw(c, BTTransp);

		// write transparent pixels
		selectMaterial(BTModel2Side);
		for( c in todraw )
			draw(c, BTModel2Side);
			
		// write sprites
		var spriteScale = new h3d.Vector(100, -100 * camera.ratio);
		selectMaterial(BTSprite);
		shaders.sprite.spriteScale = spriteScale;
		for( c in todraw )
			draw(c, BTSprite);
			
		// dummies
		builder.initBuffer();
		for( d in fx.dummies )
			builder.addBufferBlock(d.block, 0, 0, 0, d.light);
		var buf = builder.allocBuffer();
		if( buf != null ) {
			shaders.dummy.mproj = camera.m;
			shaders.dummy.cam = camPosition;
			shaders.dummy.fogPower = fogPower;
			shaders.dummy.tex = tex;
			shaders.dummy.depthScale = 1;
			var mpos = new h3d.Matrix();
			var scale = 0.3;
			mpos.initTranslate( -0.5, -0.5);
			mpos.scale(scale, scale, scale);
			mpos.rotate(new h3d.Vector(0, 0, 1), fx.time);
			engine.selectMaterial(matDummy);
			var pos = 0;
			for( d in fx.dummies ) {
				var mpos = mpos.copy();
				if( d.time < 1 )
					mpos.scale(d.time,d.time,d.time);
				mpos.translate(viewX(d.x), viewY(d.y), d.z);
				shaders.dummy.mpos = mpos;
				switch( d.block.type ) {
				case BTSprite:
					shaders.dummy.spriteScale = new h3d.Vector(scale * spriteScale.x, scale * spriteScale.y);
				default:
					shaders.dummy.spriteScale = new h3d.Vector(0, 0);
				}
				engine.selectShader(shaders.dummy);
				var count = builder.blockTriangles(d.block);
				engine.renderIndexes(buf, engine.mem.quadIndexes, 2, pos, count);
				pos += count;
			}
			buf.dispose();
		}

		// water
		var awater = game.planet.animWater;
		if( awater != null ) {
			var wscale = awater.width;
			var wspeed = fx.time * awater.speed;
			var w = new h3d.Vector(wspeed, wspeed, awater.scale * 0.5, wscale);
			shaders.water0.water = w;
			shaders.water1.water = w;
			shaders.water2.water = w;
		}
		for( pass in 0...3 ) {
			var m = materials[Type.enumIndex(BTWater)][pass];
			if( m == null ) break;
			m.culling = fx.inWater ? Face.Front : Face.Back;
			selectMaterial(BTWater,pass);
			for( c in todraw )
				draw(c, BTWater);
		}
		
		
		// sky
		if( skyPos != null ) {
			var rx = ((px - skyPos.px) * Math.PI * 2 / psize) % (Math.PI * 2);
			var ry = ((py - skyPos.py) * Math.PI * 2 / psize) % (Math.PI * 2);
			var mtmp = new h3d.Matrix();
			mtmp.initRotateY( -rx);
			skyPos.m.add(mtmp);
			mtmp.initRotateX(ry);
			skyPos.m.add(mtmp);
			skyPos.px = px;
			skyPos.py = py;
			if( engine.hardware && fx.skyBoxAlpha > 0 ) {
				skyBox.color = new h3d.Vector(1, 1, 1, fx.skyBoxAlpha);
				skyBox.render(engine,skyPos.m);
			}
		}
		
		
		
		// alpha
		shaders.fogColor.tex = fogTexture;
		shaders.fogColor.fogDy = fogDY;
		shaders.fogColor.fogTScale = fogTScale;
		var passes = materials[Type.enumIndex(BTAlpha)].length;
		for( pass in 0...passes ) {
			selectMaterial(BTAlpha, pass);
			for( c in todraw )
				draw(c, BTAlpha);
		}
		
		var sel = fx.select;
		if( sel != null ) {
			// select box
			if( !(screenShot || fx.laser != null) ) {
				var pos = new h3d.Vector(sel.x, sel.y, sel.z, 0);
				var size = new h3d.Vector(1, 1, 1, 1);
				var b = sel.b;
				if( b == null ) {
					b = fx.currentBlock;
					if( b != null ) b = b.getFlip(angle);
				}
				if( b != null && b.size != null ) {
					var s = b.size;
					pos.x += s.x1;
					pos.y += s.y1;
					pos.z += s.z1;
					size.x = s.x2 - s.x1;
					size.y = s.y2 - s.y1;
					size.z = s.z2 - s.z1;
				}
				select.shader.mpos = pos;
				select.shader.size = size;
				select.shader.mproj = camera.m;
				select.shader.cam = camPosition;
				select.shader.scale = 1;
				select.render(engine);
			}
			
			// breaking kube overlay
			if( fx.laser != null ) {
				var pos;
				if( fx.laser.canBreak ) {
					pos = h3d.Matrix.S(
						1 + 0.015 + Math.random() * 0.075,
						1 + 0.015 + Math.random() * 0.075,
						1 + 0.015 + Math.random() * 0.075
					);
					shaders.breaks.uvMod = new h3d.Vector(1, 1);
					shaders.breaks.uvDelta = new h3d.Vector(0, 0);
				} else {
					pos = h3d.Matrix.S(1.15, 1.15, 1.15);
					shaders.breaks.uvMod = new h3d.Vector(1/64, 1/64);
					shaders.breaks.uvDelta = new h3d.Vector(51/64, 0/64);
				}
				pos.translate(
					sel.x - (pos._11 - 1) * 0.5,
					sel.y - (pos._22 - 1) * 0.5,
					sel.z - (pos._33 - 1) * 0.5
				);
				shaders.breaks.tex = tex;
				shaders.breaks.mpos = pos;
				shaders.breaks.mproj = camera.m;
				shaders.breaks.cam = camPosition;
				var m = new h3d.mat.Material(shaders.breaks);
				m.culling = Face.None;
				m.blend(SrcAlpha, OneMinusSrcAlpha);

				var shade = game.level.getLightAt(sel.pt.x,sel.pt.y,sel.pt.z, game.planet.defaultLight);
				
				// draw RGB
				m.colorMask = 7;
				shaders.breaks.alpha = fx.laser.canBreak ? 0.5 : 0.1+0.7*Math.random();
				engine.selectMaterial(m);
				drawBlock(sel.b,shade);
				
				// set alpha
				m.colorMask = 8;
				shaders.breaks.alpha = 1;
				engine.selectMaterial(m);
				drawBlock(sel.b,shade);
			}
		}

		// particules
		parts.render();
		
		if( SHOW_OTHER_LAZER)
			for ( e in fx.entities)
			{
				if( e.select != null)
				{
					if ( e.select.laser != null)
					{
						if( e.z > Const.SHIP_Z )
							continue;
						
						var m = new h3d.Matrix();
						m.initRotateZ(e.angle);
						m.translate(game.realDist(e.x - px) + px, game.realDist(e.y - py) + py, e.z + 1.3);
						var to = new h3d.Vector(e.select.x, e.select.y, e.select.z);
						worldLazer.render( fx, { from: m.pos(), to: to, mat : m, type:e.select.laser  } );
					}
				}
			}
		
		
		// fog
		if( fx.fogPower > 0 ) {
			tfog.shader.tex = fogTexture;
			tfog.shader.dy = fogDY;
			tfog.shader.fogTScale = fogTScale;
			tfog.render(engine);
		}
		
		// in-hand block
		var block = fx.currentBlock;
		if( block != null && !screenShot ) {
			var cam = engine.camera.clone();
			cam.pos.set(0, 0, 0);
			cam.target.set(1, 0, 0);
			cam.update();
			
			var mpos = new h3d.Matrix();
			var angle = angle;
			var dz = 0.;
			if( block.model != null )
				switch( block.model ) {
				case MCross: dz = 0.5;
				default:
				}
			mpos.identity();
			mpos.translate(-0.5, -0.5, -0.5);
			mpos.rotate(new h3d.Vector(0, 0, 1), Math.PI * 2 / 3);
			mpos.translate(1, 0.8 + fx.bobbing.x / 50, -0.8 - fx.bobbing.y / 50 + dz);
			
			shaders.dummy.mproj = cam.m;
			shaders.dummy.cam = new h3d.Vector(0,0,0,camPosition.w);
			shaders.dummy.tex = tex;
			shaders.dummy.mpos = mpos;
			shaders.dummy.spriteScale = new h3d.Vector(0, 0);
			shaders.dummy.depthScale = 0.01;
			engine.selectMaterial(matDummy);
			
			var tlight = game.level.getLightAt(camPosition.x, camPosition.y, camPosition.z, game.planet.defaultLight);
			if( curLight == null || !engine.hardware )
				curLight = tlight;
			else
				curLight = curLight * 0.7 + tlight * 0.3;
			
			drawBlock(block, curLight);
		} else
			curLight = null;
		
		// lazer
		if( block == null && fx.laser != null ) {
			var laserId = 0;
			if( fx.laser.c != null )
				laserId = 1 + Type.enumIndex(fx.laser.c);

			var cam = engine.camera.clone();
			cam.pos.set(0, 0, 0);
			cam.target.set(1, 0, 0);
			cam.update();

			var icam = cam.mcam.copy();
			icam.inverse(icam);
			var target = sel.pt.transform(engine.camera.mcam).transform(icam).toVector();
			var pos = new h3d.Vector(1, 0.8 + fx.bobbing.x / 50, -0.8 - fx.bobbing.y / 50);
			var dist = target.sub(pos);
			
			var length = dist.length(), size = 0.2;
			var mrot = h3d.Matrix.I();
			mrot._11 = dist.x / length;
			mrot._12 = dist.y / length;
			mrot._13 = dist.z / length;
			
				
			var rspeed = 3.;
			var tspeed = 1.;
			switch( laserId ) {
				case 0	: tspeed = 0.8; rspeed = 5;
				case 1	: tspeed = 3; rspeed = 4;
				//case 1	: tspeed = 1.5; rspeed = 3;
				case 2	: tspeed = 2; rspeed = 5;
				case 3	: tspeed = 2; rspeed = 5;
			}
			
			var mpos = if(rspeed==0) h3d.Matrix.I() else h3d.Matrix.R(new h3d.Vector(1, 0, 0), rspeed*fx.time);
			mpos.scale(length, size, size);
			mpos.add(mrot);
			mpos.translate(pos.x, pos.y, pos.z);
			
			var tscale = length / 2;
			lazer.shader.uvScale = new h3d.Vector(tscale, 1);
			lazer.shader.uvDelta = new h3d.Vector(-tspeed*fx.time / tscale, 0);
			lazer.shader.mpos = mpos;
			lazer.shader.mproj = cam.m;
			lazer.shader.tex = getLazerTex( laserId );
			
			// reduce curve deform when we are looking up/down
			// this is a quick approx., the best would be to have everything in _real_ camera space to get correct Z-distort
			lazer.shader.cam = new h3d.Vector(0,0,0,game.planet.curve * Math.sqrt(sel.dir.x*sel.dir.x+sel.dir.y*sel.dir.y) );
			lazer.render(engine);
		}
		
		// ship
		var ship = fx.shipDock;
		if( ship != null ) {
			var pos = h3d.Matrix.S(1, 1, ship.h);
			pos.translate(viewX(ship.x + 0.5), viewY(ship.y + 0.5), ship.z);
			
			shipDock.shader.tex = getTex( cst().shipDockBitmap );
			shipDock.shader.mpos = pos;
			shipDock.shader.uvDelta = new h3d.Vector(fx.time / 100, 0);
			shipDock.shader.mproj = camera.m;
			shipDock.shader.cam = camPosition;
			shipDock.render(engine);
		}

		// fade
		if( fx.fades.length > 0 ) {
			var col = -1;
			var maxAlpha = 0.;
			for( f in fx.fades ) {
				var a = f.a;
				if( a >= 1.0 ) a = 0.999;
				if( a>maxAlpha )
					maxAlpha = a;
				if( col < 0 ) {
					col = f.col;
				} else {
					var r = (col >> 16) & 0xFF;
					var g = (col >> 8) & 0xFF;
					var b = col & 0xFF;
					r += (f.col >> 16) & 0xFF;
					g += (f.col >> 8) & 0xFF;
					b += f.col & 0xFF;
					if( r > 255 ) r = 255;
					if( g > 255 ) g = 255;
					if( b > 255 ) b = 255;
					col = (r << 16) | (g << 8) | b;
				}
			}
			fade.shader.color = col | (Std.int(maxAlpha * 256) << 24);
			fade.render(engine);
		}
		
		if( !screenShot ) {
			for( h in hud )
				if( h != null && h.visible )
					h.render(engine);
		}
	}

	public function getLazerTex(laserId) 
	{
		mt.gx.Debug.assert( cst().laserBitmaps[laserId] != null,"no laser tex in slot "+laserId );
		return getTex( cst().laserBitmaps[laserId] );
	}

}