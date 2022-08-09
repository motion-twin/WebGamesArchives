import mb2.Tools;
import mb2.Const;
import mb2.Game;
import mb2.Manager;
import mb2.Sound;

class mb2.Collide {

	static var game : Game = null;
	static var hitmap;
	static var border_collide;
	static var border_collide_no_recal;
	static var frame_nb = 0;

	static var interupt_flag;

// ---------------------------------------------------------------------------

	static function init( game ) {
		mb2.Collide.game = game;

		hitmap = new Array();
		var i;
		var bumpers = ["bnormal","btime","bdeath","bmagnet","bshadow","wall","wall","itembox"];
		for(i=0;i<bumpers.length;i++)
			hitmap[i] = gen_hitmap(bumpers[i]);

		hitmap[10] = gen_hitmap("interupt");
		hitmap[11] = hitmap[5];
		hitmap[12] = hitmap[5];
		hitmap[13] = gen_hitmap("zapper");

		interupt_flag = false;

		border_collide = new Object();
		border_collide.on_hit = mb2.Collide.border_on_hit;
		border_collide.is_border = true;
		border_collide.hit_min = 4;
		border_collide.hit_coef = 1.1;

		border_collide_no_recal = new Object();
		border_collide_no_recal.on_hit = mb2.Collide.border_on_hit_no_recal;
		border_collide_no_recal.is_border = true;
		border_collide_no_recal.hit_min = 4;
		border_collide_no_recal.hit_coef = 1.1;
	}

// ---------------------------------------------------------------------------

	static function gen_hitmap(item) {
		var mc = game.dmanager.attach(item,0);
		var msize = Tools.mc_size(mc);
		var x,y;
		var dx = Const.DELTA / 2 - (msize.w/2)*Const.DELTA;
		var dy = Const.DELTA / 2 - (msize.h/2)*Const.DELTA;
		var ctbl = new Array(msize.w);

		for(x=0;x<msize.w;x++) {
			ctbl[x] = new Array(msize.h);
			for(y=0;y<msize.h;y++)
				if( mc.hitTest(x*Const.DELTA+dx+Const.POS_X,y*Const.DELTA+dy+Const.POS_Y,true) )
					ctbl[x][y] = true;
				else
					ctbl[x][y] = false;
		}
		mc.removeMovieClip();
		return ctbl;
	}

// ---------------------------------------------------------------------------

	static function on_get_map(game : Game) {
		game.options.has_map = true;
		game.setPause();
	}

// ---------------------------------------------------------------------------

	static function on_get_radar(game : Game) {
		game.options.has_radar = true;
		game.setPause(true);
	}

// ---------------------------------------------------------------------------

	static function on_get_key(game : Game) {
		game.options.grelot_count+=3;
		game.options.update_icons();
	}

// ---------------------------------------------------------------------------

	static function on_get_small_blue(game : Game) {
		if( Manager.play_mode != Const.MODE_COURSE )
			game.curtime += 1*60*1000; // 1 min
	}

// ---------------------------------------------------------------------------

	static function on_get_big_blue(game : Game) {
		if( Manager.play_mode != Const.MODE_COURSE )
			game.curtime += 3*60*1000; // 3 min
	}


// ---------------------------------------------------------------------------

	static function gen_hit(game : Game,px,py) {
		var hit = game.dmanager.attach("hit",Const.DUMMY_PLAN);
		hit._x = px*Const.DELTA + Const.DELTA/2;
		hit._y = py*Const.DELTA + Const.DELTA/2;
		hit._rotation = Math.atan2(game.ball.sy,game.ball.sy) * 180 / Math.PI;
	}

// ---------------------------------------------------------------------------

