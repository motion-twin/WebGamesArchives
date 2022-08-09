import mb2.Const;
import mb2.Collide;
import mb2.Tools;
import mb2.Manager;

class mb2.Level {//}

	var game : mb2.Game;

	var width, height;
	var start_x, start_y;
	var dungeon;

	var pos_x, pos_y;

	var bonus, updates, objects, dummies;
	
	var coltable;
	var bonus_reds;

	var dmanager;
	var loader;
	var interf : mb2.Interf;

	var exit;

// ---------------------------------------------------------------------------

	function Level(game : mb2.Game ) {
		this.game = game;
		dmanager = game.dmanager;
		loader = new mb2.LevelLoader(mb2.Loader.last_data);
		width = loader.width;
		height = loader.height;		
		start_x = loader.start_x;
		start_y = loader.start_y;
		dungeon = loader.dungeon;
		pos_x = start_x;
		pos_y = start_y;
		interf = new mb2.Interf(game);
	}

// ---------------------------------------------------------------------------

	function init_room() {
		interf.init_room();
		bonus = new Array();
		updates = new Array();
		objects = new Array();
		coltable = new Array();
		dummies = new Array();
		var x,y;
		for(x=0;x<Const.LVL_CWIDTH;x++)
			coltable[x] = new Array();
		for(x=0;x<Const.BORDER_CSIZE;x++) {
			for(y=0;y<Const.LVL_CHEIGHT;y++)
				coltable[x][y] = Collide.border_collide;
			for(y=0;y<Const.LVL_CHEIGHT;y++)
				coltable[Const.LVL_CWIDTH-1-x][y] = Collide.border_collide;
		}
		for(y=0;y<Const.BORDER_CSIZE;y++) {
			for(x=0;x<Const.LVL_CWIDTH;x++)
				coltable[x][y] = Collide.border_collide;
			for(x=0;x<Const.LVL_CWIDTH;x++)
				coltable[x][Const.LVL_CHEIGHT-1-y] = Collide.border_collide;
		}		
		loader.decodeRoom(pos_x,pos_y);
		gen_room();
		return true;
	}

// ---------------------------------------------------------------------------

	function free_pos(px,py,msize) {
		var x,y;
		for(x=0;x<msize.w;x++)
			for(y=0;y<msize.h;y++)
				if( coltable[x+px][y+py] )
					return false;
		return true;
	}

// ---------------------------------------------------------------------------

	function fill_pos(p,map,v) {
		var x , y;
		var w = map.length;
		var h = map[0].length;
		var dx = Const.DELTA / 2 - (w/2)*Const.DELTA;
		var dy = Const.DELTA / 2 - (h/2)*Const.DELTA;
		for(x=0;x<w;x++)
			for(y=0;y<h;y++)
				if( map[x][y] )
					coltable[x+p.x][y+p.y] = v;
	}

// ---------------------------------------------------------------------------

	function erase_pos(b) {
		var x , y;
		var msize = Tools.mc_size(b.clip);
		msize.w += b.x;
		msize.h += b.y;
		for(x=b.x;x<msize.w;x++)
			for(y=b.y;y<msize.h;y++)
				if( coltable[x][y] == b )
					coltable[x][y] = null;
	}

// ---------------------------------------------------------------------------

	function gen_room() {
		var room = dungeon[pos_x][pos_y];
		var d;
		room.visited = true;
		bonus_reds = 0;
		switch( room.rtype ) {
		case 2:
			gen_boss_room(room);
			break;
		case 3:
			gen_object_room(room.rdata);
			break;
		case 4:
			gen_bonus_room(room.rdata);
			break;
		default:
			gen_normal_room(room.bdata);
			break;
		}
		interf.init_doors(0);
		if( bonus_reds == 0 )
			interf.open_doors();
		interf.update_walls();	
	}

// ---------------------------------------------------------------------------

