import snake3.Const;

class snake3.bonus.Rondelle extends snake3.bonus.TimedSlot {

	function Rondelle( game : snake3.Game ) {
		super(game,8,Const.TIME_RONDELLE);
		game.loose_frutibar = false;
	}

	function close() {
		game.loose_frutibar = true;
		super.close();
	}

	function effect() {
		if( random(int(15/Std.tmod)) == 0 )
			game.gen_fruit();
	}

}