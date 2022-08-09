class Level {//}

	var game : Game;
	var step: int;
	var coins : Array<Array<Coin>>;
	var groups : Array<Array<Coin>>;
	var oldgravity : Array<Coin>;
	var gravityList : Array<Coin>;
	var explodeList : Array<Coin>;
	var transmuteList : Array<Coin>;

	function new(g) {
		game = g;
		step = 0
	}

	function initLevel() {
        var x,y;
        coins = new Array();
        for(x=0;x<Const.WIDTH;x++)
            coins[x] = new Array();
    }

	function makeGroupsRec(c : Coin,x : int,y : int,g : Array<Coin>) {
        var id = c.id;
        c.group = g;
        g.push(c);
        c = coins[x-1][y];
        if( c.id == id && c.group == null )
            makeGroupsRec(c,x-1,y,g);
        c = coins[x+1][y];
        if( c.id == id && c.group == null )
            makeGroupsRec(c,x+1,y,g);
        c = coins[x][y-1];
        if( c.id == id && c.group == null )
            makeGroupsRec(c,x,y-1,g);
        c = coins[x][y+1];
        if( c.id == id && c.group == null )
            makeGroupsRec(c,x,y+1,g);
    }

	function makeGroups() {
        var x,y;
        for(x=0;x<Const.WIDTH;x++)
			for(y=0;y<Const.HEIGHT;y++) {
				var c = coins[x][y];
                c.group = null;
				c.x = x;
				c.y = y;
			}
		groups = new Array();
        var exists = false;
        for(x=0;x<Const.WIDTH;x++)
            for(y=0;y<Const.HEIGHT;y++) {
                var c = coins[x][y];
                if( c != null && c.group == null ) {
                    var g = new Array();
                    makeGroupsRec(c,x,y,g);
                    groups.push(g);
                    exists = true;
                }
            }
    }

	function gravity() {
        var x,y;
		gravityList = new Array();
        for(x=0;x<Const.WIDTH;x++) {
            var space = false;
            for(y=Const.HEIGHT-1;y>=0;y--) {
                var c = coins[x][y];
				if( c == null )
                    space = true;
				else if( space ) {
                    coins[x][y+1] = c;
                    coins[x][y] = null;
					c.x = x;
					c.y = y+1;
                    c.gravityInit();
					gravityList.push(c);
                }
            }
        }


		for(y=0;y<Const.HEIGHT;y++)
			for(x=0;x<Const.WIDTH;x++) {
				var c = coins[x][y];
				if( c != null )
					game.dmanager.over(c.mc);
			}

		var i,j;
		for(i=0;i<oldgravity.length;i++) {
			var c = oldgravity[i];
			var found = false;
			for(j=0;j<gravityList.length;j++)
				if( gravityList[j] == c ) {
					found = true;
					break;
				}
			if( !found )				
				c.recall();			
		}				
		oldgravity = gravityList.duplicate();
		return gravityList.length > 0;
	}

	function explode() {
		makeGroups();
		explodeList = new Array();
		var i;
		for(i=0;i<groups.length;i++) {
			var g = groups[i];
			if( g.length >= Const.EXPLODE_COUNT && g[0].id != Const.POINTS.length-1 ) {
				var j;
				var minx = g[0].x;
				var miny = g[0].y;
				var nextId = g[0].id+1;
				
				if( nextId >= Const.ID_COUNT )
					Const.ID_COUNT = nextId+1;

				for(j=0;j<g.length;j++) {
					if( g[j].y >= miny ) {
						if( g[j].y > miny || g[j].x < minx )
							minx = g[j].x;
						miny = g[j].y;
					}
				}
				
				var coin = null;
				for(j=0;j<g.length;j++) {
					var c = g[j];
					if( minx == c.x && miny == c.y ) coin = c;
				}
				
				
				for(j=0;j<g.length;j++) {
					var c = g[j];
					c.explodeInit(coin);
					explodeList.push(c);
					if(c!=coin){
						coins[c.x][c.y] = null;
					}else{
						c.nextId = nextId;
					}
					
					
					
					
					/*
					if( p == c.x ) {
						p = null;
						c.transmuteInit(nextId);
						transmuteList.push(c);
					} else {
						c.explodeInit();
						coins[c.x][c.y] = null;
						explodeList.push(c);
					}
					*/
				}
				
				
				
			}
		}
		return explodeList.length > 0;
	}

	function update() {
		var i;
		for(i=0;i<explodeList.length;i++) {
			var c = explodeList[i];
			if( !c.explodeUpdate() )
				explodeList.splice(i--,1);
		}
		for(i=0;i<gravityList.length;i++) {
			var c = gravityList[i];
			if( !c.gravityUpdate() )
				gravityList.splice(i--,1);
		}
		for(i=0;i<transmuteList.length;i++) {
			var c = transmuteList[i];
			if( !c.transmuteUpdate() )
				transmuteList.splice(i--,1);
		}
		return gravityList.length > 0 || explodeList.length > 0 || transmuteList.length > 0;
	}

//{
}