class Monster {	

	var game : Game;
	var type : int;
	var mc : {> MovieClip, sub : {> MovieClip, col : MovieClip } };
	var x : float;
	var y : float;
	var dx : float;
	var dy : float;
	var speed : float;
	var nsteps : int;
	var ang : float;
	var ray : float;
	var time : float;
	var wait : float;
	var flag : bool;
	var next : { x : float, y : float };
	var pv : int;
	var flash_time : float;

	function new(g,t) {
		game = g;
		type = t;
		mc = downcast(game.dmanager.attach("monster",Const.PLAN_MONSTER));
		mc.gotoAndStop(string(t+1));
		init();
		mc._x = x;
		mc._y = y;
	}

	function genRandPos(out) {
		var x = Std.random(260) + 20;
		var y = Std.random(260) + 20;
		if( out ) {
			switch( Std.random(4) ) {
			case 0:
				x = -20;
				break;
			case 1:
				x = 320;
				break;
			case 2:
				y = -20;
				break;
			case 3:
				y = 320;
				break;
			}
		}
		return { x : x, y : y };
	}

	function init() {
		var p = genRandPos(true);
		x = p.x;
		y = p.y;

		var ddx = x - game.hero.x;
		var ddy = y - game.hero.y;
		var d = Math.sqrt(ddx*ddx+ddy*ddy);
		if( d < 70 ) {
			init();
			return;
		}

		switch( type ) {
		case 0:
			pv = 5;
			nsteps = 10;
			nextStep();
			dx = next.x - x;
			dy = next.y - y;
			speed = 2 + game.level / 40;
			break;
		case 1:
			pv = 3;
			nsteps = 20;
			nextStep();
			dx = Math.cos(ang);
			dy = Math.sin(ang);
			speed = 4 + game.level / 100;
			break;
		case 2:
			pv = 10;
			next = genRandPos(false);
			speed = 2 + game.level / 100;
			time = 0;
			break;
		}
	}

	function fire3() {
		var a = Math.atan2(dy,dx);
		var s = 4;
		game.tirs.push( new Tir(game,1,x,y,s * Math.cos(a),s * Math.sin(a)) );
		game.tirs.push( new Tir(game,1,x,y,s * Math.cos(a+0.2),s * Math.sin(a+0.2)) );
		game.tirs.push( new Tir(game,1,x,y,s * Math.cos(a-0.2),s * Math.sin(a-0.2)) );
	}

	function fire4() {
		var s = 3;
		game.tirs.push( new Tir(game,2,x,y,-s,-s) );
		game.tirs.push( new Tir(game,2,x,y,-s,s) );
		game.tirs.push( new Tir(game,2,x,y,s,-s) );
		game.tirs.push( new Tir(game,2,x,y,s,s) );
	}

	function nextStep() {
		switch( type ) {
		case 0:
			next = genRandPos((--nsteps) <= 0);
			if( dx != null && Std.random(5) == 0 ) {
				fire3();
				wait = 2;
			}
			break;
		case 1:
			next = genRandPos((--nsteps) <= 0);
			ang = Math.atan2(y-next.y,x-next.x);
			ray = Math.sqrt((x - next.x) * (x - next.x) + (y - next.y) * (y - next.y));
			break;
		case 2:
			next = genRandPos(false);
			break;
		}
	}

	function touched( t : Tir ) {

		pv -= t.pow;

		if( pv > 0 ) {
			if( !game.game_over )
				KKApi.addScore(Const.MONSTER_POINTS[type]);
			flash_time = 1;
			var vx = x - game.hero.x;
			var vy = y - game.hero.y;
			var v = Math.sqrt(vx*vx+vy*vy);
			var d = Math.sqrt(dx*dx+dy*dy);
			dx += vx * d / v;
			dy += vy * d / v;
			return;
		}

		game.doCombo();

		game.stats.$k[type]++;
		mc.removeMovieClip();
		game.monsters.remove(this);

		{
			var b = downcast(game.dmanager.attach("bonus",Const.PLAN_BONUS));
			b._x = x;
			b._y = y;
			if( b._x < 10 )
				b._x = 10;
			if( b._y < 10 )
				b._y = 10;
			if( b._x > 290 )
				b._x = 290;
			if( b._y > 290 )
				b._y = 290;
			b.t = Tools.randomProbas(Const.BONUS);
			b.time = 15;
			b.gotoAndStop(string(b.t+1));
			game.bonus.push(upcast(b));	
		}

		switch( type ) {
		case 0:
			var b = game.dmanager.attach("boum",Const.PLAN_PART);
			b._x = x;
			b._y = y;
			break;
		case 1:
			var i;
			for(i=1;i<6;i++) {
				var b = downcast(game.dmanager.attach("heliPart",Const.PLAN_PART));
				b._x = x;
				b._y = y;
				b.gotoAndStop(string(i));
				b.x = x;
				b.y = 0;
				b.vx = (Std.random(15) - 7) / 3;
				b.vy = - ( 5 + Std.random(4) );
				b.by = y;
				game.addPart(upcast(b));
			}
			break;
		case 2:
			var b = game.dmanager.attach("blam",Const.PLAN_PART);
			b._x = x;
			b._y = y;
			break;
		}
	}

