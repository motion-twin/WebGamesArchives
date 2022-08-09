package fx;

import mt.bumdum.Lib;

class Focus extends State {

	var caster:Fighter;
	var color:Int;
	var ball:flash.MovieClip;

	public function new( f, c) {
		super();
		caster = f;
		color = c;
		addActor(f);
		spc = 0.025;
	}

	override function init(){
		caster.playAnim("cast");
		ball = caster.bdm.attach("mcFocus",Fighter.DP_FRONT);
		ball.blendMode = "add";
		ball._xscale = ball._yscale = 0;
		ball._y = -caster.height*0.5;
		Filt.glow(ball,10,2,color);
	}

	public override function update(){
		super.update();
		if(castingWait) return;
		if( coef < 0.9 && Std.random(2) == 0 ){
			for( i in 0...3 ){
				var d = Fighter.DP_BACK;
				if(Std.random(3)==0)d = Fighter.DP_FRONT;
				var mc = caster.bdm.attach("mcRayConcentrate",d);
				mc._x = 0;
				mc._y = -caster.height*0.5;
				mc._rotation = Math.random()*360;
				mc.blendMode = "add";
				Filt.glow(mc,10,2,color);
			}
			ball._xscale = ball._yscale = coef*200;
		}

		if(coef==1){
			ball.gotoAndPlay("burst");
			end();
		}
	}
}
