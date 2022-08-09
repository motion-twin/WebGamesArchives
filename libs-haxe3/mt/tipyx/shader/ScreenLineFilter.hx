package mt.tipyx.shader;

import h2d.filter.Filter;

/**
 * ...
 * @author Tipyx
 */

class ScreenLineShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture		: Sampler2D;
		@param var time			: Float;
		@param var res			: Vec2;
		
		@param var speed		: Float;
		@param var minAlpha		: Float;
		@param var thickness	: Float;
		@param var spacing		: Float;
		
		function fragment() {
			var c = texture.get(input.uv);
			
			var b = (((input.uv.y * res.y) + time * 30 * speed) % spacing > thickness) ? 1 : 0;
			
			var t = b * 2;
			
			//output.color = vec4(c.rgb * (b ? 0.95 : 1), c.a);
			output.color = vec4(b * minAlpha * c.rgb + (1 - b) * c.rgb, c.a);
		}
	}
}

class ScreenLineFilter extends Filter
{
	var pass 			: h3d.pass.ScreenFx<ScreenLineShader>;
	var speed			: Float;
	var minAlpha		: Float;
	var thickness		: Float;
	var spacing			: Float;

	public function new(newSpeed:Float = 1, newMinAlpha:Float = 0.75, newThickness:Float = 5, newSpacing:Null<Float> = null) 
	{
		super();
		
		this.speed = newSpeed;
		this.minAlpha = newMinAlpha;
		this.thickness = newThickness;
		if (newSpacing == null)
			spacing = thickness * 2;
		else
			this.spacing = newSpacing;
		
		if (thickness >= spacing)
			throw "ScreenLineFilter : THICKNESS IS LARGER THAN SPACING";
		
		pass = new h3d.pass.ScreenFx(new ScreenLineShader());
	}
	
	override function draw( ctx : h2d.RenderContext, t : h2d.Tile ) {
		var out = ctx.textures.allocTarget("screenLineShaderOutput", ctx, t.width, t.height, false);
		var s = pass.shader;
		s.texture = t.getTexture();
		s.res.set(t.width, t.height);
		s.time = ctx.time;
		s.speed = speed;
		s.minAlpha = minAlpha;
		s.thickness = thickness;
		s.spacing = spacing;
		
		ctx.engine.pushTarget(out);
		pass.render();
		ctx.engine.popTarget();
		
		return h2d.Tile.fromTexture(out);
	}
	
}