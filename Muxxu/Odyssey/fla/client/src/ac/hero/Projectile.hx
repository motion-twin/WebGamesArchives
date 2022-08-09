package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class Projectile extends Action {//}
	
	var projectileType:Int;
	var agg:Hero;
	var vic:Monster;
	var damage:Damage;
	var proj:MC;

	
	public function new(agg,vic:Monster,projectileType:Int,value:Int,?types) {
		super();
		this.projectileType = projectileType;
		if ( types == null ) 	types = [PHYSICAL];
		this.agg = agg;
		this.vic = vic;
		damage = { types:types, value:value, source:cast agg };
		if ( Lambda.has(types, GROUND) && vic.have(FLYING) ) damage.value = 0;


	}
	override function init() {
		super.init();
		if ( Folk.FAKE )	launch();
		else				agg.folk.play("shoot", launch, true);
		
	}
	
	
	function launch() {
		
		var speed = 0.1;
		var pos = agg.folk.getCenter();
		switch(projectileType) {
			case 0 :
				proj = new McArrow();
				proj.stop();
				if ( Lambda.has( damage.types, FIRE ) )
					proj.nextFrame();
					
			case 1 :
				proj = new McAxe();
				speed = 0.05;

			case 2 :
				proj = new McDart();
				speed = 0.05;
				pos.x += 32;
				pos.y -= 11;
			case 3 :
				proj = new MC();
				speed = 0.1;
		}
		
		
		proj.x = pos.x;
		proj.y = pos.y;
		Scene.me.dm.add(proj, Scene.DP_FX);
		
		var pos = vic.folk.getCenter();
		
		var move = new mt.fx.Tween(proj, pos.x, pos.y,speed);
		move.onFinish = hit;
		
	}
	
	
	function hit() {
		nextStep();
		
		// KILL PROJ
		proj.parent.removeChild(proj);
		
		
		//
		var n = vic.hit(damage);
		vic.majInter();
		agg.majInter();
		
			
		if ( n > 0 ) { // ON DAMAGE
			
			for ( dt in damage.types ) {
				switch(dt) {
					case  STEAL(k) :
						add( new ac.hero.Steal(agg, vic, k) );
						add( new Fall(agg.board) );
						
					default :
				}

			}
			
			// FLECHE EXPLOSIVES
			if ( agg.have(GUNPOWDER) && Lambda.has( damage.types, FIRE ) ) {
				var max = 8;
				for ( i in 0...max ) {
					var a = Math.random() * 6.28;
					var speed = 0.5 + Math.random() * 4;
					var mc = new FxCloudBurn();
					mc.gotoAndPlay(max-i);
					var p = Scene.me.getPart(mc);
					p.vx = Math.cos(a) * speed;
					p.vy = Math.sin(a) * speed;
					p.frict = 0.92;
					p.setPos(proj.x, proj.y);
					p.timer = 40;
					p.setScale(1 - (i / max) * 0.5);
				}
				
				//
				var max = 16;
				for ( i in 0...max ) {
					var p = new mt.fx.Spinner(new FxSpark(),10+Std.random(30));
					var a = i / max * 6.28;
					var speed = Math.random() * 4;
					p.launch(a, speed, 0.5+Math.random()*4);
					p.setPos(proj.x, proj.y);
					p.frict = 0.99;
					p.timer = 10 + Std.random(60);
					Scene.me.dm.add(p.root, Scene.DP_FX);
				}
								
				
				
			}
			
		}
		
		if( vic.willRiposte(damage) ) add( new MonsterAttack(vic, agg, vic.getAttack() ) );
		
		
		
	}
	
	// UPDATE
	override function update() {
		super.update();
		switch(step) {
			case 0:
				if ( proj != null && projectileType == 1 ) {
					proj.rotation += 23;
				}
			case 1:
				if (timer > 20 && tasks.length == 0 ) kill();
		}
		
		
		
	}


	
	
//{
}