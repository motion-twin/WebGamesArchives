import mb2.Const;
import mb2.Tools;
import mb2.Sound;
import mb2.Ball;
import mb2.Manager;

class mb2.BossSerpent {

	var game : mb2.Game;
	var timer;
	var state;
	var excite;

	var x,y;
	var ang;
	var speed;
	var accel;
	var power;
	var delta;
	var elt;
	var target_speed;

	var hit;
	var parts;
	var ecailles;
	var smc;
	var histo;
	var rot_ang;
	var powers;

	var dying;
	var berserk_time;

	static var STATE_PROBAS = [
		[1,5,2,2,5],
		[2,0,0,10,2]
	];

	static var NHITS = 3;

	static var EAU = 1;
	static var FEU = 2;
	static var VENT = 3;
	static var TERRE = 4;

	static var ST_WAIT = 0;
	static var ST_SEARCH = 1;
	static var ST_FONCE = 2;
	static var ST_EVADE = 3;
	static var ST_POWER = 4;
	static var ST_RECALL = 5;

	function BossSerpent( game : mb2.Game ) {
		var lbg = game.dmanager.attach("logoBg",Const.BG_PLAN);		
		elt = Manager.play_mode_param + 1;
		lbg.gotoAndStop(elt);

		this.game = game;
		powers = new Array();
		ecailles = new Array();
		power = 3;		
		dying = false;
		excite = 0;
		target_speed = 0;
		berserk_time = 0;
		speed = 0;
		ang = 0;
		rot_ang = 0;
		x = Const.LVL_WIDTH / 2;
		y = Const.LVL_HEIGHT / 2;
		initSerpent();
		change_pattern();
		setExcite(false);
		var i;
		for(i=0;i<5;i++)
			on_update();
	}

	function updateScales() {
		var i;
		for(i=1;i<parts.length-1;i++) {
			var s = 1 - (i / parts.length);
			var p = parts[i];
			p._xscale = s * 100;
			p._yscale = s * 100;
			p.ray = s * 50;
			p.rsq = (p.ray + Const.BALL_RAYSIZE/2) * (p.ray + Const.BALL_RAYSIZE/2);
		}
	}

	function initSerpent() {		
		parts = new Array();
		smc = game.dmanager.empty(Const.BOSS_PLAN);
		var i;
		for(i=0;i<NHITS+2;i++) {
			var p = Std.attachMC(smc,"snake",NHITS+2 - i);
			if( i == 0 ) {
				p.gotoAndStop(1);
				p.crane.gotoAndStop(elt);
				p.ray = 20;
			} else if( i == NHITS+2 - 1 ) {
				p.gotoAndStop(3);
				p.ray = 25;
			} else
				p.gotoAndStop(2);
			p.ang = ang;
			p.gfx.gotoAndStop(elt);
			p.rsq = (p.ray + Const.BALL_RAYSIZE/2) * (p.ray + Const.BALL_RAYSIZE/2);
			parts.push(p);
		}
		updateScales();
		histo = new Array();
		histo.push({x : x, y : y, a : ang});
	}

	function normalize(a) {
		a %= (Math.PI * 2);
		if( a <= -Math.PI )
			a += Math.PI * 2;
		else if( a > Math.PI )
			a -= Math.PI * 2;
		return a;
	}

	function toBall() {
		return Math.atan2(game.ball.y - y, game.ball.x - x);
	}

	function recall() {
		hit = false;
		var d = 60;
		var tang;
		if( x < Const.BOSS_MIN_X + d ) {
			x = Const.BOSS_MIN_X + d;
			hit = true;			
		}
		if( y < Const.BOSS_MIN_Y + d) {
			y = Const.BOSS_MIN_Y + d;
			hit = true;			
		}
		if( x > Const.LVL_WIDTH-Const.BOSS_MIN_X-d ) {
			x = Const.LVL_WIDTH-Const.BOSS_MIN_X-d;
			hit = true;
		}
		if( y > Const.LVL_HEIGHT-Const.BOSS_MAX_Y-d ) {
			y = Const.LVL_HEIGHT-Const.BOSS_MAX_Y-d;
			hit = true;			
		}
		if( hit && state != ST_RECALL ) {
			delta = 0.3;
			if( random(2) == 0 )
				delta *= -1;
			state = ST_RECALL;
			timer = 1;
		}
	}

