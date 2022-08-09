import mb2.Const;

class mb2.BossPowEau {

	var game : mb2.Game;
	var boss;

	var x,y,ang,da;
	var mc;
	var speed;
	var acc;
	var parts;	
	var gliss_time;
	var active;

	function BossPowEau( g : mb2.Game, b ) {
		game = g;
		boss = b;
		init();
		update();
	}

	function init() {
		active = false;
		mc = game.dmanager.attach("FXWater",Const.DUMMY_PLAN);
		x = boss.x;
		y = boss.y;
		parts = new Array();
		ang = boss.toBall();
		speed = 1;
		gliss_time = 0;
		da = boss.tb?0.01:0;
		acc = boss.tb?1.03:1;
	}

	function genParts() {
		var i;
		var ddx = [-1,-2,1,2];
		for(i=0;i<4;i++) {
			var p = game.dmanager.attach("FXWaterParticule", Const.DUMMY_PLAN);
			p.dx = ddx[i];
			p.dy = -( 3 + random(2));
			p._x = x;
			p._y = y;
			p.gotoAndStop(1+random(3));
			parts.push(p);
		}
	}

	function updateParts() {
		var i;
		for(i=0;i<parts.length;i++) {
			var p = parts[i];
			p._x += p.dx * Std.tmod;
			p._y += p.dy * Std.tmod;
			p.dy += 0.4 * Std.tmod;

			p._xscale -= 200 * Std.deltaT;
			p._yscale -= 200 * Std.deltaT;
			if( p._xscale < 5 ) {
				parts.remove(p);
				p.removeMovieClip();
			}
		}
	}

	function updateTrainee() {
		if( active ) {
			if( game.ball.hole_death ) {
				gliss_time = 0;
				return;
			}
			var trainee = game.dmanager.attach("FXWaterQueue",Const.BONUS_PLAN);			
			trainee._x = game.ball.x + 2;
			trainee._y = game.ball.y + 2;
			trainee._rotation = (Math.atan2(game.ball.sy,game.ball.sx) + Math.PI) * 180 / Math.PI;
			trainee._xscale = game.ball.speed * 3;
			trainee._alpha = Math.min(gliss_time,1) * 100;
		}
	}

	function update() {

		updateParts();
		updateTrainee();

		if( active ) {

			gliss_time -= Std.deltaT;

			game.ball.water = true;

			if( gliss_time < 0 && parts.length == 0 ) {
				active = false;
				game.ball.water = false;
				boss.powers.remove(this);
			}
			return;
		}

		ang += da * Std.tmod;
		speed *= Math.pow(acc,Std.tmod);
		x += Math.cos(ang) * Std.tmod * speed;
		y += Math.sin(ang) * Std.tmod * speed;
		if( x < -50 || y < -50 || x > Const.LVL_WIDTH + 50 || y > Const.LVL_HEIGHT + 50 ) {
			mc.removeMovieClip();
			boss.powers.remove(this);
			return;
		}
		mc._x = x;
		mc._y = y;
		
		var d = Math.sqrt(mb2.Tools.dist2(game.ball.mc,mc));
		if( d < 25 )
			explode();
	}

	function explode() {
		mc.removeMovieClip();
		gliss_time = 10 + random(5);
		genParts();
		active = true;
		update();
	}

	function destroy() {
		if( !active )
			explode();
		gliss_time = 0;
		update();
	}

}