package fx.gr;
import mt.bumdum.Lib;

import Fight;

class WaterCanon extends fx.GroupEffect {
	
	var listMc:Array<flash.MovieClip>;
	var canon:Part;
	var trg:Fighter;
	var flaque:flash.MovieClip;
	var cdm:mt.DepthManager;
	var fdm:mt.DepthManager;

	public function new( f, list ) {
		super(f,list);
		trg = list[0].t;
		var tx = Cs.mcw*0.5 - 20;
		var ty = trg.y+0.2;
		goto(tx, ty);
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				caster.updateMove(coef);
				if(coef==1){
					caster.setSens(1);

					nextStep();
					caster.playAnim("release");

					canon = new Part(Scene.me.dm.attach("mcWaterCanon",Scene.DP_FIGHTER));
					canon.x = caster.x;
					canon.y = caster.y-0.1;
					canon.z = -caster.height;
					//canon.root._xscale = caster.intSide*100;
					cdm = new mt.DepthManager(canon.root);


					spc = 0.03;

					flaque = Scene.me.dm.empty(Scene.DP_SHADE);
					flaque._alpha = 40;
					flaque.blendMode = "layer";
					fdm = new mt.DepthManager(flaque);
					Filt.glow(flaque,2,4,0xFFFFFF);

				}

			case 1:
				if(! trg.haveProp(_PStatic) )
					trg.x += Math.random()*3 * caster.intSide;
				var tx = trg.x+(trg.z-trg.height)*0.5;
				var ty = trg.y+(trg.z-trg.height)*0.5;
				var px = caster.x+(caster.z-caster.height)*0.5;
				var py = caster.y+(caster.z-caster.height)*0.5;

				canon.z = caster.z-caster.height;

				var dx = tx-px;
				var dy = ty-py;

				var a = Math.atan2(dy,dx);
				var dist = Math.sqrt(dx*dx+dy*dy);

				//canon.root.smc._x = Math.abs( caster.x - trg.x );
				canon.root.smc._x = Math.abs( caster.x - trg.x );
				canon.root._rotation = a/0.0174;


				// GOUTTE
				var p = new mt.bumdum.Phys( cdm.attach( "partWater",0) );
				p.x = Math.random()*5;
				p.y = (Math.random()*2-1)*10;
				p.vx = Math.random()*(3+Math.random()*5);
				p.timer = 10+Math.random()*20;
				p.fadeType =  0;
				p.root._rotation = Math.random()*360;
				p.vr = (Math.random()*2-1)*5;
				p.fr = 0.98;
				p.setScale(50+Math.random()*100);

				// ECUMES
				var p = new mt.bumdum.Phys( cdm.attach( "partEcume",1) );
				p.x = Math.abs(caster.x-trg.x) + (Math.random()*2-1)*2;
				p.y = (Math.random()*2-1)*10;
				p.vx =  Math.random()*5;
				p.vy = -Math.random()*3;
				p.weight = 0.1+Math.random()*0.2;
				p.timer = 10+Math.random()*10;
				p.fadeType =  0;
				p.root._rotation = Math.random()*360;
				p.vr = (Math.random()*2-1)*5;
				p.fr = 0.98;
				p.frict= 0.97;
				p.setScale(50+Math.random()*50);
				p.root.smc.gotoAndStop(p.root.smc._totalframes);

				// FLAQUE
				if(Std.random(3)==0){
					var mc = fdm.attach("mcFlaque",0);
					mc._x = trg.x+Math.random()*15;
					mc._y = trg.root._y+(Math.random()*2-1)*15;
					mc._xscale = mc._yscale = 50+Math.random()*100;
				}
				
				if(coef==1){
					canon.root.smc.gotoAndPlay("endAnim");
					nextStep();
					canon.timer = 20;
					canon.fadeLimit = 5;
					if(  list[0].life != null )
						trg.damages( list[0].life,30 );

					spc = 0.1;
				}
			case 2:
				if(coef==1){
					spc = caster.initReturn();
					caster.playAnim("run");
					nextStep();
				}
			case 3:
				caster.updateMove(coef);
				if(coef==1){
					caster.backToDefault();
					flaque.removeMovieClip();
					end();
				}
		}
	}

	function initLava(){
		listMc = [];
		for ( o in list ) {
			if(  o.life == null ) continue;
			var mc = o.t.bdm.attach("mcLava",Fighter.DP_BACK);
			Col.setPercentColor(o.t.skin,100,0);
			o.t.shake = 20;
			listMc.push(mc);
		}
	}
}
