
class DefShader extends format.hxsl.Shader {
	
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
		
		function vertex( mproj : Matrix, cam : Float4 ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			out = tpos;
			fog = 1 - (tpos.z - 10) * 0.01;
			tuv = uv;
			tshade = shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest);
			tmp.a = fog;
			tmp.rgb *= tshade;
			out = tmp;
		}
	}
	
}

class AlphaShader extends format.hxsl.Shader {
	
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
		
		function vertex( mproj : Matrix, cam : Float4 ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			out = tpos;
			fog = 1 - (tpos.z - 10) * 0.01;
			tuv = uv;
			tshade = shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest);
			tmp.a *= fog;
			tmp.rgb *= tshade;
			out = tmp;
		}
	}
	
}

class TransShader extends format.hxsl.Shader {

	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			shade : Float,
		};
		var fog : Float;
		var tuv : Float2;
		var tshade : Float;
		
		function vertex( mproj : Matrix, cam : Float4 ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			out = tpos;
			fog = 1 - (tpos.z - 10) * 0.01;
			tuv = uv;
			tshade = shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest);
			kill(tmp.a - 0.001);
			tmp.a = fog;
			tmp.rgb *= tshade;
			out = tmp;
		}
	}
}

class WaterShader extends format.hxsl.Shader {

	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
			shade : Float,
		};
		var fog : Float;
		var tuv : Float2;
		var tshade : Float;
		
		function vertex( mproj : Matrix, cam : Float4, water : Float4 ) {
			var fpos = pos.xyzw;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w + (sin(pos.x * water.w + water.x) * cos(pos.y * water.w + water.y) + 1) * water.z;
			var tpos = fpos * mproj;
			out = tpos;
			fog = 1 - (tpos.z - 10) * 0.01;
			tuv = uv;
			tshade = shade;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest);
			tmp.a *= fog;
			tmp.rgb *= tshade;
			out = tmp;
		}
	}
}

class DummyShader extends format.hxsl.Shader {
	
	static var SRC = {
		var input : {
			pos : Float3,
			uv : Float2,
		};
		var fog : Float;
		var tuv : Float2;
		
		function vertex( mproj : Matrix, cam : Float4, rpos : Float4, ruv : Float2 ) {
			var fpos = pos.xyzw + rpos;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var tpos = fpos * mproj;
			out = tpos;
			fog = 1 - (tpos.z - 10) * 0.01;
			tuv = uv + ruv;
		}
		
		function fragment( tex : Texture ) {
			var tmp = tex.get(tuv, nearest);
			tmp.a = fog;
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
			delta : Float,
		};
		function vertex( mpos : Float4, cam : Float4, mproj : Matrix, scale : Float ) {
			var fpos = pos.xyzw + mpos;
			var eye = fpos.xy - cam.xy;
			fpos.z -= (eye.x * eye.x + eye.y * eye.y) * cam.w;
			var calc = fpos * mproj;
			calc.z -= 0.0001;
			calc.xy += delta * calc.w * scale;
			out = calc;
		}
		function fragment() {
			out = [0,0,0,0.5];
		}
	};
}