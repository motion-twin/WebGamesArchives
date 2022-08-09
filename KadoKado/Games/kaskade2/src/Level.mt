class Level {

    var game : Game;
    var billes : Array<Array<Bille>>;
    var groups : Array<Array<Bille>>;
    var gravityList : Array<Bille>;

    function new(g) {
        game = g;
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
			for(x=0;x<Const.LVL_WIDTH;x++)
				for(y=0;y<Const.LVL_HEIGHT;y++)
					if( billes[x][y] == null )
						billes[x][y] = new Bille(game,x,y);
            gravityList = null;
            makeGroups();
			game.nextTurn();
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
        var i,x,y;
        for(x=0;x<Const.LVL_WIDTH;x++)
            for(y=0;y<Const.LVL_HEIGHT;y++)
                billes[x][y].group = null;
        groups = new Array();
        for(x=0;x<Const.LVL_WIDTH;x++)
            for(y=0;y<Const.LVL_HEIGHT;y++) {
                var b = billes[x][y];
                if( b != null && b.group == null ) {
                    var g = new Array();
                    makeGroupsRec(b,x,y,g);
					if( g.length < 2 || g[0].id == Const.MAXCOLORS-1 ) {	// COUPS
						for(i=0;i<g.length;i++) {
							b = g[i];
							b.group = null;
							b.star.gotoAndPlay("off");
						}
					} else {
                        groups.push(g);
						for(i=0;i<g.length;i++) {
							b = g[i];
							b.star.gotoAndPlay("on");
						}
					}
                }
            }
		if( groups.length == 0 )
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

		animate();

        var i;
        for(i=0;i<gravityList.length;i++) {
            var b = gravityList[i];
            if( !b.gravityMain() ) {
                gravityList.remove(b);
                i--;
                if( gravityList.length == 0 ) {
                    game.bg.useHandCursor = false ;
                    gravity();
                    break;
                }
            }
        }
    }

}