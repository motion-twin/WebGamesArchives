import snake3.Const;
import snake3.Manager;

class snake3.bonus.Bombe extends snake3.bonus.Slot {

	var x,y;

	function Bombe( game ) {
		super(game,13);
	}

	function explose() {
		var q = game.snake.queue;
		var l = q.length;
		var i;
		for(i=1;i<game.snake.len;i++) {
			var p = q[l - i * 5 - 3];
			var d = (p.x - x) * (p.x - x) + (p.y - y) * (p.y - y);
			if( d < 160*160 )
				break;
		}
		var di = int(i / 3);
		while( i < game.snake.len ) {
			game.snake.explode(0xFFFFFF);
			game.snake.len -= di; 
			if( game.snake.len <= i )
				game.snake.len = i;
		}
		if( i < 2 )
			game.game_over();
	}

	function use() {
		var b = game.dmanager.attach("bombe",Const.PLAN_BONUSES);
		x = game.snake.x;
		y = game.snake.y;
		b._x = x;
		b._y = y;
		var time = Const.TIME_BOMBE;
		var id = { _ : 0 };
		var f_update;
		function update() {
			time -= Std.deltaT;
			if( time <= 0 ) {
				b.play();
				game.updates.remove(id,f_update);
			}
		}
		f_update = update;
		game.updates.push(id,update);


		var me = this;
		function loc_explose() {
			me.explose();
		}
		Std.setVar(game.mc,"bombe_explose",loc_explose);
		return true;
	}

	function activable() {
		return true;
	}

}