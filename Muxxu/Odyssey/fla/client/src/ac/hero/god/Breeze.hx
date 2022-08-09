package ac.hero.god;
import Protocole;
import mt.bumdum9.Lib;



class Breeze extends ac.hero.God {//}
	
	
	var balls:Array<Ball>;
	
	override function start() {
		super.start();

		balls = [];
		var a = [];
		for ( h in game.heroes ) a.push(h.board);
		for ( board in a ) {
			var grid = board.getGrid();
			
			for ( y in 0...board.ymax ) {
				var fall = 0;
				for ( x in 0...board.xmax ) {
					var b = grid[x][y];
					if ( b == null ) {
						fall++;
					}else {
						b.fall = fall;
						if( fall > 0 )balls.push(b);
					}
				}
			}
		}
		
		if ( balls.length == 0 )
			kill();
			
	}
	
	override function updatePrayer() {
		super.updatePrayer();

		//
		while ( coef >= 1 ) {
			coef--;
			var end = true;
			for ( b in balls ) {
				if ( b.fall == 0 ) continue;
				b.fall--;
				b.setPos(b.px-1, b.py);
				end = false;
			}
			if ( end ) {
				kill();
				return;
			}
		}
		for ( b in balls ) {
			if ( b.fall == 0 ) continue;
			b.x = (b.px+0.5 - coef) * Ball.SIZE;
		}
		
		
		
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
		
	}
	
	
	
	
	
	
	
	
	

	
	//
	


	
	
//{
}