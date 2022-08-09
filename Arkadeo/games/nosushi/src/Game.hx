import api.AKApi;
import api.AKProtocol;
import TitleLogo;
using mt.bumdum9.MBut ;

enum Step {
	S_InitCreate;
	S_Play;
	S_Bombe;
	S_Break;
	S_TurnBonus;
	S_Gravity;
	S_Create;
	S_End;
	S_Void;
}

enum Bonus {
	@proba(1400) B_None;
	@proba(5) B_Dynamite;
	@proba(5) B_Bombe;
	@proba(3) B_MorePlay;
	@proba(10) B_X2;
	@proba(0) B_AK1;
	@proba(0) B_AK2;
	@proba(0) B_AK3;
	@proba(0) B_AK4;
}

typedef MiniContract = {>MC, _block: gfx.Bloc};
typedef BG = {> MC, _moves: TF, _contract1: MiniContract, _contract2: MiniContract, _contract3: MiniContract, _text: TF};
typedef ContractMC = {> MC, _jauge: {>MC, _completed: MC, _over: MC}, _contract: MC, _score: TF};

class Game extends SP, implements game.IGame {

	public static var GRID_SIZE = 9;

	public static var WIDTH = 600 ;
	public static var HEIGHT = 480 ;

	public static var DP_BG = 		0;
	public static var DP_CONTRACT = 		1;
	public static var DP_TRAY = 4;
	public static var DP_BLOCKS = 		5;
	public static var DP_PART = 6;
	public static var DP_TOPPART = 7;
	public static var DP_FG = 10;

	public static var DELTA_X : Int;
	public static var DELTA_Y : Int;

	public static var RAY = 24;
	public static var TRAY_SIZE = RAY * GRID_SIZE * 2;

	public static var me : Game;

	public static var START_PLAY = AKApi.const(20);
	public static var BONUS_ASPIRINE = AKApi.const(5);
	public static var PTS = AKApi.const(10);

	public static var MAX_ID = AKApi.const(3);
	public static var BLACK_ID = AKApi.const(4);

	public static var BONUS_MIN_LEVEL = AKApi.const(3);
	public static var BOMBE_MIN_LEVEL = AKApi.const(5);
	public static var BOMBE_TIMER = AKApi.const(3);

	public static var MAX_MOREPLAY = AKApi.const(2);

	public static var PROGRESSION_CONTRACTS = [
		AKApi.aconst([900, 1200]),
		AKApi.aconst([500, 800, 1000]),
		AKApi.aconst([2000, 5000]),
		AKApi.aconst([500,2500,1000]),
		AKApi.aconst([800,4000,1000]),
		AKApi.aconst([5000, 500,2000]),
		AKApi.aconst([4000, 4000]),
		AKApi.aconst([12000]),
		AKApi.aconst([500, 6000, 6000]),
		AKApi.aconst([7000,8000]),
		AKApi.aconst([1000, 2000, 3000]),
		AKApi.aconst([2000, 3000, 4000]),
		AKApi.aconst([3000, 5000, 2000]),
		AKApi.aconst([8000, 9000]),
		AKApi.aconst([3000,4000,5000]),
		AKApi.aconst([2000, 3000, 9000]),
		AKApi.aconst([3000, 5000, 4000]),
		AKApi.aconst([9000, 3000, 5000]),
		AKApi.aconst([6000, 7000, 8000]),
		AKApi.aconst([7000,8000,9000]),
	];

	public static var BLACK_PROBA = AKApi.aconst([
		0, 0, 0, 0, 0, 0, 0, 200, 170, 150,
		130, 110, 100, 90, 90, 80, 80, 80, 80, 75
	]);

	public static var ID_COLORS = [0xE07450,0xF09585,0xFAD777];

	public var leftPlay : mt.flash.Volatile<Int>;
	public var emptyCells : mt.flash.Volatile<Int>;

	public var contractPts : mt.flash.Volatile<Int>;

	public var contractStep : mt.flash.Volatile<Int>;
	public var contractSteps : mt.flash.Volatile<Int>;

	public var contractReqs : Null<Array<api.AKConst>>;
	public var contractIds : Null<Array<api.AKConst>>;

	public var blackProba : mt.flash.Volatile<Int>;

	public var grid : Array<Array<Block>>;
	public var dm : mt.DepthManager;
	public var bg : BG;
	public var tray : MC;
	public var dmtray : mt.DepthManager;
	public var dmplates : mt.DepthManager;
	public var plates : Array<gfx.Plate>;
	public var curPlate : gfx.Plate;
	public var seed : mt.Rand;
	public var fxm : mt.fx.Manager;