	function update() {

		if( flash_time > 0 ) {
			var c = new Color(mc);
			flash_time -= Timer.tmod * 0.15;
			if( flash_time < 0 )
				c.reset();
			else {
				var k = int(flash_time * 250);
				c.setTransform({ ra : 100, rb : k, ba : 100, bb : k, ga : 100, gb : k, aa : 100, ab : 0 });
			}
		}

		if( wait > 0 ) {
			wait -= Timer.deltaT;
			if( type == 2 ) {
				time += Timer.tmod;
				if( flag ) {
					if( time > 30 )
						time = 30;
				} else {
					if( time > 43 )
						time = 0;
					else if( time < 30 )
						time = time % 14;
				}
				mc.sub.gotoAndStop(string(int(time+1)));
			}
		} else
		switch( type ) {
		case 0:
			var tdx = next.x - x;
			var tdy = next.y - y;
			var p = Math.pow(0.95,Timer.tmod);
			dx = dx * p + tdx * (1 - p);
			dy = dy * p + tdy * (1 - p);

			//----------
			var ang = Math.atan2(dy,dx);
			if( ang < 0 )
				mc.sub.gotoAndStop(string(int(-ang * 30/Math.PI) + 1));
			else
				mc.sub.gotoAndStop(string(31 + int((-ang + Math.PI) * 30/Math.PI)));
			//----------
			
			var s = Timer.tmod * speed / Math.sqrt(dx*dx+dy*dy);
			x += s * dx;
			y += s * dy;
			if( Math.abs(x-next.x) + Math.abs(y-next.y) < Timer.tmod * speed * 2 ) {
				if( nsteps <= 0 ) {
					mc.removeMovieClip();
					return false;
				}
				nextStep();
			}
			break;
		case 1:
			ray -= Timer.tmod;
			ang += (100 / ray) * 0.05 * Timer.tmod;
			var px = next.x + Math.cos(ang) * ray;
			var py = next.y + Math.sin(ang) * ray;
			var tdx = px - x;
			var tdy = py - y;
			
			var p = Math.pow(0.95,Timer.tmod);

			dx = dx * p + tdx * (1 - p);
			dy = dy * p + tdy * (1 - p);
			var s = speed * Timer.tmod / Math.sqrt(dx*dx+dy*dy);

			x += dx * s;
			y += dy * s;

			//----------
			var ang = Math.atan2(dy,dx);
			if( ang < 0 )
				mc.sub.gotoAndStop(string(int(-ang * 30/Math.PI) + 1));
			else
				mc.sub.gotoAndStop(string(31 + int((-ang + Math.PI) * 30/Math.PI)));
			//----------


			if( ray < 20 || ang > Math.PI * 2 )
				nextStep();

			if( x < -10 || y < -10 || x > 310 || y > 310 ) {
				time += Timer.deltaT;
				if( time > 3 ) {
					mc.removeMovieClip();
					return false;
				}
			} else
				time = 0;
			break;
		case 2:

			if( flag ) {
				flag = false;
				fire4();
				wait = 1;
				nextStep();
				return true;
			}

			time += Timer.tmod;
			mc.sub.gotoAndStop(string(int(time%14+1)));

			// move
			var p = Math.pow(0.97,Timer.tmod);
			x = x * p + next.x * (1 - p);
			y = y * p + next.y * (1 - p);

			var ddx = next.x - x;
			var ddy = next.y - y;
			var d = Math.sqrt(ddx*ddx+ddy*ddy);

			if( d < 20 ) {
				flag = true;
				wait = 2;
				time = time % 14;
			}
			break;
		}

		mc._x = x;
		mc._y = y;
		return true;
	}

}