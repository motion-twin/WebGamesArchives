package ac.hero.god;
import Protocole;
import mt.bumdum9.Lib;



class Warhammer extends ac.hero.God {//}
	

	var hammer:fx.Warhammer;
	var trg:Monster;

	
	override function start() {
		super.start();
		
		trg = game.monster;
		hero.folk.play("atk", launch,true);

	}
	
	
	function launch() {
		hammer = new fx.Warhammer();
		Scene.me.dm.add(hammer, Scene.DP_UNDER_FX);
		var a = hero.folk.getCenter();
		var b = trg.folk.getCenter();
		
		
		hammer.x = a.x;
		hammer.y = a.y;
		var move = new mt.fx.Tween(hammer, b.x, b.y );
		move.onFinish = impact;
	}
	
	function impact() {
		
		trg.armor = 0;
		trg.majInter();
		
		//FX
		var b = trg.folk.getCenter();
		trg.fxHit();
		hammer.parent.removeChild(hammer);
		
		for( i in 0...3 ){
			var onde = new mt.fx.ShockWave(60, 60 + (i+1) * 50, 0.15 - i * 0.025);
			onde.setHole(0.5);
			onde.setPos(b.x, b.y);
			Scene.me.dm.add( onde.root, Scene.DP_UNDER_FX);
		
		}
		
		//
		var max = 32;
		var cr = 8;
		for ( i in 0...max ) {
			var a = (i / max) * 6.28;
			var speed = 0.1 + Math.random() * 3;
			var p = Scene.me.getPart( new fx.Triangle() );
			p.vx = Math.cos(a) * speed + Math.random()*4;
			p.vy = Math.sin(a) * speed;
			p.setPos(b.x + cr * p.vx, b.y + cr * p.vy);
			p.twist(24, 0.98);
			p.timer = 40+Std.random(20);
			p.setGround(Scene.HEIGHT - Scene.GH, 0.8, 0.5);
			p.weight = 0.2 + Math.random() * 0.2;
			p.fadeType = 2;
			
		}
		
		//
		haxe.Timer.delay(kill, 1000);
		
	}
	
	
	
//{
}