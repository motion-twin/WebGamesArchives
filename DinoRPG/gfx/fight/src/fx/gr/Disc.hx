package fx.gr;
import mt.bumdum.Lib;

import Fight;

typedef Vac = {>Phys,t:Fighter};

class Disc extends fx.GroupEffect{

	var discs:Array<Vac>;

	public function new( f, list ) {
		super(f,list);
		caster.playAnim("cast");
		spc = 0.03;

		discs = [];
		var id = 0;
		for( o in list ){
			var disc:Vac = cast new Phys( Scene.me.dm.attach("mcDisc",Scene.DP_FIGHTER) );
			disc.x = caster.x;
			disc.y = caster.y+0.2*id;
			disc.z = -((caster.height-caster.z)+30);
			disc.t = o.t;
			disc.setScale(0);
			disc.ray = 25 ;
			id++;
			discs.push(disc);

			Filt.glow(disc.root,6,1,0xFFFFFF,true);
			Filt.glow(disc.root,2,4,0xFFFFFF);
			Filt.glow(disc.root,8,2,0x66BBFF);
		}
	}

	public function getDiscHeight(){
		return (caster.height-caster.z)+30;
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				updateAura(4,caster.skinBox);
				for( i in 0...2)genRayConcentrate();

				var id = 0;
				var dh = getDiscHeight();

				for( p in discs ){
					p.z = -( dh+25*id*coef);
					p.setScale( coef*100 );
					p.root.smc.smc._rotation += 23;
					id++;
				}

				if(coef==1){
					caster.skinBox.filters = [];
					caster.playAnim("release");
					nextStep();
					spc = 0.07;
					for(p in discs){
						p.dropShadow();
						p.updatePos();
					}
				}

			case 1:
				var id = 0;
				var dh = getDiscHeight();

				for( p in discs ){
					var th = (p.t.z - p.t.height*0.5);

					p.x = caster.x*(1-coef) + p.t.x*coef;
					p.y = caster.y*(1-coef) + p.t.y*coef;
					p.z =  th*coef -(dh+25*id)*(1-coef)  ;
					p.root.smc.smc._rotation += 23;
					id++;

					var mc = Scene.me.dm.attach("mcDiscShade",Scene.DP_SHADE);
					mc._x = p.root._x;
					mc._y = p.root._y;
				}
				if(coef==1){
					for( p in discs )p.kill();
					damageAll(_LAir);
					end();
				}
		}
	}
}
