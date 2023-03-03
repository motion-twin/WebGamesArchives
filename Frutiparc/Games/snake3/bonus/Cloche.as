import snake3.bonus.Sonnette;

class snake3.bonus.Cloche {

	static var FRUITS_VERTS = [76];

	static var game = null;

	static function activate( game : snake3.Game ) {
		Cloche.game = game;
		Sonnette.activated = false;
		game.updates.push(Cloche,removeQueue);
	}

	static function removeQueue() {
		if( game.snake.len <= 0 ) {
			Sonnette.activated = true;
			Cloche.game = null;
			game.updates.remove(Cloche,removeQueue);
			return;
		}

		var p = game.snake.end_queue_pos(0);
		var f = game.gen_fruit();
		f.set_id( FRUITS_VERTS[random(FRUITS_VERTS.length)] );
		f._x = p.x;
		f._y = p.y;

		game.snake.explode(game.snake.color);
	}

}
