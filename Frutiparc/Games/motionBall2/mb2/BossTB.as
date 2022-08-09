import mb2.Const;
import mb2.Tools;
import mb2.Sound;
import mb2.Ball;
import mb2.Manager;

class mb2.BossTB {

	var game : mb2.Game;
	var timer;
	var state;
	
	var hits;
	var hit_time;
	var bulle_active;

	var mc;
	var shade;
	var bulle;
	var color;
	var dalles;

	var tb;

	var accel;
	var powers;
	var x,y;
	var tx,ty;	
	var speed;
	var fly_loops;
	var target_speed;
	var pause;
	var pause_action;

	var nkatas;
	var nblocks;
	var ncasses;
	var prev_kata;
	var target_power;

	static var NHITS = 4;

	static var ST_APPEAR = 0;
	static var ST_FLYING = 1;
	static var ST_MOVING = 2;
	static var ST_DROPING = 3;
	static var ST_WAITING = 4;
	static var ST_KATA = 5;
	static var ST_COMEBACK = 6;
	static var ST_DEATH = 7;


	function BossTB( game : mb2.Game ) {
		this.game = game;
		powers = new Array();
		dalles = new Array();
		x = Const.LVL_WIDTH / 2;
		y = Const.LVL_HEIGHT / 2;
		initTB();
		on_update();
	}

	function initTB() {
		tb = true;		
		mc = game.dmanager.attach("tourneboule",Const.BOSS_PLAN);
		bulle = game.dmanager.attach("forceBubble",Const.BOSS_PLAN);
		shade = game.dmanager.attach("TBShadow",Const.SHADE_PLAN);
		shade.gotoAndPlay("stopFly");
		mc.gotoAndPlay("stopFly");
		color = new Color(mc);
		hit_time = 0;
		state = ST_APPEAR;
		speed = 0;
		ncasses = 0;
		nblocks = 0;
		hits = 0;
		target_speed = 0;
		bulle._visible = false;

		var me = this;
		mc.animDone = function() {
			me.animDone();
		};
		mc.kataDone = function() {
			me.kataDone();
		};
	}

	function fly() {
		mc.gotoAndPlay("startFly");
		shade.gotoAndPlay("startFly");
		state = ST_FLYING;
		fly_loops = Math.round(3 / Std.tmod);
	}

	function move() {
		Sound.play(Sound.TB_HIDE);
		var fx = game.dmanager.attach("TBVanish",Const.BOSS_PLAN);
		fx._x = mc._x;
		fx._y = mc._y;
		mc.gotoAndPlay("flyVanish");
		shade.gotoAndPlay("flyVanish");
		state = ST_MOVING;
		accel = 1.05;
		target_speed = 10 + random(3);
		while( true ) {
			tx = 50 + random(Const.LVL_WIDTH-100);
			ty = 50 + random(Const.LVL_HEIGHT-100);
			var dx = x - tx;
			var dy = y - ty;
			if( Math.sqrt(dx*dx+dy*dy) > 200 )
				break;
		}
	}

	function moveDone() {
		var me = this;
		var fx = game.dmanager.attach("TBSpawn",Const.BOSS_PLAN);
		mc.stop();
		fx._x = mc._x;
		fx._y = mc._y;
		fx.animDone = function() {
			me.animDone();
		};
		state = ST_COMEBACK;
	}

	function visibleDone() {
		Sound.play(Sound.TB_HIDE);
		mc.gotoAndPlay("stopFly");
		shade.gotoAndPlay("stopFly");
		speed = 0;
		target_speed = 0;
		state = ST_DROPING;
		mc._alpha = 100;
		shade._alpha = 100;
		mc._visible = true;
		shade._visible = true;
	}

	function wait() {
		bulle_active = true;
		mc.gotoAndStop(1);
		shade.gotoAndStop(1);
		state = ST_WAITING;
		switch(hits) {
		case 0:
			timer = 0.5;
			break;
		case 1:
			timer = 0.2;
			break;
		case 2:
			timer = 0.1;
			break;
		default:
			timer = 0;
			break;
		}
	}

