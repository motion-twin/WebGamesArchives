

class Cs {//}

	static public var mcw = 300;
	static public var mch = 300;

	static public var DIR = [[1,0],[0,1],[-1,0],[0,-1]];

	// GFX VALUE
	static public var CARD_WIDTH = 		37;
	static public var CARD_HEIGHT = 	46;
	static public var MARGIN_CARD_WIDTH =	10;
	static public var MARGIN_CARD_HEIGHT =	8;
	static public var MARGIN_TOP =		13;
	static public var MARGIN_LEFT =		13;
	static public var HAND_Y =		242;
	static public var COLORS = [0x00CC00,0x8800AA];

	// GAMEPLAY VALUE
	static public var XMAX = 6;
	static public var YMAX = 4;
	static public var CARD_MAX = 8;


	// COMPUTED VALUE

	static public function getX(px:Int){
		return MARGIN_LEFT + px*( CARD_WIDTH + MARGIN_CARD_WIDTH );
	}
	static public function getY(py:Int){
		return MARGIN_TOP + py*( CARD_HEIGHT + MARGIN_CARD_HEIGHT );
	}

//{
}