	public var contractInfo : {maxContract: Int, completedMask: fx.CircleMask.CMState, overMask: fx.CircleMask.CMState, mc: ContractMC};
	public var contractMCs : Array<MiniContract>;

	public var step : Step;
	public var waitingFx : Int;
	public var lockPlay : Int;
	public var lockFrames : Int;

	public var rotate : Array<Bool>;
	public var bombs : Array<Block>;

	public var prizeTokens : Array<SecureInGamePrizeTokens>;
	public var totalPrizeTokens : mt.flash.Volatile<Int>;
	public var globalProgression : mt.flash.Volatile<Float>;

	var curGroup : Null<Group>;

	public var curMoreplay : mt.flash.Volatile<Int>;

	public function new(){
		#if dev
		//haxe.Firebug.redirectTraces();
		#end

		super();

		var raw = haxe.Resource.getString("texts."+AKApi.getLang()+".xml");
		if( raw == null )
			raw = haxe.Resource.getString("texts.en.xml");
		Text.init( raw );

		me = this;
		seed = new mt.Rand(AKApi.getSeed());
		dm = new mt.DepthManager(this);
			
		tray = new MC();
		dm.add(tray,DP_TRAY);
		dmtray = new mt.DepthManager(tray);

		var plates = new MC();
		dm.add(plates,DP_TRAY);
		dmplates = new mt.DepthManager(plates);

		var mcMask = new MC();
		dmplates.add(mcMask,0);
		plates.mask = mcMask;
		var x = 459;
		mcMask.graphics.beginFill(0xFF00FF);
		mcMask.graphics.moveTo(x,0);
		mcMask.graphics.lineTo(600,0);
		mcMask.graphics.lineTo(600,480);
		mcMask.graphics.lineTo(x,480);
		mcMask.graphics.lineTo(x,0);
		mcMask.graphics.endFill();


		fxm = new mt.fx.Manager();

		waitingFx = 0;
		leftPlay = START_PLAY.get();
		curMoreplay = 0;

		rotate = [];
		bombs = [];

		prizeTokens = api.AKApi.getInGamePrizeTokens();
		totalPrizeTokens = prizeTokens.length;
		
		initStage();

		switch( AKApi.getGameMode() ){
			case GM_PROGRESSION:
				initContracts();
				contractStart();
				blackProba = BLACK_PROBA[AKApi.getLevel()-1].get();
				globalProgression = 0;
			case GM_LEAGUE:
				contractSteps = 0;
				blackProba = 0;
		}

		setStep(S_InitCreate);
		lockPlay = 0;
	}

	public function rand(n) : Int {
		return seed.random(n) ;
	}

	function initContracts(){
		bg._text.text = Text.contracts;
		
		contractMCs = [bg._contract1,bg._contract2,bg._contract3];

		contractReqs = PROGRESSION_CONTRACTS[AKApi.getLevel()-1];
		contractSteps = contractReqs.length;
		var a = [];

		var ids = [];
		for( i in 0...MAX_ID.get() )
			ids.push(i);

		for( i in 0...contractSteps ){
			var id = ids[rand(ids.length)];
			if( AKApi.getLevel() <= 12 ){
				ids.remove(id);
			}

			a.push(id);
			
			contractMCs[i].gotoAndStop( i==0 ? 2 : 1 );
			contractMCs[i]._block.gotoAndStop( id+1 );
		}
		for( i in contractSteps...3 )
			contractMCs[i].visible = false;

		contractIds = AKApi.aconst(a);
		contractStep = 0;
		contractPts = 0;

		var id = contractIds[0].get();

		var c : ContractMC = cast new gfx.Contract();
		contractInfo.mc = c;

		c.gotoAndStop(id+1);
		c.x = 527;
		c.y = 165;

		var r = c._jauge.width/2 + 4;

		var mc = new MC();
		c.addChild( mc );
		c.mask = mc;
		mc.graphics.beginFill(0);
		mc.graphics.drawCircle(0,0,r);
		mc.graphics.endFill();

		c._jauge.scaleX = c._jauge.scaleY = 0.1;
		mc.scaleX = mc.scaleY = 0.1;
		new mt.fx.Grow(c._jauge,0.1,1);
		var f = new mt.fx.Grow(mc,0.1,1);
		f.onFinish = function(){
			c.removeChild(mc);
			c.mask = null;
		}

		//
		var mc = new MC();
		c._jauge._completed.addChild( mc );
		c._jauge._completed.mask = mc;

		contractInfo.completedMask = new fx.CircleMask.CMState(mc);

		var mc = new MC();
		c._jauge._over.addChild( mc );
		c._jauge._over.mask = mc;

		contractInfo.overMask = new fx.CircleMask.CMState(mc);
		dm.add(c,DP_CONTRACT);

	}

