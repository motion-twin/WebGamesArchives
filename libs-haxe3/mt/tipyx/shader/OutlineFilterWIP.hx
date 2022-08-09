package mt.tipyx.shader;

import h2d.filter.Filter;

/**
 * ...
 * @author Tipyx
 */

class OutlineShader extends h3d.shader.ScreenShader { // WIP OUTLINE
	static var SRC = {
		@param var texture	: Sampler2D;
		@param var res		: Vec2;
		@param var diff		: Float;
		
		function getLum(c : Vec4):Float {
			var lum = vec4(0.299, 0.587, 0.114, 0.);
			return c.dot(lum);
		}
		
		function fragment() {
			var c = texture.get(input.uv);
			
			var l = getLum(c);
			
			var cL = getLum(texture.get(vec2(input.uv.x - 1 / res.x, input.uv.y)));
			var cR = getLum(texture.get(vec2(input.uv.x + 1 / res.x, input.uv.y)));
			var cT = getLum(texture.get(vec2(input.uv.x, input.uv.y - 1 / res.y)));
			var cD = getLum(texture.get(vec2(input.uv.x, input.uv.y + 1 / res.y)));
			
			var mL = (abs(l - cL) <= diff) ? 1 : 0;
			var mR = (abs(l - cR) <= diff) ? 1 : 0;
			var mT = (abs(l - cT) <= diff) ? 1 : 0;
			var mD = (abs(l - cD) <= diff) ? 1 : 0;
			
			output.color = vec4(c.rgb * mL * mR * mT * mD, c.a);
			//output.color = c;
			//output.color = mL;
		}
	}
}

class OutlineFilter extends Filter
{
	var pass			: h3d.pass.ScreenFx<OutlineShader>;
	
	public function new() 
	{
		super();
		
		#if !debug
		throw "STILL IS WIP";
		#end
		
		pass = new h3d.pass.ScreenFx(new OutlineShader());
	}
	
	override function draw( ctx : h2d.RenderContext, t : h2d.Tile ) {
		var out = ctx.textures.allocTarget("outlineShaderOutput", ctx, t.width, t.height, false);
		var s = pass.shader;
		s.texture = t.getTexture();
		s.res.set(t.width, t.height);
		s.diff = 0.05;
		
		ctx.engine.pushTarget(out);
		pass.render();
		ctx.engine.popTarget();
		
		return h2d.Tile.fromTexture(out);
	}
	
}