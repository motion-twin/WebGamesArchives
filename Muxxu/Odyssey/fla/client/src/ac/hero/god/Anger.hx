package ac.hero.god;
import Protocole;
import mt.bumdum9.Lib;



class Anger extends ac.hero.God {//}
	

	var num:Int;
	var aura:fx.Aura;

	
	override function start() {
		super.start();
		
		num = 3;
		spc = 0.1;
		aura = new fx.Aura(hero.folk);
		hero.folk.play("stand");
	}
	
	override function updatePrayer() {
		super.updatePrayer();
		
		switch(step) {
			case 1:
				//
				hero.folk.filters = [];
				Filt.grey(hero.folk, coef, 0, { r:0, g: -200, b:-200 });
				if ( coef == 1 ) nextStep();
				
			case 2 :
				if ( timer == 60 ) nextStep(0.2);
				
			case 3 :
				
				if ( coef >= 1 ) {
					coef--;
					hero.setStock(FRENZY, 1);
					hero.majInter();
					new mt.fx.Flash(hero.folk, 0.34);
					if ( --num == 0 ){
						kill();
						aura.fade();
						hero.folk.filters = [];
					}
				}
		}
		
		
		
		// Fx
		var p = Scene.me.getPart(new fx.RoundRad());
		var pos = hero.folk.getRandomBodyPos();
		p.setPos(pos.x, pos.y);
		p.root.blendMode = flash.display.BlendMode.ADD;
		Col.setColor(p.root, 0xFFFF00);
		p.weight = -(0.05 + Math.random() * 0.1);
		p.timer = 10 + Std.random(20);
		p.frict = 0.98;
		//p.setScale(0.1+Math.random() * 0.5);
		p.fadeType = 2;
		p.setAlpha(0.2);
		
		
		
		
		
	}
	
	

	
	//
	


	
	
//{
}