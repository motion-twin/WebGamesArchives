import snake3.Const;
import snake3.Manager;

class snake3.Snake {

	var gfx : MovieClip;
	public var queue : Array;
	public var eat;
	var old_ang;
	var dist;
	var dx, dy;
	var col_mc : MovieClip;
	var col_pt;
	var dmanager;
	var time;
	
	var color_qpos;
	var color_val;
	public var redraw;
	var last_fruit_id;

	public var eat_speed;
	public var can_move;
	public var base_speed;
	public var alpha_val;
	public var wall_rebonds;
	public var distort;
	public var distort_val;
	public var queue_collide;
	public var tete : MovieClip;
	public var border_color;
	public var color;
	public var speed;
	public var x, y;
	public var len;
	public var ang;
	public var delta_ang;
	public var fuca_game;
	
	function Snake( dman : asml.DepthManager, pos ) {
		dmanager = dman;
		color = Const.COLOR_SNAKE_DEFAULT;
		border_color = Const.COLOR_SNAKE_BORDER_DEFAULT;
		gfx = dman.empty(Const.PLAN_SNAKE);
		tete = dman.attach("tete",Const.PLAN_SNAKE);
		base_speed = 1;
		eat_speed = 1;
		queue = new Array();
		col_mc = Std.getVar(tete,"col");
		col_mc._visible = false;
		x = pos.x;
		y = pos.y;
		dx = 0;
		dy = 0;
		ang = 0;
		eat = 0;
		fuca_game = null;
		old_ang = -100;
		delta_ang = Const.SNAKE_DEFAULT_TURN;
		speed = Const.SNAKE_DEFAULT_SPEED;
		len = Const.SNAKE_DEFAULT_LENGTH;
		dist = 0;
		can_move = true;
		distort = false;
		distort_val = 0;
		redraw = true;
		queue_collide = true;
		wall_rebonds = false;
		alpha_val = 100;
		color_qpos = -1;
		
		var i;
		for(i=0;i<50;i++)
			queue.push(pos);

	}
	
	function end_queue_pos(delta) {
		return queue[Math.max(0,queue.length - len * 5 + delta)];
	}

	function move( bounds ) {
		var tmod = Std.tmod;
		var hit = false;

		this.speed += Std.tmod / 10000;	

		if( eat > 0 ) {
			eat -= eat_speed * tmod/2;
			redraw = true;
			if( eat < 0 && fuca_game != null ) {
				len--;
				var f = fuca_game.gen_fruit();
				var p = end_queue_pos(0);
				f.set_id(last_fruit_id);
				f.set_pos(p.x,p.y);
			}
		}
		
		if( old_ang != ang ) {
			ang -= int(ang / (Math.PI * 2)) * Math.PI * 2;
			old_ang = ang;
			dx = Math.cos(ang);
			dy = Math.sin(ang);		
		}
	
		var speed = this.speed*tmod*base_speed;
		if( !can_move )
			speed = 0;

		var ds = Math.min(10+len,18);
		var col_pt = { x : Const.POS_X + x + dx*ds, y : Const.POS_Y + y + dy*ds };
		var ncols = int(speed/5)+1;

		while( ncols > 0 ) {			
			ncols--;
			var delta_speed = ((ncols > 0)?5:(speed%5));
			col_pt.x += dx * delta_speed;
			col_pt.y += dy * delta_speed;
			if( queue_collide && gfx.hitTest(col_pt.x,col_pt.y,true) ) {
				hit = true;
				break;
			}
		}

		x += dx*speed;
		y += dy*speed;

		dist += speed/5;
		var curp = { x : x, y : y };
		while( dist >= 1 ) {
			dist--;			
			queue.push(curp);
			redraw = true;
		}

		var px = col_pt.x - Const.POS_X;
		var py = col_pt.y - Const.POS_Y;
		if( px < bounds.left || py < bounds.top || px > bounds.right || py > bounds.bottom ) {
			if( wall_rebonds ) {
				if( px < bounds.left || px > bounds.right )
					dx *= -1;
				else
					dy *= -1;
				ang = Math.atan2(dy,dx);
				Manager.smanager.play(Const.SOUND_RESSORT);
			} else
				hit = true;
		}
		this.col_pt = col_pt;
		return hit;
	}

	function collision_pt() {
		return col_pt;
	}

	function collision() {
		return col_mc;
	}

	function hit(pt) {
		return gfx.hitTest(pt.x,pt.y,true) || tete.hitTest(pt.x,pt.y,true);
	}

