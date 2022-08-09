package mt.tipyx.shader;

import h2d.filter.Filter;

/**
 * ...
 * @author Tipyx
 */

class SampleShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture	: Sampler2D;
		@param var res		: Vec2;
		
		function fragment() {
			var c = texture.get(input.uv);
			
			output.color = c;
		}
	}
}

class ReverseFilter extends Filter
{
	var pass			: h3d.pass.ScreenFx<SampleShader>;
	
	public function new() 
	{
		super();
		
		throw "DO NOT USE SAMPLE FILTER";
		
		pass = new h3d.pass.ScreenFx(new SampleShader());
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