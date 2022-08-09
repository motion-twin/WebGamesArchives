import mb2.Const;
import mb2.Collide;
import mb2.Tools;
import mb2.Manager;

class mb2.Interf {

	var game : mb2.Game;

	var doors;
	var bg1, bg2, ground, decor1, decor2;
	var holes, shades;
	var tview;
	var old_time;

	var walltable;

	var scroll_dx;
	var scroll_dy;
	var scroll_x;
	var scroll_y;
	var scroll_end;

	var save_tmod;

	function Interf( game : mb2.Game ) {
		this.game = game;

		var dmanager = game.dmanager;
		var d;
		doors = new Array();
		for(d=0;d<4;d++) {
			var door = dmanager.attach("door",Const.DOOR_PLAN);
			doors[d] = door;
			var b = Const.BORDER_SIZE/2
			switch( d ) {
			case 0:
				door.sx = b;
				door.sy = Const.LVL_HEIGHT/2;
				door._rotation = -90;
				break;
			case 1:
				door.sx = Const.LVL_WIDTH-b;
				door.sy = Const.LVL_HEIGHT/2;
				door._rotation = 90;
				break;
			case 2:
				door.sx = Const.LVL_WIDTH/2;
				door.sy = b;
				break;
			case 3:
				door.sx = Const.LVL_WIDTH/2;
				door.sy = Const.LVL_HEIGHT-b;
				door._rotation = 180;
				break;
			}
			door._x = door.sx;
			door._y = door.sy;
			door.stop();
			door.porteA.stop();
			door.porteB.stop();

			door = dmanager.attach("door",Const.DOOR_PLAN);
			door.stop();
			door.porteA.stop();
			door.porteB.stop();
			doors[d+4] = door;
			door._rotation = doors[d]._rotation;
			door._visible = false;
		}
		bg1 = dmanager.attach("background",Const.BG_PLAN);
		bg2 = dmanager.attach("background",Const.BG_PLAN);
		ground = dmanager.attach("ground",Const.HOLE_PLAN);
		holes = dmanager.empty(Const.HOLE_PLAN);
		shades = dmanager.empty(Const.SHADE_PLAN-1);
		decor1 = dmanager.attach("border",Const.DECOR_PLAN);
		decor2 = dmanager.attach("border",Const.DECOR_PLAN);
		tview = dmanager.attach("time counter",Const.ICON_PLAN);

		switch( Manager.play_mode ) {
		case Const.MODE_CLASSIC:
			tview.gotoAndStop("classic");
			break;
		case Const.MODE_COURSE:
			tview.gotoAndStop("time");
			break;
		default:
			tview.gotoAndStop(1);
			break;
		}

		tview._x = Const.LVL_WIDTH;
		bg2.stop();
		bg2._visible = false;
		decor2._visible = false;
		ground.setMask(holes);
		ground._visible = false;
	}

// ---------------------------------------------------------------------------

	function init_room() {
		var WWIDTH = int(Const.LVL_CWIDTH/10);
		walltable = new Array();
		var x;
		for(x=0;x<WWIDTH;x++)
			walltable[x] = new Array();	
		bg1.gotoAndStop( selectBg(game.level.pos_x,game.level.pos_y) );
	}

// ---------------------------------------------------------------------------

	function init_doors(ddelta) {
		var room = game.level.dungeon[game.level.pos_x][game.level.pos_y];
		var d;
		for(d=0;d<4;d++) {
			var p = room.paths[d];
			var door = doors[ddelta+d];
			var pt = p.ptype;
			if( pt == 3 && Manager.play_mode != Const.MODE_CHALLENGE )
				pt = -2;			
			switch(pt) {
			case -2: // ONE-WAY
				var x = game.ball.x;
				var y = game.ball.y;
				if( ddelta != 0 ) {
					x -= scroll_dx * Const.LVL_WIDTH;
					y -= scroll_dy * Const.LVL_HEIGHT;					
				}

				if( (d == 0 && scroll_dx == 1) ||
					(d == 1 && scroll_dx == -1) ||
					(d == 2 && scroll_dy == 1) ||
					(d == 3 && scroll_dy == -1)
				) {
					if( ddelta == 0 ) {
						var o = new Object();
						o.d = d;
						o.validate = (p.ptype == -2);
						o.on_update = Collide.autoclose_door_on_update;
						game.level.updates.push(o);
					}
					door.gotoAndStop("opened");
					game.level.set_door_collide(d,Collide.border_collide_no_recal,Const.DOOR_COLLIDE_DELTA);
					game.level.set_door_collide(d,null);
				}
				else {
					door.gotoAndStop("off");
					game.level.set_door_collide(d,Collide.border_collide);
				}
				break;
			case -1: // OPEN
				door.gotoAndStop("opened");
				game.level.set_door_collide(d,Collide.border_collide_no_recal,Const.DOOR_COLLIDE_DELTA);
				game.level.set_door_collide(d,null);
				break;
			case 0: // DOOR
			case 3: // NEED				
				door.gotoAndStop(game.level.bonus_reds?"off":"on");
				var o = new Object();
				o.on_hit = Collide.door_on_hit;
				o.hit_coef = Collide.border_collide.hit_coef;
				o.hit_min = Collide.border_collide.hit_min;
				o.d = d;
				game.level.set_door_collide(d,o);
				break;
			case 2: // INVISIBLE
				door.gotoAndStop("nodoor"+d);
				game.level.set_door_collide(d,Collide.border_collide_no_recal,Const.DOOR_COLLIDE_DELTA);
				game.level.set_door_collide(d,null);
				break;
			case 1: // NO DOOR
			default: // NO ROOM
				door.gotoAndStop("nodoor"+d);
				game.level.set_door_collide(d,Collide.border_collide);
				break;
			}
			switch(d) {
			case 0: // OPEN
				door.porteA.gotoAndStop(2)
				door.porteB.gotoAndStop(1)
				break;
			case 1: // OPEN
				door.porteA.gotoAndStop(3)
				door.porteB.gotoAndStop(4)
				break;
			case 2: // OPEN
				door.porteA.gotoAndStop(1)
				door.porteB.gotoAndStop(2)
				break;
			case 3: // OPEN
				door.porteA.gotoAndStop(4)
				door.porteB.gotoAndStop(3)
				break;
			}
		}
	}

// ---------------------------------------------------------------------------

