import snake3.Manager;
import snake3.Const;

class snake3.bonus.Ciseaux extends snake3.bonus.Slot {

	var q_pos;
	var q_time;
	var q_delta;
	var level;

	static var CUTS = [ 3 , 7, 12 ]

	function Ciseaux( game, lvl ) {
		super(game,1);
		level = lvl;
		q_pos = 0;
		q_time = 0;
		q_delta = 1;
	}

	function update() {
		q_time += Std.deltaT / (3.5 - level);
		while( q_time > 0.1) {
			q_pos += q_delta;
			q_time -= 0.1;
		}

		if( q_pos <= 0 ) {
			q_pos = 0;
			q_delta = 1;
		}

		var q_max = Math.min(CUTS[level-1],game.snake.len-4)-1;

		if( q_max < 0 ) {
			q_max = 0;
			q_pos = -1;
		}

		if( q_pos >= q_max ) {
			q_pos = q_max;
			q_delta = -1;
		}

		game.snake.set_color(q_pos+1,Const.COLOR_CISEAUX);
	}

	function activate( b ) {
		if( !b )
			game.snake.set_color(0,0);
	}

	function use() {
		activate(false);
		Manager.smanager.play(Const.SOUND_CISEAUX);
		game.snake.cut(q_pos+1);
		return true;
	}

	function activable() {
		return true;
	}

}