	static function border_on_hit(game : Game,mc,px,py) {
		gen_hit(game,px,py);
		var size = Const.BORDER_SIZE + Const.DELTA;

		if( game.ball.x < size )
			game.ball.x = size;
		if( game.ball.y < size )
			game.ball.y = size;

		size += Const.DELTA * 2;

		if( game.ball.x > Const.LVL_WIDTH - size )
			game.ball.x = Const.LVL_WIDTH - size;
		if( game.ball.y > Const.LVL_HEIGHT - size )
			game.ball.y = Const.LVL_HEIGHT - size;
		Sound.play(Sound.WALL_HIT);
	}

// ---------------------------------------------------------------------------

	static function border_on_hit_no_recal(game : Game,mc,px,py) {
		gen_hit(game,px,py);
		Sound.play(Sound.WALL_HIT);
	}

// ---------------------------------------------------------------------------

	static function item_box_on_hit(game : Game, mc, px,py) {
		if( mc.item == -1 )
			return;
		Sound.play(Sound.GET_ITEM);
		gen_hit(game,px,py);
		game.level.fill_pos(mc.pos,hitmap[7],null);
		mc.clip.gotoAndPlay("hit");
		game.level.dungeon[game.level.pos_x][game.level.pos_y].rdata = -1;
		mc.on_get_item(game);
		mc.item = -1;
		game.options.update_icons();
	}

// ---------------------------------------------------------------------------

	static function red_on_hit(game : Game, mc ) {
		game.level.bonus_reds--;
		if( game.level.bonus_reds == 0 ) {
			game.level.interf.open_doors();
			Sound.play(Sound.OPEN_DOOR);
		}
		mc.clip.gotoAndPlay("hit");
		Sound.play(Sound.GET_RED);
		return true;
	}

// ---------------------------------------------------------------------------

	static function classic_exit_on_hit(game : Game, mc ) {
		if( !mc.clip.flOpen )
			return false;

		game.ball.classic_mask = game.dmanager.attach("maskHole",Const.BUMPER_PLAN);
		game.ball.classic_mask._x = mc.clip._x;
		game.ball.classic_mask._y = mc.clip._y;
		game.ball.mc.setMask(game.ball.classic_mask);

		game.ball.hole_death_speed = 3;
		game.ball.death_hit = false;
		game.ball.hole_death = true;
		game.ball.shadow._visible = false;
		return true;
	}

// ---------------------------------------------------------------------------

	static function blue_on_hit(game : Game, mc ) {
		if( Manager.play_mode == Const.MODE_COURSE ) {
			game.curtime -= 1; // 1 sec
		} else if( Manager.play_mode == Const.MODE_CLASSIC )
			game.curtime += 2*1000; // 2 sec
		else
			game.curtime += 10*1000; // 10 sec			
		mc.clip.gotoAndPlay("hit");
		Sound.play(Sound.GET_BLUE);
		return true;
	}

// ---------------------------------------------------------------------------

	static function bumper_normal_on_hit(game : Game, mc) {
		if( mc.clip._currentframe == 1 ) {
			mc.clip.gotoAndPlay("hit");
			Sound.play(Sound.BUMPER_NORMAL);
		}
	}

// ---------------------------------------------------------------------------

	static function bumper_time_on_hit( game : Game, mc ) {
		if( mc.clip._currentframe == 1 ) {
			mc.clip.gotoAndPlay("hit"); 
			Sound.play(Sound.BUMPER_TIME);
			if( Manager.play_mode == Const.MODE_COURSE )
				game.curtime += 5; // 5 sec
			else
				game.curtime -= 5000;
		}
	}

// ---------------------------------------------------------------------------

	static function bumper_death_on_hit( game : Game, mc ) {
		if( game.ball.btype != 5 && game.ball.clign_count <= 0 ) { // METAL
			Sound.play(Sound.BUMPER_DEATH);
			mc.clip.gotoAndPlay("hit");
			game.ball.die();
		}
		else
			Sound.play(Sound.BUMPER_DEATH_PROTECT);
	}

// ---------------------------------------------------------------------------

	static function bumper_magnet_on_hit( game : Game, mc ) {
		if( mc.way ) {
			mc.way = false; 
			Sound.play(Sound.BUMPER_MAGNET);
			mc.clip.gotoAndPlay("neg");
		}
	}

// ---------------------------------------------------------------------------

