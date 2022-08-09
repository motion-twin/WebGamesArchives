package mt.tipyx.shader;

import h2d.filter.Filter;

/**
 * ...
 * @author Tipyx
 */

class ColorShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture	: Sampler2D;
		@param var time		: Float;
		@param var v		: Vec4;
		
		function getLum(c : Vec4):Float {
			var lum = vec4(0.299, 0.587, 0.114, 0.);
			return c.dot(lum);
		}
		
		function fragment() {
			var c = texture.get(input.uv);
			
			var l = getLum(c);
			
			c = vec4(v.rgb * l, c.a);
			
			output.color = c;
		}
	}
}
 
class ColorFilter extends Filter {
	
	var pass	: h3d.pass.ScreenFx<ColorShader>;
	
	var cr		: Int;
	var cg		: Int;
	var cb		: Int;
	
	public function new(col:Int) 
	{
		super();
		
		cr = (col >> 16) & 0xFF;
		cg = (col >> 8) & 0xFF;
		cb = col & 0xFF;
		
		pass = new h3d.pass.ScreenFx(new ColorShader());
	}
	
	override function draw( ctx : h2d.RenderContext, t : h2d.Tile ) {
		var out = ctx.textures.allocTarget("colorShaderOutput", ctx, t.width, t.height, false);
		var s = pass.shader;
		s.texture = t.getTexture();
		s.v.set(cr / 0xFF, cg / 0xFF, cb / 0xFF, 1);
		
		ctx.engine.pushTarget(out);
		pass.render();
		ctx.engine.popTarget();
		
		return h2d.Tile.fromTexture(out);
	}
	
}