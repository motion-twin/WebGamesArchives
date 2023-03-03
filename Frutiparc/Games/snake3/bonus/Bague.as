
class snake3.bonus.Bague extends snake3.bonus.Slot {

	function Bague( game ) {
		super(game,40);
		game.snake.delta_ang *= 1.7;
	}

}