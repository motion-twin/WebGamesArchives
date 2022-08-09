import haxe.zip.Entry;
import mt.bumdum9.Lib;
import mt.kiroukou.events.Signaler;
import Protocol;
import api.AKApi;
import api.AKProtocol;
import TitleLogo;
/**
 * FAMILY
 */
using Lambda;
using mt.Std;
using GridTools;
@:build(mt.kiroukou.macros.IntInliner.create([
[
	DP_BG, DP_BLOOD, DP_SHADE, DP_GROUND, DP_ENTS, DP_PLASMA, DP_ENTS_FLY, DP_FX, DP_FG, DP_INTER, DP_UI,
],
[ 
	AK_EVENT_SQUARE_SELECTED, AK_EVENT_MOVE_CANCELLED
]
]))
class Game extends SP, implements Signaler
{
	
	public static var XMAX = 8;
	public static var YMAX = 8;
	public static var CX = (Cs.WIDTH - (XMAX*Cs.SQ)) >> 1;
	public static var CY = (Cs.HEIGHT - (YMAX*Cs.SQ)) >> 1;
	
	public static var TEXT =  ods.Data.parse("data.ods", "text", DataText);
	
	public var gtimer:Int;
	public var bloodsafe:Int;
	public var turns:Int;
	public var forceZSort:Bool;
	
	public var bg:SP;
	public var shadeLayer:SP;
	public var bloodLayer:SP;
	public var stamp:BMD;

	public var seed:mt.Rand;

	public var squares	: Array<Square>;
	public var balls	: Array<ent.Ball>;
	public var ents		: Array<Ent>;
	public var pool		: Array<BallType>;
	public var completePool		: Array<BallType>;
	//public var obj:mt.flash.Volatile<Int>;
	//public var ballValidated:api.AKConst;
	public var currentTurn : api.AKConst;
	
	public var queue:Queue;
	public var plasma:BMD;
	public var blood:BMD;
	public var runState:RunState;
	public var rules:RoundRules;
	public var extraRound:Array<RoundRules>;
	
	public var fxm:mt.fx.Manager;
	public var dm:mt.DepthManager;
	public static var me:Game;
	
	public var infosPanel : seq.ShowBallInfo;
	
	var pkPop : PKPop; /* class distributing ingame PK */

	public var scoreObjective : api.AKConst;
	
	@:signal public function onSquareSelected( square : Square ) { }
	@:signal public function onMoveCancelled() { }
	
