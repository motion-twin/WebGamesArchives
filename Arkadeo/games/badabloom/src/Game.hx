package;

import flash.display.Sprite;
import mt.deepnight.Particle;
import mt.deepnight.Tweenie;
import mt.kiroukou.motion.Tween;

import mt.Rand;
import mt.MLib;

using mt.flash.Lib;
using mt.Std;

enum BonusKind {
	TIME;
	LEVEL;
}

enum Dirs {
	NONE;
	UP;
	DOWN;
	RIGHT;
	LEFT;
}

enum GameState {
	TRANSITION;
	PLAY;
	INIT;
	WAIT;
}

typedef Trigger = {
	var x:Int;
	var y:Int;
	var type:Int;
	@:optional
	var path:Path;
	var name:String;
}

typedef Path = {
	var trigger:Trigger;
	var triggerA:Trigger;
	var triggerB:Trigger;
	var dirs:Array<Dirs>;
	var lastDir:Dirs;
	var lastX:Int;
	var lastY:Int;
	var currentX:Int;
	var currentY:Int;	
	var completed:Bool;
}

typedef NodeData = {
	var left	: Null<Path>;
	var right	: Null<Path>;
	var top		: Null<Path>;
	var bottom	: Null<Path>;
	var points : Null<Int>;
}

@:build( mt.kiroukou.macros.IntInliner.create([EVT_MOVE, EVT_CANCEL_MOVE, EVT_SELECT]) )
class Game extends Sprite#if !haxe3,#end implements game.IGame
{
	public static var GRID_WMAX;
	public static var GRID_HMAX;
	
	public static var TILE_SIZE:Int;
	public static var me : Game;
	
	#if haxe3
	public var pathMap:Map<Int, Path>;
	var triggers:haxe.ds.StringMap<Trigger>;
	#else
	public var pathMap:IntHash<Path>;
	var triggers:Hash<Trigger>;
	#end
	
	public var rand(default, null):Rand;
	public var state(default, null):GameState;
	public var tweenie(default, null):mt.deepnight.Tweenie;
	public var delayer(default, null):mt.deepnight.Delayer;
	
	var bonus:Array<{x:Int, y:Int, k:BonusKind}>;
	var kdos:Array<{ ref:api.AKProtocol.SecureInGamePrizeTokens, x:Int, y:Int, amount:Int, frame:Int }>;
	var gridData:Array<Array<NodeData>>;
	var currentPath:Null<Path>;
	var lastPath:Null<Path>;
	var score:Int;
	var view:View;
	
	var tutoView:Null<gfx.Tuto>;
	
	public var gamelevel(default, null):api.AKConst;
	var time : api.AKConst;
	public var lives(default, null) : api.AKConst;
	var wait:Int;
	var frame:Int;
	
	public function new() 
	{
		super();
		me = this;
		#if( dev || debug)
		haxe.Firebug.redirectTraces();
		mt.deepnight.Lib.redirectTracesToConsole("crossRoad:");
		#end
		
		var seed = api.AKApi.getSeed();
		rand = new mt.Rand(seed);
		tweenie = new Tweenie();
		delayer = new mt.deepnight.Delayer();
		initApp();
	}
	
	public function getGameFrame():Int
	{
		return frame;
	}
	
	public function getTime()
	{
		return time.get();
	}
	
	function initApp()
	{
		var raw = haxe.Resource.getString(api.AKApi.getLang());
		if( raw == null ) raw = haxe.Resource.getString("en");
		Texts.init( raw );
		
		switch( api.AKApi.getGameMode() )
		{
			case GM_PROGRESSION:
				var l = api.AKApi.getLevel();
				var count = MLib.clamp((20-l) >> 1, 3, 7);
				lives = api.AKApi.const( count );
			case GM_LEAGUE:
				time = api.AKApi.const( Cs.LEAGUE_DURATION.get() );
		}
		
		score = 0;
		frame = 0;
		gamelevel = api.AKApi.const(1);
		addChild( new BackgroundView() );
		init();
		state = INIT;
		addChild( new TopView() );
	}
	
	function nextLevel()
	{
		api.AKApi.addScore( api.AKApi.const(score) );
		
		if ( api.AKApi.getGameMode() == GM_PROGRESSION )
		{			
			if( api.AKApi.getScore() >= getTargetScore() )
				return api.AKApi.gameOver(true);
			else if ( gamelevel.get() == lives.get() )
				return api.AKApi.gameOver(false);
		}
		
		score = 0;
		
		gamelevel.add( api.AKApi.const(1) );
		dispose();
		init();
		return;
	}
	
