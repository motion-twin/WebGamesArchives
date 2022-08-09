package ac.mon.magic;
import Protocole;
import mt.bumdum9.Lib;



class Bubble extends MagicAttack {//}
	
	var bub:SP;
	var bubSkin:fx.Bubble;
	var ball:Ball;

	override function init() {
		super.init();
		if (trg.board.getUnbubbled().length == 0 ) {
			kill();
		}
	}
	
	override function start() {
		super.start();

		bub = new SP();
		bub.scaleX = bub.scaleY = 0.4;
		bubSkin = new fx.Bubble();
		bub.addChild(bubSkin);
		Game.me.dm.add(bub, Scene.DP_FX);
		var pos = agg.folk.getCenter();
		bub.x = pos.x;
		bub.y = pos.y;
		
		var h = Game.me.getFirst();
		var a = h.board.getUnbubbled();
		
		if ( a.length == 0 ) {
			kill();
			return;
		}
		
		ball = a[Std.random(a.length)];
		
		var end = ball.getGlobalPos();
		
		var move = new mt.fx.Tween(bub, end.x, end.y, 0.02);
		move.setSin( 100);
		move.onFinish = apply;
		
		new mt.fx.Spawn(bub, 0.2, false, true);
		new mt.fx.Blob(bubSkin, 0.02);
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
			
		
	}
	
	//
	public function apply() {
		
		// REMOVE BUB
		bub.parent.removeChild(bub);
		
		// FX
		var max = 32;
		var cr  = 4;
		var ray = 32;
		for ( i in 0...max) {
			var p = Scene.me.getPart( new fx.Drop() );
			var a = i / max * 6.28;
			var speed = 1 + Math.random() * 0.5;
			p.vx = Math.cos(a)*speed;
			p.vy = Math.sin(a)*speed;
			p.setPos( bub.x + Math.cos(a)*ray, bub.y + Math.sin(a)*ray);
			p.frict = 0.98;
			p.weight = 0.1 + Math.random() * 0.05;
			p.timer = 10+Std.random(5);
			p.fadeType = 2;
		}
		
		//
		if ( !checkResistance() ) {
			ball.bubble = true;
			ball.addChild(bub);
			bub.x = bub.y = 0;
		
		}else {
			trg.fxAbsorb();
		}
		
		end();
		
		
		
		
		
	}


	
//{
}


























