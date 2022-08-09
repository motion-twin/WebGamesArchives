import api.AKApi;
import api.AKProtocol;
import mt.flash.Volatile;

enum Step {
	S_Create;
	S_Play;
	S_FPlay;
	S_Gather;
	S_Destroy;
	S_GameOver;
	S_TutoLast;
	S_Void;
}

enum EventType {
	E_Over;
	E_Click;
}

typedef Clock = {>MC,
	_time: MC, 
	_clock: {> MC, _col: MC}
}

typedef ComboMeter = {> MC,
	_txt: {>MC,
		_current: {> MC, _txt: TF},
		_next: {> MC, _txt: TF},
		_txt2: TF
	}
};

class TitleLogo extends gfx.Logo {
}

class Game extends flash.display.Sprite, implements game.IGame {

	public static var TUTO_POS = [
		[[7,2],[2,9],[12,11]],
		null,
		[[7,5],[5,7],[9,7]],
		[[8,0],[1,11],[14,10]],
		null
	];

	public static var W = 600;
	public static var H = 460;

	public static var DP_BOARD = 3;
	public static var DP_BLOCKS = 5;
	public static var DP_GROUP = 6;
	public static var DP_WGROUP = 7;
	public static var DP_PART = 8;
	
	public static var PTS = AKApi.const(1);

	public static var DP_UI = 10;

	public static var DP_RENDER = 40;
	public static var DP_TUTO_TEXT = 41;

	public static var DP_FG = 50;

	public static var GRID_SIZE = AKApi.const(15);
	public static var BLOCK_SIZE = 26;
	public static var PADDING = 12;
	public static var DELTA_X = PADDING + BLOCK_SIZE/2;
	public static var DELTA_Y = PADDING + BLOCK_SIZE/2;

	public static var FP_TIMER_DELTA = AKApi.const(-30);

	public static var FP_TIMER = AKApi.const(800);
	public static var FP_TIMER_MIN = AKApi.const(320);

	public static var START_TIMER = AKApi.const(60*40);
	public static var MAX_TIMER = AKApi.const(60*40);

	public static var TIMER_DELTA = AKApi.const(5*40);
	public static var TIMER_DELTA_DECR = AKApi.const(-40);
	public static var TIMER_DELTA_MIN = AKApi.const(1*40);
	public static var TIMER_DELTA_DECR2 = AKApi.const(-10);
	
	public static var TIMER_PKPROBA_PLAY = AKApi.const(15*40);

	public static var COMBO_RAINBOW = AKApi.const( 10 );
	public static var COMBO_ONECOLOR = AKApi.aconst( [0,0,2,3,5,4,4,4,4,4,4,4,4,4,4,4,4] );

	public static var MAX_ID = AKApi.const(5);

	public static var COLORS = [
		0x6AC24D, // vert
		0xEEC55F, // jaune
		0x5FC7EE, // bleu
		0xB45FEE, // violet
		0xEE7B5F // rouge
	];

	public static var me : Game;

	public var dm : mt.DepthManager;
	public var seed : mt.Rand;
	public var fxSeed : mt.Rand;
	public var fxm : mt.fx.Manager;

	public var group : Null<Group>;
	public var lastGroup : Null<Group>;

	public var fpTimer : Volatile<Int>;
	public var gTimer : Volatile<Int>;
	public var started : Volatile<Bool>;

	public var gblocks : Null<List<Block>>;
	public var combo : Volatile<Int>;
	public var colors : Null<Array<Int>>;
	public var groups : Null<Int>;

	public var grid : Array<Array<Block>>;
	
	public var tuto : Null<Array<Int>>;
	public var tutoLast : Bool;
	public var tutoEnd : Bool;
	public var tutoText : Null<SP>;
	public var overTimer : Null<Int>;

	public var rainbowCombo : Volatile<Bool>;
	public var sameColorGroups : Volatile<Int>;
	
	public var bmd : BMD;

	public var swapingBlocks : Int;

	var render : BMP;

	var clock : Clock;
	var comboMeter : ComboMeter;
	var step : Step;

