typedef GameData = {
	var _u : Int;
	var _s : String;
	var _x : Int;
	var _y : Int;
	var _z : Null<Int>;
	var _pow : Int;
	var _force : Bool;
	var _inv : Array<Null<Int>>;
	var _imax : Int;
	var _uid : Int;
}

typedef MapData = {
	var _s : String;
	var _x : Int;
	var _y : Int;
	var _flags : Int;
	var _dol : List<{ _x : Int, _y : Int, _b : haxe.io.Bytes }>;
}

enum _GO {
	GOWater;
	GOLava;
}

enum _Cmd {
	CWatch( mx : Int, my : Int );
	CGenLevel( mx : Int, my : Int, data : haxe.io.Bytes );
	CSetBlocks( data : Array<Int> );
	CSavePos( x : Int, y : Int, z : Int );
	CLoad( mx : Int, my : Int );
	CGameOver( g : _GO );
	CDoCheck( px : Int, py : Int, pz : Int );
	CPing( i : Int );
	CActiveKube( x : Int, y : Int, z : Int );
	CUndo;
}

enum _Answer {
	ABlocks( a : Array<Null<Int>> );
	ASet( x : Int, y : Int, z : Int, k : Int );
	APosSaved;
	AMap( mx : Int, my : Int, data : haxe.io.Bytes, patches : haxe.io.Bytes );
	AGenerate( mx : Int, my : Int );
	ARedirect( url : String );
	AMessage( text : String, error : Bool );
	ANothing;
	AValue( v : Dynamic );
	AShowError( text : String );
	APong( i : Int );
	ASetMany( a : Array<Int> );
}

enum BlockType {
	BTInvisible;
	BTAlpha;
	BTTransp;
	BTModel;
	BTWater; // before full
	BTFull; // last
}

enum BlockSpecial {
	BSNone;
	BSLight;
}

@:build(mt.data.Mods.build("blocks.ods","blocks","id",{ prefix : "B" }))
enum BlockKind {
}

class Const {
	
	public static inline var FBITS = 4;
	public static inline var PREC = 1 << FBITS;
	public static inline var POWER = 10000;
	
	public static inline var BITS = 7;
	public static inline var ZBITS = 7;
	
	public static inline var MASK = (1 << BITS) - 1;
	public static inline var ZMASK = (1 << ZBITS) - 1;
	
	public static inline var SIZE = 1 << BITS;
	public static inline var ZSIZE = 1 << ZBITS;
	public static inline var TSIZE = SIZE * SIZE * ZSIZE;
	
	public static inline var Z = 0;
	public static inline var X = ZBITS;
	public static inline var Y = ZBITS + BITS;
	public static inline var DX = 1 << X;
	public static inline var DY = 1 << Y;
	public static inline var DZ = 1 << Z;
	
	public static inline var BLOCK_POWER = Std.int(POWER / 125);
	public static inline var SAVE_DIST = 15;

}
