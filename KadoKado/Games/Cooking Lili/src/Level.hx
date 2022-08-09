import mt.flash.Volatile;
import KKApi;

typedef T_Pair = {
	x		: Int,
	y		: Int,
	dx		: Int,
	dy		: Int,
	t1		: Token,
	t2		: Token,
}

typedef T_Combo = {
	v		: Int,
	x		: Int,
	y		: Int,
	score	: Int,
	mx		: Float,
	my		: Float,
}

typedef T_SolverData = {
	swap	: T_Pair,
	score	: Int,
	depth	: Int,
	l		: Level,
}


class Level {
	static public var START_LINES	= 5; // was 5
	static public var START_VARIETY	= 3;
	static public var WID			= 10;
	static public var HEI			= 10;
	static public var X_OFF			= Const.GWID*0.5 - Const.TWID*WID*0.5;
	static public var Y_OFF			= Const.GHEI - Const.THEI*HEI;
	static var SOLVES_BY_FRAME		= 7;

	public var map			: Array<Array<Token>>;
	public var variety		: Volatile<Int>;
	public var cvariety		: Volatile<Int>;
	public var diff			: Volatile<Int>;
	public var cdiff		: Volatile<Int>;
	var armorRate			: Volatile<Int>;
	var comboMul			: KKConst;
	var solverData			: Array<T_SolverData>;
	var goodMoves			: Array<T_SolverData>;

	/*------------------------------------------------------------------------
	GÉNÉRATION INITIALE
	------------------------------------------------------------------------*/
	public function new(?m:Array<Array<Token>>) {
		variety = START_VARIETY;
		cvariety = START_VARIETY;

		diff = 0;
		cdiff = 0;
		armorRate = 0;


		map = new Array();
		for (x in 0...WID) {
			map[x] = new Array();
			if ( m!=null )
				// copie d'un level existant (pour les arbres de possibilités)
				for (y in 0...HEI)
					map[x][y] = m[x][y].copy();
		}

		if ( m==null )
			for (i in 0...START_LINES)
				addLine();

		comboMul = KKApi.const(0);
	}

	function copy() {
		return new Level(map);
	}


	public function getPair(x,y,dx,dy) : T_Pair {

		var t1 = map[x][y];
		var t2 = map[x+dx][y+dy];

		if ( t1==null || t2==null ) {
			return null;
		}
		return {
			x	: x,
			y	: y,
			dx	: dx,
			dy	: dy,
			t1	: t1,
			t2	: t2,
		}
	}

	public function different(p:T_Pair) {
		return
			p.t1.id!=p.t2.id ||
			p.t1.fl_armor!=p.t2.fl_armor;
	}


	/*------------------------------------------------------------------------
	CONVERTISSEUR SYSTÈME DE COORDONNÉES RÉEL <-> CASE
	------------------------------------------------------------------------*/
	public static function x_rtc(xr:Float) {
		return Math.floor((xr-X_OFF)/Const.TWID);
	}

	public static function y_rtc(yr:Float) {
		return Math.floor((yr-Y_OFF)/Const.THEI);
	}

	public static function x_ctr(x:Int) {
		return x*Const.TWID+X_OFF;
	}

	public static function y_ctr(y:Int) {
		return y*Const.THEI+Y_OFF;
	}

	function updateCoords() {
		for (x in 0...WID) {
			for (y in 0...HEI) {
				if ( map[x][y]!=null ) {
					map[x][y].x = x;
					map[x][y].y = y;
				}
			}
		}
	}

	// *** ACTIONS

	/*------------------------------------------------------------------------
	SWAP LOGIQUE
	------------------------------------------------------------------------*/
	public function swap(p:T_Pair) {
		if ( p==null ) return false;

		var t1 = map[p.x][p.y];
		var t2 = map[p.x+p.dx][p.y+p.dy];
		if ( t1==null || t2==null )
			return false;

		map[p.x][p.y] = t2;
		map[p.x+p.dx][p.y+p.dy] = t1;
		return true;
	}

	/*------------------------------------------------------------------------
	ADDS A LINE AT BOTTOM
	------------------------------------------------------------------------*/
	public function addLine() {
		for (x in 0...WID) {
			for (y in 0...HEI) {
				if ( map[x][y]!=null && y==0 )
					return false;
				map[x][y-1] = map[x][y];
				map[x][y] = null;
			}
		}
		var x = 0;
		while ( x<WID ) {
			var t = map[x][HEI-1];
			if ( t==null )
				t = map[x][HEI-1] = new Token(Game.me, Std.random(variety) );
			else
				t.setId( (t.id+1)%variety );

			var ch = check(false);
			if ( ch==null ) {
				if ( armorRate>0 && Std.random(armorRate)==0 )
					t.fl_armor = true;
				x++;
			}
		}
		for (col in map) {
			for (t in col) {
				t.combo = null;
			}
		}
		updateCoords();

		return true;
	}


