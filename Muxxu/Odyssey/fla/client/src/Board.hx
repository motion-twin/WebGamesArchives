import Protocole;
import mt.bumdum9.Rush;
import mt.bumdum9.Lib;
using mt.bumdum9.MBut;

typedef BallGroup =  { list:Array<Ball>, type:BallType, alt:BallType, border:BallType };
typedef MoveData = { unfreeze:Int };

class Board extends SP {//}
	
	public static var DP_FX = 		4;
	public static var DP_BALLS = 	3;
	public static var DP_UFX = 		2;
	public static var DP_BG = 		1;
	
	public static var BORDER = 4;
	
	public var xmax:Int;
	public var ymax:Int;
	public var mcw:Int;
	public var mch:Int;
	public var unfreeze:Int;
	
	public var ready:Bool;
	
	public var hero:Hero;
	public var moveData:MoveData;
	
	var pool:Array<BallType>;
	public var balls:Array<Ball>;
	public var groups:Array<BallGroup>;
	public var breathes:Array<part.Breath>;

	
	// SPECIFIC
	public var ghosts:Array<Ball>;
	
	//
	public var dm:mt.DepthManager;
	var box:SP;
	
	public function new(hero) {
		super();
		this.hero = hero;
		hero.board = this;
		
		ready = true;
	
		
		var dim = Gameplay.getGridSize(hero.ghost);
		xmax = dim.width;
		ymax = dim.height;
		mcw = xmax * Ball.SIZE;
		mch = ymax * Ball.SIZE;

		unfreeze = 0;
		balls = [];
		ghosts = [];
		breathes = [];
		genPool();
		
		// BG
		initBg();
		
		//
		box = new SP();
		addChild(box);
		dm = new mt.DepthManager(box);
		//Filt.glow(box, 2, 4, 0xFF0000);
		box.filters = [new flash.filters.DropShadowFilter(2, 45, 0, 1, 1.5, 1.5, 1)];

		

		/*
		var bg = new SP();
		dm.add(bg, DP_BG);
		var gfx  = bg.graphics;
		gfx.beginFill(0x331100);
		gfx.drawRect(0, 0, xmax * Ball.SIZE, ymax * Ball.SIZE);
		*/
		
		//
		initInter();
		
	}
	
	// BG
	function initBg() {
		// 0x122931
		var pal = [0x2C2822, 0x74644C, 0x0F1D23, 0x122931];
		var sizes = [1, 1, 4, 0];
		var b = BORDER;
		
		var bg = new SP();
		addChild(bg);
		var g = bg.graphics;
		
		for ( i in 0...4 ) {
			g.beginFill(pal[i], (i == 3)?0.74:1);
			
			var ww = xmax * Ball.SIZE + b * 2;
			var hh = ymax * Ball.SIZE + b * 2;
			
			if ( i < 2 )
				hh += HeroBar.HEIGHT;
			
			
			g.drawRect(-b, -b, ww, hh);
			if ( i < 3 ) {
				var n = BORDER;
				for (k in 0...3 ) n -= sizes[k];
				g.drawRect(-n, -n, xmax * Ball.SIZE + n*2, ymax * Ball.SIZE + n*2);
			}
			g.endFill();
			
			//
			if ( i == 2 ) {
				g.beginFill(0x514738);
				g.drawRect( -b, hh, ww, HeroBar.HEIGHT-4);
				g.endFill();
			}
			
			
			//
			b -= sizes[i];
			
		}
		

		
	}
	
