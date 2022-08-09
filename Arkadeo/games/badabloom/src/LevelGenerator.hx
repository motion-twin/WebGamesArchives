package ;

import Game;
import mt.MLib;
using mt.Std;
class LevelGenerator
{
	public var GRID_HMAX(get_gridHMax, null):Int; 
	inline function get_gridHMax() { return Game.GRID_HMAX; }
	public var GRID_WMAX(get_gridWMax, null):Int; 
	inline function get_gridWMax() { return Game.GRID_WMAX; }
	public var TILE_SIZE(get_tileSize, null):Int;
	inline function get_tileSize() { return Game.TILE_SIZE; }
	
	var gridData:Array<Array<NodeData>>;
	#if haxe3
	var pathMap:Map<Int, Path>;
	var triggers:haxe.ds.StringMap<Trigger>;
	#else
	var pathMap:IntHash<Path>;
	var triggers:Hash<Trigger>;
	#end
	
	public function new(grid) 
	{
		gridData = grid;
		
		#if haxe3
		triggers = new StringMap();
		#else
		triggers = new Hash();
		#end
		
		#if haxe3
		pathMap = new Map();
		#else
		pathMap = new IntHash();
		#end
	}
	
	inline function getAt(x:Int, y:Int)
	{
		var v = if ( x < 0 || x >= GRID_WMAX || y < 0 || y >= GRID_HMAX ) null;
				else gridData[y][x];
		return v;
	}
	
	function createTrigger(type:Int, name:String):Trigger
	{
		var x:Int, y:Int;
		do
		{
			x = mt.MLib.randRange(1, GRID_WMAX-1, Game.me.rand.rand);
			y = mt.MLib.randRange(1, GRID_HMAX-1, Game.me.rand.rand);
		} while ( getAt(x, y) == null || triggers.exists(x + "_" + y) );
		return { x:x, y:y, type:type, name:name };
	}
	
	inline function key(a:Trigger)
	{
		return a.x + "_" + a.y;
	}
	
	function isValidPath( path )
	{
		return path != null && path.length >= 4; 
	}
	
	function createPath(type:Int)
	{
		var triggerA = createTrigger(type, "trigger_"+type+"_A"); 
		triggers.set(key(triggerA), triggerA);
		
		var triggerB = createTrigger(type, "trigger_"+type+"_B"); 
		triggers.set(key(triggerB), triggerB);
		
		var pf = new mt.kiroukou.game.PathFinder(this.gridData, false);
		var path = pf.resolve( triggerA.x, triggerA.y, triggerB.x, triggerB.y, function(x, y, node) { 
			if( node == null ) return false;
			else if( x == triggerA.x && y == triggerA.y ) return true;
			else if( x == triggerB.x && y == triggerB.y ) return true;
			else return !triggers.exists(x + "_" + y);
		} );
		
		if( !isValidPath(path) ) 
		{
			triggers.remove(key(triggerA));
			triggers.remove(key(triggerB));
			pf.dispose();
			return null;
		}
		
		//check if other path are still correct
		for( p in pathMap )
		{
			var path = pf.resolve( p.triggerA.x, p.triggerA.y, p.triggerB.x, p.triggerB.y, function(x, y, node) { 
				if( node == null ) return false;
				else if( x == p.triggerA.x && y == p.triggerA.y ) return true;
				else if( x == p.triggerB.x && y == p.triggerB.y ) return true;
				else return !triggers.exists(x + "_" + y);
			} );
			
			if( !isValidPath(path) ) 
			{
				triggers.remove(key(triggerA));
				triggers.remove(key(triggerB));
				pf.dispose();
				return null;
			}
		}
		
		return {a:triggerA, b:triggerB};
	}
	
