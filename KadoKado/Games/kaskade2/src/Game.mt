class Game {

	static var replaySeed = null;
	static var replay = null;

	// !TRICHE! Partie de fish1976 (User #799259) score annoncé : 584540 
	// static var replaySeed = 244383;
	// static var replay =  [[5, 5], [4, 5], [4, 5], [4, 4], [5, 5], [6, 4], [7, 5], [4, 2], [2, 3], [3, 3], [3, 4], [6, 4], [7, 5], [4, 6], [6, 3], [1, 6], [0, 1], [2, 3], [3, 1], [4, 2], [3, 1], [7, 7], [5, 6], [0, 2], [0, 3], [0, 4], [1, 0], [1, 0], [2, 1], [7, 7], [7, 4], [1, 1], [1, 1], [1, 1], [1, 0], [0, 5], [4, 4], [7, 3], [4, 4], [0, 1]];

	// OK score=402300
	//static var replaySeed = 581825;
	//static var replay = [[2, 3], [6, 2], [6, 4], [5, 3], [5, 4], [2, 3], [3, 3], [6, 4], [4, 2], [4, 0], [4, 3], [4, 3], [4, 1], [7, 3], [7, 3], [7, 2], [6, 2], [4, 4], [5, 2], [6, 2]];
	// OK score=390300
	// static var replaySeed = 10426;
	// static var replay = [[4, 3], [6, 2], [5, 2], [2, 3], [4, 3], [3, 1], [5, 4], [2, 2], [4, 4], [6, 2], [2, 4], [4, 4], [4, 3], [5, 4], [5, 4], [4, 2], [4, 2], [7, 4], [7, 3], [7, 4]];
	// score=402300,
	

	// CORRECT Partie correcte pour tester replay
	// static var replaySeed = 10426;
	// static var replay = [[4, 3], [6, 2], [5, 2], [2, 3], [4, 3], [3, 1], [5, 4], [2, 2], [4, 4], [6, 2], [2, 4], [4, 4], [4, 3], [5, 4], [5, 4], [4, 2], [4, 2], [7, 4], [7, 3], [7, 4]];
	static var replayIdx = 0;

	var level : Level;
	var particules : Particules;
	var dmanager : DepthManager;
	var nlevels : int;
	var stats : {
		$r : int,
		$l : int,
		$t : Array<int>,
		$g : Array<int>,
		$c : Array<Array<int>>,
	};

	var cur : {x:int, y:int};
    var bg : MovieClip;
	var timebar : MovieClip;
    var curGroup : Array<Bille>;
	var flash : float;
    var lock : bool;
	var time : float;
	var ncoups : KKConst;
	var seed : RandSeed;

	function new(mc) {
		dmanager = new DepthManager(mc);
		particules = new Particules(dmanager);
		if (KKApi.isLocal() && replaySeed != null){
			stats = {
				$r : replaySeed,
				$l : 0,
				$t : [],
				$g : [],
				$c : [],
				$n : KKApi.val(Const.NCOUPS),
			}
		}
		else {
			stats = {
				$r : Std.random(999999999),
				$l : 0,
				$t : [],
				$g : [],
				$c : [],
				$n : KKApi.val(Const.NCOUPS),
			};
		}
		seed = new RandSeed();
		seed.setSeed(stats.$r);
		nlevels = 3;
		level = new Level(this);
		time = 0;
		ncoups = Const.NCOUPS;
        lock = false;
        bg = dmanager.attach("bg",Const.PLAN_BG);
		timebar = dmanager.attach("timebar",Const.PLAN_OVER);
        bg.onMouseMove = callback(this,onMouseMove);
        bg.onMouseDown = callback(this,onClick);

        // for handcursor
		bg.onRelease = fun() {} ;
		bg.useHandCursor = false ;
	}

	function random(max){
		return seed.random(max);
	}

    function onMouseMove() {
        if( lock )
            return;

        var xm = Std.xmouse() - Const.WIDTH / 2;
        var ym = Std.ymouse() - Const.HEIGHT / 2;

        var delt = Math.sqrt( Const.WIDTH * Const.WIDTH + Const.HEIGHT * Const.HEIGHT ) / 2;

        var x = xm * Bille.INV_COS - ym * Bille.INV_SIN + delt / 2;
        var y = xm * Bille.INV_SIN + ym * Bille.INV_COS + delt / 2;

        x /= Const.BILLE_RAY;
        y /= Const.BILLE_RAY;

		if (KKApi.isLocal() && replaySeed != null){
			x = replay[replayIdx][0];
			y = replay[replayIdx][1];
		}

		cur = { x:int(x), y:int(y) };

        var b = level.billes[int(x)][int(y)];
        if( curGroup == b.group )
            return;
        var i;
        for(i=0;i<curGroup.length;i++)
            curGroup[i].activate(false);
        curGroup = b.group;
        if ( b.group!=null ) {
            for(i=0;i<curGroup.length;i++)
                curGroup[i].activate(true);
            showCursor() ;
        }
        else
            hideCursor() ;
    }


    function showCursor() {
		bg.useHandCursor = true;
		Mouse.hide();
		Mouse.show();
    }
    function hideCursor() {
		bg.useHandCursor = false;
		Mouse.hide();
		Mouse.show();
    }

    function onClick() {
        if( lock || curGroup == null )
            return;

		if (KKApi.isLocal() && replaySeed != null)
			replayIdx++;

        var x,y;
        for(x=0;x<Const.LVL_WIDTH;x++)
            for(y=0;y<Const.LVL_HEIGHT;y++) {
                var b = level.billes[x][y];
                if( b.group == curGroup )
                    level.billes[x][y] = null;
            }

        var n = curGroup.length;
		ncoups = KKApi.const(KKApi.val(ncoups)-1);

        var pts = int(n * (n - 1) / 2 * KKApi.val(Const.C100));
		stats.$t.push(int(time));
		stats.$g.push(n);
		stats.$c.push([cur.x, cur.y]);
        KKApi.addScore(KKApi.const(pts));

        var i,j;
        for(i=0;i<curGroup.length;i++) {
            var b = curGroup[i];
            for(j=0;j<3;j++)
                particules.addWordPart(b.mc._x,b.mc._y,b.mc._currentframe);
            var p = dmanager.attach("explosion",Const.PLAN_PART) ;
            p._x = b.mc._x ;
            p._y = b.mc._y ;
            p._rotation = Std.random(360) ;
            downcast(p).sub.gotoAndPlay( (Std.random(3)+1)+"" ) ;
            p._alpha = 30 + Std.random(70) ;
            p.gotoAndStop( b.mc._currentframe+"" ) ;
            b.mc.removeMovieClip();
        }
        lock = true;
        level.gravity();
    }

	function nextTurn() {
		if( KKApi.val(ncoups) == 0 ) {
			gameOver();
			return;
		}
		curGroup = null;
        lock = false;
        onMouseMove();
	}

	function main() {
		var p = Math.pow(0.6,Timer.tmod);
		if( flash != null ) {
			flash -= Timer.tmod * 3;
			if( flash < 0 )
				flash = 0;
			var c = new Color(dmanager.getMC());
			var k = int(flash * 2.55);
			var f = int(flash / 2);
			c.setTransform({
				ra : 100 - f,
				rb : k,
				ga : 100 - f,
				gb : 0,
				ba : 100 - f,
				bb : 0,
				aa : 100,
				ab : 0
			});
			if( flash == 0 )
				flash = null;
		}
		time += Timer.deltaT;
		timebar.gotoAndStop(string(KKApi.val(ncoups)+1));
		particules.main();
		level.main();
	}

	function gameOver() {
		KKApi.gameOver(stats);
	}

	function destroy() {
	}

}
