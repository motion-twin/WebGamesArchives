package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;



class Iceball extends ac.hero.MagicAttack {//}
	
	var sock:mt.fx.Sock;
	var ball:mt.fx.Part<fx.Iceball>;
	var tw:Tween;
	var damage:Int;
	
	public function new(agg,trg,power) {
		super(agg, trg);
		Scene.me.fadeTo(0x008899, 0.05);
		damage = 3;
		if ( power == 3 ) damage--;
		if ( agg.have(ICE_SPIRIT) ) damage++;
		if ( agg.have(FORBIDDEN_ALCHEMY) ) damage++;
		
	}
	
	override function start() {
		super.start();

		ball = new mt.fx.Part(new fx.Iceball());
		ball.vr = 10;
				
		sock = new mt.fx.Sock(ball, 8, 2);
		sock.rndCoef = 1.0;

		sock.frict = 0.95;
		sock.autoDiv = 16;
		sock.drawMode = 1;
		sock.getFrontColor = function(id) {
			var coef = Math.min(id / 8, 1);
			return Col.objToCol( { b:Std.int((1 - coef) * 255), g:Std.int((1 - coef) * 255), r:0 } );
		}

		Scene.me.dm.add(sock.canvas,Scene.DP_UNDER_FX);
		Scene.me.dm.add(ball.root, Scene.DP_FX);
		
		var a = agg.folk.getCenter();
		var b = trg.folk.getCenter();
		ball.setPos(a.x, a.y);
		//var move = new mt.fx.Tween(ball, b.folk.x, b.folk.y);
		tw = new Tween(a.x, a.y, b.x, b.y);
		this.spc = 0.04;
		
		

		
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		
		
		
		switch(step) {
			case 1 :
			
				for ( i in 0...2 ) {
					var mc = new FxDustTwinkle() ;
					var p =	Scene.me.getPart( mc);
					p.setPos( ball.x + Std.random(30) - 15, ball.y + Std.random(30) - 15);
					p.weight = Math.random() * 0.15;
					p.vx = Math.random();
					p.frict = 0.98;
					p.timer = 10 + Std.random(20);
					mc.gotoAndPlay(Std.random(mc.totalFrames) + 1);
				}
			
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
		
		trg.hit( { value:damage, types:[MAGIC, ICE(agg.have(NIXOMANCY)?3:2)], source:cast agg } );
		
		Scene.me.fxGroundImpact( trg.folk.x, 30, 8 );
		
		// FX
		var max = 32;
		for ( i in 0...max ) {
			//var p = new mt.fx.Spinner(new FxSpark(),10+Std.random(30));
			var p = Scene.me.getPart( new McCrystal());
			var a = i / max * 6.28;
			var speed = 0.5 + Math.random() * 2;
			//p.launch(a, speed, 0.5+Math.random()*4);
			var pos = trg.folk.getRandomBodyPos();
			p.setPos(pos.x, pos.y);
			p.weight = Math.random() * 0.2;
			p.twist(12, 0.98);
			p.frict = 0.99;
			p.timer = 10 + Std.random(60);
			Scene.me.dm.add(p.root, Scene.DP_FX);
			p.setScale(0.2 + Math.random() * 0.2);
			
		}
	}


	
//{
}


























