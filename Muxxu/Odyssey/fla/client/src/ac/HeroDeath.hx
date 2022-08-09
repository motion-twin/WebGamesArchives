package ac;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;



class HeroDeath extends Action {//}
	

	var hero:Hero;
	
	public function new(hero) {
		super();
		this.hero = hero;
		
		
	}
	
	
	override function init() {
		super.init();
	
	
		
	}
	
	function launch() {
		nextStep();
		var b =  hero.board;
		
		// BOARD
		var a = Tools.slice( hero.board, 128 );

		var cx = b.x + b.mcw * 0.5;
		var cy = b.y + b.mch * 0.5;
		var ray = Math.sqrt(cx * cx + cy * cy);
		
		var id = 0;
		for ( p in a ) {
			Game.me.dm.add(p.root,Game.DP_FX);
			p.weight = (0.05 + Math.random() * 0.12);
			p.frict = 0.95;
			p.fadeType = 2;
			p.fadeLimit = 30+Std.random(20);
			p.timer = p.fadeLimit ;
			
			var ddx = p.x - cx;
			var ddy = p.y - cy;
			var dist = Math.sqrt(ddx * ddx + ddy * ddy);
			var speed = Math.pow((dist / ray),2) * 32;
			var a = Math.atan2(ddy, ddx);
			p.vx  = Math.cos(a) * speed;
			p.vy  = Math.sin(a) * speed - (3+Math.random()*2);
		
			
			//
			id++;
		}
		
		b.visible = false;
		
		// FX
		for ( i in 0...32 ) {
			//var p = Game.me.getPart( new FxFluo() );
			var p = new mt.fx.Spinner(new FxFluo(),2+Math.random()*5);
			Game.me.dm.add(p.root, Game.DP_FX);
			
			p.setPos( b.x + Math.random() * b.mcw, b.y + Math.random() * b.mch );
			p.weight = -(0.01 + Math.random() * 0.1);
			p.vx = (Math.random() * 2 - 1) * 0.5;
			p.frict = 0.98;
			p.timer = 10 + Std.random(20);
			if ( Std.random(10) == 0 ) p.timer += 30;
			p.fadeType = 2;
			p.twist(15, 0.99);
			
			var ddx = p.x - cx;
			var ddy = p.y - cy;
			var dist = Math.sqrt(ddx * ddx + ddy * ddy);
			var speed = Math.pow((dist / ray),2) * 32;
			var a = Math.atan2(ddy, ddx);
			p.vx  = Math.cos(a) * speed *1.5;
			p.vy  = Math.sin(a) * speed - (2 + Math.random());
			
			p.root.blendMode = flash.display.BlendMode.ADD;
			
		}
				
	}
	
	
	
	
	// UPDATE
	override function update() {
		super.update();

		switch(step) {
			case  0:
				if ( timer > 16 ) launch();
			case 1:
				if ( timer == 16 ) {
					nextStep();
					var a = Tools.slice( hero.folk, 24 );
					
					for( p in a ) {
						Scene.me.dm.add(p.root, Scene.DP_FX);
						p.vx = (Math.random() * 2 -1);
						p.weight = -(0.1 + Math.random() * 0.2);
						p.frict = 0.99;
						p.fadeType = 2;
						p.timer = 10 + Std.random(20);
						
					}
					hero.folk.visible = false;

				}
				
			case 2 :
				if ( timer == 30 ) {
					nextStep();
					hero.kill();
					for ( h in game.heroes ) {
						if ( h.have(EMOTIONAL) ) {
							h.setStock(RAGE, 5);
							h.majInter();
						}
					}
					if ( game.heroes.length == 0 ) add( new ac.Gameover() );
					onEndTasks = kill;
				}
		}
		
		/*
		if ( timer == 80 ) {
			hero.kill();
			
			for ( h in game.heroes ) {
				if ( h.have(EMOTIONAL) ) {
					h.setStock(RAGE, 5);
					h.majInter();
				}
			}
			
			if ( game.heroes.length == 0 ) add( new ac.Gameover() );
					
			onEndTasks = kill;
			
		}
		
		*/
		
		
	}


	
	
//{
}