	function dispose()
	{
		//view.dispose();
		//
		triggers = null;
		pathMap = null;
		bonus = null;
		currentPath = lastPath = null;
	}
	
	function init()
	{
		var w = Cs.VIEW_WIDTH;
		var h = Cs.VIEW_HEIGHT;
		#if haxe3
		pathMap = new Map();
		#else
		pathMap = new IntHash();
		#end
		//
		this.mouseEnabled = true;
		this.mouseChildren = false;
		
		initGridData();
		rand.initSeed( api.AKApi.getSeed() + api.AKApi.getLevel() + gamelevel.get() );
		
		TILE_SIZE = Std.int((MLib.min(w, h) - Cs.PADDING_BOTTOM - Cs.PADDING_TOP) / MLib.max(GRID_WMAX, GRID_HMAX));
		view = new View(this.gridData);
		view.x = .5 * (w - (TILE_SIZE * GRID_WMAX));
		view.y = Cs.PADDING_TOP;
		view.drawGrid();
		
		addChildAt(view, 1);
	}
	
	function onMapClick(mx:Int, my:Int)
	{		
		if( triggers.exists( mx + "_" + my ) )
		{
			var trigger = triggers.get(mx + "_" + my);
			cleanPath(trigger.path);
			//
			view.updatePathGfx();
			//
			initDraw( trigger );
			updateUserScore();
		}
		else
		{
			var data = getAt(mx, my);
			if ( data == null || (data.bottom == null && data.top == null && data.left == null && data.right == null) ) return;
			var path = 	if ( data.left != null && !data.left.completed ) data.left;
						else if ( data.right != null && !data.right.completed ) data.right;
						else if ( data.top != null && !data.top.completed ) data.top;
						else if ( data.bottom != null && !data.bottom.completed ) data.bottom;
						else if ( data.left != null && data.left == lastPath ) data.left;
						else if ( data.right != null && data.right == lastPath ) data.right;
						else if ( data.top != null && data.top == lastPath ) data.top;
						else if ( data.bottom != null && data.bottom == lastPath ) data.bottom;
						else if ( data.left != null ) data.left;
						else if ( data.right != null ) data.right;
						else if ( data.top != null ) data.top;
						else data.bottom;
		
			invalidatePathTo(path, mx, my);
			//
			view.updatePathGfx();
			//
			currentPath = path;
			updateUserScore();
		}
	}
	
	function updateUserScore()
	{
		score = 0;
		for ( j in 0...GRID_HMAX  )
		for ( i in 0...GRID_WMAX  )
		if ( getAt(i, j) != null )
		{
			var cell = getAt(i, j);
			if ( cell.left != null && cell.right != null && cell.top != null && cell.bottom != null )
			{			
				if ( cell.left != cell.top ) score += Cs.COMPLEX_COMBO.get();
				else score += Cs.SIMPLE_COMBO.get();
			}
			else if ( cell.points != null && ( cell.left != null || cell.right != null || cell.top != null || cell.bottom != null ) )
			{
				score += cell.points;
			}
		}
	}
	
	function onCrossRoad(x:Int, y:Int)
	{
		var node = getAt(x, y);
		view.onCross(x, y, node.left != node.top ? Cs.COMPLEX_COMBO.get() : Cs.SIMPLE_COMBO.get() );
		updateUserScore();
	}
	
	function initDraw(t:Trigger)
	{		
		var path = pathMap.get(t.type);
		path.trigger = t;
		path.dirs = [NONE];
		path.lastX = -1;
		path.lastY = -1;
		path.lastDir = NONE;
		path.currentX = t.x;
		path.currentY = t.y;
		
		lastPath = currentPath;
		currentPath = path;
	}
	
	function getTargetScore()
	{
		return 50000 + (api.AKApi.getLevel()-1) * 25000;
	}
	