	function kataDone() {
		if( nkatas != 0 )
			return;		
		switch( target_power ) {
		case 0:
			Sound.play(Sound.POWER_WIND);
			powers.push( new mb2.BossPowVent(game,this) );
			var p = new mb2.BossPowVent(game,this);
			p.ray = -50;
			powers.push(p);
			break;
		case 1:
			var p;
			var delta = 80;
			Sound.play(Sound.POWER_FIRE);
			if( x > delta ) {
				p = new mb2.BossPowFeu(game,this);
				p.mc._x -= 50;
				p.mc.gotoAndPlay(1+random(5));
				powers.push(p);
			}
			if( x < Const.LVL_WIDTH - delta ) {
				p = new mb2.BossPowFeu(game,this);
				p.mc._x += 50;
				p.mc.gotoAndPlay(1+random(5));
				powers.push(p);
			}
			if( y > delta ) {
				p = new mb2.BossPowFeu(game,this);
				p.mc._y -= 50;
				p.mc.gotoAndPlay(1+random(5));
				powers.push(p);
			}
			if( y < Const.LVL_HEIGHT - delta ) {
				p = new mb2.BossPowFeu(game,this);
				p.mc._y += 50;
				p.mc.gotoAndPlay(1+random(5));
				powers.push(p);
			}
			break;
		case 2:
			var p;
			Sound.play(Sound.POWER_WATER);
			p = new mb2.BossPowEau(game,this);
			p.ang = Math.PI / 4;
			powers.push(p);
			p = new mb2.BossPowEau(game,this);
			p.ang = 3 * Math.PI / 4;
			powers.push(p);
			p = new mb2.BossPowEau(game,this);
			p.ang = - Math.PI / 4;
			powers.push(p);
			p = new mb2.BossPowEau(game,this);
			p.ang = - 3 * Math.PI / 4;
			powers.push(p);
			break;
		case 3:	
			Sound.play(Sound.POWER_EARTH);
			powers.push( new mb2.BossPowTerre(game,this) );
			break;
		case 4:
			var i;
			var n = random(3)+1;
			ncasses += n;
			for(i=0;i<n;i++) {
				var px,py;
				var hole = game.level.interf.walltable[0][8];
				do {
					px = random(14);
					py = random(9);
					if( (px == 0 && py == 0) || (px == 13 && py == 0) || (px == 6 && py == 4) || (px == 7 && py == 4) || (px == 6 && py == 5) || (px == 7 && py == 5) )
						continue;
					if( game.level.interf.walltable[px][py] == null )
						break;
				} while( true );
				game.level.interf.walltable[px][py] = { btype : -1 };
				var dmc = game.dmanager.attach("FXDalleCut",Const.BONUS_PLAN);
				dmc._x = px * 10 * Const.DELTA + Const.BORDER_SIZE;
				dmc._y = py * 10 * Const.DELTA + Const.BORDER_SIZE;
				dalles.push({ mc : dmc, px : px, py : py });
			}
			break;
		case 5:
			var px,py;
			var hole = game.level.interf.walltable[0][8];
			nblocks++;
			do {
				px = random(14);
				py = random(9);
				if( (px == 0 && py == 0) || (px == 13 && py == 0) || (px == 6 && py == 4) || (px == 7 && py == 4) || (px == 6 && py == 5) || (px == 7 && py == 5) )
					continue;
				if( game.level.interf.walltable[px][py] == null )
					break;
			} while( true );
			game.level.gen_bumper({ btype : 6, x : px * 10 + Const.BORDER_CSIZE, y : py * 10 + Const.BORDER_CSIZE });
			game.level.interf.update_walls();
			break;
		}
	}

	function die() {
		mc.gotoAndPlay("death");
		shade.gotoAndPlay("death");
		state = ST_DEATH;

		var i;
		for(i=0;i<powers.length;i++)
			powers[i].destroy();
	}

	function nextKata() {
		if( nkatas == 0 ) {
			if( hits >= 20 ) {
				die();
			} else if( hits >= NHITS ) {
				hit_time = 1;
				hits++;
				waitDone();
			} else
				fly();
			return;
		}

		var k;
		var sk;
		if( nkatas == 3 )
			k = target_power+1;			
		else {
			do {
				k = random(6)+1;
			} while( k == prev_kata );
		}
		if( nkatas == 1 )
			sk = 4;
		else
			sk = 1+random(3);
		Sound.play("kata"+sk);
		prev_kata = k;
		mc.gotoAndStop("kata"+k);
		shade.gotoAndStop("kata"+k);
		nkatas--;
		state = ST_KATA;
	}

	function waitDone() {
		nkatas = 3;
		while( true ) {
			target_power = random(6);
			if( hits >= NHITS && (target_power == 1 || target_power == 3) )
				continue;
			if( target_power == 4 && ncasses > 20 )
				continue;
			if( target_power == 5 && nblocks > 20 )
				continue;
			if( target_power == 3 ) {
				var px = int(((x / Const.DELTA) - Const.BORDER_CSIZE)/10);
				var py = int(((y / Const.DELTA) - Const.BORDER_CSIZE)/10);
				if( game.level.interf.walltable[px][py].btype == 7 )
					continue;
			}
			break;
		}
		timer = 0;
		nextKata();
		if( hits >= NHITS )
			nkatas = 0;
	}