	static function bumper_shadow_on_hit( game : Game, mc ) {
		if( mc.clip._currentframe == 1 ) {
			Sound.play(Sound.BUMPER_SHADOW);
			mc.clip.gotoAndPlay("hit");
			if( game.ball.btype != 6 ) {
				mc.alpha = 100;
				mc.clip._alpha = 100;
				mc.clip._visible = true;
			}
		}
	}

// ---------------------------------------------------------------------------

	static function door_on_hit(game : Game, mc, px, py ) {
		if( game.options.grelot_count > 0 && game.level.dungeon[game.level.pos_x][game.level.pos_y].paths[mc.d].ptype != -1 ) {
			game.options.grelot_count--;
			game.options.update_icons();
			Sound.play(Sound.GRELOT);
			game.level.interf.open_door(mc.d);
		}
		else
			border_on_hit(game,mc,px,py);
	}

// ---------------------------------------------------------------------------

	static function wall_on_hit(game : Game, mc, px, py ) {
		if( game.ball.btype == 1 ) { // VERTE
			if( mc.btype == 0 )
				return;
			Sound.play(Sound.GREEN_BLOCK_DESTROY);
			game.level.erase_pos(mc);
			game.level.interf.fill_wall(mc,null);
			game.level.interf.update_walls();
			mc.shade.removeMovieClip();
			mc.clip.removeMovieClip();
			mc.old_btype = mc.btype;
			mc.btype = 0;
			var i;
			var ballang = Math.atan2(game.ball.sy,game.ball.sx);
			var sfact = game.ball.speed;
			for(i=0;i<4;i++) {
				var p = new Object();
				var speed = (Math.random()*(sfact/2)+sfact/2)/4+1;
				var ang = (Math.random()-0.5)+ballang;
				p.clip = game.dmanager.attach("wallpart",Const.DUMMY_PLAN);
				p.clip._rotation = random(360);
				p.x = random(10*Const.DELTA) + mc.x * Const.DELTA;
				p.y = random(10*Const.DELTA) + mc.y * Const.DELTA;
				p.rspeed = speed;
				p.sx = Math.cos(ang)*speed;
				p.sy = Math.sin(ang)*speed;
				p.on_update = wall_dummy_on_update;
				p.stime = 50;
				p.time = 30;
				game.level.updates.push(p);
				game.level.dummies.push(p);
			}
				
		} else {
			Sound.play(Sound.GREEN_BLOCK_HIT);
			gen_hit(game,px,py);
		}
	}

// ---------------------------------------------------------------------------

	static function zapper_on_hit( game : Game, mc, px, py ) {
		Sound.play(Sound.ZAPPER_HIT);
		gen_hit(game,px,py);
	}

// ---------------------------------------------------------------------------

	static function zapper_line_on_hit( game : Game, mc, px, py ) {
		if( Manager.play_mode == Const.MODE_COURSE ) {
			game.course_turn_done();
			return;
		}

		if( game.ball.btype != mc.phase ) {
			var flashLine = game.dmanager.attach("flashLine",Const.DUMMY_PLAN);
			flashLine._x = mc.z1.clip._x
			flashLine._y = mc.z1.clip._y
			flashLine.gfx.gotoAndStop(mc.phase+1)

			var difx = mc.z2.clip._x - mc.z1.clip._x
			var dify = mc.z2.clip._y - mc.z1.clip._y
			
			var dist = Math.sqrt( difx*difx + dify*dify )
			
			flashLine._width = dist;
			flashLine._rotation = Math.atan2(dify,difx)/(Math.PI/180)
			
			Sound.play(Sound.ZAPPER_ACTIVATE);
			game.ball.die();
		}
	}

// ---------------------------------------------------------------------------

	static function interblock_on_hit( game : Game, mc, px, py ) {
		Sound.play(Sound.INTER_BLOCK_HIT);
		gen_hit(game,px,py);
	}

// ---------------------------------------------------------------------------