	public function getWidth() {
		return xmax * Ball.SIZE;
	}

	
	// UPDATE
	public function update() {
	
		
		//var fl  =new flash.filters.BlurFilter(4, 4);
		//var pow = 0.5 + Math.cos(hero.game.gtimer % 6.28) * 0.5;
		//var fl = new flash.filters.GlowFilter(0xFFFFFF, 1, pow*8, pow*8, pow*4, 1, true);
		for ( b in ghosts ) {
			b.el.alpha = 0.5;
			//b.filters = [fl];
			//b.alpha = (hero.game.gtimer % 5) < 3?1:0.5;
			if ( Std.random(4) == 0 ) {
				var p = new mt.fx.Part(new SP());
				p.root.graphics.beginFill(0xFFFFFF);
				p.root.graphics.drawCircle(0, 0, 1);
				p.setPos( b.x + (Math.random() * 2 - 1) * 10, b.y + (Math.random() * 2 - 1) * 10);
				p.weight = -(0.02 + Math.random() * 0.1);
				p.timer = 10 + Std.random(10);
				p.fadeType = 2;
				dm.add(p.root, 5);
			}
		}
		
	}

	// UPKEEP
	
	public function onEndTurn() {
		for ( b in ghosts ) {
			b.ghost = false;
			b.explode();
		}
		ghosts = [];
	}
	
	
	// INTERRACT
	public function activate() {

		buildGroups();
		checkPlayable();
				
		for ( b in balls ) {
			
			var select = null;
			if (b.isPlayable() ) select = callback(selectBall, b);
			b.makeBut( select, callback(showBallZone, b), callback(hideBallZone, b));
			
		}
		
	}
	public function deactivate() {
		//trace("deactivate");
		for ( b in balls ) {
			b.filters = Ball.FILTERS;
			b.box.filters = [];
			b.alpha = 1;
			b.removeEvents();
		}
		
	}
	public function checkPlayable() {

		//trace("checkPlayable");
		
		var gm = hero.game;
		var turn = ac.struct.HeroTurn.current;
		
		if ( turn == null ) return;
		
		for ( b in balls ) b.grey = false;
		
		// CONSTRAINTS
		if( turn.cons != null ){
			for ( b in balls ) b.grey = turn.cons.heroes != null;
			if ( turn.cons.heroes != null )
				for ( h in turn.cons.heroes )
					if ( h == hero )
						for ( b in balls ) b.grey = false;
				
			if( turn.cons.balls != null ){
				for ( b in balls ) {
					if ( b.grey ) continue;
					var ok = false;
					for ( bt in turn.cons.balls ) ok = bt == b.type || ok ;
					b.grey = !ok;
				}
			}
		}
		
		// SPECIAL
		if ( hero.haveStatus(STA_CLOCK) )
			for ( b in balls ) b.grey = true;


		// BALLS SPECIAL
		var reload = 		hero.haveStatus(STA_BOW_RELOAD);
		var first = 		gm.heroes[gm.heroes.length - 1] == hero;
		var rage =			hero.readStock(RAGE) > 0;
		var pacifism = 		hero.haveStatus(STA_PACIFISM);
		var pacifism2 = 	hero.haveStatus(STA_PACIFISM_2);
		var nextAction =	 Game.me.monster.getNextActionData().id;
		
		
		for ( b in balls ) {
					
			if ( b.grey ) continue;
			if ( b.bubble ) {
				dm.over(b);
				if( !hero.have(SEA_FIGHT) )	b.grey = true;
			}
			if ( reload && b.type == BOW ) 								b.grey = true;
			if ( b.type == SHIELD && rage )								b.grey = true;
			if ( Ball.isAttack(b.type) && (pacifism || pacifism2 ) )	b.grey = true;
			if ( b.isMagic() && pacifism2 )								b.grey = true;
			
			
			if ( b.group.list.length > 1 && nextAction == AC_INTIMIDATE && !hero.have(NO_FEAR) )			b.grey = true;
			
		}
		
		
		
		// FIRST
		
		
		// DRAW
		for ( b in balls ) {
			b.filters = Ball.FILTERS;

			b.alpha = 1;
			if ( b.grey ) {
				Filt.grey(b.box, null, null, { r:-50, g:-10, b: 20 } );
				b.alpha = 0.5;
			}

		}
		
	}
		
