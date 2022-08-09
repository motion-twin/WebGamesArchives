import mb2.Const;
import mb2.Tools;
import mb2.Sound;

class mb2.Boss {

	var game : mb2.Game;

	var mc, shade;
	var oeil;

	var px, py;
	var hits;
	var pat_jmp;
	var wait;
	var change_pattern;
	var color;
	var dodo;
	var collide;
	var hit_time;
	var ang;

	var jump_pos;
	var jump_time;
	var jump_speed;
	var jump_size;
	var jump_casse;
	var njumps;
	var ang_speed;
	var aspire_time;
	var eat_done;
	var do_tir;
	var tir;
	var speed;
	var particules;

	var next_frame;

	function Boss( game : mb2.Game ) {
		mc = game.dmanager.attach("boss",Const.BOSS_PLAN);
		mc._alpha = 0;
		mc.control = this;
		shade = game.dmanager.attach("boss shade",Const.SHADE_PLAN);
		shade._alpha = 0;
		px = Const.LVL_WIDTH/2;
		py = Const.LVL_HEIGHT/2;
		hits = 0;
		pat_jmp = false;
		wait = 5;
		change_pattern = true;
		color = new Color(mc);
		this.game = game;
		on_update();
		particules = new Array();
		game.ball.max_speed_enabled = false;
		mc.gotoAndStop("dodo");
		dodo = true;
		Sound.play(Sound.POULPE);
	}

	function casse() {
		var px;
		var py = 8;

		if( random(2) == 0 )
			px = 0;
		else
			px = 13;

		var b = game.level.interf.walltable[px][py];
		while( true ) {
			if( game.level.interf.walltable[px][py] == null )
				break;
			var d = random(4);
			switch( random(4) ) {
			case 0:
				if( px > 0 )
					px--;
				break;
			case 1:
				if( py > 0 )
					py--;
				break;
			case 2:
				if( px < 13 )
					px++;
				break;
			case 3:
				if( py < 8 )
					py++;
				break;
			}
		}
		game.level.interf.walltable[px][py] = b;
		game.level.interf.update_walls();

		var dmc = game.dmanager.attach("dalle",Const.BONUS_PLAN);
		dmc._x = px * 10 * Const.DELTA + Const.BORDER_SIZE;
		dmc._y = py * 10 * Const.DELTA + Const.BORDER_SIZE;
	}

	function death() {
		Sound.play(Sound.POULPE);
		mc.gotoAndPlay("death");
		var i,j;
		for(j=0;j<3;j++) 
			for(i=0;i<8;i++) {
				var p = game.dmanager.attach("bossParticule",Const.BOSS_PLAN);
				p._x = mc._x;
				p._y = mc._y; 
				p.ang = (i / 8) * Math.PI * 2 + j * 0.5;
				p.dist = 0;
				p.speed = (j+1)*2.5;
				p.scale = 200 + j * 50;
				particules.push(p);
			}				
		game.ball.sx = 0;
		game.ball.sy = 0;
		game.ball.speed = 0;
		game.ball.control = false;
		game.can_loose = false;
		shade._visible = false;
		wait = 0xFFFFF;
	}

	function move_particules() {
		var i;
		if( particules.length > 0 ) {
			for(i=0;i<particules.length;i++) {
				var p = particules[i];
				p.ang += Std.tmod * 0.1 * p.speed / 5;
				p.dist += Std.tmod * p.speed;
				p._x = mc._x + Math.cos(p.ang) * p.dist;
				p._y = mc._y + Math.sin(p.ang) * p.dist;
				p.scale -= Std.tmod * 5;				
				p._xscale = p.scale;
				p._yscale = p.scale;
				if( p._x < -p._width || p._y < -p._height || p._x > Const.LVL_WIDTH+p._width || p._y > Const.LVL_HEIGHT+p._height || p.scale <= 0 ) {
					p.removeMovieClip();
					particules.splice(i,1);
					i--;
				}
			}
			if( particules.length == 0 ) {
				game.boss_update = null;
				game.gameOver(Const.CAUSE_WINS);
			}
		}
	}