	function setExcite(b) {
		var p = parts[0];
		if( berserk_time > 0 ) {
			p.o1.gotoAndStop(3);
			p.o2.gotoAndStop(3);
		} else {
			p.o1.gotoAndStop(b?1:2);
			p.o2.gotoAndStop(b?1:2);
		}
	}

	function updateEcailles() {
		var i;
		for(i=0;i<ecailles.length;i++) {
			var e = ecailles[i];
			e._x += Math.cos(e.ang) * Std.tmod * 10;
			e._y += Math.sin(e.ang) * Std.tmod * 10;
			e._rotation += 5 * Std.tmod;
			e._xscale -= 15 * Std.tmod;
			e._yscale -= 15 * Std.tmod;
			if( e._xscale < 10 ) {
				ecailles.remove(e);
				e.removeMovieClip();
				i--;
			}
		}
	}

	function on_update() {
		var tmod = Std.tmod;

		if( berserk_time == 0 && excite > 0 ) {
			excite -= Std.deltaT;
			if( excite <= 0 ) {
				excite = 0;
				setExcite(false);
				change_pattern();
			}
		}

		if( berserk_time > 0 && !game.ball.hole_death ) {
			berserk_time -= Std.deltaT;
			if( berserk_time <= 0 ) {
				var i;
				for(i=0;i<powers.length;i++)
					powers[i].destroy();
				dying = true;
			}
		}

		var i;
		for(i=0;i<powers.length;i++)
			powers[i].update();
		updateEcailles();

		if( dying ) {
			var cont = false;
			for(i=0;i<parts.length;i++) {
				var p = parts[i];
				p._rotation += 30 * Std.tmod;
				if( p._xscale > 0 ) {				
					p._xscale -= Std.deltaT * 100;
					p._yscale -= Std.deltaT * 100;
					cont = cont || (p._xscale > 0);
				}
			}
			if( !cont ) {
				smc.removeMovieClip();
				game.boss_update = null;
				game.gameOver(Const.CAUSE_WINS);
			}
			return;
		}

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
			var ta = toBall();
			var ca = normalize(ta - ang);
			var da = Math.asin( ca );			
			if( da > 0 )
				ang += delta * tmod;
			else
				ang -= delta * tmod;
			break;
		case ST_FONCE:
			break;
		case ST_EVADE:
			var ta = toBall() + Math.PI;
			var ca = normalize(ta - ang);
			var da = Math.asin( ca );
			if( da > 0 )
				ang += delta * tmod;
			else
				ang -= delta * tmod;
			break;
		case ST_RECALL:
			delta *= Math.pow(0.97,tmod);
			if( Math.abs(delta) < 0.1 ) {
				if( delta < 0 )
					delta = -0.1;
				else
					delta = 0.1;
			}
			ang += delta * tmod;
			if( !hit )
				change_pattern();
			break;		
        }

		var ds = speed * Std.tmod;
		ang = normalize(ang);
		
		if( ds <= 0 ) {
			collide();
			histo.push({ x : x, y : y, a : ang });
		}

		while( ds > 0 ) {
			var s = Math.min(ds,1);
			ds -= 1;
			x += Math.cos(ang) * s;
			y += Math.sin(ang) * s;
			recall();
			histo.push({ x : x, y : y, a : ang });
			collide();
		}
		