	var overBlock : Null<Block>;
	var gatherBlock : Null<Block>;

	var contracts : Array<Contract>;
	public var prizeTokens : Array<SecureInGamePrizeTokens>;
	public var totalPrizeTokens : mt.flash.Volatile<Int>;
	public var emptyCells : mt.flash.Volatile<Int>;


	public function new(){
		super();
		#if dev
		haxe.Firebug.redirectTraces();
		#end

		swapingBlocks = 0;
		
		var raw = haxe.Resource.getString("texts."+AKApi.getLang()+".xml");
		if( raw == null )	
			raw = haxe.Resource.getString("texts.en.xml");
		Text.init( raw );

		me = this;
		seed = new mt.Rand(AKApi.getSeed());
		fxSeed = new mt.Rand(seed.random(0xFFFFFF));
		dm = new mt.DepthManager(this);
		fxm = new mt.fx.Manager();
		
		if( AKApi.getGameMode() == GM_PROGRESSION && AKApi.getLevel() == 1 ){
			tuto = [0,0];
		}

		prizeTokens = api.AKApi.getInGamePrizeTokens();
		totalPrizeTokens = prizeTokens.length;

		initStage();

		gTimer = START_TIMER.get();

		setStep( S_Create );

		started = false;
		tutoEnd = false;
		tutoLast = false;
	}

	public function setStep( s : Step ){
		if( step == s )
			return;
		step = s;
		switch( step ){
		case S_Create:
			if( gTimer == 0 ){
				gameOver();
				return;
			}
			initGrid();
			if( AKApi.getGameMode() == GM_PROGRESSION ){
				var done = 0;
				for( c in contracts ){
					if( c.isDone() )
						done++;
				}
				AKApi.setProgression( done/contracts.length );
				if( done == contracts.length ){
					gameOver();
					return;
				}
			}
		case S_TutoLast:
			showTutoText(Text.tuto5);
		case S_Play:
			if( tutoLast ){
				tutoLast = false;
				setStep(S_TutoLast);
				return;
			}
			if( tutoEnd ){
				showText(Text.tuto6, -1, DELTA_X+BLOCK_SIZE*GRID_SIZE.get()/2, DELTA_Y+BLOCK_SIZE*GRID_SIZE.get()/2, 20 );
				tutoEnd = false;
			}
			if( !started )
				started = true;
			overBlock = null;
			combo = 0;
			comboMeter._txt.visible = false;
			colors = [];
			groups = 0;
			rainbowCombo = false;
			sameColorGroups = 0;
			gblocks = null;
			if( tuto != null ){
				if( TUTO_POS[tuto[0]] != null ){
					var p = TUTO_POS[tuto[0]][tuto[1]];
					var block = grid[p[0]][p[1]];
					block.shine();
					showTutoText( Text.tuto0 );
				}
			}
		case S_FPlay:
		case S_Gather:
			if( group != null )
				group.deselect();

			var pts = lastGroup.calcPts();
			AKApi.addScore( pts );

			if( contracts != null ){
				for( c in contracts )
					c.onValidate( pts );
			}

			var center = lastGroup.center();
			var size = 17 + Math.ceil(Math.min(pts.get() / 10000,7));
			showText( Std.string(pts.get()), lastGroup.id, center.x*BLOCK_SIZE+DELTA_X, center.y*BLOCK_SIZE+DELTA_Y, size );

			var m = gatherBlock.center();
			for( b in gblocks ){
				var c = b.center();
				b.gather( lastGroup, Std.int((Math.abs(c.x-m.x)+Math.abs(c.y-m.y))/16) );
			}

			if( gTimer > 0 )
				gTimer += TIMER_DELTA.get() * combo;
			if( gTimer > MAX_TIMER.get() )
				gTimer = MAX_TIMER.get();
			updateClock(true);

			if( TIMER_DELTA.get() > TIMER_DELTA_MIN.get() ){
				TIMER_DELTA.add( TIMER_DELTA_DECR );
			}else if( TIMER_DELTA.get() > -TIMER_DELTA_DECR2.get() ) {
				TIMER_DELTA.add( TIMER_DELTA_DECR2 );
			}

			lastGroup.hide();
			lastGroup = null;
		case S_Destroy:
			if( tuto != null ){
				gameOver();
				return;
			}
			if( group != null )
				group.deselect();
			lastGroup.hide();
			lastGroup = null;
			for( b in gblocks )
				b.destroy();
		case S_GameOver:
			overTimer = 25;
		case S_Void:
		}
	}