	function selectBall(b:Ball) {
		ready = false;
		moveData = { unfreeze:0 };
		
		hideBallZone(b);
		hero.game.uc.select(this, b);
	}
	function showBallZone(b:Ball) {
		
		/*
		#if dev
		hero.game.help.displayBall(b);
		#else
		*/
		
		var num = b.group.list.length;
		var bt = b.type;
		
		// PATCH JAR - SHELL
		if ( b.isJar() && hero.have(SHELL) ) for ( ba in b.group.list ) if ( !ba.isJar() ) num--;
		
		var combo = hero.game.uc.getCombo( { hero:hero, type:bt, num:num, alt:null } );
		var name = Data.ballDb(bt).name;
		var str = "<h1><img src='"+Main.path+"/img/icons/balls/ball_"+Type.enumIndex(bt)+".png'/>" + name + "</h1>";
		str += "<p>" + Cs.rep(combo.desc, Cs.gnum(combo.power), Cs.gnum(combo.time), Cs.gnum(combo.data.num), Cs.gnum(combo.data.num*2) ) + "</p>";
		
		#if dev
		Game.me.help.displayBall(b);
		#else
		hero.game.showExternalTips("<div class='ball_desc'>"+str+"</div>");
		#end
		
		//#end
	
		for ( ball in b.group.list ) {
			ball.setRadiate(true);
			if ( ball.group.alt != null && hero.have(BRAINSTORM) ) ball.selfDraw(ball.group.alt);
		}
		
	}
	function hideBallZone(b:Ball) {
		#if dev
		hero.game.help.displayDefault();
		#else
		hero.game.hideExternalTips();
		#end
	
		for ( ball in b.group.list ) {
			if ( ball.group.alt != null && hero.have(BRAINSTORM) ) ball.selfDraw(ball.type);
			ball.setRadiate(false);
		}
		
	}
	
