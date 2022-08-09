package r3d;

typedef BaseShader = {
	var currentDX : Int;
	var currentDY : Int;
	var currentDZ : Int;
	var tex(null, set_tex) : h3d.mat.Texture;
	var mproj(null, set_mproj) : h3d.Matrix;
	var cam(null, set_cam) : h3d.Vector;
	var fogPower(null, set_fogPower) : Float;
};

@:skip
class BlockShader extends h3d.Shader {

	public static inline var STRIDE = 6;
	public var currentDX : Int;
	public var currentDY : Int;
	public var currentDZ : Int;
	
}

class DefShader extends BlockShader {
	
	
	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			shade : Float,
		};
		var fog : Float;
		var tuv : Float2;
		var tshade : Float;
		
		function vertex( mproj : Matrix, cam : Float4, fogPower : Float ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			out = tpos;
			fog = 1 - (tpos.z - 10) * fogPower;
			tuv = uv;
			tshade = shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest, mm_linear);
			tmp.a = fog;
			tmp.rgb *= tshade;
			out = tmp;
		}
	}
	
}

class FogColorShader extends BlockShader {
		
	static var SRC = {
		var input : {
			pos : Float3,
		};
		var h : Float;
		
		function vertex( mproj : Matrix, cam : Float4, fogDy : Float, fogTScale : Float ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			out = tpos;
			h = (1 - (tpos.y/tpos.w + 1) * 0.25 - fogDy).sat() * fogTScale;
		}
		
		function fragment( tex : Texture ) {
			out = tex.get([h,0]);
		}
	}
	
	public var fogPower(null, set_fogPower) : Float;
	function set_fogPower(t) return t

}

class AlphaShader0 extends BlockShader {

	public var tex(null, set_tex) : h3d.mat.Texture;
	function set_tex(t) return t

	public var fogPower(null, set_fogPower) : Float;
	function set_fogPower(p) return p
	
	static var SRC = {
		var input : {
			pos : Float3,
		};
		
		function vertex( mproj : Matrix, cam : Float4 ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			out = tpos;
		}
		
		function fragment() {
			out = [1,1,1,1];
		}
	}
	
}

class AlphaShader1 extends BlockShader {
	
	public var fogPower(null, set_fogPower) : Float;
	function set_fogPower(p) return p
	
	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			shade : Float,
		};
		var tuv : Float2;
		var tshade : Float;
		
		function vertex( mproj : Matrix, cam : Float4 ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			out = tpos;
			tuv = uv;
			tshade = shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest);
			tmp.rgb *= tshade;
			out = tmp;
		}
	}
	
}

class AlphaShader2 extends BlockShader {
	
	public var tex(null, set_tex) : h3d.mat.Texture;
	function set_tex(t) return t
	
	static var SRC = {
		var input : {
			pos : Float3,
		};
		var fog : Float;
		
		function vertex( mproj : Matrix, cam : Float4, fogPower : Float ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			out = tpos;
			fog = 1 - (tpos.z - 10) * fogPower;
		}
		
		function fragment() {
			out = [0,0,0,fog];
		}
	}
	
}

class PolyTexShader extends h3d.Shader {

	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
		};
		var tuv : Float2;
		
		function vertex( mproj : Matrix, mpos : Matrix, cam : Float4, uvDelta : Float2, uvScale : Float2, zScale : Float, zDelta : Float ) {
			var fpos = pos.xyzw * mpos;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			tpos.z = tpos.z * zScale + zDelta;
			out = tpos;
			tuv = (uv + uvDelta) * uvScale;
		}
		
		function fragment( tex : Texture, color : Float4 ) {
			out = tex.get(tuv, nearest, wrap) * color;
		}
	}
	
	public function new() {
		super();
		zScale = 1;
		color = new h3d.Vector(1,1,1,1);
		uvScale = new h3d.Vector(1, 1);
	}
}


class StripShader extends h3d.Shader {

	static var SRC = {
		var input : 
		{
			pos : Float3,
			uv : Float2,
		};
		
		var tuv : Float2;
		
		//mproj= worldToCam
		//mpos= camToScreen
		function vertex( mproj : Matrix,  cam : Float4, uvDelta : Float2, uvScale : Float2, from:Float4, to:Float4, ratio:Float,aOfs : Float ) 
		{
			//var STRIP_W = 2.0;
			var rpos = from + pos.z * (to - from);//pos along the line
			var fpos = rpos;
			
			//mk local base
			var eye = fpos.xyz - cam.xyz;
			var eyen = norm(eye);
			var dir = norm(to.xyz - from.xyz);
			
			//comp normal
			var c =  cross(dir.xyz, eyen.xyz);
			var sp = 0.4;//thickness
			var p = pos.x;
			p = (p-0.5) * sin( ratio + aOfs );//make the thing turn
			fpos.xyz += c * sp * p;
			
			//lower bounds by cam w to sim roundness
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			
			out = fpos * mproj;
			tuv = (uv + uvDelta) * uvScale;
		}
		
		function fragment( tex : Texture, color : Float4 ) {
			out = tex.get(tuv, nearest, wrap) * color;
		}
	}
	
