class Rail {

	var game : Game;
	var pos : int;
	var front : {> MovieClip, t0 : MovieClip, t1 : MovieClip, cruncher : MovieClip };
	var back : {> MovieClip, panel : {> MovieClip, field : TextField, green : MovieClip, red : MovieClip } };
	volatile var speed : float;
	volatile var delta : float;
	var broken : bool;
	volatile var last : int;
	volatile var ncombos : int;

	volatile var next : int;
	var toys : Array<Toy>;
	var cruncher : MovieClip;

	function new(g,p) {
		game = g;
		pos = p;
		last = null;
		delta = 0;
		ncombos = 0;
		broken = false;

		back = downcast(game.dmanager.attach("railBack",0));
		back._x = 300;
		back._y = Const.RAIL_Y_BASE + p * Const.RAIL_Y_DELTA;

		front = downcast(game.dmanager.attach("railFront",2));
		front._x = back._x;
		front._y = back._y;
		front.t0.gotoAndStop("1");
		front.t1.gotoAndStop("2");
		cruncher = front.cruncher;

		updateCounter();
		toys = new Array();
		speed = 50;
		Timer.tmod = 1;
		var i;
		for(i=0;i<5;i++) {
			toys.push(new Toy(game,-1,this,false));
			update();
		}
		speed = (5 + p) * 0.1;
	}

	function updateCounter() {
		var s = string(ncombos);
		while( s.length < 3 )
			s = "0"+s;
		back.panel.field.text = s;
		if( last != null )
			back.panel.field.textColor = Const.COLORS[last];
	}

	function active(t : Toy) {
		if( t.t == -1 )
			return;
		switch( t.t ) {
		case -1:
			return;
		case Const.BONUS_X2:
			game.stats.$b[pos].push(ncombos);
			ncombos *= 2;
			back.panel.green.play();
			back.panel.red.play();
			break;
		case Const.BONUS_PLUS20:
			game.stats.$b[pos].push(-ncombos);
			ncombos += 20;
			back.panel.green.play();
			back.panel.red.play();
			break;
		case Const.BONUS_SPEED:
			game.stats.$s[pos].push(ncombos);
			speed *= Const.SPEED_DELTA;
			if( speed > Const.MAXSPEED )
				speed = Const.MAXSPEED;
			break;
		default:
			if( t.t == last || last == null ) {
				back.panel.green.play();
				ncombos++;
			} else {
				game.stats.$c[pos].push(ncombos);
				back.panel.red.play();
				ncombos = 1;
			}
			KKApi.addScore(KKApi.cmult(Const.C10,KKApi.const(ncombos)));
			last = t.t;
			break;
		}
		if( ncombos > 199 )
			ncombos = 199;
		updateCounter();
	}

	function genType() {
		if( game.time >= Const.GAMETIME )
			return -1;
		if( next != null ) {
			var o = next;
			game.nbonuses++;
			next = null;
			return o;
		}
		return Tools.randomProbas(Const.PROBAS) - 1;
	}

	function update() : bool {
		var i;
		var dx = game.speed * speed * Timer.tmod;

		if( Std.random(int((1000 + game.nbonuses*200)/Timer.tmod)) == 0 )
			next = 4+Tools.randomProbas(Const.PROBAS_OPTIONS);

		if( broken ) {
			speed *= Math.pow(0.97,Timer.tmod);
			if( speed < 0.1 )
				speed = 0;
		}

		if( toys[toys.length-1].x <= 300 )
			toys.push(new Toy(game,genType(),this,false));
		var ok = false;
		cruncher._y = -50;
		for(i=0;i<toys.length;i++) {
			var t = toys[i];
			if( !t.update(dx) )
				toys.splice(i--,1);
			else if( t.t != -1 )
				ok = true;
		}

		delta -= dx;
		front.t0._x = int(-300 + delta % 8);
		front.t1._x = int(-308 - delta % 8);
		return ok;
	}

}