	// GROUPS
	public function buildGroups() {
			
		writeGrid();
		// GRID + CLEAN
		var grid = getGrid();
		
		// NEIGHBOURS
		for ( b in balls ) {
			b.group = null;
			b.nei = [];
			b.flag = 0;
			for ( d in Cs.DIR ) {
				var nx = b.px + d[0];
				var ny = b.py + d[1];
				if ( !isIn(nx, ny) ) continue;
				var n = grid[nx][ny];
				if ( n != null ) b.nei.push(n);
			}
		}
		
		// GROUPS
		groups = [];
		for ( b in balls ) {
			
			if ( b.group != null ) continue;
			for ( b in balls ) b.flag = 0;
			var gr = { list:[], type:b.type, alt:null, border:ORI_HELMET };
						
			switch(b.type) {
				case MADNESS :
					var a = hero.getMadList();
					gr.alt = a[Std.random(a.length)];
					
				case BOOT :
					gr.list = b.get8Nei();
					
				case JAR, JAR_CRACKED, JAR_POISON :
					if ( hero.have(SHELL) )
						gr.border = SHIELD;
					
				default :
					if ( b.bubble && hero.have(SEA_FIGHT) ) {
						gr.list = b.get8Nei();
					}
				
			}
			
			
			
			expand(b,gr);
			groups.push(b.group);
			
			for ( b in gr.list ) if ( b.generic ) b.flag = 0;	// UNLOCK GENERIC
			
		}

	}
	function expand(b:Ball, gr:BallGroup ) {
		if ( b.type == gr.type ) b.group = gr;
		b.flag = 1;
		gr.list.push(b);
		for ( nei in b.nei ){
			if ( nei.flag == 1 ) continue;
			
			if( ( nei.type == gr.type && !nei.bubble && !b.bubble ) || nei.generic )
				expand(nei, gr);

			if( b.type == gr.type && nei.type == gr.border) {
				gr.list.push(nei);
				nei.flag = 1;
			}
			
				
		}
	}

		
	// GRID
	public function getGrid() {
		var grid = [];
		for ( x in 0...xmax ) grid[x] = [];
		for ( b in balls ) 	grid[b.px][b.py] = b;
		return grid;
	}
	public function isIn(x, y) {
		return x >= 0 && x < xmax && y >= 0 && y < ymax;
	}
	public function readGrid(n:Int) {
		
	
		for ( b in balls.copy() ) b.kill();
		
		var rnd = Std.random;
		
		// BASIC FILL
		//var count = Std.int( xmax * ymax * (hero.ghost.state.grid / 1000) );
		var count = hero.ghost.state.grid;
		//count = 1;		// HACK
		var y = ymax - 1;
		var x = 0;
		while (count-- > 0) {
			addBall(getRandomBallType(), x++, y);
			if ( x == xmax ) {
				x = 0;
				y--;
			}
		}
		
		// SPECIAL
		for ( bt in hero.ghost.state.specials ) {	// HERE
			var b = getRandomBall();
			if( b != null && !b.data.skill ) b.setType(bt);
		}
		
		
		//
		buildGroups();
		
		
		var max = 0;
		var limit = Std.int(xmax * ymax * 0.15);
		
		if ( n < 10 ) {
			for ( gr in groups ) {
				if ( gr.list.length > limit ) {
					readGrid(n + 1);
					return;
				}
				if ( gr.list.length > max ) max = gr.list.length;
			}
			
			var side = Math.sqrt(balls.length);
			var min = Std.int(side*0.5);
			if ( max < min ) {
				readGrid(n + 1);
			}
		}
		

		
		
		
	}
	public function writeGrid() {
		
		//hero.ghost.state.grid = Std.int((balls.length / (xmax * ymax)) * 1000);
		hero.ghost.state.grid = balls.length;
		
		/*
		hero.ghost.grid = [];
		var gr = getGrid();
		for ( x in 0...xmax ) {
			for ( y in 0...ymax ) {
				var b = gr[x][y];
				if ( b == null ) 	hero.ghost.grid.push(null);
				else				hero.ghost.grid.push(b.type);
			}
		}
		*/
		
		
	}
	public function genPool() {
		
		var balls =  hero.data.balls.copy();
		for( sk in hero.ghost.skills ){
			switch(sk) {
				case ARROW_ICE:
					balls.remove(SHIELD);
					balls.push(ADD_ICE);
					
				case ARROW_POISON :
					balls.remove(ADD_FIRE);
					balls.push(ADD_POISON);
					
				case QUIVER :
					balls.remove(SWORD);
					balls.push(BOW);
					
				case ESCAPE_KING :
					balls.remove(CHAIN);
					
				case NODACHI :
					balls.remove(AXE);
					balls.push(SWORD_RED);
					
				case MECHA_SECRET_PATH :
					balls.remove(SHIELD);
					balls.push(MECHA_SHARD);
					
				case MECHA_MASTER :
					balls.push(MECHA_CRYSTAL);
					
				default:
			}
		}
		
		pool = balls;
		
	}
	
	// TOOLS
	public function getColumn(x) {
		var a = [];
		for ( b in balls ) if ( b.px == x ) a.push(b);
		return a;
	}
	public function getLine(y) {
		var a = [];
		for ( b in balls ) if ( b.py == y ) a.push(b);
		return a;
	}
	public function getGlobalBallPos(bx,by) {
		return { x: x + bx * Ball.SIZE, y: y + by * Ball.SIZE };
	}
	public function getFreePos() {
		var grid = getGrid();
		var a = [];
		for ( y in 0...ymax )
			for ( x in 0...xmax )
				if ( grid[x][y] == null )
					a.push( { x:x, y:y } );
					
		return a;
	}
		