	function gameOver(){
		var win = false;
		if( AKApi.getGameMode() == GM_PROGRESSION ){
			var done = true;
			for( c in contracts ){
				if( !c.isDone() )
					done = false;
			}
			win = done;
		}
		AKApi.gameOver( win );
		setStep( S_Void );
	}

	function initStage(){
		var bg = new gfx.BG();
		var bmp = flatten(bg);
		dm.add(bmp, 0);

		var board = flatten(new gfx.Board());
		board.x = board.y = 5;
		dm.add( board, DP_BOARD );

		render = flatten(new gfx.Render());
		render.blendMode = flash.display.BlendMode.OVERLAY;
		dm.add( render, DP_RENDER );
		
		var gs = GRID_SIZE.get();
		
		if ( !AKApi.isReplay() ) {
			var fg = new SP();
			fg.graphics.beginFill(0xeeeeee, 0);
			fg.graphics.drawRect( 0, 0, W, H );
			dm.add(fg, DP_FG);

			fg.addEventListener( flash.events.MouseEvent.CLICK, emitClick );
			fg.useHandCursor = true;
			fg.buttonMode = true;
			fg.mouseEnabled = true;
			fg.mouseChildren = false;
		}

		bmd = new BMD( gs, gs, false, 0xFFFFFF );
	
		/*
		// DEBUG : Show bitmap used in game logic
		var bmp = new BMP(bmd);
		bmp.scaleX = bmp.scaleY = BLOCK_SIZE;
		bmp.alpha = 0.4;
		bmp.x = DELTA_X - BLOCK_SIZE/2;
		bmp.y = DELTA_Y - BLOCK_SIZE/2;
		dm.add(bmp, DP_FG);
		*/

		clock = cast new gfx.Clock();
		clock.x = 429;
		clock.y = 33;
		clock._time.gotoAndStop(1);
		clock._time.rotation = 0;
		dm.add( clock, DP_UI );

		comboMeter = cast new gfx.ComboMeter();
		comboMeter.x = 426;
		comboMeter.y = 223;
		comboMeter._txt.visible = false;
		dm.add( comboMeter, DP_UI );

		if( AKApi.getGameMode() == GM_PROGRESSION ){
			contracts = switch( AKApi.getLevel() ){
				case  1: [ new Contract.Combo( 3, 2 ),          new Contract.Combo( 1, 3 ),          new Contract.Point( 20000 ) ];
				case  2: [ new Contract.Combo( 1, 3, 3 ),       new Contract.Combo( 3, 3 ),          new Contract.Point( 25000 ) ];
				case  3: [ new Contract.Combo( 1, 4 ),          new Contract.Combo( 2, 3, 3 ),       new Contract.Point( 30000 ) ];
				case  4: [ new Contract.Combo( 2, 4 ),          new Contract.Combo( 2, 3, 1 ),       new Contract.Point( 35000 ) ];
				case  5: [ new Contract.Combo( 1, 4, 1 ),       new Contract.Combo( 3, 4 ),          new Contract.Point( 40000 ) ];
				case  6: [ new Contract.Combo( 1, 4, 4 ),       new Contract.Combo( 4, 4 ),          new Contract.Point( 45000 ) ];
				case  7: [ new Contract.Combo( 2, 4, 1 ),       new Contract.Combo( 2, 3, 1, true ), new Contract.Point( 50000 ) ];
				case  8: [ new Contract.Combo( 2, 4, 4 ),       new Contract.Combo( 3, 3, 3 ),       new Contract.Point( 60000 ) ];
				case  9: [ new Contract.Combo( 1, 5 ),          new Contract.Combo( 1, 4, 4 ),       new Contract.Point( 70000 ) ];
				case 10: [ new Contract.Combo( 1, 5 ),          new Contract.Combo( 1, 4, 1 ),       new Contract.Point( 75000 ) ];
				case 11: [ new Contract.Combo( 1, 5 ),          new Contract.Combo( 3, 4, 4 ),       new Contract.Point( 80000 ) ];
				case 12: [ new Contract.Combo( 2, 5 ),          new Contract.Combo( 1, 4, 1, true ), new Contract.Point( 90000 ) ];
				case 13: [ new Contract.Combo( 2, 5 ),          new Contract.Combo( 2, 4, 1, true ), new Contract.Point( 100000 ) ];
				case 14: [ new Contract.Combo( 1, 5, 5 ),       new Contract.Combo( 1, 4, 4 ),       new Contract.Point( 105000 ) ];
				case 15: [ new Contract.Combo( 1, 5, 5 ),       new Contract.Combo( 3, 4, 4 ),       new Contract.Point( 110000 ) ];
				case 16: [ new Contract.Combo( 2, 5 ),          new Contract.Combo( 1, 4, 1, true ), new Contract.Point( 115000 ) ];
				case 17: [ new Contract.Combo( 1, 5, 1 ),       new Contract.Combo( 2, 3, 1, true ), new Contract.Point( 120000 ) ];
				case 18: [ new Contract.Combo( 1, 5, 1 ),       new Contract.Combo( 2, 4, 1, true ), new Contract.Point( 125000 ) ];
				case 19: [ new Contract.Combo( 1, 5, 1, true ), new Contract.Combo( 2, 4, 1, true ), new Contract.Point( 130000 ) ];
				case 20: [ new Contract.Combo( 2, 5, 5 ),	      new Contract.Combo( 1, 5, 1, true ), new Contract.Point( 150000 ) ];
				default: throw true;
			}

			for( c in contracts )
				c.init();
		}
	}

