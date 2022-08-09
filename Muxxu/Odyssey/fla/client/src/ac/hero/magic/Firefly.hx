package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;



class FireFly
extends ac.hero.MagicAttack {//}
	

	var sock:mt.fx.Sock;

	override function start() {
		super.start();

		var max = 1;
		if ( agg.have(FULMINOMANCY) )	max++;


		for( i in 0...max ){
			var proj = new SP();
			var pos = agg.folk.getCenter();
			proj.x = pos.x;
			proj.y = pos.y;

			var mis = new part.Missile();
			mis.setPos(pos.x,pos.y);
			mis.trg = trg.folk.getCenter();
			mis.vx = Math.random()*4-2;
			mis.vy = Math.random()*2-4;
			mis.asp += Math.random();
			
			mis.onImpact = impact;
		
		}
		
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		if ( part.Missile.WAIT == 0 && tasks.length == 0) kill();
		
	}
	
	//
	public function impact() {
		
		if ( agg.have(EVIL_DRAIN) ) 	add( new ac.hero.Steal(agg,trg,1) );
		if ( agg.have(WISP_HEALING) ) 	add( new ac.hero.Regeneration(agg, 1) );
		
		var damage = 1;
		if ( agg.have(FORBIDDEN_ALCHEMY) ) 	damage++;
		trg.hit( { value:damage, types:[MAGIC], source:cast agg } );
		
		if ( agg.have(FULMINOMANCY) && part.Missile.WAIT == 1 ) {
			var balls = agg.board.getRandomBalls(1, true);
			for ( b in balls ) b.damage(null);
		}
		
		
	}


	
//{
}


























