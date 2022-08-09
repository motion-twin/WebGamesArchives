class Game {//}

	var animator : Animator;
	var dmanager : DepthManager;	
	var level : Level;
	var hero : Hero;
	var bg : MovieClip;
	var game_over_flag : bool;
	volatile var time : float;
	volatile var maxtime : float;
	var game_over : bool;
	var stats : {
		$l : int,
		$g : Array<int>,
		$b1 : int,
		$b2 : int,
		$c : Array<int>
	};
	var nlegs : KKConst;
	volatile var combo_phase : int;
	var hscombo : Array<Legume>; // out screen combo
	volatile var level_count : int;

	function new( mc : MovieClip ) {
		dmanager = new DepthManager(mc);
		bg = dmanager.attach("bg",Const.PLAN_BG);
		animator = new Animator(this);
		level = new Level(this);
		hero = new Hero(this);
		hscombo = new Array();
		maxtime = 15;
		level_count = 0;
		time = maxtime;
		nlegs = Const.NLEGS;
		stats = {
			$b1 : 0,
			$b2 : 0,
			$c : new Array(),
			$g : [0,0,0,0,0],
			$l : 0,
		};
		init();
		main();
	}

	function randId() {
		var n = KKApi.val(nlegs);
		var id = Std.random(n);
		if( Std.random(10) == 0 ) {
			id = Const.BULLE + Tools.randomProbas([25,25,2]);
			if( id == Const.BULLE+2 )
				id = Std.random(n) + Const.GOLD;
		}
		return id;
	}

	function init() {
		var i;
		for(i=0;i<3;i++)
			level.genLine();
	}

	function explode() {

		if( game_over )
			return;

		var i,j;
		var bulles = level.explodeBulles();
		for(i=0;i<bulles.length;i++)
			animator.explodeLegume(bulles[i]);

		if( bulles != null )
			return;

		var g = level.gravity();
		for(i=0;i<g.length;i++)
			animator.gravity(g[i]);
		if( g != null )
			return;
		
		var expl = level.explodes();
		var combos = expl.combos;
		var s = 0;
		if( hscombo.length > 0 ) {
			hscombo.push(null);
			hscombo.push(null);
			combos.push(hscombo);
		}
		hscombo = new Array();
		for(i=0;i<combos.length;i++) {
			var c = combos[i];
			for(j=0;j<c.length;j++)
				animator.explodeLegume(c[j]);
			stats.$c.push(c.length + combo_phase * 1000);
			var pts = int(c.length * (combo_phase+1)) * KKApi.val(Const.C100);
			s += pts;
			KKApi.addScore(KKApi.const(pts));
		}

		if( s > 0 ) {
			var fs = downcast(dmanager.attach("fieldScore",Const.PLAN_INTERF));
			fs._x = 300;
			fs.score = s;
		}
	
		if( combos.length > 0 ) {
			combo_phase++;
			time-=0.3;
		}
	}

	function main() {
		animator.main();
		if( game_over ) {
			var ntrys = 100;
			while( --ntrys > 0 ) {
				var x = Std.random(Const.WIDTH);
				var y = Std.random(Const.HEIGHT);
				var l = level.legumes[x][y];
				if( l == null )
					continue;
				level.legumes[x][y] = null;
				animator.destroyLegume(l);
				return;
			}
			var x,y;
			for(x=0;x<Const.WIDTH;x++)
				for(y=0;y<Const.HEIGHT;y++) {
					animator.destroyLegume(level.legumes[x][y]);
					level.legumes[x][y] = null;
				}

			stats.$l = level_count;
			KKApi.gameOver(stats);
			return;
		}

		hero.main();
		var h = level.maxHeight();
		time -= Timer.deltaT * (30 / (h * (1+h)));

		if( h >= 8 && !animator.locked(true) )
			game_over = true;

		if( time < 0 && !animator.locked(true) ) {
			level.genLine(); 
			time = maxtime;
			level_count++;
			maxtime *= 0.97;
			if( KKApi.val(nlegs) < 5 && level_count % 15 == 0 )
				nlegs = KKApi.cadd(nlegs,KKApi.const(1));
		}
	}
//{
}