
class snake3.bonus.Poupee extends snake3.bonus.Slot {

	function Poupee( game ) {
		super(game,44);
	}

	function permanent() {
		var fruits = game.level.fruits;
		var i;
		for(i=0;i<fruits.length;i++) {
			var f = fruits[i];
			if( !f.isMoving() ) {
				var dx = game.snake.x - f._x;
				var dy = game.snake.y - f._y;
				var d = Math.sqrt(dx*dx+dy*dy);
				f._x += dx / d;
				f._y += dy / d;
			}
		}
	}
}