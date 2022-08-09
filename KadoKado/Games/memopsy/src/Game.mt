class Game {

	var dmanager : DepthManager;
	var level : Array<Array<Card>>;
	var life : Array<MovieClip>;
	var oldlife : Array<MovieClip>;
	var bg_mc : MovieClip;
	var bg_speed : float;
	var current : Card;
	volatile var maxpairs : int;
	volatile var npairs : int;
	volatile var nlevel : int;
	volatile var nmiss : int;
	var lock : int;

	volatile var time : float;
	volatile var pair_time : float;
	var times : Array<int>;

	function new( mc ) {
		dmanager = new DepthManager(mc);
		dmanager.attach("bg",Const.PLAN_BG);
		bg_speed = 0;
		bg_mc = dmanager.attach("bgAnim",Const.PLAN_BG);
		bg_mc._x = 150;
		bg_mc._y = 150;
		time = 0;
		lock = 0;
		nlevel = 0;
		nmiss = 0;
		pair_time = 0;
		times = new Array();		
		initLevel();
		initLife();
	}

	function shuffle(tbl) {
		var l = tbl.length;
		var i;
		for(i=0;i<l;i++) {
			var a = Std.random(l);
			var b = Std.random(l);
			var s = tbl[a];
			tbl[a] = tbl[b];
			tbl[b] = s;
		}
	}

	function getLevel() {
		var l = (nlevel >= Const.LEVELS.length)?(Const.LEVELS.length - 1):nlevel;
		return Const.LEVELS[l];
	}

	function initLevel() {
		var x,y;
		var ids = new Array();
		var l = getLevel();
		var w = l.width;
		var h = l.height;
		var i;

		npairs = int(w * h / 2);
		maxpairs = npairs;

		for(i=0;i<npairs;i++) {
			var id = i % Const.NUMCARDS;
			ids.push(id);
			ids.push(id);
		}
		shuffle(ids);

		var n = 0;
		level = new Array();
		for(x=0;x<w;x++) {
			level[x] = new Array();
			for(y=0;y<h;y++)
				level[x][y] = new Card(this,ids[n++],x,y);
		}
	}

	function destroyLevel() {
		var x,y;
		var l = getLevel();
		for(x=0;x<l.width;x++)
			for(y=0;y<l.height;y++)
				level[x][y].destroy();
	}

	function initLife() {
		var i;
		life = new Array();
		oldlife = new Array();
		for(i=0;i<Const.MAXLIFE;i++)
			addLife();
		for(i=0;i<Const.MAXLIFE-Const.STARTLIFE;i++)
			looseLife();
	}

	function addLife() {
		if( life.length == Const.MAXLIFE )
			return;

		if( oldlife.length == 0 ) {
			var l = dmanager.attach("life",Const.PLAN_LIFE);
			var x = 150 - 0.5 * Const.MAXLIFE * (l._width+1) ;
			l._x = x + life.length * (l._width+1);
			l._y = 2;
			l.stop();
			life.push(l);
		} else {
			var l = oldlife.shift();
			l.gotoAndStop("1");
			oldlife.remove(l);
			life.push(l);
		}
	}

	function looseLife() {
		var l = life[life.length-1];
		life.remove(l);
		l.gotoAndStop("2");
		oldlife.unshift(l);
		if( life.length == 0 ) {
			gameOver();
			return;
		}
	}

	function cardSelect(c) {
		if( lock > 1 || c.visible )
			return;
		if( lock == 1 && current != null )
			return;
		lock++;
		c.show(true);
	}

	function bonusTime() {
		var t = int(time+1);
		//KKApi.addScore( int(1000 * npairs /t) );
		//times.push(t);
		time = 0;
	}	

	function bonusPair() {
		
		var t = int(Math.min(pair_time,Const.POINTS.length-1));
		if( t < 0 )
			t = 0;
		KKApi.addScore( Const.POINTS[t] );
		times.push(t);
		pair_time = -0.3;
		nmiss = 0;
	}

	function gameOver() {
		KKApi.gameOver({$l : nlevel, $t : times });
		lock = 99;
	}

	function onShowDone(c) {
		lock--;
		if( c.visible ) {
			if( current == null )
				current = c;
			else {
				if( current.id != c.id ) {
					current.show(false);
					c.show(false);
					lock += 2;
					looseLife();
					nmiss++;
				} else {
					npairs--;
					bonusPair();
					nmiss = 0;
					if( npairs == 0 ) {
						var i;
						for(i=0;i<5;i++)
							addLife();
						destroyLevel();
						nlevel++;
						initLevel();
						bonusTime();
					} else {
						explode(current.mcface._x, current.mcface._y) ;
						explode(c.mcface._x, c.mcface._y) ;
					}
				}
				current = null;
			}
		}
	}


	function explode(x,y) {
		var fx = dmanager.attach("good",Const.PLAN_FX) ;
		fx._x = x ;
		fx._y = y ;
	}


	function main() {
		time += Timer.deltaT;
		pair_time += Timer.deltaT;
		bg_speed = bg_speed * 0.95 + (npairs + 1) * 0.05;
		bg_mc._rotation += Timer.tmod * bg_speed;
		Card.main(this);

	}

	function destroy() {
		dmanager.destroy();
	}
}