	// BALL
	public function addBall(type,x,y) {
		var ball = new Ball(this);
		ball.setType(type);
		ball.setPos(x, y);
		balls.push(ball);
		return ball;
	}
	public function getRandomBall() {
		return balls[Std.random(balls.length)];
	}
	public function getRandomBalls(max,order=false) {
		var pool = balls.copy();
		Arr.shuffle(pool);
		if ( order ) pool.sort(orderBall);
		return pool.slice(0, max);
	}
	public function getBall(type) {
		var a = balls.copy();
		Arr.shuffle(a);
		for ( b in a ) if ( b.type == type ) return b;
		return null;
	}
	

	
	public function getRandomBallType() {
		var t = pool[Std.random(pool.length)];
		if ( hero.ghost.type == Stirenx && Std.random(3) == 0 )		t = FROZEN(t);
		if ( t == HEAL && Std.random(4) == 0 ) t = pool[Std.random(pool.length)];
		return t;
	}
	
	
	public function getIcedBalls() {
		var a = [];
		for ( b in balls ) {
			switch(b.type) {
				case FROZEN(id): a.push(b);
				default:
			}
		}
		return a;
	}
	
		
	function orderBall(a:Ball,b:Ball) {
		if ( a.score > b.score ) return -1;
		return 1;
	}
	public function computeBallScores(front = true, avoidStone = false) {
		
		var mechashield = hero.have(MECHA_SHIELD);
		
		var aa = 5000;
		var bb = 4900;
		
		for ( b in balls ) {
			b.score = 0;
			if ( front ) b.score += b.px;
			switch(b.type) {
				//case TURNIP, CARROT, POTATO : 	b.score += abs;
				case STONE : 			if ( avoidStone ) 	b.score -= aa;
				case MECHA_CRYSTAL : 	if ( mechashield ) 	b.score -= bb;
				default :
			}
		}
	}
	
	// SPECIFIC
	public function getUnbubbled() {
		var a = [];
		for ( b in balls )	if ( !b.bubble )a.push(b);
		return a;
	}
	
	// BREATH
	public function checkBreath() {
		for ( br in breathes ) br.checkPos();
		breathes.sort( sortBreathes );
	}
	public function sortBreathes(a:part.Breath,b:part.Breath) {
		if ( a.py * xmax + a.px > b.py * xmax + b.px ) return -1;
		return 1;
	}
	public function getBreathFreePos(br) {
		var grid = [];
		for ( id in 0...xmax * ymax ) grid.push(true);
		for ( b in balls )  	grid[b.px +b.py*xmax] = false;
		for ( b in breathes ) {
			if ( br == b && grid[b.px +b.py * xmax] ) return null;
			grid[b.px +b.py*xmax] = false;
		}
		
		var a = [];
		for ( id in 0...xmax * ymax ) {
			if ( grid[id]  )
				a.push( { y:Std.int(id / xmax), x:(id % xmax) } );
		}
		return a ;
		
	}
	public function isBreathStable() {
		for ( br in breathes ) if ( !br.stable ) return false;
		return true;
	}
	public function breathSpawn(max,?type:BallType) {
		
		for ( i in 0...max ) {
			if ( breathes.length == 0 ) return;
			var br = breathes.shift();
			br.fxPop();
			br.kill();
			var t = type;
			if ( t == null ) t = getRandomBallType();
			var ball = addBall( t, br.px, br.py);
			
			var e = new mt.fx.Flash(ball,0.1,0);
			e.glow(4, 8);
			ball.fxDrop();
			

			
		}
		
	
		
		
	}
	public function damageBreath(max) {
		for ( i in 0...max ) {
			var br = breathes.shift();
			br.fxPop();
			br.kill();
			if ( breathes.length == 0 ) return;
		}
	}
	public function killBreathAt(x,y) {
		for ( br in breathes ) {
			if ( br.px == x && br.py == y ) {
				br.fxPop();
				br.kill();
				return;
			}
		}
		//trace("no breath at ("+x+","+y+")");
	}

