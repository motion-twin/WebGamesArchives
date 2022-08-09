class Hero {

	var game : Game;
	var ploc : MovieClip;
	var mc : {> MovieClip, col : MovieClip };
	var x : float;
	var y : float;
	volatile var speed : float;
	var wait_tir : float;
	var tang : float;
	var ang : float;
	volatile var tspeed : float;
	volatile var pow : int;
	volatile var bonus_time : float;

	function new(g) {
		game = g;
		wait_tir = 0;
		mc = downcast(game.dmanager.attach("hero",Const.PLAN_HERO));
		x = 150;
		y = 150;
		ang = 0;
		pow = 1;
		tang = 0;
		speed = 3.5;
		tspeed = 8;
		bonus_time = 0;
	}

	function genTir() {
		var t = new Tir(game,0,x,y,Math.cos(tang)*tspeed,Math.sin(tang)*tspeed);
		game.tirs.push(t);
		ploc = game.dmanager.attach("plop",Const.PLAN_HERO);
		ploc._x = x;
		ploc._y = y;
		if( pow == 2 ) {
			t.mc.gotoAndStop("4");
			t.pow = 2;
		} else if( bonus_time > 0 ) {
			setColor(t.mc,0xFF0000);
			setColor(ploc,0xFF0000);
		}
		if( tang <= 0 )
			ploc.gotoAndStop(string(int(-tang * 4/Math.PI) + 1));
		else
			ploc.gotoAndStop(string(5 + int((-tang + Math.PI) * 4/Math.PI)));
	}

	function moyAng(a,b) {
		if( Math.abs(a - b) > Math.PI ) {
			if( b < a )
				b += Math.PI * 2;
			else
				b -= Math.PI * 2;
		}
		var p = Math.pow(0.7,Timer.tmod);
		a = a * p + b * (1 - p);
		while( a <= Math.PI )
			a += Math.PI * 2;
		while( a > Math.PI )
			a -= Math.PI * 2;
		return a;
	}

	function setColor(mc,col) {
		var c = new Color(mc);
		c.setTransform({
			ra : 100, 
			rb : col >> 16,
			ga : 100,
			gb : (col >> 8) & 0xFF,
			ba : 100,
			bb : (col & 0xFF),
			aa : 100,
			ab : 0
		});
	}

	function update() {
		var dx = 0, dy = 0;
		
		if( Key.isDown(Key.LEFT) )
			dx--;
		if( Key.isDown(Key.RIGHT) )
			dx++;
		if( Key.isDown(Key.UP) )
			dy--;
		if( Key.isDown(Key.DOWN) )
			dy++;

		if( bonus_time > 0 ) {
			bonus_time -= Timer.deltaT;
			if( bonus_time <= 0 ) {
				speed = 3;
				pow = 1;
				setColor(mc,0);
			}
		}

		if( dx != 0 || dy != 0 ) {
			var d = Timer.tmod * speed / Math.sqrt(dx*dx+dy*dy);
			if( !Key.isDown(Key.SPACE) && !Key.isDown(Key.CONTROL) )
				tang = Math.atan2(dy,dx);			
			x += dx * d;
			y += dy * d;
			ploc._x += dx * d;
			ploc._y += dy * d;
		}
		
		if( x < 15 )
			x = 15;
		if( y < 20 )
			y = 20;
		if( x > 285 )
			x = 285;
		if( y > 290 )
			y = 290;

		ang = moyAng(ang,tang);
		if( ang < 0 )
			mc.gotoAndStop(string(int(-ang * 30/Math.PI) + 1));
		else
			mc.gotoAndStop(string(31 + int((-ang + Math.PI) * 30/Math.PI)));

		if( wait_tir > 0 )
			wait_tir -= Timer.deltaT;
		else if( Key.isDown(Key.SPACE) || Key.isDown(Key.CONTROL) ) {
			wait_tir = 0.2 / pow;
			genTir();
		}

		var i;
		for(i=0;i<game.monsters.length;i++) {
			var m = game.monsters[i];
			if( Std.hitTest(mc.col,m.mc.sub.col) )
				return false;
		}
		for(i=0;i<game.bonus.length;i++) {
			var b = game.bonus[i];
			b.time -= Timer.deltaT;
			if( Std.hitTest(mc.col,b) ) {
				game.stats.$b[b.t]++;
				switch( b.t ) {
				case 3:
					setColor(mc,0xFF0000);
					speed = 7;
					bonus_time += 8;
					break;
				case 4:
					pow = 2;
					bonus_time += 5;
					break;
				case 0:
				case 1:
				case 2:
					KKApi.addScore(Const.BONUS_POINTS[b.t]);
					break;
				}
				b.removeMovieClip();
				game.bonus.splice(i--,1);
			} else if( b.time < 0 ) {
				b._xscale -= 10 * Timer.tmod;
				b._yscale = b._xscale;
				if( b._xscale < 0 ) {
					b.removeMovieClip();
					game.bonus.splice(i--,1);
				}
			}
		}

		mc._x = x;
		mc._y = y;
		return true;
	}

}