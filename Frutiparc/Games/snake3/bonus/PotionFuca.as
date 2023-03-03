import snake3.Const;

class snake3.bonus.PotionFuca extends snake3.bonus.TimedSlot {


	function PotionFuca( game : snake3.Game ) {
		super(game,14,Const.TIME_POTIONFUCA);
	}

	function close() {
		game.snake.eat_speed = 1;
		game.snake.fuca_game = null;
		super.close();
	}

	function effect() {
		game.snake.eat_speed = 2;
		game.snake.fuca_game = game;
	}


}