package mt.tipyx.shader;

import h2d.filter.Filter;
import h2d.Scene;

/**
 * ...
 * @author Tipyx
 */

class BlurFFVIShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture	: Sampler2D;
		@param var time		: Float;
		@param var res		: Vec2;
		
		@param var pOffset	: Float;
		
		function fragment() {
			var bc = texture.get(input.uv);
			
			var ratio = (1 + sin(time)) * 0.5;
			
			var p = pOffset * ratio;
			
			var offset = (input.uv * res) % vec2(p);
			
			var v = input.uv - offset / res;
			
			var c = texture.get(v);
			
			output.color = c;
		}
	}
}

class BlurFFVIFilter extends Filter
{
	var pass					: h3d.pass.ScreenFx<BlurFFVIShader>;
	
	var pOffset					: Int;
	var speed					: Float;
	var numLoop					: Null<Float>;
	var spr						: Null<h2d.Sprite>;
	
	var time					: Float;
	
	public function new(pOffset:Int, ?speed:Float = 1, ?numLoop:Null<Float> = null, ?spr:Null<h2d.Sprite> = null) {
		super();
		
		this.pOffset = pOffset;
		this.speed = speed;
		this.numLoop = numLoop;
		this.spr = spr;
		
		if (numLoop != null && spr == null)
			throw "Sprite can't be null if numLoop != null !";
		
		time = -3.14 * 0.5;
		
		pass = new h3d.pass.ScreenFx(new BlurFFVIShader());
	}
	
	override function draw( ctx : h2d.RenderContext, t : h2d.Tile ) {
		var out = ctx.textures.allocTarget("blurFFVIShaderOutput", ctx, t.width, t.height, false);
		var s = pass.shader;
		s.texture = t.getTexture();
		s.res.set(t.width, t.height);
		s.time = time;
		s.pOffset = pOffset;
		
		ctx.engine.pushTarget(out);
		pass.render();
		ctx.engine.popTarget();
		
		time += ctx.elapsedTime * speed;
		
		return h2d.Tile.fromTexture(out);
	}
	
	/**
	 * Only usefull if numloop != null
	 */
	public function update() {
		if (numLoop != null && time > numLoop * 3.1415 / speed)
			spr.filters.remove(this);
	}
	
}