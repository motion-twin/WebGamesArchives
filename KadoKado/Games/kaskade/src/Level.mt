class Level {

    var game : Game;
    var bg : MovieClip;
    var billes : Array<Array<Bille>>;
    var groups : Array<Array<Bille>>;
    var curGroup : Array<Bille>;
    var lock : bool;
    var gravityList : Array<Bille>;
	var time : float;

    function new(g) {
        game = g;
		time = 0;
        lock = false;
        bg = game.dmanager.attach("bg",Const.PLAN_BG);
        bg.onMouseMove = callback(this,onMouseMove);
        bg.onMouseDown = callback(this,onClick);

        // for handcursor
		bg.onRelease = fun() {} ;
		bg.useHandCursor = false ;

        initLevel();
    }

    function initLevel() {
        var x,y;
        billes = new Array();
        for(x=0;x<Const.LVL_WIDTH;x++) {
            billes[x] = new Array();
            for(y=0;y<Const.LVL_HEIGHT;y++)
                billes[x][y] = new Bille(game,x,y);
        }
        makeGroups();
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
        var b = billes[int(x)][int(y)];
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
      bg.useHandCursor = true ;
      Mouse.hide() ;
      Mouse.show() ;
    }
    function hideCursor() {
      bg.useHandCursor = false ;
      Mouse.hide() ;
      Mouse.show() ;
    }

    function onClick() {
        if( lock || curGroup == null )
            return;		

        var x,y;
        for(x=0;x<Const.LVL_WIDTH;x++)
            for(y=0;y<Const.LVL_HEIGHT;y++) {
                var b = billes[x][y];
                if( b.group == curGroup )
                    billes[x][y] = null;
            }

        var n = curGroup.length;
        var pts = int(n * (n - 1) / 2 * KKApi.val(Const.C100));
		game.stats.$t.push(int(time));
		game.stats.$g.push(n);
        KKApi.addScore(KKApi.const(pts));

        var i,j;
        for(i=0;i<curGroup.length;i++) {
            var b = curGroup[i];
            for(j=0;j<3;j++)
                game.particules.addWordPart(b.mc._x,b.mc._y,b.mc._currentframe);
            var p = game.dmanager.attach("explosion",Const.PLAN_PART) ;
            p._x = b.mc._x ;
            p._y = b.mc._y ;
            p._rotation = Std.random(360) ;
            downcast(p).sub.gotoAndPlay( (Std.random(3)+1)+"" ) ;
            p._alpha = 30 + Std.random(70) ;
            p.gotoAndStop( b.mc._currentframe+"" ) ;
            b.mc.removeMovieClip();
        }
        lock = true;
        gravity();
    }

    function gravity() {
        var x,y;
        gravityList = new Array();
        for(y=0;y<Const.LVL_HEIGHT;y++) {
            var space = false;
            for(x=Const.LVL_WIDTH-1;x>=0;x--) {
                var b = billes[x][y];
                if( b == null )
                    space = true;
                else if( space ) {
                    billes[x+1][y] = b;
                    billes[x][y] = null;
                    b.gravityLeft();
                    gravityList.push(b);
                }
            }
        }

        if( gravityList.length > 0 )
            return;

        for(x=0;x<Const.LVL_WIDTH;x++) {
            var space = false;
            for(y=Const.LVL_HEIGHT-1;y>=0;y--) {
                var b = billes[x][y];
                if( b == null )
                    space = true;
                else if( space ) {
                    billes[x][y+1] = b;
                    billes[x][y] = null;
                    b.gravityDown();
                    gravityList.push(b);
                }
            }
        }

        if( gravityList.length == 0 ) {
            curGroup = null;
            gravityList = null;
            lock = false;
            makeGroups();
            onMouseMove();
        }
    }

    function makeGroupsRec(b : Bille,x : int,y : int,g : Array<Bille>) {
        var id = b.id;
        b.group = g;
        g.push(b);
        b = billes[x-1][y];
        if( b.id == id && b.group == null )
            makeGroupsRec(b,x-1,y,g);
        b = billes[x+1][y];
        if( b.id == id && b.group == null )
            makeGroupsRec(b,x+1,y,g);
        b = billes[x][y-1];
        if( b.id == id && b.group == null )
            makeGroupsRec(b,x,y-1,g);
        b = billes[x][y+1];
        if( b.id == id && b.group == null )
            makeGroupsRec(b,x,y+1,g);
    }

    function makeGroups() {
        var x,y;
        for(x=0;x<Const.LVL_WIDTH;x++)
            for(y=0;y<Const.LVL_HEIGHT;y++)
                billes[x][y].group = null;
        groups = new Array();
        var exists = false;
        for(x=0;x<Const.LVL_WIDTH;x++)
            for(y=0;y<Const.LVL_HEIGHT;y++) {
                var b = billes[x][y];
                if( b != null && b.group == null ) {
                    var g = new Array();
                    makeGroupsRec(b,x,y,g);
                    if( g.length == 1 )
                        b.group = null;
                    else
                        groups.push(g);
                    exists = true;
                }
            }
		if( !exists ) {
			game.stats.$l++;
			game.stats.$t.push(-1);
			game.stats.$g.push(-1);
			game.nlevels++;
            initLevel();			
		} else if( groups.length == 0 )
            game.gameOver();
    }

	function animate() {
		var ds = 10 * Timer.tmod;
		var x, y;
		for(x=Const.LVL_WIDTH-1;x>=0;x--) {
			for(y=Const.LVL_HEIGHT-1;y>=0;y--) {
				var mc = billes[x][y].mc;
				if( mc._xscale < 100 ) {
					var s = mc._xscale + ds * (y + 1) / 3;
					if( s > 100 ) s = 100;
					mc._xscale = s;
					mc._yscale = s;
					ds *= 0.95;
				}
			}
			ds *= 1.2;
		}
	}

    function main() {

		time += Timer.deltaT;
		animate();

        var i;
        for(i=0;i<gravityList.length;i++) {
            var b = gravityList[i];
            if( !b.gravityMain() ) {
                gravityList.remove(b);
                i--;
                if( gravityList.length == 0 ) {
                    bg.useHandCursor = false ;
                    gravity();
                    break;
                }
            }
        }
    }

}