import snake3.Const;

class snake3.bonus.Steroids extends snake3.bonus.TimedSlot {

	function Steroids( game : snake3.Game, x, y ) {
		super(game,4,Const.TIME_STEROIDS);
		game.snake.speed *= 2;
		game.score += 3000;
		game.popup(x,y,3000);
	}

	function close() {
		game.snake.speed /= 2;
		super.close();
	}

}
