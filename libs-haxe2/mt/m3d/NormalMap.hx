package mt.m3d;
import mt.m3d.T;

@:shader({
	var input : {
		pos : Float3
	};
	var tuv : Float2;
	function vertex() {
		out = pos.xyzw;
		tuv = [(pos.x + 1) * 0.5, 1 - (pos.y + 1) * 0.5];
	}
	function fragment( tex : Texture, du : Float, dv : Float, bump : Float ) {
		var h00 = tex.get(tuv + [ -du, -dv],wrap).r;
		var h20 = tex.get(tuv + [ du, -dv],wrap).r;

		var h01 = tex.get(tuv + [ -du, 0],wrap).r;
		var h21 = tex.get(tuv + [ du, 0],wrap).r;
		
		var h02 = tex.get(tuv + [ -du, dv],wrap).r;
		var h22 = tex.get(tuv + [ du, dv],wrap).r;
		
		// sobel 3x3 operator
		var gx = h00 - h20 + 2 * h01 - 2 * h21 + h02 - h22;

		var h10 = tex.get(tuv + [ 0, -dv], wrap).r;
		var h12 = tex.get(tuv + [ 0, dv], wrap).r;
		var gy = h00 + 2 * h10 + h20 - h02 - 2 * h12 - h22;
		
		var gz = sqrt( 1 - (gx * gx + gy * gy));
		var tmp : Float4;
		tmp.x = gx * bump;
		tmp.y = gy * bump;
		tmp.z = gz;
		tmp.xyz = (tmp.xyz.normalize() + 1) * 0.5;
		tmp.w = 1;
		out = tmp;
		
	}
})
class NormalMap extends Shader {

	var quad : Polygon;
	
	public function new(c) {
		super(c);
		// simple quad
		quad = new Polygon([new Vector( -1, -1, 0), new Vector(1, -1, 0), new Vector( -1, 1, 0), new Vector(1, 1, 0)], [0, 1, 2, 1, 3, 2]);
		quad.alloc(c);
	}
	
	public function build( tex : Texture, width : Int, height : Int, bump : Float ) {
		var tn = c.createTexture(width, height, TextureFormat.BGRA, true);
		c.setRenderToTexture(tn);
		c.clear();
		init( { }, { tex : tex, dv : 1 / width, du : 1 / height, bump : bump } );
		draw(quad.vbuf, quad.ibuf);
		return tn;
	}
	
	override function dispose() {
		super.dispose();
		quad.dispose();
	}
	
	// bitmap version (run on CPU)
	static inline function tget(x, y, s) {
		return flash.Memory.getByte(((x + y * s) << 2) + 1);
	}
	
	public static function makeNormalMap( b : flash.display.BitmapData, bump : Float ) {
		var nb = new flash.display.BitmapData(b.width, b.height, true, 0);
		flash.Memory.select(b.getPixels(b.rect));
		var Math = Math;
		nb.lock();
		var xmax = b.width - 1, ymax = b.height - 1, stride = b.width;
		for( x in 0...b.width ) {
			var xp = x == 0 ? xmax : x - 1;
			var xn = x == xmax ? 0 : x + 1;
			for( y in 0...b.height ) {
				var yp = y == 0 ? ymax : y - 1;
				var yn = y == ymax ? 0 : y + 1;

				var h00 = tget(xp, yp, stride) / 255.0;
				var h10 = tget(x, yp, stride) / 255.0;
				var h20 = tget(xn, yp, stride) / 255.0;

				var h01 = tget(xp, y, stride) / 255.0;
				var h21 = tget(xn, y, stride) / 255.0;

				var h02 = tget(xp, yn, stride) / 255.0;
				var h12 = tget(x, yn, stride) / 255.0;
				var h22 = tget(xn, yn, stride) / 255.0;
				
		
				// sobel 3x3 operator
				var gx = h00 - h20 + 2 * h01 - 2 * h21 + h02 - h22;
				var gy = h00 + 2 * h10 + h20 - h02 - 2 * h12 - h22;
				var gz = gx * gx + gy * gy;
				if( gz > 1.0 ) gz = 1.0;
				var gz = Math.sqrt(1 - gz);
				var n = new Vector(gx * bump, gy * bump, gz);
				n.normalize();
				var r = Std.int((n.x + 1) * 127.5);
				var g = Std.int((n.y + 1) * 127.5);
				var b = Std.int((n.z + 1) * 127.5);
				nb.setPixel32(x,y,0xFF000000 | (r << 16) | (g << 8) | b);
			}
		}
		nb.unlock();
		return nb;
	}

}