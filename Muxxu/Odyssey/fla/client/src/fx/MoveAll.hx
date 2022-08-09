package fx;
import Protocole;
import mt.bumdum9.Lib;

class MoveAll extends mt.fx.Fx {//}
	

	var speed:Float;
	var moves:Int;
	
	public function new(game:Game) {
		super();
		moves = 0;
		speed = 6;
		
		var a = [];
		
		// HEROES
		//var x = 80;
		for ( h in game.heroes ) a.push({folk:h.folk,x:h.getStandPos()});
		
		// MONSTER
		a.push( { x:game.monster.getStandPos(), folk:game.monster.folk } );
		
		//
		for ( o in a ) {
			var dif = Math.abs(o.x - o.folk.x );
			if ( dif < 1 ) continue;
			var move = new mt.fx.Tween( o.folk, o.x, o.folk.y,speed/dif);
			move.onFinish = callback(finish, o.folk);
			o.folk.play("run");
			moves++;
		}
		
		
	}

	
	// UPDATE
	override function update() {
		super.update();

		
	}
	
	function finish(folk:Folk) {
		folk.play("stand");
		if ( --moves == 0 ) kill();
	}

	
	
//{
}