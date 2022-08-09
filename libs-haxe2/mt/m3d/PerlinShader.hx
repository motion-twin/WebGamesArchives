package mt.m3d;
import mt.m3d.T;

class PerlinShader extends Shader {

	static var SRC = {
		var input : {
			pos : Float3,
		};
		var tuv : Float3;
		function vertex(delta : Float3, scale : Float) {
			out = pos.xyzw;
			tuv = ([(pos.x + 1) * 0.5, 1 - (pos.y + 1) * 0.5, 0] + delta) * scale;
		}

		function gradperm( g : Texture, v : Float, pp : Float3 ) {
			return (g.get(v,single,nearest,wrap).xyz * 2 - 1).dot(pp);
		}

		function lerp( x : Float, y : Float, v : Float ) {
			return x * (1 - v) + y * v;
		}

		function fade( t : Float3 ) : Float3 {
			return t * t * t * (t * (t * 6 - 15) + 10);
		}

		function gradient( permut : Texture, g : Texture, pos : Float3 ) {
			var p = pos.frc();
			var i = pos - p;
			var f = fade(p);
			var one = 1 / 256;
			i *= one;
			var a = permut.get(i.xy, nearest, wrap) + i.z;
			return lerp(
				lerp(
					lerp( gradperm(g, a.x, p), gradperm(g, a.z, p + [ -1, 0, 0] ), f.x),
					lerp( gradperm(g, a.y, p + [0, -1, 0] ), gradperm(g, a.w, p + [ -1, -1, 0] ), f.x),
					f.y
				),
				lerp(
					lerp( gradperm(g, a.x + one, p + [0, 0, -1] ), gradperm(g, a.z + one, p + [ -1, 0, -1] ), f.x),
					lerp( gradperm(g, a.y + one, p + [0, -1, -1] ), gradperm(g, a.w + one, p + [ -1, -1, -1] ), f.x),
					f.y
				),
				f.z
			);
		}

		function fragment( permut : Texture, g : Texture) {
			var pos = tuv;
			var tot = 0;
			var per = 1.0;
			for( k in 0...2 ) {
				tot += gradient(permut, g, pos) * per;
				per *= 0.5;
				pos *= 2;
			}
			var n = (tot + 1) * 0.5;
			out = [n, n, n, 1];
		}
	};

	static var PTBL = flash.Vector.ofArray([ 151, 160, 137, 91, 90, 15,
		131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
		190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
		88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
		77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
		102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
		135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
		5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
		223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
		129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
		251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
		49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
		138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
	]);

	static var GRAD = [
		1,1,0,
		-1,1,0,
		1,-1,0,
		-1,-1,0,
		1,0,1,
		-1,0,1,
		1,0,-1,
		-1,0,-1,
		0,1,1,
		0,-1,1,
		0,1,-1,
		0,-1,-1,
		1,1,0,
		0,-1,1,
		-1,1,0,
		0,-1,-1,
	];


	var permut : Texture;
	var grad : Texture;
	var pol : mt.m3d.Polygon;
	var ptbl : flash.Vector<Int>;

	public function new(c) {
		super(c);
		ptbl = PTBL;
		permut = initPermut();
		grad = initGradient();
		pol = new mt.m3d.Polygon([new Vector( -1, -1, 0), new Vector(1, -1, 0), new Vector( -1, 1, 0), new Vector(1, 1, 0)], [0, 1, 2, 1, 3, 2]);
		pol.alloc(c);
	}

	override function dispose() {
		super.dispose();
		permut.dispose();
		grad.dispose();
		pol.dispose();
	}

	inline function perm( x : Int ) {
		return ptbl[x & 0xFF];
	}

	function initPermut() {
		var bytes = new flash.utils.ByteArray();
		bytes.length = 256 * 256 * 4;
		flash.Memory.select(bytes);
		var out = 0;
		for( y in 0...256 )
			for( x in 0...256 ) {
				var a = perm(x) + y;
				var aa = perm(a);
				var ab = perm(a + 1);
				var b = perm(x + 1) + y;
				var ba = perm(b);
				var bb = perm(b + 1);
				flash.Memory.setByte(out++, ba); // B
				flash.Memory.setByte(out++, ab); // G
				flash.Memory.setByte(out++, aa); // R
				flash.Memory.setByte(out++, bb); // A
			}
		var t = c.createTexture(256, 256, TextureFormat.BGRA, false);
		t.uploadFromByteArray(bytes, 0);
		return t;
	}

	function initGradient() {
		var bytes = new flash.utils.ByteArray();
		for( x in 0...256 ) {
			var p = (perm(x) & 15) * 3;
			var r = GRAD[p];
			var g = GRAD[p + 1];
			var b = GRAD[p + 2];
			bytes.writeByte(Std.int((b + 1) * 127.5));
			bytes.writeByte(Std.int((g + 1) * 127.5));
			bytes.writeByte(Std.int((r + 1) * 127.5));
			bytes.writeByte(255); // A
		}
		var t = c.createTexture(256, 1, TextureFormat.BGRA, false);
		t.uploadFromByteArray(bytes, 0);
		return t;
	}

	public function perlin( x : Float, y : Float, z : Float, scale : Float ) {
		init( { delta : new flash.geom.Vector3D(x,y,z), scale : scale }, { permut : permut, g : grad } );
		draw(pol.vbuf, pol.ibuf);
	}

}
