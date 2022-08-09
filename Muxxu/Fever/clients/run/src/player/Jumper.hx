package player;
import mt.bumdum9.Lib;

class Jumper extends flash.display.Sprite {//}
	
	
	static var SPEED = 0.01;
	
	static var XMAX = 10;
	static var YMAX = 10;
	static var MAP_SIDE = 2000;
	
	static var maps:Array<flash.display.BitmapData>;
	var grid:flash.display.Sprite;
	
	var adv:Adventure;
	var gameId:Int;
	
	public var coef:Float;
	var bx:Float;
	var by:Float;
	var ddx:Float;
	var ddy:Float;

	public function new(from, to, adv ) {
		this.adv = adv;
		gameId = to;
		adv.dm.add(this, Player.DP_GAME);
		super();
		
		if( maps == null ) initMaps();
		while(loadMapId < XMAX * YMAX) loadMap();

		
		initGrid();
		coef = 0;
		
		//
		var a = getGamePos(from);
		var b = getGamePos(to);
		
		bx = a.x;
		by = a.y;
		ddx = Num.hMod(b.x - a.x, 5);
		ddy = Num.hMod(b.y - a.y, 5);

		//
		//display();
		
		/*
		// HACK
		for( i in 0...400 ) {
			var game = Game.getInstance(42);
			game.init(Math.random());
		}
		*/
	
	}
	function initGrid() {
		grid = new flash.display.Sprite();
		for( k in 0...4) {
			for( i in 0...4 ){
				var map = maps[i];
				var sp = new flash.display.Bitmap(map);
				grid.addChild(sp);
				sp.x = (i % 2) * MAP_SIDE;
				sp.y = Std.int(i / 2) * MAP_SIDE;
				sp.x += (k % 2) * MAP_SIDE*2;
				sp.y += Std.int(k / 2) * MAP_SIDE*2;
			}
		}
		addChild(grid);
	}
		
	public function update() {

		coef = Math.min(coef + SPEED, 1);
		display();
		if( coef == 1 ) {
			adv.initGame();
			kill();
		}
		
	}
	function display() {
		var cc = Math.sin(coef*Math.PI);
		var scale = 1 / (1 + cc * 9);
		grid.scaleX = grid.scaleY = scale;

		var x = bx + coef * ddx;
		var y = by + coef * ddy;
		//var mx = (Player.WIDTH - Game.WIDTH * scale) * 0.5;
		//var my = (Player.HEIGHT - Game.HEIGHT * scale) * 0.5;
		var mx = (Game.WIDTH - Game.WIDTH * scale) * 0.5;
		var my = (Game.HEIGHT - Game.HEIGHT * scale) * 0.5;
		
		grid.x = mx - x * (Game.WIDTH * scale);
		grid.y = my -y * (Game.HEIGHT * scale);
		
		var side = (MAP_SIDE * 2) * scale;
		
		grid.x = Num.sMod(grid.x,side)-side;
		grid.y = Num.sMod(grid.y, side) - side;
		
		grid.y += 18;
		
	}
	

	// MAPS
	static public function initMaps() {
		maps = [];
		for( i in 0...4 ){
			var sp = new flash.display.Bitmap();
			var bmp = new flash.display.BitmapData(MAP_SIDE, MAP_SIDE, false, 0xFFFFFF00);
			maps.push(bmp);
		}
	}
	static public function drawGame(game:Game) {
		var pos = getGamePos(game.id);
		
		var mid = 0;
		var lim = 5;
		if( pos.x >= lim ) {
			pos.x -= lim;
			mid++;
		}
		if( pos.y >= lim ) {
			pos.y -= lim;
			mid+=2;
		}
		var m = new flash.geom.Matrix();
		var x = pos.x * Game.WIDTH;
		var y = pos.y * Game.HEIGHT;
		m.translate(x, y);
		maps[mid].draw(game, m,null,null,new flash.geom.Rectangle(x,y,Game.WIDTH,Game.HEIGHT));
	}
	static public function drawGameId(id) {
		var game = Game.getInstance(id);
		game.init(0);
		drawGame(game);
		game.kill();
	}
		
	static function getGamePos(id:Int) {
		return {
			x: (id%XMAX),
			y: Std.int(id/XMAX)%YMAX,
		}
	}
	public static var loadMapId = 0;
	static public function loadMap() {
		if( loadMapId == XMAX*YMAX ) return false;
		drawGameId(loadMapId);
		loadMapId++;
		return true;
	}
	
	//
	public function kill() {
		parent.removeChild(this);
	}
		
//{
}