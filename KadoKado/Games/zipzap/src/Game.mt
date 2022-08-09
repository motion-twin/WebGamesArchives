class Game {

	var bg : MovieClip;
	var dmanager : DepthManager;
	var hero : Hero;
	var bals : PArray<Ballon>;
	volatile var level : int;
	volatile var nblacks : int;
	volatile var time : float;
	volatile var nbals : int;
	var counter : MovieClip;

	volatile var last : int;
	volatile var bcounter : int;
	var have_effect : bool;
	volatile var waitTimer : float;

	var stats : {
		$c : Array<int>,
		$m : int,
	};

	function new( root ) {
		dmanager = new DepthManager(root);
		root.onMouseMove = callback(this,mouse);
		root.onMouseDown = callback(this,press);
		bg = dmanager.attach("bg",Const.PLAN_BG);
		counter = dmanager.attach("compteur",Const.PLAN_INTERF);
		counter._x = 300;
		bals = new PArray();
		time = 0;
		nblacks = 0;
		waitTimer = 0;
		stats = {
			$m : 0,
			$c : [0,0,0,0,0,0],
		};
		hero = new Hero(this);
		level = -1;

		var i;
		nbals = 0;
		for(i=0;i<Const.LEVEL.length;i++)
			nbals += Const.LEVEL[i].n;
		downcast(counter).field.text = string(nbals);

		nextLevel();
	}

	function mouse() {
		hero.ty = bg._ymouse;
	}

	function press() {
		if( hero.moving == null ) {
			waitTimer = 0;
			stats.$m++;
			hero.action();
		}
	}

	function nextLevel() {
		level++;
		if( Const.LEVEL[level] == null )
			KKApi.gameOver(stats);
		else
			initBals(Const.LEVEL[level].n);
	}

	function initBals(n) {
		var i;
		var probas = [1+Std.random(3),1+Std.random(3),1+Std.random(3)];
		for(i=0;i<n;i++) {
			var b = new Ballon(this,Tools.randomProbas(probas));
			bals.push(b);
		}
	}

	function getBallon(b) {
		if( b.t == last )
			bcounter++;
		else {
			bcounter = 1;
			last = b.t;
		}
		if( b.t == 3 ) {
			var pa = dmanager.attach("partPlouch",Const.PLAN_PART);
			pa._x = b.x;
			pa._y = b.y;
			KKApi.gameOver(stats);
			hero.doGameOver();
		} else {
			var f = int(Math.min(bcounter-1,Const.POINTS.length-1));
			var s = Const.POINTS[f];
			stats.$c[f]++;
			KKApi.addScore(s);
			b.plop(f);
			nbals--;
			downcast(counter).field.text = string(nbals);
		}
		b.destroy();
		bals.remove(b);
		time = 0;
	}

	function main() {
		var steps = 7;
		var i;
		time += Timer.deltaT;
		waitTimer += Timer.deltaT;
		if( nblacks < 10 && time > 10 ) {
			time = 0;
			nblacks++;
			bals.push(new Ballon(this,3));
		}

		if( getBalsLength() > 6 && Std.random(int(10000/Timer.tmod)) == 0 ) {
			if( Std.random(5) != 0 || waitTimer > 5 ) {
				var n = getBalsLength();
				for(i=0;i<n;i++) {
					var b = bals[i];
					b.tx = 150 + Math.cos(i/n * Math.PI * 2) * 100;
					b.ty = 150 + Math.sin(i/n * Math.PI * 2) * 100;
					b.mind = 0;
					b.timer = 5;
				}
			} else {
				var ys = [50,150,250];
				var c = [0,0,0];
				for(i=0;i<getBalsLength();i++) {
					var b = bals[i];
					if( b.t != 3 ) {
						var x = c[b.t]++;
						x = (((x%2) > 0)?1:-1) * 15 * x;
						b.tx = 150 + x;
						b.ty = ys[b.t];
						b.mind = 0;
						b.timer = 5;
					}
				}
			}
		}

		for(i=0;i<steps;i++)
			hero.update(steps);
		for(i=0;i<getBalsLength();i++)
			if( !bals[i].update(i) )
				bals.splice(i--,1);
		if( getBalsLength() - nblacks <= Const.LEVEL[level].m )
			nextLevel();


		if(bals.getCheat() )KKApi.flagCheater();

	}

	function destroy() {
	}

	function getBalsLength(){
		return bals.length;
	}
}