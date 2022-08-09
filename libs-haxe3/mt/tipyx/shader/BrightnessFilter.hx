package mt.tipyx.shader;

import h2d.filter.Filter;

/**
 * ...
 * @author Tipyx
 */

class BrightnessShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture	: Sampler2D;
		@param var res		: Vec2;
		@param var prct		: Float;
		
		function getLum(c : Vec4):Float {
			var lum = vec4(0.299, 0.587, 0.114, 0.);
			return c.dot(lum);
		}
		
		function fragment() {
			var c = texture.get(input.uv);
			
			var l = getLum(c);
			
			c.rgb /= c.a;
			c.rgb += prct / 100;
			c.rgb *= c.a;
			
			output.color = c;
		}
	}
}

class BrightnessFilter extends Filter
{
	var pass			: h3d.pass.ScreenFx<BrightnessShader>;
	
	var prct			: Float;
	
	public function new(prct:Float) 
	{
		super();
		
		this.prct = prct;
		
		pass = new h3d.pass.ScreenFx(new BrightnessShader());
	}
	
	override function draw( ctx : h2d.RenderContext, t : h2d.Tile ) {
		var out = ctx.textures.allocTarget("brightnessShaderOutput", ctx, t.width, t.height, false);
		var s = pass.shader;
		s.texture = t.getTexture();
		s.res.set(t.width, t.height);
		s.prct = prct;
		
		ctx.engine.pushTarget(out);
		pass.render();
		ctx.engine.popTarget();
		
		return h2d.Tile.fromTexture(out);
	}
	
}