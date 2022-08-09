import mb2.Const;
import mb2.Manager;
import mb2.Tools;
import mb2.Sound;

class mb2.Ball {

	static var STONE_STYLE = [
		{MAX:6, 	RAYMIN:10,	RAYMAX:20		},	//JAUNE
		{MAX:20, 	RAYMIN:0,	RAYMAX:20		},	//VERTE
		{MAX:4, 	RAYMIN:14,	RAYMAX:14		},	//ROUGE
		{MAX:10, 	RAYMIN:0,	RAYMAX:12		},	//ORANGE
		{MAX:10, 	RAYMIN:6,	RAYMAX:20		},	//BLEUE
		{MAX:0, 	RAYMIN:0,	RAYMAX:20		},	//METAL
		{MAX:20, 	RAYMIN:0,	RAYMAX:20		}	//VIOLET
	];	

	static var SHADOW_DECAL = 3;

	var game : mb2.Game;

	var mc;
	var shadow;
	var btype;

	var col_count;
	var clign_count;
	var clign_flag;
	var stoneList;

	var control;

	var x,y,sx,sy;
	var start_x;
	var start_y;

	var speed;
	var maxspeed;
	var max_speed_enabled;

	var death_hit;
	var classic_mask;

	var hole_death;
	var hole_death_speed;
	var hole_mask;

	var jump;
	var jump_size;
	var jump_delta;
	var jump_way;
	var last_jump;

	var water;

	function Ball(game) {
		this.game = game;
		btype = 0;
		mc = game.dmanager.empty(Const.BALL_PLAN);
		shadow = game.dmanager.attach("shadow",Const.DECOR_PLAN);
		mc.attachMovie("marble","gfx",10);
		mc.createEmptyMovieClip("stoneMc",20);
		mc.attachMovie("round","mask",30);
		mc.stoneMc.setMask(mc.mask);
		mc.attachMovie("light","light",40);
		mc.gfx.gotoAndStop(btype+1);
		gen_stones();
		clign_count = 0;
		x = Const.LVL_CWIDTH / 2;
		y = Const.LVL_CHEIGHT / 2;
		sx = 0;
		sy = 0;
		Tools.set_mcpos(mc,this);
		x = mc._x;
		y = mc._y;		
		control = true;
		max_speed_enabled = true;
		jump_delta = 0;
	}	

	private function gen_stones() {
		stoneList = new Array();
		var SS = STONE_STYLE[btype];
		for(var i=0; i<SS.MAX; i++){
			var mc = Std.attachMC(this.mc.stoneMc,"stone",i);			
			mc.dx = random(628);
			mc.dy = random(628);
			mc.rayon = SS.RAYMIN+random(SS.RAYMAX-SS.RAYMIN);
			mc._rotation = random(360);
			mc.gotoAndStop((random(4)+1)+btype*10);
			if( btype == 6 )mc.eclat.gotoAndPlay(random(30)+1);
			stoneList.push(mc);
		}
		mc.mask._width = SS.RAYMAX;
		mc.mask._height = SS.RAYMAX;
	}

	function remove_stones() {
		var i;
		for(i=0;i<stoneList.length;i++)
			stoneList[i].removeMovieClip();
	}

	function move_stones() {
		var i;
		var tmod = Std.tmod;
		for(i=0;i<stoneList.length;i++) {
			var mc = stoneList[i];
			mc.dx = mc.dx+sx*10*tmod;
			mc.dy = mc.dy+sy*10*tmod;
			if(mc.dx>628) mc.dx-=628;
			if(mc.dx<0) mc.dx+=628;
			if(mc.dy>628) mc.dy-=628;
			if(mc.dy<0) mc.dy+=628;	
			var cs = Math.cos(mc.dx/100);
			var sn = Math.sin(mc.dy/100);
			
			mc._x = cs*mc.rayon/2;
			mc._y = sn*mc.rayon/2;
			
			var xc = Math.cos((mc.dx+157)/100);
			var yc = Math.cos((mc.dy+157)/100);
			var max = (mc.rayon/Const.BALL_RAYSIZE)*50;
			mc._alpha = 50+(xc+yc)*max;		
		}
	}

	function update_skin() {
		remove_stones();
		gen_stones();
		mc.gfx.gotoAndStop(btype+1);
	}

