package fx.gr;
import mt.bumdum.Lib;

import Fight;

private typedef Flyer = { f:Fighter, a:Float, vr:Float, vz:Float, flFall:Bool, life:Int };

class Tornade extends fx.GroupEffect {

	var tornade:Phys;
	var flyers:Array<Flyer>;

	public function new( f, list ) {
		super(f,list);
		caster.playAnim("cast");
		spc = 0.03;
	}

	public override function update() {
		super.update();
		switch(step) {
			case 0:
				updateAura(4,caster.skinBox);
				for( i in 0...2)genRayConcentrate();
				if(coef == 1) {
					caster.skinBox.filters = [];
					caster.playAnim("release");
					nextStep();
					spc = 0;
					initTornade();
				}
			case 1:
				var speed =  8;
				var list = flyers.copy();
				for( o in list ) {
					o.f.root._rotation += o.vr;
					if( !o.flFall ) {
						o.f.z += o.vz;
						o.f.vx = Math.cos(o.a) * speed;
						o.f.vy = Math.sin(o.a) * speed;
						var ta = tornade.getAng(o.f);
						var lim = 0.1;
						var da = Num.mm( -lim, Num.hMod(ta-o.a, 3.14) * 0.1, lim) ;
						o.a = Num.hMod(o.a + da,3.14);
						if( o.f.z < -300 ) {
							o.flFall = true;
							o.f.weight = 2;
						}
					} else {
						if( o.f.z == 0 ) {
							o.f.root._rotation = 0;
							o.f.backToDefault();
							o.f.weight = null;
							o.f.vx = 0;
							o.f.vy = 0;
							o.f.vz = 0;
							flyers.remove(o);
							o.f.damages(o.life,20,_LAir);
						}
					}
				}
				if( list.length == 0 ) nextStep();
			case 2:
				tornade.vx *= 1.1;
				var w = Cs.mcw*0.5;
				if( Math.abs(tornade.x-w) > w+100 ) {
					tornade.kill();
					end();
				}
		}
	}

	function initTornade() {
		// TORNADE
		tornade = new Phys(Scene.me.dm.attach("mcTornade",Scene.DP_FIGHTER));
		tornade.x = Cs.mcw*0.5 + caster.intSide*( Cs.mcw*0.25 - 50 );
		tornade.y = Scene.getPYMiddle();
		tornade.vx = caster.intSide*0.5;
		tornade.ray = 30;
		tornade.dropShadow();
		tornade.updatePos();
		Filt.blur(tornade.root,10,0);
		//
		flyers = [];
		for ( o in list ) {
			if(  o.life == null ) continue;
			var info:Flyer = {
				f:o.t,
				a:o.t.getAng(tornade)+1.57,
				vr:10+Math.random()*30,
				vz:-(1+Math.random()*0.5),
				flFall:false,
				life:o.life,
			}
			flyers.push(info);
		}
	}
}
