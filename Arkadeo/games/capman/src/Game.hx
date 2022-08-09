import mt.bumdum9.Lib;
import Protocol;
import api.AKApi;
import api.AKProtocol;
import TitleLogo;
import mt.kiroukou.math.MLib;

/**
 * PAC MAN
 */
@:build(mt.kiroukou.macros.IntInliner.create([
	DP_BG,
	DP_LEVEL,
	DP_INTER,
	DP_FILTER,
]))
class Game extends SP {
	
	public var gstep 		: Int;
	public var gtimer 		: Int;
	public var bg 			: SP;
	public var hero 		: ent.Hero;
	public var dif 			: mt.flash.Volatile<Int>;
	public var coins 		: mt.flash.Volatile<Int>;
	public var coinMax 		: mt.flash.Volatile<Int>;
	public var plasma 		: BMD;
	public var seed 		: mt.Rand;
	public var squares 		: Array<Square>;
	public var ents 		: Array<Ent>;
	public var bads 		: Array<ent.Bad>;
	public var level 		: Level;
	public var inter 		: Inter;
	public var fxm 			: mt.fx.Manager;
	public var stepFx 		: mt.fx.Fx;
	public var dm 			: mt.DepthManager;
	public var bonus 		: Null<BonusKind>;
	public var bonusLife 	: Int;
	
	public static var me 	: Game;
	public function new() {
		super();
		me = this;
		//
		fxm = new mt.fx.Manager();
		mt.fx.Fx.DEFAULT_MANAGER = fxm;
		dm = new mt.DepthManager(this);
		gtimer = 0;
		seed = new mt.Rand( AKApi.getSeed() + AKApi.getLevel() );
		gstep = -1;
		dif = 0;
		
		Cs.initGfx();
		// BAR
		inter = new Inter();
		
		bg = new SP();
		bg.graphics.beginFill(0);
		bg.graphics.drawRect(0, 0, Cs.WIDTH, Cs.HEIGHT);
		dm.add(bg, DP_BG);
		// FILTER
		var filter = new BMP();
		filter.bitmapData = new Cs.BmpFilter(0,0);
		dm.add( filter, DP_FILTER);
		filter.blendMode = flash.display.BlendMode.OVERLAY;
		// GAME MODE
		switch(AKApi.getGameMode()) {
			case GM_PROGRESSION :
				var lvl = AKApi.getLevel();
			case GM_LEAGUE :
			default:
		}
		// scroll level sequence at game start
		new seq.Init();
	}

	public function initLevel() {
		ents = [];
		bads = [];
		coins = 0;
		//setJump(3);
		// LEVEL
		level = new Level();
		dm.add(level, DP_LEVEL);
		// GRID
		initGrid();
		// HERO
		hero  = new ent.Hero();
		// DATA
		switch(AKApi.getGameMode() ) {
			case GM_PROGRESSION :
				var lvl = AKApi.getLevel();
				var data:DataProgression =  haxe.Unserializer.run(Cs.levels);
				var ldat = data._list[AKApi.getLevel() - 1];
				loadLevel( ldat );
				
			case GM_LEAGUE :
				generate();
				var sq = getFreeRandomSquare();
				if( sq == null ) throw("argh");
				hero.setSquare(sq.x, sq.y);
				
			default:
		}
		hero.majHeroDist();
		
		//COINS
		fillCoins();
		
		// PLASMA
		plasma = new BMD(Cs.XMAX, Cs.YMAX, true, 0);
		var mc = new BMP(plasma);
		mc.x = Cs.CX;
		mc.y = Cs.CY;
		mc.scaleX = mc.scaleY = Cs.SQ;
		Level.me.dm.add(mc, Level.DP_PLASMA);
		mc.blendMode = flash.display.BlendMode.ADD;
		Filt.blur(mc, 32, 32);
		
		// BADS
		new seq.PKPop();
		switch( AKApi.getGameMode() ) {
			
			case GM_PROGRESSION :
				new seq.TimeUp();
			
			case GM_LEAGUE :
				for( id in Cs.MONSTERS_INIT ) {
					var b = spawnBad(id);
					b.autoPos();
				}
				new seq.BadFlow();
			
			default:
		}
		
		for( b in bads ) b.seekDir();
		//BONUS
		new seq.BonusPop();
	}
	
	public function spawnBad(id:Int):ent.Bad {
		switch(id) {
			case 0 : return new bad.Classic();
			case 1 : return new bad.Skull();
			case 2 : return new bad.Block();
			case 3 : return new bad.Jumper();
			default : return new bad.Hunter();
		}
	}
	
