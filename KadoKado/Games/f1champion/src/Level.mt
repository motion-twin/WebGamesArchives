class Level {

	static var DELTA = 300;

	var game : Game;
	var dmanager : DepthManager;
	var scroll : MovieClip;
	var bg : MovieClip;
	var middle : MovieClip;
	var middle_mask : MovieClip;
	var walls : MovieClip;
	var walls_mask : MovieClip;

	volatile var pos : float;
	volatile var cur_speed : float;
	var points_up : Array<{ x : float, y : float, tx : float, ty : float }>;
	var points_down : Array<{ x : float, y : float, tx : float, ty : float }>;

	var wallspacing : float;
	var amplitude : float;
	var frequency : { min : float, max : float };
	volatile var speed : float;

	function new(g) {
		this.game = g;

		pos = 0;
		speed = Const.MINSPEED;
		cur_speed = 0;
		amplitude = 40;
		wallspacing = 110;
		frequency = { min : 150, max : 200 };

		scroll = game.dmanager.empty(Const.PLAN_BG);
		dmanager = new DepthManager(scroll);
		bg = dmanager.attach("bg",0);
		middle = dmanager.attach("tex1",0);
		middle_mask = dmanager.empty(0);
		middle.setMask(middle_mask);
		walls = dmanager.attach("tex2",0);
		walls_mask = dmanager.empty(0);
		walls.setMask(walls_mask);

		points_up = new Array();
		points_down = new Array();

		initLevel();
	}

	function initLevel() {
		genLevel();
		drawLevel(middle_mask,false);
		drawLevel(walls_mask,true);
	}

	function genLevel() {

		var i;
		var n = 0;
		for(i=0;i<points_up.length;i++) {
			var p = points_up[i];
			if( p.y > DELTA )
				n = i;
			p.y += DELTA;
		}
		points_up.splice(0,n);

		var pstart = points_up.length;
		n = 0;
		for(i=0;i<points_down.length;i++) {
			var p = points_down[i];
			if( p.y > DELTA )
				n = i;
			p.y += DELTA;
		}
		points_down.splice(0,n);

		var fmin = frequency.min;
		var fampl = int(frequency.max - frequency.min);
		var ampl = 40;

		var y = 650 + fmin;

		if( points_up[points_up.length-1].y < y )
			y = points_up[points_up.length-1].y;
		if( points_down[points_down.length-1].y < y )
			y = points_down[points_down.length-1].y;

		y -= fmin;

		var space = 150 - wallspacing;
		var delta = 0;

		if( Std.random(3) == 0 )
			delta = (Std.random(0)==0)?(wallspacing-140):(140-wallspacing);

		if( Std.random(5) == 0 ) {
			ampl = int(Math.min(100 * cur_speed / Const.MINSPEED,150));
			space = 40;
			delta = 0;
		}

		while( true ) {
			var dy = fmin + Std.random(fampl);
			var p = {
				x : delta + space + Std.random(ampl),
				y : y,
				tx : 0//Std.random(500)/25 - 1,
				ty : -dy / (3 + Std.random(30)/20)
			};
			points_up.push(p);
			if( y < 0 )
				break;
			y -= dy;
		}

		for(i=pstart;i<points_up.length;i++) {
			var p = points_up[i];
			var p2 = {
				x : p.x + (Const.WIDTH - space * 2 - ampl),
				y : p.y,
				tx : p.tx,
				ty : p.ty
			};
			points_down.push(p2);
		}

	}

	function point(mc,x,y,color) {
		mc.moveTo(x,y);
		mc.lineStyle(5,color,100);
		mc.lineTo(x+0.5,y+0.5);
	}

	function curve(mc,p1,p2) {
		var c1x = p1.x + p1.tx;
		var c1y = p1.y + p1.ty;
		var c2x = p2.x - p2.tx;
		var c2y = p2.y - p2.ty;

		var cx = (p2.x + p1.x) / 2;
		var cy = (p2.y + p1.y) / 2;

		mc.curveTo(c1x,c1y,cx,cy);
		mc.curveTo(c2x,c2y,p2.x,p2.y);
	}

	function drawLevel(mc,a) {
		var i;
		mc.clear();
		mc.beginFill(0,50);
		mc.moveTo(0,points_up[0].y);
		mc.lineTo(points_up[0].x,points_up[0].y);

		if( a ) {
			for(i=1;i<points_up.length;i++) {
				var p1 = points_up[i-1];
				var p2 = points_up[i];
				p1 = { x : p1.x - 4, y : p1.y, tx : p1.tx, ty : p1.ty };
				p2 = { x : p2.x - 4, y : p2.y, tx : p2.tx, ty : p2.ty };
				curve(mc,p1,p2);
			}
		} else {
			for(i=1;i<points_up.length;i++)
				curve(mc,points_up[i-1],points_up[i]);
		}

		mc.lineTo(0,points_up[i-1].y);
		mc.lineTo(0,points_up[0].y);
		mc.endFill();

		mc.beginFill(0,50);
		mc.moveTo(Const.WIDTH,points_down[0].y);
		mc.lineTo(points_down[0].x,points_down[0].y);

		if( a ) {
			for(i=1;i<points_down.length;i++) {
				var p1 = points_down[i-1];
				var p2 = points_down[i];
				p1 = { x : p1.x + 4, y : p1.y, tx : p1.tx, ty : p1.ty };
				p2 = { x : p2.x + 4, y : p2.y, tx : p2.tx, ty : p2.ty };
				curve(mc,p1,p2);
			}
		} else {
			for(i=1;i<points_down.length;i++)
				curve(mc,points_down[i-1],points_down[i]);
		}
		mc.lineTo(Const.WIDTH,points_down[i-1].y);
		mc.lineTo(Const.WIDTH,points_down[0].y);
		mc.endFill();
	}

	function main() {
		if( Timer.tmod > 10 )
			Timer.tmod = 10;

		if( wallspacing > 50 )
			wallspacing -= 0.01 * Timer.tmod;

		speed += 0.002 * Timer.tmod;
		var ps = Math.pow(0.96,Timer.tmod);
		cur_speed = cur_speed * ps + (1 - ps) * speed;
		if( cur_speed > 22 )
			cur_speed = 22;
		var dp = cur_speed * Timer.tmod;
		pos += dp;
		if( pos > DELTA ) {
			game.chkdata.$n++;
			while( pos > DELTA )
				pos -= DELTA;			
			initLevel();
		}
		scroll._y = pos - DELTA;
		return dp;
	}

}