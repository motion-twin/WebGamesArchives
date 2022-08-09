package ac.mon.magic;
import Protocole;
import mt.bumdum9.Lib;



class Drain extends MagicAttack {//}
	

	override function start() {
		super.start();

		zwip();
		
		agg.folk.x =  trg.folk.x - 50;
		agg.folk.setSens( -1);
		agg.folk.play("atk", impact, true);

	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();

		switch(step) {
			case 2 :
				if ( part.Ball.WAIT == 0 )
					nextStep();
				
			case 3 : // FAIL
				if ( timer == 20 )
					leave();
		}
		

	}
	
	function leave() {
		end();
		zwip();
		agg.folk.x =  agg.getStandPos();
		agg.folk.setSens(1);
		trg.folk.setSens(1);
		
	}
	
	//
	public function impact() {
		nextStep();
			
		var ammount = getMagicImpact(3);
		
		if ( ammount == 0 ){
			trg.fxAbsorb();
			nextStep();
			return;
		}
		
		
		var a = trg.board.getRandomBalls(ammount, true);
		
		for ( b in a  ) {
			var p = new part.Ball(b.type);
			p.initBoardPos(trg, b.px, b.py);
			p.gotoFolk(agg.folk,callback(ballImpact,p));
			p.asp = 2 + Math.random() * 3;
			
			b.kill();
			
		}
		
		trg.folk.play("hit", true);
		trg.folk.setSens( -1);
		

	}
	
	public function ballImpact(p) {
		agg.incLife(1);
		agg.folk.fxHeal();
		agg.majInter();
		//new agg.folk.
	}
	
	
	//
	function zwip() {
		var max = 32;
		for ( i in 0...max ) {
			var mc = new FxHoriSlash();
			var p = Scene.me.getPart( mc );
			var pos = agg.folk.getRandomBodyPos();
			p.setPos(pos.x, pos.y);
			p.root.rotation = -90;
			mc.stop();
			mc.visible = false;
			var count = Std.random(8);
			p.setScale(1 - (count * 0.05));
			new mt.fx.Sleep( p, function() { mc.play(); mc.visible = true; } , count );
			Col.setColor(mc, 0);
			
		}
	}
	


	
//{
}


























