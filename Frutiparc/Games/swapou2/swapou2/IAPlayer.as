import swapou2.Data;

class swapou2.IAPlayer extends swapou2.Player {

	var ia;
	var ia_pair;
	var ia_timer;
	var ia_counter;
	var ia_lock;
	var max_time;
	var need_end;

	function IAPlayer(g,pid,infos,px,py,max_time) {
		super(g,pid,infos,px,py, false);
		ia = new swapou2.IA(level);
		ia_lock = true;
		need_end = false;
		this.max_time = max_time;
	}

	function isIA() {
		return true;
	}

	function start() {
		ia_lock = false;
		ia_pair = null;
		ia.processStart(horizontal_lock > 0);
		need_end = true;
		ia_timer = 0;
		ia_counter = 0;
	}

	function getIAPair() {
		return ia_pair;
	}

	function reset() {
		if( need_end ) {
			ia.processEnd();
			need_end = false;
		}
		ia_lock = true;
		ia_pair = null;
	}

	function swapPair(p) {
		if( !super.swapPair(p) ) {
			// hack for bug fix
			reset();
			start();
			return false;
		}
		return true;
	}


	function main() {
		super.main();
		if( !ia_lock ) {

			if( random(int(100/Std.tmod)) == 0 || star_counter == Data.MAX_POWER ) {
				var h = level.calcAvgHigh();
				var h2 = Std.cast(game).player.level.calcAvgHigh();
				if( random(6) == 0 ) {
					var tmp = h;
					h = h2;
					h2 = tmp;
				}
				if( h < h2 ) {
					if( canAttack() )
						game.iaAttack();
					else if( star_counter >= Data.MAX_POWER-1 && canDefend() )
						game.iaDefend();
				} else {
					if( canDefend() )
						game.iaDefend();
					else if( star_counter >= Data.MAX_POWER-1 && canAttack() )
						game.iaAttack();
				}

				if( ia_lock )
					return;
			}

			ia_timer += Std.deltaT;
			var delta = 1 / Data.IA_TIMES[id][2];
			while( ia_timer > delta ) {
				ia_pair = ia.process(50);
				if( ia_pair != null ) {
					need_end = false;
					break;
				}
				ia_timer -= delta;
				ia_counter++;
			}
			if( ia_pair != null && ia_counter * delta > max_time ) {
				need_end = false;
				ia_pair = ia.processEnd();
			}
			if( ia_pair != null )				
				ia_lock = true;
		}
	}
}