	function contractStart(){
		setContractScore();
		lockPlay--;
		if( contractStep >= contractSteps )
			return;
	}

	function setContractScore( anim = false ){
		// TODO Anim

		var s = contractReqs[contractStep].get() - contractPts;
		if( s < 0 )
			s = 0;
		
		contractInfo.mc._score.text = Std.string( s );

		var tf = contractInfo.mc._score.getTextFormat();
		tf.color = ID_COLORS[ contractIds[contractStep].get() ];
		contractInfo.mc._score.setTextFormat(tf);
	}

	function contractEnd(){
		new mt.fx.Radiate(contractInfo.mc._jauge,0.1,null,15);

		var m = contractInfo.mc._contract;
		var f = new fx.Alpha( m, 0 );
		f.onFinish = function(){
			contractMCs[contractStep-1].gotoAndStop(3);
			contractMCs[contractStep-1]._block.gotoAndStop( contractIds[contractStep-1].get()+1 );

			if( contractStep >= contractSteps ){
				lockPlay--;
				return;
			}

			var id = contractIds[contractStep].get();
			contractInfo.mc.gotoAndStop( id + 1 );

			m = contractInfo.mc._contract;
			m.gotoAndStop(1);
			m.alpha = 0;

			contractInfo.completedMask.reset();
			contractInfo.overMask.reset();

			contractMCs[contractStep].gotoAndStop(2);
			contractMCs[contractStep]._block.gotoAndStop( contractIds[contractStep].get()+1 );

			setContractScore();
			var f = new fx.Alpha(m,1);
			f.onFinish = function(){
				contractStart();
			}
		}
	}

	function contractParticule( n : Int ){
		var col = ID_COLORS[ contractIds[contractStep].get() ];
		for( i in 0...n ){
			var mc = new SP();
			mc.graphics.beginFill(col,0.8);
			mc.graphics.drawCircle(0,0,1);
			mc.graphics.endFill();

			mc.graphics.beginFill(col,0.4);
			mc.graphics.drawCircle(0,0,3);
			mc.graphics.endFill();

			mc.graphics.beginFill(col,0.2);
			mc.graphics.drawCircle(0,0,6);
			mc.graphics.endFill();
			mc.cacheAsBitmap = true;

			mc.alpha = 0;
			mc.visible = false;
			dm.add(mc,DP_PART);

			mc.blendMode = flash.display.BlendMode.ADD;

			var d = Math.round(i*1.2);

			var f = new fx.Alpha(mc, 1, 0.1);
			new mt.fx.Sleep(f, function() mc.visible = true, d );

			var f = new fx.ContractPart(mc,new PT(488 + (contractStep) * 40,48));
			f.curveIn(1.5);
			new mt.fx.Sleep(f, null, d );
		}
	}

	public function contractAdd( pts : api.AKConst ){
		contractPts += pts.get();
		
		var r = contractReqs[contractStep].get();

		var t = 0;
		for( i in 0...contractSteps )
			t += contractReqs[i].get();

		var d = 0;
		for( i in 0...contractStep )
			d += contractReqs[i].get();

		globalProgression = (d+contractPts)/t;

		AKApi.setProgression( globalProgression );

		setContractScore( true );
		
		var p = contractPts/r;
		var s = if( p >= 1 ) "step5";
		else if( p >= 0.75 ) "step4";
		else if( p >= 0.50 ) "step3";
		else if( p >= 0.25 ) "step2";
		else "step1";
		var f = new fx.CircleMask( contractInfo.completedMask, 0.05, p );
		lockPlay++;
		f.onFinish = function(){
			lockPlay--;
		}

		var f = new fx.Play(contractInfo.mc._contract,null,s);
		contractParticule( Math.round((f.endFrame - f.startFrame) / 3) );
		lockPlay++;
		if( contractPts >= r ){
			f.onFinish = contractEnd;
			contractPts = 0;
			contractStep++;
		}else{
			f.onFinish = function(){
				lockPlay--;
			}
		}
	}

