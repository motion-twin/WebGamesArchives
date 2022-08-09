package ac;
import Protocole;
import mt.bumdum9.Lib;

typedef RFPoint = {
	board:Board,
	x:Int,
	y:Int,

	dec:Float,
	dist:Float,
	part:mt.fx.Part<gfx.PotionSpark>,
}

class Refill extends Action {//}
	
	
	var points:Array<RFPoint>;
	var work:Array<RFPoint>;
	
	public function new(){
		super();
		game.deactivate();
		game.waitRefill = false;
		

		
		
	}
	override function init() {
		super.init();
		
		points = [];
		work = [];
		
		var max = 0;
		for( h in game.heroes ) {
			var slots = h.board.getFreePos();
			
			
			for( pos in slots ) {
				/*
				var mc = new SP();
				mc.graphics.beginFill(0x00FFFF);
				mc.graphics.drawCircle(0, 0, 4);
				*/
				var mc = new gfx.PotionSpark();
				mc.blendMode = flash.display.BlendMode.ADD;
				//h.board.dm.add(mc, Board.DP_FX);
				
				Game.me.dm.add(mc, Game.DP_FX);
				var p = new mt.fx.Part(mc);
				p.twist(30, 0.99);
				
				var point = { part:p, x:pos.x, y:pos.y, dec:Math.random(), dist:Math.random(), board:h.board };
				points.push(point);
				
				new mt.fx.Spawn(mc, 0.1, false, true);
				
			}
			
		}
		
		spc = 0.01;
		Game.me.refillCount++;
		
	}
	override function update() {
		super.update();
		
		//coef = Math.min(coef +0.01, 1);
		switch(step) {
			
			case 0 :
				
				var co  = 1 - coef;
				for( o in points ) {
					
					var x = (o.x + 0.5) * Ball.SIZE;
					var y = (o.y + 0.5) * Ball.SIZE;
					
					x += o.board.x;
					y += o.board.y;
					
					var a = (co + o.dec) * 6.28;
					var dist = co * (40+o.dist*80);
					x += Math.cos(a) * dist;
					y += Math.sin(a) * dist;
					
					o.part.setPos(x, y);
					o.part.setScale(0.5 + Math.random() * 0.5);
					
				}
				
				if( coef == 1 ) {
					for( o in points ) o.dec = 0;
					nextStep(0.1);
				}
				
			case 1 :
				
				
				//var co  = Math.pow(coef, 0.25);
				
				if( points.length > 0 ) work.push(points.shift());
				
				for( o in work.copy() ) {
					
					o.dec = Math.min(o.dec + 0.1, 1);
					var co =  Math.pow(o.dec, 0.25);
					
					o.part.setScale( 0.5 + o.dec * 2 );
					if( o.dec == 1 ) {
						var ball = o.board.addBall( o.board.getRandomBallType(), o.x, o.y);
						var e = new mt.fx.Flash(ball,0.1,0xFFFFFF);
						e.glow(4, 8);
						ball.fxDrop();
						o.part.kill();
						work.remove(o);
						o.board.killBreathAt(o.x, o.y);
					}
				}
				
				
				if( work.length == 0) {

					kill();
				}
				
		}

		
	}

	
//{
}












