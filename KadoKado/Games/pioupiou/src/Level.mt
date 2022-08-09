class Level {//}

	var game : Game;
	var tbl : Array<Array<Kind>>;
	var blocks : MovieClip;
	var blocks_mask : MovieClip;
	var base_y : int;
	var target_y : int;
	var level : int;
	volatile var blk_speed : float;
	volatile var spawn : float;
	var bonuses : Array<Bonus>;
	var fallings : Array<Block>;
	var blobings : Array<Block>;

	function new(g) {
        game = g;
		bonuses = new Array();
		fallings = new Array();
		blobings = new Array();
		spawn = 0;
		level = 0;
		blk_speed = Const.BLK_SPEED + level * 0.1 * Const.LVL_WIDTH;
		initLevel();
		updateMask();
	}

	function initLevel() {
		base_y = Const.LVL_HEIGHT - 2;
		target_y = base_y;
		tbl = new Array();
		var x;
		for(x=0;x<Const.LVL_WIDTH;x++) {
			tbl[x] = new Array();
			tbl[x][0] = Kind.MASK;
		}
		blocks = game.dmanager.attach("blocks",Const.PLAN_BLOCK);
		blocks._x = Const.DELTA_X;
		blocks._y = Const.DELTA_Y;
		blocks_mask = game.dmanager.empty(Const.PLAN_BLOCK);
		blocks_mask._x = Const.DELTA_X;
		blocks_mask._y = Const.DELTA_Y;
		blocks.setMask(blocks_mask);
    }

	function drawMask(x,y) {
		var ey = Const.BLK_HEIGHT * Const.LVL_HEIGHT;
		x *= Const.BLK_WIDTH;
		y *= Const.BLK_HEIGHT;
		blocks_mask.beginFill(0,100);
		blocks_mask.moveTo(x,y);
		blocks_mask.lineTo(x+Const.BLK_WIDTH,y);
		blocks_mask.lineTo(x+Const.BLK_WIDTH,ey);
		blocks_mask.lineTo(x,ey);
		blocks_mask.lineTo(x,y);
		blocks_mask.endFill();
	}

	function updateMask() {
		blocks_mask.clear();
		var x,y;
		var sy = base_y-Const.LVL_HEIGHT+2;
		for(x=0;x<Const.LVL_WIDTH;x++) {
			for(y=sy;y<=base_y;y++)
				if( tbl[x][y] != Kind.MASK )
					break;
			if( y > sy )
				drawMask(x,base_y + 1 - y);
		}
	}

	function startFalling() {
		var x;
		var y = base_y + 1;
		var ntrys = 20;
		do {
			x = Std.random(Const.LVL_WIDTH);
		} while( --ntrys > 0 && (tbl[x][y] != null || tbl[x][y-1] != null) );
		if( ntrys == 0 )
			return;

		var i = 0;
		while( tbl[x][i+level] != null )
			i++;
		if( Std.random(i*i) > 1 ) {
			startFalling();
			return;
		}

		tbl[x][y-1] = Kind.BLOCK;
		var b = new Block(game,x,y);
		b.speed = blk_speed;
		b.mc._visible = false;
		b.time = 1;
		b.ann = game.interf.attach("announce",Const.PLAN_FX);
		b.ann._x = Const.DELTA_X + Const.BLK_WIDTH * x;
		fallings.push(b);
	}

	function genBonus() {
		var x;
		var y = base_y + 1;
		var ntrys = 20;
		do {
			x = Std.random(Const.LVL_WIDTH);
		} while( --ntrys > 0 && (tbl[x][y] != null || tbl[x][y-1] != null) );
		if( ntrys == 0 )
			return;
		var i;
		for(i=0;i<bonuses.length;i++)
			if( bonuses[i].x == x )
				return;
		var t = Tools.randomProbas(Const.BONUS_PROBAS_TBL);
		var b = new Bonus(game,x,y,t);
		bonuses.push(b);
	}

	function getFalling(x,y) {
		var i;
		for(i=0;i<fallings.length;i++) {
			var b = fallings[i];
			if( b.x == x && b.y == y )
				return b;
		}
		return null;
	}

	function getPos(x,y) {
		return {
			x :  int((x - Const.DELTA_X) / Const.BLK_WIDTH),
			y : game.level.base_y - int((y - Const.DELTA_Y) / Const.BLK_HEIGHT)
		};
	}

	function checkMove() {
		var x;
		var y = base_y - (Const.LVL_HEIGHT - 3);
		for(x=0;x<Const.LVL_WIDTH;x++)
			if( tbl[x][y] != Kind.MASK )
				return;
		target_y = base_y + 1;
	}

	function scrollUp() {
		base_y++;
		var i;
		for(i=0;i<fallings.length;i++) {
			var b = fallings[i];
			if( b.time > 0 ) {
				tbl[b.x][b.y-1] = null;
				b.y++;
				tbl[b.x][b.y-1] = Kind.BLOCK;
			}
			b.setPos();
		}
		for(i=0;i<blobings.length;i++) {
			var b = blobings[i];
			b.setPos();
		}
		for(i=0;i<bonuses.length;i++) {
			var b = bonuses[i];
			b.mc._y += Const.BLK_HEIGHT;
		}
		game.hero.scrollUp();
		if( game.hero.state != Hero.DEATH ) {
			level++;
			game.data.$l++;
			game.setMeter(level);
		}
	}

	function destroyBlock(b) {
		tbl[b.x][b.y] = Kind.MASK;
		blobings.remove(b);
		b.destroy();
		updateMask();
		checkMove();
	}

	function updateFalling(b : Block) {
		var r = true;
		var me = this;
		if( b.time > 0 ) {
			b.time -= Timer.deltaT;
			if( b.time <= 0 ) {
				b.mc._visible = true;
				b.ann.removeMovieClip();
			}
		} else {
			b.dy += Timer.tmod * b.speed;
			if( b.dy > Const.BLK_HEIGHT ) {
				b.dy -= Const.BLK_HEIGHT;
				b.y--;
				tbl[b.x][b.y] = null;
				if( tbl[b.x][b.y-1] != null ) {
					b.dy = 0;
					downcast(b.mc).finish = fun() { me.destroyBlock(b) };
					b.mc.play();
					tbl[b.x][b.y] = Kind.BLOB;
					blk_speed += 0.1;
					blobings.push(b);
					r = false;
				} else
					tbl[b.x][b.y-1] = Kind.BLOCK;
			}
			b.setPos();
		}
		return r;
	}

	function main() {

		spawn += Timer.tmod / (1 + fallings.length) / Math.max(2,15 - Math.max((level - 10)/2,0));

		while( Std.random(10) < spawn*10 ) {
			spawn--;
			var n = Tools.randomProbas([10,5,2,1]);
			while( n >= 0 ) {
				startFalling();
				n--;
			}
		}

		if( Std.random(int(Const.BONUS_PROBAS * bonuses.length / Timer.tmod)) == 0 )
			genBonus();

		var i;
		for(i=0;i<fallings.length;i++)
			if( !updateFalling(fallings[i]) )
				fallings.splice(i--,1);

		for(i=0;i<bonuses.length;i++) {
			var b = bonuses[i];
			if( game.hero.state != Hero.DEATH && Tools.distMC(b.mc,game.hero.mc) < 20 ) {
				var mc = game.dmanager.attach( "FXVanish",Const.PLAN_FX  );
				mc._x = b.mc._x+16
				mc._y = b.mc._y+16
				mc.gotoAndStop(string(b.type+1))
				KKApi.addScore( Const.BONUS_POINTS[b.type] );
				game.data.$b[b.type]++;
				b.destroy();
				bonuses.splice(i--,1);
			} else {
				if( b.falling )
					b.mc._y += 5 * Timer.tmod;
				var p = getPos(b.mc._x,b.mc._y);
				if( !b.falling && tbl[p.x][p.y] != null ) {
					var bl = getFalling(p.x,p.y+1);
					if( bl == null || bl.dy > Const.BLK_HEIGHT * 95 / 100 ) {
						b.destroy();
						bonuses.splice(i--,1);
					} else {
						b.mc._yscale = 100 - bl.dy * 100 / Const.BLK_HEIGHT;
						b.recall(p.x,p.y);
						b.mc._y += (1 - b.mc._yscale/100) * Const.BLK_HEIGHT;
					}
				} else if( tbl[p.x][p.y-1] != null && tbl[p.x][p.y-1] != Kind.BLOCK ) {
					if( b.falling ) {
						b.recall(null,p.y);
						b.falling = false;
					}
				} else
					b.falling = true;
			}
		}

		if( target_y != base_y ) {
			game.scroll._y += Timer.tmod * 5;
			if( game.scroll._y > Const.BLK_HEIGHT ) {
				game.scroll._y = 0;
				scrollUp();
				updateMask();
				checkMove();
			}
		}
    }
//{
}
