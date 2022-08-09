package ;

typedef Bitmap = flash.display.Bitmap;
typedef BitmapData = flash.display.BitmapData;
typedef Sprite = flash.display.Sprite;
typedef Shape = flash.display.Shape;
typedef MovieClip = flash.display.MovieClip;
typedef Rectangle = flash.geom.Rectangle;
typedef Point = flash.geom.Point;
typedef Matrix = flash.geom.Matrix;
typedef DisplayObject = flash.display.DisplayObject;
typedef DisplayContainer = flash.display.DisplayObjectContainer;
typedef Vec2 = mt.kiroukou.math.Vec2;
typedef Vec3 = mt.kiroukou.math.Vec3;
typedef MLib = mt.kiroukou.math.MLib;
typedef Key = flash.ui.Keyboard;

typedef Grid<T> = Array<Array<T>>;

#if standalone

enum GameMode {
	GM_LEAGUE;
	GM_PROGRESSION;
}

class SecureInGamePrizeTokens {
	var amount : AKConst;
	var score : AKConst;
	public function new( p_amount:Int, p_score:Int ) {
		this.amount = AKApi.const(p_amount);
		this.score = AKApi.const(p_score);
	}
}

class AKConst {
	var v: Int;
	public function new(val:Int) {
		this.v = val;
	}
	public function get():Int {
		return this.v;
	}
}

class AKApi {
	public static function const( v : Int ) : AKConst {
		return new AKConst(v);
	}

	public static function getGameMode():GameMode {
		return GM_LEAGUE;
	}

	public static function getInGamePrizeTokens() {
		return [ new SecureInGamePrizeTokens(5, 0) ];
	}

	public static function takePrizeTokens( t : SecureInGamePrizeTokens) {
		//TODO
	}

	static var score:AKConst;
	public static function getScore():Int {
		return score.get();
	}
	public static function setScore(score:AKConst) {
		AKApi.score = score;
	}
}

#end

enum MoveDir {
	MRight;
	MUp;
	MLeft;
	MDown;
}

enum GameStep {
	SInitGame;
	SLevelInit;
	SProcessing;
	SInteractive;
	SAnim;
	STransition;
	SGameOver;
	SFinish;
}

enum CollisionFlags {
	CTop;
	CBottom;
	CLeft;
	CRight;
}

enum CellFlags {
	Home;
	Boy;
	Girl;
	Border;
	Block;
	NoSkin;
	Lake;
	Forest;
	ExtendedCollision;
	Target;
	Kdo;
	GeneratorLocked;
}

class Lib implements haxe.Public
{
	static var P_ZERO = new Point(0, 0);
	static var M_IDENTITY = new Matrix();

	static var GRID_WMAX:Int = 16;
	static var GRID_HMAX:Int = 12;
	
	static var MAX_LEVEL:Int = 20;
	
	static var GRID_REAL_WMAX:Int = GRID_WMAX-1;
	static var GRID_REAL_HMAX:Int = GRID_HMAX-1;

	static var GRID_MID_WMAX:Int = GRID_WMAX >> 1;
	static var GRID_MID_HMAX:Int = GRID_HMAX >> 1;
	
	static var TILE_SIZE = 32;
	static var TILE_MID_SIZE = TILE_SIZE >> 1;
	
	static var WIDTH = GRID_WMAX * TILE_SIZE;
	static var HEIGHT = GRID_HMAX * TILE_SIZE;
	
	inline static var STAGE_WIDTH = 600;
	inline static var STAGE_HEIGHT = 480;
	
	static var MOVES_DIRS = [MUp, MRight, MDown, MLeft];
	
	inline static var SELECTION_FILTER_COLOR = 0xFFFFFF;
	
	inline static var KDO_COLORS = [0xB1F707, 0xFFA800, 0x00E0FF, 0xC46FE5, 0x3B3C3C];
	
	static function setGridSize( width, height )
	{
		GRID_WMAX = width;
		GRID_HMAX = height;
		
		GRID_REAL_WMAX = GRID_WMAX-1;
		GRID_REAL_HMAX = GRID_HMAX-1;
		
		GRID_MID_WMAX = GRID_WMAX >> 1;
		GRID_MID_HMAX = GRID_HMAX >> 1;
		
		WIDTH = GRID_WMAX * TILE_SIZE;
		HEIGHT = GRID_HMAX * TILE_SIZE;
	}
	
	static function snapshot(clip:DisplayObject) : Bitmap
	{
		var bounds = clip.getBounds(clip);
		var b = new BitmapData(Std.int(.5+bounds.width), Std.int(.5+bounds.height), true, 0x0);
		var m = new Matrix();
		m.translate( -bounds.x, -bounds.y );
		b.draw(clip, m, clip.transform.colorTransform);
		var bmp = new Bitmap(b);
		bmp.x = bounds.x;
		bmp.y = bounds.y;
		return bmp;
	}
	
	inline static function isValidCoord( x : Int, y : Int )
	{
		return MLib.inRange( x, 0, Lib.GRID_WMAX - 1 ) && MLib.inRange( y, 0, Lib.GRID_HMAX - 1 );
	}

	inline static function isBorder(x:Int, y:Int)
	{
		return x==0 || x==GRID_WMAX-1 || y==0 || y==GRID_HMAX-1;
	}

	inline static function getCoord( cell : GridCell, center : Bool = true )
	{
		return getCoord_XY(cell.x, cell.y, center);
	}
	
	inline static function getCoord_XY( x : Int, y : Int, center : Bool = false )
	{
		return new Vec2( x * Lib.TILE_SIZE + (center ? Lib.TILE_MID_SIZE:0), y * Lib.TILE_SIZE + (center?Lib.TILE_MID_SIZE:0) );
	}

	static var MOVES = [[1, 0], [0, -1], [-1, 0], [0, 1]];
	inline static function getDir( move : MoveDir )
	{
		return MOVES[ Type.enumIndex(move) ];
	}
	
	static function getOppositeCol( col : CollisionFlags )
	{
		return switch( col )
		{
			case CLeft: CRight;
			case CRight: CLeft;
			case CTop: CBottom;
			case CBottom: CTop;
		}
	}
	
	static function getOppositeMove( move : MoveDir )
	{
		return switch( move )
		{
			case MLeft: MRight;
			case MRight: MLeft;
			case MUp: MDown;
			case MDown: MUp;
		}
	}
}
