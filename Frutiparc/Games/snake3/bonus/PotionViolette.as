import snake3.Const;

class snake3.bonus.PotionViolette extends snake3.bonus.TimedSlot {

	function PotionViolette( game : snake3.Game ) {
		super(game,7,Const.TIME_POTIONVIOLETTE);
	}

	function close() {
		game.snake.distort = false;
		super.close();
	}

	function effect() {
		if( !game.snake.can_move )
			game.snake.redraw = true;
		game.snake.distort = true;
		if( time < 5 )
			game.snake.distort_val = time / 5;
		else
			game.snake.distort_val = 1;
	}

}