	function animDoneReplay() {
		mc.play();
		shade.play();
		animDone();
	}

	function animDone() {

		if( game.game_over_flag ) {
			mc.stop();
			shade.stop();
			return;
		}

		if( pause ) {
			pause_action = animDoneReplay;
			mc.stop();
			shade.stop();
			return;
		}

		switch( state ) {
		case ST_APPEAR:
			fly();
			break;
		case ST_FLYING:
			if( fly_loops-- <= 0 )
				move();
			else {
				mc.gotoAndPlay("fly");
				shade.gotoAndPlay("fly");
			}
			break;
		case ST_DROPING:
			wait();
			break;
		case ST_KATA:
			nextKata();
			break;
		case ST_COMEBACK:
			visibleDone();
			break;
		case ST_DEATH:
			mc.stop();
			shade.stop();
			game.boss_update = null;
			game.gameOver(Const.CAUSE_WINS);
			break;
		}
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

	function onPause(f) {
		pause = f;
		if( !pause ) {
			pause_action();
			pause_action = null;
		}
	}	

	function on_update() {
		var tmod = Std.tmod;

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

		var i;
		for(i=0;i<powers.length;i++)
			powers[i].update();

		for(i=0;i<dalles.length;i++) {
			var d = dalles[i];
			if( !d.mc._name ) {
				dalles.splice(i,1);
				i--;
				game.level.interf.walltable[d.px][d.py] = game.level.interf.walltable[0][8];
				var dmc = game.dmanager.attach("dalle",Const.BONUS_PLAN);
				dmc._x = d.px * 10 * Const.DELTA + Const.BORDER_SIZE;
				dmc._y = d.py * 10 * Const.DELTA + Const.BORDER_SIZE;
				if( dalles.length == 0 ) {
					Sound.play(Sound.CASSE);
					game.level.interf.update_walls();
				}
			}
		}

		switch( state ) {
		case ST_MOVING:
			var dx = tx - x;
			var dy = ty - y;
			var d = Math.sqrt(dx*dx+dy*dy);
			if( d > 0 ) {
				dx /= d;
				dy /= d;
			}
			var s = Math.min(speed * Std.tmod,d);
			x += dx * s;
			y += dy * s;
			if( game.ball.btype == 6 ) {
				dx = game.ball.x - x;
				dy = game.ball.y - y;
				var dball = dx*dx+dy*dy;
				var a = int(200000 / dball);
				mc._alpha = a;
				shade._alpha = a;
				mc._visible = true;
				shade._visible = true;
			} else {
				mc._visible = false;
				shade._visible = false;
			}
			if( s == d && mc._currentframe >= 169 && mc._currentframe <= 177)
				moveDone();
			break;
		case ST_KATA:
			timer += Math.pow(Std.tmod,1.3);
			while( timer > 1 && state == ST_KATA ) {
				timer--;
				mc.nextFrame();
				shade.nextFrame();
			}
			break;
		case ST_WAITING:
			timer -= Std.deltaT;
			if( timer <= 0 )
				waitDone();
			break;		
		}
		
		if( state == ST_WAITING || state == ST_KATA )
			collide();		

		if( bulle._alpha > 0 ) {
			bulle._alpha -= Std.deltaT * 200;
			if( bulle._alpha < 0 ) {
				bulle._alpha = 0;
				bulle._visible = false;
			}
		}

		if( hit_time > 0 ) {
			hit_time -= Std.deltaT;
			if( hit_time < 0 ) {
				hit_time = 0;
				color.reset();
			} else {
				var ct = {
					ra : 100,
					rb : hit_time * 300,
					ba : 100,
					bb : 0,
					ga : 100,
					gb : 0,
					aa : 100,
					ab : 0
				};
				color.setTransform(ct);
			}
		}

		mc._x = x;	
		mc._y = y;
		shade._x = x;
		shade._y = y;
		bulle._x = x;
		bulle._y = y;
	}

	function collide() {
		var dx = game.ball.x - x;
		var dy = game.ball.y - y;
		var d = Math.sqrt(dx*dx+dy*dy);
		if( d < 30 ) {
			if( bulle_active ) {
				bulle._visible = true;
				bulle._alpha = 100;
				bulle_active = false;
			} else if( hit_time == 0 ) {
				Sound.play(Sound.TB_HIT);
				hit_time = 1;
				hits++;
			}
			if( d != 0 ) {
				dx /= d;
				dy /= d;
			}
			game.ball.sx += 30 * dx;
			game.ball.sy += 30 * dy;
		}
	}

}