	function emitClick(_){
		if( AKApi.isReplay() )
			return;
		if( step == S_TutoLast ){
			api.AKApi.emitEvent(1);
		}
		if( !started )
			return;
		if( step != S_Play && step != S_FPlay )
			return;
		emitEvent( E_Click );
	}

	function initGrid(){
		var init = false;
		if( grid == null ){
			grid = [];
			init = true;
		}

		var gs = GRID_SIZE.get();

		var gd = if( init && AKApi.getGameMode()==GM_PROGRESSION ) 32 else if( init ) 22 else 0;
		var m = if( init && AKApi.getGameMode()==GM_PROGRESSION ) 1 else 1;
		var r = init ? 4 : fxSeed.random(7);

		var fd = switch( r ){
			case 0: function(x,y) return x+y;
			case 1: function(x,y) return gs-x+y;
			case 2: function(x,y) return gs+x-y;
			case 3: function(x,y) return 2*gs-x-y;
			case 4: function(x,y) return Std.int(Math.abs(x-gs/2)+Math.abs(y-gs/2));
			case 5: function(x,y) return gs-Std.int(Math.abs(x-gs/2)+Math.abs(y-gs/2));
			case 6: function(x,y) return fxSeed.random(Std.int(1.5*gs));
		}
		
		emptyCells = 0;
		for( x in 0...gs ){
			if( grid[x] == null )
				grid[x] = [];
			for( y in 0...gs ){
				if( grid[x][y] == null )
					emptyCells++;
			}
		}

		for( x in 0...gs ){
			for( y in 0...gs ){
				var b = grid[x][y];
				if( b == null )
					grid[x][y] = new Block(x,y, Math.round(gd+fd(x,y)*m), 0.1/m );
			}
		}
		
	}

