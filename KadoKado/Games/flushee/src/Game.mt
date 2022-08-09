class Game {

	var dmanager : DepthManager;
	var pcount : MovieClip;
	var gems : Array<Array<Gem>>;
	var cur : Gem;
	var next_cur : Gem;
	var tokens : KKConst;
	volatile var ngems : int;
	var cur_side : bool;
	var moves : Array<Gem>;
	var lock : bool;
	var wait_fall : bool;
	volatile var turn : int;
	volatile var tottokens : int;
	volatile var combo_score : int;
	var scores : Array<int>;
	var turns : Array<int>;
	var groups : Array<Array<Gem>>;
	var parts : Array<Particule>;

	var start_timer : float;


	function new(mc) {
		Log.setColor(0xFFFFFF);
		dmanager = new DepthManager(mc);
		dmanager.attach("bg",0);
		start_timer = 1;
		var pf = dmanager.attach("plateforme",Const.PLAN_INTERF);
		var hs = dmanager.attach("herbShade",0);
		pcount = dmanager.attach("playCount",Const.PLAN_INTERF);
		pcount._x = 70; // 150
		pcount._y = 10; // 280
		pf._x = Const.POSX;
		pf._y = Const.YFALAISE;
		hs._x = Const.POSX;
		hs._y = Const.YFALAISE;
		tottokens = 0;
		tokens = Const.NTOKENS;
		ngems = Const.NGEMS;
		lock = true;
		scores = new Array();
		turns = new Array();
		moves = new Array();
		parts = new Array();
		updateTokens();
		initLevel();
		setCur(new Gem(this,randId(),-1,0));
		mc.onRelease = callback(this,onClick);
		KKApi.registerButton(mc);
	}

	function randId() {
		return Std.random(Const.NGEMS-1);
	}

	function randSpecial( oldid ) {
		var id;
		if( Std.random(10) == 0 ) {
			if( Std.random(10) == 0 )
				return Const.ID_TOKENS;
			return Const.ID_BONUS;
		}
		do {
			id = Std.random(Const.NGEMS);
		} while( id == oldid );
		return id;
	}

	function setCur(g) {
		cur = g;
		cur.py = g.mc._y;
		cur_side = (cur.mc._x < 150);
	}

    function makeGroupsRec(b : Gem,x : int,y : int,g : Array<Gem>) {
        var id = b.id;
        b.group = g;
        g.push(b);
        b = gems[x-1][y];
        if( b.id == id && b.group == null )
            makeGroupsRec(b,x-1,y,g);
        b = gems[x+1][y];
        if( b.id == id && b.group == null )
            makeGroupsRec(b,x+1,y,g);
        b = gems[x][y-1];
        if( b.id == id && b.group == null )
            makeGroupsRec(b,x,y-1,g);
        b = gems[x][y+1];
        if( b.id == id && b.group == null )
            makeGroupsRec(b,x,y+1,g);
    }

    function makeGroups() : bool {
        var x,y;
        for(x=0;x<Const.LVL_WIDTH;x++)
            for(y=0;y<Const.LVL_HEIGHT;y++)
                gems[x][y].group = null;
        groups = new Array();
        var exists = false;
        for(x=0;x<Const.LVL_WIDTH;x++)
            for(y=0;y<Const.LVL_HEIGHT;y++) {
                var g = gems[x][y];
                if( g != null && g.group == null ) {
                    var grp = new Array();
                    makeGroupsRec(g,x,y,grp);
                    if( grp.length == 1 )
                        g.group = null;
                    else
                        groups.push(grp);
                    exists = true;
                }
            }
		return exists;
    }

	function initLevel() {
		var x,y;
		gems = new Array();
		for(x=0;x<Const.LVL_WIDTH;x++) {
			gems[x] = new Array();
			for(y=0;y<Const.LVL_HEIGHT;y++)
				gems[x][y] = new Gem(this,randId(),x,y);
		}
		var cont = true;
		while( cont ) {
			makeGroups();
			cont = false;
			var i;
			for(i=0;i<groups.length;i++) {
				var g = groups[i];
				if( g.length > Const.NEXPLS-1 && g[0].id < Const.ID_BONUS ) {
					cont = true;
					var b = g[Std.random(g.length)];
					b.setId(randSpecial(b.id));
				}
			}
		}
	}

	function onClick() {
		var x;
		var side = (cur.x < 0);
		if( lock || wait_fall )
			return;
		cur.setPos(cur.x,cur.y);
		if( side ) {
			next_cur = gems[Const.LVL_WIDTH-1][cur.y];
			for(x=Const.LVL_WIDTH;x>0;x--) {
				var g = gems[x-1][cur.y];
				gems[x][cur.y] = g;
				g.move(x,cur.y);
			}
			gems[0][cur.y] = cur;
			cur.move(0,cur.y);
		} else {
			next_cur = gems[0][cur.y];
			for(x=-1;x<Const.LVL_WIDTH-1;x++) {
				var g = gems[x+1][cur.y];
				gems[x][cur.y] = g;
				g.move(x,cur.y);
			}
			gems[Const.LVL_WIDTH-1][cur.y] = cur;
			cur.move(Const.LVL_WIDTH-1,cur.y);
		}
		dmanager.over(next_cur.mc);
		cur = null;
		combo_score = 0;
		lock = true;
		wait_fall = true;
		turn = 1;
		tokens = KKApi.cadd(tokens,Const.MINUS_ONE);
		tottokens++;
		updateTokens();
	}

	function updateTokens() {
		pcount.gotoAndStop(string(KKApi.val(tokens)+1));
	}

	function explode() : bool {
		var i,j;
		var expl = false;
		makeGroups();
		for(i=0;i<groups.length;i++) {
			var g = groups[i];
			if( g.length > Const.NEXPLS-1 && g[0].id < Const.ID_BONUS ) {
				expl = true;
				for(j=0;j<g.length;j++) {
					var b = g[j];
					gems[b.x][b.y] = null;
					b.explode();
				}
				var s = KKApi.val(Const.CMULT) * (g.length - 1) * turn;
				combo_score += s
				KKApi.addScore(KKApi.const(s));
			}
		}
		turn++;
		return expl;
	}

	function gravity() {
        var x,y;
		var grav = false;
        for(x=0;x<Const.LVL_WIDTH;x++) {
            var space = false;
            for(y=Const.LVL_HEIGHT-1;y>=0;y--) {
                var b = gems[x][y];
				if( b == null )
                    space = true;
				else if( space ) {
					grav = true;
                    gems[x][y+1] = b;
                    gems[x][y] = null;
                    b.gravity();
                }
            }
        }
		return grav;
	}

	function fills() : bool {
		var x,y;
		var generated = new Array();
		for(x=0;x<Const.LVL_WIDTH;x++) {
			var first = null;
			for(y=Const.LVL_HEIGHT-1;y>=0;y--) {
				if( gems[x][y] == null ) {
					if( first == null )
						first = y + 1;
					var g = new Gem(this,randId(),x,y-first);
					generated.push(g);
					g.fall(y);
					gems[x][y] = g;
				}
			}
		}

		if( generated.length == 0 )
			return false;

		generated = Tools.shuffle(generated);

		var fl = true;
		while( fl ) {
			fl = false;
			makeGroups();
			var i;
			for(i=0;i<generated.length;i++) {
				var g = generated[i];
				if( g.group.length > Const.NEXPLS-1 && g.id < Const.ID_BONUS ) {
					g.group.splice(0,100);
					g.setId(randSpecial(g.id));
					fl = true;
				}
			}
		}
		return true;
	}

	function nextMove() {

		if( next_cur != null ) {
			setCur(next_cur);
			next_cur = null;
		}

		if( gravity() )
			return;

		if( explode() )
			return;

		if( fills() )
			return;

		scores.push(combo_score);
		turns.push(turn);

		if( KKApi.val(tokens) == 0 && (cur.id == null || cur.id < Const.ID_BONUS) ) {
			dmanager.getMC().useHandCursor = false;
			KKApi.gameOver({ $n : tottokens, $s : scores, $t : turns });
			return;
		}

		lock = false;
	}

	function attachGloup(n) {
		var mc = dmanager.attach("bloub",Const.PLAN_INTERF);
		mc._x = (cur.x > 0)?(16+Const.POSX-36):(300-45+25);
		mc._y = 300;

		var b = dmanager.attach("bonus",Const.PLAN_INTERF);
		downcast(b).b.gotoAndStop(n);
		b._x = Const.POSX;
		b._y = Const.YFALAISE - 6;
	}

	function main() {

		if( start_timer > 0 ) {
			start_timer -= Timer.deltaT;
			if( start_timer <= 0 )
				lock = false;
		}

		var i;
		for(i=0;i<moves.length;i++) {
			var m = moves[i];
			if( !m.update() ) {
				m.px = m.mc._x;
				m.py = m.mc._y;
				moves.splice(i--,1);
				if( moves.length == 0 )
					nextMove();
			}
		}

		for(i=0;i<parts.length;i++)
			if( !parts[i].update() )
				parts.splice(i--,1);

		var side = (Std.xmouse() < 150);
		var cy = int(Math.max(Math.min((Std.ymouse() - Const.POSY)/36,Const.LVL_HEIGHT-1),0));

		var ty;
		if( side != cur_side || KKApi.val(tokens) == 0 || cur.id >= Const.ID_BONUS )
			ty = 350;
		else
			ty = Const.POSY + 36 * cy;

		var p = Math.pow(0.7,Timer.tmod);
		cur.x = side?-1:Const.LVL_WIDTH;
		cur.y = cy;
        cur.py = cur.py * p + ty * (1 - p);

		if( Math.abs(cur.py - ty) < 2 || (ty == 350 && cur.py > 300) ) {
			cur.py = ty;
			wait_fall = false;
			switch( cur.id ) {
			case Const.ID_BONUS:
				attachGloup(1);
				tokens = KKApi.cadd(tokens,Const.SMALL_BONUS);
				KKApi.addScore(Const.C1000);
				updateTokens();
				cur.setId(randId());
				break;
			case Const.ID_TOKENS:
				attachGloup(2);
				tokens = KKApi.cadd(tokens,Const.BIG_BONUS);
				if( KKApi.val(tokens) > KKApi.val(Const.NTOKENS) )
					tokens = Const.NTOKENS;
				updateTokens();
				cur.setId(randId());
				break;
			default:
				if( side != cur_side ) {
					cur_side = side;
					cur.setPos(cur.x,null);
				} else {
				}
				break;
			}
		}
		cur.mc._y = cur.py;
	}

 	function destroy() {
	}

}
