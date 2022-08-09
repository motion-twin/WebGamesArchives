import mb2.Const;
import mb2.Manager;
import mb2.Collide;
import mb2.Tools;
import mb2.Sound;

class mb2.Game {

	var root_mc;	

	var level : mb2.Level;
	var ball : mb2.Ball;
	var options : mb2.Options;
	var dmanager : asml.DepthManager;
	var pause : mb2.Pause;
		
	var main_color;
	var curtime;
	var game_over_flag;

	var course_validated;
	var course_nturns;

	var scroll_on;
	var can_loose;
	var pause_key_flag;
	var space_key_flag;
	var boss_update;

	function Game( mc : MovieClip ) {		
		root_mc = mc;		
		can_loose = true;
		course_validated = false;
		dmanager = new asml.DepthManager(mc);

		Collide.init(this);
		level = new mb2.Level(this);
		ball = new mb2.Ball(this);

		switch( Manager.play_mode ) {
		case Const.MODE_CLASSIC:
			curtime = Const.TIME_CLASSIC;
			options = new mb2.Options(this,1);
			level.pos_x = 0;
			level.pos_y = random(level.height);			
			break;
		case Const.MODE_AIDE:
			curtime = Const.TIME_CHALLENGE;
			options = new mb2.Options(this,3);
			break;
		case Const.MODE_COURSE:
			course_nturns = 3;
			curtime = 0;
			options = new mb2.Options(this,1);
			break;
		case Const.MODE_AVENTURE:
			curtime = Const.TIME_CHALLENGE * 1.2;
			options = new mb2.Options(this,5);
			break;
		default:
			curtime = Const.TIME_CHALLENGE;
			options = new mb2.Options(this,3);
			break;
		}

		main_color = new Color(mc);
		game_over_flag = false;
		ball.update_skin();
		options.update_icons();
		next_room();
		Sound.startMix();
	}

	function calcScore(cause) {

		if( Manager.play_mode == Const.MODE_CLASSIC )
			return level.pos_x + 1;

		if( Manager.play_mode == Const.MODE_COURSE )
			return int(curtime*100);

		var score = 0;

		var trooms = 0;
		var vrooms = 0;
		var x,y;
		for(x=0;x<level.width;x++)
			for(y=0;y<level.height;y++) {
				var r = level.dungeon[x][y];
				if( r.rtype != 0 )
					trooms++;
				if( r.visited )
					vrooms++;
			}
		score += int(vrooms*100/trooms)-1;

		if( cause == Const.CAUSE_WINS )
			score += int(curtime/100)*100;

		return score;
	}

	function course_turn_done() {
		var i,x,y;
		if( !course_validated )
			return;
		level.interf.tview.play();
		course_nturns--;
		if( course_nturns == 0 )
			gameOver(Const.CAUSE_WINS);
		course_validated = false;
		for(x=0;x<level.width;x++)
			for(y=0;y<level.height;y++)
				if( x != level.pos_x || y != level.pos_y ) {
					var r = level.dungeon[x][y];
					r.visited = false;
					for(i=0;i<4;i++)
						if( r.paths[i].ptype == -1 )
							r.paths[i].ptype = 0;
					for(i=0;i<r.bdata.length;i++) {
						var b = r.bdata[i];
						if( b.old_btype )
							b.btype = b.old_btype;
					}
				}
	}

	function next_room() {
		level.init_room();
		ball.sx /= 3;
		ball.sy /= 3;
		ball.speed /= 3;
		ball.start_x = ball.x;
		ball.start_y = ball.y;
		level.interf.tview.niv_txt.text = level.pos_x + 1;
	}

	function gameOver(cause) {
		if( cause != Const.CAUSE_WINS && !can_loose )
			return;

		if( !game_over_flag ) {
			game_over_flag = true;
			Manager.gameOver(cause);
		}
	}

	function is_door_opened(p) {
		return p.ptype == -1 || p.ptype == -2 || ( p.ptype == 3 && Manager.play_mode != Const.MODE_CHALLENGE ) || p.ptype == 2;
	}