	function gen_boss_room(r) {
		bonus_reds = 1;

		var o = new Object();
		o.on_update = Collide.boss_room_on_update;
		updates.push(o);
	
		gen_bumper({btype:7,x:Const.BORDER_CSIZE+1,y:Const.LVL_CHEIGHT-10});
		gen_bumper({btype:7,x:Const.BORDER_CSIZE+11,y:Const.LVL_CHEIGHT-10});
		gen_bumper({btype:7,x:Const.BORDER_CSIZE+1,y:Const.LVL_CHEIGHT-20});
		
		gen_bumper({btype:7,x:Const.LVL_CWIDTH-10,y:Const.LVL_CHEIGHT-10});
		gen_bumper({btype:7,x:Const.LVL_CWIDTH-20,y:Const.LVL_CHEIGHT-10});
		gen_bumper({btype:7,x:Const.LVL_CWIDTH-10,y:Const.LVL_CHEIGHT-20});

		objects.push(gen_bumper({btype:3,x:7,y:7}));
		objects.push(gen_bumper({btype:3,x:Const.LVL_CWIDTH-17,y:7}));
	}

// ---------------------------------------------------------------------------

	function gen_object_room(o) {
		var obj;
		switch( o ) {
		case 0: // VERTE
			obj = 1;
			break;
		case 1: // BLEUE
			obj = 4;
			break;
		case 2: // METAL
			obj = 5;
			break;
		case 3: // VIOLET
			obj = 6;
			break;
		case 4: // ORANGE
			obj = 3;
			break;
		case 5: // ROUGE
			obj = 2;
			break;
		}

		var clip = dmanager.attach("ballbox",Const.BONUS_PLAN);
		Tools.set_mcpos(clip,Tools.pos_center(clip));
		clip.ball.gotoAndStop(obj+1);

		var oo = new Object();
		oo.on_update = Collide.ball_object_on_update;
		oo.obj = obj;
		oo.clip = clip;
		updates.push(oo);
		objects.push(oo);

		objects.push(gen_bumper({btype:2,x:7,y:7}));
		objects.push(gen_bumper({btype:2,x:Const.LVL_CWIDTH-23,y:7}));	
		objects.push(gen_bumper({btype:2,x:7,y:Const.LVL_CHEIGHT-23}));	
		objects.push(gen_bumper({btype:2,x:Const.LVL_CWIDTH-23,y:Const.LVL_CHEIGHT-23}));	
		
		objects.push(gen_bumper({btype:1,x:50,y:30}));
		objects.push(gen_bumper({btype:1,x:Const.LVL_CWIDTH-62,y:30}));	
		objects.push(gen_bumper({btype:1,x:50,y:Const.LVL_CHEIGHT-42}));	
		objects.push(gen_bumper({btype:1,x:Const.LVL_CWIDTH-62,y:Const.LVL_CHEIGHT-42}));	
	}

// ---------------------------------------------------------------------------

	function gen_bonus_room(bt) {
		var item;
		var on_get_item;
		switch( bt ) {
		case 0: // B.VERTE
			gen_object_room(4);
			return;
		case 1: // B.ROUGE
			gen_object_room(5);
			return;
		case 2: // MAP
			item = 0;
			on_get_item = Collide.on_get_map;
			break;
		case 3: // RADAR
			item = 1;
			on_get_item = Collide.on_get_radar;
			break;
		case 4: // KEY
			item = 4;
			on_get_item = Collide.on_get_key;
			break;
		case 5: // SMALLTIME
			item = 2;
			on_get_item = Collide.on_get_small_blue;
			break;
		case 6: // BIGTIME
			item = 3;
			on_get_item = Collide.on_get_big_blue;
			break;
		}
		if( bt != -1 ) {
			var clip = dmanager.attach("itembox",Const.BUMPER_PLAN);
			var b = new Object();
			b.clip = clip;
			b.pos = Tools.pos_center(clip);
			b.hit_coef = 0.1;
			b.hit_min = 0;
			fill_pos(b.pos,Collide.hitmap[7],b);
			Tools.set_mcpos(clip,b.pos);
			b.on_hit = Collide.item_box_on_hit;
			b.on_get_item = on_get_item;
			clip.item.gotoAndStop(item+1);
			objects.push(b);
		}
		objects.push(gen_bumper({btype:2,x:7,y:7}));
		objects.push(gen_bumper({btype:2,x:Const.LVL_CWIDTH-23,y:7}));	
		objects.push(gen_bumper({btype:2,x:7,y:Const.LVL_CHEIGHT-23}));	
		objects.push(gen_bumper({btype:2,x:Const.LVL_CWIDTH-23,y:Const.LVL_CHEIGHT-23}));	
		
		objects.push(gen_bumper({btype:1,x:50,y:30}));
		objects.push(gen_bumper({btype:1,x:Const.LVL_CWIDTH-62,y:30}));	
		objects.push(gen_bumper({btype:1,x:50,y:Const.LVL_CHEIGHT-42}));	
		objects.push(gen_bumper({btype:1,x:Const.LVL_CWIDTH-62,y:Const.LVL_CHEIGHT-42}));	
	}

// ---------------------------------------------------------------------------