	function initLevel()
	{
		//EQUILIBRAGE AREA
		var dropBonus = this.rand.random(12) == 0;
		var generator = new LevelGenerator(this.gridData);
		var count = 0;
		switch( api.AKApi.getGameMode() )
		{
			case GM_PROGRESSION: 
				count = if ( api.AKApi.getLevel() > 7 ) 3 else 2;
				var l = gamelevel.get() - 1;
				var p = api.AKApi.getScore() / this.getTargetScore();
				var meanPts = this.getTargetScore() / this.lives.get();
				if( (meanPts * l) > (1.1 * api.AKApi.getScore()) )
					dropBonus = rand.random(2) == 0;
			case GM_LEAGUE: 
				count = if( gamelevel.get() > 4 ) 3 else 2;
		}
		
		var levelInfos = 	if ( api.AKApi.getLevel() == 1 && gamelevel.get() == 1 ) generator.generateTuto(0);
							else if ( api.AKApi.getLevel() == 1 && gamelevel.get() == 2 ) generator.generateTuto(1);
							else generator.generate( count, dropBonus );
		
		triggers = levelInfos.triggers;
		pathMap = levelInfos.paths;
		bonus = levelInfos.bonus;
		kdos = levelInfos.kdos;
		
		for ( trigger in triggers )
		{
			view.setScoreGfxAt(trigger.x, trigger.y, null);
			view.drawTrigger( trigger );
			getAt(trigger.x, trigger.y).points = 0;
		}
		
		for ( b in bonus )
		{
			view.setScoreGfxAt(b.x, b.y, null);
			view.drawBonus( b );
			getAt(b.x, b.y).points = 0;
		}
		
		for ( kdo in kdos )
		{
			view.setScoreGfxAt(kdo.x, kdo.y, null);
			view.drawKdo( kdo );
			getAt(kdo.x, kdo.y).points = 0;
		}
		
		return true;
	}

	//EQUILIBRAGE AREA
	function initGridData()
	{
		switch( api.AKApi.getGameMode() )
		{
			case GM_PROGRESSION: 
				var l = api.AKApi.getLevel();
				GRID_HMAX = GRID_WMAX = if ( l > 12 ) 11 else if ( l > 8 ) 10 else if ( l > 5 ) 9 else if ( l > 1 ) 8 else 7;
				
			case GM_LEAGUE: 
				var l = gamelevel.get();
				GRID_HMAX = GRID_WMAX = if ( l > 10 ) 11 else if ( l > 8 ) 10 else if ( l > 5 ) 9 else if ( l > 1 ) 8 else 7;
		}
		
		var generator = new GridGenerator(GRID_WMAX, GRID_HMAX);
		gridData = 	if ( api.AKApi.getLevel() == 1 && gamelevel.get() == 1 ) generator.cleanTuto(0)
					else if ( api.AKApi.getLevel() == 1 && gamelevel.get() == 2 ) generator.cleanTuto(1)
					else generator.generate();
	}
	
	inline function getAt(x:Int, y:Int)
	{
		var v = if ( x < 0 || x >= GRID_WMAX || y < 0 || y >= GRID_HMAX ) null;
				else gridData[y][x];
		return v;
	}
	
	inline function setAt(x:Int, y:Int, v)
	{
		var r = ( x < 0 || x >= GRID_WMAX || y < 0 || y >= GRID_HMAX );
		if( r ) gridData[y][x] = v;
		return r;
	}
	
	inline function cleanPathNode(data:NodeData, dir:Dirs, path)
	{
		switch( dir )
		{
			case NONE:
			case LEFT, RIGHT:	if ( data.left != null && data.left.trigger == path.trigger ) data.left = null;
								if ( data.right != null && data.right.trigger == path.trigger ) data.right = null;
			case UP, DOWN:		if ( data.top != null && data.top.trigger == path.trigger ) data.top = null;
								if ( data.bottom != null && data.bottom.trigger == path.trigger ) data.bottom = null;
		}
	}
	
	inline function cleanFullPathNode(data:NodeData, path)
	{
		if ( data.left != null && data.left.trigger == path.trigger ) data.left = null;
		if ( data.right != null && data.right.trigger == path.trigger ) data.right = null;
		if ( data.top != null && data.top.trigger == path.trigger ) data.top = null;
		if ( data.bottom != null && data.bottom.trigger == path.trigger ) data.bottom = null;
	}
	
