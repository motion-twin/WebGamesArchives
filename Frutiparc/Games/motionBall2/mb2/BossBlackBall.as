import mb2.Const;
import mb2.Tools;
import mb2.Sound;
import mb2.Ball;

class mb2.Boss2 {

	var game : mb2.Game;
	var ball : mb2.Ball;
	var timer;
	var state;

	var ang;
	var speed;
	var accel;
	var power;
	var target_speed;

	static var STATE_PROBAS = [1,5,2,2];

	static var ST_WAIT = 0;
	static var ST_SEARCH = 1;
	static var ST_FONCE = 2;
	static var ST_EVADE = 3;

	function Boss2( game : mb2.Game ) {
		ball = new mb2.Ball(game);
		ball.btype = 7;
		ball.update_skin();
		ball.control = false;
		ball.kill = undefined;
		this.game = game;		
		power = 1.5;
		target_speed = 0;
		speed = 0;
		ang = 0;
		change_pattern();
	}

	function normalize(a) {
		a %= (Math.PI * 2);
		if( a <= -Math.PI )
			a += Math.PI * 2;
		else if( a > Math.PI )
			a -= Math.PI * 2;
		return a;
	}

	function on_update() {
		var tmod = Std.tmod;

		timer -= Std.deltaT;
		if( timer <= 0 )
			change_pattern();
		
		if( speed > target_speed ) {
			speed *= Math.pow(0.97,tmod);
			if( speed < target_speed )
				speed = target_speed;
		} else if( speed < target_speed ) {
			if( speed <= 1 )
				speed = 1;
			speed *= Math.pow(accel,tmod);
			if( speed > target_speed )
				speed = target_speed;
		}		

		switch( state ) {
		case ST_WAIT:
			break;		
		case ST_SEARCH:
			var ta = Math.atan2(game.ball.y - ball.y, game.ball.x - ball.x);
			var ca = normalize(ta - ang);
			var da = Math.asin( ca );
			if( da > 0 )
				ang += 0.1 * tmod;
			else
				ang -= 0.1 * tmod;
			break;
		case ST_FONCE:
			break;
		case ST_EVADE:
			var ta = Math.atan2(game.ball.y - ball.y, game.ball.x - ball.x);
			var ca = normalize(ta - ang);
			var da = Math.asin( ca );
			if( da < 0 )
				ang += 0.1 * tmod;
			else
				ang -= 0.1 * tmod;
			break;
        }

		var dx = ball.x - game.ball.x;
		var dy = ball.y - game.ball.y;
		var d = Math.sqrt(dx * dx + dy * dy);
		var ds = speed * Std.tmod;
		if( d > Const.BALL_RAYSIZE * 2 + ds ) {
			ball.x += Math.cos(ang) * ds;
			ball.y += Math.sin(ang) * ds;
		} else {			
			while( ds > 0 ) {
				var s = Math.min(ds,1);
				ds -= 1;
				ball.x += Math.cos(ang) * s;
				ball.y += Math.sin(ang) * s;
				if( collide() )
					break;
			}
		}
		ball.mc._x = ball.x + Const.DELTA / 2;
		ball.mc._y = ball.y + Const.DELTA / 2;
		ball.shadow._x = ball.mc._x + Ball.SHADOW_DECAL;
		ball.shadow._y = ball.mc._y + Ball.SHADOW_DECAL;
		ball.move_stones();
	}

	function collide() {
		var dx = ball.x - game.ball.x;
		var dy = ball.y - game.ball.y;
		var d = Math.sqrt(dx * dx + dy * dy);
		if( d < Const.BALL_RAYSIZE * 2 ) {
			dx /= d;
			dy /= d;

			var vx = Math.cos(ang) * speed;
			var vy = Math.sin(ang) * speed;


			var a1 = vx * dx + vy * dy;
			var a2 = game.ball.sx * dx + game.ball.sy * dy;

			var p = (2.0 * (a1 - a2)) / (power + 1);

			vx -= p * dx;
			vy -= p * dy;

			game.ball.sx += p * power * dx;
			game.ball.sy += p * power * dy;

			ang = Math.atan2(vy,vx);
			speed = Math.sqrt(vx*vx+vy*vy);
			return true;
		}
		return false;
	}

	function change_pattern() {
		state = Std.randomProbas(STATE_PROBAS);
		accel = 1.05;
		switch( state ) {
		case ST_WAIT:
			timer = 0.5;
			target_speed = 0;
			break;
		case ST_SEARCH:
			timer = 1 + random(100)/100;
			target_speed = 5;
			break;
		case ST_FONCE:
			accel = 1.15;
			timer = 0.5;
			ang = Math.atan2(game.ball.y - ball.y, game.ball.x - ball.x);
			target_speed = 15;
			break;
		case ST_EVADE:
			accel = 1.1;
			timer = 1 + random(100)/100;
			target_speed = 8;
			break;
		}
	}

}