	public function fillCoins() {
		coins = 0;
		var addCoin = true;
		for( sq in Game.me.squares ) {
			if( addCoin && !sq.isBlock() && hero.square != sq ) {
				sq.addCoin();
				addCoin = !Cs.FORCE_ONE_COIN;
			}
			sq.initGfx();
		}
		coinMax = coins;
	}
	
	// UPGRADE
	public function update(render:Bool) {
		gtimer ++;
		inter.update();
		
		if( stepFx != null ) {
			stepFx.update();
			return;
		}
		
		switch(gstep) {
			case 0 :
				for( e in ents.copy())
					e.update();
				if( render )
					EL.updateAnims();
				
				var ct = new CT(1, 1, 1, 1, 0, 0, 0, -2);
				plasma.colorTransform(plasma.rect, ct);
				var fl = new flash.filters.BlurFilter(2, 2);
				
				if( gtimer % 10 == 0 )
					for( sq in squares )
						if( sq.htrack > 0 )
							sq.htrack --;
		}
		
		fxm.update();
		
		/* EDITOR */
		#if dev
		//if( api.AKApi.isToggled( 69 ) || api.AKApi.isToggled( flash.ui.Keyboard.ESCAPE ) ) new seq.Editor();
		#end
		
		// SORT ENTS
		ents.sort(zSort);
		for( e in ents )
			Level.me.dm.over(e.root);
	}

	// ZSORT
	public function zSort(a:Ent,b:Ent) {
		if( a.y < b.y ) return -1;
		if( a.y > b.y ) return 1;
		return 0;
	}
	
	// GRID
	var free:Array<Square>;
	function initGrid() {
		var skinId = 1;
		if( AKApi.getGameMode() == GM_PROGRESSION )
			skinId = AKApi.getLevel() % 4;
		// INIT
		squares = [];
		for( x in 0...Cs.XMAX ) {
			for( y in 0...Cs.YMAX ) {
				var sq = new Square(x, y);
				sq.skinId = skinId;
				squares.push(sq);
			}
		}
		// NEI
		for( sq in squares ) {
			for( d in Cs.DIR ){
				var nx = sq.x + d[0];
				var ny = sq.y + d[1];
				var nsq = getSquare(nx, ny);
				sq.dnei.push(nsq);
				if( nsq!= null ) sq.nei.push(nsq);
			}
		}
	}
	
	function generate() {
		free = squares.copy();
		var mx = 4;
		var my = 2;
		for( sq in squares ) {
			sq.out = sq.x < mx || sq.x >= Cs.XMAX-mx || sq.y < my || sq.y >= Cs.YMAX-my;
			if( sq.out )
				free.remove(sq);
		}
		// LABY
		while(free.length > 0 )
			snakeIt();
		// OPEN 3-WALL SQUARES
		for( sq in squares ) {
			if( sq.out ) continue;
			var op = [];
			for( di in 0...4 )
				if( sq.getWall(di) == 0 )
					op.push(di);
			
			if( op.length == 1 ) {
				var di = (op[0] + 2) % 4;
				var nsq = sq.dnei[di];
				if( nsq != null && !nsq.out ) {
					sq.open(di);
				} else {
					buildDistFrom(sq);
					var best = 0;
					var wdi = -1;
					for( i in 0...2 ) {
						di = (di + [1, 2][i]) % 4;
						var nsq = sq.dnei[di];
						if( nsq != null && !nsq.out && nsq.hdist > best ) {
							wdi = di;
							best = nsq.hdist;
						}
					}
					if( best > 0 ) {
						sq.open(wdi);
					} else {
						sq.mark(0xFF0000);
					}
				}
			}
		}
		
		// OPEN FAR SQUARES
		for( sq in squares ) {
			if( sq.out ) continue;
			buildDistFrom(sq);
			var best = 0;
			var wdi = -1;
			for( di in 0...4 ) {
				var nsq = sq.dnei[di];
				if( nsq != null && !nsq.out && nsq.hdist > best ) {
					wdi = di;
					best = nsq.hdist;
				}
			}
			if( best > 10 ) sq.open(wdi);
		}
		
		// DOORS
		for( i in 0...2 ) new Door();
	}
	
