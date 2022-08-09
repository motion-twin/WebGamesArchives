package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;



class Fireball extends ac.hero.MagicAttack {//}
	
	var sock:mt.fx.Sock;
	var ball:mt.fx.Part<fx.Fireball>;
	var tw:Tween;
	//var oldPos: { x:Float, y:Float };
	
	public function new(agg,trg) {
		super(agg, trg);
		Scene.me.fadeTo(0x880000,0.05);
	}
	
	override function start() {
		super.start();


		
		ball = new mt.fx.Part(new fx.Fireball());
		ball.vr = 10;
				
		sock = new mt.fx.Sock(ball, 8, 2);
		sock.rndCoef = 1.0;
		
		//sock.rndIncAngle = 0.9;
		//sock.dirCoef = 0.2;
		
		sock.frict = 0.95;
		sock.autoDiv = 16;
		sock.drawMode = 1;
		sock.getFrontColor = function(id) {
			var coef = Math.min(id / 8, 1);
			return Col.objToCol( { r:Std.int((1 - coef) * 255), g:Std.int((1 - coef) * 128), b:0 } );
		}

		Scene.me.dm.add(sock.canvas,Scene.DP_UNDER_FX);
		Scene.me.dm.add(ball.root, Scene.DP_FX);
		
		var a = agg.folk.getCenter();
		var b = trg.folk.getCenter();
		ball.setPos(a.x, a.y);

		tw = new Tween(a.x, a.y, b.x, b.y);
		this.spc = 0.04;

		
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		
		
		
		switch(step) {
			case 1 :
				var p = tw.getPos(coef);
				ball.setPos(p.x, p.y);
				if ( coef == 1 ) {
					impact();
					ball.kill();
					sock.fadeOut(0.02);
					nextStep(0.025);
					Scene.me.fadeBack();
				}
			case 2 :
				if ( coef == 1 )
					kill();
		}

	}
	
	//
	public function impact() {
		var damage = 3;
		if ( agg.have(PYROMANCY) ) 			damage++;
		if ( agg.have(FORBIDDEN_ALCHEMY) ) 	damage++;
		
		var n = trg.hit( { value:damage, types:[MAGIC, FIRE], source:cast agg } );
		
		if ( n > 0 && agg.have(PYROMANCY) ) trg.removeActions(AC_REGENERATE);
		
		Scene.me.fxGroundImpact( trg.folk.x, 30, 8 );
		
		// FX
		var max = 32;
		for ( i in 0...max ) {
			var p = new mt.fx.Spinner(new FxSpark(),10+Std.random(30));
			var a = i / max * 6.28;
			var speed = 0.5 + Math.random() * 2;
			p.launch(a, speed, 0.5+Math.random()*4);
			p.setPos(ball.x, ball.y);
			p.frict = 0.99;
			p.timer = 10 + Std.random(60);
			Scene.me.dm.add(p.root, Scene.DP_FX);
			
		}
	}


	
//{
}


























