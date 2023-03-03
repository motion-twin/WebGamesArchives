import snake3.Const;

class snake3.bonus.Pieu extends snake3.bonus.TimedSlot {

	function Pieu( game : snake3.Game ) {
		super(game,15,Const.TIME_PIEU);		
	}

	function close() {
		game.pieu = false;
		super.close();
	}

	function effect() {
		game.pieu = true;
	}


}