	static function interupt_on_hit( game : Game, mc, px, py ) {
		if( mc.last_frame_hit == null || mc.last_frame_hit < frame_nb - 20 ) {
			mc.last_frame_hit = frame_nb;			
			Sound.play(Sound.INTERUPT_HIT);
			gen_hit(game,px,py);

			interupt_flag = !interupt_flag;
			var bumpers = game.level.objects;
			var i;
			for(i=0;i<bumpers.length;i++) {
				var b = bumpers[i];
				var t = b.btype;
				if( t == 11 ) {
					b.clip.gotoAndPlay(interupt_flag?"playOn":"playOff");
				} else if( t == 13 ) {
					b.clip.gotoAndPlay(interupt_flag?"playOn":"playOff");
					b.on_hit = mb2.Collide.interupt_flag?null:mb2.Collide.interblock_on_hit;
				} else if( t == 12 ) {
					b.clip.gotoAndPlay(interupt_flag?"playOff":"playOn");
					b.on_hit = mb2.Collide.interupt_flag?mb2.Collide.interblock_on_hit:null;
				}
			}
		}
	}

// ---------------------------------------------------------------------------

	static function bumper_magnet_on_update(game : Game, mc ) {
		if( game.ball.btype == 5 )
			return;	
		var tmod = Std.tmod;
		var d = Tools.dist2(game.ball.mc,mc.clip);		
		if( d < 30000 ) {
			var w = mc.way?1:(-1);
			var dx = (mc.clip._x - game.ball.mc._x) / d;
			var dy = (mc.clip._y - game.ball.mc._y) / d;
			game.ball.sx += w * dx * 30 * tmod;
			game.ball.sy += w * dy * 30 * tmod;
		}
		if( mc.way == false && random(1000/Std.tmod) == 0 ) {
			mc.way = true;
			mc.clip.gotoAndPlay("plus");
		}
	}

// ---------------------------------------------------------------------------

	static function bumper_shadow_on_update(game : Game, mc) {
		var tmod = Std.tmod;
		if( game.ball.btype == 6 ) { // VIOLET
			var d = Tools.dist2(game.ball.mc,mc.clip);
			mc.alpha = int(200000 / d);
			if( mc.alpha <= 0 )
				mc.alpha = 0;
			if( mc.alpha > 100 )
				mc.alpha = 100;
			mc.clip._visible = (mc.alpha > 0);
			mc.clip._alpha = mc.alpha;
		} else {
			if( mc.alpha > 0 ) {
				mc.alpha -= tmod * 4;
				if( mc.alpha <= 0 ) {
					mc.alpha = 0;
					mc.clip._visible = false;
				}
				mc.clip._alpha = mc.alpha;
			}
		}
	}

// ---------------------------------------------------------------------------

	static function bumper_time_on_update( game : Game, mc ) {
		mc.curtime = mc.curtime * 0.95 + game.curtime * 0.05;
		mc.clip.aig._rotation = -(mc.curtime / 3600);
		mc.clip.aig2._rotation = -(mc.curtime % 3600) / 10;
	}

// ---------------------------------------------------------------------------

	static function wall_dummy_on_update(game : Game, mc) {
		var tmod = Std.tmod;
		mc.x += mc.sx;
		mc.y += mc.sy;
		mc.clip._x = mc.x;
		mc.clip._y = mc.y;
		mc.clip._xscale = mc.time * 200 / mc.stime;
		mc.clip._yscale = mc.time * 200 / mc.stime;
		mc.clip._rotation += 5*tmod;
		mc.time -= tmod;
		if( mc.time < 0 ) {
			game.level.updates.remove(mc);
			game.level.dummies.remove(mc);
			mc.clip.removeMovieClip();
		}
	}

// ---------------------------------------------------------------------------

