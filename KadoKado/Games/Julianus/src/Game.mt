class Game {

	var mc : MovieClip;
	var dmanager : DepthManager;
	var hero : Hero;
	var bg : Bg;
	var bulles : PArray<Bulle>;
	var pics : PArray<Pic>;
	var kills : PArray<Pic>;
	volatile var bcount : int;
	volatile var pcount : int;
	volatile var time : float;
	volatile var speed : float;
	volatile var speed_delta : float;
	var game_over : bool;
	volatile var dist : float;
	var stats : {
		$bo : Array<int>, // bonuses
		$b : int, // bulles
		$f : int, // fusions
		$p : int, // pics
		$k : int, // bulles separate
		$d : int, // dist
	};

	function new(mc) {
		this.mc = mc;
		bcount = 0;
		pcount = 0;
		dist = 0;
		speed = 0;
		speed_delta = 0;
		time = 0;
		kills = new PArray();
		dmanager = new DepthManager(mc);
		bg = new Bg(this);
		hero = new Hero(this);
		bulles = new PArray();
		pics = new PArray();
		bulles.push( new Bulle(this,150,150) );
		stats = {
			$p : 0,
			$bo : [0,0,0],
			$f : 0,
			$b : 0,
			$k : 0,
			$d : 0,
		};
		var i;
		for(i=0;i<8;i++)
			genPic(300);
	}

	function press(flg) {
		hero.action = flg;
	}

	function onMove() {
		hero.tx = mc._xmouse;
		hero.ty = mc._ymouse;
	}

	function genPic(dx : int) {
		pcount++;
		stats.$p++;
		if( Std.random(10) == 0 )
			genPic(dx);
		var x,y;
		while( true ) {
			x = Std.random(250+dx) + 320;
			y = Std.random(300) + 10;
			var i;
			var ok = true;
			for(i=0;i<pics.length;i++) {
				var p = pics[i];
				var ddx = p.px - x;
				var dy = p.py - y;
				if( ddx*ddx + dy*dy < 400 ) {
					ok = false;
					break;
				}
			}
			if( ok ) {
				var id = 0;
				if( pcount > 20 && Std.random(5) == 0 ) {
					id = 1;
					if( x > 360 && pcount > 50 && Std.random(3) == 0 )
						id = 2;
				} else if( Std.random(10*(bcount-1)) == 0 ) {
					bcount++;
					id = 3 + Tools.randomProbas([20,4,1]);
				}
				pics.push( new Pic(this,id,x,y) );
				break;
			}
		}

	}

	function genBulle() {
		var ntrys = 10;
		while( ntrys-- > 0 ) {
			var x = Std.random(200)+50;
			var i;
			var ok = true;
			for(i=0;i<pics.length;i++) {
				var p = pics[i];
				if( p.py < 100 && p.px > x - 30 && p.px < x + 30 ) {
					ok = false;
					break;
				}
			}
			if( ok ) {
				stats.$b++;
				bulles.push(new Bulle(this,x,-20));
				return;
			}
		}
	}

	function main() {
		var i;
		var dx = -( Timer.tmod * (hero.px < 150)?0.5:(hero.px / 300) );
		var p = Math.pow(0.8,Timer.tmod);
		speed_delta += 0.000025 * Timer.tmod;
		speed = speed * p + dx * (1 - p) - speed_delta;
		dist += speed;
		time += Timer.deltaT;
		if( !game_over && time > 1 ) {
			var pts = 0;
			for(i=0;i<bulles.length;i++)
				pts += bulles[i].size / 9;
			while( time > 1 ) {
				KKApi.addScore(KKApi.const(int(pts) * 5));
				time -= 1;
				if( Std.random(10*bulles.length + int(pcount/3)) == 0 )
					genBulle();
			}
		}
		for(i=0;i<bulles.length;i++)
			bulles[i].update(speed);
		for(i=0;i<pics.length;i++)
			if( !pics[i].update(speed) ) {
				genPic(0);
				pics.splice(i--,1);
			}
		for(i=0;i<kills.length;i++)
			if( !kills[i].updateKill(speed) )
				kills.splice(i--,1);
		if( bulles.length == 0 ) {
			game_over = true;
			stats.$d = int(-dist);
			KKApi.gameOver(stats);
		}
		hero.update();
		bg.update(speed);

		if(bulles.getCheat())KKApi.flagCheater();
		if(pics.getCheat())KKApi.flagCheater();
		if(kills.getCheat())KKApi.flagCheater();


	}

	function destroy() {
	}

}