	public function updateClock( add=false ){
		var t : Float = gTimer;
		if( t == 0 )
			t = 0.1;
		var f = new fx.ClockRotate( clock._time, -360*(t/MAX_TIMER.get()), add ? 0.08 : 0.2 );

		if( add ){
			new mt.fx.Radiate( clock._clock._col, 0.05, 0xFFFFCC, 10 );
		}else if( gTimer <= 5*40 ){
			var s = Math.round( (6-gTimer/40) );
			new mt.fx.Radiate(clock._clock._col, 0.05*s, 0xEE7B5F, 10 );
		}else if( Math.round(gTimer/40) == 10 ){
			new mt.fx.Radiate(clock._clock._col, 0.05, 0xEEC55F, 10 );
		}
	}

	public function emitEvent( t : EventType ){
		if( step == S_GameOver || step == S_Void )
			return;

		var b = getMouseBlock();
		var i = Type.enumIndex( t ) * 10000;
		if( b == null )
			i += 9999;
		else
			i += b.x*100 + b.y;
		AKApi.emitEvent( i );
	}

	public function update( b : Bool ){
		fxm.update();

		if( started && tuto == null && !tutoEnd && gTimer > 0 ){
			gTimer--;
			if( gTimer%40 == 0 )
				updateClock();
		}

		if( gTimer == 0 && step != S_Gather ){
			if( step == S_FPlay ){
				onClick( lastGroup.arr[0] );
			}else{
				setStep( S_GameOver );
			}
		}

		switch( step ){
		case S_Create:
			if( fxm.fxs.length == 0 )
				setStep( S_Play );
		case S_TutoLast:
			var i = AKApi.getEvent();
			if( i == 1 ){
				killTutoText();
				setStep( S_Play );
			}
			
		case S_Play,S_FPlay:
			if( started ){
				if( !AKApi.isReplay() ){
					var b = getMouseBlock();
					if( b!=null && b.grouped && swapingBlocks > 0 )
						b = null;
					if( b != overBlock ){
						if( b==null || overBlock== null || !b.grouped || !overBlock.grouped ){
							emitEvent( E_Over );
						}
					}
				}

				while( true ){
					var i = AKApi.getEvent();
					if( i == null )
						break;

					var eType = Type.createEnumIndex( EventType, Math.floor( i/10000 ) );
					var eBlock = null;
					if( i%10000 != 9999 ){
						var eX = Math.floor( (i%10000)/100 );
						var eY = i%100;
						eBlock = grid[eX][eY];					
					}

					switch( eType ){
					case E_Click:
						onClick( eBlock );
					case E_Over:
						if( overBlock != null )
							overBlock.mouseOut();
						overBlock = eBlock;

						if( eBlock != null ){
							eBlock.mouseOver();
							if( group != null && !eBlock.grouped )
								group.over( eBlock );
						}
					}
				}
			}

			if( step == S_FPlay ){
				fpTimer--;
				lastGroup.showFPlay( fpTimer / FP_TIMER.get() );
				if( fpTimer == 0 )
					setStep( S_Destroy );
			}
		case S_Destroy,S_Gather:
			if( fxm.fxs.length == 0 )
				setStep( S_Create );
		case S_GameOver:
			overTimer--;
			if( overTimer <= 0 ){
				gameOver();
				return;
			}
		case S_Void:
		}
	}