	function gen_normal_room(blist) {
		var i;
		for(i=0;i<blist.length;i++) {
			var b = blist[i];

			switch( b.btype ) {
			case 0:
				break;
			case 8:
				bonus.push( gen_bonus("red",b,Collide.red_on_hit) );
				bonus_reds++;
				break;
			case 9:
				bonus.push( gen_bonus("blue",b,Collide.blue_on_hit) );			
				break;
			case 15:
				exit = gen_bonus("exit",b,Collide.classic_exit_on_hit);
				exit.clip._x += 2;
				exit.clip._y += 2;
				bonus.push( exit );
				exit.clip.stop();
				break;
			default:
				objects.push( gen_bumper(b) );
				break;
			}
		}
		finalize_zappers();
	}

// ---------------------------------------------------------------------------

	function finalize_zappers() {
		var i,j,k;
		var zappers = new Array();
		var sx,sy;
		for(i=0;i<objects.length;i++) {
			var b = objects[i];
			if( b.btype == 14 ) {
				var zaps = zappers[b.phase];
				if( zaps == null ) {
					zaps = new Array();
					zappers[b.phase] = zaps;
					if( sx == undefined ) {
						var s = Tools.mc_size(b.clip);
						sx = s.w / 2;
						sy = s.h / 2;
					}
				}
				zaps.push(b);
			}
		}
		
		for(i=0;i<zappers.length;i++) {
			var zaps = zappers[i];
			for(j=0;j<zaps.length;j++)
				for(k=j+1;k<zaps.length;k++)
					trace_zappers(zaps[j],zaps[k],sx,sy);
		}
	}

// ---------------------------------------------------------------------------

	function trace_zappers(z1,z2,sx,sy) {
		var col = new Object();
		col.phase = z1.phase;
		col.on_hit = Collide.zapper_line_on_hit;
		col.is_event = true;
		col.z1 = z1;
		col.z2 = z2;
		var dx = z2.x - z1.x;
		var dy = z2.y - z1.y;
		var d = Math.sqrt(dx*dx + dy * dy);
		dx /= d;
		dy /= d;
		var len = int(d)+1;
		var x = z1.x + sx;
		var y = z1.y + sy;
		var l;
		for(l=0;l<len;l++) {
			coltable[int(x)][int(y)] = col;
			x += dx;
			y += dy;
		}
	}

// ---------------------------------------------------------------------------

