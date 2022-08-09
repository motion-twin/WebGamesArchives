class Game {//}

	static var CHOOSE_WAY = 0;
	static var CHOOSE_SPEED = 1;
	static var IGNITION = 2;
	static var SIMULATE = 3;
	static var GAMEOVER = 5;
	static var FICHE = 6;

	var bar : MovieClip;
	var lines : MovieClip;
	var segs : Array<MovieClip>;
	var cases : Array<{> MovieClip, s : MovieClip }>;
	var dmanager : DepthManager;
	var physics : Physics;
	var ship : Ball;
	var fiche : MovieClip;
	var result : Array<int>
	var balls : Array<Ball>;
	var aspire : Array<Ball>;
	var state : int;
	volatile var carbu : int;
	var timer : float;

	var angle : float;
	var speed : float;
	var speed_time : float;
	var start_time : float;

	var stats : {
		$r : Array<Array<int>>,
		$b : Array<int>,
	};

	function new(mc) {
		Log.setColor(0xFFFFFF);
		// HACK for Ben Gfx
		Std.setGlobal("Mc",{ setColor : fun(mc,t) {
			(new Color(mc)).setTransform(t);
		}});

		stats = {
			$r : [],
			$b : [],
		};

		start_time = 1;
		balls = new Array();
		segs = new Array();
		aspire = new Array();
		physics = new Physics(
			Std.cast(balls),
			Const.FRICTION,
			{ xmin : 0, ymin : Const.MIN_Y, xmax : 300, ymax : 300, coef : Const.BOUNDS_COEF }
		);
		dmanager = new DepthManager(mc);
		lines = dmanager.empty(Const.PLAN_LINE);
		carbu = Const.INIT_CARBU;
		initLevel();
		initBarre();
		updateCarbu();
		physics.start();
		state = CHOOSE_WAY;
	}

	function randomPos(pos) {
		while(true) {
			var x = 30 + Std.random(240);
			var y = Const.MIN_Y + 30 + Std.random(240 - Const.MIN_Y);
			var i;
			for(i=0;i<pos.length;i++) {
				var p = pos[i];
				var dx = p.x - x;
				var dy = p.y - y;
				var d = Math.sqrt(dx * dx + dy * dy);
				if( d < Const.INIT_MIN_DIST )
					break;
			}
			if( i == pos.length )
				return { x : x, y : y };
		}
	}

	function gameOver() {
		KKApi.gameOver(stats);
		state = GAMEOVER;
	}

	function initBarre() {
		cases = new Array();
		bar = dmanager.attach("bar",Const.PLAN_INTERF);
		var i;
		for(i=0;i<Const.MAX_CARBU;i++) {
			var s = downcast(dmanager.attach("square",Const.PLAN_INTERF));
			s._x = 79 + i * 10;
			s._y = 3;
			cases.push(s);
		}
	}

	function updateCarbu() {
		bar.gotoAndStop("carburant");
		var i;
		for(i=0;i<Const.MAX_CARBU;i++) {
			var s = cases[i];
			if( carbu*2 > i )
				s.gotoAndStop("1");
			else
				s.gotoAndStop("2");
			s.s.gotoAndStop("1");
		}
		downcast(bar).fieldMulti.text = "x "+carbu;
	}

	function updateSpeed() {
		bar.gotoAndStop("puissance");
		var i;
		var sp = (speed - Const.MIN_SPEED) * Const.MAX_CARBU / (Const.MAX_SPEED - Const.MIN_SPEED);
		for(i=0;i<Const.MAX_CARBU;i++) {
			var s = cases[i];
			var f = string(Math.round(i*22/Const.MAX_CARBU));
			if( sp > i ) {
				s.gotoAndStop("1");
				s.s.gotoAndStop(f);
			} else {
				s.gotoAndStop("2");
				s.s.gotoAndStop(f);
			}
		}
	}

	function initLevel() {
		var bg = dmanager.attach("bg",0);
		bg.onPress = callback(this,onClick);
		KKApi.registerButton(bg);
		var t = dmanager.attach("trou",0);
		var ts = 70;
		t._y = Const.MIN_Y;
		t._xscale = ts;
		t._yscale = ts;
		t = dmanager.attach("trou",0);
		t._xscale = -ts;
		t._yscale = ts;
		t._x = 300;
		t._y = Const.MIN_Y;
		t = dmanager.attach("trou",0);
		t._xscale = ts;
		t._yscale = -ts;
		t._y = 300;
		t = dmanager.attach("trou",0);
		t._xscale = -ts;
		t._yscale = -ts;
		t._x = 300;
		t._y = 300;

		var i;
		var pos = new Array();
		for(i=0;i<Const.NBALLS+1;i++)
			pos.push(randomPos(pos));
		for(i=0;i<Const.NBALLS+1;i++)
			balls.push(new Ball(this,i,pos[i].x,pos[i].y));
		ship = balls[0];
	}

	function clearLines() {
		var i;
		for(i=0;i<segs.length;i++)
			segs[i].removeMovieClip();
		segs = new Array();
		lines.clear();
	}

	function drawLines() {
		clearLines();
		var totd = Const.MIN_LINE + Const.DELTA_LINE * (Const.MAX_CARBU - carbu);
		var a = ship.mc._rotation * Math.PI / 180;
		var px = ship.x;
		var py = ship.y;
		var alpha = 20;
		lines.moveTo(px,py);
		while( totd > 0 ) {
			lines.lineStyle(Const.BALL_RAY*2,0xFFFFFF,alpha);
			var sx = Math.cos(a);
			var sy = Math.sin(a);
			var m = 1 / 0;
			var d;
			var x = 0;
			var y = 0;

			d = (px - physics.bounds.xmin - ship.r) / -sx;
			if( d > 0.1 && d < m ) {
				m = d;
				x = 1;
				y = 0;
			}

			d = (py - physics.bounds.ymin - ship.r) / -sy;
			if( d > 0.1 && d < m ) {
				m = d;
				x = 0;
				y = 1;
			}

			d = (px - physics.bounds.xmax + ship.r) / -sx;
			if( d > 0.1 && d < m ) {
				m = d;
				x = -1;
				y = 0;
			}

			d = (py - physics.bounds.ymax + ship.r) / -sy;
			if( d > 0.1 && d < m ) {
				m = d;
				x = 0;
				y = -1;
			}

			d = Math.min(m,totd);
			totd -= d;
			px += d * sx;
			py += d * sy;
			lines.lineTo(px,py);
			if( totd > 0 ) {
				var s = dmanager.attach("lineseg",Const.PLAN_LINE);
				s._alpha = alpha * 100 / 20;
				s._x = px;
				s._y = py;
				segs.push(s);
			}

			var k = (1 + physics.bounds.coef) * (x * sx + y * sy);
			sx -= k * x;
			sy -= k * y;
			a = Math.atan2(sy,sx);
			alpha -= 4;
		}
	}

	function onClick() {
		if( start_time >= 0 )
			return;
		switch( state ) {
		case CHOOSE_WAY:
			clearLines();
			state = CHOOSE_SPEED;
			speed_time = 0;
			break;
		case CHOOSE_SPEED:
			state = IGNITION;
			timer = 6
			//GFX
			var mc = dmanager.attach("spark",Const.PLAN_LINE)
			mc._x = ship.x
			mc._y = ship.y
			mc._rotation = ship.mc._rotation
			//
			break;
		case FICHE:
			speed_time = -1;
			break;
		}
	}

	function endFiche() {
		fiche.removeMovieClip();
		carbu--;
		updateCarbu();
		if( carbu == 0 || ship.mc._name == null || balls.length == 1 )
			gameOver();
		else {
			state = CHOOSE_WAY;
		}
	}

	function attachSlot(p,max) {
		var s = Std.attachMC(fiche,"scoreSlot",p);
		s._y = p * 18;
		downcast(s).bord.gotoAndStop(
			(max == 1)?1:((p == 0)?2:((p == max - 1)?3:4))
		);
		return s;
	}

	function initFiche() {
		stats.$r.push(result);
		stats.$b.push(ship.bande);
		if( result.length == 0 ) {
			endFiche();
			return;
		}
		state = FICHE;
		fiche = dmanager.empty(Const.PLAN_INTERF);
		fiche._x = 5;
		fiche._y = Const.MIN_Y + 5;
		var p = 0;
		var i;
		var pts = KKApi.const(0);
		var mult = carbu;

		var max = result.length;
		if( max >= 2 )
			max++;
		if( ship.bande > 0 )
			max++;
		var perfect = (balls.length == 1 && ship.mc._name != null) || (balls.length == 0);
		if( perfect )
			max++;
		for(i=0;i<result.length;i++) {
			var id = result[i];
			var s = attachSlot(p++,max);
			s.gotoAndStop("1");
			downcast(s).pts.text = KKApi.val(Const.POINTS[id]);
			downcast(s).mult.text = "x "+carbu;
			downcast(s).b.stop();
			Ball.initColor(downcast(s).b,id);
			pts = KKApi.cadd(pts,Const.POINTS[id]);
		}
		if( result.length > 1 ) {
			var s = attachSlot(p++,max);
			var m = int(Math.min(result.length,5));
			mult += m;
			s.gotoAndStop(string(m));
		}
		if( ship.bande > 0 ) {
			var s = attachSlot(p++,max);
			var m = int(Math.min(ship.bande,3));
			mult += m + 1;
			s.gotoAndStop(string(5+m));
		}
		pts = KKApi.cmult(pts,KKApi.const(mult));
		if( perfect ) {
			var s = attachSlot(p++,max);
			pts = KKApi.cadd(pts,Const.C5000);
			s.gotoAndStop("9");
		}
		KKApi.addScore(pts);
		speed = -1;
		speed_time = 0;
		fiche._alpha = 0;
	}

	function main() {
		start_time -= Timer.deltaT;
		physics.update(Timer.tmod);
		var i;
		var sim_flag = false;
		for(i=0;i<balls.length;i++) {
			var b = balls[i];
			if( b.update(Timer.tmod) )
				sim_flag = true;
			if( state == SIMULATE && b.hole() ) {
				balls.splice(i--,1);
				aspire.push(b);
				physics.stop();
				physics.start();
			}
		}

		for(i=0;i<aspire.length;i++) {
			var b = aspire[i];
			if( !b.update(Timer.tmod) ) {
				if( b != ship )
					result.push(b.id);
				b.destroy();
				aspire.splice(i--,1);
			} else
				sim_flag = true;
		}

		switch( state ) {
		case CHOOSE_WAY:
			angle = Math.atan2(Std.ymouse() - ship.y,Std.xmouse() - ship.x);
			var tr = angle - ship.mc._rotation / 180 * Math.PI;
			while( tr > Math.PI )
				tr -= 2 * Math.PI;
			while( tr < -Math.PI )
				tr += 2 * Math.PI;
			ship.mc._rotation += (tr * 180 / Math.PI) * Math.pow(0.4,Timer.tmod);
			drawLines();
			break;
		case CHOOSE_SPEED:
			if( Key.isDown(Key.SPACE) ) {
				updateCarbu();
				state = CHOOSE_WAY;
				break;
			}
			speed_time += Timer.tmod / 10;
			speed = (1-Math.abs(Math.sin(speed_time)))*(Const.MAX_SPEED-Const.MIN_SPEED) + Const.MIN_SPEED;
			updateSpeed();
			break;
		case IGNITION:
			timer -= Timer.tmod
			if( timer < 0 ) {
				state = SIMULATE;
				downcast(ship.mc).reacteur.play();
				for(i=0;i<balls.length;i++)
					balls[i].colflag = false;
				ship.bande = 0;
				ship.bandeLast = false;
				result = new Array();
				physics.stop();
				ship.dx = Math.cos(angle) * speed;
				ship.dy = Math.sin(angle) * speed;
				physics.start();
			}
			break;
		case SIMULATE:
			speed = physics.speed(ship);
			updateSpeed();
			ship.colflag = true;
			if( !sim_flag )
				initFiche();
			break;
		case FICHE:
			if( speed_time == 0 ) {
				speed += Timer.tmod / 10;
				if( speed >= 0 ) {
					speed = 0;
					speed_time = 1.5;
				}
			} else if( speed_time > 0 ) {
				speed_time -= Timer.deltaT;
				if( speed_time == 0 )
					speed_time = -1;
			} if( speed_time < 0 ) {
				speed += Timer.tmod / 10;
				if( speed >= 1 )
					endFiche();
			}
			fiche._alpha = (1 - Math.abs(speed)) * 100;
			break;
		case GAMEOVER:
			break;
		}
	}

 	function destroy() {
	}
//{
}
