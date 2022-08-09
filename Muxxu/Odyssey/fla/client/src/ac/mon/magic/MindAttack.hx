package ac.mon.magic;
import Protocole;
import mt.bumdum9.Lib;



class MindAttack extends MagicAttack {//}
	

	var list:Array<Ball>;

	override function start() {
		super.start();
		
		var y = trg.board.ymax;
		for ( b in trg.board.balls )
			if( b.py < y ) y = b.py;
		
		list = [];
		var max = this.getMagicImpact(3);
		if ( max == 0 ) trg.fxAbsorb();
		for ( i in 0...max ) {
			var line = trg.board.getLine(y);
			for ( b in line ) list.push(b);
			if (++y == trg.board.ymax) break;
		}
		

		if ( list.length == 0 ) kill();
		
		
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
			
		
		if( timer%2 == 0 ){
			var b = list.shift();
			
			
			b.kill(); // null ? TODO a tester
			
			var max = 4;
			for ( i in 0...max ) {
				var mc = new FxDustTwinkle();
				var p = Game.me.getPart( mc );
				mc.gotoAndPlay(Std.random(mc.totalFrames) + 1);
				var pos = b.getGlobalPos(Math.random(), Math.random());
				p.setPos(pos.x,pos.y);
				p.timer = 10 + Std.random(20);
				p.weight = -(0.02 + Math.random() * 0.05);
				
			}
			
			if ( list.length == 0 )
				end();
			
		}
		
	}
	
	
	
//{
}


























