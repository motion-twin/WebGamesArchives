package fx;

import mt.bumdum.Lib;

class Swamp extends State{//}

	var caster:Fighter;

	var swamp:flash.MovieClip;
	var sdm:mt.DepthManager;

	public function new( f ) {
		super();
		caster = f;
		addActor(f);
		spc = 0.015;


	}


	override function init(){
		caster.playAnim("release");
		swamp = Scene.me.dm.empty(Scene.DP_SHADE);
		swamp._alpha = 50;
		swamp.blendMode = "layer";
		Filt.blur(swamp,12,6);

		sdm = new mt.DepthManager(swamp);


		var max = 42;
		var w = Cs.mcw*0.5;
		for( i in 0...max ){
			var p = new mt.bumdum.Phys(sdm.attach("mcSwamp",0));
			p.x = w+Math.random()*w*caster.intSide;
			p.y = Scene.getRandomPYPos();
			p.timer = 50;
			p.sleep = Math.random()*20;
			p.setScale(50+Math.random()*200);
			p.fadeType = 0;
			p.root.stop();
		}

	}


	public override function update(){
		super.update();
		if(castingWait)return;


		if(coef==1)end();

	}





//{
}