	public function generateTuto( level : Int )
	{
		var bonusList = [];
		if ( level == 0 ) 
		{
			var triggerA:Trigger = { x:0, y:GRID_HMAX >> 1, type:0, name:"trigger_0_A" };
			var triggerB:Trigger = { x:GRID_WMAX-1, y:GRID_HMAX >> 1, type:0, name:"trigger_0_B" }
			triggers.set(key(triggerA), triggerA);
			triggers.set(key(triggerB), triggerB);
			
			var path:Path = { trigger:triggerA, dirs:[], lastX:-1, lastY:-1, currentX:-1, currentY:-1, lastDir:Dirs.NONE, completed:false, triggerA:triggerA, triggerB:triggerB };
			pathMap.set(triggerA.type, path);
			triggerA.path = path;
			triggerB.path = path;
		}
		else if( level == 1 )
		{
			var triggerA:Trigger = { x:0, y:GRID_HMAX >> 1, type:0, name:"trigger_0_A" };
			var triggerB:Trigger = { x:GRID_WMAX-1, y:GRID_HMAX >> 1, type:0, name:"trigger_0_B" }
			triggers.set(triggerA.x + "_" + triggerA.y, triggerA);
			triggers.set(triggerB.x + "_" + triggerB.y, triggerB);
			
			var path:Path = { trigger:triggerA, dirs:[], lastX:-1, lastY:-1, currentX:-1, currentY:-1, lastDir:Dirs.NONE, completed:false, triggerA:triggerA, triggerB:triggerB };
			pathMap.set(triggerA.type, path);
			triggerA.path = path;
			triggerB.path = path;			
			
			var triggerC:Trigger = { x:GRID_WMAX>>1, y:0, type:1, name:"trigger_1_A" };
			var triggerD:Trigger = { x:GRID_WMAX>>1, y:GRID_HMAX-1, type:1, name:"trigger_1_B" }
			triggers.set(triggerC.x + "_" + triggerC.y, triggerC);
			triggers.set(triggerD.x + "_" + triggerD.y, triggerD);
			
			var path:Path = { trigger:triggerA, dirs:[], lastX:-1, lastY:-1, currentX:-1, currentY:-1, lastDir:Dirs.NONE, completed:false, triggerA:triggerC, triggerB:triggerD };
			pathMap.set(triggerC.type, path);
			triggerC.path = path;
			triggerD.path = path;
			
			bonusList.push( { x:GRID_WMAX >> 1, y:GRID_HMAX >> 1, k:BonusKind.LEVEL } );
		}
		else
		{
			throw "impossible";
		}
		
		return { paths:pathMap, triggers:triggers, bonus:bonusList, kdos:[] };
	}
	
	public function generate(complexity:Int, ?dropBonus:Bool = false)
	{
		var id = 0;
		var count = complexity;
		while( id < count )
		{
			var p = createPath(id);
			if( p != null )
			{
				id++;
				//
				var path:Path = { trigger:p.a, dirs:[], lastX:-1, lastY:-1, currentX:-1, currentY:-1, lastDir:Dirs.NONE, completed:false, triggerA:p.a, triggerB:p.b };
				pathMap.set(p.a.type, path);
				p.a.path = path;
				p.b.path = path;
			}
		}
		
		var bonusList:Array<{x:Int, y:Int, k:BonusKind}> = [];
		if( dropBonus )
		{
			var x:Int, y:Int;
			do 
			{
				x = MLib.randRange(1, GRID_WMAX - 2, Game.me.rand.rand);
				y = MLib.randRange(1, GRID_HMAX - 2, Game.me.rand.rand);
			} while ( triggers.exists(x + "_" + y) || Lambda.exists( bonusList, function(e) return e.x == x && e.y == y ) );
			
			var k = switch( api.AKApi.getGameMode() )
			{
				case GM_PROGRESSION: BonusKind.LEVEL;
				case GM_LEAGUE: BonusKind.TIME;
			}
			bonusList.push( { x:x, y:y, k:k} );
		}
		
		var kdoList : Array<{ ref:api.AKProtocol.SecureInGamePrizeTokens, x:Int, y:Int, amount:Int, frame:Int }>= [];
		var oTokens = api.AKApi.getRealInGamePrizeTokens();
		var tokens = [];
		switch( api.AKApi.getGameMode() )
		{
			case GM_PROGRESSION: 
				for ( i in 0...MLib.min(3, oTokens.length) ) 
				{
					var n = oTokens.getRandom(Game.me.rand.random);
					oTokens.remove(n);
					tokens.addLast(n);
				}
			case GM_LEAGUE: 
				var fTokens = Lambda.array(Lambda.filter( oTokens, function(t) return api.AKApi.getScore() >= t.score.get() ));
				for ( i in 0...MLib.min(3, fTokens.length) ) 
				{
					var n = fTokens.getRandom(Game.me.rand.random);
					tokens.addLast(n);
					fTokens.remove(n);
				}
		}
		
		for( token in tokens )
		{
			var x:Int, y:Int;
			do 
			{
				x = MLib.randRange(0, GRID_WMAX - 1, Game.me.rand.rand);
				y = MLib.randRange(0, GRID_HMAX - 1, Game.me.rand.rand);
			} while ( triggers.exists(x + "_" + y) || Lambda.exists( bonusList, function(e) return e.x == x && e.y == y ) || Lambda.exists(kdoList, function(e) return e.x == x && e.y == y) );
			kdoList.push( { ref:token, x:x, y:y, amount:token.amount.get(), frame:token.frame } );
		}
		
		return { paths:pathMap, triggers:triggers, bonus:bonusList, kdos:kdoList };
	}
	
}