import snake3.Const;

class snake3.bonus.PotionOrange extends snake3.bonus.TimedSlot {

	var delta;

	function PotionOrange( game : snake3.Game ) {
		super(game,10,Const.TIME_POTIONORANGE);
		delta = 0;
	}

	function effect() {
		delta += Std.tmod * (random(3) - 1) * 0.02;
		if( delta < -0.07 )
			delta = -0.07;
		if( delta > 0.07 )
			delta = 0.07;
		game.snake.ang += delta;
	}


}