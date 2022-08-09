class Snake {

	// gfx logic
	var gfx : MovieClip;
	var shade : MovieClip;
	var tete : MovieClip;
	var collide_mc : MovieClip;
	var collide_point : { x : float, y : float };
	var queue : Array<{ x : float, y : float }>;
	var dmanager : DepthManager;

	// intern
	var eat : float;
	var old_ang : float;
	var dist : float;
	var dx : float, dy : float;
	var redraw : bool;

	// available
	volatile var base_speed : float;
	var eat_speed : float;
	var x : float;
	var y : float;
	var ang : float;
	volatile var speed : float;
	volatile var len : int;
	var delta_ang : float;

	// objects
	var blue : bool;
	var blue_flag : bool;


	function new( dman, pos ) {
		dmanager = dman;
		shade = dman.empty(Const.PLAN_SNAKE);
		gfx = dman.empty(Const.PLAN_SNAKE);
		tete = dman.attach("tete",Const.PLAN_SNAKE);
		base_speed = 1;
		eat_speed = 1;
		queue = new Array();
		collide_mc = Std.getVar(tete,"col");
		collide_mc._visible = false;
		x = pos.x;
		y = pos.y;
		dx = 0;
		dy = 0;
		ang = 0;
		eat = 0;
		old_ang = -100;
		delta_ang = Const.SNAKE_DEFAULT_TURN;
		speed = Const.SNAKE_DEFAULT_SPEED;
		len = Const.SNAKE_DEFAULT_LENGTH;
		dist = 0;
		redraw = true;

		var i;
		for(i=0;i<50;i++)
			queue.push(pos);

	}

	function endQueuePos(delta) {
		return queue[int(Math.max(0,queue.length - len * Const.SNAKE_QUEUE_ELT_SIZE + delta))];
	}

	function move( bounds ) {



		var tmod = Timer.tmod;
		var hit = false;

		if( Std.random(Math.round(100/tmod)) == 0 ) {
			downcast(tete).o1.play();
			downcast(tete).o2.play();
		}

		if( eat > 0 ) {
			eat -= eat_speed * tmod/2;
			redraw = true;
		}

		if( old_ang != ang ) {
			ang -= int(ang / (Math.PI * 2)) * Math.PI * 2;
			old_ang = ang;
			dx = Math.cos(ang);
			dy = Math.sin(ang);
		}

		var speed = this.speed * tmod * base_speed;

		var esize = Const.SNAKE_QUEUE_ELT_SIZE;
		var ds = Math.min(esize*1.5+len,3*esize);
		var col_pt = { x : x + dx*ds, y : y + dy*ds };
		var ncols = int(speed/esize)+1;

		while( ncols > 0 ) {
			ncols--;
			var delta_speed = ((ncols > 0)?esize:(speed%esize));
			col_pt.x += dx * delta_speed;
			col_pt.y += dy * delta_speed;
			if( !blue && gfx.hitTest(col_pt.x,col_pt.y,true) ) {
				eat = 0;
				hit = true;
				break;
			}
		}

		x += dx*speed;
		y += dy*speed;

		dist += speed/esize;
		var curp = { x : x, y : y };
		while( dist >= 1 ) {
			dist--;
			queue.push(curp);
			redraw = true;
		}

		var px = col_pt.x;
		var py = col_pt.y;
		if( px < bounds.left || py < bounds.top || px > bounds.right || py > bounds.bottom ) {
			eat = 0;
			hit = true;
		}
		collide_point = col_pt;
		return hit;
	}

	function hit(pt) {
		return gfx.hitTest(pt.x,pt.y,true) || tete.hitTest(pt.x,pt.y,true);
	}

	function draw() {
		var scale = Math.min(10,len+3) / 20;

		tete._x = x;
		tete._y = y;
		tete._rotation = ang*180/Math.PI;
		tete._xscale = 30 + 70 * scale;
		tete._yscale = 30 + 70 * scale;

		if( !redraw )
			return;

		redraw = false;

		gfx.clear();
		shade.clear();
		var tmp = gfx;
		gfx = shade;
		drawQueue(scale,0xB7EF7C,8,4);
		gfx = tmp;
		drawQueue(scale,getBorderColor(),8,0);
		drawQueue(scale,getColor(),5,0);
		if( blue && blue_flag )
			tete.gotoAndStop("2");
		else
			tete.gotoAndStop("1");
	}

	function getColor() {
		if( blue && blue_flag )
			return Const.COLOR_SNAKE_INVINCIBLE;
		return Const.COLOR_SNAKE_DEFAULT;
	}

	function getBorderColor() {
		if( blue && blue_flag )
			return Const.COLOR_SNAKE_BORDER_INVINCIBLE;
		return Const.COLOR_SNAKE_BORDER_DEFAULT;
	}

	function drawQueue(scale,color,lsize,dy) {
		var n = queue.length-1;
		var p = queue[n], p2;
		var i,s = scale * 15/len,q;
		var eat_flag = (eat > 0);
		var a,c;
		var esize = Const.SNAKE_QUEUE_ELT_SIZE;
		var demi_esize = int(esize/2);

		gfx.moveTo(p.x,p.y+dy);

		if( Timer.tmod < 1.7 ) {
			for(i=len;i>0;i--) {
				p = queue[n-esize];
				p2 = queue[n-demi_esize];
				if( eat_flag )
					q = Math.max(1,2-(i-eat)*(i-eat)/2);
				else
					q = 1;
				gfx.lineStyle( i*s*q+lsize, color, 100 );
				gfx.curveTo(p2.x,p2.y+dy,p.x,p.y+dy);
				n-=esize;
			}
		} else {
			for(i=len;i>0;i--) {
				n-=esize;
				p = queue[n];
				if( eat_flag )
					q = Math.max(1,2-(i-eat)*(i-eat)/2);
				else
					q = 1;
				gfx.lineStyle( i*s*q+lsize, color, 100 );
				gfx.lineTo(p.x,p.y+dy);
			}
		}
	}

	function addQueue() {
		queue.splice(0,int(Math.max(0,queue.length-len*Const.SNAKE_QUEUE_ELT_SIZE-1)));
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
		var p1 = Std.cast(endQueuePos(delta));
		var p2;
		do {
			p2 = Std.cast(endQueuePos(delta++));
		} while( p1 == p2 && delta < 20 );

 		queue.splice(0,int(Math.max(0,queue.length-len*Const.SNAKE_QUEUE_ELT_SIZE-1)));
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

	function explode(rgb) {
		var pos = queue[queue.length - (len * Const.SNAKE_QUEUE_ELT_SIZE)];
		len--;
		var particules = new Array();
		var i;
		for(i=0;i<10;i++) {
			var p = dmanager.attach("qparticule",Const.PLAN_PARTICULES);
			var ang = Std.random(180) / Math.PI;
			var speed = 1 + Std.random(100) / 100;
			var c = new Color(p);
			c.setRGB(rgb);
			p._xscale = tete._xscale;
			p._yscale = tete._yscale;
			p._x = pos.x;
			p._y = pos.y;
			particules.push({ mc : p, ang : ang, speed : speed });
		}
		var fupdate;
		fupdate = fun() {
			for(i=0;i<particules.length;i++) {
				var p = particules[i];
				var s = p.speed * Timer.tmod;
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
				Manager.updates.remove(fupdate);
		};
		Manager.updates.push(fupdate);
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
