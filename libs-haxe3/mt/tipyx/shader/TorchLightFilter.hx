package mt.tipyx.shader;

import h2d.filter.Filter;

/**
 * ...
 * @author Tipyx
 */

class TorchLightShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture	: Sampler2D;
		@param var res			: Vec2;
		@param var mX			: Float;
		@param var mY			: Float;
		@param var maxDist		: Float;
		@param var minDist		: Float;
		@param var alphaGlobal	: Float;
		
		function getLum(c : Vec4):Float {
			var lum = vec4(0.299, 0.587, 0.114, 0.);
			return c.dot(lum);
		}
		
		function dist(ax:Float, ay:Float, bx:Float, by:Float):Float {
			return sqrt((ax - bx) * (ax - bx) + (ay - by) * (ay - by));
		}
		
		function fragment() {
			var c = texture.get(input.uv);
			
			var lum = getLum(c);
			
			var d = dist(input.uv.x * res.x, input.uv.y * res.y, mX, mY);
			
			var t = 1 - ((d - minDist) / (maxDist - minDist));
			
			output.color = vec4(clamp(t, alphaGlobal, 1.) * c.rgb, c.a);
		}
	}
}

class TorchLightFilter extends Filter
{
	var pass			: h3d.pass.ScreenFx<TorchLightShader>;
	
	var mX				: Float;
	var mY				: Float;
	
	var maxDist			: Float;
	var minDist			: Float;
	var alphaGlobal		: Float;
	
	public function new(maxDist:Float, ?minDist:Float = 0, ?alphaGlobal:Float = 0) 
	{
		super();
		
		this.maxDist = maxDist;
		this.minDist = minDist;
		this.alphaGlobal = alphaGlobal;
		
		pass = new h3d.pass.ScreenFx(new TorchLightShader());
	}
	
	override function draw( ctx : h2d.RenderContext, t : h2d.Tile ) {
		var out = ctx.textures.allocTarget("torchLightShaderOutput", ctx, t.width, t.height, false);
		var s = pass.shader;
		s.texture = t.getTexture();
		s.res.set(t.width, t.height);
		s.maxDist = maxDist;
		s.minDist = minDist;
		s.alphaGlobal = alphaGlobal;
		
		s.mX = mX;
		s.mY = mY;
		
		ctx.engine.pushTarget(out);
		pass.render();
		ctx.engine.popTarget();
		
		return h2d.Tile.fromTexture(out);
	}
	
	public function update(mX:Float, mY:Float) {
		this.mX = mX;
		this.mY = mY;
	}
	
}