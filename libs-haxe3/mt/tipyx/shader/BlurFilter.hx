package mt.tipyx.shader;

import h2d.filter.Filter;

/**
 * ...
 * @author Tipyx
 */

class BlurShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture			: Sampler2D;
		@param var res				: Vec2;
		@param @const var quality	: Int;
		
		function getLum(c : Vec4):Float {
			var lum = vec4(0.299, 0.587, 0.114, 0.);
			return c.dot(lum);
		}
		
		function fragment() {
			var c = texture.get(input.uv);
			
			var b = vec4(0, 0, 0, 1);
			
			for (i in -quality...quality + 1) {
				b += texture.get(input.uv + (i / res));
			}
			
			output.color = vec4(b.rgb / (1 + quality * 2), c.a);
		}
	}
}

class BlurFilter extends Filter
{
	var pass			: h3d.pass.ScreenFx<BlurShader>;
	
	var quality			: Int;
	
	public function new(quality:Int = 1) 
	{
		super();
		
		this.quality = quality;
		
		pass = new h3d.pass.ScreenFx(new BlurShader());
	}
	
	override function draw( ctx : h2d.RenderContext, t : h2d.Tile ) {
		var out = ctx.textures.allocTarget("blurShaderOutput", ctx, t.width, t.height, false);
		var s = pass.shader;
		s.texture = t.getTexture();
		s.res.set(t.width, t.height);
		s.quality = quality;
		
		ctx.engine.pushTarget(out);
		pass.render();
		ctx.engine.popTarget();
		
		return h2d.Tile.fromTexture(out);
	}
	
}