	public function new() {
		super();
		color = new h3d.Vector(1,1,1,1);
		uvScale = new h3d.Vector(1, 1);
		uvDelta = new h3d.Vector(0,0);
		from = new h3d.Vector(0, 0, 0);
		to = new h3d.Vector(0, 0, 0);
		ratio = 0;
	}
}

class SharpModelShader extends h3d.Shader {

	static var SRC = {
		var input : {
			pos : Float3,
			norm : Float3,
			uv : Float2,
		};
		var fog : Float;
		var tuv : Float2;
		var tlight : Float;
		
		function vertex( mpos : Matrix, mproj : Matrix, cam : Float4, fogPower : Float, ldir : Float3, ambient : Float ) {
			var fpos = pos.xyzw * mpos;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tnorm = norm * mpos;
			
			var tpos = fpos * mproj;
			out = tpos;
			fog = 1 - (tpos.z - 10) * fogPower;
			tuv = uv;
			tlight = ambient + (1 - ambient) * tnorm.normalize().dot(ldir).max(0);
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv,nearest);
			tmp.a *= fog;
			tmp.rgb *= tlight;
			out = tmp;
		}
	}
	
	public function new() {
		super();
		var dir = new h3d.Vector( -2, -1, -3);
		dir.normalize();
		ambient = 0.7;
		ldir = dir;
	}

}

class ModelShader extends h3d.Shader {

	static var SRC = {
		var input : {
			pos : Float3,
			norm : Float3,
			uv : Float2,
		};
		var fog : Float;
		var tuv : Float2;
		var tlight : Float;
		
		function vertex( mpos : Matrix, mproj : Matrix, cam : Float4, fogPower : Float, ldir : Float3, ambient : Float ) {
			var fpos = pos.xyzw * mpos;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tnorm = norm * mpos;
			
			var tpos = fpos * mproj;
			out = tpos;
			fog = 1 - (tpos.z - 10) * fogPower;
			tuv = uv;
			tlight = ambient + (1 - ambient) * tnorm.normalize().dot(ldir).max(0);
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv);
			tmp.a *= fog;
			tmp.rgb *= tlight;
			out = tmp;
		}
	}
	
	public function new() {
		super();
		var dir = new h3d.Vector( -2, -1, -3);
		dir.normalize();
		ambient = 0.7;
		ldir = dir;
	}

}

class BreaksShader extends h3d.Shader {

	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			shade : Float,
		};
		var tuv : Float2;
		var tshade : Float;
		
		function vertex( mproj : Matrix, mpos : Matrix, cam : Float4, uvMod : Float2, uvDelta : Float2 ) {
			var fpos = pos.xyzw * mpos;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			tpos.z = tpos.z;
			out = tpos;
			tuv = uv % uvMod + uvDelta;
			tshade = shade;
		}
		
		function fragment( tex : Texture, alpha : Float ) {
			var c = tex.get(tuv, nearest, wrap);
			kill(c.a - 0.001);
			c.a *= alpha;
			c.rgb *= tshade;
			out = c;
		}
	}

}

class DummyShader extends h3d.Shader {
	
	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			shade : Float,
		};
		var fog : Float;
		var tuv : Float2;
		var tshade : Float;
		
		function vertex( mproj : Matrix, mpos : Matrix, cam : Float4, fogPower : Float, depthScale : Float, spriteScale : Float2 ) {
			var fpos = pos.xyzw * mpos;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			tpos.xy += ((uv % [1 / 64, 1 / 64]) - [0.5/64,0.5/64]) * spriteScale;
			tpos.z *= depthScale;
			out = tpos;
			fog = 1 - (tpos.z - 10) * fogPower;
			tuv = uv;
			tshade = shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest);
			kill(tmp.a - 0.001);
			tmp.a *= fog;
			tmp.rgb *= tshade;
			out = tmp;
		}
	}

}

class IconShader extends h3d.Shader {

	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			shade : Float,
		};
		var tuv : Float2;
		var tshade : Float;
		
		function vertex( mproj : Matrix, mpos : Matrix, depthScale : Float, spriteScale : Float2 ) {
			var tpos = pos.xyzw * mpos * mproj;
			tpos.z *= depthScale;
			tpos.xy += ((uv % [1 / 64, 1 / 64]) - [0.5/64,0.5/64]) * spriteScale;
			out = tpos;
			tuv = uv;
			tshade = shade < 1 ? shade * shade : shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv,nearest);
			kill(tmp.a - 0.001);
			tmp.rgb *= tshade;
			out = tmp;
		}
	}
}

