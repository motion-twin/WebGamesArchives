class snake3.bonus.Sabre {

	static function activate( game : snake3.Game ) {
		game.fbarre /= 2;		
		game.snake.len = int(game.snake.len/2);
	}

}