	/*------------------------------------------------------------------------
	ENDS ROUND AND UPDATES DIFFICULTY
	------------------------------------------------------------------------*/
	public function endRound() {
		comboMul = KKApi.const(0);
		diff++;
		cdiff++;
		if ( diff==5 )
			armorRate = 10;
		if ( diff%15==0 && armorRate>4 )
			armorRate -=2;

		if ( diff==15 ) {
			variety++;
			cvariety++;
		}

		if ( diff==35 ) {
			variety++;
			cvariety++;
		}
	}


	/*------------------------------------------------------------------------
	GET THE LIST OF DANGEROUS TOKENS
	------------------------------------------------------------------------*/
	public function getWarnings() {
		updateCoords();
		var w = new Array();
		for (col in map) {
			if ( col[0]!=null ) {
				w.push(col[0]);
			}
		}
		return w;
	}




	// *** GAME RESOLUTION

	/*------------------------------------------------------------------------
	GENERAL COMBO CHECK
	------------------------------------------------------------------------*/
	public function checkRec(token,x,y,c:T_Combo) {
		if ( token.fl_armor ) {
			return;
		}
		c.v++;
		c.score += token.mul * c.v*c.v * KKApi.val(Const.PTS_TOKEN);
		c.mx = 0.5 * (token.mc._x + c.mx);
		c.my = 0.5 * (token.mc._y + c.my);
		token.combo = c;
		var nei;
		// gauche
		nei = map[x-1][y];
		if ( token.id==nei.id && nei.combo==null )
			checkRec(nei,x-1,y,c);
		// droite
		nei = map[x+1][y];
		if ( token.id==nei.id && nei.combo==null )
			checkRec(nei,x+1,y,c);
		// haut
		nei = map[x][y-1];
		if ( token.id==nei.id && nei.combo==null )
			checkRec(nei,x,y-1,c);
		// bas
		nei = map[x][y+1];
		if ( token.id==nei.id && nei.combo==null )
			checkRec(nei,x,y+1,c);
	}

	public function check(fl_score) {
		comboMul = KKApi.cadd( comboMul, KKApi.const(1) );
		var combos = new Array();
		for (col in map)
			for (token in col)
				token.combo = null;

		for (x in 0...WID)
			for (y in 0...HEI) {
				var token = map[x][y];
				if ( token!=null && token.combo==null ) {
					var c : T_Combo = {v:0, x:x, y:y, mx:token.mc._x, my:token.mc._y, score:0};
					checkRec(token,x,y,c);
					if ( c.v>=KKApi.val( Const.MIN_COMBO ) )
						combos.push(c);
				}
			}

		if ( combos.length==0 )
			return null;
		if ( fl_score ) {
			for ( c in combos ) {
				var val = KKApi.val(comboMul) * c.score;
				Game.me.addScore(KKApi.const(val) , c.mx+Const.TWID*0.5, c.my+Const.THEI*0.5 );
			}
		}
		return combos;
	}


	function getPossibleSwaps() {
		// listing des possibilités
		var swaps : List<T_Pair> = new List();
		for (x in 0...WID)
			for (y in 1...HEI) { // on ignore la ligne 0, pas intéressante à swapper
				if ( map[x][y]==null )
					continue;
				var s : T_Pair = {
					x	: x,
					y	: y,
					dx	: 0,
					dy	: 0,
					t1	: null,
					t2	: null,
				}
				// droite
				if ( map[x+1][y]!=null && map[x+1][y].id!=map[x][y].id ) {
					s.dx=1;
					swaps.add(s);
				}
				else
					// bas
					if ( map[x][y+1]!=null && map[x][y+1].id!=map[x][y].id ) {
						s.dy=1;
						swaps.add(s);
					}
			}
		return swaps;
	}

	public function initSolver() {
		solverData = new Array();
		var swaps = getPossibleSwaps();
		for( s in swaps)
			solverData.push({
				swap	: s,
				depth	: 0,
				score	: 0,
				l		: this,
			});
		trace("initSolver solverData="+solverData.length);

		goodMoves = new Array();
	}

	public function updateSolver() {
		if ( solverData.length==0 )
			return;

		var i = 0;
		while( i<solverData.length && i<SOLVES_BY_FRAME ) {
			updateSolverData(0);
			i++;
		}

		if( solverData.length==0 ) {
			var best : T_SolverData = null;
			for(sd in goodMoves)
				if ( best==null || sd.score>best.score )
					best = sd;
			trace( printSwap(best.swap) );
			map[best.swap.x][best.swap.y].mc.filters = [ new flash.filters.GlowFilter(0xffffff,1, 4,4, 10) ];
			map[best.swap.x+best.swap.dx][best.swap.y+best.swap.dy].mc.filters = [ new flash.filters.GlowFilter(0xffffff,1, 4,4, 10) ];
		}
	}

