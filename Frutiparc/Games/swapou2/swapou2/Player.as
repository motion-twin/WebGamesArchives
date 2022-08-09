import swapou2.Data;

class swapou2.Player implements swapou2.IPlayer {

	var game;
	var animator;
	var level;

	var infos;
	var combo;
	var combo_number;

	public var game_over_flag;
	var star_counter;
	var id;
	var sync_attacks;
	var next_combo_double;
	var horizontal_lock;
	var dbglabels;

	public var combo_score;
	public var score;

	function Player(g,pid,inf,px,py, challengeAnimator) {
		id = pid;
		infos = inf;
		game = g;
		if ( challengeAnimator )
			animator = new swapou2.AnimatorChallenge(this,px,py);
		else
			animator = new swapou2.Animator(this,px,py);
		level = new swapou2.Level(infos,animator);
		game_over_flag = undefined;
		star_counter = 0;
		score = 0;
		horizontal_lock = 0;
		next_combo_double = false;
		sync_attacks = new Array();

		/***
		dbglabels = new Array();
		var x,y;
		var p = 30000;
		if( px > Data.DOCWIDTH / 2 )
			p += 10000;
		for(x=0;x<inf.width;x++) {
			dbglabels[x] = new Array();
			for(y=0;y<inf.height;y++) {
				var t = Std.createTextField(game.depthManager().getMC(),p+x+y*inf.width,0,0,Data.FRUIT_WIDTH,Data.FRUIT_HEIGHT);
				t._x = px+x*1.0*Data.FRUIT_WIDTH;
				t._y = py+y*1.0*Data.FRUIT_HEIGHT;
				t.text = string(random(100));
				t.selectable = false;
				dbglabels[x][y] = t;
			}
				
		}
		/***/
	}

	function isIA() : Boolean {
		return false;
	}

	function setVisible(b) {
		animator.setFruitsVisible(b);
	}

	function depthManager() : asml.DepthManager {
		return game.depthManager();
	}

	function getLevelWidth() : Number {
		return level.getWidth();
	}

	function getLevelHeight() : Number {
		return level.getHeight();
	}

	function recall() {
		var x,y;
		var fruits = level.getFruits();
		var w = level.getWidth();
		var h = level.getHeight();
		for(x=0;x<w;x++)
			for(y=0;y<h;y++) {
				var f = fruits[x][y];
				f._x = Std.cast(animator.pos_x + x * Data.FRUIT_WIDTH);
				f._y = Std.cast(animator.pos_y + y * Data.FRUIT_HEIGHT);
			}

	}

	function noMoreLine() {
		var x;
		var fruits = level.getFruits();
		var w = level.getWidth();
		var y = level.getHeight() - 1;
		var prev_fruit = false;
		for(x=0;x<w;x++)
			if( fruits[x][y] != null ) {
				if( prev_fruit )
					return false;
				else
					prev_fruit = true;
			} else
				prev_fruit = false;
			return true;
	}

	function checkAttacks() {
		if( sync_attacks.length == 0 )
			return false;
		var aid = sync_attacks[0];
		sync_attacks.splice(0,1);
		attacked(aid,true);
		return true;
	}

	function main() {
		if( dbglabels != undefined ) {
			var x,y;
			var fruits = level.getFruits();
			for(x=0;x<dbglabels.length;x++)
				for(y=0;y<dbglabels[x].length;y++) {
					var t = dbglabels[x][y];
					var f = fruits[x][y];
					if( f != undefined )
						t.text = string(f.t);
					else
						t.text = "";
				}
		}
		if( horizontal_lock > 0 ) {
			horizontal_lock -= Std.deltaT;
			if( horizontal_lock < 0 )
				horizontal_lock = 0;
		}
		animator.main();
	}

	function destroy() {
		animator.destroy();
		level.destroy();
	}