	public function new() 
	{
		super();
		me = this;
		
		var raw = haxe.Resource.getString(AKApi.getLang());
		if( raw == null ) raw = haxe.Resource.getString("en");
		Texts.init( raw );
		
		fxm = new mt.fx.Manager();
		mt.fx.Fx.DEFAULT_MANAGER = fxm;
		dm = new mt.DepthManager(this);
		gtimer = 0;
		bloodsafe = 0;
		forceZSort = false;
		
		//ballValidated = api.AKApi.const(0);
		currentTurn = api.AKApi.const(0);
		//
		seed = new mt.Rand( AKApi.getSeed() + AKApi.getLevel() );
		turns = 0;
		balls = [];
		ents = [];
		initBg();
		initGrid();
		stamp = new BMD(100, 100, true, 0);
		
		// SHADE
		shadeLayer = new SP();
		shadeLayer.blendMode = flash.display.BlendMode.LAYER;
		shadeLayer.alpha = 0.25;
		dm.add(shadeLayer, DP_SHADE);
		
		// QUEUE
		queue = new Queue();
		dm.add(queue, DP_INTER);
		
		// PLASMA
		plasma = new BMD(Cs.WIDTH, Cs.HEIGHT, true, 0x40FF0000);
		var mc = new BMP(plasma);
		dm.add(mc, DP_PLASMA);
		
		// BLOOD
		blood = new BMD(Cs.WIDTH, Cs.HEIGHT, true, 0);
		var mc = new BMP(blood);
		mc.blendMode = flash.display.BlendMode.MULTIPLY;
		dm.add(mc, DP_BLOOD);
		
		pkPop = new PKPop();
		// GAME MOVE
		switch(AKApi.getGameMode()) 
		{
			case GM_PROGRESSION :
				var lvl = AKApi.getLevel();
				scoreObjective = AKApi.const( Cs.SCORE_OBJECTIVE.get() + (lvl - 1) * Cs.SCORE_OBJECTIVE_INC.get() );
				if( lvl >= Cs.SCORE_OBJECTIVE_HARD_LEVEL.get() )
					scoreObjective.add( AKApi.const( (lvl - Cs.SCORE_OBJECTIVE_HARD_LEVEL.get() + 1) * Cs.SCORE_OBJECTIVE_HARD_INC.get() ) );
				//
				AKApi.setStatusText( Texts.objective_points( { _points:scoreObjective.get() } ), "center" );
				//
				if ( lvl == 1 )
				{
					pool = Cs.RUN_POOL;
					completePool = pool.copy();
					saveState();
					new seq.Play();
				}
				else 
				{
					var runState = AKApi.getState();
					if ( runState == null ) 
					{
						pool = Cs.RUN_POOL;
					} 
					else 
					{
						pool = runState.pool;
					}
					//
					completePool = pool.copy();
					pool = pool.shuffle(Game.me.seed.random).splice(0, 3);
					//
					saveState();
					var up = false;
					for( lim in Cs.RUN_UPG_THRESHOLDS ) up = up || lvl == lim;
					if( up ) 	new seq.ChooseBallType();
					else		new seq.Play();
				}
			
			case GM_LEAGUE :
				scoreObjective = AKApi.const(-1);
				
				var all = ent.Ball.DATA.map(function(data) return data.id ).array();
				for( p in Cs.RUN_POOL )
					all.remove(p);
				
				for( p in Cs.DISABLED_POOL )
					all.remove(p);
				
				pool = all.shuffle(seed.random).splice(0, 2);
				pool.addFirst(Cs.RUN_POOL.copy().shuffle(seed.random).first());
				
				new seq.Play();
			
			default:
				throw "unknown game mode";
		}
		
		if( !AKApi.isReplay() )
		{
			infosPanel = new seq.ShowBallInfo();
			infosPanel.hide();
		}
	}
	
	function initBg() 
	{
		var mc = new gfx.Bg();
		var bmd = new BMD(Cs.WIDTH, Cs.HEIGHT, false, 0);
		bmd.draw(mc);
		var bmp = new BMP(bmd);
		var bg = new SP();
		bg.addChild(bmp);
		dm.add(bg, DP_BG);
		
		var fg = new gfx.Foreground();
		fg.y = Cs.HEIGHT;
		dm.add(fg, DP_FG);
	}
	
	public function emitSquareSelectedEvent( square : Square )
	{
		if ( square != null )
		{
			api.AKApi.emitEvent(AK_EVENT_SQUARE_SELECTED);
			api.AKApi.emitEvent( square.getId() );
		}
	}
	
	public function emitMoveCancelEvent()
	{
		api.AKApi.emitEvent(AK_EVENT_MOVE_CANCELLED);
	}
	
	// UPGRADE
	public function update(render:Bool) 
	{
		gtimer++;
		for( e in ents.copy() )
			e.update();
		
		fxm.update();
		
		var e = api.AKApi.getEvent();
		while( e != null )
		{
			switch(e)
			{
				case AK_EVENT_SQUARE_SELECTED:
				{
					var squareId = api.AKApi.getEvent();
					var square = this.squares[squareId];
					this.dispatchOnSquareSelected( square );
				}
				case AK_EVENT_MOVE_CANCELLED :
				{
					this.dispatchOnMoveCancelled();
				}
				default : throw "Unknown event : " + e;
			}
			//
			e = AKApi.getEvent();
		}
		
		if( render )
			updatePlasma();
	}
	
	function updatePlasma() 
	{
		var ct = new CT(1, 1, 1, 1, 0, 0, 0, -16);
		plasma.colorTransform(plasma.rect, ct);
		
		if ( bloodsafe-- < 0 && bloodsafe > -60 ) 
		{
			var ct = new CT(1, 1, 1, 1, 0, 0, 0, -5);
			blood.colorTransform(blood.rect, ct);
		}
	}
	
