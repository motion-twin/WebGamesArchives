package ac.hero;
import Protocole;
import mt.bumdum9.Lib;


class ShieldMove extends Action {//}
	

	var speed:Float;
	var moves:Int;
	
	public function new() {
		super();
		moves = 0;
		speed = 6;
		

		
		
	}
	
	override function init() {
		super.init();
		
		// ORDER
		game.heroes.sort(sortHeroes);
		
		//
		for ( h in game.heroes ) {
			var tx = h.getStandPos();
			var dif = Math.abs(tx - h.folk.x );
			if (  dif < 1 ) continue;
			var move = new mt.fx.Tween( h.folk, tx, h.folk.y,speed/dif);
			move.onFinish = callback(finish, h.folk);
			h.folk.play("run");
			moves++;
		}
		
		if ( moves == 0 ) kill();
		
		game.majPanels(true);
		
	}
	
	function sortHeroes(a:Hero, b:Hero ) {
		var aa:Float = a.armor + a.readStock(RAGE);
		var rage = a.readStock(RAGE);
		if ( rage > 0 ) aa += rage -0.5;
		
		var bb:Float = b.armor + b.readStock(RAGE);
		var rage = b.readStock(RAGE);
		if ( rage > 0 ) bb += rage -0.5;
		
		if ( aa > bb ) return 1;
		if ( aa < bb ) return -1;
		return 0;
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