import snake3.Const;

class snake3.bonus.PotionBleue extends snake3.bonus.TimedSlot {

	var counter;

	function PotionBleue( game : snake3.Game ) {
		super(game,6,Const.TIME_POTIONBLEUE);
		counter = 0;
	}

	function color(flag) {
		if( flag ) {
			game.snake.color = Const.COLOR_SNAKE_INVINCIBLE;
			game.snake.border_color = Const.COLOR_SNAKE_BORDER_INVINCIBLE;
			game.snake.tete.gotoAndStop(string(2));
		} else {
			game.snake.color = Const.COLOR_SNAKE_DEFAULT;
			game.snake.border_color = Const.COLOR_SNAKE_BORDER_DEFAULT;
			game.snake.tete.gotoAndStop(string(1));
		}
	}

	function close() {
		color(false);
		game.snake.queue_collide = true;
		super.close();
	}

	function effect() {
		if( time < 2 && (counter++ & 2) == 0 )
			color(false);
		else
			color(true);
		game.snake.queue_collide = false;
	}


}