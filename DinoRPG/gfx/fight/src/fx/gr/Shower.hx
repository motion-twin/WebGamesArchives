package fx.gr;
import mt.bumdum.Lib;

import Fight;

typedef Rain = {>Phys, ox:Float, oy:Float};

class Shower extends fx.GroupEffect{

	var rains:Array<Rain>;
	var type:Int;

	public function new( f, list, type ) {
		super(f,list);
		this.type = type;
		caster.playAnim("cast");
		spc = 0.03;
	}

	public override function update() {
		super.update();
		switch(step) {
			case 0:
				var aura = [2,0][type];
				updateAura(aura,caster.skinBox);
				for( i in 0...2)genRayConcentrate();
				if(coef == 1) {
					caster.skinBox.filters = [];
					caster.playAnim("release");
					nextStep();
					spc = 0.015;
					rains = [];
				}

			case 1:

				// GOUTTES DE PLUIE
				if(coef < 0.8){
					for( i in 0...2 ){
						var w = Cs.mcw * 0.5;
						var link = ["mcRain","mcBraise"][type];
						var p:Rain = cast new Phys( Scene.me.dm.attach( link, Scene.DP_FIGHTER ) );
						p.x = w + (Math.random() * w - 50)*caster.intSide;
						p.y = Scene.getRandomPYPos();
						p.z = -500;
						p.vz = 50 + Math.random() * 20;
						p.vx = (5 + Math.random()) * caster.intSide;
						p.updatePos();
						p.ox = p.root._x;
						p.oy = p.root._y;
						rains.push(p);
						switch(type){
							case 0:
							case 1:
								//p.root._rotation = Math.random()*360;
								p.root.gotoAndStop(Std.random(p.root._totalframes)+1);
						}
					}
				}

				// LISTE UPDATE
				var list = rains.copy();
				for( p in list ) {
					var dx = p.root._x - p.ox;
					var dy = p.root._y - p.oy;
					var mc = p.root;
					if(type == 1) mc = mc.smc;
					mc._xscale = Math.sqrt(dx*dx+dy*dy);
					mc._rotation = Math.atan2(dy,dx)/0.0174;

					p.ox = p.root._x;
					p.oy = p.root._y;

					if(p.z == 0) {
						var link = ["mcPloc","mcPlocBraise"][type];
						var mc = Scene.me.dm.attach(link,Scene.DP_SHADE);
						mc._x = p.root._x;
						mc._y = p.root._y;
						rains.remove(p);
						p.kill();
					}
				}

				if( coef == 1 ) {
					for( p in list )p.kill();
					damageAll();
					end();
				}
		}
	}
}