	// FX
	var shake:mt.fx.Shake;
	public function fxHit() {
		if ( shake != null ) shake.kill();
		shake = new mt.fx.Shake(this, 16,0,0.6 );
	}
	public function fxArmor() {
		var mc = new gfx.Armor();
		mc.scaleX = xmax * Ball.SIZE * 0.01;
		mc.scaleY = ymax * Ball.SIZE * 0.01;
		addChild(mc);
		
	}

	// INTER
	public var inter:HeroBar;
	function initInter() {
		inter = new HeroBar(hero, xmax*Ball.SIZE+BORDER*2);
		inter.x = -Board.BORDER;
		inter.y = ymax * Ball.SIZE + 2;
		addChild(inter);
		inter.maj();
	}

	// KILL
	public function kill() {
		parent.removeChild(this);
	}


//{
}


class HeroBar extends SP {
	
	public static var HEIGHT = 24;
	
	var hero:Hero;
	public var counters:Array<inter.Counter>;
	var icons:Array<{mc:MC,sta:StatusType,sk:SkillType,num:Int}>;
	
	var title:TF;
	
	
	public function new(h,ww) {
		super();
		hero = h;
		//graphics.beginFill(0);
		//graphics.drawRect(0, 0, hero.board.xmax * Ball.SIZE, HEIGHT );
		
		// WAVES
		var waves = new MotifWave();
		var mw = new SP();
		mw.graphics.beginFill(0xFF0000);
		mw.graphics.drawRect(2, 0, ww-4, 10);
		waves.mask = mw;
		addChild(waves);
		addChild(mw);
		
		
		//
		icons = [];
		
		// CURSOR
		var cx = 3;
		
		// TITLE
		title = Cs.getField(0xECD482, 16, "diogenes");
		title.height = 24;
		title.x = cx;
		title.y = 0;
		title.text = hero.ghost.name == null ? Std.string(hero.data.id) : hero.ghost.name;
		title.width = 120;
		addChild(title);
		Filt.glow(title, 3, 2, 0);
		cx += 120;
		
		// COUNTERS
		counters = [];
		for ( i in 0...3 ) {
			var counter = new inter.Counter([1,7,5][i],i==2);
			counter.y = 5;
			addChild(counter);
			counters.push(counter);
			cx += 40;
		}
		
		//
		maj();
		
	}
	