	function update_jump() {
		var tmod = Std.tmod;
		if( jump ) {
			jump_size += tmod*jump_way*60;
			jump_delta = Math.sqrt(jump_size*speed)/6;
			shadow._y = x+SHADOW_DECAL+jump_delta;
			mc._xscale = 100+jump_delta*3;
			mc._yscale = 100+jump_delta*3;
			if( jump_size > 200 )
				jump_way *= -1;
			else if( jump_size < 0 ) {
				jump_delta = 0;
				jump = false;
				mc._xscale = 100;
				mc._yscale = 100;
				mc.shadow._y = 0;
				last_jump = true;
			}
		}
	}

	function update_hole() {
		if( !hole_death )
			return false;

		sx *= 0.9;
		sy *= 0.9;
		mc._xscale *= Math.pow(0.92,Std.tmod*hole_death_speed);
		mc._yscale *= Math.pow(0.92,Std.tmod*hole_death_speed);
		mc._x += sx/5;
		mc._y += sy/5;
		if( mc._xscale < 3 ) {
			hole_death = false;
			mc.setMask(null);
			classic_mask.removeMovieClip();
			hole_mask.removeMovieClip();
			if( Manager.play_mode == Const.MODE_CLASSIC && !death_hit ) {
				game.curtime += Const.TIME_CLASSIC_EXTENDED;
				x = game.level.exit.clip._x;
				y = game.level.exit.clip._y + Const.LVL_HEIGHT; // will scroll room down
				game.level.pos_y = random(game.level.height) - 1;
				game.level.pos_x++;
				sx = 0;
				sy = 0;
				mc._xscale = 100;
				mc._yscale = 100;
				mc._x = x;
				mc._y = y;
				shadow._visible = true;
				shadow._x = x;
				shadow._y = y;			
			}
			else
				kill();
		}
		return true;
	}

	function update() {
		var tmod = Std.tmod;
		if( clign_count > 0 ) {
			clign_count -= tmod * 1000 / 40;
			clign_flag = !clign_flag;
			mc._alpha = clign_flag?30:60;
			if( clign_count <= 0 )
				mc._alpha = 100;
		}

		// KEYS
		var i;
		var dx = 0, dy = 0;
		if( control && !jump ) {
			if( Key.isDown(Key.DOWN) )
				dy++;
			if( Key.isDown(Key.UP) )
				dy--;
			if( Key.isDown(Key.LEFT) )
				dx--;
			if( Key.isDown(Key.RIGHT) )
				dx++;
		}

		// MOVE	
		var speed_coef = 0.6;
		var inertia = 0.95;
		
		maxspeed = 20;
		switch( btype ) {
		case 3: // ORANGE
			speed_coef = 2.1;
			inertia = 0.85;
			break;
		case 2: // RED
			speed_coef = 0.6;
			inertia = 0.95;
			for(i=0;i<game.level.bonus.length;i++) {
				var b = game.level.bonus[i];
				if( b && b.bname == "red" ) {
					var d = Tools.dist2(mc,b.clip);
					if( d < 40000 ) {
						b.clip._x += (mc._x - b.clip._x) * 150 * tmod / d;
						b.clip._y += (mc._y - b.clip._y) * 150 * tmod / d;
					}
				}
			}
			break;
		case 5: // METAL
			maxspeed = 7;
			speed_coef = 0.2;
			inertia = 0.98;
			break;
		default:
			speed_coef = 0.85;
			inertia = 0.94;
			break;
		}
		
		if( water ) {
			inertia = 0.98;
			speed_coef *= 2;
		}

		if( dx != 0 && dy != 0 ) {
			var sq2 = Math.sqrt(2);
			dx /= sq2;
			dy /= sq2;
		}

		sx *= Math.pow(inertia,tmod);
		sy *= Math.pow(inertia,tmod);
		if( Math.abs(sx) < 0.1 )
			sx = 0;
		if( Math.abs(sy) < 0.1 )
			sy = 0;

		sx += speed_coef*dx*tmod;
		sy += speed_coef*dy*tmod;
		speed = Math.sqrt(sx*sx+sy*sy);
		if( max_speed_enabled && speed > maxspeed ) {
			if( speed > 3*maxspeed ) {
				speed /= 3;
				sx /= 3;
				sy /= 3;
			}
			speed *= Math.pow(0.8,tmod);
			sx *= Math.pow(0.8,tmod);
			sy *= Math.pow(0.8,tmod);
		}		

		// COLLIDE	
		dx = sx * tmod;
		dy = sy * tmod;
		
		var ncol = 1+int(Math.sqrt(dx*dx+dy*dy)/Const.DELTA);
		dx/=ncol;
		dy/=ncol;
		for(i=0;i<ncol;i++) {
			hole_test();
			var c = game.level.col_test(x+dx,y+dy,true);
			if( c ) {
				col_count++;
				break;
			}
			x += dx;
			y += dy;
		}
		if( i == ncol )
			col_count = 0;
		else if( col_count >= 20 ) {
			sx = 0;
			sy = 0;
			recall();
		}

		mc._x = x + Const.DELTA / 2;
		mc._y = y + Const.DELTA / 2 - jump_delta;
		shadow._x = mc._x + SHADOW_DECAL;
		shadow._y = mc._y + SHADOW_DECAL;
		move_stones();
	}