	function gen_bumper(b) {
		var bname;
		var upper = true;
		switch( b.btype ) {
		case 1:
			bname = "bnormal";
			b.on_hit = Collide.bumper_normal_on_hit;
			b.hit_coef = 1.5;
			b.hit_min = 20;
			break;
		case 2:
			bname = "btime";
			b.on_hit = Collide.bumper_time_on_hit;
			b.hit_coef = 1.5;
			b.hit_min = 15;
			break;
		case 3:
			bname = "bdeath";
			b.on_hit = Collide.bumper_death_on_hit;
			b.hit_coef = 1.2;
			b.hit_min = 5;
			break;
		case 4:
			bname = "bmagnet";
			b.on_hit = Collide.bumper_magnet_on_hit;
			b.hit_coef = 1.0;
			b.hit_min = 5;
			break;
		case 5:
			bname = "bshadow";
			b.on_hit = Collide.bumper_shadow_on_hit;
			b.hit_coef = 3.0;
			b.hit_min = 15;
			break;
		case 6:
			bname = "wall";
			b.on_hit = Collide.wall_on_hit;
			b.hit_coef = 1.2;
			b.hit_min = 0;
			interf.fill_wall(b,b);
			break;
		case 10:
			upper = false;
			bname = "bteleport";
			break;
		case 11:
			bname = "interupt";
			b.on_hit = Collide.interupt_on_hit;
			b.hit_coef = 1.2;
			b.hit_min = 0;
			break;
		case 12:
			upper = false;
			bname = "interred";
			b.on_hit = Collide.interupt_flag?Collide.interblock_on_hit:null;
			b.hit_coef = 1.2;
			b.hit_min = 0;
			break;
		case 13:
			upper = false;
			bname = "interblue";
			b.on_hit = Collide.interupt_flag?null:Collide.interblock_on_hit;
			b.hit_coef = 1.2;
			b.hit_min = 0;
			break;
		case 14:
			bname = (Manager.play_mode == Const.MODE_COURSE)?"checkpoint":"zapper";
			b.on_hit = Collide.zapper_on_hit;
			b.hit_coef = 1.1;
			b.hit_min = 10;
			break;
		case 7:
			// TROU
			interf.ground._visible = true;
			interf.fill_wall(b,b);
			return null;
		}
		
		var clip = dmanager.attach(bname,upper?Const.BUMPER_PLAN:Const.SHADE_PLAN);
		fill_pos(b,Collide.hitmap[b.btype-1],b);
		Tools.set_mcpos(clip,b);
		b.clip = clip;
		if( b.btype != 5 && b.btype != 6 && b.btype != 10 && b.btype != 12 && b.btype != 13 ) {
			b.shade = dmanager.attach("ombre",Const.SHADE_PLAN);
			b.shade._x = b.clip._x;
			b.shade._y = b.clip._y;
			b.shade.gotoAndStop(b.btype);
		}
		
		switch( b.btype ) {
		case 4:
			b.way = true;
			b.clip.gotoAndPlay("plus");
			b.on_update = Collide.bumper_magnet_on_update;
			updates.push(b);
			break;
		case 5:
			b.clip._visible = false;
			b.clip._alpha = 0;
			b.on_update = Collide.bumper_shadow_on_update;
			updates.push(b);
			break;
		case 2:
			b.on_update = Collide.bumper_time_on_update;
			b.curtime = game.curtime;
			b.on_update(game,b);
			updates.push(b);
			break;
		case 10:
			b.on_update = Collide.bumper_teleport_on_update;
			updates.push(b);			
			b.clip.num = 5
			for(var i=0; i<b.clip.num; i++){
				if(i>0)b.clip.c0.duplicateMovieClip("c"+i,i);
				var mc = b.clip["c"+i];				
				mc.gfx._y = random(6);
				mc.gfx._rotation = random(360);
				mc.rot = 3+random(3);
				mc.c = random(628);
			}
			break;
		case 11:
		case 13:
			b.clip._x -= 2;
			b.clip._y -= 2;
			b.clip.gotoAndStop(Collide.interupt_flag?"on":"off");
			break;
		case 12:
			b.clip.gotoAndStop(Collide.interupt_flag?"off":"on");
			break;
		case 14:
			var s = Tools.mc_size(b.clip);
			if( Manager.play_mode == Const.MODE_COURSE )
				b.phase = 0;
			else {
				b.phase = ((b.x-s.w/2)+(b.y-s.h/2))%7;
				b.clip.gotoAndStop(1+b.phase);
			}
			break;
		}
		return b;
	}

// ---------------------------------------------------------------------------

	function gen_bonus(bname,b,on_hit) {
		var clip = dmanager.attach(bname,Const.BONUS_PLAN);
		Tools.set_mcpos(clip,b);
		b.bname = bname;
		b.clip = clip;
		b.on_hit = on_hit;
		return b;
	}

// ---------------------------------------------------------------------------