	function main() {
		var i;
		var tmod = Std.tmod;

		if( game_over_flag )
			return;

		if( scroll_on ) {
			level.interf.scroll_room();
			return;
		}
		
		if( pause != null ) {
			pause.main();
			return;
		}

		if( Manager.play_mode == Const.MODE_COURSE ) {
			if( curtime < 0 )
				curtime = 0;
			curtime += Std.deltaT;
		}
		else {
			curtime -= tmod * 1000 / 40;
			if( curtime < 0 ) {
				curtime = 0;
				if( !ball.hole_death )
					gameOver(Const.CAUSE_NOTIME);
			} else if( Manager.play_mode == Const.MODE_CLASSIC && curtime > 100000 )
				curtime = 100000;
		}
		
		level.interf.update();
		ball.update_jump();
		
		// UPDATES
		for(i=0;i<level.updates.length;i++)
			level.updates[i].on_update(this,level.updates[i]);
			
		if( game_over_flag )
			return;
		
		if( ball.update_hole() ) {
			boss_update.on_update(this,boss_update);
			return;
		}

		if( Key.isDown(Key.SPACE) && Manager.play_mode != Const.MODE_CLASSIC ) {
			if( !space_key_flag ) {
				space_key_flag = true;
				do {
					ball.btype++;
					ball.btype %= 7;
				} while( !options.ball_types[ball.btype] );
				options.update_icons();
				ball.update_skin();
				Sound.play(Sound.BALL_CHANGE);
			}
		} else
			space_key_flag = false;

		if( Manager.client.forcePause || Key.isDown(Key.ESCAPE) ) {
			if( !pause_key_flag ) {
				pause_key_flag = true;
				setPause();
				return;
			}
		} else
			pause_key_flag = false;

		ball.update();
		boss_update.on_update(this,boss_update);

		// GET BONUS
		var b;
		for(i=0;i<level.bonus.length;i++) {
			b = level.bonus[i];
			if( b && Tools.dist2(b.clip,ball.mc) < 300 && b.on_hit(this,b) ) {
				b.old_btype = b.btype;
				b.btype = 0;
				level.bonus[i] = null;				
			}
		}

		// CHEATS BEGIN
		/*
		if( mb2.Client.STANDALONE ) { 
			if( Key.isDown("B".charCodeAt(0)) ) {
				var i;
				var _this = this;
				for(i=0;i<7;i++)
					if( Key.isDown(i+48) || Key.isDown(i+96) ) {
						if( _this[i] )
							continue;
						_this[i] = true;
						options.ball_types[i]++;
						options.ball_types_chk++;
						options.update_icons();
					}
					else
						_this[i] = false;
			}
			if( Key.isDown("T".charCodeAt(0)) && random(10) == 0 ) {				
				course_validated = true;
				course_turn_done();
			}
			if( Key.isDown("W".charCodeAt(0)) ) {
				gameOver(Const.CAUSE_WINS);
			}
			if( Key.isDown("L".charCodeAt(0)) ) {
				curtime = 1;
			}
			if( Key.isDown("S".charCodeAt(0)) ) {
				ball.y += 50;				
			}
		} */
		// CHEATS END

		var room = level.dungeon[level.pos_x][level.pos_y];
		var is_classic = (Manager.play_mode == Const.MODE_CLASSIC);
		if( ball.x < 0 ) {
			if( is_classic || is_door_opened(room.paths[0]) )
				level.change_room(-1,0);
			else
				ball.x = 5;
		} else if( ball.x > Const.LVL_WIDTH ) {
			if( is_classic || is_door_opened(room.paths[1]) )
				level.change_room(1,0);
			else
				ball.x = Const.LVL_WIDTH - 5;
		} else if( ball.y < 0 ) {
			if( is_classic || is_door_opened(room.paths[2]) )
				level.change_room(0,-1);
			else
				ball.y = 5;
		} else if( ball.y > Const.LVL_HEIGHT ) {
			if( is_classic || is_door_opened(room.paths[3]) )
				level.change_room(0,1);
			else
				ball.y = Const.LVL_HEIGHT - 5;
		}
	}

	function setPause() {
		pause = new mb2.Pause(this);
		boss_update.onPause(true);
	}

	function destroy() {
		ball.hole_mask.removeMovieClip();
		pause.destroy();
		dmanager.destroy();
	}

}