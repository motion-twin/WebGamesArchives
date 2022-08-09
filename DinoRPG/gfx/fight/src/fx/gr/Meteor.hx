package fx.gr;
import mt.bumdum.Lib;
import Fight;

typedef Ball = {>Phys, dm:mt.DepthManager};

class Meteor extends fx.GroupEffect {

	var meteors:Array<Ball>;
	
	public function new( f, list ) {
		super(f,list);
		caster.playAnim("cast");
		spc = 0.03;
		meteors = [];
	}

	public override function update() {
		super.update();
		switch(step){
			case 0:
				updateAura(0,caster.skinBox);
				for( i in 0...2)genRayConcentrate();
				if(coef==1){
					//for( i in 0...3 )launchMeteor();
					caster.skinBox.filters = [];
					caster.playAnim("release");
					nextStep();
					spc = 0.015;
				}
			case 1:
				if( coef<0.7 && Std.random(3)==0 )launchMeteor();
				var list = meteors.copy();
				for( sp in list ){
					sp.root.smc._rotation += 8;
					if( sp.z > -sp.ray ){
						var p = new Phys( Scene.me.dm.attach("mcGroundMeteorImpact",Scene.DP_FIGHTER) );
						p.x = sp.x;
						p.y = sp.y;
						sp.kill();
						meteors.remove(sp);
						var mc = Scene.me.dm.attach( "mcOndeFeu", Scene.DP_SHADE );
						mc._x = sp.x;
						mc._y = Scene.getY(sp.y);
						mc._yscale = 50;
					}
				}
				if(coef==1 && meteors.length == 0 ) {
					damageAll();
					end();
				}
		}
	}

	function launchMeteor() {
		var p:Ball  = cast new Phys( Scene.me.dm.attach("mcMeteor",Scene.DP_FIGHTER) );
		p.x = Cs.mcw*0.5 - caster.intSide*(20+Math.random()*150);
		p.y = Scene.getRandomPYPos();
		p.z = - 250;
		p.vx = caster.intSide*(12+Math.random()*5);
		p.vz = 15+Math.random()*5;
		p.ray = 10;

		var a = Math.atan2( p.vz*0.5, p.vx );
		p.root._rotation = a/0.0174;
		p.dm  = new mt.DepthManager(p.root);
		p.dropShadow();
		p.updatePos();
		meteors.push(p);
	}

}
