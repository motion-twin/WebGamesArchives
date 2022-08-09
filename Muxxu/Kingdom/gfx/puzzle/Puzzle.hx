import data.PuzzleData;
private typedef MC = flash.MovieClip;
import Level;
import Anims;

class Puzzle implements haxe.Public {

	var dm : mt.DepthManager;
	var bg : MC;
	var level : Level;
	var select : {
		var mc : MC;
		var x : Int;
		var y : Int;
		var horiz : Bool;
		var lock : Bool;
		var hide : Bool;
	};
	var swapMap : Array<Array<Bool>>;
	var swap : { x : Int, y : Int };
	var nextPieces : Array<Int>;
	var anims : List<{ function update() : Bool; }>;
	var wrongSwaps : Int;

	function new(root) {
		wrongSwaps = 0;
		dm = new mt.DepthManager(root);
		bg = dm.attach("bg",0);
		bg._y = Piece.YBASE;
		level = new Level();
		anims = new List();
		for( x in 0...Level.SIZE )
			for( y in 0...Level.SIZE )
				level.set(x,y,initPiece(DATA._t[x][y],x,y));
		var me = this;
		bg.onRollOut = function() { me.select.hide = true; me.updateSelector(); };
		bg.onMouseMove = function() { me.select.hide = false; me.updateSelector(); };
		bg.onMouseUp = executeAction;
		select = {
			mc : dm.attach("selector",2),
			x : 0,
			y : 0,
			horiz : true,
			hide : true,
			lock : DATA._act <= 0,
		};
		buildSwapMap();
		updateSelector();
	}

	function buildSwapMap() {
		swapMap = new Array();
		var swaps = new Array();
		for( x in 0...Level.SIZE )
			swapMap = new Array();
		var canSwap = false;
		for( x in 0...Level.SIZE )
			for( y in 0...Level.SIZE )
				if( level.checkSwapH(x,y,1) || level.checkSwapH(x,y,-1) || level.checkSwapV(x,y,1) || level.checkSwapV(x,y,-1) ) {
					swapMap[x][y] = true;
					swaps.push({ x : x, y : y });
					canSwap = true;
				}
		if( canSwap ) {
			var r = new mt.Rand(0);
			r.initSeed(DATA._s);
			swap = swaps[r.random(swaps.length)];
		} else {
			select.lock = true;
			var cmd : PuzzleCommand = {
				_s : DATA._s,
				_x : -1,
				_y : -1,
				_h : false,
			};
			Codec.load(DATA._url,cmd,onResetAll);
		}
	}

	function initPiece( k, x, y ) {
		var mc = dm.attach("icons",1);
		mc.gotoAndStop(k + 1);
		return new Piece(mc,x,y,level.pieces[k]);
	}

	function resetFilters() {
		for( x in 0...Level.SIZE )
			for( y in 0...Level.SIZE ) {
				var mc = level.tbl[x][y].mc;
				if( mc.filters.length > 0 ) mc.filters = [];
			}
	}

	function updateSelector() {
		if( select.lock ) {
			resetFilters();
			select.mc._visible = false;
			return;
		}
		var px = Std.int(bg._xmouse/Piece.SIZE);
		var py = Std.int(bg._ymouse/Piece.SIZE);
		var dx = bg._xmouse % Piece.SIZE, dy = bg._ymouse % Piece.SIZE;
		var minus = dx + dy < Piece.SIZE;
		var diag = dx > dy;
		var horiz;
		if( minus ) {
			if( diag ) {
				py--;
				horiz = false;
			} else {
				px--;
				horiz = true;
			}
		} else
			horiz = diag;
		if( px < 0 ) px = 0;
		if( py < 0 ) py = 0;
		if( px >= Level.SIZE ) px = Level.SIZE - 1;
		if( py >= Level.SIZE ) py = Level.SIZE - 1;
		if( px == Level.SIZE - 1 && horiz ) px = Level.SIZE - 2;
		if( py == Level.SIZE - 1 && !horiz ) py = Level.SIZE - 2;
		select.x = px;
		select.y = py;
		select.horiz = horiz;
		select.mc._x = (px + (horiz?1:0.5)) * Piece.SIZE;
		select.mc._y = (py + (horiz?0.5:1)) * Piece.SIZE + Piece.YBASE;
		select.mc.gotoAndStop(horiz?1:2);
		select.mc._visible = !select.hide;
		resetFilters();
		level.tbl[swap.x][swap.y].mc.filters = [new flash.filters.GlowFilter(0xFFFFFF,0.7,4,4,20)];
		if( !select.hide ) {
			var p1 = level.tbl[select.x][select.y];
			var p2 = level.tbl[select.x+(select.horiz?1:0)][select.y+(select.horiz?0:1)];
			var glow = new flash.filters.GlowFilter(0xFFFFFF,100,8,8,10);
			p1.mc.filters = [glow];
			p2.mc.filters = [glow];
		}
	}

	function executeAction() {
		if( select.lock || select.hide ) return;
		if( !level.canSwap(select.x,select.y,select.horiz) ) {
			wrongSwaps++;
			if( wrongSwaps >= 2 ) {
				wrongSwaps = 0;
				flash.external.ExternalInterface.call("wrongSwaps");
			}
			return;
		}
		select.lock = true;
		select.mc._visible = false;
		var cmd : PuzzleCommand = {
			_x : select.x,
			_y : select.y,
			_h : select.horiz,
			_s : DATA._s,
		};
		DATA._s++;
		Codec.load(DATA._url,cmd,onActionAnswer);
		resetFilters();
	}

	function onActionAnswer( answer : PuzzleAnswer ) {
		if( answer._fill.length == 0 ) {
			flash.Lib.getURL(answer._url,"_self");
			return;
		}
		ANSWER = answer;
		anims.add(new SwapAnim());
	}

	function onResetAll( answer : PuzzleAnswer ) {
		ANSWER = answer;
		for( x in 0...Level.SIZE )
			for( y in 0...Level.SIZE )
				anims.add(new FadeAnim(level.tbl[x][y].mc));
		var me = this;
		anims.add(new WaitAnim(function() {
			me.level.reset();
			me.gravity();
		}));
	}

	function explode() {
		var combos = level.checkExplodes();
		if( combos.isEmpty() ) {
			nextTurn();
			return;
		}
		anims.add(new DestroyAnim(combos,ANSWER._res.shift()));
	}

	function gravity() {
		var nfalls = level.gravity();
		anims.add(new GravityAnim());
		loop();
	}

	function refill() {
		var fills = ANSWER._fill.shift();
		if( fills == null ) {
			nextTurn();
			return;
		}
		anims.add(new RefillAnim(fills));
	}

	function nextTurn() {
		if( ANSWER._url != null ) {
			anims.add(new WaitAnim(callback(flash.Lib.getURL,ANSWER._url,"_self")));
			return;
		}
		anims.add(new WaitAnim(function() flash.external.ExternalInterface.call("eval",DATA._reload)));
	}

	function loop() {
		mt.Timer.update();
		for( a in anims )
			if( !a.update() )
				anims.remove(a);
	}

	static var DATA : PuzzleData;
	static var ANSWER : PuzzleAnswer;
	static var inst : Puzzle;

	static function main() {
		DATA = Codec.getData("data");
		inst = new Puzzle(flash.Lib.current);
		flash.Lib.current.onEnterFrame = inst.loop;
	}

}