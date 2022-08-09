package mt.tipyx.shader;

import h2d.filter.Filter;

/**
 * ...
 * @author Tipyx
 */

class ReverseShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture	: Sampler2D;
		@param var res		: Vec2;
		
		function getLum(c : Vec4):Float {
			var lum = vec4(0.299, 0.587, 0.114, 0.);
			return c.dot(lum);
		}
		
		function fragment() {
			var c = texture.get(input.uv);
			
			var lum = getLum(c);
			
			//output.color = vec4(c.rgb * lum, c.a);
			output.color = vec4(1 - lum, 1 - lum, 1 - lum, c.a);
		}
	}
}

class ReverseFilter extends Filter
{
	var pass			: h3d.pass.ScreenFx<ReverseShader>;
	
	public function new() 
	{
		super();
		
		pass = new h3d.pass.ScreenFx(new ReverseShader());
	}
	
	override function draw( ctx : h2d.RenderContext, t : h2d.Tile ) {
		var out = ctx.textures.allocTarget("reverseShaderOutput", ctx, t.width, t.height, false);
		var s = pass.shader;
		s.texture = t.getTexture();
		s.res.set(t.width, t.height);
		
		ctx.engine.pushTarget(out);
		pass.render();
		ctx.engine.popTarget();
		
		return h2d.Tile.fromTexture(out);
	}
	
}