	function cleanPath(p:Path)
	{
		p.completed = false;
		var x = p.trigger.x, y = p.trigger.y;
		for ( d in p.dirs )
		{
			var data = getAt(x, y);
			cleanFullPathNode(data, p);
			switch( d )
			{
				case NONE:
				case LEFT: --x;
				case RIGHT: ++x;
				case UP: --y;
				case DOWN: ++y;
			}
		}
		var data = getAt(x, y);
		cleanPathNode(data, p.lastDir, p);
	}
	
	inline function oppDir(dir:Dirs):Dirs
	{
		return switch( dir )
		{
			case NONE:	NONE;
			case LEFT:	RIGHT;
			case RIGHT: LEFT;
			case UP: 	DOWN;
			case DOWN: 	UP;
		}
	}
	
	function invalidatePathTo( p:Path, x:Int, y:Int )
	{
		while ( p.currentX != x || p.currentY != y )
		{
			cleanPathNode(getAt(p.currentX, p.currentY), p.lastDir, p);
			p.currentX = p.lastX;
			p.currentY = p.lastY;
			cleanPathNode(getAt(p.currentX, p.currentY), oppDir(p.lastDir), p);
			p.dirs.removeLast();
			p.lastDir = p.dirs.last();
			switch( p.lastDir )
			{
				case NONE:	
				case LEFT:	p.lastX = p.currentX + 1;
				case RIGHT: p.lastX = p.currentX - 1;
				case UP: 	p.lastY = p.currentY + 1;
				case DOWN: 	p.lastY = p.currentY - 1;
			}
		}
		var node = getAt(p.currentX, p.currentY);
		cleanPathNode(node, p.lastDir, p);
		switch( p.lastDir )
		{
			case NONE:	
			case LEFT:	node.right = p;
			case RIGHT: node.left = p;
			case UP:	node.bottom = p;
			case DOWN: 	node.top = p;
		}
	}
	
	function invalidatePathLastMove(p:Path)
	{
		invalidatePathTo( p, p.lastX, p.lastY );
		updateUserScore();
	}
	
	var clickState:Bool;
	function handleInteractivity()
	{
		var clicked = try api.AKApi.isClicked() catch (e:Dynamic) false;
		if ( clicked )
		{
			if ( tutoView != null ) 
			{
				tutoView.detach();
				tutoView = null;
			}
			if ( !clickState )
			{
				if ( !api.AKApi.isReplay() )
				{
					var p = view.mouseGridPos;
					if ( p.x >= 0 && p.y >= 0 )
					{
						api.AKApi.emitEvent(EVT_SELECT);
						api.AKApi.emitEvent(p.x);
						api.AKApi.emitEvent(p.y);
					}
				}
				clickState = true;
			}
		}
		else
		{
			if ( clickState )
			{
				clickState = false;
				currentPath = null;
				view.resetMouseGridPos();
			}
		}
	}
	
	public function grabKdo( kdo )
	{
		api.AKApi.takePrizeTokens( kdo.ref );
		kdos.remove(kdo);
		view.grabKdo(kdo);
	}
	