	// GRID
	function initGrid() 
	{
		squares = [];
		for ( x in 0...XMAX ) 
		{
			for ( y in 0...YMAX ) 
			{
				var sq = new Square(x, y);
				squares.push(sq);
			}
		}
		
		for ( sq in squares ) 
		{
			for ( d in Cs.DIR )
			{
				var nx = sq.x + d[0];
				var ny = sq.y + d[1];
				var nsq = getSquare(nx, ny);
				sq.dnei.push(nsq);
				if( nsq!= null ) sq.nei.push(nsq);
			}
		}
	}
	
	public function getSquare(x, y) 
	{
		if( !isIn(x, y) ) return null;
		return squares[x*YMAX+y];
	}
	
	inline public function isIn(x, y) 
	{
		return x >= 0 && x < XMAX && y >= 0 && y < YMAX;
	}
	
	public function getPos(px:Float, py:Float) 
	{
		return {
			x : CX + px * Cs.SQ,
			y : CY + py * Cs.SQ,
		}
	}
	
	public function getRandomFreeSquare() 
	{
		var a = [];
		for ( sq in squares )
		{
			if ( sq.isFree() )
			{
				a.push(sq);
			}
		}
		
		return a[Game.me.random(a.length, "getRandomFreeSquare")];
	}
	
	public function getMouseSquare() 
	{
		var x = Std.int((mouseX - CX) / Cs.SQ);
		var y = Std.int((mouseY - CY) / Cs.SQ);
		return getSquare(x, y);
	}
	
	public function getRandomBall()
	{
		return Game.me.balls[Std.random(balls.length)];
	}

	public function buildGrid() 
	{
		// GRID
		var grid = [];
		for( x in 0...Game.XMAX ) grid[x] = [];
		for( b in Game.me.balls ) grid[b.square.x][b.square.y] = b;
		return grid;
	}

	// COMBOS
	var stack:Array<ent.Ball>;
	public function buildCombos() 
	{
		stack = [];
		for( b in Game.me.balls ) 
		{
			b.score = 0;
			b.combos = [];
		}
		
		// FROGS
		var frogs = [];
		for( b in Game.me.balls )
		{
			if ( b.type == _FROG )
			{
				frogs.push(b);
			}
		}
		
		for( b in frogs )
		{
			if( b.score > 0 ) continue;
			var a = expandFrogs(b);
			if( a.length < Cs.COMBO_MINIMUM ) 
			{
				for( ball in a )
					ball.score = 0;
			} 
			else 
			{
				b.combos.push(a);
			}
		}
		// GRID
		var grid = buildGrid();
		// FUNC
		function check(x, y) 
		{
			var ball = grid[x][y];
			if( ball == null || ball.type == _FROG ) 
			{
				endStack();
				return;
			}
			
			if( stack.length > 0 && ball.type != stack.first().type ) 
			{
				endStack();
				stack.push(ball);
				return;
			}
			stack.push(ball);
		}
		// VERTICAL
		for( x in 0...Game.XMAX ) 
		{
			for ( y in 0...Game.YMAX )
			{
				check(x, y);
			}
			endStack();
		}
		// HORIZONTAL
		for( y in 0...Game.YMAX ) 
		{
			for( x in 0...Game.XMAX )
				check(x,y);
			endStack();
		}
		//CHECK MULTI COMBO (super crade mais bon)
		for( b in Game.me.balls ) 
		{
			if( b.combos.length == 0 ) continue;
			//update score
			var multiplicator = 1;
			var total = 0;
			for( combo in b.combos ) 
			{
				total += combo.length;
				for( ball in combo ) 
				{
					if( ball.square.bonus != null && ball.square.bonus.type == fx.Bonus.BONUS_POINTS_MULT )
					{
						multiplicator++;
					}
				}
			}
			total -= Cs.COMBO_MINIMUM;
			//
			if( b.type == _ELEPHANT ) multiplicator++;
			else if( b.type == _PANDA ) total++;
			//
			var score = multiplicator * ( Cs.SCORE_BALL.get() + total * Cs.SCORE_COMBO_INC.get() );
			for( combo in b.combos )
				for( ball in combo )
					if( score > ball.score )
						ball.score = score;
		}
	}
	
