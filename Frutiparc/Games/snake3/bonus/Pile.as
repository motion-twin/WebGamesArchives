class snake3.bonus.Pile {

	public static var counter = 0;

	public static function activate( game : snake3.Game ) {
		counter++;
		var i;
		for(i=0;i<counter;i++) {
			if( game.snake.len > 0 )
				game.snake.explode(game.snake.color);
			else {
				game.game_over();
				return;
			}
		}
	}

}