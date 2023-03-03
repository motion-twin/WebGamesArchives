
class snake3.bonus.Ressort extends snake3.bonus.Slot {

	function Ressort( game ) {
		super(game,41);
		game.snake.wall_rebonds = true;
	}

}