	function set_door_collide(d,v,delta) {
		if( delta == undefined )
			delta = 0;
		var x,y;
		switch(d) {
		case 0:
			for(x=0;x<Const.BORDER_CSIZE;x++)
				for(y=-delta;y<Const.DOOR_CSIZE+delta;y++)
					coltable[x][y+Const.DOOR_CYPOS] = v;
			break;
		case 1:
			for(x=0;x<Const.BORDER_CSIZE;x++)
				for(y=-delta;y<Const.DOOR_CSIZE+delta;y++)
					coltable[Const.LVL_CWIDTH-1-x][y+Const.DOOR_CYPOS] = v;
			break;
		case 2:
			for(x=-delta;x<Const.DOOR_CSIZE+delta;x++)
				for(y=0;y<Const.BORDER_CSIZE;y++)
					coltable[x+Const.DOOR_CXPOS][y] = v;
			break;
		case 3:
			for(x=-delta;x<Const.DOOR_CSIZE+delta;x++)
				for(y=0;y<Const.BORDER_CSIZE;y++)
					coltable[x+Const.DOOR_CXPOS][Const.LVL_CHEIGHT-1-y] = v;
			break;
		}
	}

// ---------------------------------------------------------------------------


	function clean_room() {
		var i;
		for(i=0;i<objects.length;i++) {
			objects[i].clip.removeMovieClip();
			objects[i].shade.removeMovieClip();
		}
		for(i=0;i<bonus.length;i++)
			bonus[i].clip.removeMovieClip();
		for(i=0;i<dummies.length;i++)
			dummies[i].clip.removeMovieClip();
		exit.clip.removeMovieClip();
		exit = null;		
		interf.holes.clear();
		interf.shades.clear();
		interf.ground._visible = false;
	}

// ---------------------------------------------------------------------------

	function change_room(dx,dy) {
		clean_room();
		interf.change_room(dx,dy);
	}

// ---------------------------------------------------------------------------

	function max(a,b) {
		if( a < b )
			return b;
		return a;
	}

	function col_test(x,y,side_effects) {
		var i,ang;
		var asteps = 16;
		var px,py;
		var first_col = 0;
		var n_col = 0;
		var tot = 0;
		var hit_coef = 0;
		var hit_min = 0;
		var ct;
		var first_ct;
		var fpx,fpy;
		var in_ang = Math.atan2(game.ball.sy,game.ball.sx); // angle d'approche
		for(i=0;i<asteps;i++) {
			ang = (Math.PI * 2) * i / asteps;		
			px = int((x+Math.cos(ang)*Const.BALL_RAYSIZE+Const.DELTA/2)/Const.DELTA);
			py = int((y+Math.sin(ang)*Const.BALL_RAYSIZE+Const.DELTA/2)/Const.DELTA);
			ct = coltable[px][py];
			if( ct.on_hit ) {
				if( ct.is_event ) {
					if( side_effects )
						ct.on_hit(game,ct,px,py);
				} else {
					if( !side_effects )
						return true;
					hit_coef = max(ct.hit_coef,hit_coef);
					hit_min = max(ct.hit_min,hit_min);
					if( n_col == 0 ) {
						first_col = i;
						first_ct = ct;
						fpx = px;
						fpy = py;
					} else {
						first_ct.on_hit(game,first_ct,fpx,fpy);
						ct.on_hit(game,ct,px,py);
						if( i - first_col < asteps / 2 )
							tot += i - first_col;
						else
							tot += i - asteps - first_col;
					}
					n_col++;
				}
			}
		}
		if( n_col > 1 ) {
			tot /= n_col;
			tot += first_col;
			if( tot < 0 )
				tot += asteps;			
			ang = (Math.PI * 2) * tot / asteps - Math.PI; // angle de la collision
			var speed = game.ball.speed * hit_coef; // vitesse d'approche
			if( speed < hit_min )
				speed = hit_min;
			var out_ang = ang + Math.PI - (in_ang - ang)+Math.random()/100; // rebond
			if( Math.abs(Tools.rad_dif(in_ang,ang)) > Math.PI / 2 + 0.05 ) {
				game.ball.sx = speed * Math.cos(out_ang);
				game.ball.sy = speed * Math.sin(out_ang);
				// recal with hit density
				game.ball.x += Math.cos(out_ang) * Std.tmod * Math.min(n_col * n_col / 10,3);
				game.ball.y += Math.sin(out_ang) * Std.tmod * Math.min(n_col * n_col / 10,3);
				return true;
			}
		}
		return false;
	}
//{
}
