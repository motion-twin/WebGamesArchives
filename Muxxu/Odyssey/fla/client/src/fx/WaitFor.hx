package fx;
import Protocole;
import mt.bumdum9.Lib;



class WaitFor extends mt.fx.Fx {//}
	
	var game:Game;
	var action:Void->Void;

	public function new(game) {
		this.game = game;
		super();

	}

	
	// UPDATE
	override function update() {
		super.update();
		var ok = true;
		for ( h in game.heroes ) ok = ok && h.board.ready;
		if ( ok ) kill();
		
	}

	
	
//{
}