	function on_update() {
		var tmod = Std.tmod;
		move_particules();
		move_eye();

		if( mc._alpha < 100 ) {
			mc._alpha += 10 * Std.tmod;
			shade._alpha += 10 * Std.tmod;
			if( mc._alpha >= 100 ) {
				mc._alpha = 100;
				shade._alpha = 100;
			}
		}

		if( wait > 0 ) {
			wait -= tmod / 25;
			mc._x = px;
			mc._y = py;
			shade._x = px;
			shade._y = py;
			if(	collide )
				do_collide();
			if( dodo && wait <= 3 ){
				dodo=false;
				mc.gotoAndStop("normal");
				mc.oeil.gotoAndPlay("close");				
			}
			if( wait <= 0 ){
				mc.gotoAndPlay(next_frame);
				wait = 0;
			}
			return;
		}

		if( hit_time > 0 ) {
			var a = 100-10*hits;
			hit_time -= tmod / 25;
			if( hit_time <= 0 ) {
				var ct = {
					ra : a,
					rb : 40*hits,
					ba : a,
					bb : 0,
					ga : a,
					gb : 0,
					aa : 100,
					ab : 0
				};
				color.setTransform(ct);
				if( hits >= 4 ) {
					death();
					return;
				}
			} else {
				var ct = {
					ra : a,
					rb : 60*hits+hit_time*100,
					ba : a,
					bb : 0,
					ga : a,
					gb : 0,
					aa : 100,
					ab : 0
				};
				color.setTransform(ct);
			}
			return;
		}
		if( change_pattern ) {
			change_pattern = false;
			do_change_pattern();
			return;
		}
		if( njumps > 0 ) {
			jump_time += Std.deltaT;
			jump_pos = jump_size * Math.sin(jump_time*jump_speed/jump_size);
			if( jump_pos < 10 )
				do_collide();
			if( jump_pos < 0 ) {
				jump_pos = 0;
				jump_time = 0;
				njumps--;				
				while( jump_casse-- > 0 ) {
					Sound.play(Sound.CASSE);
					casse();
				}
				if( njumps == 0 ) {
					do_change_pattern();
					return;
				} else
					Sound.play(Sound.BOSS_JUMP);
			}
		}
		if( ang_speed != 0 ) {
			var bang = Math.atan2(game.ball.y-py,game.ball.x-px);
			var adif = Tools.rad_dif(ang,bang);
			if( Math.abs(adif) > ang_speed ) {
				if( adif < 0 )
					ang -= ang_speed*tmod;
				else
					ang += ang_speed*tmod;
			}
			else
				ang = bang+(random(3)-1)/100;
			px += Math.cos(ang)*speed*tmod;
			py += Math.sin(ang)*speed*tmod;
			mc._x = px;
			mc._y = py - jump_pos;
			mc.b.gotoAndStop(Math.max(1,Math.round(jump_pos/5)))
			shade._x = px;
			shade._y = py;
			shade._xscale = 100 + jump_pos/3;
			shade._yscale = 100 + jump_pos/3;
			var whit = false;
			if( px < Const.BOSS_MIN_X ) {
				px = Const.BOSS_MIN_X;
				whit = true;
			}
			
			if( py < Const.BOSS_MIN_Y ) {
				py = Const.BOSS_MIN_Y;
				whit = true;
			}
			
			if( px > Const.LVL_WIDTH-Const.BOSS_MIN_X ) {
				px = Const.LVL_WIDTH-Const.BOSS_MIN_X;
				whit = true;
			}
			if( py > Const.LVL_HEIGHT-Const.BOSS_MAX_Y ) {
				py = Const.LVL_HEIGHT-Const.BOSS_MAX_Y;
				whit = true;
			}

			if( whit )
				ang += Math.PI * 3 /4 + random(45) * Math.PI/180;			
		}
		if( !game.ball.hole_death && aspire_time > 0 ) {
			aspire_time -= tmod / 25;
			var d = Tools.dist2(game.ball.mc,mc);
			if( d < 500 ) {
				game.ball.control = false;
				game.ball.sx = 0;
				game.ball.sy = 0;
				game.ball.x = px;
				game.ball.y = py+22;			
				
				aspire_time = 0;
				mc.gotoAndPlay("eat");
				wait = 1;
				collide = false;
				next_frame = "throw";
				eat_done = true;
				return;
			}
			// ANIM PINCES OUVERTURE
			var c  = Math.pow( 0.6, tmod );
			mc.b.p1._rotation = mc.b.p1._rotation*c + 45*(1-c);
			mc.b.p2._rotation = mc.b.p2._rotation*c - 45*(1-c);
			
			// TAILLE DE L'ANIM DE SOUFFLE
			c  = Math.pow( 0.95, tmod )
			var scale = mc.souffle._xscale*c + (100+(hits*20))*(1-c);
			mc.souffle._xscale = scale;
			mc.souffle._yscale = scale;
			
			var dx = (px - game.ball.mc._x) / d;
			var dy = (py - game.ball.mc._y) / d;
			game.ball.sx += dx * (120+hits*20) * tmod;
			game.ball.sy += dy * (120+hits*20) * tmod;
			if( aspire_time <= 0 ) {
				do_change_pattern();
				return;
			}
			
		}else if( eat_done ) {
			
			var ang = (random(100)+40)*Math.PI/180;
			game.ball.sx = 60*Math.cos(ang);
			game.ball.sy = 60*Math.sin(ang);
			game.ball.control = true;
			eat_done = false;
			wait = 0.5;
			change_pattern = true;
			return;
			
		}else{
			// ANIM PINCES FERMETURE
			var c  = Math.pow( 0.6, tmod );
			mc.b.p1._rotation = mc.b.p1._rotation*c;
			mc.b.p2._rotation = mc.b.p2._rotation*c;
		}
		
		if( do_tir ) {
			if( tir == null ) {
				Sound.play(Sound.BOSS_EYE);
				mc.gotoAndPlay("looseEye")
				tir = game.dmanager.attach("boss tir",Const.BOSS_PLAN);
				tir.px = px;
				tir.py = py - 10;
				tir.activated = false;

				var tir_color = new Color(tir);
				var a = 100-10*hits;
				var ct = {
					ra : a,
					rb : 40*hits,
					ba : a,
					bb : 0,
					ga : a,
					gb : 0,
					aa : 100,
					ab : 0
				};
				tir_color.setTransform(ct);

				var ang = Math.atan2(game.ball.mc._y - (py - 100),game.ball.mc._x - px);
				var m_speed = 5+hits*1.5;
				tir.sx = m_speed * Math.cos(ang);
				tir.sy = m_speed * Math.sin(ang);
			}
			var d = Tools.dist2(game.ball.mc,tir); 
			if( !game.ball.hole_death && d < 38*38 ) {
				Sound.play(Sound.WALL_HIT);
				d = Math.sqrt(d);
				tir.sx = (7 + hits * 1.5) * (tir.px - game.ball.mc._x) / d;
				tir.sy = (7 + hits * 1.5) * (tir.py - game.ball.mc._y) / d;
				if( game.ball.speed < 25 )
					game.ball.speed = 25;
				game.ball.sx = game.ball.speed * (game.ball.mc._x - tir.px) / d;
				game.ball.sy = game.ball.speed * (game.ball.mc._y - tir.py) / d;
				tir.activated = true;
			}
			if( tir.activated && Tools.dist2(mc,tir) < 50*50 ) {
				tir.removeMovieClip();
				hit_time = 1;
				Sound.play(Sound.BOSS_NEW_EYE);
				mc.gotoAndPlay("newEye")
				Sound.play(Sound.POULPE);
				hits++;
				do_tir = false;
				return;
			}
			tir.px += tir.sx*tmod;
			tir.py += tir.sy*tmod;
			if( tir.px < Const.BORDER_SIZE*2 || tir.px > Const.LVL_WIDTH-Const.BORDER_SIZE*2 )
				tir.ang = Math.PI - tir.ang;
			if( tir.py < Const.BORDER_SIZE*2 || tir.py > Const.LVL_HEIGHT-Const.BORDER_SIZE*2 )
				tir.ang *= -1;
			tir._x = tir.px;
			tir._y = tir.py;
			if( tir._x < -30 || tir._y < -30 || tir._x > Const.LVL_WIDTH+30 || tir._y > Const.LVL_HEIGHT+30 ) {
				Sound.play(Sound.BOSS_NEW_EYE);
				mc.gotoAndPlay("newEye")
				tir.removeMovieClip();;
				tir = null;
				do_tir = false;	
				return;
			}
			do_collide();
		}

	}