class TransShader extends BlockShader {

	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			shade : Float,
		};
		var fog : Float;
		var tuv : Float2;
		var tshade : Float;
		
		function vertex( mproj : Matrix, cam : Float4, fogPower : Float ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			out = tpos;
			fog = 1 - (tpos.z - 10) * fogPower;
			tuv = uv;
			tshade = shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest, mm_linear);
			kill(tmp.a - 0.5);
			tmp.a = fog;
			tmp.rgb *= tshade;
			out = tmp;
		}
	}
}

class SpriteShader extends BlockShader {

	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			shade : Float,
		};
		var fog : Float;
		var tuv : Float2;
		var tshade : Float;
		
		function vertex( mproj : Matrix, cam : Float4, fogPower : Float, spriteScale : Float2 ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			tpos.xy += ((uv % [1 / 64, 1 / 64]) - [0.5/64,0.5/64]) * spriteScale;
			out = tpos;
			fog = 1 - (tpos.z - 10) * fogPower;
			tuv = uv;
			tshade = shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest, mm_linear);
			kill(tmp.a - 0.5);
			tmp.a = fog;
			tmp.rgb *= tshade;
			out = tmp;
		}
	}
}

class WaterShader0 extends BlockShader {
	
	public var tex(null, set_tex) : h3d.mat.Texture;
	function set_tex(t) return t

	public var fogPower(null, set_fogPower) : Float;
	function set_fogPower(p) return p

	static var SRC = {
		var input : {
			pos : Float3,
		};
		
		function vertex( mproj : Matrix, cam : Float4, water : Float4 ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w + (sin(pos.x * water.w + water.x) * cos(pos.y * water.w + water.y) + 1) * water.z;
			var tpos = fpos * mproj;
			tpos.z += 0.00002; // prevent some z-fighting with alpha blocks
			out = tpos;
		}
		
		function fragment() {
			out = [1,1,1,1];
		}
	}
}

class WaterShader1 extends BlockShader {

	public var fogPower(null, set_fogPower) : Float;
	function set_fogPower(p) return p
	
	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			shade : Float,
		};
		var tuv : Float2;
		var tshade : Float;
		
		function vertex( mproj : Matrix, cam : Float4, water : Float4 ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w + (sin(pos.x * water.w + water.x) * cos(pos.y * water.w + water.y) + 1) * water.z;
			var tpos = fpos * mproj;
			tpos.z += 0.00002; // prevent some z-fighting with alpha blocks
			out = tpos;
			tuv = uv;
			tshade = shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest, mm_linear);
			tmp.rgb *= tshade;
			out = tmp;
		}
	}
}

class WaterShader2 extends BlockShader {

	public var tex(null, set_tex) : h3d.mat.Texture;
	function set_tex(t) return t
	
	static var SRC = {
		var input : {
			pos : Float3,
		};
		var fog : Float;
		
		function vertex( mproj : Matrix, cam : Float4, fogPower : Float, water : Float4 ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w + (sin(pos.x * water.w + water.x) * cos(pos.y * water.w + water.y) + 1) * water.z;
			var tpos = fpos * mproj;
			tpos.z += 0.00002; // prevent some z-fighting with alpha blocks
			out = tpos;
			fog = 1 - (tpos.z - 10) * fogPower;
		}
		
		function fragment() {
			out = [0,0,0,fog];
		}
	}
}

class TexFogShader extends h3d.Shader {
	
	static var SRC = {
		var input : {
			pos : Float2
		};
		var h : Float;
		function vertex( dy : Float, fogTScale : Float ) {
			h = (1 - pos.y * 0.5 - dy).sat() * fogTScale;
			out = [pos.x * 2 - 1, pos.y * 2 - 1, 0, 1];
		}
		function fragment( tex : Texture ) {
			out = tex.get([h, 0]);
		}
	}
	
}

class FadeShader extends h3d.Shader {
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

class SelectShader extends h3d.Shader {
	static var SRC = {
		var input : {
			pos : Float3,
			delta : Float,
		};
		function vertex( mpos : Float4, size : Float4, cam : Float4, mproj : Matrix, scale : Float ) {
			var fpos = pos.xyzw * size + mpos;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var calc = fpos * mproj;
			calc.z -= 0.00003;
			calc.xy += delta * calc.w * scale;
			out = calc;
		}
		function fragment() {
			out = [1,0.3,0,0.5];
		}
	};
}

class PartShader extends h3d.Shader {
	
	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			size : Float2,
			light : Float,
		};
		var fog : Float;
		var tuv : Float2;
		var tlight : Float;
		
		function vertex( mproj : Matrix,cam : Float4, fogPower : Float ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			tpos.xy += size;
			out = tpos;
			fog = 1 - (tpos.z - 10) * fogPower;
			tuv = uv;
			tlight = light;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest);
			kill(tmp.a - 0.001);
			tmp.a *= fog;
			tmp.rgb *= tlight;
			out = tmp;
		}
	}

}