	function swapDone() {

		var combos;
		var x = null;

		if( game_over_flag == undefined ) {
			combos = level.calc();
			x = level.explode(combos);
		}

		if( x != null ) {
			var i;
			var nexpl = 0;
			combo_number++;
			for(i=0;i<x.combos.length;i++)
				nexpl += x.combos[i].v;
			var mcs = x.mcs;
			for(i=0;i<mcs.length;i++)
				if( (mcs[i].flags & Data.FLAG_STAR) != 0 ) {
					game.getPower(this,mcs[i]);
					star_counter++;
					if( star_counter > Data.MAX_POWER )
						star_counter = Data.MAX_POWER;
				}

			combo.push(nexpl);
			var expl_score;
			if( Data.gameMode == Data.CLASSIC )
				expl_score = Data.calcScoreClassic(nexpl,combo_number,game.level);
			else
				expl_score = Data.calcScore(nexpl,combo_number);
			animator.explode(x.mcs,x.pete_armures,expl_score);
			animator.comboScore(expl_score,combo_number);
			combo_score += expl_score;
		} else if( !checkAttacks() )
			turnDone();

	}

	function explodeDone() {

		var p = combo.length - 1;
		var c = combo[p];
		game.sendFruits(this,c,p);
		if( next_combo_double )
			game.sendFruits(this,c,p);

		var mcs = level.gravity();
		if( mcs != null )
			animator.gravity(mcs);
		else
			swapDone();
	}

	function gravityDone() {
		swapDone();
	}

	function fallingDone() {
		skipTurn();
	}

	function skipTurn() {
		combo = new Array();
		combo_number = 0;
		combo_score = 0;
		swapDone();
	}

	function turnDone() {
		score += combo_score;
		animator.finalComboScore(combo_score,combo_number);
		next_combo_double = false;
		game.turnDone(this,combo);
	}

	function fallFruits() {
		var fruits = new Array();
		var send_list = game.getPool(this);
		var highs = new Array();
		var sorted_highs = new Array();
		var tbl = level.getFruits();
		var x,y;
		for(x=0;x<infos.width;x++) {
			for(y=0;y<infos.height;y++)
				if( tbl[x][y] != null )
					break;
			var k = { x : x, h : infos.height - y };
			highs.push(k);
			sorted_highs.push(k);
		}
		sorted_highs.sort(sort_by_h);

		while(send_list.length > 0) {
			var send = send_list[0];
			var n = 0;
			if( send.x == -1 ) {
				while(true) {
					if( isIA() )
						send.x = sorted_highs[random(4)].x;
					else
						send.x = random(infos.width);
					n++;
					if( n > 500 || level.getFruit(send.x,1) == null )
						break;
				}
			}
			var f = level.addFruit(send.x,send.col,send.flags);
			highs[send.x].h++;
			sorted_highs.sort(sort_by_h);
			if( f == null ) {
				game_over_flag = true;
				break;
			}
			fruits.push(f);
			send_list.splice(0,1);
		}
		if( fruits.length > 0 ) {
			animator.falling(fruits);
			return true;
		}
		return false;
	}

	function updateSudden() {
		var f = level.getFruits();
		var sudden = new Array();
		var i;
		var w = level.getWidth();
		for(i=0;i<w;i++)
			if( f[i][0] != null )
				sudden.push(f[i][0]);
		animator.suddenFruits(sudden);
	}

	function panic() {
		var x;
		var w = level.getWidth();
		for(x=0;x<w;x++)
			if( level.getFruit(x,1) != null )
				break;
		return( x != w );
	}

	function getPair(x,y) {
		return level.getPair(x,y);
	}

	function swapPair(p) {
		if( horizontal_lock > 0 && p.dx != 0 )
			return false;		
		if( level.swapPair(p) ) {			
			combo = new Array();
			combo_number = 0;
			combo_score = 0;
			animator.swap(p.f1,p.f2);
			return true;
		}
		return false;
	}

	function isGameOver() {
		return (game_over_flag == true);
	}

	function genLine() {
		return level.genLine();
	}

	function canAttack() {
		return (star_counter >= Data.ATTACK_STARS[id]);
	}

	function canDefend() {
		return (star_counter >= Data.DEFENSE_STARS[id]);
	}

