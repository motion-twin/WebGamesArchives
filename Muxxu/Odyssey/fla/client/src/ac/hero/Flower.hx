package ac.hero;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;



class Flower extends Action {//}
	
	var hero:Hero;
	var power:Int;
	
	public function new(hero,power) {
		super();
		this.hero = hero;
		this.power = power;
		
		

		
		
	}

	
	override function init() {
		super.init();
		var anim = "flower";
		if( !hero.folk.haveAnim(anim) ) anim = "atk";
		hero.folk.play(anim, launch, true);
		
	}
	
	override function update() {
		super.update();
		switch(step) {
			case 1 :
				if ( timer == 80 ) {
					nextStep();
					apply();
				}
			case 2 :
				
				if ( timer == 20 ) kill();
		}
		
		
	}
	
	function launch() {
		var max = 32;
		nextStep();
		for ( i in 0...max ) {
			
			var mc = new fx.Petal();
			Scene.me.dm.add(mc,Scene.DP_FX);
			mc.gotoAndPlay(Std.random(20)+1);
			var p = new mt.fx.Part(mc);
			p.vx = 2+Math.random() * 10;
			p.vy = - Math.random() * 5;
			p.frict = 0.98;
			p.weight = 0.02 + Math.random() * 0.08;
			p.timer = 140 + Std.random(100);
			p.fadeType = 2;
			p.setGround(Scene.HEIGHT - Scene.GH, 0.5, 0.2 );
			p.onBounceGround = function() { mc.stop(); if( p.timer > 10 ) p.timer = 20; p.onBounceGround = null; };
			p.setScale(0.3);
		
			p.setPos(hero.folk.x + 16, hero.folk.y - 14);
			
			//Col.setColor(mc, Col.getRainbow2());
			Col.setColor(mc, [0xFF6622,0xFFAA44, 0xFFFF88][Std.random(3)]);
			
			
		}
		
		
	}
	
	
	public function apply() {
		var sta = STA_PACIFISM;
		if ( hero.have(POLLEN) ) sta = STA_PACIFISM_2;
		if ( hero.have(NATURAL_HEALING) ) hero.removeAllNegativeStatus();
		
		
		var a:Array<Ent> = [];
		a.push(Game.me.monster);
		for ( h in game.heroes ) a.push(h);

		for ( ent in a ) {
			var e = new mt.fx.Flash(ent.folk, 0.05, 0xFFCC44);
			e.curveIn(2);
			e.glow(3, 8);
			ent.addStatus(sta, power);
		}
		
		
		
	}
	


	
	//
	


	
	
//{
}