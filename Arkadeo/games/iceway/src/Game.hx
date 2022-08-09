import Lib;
//arkadeo
#if !standalone
import api.AKApi;
import api.AKProtocol;
import api.AKConst;
import TitleLogo;
#end

import mt.deepnight.Particle;
import mt.deepnight.SpriteLib;
import Entity.EntityKind;

using GridCellTools;
using GridTools;
@:build(mt.kiroukou.macros.IntInliner.create([[
	DM_REFLECT,
	DM_BACKGROUND,
	DM_GROUND,
	DM_GAME,
	DM_FX,
	DM_UI,
],[
	AK_EVENT_RESET_LEVEL,
	AK_EVENT_MOVE_DIR,
]]))
class Game extends Sprite, implements game.IGame, implements mt.kiroukou.events.Signaler
{
	public static var me : Game;
	public static var GAME_TIMER_SECOND 		= AKApi.const(30);
	public static var GAME_PROGRESSION_TIMER 	= AKApi.const(120 * GAME_TIMER_SECOND.get());
	public static var GAME_LEAGUE_TIMER 		= AKApi.const(60 * GAME_TIMER_SECOND.get());
	inline static var LEAGUE_SECOND_INC 		= AKApi.const(10);
	public static var GAME_MAX_TIMER 			= AKApi.const(200 * GAME_TIMER_SECOND.get());
	public static var GAME_LEVEL_POINTS	 		= AKApi.const(1000);
	public static var GAME_BONUS_NO_RESET		= AKApi.const(300);
	public static var GAME_BONUS_BEST_PATH		= AKApi.const(500);
	
	public var delayer 					: mt.deepnight.Delayer;
	public var dm (default, null)		: mt.DepthManager;
	public var rand(default, null)		: mt.Rand;
	public var player 					: InteractiveEntity;
	public var boy 						: Entity;
	public var grid						: Grid<GridCell>;
	public var step						: GameStep;
	public var boyFound 				: mt.flash.Volatile<Bool>;
	public var gameLevel				: mt.flash.Volatile<Int>;
	public var reflectsToUpdate			: List<Reflection>;
	public var control					: Control;
	public var allEntities(default, null) 	: Array<Entity>;
	public var intEntities(default, null) 	: Array<InteractiveEntity>;
	public var tiles(default, null) 		: anim.TilesManager;
	
	var timer 			: mt.flash.Volatile<Int>;
	var mcTimer 		: gfx.Timer;
	var frame 			: Int = 0;
	
	public var gameContainer : Sprite;
	public var container : Sprite;
	
	
	var counter 		: mt.flash.Volatile<Int>;
	var resetCount		: mt.flash.Volatile<Int>;
	var started			: Bool;
	var mode  			: GameMode;	
	var _cinematic 		: mt.deepnight.Cinematic;
	var _tokens			: Array<SecureInGamePrizeTokens>;
	var _path			: { girl:GridCell, boy:GridCell, home:GridCell, helpers:Array<GridCell>, length : api.AKConst, kdo : Array<GridCell> };
	var fxManager 		: mt.fx.Manager;
	var transition 		: Null<seq.Transition>;
	#if debug
	var _debug			: flash.text.TextField;
	#end

	public var levelInfos(default, null): { _score : Int, _bonusPerfect : Int, _bonusReset : Int, _nextLevel : Int };
	

	#if standalone
	public static function main()
	{
		var game = new Game();
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.addEventListener(flash.events.Event.ENTER_FRAME, function(e) { game.update(true); });
		flash.Lib.current.addChild(game);
	}
	#end

