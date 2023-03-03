import snake3.Const;

class snake3.bonus.PotionJaune extends snake3.bonus.TimedSlot {

	var dir;

	function PotionJaune( game : snake3.Game ) {
		super(game,11,Const.TIME_POTIONJAUNE);
		dir = -1;
		game.enable_snake_keys = false;
	}

	function close() {
		game.enable_snake_keys = true;
		super.close();
	}

	function effect() {
		switch( dir ) {
		case 0:
			game.snake.ang = 0;
			break;
		case 1:
			game.snake.ang = - Math.PI / 2;
			break;
		case 2:
			game.snake.ang = Math.PI;
			break;
		case 3:
			game.snake.ang = Math.PI / 2;
			break;
		}
		if( Key.isDown(Key.LEFT) && dir != 0 )
			dir = 2;
		if( Key.isDown(Key.RIGHT) && dir != 2 )
			dir = 0;
		if( Key.isDown(Key.UP) && dir != 3 )
			dir = 1;
		if( Key.isDown(Key.DOWN) && dir != 1 )
			dir = 3;
	}


}