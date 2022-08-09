package ac.mon.magic;
import Protocole;
import mt.bumdum9.Lib;



class Firebreath extends MagicAttack {//}
	

	var fireball:McFireBall;
	var work:Array<Ball>;


	override function start() {
		super.start();
		work = trg.board.getLine( trg.board.ymax - 1 );
		var f = function(a:Ball, b:Ball) { if (a.px < b.px ) return - 1; return 1; };
		work.sort(f);
		
		//var right = work[0];
		//for ( b in work ) if ( b.px > right.px ) right = b;
		var right = work[work.length - 1];
		
		// MAGIC RESISTANCE
		var max = getMagicImpact(work.length);
		work = work.splice(work.length - max, max);
		
		//
		fireball = new McFireBall();
		Game.me.dm.add(fireball, Game.DP_FX);
		var pos = agg.folk.getCenter();
		fireball.x = pos.x;
		fireball.y = pos.y;
		
		var end = right.board.getGlobalBallPos(right.px, right.py);
		
		
		var move = new mt.fx.Tween(fireball, end.x + 10, end.y + 10, 0.03);
		spc = 0.03;
		move.setSin(100, 0.77);
		move.onFinish = impact;
		move.curveIn(2);
		

		new mt.fx.Spawn(fireball, 0.1, false, true);
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		
		
		switch(step) {
			case 1 :
			
				var ccc = Math.pow(coef, 2);
			
				
			
				for( i in 0...2 ){
					var mc = new FxHoriFlame() ;
					var p = new mt.fx.Part( mc );
					Game.me.dm.add(mc, Game.DP_FX);
					var a = Math.random() * 6.28;
					var cc = Math.random();
					var ray = cc * 16;
					p.setPos(fireball.x + Math.cos(a) * ray, fireball.y + Math.sin(a) * ray);
					p.timer = 10;
					p.setScale(0.25+(1-cc)*0.5);
					p.root.rotation = 90 + 90 * ccc;
					p.weight = - 0.02 - Math.random() * 0.1;
					
					
					
				}
				
				//var mc = new SP();
				//var spark = new FxSpark();
				//mc.addChild(spark);
				var an = (1-ccc) * 1.57 -3.14;
				
				var p = new mt.fx.Spinner( new FxSpark(), 20 + Math.random() * 10 );
				Game.me.dm.add( p.root, Game.DP_FX);
				p.frict = 0.95;
				p.rfr = 0.98;
				p.launch( an, 3 + Math.random()*4, 2 );
				p.setPos(fireball.x, fireball.y);
				p.timer = 10 + Std.random(20);
				
			
			case 2 :
				if ( work.length == 0 ) {
					nextStep();
				}else if ( timer > 1 ) {
					timer = 0;
					new fx.Burn(work.pop(),-1,75);
				}
			case 3 :
				if ( timer == 16 ) end();
				
				/*
				if ( burn == null ) {
					burn = work.pop();
					timer = 0;
				}
				Col.setPercentColor(burn.el,1, [0xFF0000,0xFFCC00,0xFFFF00][timer%3]);
				if ( timer == 5 ) {
					burn.kill();
					if ( work.length == 0 ) {
						new Fall(trg.board);
						kill();
					}else {
						burn = null;
					}
				}
				*/

				/*
				for ( b in work ) Col.setPercentColor(b.el,1, [0xFF0000,0xFFCC00,0xFFFF00][timer%3]);
				if ( timer == 24 ) {
					for ( b in work ) b.kill();
					new Fall(trg.board);
					kill();
				}
				*/
				
		}
	
	}
	//
	function impact() {
		nextStep();
		fireball.parent.removeChild(fireball);
		timer = 100;
		
		var max = 32;
		var cr = 6;
		for ( i in 0...max ) {
			var p = Game.me.getPart(new FxSpark());
			var a = i / max *6.28;
			var speed = Math.random() * 3;
			p.vx = Math.cos(a) * speed - Math.random()*3;
			p.vy = Math.sin(a) * speed;
			p.setPos( fireball.x + p.vx * cr, fireball.y + p.vy * cr);
			p.timer = 10 + Std.random(20);
			p.weight = 0.05 + Math.random() * 0.1;
		}
		
	}


	
//{
}


