	public function onClick( block : Block ){
		var showGroupClick = false;
		if( tuto != null ){
			var s = TUTO_POS[tuto[0]];
			if( s == null ){
				if( block == null || !block.grouped )
					return;
				tuto[0]++;
				killTutoText();
			}else{
				var p = s[tuto[1]];
				if( block == null || block.x != p[0] || block.y != p[1] )
					return;

				killTutoText();

				if( tuto[1] == 2 )
					tuto = [ tuto[0]+1, 0 ];
				else
					tuto[1]++;
				block.unshine();
				
				var nextPos = try TUTO_POS[ tuto[0] ][ tuto[1] ] catch( e : Dynamic ) null;
				if( nextPos != null ){
					var block = grid[ nextPos[0] ][ nextPos[1] ];
					block.shine();
					if( tuto[1] == 0 ){
						showTutoText( Text.tuto4 );
					}else if( tuto[1] == 1 ){
						showTutoText( Text.tuto1 );
					}else if( tuto[1] == 2 ){
						showTutoText( Text.tuto2 );
					}
				}else{
					showGroupClick = true;
				}
			}
			if( tuto[0] >= TUTO_POS.length ){
				tuto = null;
				tutoEnd = true;
				tutoLast = true;
			}
		}
		
		if( block == null ){
			if( group != null )
				group.deselect();
			return;
		}else if( block.grouped ){
			gatherBlock = block;
			setStep(S_Gather);
			return;
		}
		
		if( block.id == null )
			return;

		if( group == null ){
			group = new Group(block);
		}else{
			if( group.click( block ) ){
				
				if( block == overBlock ){
					block.mouseOut();
					overBlock = null;
				}
		
				var center = group.center();
				var pcenter = new PT(center.x*BLOCK_SIZE+DELTA_X, center.y*BLOCK_SIZE+DELTA_Y);

				if( showGroupClick )
					showTutoText(Text.tuto3 );

				groups++;
				if( gblocks == null ){
					gblocks = new List();
					combo = 1;
					colors = [group.id];
				}else{
					combo++;
					showText( Text.combo, -1, pcenter.x, pcenter.y, 18 );
					if( !Lambda.has(colors,group.id) )
						colors.push( group.id );
				}

				if( lastGroup != null && lastGroup.id == group.id )
					sameColorGroups++;
				else
					sameColorGroups = 1;

				var c = COMBO_ONECOLOR[sameColorGroups-1].get();
				if( c > 0 ){
					combo += c;
					showText( Text.unicombo({_c: c}), group.id, pcenter.x, pcenter.y+20, 22 );
				}

				if( colors.length == MAX_ID.get() && !rainbowCombo ){
					rainbowCombo = true;
					combo += COMBO_RAINBOW.get();
					showText( Text.rainbowcombo({_c: COMBO_RAINBOW.get()}), -2, pcenter.x, pcenter.y+20, 22 );
				}
				
				for( b in group.newBlocks ){
					b.group( group, Std.int(Math.abs(b.x-block.x)+Math.abs(b.y-block.y)) );
				}

				if( contracts != null ){
					for( c in contracts )
						c.onGroup( group );
				}

				if( groups == 1 ){
					comboMeter._txt.visible = true;
					comboMeter._txt.alpha = 0;
					comboMeter._txt._current._txt.text = Std.string( combo );
					var f = new fx.Alpha(comboMeter._txt,1);
					new mt.fx.Sleep(f,null,15);
				}else{
					comboMeter._txt._next._txt.text = Std.string( combo );
					var f = new fx.Play( comboMeter._txt );
					f.onFinish = function(){
						comboMeter._txt._current._txt.text = Std.string( combo );
						comboMeter._txt.gotoAndStop(1);
					}
					new mt.fx.Sleep(f,null,25);
				}

				if( lastGroup != null ){
					lastGroup.hide();
					for( b in lastGroup.blocks ){
						b.sp.y += 1;
					}
				}


				lastGroup = group;
				group = null;
				fpTimer = getFPTimer();
				setStep(S_FPlay);
			}
		}
	}

	
	function getFPTimer(){
		var t = FP_TIMER.get();
		t += FP_TIMER_DELTA.get();
		if( t < FP_TIMER_MIN.get() )
			t = FP_TIMER_MIN.get();
		FP_TIMER = AKApi.const( t );
		return t;
	}

	function getMouseBlock(){
		var mx = mouseX;
		var my = mouseY;
		var x = Math.floor((mx - DELTA_X + BLOCK_SIZE/2)/BLOCK_SIZE);
		var y = Math.floor((my - DELTA_Y + BLOCK_SIZE/2)/BLOCK_SIZE);
		
		if( x < 0 || x >= GRID_SIZE.get() )
			return null;
		if( y < 0 || y >= GRID_SIZE.get() )
			return null;

		return grid[x][y];
	}

