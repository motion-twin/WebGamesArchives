package mt.tipyx.shader;

import h2d.filter.Filter;
import h2d.Scene;

/**
 * ...
 * @author Tipyx
 */

class LightScatShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@const var numSamples : Int;
		
		@param var exposure : Float;
		@param var decay : Float;
		@param var density : Float;
		@param var weight : Float;
		@param var lightPos : Vec2;
		@param var texture : Sampler2D;
		
		function getLum(c : Vec4):Float {
			var lum = vec4(0.299, 0.587, 0.114, 0.);
			return c.dot(lum);
		}
		
		function fragment() {
			var dtCoord = input.uv - lightPos.xy;
			var coord = input.uv;
			dtCoord *= 1.0 / numSamples * density;
			
			var decayValue = 1.0;
			
			var color  = vec4(0, 0, 0, 1);
			var sample = vec4(0);
			for (i in 0...numSamples) {
				coord -= dtCoord;
				sample = texture.get(coord) * decayValue * weight;
				color += sample;
				decayValue *= decay;
			}
			color *= exposure;
			color.a = 1.;
			
			output.color = color;				
		}
	}
	
	public function new() {
		super();
		numSamples = 30;
		exposure = 0.0034;
		decay = 1.0;
		density = 0.84;
		weight = 5.65;
	}
}

@:access(h2d.Sprite)
class LightScat extends h3d.pass.ScreenFx<LightScatShader> {
	var light				: h2d.Sprite;
	public var arObstacles	: Array<h2d.Sprite>;
	
	var blur				: h3d.pass.Blur;
	var blockingColor		: h3d.Vector;
	var tmpColor			: h3d.Vector;
	
	var sp					: h2d.col.Point;
	var offsetX				: Float;
	var offsetY				: Float;
	
	public var power		: Float;
	
	public function new(light:h2d.Sprite, arObstacles:Array<h2d.Sprite>, power:Float = 0.0034) {
		this.power = power;
		this.light = light;
		this.arObstacles = arObstacles;
		
		blur = new h3d.pass.Blur(2, 2);
		
		blockingColor = new h3d.Vector(0, 0, 0, 1);
		tmpColor = new h3d.Vector();
		blur = new h3d.pass.Blur(2, 2);
		
		sp = new h2d.col.Point();
		
		super(new LightScatShader());
	}

	public function apply(ctx:h2d.RenderContext, ?point:h2d.col.Point = null) {
		var b = light.getBounds();
		b.addBounds(h2d.col.Bounds.fromValues(0, 0, ctx.engine.width, ctx.engine.height));
		
		var targetA = ctx.textures.allocTarget("gameA", ctx, 
			Std.int(b.width) >> 1, Std.int(b.height) >> 1, false);
			
		var targetB = ctx.textures.allocTarget("gameB", ctx, 
			Std.int(b.width) >> 1, Std.int(b.height) >> 1, false);
			
		ctx.pushTarget(targetA, Std.int(b.xMin), Std.int(b.yMin), Std.int(b.width), Std.int(b.height));
		ctx.engine.clear(0xFF000000);
		//ctx.engine.clear(0xFF000000);
		
		light.drawRec(ctx);
		for (c in arObstacles) {
			drawObstacle(c, ctx);
		}
		
	// BLUR
		blur.apply(targetA, ctx.textures.allocTarget("tmpBlur", ctx, ctx.engine.width >> 1, ctx.engine.height >> 1, false));
	// SCATTER
		shader.texture = targetA;
		if (point == null) {
			sp.x = light.x;
			sp.y = light.y;
			sp = light.parent.localToGlobal(sp);
		}
		else
			sp = point;
		shader.lightPos.set((sp.x - b.xMin) / (b.width), (sp.y - b.yMin) / b.height);
		shader.exposure = power;
		engine.pushTarget(targetB);
		render();
		engine.popTarget();
		
	 //RENDER
		offsetX = b.xMin < 0 ? b.xMin : (b.width > ctx.engine.width ? b.width - ctx.engine.width : 0);
		offsetY = b.yMin < 0 ? b.yMin : (b.height > ctx.engine.height ? b.height - ctx.engine.height : 0);
		
		h3d.pass.Copy.run(targetB, null, h2d.BlendMode.Add, new h3d.Vector(-offsetX / b.width, -offsetY / b.height));
		ctx.popTarget();
	}
	
	function drawObstacle(obj : h2d.Sprite, ctx) {
		var d = null;
		if (Type.getSuperClass(Type.getClass(obj)) == h2d.Drawable) {
			d = cast(obj, h2d.Drawable);
		}
		if (d == null) {
			obj.drawRec(ctx);
			for (c in obj.childs)
				drawObstacle(c, ctx);
		}
		else {
			tmpColor.load(d.color);
			d.color.load(blockingColor);
			d.drawRec(ctx);
			d.color.load(tmpColor);
		}
	}
}