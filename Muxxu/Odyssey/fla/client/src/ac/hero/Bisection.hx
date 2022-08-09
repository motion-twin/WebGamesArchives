package ac.hero;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;



class Bisection extends Action {//}
	
	var hero:Hero;
	var trg:Monster;
	
	public function new(hero, trg) {
		this.hero = hero;
		this.trg = trg;
		super();

	}
	override function init() {
		super.init();
		var e = new ac.MoveMid(hero.folk);
		e.onFinish = callback(hero.folk.play, "atk", hit, true);
		add(e);
	}
	
	
	override function update() {
		super.update();
		switch(step) {
			case 1 :
				if ( timer == 40 ) {
					var e = new MoveBack(hero.folk);
					e.onFinish = kill;
					add(e);
				}
		}
	}
	
	
	public function hit() {
		nextStep();
		// BISECTION
		var a = Tools.slice( trg.folk, 1 );
		
		var id = 0;
		for( p in a ) {
			Scene.me.dm.add(p.root, Scene.DP_FX);
			p.frict = 0.99;
			p.fadeType = 2;
			p.timer = 35 + id * 30;
			
			if ( id == 0 ) {
				p.vx = 1.5;
				p.weight = 0.2;
				p.setGround( Scene.HEIGHT - Scene.GH,0.75,0.5);
			}
			
			id++;
		}
		
		// BLOOD
		var max = 3;
		var ce = trg.folk.getCenter();
		for ( i in 0...max ) {
			var mc = new FxCloud();
			Col.setPercentColor(mc, 1, 0xFF0000);
			mc.gotoAndPlay(Std.random(8) + 1);
			Scene.me.dm.add(mc, Scene.DP_UNDER_FX);
			
			var p = new mt.fx.Part(mc);
			p.setPos(ce.x, ce.y);
			p.vx  = (i / max) * 10;
			p.frict = 0.9;
			p.weight = 0.02 + Math.random() * 0.03;
			p.timer = 40;
			p.setScale(0.2 + Math.random() * 0.3);
			p.twist(13, 0.99);
			
		}
		//
				
		//
		trg.incLife( -trg.life);
		trg.folk.visible = false;

		
		
	}
	
	
	//
	


	
	
//{
}