	public function maj() {
		//trace("maj");
		var cx = hero.board.xmax*Ball.SIZE + Board.BORDER*2;
		
		// COUNTERS
		for ( id in 0...3 ) {
			var counter = counters[id];
			
			var help = "";

			switch(id) {
				
				case 0 :	// ARMOR
				
					
					counter.set( hero.armor );
					var n = hero.armorLifeMax;
					switch(n) {
						case 3 :	counter.goto(4 - hero.armorLife);
						case 4 :	counter.goto(13 - hero.armorLife);
					}
					/*
					if ( hero.armor == 0 )	help = "Votre héro n'a pas d'armure. Cliquez sur un bouclier pour lui en fabriquer une."
					else					help = "Annule " + hero.armor+" blessures pour les "+hero.armorLife+" prochains coups. Protection contre la magie : "+(hero.armor*5)+"%";
					*/
					
					help = Cs.rep(Data.BALLS[Type.enumIndex(SHIELD)].desc3, Std.string(hero.armor), Std.string(hero.armorLife), Std.string(hero.armor * 5) );
					counter.visible = hero.armor > 0;
				
				case 1 :	// REGENERATION
					
					counter.visible = false;
					/*
					counter.set( hero.breath );
					counter.visible = hero.breath > 0;
					//help = "Votre hero régénère un élement a chaque tour pendant "+hero.regeneration+" tour(s).";
					help = "Votre hero peut régénérer jusqu'a " + hero.breath + " rune(s) lors de ce combat.";
					*/
					
				case 2 :
					counter.set( hero.stock );
					counter.visible = hero.stock > 0;
					
					
					if ( counter.visible ) {
						counter.goto(Type.enumIndex(hero.stockType));
						help = Data.BALLS[Type.enumIndex(hero.stockType)].desc3;
						help = Cs.rep(help, Std.string(hero.stock) );
					}
				
				
				
			}
	
			if ( counter.visible ) {
				// POS
				//cx -= 30;
				//trace(counter.width);
				cx -= 20+Std.int( counter.field.textWidth);
				counter.x  = cx;
				
				// HELP
				counter.removeEvents();
				Game.me.makeHint(counter, help);
				
			}
			
			
		}
		
		// STATUS
		cx -= 10;
		var olds = icons.copy();
		icons = [];
		var a = [];
		var allStatus = [];
		var skills = hero.getSkills();
		
		for ( sk in skills ) {
			var data = Data.SKILLS[Type.enumIndex(sk)];
			if ( !data.visible ) continue;
			var hint = "<div class='skill_desc'><h1>" + data.name + "</h1><p>" + data.desc + "</p></div>";
			a.push( { lib:"skills", fr:Type.enumIndex(sk)-Type.enumIndex(VENOM), hint:hint, sk:sk, sta:null, num:0 } );
		}
		for ( o in hero.status ) {
			var sid = Type.enumIndex(o.sta);
			var data = Data.STATUS[sid];
			var hint = "<div class='status_desc'><h1><img src='"+Main.path+"/img/status/status_"+sid+".png'/>" + data.name + "</h1><p>" + data.desc + "</p></div>";
			
			
			if ( allStatus[sid] == null ) {
				var obj = { lib:"status", fr:sid, hint:hint, sk:null, sta:o.sta, num:0 };
				allStatus[sid] = obj;
				a.push( obj );
			}
			allStatus[sid].num++;
			
		}
				
		var id = 0;
		cx -= 10;
		for ( o in a ) {
			
			var zomb = null;
			for ( old in olds ) {
				if ( old.sk == o.sk && old.sta == o.sta && old.num == o.num) {
					zomb = old;
					break;
				}
			}
			if ( zomb != null ) {
				zomb.mc.x = cx;
				zomb.mc.y = 5;
				icons.push(zomb);
				cx -= 18;
				olds.remove(zomb);
				continue;
			}
			
			var el = new StatusIcons();
			el.x = cx;
			el.y = 5;
			el.gotoAndStop(o.fr+1);
			el.filters = [new flash.filters.DropShadowFilter(1, 45, 0, 1, 0, 0, 1)];
			addChild(el);
			icons.push({mc:cast el,sk:o.sk,sta:o.sta,num:o.num});
			
		
			if ( o.num > 1 ) {
				var tf = TField.get(0xFFFFFF);
				Filt.glow(tf, 2, 4, 0);
				el.addChild(tf);
				tf.text = "x" + o.num;
				tf.x = 4;
				tf.y = 4;
			}
			
			Game.me.makeHint(el, o.hint);
			cx -= 18;
		}
		
		
		for ( o in olds ){
			removeChild(o.mc);
			o.mc.removeEvents();
		}
		
		
		//
		
		title.visible = cx > title.textWidth-10;

	}
	
	public function getIcon(?sta:StatusType,?sk:SkillType) {
		for ( o in icons ) if ( o.sta == sta && o.sk == sk ) return o.mc;
		return null;
	}
	
	public function show(sta:StatusType) {
		var icon = getIcon(sta);
		if ( icon == null ) return;
		new mt.fx.Radiate(icon, 0.2, 0xFFFFFF, 40);
	}
	
	public function getCounterGlobalPos(id) {
		var mc = counters[id];
		return {
			x:hero.board.x + x + mc.x + 6,
			y:hero.board.y + y + mc.y + 6
		};
	}
}






