	public function new()
	{
		super();
		me = this;
		
		allEntities = [];
		intEntities = [];
		reflectsToUpdate = new List();
		started = false;
		gameLevel = 0;
		levelInfos = cast { };
		fxManager = new mt.fx.Manager();
		delayer = new mt.deepnight.Delayer();
		//
		#if standalone
			rand = new mt.Rand( Std.random(10) );
			level = 5;
		#else
			#if dev
			haxe.Firebug.redirectTraces();
			mt.deepnight.Lib.redirectTracesToConsole("iceway:");
			#end
			var seed = AKApi.getSeed();
			rand = new mt.Rand(seed);
			var raw = haxe.Resource.getString(AKApi.getLang());
			if( raw == null ) raw = haxe.Resource.getString("en");
			Texts.init( raw );
			
			_tokens = AKApi.getInGamePrizeTokens();
		#end
		//
		tiles = new anim.TilesManager();
		//
		container = new Sprite();
		gameContainer = new Sprite();
		dm = new mt.DepthManager(gameContainer);
		container.addChild(gameContainer);
		//
		var button = new gfx.Button2();
		button.x = Lib.STAGE_WIDTH / 2 - button.width / 2;
		button.y = Lib.STAGE_HEIGHT - 2 * button.height + 30;
		button.addEventListener(flash.events.MouseEvent.CLICK, function(_) {  AKApi.emitEvent( AK_EVENT_RESET_LEVEL ); } );
		container.addChild(button);
		//
		mcTimer = new gfx.Timer();
		mcTimer.y = button.y + button.height - mcTimer.height + 3;
		mcTimer.x = button.x + mcTimer.width - 20;
		container.addChild(mcTimer);
		//
		control = new Control(this);
		control.init();
		//
		#if standalone
		flash.Lib.current.stage.quality = flash.display.StageQuality.LOW;
		#end
		//		
		addChild(container);
		
		setStep(STransition);
	}
	
	public function getLevel()
	{
		return switch( AKApi.getGameMode() )
		{
			case GM_PROGRESSION :
				MLib.clamp( 4 + Std.int(1.2 * AKApi.getLevel()), 5, 35);
			case GM_LEAGUE :
				MLib.clamp(gameLevel * 5, 5, 35);
		}
	}
	
	function initGame()
	{
		var offsetY = 30;
		if( AKApi.getLevel() == 1 )
		{
			Lib.setGridSize( 10, 10 );
			gameContainer.x = .5 * (Lib.STAGE_WIDTH - Lib.WIDTH);
			gameContainer.y = 2 * offsetY;
		}
		else if( AKApi.getLevel() <= 3 )
		{
			Lib.setGridSize( 12, 10 );
			gameContainer.x = .5 * (Lib.STAGE_WIDTH - Lib.WIDTH);
			gameContainer.y = 2 * offsetY;
		}
		else if( getLevel() < 10 )
		{
			Lib.setGridSize( 14, 10 );
			gameContainer.x = .5 * (Lib.STAGE_WIDTH - Lib.WIDTH);
			gameContainer.y = 2 * offsetY;
		}
		else
		{
			Lib.setGridSize( 16, 12 );
			gameContainer.x = .5 * (Lib.STAGE_WIDTH - Lib.WIDTH);
			gameContainer.y = offsetY;
		}
		//
		setStep(SProcessing);
		//
		Skinner.drawBackground();
		Skinner.drawGrid();
		Fx.initSnow();
	}
	
	function generateLevel()
	{
		cleanLevel();
		switch( AKApi.getGameMode() )
		{
			case GM_PROGRESSION :
				var level = getLevel();
				var error = if( level > 15 ) Std.int(0.1 * level) else 0;
				initLevel(level, error);
			case GM_LEAGUE :
				var level = getLevel();
				var error = if( level > 15 ) Std.int(0.1 * level) else 0;
				initLevel(level, error);
		}
	}
	
	function cleanLevel()
	{
		for( e in allEntities )
			e.dispose();
		allEntities = [];
		intEntities = [];
		//
		if( grid != null )
			grid.iter(function(cell:GridCell) cell.dispose());
	}
	
	function cleanGame()
	{
		PopupManager.get().free();
		Particle.clearAll();
		//
		if( dm != null )
			dm.destroy();
		//
		for( e in allEntities )
			e.dispose();
		allEntities = [];
		intEntities = [];
		//
		if( grid != null )
			grid.iter(function(cell:GridCell) cell.dispose());
	}

