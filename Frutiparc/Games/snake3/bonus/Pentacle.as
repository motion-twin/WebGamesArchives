
class snake3.bonus.Pentacle extends snake3.bonus.Slot {

	function Pentacle( game ) {
		super(game,46);
		var me = this;
		function new_on_eat(f) {
			me.on_eat();
		}
		game.call_on_eat = new_on_eat;
	}

	function on_eat() {
		if( game.snake.len == 0 )
			game.game_over();
		else
			game.snake.explode(game.snake.color);
	}

	function permanent() {
	}
}