	function open_doors() {
		var d;
		var exit = game.level.exit;
		if( exit != null )
			exit.clip.gotoAndPlay("anim_open");
		for(d=0;d<4;d++)
			open_door(d);
	}

// ---------------------------------------------------------------------------

	function open_door(d) {
		var room = game.level.dungeon[game.level.pos_x][game.level.pos_y];
		var p = room.paths[d];
		if( p.ptype == 0 || p.ptype == 3 ) { // DOOR | NEED
			if( p.ptype == 3 && Manager.play_mode != Const.MODE_CHALLENGE ) {
				p.ptype = -2;
				return;
			} else
				p.ptype = -1;
			doors[d].gotoAndPlay("open");
			game.level.set_door_collide(d,Collide.border_collide_no_recal,Const.DOOR_COLLIDE_DELTA);
			game.level.set_door_collide(d,null);
		}
	}

// ---------------------------------------------------------------------------

	function update_walls() {
		var x, y;
		var b, frame;
		var WWIDTH = int(Const.LVL_CWIDTH/10);
		var WHEIGHT = int(Const.LVL_CHEIGHT/10);

		if( holes == undefined )
			return;

		holes.clear();
		shades.clear();
		for(x=0;x<WWIDTH;x++)
			for(y=0;y<WHEIGHT;y++) {
				b = walltable[x][y];
				if( b ) {
					frame = 0;
					if( walltable[x-1][y].btype == b.btype ) frame += 1;
					if( walltable[x][y-1].btype == b.btype ) frame += 2;
					if( walltable[x+1][y].btype == b.btype ) frame += 4;
					if( walltable[x][y+1].btype == b.btype ) frame += 8;
					if( b.btype == 7 ) { // HOLE
						var w = Const.DELTA*10;
						var h = 0;
						var px = (Const.BORDER_CSIZE+x*10)*Const.DELTA+1;
						var py = (Const.BORDER_CSIZE+y*10)*Const.DELTA+1;
						if( y > 0 && (frame & 2) == 0 ) {
							h = Const.HOLE_BORDER_SIZE;
							shades.moveTo(px,py);
							shades.beginFill(0x9B76BC);
							shades.lineTo(px+w,py);
							shades.lineTo(px+w,py+Const.HOLE_BORDER_SIZE);
							shades.lineTo(px,py+Const.HOLE_BORDER_SIZE);
							shades.endFill();
						}
						holes.moveTo(px,py+h);
						holes.beginFill(0);
						holes.lineTo(px+w,py+h);
						holes.lineTo(px+w,py+w);
						holes.lineTo(px,py+w);
						holes.endFill();
					}
					b.frame = frame;
					b.clip.gotoAndStop(frame+1);
				}
			}
		var x2,y2;
		var decal = 4;
		for(x=0;x<WWIDTH;x++)
			for(y=0;y<WHEIGHT;y++) {
				b = walltable[x][y];
				if( b.btype == 6 ) { // WALL
					var p = null;
					if( (b.frame & 2) == 0 ) {
						var dy = 1;
						while( walltable[x][y+dy].btype == 6 )
							dy++;
						p = new Object();
						p.x = (Const.BORDER_CSIZE+x*10)*Const.DELTA+decal;
						p.y = (Const.BORDER_CSIZE+y*10)*Const.DELTA+decal;
						p.w = 10*Const.DELTA;
						p.h = dy*10*Const.DELTA;
						Tools.drawSmoothSquare(shades,p,0,8,20);
					}
					if( (b.frame & 1) == 0 ) {
						var dx = 1;
						while( walltable[x+dx][y].btype == 6 )
							dx++;
						if( p == null ) {
							p = new Object();
							p.x = (Const.BORDER_CSIZE+x*10)*Const.DELTA+decal;
							p.y = (Const.BORDER_CSIZE+y*10)*Const.DELTA+decal;
						}
						p.w = dx*10*Const.DELTA;
						p.h = 10*Const.DELTA;
						Tools.drawSmoothSquare(shades,p,0,8,20);
					}
				}
			}
	}

// ---------------------------------------------------------------------------