	function gameOver(wins) {
		animator.gameOver(wins,Std.cast(level.getFruits()));
	}

	function specialDone() {
		swapDone();
	}

	function specialDoneGravity() {
		explodeDone();
	}

	static function sort_by_h(a,b) {
		return a.h - b.h;
	}

	function attacked(aid,sync) {
		var x,y;
		var w = level.getWidth();
		var h = level.getHeight();
		var fruits = level.getFruits();

		var highs = new Array();
		for(x=0;x<w;x++) {
			for(y=0;y<h;y++)
				if( fruits[x][y] != null )
					break;
			highs.push(h - y);
		}

		switch( aid ) {
		case 0: // HORIZONTAL LOCK

			if( !sync ) {				
				sync_attacks.push(aid);
				return false;
			}

			reset();
			horizontal_lock = Data.HORIZ_LOCK_TIME;
			animator.tremblementDeTerre([],[],Std.cast(fruits));
			return true;
		case 1: // 2-LINES
			for(y=0;y<2;y++)
				for(x=0;x<w;x++)					
					game.sendTo(this,{ col : infos.gen_fruit_color(), flags : Data.FLAG_ARMURE, x : -1 });
			return false;
		case 2: // 1-LINE
			for(x=0;x<w;x++)
				game.sendTo(this,{ col : infos.gen_fruit_color(), flags : Data.FLAG_ARMURE, x : -1 });
			return false;
		case 3: // 4-fruits sur une colonne
			var n = 0;
			while(true) {
				x = random(w);
				n++;
				if( n >= 100 || fruits[x][3] == null )
					break;
			}
			for(y=0;y<4;y++)
				game.sendTo(this,{ col : infos.gen_fruit_color(), flags : Data.FLAG_ARMURE, x : x });
			return false;
		case 4: // TREMBLEMENT DE TERRE : amplifie les reliefs
			if( !sync ) {
				sync_attacks.push(aid);
				return false;
			}

			reset();
			var cols = new Array();
			for(x=0;x<w;x++) {
				var hh = highs[x];
				if( hh > 0 )
					cols.push( { x : x, h : hh } );
			}
			cols.sort(sort_by_h);
			var rems = new Array();
			var adds = new Array();
			var dw = int(cols.length/2);
			for(x=0;x<dw;x++) {
				var c1 = cols[x];
				var c2 = cols[cols.length-1-x];
				var f = level.popBottomFruit(c1.x);
				var f2 = level.pushBottomFruit(c2.x,null);
				f2.init(f.save_t,f.flags);
				rems[c1.x] = f;
				adds[c2.x] = f2;
			}
			animator.tremblementDeTerre(rems,adds,Std.cast(fruits));
			return true;
		case 5: // COMBOx2 : double la prochaine combo
			return false;
		case 6: // COULEE D'ACIER : 3 premiers de chaque colonne -> NOSWAP
			if( !sync ) {
				sync_attacks.push(aid);
				return false;
			}
			reset();

			var acier = new Array();
			for(x=0;x<w;x++) {
				var sy = h - highs[x];
				for(y=0;y<2;y++) {
					var f = fruits[x][sy+y];
					if( f != null ) {
						f.has_armure = false;
						f.flags = Data.FLAG_NOSWAP;
						f.t = f.save_t;
						acier.push(f);
					}
				}
			}
			animator.couleeMetal(acier,fruits);
			return true;
		}
		return false;
	}

	function reset() {
		// FOR IA ONLY
	}

	function attack( p : swapou2.Player, sync ) {
		var attack_id = Data.ATTACK_PLAYERS[id];
		star_counter -= Data.ATTACK_STARS[id];
		animator.showAttack(Data.ATTACK_NAMES[attack_id]);

		if( attack_id == 5 )
			next_combo_double = true;

		return p.attacked(attack_id,sync);
	}

