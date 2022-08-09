package fx.gr;
import mt.bumdum.Lib;

import Fight;

typedef Pro = {>Part,t:Fighter};

class Projectile extends fx.GroupEffect {

	var speed:Float;
	var type:String;
	var projectiles:Array<Pro>;

	public function new( f, list, type, move, speed ) {
		if(speed == null) speed = 0.1;
		super(f, list);
		this.type = type;
		this.speed = speed;
		if(move == null) move = "shoot";
		caster.playAnim(move);
		spc = speed;
		projectiles = [];
	}

	public function getDiscHeight() {
		return (caster.height-caster.z) + 30;
	}

	public override function update() {
		super.update();
		switch(step){
			case 0:
				if(coef == 1){
					for( o in list ){
						var p:Pro = cast new Part( Scene.me.dm.attach("mcProjectile",Scene.DP_FIGHTER) );
						p.root.gotoAndStop(type);
						p.x = caster.x;
						p.y = caster.y;
						p.z = caster.z-caster.height*0.5;
						p.t = o.t;
						projectiles.push(p);
						p.root._xscale = caster.intSide*100;
						p.ray = 6;
						p.dropShadow();
						p.updatePos();
					}
					nextStep();
					spc = speed;
				}

			case 1:
				for( p in projectiles ){
					p.x = caster.x*(1-coef) + p.t.x*coef;
					p.y = caster.y*(1-coef) + p.t.y*coef;
					p.z = (caster.z-caster.height*0.5)*(1-coef) + (p.t.z-p.t.height)*0.5*coef;

					if( coef == 1 && type == "gland" ){
						p.vx = caster.intSide*(1+Math.random());
						p.vz = -(1.5+Math.random())*7;
						p.weight = 0.75;
						p.timer = 140;
						p.fadeType = 0;
						p.vr = (Math.random()*2-1)*15;
					}

					if( type == "aiguillon" ){
						var max = 1+Std.int(5*(1-coef));
						for( i in 0...max ){
							var pw = new Part( Scene.me.dm.attach( "partWind", Scene.DP_FIGHTER ) );
							pw.x = p.x;
							pw.y = p.y;
							pw.z = p.z;
							pw.vx = ( 0.5+Math.random()*2 ) * caster.intSide;

							pw.vr = (Math.random()*2-1)*15;
							pw.root.smc._x = Math.random()*20;
							pw.root._rotation = Math.random()*360;
							pw.timer = 10+Math.random()*20;

							pw.root.smc._xscale = p.root.smc._yscale = 100+Math.random()*50;
							pw.updatePos();
						}
					}
				}
				
				if( type == "rocher" && coef > 0.8 ) {
					for( p in projectiles )
						p.root._visible = false;
					makeRocherParticles();
				}
				if( coef == 1 ) {
					if( type == "rocher" )
						nextStep();
					else
						finish();
				}
			case 2:
				if( coef == 1 ) {
					finish();
				}
		}
	}
	
	function finish() {
		for( p in projectiles )
			if(p.weight == null)
				p.kill();
		damageAll();
		end();
	}
	
	function makeRocherParticles() {
		for( p in projectiles ) {
			for( i in 0...5 ) {
				var sp = new Part(Scene.me.dm.attach("partRoche", Scene.DP_FIGHTER));
				sp.x = p.x;
				sp.y = p.y;
				sp.z = -2;
				sp.vx = -5 + Std.random(10);
				sp.vy = 0;
				sp.vz = -(3+Math.random()*6);
				sp.weight = 0.2+Math.random()*0.3;
				sp.timer = 80+Math.random()*10;
				sp.setScale(50+Math.random()*50);
				sp.root._rotation = Math.random()*360;
				sp.fadeType = 0;
				sp.updatePos();
			}
		}
	}
}

