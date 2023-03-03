import snake3.Const;
import snake3.Manager;

class snake3.bonus.Langue extends snake3.bonus.Slot {

	var n;
	var l_using;
	var l_mc;
	var l_delta;
	var l_size;
	var got_fruit;

	function Langue( game ) {
		super(game,2);
		n = 10;
		got_fruit = null;
		l_using = false;
	}

	function update() {
		Std.cast(mc).count.n = n;
		if( l_using ) {
			l_delta *= Math.pow(1.05,Std.tmod);
			l_size += l_delta * Std.tmod;
			if( l_size > 100 ) {
				l_size = 100;
				l_delta = -Math.abs(l_delta);
			}
			if( l_delta < 0 && l_size < 40 ) {
				if( got_fruit != null ) {
					game.score_factor *= 2;
					game.eat_fruit(got_fruit);
					game.score_factor /= 2;
					got_fruit = null;
				}
				activate(false);
				return;
			}

			var dist = 15;
			l_mc._x = game.snake.x + Math.cos(game.snake.ang) * dist;
			l_mc._y = game.snake.y + Math.sin(game.snake.ang) * dist;
			l_mc._rotation = game.snake.ang * 180 / Math.PI;
			l_mc.base._xscale = l_mc.col._x = (l_size/100)*(l_size/100)*100 * 1.4;
			

			if( got_fruit == null )
				got_fruit = game.level.hit_fruit(Std.getVar(l_mc,"col"));
			else {
				got_fruit._x = l_mc._x + Math.cos(game.snake.ang) * l_mc.base._xscale
				got_fruit._y = l_mc._y + Math.sin(game.snake.ang) * l_mc.base._xscale
			}
		}
	}

	function activate(b) {
		if( !b ) {
			if( got_fruit != null ) {
				game.level.pushFruit(got_fruit);
				got_fruit = null;
			}
			l_mc.removeMovieClip();
			l_using = false;
			if( n == 0 )
				game.remove_slot(this);
		}
	}

	function use() {
		if( !l_using ) {
			n--;
			l_using = true;
			l_mc = game.dmanager.attach("langue",Const.PLAN_LANGUE);
			l_delta = 7;
			l_size = 0;
			Manager.smanager.play(Const.SOUND_LANGUE);
		}
		return false;
	}

	function activable() {
		return true;
	}

}