	function do_collide() {
		var dist = (game.ball.x - px)*(game.ball.x - px)+(game.ball.y - py)*(game.ball.y - py)*2;
		if( dist < 2000 ) {
			var ang = Math.atan2(game.ball.y - py,game.ball.x - px);
			game.ball.sx += 30*Math.cos(ang);
			game.ball.sy += 30*Math.sin(ang);
			Sound.play(Sound.WALL_HIT);
		}
	}

	function do_change_pattern() {
		collide = true;
		pat_jmp = !pat_jmp;
		jump_pos = 0;
		jump_casse = 0;
		jump_time = 0;
		njumps = 0;
		ang_speed = 0;
		do_tir = false;
		wait = 0;
		aspire_time = 0;
		hit_time = 0;
		if( pat_jmp ) {
			jump_speed = 300;
			njumps = 3+hits*2;
			Sound.play(Sound.BOSS_JUMP);
			if( hits == 3 ) {
				njumps *= 5;
				hits++;
			}
			jump_size = 75-hits*10;
			ang_speed = 0.1+0.02*hits;
			speed = 2+hits*1.5;
			mc.gotoAndStop("normal");
		}
		else {
			if( hits >= 4 ) {
				hit_time = 1;
				return;
			}
			switch( random(8) ) {
			case 0:
			case 1:
				jump_casse = 1+random(3);
				jump_speed = 1500;
				jump_size = 300;
				njumps = 1;
				Sound.play(Sound.BOSS_JUMP);
				ang_speed = 0.1+0.02*hits;
				speed = 10;
				mc.gotoAndStop("normal");
				break;
			case 4:
				wait = 0.5;
				change_pattern = true;
				Sound.play(Sound.POULPE);
				break;
			case 2:
			case 3:
				wait = 1+random(100)/100;
				next_frame = "aspire";
				aspire_time = 2+0.5*hits;
				break;
			default:
				wait = 0.7+random(50)/50;
				next_frame = "tir";
				do_tir = true;
				tir = null;
				break;
			}
		}
	}


	function move_eye() {
		// PUPILLE
		var difx =  game.ball.mc._x - mc._x;
		var dify =  game.ball.mc._y - mc._y;	

		var a = Math.atan2(dify,difx)
		
		var x = Math.cos(a)*28
		var y = Math.sin(a)*7 + 8*Math.abs(Math.sin(a))
		
		var c = 0.9
		mc.oeil.p._x = mc.oeil.p._x*c + x*(1-c)
		mc.oeil.p._y = mc.oeil.p._y*c + y*(1-c)
		
		mc.oeil.p._xscale = 100-Math.abs(mc.oeil.p._x)
		mc.oeil.p._yscale = 100-Math.abs(mc.oeil.p._y)*1.5
		
		// PAUPIERE
		if( !mc.dodo && !random(40) )
			mc.oeil.play();
	}
}
