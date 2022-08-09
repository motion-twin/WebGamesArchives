package ac.hero.god;
import Protocole;
import mt.bumdum9.Lib;



class Harmattan extends ac.hero.God {//}
	
	

	
	override function start() {
		super.start();


		for ( h in game.heroes )
			add( new ac.hero.Regeneration(h, Math.ceil(h.board.breathes.length * 0.5)) );
		
			
	}
	
	override function updatePrayer() {
		super.updatePrayer();


		
		
		/*
		// FX
		var p = new fx.Liner(0xDDDDFF);
		p.setPos( Std.random(Cs.mcw), Scene.HEIGHT + Std.random(Cs.mch - Scene.HEIGHT));
		//p.vx = -(6+Math.random() * 8);
		p.timer = 10 + Std.random(30);
		
		//Filt.glow(p.root, 10, 4, 0xFFFFFF);
		//p.root.blendMode = flash.display.BlendMode.ADD;

		
		p.an = -3.14;
		p.turnAcc = 0.05;//0.25;
		p.gy = null;
		p.asp = 8 + Math.random() * 8;
		p.aspAcc = 0.1;
		*/
		
		if ( tasks.length == 0 ) kill();
		
		
	}
	
	
	
	
	
	
	
	
	

	
	//
	


	
	
//{
}