	function snakeIt() {
		var color = Std.random(0xFFFFFF);
		//
		Arr.shuffle(free, seed);
		var start = free[rnd(free.length)];
		//*	// A REIMP
		for( sq in free ) {
			var ok = false;
			for( di in 0...4 ) {
				var nei = sq.dnei[di];
				if( nei!= null && nei.tag == 1 && !nei.out ) {
					start = sq;
					start.open(di);
					ok = true;
					break;
				}
			}
			if(ok)break;
		}
		//
		var cur = start;
		var max = 48;
		var n = 0;
		while(n++ < max) {
			cur.color = color;
			cur.tag = 1;
			free.remove(cur);
			var a = [];
			for( di in 0...4 ) {
				var nsq = cur.dnei[di];
				if( nsq == null || nsq.tag == 1 || nsq.out) continue;
				a.push(di);
			}
			if( a.length == 0 ) break;
			var di = a[rnd(a.length)];
			cur.open(di);
			cur = cur.dnei[di];
		}
	}

	// GRID - DIST
	public function buildDistFrom(square:Square,passDoor=false) {
		for( sq in Game.me.squares )
			sq.hdist = 999;
		square.hdist = 0;
		var work = [square];
		while(work.length > 0 )
			work = expand(work, passDoor);
	}
	
	function expand(work:Array<Square>, passDoor=false) {
		var a = [];
		for( sq in work ) {
			var hdist = sq.hdist + 1;
			for( di in 0...4 ) {
				var nsq = sq.dnei[di];
				var wall = sq.getWall(di) > 0;
				if( passDoor && sq.getWall(di) == 2 ) wall = false;
				if( nsq == null || nsq.hdist <= hdist || wall ) continue;
				nsq.hdist = hdist;
				a.push(nsq);
			}
		}
		return a;
	}
	
	// RANDOM
	public function rnd(n) {
		return seed.random(n);
	}
	
	// FX
	public function addScore(n, ?x, ?y) {
		if(AKApi.getGameMode() != GM_LEAGUE ) return;
		AKApi.addScore(api.AKApi.const(n));
		
		if( x != null ) {
			var mc = Cs.getTinyScore(n);
			Level.me.dm.add(mc, Level.DP_SCORE);
			var p = new mt.fx.Part(mc);
			p.vy = -5;
			p.frict = 0.75;
			p.timer = 50;
			p.fadeLimit = 5;
			p.fadeType = 2;
			p.fitPix = true;
			p.setPos(x, y);
			p.setScale(0.5);
			
			var c = (gtimer % 200) / 200;
			var c = (n - Cs.SCORE_BALL.get()) / (Cs.SCORE_BALL_MAX.get() - Cs.SCORE_BALL.get());
			Col.setColor(p.root, Col.hsl2Rgb(c*0.8+0.1,1.0,0.6));
			Filt.glow(p.root, 2, 8, 0);
		}
	}
	
	//
	public function onLastCoin() {
		switch(AKApi.getGameMode()) {
			case GM_LEAGUE :
				new seq.SpitCoins();
			case GM_PROGRESSION :
				new seq.Win();
			default:
		}
	}
	
	// TOOLS
	public function getSquare(x, y) {
		if( !isIn(x, y) ) return null;
		return squares[x*Cs.YMAX+y];
	}
	
	public function isIn(x,y) {
		return x >= 0 && x < Cs.XMAX && y >= 0 && y < Cs.YMAX;
	}
	
	public function getFreeSquares() {
		var a = [];
		for( sq in squares )
			if( !sq.isBlock() && !sq.out )
				a.push(sq);
		return a;
	}
	
	public function getFreeRandomSquare(distMin=-1) {
		var a = getFreeSquares();
		if( distMin > 0 )
			for( sq in a.copy() )
				if( sq.hdist < distMin )
					a.remove(sq);
 		return a[rnd(a.length)];
	}
	
	public function loadLevel(data:DataLevel) {
		// SQUARES
		var id = 0;
		for( n in data._squares ) {
			var sq = squares[id];
			for( di in 0...4 ) {
				var base = Std.int(Math.pow(2, di));
				if( sq.dnei[di] == null ) continue;
				sq.setWall(di, (n % (base*2) >= base )?0:1);
			}
			id ++ ;
		}
		
		// DOORS
		for( id in data._doors )
			new Door(squares[id]);
		
		// BADS
		for( i in 0...(data._bads.length >> 1)) {
			var b = spawnBad(data._bads[i*2]);
			b.gotoSquareId(data._bads[i*2 + 1]);
		}
		
		// HERO
		hero.gotoSquareId(data._start);
	}
}

