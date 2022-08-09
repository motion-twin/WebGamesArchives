package fx.gr;
import mt.bumdum.Lib;

import Fight;

class LevitRay extends fx.GroupEffect{

	public function new( f, list ) {
		super(f,list);
		caster.playAnim("cast");
		spc = 0.02;
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				updateAura(2,caster.skinBox);
				for( i in 0...2)genRayConcentrate();
				levit(coef,160);
				if(coef==1) {

					caster.skinBox.filters = [];
					caster.playAnim("release");
					nextStep();

					var ex = caster.root._x;
					var ey = caster.root._y;

					for( o in list ){
						var sp = new Sprite( Scene.me.dm.attach("mcRayWater",Scene.DP_FIGHTER) );
						var sx = o.t.root._x;
						var sy = o.t.root._y;
						var dx = sx-ex;
						var dy = sy-ey;

						sp.x = sx;
						sp.y = Scene.getGY(sy);	//CHECK^^
						sp.z = 0;
						sp.root._rotation = Math.atan2(dy,dx)/0.0174;
						sp.root._xscale = Math.sqrt(dx*dx+dy*dy);
						sp.updatePos();
					}
					spc = 0.2;
				}

			case 1:
				if( coef==1 ) {
					for( o in list ) {
						var max = 12;
						for( i in 0...10 ) {
							var p = new mt.bumdum.Phys( o.t.bdm.attach( "partEcume",1) );
							p.x = (Math.random()*2-1) * o.t.ray*0.5;
							p.y = -Math.random()*o.t.height;
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
							p.sleep = Math.random()*10;
							p.root.stop();
							p.root._visible = false;
							p.updatePos();
						}
					}
					//
					damageAll();
					nextStep();
					spc = 0.03;
				}

			case 2:
				levit(1-coef,160);
				if( coef==1 ){
					caster.backToDefault();
					end();
				}
		}
	}
}























