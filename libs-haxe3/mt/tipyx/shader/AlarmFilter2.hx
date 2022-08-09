package mt.tipyx.shader;

import h2d.filter.Filter;

/**
 * ...
 * @author Tipyx
 */

class AlarmShader2 extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture	: Sampler2D;
		@param var time		: Float;
		@param var v2		: Vec4;
		@param var v3		: Vec4;
		@param var b		: Float;
		
		function getLum(c : Vec4):Float {
			var lum = vec4(0.299, 0.587, 0.114, 0.);
			return c.dot(lum);
		}
		
		function fragment() {
			var c1 = texture.get(input.uv);
			var lc = getLum(c1);
			
			var c2 = vec4(lc * v2.rgb, c1.a);
			
			c1 = vec4(b * c1.rgb + (1 - b) * lc * v3.rgb, c1.a);
			
			output.color = mix(c1, c2, (1 + sin(time)) * 0.5);
		}
	}
}
 
class AlarmFilter2 extends Filter {
	
	var pass	: h3d.pass.ScreenFx<AlarmShader2>;
	
	var speed	: Float;
	
	var c1r		: Int;
	var c1g		: Int;
	var c1b		: Int;
	
	var col2	: Null<Int>;
	var c2r		: Int;
	var c2g		: Int;
	var c2b		: Int;
	
	var time	: Float;

	public function new(speed:Float = 1, col1:Int, ?col2:Null<Int>) 
	{
		super();
		this.col2 = col2;
		
		this.speed = speed;
		
		c1r = (col1 >> 16) & 0xFF;
		c1g = (col1 >> 8) & 0xFF;
		c1b = col1 & 0xFF;
		
		c2r = col2 == null ? 0xFF : (col2 >> 16) & 0xFF;
		c2g = col2 == null ? 0xFF : (col2 >> 8) & 0xFF;
		c2b = col2 == null ? 0xFF : col2 & 0xFF;
		
		time = -3.14 * 0.5;
		
		pass = new h3d.pass.ScreenFx(new AlarmShader2());
	}
	
	override function draw( ctx : h2d.RenderContext, t : h2d.Tile ) {
		var out = ctx.textures.allocTarget("alarmShaderOutput", ctx, t.width, t.height, false);
		var s = pass.shader;
		s.texture = t.getTexture();
		s.time = time;
		s.v2.set(c1r / 0xFF, c1g / 0xFF, c1b / 0xFF, 1);
		s.v3.set(c2r / 0xFF, c2g / 0xFF, c2b / 0xFF, 1);
		s.b = col2 == null ? 1 : 0;
		
		time += ctx.elapsedTime * speed;
		
		ctx.engine.pushTarget(out);
		pass.render();
		ctx.engine.popTarget();
		
		return h2d.Tile.fromTexture(out);
	}
	
}