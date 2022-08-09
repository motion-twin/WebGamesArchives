package fx;

import mt.bumdum.Lib;

class Generate extends State {

	var caster:Fighter;
	var color:Int;
	var ball:flash.MovieClip;
	var strength : Float;
	var radius : Float;
	public function new( f, c, power = 1., radius = 1.) {
		super();
		caster = f;
		color = c;
		addActor(f);
		strength = power;
		this.radius = radius;
		spc = 0.030;
	}

	override function init() {
		caster.playAnim("cast");
		ball = caster.bdm.attach("mcFocus", Fighter.DP_FRONT);
		ball.blendMode = "add";
		ball._xscale = ball._yscale = 0;
		ball._y = -caster.height * .5;
		Filt.glow(ball, 10, 2, color);
	}

	public override function update(){
		super.update();
		if(castingWait) return;
		if( coef < 0.9 && Std.random(2) == 0 ) {
			for( i in 0...3 ) {
				var d = Fighter.DP_BACK;
				if(Std.random(3) == 0) d = Fighter.DP_FRONT;
				var mc = caster.bdm.attach("mcRayGenerate", d);
				mc._x = 0;
				mc._y = -caster.height * .5;
				mc._rotation = Math.random() * 360;
				mc._xscale = mc._yscale = radius * 100;
				mc.blendMode = "add";
				Filt.glow(mc, 10, 2, color);
			}
			ball._xscale = ball._yscale = coef * strength * 100;
		}

		if(coef == 1) {
			ball.gotoAndPlay("burst");
			end();
		}
	}
}
