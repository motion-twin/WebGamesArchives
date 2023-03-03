class snake3.bonus.PotionNoire extends snake3.bonus.Slot {

	var hit;
	var snake;

	function PotionNoire( game : snake3.Game ) {
		super(game,12);
		snake = new snake3.Snake(game.dmanager, { x : game.snake.x, y : game.snake.y } );
		snake.color = 0;
		snake.border_color = 0;
		snake.tete.gotoAndStop(string(3));
		snake.ang = game.snake.ang;
		snake.len = 3;
		snake.queue_collide = false;
		var i;
		var q = game.snake.queue;
		for(i=0;i<q.length;i++)
			snake.queue.push(q[i]);
		snake.draw();
		hit = false;
	}

	function close() {
		super.close();
	}

	function permanent() {

		if( hit ) {
			snake.explode(0);
			snake.draw();
			if( snake.len == 0 ) {
				snake.destroy();
				game.remove_slot(this);
			}
			return;
		}

		var fruits = game.level.fruits;
		var i;
		var fnear = null;
		var dnear = 10000000;
		for(i=0;i<fruits.length;i++) {
			var f = fruits[i];
			var d = (f.x - snake.x) * (f.x - snake.x) + (f.y - snake.y) * (f.y - snake.y);
			if( d < dnear ) {
				dnear = d;
				fnear = f;
			}
		}

		hit = snake.move( game.level.bounds() );

		var ang = Math.atan2(fnear.y - snake.y,fnear.x - snake.x);
		if( Math.sin(ang - snake.ang) < 0 ) {
			snake.ang -= 0.1 * Std.tmod;
		} else {
			snake.ang += 0.1 * Std.tmod;
		}

		snake.draw();

		var c = snake.collision();
		var f = game.level.get_fruit(c);
		if( f != null ) {
			f.on_eat = undefined;
			game.eat_fruit(f);
		}

	}

}