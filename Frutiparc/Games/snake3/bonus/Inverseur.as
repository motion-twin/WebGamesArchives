
class snake3.bonus.Inverseur extends snake3.bonus.Slot {

	var down_flag;

	function Inverseur( game ) {
		super(game,42);
	}

	function permanent() {
		if( Key.isDown(Key.DOWN) ) {
			if( !down_flag )
				game.snake.reverse();
			down_flag = true;
		} else
			down_flag = false;
	}

}