	function defend() {
		var defense_id = Data.DEFENSE_PLAYERS[id];
		star_counter -= Data.DEFENSE_STARS[id];
		var x,y;
		var w = level.getWidth();
		var h = level.getHeight();
		var fruits = level.getFruits();

		var highs = new Array();
		for(x=0;x<w;x++) {
			for(y=0;y<h;y++)
				if( fruits[x][y] != null )
					break;
			highs.push(h - y);
		}

		var data = null;

		combo = new Array();
		combo_number = 0;
		combo_score = 0;

		switch( defense_id ) {
		case 0: // ECARTEUR
			var center = level.getWidth()/2;
			var mc1 = new Array();
			var mc2 = new Array();
			var dw = int(w/2);
			var f;
			for(y=0;y<h;y++) {
				mc1.push(fruits[0][y]);
				mc2.push(fruits[w-1][y]);
				for(x=1;x<dw;x++)
					fruits[x-1][y] = fruits[x][y];
				fruits[dw-1][y] = null;
				for(x=w-2;x>=dw;x--)
					fruits[x+1][y] = fruits[x][y];
				fruits[dw][y] = null;
			}
			data = { id : 0, mc1 : mc1, mc2 : mc2 };
			break;
		case 1: // EGALISEUR
			var cols = new Array();
			for(x=0;x<w;x++)
				cols.push( { x : x, h : highs[x] } );
			cols.sort(sort_by_h);
			var rems = new Array();
			var adds = new Array();
			var dw = int(w/2);
			for(x=0;x<dw;x++) {
				var c1 = cols[x];
				var c2 = cols[w-1-x];
				if( c1.h >= c2.h )
					break;
				var f = level.popBottomFruit(c2.x);
				var f2 = level.pushBottomFruit(c1.x,null);
				f2.init(f.save_t,f.flags);
				rems[c2.x] = f;
				adds[c1.x] = f2;
			}
			data = { id : 1, rems : rems, adds : adds };
			break;
		case 2: // COUPEUR
			var max_h = 0;
			for(x=0;x<w;x++)
				if( highs[x] > max_h )
					max_h = highs[x];
			max_h -= 2;
			var cuts = new Array();
			for(x=0;x<w;x++) {
				var hx = highs[x];
				while( hx > max_h ) {
					cuts.push( fruits[x][h-hx] );
					fruits[x][h-hx] = null;
					hx--;
				}
			}
			data = { id : 2, cuts : cuts };
			break;
		case 3: // PETE1LIGNE
			var cuts = new Array();
			for(x=0;x<w;x++) {
				var f = fruits[x][h-1];
				if( f != null ) {
					cuts.push(f);
					fruits[x][h-1] = null;
				}
			}
			data = { id : 3, cuts : cuts };
			break;
		case 4: // CONVERTISEUR
			var converts = new Array();
			var src_color = infos.gen_fruit_color();
			var dst_color;
			do {
				dst_color = infos.gen_fruit_color();
			} while( src_color == dst_color );
			for(x=0;x<w;x++)
				for(y=0;y<h;y++) {
					var f = fruits[x][y];
					if( f.save_t == src_color ) {
						f.save_t = dst_color;
						f.flags = Data.FLAG_ARMURE
						f.has_armure = true;
						f.t = -1;
						converts.push(f);
					}
				}
			data = { id : 4, converts : converts, src : src_color, dst : dst_color };
			break;
		case 5: // PETEARMURES
			var mcs = new Array();
			for(x=0;x<w;x++)
				for(y=0;y<h;y++) {
					var f = fruits[x][y];
					if( (f.flags & Data.FLAG_ARMURE) != 0 ) {
						f.has_armure = false;
						f.flags &= (0xFFFF - Data.FLAG_ARMURE);
						f.t = f.save_t;
						mcs.push(f);
					}
				}
			data = { id : 5, mcs : mcs };
			break;
		case 6: // EXPLODES COMBOS 2
			var combos = level.calcMinCombos(2);
			var expl = { mcs : [], pete_armures : [] };
			if( combos != null )
				expl = level.explode(combos);
			data = { id:6, mcs : expl.mcs, arms : expl.pete_armures } ;
			break;
		}
		animator.dispatchDefense(Std.cast(data),fruits);
	}

}