	function draw() {
		var scale = Math.min(10,len+3) / 10;

		tete._x = x;
		tete._y = y;
		tete._rotation = ang*180/Math.PI;
		tete._xscale = 30 + 70 * scale;
		tete._yscale = 30 + 70 * scale;

		if( !redraw )
			return;

		time = getTimer() / 100;

		redraw = false;

		gfx.clear();
		var old = color;
		color = border_color;
		draw_queue(scale,8);
		color = old;
		draw_queue(scale,5);
	}

	function draw_queue(scale,lsize) {
		var n = queue.length-1;
		var p = queue[n], p2;
		var i,s = scale * 15/len,q;
		var eat_flag = (eat > 0);
		var a,c;

		gfx.moveTo(p.x,p.y);

		if( Std.tmod < 1.7 ) {
			for(i=len;i>0;i--) {
				p = queue[n-5];
				p2 = queue[n-2];
				if( eat_flag )
					q = Math.max(1,2-(i-eat)*(i-eat)/2);
				else
					q = 1;
				if( i == color_qpos )
					c = color_val;
				else
					c = color;
				if( i == 1 )
					a = alpha_val;
				else
					a = 100;
				gfx.lineStyle( i*s*q+lsize, c, a );
				if( distort ){
					var delta = Math.cos(i+time)*Math.min(6,len-i)*distort_val;
					gfx.curveTo(p2.x+delta,p2.y-delta,p.x+delta,p.y-delta);
				} 
				else
					gfx.curveTo(p2.x,p2.y,p.x,p.y);
				n-=5;
			}
		} else {
			for(i=len;i>0;i--) {
				n-=5;
				p = queue[n];
				if( eat_flag )
					q = Math.max(1,2-(i-eat)*(i-eat)/2);
				else
					q = 1;
				if( i == color_qpos )
					c = color_val;
				else
					c = color;
				if( i == 1 )
					a = alpha_val;
				else
					a = 100;
				gfx.lineStyle( i*s*q+lsize, c, a );
				if( distort ) {
					var delta = Math.cos(i+time)*Math.min(6,len-i)*distort_val;
					gfx.lineTo(p.x+delta,p.y-delta);
				} else
					gfx.lineTo(p.x,p.y);
			}
		} 
	}

	function add_queue(fid) {
		last_fruit_id = fid;
		queue.splice(0,Math.max(0,queue.length-len*5-1));
		var p = queue[0];
		var i;
		for(i=0;i<10;i++)
			queue.unshift(p);
		len++;
		redraw = true;
		eat = int(len-1);
	}

	function reverse() {
		var delta = -1;
		var p1 = Std.cast(end_queue_pos(delta));
		var p2;
		do {
			p2 = Std.cast(end_queue_pos(delta++));
		} while( p1 == p2 && delta < 20 );

 		queue.splice(0,Math.max(0,queue.length-len*5-1));
		var i;
		var qlen = queue.length;
		for(i=0;i<int(qlen/2);i++) {
			var q = queue[i];
			queue[i] = queue[qlen-i-1];
			queue[qlen-i-1] = q;
		}

		ang = Math.atan2(p1.y - p2.y,p1.x - p2.x);
		x = p1.x;
		y = p1.y;
		redraw = true;
	}

	function set_color(qpos,qcolor) {
		if( qpos != color_qpos )
			redraw = true;
		color_qpos = qpos;
		color_val = qcolor;
	}	

	function explode(rgb) {
		var pos = queue[queue.length - (len * 5)];
		len--;
		var particules = new Array();
		var i;
		for(i=0;i<10;i++) {
			var p = dmanager.attach("qparticule",Const.PLAN_DUMMIES);
			var ang = random(180) / Math.PI;
			var speed = 1 + random(100) / 100;
			var c = new Color(p);
			c.setRGB(rgb);
			p._x = pos.x;
			p._y = pos.y;
			particules.push({ mc : p, ang : ang, speed : speed });
		}
		var f_update_particules;
		function update_particules() {
			var i;
			for(i=0;i<particules.length;i++) {
				var p = particules[i];
				var s = p.speed * Std.tmod;
				p.mc._x += Math.cos(p.ang) * s;
				p.mc._y += Math.sin(p.ang) * s;
				p.mc._rotation += s * 10;
				p.mc._alpha -= s * 10;
				if( p.mc._alpha <= 0 ) {
					p.mc.removeMovieClip();
					particules.remove(p);
					i--;
				}
			}
			if( particules.length == 0 )
				Manager.updates.remove(particules,f_update_particules);
		}
		f_update_particules = update_particules;
		Manager.updates.push(particules,update_particules);
		Manager.smanager.play(Const.SOUND_EXPLOSE);
		redraw = true;
	}

	function cut(qpos) {
		len -= qpos;
		redraw = true;
	}

	function destroy() {
		tete.removeMovieClip();
		gfx.removeMovieClip();
	}
}