	function updateSolverData(id:Int) {
		var sd = solverData[id];
		var l = sd.l.copy();
		var score = 0;

		// on résout
		if ( sd.depth==0 )
			l.swap(sd.swap);
		var combos = l.check(false);
		for (c in combos)
			score+=c.score;
		l.explode(combos);
		l.gravity();

		// swap gagnant
		if ( score>0 ) {
			sd.score+=score;
			combos = l.check(false);
		}

		// fin de chaîne de combos
		if ( combos==null ) {
			if ( sd.score>0 ) {
				// on exclue les coups qui font perdre
				var fl_goodMove = true;
				for(x in 0...WID)
					if ( l.map[x][0]!=null || l.map[x][1]!=null ) {
						fl_goodMove = false;
						break;
					}
				if ( fl_goodMove )
					goodMoves.push(sd);
			}
		}
		else
			// on ajoute à la liste à solver
			solverData.push({
				swap	: sd.swap,
				depth	: sd.depth+1,
				score	: sd.score,
				l		: l,
			});

		solverData.splice(id,1);
	}

	function printSwap(s:T_Pair) {
		return s.x+","+s.y+" TO "+(s.x+s.dx)+","+(s.y+s.dy);
	}



	/*------------------------------------------------------------------------
	COMBO EXPLOSIONS
	------------------------------------------------------------------------*/
	public function explodeRec(now,arm,c:T_Combo,x,y) {
//		var g = new flash.filters.GlowFilter();
//		if ( c.x==x && c.y==y ) {
//			g.color = 0xffffff;
//		}
//		else {
//			g.color = 0x990000;
//		}
//
//		g.blurX = 10;
//		g.blurY = g.blurX;
//		g.inner = true;
//		map[x][y].mc.filters = [g];

		var nei = map[x][y];
		nei.combo = null;
		now.push(nei);
		map[x][y] = null;

		// left
		nei = map[x-1][y];
		if (nei.combo==c)
			explodeRec(now,arm,c,x-1,y);
		else if (nei.fl_armor) {
			arm.push(nei);
			nei.fl_armor = false;
			nei.mc._alpha = 100;
		}
		// right
		nei = map[x+1][y];
		if (nei.combo==c)
			explodeRec(now,arm,c,x+1,y);
		else if (nei.fl_armor) {
			arm.push(nei);
			nei.fl_armor = false;
			nei.mc._alpha = 100;
		}
		// up
		nei = map[x][y-1];
		if (nei.combo==c)
			explodeRec(now,arm,c,x,y-1);
		else if (nei.fl_armor) {
			arm.push(nei);
			nei.fl_armor = false;
			nei.mc._alpha = 100;
		}
		// down
		nei = map[x][y+1];
		if (nei.combo==c)
			explodeRec(now,arm,c,x,y+1);
		else if (nei.fl_armor) {
			arm.push(nei);
			nei.fl_armor = false;
			nei.mc._alpha = 100;
		}
	}


	public function explode(combos:Array<T_Combo>) {
		updateCoords();
		var arm = new Array();
		var now = new Array();
		for (c in combos)
			explodeRec(now,arm,c,c.x,c.y);
		return {explNow:now,explArm:arm};
	}


	public function gravity() {
		for (col in map)
			for (token in col) {
				token.fall = 0;
				token.moveDist = 0;
			}
		var falls = 0;
		var y = HEI-2;
		while (y>=0) {
			for (x in 0...WID) {
				var token = map[x][y];
				if ( token!=null && token.fall==0 ) {
					var under=map[x][y+1];
					if ( under!=null ) {
						// check under status
						token.fall=under.fall;
					}
					else {
						// nothing under
						var h=1;
						while ( y+h<HEI-1 && map[x][y+h]==null ) {
							h++;
						}
						if ( map[x][y+h]!=null ) {
							h+=map[x][y+h].fall-1;
						}
						token.fall = h;
					}
				}
				if ( token.fall>0 ) {
					falls++;
				}
			}
			y--;
		}

		// application réelle des mouvements
		y = HEI-2;
		while (y>=0) {
			for (x in 0...WID) {
				var token = map[x][y];
				if ( token.fall>0 ) {
					map[x][y+token.fall] = map[x][y];
					map[x][y] = null;
				}
			}
			y--;
		}
		return falls;
	}


}

