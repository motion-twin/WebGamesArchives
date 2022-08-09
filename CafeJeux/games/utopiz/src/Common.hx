enum Msg {
	Init(b:Bool);
	AddBlock( type : BlockType, bottom : Bool );
	EndBlock( type : BlockType, bottom : Bool );	
}

enum BlockType {
	BAttack;
	BDefense;
	BBuilder;
	BSupply;
}

class Const {

	public static var WIDTH = 300;
	public static var XSCALE = 100.0;
	public static var YSCALE = 100.0;
	public static var BLOCK_HEIGHT = 24;
	
	public static var MAXTURNS = 6;
	public static var DP_BG = 0;	
	public static var DP_BLOCK = 1;
	public static var DP_CHOICEBAR = 2;
	
	public static var TURN_TOKENS = 2;
	public static var TURN_ACTIONS = 1;
	
	public static var COLOR1 = 0xF5CB23;
	public static var COLOR2 = 0xC66C31;
	
	public static function getType( t  ) : BlockType {
		switch(t) {
			case 0 : return BAttack;
			case 1 : return BDefense;
			case 2 : return BBuilder;
			case 3 : return BSupply;
		}
		return null;
	}
	
}