	public function update(render:Bool)
	{	
		frame++;
		tweenie.update();
		delayer.update();
		Tween.updateTweens(1.0);
		mt.deepnight.Particle.update();
		
		switch( state )
		{
			case WAIT:				
				wait--;
				if ( wait == 0 )
				{
					view.fadeOut( view.dispose );
					nextLevel();
					view.fadeIn( function() { state = INIT; } );
					state = TRANSITION;
				}
			
			case INIT:
	
				if ( !api.AKApi.isReplay() )
				{
					if ( api.AKApi.getLevel() == 1 && gamelevel.get() == 1 ) 
					{
						tutoView = new gfx.Tuto();
						tutoView.x = (Cs.VIEW_WIDTH - tutoView.width) / 2;
						tutoView.y = (Cs.VIEW_HEIGHT - tutoView.height) / 2;
						tutoView.gotoAndStop(1);
						tutoView._descTF.text = Texts.tuto1;
						addChild(tutoView);
					}
					else if ( api.AKApi.getLevel() == 1 && gamelevel.get() == 2 )
					{
						tutoView = new gfx.Tuto();
						tutoView.x = (Cs.VIEW_WIDTH - tutoView.width) / 2;
						tutoView.y = (Cs.VIEW_HEIGHT - tutoView.height) / 2;
						tutoView.gotoAndStop(2);
						tutoView._descTF.text = Texts.tuto2;
						addChild(tutoView);
					}
				}
				if ( initLevel() )
				{
					state = PLAY;
				}
			case PLAY:
				
				var pathRedraw = false;
				var eid = api.AKApi.getEvent();
				while ( eid != null ) 
				{ 
					switch(eid) 
					{
						case EVT_MOVE : 
							var mx = api.AKApi.getEvent();
							var my = api.AKApi.getEvent();
							applyPathMove(mx, my);
							pathRedraw = true;
						
						case EVT_CANCEL_MOVE : 
							invalidatePathLastMove(currentPath);
							pathRedraw = true;
						
						case EVT_SELECT :
							var mx = api.AKApi.getEvent();
							var my = api.AKApi.getEvent();
							onMapClick(mx, my);
					}
					eid = api.AKApi.getEvent();
				}
				//
				updateUserScore();
				view.update(pathRedraw);
				//
				handleInteractivity();
				//
				if( currentPath != null )
				{
					if ( !api.AKApi.isReplay() )
					{
						var path = currentPath;
						var mouse = view.mouseGridPos;
						if( (mouse.x >= 0 && mouse.y >= 0 ) && (path.lastDir == NONE || (mouse.x != path.currentX || mouse.y != path.currentY)) ) 
						{
							if ( mouse.x == path.lastX && mouse.y == path.lastY ) 
							{
								api.AKApi.emitEvent(EVT_CANCEL_MOVE);
							}
							else
							{
								var cx = path.currentX;
								var cy = path.currentY;
								var dx = MLib.abs(mouse.x - cx);
								var dy = MLib.abs(mouse.y - cy);
								if( dx > 1 || dy > 1 || (dx != 0 && dy != 0) )
								{
									var moves = slope( cx, cy, mouse.x, mouse.y );
									moves.removeFirst();
									for ( move in moves )
									{
										if ( !checkPathMove(cx, cy, move.x, move.y) )
											break;
										api.AKApi.emitEvent(EVT_MOVE);
										api.AKApi.emitEvent(move.x);
										api.AKApi.emitEvent(move.y);
										cx = move.x;
										cy = move.y;
									}
								}
								else
								{
									if ( checkPathMove(cx, cy, mouse.x, mouse.y) )
									{
										api.AKApi.emitEvent(EVT_MOVE);
										api.AKApi.emitEvent(mouse.x);
										api.AKApi.emitEvent(mouse.y);
									}
								}
							}
						}
					}
				}
				//
				checkLevelCleared();
				//
				switch( api.AKApi.getGameMode() )
				{
					case GM_PROGRESSION:
					case GM_LEAGUE:
						time.add( api.AKApi.const( -1) );
						if ( time.get() == 0 )
						{
							api.AKApi.gameOver(true);
						}
				}
			default:	
		}
		
		var text = switch( api.AKApi.getGameMode() )
		{
			case GM_PROGRESSION:
				var s = mt.kiroukou.tools.StringTools.capitalizeWord( Texts.obj );
				var objectiveText = StringTools.rpad(s + ": " + this.getTargetScore() + "", " ", 20);
				
				var s = mt.kiroukou.tools.StringTools.capitalizeWord( Texts.score );
				var scoreText = StringTools.rpad(s+": " + score + "", " ", 20);
				objectiveText + "       " + scoreText;
			case GM_LEAGUE:
				var s = mt.kiroukou.tools.StringTools.capitalizeWord( Texts.score );
				s+": " + score + " "+Texts.points;
		}
		
		api.AKApi.setStatusText(text, "center");
		
		switch( api.AKApi.getGameMode() )
		{
			case GM_PROGRESSION:
				api.AKApi.setProgression( api.AKApi.getScore() / getTargetScore() );
			case GM_LEAGUE:
				
		}
	}
	
	function checkLevelCleared()
	{
		for ( path in this.pathMap )
			if ( !path.completed ) 
				return;
		var credited = true;
		state = WAIT;
		wait = Cs.WAIT_TIME;
		// we apply the different end-level effects
		for ( b in bonus )
		{
			if ( isIntersection(b.x, b.y) )
			{
				switch( b.k )
				{
					case TIME: 	time.add( Cs.BONUS_TIME );
					case LEVEL: if ( (lives.get() - gamelevel.get()) < Cs.MAX_LIVES.get() ) this.lives.add( api.AKApi.const(1) )
								else credited = false;
				}
				//on faire un feedback visuel
				if( credited ) view.bonusUnlocked( b );
			}
		}
		
		for ( kdo in kdos.copy() )
		{
			var cell = getAt( kdo.x, kdo.y );
			if ( cell.bottom != null || cell.top != null || cell.left != null || cell.right != null )
			{
				this.grabKdo(kdo);
			}
		}
		
		view.scoreExplosion();
	}
	