	public function setStep( step : GameStep )
	{
		this.step = step;
		switch( step )
		{
			case SInitGame:			
				if( !started )
				{
					timer = switch( AKApi.getGameMode() )
					{
						case GM_PROGRESSION :
							GAME_PROGRESSION_TIMER.get();
						case GM_LEAGUE :
							GAME_LEAGUE_TIMER.get();
					}
				}
				cleanGame();
				initGame();
				
			case SProcessing :
				generateLevel();
			
			case SLevelInit:
				PopupManager.get().free();
				control.reset();
				control.lock();
				counter = 0;
				resetCount = 0;
				boyFound = false;
				if( AKApi.getLevel() < 4 && gameLevel == 0 )
				{
					_cinematic = new mt.deepnight.Cinematic();
					_cinematic.create( {
						end("onInteractive");
						if( gameLevel == 0 ) player.talk( Texts.TutoStep_1 ) > 3000;
						if( gameLevel == 0 ) player.talk( Texts.TutoStep_2 ) > 3000;
						if( gameLevel == 0 ) this.boy.talk( Texts.BoyCry ) > 3000;
						end("foundHome");
						if( gameLevel == 0 ) player.talk( Texts.Home );
					});
				}
				
				started = true;
				if( transition != null )
					transition.levelInit();
				else
					setStep(SInteractive);
			
			case SInteractive:
				if ( _cinematic != null ) _cinematic.signal("onInteractive");
				if( !api.AKApi.isReplay() )
					control.unlock();
			
			case SAnim:
				if( control.selectedEntity == player )
					counter ++;
				control.lock();
				control.selectedEntity.hideArrows();
				gfx.Selection.cleanAll();
			
			case STransition:
				transition = new seq.Transition();
				transition.onHidden = callback(Game.me.setStep, SInitGame);
				transition.onFinish = callback(Game.me.setStep, SInteractive);
				transition.init();
			
			case SGameOver:
				if( _cinematic != null ) _cinematic.skip();
				api.AKApi.setProgression( (gameLevel+1) / 3 );
				switch( AKApi.getGameMode() )
				{
					case GM_PROGRESSION :
						if( timer > 0 )
						{
							player.gfx.libGroup = "win";
							player.gfx.setFrame(0);
							boy.gfx.libGroup = "down";
							boy.gfx.setFrame(0);
								
							if( gameLevel == 2 )
							{
								AKApi.gameOver(true);
							}
							else
							{
								gameLevel ++;
								setStep(STransition);
							}
						}
						else
						{
							AKApi.gameOver(false);
							setStep(SFinish);
						}
					case GM_LEAGUE :
						if( timer > 0 )
						{
							player.gfx.libGroup = "win";
							player.gfx.setFrame(0);
							boy.gfx.libGroup = "down";
							boy.gfx.setFrame(0);
							//
							gameLevel++;
							// score basé sur le temps
							levelInfos._score = Std.int( gameLevel * ( timer + GAME_LEVEL_POINTS.get() ) );
							// Bonus si pas de reset !
							if( resetCount == 0 ) 	levelInfos._bonusReset = gameLevel * GAME_BONUS_NO_RESET.get();
							else 					levelInfos._bonusReset = 0;
							// bonus de chemin parfait !
							if( MLib.abs(counter - _path.length.get()) == 0 ) 	levelInfos._bonusPerfect = gameLevel * GAME_BONUS_BEST_PATH.get();
							else 												levelInfos._bonusPerfect = 0;
							//
							levelInfos._nextLevel = getLevel();
							//
							api.AKApi.addScore( api.AKApi.const( levelInfos._score ) );
							api.AKApi.addScore( api.AKApi.const(levelInfos._bonusReset  ) );
							api.AKApi.addScore( api.AKApi.const( levelInfos._bonusPerfect ) );
							//
							timer = timer + ( LEAGUE_SECOND_INC.get() * GAME_TIMER_SECOND.get() );
							//
							setStep(STransition);
						}
						else
						{
							AKApi.gameOver(false);
							setStep(SFinish);
						}
				}
			case SFinish: //nothing....
		}
	}
	
	function popHelper(helpCell : GridCell )
	{
		var e = new InteractiveEntity(EntityKind.EK_Dog, tiles.dogTiles.getSprite("down"), helpCell);
		var r = new Reflection( e.gfx, 0.35, 150, 0, -13 );
		r.x = e.gfx.x;
		r.y = e.gfx.y;
		dm.add( r, DM_REFLECT );
		reflectsToUpdate.add(r);
		//
		allEntities.push(e);
		intEntities.push(e);
		//
		e.sync();
		dm.add( e.gfx, DM_GAME );
	}
	