	public function listBlocks( id : Int ){
		var l = new List();
		for( ix in 0...GRID_SIZE.get() ){
			for( iy in 0...GRID_SIZE.get() ){
				var b = grid[ix][iy];
				if( b!=null && b.id == id )
					l.add(b);
			}
		}
		return l;
	}

	public function listFreeBlocksWithoutPK(){
		var a = new Array();
		for( ix in 0...GRID_SIZE.get() ){
			for( iy in 0...GRID_SIZE.get() ){
				var b = grid[ix][iy];
				if( !b.grouped && b.prizeToken == null )
					a.push(b);
			}
		}
		return a;
	}

	function showTutoText( text : String ){
		killTutoText();

		var mc = new gfx.HelpBox();
		mc._txt.text = text;

		var sp = new SP();
		sp.addChild( flatten(mc) );

		Game.me.dm.add(sp,Game.DP_TUTO_TEXT);
		sp.x = PADDING + (GRID_SIZE.get() * BLOCK_SIZE) / 2 - sp.width / 2;
		sp.y = H;
		sp.alpha = 1;


		var y = PADDING + (GRID_SIZE.get() * BLOCK_SIZE) - 50;
		new mt.fx.Tween(sp,sp.x,y);

		tutoText = sp;
	}

	function killTutoText(){
		if( tutoText == null )
			return;
		new fx.Alpha(tutoText,0);
	}

	public function showText( text : String, id : Int, x : Float, y : Float, size=18 ){
		var tf = new TF();
		tf.text = text;
		tf.width = 200;
		tf.selectable = false;

		var col = ( id >= 0 ) ? COLORS[id] : 0x000000;

		var f = tf.getTextFormat();
		f.size = size;
		f.bold = true;
		f.font = "arial";

		if( id == -2 ){
			for( i in 0...text.length ){
				f.color = COLORS[i%COLORS.length];
				tf.setTextFormat(f,i,i+1);
			}
		}else{
			f.color = col;		
			tf.setTextFormat(f);
		}

		tf.x = -tf.textWidth / 2;
		tf.y = -tf.textHeight;

		var sp = new SP();
		Game.me.dm.add(sp,Game.DP_PART);
		sp.addChild(tf);
		sp.x = Math.max( x, tf.textWidth/2 );
		sp.y = y;
		sp.alpha = 1;
		sp.cacheAsBitmap = true;

		var f = new flash.filters.GlowFilter();
		f.color = 0xFFFFFF;
		f.strength = 4;
		f.blurX = f.blurY = 4;
		f.alpha = 1;
		sp.filters = [f];

		var f = new mt.fx.Spawn(sp,0.1,true,true);
		f.onFinish = function(){
			var p = new mt.fx.Part(sp);
			p.weight = -0.12;
			p.timer = 40;
			p.fadeLimit = 25;
			p.fadeType = 1;
			new mt.fx.Sleep(p,null,10);
		}

		return sp;
	}

	public function createPart( pos : PT, type:Int ){
		var psp = new gfx.Part();
		psp.gotoAndStop(type);
		psp.x = pos.x;
		psp.y = pos.y;

		psp.blendMode = flash.display.BlendMode.ADD;

		Game.me.dm.add(psp,Game.DP_PART);
		var p = new mt.fx.Part(psp);
		p.weight = 0.1;
		p.vx = 2*fxSeed.random(100)/100 -1;
		p.vy = 2*fxSeed.random(100)/100 -1;
		p.timer = 20;
		p.fadeType = 1;

		return p;
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

	public static function flatten(o:flash.display.DisplayObject) {
		var b = o.getBounds(o);
		var bmp = new flash.display.Bitmap( new flash.display.BitmapData(Math.ceil(b.width), Math.ceil(b.height), true, 0x0) );
		var m = new flash.geom.Matrix();
		m.translate(-b.x, -b.y);
		bmp.bitmapData.draw(o, m, o.transform.colorTransform);
		bmp.x = b.x;
		bmp.y = b.y;
		return bmp;
	}

}