	function endStack() 
	{
		var min = Cs.COMBO_MINIMUM;
		if ( stack.length > 0 && stack.first().type == _PANDA )
		{
			min = 3;
		}
		
		if ( stack.length >= min ) 
		{
			if ( stack.first().type == _SNAKE ) 
			{
				var all = Game.me.balls.copy();
				for( b in stack )
					all.remove(b);
				
				if ( stack.first().x == stack[1].x ) 
				{
					var x = stack.first().x;
					for( b in all )
						if( b.x == x && b.score == 0 )
							b.score = -1;
				}
				else 
				{
					var y = stack.first().y;
					for( b in all )
						if( b.y == y && b.score == 0 )
							b.score = -1;
				}
			}
			
			// BUILD COMBO
			var score = Cs.SCORE_BALL.get() + (stack.length - min) * Cs.SCORE_COMBO_INC.get();
			if( stack.first().type == _ELEPHANT ) score *= 2;
			for ( b in stack ) 
			{
				b.score = score;
				b.combos.push( stack );
			}
		}
		stack = [];
	}
	
	function expandFrogs(frog:ent.Ball) 
	{
		var all = [frog];
		frog.score = 1;
		for ( nei in frog.square.nei ) 
		{
			var b = nei.getBall();
			if( b == null || b.type != _FROG || b.score > 0 ) continue;
			all = all.concat(expandFrogs(b));
		}
		return all;
	}
	
	// STRUCT
	public function newTurn() 
	{
		// OBJECTIF ATTEINT
		if( Game.me.scoreObjective.get() > 0 && api.AKApi.getScore() >= Game.me.scoreObjective.get() ) 
		{
			var count = Game.me.balls.length;
			for ( ball in Game.me.balls ) 
			{
				var e = new fx.Exit(ball, Std.random(10) );
				e.onFinish = function()
				{
					count--;
					if( count == 0 ) AKApi.gameOver(true);
				}
			}			
			return;
		}
		
		// DERNIERE CHANCE
		if( this.getRandomFreeSquare() == null ) 
		{
			new seq.CheckCombo();
			return;
		}
		
		// QUEUE
		queue.next();
		
		// INIT
		rules = { notPlayable:[], blockEffect:[] };
		extraRound = [];
		turns++;
		
		// BONUS
		var rnd = Cs.FREQ_BONUS;
		for( sq in Game.me.squares )
			if( sq.bonus != null )
				rnd <<= 1;
		
		if( Game.me.random(rnd, "freq bonus") == 0 ) 
		{
			var sq = getRandomFreeSquare();
			if(sq != null && sq.isFree())	new fx.Bonus(sq);
		}
		
		// INGAME PK
		pkPop.check(getRandomFreeSquare());
		
		// NEW ROUND
		newRound();
	}

	public function newRound() 
	{
		new seq.SelectBall();
	}
	
	public function endRound() 
	{
		if( extraRound.length > 0 ) 
		{
			rules = extraRound.shift();
			newRound();
		} 
		else 
		{
			new seq.CheckCombo();
		}
	}
	
	public function isEffectAvailable(bt) 
	{
		for( e in rules.blockEffect )
			if( e == bt )
				return false;
		return true;
	}
	
	public function addExtraRound() 
	{
		extraRound.push( { notPlayable:[], blockEffect:[] } );
	}
	
	// FX
	public function incScore(score:Int, ?x, ?y, ?color)
	{
		AKApi.addScore( api.AKApi.const(score) );
		if( x != null) new fx.Score(x, y, score);
	}
	
	public function fxAmbient() 
	{
		if( Std.random(balls.length) == 0 )
		{
			var b = getRandomBall();
			if( b != null && b.skin.smc.currentFrame == 1 )	b.goto("ambiant");
		}
	}
	
	// RUN
	var countLayer:SP;
	public function saveState() 
	{
		AKApi.saveState( { pool:completePool } );
	}
	
	public function getPoolType() 
	{
		return pool[Game.me.random(pool.length, "pooltype")];
	}

	public function getDir(dx, dy)
	{
		if( dx == 1 && dy == 0 )	return 0;
		if( dx == 0 && dy == 1 )	return 1;
		if( dx == -1 && dy == 0 )	return 2;
		if( dx == 0 && dy == -1 )	return 3;
		return -1;
	}
	
	// STATIC
	public static function txt(n) 
	{
		return TEXT[n].txt;
	}
	
	// RANDOM SEED
	public function random(n, str) 
	{
		var n = seed.random(n);
		return n;
	}
}
