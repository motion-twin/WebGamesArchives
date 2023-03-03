import snake3.Const;

class snake3.bonus.PotionVerte extends snake3.bonus.TimedSlot {

	var t;

	function PotionVerte( game : snake3.Game ) {
		super(game,9,Const.TIME_POTIONVERTE);
		t = 100;
	}

	function close() {
		game.snake.alpha_val = 100;
		super.close();
	}

	function effect() {
		t -= Std.deltaT * 100;
		if( t < 0 ) {
			t = 100;
			game.snake.len--;
			if( game.snake.len <= 0 )
				game.game_over();
		}
		game.snake.alpha_val = t;
	}

}