		var p = histo.length - 1 + parts[0].ray;
		for(i=0;i<parts.length;i++) {
			var mc = parts[i];
			p -= mc.ray;
			mc.pos = histo[int(Math.max(p,0))];
			var dif = normalize(mc.pos.a - mc.ang);
			mc.ang += dif * ((excite > 0) ? 0.4 : 0.3) * tmod;
			mc._rotation = mc.ang * 180 / Math.PI + 180;
			mc._x = mc.pos.x;
			mc._y = mc.pos.y;
			p -= mc.ray;
		}
	}

	function collideBall(n) {
		var p = parts[n];
		var dx = p.pos.x - game.ball.x;
		var dy = p.pos.y - game.ball.y;
		var d = Math.sqrt(dx*dx+dy*dy);
		if( d != 0 ) {
			dx /= d;
			dy /= d;
		}
		game.ball.sx -= power * dx;
		game.ball.sy -= power * dy;
		Sound.play(Sound.SERPENT_COLLIDE);
	}

	function explode() {
		if( parts.length > 2 ) {
			var p = parts[1];
			Sound.play(Sound.SERPENT_HIT);
			var i;
			for(i=0;i<5;i++) {
				var e = game.dmanager.attach("snakePart",Const.BOSS_PLAN);				
				var ray = random(p.ray/2) + p.ray/2;
				e.gotoAndStop(elt);
				e._rotation = random(360);
				e.ang = i * Math.PI / 2.5;
				e._x = p._x + Math.cos(e.ang) * ray;
				e._y = p._y + Math.sin(e.ang) * ray;
				e._xscale = 300;
				e._yscale = 300;
				ecailles.push(e);
			}

			parts.remove(p);
			updateScales();
			p.removeMovieClip();
			excite = 1;
			if( parts.length == 2 ) {
				berserk_time = 10;
				setExcite(true);
			}
			change_pattern(ST_FONCE);
		}
	}

	function collide() {
		if( game.ball.hole_death )
			return false;

		var bx = game.ball.x;
		var by = game.ball.y;
		var p = parts[0];
		if( p.hitTest(bx+Const.POS_X,by+Const.POS_Y,true) ) {
			if( Math.abs(normalize(ang - toBall())) < 0.3 ) {
				p.crane.anim.play();
				setExcite(true);
				if( excite == 0 )
					explode();
				excite = 6 + random(4);
			}
			collideBall(0);
			return true;
		}
		p = parts[parts.length-1];
		if( p.hitTest(bx+Const.POS_X,by+Const.POS_Y,true) && game.ball.clign_count <= 0 ) {
			Sound.play(Sound.BUMPER_DEATH);
			game.ball.die();
			return true;
		}
		var i;
		for(i=1;i<parts.length;i++) {
			p = parts[i];
			var dx = bx - p.pos.x;
			var dy = by - p.pos.y;
			if( dx * dx + dy * dy < p.rsq ) {
				collideBall(i);
				return true;
			}
		}
		return false;
	}

	function change_pattern(s) {
		var is_excite = (excite > 0) || (berserk_time > 0);
		if( s != undefined )
			state = s;
		else
			state = Std.randomProbas(STATE_PROBAS[is_excite?0:1]);
		accel = 1.05;
		delta = is_excite ? 0.05 : 0.03;
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
			ang = toBall();
			target_speed = 15;
			break;
		case ST_EVADE:
			accel = 1.1;
			timer = 1 + random(100)/100;
			target_speed = is_excite?8:4;
			break;
		case ST_POWER:
			switch( elt ) {
			case VENT:
				if( powers.length < 1 ) {
					Sound.play(Sound.POWER_WIND);
					powers.push( new mb2.BossPowVent(game,this) );
				}
				break;
			case FEU:
				if( powers.length < 3 ) {
					Sound.play(Sound.POWER_FIRE);
					powers.push( new mb2.BossPowFeu(game,this) );
				}
				break;
			case EAU:
				if( powers.length < 2 ) {
					Sound.play(Sound.POWER_WATER);
					powers.push( new mb2.BossPowEau(game,this) );
				}
				break;
			case TERRE:
				if( powers.length < 3 ) {
					Sound.play(Sound.POWER_EARTH);
					powers.push( new mb2.BossPowTerre(game,this) );
				}
				break;
			}
			change_pattern();
			break;
		}
		if( berserk_time > 0 ) {			
			timer /= 2;
			target_speed *= 1.3;
			delta *= 2;
		}
	}

}
