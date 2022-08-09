package ac.mon.magic;
import Protocole;
import mt.bumdum9.Lib;



class Thunder extends MagicAttack {//}
	

	var layer:SP;
	var board:Board;
	var tx:Int;
	var resist:Int;

	public function new(agg) {
		
		var column = [];
		var best = 0;
		for ( h in Game.me.heroes ) {
			var b = h.board;
			var bonus = h.have(NO_PAIN)?100:0;
			for ( x in 0...b.xmax ) {
				var a = b.getColumn(x);
				var score = a.length + bonus;
				if ( score> best ) {
					column = a;
					best = score;
					tx = x;
				}
			}
		}
		
		board = Game.me.heroes[0].board;
		if( column.length > 0 )	board = column[0].board;
		
		super(agg,board.hero);
	
		
	}
	override function start() {
		super.start();
		

		var column = board.getColumn(tx);

		
		spc = 0.1;
		
		// MAGIC RESISTANCE
		//var max = Std.int(column.length * (1 - board.hero.magicResistance * 0.1));
		var max = getMagicImpact(column.length);
		resist = column.length;
		column = column.splice(column.length - max, column.length);
		resist -=column.length;
		
		//
		for ( ball in column ) ball.kill();
		
		layer = new SP();
		board.dm.add(layer, 6 );
		layer.blendMode = flash.display.BlendMode.ADD;
		
		// FX IMPACT
		var max = 32;
		var cx = (tx + 0.5) * Ball.SIZE;
		var cy = (board.ymax - resist) * Ball.SIZE;
		for ( i in 0...max ) {
			var mc = new SP();
			mc.graphics.beginFill(0xFFFFFF);
			mc.graphics.drawRect( -1, -1, 2, 2);
			Filt.glow(mc, 4, 1, 0xFFFF00);
			board.dm.add(mc, 8);
			var a = (i + Math.random()) * 6.28;
			var speed = Math.random() * 3;
			var p = new mt.fx.Part(mc);
			
			p.vx = Math.cos(a) * speed;
			p.vy = Math.sin(a) * speed - (1+Math.random())*0.5;
			p.setPos(cx, cy);
			
			p.timer = 10 + Std.random(20);
			p.weight = 0.015 + Math.random()*0.015;
			p.frict = 0.98;
			p.fadeType = 2;
			
			
		}
		
		

	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		
		var a = [];

		for ( py in 0...(board.ymax+1-resist) ) {
			var x = (tx+Math.random()) * Ball.SIZE;
			var y = py * Ball.SIZE;
			a.push({x:x,y:y});
		}
		
		layer.graphics.clear();
		layer.graphics.lineStyle(1, 0xFFFFFF, 1,true,flash.display.LineScaleMode.NORMAL, flash.display.CapsStyle.SQUARE,flash.display.JointStyle.MITER,0);
		layer.graphics.moveTo(a[0].x, a[0].y);
		
		for ( p in a ) layer.graphics.lineTo(p.x, p.y);
		layer.filters = [];
		
		var pow = 1 - coef;
		Filt.glow(layer, 2*pow, 8*pow, 0xFFFF00);
		Filt.glow(layer, 30*pow, 4*pow, 0xFFFF00);
		
		
		if ( coef == 1 ) {
			layer.parent.removeChild(layer);
			end();
		}
		
		
		
		
	}


	
//{
}


























