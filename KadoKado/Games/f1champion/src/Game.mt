class Game {

	var mc : MovieClip;
	var dmanager : DepthManager;
	var level : Level;
	var f1 : MovieClip;
	var shadow : MovieClip;
	var life : MovieClip;
	var speed : MovieClip;
	var trail_mc : MovieClip;
	var expl_mc : MovieClip;
	var options : Array<{ id : int , mc : MovieClip}>;
	var trails : Array<Array<{ x : float, y : float, c : int }>>;
	var parts : Array<{ mc : MovieClip, sx : float, sy : float, sr : float, ay : float, ss : float }>;

	var chkdata : {
		$n : int,
		$b : Array<int>
	};

	volatile var pos : float;
	volatile var delta : float;
	volatile var lifepts : float;
	var lock : bool;
	volatile var score : float;
	volatile var oil_time : float;

	function new(mc) {
		this.mc = mc;
		dmanager = new DepthManager(mc);
		shadow = dmanager.attach("shadow",Const.PLAN_F1);
		shadow._xscale = Const.CAR_SCALE ;
		shadow._yscale = Const.CAR_SCALE ;
		shadow._alpha = 10 ;
		f1 = dmanager.attach("f1",Const.PLAN_F1);
		f1._xscale = Const.CAR_SCALE ;
		f1._yscale = Const.CAR_SCALE ;
		trail_mc = dmanager.empty(Const.PLAN_TRAIL);
		life = dmanager.attach("life",Const.PLAN_INTERFACE);
		life._x = Const.WIDTH-life._width-5;
		life._y = Const.HEIGHT-30;
		lifepts = Const.MAXLIFE;
		oil_time = 0;
		speed = dmanager.attach("speed",Const.PLAN_INTERFACE);
		speed._x = life._x ;
		speed._y = life._y - 16 ;
		pos = 150;
		delta = 0;
		score = 0;
		trails = [[],[],[],[]];
		chkdata =  { $n : 0, $b : [0,0,0,0] };
		parts = new Array();
		options = new Array();
		level = new Level(this);
		updateInterf();
	}

	function updateInterf() {
		downcast(life).mask._xscale = 100 * lifepts / Const.MAXLIFE;
		downcast(speed).speed.text = int(Math.pow(level.cur_speed,0.75) * 30)+" KM/H";
	}

	function slowDown() {
		if( level.cur_speed > level.speed / 2 )
			level.cur_speed *= Math.pow(0.98,Timer.tmod);
	}

	function updateF1() {
		var max = 4;
		var time = Timer.tmod * level.speed / 5;
		var dd = (oil_time > 0)?0.15:0.2;

		if( !lock ) {
			if( Key.isDown(Key.LEFT) ) {
				delta -= dd * time;
				if( delta < -max )
					delta = -max;
				else
					slowDown();
			} else if( Key.isDown(Key.RIGHT) ) {
				delta += dd * time;
				if( delta > max )
					delta = max;
				else
					slowDown();
			} else if( Key.isDown(Key.UP) )
				level.cur_speed += 1;
		}
		delta += 0.05 * time * (Const.MAXLIFE - lifepts) / Const.MAXLIFE * ((Std.random(2) == 0)?-1:1);
		delta *= Math.pow((oil_time <= 0)?0.95:1.005,time);
		if( delta > 4 )
			delta = 4;
		else if( delta < -4 )
			delta = -4;
		pos += delta * time;
		if( pos < 5 )
			pos = 5;
		else if( pos > 295 )
			pos = 295;
		f1._rotation = delta * 15;
		f1._x = pos;
		f1._y = 250 + (level.speed - level.cur_speed) * 2;
		shadow._x = f1._x + Const.SHADOW_X;
		shadow._y = f1._y + Const.SHADOW_Y;
		shadow._rotation = f1._rotation;
	}

	function updateTrails(delta) {
		var i;		
		var c = (oil_time > 0)?30:((Math.abs(f1._rotation) > 30)?10:0);

		if( f1._name != null ) {
			var p1 = downcast(f1).dr.getBounds(mc);
			var p2 = downcast(f1).dl.getBounds(mc);
			var p3 = downcast(f1).ur.getBounds(mc);
			var p4 = downcast(f1).ul.getBounds(mc);
			trails[0].unshift({
				x : (p1.xMin + p1.xMax) / 2,
				y : (p1.yMin + p1.yMax) / 2,
				c : c
			});
			trails[1].unshift({
				x : (p2.xMin + p2.xMax) / 2,
				y : (p2.yMin + p2.yMax) / 2,
				c : c
			});
			trails[2].unshift({
				x : (p3.xMin + p3.xMax) / 2,
				y : (p3.yMin + p3.yMax) / 2,
				c : c
			});
			trails[3].unshift({
				x : (p4.xMin + p4.xMax) / 2,
				y : (p4.yMin + p4.yMax) / 2,
				c : c
			});
		}

		trail_mc.clear();

		var n;
		c = null;
		for(n=0;n<trails.length;n++) {
			var tr = trails[n];
			var p = tr[0];
			trail_mc.moveTo(p.x,p.y);
			for(i=1;i<tr.length;i++) {
				p = tr[i];
				p.y += delta;
				if( c != p.c ) {
					c = p.c;
					trail_mc.lineStyle(3,4,p.c);
				}
				trail_mc.lineTo(p.x,p.y);
				if( p.y > 300 )
					break;
			}
			tr.splice(i,tr.length-i);
		}
	}

	static var BONUS = KKApi.aconst([200,500,1000]);

	function getOption(id) {		
		switch( id ) {
		case 0:
			lifepts += 20;
			if( lifepts > Const.MAXLIFE )
				lifepts = Const.MAXLIFE;  
			break;
		case 1:
		case 2:
		case 3:
			var mc = dmanager.attach("popScore",Const.PLAN_INTERFACE);
			mc._x = f1._x;
			mc._y = f1._y;
			downcast(mc).sub.field.text = KKApi.val(BONUS[id-1]);
			KKApi.addScore(BONUS[id-1]);
			chkdata.$b[id]++;
			break;
		case 4:
			chkdata.$b[0]++;
			oil_time += 2+Std.random(200)/100;
			break;
		}
	}

	function updateOptions(delta) {
		var i;
		for(i=0;i<options.length;i++) {
			var o = options[i];
			o.mc._y += delta;			
			if( Std.hitTest(o.mc,f1) ) {
				getOption(o.id);
				o.mc._y = 600;
			}
			if( o.mc._y > 320 ) {
				o.mc.removeMovieClip();
				options.splice(i--,1);
			}
		}
		if( level.pos < Level.DELTA - 25 && Std.random(int(Const.OPTIONS_PROBA*(options.length/5+1)/Timer.tmod)) == 0 ) {			
			var ntries = 20;
			var y = -10;
			var x;
			do {
				x = 30+Std.random(240);
				if( !level.middle.hitTest(x-15,y,true) &&
					!level.middle.hitTest(x+15,y,true) &&
					!level.middle.hitTest(x,y-15,true) &&
					!level.middle.hitTest(x,y+15,true) )
					break;
			} while( --ntries > 0 ); 
			if( ntries == 0 )
				return;
			var mc = dmanager.attach("option",Const.PLAN_OPTION);
			var sum = 0;
			var id;

			for(id=0;id<Const.OPTIONS.length;id++)
				sum += Const.OPTIONS[id];

			sum = Std.random(sum);

			id = 0;
			while( sum >= Const.OPTIONS[id] )
				sum -= Const.OPTIONS[id++];

			if( id == 0 && lifepts == Const.MAXLIFE ) {
				mc.removeMovieClip();
				return;
			}
			
			mc._x = x;
			mc._y = y;
			if( id == 4 )
				mc.gotoAndStop(string(Std.random(3)+5));
			else
				mc.gotoAndStop(string(id+1));
			options.push({ id : id, mc : mc });
		}
	}

	function genParticules() {
		var mc = dmanager.attach("part",Const.PLAN_PART);
		mc._x = f1._x;
		mc._y = f1._y + 10;		
		mc._xscale = 25 + Std.random(40);
		mc._yscale = mc._xscale;
		mc._rotation = Std.random(360);
		new Color(mc).setRGB(0x224400);
		mc.gotoAndStop("3");
		parts.push({
			mc : mc
			sx : Std.random(8) - 4
			sy : -(3+Std.random(30)/10)
			ay : 0.95
			ss : 0
			sr : 10
		});
	}

	function genSmoke() {
		var sx = (Std.random(8) - 4) / 5;
		var i;
		for(i=0;i<3;i++) {
			var mc = dmanager.attach("part",Const.PLAN_PART);
			mc.gotoAndStop("1");
			mc._x = f1._x + Std.random(10) - 5;
			mc._y = f1._y + Std.random(10) - 5;
			mc._xscale = 60 + Std.random(40);
			mc._yscale = mc._xscale;
			mc._rotation = Std.random(360);
			mc._alpha = 30;
			parts.push({
				mc : mc
				sx : sx 
				sy : -(5 * level.speed / Const.MINSPEED)
				ay : 1
				ss : 3
				sr : 30
			});
		}
	}

	function updateParticules(delta) {
		var i;
		for(i=0;i<parts.length;i++) {
			var p = parts[i];
			p.sy *= Math.pow(p.ay,Timer.tmod);
			p.mc._xscale += p.ss * Timer.tmod;
			p.mc._yscale += p.ss * Timer.tmod;
			p.mc._x += p.sx * Timer.tmod;
			p.mc._y += p.sy * Timer.tmod + delta;
			p.mc._rotation += p.sr * Timer.tmod;
			if( p.mc._y > 310 ) {
				p.mc.removeMovieClip();
				parts.splice(i--,1);
			}
		}
	}

	function main() {
		updateF1();
		var delta = level.main();
		updateTrails(delta);
		updateOptions(delta);
		if( oil_time >= 0 )
			oil_time -= Timer.deltaT;
		if( !lock && level.walls.hitTest(f1._x,f1._y,true) ) {
			lifepts -= Timer.tmod * level.cur_speed / 2;
			var i;
			for(i=0;i<3;i++)
				slowDown();
			genParticules();
			if( lifepts < 0 ) {
				lifepts = 0;
				lock = true;
				oil_time = 0;
				expl_mc = dmanager.attach("explosion",Const.PLAN_PART);
				expl_mc._alpha = 70;
				expl_mc._xscale = Const.CAR_SCALE;
				expl_mc._yscale = Const.CAR_SCALE;
				expl_mc._x = f1._x;
				expl_mc._y = f1._y;
				f1.removeMovieClip();
				shadow.removeMovieClip();
				KKApi.gameOver(chkdata);
			}
		}

		if( !lock && lifepts < Const.MAXLIFE / 2 && Std.random(int(30*(lifepts/Const.MAXLIFE)/Timer.tmod)) == 0 )
			genSmoke();

		expl_mc._y += delta / 3;
		updateParticules(delta);
		updateInterf();
		if( !lock ) {
			score += Timer.tmod * level.cur_speed;
			var ratio = 5
			var s = int(score/ratio);
			score -= s * ratio;
			KKApi.addScore(KKApi.const(s));
		}
	}

	function destroy() {
	}

}