	function initStage(){
		bg = cast new gfx.Bg();
		bg.gotoAndStop( AKApi.getGameMode()==GM_PROGRESSION ? 1 : 2 );
		dm.add(bg,DP_BG);

		var m = 0;
		for( a in PROGRESSION_CONTRACTS )
			for( b in a )
				if( b.get() > m ) m = b.get();

		contractInfo = {
			maxContract: m,
			completedMask: null,
			overMask: null,
			mc: null
		};


		//ALPHA FG
		var fg = new SP() ;
		fg.graphics.beginFill(0xeeeeee, 0) ;
		fg.graphics.drawRect(0, 0, WIDTH, HEIGHT ) ;
		fg.useHandCursor = true ;
		dm.add(fg, DP_FG) ;
		fg.onClick(onClick) ;


		var plateau = new gfx.Plateau();
		dmtray.add(plateau,DP_TRAY);

		DELTA_X = Std.int(TRAY_SIZE / 2) + 7;
		DELTA_Y = RAY + 4;

		grid = [];
		for( x in 0...GRID_SIZE ){
			grid[x] = [];
		}
	}

	public function enqueueBomb( b : Block ){
		bombs.push(b);
	}

	public function addPlay( p : Int ){
		if( leftPlay + p > START_PLAY.get() )
			p = START_PLAY.get() - leftPlay;
		leftPlay += p;

		for( i in 0...p )
			addPlate();
		updateMoves();
	}

	public function updateMoves(){
		bg._moves.text = Std.string( leftPlay );
	}

	function addPlate( init = false ){
		var p = new gfx.Plate();
		dmplates.add(p,1);
		p.x = 400;
		var fy = 340 - plates.length*6;
		if( init ){
			p.y = fy;
		}else{
			p.y = fy - 80;
			new mt.fx.Tween(p,p.x,fy);
			new mt.fx.Spawn(p);
		}
		plates.push( p );
	}

	function checkEnd(){
		if( AKApi.getGameMode() == GM_PROGRESSION ){
			if( contractStep >= contractSteps ){
				setStep(S_End);
				return true;
			}
		}
		if( leftPlay <= 0 ){
			setStep(S_End);
			return true;
		}

		return false;
	}

