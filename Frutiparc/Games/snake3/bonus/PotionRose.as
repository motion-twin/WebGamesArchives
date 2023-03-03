import snake3.Const;

class snake3.bonus.PotionRose extends snake3.bonus.TimedSlot {

	function PotionRose( game : snake3.Game ) {
		super(game,5,Const.TIME_POTIONROSE);
		game.score_factor *= 2;
		game.fruit_time_factor *= 2;		
	}

	function close() {
		game.do_call_on_eat = true;
		game.score_factor /= 2;
		game.fruit_time_factor /= 2;
		super.close();
	}

	function jump_fruit() {
		var f = game.level.fruits[random(game.level.fruits.length)];
		if( f.isMoving() )
			return;
		f.jump_near(random(50)+20,random(10)+20,0.1,game.level.bounds());
	}

	function effect() {
		game.do_call_on_eat = false;
		if( random(int(30/Std.tmod)) == 0 )
			jump_fruit();
	}


}