	function recall() {
		var ray;
		var a;
		for(ray=1;ray<30;ray+=2) {
			for(a=0;a<8;a++) {
				var ang = a * Math.PI / 4;
				var dx = Math.cos(ang) * ray;
				var dy = Math.sin(ang) * ray;
				if( !game.level.col_test(x+dx,y+dy,false) ) {
					x += dx;
					y += dy;
					return;
				}
			}
		}
	}

	function hole_test() {
		var dx = int((int(x/Const.DELTA)-Const.BORDER_CSIZE)/10);
		var dy = int((int(y/Const.DELTA)-Const.BORDER_CSIZE)/10);
		var walltable = game.level.interf.walltable;
		if( walltable[dx][dy].btype == 7 && !jump ) { // TROU
			
			var px = ((dx+0.5)*10+Const.BORDER_CSIZE)*Const.DELTA;
			var py = ((dy+0.5)*10+Const.BORDER_CSIZE)*Const.DELTA;
			var delt = 5*Const.DELTA;
			var d = 0;
			
			sx *= 1.1;
			sy *= 1.1;
			speed *= 1.1;
			
			if( x < px && walltable[dx-1][dy].btype != 7 )
				d |= 1;
			else if( x > px && walltable[dx+1][dy].btype != 7 )
				d |= 2;
			if( y < py && walltable[dx][dy-1].btype != 7 )
				d |= 4;
			else if( y > py && walltable[dx][dy+1].btype != 7 )
				d |= 8;
			if( d == 15 )
				d = 0;
			if( d & 1 )
				sx++;
			if( d & 2 )
				sx--;
			if( d & 4 )
				sy++;
			if( d & 8 )
				sy--;
			
			if( x > (px - delt + ((d & 1)?Const.BALL_RAYSIZE:0)) &&
				x < (px + delt - ((d & 2)?Const.BALL_RAYSIZE:0)) &&
				y > (py - delt + ((d & 4)?Const.BALL_RAYSIZE:0)) &&
				y < (py + delt - ((d & 8)?Const.BALL_RAYSIZE:0)) )
			{
				hole_mask = Std.duplicateMC(game.level.interf.holes,Const.HOLE_PLAN*5000-1);
				mc.setMask(hole_mask);
				shadow._visible = false;
				clign_count = 0;
				hole_death_speed = 1;
				death_hit = false;
				hole_death = true;
				return;
			} else if( btype == 4 && !last_jump ) { // BLUE
				jump = true;
				jump_way = 1;
				jump_size = 0;
				jump_delta = 0;
				return;
			}
		} else if( last_jump )
			last_jump = false;
	}

	function die() {
		if( clign_count > 0 )
			return;
		if( !hole_death ) {
			mc._alpha = 100;
			hole_death = true;
			death_hit = true;
			hole_death_speed = 5;
			shadow._visible = false;
			sx = 0;
			sy = 0;
		}
	}

	function kill() {
		sx = 0;
		sy = 0;
		x = start_x;
		y = start_y;
		mc._xscale = 100;
		mc._yscale = 100;
		mc._x = x;
		mc._y = y;
		mc._visible = true;
		mc._alpha = 100;
		shadow._visible = true;
		shadow._x = x;
		shadow._y = y;
		if( Manager.play_mode != Const.MODE_AIDE ) {
			if( btype != 0 || Manager.play_mode != Const.MODE_COURSE ) {
				game.options.ball_types[btype]--;
				game.options.ball_types_chk--;
			}
		}
		clign_count = 400;
		clign_flag = true;
		var last = btype;
		while( !(game.options.ball_types[btype] > 0) ) {
			btype++;
			btype %= 7;
			if( btype == last ) {
				game.options.update_icons();
				shadow._visible = false;
				mc._visible = false;
				game.gameOver(Const.CAUSE_NOBALLS);
				return;
			}
		}
		game.options.update_icons();
		update_skin();		
	}
}