	function fill_wall(b,v) {
		walltable[int((b.x-Const.BORDER_CSIZE)/10)][int((b.y-Const.BORDER_CSIZE)/10)] = v;
	}

// ---------------------------------------------------------------------------

	function scroll_room() {
		var d;
		var tmod = Std.tmod;
		scroll_x -= scroll_dx * tmod * (Const.LVL_WIDTH / 20);
		scroll_y -= scroll_dy * tmod * (Const.LVL_HEIGHT / 20);
		if( scroll_end ) {
			game.scroll_on = false;
			bg2._visible = false;
			decor2._visible = false;
			for(d=0;d<4;d++)
				doors[d+4]._visible = false;
			game.ball.x -= scroll_dx * Const.LVL_WIDTH;
			game.ball.y -= scroll_dy * Const.LVL_HEIGHT;
			scroll_x = 0;
			scroll_y = 0;
			Std.tmod = save_tmod;
			game.next_room();
		}
		if( Math.abs(scroll_x) >= Math.abs(scroll_dx * Const.LVL_WIDTH) && Math.abs(scroll_y) >= Math.abs(scroll_dy * Const.LVL_HEIGHT) ) {
			scroll_end = true;
			scroll_x = -scroll_dx * Const.LVL_WIDTH;
			scroll_y = -scroll_dy * Const.LVL_HEIGHT;
		}
		bg2._x = scroll_dx * Const.LVL_WIDTH + scroll_x;
		bg2._y = scroll_dy * Const.LVL_HEIGHT + scroll_y;
		decor2._x = bg2._x;
		decor2._y = bg2._y;
		bg1._x = scroll_x;
		bg1._y = scroll_y;
		decor1._x = scroll_x;
		decor1._y = scroll_y;
		game.ball.mc._x = game.ball.x + scroll_x;
		game.ball.mc._y = game.ball.y + scroll_y;
		game.ball.shadow._x = game.ball.mc._x + mb2.Ball.SHADOW_DECAL;
		game.ball.shadow._y = game.ball.mc._y + mb2.Ball.SHADOW_DECAL;
		for(d=0;d<4;d++) {
			var door = doors[d];
			door._x = doors[d].sx + scroll_x;
			door._y = doors[d].sy + scroll_y;
		}
		for(d=0;d<4;d++) {
			var door = doors[d+4];
			door._x = doors[d].sx + scroll_x + scroll_dx * Const.LVL_WIDTH;
			door._y = doors[d].sy + scroll_y + scroll_dy * Const.LVL_HEIGHT;
		}
	}

// ---------------------------------------------------------------------------

	static function makeTime(t) {
		return padNumber( int(t/6000) , 2 ) + ":" + padNumber( int(t/100)%60 , 2 ) + ":" + padNumber( t%100, 2 );
	}

	static function padNumber(x,n) {
		x = ""+x;
		while( x.length < n )
			x = "0"+x;
		return x;
	}

// ---------------------------------------------------------------------------

	function update() {
		if( Manager.play_mode == Const.MODE_COURSE ) {
			tview.lap_txt.text = game.course_nturns - 1;
			if( tview._currentframe != 11 ) {
				old_time = 1.5;
				return;
			}
			if( old_time > 0 ) {
				old_time -= Std.deltaT;
				return;
			}
			tview.timerPanel.min_txt.text = padNumber(int(game.curtime/60),2);
			tview.timerPanel.sec_txt.text = padNumber(int(game.curtime) % 60,2); 
			tview.timerPanel.mil_txt.text = padNumber(int(game.curtime*100) % 100,2);
		}
		else {
			var t = int(game.curtime / 100);
			if( old_time != t ) {
				old_time = t;
				tview.tview_txt.text = t;
			}
		}
	}

// ---------------------------------------------------------------------------

	function selectBg(x,y) {
		return 1+(x+y)%4;
	}

// ---------------------------------------------------------------------------

	function change_room(dx,dy) {
		save_tmod = Std.tmod;

		scroll_x = 0;
		scroll_y = 0;
		scroll_dx = dx;
		scroll_dy = dy;
		bg2._visible = true;
		decor2._visible = true;
		bg2._x = -1000;
		decor2._x = -1000;
		var d;
		for(d=0;d<4;d++) {
			var door = doors[d+4];
			door._visible = true;
			door._x = -1000;
			door._y = -1000;
		}
		game.level.pos_x += scroll_dx;
		game.level.pos_y += scroll_dy;
		bg2.gotoAndStop( selectBg(game.level.pos_x,game.level.pos_y) );

		var dir;
		if( dx < 0 )
			dir = 1;
		else if( dx > 0 )
			dir = 0;
		else if( dy < 0 )
			dir = 3;
		else if( dy > 0 )
			dir = 2;
		open_door(dir);
		// don't open doors automaticly :)
		game.level.bonus_reds = 1;
		init_doors(4);
		game.scroll_on = true;
		scroll_end = false;
		scroll_room();
	}
}