class Game {

	var dmanager : DepthManager;
	var parts : Array<{> MovieClip, vx : float, vy : float, x : float, y : float, by : float }>;
	var tirs : Array<Tir>;
	var monsters : Array<Monster>;
	var bonus : Array<{> MovieClip, t : int, time : float }>;
	var bg : MovieClip;
	var hero : Hero;
	volatile var level : int;
	var game_over : bool;
	var last_dead : float;
	volatile var time : float;
	volatile var combo : int;
	var combo_mc : MovieClip;
	var death : MovieClip;
	var stats : {
		$g : Array<int>,
		$k : Array<int>,
		$b : Array<int>,
		$c : Array<int>
	};

	function new(mc) {
		level = 1;
		time = 0;
		combo = 0;
		last_dead = -1000;
		dmanager = new DepthManager(mc);
		bg = dmanager.attach("bg",Const.PLAN_BG);
		hero = new Hero(this);
		tirs = new Array();
		parts = new Array();
		bonus = new Array();
		monsters = new Array();
		stats = {
			$g : [0,0,0],
			$k : [0,0,0],
			$c : [0,0,0,0],
			$b : [0,0,0,0,0,0]
		};
		genMonster();
	}

	function genMonster() {
		var t = 0;
		
		if( level >= 10 )
			t = Tools.randomProbas([3,1]);
		if( level >= 20 )
			t = Tools.randomProbas([1,4]);
		if( level >= 30 )
			t = Tools.randomProbas([3,2,1]);

		stats.$g[t]++;
		var m = new Monster(this,t);
		monsters.push(m);
		level++;
	}

	function gameOver() {
		if( !game_over ) {
			game_over = true;
			death = dmanager.attach("death",Const.PLAN_PART);
			death._x = hero.x;
			death._y = hero.y;
			hero.mc._visible = false;
		}
	}

	function addPart(p) {
		parts.push(p);
	}

	function doCombo() {
		if( time - last_dead < 2.5 ) {
			if( combo < Const.COMBOS.length ) {
				combo_mc.removeMovieClip();
				combo_mc = dmanager.attach("comment",2);
				combo_mc._y = 300;
				downcast(combo_mc).c.gotoAndStop(string(combo+1));
				KKApi.addScore(Const.COMBOS[combo]);
				stats.$c[combo]++;
				combo++;
			}
		} else
			combo = 0;
		last_dead = time;
	}

	function main() {
		time += Timer.deltaT;

		if( game_over && death != null && death._name == null ) {
			death = null;
			KKApi.gameOver(stats);
		}

		if( monsters.length < 6 && Std.random(int(1500 * monsters.length / (Timer.tmod * level))) == 0 )
			genMonster();
		if( !game_over && !hero.update() )
			gameOver();
		var i;
		for(i=0;i<monsters.length;i++)
			if( !monsters[i].update() )
				monsters.splice(i--,1);
		for(i=0;i<tirs.length;i++)
			if( !tirs[i].update() )
				tirs.splice(i--,1);
		for(i=0;i<parts.length;i++) {
			var p = parts[i];
			p.x += p.vx * Timer.tmod;
			p.y += p.vy * Timer.tmod;
			if( p.y > 0 ) {
				p.y *= -1;
				p.vy *= -0.5;
			}
			p._rotation += p.vx * 5 * Timer.tmod;
			p._alpha -= 5;
			if( p._alpha <= 0 ) {
				p.removeMovieClip();
				parts.splice(i--,1);
			}
			p.vy += Timer.tmod;			
			p._x = p.x;
			p._y = p.by + p.y;
		}
		dmanager.compact(Const.PLAN_HERO);
		dmanager.ysort(Const.PLAN_HERO);
	}

	function destroy() {
	}

}