	function popKdo(token:SecureInGamePrizeTokens)
	{
		if( _path.kdo.length == 0 ) return;
		
		var kdo = _path.kdo[ this.rand.random(_path.kdo.length)];
		_path.kdo.remove(kdo);
		
		kdo.flags.set(Kdo);
		kdo.flags.set(GeneratorLocked);
		//
		var gfx = new gfx.Kado(token);
		gfx.mouseEnabled = false;
		gfx.gotoAndStop( token.frame );
		var coord = Lib.getCoord_XY( kdo.x, kdo.y );
		gfx.x += coord.x;
		gfx.y += coord.y;
		gfx.cacheAsBitmap = true;
		dm.add( gfx, Game.DM_GAME);
		//
		kdo.gfx = gfx;
		gfx.visible = false;
		haxe.Timer.delay( function() gfx.visible = true, 1500 );
		Fx.spawnKdo( gameContainer.x + coord.x + Lib.TILE_MID_SIZE, gameContainer.y + coord.y + Lib.TILE_MID_SIZE, Lib.KDO_COLORS[token.frame-1], gameLevel == 0 ? 0 : 30);
	}
	
	public function onMoveEnd( entity : Entity )
	{
		if ( this.step == SGameOver ) return;
		if ( _cinematic != null ) 
		{
			_cinematic.signal("moveEnd");
		}
		
		if( player == entity && player.cell.flags.has(Boy) && !boyFound )
		{
			boyFound = true;
			player.follower = boy;
			if( _cinematic != null ) _cinematic.signal("foundBrother");
			player.talk( Texts.GirlFoundBrother, 3 );
		}
		
		if( player == entity &&  boyFound && player.cell.flags.has(Home) )
		{
			if( _cinematic != null ) _cinematic.signal("foundHome");
		}
		else if ( boy == entity && boyFound && boy.cell.flags.has(Home) )
		{
			setStep( SGameOver );
		}
		else
		{
			setStep( SInteractive );
		}
	}
	
	public function grabToken( token : SecureInGamePrizeTokens )
	{
		api.AKApi.takePrizeTokens( token );
		_tokens.remove(token);
	}
	
	public function update(render:Bool)
	{
		var timeUpdate = true;
		if( transition != null && !transition.dead )
			timeUpdate = false;
		switch( step )
		{
			case SProcessing:
				generateLevel();
			case SInteractive:
				control.update();
				#if standalone
				var isDown = mt.flash.Key.isDown, isToggled = isDown;
				#else
				var isDown = api.AKApi.isDown, isToggled = api.AKApi.isToggled;
				#end
				if( isDown( Key.LEFT ) ) 			{ control.useKeyboard = true; move( control.selectedEntity, MLeft); }
				else if( isDown( Key.RIGHT ) ) 		{ control.useKeyboard = true; move( control.selectedEntity, MRight ); }
				else if( isDown( Key.UP ) ) 		{ control.useKeyboard = true; move( control.selectedEntity, MUp ); }
				else if( isDown( Key.DOWN ) ) 		{ control.useKeyboard = true; move( control.selectedEntity, MDown ); }
				else if( isToggled( Key.ENTER ) ) 	{ AKApi.emitEvent( AK_EVENT_RESET_LEVEL ); }
			case STransition:
				timeUpdate = false;
			case SAnim, SGameOver, SInitGame, SLevelInit, SFinish:
		}
		//
		#if !standalone
		var e = AKApi.getEvent();
		if( e != null )
		{
			switch(e)
			{
				case AK_EVENT_RESET_LEVEL:
				{
					resetLevel();
				}
				case AK_EVENT_MOVE_DIR :
				{
					var entity = allEntities[AKApi.getEvent()];
					move( cast entity, Lib.MOVES_DIRS[AKApi.getEvent()] );
				}
			}
		}
		#end
		//
		fxManager.update();
		delayer.update();
		if( _cinematic != null ) _cinematic.update();
		//
		Particle.WINDX = Fx.windForce * Math.cos(frame * 0.001);
		//
		if( render )
		{
			PopupManager.get().syncAll();
			DSprite.updateAll(1.0);
			Particle.update(1.0);
			for( r in reflectsToUpdate )
			{
				r.visible = r.mcRef.visible;
				r.x = r.mcRef.x;
				r.y = r.mcRef.y;
				r.scaleX = r.mcRef.scaleX;
				r.update();
			}
			dm.ysort(DM_GAME);
		}
		//
		if( started && timeUpdate )
		{
			for ( e in allEntities )
			{
				e.update();
			}
		
			timer --;
			mcTimer._text.text = Std.int(timer / GAME_TIMER_SECOND.get()) + "s";
			if( timer % GAME_TIMER_SECOND.get() == 0 ) //update display
			{
				Fx.windForce += 0.06;
				Particle.WINDY += 0.1;
			}
			
			if( timer == 0 )
			{
				setStep(SGameOver);
				return;
			}
			frame ++;
		}
	}
	