	public function setStep( s : Step ){
		if( s == S_Play && lockPlay > 0 )
			return;
		step = s;
		switch( step ){
		case S_InitCreate:
			create(true);
			plates = new Array();
			for( i in 0...leftPlay )
				addPlate(true);
		case S_Play:
			if( checkEnd() )
				return;
			initGroups();

			curPlate = plates.shift();
			new mt.fx.Tween(curPlate,495,curPlate.y);

			var i = 0;
			for( p in plates ){
				new mt.fx.Sleep(new mt.fx.Tween(p,p.x,p.y+6,0.4),null,i*2);
				i++;
			}
		case S_Break:

		case S_TurnBonus:
			for( x in 0...GRID_SIZE ){
				for( y in 0...GRID_SIZE ){
					var b = grid[x][y];
					if( b != null )
						b.turnBonus();
				}
			}
			if( waitingFx == 0 )
				setStep(S_Gravity);
		case S_Gravity:
			if( bombs.length > 0 ){
				setStep(S_Bombe);
				return;
			}

			if( checkEnd() )
				return;
			lockFrames = 25;
			gravity();
		case S_Create:
			create( false );
		case S_Bombe:
			var bomb = bombs.shift();
			bomb.showBombe();
			
			var a = new Array<Block>();

			function bombBlocks(){
				for( b in a ){
					bombs.remove( b );
					b.breakBmp();
					var f = new mt.fx.Part(b.mc);
					f.timer = 6;
					var mc = new gfx.Explode();
					mc.x = b.mc.x + tray.x;
					mc.y = b.mc.y + tray.y;
					mc.scaleX = mc.scaleY = b.mc.scaleX;
					dm.add(mc,DP_PART);

					var p = new mt.fx.Part(mc);
					p.setScale(mc.scaleX);
					p.timer = 25;
					addFx(p,function(){
						b.exec(false,false,a.length,0);
					});
				}
			}

			if( bomb.bonus == B_Bombe ){
				var d = 2;
				for( x in 0...GRID_SIZE ){
					for( y in 0...Game.GRID_SIZE ){
						var b = Game.me.grid[x][y];
						if( b != null ){
							var dx = (bomb.x-x);
							var dy = (bomb.y-y);
							if( dx*dx + dy*dy <= d*d )
								a.push(b);
						}
					}
				}

				var mc = new SP();
				mc.graphics.beginFill(0xFFFFFF,1);
				mc.graphics.drawCircle(0,0,(RAY / Math.cos(Math.PI/4) )*d);
				mc.graphics.endFill();
				mc.x = bomb.mc.x + tray.x;
				mc.y = bomb.mc.y + tray.y;
				mc.filters = [
					new flash.filters.GlowFilter(0xFFCC00,1,30,30,2)
				];
				mc.scaleX = mc.scaleY = 0.01;
				dm.add(mc,DP_PART);

				var fx = new mt.fx.Grow(mc,0.1,1);
				addFx(fx,function(){
					mc.parent.removeChild(mc);
					bombBlocks();
				});
			}else if( bomb.bonus == B_Dynamite ){
				for( i in 0...GRID_SIZE ){
					var b = grid[bomb.x][i];
					if( b != null )
						a.push(b);
					var b = grid[i][bomb.y];
					if( b != null && b != bomb )
						a.push(b);
				}

				var l = RAY / Math.cos(Math.PI/4);

				var n = [bomb.x,bomb.y,GRID_SIZE-bomb.x-1,GRID_SIZE-bomb.y-1];
				
				var mc = new SP();
				mc.x = bomb.mc.x + tray.x;
				mc.y = bomb.mc.y + tray.y;
				dm.add(mc,DP_PART);
				var f = 4;
				for( i in 0...4 ){
					var line = new SP();
					line.graphics.lineStyle(l*0.7,0xeefd9a);
					line.graphics.drawRect(0,0,0,l*n[i]);
					line.rotation = 135+90*i;
					mc.addChild(line);
					line.scaleY = 0;
					var fx = new mt.fx.Grow(line,1.2/n[i],1,2);
					addFx(fx,function(){
						f--;
						if( f == 0 ){
							line.parent.removeChild(line);
							mc.parent.removeChild(mc);
							bombBlocks();
						}
					});
				}
				mc.filters = [
					new flash.filters.GlowFilter(0xFFCC00,1,30,30,2)
				];

			}
		case S_End:

			for( x in 0...GRID_SIZE ){
				for( y in 0...GRID_SIZE ){
					var b = grid[x][y];
					if( b != null ){
						b.vanish();
					}
				}
			}
			Game.me.addFx(new fx.Sleep(50));
			
		case S_Void:
		}
	}

	public function addFx( x : mt.fx.Fx, ?onEnd : Void -> Void ){
		waitingFx++;
		x.onFinish = function(){
			if( onEnd != null )
				onEnd();
			fxEnd();
		}
		return x;
	}

	function fxEnd(){
		waitingFx--;
	}

	/*
	function debugGrid(){
		var s = new SP();
		s.alpha = 0.2;
		dm.add(s,DP_FG);
	
		var ac = [
			0xFF0000,
			0x00FF00,
			0x0000FF,
			0xFFFF00
		];
		
		for( x in 0...WIDTH ){
			for( y in 0...HEIGHT ){
				var p = convertPos(x,y);
				if( p.x >= 0 && p.y >= 0 && p.x < GRID_SIZE && p.y < GRID_SIZE ){
					var b = grid[p.x][p.y];
					var c = ac[b.id];

					s.graphics.beginFill(c);

					s.graphics.drawRect(x,y,1,1);
				}
			}
		}
		s.graphics.endFill();

	}
	*/

	function initGroups(){
		for( x in 0...GRID_SIZE ){
			for( y in 0...GRID_SIZE ){
				grid[x][y].group = null;
			}
		}

		for( x in 0...GRID_SIZE ){
			for( y in 0...GRID_SIZE ){
				var b = grid[x][y];
				if( b.group != null )
					continue;
				b.makeGroup(new Group(b.id));
			}
		}
	}


	public function update( render : Bool ){
		fxm.update();

		switch( step ){
		case S_Void:
		case S_End:
			if( waitingFx == 0 ){
				var win = switch( AKApi.getGameMode() ){
					case GM_PROGRESSION: contractStep >= contractSteps;
					case GM_LEAGUE: true;
				}
		
				AKApi.gameOver(win);
				setStep( S_Void );
			}
		case S_Play:
			if( !AKApi.isReplay() )
				updateSelection();
			var e = AKApi.getEvent();
			if( e != null ){
				var x = Math.floor(e/100);
				var y = e%100;
				var b = grid[x][y];
				if( b != null && b.group != null ){
					b.group.onClick();
				}
			}
		case S_Break:
			if( waitingFx == 0 )
				setStep(S_TurnBonus);
		case S_TurnBonus:
			if( waitingFx == 0 )
				setStep(S_Gravity);
		case S_Gravity:
			lockFrames--;
			dmtray.ysort(DP_BLOCKS);
			if( waitingFx == 0 )
				gravity();
		case S_Create,S_InitCreate:
			if( waitingFx == 0 )
				setStep(S_Play);
		case S_Bombe:
			if( waitingFx == 0 )
				setStep(S_Gravity);
		}
		
	}

