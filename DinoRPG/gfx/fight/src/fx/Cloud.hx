package fx;

import mt.bumdum.Lib;

class Cloud extends State{

	var flDamage:Bool;
	var caster:Fighter;
	var color:Int;
	var type:Int;

	public function new( f, t, col  ) {
		super();
		caster = f;
		type = t;
		color = col;
		addActor(f);
		spc = 0.01;
	}

	override function init(){
		caster.playAnim("release");

		flDamage = false;
		/*
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
			p.y = Scene.getRandomYPos() * Cs.CZ;
			p.timer = 50;
			p.sleep = Math.random()*20;
			p.setScale(50+Math.random()*200);
			p.fadeType = 0;
			p.root.stop();v
		}
		*/
	}

	public override function update(){
		super.update();
		if( castingWait ) return;

		var w = Cs.mcw*0.5;
		for( i in 0...1 ) {
			var sens = caster.intSide;
			var p = new part.Turner(Scene.me.dm.attach("partCloud", Scene.DP_FIGHTER));
			p.x = w + ( Math.random()*w - 20 ) * sens;
			p.y = Scene.getRandomPYPos();
			p.vx = sens*(5+Math.random()*10);

			p.timer = 40;
			p.root.blendMode = "layer";
			p.root.gotoAndStop(type+1);
			//p.root.smc.smc.gotoAndStop(type+1);
			p.svr = ( 3+Math.random()*10 )*caster.intSide;
			if(color!=null)Col.setColor(p.root,color,Std.random(50)-255);
			p.updatePos();

			switch(type){
				case 1:	// WAVE
					p.vx *= 0.8;
					p.x -= 80*sens;
					p.svr = 0;

					Col.setPercentColor(p.root.smc.smc.smc,Std.random(50),0xFFFFFF);
					p.root.smc.smc.smc._alpha = 75;
					p.setScale(50+Math.random()*80);
					p.root._xscale = sens*p.root._xscale;
			}
		}

		if(!flDamage && coef>0.85){
			flDamage = true;
			for( o in tids )o.t.damages(o.life,20,null);
		}

		if(coef==1)end();
	}
}