	public function move( entity : InteractiveEntity, dir : MoveDir )
	{
		if( grid.isValidMove( entity.cell, dir, true ) == false ) return;
		var dest = grid.getEntityMoveTarget(entity.cell, dir);
		entity.move(dir, dest);
		setStep( SAnim );
	}
	
	function resetLevel()
	{
		resetCount ++;
		if( boyFound )
		{
			player.follower.cell = player.follower.origin;
			player.cell = player.follower.cell;
			player.reset();
			if( player.follower != null )
				player.follower.reset();
			player.sync();
			if( player.follower != null )
				player.follower.sync();
		}
		else
		{
			player.cell = player.origin;
			player.reset();
			player.sync();
		}
		
		var h = getHelper();
		if( h != null )
		{
			h.cell = h.origin;
			h.reset();
			h.sync();
		}
		
		control.reset();
		control.unlock();
		control.giveEntityFocus(player);
		setStep(SInteractive);
	}
	
	function getHelper()
	{
		for( e in intEntities )
		{
			if( e.kind == EK_Dog )
			{
				return e;
			}
		}
		return null;
	}
	
	function initLevel(level:Int, error:Int=0)
	{
		PathGenerator.grid = grid = LevelGenerator.generate( level, (level <= 7) ? true : false );
		_path = PathGenerator.computePath( level, error );
		
		if( _path == null )
		{
			#if dev
			trace("no valid path found");
			#end
			grid.iter( function(c) c.dispose() );
			grid = null;
			return;
		}
		// GIRL
		player = new InteractiveEntity(EntityKind.EK_Girl, tiles.girlTiles.getSprite("down"), _path.girl);
		player.speed = 8;
		var r = new Reflection( player.gfx, 0.35, 150, 0, -24 );
		r.x = player.gfx.x;
		r.y = player.gfx.y;
		dm.add( r, DM_REFLECT );
		reflectsToUpdate.add(r);
		//
		allEntities.push(player);
		intEntities.push(player);
		// BOY
		boy = new Entity(EntityKind.EK_Boy, Game.me.tiles.boyTiles.getSpriteAnimated("cry", "cry_anim"), _path.boy);
		boy.cell.flags.set(Boy);
		boy.speed = player.speed - 1;
		allEntities.push(boy);
		var r = new Reflection( boy.gfx, 0.35, 150, 0, -22 );
		r.x = boy.gfx.x;
		r.y = boy.gfx.y;
		dm.add( r, DM_REFLECT );
		reflectsToUpdate.add(r);
		//
		_path.girl.flags = haxe.EnumFlags.ofInt(0);
		_path.girl.flags.set(Girl);
		_path.boy.flags = haxe.EnumFlags.ofInt(0);
		_path.boy.flags.set(Boy);
		//HOME
		var home = _path.home;
		home.flags.set(Home);
		Skinner.skinLevel();
		//
		if( _path.helpers.length > 0 )
		{
			for( h in _path.helpers )
			{
				popHelper( h );
			}
		}
		//
		for( e in allEntities )
		{
			e.sync();
			dm.add( e.gfx, DM_GAME );
		}
		//
		for( i in 0...MLib.min(5, _tokens.length ) )
		{
			var token = _tokens[i];
			switch( AKApi.getGameMode() )
			{
				case GM_PROGRESSION: popKdo(token);
				case GM_LEAGUE:
					if( AKApi.getScore() > token.score.get() ) popKdo(token);
			}
		}
		//
		dm.ysort( DM_GROUND );
		dm.ysort( DM_GAME );
		//
		setStep( SLevelInit );
	}
}