	function gravity(){
		var l = new List();
		for( y in 0...GRID_SIZE ){
			var empty = false;
			for( x in 0...GRID_SIZE ){
				var rx = GRID_SIZE-x-1;
				var b = grid[rx][y];
				if( b == null )
					empty = true;
				else if( empty ){
					b.gravityLeft();
					l.add(b);
				}
			}
		}
		if( l.length > 0 )
			return;
		for( x in 0...GRID_SIZE ){
			var empty = false;
			for( y in 0...GRID_SIZE ){
				var ry = GRID_SIZE-y-1;
				var b = grid[x][ry];
				if( b == null )
					empty = true;
				else if( empty ){
					b.gravityDown();
					l.add(b);
				}
			}
		}

		if( l.length == 0 && lockFrames <= 0 )
			setStep(S_Create);
	}

	function create( isInit : Bool ){
		emptyCells = 0;
		for( x in 0...GRID_SIZE ){
			for( y in 0...GRID_SIZE ){
				if( grid[x][y] == null ){
					emptyCells++;
				}
			}
		}
		
		for( x in 0...GRID_SIZE ){
			for( y in 0...GRID_SIZE ){
				if( grid[x][y] == null ){
					grid[x][y] = new Block(x,y,isInit);
				}
			}
		}
		dmtray.ysort(DP_BLOCKS);
		//debugGrid();
	}

	public function filteredPrizeTokens(){
		var a = [];
		var s = AKApi.getGameMode()==GM_PROGRESSION ? 1 : AKApi.getScore();
		for( p in prizeTokens )
			if( p.score.get() <= s )
				a.push(p);
		return a;
	}

	public function getPrizeToken(){
		var s = AKApi.getGameMode()==GM_PROGRESSION ? 1 : AKApi.getScore();
		var p = prizeTokens[0];
		if( p.score.get() <= s )
			return prizeTokens.shift();
		throw "Oops";
	}

	function updateSelection(){
		var p = convertPos(mouseX,mouseY);

		var b = null;
		if( grid[p.x] != null  )
			b = grid[p.x][p.y];

		var g = b!=null ? b.group : null;

		if( g != curGroup ){
			if( curGroup != null )
				curGroup.onOut();
			curGroup = g;
			if( curGroup != null )
				curGroup.onOver();
		}
	}

	function onClick(){
		if( step != S_Play )
			return;

		var p = convertPos(mouseX,mouseY);
		var b = null;
		if( grid[p.x] != null  )
			b = grid[p.x][p.y];
		if( b != null )
			AKApi.emitEvent(b.x*100 + b.y);
	}

	function convertPos( x : Float, y : Float ){
		var cx = x - DELTA_X - tray.x;
		var cy = y - DELTA_Y + RAY - tray.y;

		var ax = (cy / RAY + cx / RAY)/2;
		var ay = (-cx / RAY + cy / RAY)/2;
		
		return {
			x: Math.floor(ax),
			y: Math.floor(ay)
		};
	}

	public function findSameBlock( block : Block ){
		for( x in 0...GRID_SIZE ){
			for( y in 0...GRID_SIZE ){
				var b = grid[x][y];
				if( b == null || b == block )
					continue;
				if( b.id == block.id && b.bonus == block.bonus )
					return true;
			}
		}
		return false;
	}

	public static function flatten(o:flash.display.DisplayObject) {
		var b = o.getBounds(o);
		var bmp = new flash.display.Bitmap( new flash.display.BitmapData(Math.ceil(b.width), Math.ceil(b.height), true, 0x0) );
		var m = new flash.geom.Matrix();
		m.translate(-b.x, -b.y);
		bmp.bitmapData.draw(o, m, o.transform.colorTransform);
		bmp.x = b.x;
		bmp.y = b.y;
		var sp = new SP();
		sp.addChild(bmp);
		return sp;
	}

}
