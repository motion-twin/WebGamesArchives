package mt.tipyx.shader;

import h2d.filter.Filter;

/**
 * ...
 * @author Tipyx
 */

class TestShader extends h3d.shader.ScreenShader { // WIP : LIGHT SCATTERING
	static var SRC = {
		@param var texture	: Sampler2D;
		@param var res		: Vec2;
		
		function getLum(c : Vec4):Float {
			var lum = vec4(0.299, 0.587, 0.114, 0.);
			return c.dot(lum);
		}
		
		function fragment() {
			var c = texture.get(input.uv);
			
			var l = getLum(c);
			
			output.color = c;
		}
	}
}

class TestFilter extends Filter
{
	var pass			: h3d.pass.ScreenFx<TestShader>;
	
	public function new() 
	{
		super();
		
		pass = new h3d.pass.ScreenFx(new TestShader());
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

//package mt.tipyx.shader;
//
//import h2d.filter.Filter;
//
///**
 //* ...
 //* @author Tipyx
 //*/
//
//class TestShader extends h3d.shader.ScreenShader {
	//static var SRC = {
		//@param var texture	: Sampler2D;
		//@param var res		: Vec2;
		//
		//function getLum(c : Vec4):Float {
			//var lum = vec4(0.299, 0.587, 0.114, 0.);
			//return c.dot(lum);
		//}
		//
		//function fragment() {
			//var c = texture.get(input.uv);
			//
			//var l = getLum(c);
			//
			//output.color = c;
		//}
	//}
//}
//
//class TestFilter extends Filter
//{
	//var pass			: h3d.pass.ScreenFx<TestShader>;
	//
	//public function new() 
	//{
		//super();
		//
		//pass = new h3d.pass.ScreenFx(new TestShader());
	//}
	//
	//override function draw( ctx : h2d.RenderContext, t : h2d.Tile ) {
		//var out = ctx.textures.allocTarget("reverseShaderOutput", ctx, t.width, t.height, false);
		//var s = pass.shader;
		//s.texture = t.getTexture();
		//s.res.set(t.width, t.height);
		//
		//ctx.engine.pushTarget(out);
		//pass.render();
		//ctx.engine.popTarget();
		//
		//return h2d.Tile.fromTexture(out);
	//}
	//
//}