	function slope( fromX:Int, fromY:Int, toX:Int, toY:Int )
	{
		var l = [];
		var dx = MLib.abs(fromX - toX);
		var dy = MLib.abs(fromY - toY);
		//move
		var ix = MLib.sgn(toX - fromX);
		var iy = MLib.sgn(toY - fromY);
		//
		var x = fromX;
		var y = fromY;
		l.addLast({x:x, y:y});
		while ( x != toX || y != toY )
		{
			if (dx > dy) 
			{
				x += ix;
				dx --;
			}
			else
			{
				y += iy;
				dy --;
			}
			l.addLast({x:x, y:y});
		}
		return l;
	}
	
	function applyPathMove(mx:Int, my:Int)
	{
		var data = getAt(mx, my);
		var dir = 	if( mx != currentPath.currentX )
						if( mx > currentPath.currentX ) Dirs.RIGHT ;
						else Dirs.LEFT;
					else
						if( my > currentPath.currentY ) Dirs.DOWN;
						else Dirs.UP;
		
		var cx = currentPath.currentX;
		var cy = currentPath.currentY;
		var current = getAt(cx, cy);
		switch( dir )
		{
			case NONE:
			case LEFT:
				getAt(cx, cy).left = currentPath;
				getAt(mx, my).right = currentPath;
				
			case RIGHT:
				getAt(cx, cy).right = currentPath;
				getAt(mx, my).left = currentPath;
				
			case UP:
				getAt(cx, cy).top = currentPath;
				getAt(mx, my).bottom = currentPath;
				
			case DOWN:
				getAt(cx, cy).bottom = currentPath;
				getAt(mx, my).top = currentPath;
		}
		//
		currentPath.dirs.addLast(dir);
		currentPath.lastDir = dir;
		currentPath.lastX = cx;
		currentPath.lastY = cy;
		currentPath.currentX = mx;
		currentPath.currentY = my;
		//
		view.drawHighlight(mx, my);
		//
		if ( isIntersection(currentPath.lastX, currentPath.lastY) )
		{
			onCrossRoad(currentPath.lastX, currentPath.lastY);
		}
		// check path finished
		if ( triggers.exists( mx + "_" + my ) )
		{
			var trigger = triggers.get(mx + "_" + my);
			if ( trigger != currentPath.trigger && trigger.type == currentPath.trigger.type )
			{
				currentPath.completed = true;
				view.onPathCompleted(currentPath);
			}
		}
	}
	
	function checkPathMove( cx:Int, cy:Int, tx:Int, ty:Int ):Bool
	{
		var data = getAt(tx, ty);
		if ( data == null ) return false;
		//we check if path was finished
		if ( triggers.exists(cx + "_" + cy) )
		{
			var trigger = triggers.get(cx + "_" + cy);
			if ( trigger != currentPath.trigger && trigger.type == currentPath.trigger.type ) return false;
		}
		
		if ( triggers.exists( tx + "_" + ty ) ) 
		{
			var trigger = triggers.get(tx + "_" + ty);
			if ( trigger.type != currentPath.trigger.type ) return false;
			if ( trigger == currentPath.trigger ) return false;
		}
		
		var dir = 	if( tx != cx )
						if( tx > cx ) Dirs.RIGHT ;
						else Dirs.LEFT;
					else
						if( ty > cy ) Dirs.DOWN;
						else Dirs.UP;
		
		var current = getAt(cx, cy);
		switch( dir )
		{
			case NONE:
			case LEFT:
				if (data.left != null || data.right != null ) return false;
			case RIGHT:
				if (data.left != null || data.right != null ) return false;
			case UP:
				if ( data.top != null || data.bottom != null ) return false;
			case DOWN:
				if ( data.top != null || data.bottom != null ) return false;
		}
		return true;
	}
	
	function isIntersection(mx:Int, my:Int):Bool
	{
		var current = getAt(mx, my);
		if ( current == null ) return false;
		return current.left != null && current.right != null && current.top != null && current.bottom != null;
	}
}
