class Game { //}

	var root : MovieClip;
	var hero : Hero;
	var death : MovieClip;
	var game_over : bool;
	var dmanager : DepthManager;
	var entities : PArray<MovieClip>;
	var bonuses : PArray<Bonus>;
	var jamas : PArray<Jama>;
	volatile var nb : int;
	volatile var level : int;
	var dbg : MovieClip;
	var avg_tmod : float;
	var death_y : float;

	var stats : {
		$t : int,
		$l : int,
		$n : int,
		$b : Array<int>,
		$m : Array<int>
	};

	function new(mc) {
		this.root = mc;
		nb = 0;
		level = 0;
		avg_tmod = 0;

		if( Std.random(1000) == 0 )
			Const.BONUS_PROBAS_TBL[2] = 3;

		stats = {
			$t : 0,
			$l : 0,
			$n : 0,
			$b : [0,0,0],
			$m : [0,0,0]
		};
		dmanager = new DepthManager(mc);
		dmanager.attach("bg",0);
		dbg = dmanager.empty(30);
		hero = new Hero(this);
		jamas = new PArray();
		entities = new PArray();
		bonuses = new PArray();
		entities.push(hero.mc);
	}

	function genPlace(r : int,bx) {
		var i;
		var x = bx,y;
		var ntrys = 50;
		var l = entities.length;
		var r2 = r * r;
		while( ntrys-- > 0 ) {
			if( bx == null )
				x = Std.random(300 - r * 2) + r;
			y = Std.random(Const.MAXY - r * 2) + r;
			for(i=0;i<l;i++) {
				var b = entities[i];
				var dx = b._x - x;
				var dy = b._y - y;
				if( dx * dx + dy * dy < r2 )
					break;
			}
			if( i == l )
				return { x : x, y : y };
		}
		return null;
	}

	function kill() {
		if( game_over )
			return;
		game_over = true;
		hero.mc.removeMovieClip();
		death = dmanager.attach("death",Const.PLAN_HERO);
		death._x = hero.x;
		death._y = hero.y - 15;

		death = dmanager.attach("fall",Const.PLAN_HERO);
		death_y = -5;
		death._x = hero.x;
		death._y = hero.y;
		hero.jump_dx = (hero.x < 150)?1:-1;
	}

	function genBonus() {
		var p = genPlace(5+int(Math.sqrt(Const.BONUS_RAY2)),null);
		if( p == null )
			return;
		var t = Tools.randomProbas(Const.BONUS_PROBAS_TBL);
		var b = new Bonus(this,p,t);
		bonuses.push(b);
	}

	function getBonus(b) {
		KKApi.addScore(Const.BONUS_POINTS[b.t]);
		nb++;
		stats.$n++;
		stats.$b[b.t]++;
		if( nb % Const.LEVEL_DELTA == 0 )
			level++;
	}

	function genJama() {
		var w = (Std.random(2) == 0);
		var p = genPlace(40,w?320:-20);
		if( p == null )
			return;
		var t = Tools.randomProbas(Const.JAMA_PROBAS_TBL.slice(0,level+1));
		var j = new Jama(this,p,t);
		stats.$m[t]++;
		jamas.push(j);
	}

	function drawBox(b,x,y) {
		dbg.moveTo(b.xMin+x,b.yMin+y);
		dbg.lineStyle(1,0xFF00FF,100);
		dbg.lineTo(b.xMax+x,b.yMin+y);
		dbg.lineTo(b.xMax+x,b.yMax+y);
		dbg.lineTo(b.xMin+x,b.yMax+y);
		dbg.lineTo(b.xMin+x,b.yMin+y);
	}

	function main() {

		avg_tmod = avg_tmod * 0.99 + Timer.calc_tmod * 0.01;

		dbg.clear();

		if( Key.isDown("$D".charCodeAt(1)) && KKApi.isLocal() )
			Const.DEBUG = !Const.DEBUG;

		if( game_over ) {
			death._x += hero.jump_dx * Timer.tmod;
			death._y += death_y * Timer.tmod;
			death_y += Timer.tmod;
			if( death._y > 330 )  {
				stats.$l = level;
				stats.$t = int(avg_tmod * 100);
				KKApi.gameOver(stats);
				game_over = false;

			}
		}
		else
			hero.main();

		if( bonuses.length < 3 && Std.random(int(Const.BONUS_PROBAS * bonuses.length / Timer.tmod)) == 0 )
			genBonus();

		var l = level;
		if( l >= Const.JAMA_PROBAS.length )
			l = Const.JAMA_PROBAS.length - 1;
		if( jamas.length < 10 && Std.random(int(Const.JAMA_PROBAS[l] * jamas.length / Timer.tmod)) == 0 )
			genJama();

		var i;
		for(i=0;i<bonuses.length;i++)
			if( !bonuses[i].update() )
				bonuses.splice(i--,1);

		for(i=0;i<jamas.length;i++)
			if( !jamas[i].update() )
				jamas.splice(i--,1);

		hero.mc._xscale = hero.way * 100;

		if( entities.getCheat() || bonuses.getCheat() || jamas.getCheat()  )KKApi.flagCheater();
	}

	function destroy() {
	}

//{
}