	static function ball_object_on_update(game : Game, mc) {
		var d = Math.sqrt(Tools.dist2(mc.clip,game.ball.mc));
		if( d < Const.BALL_RAYSIZE * 3 ) {
			game.level.updates.remove(mc)
			mc.clip.gotoAndPlay("hit");
			game.options.ball_types_chk -= game.options.ball_types[mc.obj];
			Sound.play(Sound.GET_BALL);
			game.options.ball_types[mc.obj] = 1;
			game.options.ball_types_chk++;
			game.ball.btype = mc.obj;
			game.options.update_icons();
			game.ball.update_skin();
			if( !game.options.ball_flags[mc.obj] ) {
				game.options.ball_flags[mc.obj] = true;
				Sound.nextMix();
			}
		}
	}

// ---------------------------------------------------------------------------

	static function bumper_teleport_on_update(game : Game, mc) {
		var d = Math.sqrt(Tools.dist2(mc.clip,game.ball.mc));
		d+=0.1
		for(var i=0; i<mc.clip.num; i++){
			var circle = mc.clip["c"+i];
			circle._rotation += circle.rot*Std.tmod*(1+(60/d));
			circle.c += Std.tmod*(20+(200/d))
			var a = circle.c/100
			circle._xscale = 100+Math.cos(a)*50
			circle._yscale = 100+Math.sin(a)*50
		}
		
		
		
		if( d < Const.BALL_RAYSIZE ) {
			if( !mc.teleport ) {
				var bumpers = game.level.updates;
				var i;
				for(i=0;i<bumpers.length;i++)
					if( bumpers[i].btype == 10 && bumpers[i] != mc )
						break;
				mc.teleport = true;
				bumpers[i].teleport = true;
				game.ball.x = bumpers[i].clip._x;
				game.ball.y = bumpers[i].clip._y;
				game.ball.mc._x = game.ball.x;
				game.ball.mc._y = game.ball.y;
			}
		} else
			mc.teleport = false;
	}

// ---------------------------------------------------------------------------

	static function boss_room_on_update(game : Game,mc) {
		var sz = Const.BORDER_SIZE + Const.BALL_RAYSIZE;
		var bpos : mb2.Ball = game.ball;
		if( bpos.x > sz  && bpos.y > sz && bpos.x < Const.LVL_WIDTH - sz && bpos.y < Const.LVL_HEIGHT - sz ) {
			game.level.updates.remove(mc);
			var d;
			for(d=0;d<4;d++) {
				var door = game.level.interf.doors[d];
				if( game.level.dungeon[game.level.pos_x][game.level.pos_y].paths[d].ptype == -1 ) {
					door.gotoAndStop("off");
					game.level.set_door_collide(d,border_collide);
				}
			}
			game.ball.start_x = Const.LVL_WIDTH / 2;
			game.ball.start_y = Const.LVL_HEIGHT / 2;

			if( Manager.play_mode == Const.MODE_AIDE ) {
				Sound.fadeMix(Sound.MUSIC_MENU);
				Manager.gameOver(true);
				return;
			}


			var boss;
			Sound.fadeMix(Sound.MUSIC_BOSS);
			if( Manager.play_mode == Const.MODE_AVENTURE ) {
				if( Manager.play_mode_param == 4 )
					boss = new mb2.BossTB(game);
				else
					boss = new mb2.BossSerpent(game);
			} else
				boss = new mb2.Boss(game);
			game.boss_update = boss;
		}
	}

// ---------------------------------------------------------------------------

	static function autoclose_door_on_update( game : Game, mc ) {
		var sz = Const.BORDER_SIZE + Const.BALL_RAYSIZE;
		var bpos : mb2.Ball = game.ball;
		if( bpos.x > sz  && bpos.y > sz && bpos.x < Const.LVL_WIDTH - sz && bpos.y < Const.LVL_HEIGHT - sz ) {			
			game.level.updates.remove(mc);
			game.level.interf.doors[mc.d].gotoAndStop("off");
			game.level.set_door_collide(mc.d,border_collide);			
			if( mc.validate )
				game.course_validated = true;
		}
	}

}
